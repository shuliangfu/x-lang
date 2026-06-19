/**
 * std/queue/queue.c — STD-048：并发安全队列竞争烟测（C 层）
 *
 * 【文件职责】双线程各 push 500 次至 mutex 保护环形队列；验证 len==1000。
 * 【依赖】POSIX pthread 或 Windows _beginthreadex；mutex 自包含（与 SyncQueue 语义一致）。
 */
#include <stdint.h>
#include <stdlib.h>

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define SHUX_QUEUE_WIN 1
#else
#include <pthread.h>
#include <time.h>
#define SHUX_QUEUE_WIN 0
#endif

/** 烟测用 mutex 保护环形队列（i32）。 */
typedef struct {
#if SHUX_QUEUE_WIN
    CRITICAL_SECTION cs;
#else
    pthread_mutex_t mu;
#endif
    int32_t *data;
    int32_t cap;
    int32_t len;
    int32_t head;
} shu_sync_q_smoke_t;

static int32_t shu_sq_at(shu_sync_q_smoke_t *q, int32_t i) {
    int32_t idx = q->head + i;
    if (idx >= q->cap) idx -= q->cap;
    return idx;
}

static int32_t shu_sq_push_back(shu_sync_q_smoke_t *q, int32_t x) {
    if (q->len >= q->cap) {
        int32_t new_cap = (q->cap <= 0) ? 8 : q->cap * 2;
        int32_t *p = (int32_t *)malloc((size_t)new_cap * sizeof(int32_t));
        int32_t i;
        if (p == NULL) return -1;
        for (i = 0; i < q->len; i++)
            p[i] = q->data[shu_sq_at(q, i)];
        free(q->data);
        q->data = p;
        q->cap = new_cap;
        q->head = 0;
    }
    q->data[shu_sq_at(q, q->len)] = x;
    q->len++;
    return 0;
}

static void shu_sq_lock(shu_sync_q_smoke_t *q) {
#if SHUX_QUEUE_WIN
    EnterCriticalSection(&q->cs);
#else
    pthread_mutex_lock(&q->mu);
#endif
}

static void shu_sq_unlock(shu_sync_q_smoke_t *q) {
#if SHUX_QUEUE_WIN
    LeaveCriticalSection(&q->cs);
#else
    pthread_mutex_unlock(&q->mu);
#endif
}

typedef struct {
    shu_sync_q_smoke_t *q;
} shu_sq_worker_ctx_t;

#if SHUX_QUEUE_WIN
static unsigned __stdcall shu_sq_worker(void *arg) {
#else
static void *shu_sq_worker(void *arg) {
#endif
    shu_sq_worker_ctx_t *ctx = (shu_sq_worker_ctx_t *)arg;
    int32_t i;
    for (i = 0; i < 500; i++) {
        shu_sq_lock(ctx->q);
        shu_sq_push_back(ctx->q, 1);
        shu_sq_unlock(ctx->q);
    }
#if SHUX_QUEUE_WIN
    return 0;
#else
    return NULL;
#endif
}

/** STD-048：双线程并发 push 烟测；0 通过，-1 失败。 */
int32_t sync_queue_contention_smoke_c(void) {
    shu_sync_q_smoke_t q;
    shu_sq_worker_ctx_t ctx;
#if SHUX_QUEUE_WIN
    uintptr_t h0, h1;
#else
    pthread_t t0, t1;
#endif
    int32_t rc = -1;

    q.data = NULL;
    q.cap = 0;
    q.len = 0;
    q.head = 0;
#if SHUX_QUEUE_WIN
    InitializeCriticalSection(&q.cs);
#else
    if (pthread_mutex_init(&q.mu, NULL) != 0) return -1;
#endif
    ctx.q = &q;
#if SHUX_QUEUE_WIN
    h0 = _beginthreadex(NULL, 0, shu_sq_worker, &ctx, 0, NULL);
    h1 = _beginthreadex(NULL, 0, shu_sq_worker, &ctx, 0, NULL);
    if (h0 == 0 || h1 == 0) goto done;
    WaitForSingleObject((HANDLE)h0, INFINITE);
    WaitForSingleObject((HANDLE)h1, INFINITE);
    CloseHandle((HANDLE)h0);
    CloseHandle((HANDLE)h1);
#else
    if (pthread_create(&t0, NULL, shu_sq_worker, &ctx) != 0) goto done;
    if (pthread_create(&t1, NULL, shu_sq_worker, &ctx) != 0) {
        pthread_join(t0, NULL);
        goto done;
    }
    pthread_join(t0, NULL);
    pthread_join(t1, NULL);
#endif
    rc = (q.len == 1000) ? 0 : -1;
done:
    free(q.data);
#if SHUX_QUEUE_WIN
    DeleteCriticalSection(&q.cs);
#else
    pthread_mutex_destroy(&q.mu);
#endif
    return rc;
}
