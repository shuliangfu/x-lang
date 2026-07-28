/* seeds/runtime_queue_contention_surface.from_x.c
 * G-02f-21 runtime_queue_contention R2 mixed (thin+rest + DIRECT) surface — isomorphic with src/asm/runtime_queue_contention.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + ld -r with rest (seeds/runtime_queue_contention.from_x.c)
 * Prove: full.x vs this surface → nm IDENTICAL (13 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed — 5 thin+rest forwards (queue_os_*_c → _impl extern C bridges) +
 *   8 DIRECT (queue_smoke_at_impl/at + push_back_impl/push_back + worker_push_c +
 *   trampoline_impl/trampoline + sync_queue_contention_smoke_c)
 * Cap residual: 5 _impl — queue_os_mutex_create/destroy/lock/unlock/run_two_workers_impl
 *   (POSIX pthread_mutex_t + pthread_create / Windows CRITICAL_SECTION + _beginthreadex)
 * Note: doc_anchor runtime_queue_contention_x_doc_anchor (no ast_; queue_ prefix doesn't trigger).
 * Struct: QueueSmokeState { mu, data, cap, length, head } — 5 fields, matches .x allow(padding) struct.
 * Logic: 13 functions = 5 thin+rest + 8 DIRECT (circular buffer queue + dual-thread smoke test).
 * Regen: ./xlang-c -E ... runtime_queue_contention.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void *malloc(size_t size);
extern void free(void *ptr);

extern void *queue_os_mutex_create_impl(void);
extern void queue_os_mutex_destroy_impl(void *mu);
extern void queue_os_mutex_lock_impl(void *mu);
extern void queue_os_mutex_unlock_impl(void *mu);
extern int32_t queue_os_run_two_workers_impl(void *ctx);

typedef struct {
  void *mu;
  int32_t *data;
  int32_t cap;
  int32_t length;
  int32_t head;
} QueueSmokeState;

int32_t runtime_queue_contention_x_doc_anchor(void) {
  return 0;
}

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

int32_t queue_smoke_at_impl(QueueSmokeState *q, int32_t i) {
  int32_t idx = q->head + i;
  if (idx >= q->cap) {
    idx = idx - q->cap;
  }
  return idx;
}

int32_t queue_smoke_at(QueueSmokeState *q, int32_t i) {
  return queue_smoke_at_impl(q, i);
}

int32_t queue_smoke_push_back_impl(QueueSmokeState *q, int32_t x) {
  if (q == 0) {
    return -1;
  }
  if (q->length >= q->cap) {
    int32_t new_cap = 8;
    if (q->cap > 0) {
      new_cap = q->cap * 2;
    }
    int32_t *p = 0;
    p = (int32_t *)malloc((size_t)new_cap * 4);
    if (p == 0) {
      return -1;
    }
    int32_t i = 0;
    while (i < q->length) {
      p[i] = q->data[queue_smoke_at(q, i)];
      i = i + 1;
    }
    if (q->data != 0) {
      free(q->data);
    }
    q->data = p;
    q->cap = new_cap;
    q->head = 0;
  }
  q->data[queue_smoke_at(q, q->length)] = x;
  q->length = q->length + 1;
  return 0;
}

int32_t queue_smoke_push_back(QueueSmokeState *q, int32_t x) {
  return queue_smoke_push_back_impl(q, x);
}

int32_t queue_contention_worker_push_c(void *ctx) {
  QueueSmokeState *q = (QueueSmokeState *)ctx;
  if (q == 0) {
    return -1;
  }
  int32_t i = 0;
  while (i < 500) {
    queue_os_mutex_lock_c(q->mu);
    queue_smoke_push_back(q, 1);
    queue_os_mutex_unlock_c(q->mu);
    i = i + 1;
  }
  return 0;
}

void *queue_os_worker_trampoline_impl(void *arg) {
  queue_contention_worker_push_c(arg);
  return 0;
}

void *queue_os_worker_trampoline(void *arg) {
  return queue_os_worker_trampoline_impl(arg);
}

int32_t sync_queue_contention_smoke_c(void) {
  QueueSmokeState st;
  st.mu = 0;
  st.data = 0;
  st.cap = 0;
  st.length = 0;
  st.head = 0;
  int32_t rc = -1;
  st.mu = queue_os_mutex_create_c();
  if (st.mu == 0) {
    return -1;
  }
  int32_t workers_rc = queue_os_run_two_workers_c((void *)&st);
  if (workers_rc != 0) {
    queue_os_mutex_destroy_c(st.mu);
    if (st.data != 0) {
      free(st.data);
    }
    return -1;
  }
  if (st.length == 1000) {
    rc = 0;
  }
  if (st.data != 0) {
    free(st.data);
  }
  queue_os_mutex_destroy_c(st.mu);
  return rc;
}
