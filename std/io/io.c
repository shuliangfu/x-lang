/**
 * std/io/io.c — 舒 IO 后端统一入口（分析/舒IO实现路线图.md 阶段 1/2）
 *
 * 与 std.io .su（core/driver/mod）同目录；供 std.io.core 调用的 C 侧读写实现。
 * 阶段 1：按平台接入 io_uring（Linux）/ kqueue（macOS）/ IOCP（Windows）；失败或不可用时回退到 read/write。
 * 链接用户程序（-o exe）时由编译器链入本目录产出的 io.o；Linux 下需 -luring -lpthread。
 *
 * 零拷贝：写路径（io_write）直接使用调用方 buf，无库内拷贝；读零拷贝由 io_read_ptr/io_read_ptr_len 提供。
 * ZC-2：macOS dispatch_data / Linux mmap 绝对视图；read_ptr_gen 校验跨 read_ptr 调用生命周期。
 *
 * Linux io_uring 调优（NEXT IO-A3/A4）：
 *   SHU_IO_URING_SQPOLL=1（默认）— 尝试 SQPOLL + fixed files；0 关闭。
 *   SHU_IO_URING_MULTISHOT_ACCEPT=1（默认）— 内核支持时用 multishot accept（IO-A4）。
 *   SHU_IO_URING_PROVIDE_BUFFERS=1（默认）— ZC-1 Provided Buffers（Linux 5.19+）。
 *   connect/accept 成功后自动 io_uring_prefetch_fd（SQPOLL fixed files 槽预热）。
 *   SHU_IO_URING_RING_ENTRIES — ring 深度（64..4096，默认 512）。
 *   SHU_IO_ASYNC_SLOTS — IO-A5 read/write async 并行槽数（1..32，默认 8）。
 *   IO-A5 v3：shu_io_poll_async_completions 收割 CQE 至 slot 并唤醒 async scheduler。
 */

/* Linux io_uring：须在任意 #include 之前定义，否则 liburing 缺 cpu_set_t/loff_t（Alpine/musl）。 */
#if defined(__linux__) && !defined(_GNU_SOURCE)
#define _GNU_SOURCE
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/** IO-A5：io_uring 完成时唤醒 async IO 等待队列（weak；链 scheduler.o 时由强符号覆盖）。 */
void shu_async_io_completions_ready(unsigned n) __attribute__((weak));
void shu_async_io_completions_ready(unsigned n) {
    (void)n;
}

/** 在 reap CQE 后通知 async scheduler（got 为本次完成数）。 */
static void shu_io_async_notify_cq(unsigned got) {
    if (got > 0)
        shu_async_io_completions_ready(got);
}

#define IO_FIXED_MAX 8
/* 阶段 2 超越：ring 扩大；默认 512，可用 SHU_IO_URING_RING_ENTRIES 覆盖（64..4096，I6 A/B）。 */
#define IO_URING_RING_ENTRIES_DEFAULT 512u
#define IO_URING_RING_ENTRIES_MIN 64u
#define IO_URING_RING_ENTRIES_MAX 4096u
#define IO_FILES_MAX 32
/** 与 .su std.io.driver.Buffer ABI 一致（ptr+len+handle），供 io_read_batch_buf/io_write_batch_buf 接收「指针+段数」式调用（对齐 Zig/Rust 切片语义）。 */
#define IO_READV_BUF_MAX 16
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
#ifndef IOSQE_FIXED_FILE
#define IOSQE_FIXED_FILE 1u
#endif
#define IO_PROVIDED_BGID 1
#define IO_PROVIDED_MAX 32
#define IO_PROVIDED_BUFSZ_DEFAULT 4096u
#define IO_PROVIDED_NR_DEFAULT 16u
/** PROVIDE_BUFFERS SQE user_data 魔数基底（勿用 0xPROV 等非法十六进制字面量；GCC 15 会报错）。 */
#define IO_SQE_UDATA_PROV_BASE 0x50524F00u

#if defined(__linux__)
#include <liburing.h>
#include <linux/io_uring.h>
/* 老版本 liburing 头可能未暴露下列宏；#ifndef 避免与 enum 冲突（Alpine/musl）。 */
#ifndef IORING_CQE_F_BUFFER
#define IORING_CQE_F_BUFFER (1U << 5)
#endif
#ifndef IORING_CQE_BUFFER_SHIFT
#define IORING_CQE_BUFFER_SHIFT 16
#endif
#ifndef IORING_CQE_BUFFER_MASK
#define IORING_CQE_BUFFER_MASK ((1U << IORING_CQE_BUFFER_SHIFT) - 1)
#endif
#ifndef IOSQE_BUFFER_SELECT
#define IOSQE_BUFFER_SELECT (1U << 5)
#endif
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/uio.h>
/* __kernel_timespec 由 liburing.h 所包含的 linux/time_types.h 提供，勿在此重复定义。 */
/* 极致压榨：每线程一个 io_uring，无全局锁；固定 buffer + 固定 files（SQPOLL 用）。 */
typedef struct {
    struct io_uring ring;
    int ok;
    int use_sqpoll;           /* 1=已用 SQPOLL 初始化并注册了 files，读写须走 fixed file */
    int registered_fds[IO_FILES_MAX];  /* 槽位 i 对应的 fd，-1 表示空 */
    struct iovec fixed_iov[IO_FIXED_MAX];
    unsigned fixed_nr;
    int fixed_ok;
    /* ZC-1：内核 buffer ring（IORING_OP_PROVIDE_BUFFERS）；recv 时 IOSQE_BUFFER_SELECT 零拷贝落池。 */
    uint8_t *provided_base;
    unsigned provided_nr;
    unsigned provided_bufsz;
    int provided_ok;
} uring_thread_t;
static pthread_key_t g_uring_key;
static pthread_once_t g_uring_key_once = PTHREAD_ONCE_INIT;

/** 读取 io_uring ring 深度：环境变量 SHU_IO_URING_RING_ENTRIES，默认 512。 */
static unsigned io_uring_ring_entries(void) {
    static unsigned cached;
    static int inited;
    if (!inited) {
        const char *e;
        inited = 1;
        cached = IO_URING_RING_ENTRIES_DEFAULT;
        e = getenv("SHU_IO_URING_RING_ENTRIES");
        if (e && e[0]) {
            unsigned long v = strtoul(e, NULL, 10);
            if (v >= IO_URING_RING_ENTRIES_MIN && v <= IO_URING_RING_ENTRIES_MAX)
                cached = (unsigned)v;
        }
    }
    return cached;
}

/** 读 /proc/sys/kernel/io_uring_disabled；非 0 表示管理员禁用 io_uring。 */
static int io_uring_disabled_by_admin(void) {
    FILE *f = fopen("/proc/sys/kernel/io_uring_disabled", "r");
    int v = 0;
    if (!f)
        return 0;
    if (fscanf(f, "%d", &v) != 1)
        v = 0;
    (void)fclose(f);
    return v != 0;
}

/** 解析环境变量开关：未设置或非 0/false/off 视为开启。 */
static int io_uring_env_enabled(const char *name, int default_on) {
    const char *e = getenv(name);
    if (!e || !e[0])
        return default_on;
    if (e[0] == '0' || e[0] == 'n' || e[0] == 'N' || e[0] == 'f' || e[0] == 'F')
        return 0;
    return 1;
}

/** IO-A3：是否尝试 SQPOLL（默认开；管理员禁用 io_uring 时关）。 */
static int io_uring_sqpoll_wanted(void) {
    static int cached = -1;
    if (cached >= 0)
        return cached;
    if (io_uring_disabled_by_admin())
        cached = 0;
    else
        cached = io_uring_env_enabled("SHU_IO_URING_SQPOLL", 1);
    return cached;
}

/** IO-A4：是否尝试 multishot accept（默认开；需 liburing + 内核 6.0+）。 */
static int io_uring_multishot_wanted(void) {
    static int cached = -1;
    if (cached >= 0)
        return cached;
    if (io_uring_disabled_by_admin())
        cached = 0;
    else
        cached = io_uring_env_enabled("SHU_IO_URING_MULTISHOT_ACCEPT", 1);
    return cached;
}

/** 已注册 fixed buffer 池内 ptr 对应下标；-1 表示未注册或非 fixed 模式。 */
static int uring_fixed_buf_index(const uring_thread_t *ut, const void *ptr) {
    unsigned i;
    if (!ut || !ut->fixed_ok || !ptr)
        return -1;
    for (i = 0; i < ut->fixed_nr; i++) {
        if (ut->fixed_iov[i].iov_base == ptr)
            return (int)i;
    }
    return -1;
}

/** 批量读 n 段 ptr 均已 register_buffers 时可走 read_fixed。 */
static int uring_batch_all_fixed(const uring_thread_t *ut, uint8_t *const *ps, int n) {
    int i;
    if (!ut || !ut->fixed_ok || n <= 0)
        return 0;
    for (i = 0; i < n; i++) {
        if (uring_fixed_buf_index(ut, ps[i]) < 0)
            return 0;
    }
    return 1;
}

/** ZC-1：是否启用 Provided Buffers（默认开；管理员禁用 io_uring 时关）。 */
static int io_uring_provide_wanted(void) {
    static int cached = -1;
    if (cached >= 0)
        return cached;
    if (io_uring_disabled_by_admin())
        cached = 0;
    else
        cached = io_uring_env_enabled("SHU_IO_URING_PROVIDE_BUFFERS", 1);
    return cached;
}

/** 向 ring 提交单块 PROVIDE_BUFFERS SQE（bid 为池内下标）。 */
static int io_provide_submit_one(uring_thread_t *ut, unsigned bid) {
    struct io_uring_sqe *sqe;
    void *addr;
    if (!ut || !ut->provided_ok || bid >= ut->provided_nr)
        return 0;
    addr = (void *)(ut->provided_base + (size_t)bid * (size_t)ut->provided_bufsz);
    sqe = io_uring_get_sqe(&ut->ring);
    if (!sqe)
        return 0;
    io_uring_prep_provide_buffers(sqe, addr, (unsigned)ut->provided_bufsz, 1, IO_PROVIDED_BGID, (int)bid);
    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)(IO_SQE_UDATA_PROV_BASE + bid));
    return 1;
}

/** 初始化 provided buffer 池：分配 nr×bufsz 并 submit 全部 PROVIDE_BUFFERS。 */
static int io_provide_buffers_init_pool(uring_thread_t *ut, unsigned nr, unsigned bufsz) {
    unsigned i;
    int submitted;
    if (!ut || !ut->ok || nr == 0 || nr > IO_PROVIDED_MAX || bufsz == 0)
        return 0;
    if (ut->provided_base) {
        free(ut->provided_base);
        ut->provided_base = NULL;
        ut->provided_ok = 0;
    }
    ut->provided_base = (uint8_t *)aligned_alloc(4096, (size_t)nr * (size_t)bufsz);
    if (!ut->provided_base)
        return 0;
    ut->provided_nr = nr;
    ut->provided_bufsz = bufsz;
    for (i = 0; i < nr; i++) {
        if (!io_provide_submit_one(ut, i)) {
            free(ut->provided_base);
            ut->provided_base = NULL;
            ut->provided_nr = 0;
            return 0;
        }
    }
    submitted = io_uring_submit_and_wait(&ut->ring, (int)nr);
    if (submitted < (int)nr) {
        free(ut->provided_base);
        ut->provided_base = NULL;
        ut->provided_nr = 0;
        return 0;
    }
    /* 一次 peek_batch 收割全部 PROVIDE CQE，比 nr 次 wait_cqe 更快。 */
    {
        struct io_uring_cqe *cqes[IO_PROVIDED_MAX];
        unsigned got, j;
        unsigned limit = nr > IO_PROVIDED_MAX ? IO_PROVIDED_MAX : nr;
        got = (unsigned)io_uring_peek_batch_cqe(&ut->ring, cqes, limit);
        for (j = 0; j < got; j++)
            io_uring_cqe_seen(&ut->ring, cqes[j]);
        for (j = got; j < nr; j++) {
            struct io_uring_cqe *cqe = NULL;
            if (io_uring_wait_cqe(&ut->ring, &cqe) != 0 || !cqe) {
                free(ut->provided_base);
                ut->provided_base = NULL;
                ut->provided_nr = 0;
                return 0;
            }
            io_uring_cqe_seen(&ut->ring, cqe);
        }
    }
    ut->provided_ok = 1;
    if (getenv("SHU_IO_URING_DEBUG") != NULL)
        (void)fprintf(stderr, "shu_io: provided_buffers nr=%u bufsz=%u ok\n", nr, bufsz);
    return 1;
}

/** 从 CQE 解析 provided recv 的 bid 与字节数。 */
static int io_provided_cqe_decode(const struct io_uring_cqe *cqe, unsigned *out_bid, unsigned *out_len) {
    unsigned res;
    if (!cqe || !(cqe->flags & IORING_CQE_F_BUFFER))
        return 0;
    res = (unsigned)cqe->res;
    if (out_bid)
        *out_bid = res & IORING_CQE_BUFFER_MASK;
    if (out_len)
        *out_len = res >> IORING_CQE_BUFFER_SHIFT;
    return 1;
}

/** CQE user_data 是否为 PROVIDE_BUFFERS 完成事件。 */
static int io_provide_cqe_is_prov(uintptr_t udata) {
    return udata >= (uintptr_t)IO_SQE_UDATA_PROV_BASE
        && udata < (uintptr_t)IO_SQE_UDATA_PROV_BASE + (uintptr_t)IO_PROVIDED_MAX;
}

/**
 * ZC-1 热路径：peek 并收割 PROVIDE_BUFFERS 完成 CQE（最多 max 条）。
 * 返回实际收割条数；读前调用以回收 buffer 回池，避免 ring 堆积。
 * lazy 模式下每轮读通常只需 expect=1（与上一轮 re-provide 1:1）。
 */
static unsigned io_provide_drain_cqes(uring_thread_t *ut, unsigned max) {
    struct io_uring_cqe *cqes[16];
    unsigned got, i, drained = 0;
    unsigned limit;
    if (!ut || !ut->provided_ok || max == 0)
        return 0;
    limit = max > 16u ? 16u : max;
    got = (unsigned)io_uring_peek_batch_cqe(&ut->ring, cqes, limit);
    for (i = 0; i < got; i++) {
        uintptr_t u = (uintptr_t)io_uring_cqe_get_data(cqes[i]);
        if (!io_provide_cqe_is_prov(u))
            continue;
        io_uring_cqe_seen(&ut->ring, cqes[i]);
        drained++;
    }
    return drained;
}

/** 读前按预期 re-provide 条数收割 PROVIDE CQE（echo n=1 时 expect=1，避免扫整池）。 */
static void io_provide_drain_before_read(uring_thread_t *ut, unsigned expect) {
    if (!ut || expect == 0)
        return;
    (void)io_provide_drain_cqes(ut, expect);
}

/** SQ 满或 get_sqe 失败时，尽量清空 pending 的 PROVIDE CQE。 */
static void io_provide_drain_all_pending(uring_thread_t *ut) {
    unsigned n;
    if (!ut)
        return;
    do {
        n = io_provide_drain_cqes(ut, ut->provided_nr);
    } while (n > 0);
}

/** SHU_IO_PROVIDE_LAZY=1（默认）：re-provide 后不同步 drain PROVIDE CQE，下轮读前批量收割。 */
static int io_provide_lazy_enabled(void) {
    static int cached = -1;
    if (cached < 0) {
        const char *e = getenv("SHU_IO_PROVIDE_LAZY");
        cached = (!e || e[0] != '0' || (e[1] != '\0' && e[1] != ' ')) ? 1 : 0;
    }
    return cached;
}

/**
 * 批量 re-provide 指定 bid；一次 submit。lazy 时不阻塞等待 PROVIDE CQE。
 */
