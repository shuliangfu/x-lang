/**
 * std/async/scheduler.c — A1/A2 单线程协作调度与 ping-pong 压测内核
 *
 * 职责：
 *   1) 无 malloc 的协作任务帧（state + ops）；
 *   2) computed-goto 跳转表 dispatch（A2 预览）；
 *   3) 1M ping-pong 压测入口，供 B-ASYNC / run-perf-async.sh 门禁；
 *   4) A3 CPS suspend/resume 钩子（shu_async_cps_suspend / shu_async_run_i32）；
 *   5) A4 就绪队列（MPSC ring v1；per-worker 环 + 多 consumer drain）；
 *   6) IO-A5 v0–v3：IO 等待队列 + io_uring completion poll/wake hook；
 *   7) run v4：`shu_async_run_seed_*` 实参队列（i32/u32/i64/usize，最多 8 个）；
 *   8) IO-A5 v5：`shu_async_spawn_i32` + `shu_async_run_drain_until_idle` 并行 spawn 语义。
 *
 * 链接：-o exe ... std/async/scheduler.o（按需）；MPSC 烟测需 -pthread。
 * 环境：SHU_ASYNC_YIELD=1 await 边界 yield；SHU_ASYNC_IO_WAIT=1 suspend 进 IO 等待队列；
 *       SHU_ASYNC_WORKERS=N 启用 N 个 per-worker 就绪环（1..8，默认 1）；
 *       SHU_ASYNC_AFFINITY=1 且链 std.thread 时 worker_drain 绑核 worker_id。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdatomic.h>

#if defined(__GNUC__) || defined(__clang__)
/**
 * 可选绑核：未链 std/thread 时用 weak 桩；链 thread.o 时强符号覆盖。
 */
__attribute__((weak)) int32_t thread_set_affinity_self_c(int32_t cpu_index) {
    (void)cpu_index;
    return -1;
}
/** IO-A5 v3：未链 io.o 时 poll 桩（run_i32 回退 wake_all）。 */
__attribute__((weak)) unsigned shu_io_poll_async_completions(unsigned timeout_ms) {
    (void)timeout_ms;
    return 0;
}
#endif

/** 就绪队列容量（2 的幂便于取模；保留 1 空槽区分满/空）。 */
#define SHU_ASYNC_TASK_Q_CAP 64

/** per-worker 就绪环数量上限（A4 v2）。 */
#define SHU_ASYNC_MAX_WORKERS 8

/** IO 等待队列容量（v0 单 worker；completion 唤醒后 re-queue 就绪环）。 */
#define SHU_ASYNC_IO_WAIT_CAP 64

/** async 任务入口：返回 SHU_ASYNC_SUSPENDED 表示 yield，其它值为完成结果。 */
typedef int32_t (*shu_async_task_fn_t)(void);

/**
 * A4：MPSC 就绪 ring（head/tail atomic + align(64)；每 worker 单 consumer drain）。
 */
typedef struct {
    atomic_uint_fast32_t head __attribute__((aligned(64)));
    atomic_uint_fast32_t tail __attribute__((aligned(64)));
    shu_async_task_fn_t slots[SHU_ASYNC_TASK_Q_CAP] __attribute__((aligned(64)));
} shu_async_task_queue_t;

/** per-worker 就绪环（SHU_ASYNC_WORKERS>1 时多 consumer 各 drain 一环）。 */
static shu_async_task_queue_t shu_async_worker_q[SHU_ASYNC_MAX_WORKERS];

/** 默认 submit 轮询选 worker；suspend re-queue 用 TLS 当前 worker。 */
static atomic_uint_fast32_t shu_async_submit_rr;
static uint32_t shu_async_n_workers = 1;
static int shu_async_workers_inited;

/** drain 路径标记当前 worker，suspend 任务 re-queue 回同一环。 */
static _Thread_local uint32_t shu_async_tls_worker;

