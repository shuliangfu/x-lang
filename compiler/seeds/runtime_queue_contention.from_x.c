/* seeds/runtime_queue_contention.from_x.c — G-02f-21 product TU
 * Logic still C until full .x port.
 */
/**
 * runtime_queue_contention.c — 并发队列烟测 OS 胶层（F-ZC：自 std/queue/queue_contention_os_glue.c 迁入）
 *
 * pthread/Win32 mutex 与双 worker spawn；烟测队列逻辑与 sync_queue_contention_smoke_c 在本文件（G-03 seed asm）。
 * 与 queue.o 一并链入；Unix 需 -lpthread。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <process.h>
#include <windows.h>
#define SHUX_QUEUE_WIN 1
#else
#include <pthread.h>
#define SHUX_QUEUE_WIN 0
#endif

/** 烟测用 mutex 保护环形队列（与 queue.x QueueSmokeState 布局一致）。 */
typedef struct {
  void *mu;
  int32_t *data;
  int32_t cap;
  int32_t len;
  int32_t head;
} QueueSmokeState;

#if SHUX_QUEUE_WIN
typedef CRITICAL_SECTION queue_os_mutex_t;
#else
typedef pthread_mutex_t queue_os_mutex_t;
#endif

void *queue_os_mutex_create_c(void);
void queue_os_mutex_destroy_c(void *mu);
void queue_os_mutex_lock_c(void *mu);
void queue_os_mutex_unlock_c(void *mu);
int32_t queue_os_run_two_workers_c(void *ctx);

/** 逻辑下标 i 对应的物理下标。 */
static int32_t queue_smoke_at(QueueSmokeState *q, int32_t i) {
  int32_t idx = q->head + i;
  if (idx >= q->cap) {
    idx -= q->cap;
  }
  return idx;
}

/** 队尾插入；失败 -1。 */
static int32_t queue_smoke_push_back(QueueSmokeState *q, int32_t x) {
  int32_t new_cap;
  int32_t *p;
  int32_t i;
  if (!q) {
    return -1;
  }
  if (q->len >= q->cap) {
    if (q->cap <= 0) {
      new_cap = 8;
    } else {
      new_cap = q->cap * 2;
    }
    p = (int32_t *)malloc((size_t)new_cap * sizeof(int32_t));
    if (!p) {
      return -1;
    }
    for (i = 0; i < q->len; i++) {
      p[i] = q->data[queue_smoke_at(q, i)];
    }
    if (q->data) {
      free(q->data);
    }
    q->data = p;
    q->cap = new_cap;
    q->head = 0;
  }
  q->data[queue_smoke_at(q, q->len)] = x;
  q->len++;
  return 0;
}

/** 每 worker 线程：加锁 push 500 次。 */
int32_t queue_contention_worker_push_c(void *ctx) {
  QueueSmokeState *q = (QueueSmokeState *)ctx;
  int32_t i;
  if (!q) {
    return -1;
  }
  for (i = 0; i < 500; i++) {
    queue_os_mutex_lock_c(q->mu);
    queue_smoke_push_back(q, 1);
    queue_os_mutex_unlock_c(q->mu);
  }
  return 0;
}

/**
 * 创建 mutex。
 * 返回值：mutex 指针；失败 NULL。
 */
void *queue_os_mutex_create_c(void) {
    queue_os_mutex_t *m = (queue_os_mutex_t *)malloc(sizeof(queue_os_mutex_t));
    if (!m)
        return NULL;
#if SHUX_QUEUE_WIN
    InitializeCriticalSection(m);
#else
    if (pthread_mutex_init(m, NULL) != 0) {
        free(m);
        return NULL;
    }
#endif
    return (void *)m;
}

/** 销毁 mutex。 */
void queue_os_mutex_destroy_c(void *mu) {
    if (!mu)
        return;
#if SHUX_QUEUE_WIN
    DeleteCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_destroy((queue_os_mutex_t *)mu);
#endif
    free(mu);
}

/** 加锁。 */
void queue_os_mutex_lock_c(void *mu) {
    if (!mu)
        return;
#if SHUX_QUEUE_WIN
    EnterCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_lock((queue_os_mutex_t *)mu);
#endif
}

/** 解锁。 */
void queue_os_mutex_unlock_c(void *mu) {
    if (!mu)
        return;
#if SHUX_QUEUE_WIN
    LeaveCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_unlock((queue_os_mutex_t *)mu);
#endif
}

#if SHUX_QUEUE_WIN
static unsigned __stdcall queue_os_worker_trampoline(void *arg) {
    (void)queue_contention_worker_push_c(arg);
    return 0;
}
#else
static void *queue_os_worker_trampoline(void *arg) {
    (void)queue_contention_worker_push_c(arg);
    return NULL;
}
#endif

/**
 * 启动两个 worker 线程并 join；ctx 透传给 queue_contention_worker_push_c。
 * 返回值：0 成功，-1 失败。
 */
int32_t queue_os_run_two_workers_c(void *ctx) {
#if SHUX_QUEUE_WIN
    uintptr_t h0, h1;
    h0 = _beginthreadex(NULL, 0, queue_os_worker_trampoline, ctx, 0, NULL);
    h1 = _beginthreadex(NULL, 0, queue_os_worker_trampoline, ctx, 0, NULL);
    if (h0 == 0 || h1 == 0)
        return -1;
    WaitForSingleObject((HANDLE)h0, INFINITE);
    WaitForSingleObject((HANDLE)h1, INFINITE);
    CloseHandle((HANDLE)h0);
    CloseHandle((HANDLE)h1);
#else
    pthread_t t0, t1;
    if (pthread_create(&t0, NULL, queue_os_worker_trampoline, ctx) != 0)
        return -1;
    if (pthread_create(&t1, NULL, queue_os_worker_trampoline, ctx) != 0) {
        pthread_join(t0, NULL);
        return -1;
    }
    pthread_join(t0, NULL);
    pthread_join(t1, NULL);
#endif
    return 0;
}

/** STD-048：双线程并发 push 烟测；0 通过，-1 失败。 */
int32_t sync_queue_contention_smoke_c(void) {
  QueueSmokeState st;
  int32_t rc = -1;
  memset(&st, 0, sizeof(st));
  st.mu = queue_os_mutex_create_c();
  if (!st.mu) {
    return -1;
  }
  if (queue_os_run_two_workers_c(&st) != 0) {
    queue_os_mutex_destroy_c(st.mu);
    if (st.data) {
      free(st.data);
    }
    return -1;
  }
  rc = (st.len == 1000) ? 0 : -1;
  if (st.data) {
    free(st.data);
  }
  queue_os_mutex_destroy_c(st.mu);
  return rc;
}
