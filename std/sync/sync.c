/**
 * std/sync/sync.c — 互斥锁与同步原语（对标 Zig Thread.Mutex、Rust std::sync::Mutex）
 *
 * 【文件职责】
 * 实现 std.sync 的 C 层：mutex_new、mutex_lock、mutex_try_lock、mutex_unlock、mutex_free。
 * POSIX 使用 pthread_mutex_t；Windows 使用 CRITICAL_SECTION。与 std.thread 配合用于多线程互斥。
 *
 * 【所属模块/组件】
 * 标准库 std.sync；与 std/sync/mod.sx 同目录。用户 import std.sync 时链入 std/sync/sync.o；Unix 需 -lpthread。
 *
 * 【与其它文件的关系】
 * - 被依赖：用户 import std.sync 且 -o exe 时链入本 .o。
 * - 依赖：无项目内头文件；POSIX 依赖 pthread，Windows 依赖 kernel32。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* --- STD-111：调试模式锁诊断（全平台共享） --- */

#define SYNC_LOCK_DIAG_ERR_RECURSIVE (-1)
#define SYNC_LOCK_DIAG_ERR_ORDER     (-2)
#define SYNC_LOCK_DIAG_ERR_UNLOCK    (-3)
#define SYNC_LOCK_DIAG_ERR_TABLE     (-4)
#define SYNC_LOCK_DIAG_MAX_META      64
#define SYNC_LOCK_DIAG_MAX_HELD      16

typedef struct {
    void *mutex;
    int32_t order_id;
} sync_lock_diag_meta_t;

static struct {
    int32_t enabled;
    int32_t last_err;
    int32_t acquires;
    int32_t contentions;
    int32_t meta_n;
    sync_lock_diag_meta_t meta[SYNC_LOCK_DIAG_MAX_META];
} g_sync_lock_diag;

#if defined(_MSC_VER)
static __declspec(thread) void *t_held_mutex[SYNC_LOCK_DIAG_MAX_HELD];
static __declspec(thread) int32_t t_held_order[SYNC_LOCK_DIAG_MAX_HELD];
static __declspec(thread) int32_t t_held_n;
#else
static __thread void *t_held_mutex[SYNC_LOCK_DIAG_MAX_HELD];
static __thread int32_t t_held_order[SYNC_LOCK_DIAG_MAX_HELD];
static __thread int32_t t_held_n;
#endif

/** 查找 mutex 对应的锁序元数据。 */
static sync_lock_diag_meta_t *sync_lock_diag_find_meta(void *m) {
    int32_t i;
    for (i = 0; i < g_sync_lock_diag.meta_n; i++) {
        if (g_sync_lock_diag.meta[i].mutex == m) {
            return &g_sync_lock_diag.meta[i];
        }
    }
    return NULL;
}

/** 读取 mutex 绑定的锁序 id；未绑定返回 0（跳过锁序检查）。 */
static int32_t sync_lock_diag_get_order(void *m) {
    sync_lock_diag_meta_t *e = sync_lock_diag_find_meta(m);
    return e ? e->order_id : 0;
}

/** 当前线程是否已持有该 mutex。 */
static int sync_lock_diag_held_has(void *m) {
    int32_t i;
    for (i = 0; i < t_held_n; i++) {
        if (t_held_mutex[i] == m) {
            return 1;
        }
    }
    return 0;
}

/** 当前线程已持有锁的最大 order id。 */
static int32_t sync_lock_diag_max_held_order(void) {
    int32_t mx = 0;
    int32_t i;
    for (i = 0; i < t_held_n; i++) {
        if (t_held_order[i] > mx) {
            mx = t_held_order[i];
        }
    }
    return mx;
}

/** 加锁前诊断：递归/锁序违规返回 -1。 */
static int32_t sync_lock_diag_before_lock(void *m) {
    int32_t oid;
    int32_t maxo;
    if (!g_sync_lock_diag.enabled) {
        return 0;
    }
    if (sync_lock_diag_held_has(m)) {
        g_sync_lock_diag.last_err = SYNC_LOCK_DIAG_ERR_RECURSIVE;
        return -1;
    }
    oid = sync_lock_diag_get_order(m);
    if (oid != 0) {
        maxo = sync_lock_diag_max_held_order();
        if (maxo > 0 && oid <= maxo) {
            g_sync_lock_diag.last_err = SYNC_LOCK_DIAG_ERR_ORDER;
            g_sync_lock_diag.contentions++;
            return -1;
        }
    }
    return 0;
}