/** 解析 SHU_ASYNC_WORKERS（1..SHU_ASYNC_MAX_WORKERS，默认 1）。 */
static void shu_async_init_workers(void) {
    const char *e;
    long v;
    if (shu_async_workers_inited)
        return;
    shu_async_workers_inited = 1;
    shu_async_n_workers = 1;
    e = getenv("SHU_ASYNC_WORKERS");
    if (!e || !e[0])
        return;
    v = strtol(e, NULL, 10);
    if (v >= 1 && v <= SHU_ASYNC_MAX_WORKERS)
        shu_async_n_workers = (uint32_t)v;
}

/** 返回配置的 worker 数（lazy init）。 */
uint32_t shu_async_worker_count(void) {
    shu_async_init_workers();
    return shu_async_n_workers;
}

/** A4：就绪环入队（前向声明，供 IO-A5 wake 路径调用）。 */
int shu_async_task_submit(shu_async_task_fn_t fn);
int shu_async_task_submit_to(uint32_t worker_id, shu_async_task_fn_t fn);

/** IO 等待队列（SHU_ASYNC_IO_WAIT=1 时 suspend 任务暂存于此）。 */
static shu_async_task_fn_t shu_async_io_wait[SHU_ASYNC_IO_WAIT_CAP];
static uint32_t shu_async_io_wait_n;

/** SHU_ASYNC_IO_WAIT=1 时 suspend 任务进入 IO 等待队列而非就绪环。 */
static int shu_async_io_wait_enabled(void) {
    const char *e = getenv("SHU_ASYNC_IO_WAIT");
    return e && e[0] == '1' && e[1] == '\0';
}

/** IO-A5：最近一次 suspend 来自 await IO（由 shu_async_cps_suspend_io 置位，drain 消费）。 */
static int shu_async_suspend_io_flag;

/** run v4：实参 seed 队列（i32/u32/i64/usize；内部 int64 存储）。 */
#define SHU_ASYNC_RUN_SEED_MAX 8
static int shu_async_run_seed_on;
static int shu_async_run_seed_n;
static int shu_async_run_seed_take_i;
static int64_t shu_async_run_seed_vals[SHU_ASYNC_RUN_SEED_MAX];

/** 清空 run seed 队列（run 表达式 emit 在 push 前调用）。 */
void shu_async_run_seed_reset(void) {
    shu_async_run_seed_on = 0;
    shu_async_run_seed_n = 0;
    shu_async_run_seed_take_i = 0;
}

/** 追加 int64 seed（内部）。 */
static void shu_async_run_seed_push_i64_impl(int64_t v) {
    if (shu_async_run_seed_n >= SHU_ASYNC_RUN_SEED_MAX)
        return;
    shu_async_run_seed_vals[shu_async_run_seed_n++] = v;
    shu_async_run_seed_on = 1;
}

/** 追加 i32 实参到 seed 队列。 */
void shu_async_run_seed_push_i32(int32_t v) {
    shu_async_run_seed_push_i64_impl((int64_t)v);
}

/** 追加 u32 实参到 seed 队列。 */
void shu_async_run_seed_push_u32(uint32_t v) {
    shu_async_run_seed_push_i64_impl((int64_t)(uint64_t)v);
}

/** 追加 i64 实参到 seed 队列。 */
void shu_async_run_seed_push_i64(int64_t v) {
    shu_async_run_seed_push_i64_impl(v);
}

/** 追加 usize 实参到 seed 队列（IO handle / fd 等；内部按 uint64 存储）。 */
void shu_async_run_seed_push_usize(size_t v) {
    shu_async_run_seed_push_i64_impl((int64_t)(uint64_t)v);
}

/**
 * IO-A5 v5：push 单 i32 seed 并 submit 协程体（spawn 语义；不 reset 队列/seed 队列外状态）。
 * 返回 shu_async_task_submit 结果：0 成功，-1 失败。
 */
int shu_async_spawn_i32(int32_t (*fn)(void), int32_t seed) {
    if (!fn)
        return -1;
    shu_async_run_seed_push_i32(seed);
    return shu_async_task_submit(fn);
}