static void io_provide_resubmit_bids(uring_thread_t *ut, const unsigned *bids, int n) {
    int i, cnt = 0;
    if (!ut || !bids || n <= 0)
        return;
    for (i = 0; i < n; i++) {
        if (io_provide_submit_one(ut, bids[i]))
            cnt++;
    }
    if (cnt > 0)
        (void)io_uring_submit(&ut->ring);
    if (!io_provide_lazy_enabled()) {
        for (i = 0; i < cnt; i++) {
            struct io_uring_cqe *pcqe = NULL;
            if (io_uring_peek_cqe(&ut->ring, &pcqe) == 0 && pcqe)
                io_uring_cqe_seen(&ut->ring, pcqe);
        }
    }
}

static void uring_destructor(void *v) {
    uring_thread_t *ut = (uring_thread_t *)v;
    if (ut) {
        if (ut->fixed_ok) (void)io_uring_unregister_buffers(&ut->ring);
        ut->fixed_nr = 0;
        if (ut->provided_base) {
            free(ut->provided_base);
            ut->provided_base = NULL;
            ut->provided_ok = 0;
            ut->provided_nr = 0;
        }
        if (ut->use_sqpoll) (void)io_uring_unregister_files(&ut->ring);
        if (ut->ok) io_uring_queue_exit(&ut->ring);
        free(ut);
    }
}
static void uring_key_init(void) {
    (void)pthread_key_create(&g_uring_key, uring_destructor);
}
/** 为 SQPOLL 取 fd 对应的已注册槽位下标；若未注册则分配一槽并 register_files_update。无空槽返回 -1。 */
static int uring_get_fd_slot(uring_thread_t *ut, int fd) {
    int i;
    for (i = 0; i < IO_FILES_MAX; i++)
        if (ut->registered_fds[i] == fd) return i;
    for (i = 0; i < IO_FILES_MAX; i++) {
        if (ut->registered_fds[i] != -1) continue;
        if (io_uring_register_files_update(&ut->ring, i, &fd, 1) == 1) {
            ut->registered_fds[i] = fd;
            return i;
        }
        /* 该槽 register 失败，继续尝试下一空槽（勿立即 syscall 回退）。 */
    }
    return -1;
}

/** 返回当前线程的 uring；首次调用时尝试 SQPOLL + fixed files，失败则回退普通 ring。 */
static uring_thread_t *uring_get_thread(void) {
    uring_thread_t *ut;
    int i;
    (void)pthread_once(&g_uring_key_once, uring_key_init);
    ut = (uring_thread_t *)pthread_getspecific(g_uring_key);
    if (ut == NULL) {
        ut = (uring_thread_t *)calloc(1, sizeof(*ut));
        if (ut) {
            unsigned flags = 0;
            int r;
            for (i = 0; i < IO_FILES_MAX; i++) ut->registered_fds[i] = -1;
#ifdef IORING_SETUP_DEFER_TASKRUN
            flags = IORING_SETUP_DEFER_TASKRUN;
# ifdef IORING_SETUP_SINGLE_ISSUER
            flags |= IORING_SETUP_SINGLE_ISSUER;
# endif
#endif
#ifdef IORING_SETUP_SQPOLL
            if (io_uring_sqpoll_wanted()) {
                int init_fds[IO_FILES_MAX];
                init_fds[0] = 0; init_fds[1] = 1; init_fds[2] = 2;
                for (i = 3; i < IO_FILES_MAX; i++) init_fds[i] = -1;
                r = io_uring_queue_init((unsigned)io_uring_ring_entries(), &ut->ring, flags | IORING_SETUP_SQPOLL);
                if (r >= 0 && io_uring_register_files(&ut->ring, init_fds, IO_FILES_MAX) >= 0) {
                    ut->ok = 1;
                    ut->use_sqpoll = 1;
                    ut->registered_fds[0] = 0; ut->registered_fds[1] = 1; ut->registered_fds[2] = 2;
                    if (getenv("SHU_IO_URING_DEBUG") != NULL)
                        (void)fprintf(stderr, "shu_io: SQPOLL+fixed_files ok (ring=%u)\n", io_uring_ring_entries());
                    pthread_setspecific(g_uring_key, ut);
                    return ut;
                }
                if (r >= 0) (void)io_uring_queue_exit(&ut->ring);
            }
#endif
            r = io_uring_queue_init((unsigned)io_uring_ring_entries(), &ut->ring, flags);
            if (r < 0 && flags != 0)
                r = io_uring_queue_init((unsigned)io_uring_ring_entries(), &ut->ring, 0);
            ut->ok = (r >= 0) ? 1 : 0;
            pthread_setspecific(g_uring_key, ut);
        }
    }
    return ut;
}

/**
 * SQPOLL 快路径：预注册 fd 到 io_uring fixed files 槽（connect 后调用一次）。
 * echo/proxy 热路径可避免每轮 read/write 重复 register_files_update。
 * 非 Linux 或未启用 SQPOLL 时无操作，返回 1。
 */
int io_uring_prefetch_fd(int fd) {
#if defined(__linux__)
    uring_thread_t *ut;
    int slot;
    if (fd < 0)
        return 0;
    ut = uring_get_thread();
    if (!ut || !ut->ok || !ut->use_sqpoll)
        return 1;
    slot = uring_get_fd_slot(ut, fd);
    return slot >= 0 ? 1 : 0;
#else
    (void)fd;
    return 1;
#endif
}

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>
/* 阶段 1 性能压榨：Linux 上 accept/connect 走 io_uring，供 std.net 调用；与 uring 共用同一 ring，超越 Zig 典型用法。 */

/** 单次 accept 走 io_uring；timeout_ms 毫秒（0=无超时）。返回 client fd，失败 -1；client 已设非阻塞。阶段 4：SQPOLL 时 listener 走 fixed file 槽，减少 uring 开销。 */
int32_t io_uring_accept(int listener_fd, unsigned timeout_ms) {
    uring_thread_t *ut = uring_get_thread();
    if (!ut || !ut->ok) return -1;
    struct io_uring *ring = &ut->ring;
    struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
    if (!sqe) return -1;
    io_uring_prep_accept(sqe, listener_fd, NULL, NULL, 0);
    if (ut->use_sqpoll) {
        int slot = uring_get_fd_slot(ut, listener_fd);
        if (slot >= 0) { sqe->fd = (unsigned)slot; sqe->flags |= (unsigned)IOSQE_FIXED_FILE; }
    }
    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)listener_fd);
    struct io_uring_cqe *cqe = NULL;
    struct io_uring_cqe *cqe_ptrs[1];
    if (timeout_ms == 0) {
        if (io_uring_submit_and_wait(ring, 1) != 1) return -1;
        if (io_uring_peek_batch_cqe(ring, cqe_ptrs, 1) < 1) return -1;
        cqe = cqe_ptrs[0];
    } else {
        if (io_uring_submit(ring) != 1) return -1;
        struct __kernel_timespec ts;
        ts.tv_sec = (long long)(timeout_ms / 1000u);
        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
        if (io_uring_wait_cqe_timeout(ring, &cqe, &ts) != 0) return -1;
    }
    int res = (int)cqe->res;
    io_uring_cqe_seen(ring, cqe);
    shu_io_async_notify_cq(1);
    if (res < 0) return -1;
    int fd = res;
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags >= 0) (void)fcntl(fd, F_SETFL, flags | O_NONBLOCK);
    (void)io_uring_prefetch_fd(fd);
    return (int32_t)fd;
}

/** 单次 connect 走 io_uring；addr_u32 主机序 (a<<24)|(b<<16)|(c<<8)|d，port_u32 取低 16 位。返回 fd，失败 -1；socket 已非阻塞。 */
int32_t io_uring_connect(uint32_t addr_u32, uint32_t port_u32, unsigned timeout_ms) {
    int fd = (int)socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0 || fcntl(fd, F_SETFL, flags | O_NONBLOCK) != 0) { (void)close(fd); return -1; }
    struct sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = htonl(addr_u32);
    sin.sin_port = htons((uint16_t)(port_u32 & 0xFFFFu));
    uring_thread_t *ut = uring_get_thread();
    if (!ut || !ut->ok) {
        (void)close(fd);
        return -1;
    }
    struct io_uring *ring = &ut->ring;
    struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
    if (!sqe) { (void)close(fd); return -1; }
    io_uring_prep_connect(sqe, fd, (struct sockaddr *)&sin, sizeof(sin));
    if (ut->use_sqpoll) {
        int slot = uring_get_fd_slot(ut, fd);
        if (slot >= 0) { sqe->fd = (unsigned)slot; sqe->flags |= (unsigned)IOSQE_FIXED_FILE; }
    }
    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
    struct io_uring_cqe *cqe = NULL;
    struct io_uring_cqe *cqe_ptrs[1];
    if (timeout_ms == 0) {
        if (io_uring_submit_and_wait(ring, 1) != 1) { (void)close(fd); return -1; }
        if (io_uring_peek_batch_cqe(ring, cqe_ptrs, 1) < 1) { (void)close(fd); return -1; }
        cqe = cqe_ptrs[0];
    } else {
        if (io_uring_submit(ring) != 1) { (void)close(fd); return -1; }
        struct __kernel_timespec ts;
        ts.tv_sec = (long long)(timeout_ms / 1000u);
        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
        if (io_uring_wait_cqe_timeout(ring, &cqe, &ts) != 0) { (void)close(fd); return -1; }
    }
    int res = (int)cqe->res;
    io_uring_cqe_seen(ring, cqe);
    if (res != 0) { (void)close(fd); return -1; }
    (void)io_uring_prefetch_fd(fd);
    return (int32_t)fd;
}

#define IO_NET_BATCH_MAX 64

/** IO-A4：multishot accept 成功次数（烟测/观测；Linux + liburing 有效）。 */
static unsigned g_io_uring_multishot_accept_hits;

/** 返回 multishot accept 路径成功收割次数（IO-A4 烟测）。 */
unsigned shu_io_uring_multishot_accept_hits(void) {
    return g_io_uring_multishot_accept_hits;
}

/** 清零 multishot accept 统计（烟测用）。 */
void shu_io_uring_multishot_accept_stats_reset(void) {
    g_io_uring_multishot_accept_hits = 0;
}

#if defined(IORING_ACCEPT_MULTISHOT) && defined(IORING_CQE_F_MORE)
/**
 * IO-A4：multishot accept — 单 SQE 收割多连接，减少 submit 次数。
 * 失败或无 MORE 标志时由调用方回退批量 accept。
 */
static int io_uring_accept_many_multishot(uring_thread_t *ut, int listener_fd, int listener_slot,
                                          int32_t *out_fds, int want, unsigned timeout_ms) {
    struct io_uring *ring = &ut->ring;
    struct io_uring_sqe *sqe;
    struct io_uring_cqe *cqe = NULL;
    int count = 0;

    (void)timeout_ms;
    if (!io_uring_multishot_wanted() || want <= 0)
        return 0;
    sqe = io_uring_get_sqe(ring);
    if (!sqe)
        return 0;
    io_uring_prep_multishot_accept(sqe, listener_fd, NULL, NULL, 0);
    if (listener_slot >= 0) {
        sqe->fd = (unsigned)listener_slot;
        sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
    }
    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)0xACC711u);
    if (io_uring_submit(ring) < 1)
        return 0;
    while (count < want) {
        cqe = NULL;
        if (io_uring_wait_cqe(ring, &cqe) != 0 || !cqe)
            break;
        if (cqe->res >= 0) {
            int fd = (int)cqe->res;
            int flags = fcntl(fd, F_GETFL, 0);
            if (flags >= 0)
                (void)fcntl(fd, F_SETFL, flags | O_NONBLOCK);
            out_fds[count++] = (int32_t)fd;
            (void)io_uring_prefetch_fd(fd);
        }
        {
            unsigned more = (unsigned)(cqe->flags & (unsigned)IORING_CQE_F_MORE);
            io_uring_cqe_seen(ring, cqe);
            if (!more)
                break;
        }
    }
    if (count > 0)
        g_io_uring_multishot_accept_hits++;
    return count;
}
#endif

/** 阶段 2 性能压榨：一次提交 N 个 accept SQE，一次收割 N 个 CQE；out_fds 填满成功得到的 client fd，已设非阻塞。返回实际数量。阶段 4：SQPOLL 时 listener 走 fixed file。收割用 peek_batch 一次取齐 CQE，减少 wait_cqe 次数。IO-A4：优先 multishot accept。 */
int io_uring_accept_many(int listener_fd, int32_t *out_fds, int n, unsigned timeout_ms) {
    (void)timeout_ms;
    if (n <= 0 || n > IO_NET_BATCH_MAX || !out_fds) return 0;
    uring_thread_t *ut = uring_get_thread();
    if (!ut || !ut->ok) return 0;
    struct io_uring *ring = &ut->ring;
    int listener_slot = -1;
    if (ut->use_sqpoll) listener_slot = uring_get_fd_slot(ut, listener_fd);
#if defined(IORING_ACCEPT_MULTISHOT) && defined(IORING_CQE_F_MORE)
    {
        int ms = io_uring_accept_many_multishot(ut, listener_fd, listener_slot, out_fds, n, timeout_ms);
        if (ms > 0)
            return ms;
    }
#endif
    int i;
    for (i = 0; i < n; i++) {
        struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
        if (!sqe) break;
        io_uring_prep_accept(sqe, listener_fd, NULL, NULL, 0);
        if (listener_slot >= 0) { sqe->fd = (unsigned)listener_slot; sqe->flags |= (unsigned)IOSQE_FIXED_FILE; }
        io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
    }
    n = i;
    if (n == 0) return 0;
    int submitted = io_uring_submit_and_wait(ring, n);
    if (submitted <= 0) return 0;
    struct io_uring_cqe *cqe_ptrs[IO_NET_BATCH_MAX];
    int reaped = io_uring_peek_batch_cqe(ring, cqe_ptrs, submitted);
    int count = 0;
    for (i = 0; i < reaped; i++) {
        struct io_uring_cqe *cqe = cqe_ptrs[i];
        int res = (int)cqe->res;
        io_uring_cqe_seen(ring, cqe);
        if (res >= 0) {
            int fd = res;
            int flags = fcntl(fd, F_GETFL, 0);
            if (flags >= 0) (void)fcntl(fd, F_SETFL, flags | O_NONBLOCK);
            out_fds[count++] = (int32_t)fd;
            (void)io_uring_prefetch_fd(fd);
        }
    }
    return count;
}

/** 阶段 2 性能压榨：一次提交 N 个 connect SQE，一次收割 N 个 CQE；out_fds 填满成功的 fd。返回实际成功数量。timeout_ms 保留供后续超时控制用。 */
int io_uring_connect_many(uint32_t addr_u32, uint32_t port_u32, int32_t *out_fds, int n, unsigned timeout_ms) {
    (void)timeout_ms;
    if (n <= 0 || n > IO_NET_BATCH_MAX || !out_fds) return 0;
    struct sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_addr.s_addr = htonl(addr_u32);
    sin.sin_port = htons((uint16_t)(port_u32 & 0xFFFFu));
    int fds[IO_NET_BATCH_MAX];
    int i;
    for (i = 0; i < n; i++) {
        fds[i] = (int)socket(AF_INET, SOCK_STREAM, 0);
        if (fds[i] < 0) break;
        int flags = fcntl(fds[i], F_GETFL, 0);
        if (flags < 0 || fcntl(fds[i], F_SETFL, flags | O_NONBLOCK) != 0) {
            (void)close(fds[i]);
            break;
        }
    }
    n = i;
    if (n == 0) return 0;
    uring_thread_t *ut = uring_get_thread();
    if (!ut || !ut->ok) {
        for (i = 0; i < n; i++) (void)close(fds[i]);
        return 0;
    }
    struct io_uring *ring = &ut->ring;
    for (i = 0; i < n; i++) {
        struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
        if (!sqe) { for (; i < n; i++) (void)close(fds[i]); return 0; }
        io_uring_prep_connect(sqe, fds[i], (struct sockaddr *)&sin, sizeof(sin));
        if (ut->use_sqpoll) {
            int slot = uring_get_fd_slot(ut, fds[i]);
            if (slot >= 0) { sqe->fd = (unsigned)slot; sqe->flags |= (unsigned)IOSQE_FIXED_FILE; }
        }
        io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fds[i]);
    }
    int submitted = io_uring_submit_and_wait(ring, n);
    if (submitted <= 0) {
        for (i = 0; i < n; i++) (void)close(fds[i]);
        return 0;
    }
    struct io_uring_cqe *cqe_ptrs[IO_NET_BATCH_MAX];
    int reaped = io_uring_peek_batch_cqe(ring, cqe_ptrs, submitted);
    int count = 0;
    for (i = 0; i < reaped; i++) {
        struct io_uring_cqe *cqe = cqe_ptrs[i];
        int res = (int)cqe->res;
        int fd = (int)(intptr_t)io_uring_cqe_get_data(cqe);
        io_uring_cqe_seen(ring, cqe);
        if (res == 0) {
            out_fds[count++] = (int32_t)fd;
            (void)io_uring_prefetch_fd(fd);
        } else
            (void)close(fd);
    }
    return count;
}

