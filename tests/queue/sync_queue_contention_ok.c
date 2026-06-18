/**
 * tests/queue/sync_queue_contention_ok.c — STD-048 C 竞争烟测入口
 */
#include <stdint.h>

extern int32_t sync_queue_contention_smoke_c(void);

int main(void) {
    return sync_queue_contention_smoke_c();
}