/** 取出并清除 IO await suspend 标记；drain 见 SUSPENDED 时用于选 IO 等待队列。 */
static int shu_async_take_suspend_io_flag(void) {
    int v = shu_async_suspend_io_flag;
    shu_async_suspend_io_flag = 0;
    return v;
}

/** 将任务放入 IO 等待队列；返回 0 成功。 */
static int shu_async_io_wait_push(shu_async_task_fn_t fn) {
    if (!fn || shu_async_io_wait_n >= SHU_ASYNC_IO_WAIT_CAP)
        return -1;
    shu_async_io_wait[shu_async_io_wait_n++] = fn;
    return 0;
}

/** 队列占用（tail - head；计数器可绕回 uint32）。 */
static uint32_t shu_async_q_occupancy(uint32_t head, uint32_t tail) {
    return tail - head;
}

/** 协作任务帧：phase 为状态机下标，ops 为步进计数。 */
typedef struct {
    int32_t phase;
    int64_t ops;
} shu_coop_frame_t;

/**
 * 单任务一步（computed goto 跳转表）：phase 0↔1 交替并 ops++。
 * 返回 0=可继续，1=结束（本 bench 永不返回 1）。
 */
static int shu_coop_frame_step_jmp(shu_coop_frame_t *f) {
    if (!f)
        return 1;
#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
    static const void *const dispatch[3] = { &&coop_s0, &&coop_s1, &&coop_done };
    if (f->phase < 0 || f->phase > 1)
        f->phase = 0;
    goto *dispatch[f->phase];
coop_s0:
    f->ops++;
    f->phase = 1;
    return 0;
coop_s1:
    f->ops++;
    f->phase = 0;
    return 0;
coop_done:
    return 1;
#else
    switch (f->phase) {
    case 0:
        f->ops++;
        f->phase = 1;
        return 0;
    case 1:
        f->ops++;
        f->phase = 0;
        return 0;
    default:
        f->phase = 0;
        f->ops++;
        return 0;
    }
#endif
}

/**
 * A1/A2：双任务 computed-goto ping-pong，共 rounds 轮（每轮 ping+pong 各一步）。
 * 返回总 ops（应为 2*rounds）。
 */
int64_t shu_async_coop_pingpong_jmp(int64_t rounds) {
    shu_coop_frame_t ping = {0, 0};
    shu_coop_frame_t pong = {0, 0};
    int64_t i;
    if (rounds <= 0)
        return 0;
    for (i = 0; i < rounds; i++) {
        (void)shu_coop_frame_step_jmp(&ping);
        (void)shu_coop_frame_step_jmp(&pong);
    }
    return ping.ops + pong.ops;
}

/** A1：switch 版单帧步进（对照 jmp 路径开销）。 */
static int shu_coop_frame_step_switch(shu_coop_frame_t *f) {
    if (!f)
        return 1;
    switch (f->phase) {
    case 0:
        f->ops++;
        f->phase = 1;
        return 0;
    case 1:
        f->ops++;
        f->phase = 0;
        return 0;
    default:
        f->phase = 0;
        f->ops++;
        return 0;
    }
}

/**
 * A1：双任务 switch dispatch ping-pong（与 jmp 版同语义，便于 A/B）。
 */
int64_t shu_async_coop_pingpong(int64_t rounds) {
    shu_coop_frame_t ping = {0, 0};
    shu_coop_frame_t pong = {0, 0};
    int64_t i;
    if (rounds <= 0)
        return 0;
    for (i = 0; i < rounds; i++) {
        (void)shu_coop_frame_step_switch(&ping);
        (void)shu_coop_frame_step_switch(&pong);
    }
    return ping.ops + pong.ops;
}

/** async 函数 suspend 哨兵返回值（与正常 i32 结果区分）。 */
#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)