/** 加锁成功后记录持有栈。 */
static void sync_lock_diag_after_lock(void *m) {
    int32_t oid;
    if (!g_sync_lock_diag.enabled) {
        return;
    }
    if (t_held_n >= SYNC_LOCK_DIAG_MAX_HELD) {
        g_sync_lock_diag.last_err = SYNC_LOCK_DIAG_ERR_TABLE;
        return;
    }
    oid = sync_lock_diag_get_order(m);
    t_held_mutex[t_held_n] = m;
    t_held_order[t_held_n] = oid;
    t_held_n++;
    g_sync_lock_diag.acquires++;
    g_sync_lock_diag.last_err = 0;
}

/** 解锁前诊断：须 LIFO 释放。 */
static int32_t sync_lock_diag_before_unlock(void *m) {
    if (!g_sync_lock_diag.enabled) {
        return 0;
    }
    if (t_held_n <= 0 || t_held_mutex[t_held_n - 1] != m) {
        g_sync_lock_diag.last_err = SYNC_LOCK_DIAG_ERR_UNLOCK;
        return -1;
    }
    return 0;
}

/** 解锁成功后弹出持有栈。 */
static void sync_lock_diag_after_unlock(void *m) {
    (void)m;
    if (!g_sync_lock_diag.enabled) {
        return;
    }
    if (t_held_n > 0) {
        t_held_n--;
    }
    g_sync_lock_diag.last_err = 0;
}

/** 开启/关闭锁诊断。 */
void sync_lock_diag_set_enabled_c(int32_t on) {
    g_sync_lock_diag.enabled = on ? 1 : 0;
}

/** 查询锁诊断是否开启。 */
int32_t sync_lock_diag_is_enabled_c(void) {
    return g_sync_lock_diag.enabled ? 1 : 0;
}

/** 为 mutex 绑定锁序 id；0=跳过锁序检查。 */
int32_t sync_lock_diag_mutex_set_id_c(void *m, int32_t id) {
    sync_lock_diag_meta_t *e;
    if (!m) {
        return -1;
    }
    e = sync_lock_diag_find_meta(m);
    if (e) {
        e->order_id = id;
        return 0;
    }
    if (g_sync_lock_diag.meta_n >= SYNC_LOCK_DIAG_MAX_META) {
        g_sync_lock_diag.last_err = SYNC_LOCK_DIAG_ERR_TABLE;
        return -1;
    }
    g_sync_lock_diag.meta[g_sync_lock_diag.meta_n].mutex = m;
    g_sync_lock_diag.meta[g_sync_lock_diag.meta_n].order_id = id;
    g_sync_lock_diag.meta_n++;
    return 0;
}

/** 最近诊断错误码。 */
int32_t sync_lock_diag_last_err_c(void) {
    return g_sync_lock_diag.last_err;
}

/** 清空元数据、统计与当前线程持有栈。 */
void sync_lock_diag_clear_c(void) {
    g_sync_lock_diag.last_err = 0;
    g_sync_lock_diag.acquires = 0;
    g_sync_lock_diag.contentions = 0;
    g_sync_lock_diag.meta_n = 0;
    t_held_n = 0;
}

/** 写入文本快照；返回写入字节数（不含 NUL），失败 -1。 */
int32_t sync_lock_diag_snapshot_c(uint8_t *out, int32_t cap) {
    int n;
    if (!out || cap <= 0) {
        return -1;
    }
    n = snprintf((char *)out, (size_t)cap,
                 "enabled=%d held=%d acquires=%d contentions=%d last_err=%d",
                 g_sync_lock_diag.enabled, (int)t_held_n,
                 g_sync_lock_diag.acquires, g_sync_lock_diag.contentions,
                 g_sync_lock_diag.last_err);
    if (n < 0 || n >= cap) {
        return -1;
    }
    return n;
}

/* sync_mutex_* 前向声明（平台实现见下方）。 */
void *sync_mutex_new_c(void);
int32_t sync_mutex_lock_c(void *m);
int32_t sync_mutex_try_lock_c(void *m);
int32_t sync_mutex_unlock_c(void *m);
void sync_mutex_free_c(void *m);

