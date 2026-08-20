/* seeds/runtime_queue_contention.from_x.c — G-02f-21 product TU
 * R2 migration: OS-level _impl bridges + thin-rest pattern.
 * Thin wrappers (queue_os_*_c, queue_smoke_*, sync_queue_contention_smoke_c)
 * are provided by runtime_queue_contention.x when XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X
 * is defined (R2 path); otherwise this seed provides both _impl and _c wrappers.
 *
 * PLATFORM: SHARED — Windows uses CRITICAL_SECTION + _beginthreadex (stdcall);
 *           POSIX uses pthread_mutex_t + pthread_create.
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#include <process.h>
#include <windows.h>
#define XLANG_QUEUE_WIN 1
#else
#include <pthread.h>
#define XLANG_QUEUE_WIN 0
#endif

/* Smoke state matching QueueSmokeState layout in runtime_queue_contention.x. */
typedef struct {
  void *mu;
  int32_t *data;
  int32_t cap;
  int32_t length;
  int32_t head;
} QueueSmokeState;

#if XLANG_QUEUE_WIN
typedef CRITICAL_SECTION queue_os_mutex_t;
#else
typedef pthread_mutex_t queue_os_mutex_t;
#endif

/* POSIX pthread start routine: public trampoline exists in both hybrid thin
 * (runtime_queue_contention.x) and cold seed. Rest must not U the thin-only
 * queue_os_worker_trampoline_impl (mac run-queue Darwin UNDEF after L4). */
void *queue_os_worker_trampoline(void *arg);

/* Thin function forward declarations for rest-only call sites in R2 mode. */
#ifndef XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X
void *queue_os_mutex_create_c(void);
void queue_os_mutex_destroy_c(void *mu);
void queue_os_mutex_lock_c(void *mu);
void queue_os_mutex_unlock_c(void *mu);
int32_t queue_os_run_two_workers_c(void *ctx);
int32_t queue_smoke_at_impl(QueueSmokeState *q, int32_t i);
int32_t queue_smoke_push_back_impl(QueueSmokeState *q, int32_t x);
int32_t queue_contention_worker_push_c(void *ctx);
int32_t sync_queue_contention_smoke_c(void);
#endif

/* ----- OS _impl bridges (always compiled, provide _impl symbols). ----- */

/** Create mutex (pthread_mutex_init / InitializeCriticalSection). Returns opaque ptr or NULL. */
void *queue_os_mutex_create_impl(void) {
    queue_os_mutex_t *m = (queue_os_mutex_t *)malloc(sizeof(queue_os_mutex_t));
    if (!m)
        return NULL;
#if XLANG_QUEUE_WIN
    InitializeCriticalSection(m);
#else
    if (pthread_mutex_init(m, NULL) != 0) {
        free(m);
        return NULL;
    }
#endif
    return (void *)m;
}

/** Destroy mutex and free backing memory. */
void queue_os_mutex_destroy_impl(void *mu) {
    if (!mu)
        return;
#if XLANG_QUEUE_WIN
    DeleteCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_destroy((queue_os_mutex_t *)mu);
#endif
    free(mu);
}

/** Lock mutex (pthread_mutex_lock / EnterCriticalSection). */
void queue_os_mutex_lock_impl(void *mu) {
    if (!mu)
        return;
#if XLANG_QUEUE_WIN
    EnterCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_lock((queue_os_mutex_t *)mu);
#endif
}

/** Unlock mutex (pthread_mutex_unlock / LeaveCriticalSection). */
void queue_os_mutex_unlock_impl(void *mu) {
    if (!mu)
        return;
#if XLANG_QUEUE_WIN
    LeaveCriticalSection((queue_os_mutex_t *)mu);
#else
    pthread_mutex_unlock((queue_os_mutex_t *)mu);
#endif
}

/** Launch two worker threads via _beginthreadex / pthread_create, join both.
 *  Returns 0 on success, -1 on failure.
 *  On POSIX, start routine is queue_os_worker_trampoline (thin or cold).
 *  On Windows, trampoline is queue_os_worker_trampoline_win_impl (rest-provided, stdcall). */