/**
 * A3：CPS await 边界 suspend；SHU_ASYNC_YIELD=1 时 yield，否则 sync fallthrough。
 * 参数 phase 指向协程帧 __phase；next_phase 为下一段 phase 值。
 * 返回值：1 须 return SHU_ASYNC_SUSPENDED；0 同栈 fallthrough。
 */
int shu_async_cps_suspend(int32_t *phase, int32_t next_phase) {
    const char *yield_env;
    if (phase)
        *phase = next_phase;
    yield_env = getenv("SHU_ASYNC_YIELD");
    if (yield_env && yield_env[0] == '1' && yield_env[1] == '\0')
        return 1;
    return 0;
}

/**
 * IO-A5：await IO 边界 suspend；yield 时 drain 将任务放入 IO 等待队列（无需 SHU_ASYNC_IO_WAIT）。
 * v0：IO 调用仍为同步 blocking emit，非阻塞 submit 待后续。
 */
int shu_async_cps_suspend_io(int32_t *phase, int32_t next_phase) {
    const char *yield_env;
    if (phase)
        *phase = next_phase;
    shu_async_suspend_io_flag = 1;
    yield_env = getenv("SHU_ASYNC_YIELD");
    if (yield_env && yield_env[0] == '1' && yield_env[1] == '\0')
        return 1;
    shu_async_suspend_io_flag = 0;
    return 0;
}

/**
 * A4：清空就绪队列与 IO 等待队列；clear_seed=0 时保留 run seed（run_i32 路径）。
 */
static void shu_async_queue_reset_impl(int clear_seed) {
    uint32_t n = shu_async_worker_count();
    for (uint32_t w = 0; w < n; w++) {
        atomic_store_explicit(&shu_async_worker_q[w].head, 0, memory_order_release);
        atomic_store_explicit(&shu_async_worker_q[w].tail, 0, memory_order_release);
    }
    shu_async_io_wait_n = 0;
    if (clear_seed)
        shu_async_run_seed_reset();
}

/**
 * A4：清空就绪队列（drain 完成后可选调用，便于同进程二次 run）。
 */
void shu_async_queue_reset(void) {
    shu_async_queue_reset_impl(1);
}

/** 设置 run 单实参 seed（v1 兼容：等价 reset + push）。 */
void shu_async_run_seed_set_i32(int32_t v) {
    shu_async_run_seed_reset();
    shu_async_run_seed_push_i32(v);
}

/** phase==0 首次进入 async 时是否还有待注入的 seed。 */
int shu_async_run_seed_valid(void) {
    return shu_async_run_seed_on && shu_async_run_seed_take_i < shu_async_run_seed_n;
}

/** 按 FIFO 取出一个 i64 seed。 */
int64_t shu_async_run_seed_take_i64(void) {
    if (shu_async_run_seed_take_i >= shu_async_run_seed_n)
        return 0;
    int64_t v = shu_async_run_seed_vals[shu_async_run_seed_take_i++];
    if (shu_async_run_seed_take_i >= shu_async_run_seed_n)
        shu_async_run_seed_on = 0;
    return v;
}

/** 按 FIFO 取出一个 i32 seed。 */
int32_t shu_async_run_seed_take_i32(void) {
    return (int32_t)shu_async_run_seed_take_i64();
}

/** 按 FIFO 取出一个 u32 seed。 */
uint32_t shu_async_run_seed_take_u32(void) {
    return (uint32_t)shu_async_run_seed_take_i64();
}

/** 按 FIFO 取出一个 usize seed（IO handle / fd 等）。 */
size_t shu_async_run_seed_take_usize(void) {
    return (size_t)(uint64_t)shu_async_run_seed_take_i64();
}

/**
 * A4：返回就绪队列中待执行任务数（烟测/观测用）。
 */
uint32_t shu_async_scheduler_pending(void) {
    uint32_t n = shu_async_worker_count();
    uint32_t sum = 0;
    for (uint32_t w = 0; w < n; w++) {
        uint32_t h = atomic_load_explicit(&shu_async_worker_q[w].head, memory_order_acquire);
        uint32_t t = atomic_load_explicit(&shu_async_worker_q[w].tail, memory_order_acquire);
        sum += shu_async_q_occupancy(h, t);
    }
    return sum;
}