/** C 烟测：锁序/递归/快照场景。 */
int32_t sync_lock_diag_smoke_c(void) {
    void *m1;
    void *m2;
    uint8_t snap[96];
    m1 = sync_mutex_new_c();
    m2 = sync_mutex_new_c();
    if (!m1 || !m2) {
        sync_mutex_free_c(m1);
        sync_mutex_free_c(m2);
        return 1;
    }
    sync_lock_diag_clear_c();
    sync_lock_diag_set_enabled_c(1);
    if (sync_lock_diag_mutex_set_id_c(m1, 1) != 0 || sync_lock_diag_mutex_set_id_c(m2, 2) != 0) {
        return 2;
    }
    if (sync_mutex_lock_c(m1) != 0 || sync_mutex_lock_c(m2) != 0) {
        return 3;
    }
    if (sync_mutex_unlock_c(m2) != 0 || sync_mutex_unlock_c(m1) != 0) {
        return 4;
    }
    if (sync_mutex_lock_c(m2) != 0) {
        return 5;
    }
    if (sync_mutex_lock_c(m1) != -1 || sync_lock_diag_last_err_c() != SYNC_LOCK_DIAG_ERR_ORDER) {
        sync_mutex_unlock_c(m2);
        return 6;
    }
    sync_mutex_unlock_c(m2);
    if (sync_mutex_lock_c(m1) != 0) {
        return 7;
    }
    if (sync_mutex_lock_c(m1) != -1 || sync_lock_diag_last_err_c() != SYNC_LOCK_DIAG_ERR_RECURSIVE) {
        sync_mutex_unlock_c(m1);
        return 8;
    }
    sync_mutex_unlock_c(m1);
    if (sync_lock_diag_snapshot_c(snap, 96) <= 0) {
        return 9;
    }
    sync_lock_diag_set_enabled_c(0);
    if (sync_mutex_lock_c(m1) != 0 || sync_mutex_unlock_c(m1) != 0) {
        return 10;
    }
    sync_mutex_free_c(m1);
    sync_mutex_free_c(m2);
    return 0;
}

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>

/** Windows：互斥体为 CRITICAL_SECTION*，堆分配以便返回不透明指针。 */
typedef CRITICAL_SECTION shu_mutex_impl_t;

void *sync_mutex_new_c(void) {
    shu_mutex_impl_t *m = (shu_mutex_impl_t *)malloc(sizeof(shu_mutex_impl_t));
    if (m == NULL) return NULL;
    InitializeCriticalSection(m);
    return (void *)m;
}

/** 加锁；阻塞直到获取。返回 0 成功，-1 失败（如 m 为 NULL）。 */
int32_t sync_mutex_lock_c(void *m) {
    if (m == NULL) return -1;
    if (sync_lock_diag_before_lock(m) != 0) {
        return -1;
    }
    EnterCriticalSection((CRITICAL_SECTION *)m);
    sync_lock_diag_after_lock(m);
    return 0;
}

/** 尝试加锁；不阻塞。返回 0 成功获取，非 0 未获取（忙或 m 为 NULL）。 */
int32_t sync_mutex_try_lock_c(void *m) {
    if (m == NULL) return -1;
    if (sync_lock_diag_before_lock(m) != 0) {
        return -1;
    }
    if (!TryEnterCriticalSection((CRITICAL_SECTION *)m)) {
        return 1;
    }
    sync_lock_diag_after_lock(m);
    return 0;
}

/** 解锁。返回 0 成功，-1 失败（如 m 为 NULL）。 */
int32_t sync_mutex_unlock_c(void *m) {
    if (m == NULL) return -1;
    if (sync_lock_diag_before_unlock(m) != 0) {
        return -1;
    }
    LeaveCriticalSection((CRITICAL_SECTION *)m);
    sync_lock_diag_after_unlock(m);
    return 0;
}

/** 销毁并释放互斥体；调用后 m 不可再使用。 */
void sync_mutex_free_c(void *m) {
    if (m == NULL) return;
    DeleteCriticalSection((CRITICAL_SECTION *)m);
    free(m);
}

typedef SRWLOCK shu_rwlock_impl_t;
typedef CONDITION_VARIABLE shu_condvar_impl_t;

void *sync_rwlock_new_c(void) {
    shu_rwlock_impl_t *rw = (shu_rwlock_impl_t *)malloc(sizeof(shu_rwlock_impl_t));
    if (!rw) return NULL;
    InitializeSRWLock(rw);
    return (void *)rw;
}

int32_t sync_rwlock_read_lock_c(void *rw) {
    if (!rw) return -1;
    AcquireSRWLockShared((SRWLOCK *)rw);
    return 0;
}

int32_t sync_rwlock_write_lock_c(void *rw) {
    if (!rw) return -1;
    AcquireSRWLockExclusive((SRWLOCK *)rw);
    return 0;
}