#endif

#if defined(__APPLE__)
#include <sys/event.h>
#include <sys/time.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <pthread.h>
/* 再压榨：每线程一个 kqueue，无全局锁、无竞争；线程退出时 destructor 关闭 fd */
static pthread_key_t g_kq_key;
static pthread_once_t g_kq_key_once = PTHREAD_ONCE_INIT;
static void kq_destructor(void *v) {
    int kq = (v == NULL) ? -1 : ((int)(intptr_t)v) - 1;
    if (kq >= 0) (void)close(kq);
}
static void kq_key_init(void) {
    (void)pthread_key_create(&g_kq_key, kq_destructor);
}
static int kq_get(void) {
    int kq;
    (void)pthread_once(&g_kq_key_once, kq_key_init);
    /* 存 (kq+1) 以区分「未设置」(NULL→0) 与有效 fd 0 */
    kq = (int)(intptr_t)pthread_getspecific(g_kq_key);
    kq = (kq <= 0) ? -1 : (kq - 1);
    if (kq < 0) {
        kq = kqueue();
        if (kq >= 0)
            pthread_setspecific(g_kq_key, (void *)(intptr_t)(kq + 1));
    }
    return kq;
}
#include <sys/uio.h>
/* 固定 buffer 池（最多 IO_FIXED_MAX 块）：非 Linux 无 io_uring_register，仅存 iov[] 供 read_fixed/write_fixed 走普通 read/write */
#define IO_FIXED_MAX_APPLE 8
typedef struct { struct iovec iov[IO_FIXED_MAX_APPLE]; unsigned nr; } fixed_pool_t;
static pthread_key_t g_fixed_key;
static pthread_once_t g_fixed_key_once = PTHREAD_ONCE_INIT;
static void fixed_destructor(void *v) { free(v); }
static void fixed_key_init(void) { (void)pthread_key_create(&g_fixed_key, fixed_destructor); }
#endif

#if defined(_WIN32) || defined(_WIN64)
#include <io.h>
#include <stdlib.h>
#include <windows.h>
#include <winsock2.h>
#ifndef FILE_SKIP_COMPLETION_PORT_ON_SUCCESS
#define FILE_SKIP_COMPLETION_PORT_ON_SUCCESS 1
#endif
/* 全局完成端口，首次使用时创建 */
static HANDLE g_iocp = NULL;
static CRITICAL_SECTION g_iocp_cs;
static int g_iocp_cs_init = 0;
/* 阶段 2 超越：OVERLAPPED 池扩为 8，支持更大批量（路线图 §4.4）；与 Linux 8 段 batch 同思路 */
#define IO_BATCH_MAX_WIN 8
typedef struct { OVERLAPPED ov_read[IO_BATCH_MAX_WIN]; OVERLAPPED ov_write[IO_BATCH_MAX_WIN]; } win_ov_thread_t;
static DWORD g_win_tls_idx = TLS_OUT_OF_INDEXES;
static CRITICAL_SECTION g_win_tls_cs;
static int g_win_tls_cs_init = 0;
static win_ov_thread_t *win_get_thread_ov(void) {
    win_ov_thread_t *ov;
    if (g_win_tls_cs_init == 0) { InitializeCriticalSection(&g_win_tls_cs); g_win_tls_cs_init = 1; }
    EnterCriticalSection(&g_win_tls_cs);
    if (g_win_tls_idx == TLS_OUT_OF_INDEXES)
        g_win_tls_idx = TlsAlloc();
    LeaveCriticalSection(&g_win_tls_cs);
    if (g_win_tls_idx == TLS_OUT_OF_INDEXES) return NULL;
    ov = (win_ov_thread_t *)TlsGetValue(g_win_tls_idx);
    if (ov == NULL) {
        ov = (win_ov_thread_t *)calloc(1, sizeof(*ov));
        if (ov) TlsSetValue(g_win_tls_idx, ov);
    }
    return ov;
}
/* 最多缓存 2 个 handle 的 SetFileCompletionNotificationModes */
static HANDLE g_win_skip_handle[2] = { NULL, NULL };
static unsigned g_win_skip_next = 0;
static int win_handle_skip_set(HANDLE h) {
    if (h == g_win_skip_handle[0] || h == g_win_skip_handle[1]) return 1;
    if (SetFileCompletionNotificationModes(h, FILE_SKIP_COMPLETION_PORT_ON_SUCCESS)) {
        g_win_skip_handle[g_win_skip_next] = h;
        g_win_skip_next = 1u - g_win_skip_next;
        return 1;
    }
    return 0;
}
static void win_zero_overlapped(OVERLAPPED *ov, int count) {
    int j;
    for (j = 0; j < count; j++) {
        ov[j].Internal = 0;
        ov[j].InternalHigh = 0;
        ov[j].Offset = 0;
        ov[j].OffsetHigh = 0;
        ov[j].hEvent = NULL;
    }
}
/* 固定 buffer 池（最多 8 块）：Windows 无 io_uring，TLS 存 base[]/len[] 供 read_fixed/write_fixed 走普通 read/write */
#define IO_FIXED_MAX_WIN 8
typedef struct { void *base[IO_FIXED_MAX_WIN]; size_t len[IO_FIXED_MAX_WIN]; unsigned nr; } win_fixed_pool_t;
static DWORD g_win_fixed_tls_idx = TLS_OUT_OF_INDEXES;
static CRITICAL_SECTION g_win_fixed_cs;
static int g_win_fixed_cs_init = 0;
static win_fixed_pool_t *win_get_fixed_pool(void) {
    if (g_win_fixed_cs_init == 0) { InitializeCriticalSection(&g_win_fixed_cs); g_win_fixed_cs_init = 1; }
    EnterCriticalSection(&g_win_fixed_cs);
    if (g_win_fixed_tls_idx == TLS_OUT_OF_INDEXES)
        g_win_fixed_tls_idx = TlsAlloc();
    LeaveCriticalSection(&g_win_fixed_cs);
    if (g_win_fixed_tls_idx == TLS_OUT_OF_INDEXES) return NULL;
    return (win_fixed_pool_t *)TlsGetValue(g_win_fixed_tls_idx);
}
#endif

#if !defined(_WIN32) && !defined(_WIN64)
#include <unistd.h>
#include <sys/uio.h>
#include <poll.h>
#include <errno.h>
#define FALLBACK_READ(fd, buf, count)   ((ptrdiff_t)read((int)(fd), (void *)(buf), (size_t)(count)))
#define FALLBACK_WRITE(fd, buf, count)  ((ptrdiff_t)write((int)(fd), (const void *)(buf), (size_t)(count)))

/** readv 直至 n 段总长度读满；非阻塞短读/EAGAIN 时 poll 重试（macOS bulk echo 需此路径）。 */
static ptrdiff_t io_readv_all(int fd, struct iovec *iov, int n) {
    size_t target = 0;
    size_t done = 0;
    int i;
    for (i = 0; i < n; i++) target += iov[i].iov_len;
    while (done < target) {
        ssize_t r = readv(fd, iov, n);
        if (r < 0) {
            if (errno == EINTR) continue;
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                struct pollfd pfd = { fd, POLLIN, 0 };
                if (poll(&pfd, 1, -1) <= 0) return -1;
                continue;
            }
            return -1;
        }
        if (r == 0) return -1;
        done += (size_t)r;
    }
    return (ptrdiff_t)done;
}

/** writev 直至 n 段总长度写完；非阻塞短写/EAGAIN 时 poll 重试。 */
static ptrdiff_t io_writev_all(int fd, struct iovec *iov, int n) {
    size_t target = 0;
    size_t done = 0;
    int i;
    for (i = 0; i < n; i++) target += iov[i].iov_len;
    while (done < target) {
        ssize_t r = writev(fd, iov, n);
        if (r < 0) {
            if (errno == EINTR) continue;
            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                struct pollfd pfd = { fd, POLLOUT, 0 };
                if (poll(&pfd, 1, -1) <= 0) return -1;
                continue;
            }
            return -1;
        }
        if (r == 0) return -1;
        done += (size_t)r;
    }
    return (ptrdiff_t)done;
}
#else
#define FALLBACK_READ(fd, buf, count)  ((ptrdiff_t)_read((int)(fd), (void *)(buf), (unsigned)(count)))
#define FALLBACK_WRITE(fd, buf, count) ((ptrdiff_t)_write((int)(fd), (const void *)(buf), (unsigned)(count)))
#endif

#ifdef __cplusplus
extern "C" {
#endif

/** IO 读：fd 为 handle（0=stdin，≥2 为任意 fd）；timeout_ms 毫秒，0=无超时。返回读入字节数，0=EOF，-1=错误/超时。 */
ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms) {
    /* 调试 LSP stdin：LSP_READ_DEBUG=1 时对 fd=0 单次 read 并打日志，便于确认每次请求/返回字节数 */
    if (fd == 0 && getenv("LSP_READ_DEBUG") != NULL) {
        ptrdiff_t r = (ptrdiff_t)read(0, buf, count);
        (void)fprintf(stderr, "LSP_READ_DEBUG: io_read fd=0 count=%zu => %td\n", count, r);
        return r;
    }
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            int use_idx = -1;
            if (ut->use_sqpoll)
                use_idx = uring_get_fd_slot(ut, fd);
            {
                struct io_uring *ring = &ut->ring;
                struct io_uring_sqe *sqe;
                struct io_uring_cqe *cqe;
                struct io_uring_cqe *cqe_ptrs[1];
                struct __kernel_timespec ts;
                if (timeout_ms > 0) {
                    ts.tv_sec = (long long)(timeout_ms / 1000u);
                    ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
                }
                sqe = io_uring_get_sqe(ring);
                if (sqe) {
                    if (use_idx >= 0) {
                        io_uring_prep_read(sqe, use_idx, buf, count, 0);
                        sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
                    } else {
                        io_uring_prep_read(sqe, fd, buf, count, 0);
                    }
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (timeout_ms == 0) {
                    if (io_uring_submit_and_wait(ring, 1) == 1) {
                        unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                        if (got >= 1) {
                            cqe = cqe_ptrs[0];
                            ptrdiff_t res = (ptrdiff_t)cqe->res;
                            io_uring_cqe_seen(ring, cqe);
                            shu_io_async_notify_cq(1);
                            return res >= 0 ? res : -1;
                        }
                        return -1;
                    }
                } else {
                    if (io_uring_submit(ring) == 1) {
                        int wait_ret = io_uring_wait_cqe_timeout(ring, &cqe, &ts);
                        if (wait_ret == 0 && cqe) {
                            ptrdiff_t res = (ptrdiff_t)cqe->res;
                            io_uring_cqe_seen(ring, cqe);
                            shu_io_async_notify_cq(1);
                            return res >= 0 ? res : -1;
                        }
                        if (cqe) io_uring_cqe_seen(ring, cqe);
                        return -1;
                    }
                }
            }
            }
        }
    }
    return FALLBACK_READ(fd, buf, count);
#endif

#if defined(__APPLE__)
    if (fd >= 3) {
        int kq = kq_get();
        if (kq >= 0) {
            struct kevent ev, ev_out;
            struct timespec ts_abs, *pts = NULL;
            if (timeout_ms > 0) {
                ts_abs.tv_sec = (timeout_ms / 1000u);
                ts_abs.tv_nsec = (long)((timeout_ms % 1000u) * 1000000u);
                pts = &ts_abs;
            }
            /* EV_CLEAR：取到事件后自动清除状态，减少重复/伪触发（再压榨） */
            EV_SET(&ev, (uintptr_t)fd, EVFILT_READ, EV_ADD | EV_ONESHOT | EV_CLEAR, 0, 0, 0);
            if (kevent(kq, &ev, 1, NULL, 0, pts) >= 0 &&
                kevent(kq, NULL, 0, &ev_out, 1, pts) >= 0)
                return (ptrdiff_t)read(fd, buf, count);
        }
    }
    return FALLBACK_READ(fd, buf, count);
#endif

#if defined(_WIN32) || defined(_WIN64)
    {
        DWORD wait_ms = (timeout_ms == 0) ? INFINITE : (DWORD)timeout_ms;
        HANDLE h = (HANDLE)_get_osfhandle(fd);
        if (h != INVALID_HANDLE_VALUE) {
            if (g_iocp == NULL) {
                if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
                EnterCriticalSection(&g_iocp_cs);
                if (g_iocp == NULL)
                    g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
                LeaveCriticalSection(&g_iocp_cs);
            }
            if (g_iocp) {
                CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                OVERLAPPED ov = { 0 };
                if (ReadFile(h, buf, (DWORD)(count > 0x7FFFFFFFu ? 0x7FFFFFFFu : count), NULL, &ov)) {
                    DWORD bytes = 0;
                    GetOverlappedResult(h, &ov, &bytes, TRUE);
                    return (ptrdiff_t)bytes;
                }
                if (GetLastError() == ERROR_IO_PENDING) {
                    DWORD bytes = 0;
                    ULONG_PTR key;
                    LPOVERLAPPED pov = NULL;
                    if (GetQueuedCompletionStatus(g_iocp, &bytes, &key, &pov, wait_ms) && pov)
                        return (ptrdiff_t)bytes;
                    return -1; /* 超时或错误 */
                }
            }
        }
    }
    return FALLBACK_READ(fd, buf, count);
#endif

#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    (void)timeout_ms;
    return FALLBACK_READ(fd, buf, count);
#endif
}

/** IO-A5：非阻塞 read 的 SQE user_data 魔数（与 PROVIDE/accept 区分）。 */
#define IO_SQE_UDATA_READ_ASYNC 0x52414144u

/** IO-A5：非阻塞 write 的 SQE user_data 魔数。 */
#define IO_SQE_UDATA_WRITE_ASYNC 0x57524144u

/** IO-A5 v2：每方向最大 async in-flight 槽（可用 SHU_IO_ASYNC_SLOTS 调 1..32）。 */
#define SHU_IO_ASYNC_MAX_SLOTS 32

/** read async 单槽状态。 */
typedef struct {
    int pending;
    int reaped;       /* poll 路径已收割 CQE，待 complete 取结果 */
    int32_t reaped_res;
    size_t handle;
    uint8_t *ptr;
    size_t len;
} shu_io_read_async_slot_t;

/** write async 单槽状态。 */
typedef struct {
    int pending;
    int reaped;
    int32_t reaped_res;
    size_t handle;
    const uint8_t *ptr;
    size_t len;
} shu_io_write_async_slot_t;

static shu_io_read_async_slot_t shu_io_read_slots[SHU_IO_ASYNC_MAX_SLOTS];
static shu_io_write_async_slot_t shu_io_write_slots[SHU_IO_ASYNC_MAX_SLOTS];
static int shu_io_async_slot_cap = 8;
static int shu_io_async_slot_cap_inited;