/** A4 v2：指定 worker 就绪环待执行任务数。 */
uint32_t shu_async_worker_pending(uint32_t worker_id) {
    uint32_t h;
    uint32_t t;
    if (worker_id >= shu_async_worker_count())
        return 0;
    h = atomic_load_explicit(&shu_async_worker_q[worker_id].head, memory_order_acquire);
    t = atomic_load_explicit(&shu_async_worker_q[worker_id].tail, memory_order_acquire);
    return shu_async_q_occupancy(h, t);
}

/** IO-A5：IO 等待队列中任务数（烟测/观测用）。 */
uint32_t shu_async_io_waiters_pending(void) {
    return shu_async_io_wait_n;
}

/**
 * IO-A5：将最多 n 个 IO 等待任务移入就绪环（n=0 表示全部）。
 * 由 io_uring completion hook 或测试 harness 调用。
 */
void shu_async_io_wake(unsigned n) {
    unsigned moved = 0;
    unsigned limit = n;
    if (limit == 0)
        limit = (unsigned)shu_async_io_wait_n;
    while (shu_async_io_wait_n > 0 && moved < limit) {
        shu_async_task_fn_t fn = shu_async_io_wait[--shu_async_io_wait_n];
        if (shu_async_task_submit(fn) != 0) {
            shu_async_io_wait[shu_async_io_wait_n++] = fn;
            break;
        }
        moved++;
    }
}

/** IO-A5：唤醒全部 IO 等待任务。 */
void shu_async_io_wake_all(void) {
    shu_async_io_wake(0);
}

/**
 * IO-A5：io_uring 完成回调（强符号；io.c 弱 stub，链 scheduler.o 时覆盖）。
 * 每个 completion 唤醒一个 IO 等待任务。
 */
void shu_async_io_completions_ready(unsigned n) {
    if (n == 0)
        return;
    shu_async_io_wake(n);
}

/**
 * A4：将任务提交到指定 worker 就绪环；fn 帧须 static 持久化。
 * 返回 0 成功，-1 队列满、worker_id 无效或 fn 为空。
 */
int shu_async_task_submit_to(uint32_t worker_id, shu_async_task_fn_t fn) {
    shu_async_task_queue_t *q;
    uint32_t t;
    uint32_t h;
    if (!fn || worker_id >= shu_async_worker_count())
        return -1;
    q = &shu_async_worker_q[worker_id];
    t = (uint32_t)atomic_fetch_add_explicit(&q->tail, 1, memory_order_acq_rel);
    h = (uint32_t)atomic_load_explicit(&q->head, memory_order_acquire);
    if (t - h >= SHU_ASYNC_TASK_Q_CAP - 1) {
        atomic_fetch_sub_explicit(&q->tail, 1, memory_order_acq_rel);
        return -1;
    }
    q->slots[t % SHU_ASYNC_TASK_Q_CAP] = fn;
    return 0;
}

/**
 * A4：将就绪 async 任务入队（MPSC round-robin 选 worker）。
 * 返回 0 成功，-1 队列满或 fn 为空。
 */
int shu_async_task_submit(shu_async_task_fn_t fn) {
    uint32_t n = shu_async_worker_count();
    uint32_t w = (uint32_t)atomic_fetch_add_explicit(&shu_async_submit_rr, 1, memory_order_relaxed) % n;
    return shu_async_task_submit_to(w, fn);
}

/** SHU_ASYNC_AFFINITY=1 时 worker drain 尝试绑核。 */
static int shu_async_affinity_enabled(void) {
    const char *e = getenv("SHU_ASYNC_AFFINITY");
    return e && e[0] == '1' && e[1] == '\0';
}

