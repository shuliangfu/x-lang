/**
 * std/channel/channel.c — 有界/无界 channel（对标 Rust std::sync::mpsc、Zig 无标准 channel）
 *
 * 【文件职责】
 * 实现 std.channel 的 C 层：channel_i32_bounded、channel_i32_unbounded、send、recv、try_recv、close、free；
 * select 双路/N 路 recv/send/混合（STD-098/102/104/108）。
 * 有界：固定容量，send 满时阻塞；无界：缓冲区按需增长。使用 mutex + condition variable。
 *
 * 【所属模块/组件】
 * 标准库 std.channel；与 std/channel/mod.sx 同属一模块。依赖 std.heap（malloc/realloc/free）；
 * Unix 需 -lpthread；Windows 使用 CRITICAL_SECTION + CONDITION_VARIABLE（Vista+）。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define CHANNEL_SELECT_MAX 8
#define SELECT_DIR_RECV 0
#define SELECT_DIR_SEND 1
#define SELECT_ERR_PENDING 1
#define SELECT_ERR_ALL_CLOSED (-1)

#define CHAN_ERR_CLOSED (-1)
#define CHAN_ERR_FULL   1
#define CHAN_ERR_EMPTY  1
#define UNBOUNDED_INIT_CAP 16
#define SELECT_TIMEDWAIT_MS 5

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define CHAN_SYNC_WIN 1
#else
#include <pthread.h>
#include <time.h>
#define CHAN_SYNC_WIN 0
#endif

/** 将 channel 句柄写入 i64 槽（64 位 LE，与 void* 布局兼容）。 */
void channel_select_chs_set_c(int64_t *slots, int32_t idx, void *ch) {
    if (!slots || idx < 0 || idx >= CHANNEL_SELECT_MAX) return;
    memcpy(&slots[idx], &ch, sizeof(void *));
}

/** 写入 select 方向槽。 */
void channel_select_dirs_set_c(int32_t *dirs, int32_t idx, int32_t dir) {
    if (!dirs || idx < 0 || idx >= CHANNEL_SELECT_MAX) return;
    dirs[idx] = dir;
}

/** i32 channel 内部实现：环形缓冲 + 同步原语。 */
typedef struct {
#if CHAN_SYNC_WIN
    CRITICAL_SECTION mutex;
    CONDITION_VARIABLE cond_not_empty;
    CONDITION_VARIABLE cond_not_full;
#else
    pthread_mutex_t mutex;
    pthread_cond_t  cond_not_empty;
    pthread_cond_t  cond_not_full;
#endif
    int32_t        *buf;
    int32_t         cap;       /* 有界为固定容量；无界为当前缓冲区大小，满时翻倍 */
    int32_t         len;
    int32_t         head;      /* 环形：下一个取的位置 */
    int32_t         closed;    /* 1 已关闭 */
    int32_t         unbounded; /* 1 无界，可扩容 */
} channel_i32_impl_t;

/** 初始化 channel 同步原语；失败返回非 0。 */
static int32_t channel_sync_init(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    InitializeCriticalSection(&c->mutex);
    InitializeConditionVariable(&c->cond_not_empty);
    InitializeConditionVariable(&c->cond_not_full);
    return 0;
#else
    if (pthread_mutex_init(&c->mutex, NULL) != 0) return -1;
    if (pthread_cond_init(&c->cond_not_empty, NULL) != 0) {
        pthread_mutex_destroy(&c->mutex);
        return -1;
    }
    if (pthread_cond_init(&c->cond_not_full, NULL) != 0) {
        pthread_cond_destroy(&c->cond_not_empty);
        pthread_mutex_destroy(&c->mutex);
        return -1;
    }
    return 0;
#endif
}

/** 销毁 channel 同步原语。 */
static void channel_sync_destroy(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    DeleteCriticalSection(&c->mutex);
#else
    pthread_mutex_destroy(&c->mutex);
    pthread_cond_destroy(&c->cond_not_empty);
    pthread_cond_destroy(&c->cond_not_full);
#endif
}