/** 解析 SHU_IO_ASYNC_SLOTS（默认 8，范围 1..32）。 */
static int shu_io_async_slot_count(void) {
    if (!shu_io_async_slot_cap_inited) {
        const char *e = getenv("SHU_IO_ASYNC_SLOTS");
        int n = 8;
        if (e && e[0]) {
            char *end = NULL;
            long v = strtol(e, &end, 10);
            if (end && end > e && v >= 1 && v <= SHU_IO_ASYNC_MAX_SLOTS)
                n = (int)v;
        }
        shu_io_async_slot_cap = n;
        shu_io_async_slot_cap_inited = 1;
    }
    return shu_io_async_slot_cap;
}

/** read async SQE user_data：低 32 位魔数 + 高 32 位 slot。 */
static uintptr_t shu_io_read_slot_udata(unsigned slot) {
    return ((uintptr_t)slot << 32) | (uintptr_t)IO_SQE_UDATA_READ_ASYNC;
}

/** write async SQE user_data：低 32 位魔数 + 高 32 位 slot。 */
static uintptr_t shu_io_write_slot_udata(unsigned slot) {
    return ((uintptr_t)slot << 32) | (uintptr_t)IO_SQE_UDATA_WRITE_ASYNC;
}

/** 从 CQE user_data 解析 read slot；-1 表示非 read async。 */
static int shu_io_read_udata_to_slot(uintptr_t u) {
    if ((u & 0xFFFFFFFFu) != (uintptr_t)IO_SQE_UDATA_READ_ASYNC)
        return -1;
    return (int)(u >> 32);
}

/** 从 CQE user_data 解析 write slot；-1 表示非 write async。 */
static int shu_io_write_udata_to_slot(uintptr_t u) {
    if ((u & 0xFFFFFFFFu) != (uintptr_t)IO_SQE_UDATA_WRITE_ASYNC)
        return -1;
    return (int)(u >> 32);
}

/**
 * IO-A5 v3：窥视/等待 async read/write CQE，收割至 slot 后唤醒 scheduler。
 * timeout_ms=0 仅 peek；>0 无 CQE 时 wait_cqe_timeout。返回本次收割的 async 完成数。
 */
unsigned shu_io_poll_async_completions(unsigned timeout_ms) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    struct io_uring *ring;
    struct io_uring_cqe *cqe_ptrs[8];
    struct io_uring_cqe *cqe;
    unsigned got;
    unsigned async_n;
    unsigned i;

    if (!ut || !ut->ok)
        return 0;
    ring = &ut->ring;
    got = (unsigned)io_uring_peek_batch_cqe(ring, cqe_ptrs, 8);
    if (got == 0 && timeout_ms > 0) {
        struct __kernel_timespec ts;
        ts.tv_sec = (long long)(timeout_ms / 1000u);
        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
        if (io_uring_wait_cqe_timeout(ring, &cqe, &ts) != 0 || !cqe)
            return 0;
        got = (unsigned)io_uring_peek_batch_cqe(ring, cqe_ptrs, 8);
    }
    async_n = 0;
    for (i = 0; i < got; i++) {
        struct io_uring_cqe *cqe_i = cqe_ptrs[i];
        uintptr_t u = (uintptr_t)io_uring_cqe_get_data(cqe_i);
        int rs = shu_io_read_udata_to_slot(u);
        int ws;
        if (rs >= 0) {
            shu_io_read_async_slot_t *st = &shu_io_read_slots[rs];
            if (st->pending && !st->reaped) {
                st->reaped = 1;
                st->reaped_res = (int32_t)cqe_i->res;
                io_uring_cqe_seen(ring, cqe_i);
                async_n++;
            }
            continue;
        }
        ws = shu_io_write_udata_to_slot(u);
        if (ws >= 0) {
            shu_io_write_async_slot_t *st = &shu_io_write_slots[ws];
            if (st->pending && !st->reaped) {
                st->reaped = 1;
                st->reaped_res = (int32_t)cqe_i->res;
                io_uring_cqe_seen(ring, cqe_i);
                async_n++;
            }
        }
    }
    if (async_n > 0)
        shu_io_async_notify_cq(async_n);
    return async_n;
#else
    (void)timeout_ms;
    return 0;
#endif
}

/** 分配 read async 槽；无空闲返回 -1。 */
static int shu_io_read_slot_alloc(void) {
    int cap = shu_io_async_slot_count();
    int i;
    for (i = 0; i < cap; i++) {
        if (!shu_io_read_slots[i].pending && !shu_io_read_slots[i].reaped)
            return i;
    }
    return -1;
}

/** 分配 write async 槽；无空闲返回 -1。 */
static int shu_io_write_slot_alloc(void) {
    int cap = shu_io_async_slot_count();
    int i;
    for (i = 0; i < cap; i++) {
        if (!shu_io_write_slots[i].pending && !shu_io_write_slots[i].reaped)
            return i;
    }
    return -1;
}

/**
 * IO-A5：提交非阻塞 read（io_uring submit 不 wait；非 Linux 登记状态供 complete 同步读）。
 * 成功返回 slot 索引（>=0），失败或槽满返回 -1。
 */
int shu_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle) {
    int slot;
    if (!ptr || len == 0)
        return -1;
    slot = shu_io_read_slot_alloc();
    if (slot < 0)
        return -1;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        struct io_uring *ring;
        struct io_uring_sqe *sqe;
        int fd = (int)handle;
        int use_idx = -1;
        if (!ut || !ut->ok)
            return -1;
        ring = &ut->ring;
        if (ut->use_sqpoll)
            use_idx = uring_get_fd_slot(ut, fd);
        sqe = io_uring_get_sqe(ring);
        if (!sqe)
            return -1;
        if (use_idx >= 0) {
            io_uring_prep_read(sqe, use_idx, ptr, len, 0);
            sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
        } else {
            io_uring_prep_read(sqe, fd, ptr, len, 0);
        }
        io_uring_sqe_set_data(sqe, (void *)shu_io_read_slot_udata((unsigned)slot));
        if (io_uring_submit(ring) < 0)
            return -1;
        shu_io_read_slots[slot].pending = 1;
        shu_io_read_slots[slot].reaped = 0;
        shu_io_read_slots[slot].handle = handle;
        shu_io_read_slots[slot].ptr = ptr;
        shu_io_read_slots[slot].len = len;
        return slot;
    }
#else
    shu_io_read_slots[slot].pending = 1;
    shu_io_read_slots[slot].reaped = 0;
    shu_io_read_slots[slot].handle = handle;
    shu_io_read_slots[slot].ptr = ptr;
    shu_io_read_slots[slot].len = len;
    return slot;
#endif
}

/**
 * IO-A5 v2：收割指定 slot 的 read async；>0 字节数，0=EOF，-1=错误，-2=尚未完成。
 */
int32_t shu_io_complete_read_async_slot(int slot) {
    shu_io_read_async_slot_t *st;
    if (slot < 0 || slot >= shu_io_async_slot_count())
        return -1;
    st = &shu_io_read_slots[slot];
    if (st->reaped) {
        int32_t out = st->reaped_res >= 0 ? st->reaped_res : -1;
        st->reaped = 0;
        st->pending = 0;
        return out;
    }
    if (!st->pending)
        return -1;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        struct io_uring *ring;
        struct io_uring_cqe *cqe_ptrs[8];
        unsigned got;
        unsigned i;
        int32_t res;
        if (!ut || !ut->ok)
            return -1;
        ring = &ut->ring;
        got = (unsigned)io_uring_peek_batch_cqe(ring, cqe_ptrs, 8);
        for (i = 0; i < got; i++) {
            struct io_uring_cqe *cqe = cqe_ptrs[i];
            uintptr_t u = (uintptr_t)io_uring_cqe_get_data(cqe);
            int s = shu_io_read_udata_to_slot(u);
            if (s != slot)
                continue;
            res = (int32_t)cqe->res;
            io_uring_cqe_seen(ring, cqe);
            shu_io_async_notify_cq(1);
            st->pending = 0;
            st->reaped = 0;
            return res >= 0 ? res : -1;
        }
        return (int32_t)-2;
    }
#else
    {
        ptrdiff_t r = io_read((int)st->handle, st->ptr, st->len, 0);
        st->pending = 0;
        shu_io_async_notify_cq(1);
        if (r < 0)
            return -1;
        return (int32_t)r;
    }
#endif
}

/**
 * IO-A5：收割在途 read async（v1 兼容：仅当恰有 1 个 read in-flight 时无 slot 完成）。
 */
int32_t shu_io_complete_read_async(void) {
    int cap = shu_io_async_slot_count();
    int pending = 0;
    int only = -1;
    int i;
    for (i = 0; i < cap; i++) {
        if (shu_io_read_slots[i].pending) {
            pending++;
            only = i;
        }
    }
    if (pending == 1)
        return shu_io_complete_read_async_slot(only);
    return -1;
}

/** IO 写：fd 为 handle（1=stdout，≥2 为任意 fd）；timeout_ms 毫秒，0=无超时。返回写入字节数，-1=错误/超时。 */
ptrdiff_t io_write(int fd, const uint8_t *buf, size_t count, unsigned timeout_ms) {
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            int use_idx = -1;
            if (ut->use_sqpoll)
                use_idx = uring_get_fd_slot(ut, fd);
            {
                struct io_uring *ring = &ut->ring;
                struct io_uring_sqe *sqe;
                struct io_uring_cqe *cqe;
                struct io_uring_cqe *cqe_ptrs[1];
                struct __kernel_timespec ts;
                if (timeout_ms > 0) {
                    ts.tv_sec = (long long)(timeout_ms / 1000u);
                    ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
                }
                sqe = io_uring_get_sqe(ring);
                if (sqe) {
                    if (use_idx >= 0) {
                        io_uring_prep_write(sqe, use_idx, (void *)buf, count, 0);
                        sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
                    } else {
                        io_uring_prep_write(sqe, fd, (void *)buf, count, 0);
                    }
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (timeout_ms == 0) {
                    if (io_uring_submit_and_wait(ring, 1) == 1) {
                        unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                        if (got >= 1) {
                            cqe = cqe_ptrs[0];
                            ptrdiff_t res = (ptrdiff_t)cqe->res;
                            io_uring_cqe_seen(ring, cqe);
                            shu_io_async_notify_cq(1);
                            return res >= 0 ? res : -1;
                        }
                        return -1;
                    }
                } else {
                    if (io_uring_submit(ring) == 1) {
                        int wait_ret = io_uring_wait_cqe_timeout(ring, &cqe, &ts);
                        if (wait_ret == 0 && cqe) {
                            ptrdiff_t res = (ptrdiff_t)cqe->res;
                            io_uring_cqe_seen(ring, cqe);
                            shu_io_async_notify_cq(1);
                            return res >= 0 ? res : -1;
                        }
                        if (cqe) io_uring_cqe_seen(ring, cqe);
                        return -1;
                    }
                }
            }
            }
        }
    }
    return FALLBACK_WRITE(fd, buf, count);
#endif

#if defined(__APPLE__)
    if (fd >= 3) {
        int kq = kq_get();
        if (kq >= 0) {
            struct kevent ev, ev_out;
            struct timespec ts_abs, *pts = NULL;
            if (timeout_ms > 0) {
                ts_abs.tv_sec = (timeout_ms / 1000u);
                ts_abs.tv_nsec = (long)((timeout_ms % 1000u) * 1000000u);
                pts = &ts_abs;
            }
            EV_SET(&ev, (uintptr_t)fd, EVFILT_WRITE, EV_ADD | EV_ONESHOT | EV_CLEAR, 0, 0, 0);
            if (kevent(kq, &ev, 1, NULL, 0, pts) >= 0 &&
                kevent(kq, NULL, 0, &ev_out, 1, pts) >= 0)
                return (ptrdiff_t)write(fd, buf, count);
        }
    }
    return FALLBACK_WRITE(fd, buf, count);
#endif

#if defined(_WIN32) || defined(_WIN64)
    {
        DWORD wait_ms = (timeout_ms == 0) ? INFINITE : (DWORD)timeout_ms;
        HANDLE h = (HANDLE)_get_osfhandle(fd);
        if (h != INVALID_HANDLE_VALUE && g_iocp) {
            CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
            OVERLAPPED ov = { 0 };
            if (WriteFile(h, buf, (DWORD)(count > 0x7FFFFFFFu ? 0x7FFFFFFFu : count), NULL, &ov)) {
                DWORD bytes = 0;
                GetOverlappedResult(h, &ov, &bytes, TRUE);
                return (ptrdiff_t)bytes;
            }
            if (GetLastError() == ERROR_IO_PENDING) {
                DWORD bytes = 0;
                if (GetOverlappedResultEx(h, &ov, &bytes, wait_ms, 0))
                    return (ptrdiff_t)bytes;
                return -1; /* 超时或错误 */
            }
        }
    }
    return FALLBACK_WRITE(fd, buf, count);
#endif

#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    (void)timeout_ms;
    return FALLBACK_WRITE(fd, buf, count);
#endif
}

/**
 * IO-A5：提交非阻塞 write（io_uring submit 不 wait；非 Linux 登记状态供 complete 同步写）。
 * 成功返回 slot 索引（>=0），失败或槽满返回 -1。
 */
int shu_io_submit_write_async(const uint8_t *ptr, size_t len, size_t handle) {
    int slot;
    if (!ptr || len == 0)
        return -1;
    slot = shu_io_write_slot_alloc();
    if (slot < 0)
        return -1;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        struct io_uring *ring;
        struct io_uring_sqe *sqe;
        int fd = (int)handle;
        int use_idx = -1;
        if (!ut || !ut->ok)
            return -1;
        ring = &ut->ring;
        if (ut->use_sqpoll)
            use_idx = uring_get_fd_slot(ut, fd);
        sqe = io_uring_get_sqe(ring);
        if (!sqe)
            return -1;
        if (use_idx >= 0) {
            io_uring_prep_write(sqe, use_idx, (void *)ptr, len, 0);
            sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
        } else {
            io_uring_prep_write(sqe, fd, (void *)ptr, len, 0);
        }
        io_uring_sqe_set_data(sqe, (void *)shu_io_write_slot_udata((unsigned)slot));
        if (io_uring_submit(ring) < 0)
            return -1;
        shu_io_write_slots[slot].pending = 1;
        shu_io_write_slots[slot].reaped = 0;
        shu_io_write_slots[slot].handle = handle;
        shu_io_write_slots[slot].ptr = ptr;
        shu_io_write_slots[slot].len = len;
        return slot;
    }
#else
    shu_io_write_slots[slot].pending = 1;
    shu_io_write_slots[slot].reaped = 0;
    shu_io_write_slots[slot].handle = handle;
    shu_io_write_slots[slot].ptr = ptr;
    shu_io_write_slots[slot].len = len;
    return slot;
#endif
}

/**
 * IO-A5 v2：收割指定 slot 的 write async；>0 字节数，-1=错误，-2=尚未完成。
 */
int32_t shu_io_complete_write_async_slot(int slot) {
    shu_io_write_async_slot_t *st;
    if (slot < 0 || slot >= shu_io_async_slot_count())
        return -1;
    st = &shu_io_write_slots[slot];
    if (st->reaped) {
        int32_t out = st->reaped_res >= 0 ? st->reaped_res : -1;
        st->reaped = 0;
        st->pending = 0;
        return out;
    }
    if (!st->pending)
        return -1;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        struct io_uring *ring;
        struct io_uring_cqe *cqe_ptrs[8];
        unsigned got;
        unsigned i;
        int32_t res;
        if (!ut || !ut->ok)
            return -1;
        ring = &ut->ring;
        got = (unsigned)io_uring_peek_batch_cqe(ring, cqe_ptrs, 8);
        for (i = 0; i < got; i++) {
            struct io_uring_cqe *cqe = cqe_ptrs[i];
            uintptr_t u = (uintptr_t)io_uring_cqe_get_data(cqe);
            int s = shu_io_write_udata_to_slot(u);
            if (s != slot)
                continue;
            res = (int32_t)cqe->res;
            io_uring_cqe_seen(ring, cqe);
            shu_io_async_notify_cq(1);
            st->pending = 0;
            st->reaped = 0;
            return res >= 0 ? res : -1;
        }
        return (int32_t)-2;
    }