int32_t queue_os_run_two_workers_impl(void *ctx) {
#if XLANG_QUEUE_WIN
    uintptr_t h0, h1;
    h0 = _beginthreadex(NULL, 0, queue_os_worker_trampoline_win_impl, ctx, 0, NULL);
    h1 = _beginthreadex(NULL, 0, queue_os_worker_trampoline_win_impl, ctx, 0, NULL);
    if (h0 == 0 || h1 == 0)
        return -1;
    WaitForSingleObject((HANDLE)h0, INFINITE);
    WaitForSingleObject((HANDLE)h1, INFINITE);
    CloseHandle((HANDLE)h0);
    CloseHandle((HANDLE)h1);
#else
    pthread_t t0, t1;
    if (pthread_create(&t0, NULL, (void *(*)(void *))queue_os_worker_trampoline, ctx) != 0)
        return -1;
    if (pthread_create(&t1, NULL, (void *(*)(void *))queue_os_worker_trampoline, ctx) != 0) {
        pthread_join(t0, NULL);
        return -1;
    }
    pthread_join(t0, NULL);
    pthread_join(t1, NULL);
#endif
    return 0;
}

/* ----- Thin wrappers (guarded in R2 mode: provided by runtime_queue_contention.x). ----- */

#ifndef XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X
/* Cold path: provide _c wrappers that delegate to _impl. */

void *queue_os_mutex_create_c(void) {
    return queue_os_mutex_create_impl();
}

void queue_os_mutex_destroy_c(void *mu) {
    queue_os_mutex_destroy_impl(mu);
}

void queue_os_mutex_lock_c(void *mu) {
    queue_os_mutex_lock_impl(mu);
}

void queue_os_mutex_unlock_c(void *mu) {
    queue_os_mutex_unlock_impl(mu);
}

int32_t queue_os_run_two_workers_c(void *ctx) {
    return queue_os_run_two_workers_impl(ctx);
}

#endif /* !XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X */

/* ----- Windows-only stdcall trampoline (required by _beginthreadex). ----- */

#if XLANG_QUEUE_WIN
/** Windows-only stdcall trampoline for _beginthreadex. Calls worker_push via
 *  queue_contention_worker_push_c (provided by .x thin in R2, or by this seed
 *  in cold path via forward declaration above). */
static unsigned __stdcall queue_os_worker_trampoline_win_impl(void *arg) {
    (void)queue_contention_worker_push_c(arg);
    return 0;
}
#endif

/* ----- Smoke test helpers (guarded in R2: provided by .x thin). ----- */

#ifndef XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X
/* Cold path: smoke test logic implemented in seed C. */

int32_t queue_smoke_at_impl(QueueSmokeState *q, int32_t i) {
    int32_t idx = q->head + i;
    if (idx >= q->cap) {
        idx -= q->cap;
    }
    return idx;
}

int32_t queue_smoke_at(QueueSmokeState *q, int32_t i) {
    return queue_smoke_at_impl(q, i);
}

int32_t queue_smoke_push_back_impl(QueueSmokeState *q, int32_t x) {
    int32_t new_cap;
    int32_t *p;
    int32_t i;
    if (!q) {
        return -1;
    }
    if (q->length >= q->cap) {
        if (q->cap <= 0) {
            new_cap = 8;
        } else {
            new_cap = q->cap * 2;
        }
        p = (int32_t *)malloc((size_t)new_cap * sizeof(int32_t));
        if (!p) {
            return -1;
        }
        for (i = 0; i < q->length; i++) {
            p[i] = q->data[queue_smoke_at(q, i)];
        }
        if (q->data) {
            free(q->data);
        }
        q->data = p;
        q->cap = new_cap;
        q->head = 0;
    }
    q->data[queue_smoke_at(q, q->length)] = x;
    q->length++;
    return 0;
}

int32_t queue_smoke_push_back(QueueSmokeState *q, int32_t x) {
    return queue_smoke_push_back_impl(q, x);
}

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

#if !XLANG_QUEUE_WIN
/* POSIX trampoline (cold path only: thin provides this in R2).
 * Marked static to avoid symbol collision with thin-provided
 * queue_os_worker_trampoline_impl in ld -r merge. */
static void *queue_os_worker_trampoline_impl_cold(void *arg) {
    (void)queue_contention_worker_push_c(arg);
    return NULL;
}

void *queue_os_worker_trampoline(void *arg) {
    return queue_os_worker_trampoline_impl_cold(arg);
}
#endif

/** STD-048 sync_queue_contention_smoke_c (cold path). */
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
  rc = (st.length == 1000) ? 0 : -1;
  if (st.data) {
    free(st.data);
  }
  queue_os_mutex_destroy_c(st.mu);
  return rc;
}

#endif /* !XLANG_RUNTIME_QUEUE_CONTENTION_FROM_X */