/** 加锁 channel。 */
static void channel_lock(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    EnterCriticalSection(&c->mutex);
#else
    pthread_mutex_lock(&c->mutex);
#endif
}

/** 解锁 channel。 */
static void channel_unlock(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    LeaveCriticalSection(&c->mutex);
#else
    pthread_mutex_unlock(&c->mutex);
#endif
}

/** 唤醒一个等待 recv 的线程。 */
static void channel_signal_not_empty(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    WakeConditionVariable(&c->cond_not_empty);
#else
    pthread_cond_signal(&c->cond_not_empty);
#endif
}

/** 唤醒一个等待 send 的线程。 */
static void channel_signal_not_full(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    WakeConditionVariable(&c->cond_not_full);
#else
    pthread_cond_signal(&c->cond_not_full);
#endif
}

/** 广播唤醒所有等待 recv 的线程。 */
static void channel_broadcast_not_empty(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    WakeAllConditionVariable(&c->cond_not_empty);
#else
    pthread_cond_broadcast(&c->cond_not_empty);
#endif
}

/** 广播唤醒所有等待 send 的线程。 */
static void channel_broadcast_not_full(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    WakeAllConditionVariable(&c->cond_not_full);
#else
    pthread_cond_broadcast(&c->cond_not_full);
#endif
}

/** 阻塞等待直到 buffer 非空或 channel 关闭。 */
static void channel_wait_not_empty(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    SleepConditionVariableCS(&c->cond_not_empty, &c->mutex, INFINITE);
#else
    pthread_cond_wait(&c->cond_not_empty, &c->mutex);
#endif
}

/** 阻塞等待直到 buffer 有空间或 channel 关闭。 */
static void channel_wait_not_full(channel_i32_impl_t *c) {
#if CHAN_SYNC_WIN
    SleepConditionVariableCS(&c->cond_not_full, &c->mutex, INFINITE);
#else
    pthread_cond_wait(&c->cond_not_full, &c->mutex);
#endif
}

/** 限时等待 buffer 非空（select 轮询用）。 */
static void channel_timedwait_not_empty(channel_i32_impl_t *c, int32_t ms) {
#if CHAN_SYNC_WIN
    SleepConditionVariableCS(&c->cond_not_empty, &c->mutex, (DWORD)ms);
#else
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    ts.tv_nsec += (long)ms * 1000000L;
    if (ts.tv_nsec >= 1000000000L) {
        ts.tv_sec += ts.tv_nsec / 1000000000L;
        ts.tv_nsec %= 1000000000L;
    }
    pthread_cond_timedwait(&c->cond_not_empty, &c->mutex, &ts);
#endif
}

/** 限时等待 buffer 有空间（select 轮询用）。 */
static void channel_timedwait_not_full(channel_i32_impl_t *c, int32_t ms) {
#if CHAN_SYNC_WIN
    SleepConditionVariableCS(&c->cond_not_full, &c->mutex, (DWORD)ms);
#else
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    ts.tv_nsec += (long)ms * 1000000L;
    if (ts.tv_nsec >= 1000000000L) {
        ts.tv_sec += ts.tv_nsec / 1000000000L;
        ts.tv_nsec %= 1000000000L;
    }
    pthread_cond_timedwait(&c->cond_not_full, &c->mutex, &ts);
#endif
}

/** 无界 channel 缓冲满时翻倍扩容并整理为连续布局。 */
static int32_t channel_unbounded_grow(channel_i32_impl_t *c) {
    int32_t new_cap = c->cap * 2;
    int32_t *n;
    int32_t i, j;
    if (new_cap <= c->cap) return -1;
    n = (int32_t *)realloc(c->buf, (size_t)new_cap * sizeof(int32_t));
    if (!n) return -1;
    for (i = 0, j = c->head; i < c->len; i++, j = (j + 1) % c->cap)
        n[i] = n[j];
    c->buf = n;
    c->cap = new_cap;
    c->head = 0;
    return 0;
}