#else
    {
        ptrdiff_t r = io_write((int)st->handle, st->ptr, st->len, 0);
        st->pending = 0;
        shu_io_async_notify_cq(1);
        if (r < 0)
            return -1;
        return (int32_t)r;
    }
#endif
}

/**
 * IO-A5：收割在途 write async（v1 兼容：仅当恰有 1 个 write in-flight 时无 slot 完成）。
 */
int32_t shu_io_complete_write_async(void) {
    int cap = shu_io_async_slot_count();
    int pending = 0;
    int only = -1;
    int i;
    for (i = 0; i < cap; i++) {
        if (shu_io_write_slots[i].pending) {
            pending++;
            only = i;
        }
    }
    if (pending == 1)
        return shu_io_complete_write_async_slot(only);
    return -1;
}

/** 批量读：最多 4 段 (p0,l0)..(p3,l3)，n 为实际段数（1..4）。timeout_ms=0 时 Linux 用 io_uring 一次提交 n 个 SQE（阶段 2 起步），POSIX 非 Linux 用 readv。已 register_fixed_buffers 时走 read_fixed。 */
ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms) {
    if (n <= 0 || n > 4) return -1;
    if (n == 1) return io_read(fd, p0, l0, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0 && n >= 2) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            uint8_t *ps_skip[4] = { p0, p1, p2, p3 };
            /* 已 register_fixed_buffers 时走下方 multi-SQE read_fixed，避免 readv 忽略 fixed 池。 */
            if (!uring_batch_all_fixed(ut, ps_skip, n)) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[4];
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[1];
            int use_idx = -1;
            if (ut->use_sqpoll)
                use_idx = uring_get_fd_slot(ut, fd);
            iov[0].iov_base = (void *)p0; iov[0].iov_len = l0;
            iov[1].iov_base = (void *)p1; iov[1].iov_len = l1;
            if (n >= 3) { iov[2].iov_base = (void *)p2; iov[2].iov_len = l2; }
            if (n >= 4) { iov[3].iov_base = (void *)p3; iov[3].iov_len = l3; }
            sqe = io_uring_get_sqe(ring);
            if (sqe) {
                if (use_idx >= 0) {
                    io_uring_prep_readv(sqe, use_idx, iov, (unsigned)n, 0);
                    sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
                } else {
                    io_uring_prep_readv(sqe, fd, iov, (unsigned)n, 0);
                }
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
            }
        }
    }
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[4];
            int i, submitted;
            uint8_t *ps[4] = { p0, p1, p2, p3 };
            size_t ls[4] = { l0, l1, l2, l3 };
            int use_fixed = uring_batch_all_fixed(ut, ps, n);
            if (io_uring_sq_space_left(ring) >= (unsigned)n) {
                int fd_slot = -1;
                if (ut->use_sqpoll)
                    fd_slot = uring_get_fd_slot(ut, fd);
                for (i = 0; i < n; i++) {
                    sqe = io_uring_get_sqe(ring);
                    if (!sqe) break;
                    if (use_fixed) {
                        int bi = uring_fixed_buf_index(ut, ps[i]);
                        if (fd_slot >= 0) {
                            io_uring_prep_read_fixed(sqe, fd_slot, (void *)ps[i], (unsigned)ls[i], (uint64_t)-1, bi);
                            sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
                        } else {
                            io_uring_prep_read_fixed(sqe, fd, (void *)ps[i], (unsigned)ls[i], (uint64_t)-1, bi);
                        }
                    } else if (fd_slot >= 0) {
                        io_uring_prep_read(sqe, fd_slot, ps[i], ls[i], 0);
                        sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
                    } else {
                        io_uring_prep_read(sqe, fd, ps[i], ls[i], 0);
                    }
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
                }
                if (i == n && (submitted = io_uring_submit_and_wait(ring, n)) == n) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, (unsigned)n);
                    if (got >= (unsigned)n) {
                        ptrdiff_t total = 0;
                        for (i = 0; i < n; i++) {
                            if (cqe_ptrs[i]->res < 0) {
                                for (i = 0; i < n; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                                return -1;
                            }
                            total += (ptrdiff_t)cqe_ptrs[i]->res;
                            io_uring_cqe_seen(ring, cqe_ptrs[i]);
                        }
                        return total;
                    }
                    for (i = 0; i < (int)got; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL)
                g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_read, n);
                {
                    uint8_t *ps[4] = { p0, p1, p2, p3 };
                    size_t ls[4] = { l0, l1, l2, l3 };
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(ls[i] > 0x7FFFFFFFu ? 0x7FFFFFFFu : ls[i]);
                        if (ReadFile(h, ps[i], ulen, NULL, &ovt->ov_read[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_read[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING)
                            issued++;
                        else
                            break;
                    }
                    if (issued == n) {
                        int need = n - sync_count;
                        OVERLAPPED_ENTRY entries[4];
                        ULONG removed;
                        int got = 0;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, 4, &removed, INFINITE, FALSE))
                                break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE))
                                    return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need)
                            return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[4];
        iov[0].iov_base = (void *)p0; iov[0].iov_len = l0;
        if (n >= 2) { iov[1].iov_base = (void *)p1; iov[1].iov_len = l1; }
        if (n >= 3) { iov[2].iov_base = (void *)p2; iov[2].iov_len = l2; }
        if (n >= 4) { iov[3].iov_base = (void *)p3; iov[3].iov_len = l3; }
        return io_readv_all(fd, iov, n);
    }
#endif
    /* 带超时或非批量路径：逐段读 */
    ptrdiff_t total = 0;
    ptrdiff_t r0 = io_read(fd, p0, l0, timeout_ms);
    if (r0 < 0) return -1;
    total += r0;
    if (n == 1) return total;
    ptrdiff_t r1 = io_read(fd, p1, l1, timeout_ms);
    if (r1 < 0) return -1;
    total += r1;
    if (n == 2) return total;
    ptrdiff_t r2 = io_read(fd, p2, l2, timeout_ms);
    if (r2 < 0) return -1;
    total += r2;
    if (n == 3) return total;
    ptrdiff_t r3 = io_read(fd, p3, l3, timeout_ms);
    if (r3 < 0) return -1;
    return total + r3;
}

/** 批量写：最多 4 段；timeout_ms=0 时 Linux 用 io_uring prep_writev 单 SQE（n>=2）或 n×write，POSIX 用 writev。 */
ptrdiff_t io_write_batch(int fd, const uint8_t *p0, size_t l0, const uint8_t *p1, size_t l1, const uint8_t *p2, size_t l2, const uint8_t *p3, size_t l3, int n, unsigned timeout_ms) {
    if (n <= 0 || n > 4) return -1;
    if (n == 1) return io_write(fd, p0, l0, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0 && n >= 2) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[4];
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[1];
            iov[0].iov_base = (void *)p0; iov[0].iov_len = l0;
            iov[1].iov_base = (void *)p1; iov[1].iov_len = l1;
            if (n >= 3) { iov[2].iov_base = (void *)p2; iov[2].iov_len = l2; }
            if (n >= 4) { iov[3].iov_base = (void *)p3; iov[3].iov_len = l3; }
            sqe = io_uring_get_sqe(ring);
            if (sqe) {
                io_uring_prep_writev(sqe, fd, iov, (unsigned)n, 0);
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
        }
    }
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[4];
            int i, submitted;
            const uint8_t *ps[4] = { p0, p1, p2, p3 };
            size_t ls[4] = { l0, l1, l2, l3 };
            if (io_uring_sq_space_left(ring) >= (unsigned)n) {
                for (i = 0; i < n; i++) {
                    sqe = io_uring_get_sqe(ring);
                    if (!sqe) break;
                    io_uring_prep_write(sqe, fd, ps[i], ls[i], 0);
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
                }
                if (i == n && (submitted = io_uring_submit_and_wait(ring, n)) == n) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, (unsigned)n);
                    if (got >= (unsigned)n) {
                        ptrdiff_t total = 0;
                        for (i = 0; i < n; i++) {
                            if (cqe_ptrs[i]->res < 0) {
                                for (i = 0; i < n; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                                return -1;
                            }
                            total += (ptrdiff_t)cqe_ptrs[i]->res;
                            io_uring_cqe_seen(ring, cqe_ptrs[i]);
                        }
                        return total;
                    }
                    for (i = 0; i < (int)got; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL)
                g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_write, n);
                {
                    const uint8_t *ps[4] = { p0, p1, p2, p3 };
                    size_t ls[4] = { l0, l1, l2, l3 };
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(ls[i] > 0x7FFFFFFFu ? 0x7FFFFFFFu : ls[i]);
                        if (WriteFile(h, ps[i], ulen, NULL, &ovt->ov_write[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_write[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING)
                            issued++;
                        else
                            break;
                    }
                    if (issued == n) {
                        int need = n - sync_count;
                        OVERLAPPED_ENTRY entries[4];
                        ULONG removed;
                        int got = 0;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, 4, &removed, INFINITE, FALSE))
                                break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE))
                                    return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need)
                            return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[4];
        iov[0].iov_base = (void *)p0; iov[0].iov_len = l0;
        if (n >= 2) { iov[1].iov_base = (void *)p1; iov[1].iov_len = l1; }
        if (n >= 3) { iov[2].iov_base = (void *)p2; iov[2].iov_len = l2; }
        if (n >= 4) { iov[3].iov_base = (void *)p3; iov[3].iov_len = l3; }
        return io_writev_all(fd, iov, n);
    }
#endif
    ptrdiff_t total = 0;
    ptrdiff_t r0 = io_write(fd, p0, l0, timeout_ms);
    if (r0 < 0) return -1;
    total += r0;
    if (n == 1) return total;
    ptrdiff_t r1 = io_write(fd, p1, l1, timeout_ms);
    if (r1 < 0) return -1;
    total += r1;
    if (n == 2) return total;
    ptrdiff_t r2 = io_write(fd, p2, l2, timeout_ms);
    if (r2 < 0) return -1;
    total += r2;
    if (n == 3) return total;
    ptrdiff_t r3 = io_write(fd, p3, l3, timeout_ms);
    if (r3 < 0) return -1;
    return total + r3;
}

/** 阶段 2 超越：批量读最多 8 段（路线图 §4.2 更大批量）；C 侧 API，.su 仍用 4 段 batch。n 为 1..8。 */
ptrdiff_t io_read_batch_8(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3,
    uint8_t *p4, size_t l4, uint8_t *p5, size_t l5, uint8_t *p6, size_t l6, uint8_t *p7, size_t l7,
    int n, unsigned timeout_ms) {
    if (n <= 0 || n > 8) return -1;
    if (n <= 4) return io_read_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[8];
            uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
            size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[8];
            int i, submitted;
            for (i = 0; i < n; i++) { iov[i].iov_base = (void *)ps[i]; iov[i].iov_len = ls[i]; }
            sqe = io_uring_get_sqe(ring);
            if (sqe && n >= 2) {
                io_uring_prep_readv(sqe, fd, iov, (unsigned)n, 0);
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
            if (io_uring_sq_space_left(ring) >= (unsigned)n) {
                for (i = 0; i < n; i++) {
                    sqe = io_uring_get_sqe(ring);
                    if (!sqe) break;
                    io_uring_prep_read(sqe, fd, ps[i], ls[i], 0);
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
                }
                if (i == n && (submitted = io_uring_submit_and_wait(ring, n)) == n) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, (unsigned)n);
                    if (got >= (unsigned)n) {
                        ptrdiff_t total = 0;
                        for (i = 0; i < n; i++) {
                            if (cqe_ptrs[i]->res < 0) {
                                for (i = 0; i < n; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                                return -1;
                            }
                            total += (ptrdiff_t)cqe_ptrs[i]->res;
                            io_uring_cqe_seen(ring, cqe_ptrs[i]);
                        }
                        return total;
                    }
                    for (i = 0; i < (int)got; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL)
                g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_read, n);
                {
                    uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
                    size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    OVERLAPPED_ENTRY entries[IO_BATCH_MAX_WIN];
                    ULONG removed;
                    int got = 0, need;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(ls[i] > 0x7FFFFFFFu ? 0x7FFFFFFFu : ls[i]);
                        if (ReadFile(h, ps[i], ulen, NULL, &ovt->ov_read[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_read[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING)
                            issued++;
                        else
                            break;
                    }
                    if (issued == n) {
                        need = n - sync_count;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, IO_BATCH_MAX_WIN, &removed, INFINITE, FALSE))
                                break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE))
                                    return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need)
                            return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[8];
        uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
        size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
        int i;
        for (i = 0; i < n; i++) { iov[i].iov_base = (void *)ps[i]; iov[i].iov_len = ls[i]; }
        return (ptrdiff_t)readv(fd, iov, n);
    }
#endif
    {
        ptrdiff_t total = 0, r;
        uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
        size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
        int i;
        for (i = 0; i < n; i++) {
            r = io_read(fd, ps[i], ls[i], timeout_ms);
            if (r < 0) return -1;
            total += r;
        }
        return total;
    }
}

/** 阶段 2 超越：批量写最多 8 段；C 侧 API。n 为 1..8。 */
ptrdiff_t io_write_batch_8(int fd, const uint8_t *p0, size_t l0, const uint8_t *p1, size_t l1, const uint8_t *p2, size_t l2, const uint8_t *p3, size_t l3,
    const uint8_t *p4, size_t l4, const uint8_t *p5, size_t l5, const uint8_t *p6, size_t l6, const uint8_t *p7, size_t l7,
    int n, unsigned timeout_ms) {
    if (n <= 0 || n > 8) return -1;
    if (n <= 4) return io_write_batch(fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[8];
            const uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
            size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[8];
            int i, submitted;
            for (i = 0; i < n; i++) { iov[i].iov_base = (void *)ps[i]; iov[i].iov_len = ls[i]; }
            sqe = io_uring_get_sqe(ring);
            if (sqe && n >= 2) {
                io_uring_prep_writev(sqe, fd, iov, (unsigned)n, 0);
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
            if (io_uring_sq_space_left(ring) >= (unsigned)n) {
                for (i = 0; i < n; i++) {
                    sqe = io_uring_get_sqe(ring);
                    if (!sqe) break;
                    io_uring_prep_write(sqe, fd, (void *)ps[i], ls[i], 0);
                    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
                }
                if (i == n && (submitted = io_uring_submit_and_wait(ring, n)) == n) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, (unsigned)n);
                    if (got >= (unsigned)n) {
                        ptrdiff_t total = 0;
                        for (i = 0; i < n; i++) {
                            if (cqe_ptrs[i]->res < 0) {
                                for (i = 0; i < n; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                                return -1;
                            }
                            total += (ptrdiff_t)cqe_ptrs[i]->res;
                            io_uring_cqe_seen(ring, cqe_ptrs[i]);
                        }
                        return total;
                    }
                    for (i = 0; i < (int)got; i++) io_uring_cqe_seen(ring, cqe_ptrs[i]);
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL)
                g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_write, n);
                {
                    const uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
                    size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    OVERLAPPED_ENTRY entries[IO_BATCH_MAX_WIN];
                    ULONG removed;
                    int got = 0, need;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(ls[i] > 0x7FFFFFFFu ? 0x7FFFFFFFu : ls[i]);
                        if (WriteFile(h, ps[i], ulen, NULL, &ovt->ov_write[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_write[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING)
                            issued++;
                        else
                            break;
                    }
                    if (issued == n) {
                        need = n - sync_count;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, IO_BATCH_MAX_WIN, &removed, INFINITE, FALSE))
                                break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE))
                                    return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need)
                            return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[8];
        const uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
        size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
        int i;
        for (i = 0; i < n; i++) { iov[i].iov_base = (void *)ps[i]; iov[i].iov_len = ls[i]; }
        return (ptrdiff_t)writev(fd, iov, n);
    }
#endif
    {
        ptrdiff_t total = 0, r;
        const uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
        size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
        int i;
        for (i = 0; i < n; i++) {
            r = io_write(fd, ps[i], ls[i], timeout_ms);
            if (r < 0) return -1;
            total += r;
        }
        return total;
    }
}