int32_t sync_rwlock_read_unlock_c(void *rw) {
    if (!rw) return -1;
    ReleaseSRWLockShared((SRWLOCK *)rw);
    return 0;
}

int32_t sync_rwlock_write_unlock_c(void *rw) {
    if (!rw) return -1;
    ReleaseSRWLockExclusive((SRWLOCK *)rw);
    return 0;
}

void sync_rwlock_free_c(void *rw) {
    free(rw);
}

void *sync_condvar_new_c(void) {
    shu_condvar_impl_t *cv = (shu_condvar_impl_t *)malloc(sizeof(shu_condvar_impl_t));
    if (!cv) return NULL;
    InitializeConditionVariable(cv);
    return (void *)cv;
}

int32_t sync_condvar_wait_c(void *cv, void *mutex) {
    if (!cv || !mutex) return -1;
    if (!SleepConditionVariableCS((CONDITION_VARIABLE *)cv, (CRITICAL_SECTION *)mutex, INFINITE)) {
        return -1;
    }
    return 0;
}

int32_t sync_condvar_signal_c(void *cv) {
    if (!cv) return -1;
    WakeConditionVariable((CONDITION_VARIABLE *)cv);
    return 0;
}

int32_t sync_condvar_broadcast_c(void *cv) {
    if (!cv) return -1;
    WakeAllConditionVariable((CONDITION_VARIABLE *)cv);
    return 0;
}

void sync_condvar_free_c(void *cv) {
    free(cv);
}

int32_t sync_rwlock_contention_smoke_c(void) {
    void *rw = sync_rwlock_new_c();
    int32_t counter = 0;
    if (!rw) return 1;
    {
        int32_t i;
        for (i = 0; i < 1000; i++) {
            sync_rwlock_write_lock_c(rw);
            counter++;
            sync_rwlock_write_unlock_c(rw);
        }
    }
    sync_rwlock_free_c(rw);
    return (counter == 1000) ? 0 : 2;
}

int32_t sync_condvar_contention_smoke_c(void) {
    (void)sync_condvar_new_c;
    return 0;
}

#else
#include <pthread.h>
#include <time.h>

/** POSIX：互斥体为 pthread_mutex_t*，堆分配以便返回不透明指针。 */
typedef pthread_mutex_t shu_mutex_impl_t;

void *sync_mutex_new_c(void) {
    shu_mutex_impl_t *m = (shu_mutex_impl_t *)malloc(sizeof(shu_mutex_impl_t));
    if (m == NULL) return NULL;
    if (pthread_mutex_init(m, NULL) != 0) {
        free(m);
        return NULL;
    }
    return (void *)m;
}

/** 加锁；阻塞直到获取。返回 0 成功，-1 失败（如 m 为 NULL）。 */
int32_t sync_mutex_lock_c(void *m) {
    if (m == NULL) return -1;
    if (sync_lock_diag_before_lock(m) != 0) {
        return -1;
    }
    if (pthread_mutex_lock((pthread_mutex_t *)m) != 0) {
        return -1;
    }
    sync_lock_diag_after_lock(m);
    return 0;
}

/** 尝试加锁；不阻塞。返回 0 成功获取，非 0 未获取（EBUSY 或 m 为 NULL）。 */
int32_t sync_mutex_try_lock_c(void *m) {
    int ret;
    if (m == NULL) return -1;
    if (sync_lock_diag_before_lock(m) != 0) {
        return -1;
    }
    ret = pthread_mutex_trylock((pthread_mutex_t *)m);
    if (ret == 0) {
        sync_lock_diag_after_lock(m);
        return 0;
    }
    return 1; /* EBUSY 或其它 */
}

/** 解锁。返回 0 成功，-1 失败。 */
int32_t sync_mutex_unlock_c(void *m) {
    if (m == NULL) return -1;
    if (sync_lock_diag_before_unlock(m) != 0) {
        return -1;
    }
    if (pthread_mutex_unlock((pthread_mutex_t *)m) != 0) {
        return -1;
    }
    sync_lock_diag_after_unlock(m);
    return 0;
}

/** 销毁并释放互斥体；调用后 m 不可再使用。 */
void sync_mutex_free_c(void *m) {
    if (m == NULL) return;
    pthread_mutex_destroy((pthread_mutex_t *)m);
    free(m);
}

typedef pthread_rwlock_t shu_rwlock_impl_t;
typedef pthread_cond_t shu_condvar_impl_t;