/** 有界 channel：容量 cap，send 满时阻塞。返回句柄或 NULL。 */
void *channel_i32_bounded_c(int32_t cap) {
    channel_i32_impl_t *ch;
    if (cap <= 0) return NULL;
    ch = (channel_i32_impl_t *)malloc(sizeof(channel_i32_impl_t));
    if (!ch) return NULL;
    ch->buf = (int32_t *)malloc((size_t)cap * sizeof(int32_t));
    if (!ch->buf) { free(ch); return NULL; }
    ch->cap = cap;
    ch->len = 0;
    ch->head = 0;
    ch->closed = 0;
    ch->unbounded = 0;
    if (channel_sync_init(ch) != 0) { free(ch->buf); free(ch); return NULL; }
    return (void *)ch;
}

/** 无界 channel：send 不因满而阻塞，内部按需扩容。 */
void *channel_i32_unbounded_c(void) {
    channel_i32_impl_t *ch = (channel_i32_impl_t *)malloc(sizeof(channel_i32_impl_t));
    if (!ch) return NULL;
    ch->buf = (int32_t *)malloc((size_t)UNBOUNDED_INIT_CAP * sizeof(int32_t));
    if (!ch->buf) { free(ch); return NULL; }
    ch->cap = UNBOUNDED_INIT_CAP;
    ch->len = 0;
    ch->head = 0;
    ch->closed = 0;
    ch->unbounded = 1;
    if (channel_sync_init(ch) != 0) { free(ch->buf); free(ch); return NULL; }
    return (void *)ch;
}

/** 发送 val；有界且满时阻塞直到有空间。返回 0 成功，-1 已关闭。 */
int32_t channel_i32_send_c(void *ch, int32_t val) {
    channel_i32_impl_t *c;
    if (!ch) return CHAN_ERR_CLOSED;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    if (c->closed) { channel_unlock(c); return CHAN_ERR_CLOSED; }
    if (c->unbounded) {
        while (c->len == c->cap) {
            if (channel_unbounded_grow(c) != 0) {
                channel_unlock(c);
                return CHAN_ERR_CLOSED;
            }
        }
    } else {
        while (c->len == c->cap) {
            if (c->closed) { channel_unlock(c); return CHAN_ERR_CLOSED; }
            channel_wait_not_full(c);
        }
    }
    c->buf[(c->head + c->len) % c->cap] = val;
    c->len++;
    channel_signal_not_empty(c);
    channel_unlock(c);
    return 0;
}

/** 接收：阻塞直到有值或已关闭。*out 写入值；返回 0 成功，-1 已关闭且无数据。 */
int32_t channel_i32_recv_c(void *ch, int32_t *out) {
    channel_i32_impl_t *c;
    if (!ch || !out) return CHAN_ERR_CLOSED;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    while (c->len == 0) {
        if (c->closed) { channel_unlock(c); return CHAN_ERR_CLOSED; }
        channel_wait_not_empty(c);
    }
    *out = c->buf[c->head];
    c->head = (c->head + 1) % c->cap;
    c->len--;
    channel_signal_not_full(c);
    channel_unlock(c);
    return 0;
}

/** 非阻塞发送。返回 0 成功，1 满（有界），-1 已关闭。 */
int32_t channel_i32_try_send_c(void *ch, int32_t val) {
    channel_i32_impl_t *c;
    if (!ch) return CHAN_ERR_CLOSED;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    if (c->closed) { channel_unlock(c); return CHAN_ERR_CLOSED; }
    if (c->unbounded) {
        if (c->len == c->cap && channel_unbounded_grow(c) != 0) {
            channel_unlock(c);
            return CHAN_ERR_CLOSED;
        }
    } else if (c->len == c->cap) {
        channel_unlock(c);
        return CHAN_ERR_FULL;
    }
    c->buf[(c->head + c->len) % c->cap] = val;
    c->len++;
    channel_signal_not_empty(c);
    channel_unlock(c);
    return 0;
}