/** 与 Zig/Rust 对齐：按「指针+段数」批量读；bufs 为 shu_batch_buf_t 数组（ptr/len 有效，handle 可忽略），n 为 1..IO_READV_BUF_MAX。一次 readv/io_uring 覆盖多段，减少 syscall。 */
ptrdiff_t io_read_batch_buf(int fd, const shu_batch_buf_t *bufs, int n, unsigned timeout_ms) {
    if (n <= 0 || n > IO_READV_BUF_MAX || !bufs) return -1;
    if (n == 1) return io_read(fd, bufs[0].ptr, bufs[0].len, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[IO_READV_BUF_MAX];
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[1];
            int i;
            for (i = 0; i < n; i++) { iov[i].iov_base = (void *)bufs[i].ptr; iov[i].iov_len = bufs[i].len; }
            sqe = io_uring_get_sqe(ring);
            if (sqe) {
                io_uring_prep_readv(sqe, fd, iov, (unsigned)n, 0);
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0 && n <= IO_BATCH_MAX_WIN) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL) g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_read, n);
                {
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(bufs[i].len > 0x7FFFFFFFu ? 0x7FFFFFFFu : bufs[i].len);
                        if (ReadFile(h, bufs[i].ptr, ulen, NULL, &ovt->ov_read[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_read[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING) issued++;
                        else break;
                    }
                    if (issued == n) {
                        int need = n - sync_count;
                        OVERLAPPED_ENTRY entries[IO_BATCH_MAX_WIN];
                        ULONG removed;
                        int got = 0;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, IO_BATCH_MAX_WIN, &removed, INFINITE, FALSE)) break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE)) return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need) return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[IO_READV_BUF_MAX];
        int i;
        for (i = 0; i < n; i++) { iov[i].iov_base = (void *)bufs[i].ptr; iov[i].iov_len = bufs[i].len; }
        return (ptrdiff_t)readv(fd, iov, n);
    }
#endif
    {
        ptrdiff_t total = 0, r;
        int i;
        for (i = 0; i < n; i++) {
            r = io_read(fd, bufs[i].ptr, bufs[i].len, timeout_ms);
            if (r < 0) return -1;
            total += r;
        }
        return total;
    }
}

/** 与 Zig/Rust 对齐：按「指针+段数」批量写；bufs 同上，n 为 1..IO_READV_BUF_MAX。 */
ptrdiff_t io_write_batch_buf(int fd, const shu_batch_buf_t *bufs, int n, unsigned timeout_ms) {
    if (n <= 0 || n > IO_READV_BUF_MAX || !bufs) return -1;
    if (n == 1) return io_write(fd, bufs[0].ptr, bufs[0].len, timeout_ms);
#if defined(__linux__)
    if (timeout_ms == 0) {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->ok) {
            struct io_uring *ring = &ut->ring;
            struct iovec iov[IO_READV_BUF_MAX];
            struct io_uring_sqe *sqe;
            struct io_uring_cqe *cqe_ptrs[1];
            int i;
            for (i = 0; i < n; i++) { iov[i].iov_base = (void *)bufs[i].ptr; iov[i].iov_len = bufs[i].len; }
            sqe = io_uring_get_sqe(ring);
            if (sqe) {
                io_uring_prep_writev(sqe, fd, iov, (unsigned)n, 0);
                io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                if (io_uring_submit_and_wait(ring, 1) == 1) {
                    unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                    if (got >= 1) {
                        ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                        io_uring_cqe_seen(ring, cqe_ptrs[0]);
                        return res >= 0 ? res : -1;
                    }
                    return -1;
                }
            }
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    if (timeout_ms == 0 && n <= IO_BATCH_MAX_WIN) {
        HANDLE h = (HANDLE)_get_osfhandle((int)fd);
        win_ov_thread_t *ovt = win_get_thread_ov();
        if (h != INVALID_HANDLE_VALUE && h != NULL && ovt != NULL) {
            if (g_iocp_cs_init == 0) { InitializeCriticalSection(&g_iocp_cs); g_iocp_cs_init = 1; }
            EnterCriticalSection(&g_iocp_cs);
            if (g_iocp == NULL) g_iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
            LeaveCriticalSection(&g_iocp_cs);
            if (g_iocp != NULL) {
                (void)CreateIoCompletionPort(h, g_iocp, (ULONG_PTR)(uintptr_t)fd, 0);
                (void)win_handle_skip_set(h);
                win_zero_overlapped(ovt->ov_write, n);
                {
                    DWORD ulen;
                    int i, issued = 0, sync_count = 0;
                    ptrdiff_t total = 0;
                    for (i = 0; i < n; i++) {
                        ulen = (DWORD)(bufs[i].len > 0x7FFFFFFFu ? 0x7FFFFFFFu : bufs[i].len);
                        if (WriteFile(h, bufs[i].ptr, ulen, NULL, &ovt->ov_write[i])) {
                            issued++;
                            { DWORD bytes = 0; GetOverlappedResult(h, &ovt->ov_write[i], &bytes, FALSE); total += (ptrdiff_t)bytes; sync_count++; }
                        } else if (GetLastError() == ERROR_IO_PENDING) issued++;
                        else break;
                    }
                    if (issued == n) {
                        int need = n - sync_count;
                        OVERLAPPED_ENTRY entries[IO_BATCH_MAX_WIN];
                        ULONG removed;
                        int got = 0;
                        while (got < need) {
                            if (!GetQueuedCompletionStatusEx(g_iocp, entries, IO_BATCH_MAX_WIN, &removed, INFINITE, FALSE)) break;
                            for (ulen = 0; ulen < removed && got < need; ulen++) {
                                DWORD bytes = 0;
                                if (!GetOverlappedResult(h, entries[ulen].lpOverlapped, &bytes, FALSE)) return -1;
                                total += (ptrdiff_t)bytes;
                                got++;
                            }
                        }
                        if (got == need) return total;
                    }
                }
            }
        }
    }
#endif
#if !defined(_WIN32) && !defined(_WIN64)
    if (timeout_ms == 0) {
        struct iovec iov[IO_READV_BUF_MAX];
        int i;
        for (i = 0; i < n; i++) { iov[i].iov_base = (void *)bufs[i].ptr; iov[i].iov_len = bufs[i].len; }
        return (ptrdiff_t)writev(fd, iov, n);
    }
#endif
    {
        ptrdiff_t total = 0, r;
        int i;
        for (i = 0; i < n; i++) {
            r = io_write(fd, bufs[i].ptr, bufs[i].len, timeout_ms);
            if (r < 0) return -1;
            total += r;
        }
        return total;
    }
}

/** 注册当前线程的固定 buffer 池（最多 8 块）：p0..p7 与 l0..l7 为 (ptr,len) 对，nr 为实际数量 1..8。Linux 上 io_uring_register_buffers，它平台仅存 iov 供 read_fixed/write_fixed。返回 1 成功，0 失败。 */
int io_register_buffers(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3,
    uint8_t *p4, size_t l4, uint8_t *p5, size_t l5, uint8_t *p6, size_t l6, uint8_t *p7, size_t l7,
    unsigned nr) {
    if (nr == 0 || nr > IO_FIXED_MAX) return 0;
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    if (!ut) return 0;
    if (ut->fixed_ok) {
        (void)io_uring_unregister_buffers(&ut->ring);
        ut->fixed_ok = 0;
    }
    {
        uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
        size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
        unsigned i;
        for (i = 0; i < nr; i++) {
            if (!ps[i]) return 0;
            ut->fixed_iov[i].iov_base = (void *)ps[i];
            ut->fixed_iov[i].iov_len = ls[i];
        }
        ut->fixed_nr = nr;
        if (io_uring_register_buffers(&ut->ring, ut->fixed_iov, nr) != 0) {
            ut->fixed_nr = 0;
            return 0;
        }
        ut->fixed_ok = 1;
    }
    return 1;
#endif
#if defined(__APPLE__)
    fixed_pool_t *p;
    uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
    size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
    unsigned i;
    (void)pthread_once(&g_fixed_key_once, fixed_key_init);
    p = (fixed_pool_t *)pthread_getspecific(g_fixed_key);
    if (p) { free(p); p = NULL; }
    for (i = 0; i < nr; i++) if (!ps[i]) return 0;
    p = (fixed_pool_t *)malloc(sizeof(*p));
    if (!p) return 0;
    for (i = 0; i < nr; i++) {
        p->iov[i].iov_base = (void *)ps[i];
        p->iov[i].iov_len = ls[i];
    }
    p->nr = nr;
    pthread_setspecific(g_fixed_key, p);
    return 1;
#endif
#if defined(_WIN32) || defined(_WIN64)
    win_fixed_pool_t *pool;
    uint8_t *ps[8] = { p0, p1, p2, p3, p4, p5, p6, p7 };
    size_t ls[8] = { l0, l1, l2, l3, l4, l5, l6, l7 };
    unsigned i;
    pool = win_get_fixed_pool();
    if (pool) { free(pool); pool = NULL; }
    for (i = 0; i < nr; i++) if (!ps[i]) return 0;
    pool = (win_fixed_pool_t *)malloc(sizeof(*pool));
    if (!pool) return 0;
    for (i = 0; i < nr; i++) {
        pool->base[i] = (void *)ps[i];
        pool->len[i] = ls[i];
    }
    pool->nr = nr;
    TlsSetValue(g_win_fixed_tls_idx, pool);
    return 1;
#endif
#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    (void)p0; (void)l0; (void)p1; (void)l1; (void)p2; (void)l2; (void)p3; (void)l3;
    (void)p4; (void)l4; (void)p5; (void)l5; (void)p6; (void)l6; (void)p7; (void)l7;
    (void)nr;
    return 0;
#endif
}

/** 注册当前线程的固定 buffer（单 buffer）：等同于 io_register_buffers(ptr,len, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 1)。返回 1 成功，0 失败。 */
int io_register_buffer(uint8_t *ptr, size_t len) {
    return io_register_buffers(ptr, len,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1);
}

/** 供 .su 调用：最多 4 块 buffer（避免 .su 参数个数限制）；内部转调 io_register_buffers，p4..p7 传 0。 */
int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, unsigned nr) {
    if (nr > 4) return 0;
    return io_register_buffers(p0, l0, p1, l1, p2, l2, p3, l3,
        0, 0, 0, 0, 0, 0, 0, 0,
        nr);
}

/** 与 Zig/Rust 对齐：按「指针+块数」注册固定 buffer 池；bufs 为 shu_batch_buf_t 数组，nr 为 1..IO_FIXED_MAX（8）。仅用 ptr/len。返回 1 成功，0 失败。io_abi.h 以 io_register_buffers_buf_c 声明供生成 C 通过宏调用。 */
int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);

/** codegen 可能生成 (io_register_buffers_buf)(bufs,nr) 导致宏不展开，链接时需此符号；包装调用 io_register_buffers_buf_c。 */
int io_register_buffers_buf(int32_t bufs, int nr) {
    return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr);
}

int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr) {
    if (nr <= 0 || nr > (int)IO_FIXED_MAX || !bufs) return 0;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        if (!ut) return 0;
        if (ut->fixed_ok) {
            (void)io_uring_unregister_buffers(&ut->ring);
            ut->fixed_ok = 0;
        }
        {
            unsigned i;
            for (i = 0; i < (unsigned)nr; i++) {
                if (!bufs[i].ptr) return 0;
                ut->fixed_iov[i].iov_base = (void *)bufs[i].ptr;
                ut->fixed_iov[i].iov_len = bufs[i].len;
            }
            ut->fixed_nr = (unsigned)nr;
            if (io_uring_register_buffers(&ut->ring, ut->fixed_iov, (unsigned)nr) != 0) {
                ut->fixed_nr = 0;
                return 0;
            }
            ut->fixed_ok = 1;
        }
    }
    return 1;
#endif
#if defined(__APPLE__)
    {
        fixed_pool_t *p;
        unsigned i;
        (void)pthread_once(&g_fixed_key_once, fixed_key_init);
        p = (fixed_pool_t *)pthread_getspecific(g_fixed_key);
        if (p) { free(p); p = NULL; }
        for (i = 0; i < (unsigned)nr; i++) if (!bufs[i].ptr) return 0;
        p = (fixed_pool_t *)malloc(sizeof(*p));
        if (!p) return 0;
        for (i = 0; i < (unsigned)nr; i++) {
            p->iov[i].iov_base = (void *)bufs[i].ptr;
            p->iov[i].iov_len = bufs[i].len;
        }
        p->nr = (unsigned)nr;
        pthread_setspecific(g_fixed_key, p);
    }
    return 1;
#endif
#if defined(_WIN32) || defined(_WIN64)
    {
        win_fixed_pool_t *pool;
        unsigned i;
        pool = win_get_fixed_pool();
        if (pool) { free(pool); pool = NULL; }
        for (i = 0; i < (unsigned)nr; i++) if (!bufs[i].ptr) return 0;
        pool = (win_fixed_pool_t *)malloc(sizeof(*pool));
        if (!pool) return 0;
        for (i = 0; i < (unsigned)nr; i++) {
            pool->base[i] = (void *)bufs[i].ptr;
            pool->len[i] = bufs[i].len;
        }
        pool->nr = (unsigned)nr;
        TlsSetValue(g_win_fixed_tls_idx, pool);
    }
    return 1;
#endif
#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    (void)bufs;
    (void)nr;
    return 0;
#endif
}

/** 注销当前线程的固定 buffer 池。 */
void io_unregister_buffers(void) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    if (ut && ut->fixed_ok) {
        (void)io_uring_unregister_buffers(&ut->ring);
        ut->fixed_ok = 0;
        ut->fixed_nr = 0;
    }
#endif
#if defined(__APPLE__)
    fixed_pool_t *p;
    (void)pthread_once(&g_fixed_key_once, fixed_key_init);
    p = (fixed_pool_t *)pthread_getspecific(g_fixed_key);
    if (p) {
        pthread_setspecific(g_fixed_key, NULL);
        free(p);
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    win_fixed_pool_t *p = win_get_fixed_pool();
    if (p) {
        TlsSetValue(g_win_fixed_tls_idx, NULL);
        free(p);
    }
#endif
}

/* ─── ZC-1：Provided Buffers（IORING_OP_PROVIDE_BUFFERS + IOSQE_BUFFER_SELECT）─── */

/** 注册当前线程 provided buffer 池；nr 1..32，bufsz 建议 4096。Linux io_uring 专用。返回 1 成功，0 失败/不支持。 */
int io_register_provided_buffers(unsigned nr, unsigned bufsz) {
#if defined(__linux__)
    uring_thread_t *ut;
    if (!io_uring_provide_wanted())
        return 0;
    if (nr == 0)
        nr = IO_PROVIDED_NR_DEFAULT;
    if (bufsz == 0)
        bufsz = IO_PROVIDED_BUFSZ_DEFAULT;
    ut = uring_get_thread();
    if (!ut || !ut->ok)
        return 0;
    return io_provide_buffers_init_pool(ut, nr, bufsz);
#else
    (void)nr;
    (void)bufsz;
    return 0;
#endif
}

/** 注销 provided buffer 池（释放内存；下次读须重新 register）。 */
void io_unregister_provided_buffers(void) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    if (ut && ut->provided_base) {
        free(ut->provided_base);
        ut->provided_base = NULL;
        ut->provided_ok = 0;
        ut->provided_nr = 0;
        ut->provided_bufsz = 0;
    }
#else
    return;
#endif
}

/** 返回 provided 池内 bid 对应只读指针；无效 bid 返回 NULL。 */
uint8_t *io_provided_buffer_ptr(unsigned bid) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    if (!ut || !ut->provided_ok || bid >= ut->provided_nr || !ut->provided_base)
        return NULL;
    return ut->provided_base + (size_t)bid * (size_t)ut->provided_bufsz;
#else
    (void)bid;
    return NULL;
#endif
}

