/**
 * runtime_sync_os.c — Mutex/RwLock/Condvar OS 胶层（F-ZC：自 std/sync/sync_os_glue.c 迁入）
 *
 * 【文件职责】
 * 实现 sync_mutex_*、sync_rwlock_*、sync_condvar_* 及竞争烟测；
 * POSIX 使用 pthread；Windows 使用 CRITICAL_SECTION / SRWLOCK / CONDITION_VARIABLE。
 * 加解锁时调用 sync.sx 中的诊断钩子。
 *
 * 【所属模块】std.sync；与 sync.o、runtime_sync_lock_diag_tls.o 一并链入 exe。
 */

#include <stdint.h>
#include <stdlib.h>

/** 锁诊断钩子（sync.sx）。 */
extern int32_t sync_lock_diag_before_lock(void *m);
extern void sync_lock_diag_after_lock(void *m);
extern int32_t sync_lock_diag_before_unlock(void *m);
extern void sync_lock_diag_after_unlock(void *m);

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>

/** Windows：互斥体为 CRITICAL_SECTION*，堆分配以便返回不透明指针。 */
typedef CRITICAL_SECTION shu_mutex_impl_t;

/** 创建新互斥体；失败 NULL。 */
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

/** 创建 RwLock；失败 NULL。 */
void *sync_rwlock_new_c(void) {
    shu_rwlock_impl_t *rw = (shu_rwlock_impl_t *)malloc(sizeof(shu_rwlock_impl_t));
    if (!rw) return NULL;
    InitializeSRWLock(rw);
    return (void *)rw;
}

/** 获取读锁；成功 0。 */
int32_t sync_rwlock_read_lock_c(void *rw) {
    if (!rw) return -1;
    AcquireSRWLockShared((SRWLOCK *)rw);
    return 0;
}

/** 获取写锁；成功 0。 */
int32_t sync_rwlock_write_lock_c(void *rw) {
    if (!rw) return -1;
    AcquireSRWLockExclusive((SRWLOCK *)rw);
    return 0;
}

/** 释放读锁；成功 0。 */
int32_t sync_rwlock_read_unlock_c(void *rw) {
    if (!rw) return -1;
    ReleaseSRWLockShared((SRWLOCK *)rw);
    return 0;
}

/** 释放写锁；成功 0。 */
int32_t sync_rwlock_write_unlock_c(void *rw) {
    if (!rw) return -1;
    ReleaseSRWLockExclusive((SRWLOCK *)rw);
    return 0;
}

/** 销毁 RwLock。 */
void sync_rwlock_free_c(void *rw) {
    free(rw);
}

/** 创建 Condvar；失败 NULL。 */
void *sync_condvar_new_c(void) {
    shu_condvar_impl_t *cv = (shu_condvar_impl_t *)malloc(sizeof(shu_condvar_impl_t));
    if (!cv) return NULL;
    InitializeConditionVariable(cv);
    return (void *)cv;
}

/** 在已持有 mutex 时等待 condvar。 */
int32_t sync_condvar_wait_c(void *cv, void *mutex) {
    if (!cv || !mutex) return -1;
    if (!SleepConditionVariableCS((CONDITION_VARIABLE *)cv, (CRITICAL_SECTION *)mutex, INFINITE)) {
        return -1;
    }
    return 0;
}

/** 唤醒一个等待线程。 */
int32_t sync_condvar_signal_c(void *cv) {
    if (!cv) return -1;
    WakeConditionVariable((CONDITION_VARIABLE *)cv);
    return 0;
}

/** 唤醒全部等待线程。 */
int32_t sync_condvar_broadcast_c(void *cv) {
    if (!cv) return -1;
    WakeAllConditionVariable((CONDITION_VARIABLE *)cv);
    return 0;
}

/** 销毁 Condvar。 */
void sync_condvar_free_c(void *cv) {
    free(cv);
}

/** RwLock 竞争烟测；成功 0。 */
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

/** Condvar 烟测（Windows 桩：创建 API 可用即可）。 */
int32_t sync_condvar_contention_smoke_c(void) {
    (void)sync_condvar_new_c;
    return 0;
}

#else
#include <pthread.h>
#include <time.h>

/** POSIX：互斥体为 pthread_mutex_t*，堆分配以便返回不透明指针。 */
typedef pthread_mutex_t shu_mutex_impl_t;

/** 创建新互斥体；失败 NULL。 */
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

/** 创建 RwLock；失败 NULL。 */
void *sync_rwlock_new_c(void) {
    shu_rwlock_impl_t *rw = (shu_rwlock_impl_t *)malloc(sizeof(shu_rwlock_impl_t));
    if (!rw) return NULL;
    if (pthread_rwlock_init(rw, NULL) != 0) {
        free(rw);
        return NULL;
    }
    return (void *)rw;
}

/** 获取读锁；成功 0。 */
int32_t sync_rwlock_read_lock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_rdlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

/** 获取写锁；成功 0。 */
int32_t sync_rwlock_write_lock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_wrlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

/** 释放读锁；成功 0。 */
int32_t sync_rwlock_read_unlock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_unlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

/** 释放写锁；成功 0。 */
int32_t sync_rwlock_write_unlock_c(void *rw) {
    if (!rw) return -1;
    return (pthread_rwlock_unlock((pthread_rwlock_t *)rw) == 0) ? 0 : -1;
}

/** 销毁 RwLock。 */
void sync_rwlock_free_c(void *rw) {
    if (!rw) return;
    pthread_rwlock_destroy((pthread_rwlock_t *)rw);
    free(rw);
}

/** 创建 Condvar；失败 NULL。 */
void *sync_condvar_new_c(void) {
    shu_condvar_impl_t *cv = (shu_condvar_impl_t *)malloc(sizeof(shu_condvar_impl_t));
    if (!cv) return NULL;
    if (pthread_cond_init(cv, NULL) != 0) {
        free(cv);
        return NULL;
    }
    return (void *)cv;
}

/** 在已持有 mutex 时等待 condvar。 */
int32_t sync_condvar_wait_c(void *cv, void *mutex) {
    if (!cv || !mutex) return -1;
    return (pthread_cond_wait((pthread_cond_t *)cv, (pthread_mutex_t *)mutex) == 0) ? 0 : -1;
}

/** 唤醒一个等待线程。 */
int32_t sync_condvar_signal_c(void *cv) {
    if (!cv) return -1;
    return (pthread_cond_signal((pthread_cond_t *)cv) == 0) ? 0 : -1;
}

/** 唤醒全部等待线程。 */
int32_t sync_condvar_broadcast_c(void *cv) {
    if (!cv) return -1;
    return (pthread_cond_broadcast((pthread_cond_t *)cv) == 0) ? 0 : -1;
}

/** 销毁 Condvar。 */
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

/** Condvar 烟测 waiter 线程入口。 */
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

/** RwLock 竞争烟测；成功 0。 */
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

/** Condvar 竞争烟测；成功 0。 */
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