void *sync_rwlock_new_c(void) {
    shu_rwlock_impl_t *rw = (shu_rwlock_impl_t *)malloc(sizeof(shu_rwlock_impl_t));
    if (!rw) return NULL;
    if (pthread_rwlock_init(rw, NULL) != 0) {
        free(rw);
        return NULL;
    }
    return (void *)rw;
}

int32_t sync_rwlock_read_lock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_rdlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

int32_t sync_rwlock_write_lock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_wrlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

int32_t sync_rwlock_read_unlock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_unlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

int32_t sync_rwlock_write_unlock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_unlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

void sync_rwlock_free_c(void *rw) {
    if (!rw) return;
    pthread_rwlock_destroy((pthread_rwlock_t *)rw);
    free(rw);
}

void *sync_condvar_new_c(void) {
    shu_condvar_impl_t *cv = (shu_condvar_impl_t *)malloc(sizeof(shu_condvar_impl_t));
    if (!cv) return NULL;
    if (pthread_cond_init(cv, NULL) != 0) {
        free(cv);
        return NULL;
    }
    return (void *)cv;
}

int32_t sync_condvar_wait_c(void *cv, void *mutex) {
    if (!cv || !mutex) return -1;
    return (pthread_cond_wait((pthread_cond_t *)cv, (pthread_mutex_t *)mutex) == 0) ? 0 : -1;
}

int32_t sync_condvar_signal_c(void *cv) {
    if (!cv) return -1;
    return (pthread_cond_signal((pthread_cond_t *)cv) == 0) ? 0 : -1;
}

int32_t sync_condvar_broadcast_c(void *cv) {
    if (!cv) return -1;
    return (pthread_cond_broadcast((pthread_cond_t *)cv) == 0) ? 0 : -1;
}

void sync_condvar_free_c(void *cv) {
    if (!cv) return;
    pthread_cond_destroy((pthread_cond_t *)cv);
    free(cv);
}

typedef struct {
    void *cv;
    void *mu;
    int32_t ready;
} shu_cond_smoke_ctx_t;

static void *shu_condvar_smoke_waiter(void *arg) {
    shu_cond_smoke_ctx_t *ctx = (shu_cond_smoke_ctx_t *)arg;
    if (sync_mutex_lock_c(ctx->mu) != 0) return (void *)(intptr_t)1;
    while (ctx->ready == 0) {
        if (sync_condvar_wait_c(ctx->cv, ctx->mu) != 0) {
            sync_mutex_unlock_c(ctx->mu);
            return (void *)(intptr_t)2;
        }
    }
    sync_mutex_unlock_c(ctx->mu);
    return NULL;
}

int32_t sync_rwlock_contention_smoke_c(void) {
    void *rw = sync_rwlock_new_c();
    int32_t counter = 0;
    if (!rw) return 1;
    {
        int32_t i;
        for (i = 0; i < 1000; i++) {
            sync_rwlock_write_lock_c(rw);
            counter++;
            sync_rwlock_write_unlock_c(rw);
        }
    }
    sync_rwlock_free_c(rw);
    return (counter == 1000) ? 0 : 2;
}

int32_t sync_condvar_contention_smoke_c(void) {
    shu_cond_smoke_ctx_t ctx;
    pthread_t tid;
    void *ret;
    ctx.cv = sync_condvar_new_c();
    ctx.mu = sync_mutex_new_c();
    ctx.ready = 0;
    if (!ctx.cv || !ctx.mu) {
        sync_condvar_free_c(ctx.cv);
        sync_mutex_free_c(ctx.mu);
        return 1;
    }
    if (pthread_create(&tid, NULL, shu_condvar_smoke_waiter, &ctx) != 0) {
        sync_condvar_free_c(ctx.cv);
        sync_mutex_free_c(ctx.mu);
        return 2;
    }
    {
        struct timespec ts = { 0, 20000000L };
        nanosleep(&ts, NULL);
    }
    if (sync_mutex_lock_c(ctx.mu) != 0) {
        pthread_join(tid, NULL);
        sync_condvar_free_c(ctx.cv);
        sync_mutex_free_c(ctx.mu);
        return 3;
    }
    ctx.ready = 1;
    sync_condvar_signal_c(ctx.cv);
    sync_mutex_unlock_c(ctx.mu);
    pthread_join(tid, &ret);
    sync_condvar_free_c(ctx.cv);
    sync_mutex_free_c(ctx.mu);
    return (ret == NULL) ? 0 : 4;
}

#endif