/** worker drain 前绑核（SHU_ASYNC_AFFINITY=1 时调用 thread_set_affinity_self_c）。 */
static void shu_async_maybe_bind_worker(uint32_t worker_id) {
#if defined(__GNUC__) || defined(__clang__)
    if (!shu_async_affinity_enabled())
        return;
    (void)thread_set_affinity_self_c((int32_t)worker_id);
#else
    (void)worker_id;
#endif
}

/** 单 worker 就绪环 drain；suspend 任务 re-queue 到 tls worker；acc 非空时累加已完成任务返回值。 */
static int32_t shu_async_drain_queue(shu_async_task_queue_t *q, uint32_t worker_id, int32_t *acc) {
    int32_t last = 0;
    shu_async_maybe_bind_worker(worker_id);
    shu_async_tls_worker = worker_id;
    for (;;) {
        uint32_t h = (uint32_t)atomic_load_explicit(&q->head, memory_order_acquire);
        uint32_t t = (uint32_t)atomic_load_explicit(&q->tail, memory_order_acquire);
        shu_async_task_fn_t fn;
        int32_t r;
        if (h == t)
            break;
        fn = q->slots[h % SHU_ASYNC_TASK_Q_CAP];
        atomic_store_explicit(&q->head, h + 1, memory_order_release);
        if (!fn)
            continue;
        r = fn();
        if (r == SHU_ASYNC_SUSPENDED) {
            if (shu_async_io_wait_enabled() || shu_async_take_suspend_io_flag()) {
                if (shu_async_io_wait_push(fn) != 0)
                    return SHU_ASYNC_SUSPENDED;
            } else if (shu_async_task_submit_to(shu_async_tls_worker, fn) != 0) {
                return SHU_ASYNC_SUSPENDED;
            }
            continue;
        }
        last = r;
        if (acc && r != 0)
            *acc += r;
    }
    return last;
}

/**
 * A4 v2：单 consumer  drain 指定 worker 就绪环直至为空。
 */
int32_t shu_async_worker_drain(uint32_t worker_id) {
    if (worker_id >= shu_async_worker_count())
        return 0;
    return shu_async_drain_queue(&shu_async_worker_q[worker_id], worker_id, NULL);
}

/**
 * A4：轮询全部 worker 就绪环直至为空（兼容 v1 单线程 drain）。
 */
int32_t shu_async_scheduler_drain(void) {
    int32_t last = 0;
    uint32_t n = shu_async_worker_count();
    for (uint32_t w = 0; w < n; w++) {
        int32_t r = shu_async_drain_queue(&shu_async_worker_q[w], w, NULL);
        if (r != 0)
            last = r;
    }
    return last;
}

/**
 * A3/A4/IO-A5 v4：poll + drain 直至就绪环空且无 IO 等待者；返回已完成任务返回值之和。
 */
int32_t shu_async_run_drain_until_idle(void) {
    int32_t sum = 0;
    unsigned stall = 0;
    for (;;) {
        int32_t batch = 0;
        uint32_t n = shu_async_worker_count();
        uint32_t w;
        for (w = 0; w < n; w++)
            (void)shu_async_drain_queue(&shu_async_worker_q[w], w, &batch);
        sum += batch;
        if (shu_async_scheduler_pending() == 0 && shu_async_io_waiters_pending() == 0)
            return sum;
        if (shu_io_poll_async_completions(50) > 0) {
            /* poll 窥视未消费 CQE 时可能反复 >0 却无任务进展，需有界退出。 */
            if (batch != 0)
                stall = 0;
            else
                stall++;
            continue;
        }
        /*
         * Linux io_uring：无 CQE 时勿 wake IO 等待者，否则 resume 后 complete 得 NOT_READY
         * 会被当作任务结束（累加 -2），spawn 并行 drain 出现 total=1/-2。
         * macOS 同步 complete 路径仍依赖 wake_all 推进。
         */
#if !defined(__linux__)
        shu_async_io_wake_all();
#else
        if (shu_async_io_waiters_pending() == 0)
            shu_async_io_wake_all();
#endif
        stall++;
        /* 有界退出：poll=0 且仅 wake_all 时最多 64 轮（避免 CI 8min 挂死）。 */
        if (stall >= 64u)
            return sum;
    }
}