/** 非阻塞接收。返回 0 成功 *out 有效，1 空，-1 已关闭。 */
int32_t channel_i32_try_recv_c(void *ch, int32_t *out) {
    channel_i32_impl_t *c;
    if (!ch || !out) return CHAN_ERR_CLOSED;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    if (c->closed && c->len == 0) { channel_unlock(c); return CHAN_ERR_CLOSED; }
    if (c->len == 0) { channel_unlock(c); return CHAN_ERR_EMPTY; }
    *out = c->buf[c->head];
    c->head = (c->head + 1) % c->cap;
    c->len--;
    channel_signal_not_full(c);
    channel_unlock(c);
    return 0;
}

/** 关闭 channel：唤醒所有阻塞 send/recv。 */
void channel_i32_close_c(void *ch) {
    channel_i32_impl_t *c;
    if (!ch) return;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    c->closed = 1;
    channel_broadcast_not_empty(c);
    channel_broadcast_not_full(c);
    channel_unlock(c);
}

/** 释放 channel 资源。 */
void channel_i32_free_c(void *ch) {
    channel_i32_impl_t *c;
    if (!ch) return;
    c = (channel_i32_impl_t *)ch;
    channel_sync_destroy(c);
    free(c->buf);
    free(c);
}

/** 查询 channel 是否已关闭；无效句柄视为已关闭返回 1。 */
int32_t channel_i32_is_closed_c(void *ch) {
    channel_i32_impl_t *c;
    int32_t closed;
    if (!ch) {
        return 1;
    }
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    closed = c->closed ? 1 : 0;
    channel_unlock(c);
    return closed;
}

/** 从 i64 槽读取 channel 句柄。 */
static void *channel_select_chs_get(int64_t *slots, int32_t idx) {
    void *p = NULL;
    if (slots) memcpy(&p, &slots[idx], sizeof(void *));
    return p;
}

/** recv case 仍有可能：未关闭或缓冲仍有数据。 */
static int32_t channel_select_recv_case_live(void *ch) {
    channel_i32_impl_t *c;
    int32_t live;
    if (!ch) return 0;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    live = !(c->closed && c->len == 0);
    channel_unlock(c);
    return live;
}

/** send case 仍有可能：channel 未关闭。 */
static int32_t channel_select_send_case_live(void *ch) {
    channel_i32_impl_t *c;
    int32_t live;
    if (!ch) return 0;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    live = !c->closed;
    channel_unlock(c);
    return live;
}

/** 单路 recv 阻塞等待：轮询 try 之间的 timedwait（5ms）。 */
static void channel_select_wait_recv_one(void *ch) {
    channel_i32_impl_t *c;
    if (!ch) return;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    if (c->len > 0 || c->closed) {
        channel_unlock(c);
        return;
    }
    channel_timedwait_not_empty(c, SELECT_TIMEDWAIT_MS);
    channel_unlock(c);
}

/** 单路 send 阻塞等待：轮询 try 之间的 timedwait（5ms）。 */
static void channel_select_wait_send_one(void *ch) {
    channel_i32_impl_t *c;
    if (!ch) return;
    c = (channel_i32_impl_t *)ch;
    channel_lock(c);
    if (c->closed || c->unbounded || c->len < c->cap) {
        channel_unlock(c);
        return;
    }
    channel_timedwait_not_full(c, SELECT_TIMEDWAIT_MS);
    channel_unlock(c);
}

