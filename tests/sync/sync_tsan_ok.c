/**
 * tests/sync/sync_tsan_ok.c — STD-045 TSAN 正例：RwLock 保护共享计数
 *
 * 双线程各递增 500 次；无数据竞争，TSAN 应 exit 0。
 */
#include <pthread.h>
#include <stdint.h>

extern void *sync_rwlock_new_c(void);
extern int32_t sync_rwlock_write_lock_c(void *rw);
extern int32_t sync_rwlock_write_unlock_c(void *rw);
extern void sync_rwlock_free_c(void *rw);

typedef struct {
    void *rw;
    int32_t *counter;
} ctx_t;

static void *worker(void *arg) {
    ctx_t *c = (ctx_t *)arg;
    int32_t i;
    for (i = 0; i < 500; i++) {
        sync_rwlock_write_lock_c(c->rw);
        (*c->counter)++;
        sync_rwlock_write_unlock_c(c->rw);
    }
    return NULL;
}

int main(void) {
    void *rw = sync_rwlock_new_c();
    int32_t counter = 0;
    ctx_t ctx = { rw, &counter };
    pthread_t t0, t1;
    if (rw == NULL) return 1;
    if (pthread_create(&t0, NULL, worker, &ctx) != 0) return 2;
    if (pthread_create(&t1, NULL, worker, &ctx) != 0) return 3;
    pthread_join(t0, NULL);
    pthread_join(t1, NULL);
    sync_rwlock_free_c(rw);
    return (counter == 1000) ? 0 : 4;
}