/** 当前线程 provided 池单块容量（字节）。 */
unsigned io_provided_buffer_size(void) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    return (ut && ut->provided_ok) ? ut->provided_bufsz : 0u;
#else
    return 0u;
#endif
}

/** 当前线程 provided 池块数。 */
unsigned io_provided_buffer_count(void) {
#if defined(__linux__)
    uring_thread_t *ut = uring_get_thread();
    return (ut && ut->provided_ok) ? ut->provided_nr : 0u;
#else
    return 0u;
#endif
}

/**
 * 单次 provided recv：内核从池选 buffer，数据零拷贝落入 provided_base[bid]。
 * out_bid/out_len 可选；返回读入字节数，0=EOF，-1=错误。
 */
ptrdiff_t io_read_provided(int fd, unsigned timeout_ms, unsigned *out_bid, unsigned *out_len) {
#if defined(__linux__)
    uring_thread_t *ut;
    struct io_uring *ring;
    struct io_uring_sqe *sqe;
    struct io_uring_cqe *cqe = NULL;
    struct io_uring_cqe *cqe_ptrs[1];
    struct __kernel_timespec ts;
    int use_idx = -1;
    unsigned bid = 0, blen = 0;
    if (fd < 0)
        return -1;
    ut = uring_get_thread();
    if (!ut || !ut->ok || !ut->provided_ok)
        return -1;
    ring = &ut->ring;
    io_provide_drain_before_read(ut, 1u);
    if (ut->use_sqpoll)
        use_idx = uring_get_fd_slot(ut, fd);
    sqe = io_uring_get_sqe(ring);
    if (!sqe) {
        io_provide_drain_all_pending(ut);
        sqe = io_uring_get_sqe(ring);
        if (!sqe)
            return -1;
    }
    if (use_idx >= 0) {
        io_uring_prep_read(sqe, use_idx, NULL, ut->provided_bufsz, 0);
        sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
    } else {
        io_uring_prep_read(sqe, fd, NULL, ut->provided_bufsz, 0);
    }
    sqe->flags |= (unsigned)IOSQE_BUFFER_SELECT;
    sqe->buf_group = IO_PROVIDED_BGID;
    io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
    if (timeout_ms == 0) {
        if (io_uring_submit_and_wait(ring, 1) != 1)
            return -1;
        if (io_uring_peek_batch_cqe(ring, cqe_ptrs, 1) < 1)
            return -1;
        cqe = cqe_ptrs[0];
    } else {
        ts.tv_sec = (long long)(timeout_ms / 1000u);
        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
        if (io_uring_submit(ring) != 1)
            return -1;
        if (io_uring_wait_cqe_timeout(ring, &cqe, &ts) != 0 || !cqe)
            return -1;
    }
    if ((int)cqe->res < 0) {
        io_uring_cqe_seen(ring, cqe);
        return -1;
    }
    if (!io_provided_cqe_decode(cqe, &bid, &blen)) {
        io_uring_cqe_seen(ring, cqe);
        return -1;
    }
    io_uring_cqe_seen(ring, cqe);
    if (out_bid)
        *out_bid = bid;
    if (out_len)
        *out_len = blen;
    io_provide_resubmit_bids(ut, &bid, 1);
    return (ptrdiff_t)blen;
#else
    (void)fd;
    (void)timeout_ms;
    (void)out_bid;
    (void)out_len;
    return -1;
#endif
}

/**
 * 批量 provided read（1..4 段，对齐 echo batch）：一次 submit n 个 BUFFER_SELECT read。
 * out_bids/out_lens 各 n 元素；返回总字节数，-1=错误。数据在 io_provided_buffer_ptr(bid)。
 */
ptrdiff_t io_read_batch_provided(int fd, int n, unsigned timeout_ms, unsigned *out_bids, unsigned *out_lens) {
#if defined(__linux__)
    uring_thread_t *ut;
    struct io_uring *ring;
    struct io_uring_sqe *sqe;
    struct io_uring_cqe *cqe_ptrs[4];
    int i, submitted, reaped;
    int use_idx = -1;
    ptrdiff_t total = 0;
    if (fd < 0 || n <= 0 || n > 4 || !out_bids || !out_lens)
        return -1;
    /* echo ZC-1 bench 为 n=1×16KiB；走单次 provided 快路径，少一层 batch 循环。 */
    if (n == 1)
        return io_read_provided(fd, timeout_ms, out_bids, out_lens);
    ut = uring_get_thread();
    if (!ut || !ut->ok || !ut->provided_ok)
        return -1;
    ring = &ut->ring;
    io_provide_drain_before_read(ut, (unsigned)n);
    if (ut->use_sqpoll)
        use_idx = uring_get_fd_slot(ut, fd);
    for (i = 0; i < n; i++) {
        sqe = io_uring_get_sqe(ring);
        if (!sqe) {
            io_provide_drain_all_pending(ut);
            sqe = io_uring_get_sqe(ring);
            if (!sqe)
                return -1;
        }
        if (use_idx >= 0) {
            io_uring_prep_read(sqe, use_idx, NULL, ut->provided_bufsz, 0);
            sqe->flags |= (unsigned)IOSQE_FIXED_FILE;
        } else {
            io_uring_prep_read(sqe, fd, NULL, ut->provided_bufsz, 0);
        }
        sqe->flags |= (unsigned)IOSQE_BUFFER_SELECT;
        sqe->buf_group = IO_PROVIDED_BGID;
        io_uring_sqe_set_data(sqe, (void *)(uintptr_t)i);
    }
    submitted = (timeout_ms == 0) ? io_uring_submit_and_wait(ring, n) : io_uring_submit(ring);
    if (submitted < n)
        return -1;
    if (timeout_ms != 0) {
        struct __kernel_timespec ts;
        ts.tv_sec = (long long)(timeout_ms / 1000u);
        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
        for (i = 0; i < n; i++) {
            struct io_uring_cqe *cqe = NULL;
            if (io_uring_wait_cqe_timeout(ring, &cqe, &ts) != 0 || !cqe)
                return -1;
            cqe_ptrs[i] = cqe;
        }
        reaped = n;
    } else {
        reaped = io_uring_peek_batch_cqe(ring, cqe_ptrs, (unsigned)n);
        if (reaped < n)
            return -1;
    }
    for (i = 0; i < reaped; i++) {
        unsigned bid = 0, blen = 0;
        if ((int)cqe_ptrs[i]->res < 0) {
            int j;
            for (j = 0; j < reaped; j++)
                io_uring_cqe_seen(ring, cqe_ptrs[j]);
            return -1;
        }
        if (!io_provided_cqe_decode(cqe_ptrs[i], &bid, &blen)) {
            int j;
            for (j = 0; j < reaped; j++)
                io_uring_cqe_seen(ring, cqe_ptrs[j]);
            return -1;
        }
        out_bids[i] = bid;
        out_lens[i] = blen;
        total += (ptrdiff_t)blen;
        io_uring_cqe_seen(ring, cqe_ptrs[i]);
    }
    io_provide_resubmit_bids(ut, out_bids, reaped);
    return total;
#else
    (void)fd;
    (void)n;
    (void)timeout_ms;
    (void)out_bids;
    (void)out_lens;
    return -1;
#endif
}

/** 使用已注册固定 buffer 读：buf_index 为已注册池中的下标（0..nr-1）；offset+len 须 ≤ 该 buffer 的注册长度。返回读入字节数，0=EOF，-1=错误/超时。 */
ptrdiff_t io_read_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms) {
    uint8_t *addr = NULL;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->fixed_nr > 0 && buf_index < ut->fixed_nr) {
            size_t buf_len = ut->fixed_iov[buf_index].iov_len;
            if (offset <= buf_len && len <= buf_len - offset) {
                addr = (uint8_t *)ut->fixed_iov[buf_index].iov_base + offset;
                if (ut->fixed_ok) {
                    struct io_uring *ring = &ut->ring;
                    struct io_uring_sqe *sqe;
                    struct io_uring_cqe *cqe;
                    struct io_uring_cqe *cqe_ptrs[1];
                    struct __kernel_timespec ts;
                    if (timeout_ms > 0) {
                        ts.tv_sec = (long long)(timeout_ms / 1000u);
                        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
                    }
                    sqe = io_uring_get_sqe(ring);
                    if (sqe) {
                        io_uring_prep_read_fixed(sqe, fd, (void *)addr, (unsigned)len, (uint64_t)offset, (int)buf_index);
                        io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                        if (timeout_ms == 0) {
                            if (io_uring_submit_and_wait(ring, 1) == 1) {
                                unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                                if (got >= 1) {
                                    ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                                    io_uring_cqe_seen(ring, cqe_ptrs[0]);
                                    return res >= 0 ? res : -1;
                                }
                                return -1;
                            }
                        } else {
                            if (io_uring_submit(ring) == 1) {
                                int wait_ret = io_uring_wait_cqe_timeout(ring, &cqe, &ts);
                                if (wait_ret == 0 && cqe) {
                                    ptrdiff_t res = (ptrdiff_t)cqe->res;
                                    io_uring_cqe_seen(ring, cqe);
                                    return res >= 0 ? res : -1;
                                }
                                if (cqe) io_uring_cqe_seen(ring, cqe);
                                return -1;
                            }
                        }
                    }
                    return FALLBACK_READ(fd, addr, len);
                }
            }
        }
    }
#endif
#if defined(__APPLE__)
    {
        fixed_pool_t *p;
        (void)pthread_once(&g_fixed_key_once, fixed_key_init);
        p = (fixed_pool_t *)pthread_getspecific(g_fixed_key);
        if (p && buf_index < p->nr) {
            size_t buf_len = p->iov[buf_index].iov_len;
            if (offset <= buf_len && len <= buf_len - offset)
                addr = (uint8_t *)p->iov[buf_index].iov_base + offset;
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    {
        win_fixed_pool_t *p = win_get_fixed_pool();
        if (p && buf_index < p->nr) {
            size_t buf_len = p->len[buf_index];
            if (offset <= buf_len && len <= buf_len - offset)
                addr = (uint8_t *)p->base[buf_index] + offset;
        }
    }
#endif
    if (!addr) return -1;
#if defined(__APPLE__) || defined(_WIN32) || defined(_WIN64)
    return io_read(fd, addr, len, timeout_ms);
#endif
#if defined(__linux__)
    return FALLBACK_READ(fd, addr, len);
#endif
#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    return -1;
#endif
}

/** 使用已注册固定 buffer 写：buf_index 为已注册池中的下标（0..nr-1）；offset+len 须 ≤ 该 buffer 的注册长度。返回写入字节数，-1=错误/超时。 */
ptrdiff_t io_write_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms) {
    const uint8_t *addr = NULL;
#if defined(__linux__)
    {
        uring_thread_t *ut = uring_get_thread();
        if (ut && ut->fixed_nr > 0 && buf_index < ut->fixed_nr) {
            size_t buf_len = ut->fixed_iov[buf_index].iov_len;
            if (offset <= buf_len && len <= buf_len - offset) {
                addr = (const uint8_t *)ut->fixed_iov[buf_index].iov_base + offset;
                if (ut->fixed_ok) {
                    struct io_uring *ring = &ut->ring;
                    struct io_uring_sqe *sqe;
                    struct io_uring_cqe *cqe;
                    struct io_uring_cqe *cqe_ptrs[1];
                    struct __kernel_timespec ts;
                    if (timeout_ms > 0) {
                        ts.tv_sec = (long long)(timeout_ms / 1000u);
                        ts.tv_nsec = (long long)((timeout_ms % 1000u) * 1000000u);
                    }
                    sqe = io_uring_get_sqe(ring);
                    if (sqe) {
                        io_uring_prep_write_fixed(sqe, fd, (const void *)addr, (unsigned)len, (uint64_t)offset, (int)buf_index);
                        io_uring_sqe_set_data(sqe, (void *)(uintptr_t)fd);
                        if (timeout_ms == 0) {
                            if (io_uring_submit_and_wait(ring, 1) == 1) {
                                unsigned got = io_uring_peek_batch_cqe(ring, cqe_ptrs, 1);
                                if (got >= 1) {
                                    ptrdiff_t res = (ptrdiff_t)cqe_ptrs[0]->res;
                                    io_uring_cqe_seen(ring, cqe_ptrs[0]);
                                    return res >= 0 ? res : -1;
                                }
                                return -1;
                            }
                        } else {
                            if (io_uring_submit(ring) == 1) {
                                int wait_ret = io_uring_wait_cqe_timeout(ring, &cqe, &ts);
                                if (wait_ret == 0 && cqe) {
                                    ptrdiff_t res = (ptrdiff_t)cqe->res;
                                    io_uring_cqe_seen(ring, cqe);
                                    return res >= 0 ? res : -1;
                                }
                                if (cqe) io_uring_cqe_seen(ring, cqe);
                                return -1;
                            }
                        }
                    }
                    return FALLBACK_WRITE(fd, addr, len);
                }
            }
        }
    }
#endif
#if defined(__APPLE__)
    {
        fixed_pool_t *p;
        (void)pthread_once(&g_fixed_key_once, fixed_key_init);
        p = (fixed_pool_t *)pthread_getspecific(g_fixed_key);
        if (p && buf_index < p->nr) {
            size_t buf_len = p->iov[buf_index].iov_len;
            if (offset <= buf_len && len <= buf_len - offset)
                addr = (const uint8_t *)p->iov[buf_index].iov_base + offset;
        }
    }
#endif
#if defined(_WIN32) || defined(_WIN64)
    {
        win_fixed_pool_t *p = win_get_fixed_pool();
        if (p && buf_index < p->nr) {
            size_t buf_len = p->len[buf_index];
            if (offset <= buf_len && len <= buf_len - offset)
                addr = (const uint8_t *)p->base[buf_index] + offset;
        }
    }
#endif
    if (!addr) return -1;
#if defined(__APPLE__) || defined(_WIN32) || defined(_WIN64)
    return io_write(fd, addr, len, timeout_ms);
#endif
#if defined(__linux__)
    return FALLBACK_WRITE(fd, addr, len);
#endif
#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    return -1;
#endif
}

/** 阶段 2 超越（路线图 §4.3）：多 fd 就绪等待；一次系统调用等待 n 个 fd 中任意可读。返回第一个就绪的 fd 在下标 0..n-1，超时/错误返回 -1。n 建议 ≤8。 */
int io_wait_readable(const int *fds, int n, unsigned timeout_ms) {
    if (!fds || n <= 0 || n > 8) return -1;
#if defined(__APPLE__)
    {
        int kq = kq_get();
        if (kq >= 0) {
            struct kevent ev_in[8], ev_out;
            struct timespec ts, *pts = NULL;
            int i;
            if (timeout_ms > 0) {
                ts.tv_sec = (timeout_ms / 1000u);
                ts.tv_nsec = (long)((timeout_ms % 1000u) * 1000000u);
                pts = &ts;
            }
            for (i = 0; i < n; i++)
                EV_SET(&ev_in[i], (uintptr_t)fds[i], EVFILT_READ, EV_ADD | EV_ONESHOT | EV_CLEAR, 0, 0, 0);
            if (kevent(kq, ev_in, n, &ev_out, 1, pts) >= 1) {
                for (i = 0; i < n; i++)
                    if ((int)(intptr_t)ev_out.ident == fds[i]) return i;
                return 0;
            }
        }
    }
    return -1;
#endif
#if defined(__linux__)
    {
        struct pollfd pfd[8];
        int i, r;
        for (i = 0; i < n; i++) {
            pfd[i].fd = fds[i];
            pfd[i].events = POLLIN;
            pfd[i].revents = 0;
        }
        r = poll(pfd, (nfds_t)n, timeout_ms == 0 ? -1 : (int)timeout_ms);
        if (r <= 0) return -1;
        for (i = 0; i < n; i++)
            if (pfd[i].revents & (POLLIN | POLLHUP | POLLERR)) return i;
    }
    return -1;
#endif
#if defined(_WIN32) || defined(_WIN64)
    {
        static int g_wsa_ready = 0;
        WSADATA wsa;
        fd_set read_fds;
        struct timeval tv, *ptv = NULL;
        int i, r;
        if (!g_wsa_ready) {
            if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) return -1;
            g_wsa_ready = 1;
        }
        FD_ZERO(&read_fds);
        for (i = 0; i < n; i++)
            FD_SET((SOCKET)(intptr_t)fds[i], &read_fds);
        if (timeout_ms > 0) {
            tv.tv_sec = (long)(timeout_ms / 1000u);
            tv.tv_usec = (long)((timeout_ms % 1000u) * 1000u);
            ptv = &tv;
        }
        r = select(0, &read_fds, NULL, NULL, ptv);
        if (r <= 0) return -1;
        for (i = 0; i < n; i++)
            if (FD_ISSET((SOCKET)(intptr_t)fds[i], &read_fds)) return i;
    }
    return -1;