/** 非阻塞双路 recv；ch0 优先于 ch1。 */
int32_t channel_select_try_recv_2_c(void *ch0, void *ch1, int32_t *out_val, int32_t *out_index) {
    int32_t r;
    if (!out_val || !out_index) return SELECT_ERR_ALL_CLOSED;
    r = channel_i32_try_recv_c(ch0, out_val);
    if (r == 0) { *out_index = 0; return 0; }
    r = channel_i32_try_recv_c(ch1, out_val);
    if (r == 0) { *out_index = 1; return 0; }
    if (!channel_select_recv_case_live(ch0) && !channel_select_recv_case_live(ch1))
        return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞双路 recv 直至任一路有数据。 */
int32_t channel_select_recv_2_c(void *ch0, void *ch1, int32_t *out_val, int32_t *out_index) {
    int32_t r;
    for (;;) {
        r = channel_select_try_recv_2_c(ch0, ch1, out_val, out_index);
        if (r != SELECT_ERR_PENDING) return r;
        channel_select_wait_recv_one(ch0);
        channel_select_wait_recv_one(ch1);
    }
}

/** 非阻塞 N 路 recv；index 升序优先。 */
int32_t channel_select_try_recv_n_c(int64_t *chs_slots, int32_t n, int32_t *out_val, int32_t *out_index) {
    int32_t i, r, any_live = 0;
    void *ch;
    if (!chs_slots || !out_val || !out_index || n <= 0 || n > CHANNEL_SELECT_MAX)
        return SELECT_ERR_ALL_CLOSED;
    for (i = 0; i < n; i++) {
        ch = channel_select_chs_get(chs_slots, i);
        r = channel_i32_try_recv_c(ch, out_val);
        if (r == 0) { *out_index = i; return 0; }
    }
    for (i = 0; i < n; i++) {
        if (channel_select_recv_case_live(channel_select_chs_get(chs_slots, i)))
            any_live = 1;
    }
    if (!any_live) return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞 N 路 recv 直至任一路有数据。 */
int32_t channel_select_recv_n_c(int64_t *chs_slots, int32_t n, int32_t *out_val, int32_t *out_index) {
    int32_t i, r;
    for (;;) {
        r = channel_select_try_recv_n_c(chs_slots, n, out_val, out_index);
        if (r != SELECT_ERR_PENDING) return r;
        for (i = 0; i < n; i++)
            channel_select_wait_recv_one(channel_select_chs_get(chs_slots, i));
    }
}

/** 非阻塞双路 send；ch0 优先于 ch1。 */
int32_t channel_select_try_send_2_c(void *ch0, void *ch1, int32_t val, int32_t *out_index) {
    int32_t r;
    if (!out_index) return SELECT_ERR_ALL_CLOSED;
    r = channel_i32_try_send_c(ch0, val);
    if (r == 0) { *out_index = 0; return 0; }
    r = channel_i32_try_send_c(ch1, val);
    if (r == 0) { *out_index = 1; return 0; }
    if (!channel_select_send_case_live(ch0) && !channel_select_send_case_live(ch1))
        return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞双路 send 直至任一路可写。 */
int32_t channel_select_send_2_c(void *ch0, void *ch1, int32_t val, int32_t *out_index) {
    int32_t r;
    for (;;) {
        r = channel_select_try_send_2_c(ch0, ch1, val, out_index);
        if (r != SELECT_ERR_PENDING) return r;
        channel_select_wait_send_one(ch0);
        channel_select_wait_send_one(ch1);
    }
}

/** 非阻塞 N 路 send；index 升序优先。 */
int32_t channel_select_try_send_n_c(int64_t *chs_slots, int32_t n, int32_t val, int32_t *out_index) {
    int32_t i, r, any_live = 0;
    void *ch;
    if (!chs_slots || !out_index || n <= 0 || n > CHANNEL_SELECT_MAX)
        return SELECT_ERR_ALL_CLOSED;
    for (i = 0; i < n; i++) {
        ch = channel_select_chs_get(chs_slots, i);
        r = channel_i32_try_send_c(ch, val);
        if (r == 0) { *out_index = i; return 0; }
    }
    for (i = 0; i < n; i++) {
        if (channel_select_send_case_live(channel_select_chs_get(chs_slots, i)))
            any_live = 1;
    }
    if (!any_live) return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞 N 路 send 直至任一路可写。 */
int32_t channel_select_send_n_c(int64_t *chs_slots, int32_t n, int32_t val, int32_t *out_index) {
    int32_t i, r;
    for (;;) {
        r = channel_select_try_send_n_c(chs_slots, n, val, out_index);
        if (r != SELECT_ERR_PENDING) return r;
        for (i = 0; i < n; i++)
            channel_select_wait_send_one(channel_select_chs_get(chs_slots, i));
    }
}

/** 非阻塞混合双路；recv 优先于 send。 */
int32_t channel_select_try_mixed_2_c(void *recv_ch, void *send_ch, int32_t send_val,
    int32_t *out_val, int32_t *out_is_send) {
    int32_t r;
    if (!out_val || !out_is_send) return SELECT_ERR_ALL_CLOSED;
    r = channel_i32_try_recv_c(recv_ch, out_val);
    if (r == 0) { *out_is_send = 0; return 0; }
    r = channel_i32_try_send_c(send_ch, send_val);
    if (r == 0) { *out_is_send = 1; return 0; }
    if (!channel_select_recv_case_live(recv_ch) && !channel_select_send_case_live(send_ch))
        return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞混合双路；recv 优先于 send。 */
int32_t channel_select_mixed_2_c(void *recv_ch, void *send_ch, int32_t send_val,
    int32_t *out_val, int32_t *out_is_send) {
    int32_t r;
    for (;;) {
        r = channel_select_try_mixed_2_c(recv_ch, send_ch, send_val, out_val, out_is_send);
        if (r != SELECT_ERR_PENDING) return r;
        channel_select_wait_recv_one(recv_ch);
        channel_select_wait_send_one(send_ch);
    }
}

/** 非阻塞 N 路混合；index 升序优先。 */
int32_t channel_select_try_mixed_n_c(int64_t *chs_slots, int32_t *dirs, int32_t n, int32_t send_val,
    int32_t *out_val, int32_t *out_index, int32_t *out_is_send) {
    int32_t i, r, any_live = 0;
    void *ch;
    if (!chs_slots || !dirs || !out_val || !out_index || !out_is_send || n <= 0 || n > CHANNEL_SELECT_MAX)
        return SELECT_ERR_ALL_CLOSED;
    for (i = 0; i < n; i++) {
        ch = channel_select_chs_get(chs_slots, i);
        if (dirs[i] == SELECT_DIR_RECV) {
            r = channel_i32_try_recv_c(ch, out_val);
            if (r == 0) { *out_index = i; *out_is_send = 0; return 0; }
        } else {
            r = channel_i32_try_send_c(ch, send_val);
            if (r == 0) { *out_index = i; *out_is_send = 1; return 0; }
        }
    }
    for (i = 0; i < n; i++) {
        ch = channel_select_chs_get(chs_slots, i);
        if (dirs[i] == SELECT_DIR_RECV) {
            if (channel_select_recv_case_live(ch)) any_live = 1;
        } else {
            if (channel_select_send_case_live(ch)) any_live = 1;
        }
    }
    if (!any_live) return SELECT_ERR_ALL_CLOSED;
    return SELECT_ERR_PENDING;
}

/** 阻塞 N 路混合。 */
int32_t channel_select_mixed_n_c(int64_t *chs_slots, int32_t *dirs, int32_t n, int32_t send_val,
    int32_t *out_val, int32_t *out_index, int32_t *out_is_send) {
    int32_t i, r;
    void *ch;
    for (;;) {
        r = channel_select_try_mixed_n_c(chs_slots, dirs, n, send_val, out_val, out_index, out_is_send);
        if (r != SELECT_ERR_PENDING) return r;
        for (i = 0; i < n; i++) {
            ch = channel_select_chs_get(chs_slots, i);
            if (dirs[i] == SELECT_DIR_RECV)
                channel_select_wait_recv_one(ch);
            else
                channel_select_wait_send_one(ch);
        }
    }
}