/**
 * A3/A4：submit + drain 驱动单帧 async 函数直至完成（帧须 static 持久化）。
 * IO await 路径：poll io_uring CQE 唤醒 IO 等待队列；无 completion 时回退 wake_all（macOS 同步 complete）。
 */
int32_t shu_async_run_i32(int32_t (*fn)(void)) {
    if (!fn)
        return 0;
    shu_async_queue_reset_impl(0);
    if (shu_async_task_submit(fn) != 0)
        return 0;
    return shu_async_run_drain_until_idle();
}

/** asm CPS 帧槽数量（WPO-S3；按 fn_id 哈希，无 malloc）。 */
#define SHU_ASYNC_ASM_FRAME_SLOTS 8

/** 单槽：fn_id + phase + live data blob（phase 与 C __shu_frame.__phase 对齐）。 */
typedef struct {
    uint32_t fn_id;
    int32_t phase;
    uint8_t data[120];
} shu_async_asm_frame_slot_t;

static shu_async_asm_frame_slot_t shu_async_asm_frames[SHU_ASYNC_ASM_FRAME_SLOTS];

/** 按 fn_id 查找或分配帧槽。 */
static shu_async_asm_frame_slot_t *shu_async_asm_frame_slot(uint32_t fn_id) {
    int i;
    if (fn_id == 0)
        fn_id = 1u;
    for (i = 0; i < SHU_ASYNC_ASM_FRAME_SLOTS; i++) {
        if (shu_async_asm_frames[i].fn_id == fn_id)
            return &shu_async_asm_frames[i];
    }
    for (i = 0; i < SHU_ASYNC_ASM_FRAME_SLOTS; i++) {
        if (shu_async_asm_frames[i].fn_id == 0) {
            shu_async_asm_frames[i].fn_id = fn_id;
            shu_async_asm_frames[i].phase = 0;
            return &shu_async_asm_frames[i];
        }
    }
    return &shu_async_asm_frames[0];
}

/**
 * asm 后端：按 fn_id 取 phase 指针（&slot->phase）。
 * 供 emit 调 shu_async_cps_suspend(&phase, next)。
 */
int32_t *shu_async_asm_frame_phase_by_id(uint32_t fn_id) {
    return &shu_async_asm_frame_slot(fn_id)->phase;
}

/** asm 后端：live data 区起始（slot->data，与 phase 分离存储）。 */
uint8_t *shu_async_asm_frame_data_by_id(uint32_t fn_id) {
    return shu_async_asm_frame_slot(fn_id)->data;
}

/** async 正常 return 前 reset phase，便于同进程二次 poll。 */
void shu_async_asm_frame_reset_by_id(uint32_t fn_id) {
    shu_async_asm_frame_slot(fn_id)->phase = 0;
}

/** asm emit：frame data 区 ← 栈/memory（src 指向 live 变量）。 */
void shu_async_asm_frame_store_from_ptr(uint32_t fn_id, int32_t data_off, void *src, int32_t nbytes) {
    shu_async_asm_frame_slot_t *s;
    if (!src || nbytes <= 0 || data_off < 0)
        return;
    s = shu_async_asm_frame_slot(fn_id);
    if ((size_t)data_off + (size_t)nbytes > sizeof(s->data))
        return;
    memcpy(s->data + data_off, src, (size_t)nbytes);
}

/** asm emit：frame data 区 → 栈/memory（dst 指向 live 变量）。 */
void shu_async_asm_frame_load_to_ptr(uint32_t fn_id, int32_t data_off, void *dst, int32_t nbytes) {
    shu_async_asm_frame_slot_t *s;
    if (!dst || nbytes <= 0 || data_off < 0)
        return;
    s = shu_async_asm_frame_slot(fn_id);
    if ((size_t)data_off + (size_t)nbytes > sizeof(s->data))
        return;
    memcpy(dst, s->data + data_off, (size_t)nbytes);
}