#endif
#if !defined(__linux__) && !defined(__APPLE__) && !defined(_WIN32) && !defined(_WIN64)
    {
        struct pollfd pfd[8];
        int i, r;
        for (i = 0; i < n; i++) {
            pfd[i].fd = fds[i];
            pfd[i].events = POLLIN;
            pfd[i].revents = 0;
        }
        r = poll(pfd, (nfds_t)n, timeout_ms == 0 ? -1 : (int)timeout_ms);
        if (r <= 0) return -1;
        for (i = 0; i < n; i++)
            if (pfd[i].revents & (POLLIN | POLLHUP | POLLERR)) return i;
    }
    return -1;
#endif
}

/* ——— 零拷贝读：TLS 缓冲或（ZC-2）常规文件 mmap 绝对视图；gen 校验跨 read_ptr 调用 ——— */
#define IO_READ_PTR_BUF_SIZE 65536
static uint8_t g_io_read_ptr_buf[IO_READ_PTR_BUF_SIZE];
static int32_t g_io_read_ptr_len;
/** ZC-2：每次 read_ptr 成功返回后递增；read_ptr_gen_valid(saved) 校验视图是否仍属最近一次读。 */
static uint64_t g_io_read_ptr_gen;

/** ZC-2：上次 read_ptr 后端：0=TLS buf，1=mmap(Linux)，2=dispatch_data(macOS)。 */
static int32_t g_io_read_ptr_backend;

#if defined(__APPLE__)
#include <dispatch/dispatch.h>
#include <sys/mman.h>
#include <sys/stat.h>

static dispatch_data_t g_io_read_ptr_ddata = NULL;
static uint8_t *g_io_read_ptr_ddata_ptr = NULL;

/** 释放 macOS dispatch_data 绝对视图（munmap 在 destructor 中）。 */
static void io_read_ptr_release_view(void) {
    g_io_read_ptr_ddata_ptr = NULL;
    if (g_io_read_ptr_ddata) {
        dispatch_release(g_io_read_ptr_ddata);
        g_io_read_ptr_ddata = NULL;
    }
}

/**
 * ZC-2 macOS：mmap 内核页 + dispatch_data 引用计数包装（绝对视图，无 TLS 拷贝）。
 * 成功写 *out_len 并返回 1。
 */
static int io_read_ptr_try_dispatch_data_file(int fd, int32_t *out_len) {
    struct stat st;
    off_t off, remain;
    size_t n;
    void *p;
    dispatch_data_t ddata;
    if (fd <= 0 || !out_len)
        return 0;
    if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode))
        return 0;
    off = lseek(fd, 0, SEEK_CUR);
    if (off < 0)
        return 0;
    remain = (off_t)st.st_size - off;
    if (remain <= 0)
        return 0;
    n = (size_t)remain;
    if (n > (size_t)IO_READ_PTR_BUF_SIZE)
        n = (size_t)IO_READ_PTR_BUF_SIZE;
    p = mmap(NULL, n, PROT_READ, MAP_PRIVATE, fd, off);
    if (p == MAP_FAILED)
        return 0;
    /* destructor 非空时不拷贝 buffer，释放 ddata 时 munmap。 */
    ddata = dispatch_data_create(
        p, n, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0),
        ^{
            munmap(p, n);
        });
    if (!ddata) {
        munmap(p, n);
        return 0;
    }
    io_read_ptr_release_view();
    g_io_read_ptr_ddata = ddata;
    g_io_read_ptr_ddata_ptr = (uint8_t *)p;
    (void)lseek(fd, off + (off_t)n, SEEK_SET);
    *out_len = (int32_t)n;
    g_io_read_ptr_backend = 2;
    return 1;
}

#elif defined(__linux__)
#include <sys/mman.h>
#include <sys/stat.h>

static void *g_io_read_ptr_mmap = NULL;
static size_t g_io_read_ptr_mmap_len = 0;

/** 释放 Linux mmap 绝对视图。 */
static void io_read_ptr_release_view(void) {
    if (g_io_read_ptr_mmap) {
        munmap(g_io_read_ptr_mmap, g_io_read_ptr_mmap_len);
        g_io_read_ptr_mmap = NULL;
        g_io_read_ptr_mmap_len = 0;
    }
}

/**
 * ZC-2 Linux：常规文件 fd mmap 只读页（绝对视图，无 TLS 拷贝）。
 * 成功写 *out_len 并返回 1。
 */
static int io_read_ptr_try_mmap_file(int fd, int32_t *out_len) {
    struct stat st;
    off_t off, remain;
    size_t n;
    void *p;
    if (fd <= 0 || !out_len)
        return 0;
    if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode))
        return 0;
    off = lseek(fd, 0, SEEK_CUR);
    if (off < 0)
        return 0;
    remain = (off_t)st.st_size - off;
    if (remain <= 0)
        return 0;
    n = (size_t)remain;
    if (n > (size_t)IO_READ_PTR_BUF_SIZE)
        n = (size_t)IO_READ_PTR_BUF_SIZE;
    p = mmap(NULL, n, PROT_READ, MAP_PRIVATE, fd, off);
    if (p == MAP_FAILED)
        return 0;
    io_read_ptr_release_view();
    g_io_read_ptr_mmap = p;
    g_io_read_ptr_mmap_len = n;
    (void)lseek(fd, off + (off_t)n, SEEK_SET);
    *out_len = (int32_t)n;
    g_io_read_ptr_backend = 1;
    return 1;
}

#else
static void io_read_ptr_release_view(void) { }
#endif

/** 零拷贝读：从 handle（0=stdin，≥2=fd）读入绝对视图或 TLS 缓冲；失败返回 NULL。 */
uint8_t *io_read_ptr(unsigned int handle, unsigned int timeout_ms) {
    int fd = (int)handle;
    /* 任意 read_ptr 调用均使先前 saved gen 失效（含 EOF/失败路径，ZC-2 gen smoke）。 */
    g_io_read_ptr_gen++;
#if defined(__APPLE__)
    io_read_ptr_release_view();
    if (io_read_ptr_try_dispatch_data_file(fd, &g_io_read_ptr_len)) {
        return g_io_read_ptr_ddata_ptr;
    }
#elif defined(__linux__)
    io_read_ptr_release_view();
    if (io_read_ptr_try_mmap_file(fd, &g_io_read_ptr_len)) {
        return (uint8_t *)g_io_read_ptr_mmap;
    }
#endif
    g_io_read_ptr_backend = 0;
    ptrdiff_t r = io_read(fd, g_io_read_ptr_buf, (size_t)IO_READ_PTR_BUF_SIZE, timeout_ms);
    if (r < 0) {
        g_io_read_ptr_len = 0;
        return NULL;
    }
    g_io_read_ptr_len = (int32_t)r;
    return g_io_read_ptr_buf;
}

/** 返回最近一次 io_read_ptr 成功读入的字节数（0 表示 EOF 或尚未调用/失败）。 */
int32_t io_read_ptr_len(void) {
    return g_io_read_ptr_len;
}

/** ZC-2：返回最近一次成功 read_ptr 的 generation；与 read_ptr_gen_valid 配套。 */
uint64_t io_read_ptr_gen(void) {
    return g_io_read_ptr_gen;
}

/** ZC-2：saved 与当前 gen 相等时返回 1（视图仍有效），否则 0。 */
int32_t io_read_ptr_gen_valid(uint64_t saved) {
    return saved == g_io_read_ptr_gen ? 1 : 0;
}

/** ZC-2：返回上次 read_ptr 后端（0=TLS，1=mmap Linux，2=dispatch_data macOS）。 */
int32_t io_read_ptr_backend(void) {
    return g_io_read_ptr_backend;
}

/** M-5：[]u8 slice 视图；与 pipeline/parser 侧 shulang_slice_uint8_t ABI 一致。 */
typedef struct {
    uint8_t *data;
    size_t length;
} shulang_slice_uint8_t;

/**
 * M-5：零拷贝读并返回 []u8 slice（data 指向 g_io_read_ptr_buf，length 为本次读入字节数）。
 * typeck 将 callee read_ptr_slice 绑定域 io_read_ptr；失败时 data=NULL、length=0。
 */
shulang_slice_uint8_t io_read_ptr_slice(unsigned int handle, unsigned int timeout_ms) {
    shulang_slice_uint8_t s;
    s.data = io_read_ptr(handle, timeout_ms);
    s.length = s.data ? (size_t)g_io_read_ptr_len : (size_t)0;
    return s;
}

/* duplicate symbol with asm backend：user .o 与 io.o 同时含同名 Shulang 符号时，
 * Darwin ld 报错；弱化 io.o 里这些可被 core.su/driver.su 机器码替代的入口，若有强符号则由其覆盖。 */
#if defined(__APPLE__) || defined(__ELF__)
#ifdef __GNUC__
#define SHU_IO_BACKEND_WEAK __attribute__((weak))
#else
#define SHU_IO_BACKEND_WEAK
#endif
#else
#define SHU_IO_BACKEND_WEAK
#endif
/** std.io.core / pipeline 所用符号：与内联 ABI 声明一致，供自举链接 io.o 时解析；pipeline 若未生成 core 的 register/submit 体则由 io.o 提供。 */
SHU_IO_BACKEND_WEAK int32_t shu_io_register(uint8_t *ptr, size_t len, size_t handle) {
    (void)handle;
    return (int32_t)io_register_buffer(ptr, len);
}
SHU_IO_BACKEND_WEAK int32_t shu_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms) {
    ptrdiff_t r = io_read((int)handle, ptr, len, timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}
SHU_IO_BACKEND_WEAK int32_t shu_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_ms) {
    ptrdiff_t r = io_write((int)handle, ptr, len, timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}
SHU_IO_BACKEND_WEAK uint8_t *shu_io_read_ptr(size_t handle, unsigned timeout_ms) {
    return io_read_ptr(handle, timeout_ms);
}
/** C 流水线（非 driver）时由 io.o 提供；driver 流水线若生成 core 则 codegen 跳过此符号以免重复。 */
SHU_IO_BACKEND_WEAK int32_t shu_io_read_ptr_len(void) {
    return io_read_ptr_len();
}
SHU_IO_BACKEND_WEAK uint64_t shu_io_read_ptr_gen(void) {
    return io_read_ptr_gen();
}
SHU_IO_BACKEND_WEAK int32_t shu_io_read_ptr_gen_valid(uint64_t saved) {
    return io_read_ptr_gen_valid(saved);
}
SHU_IO_BACKEND_WEAK int32_t shu_io_read_ptr_backend(void) {
    return io_read_ptr_backend();
}
SHU_IO_BACKEND_WEAK shulang_slice_uint8_t shu_io_read_ptr_slice(size_t handle, unsigned timeout_ms) {
    return io_read_ptr_slice((unsigned int)handle, timeout_ms);
}

/**
 * ASM 后端链 io.o（见 compiler asm_ld_append_std_objs）但不把 std.io core/driver 的 .su 再编成 .o 时，
 * CALL 仍会引用下面这些与 core.su / mod.su / driver.su 导出名一致的符号；在此用 C 实现对齐语义。
 */

/** std.io(mod)：fd 视作 usize handle，占位参数忽略。 */
size_t handle_from_fd(int32_t fd, int32_t unused) {
    (void)unused;
    /* 约定：stdin/stdout/stderr 与各 fd 为非负或与 core 一致的 (handle as i32) 语义。 */
    return (size_t)(unsigned)fd;
}

int32_t shu_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
    int fd = (int)handle;
    ptrdiff_t r = io_read_fixed(fd, buf_index, offset, len, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

int32_t shu_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms) {
    int fd = (int)handle;
    ptrdiff_t r = io_write_fixed(fd, buf_index, offset, len, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

int32_t shu_io_submit_read_batch(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3,
    size_t handle, int32_t n, uint32_t timeout_ms) {
    /* 与 core.su：仅 handle==0 或 handle>=2 走读路径。 */
    if (!(handle == (size_t)0 || handle >= (size_t)2))
        return -1;
    ptrdiff_t r = io_read_batch((int)handle, p0, l0, p1, l1, p2, l2, p3, l3, n, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

int32_t shu_io_submit_write_batch(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, size_t l3,
    size_t handle, int32_t n, uint32_t timeout_ms) {
    /* 与 core.su：handle>=1 可写（含 stdout）。 */
    if (handle < (size_t)1)
        return -1;
    ptrdiff_t r = io_write_batch((int)handle, (const uint8_t *)p0, l0, (const uint8_t *)p1, l1,
        (const uint8_t *)p2, l2, (const uint8_t *)p3, l3, n, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

/** driver.su：切片式批量读（Buffer 数组同 shu_batch_buf_t）。 */
int32_t submit_read_batch_buf(size_t handle, shu_batch_buf_t *bufs, int32_t n, uint32_t timeout_ms) {
    ptrdiff_t r = io_read_batch_buf((int)handle, (const shu_batch_buf_t *)bufs, (int)n, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

int32_t submit_write_batch_buf(size_t handle, shu_batch_buf_t *bufs, int32_t n, uint32_t timeout_ms) {
    ptrdiff_t r = io_write_batch_buf((int)handle, (const shu_batch_buf_t *)bufs, (int)n, (unsigned)timeout_ms);
    return (r < 0) ? -1 : (int32_t)r;
}

/** driver.su：`io_register_buffers_buf` 在历史上用 intptr 传指针，此处对齐该 ABI。 */
int32_t submit_register_fixed_buffers_buf(shu_batch_buf_t *bufs, uint32_t nr) {
    int ok = io_register_buffers_buf((int32_t)(uintptr_t)bufs, (int)nr);
    return ok ? (int32_t)ok : (int32_t)0;
}

/** std.io.core：provided buffer 池注册（ZC-1）。 */
int32_t shu_io_register_provided_buffers(uint32_t nr, uint32_t bufsz) {
    return (int32_t)io_register_provided_buffers((unsigned)nr, (unsigned)bufsz);
}

void shu_io_unregister_provided_buffers(void) {
    io_unregister_provided_buffers();
}

uint8_t *shu_io_provided_buffer_ptr(uint32_t bid) {
    return io_provided_buffer_ptr((unsigned)bid);
}

uint32_t shu_io_provided_buffer_size(void) {
    return (uint32_t)io_provided_buffer_size();
}

/** 批量 provided recv；out_bids/out_lens 各 n 元素。 */
int32_t shu_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t *out_bids, uint32_t *out_lens) {
    ptrdiff_t r;
    if (!(handle == (size_t)0 || handle >= (size_t)2))
        return -1;
    r = io_read_batch_provided((int)handle, (int)n, (unsigned)timeout_ms, (unsigned *)out_bids, (unsigned *)out_lens);
    return (r < 0) ? -1 : (int32_t)r;
}

int32_t shu_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t *out_bid, uint32_t *out_len) {
    ptrdiff_t r;
    if (!(handle == (size_t)0 || handle >= (size_t)2))
        return -1;
    r = io_read_provided((int)handle, (unsigned)timeout_ms, (unsigned *)out_bid, (unsigned *)out_len);
    return (r < 0) ? -1 : (int32_t)r;
}

#ifdef __cplusplus
}
#endif
