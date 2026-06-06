/**
 * tests/bench/async_run_seed.c — run v2 seed 队列烟测（不经 codegen）
 *
 * 编译：cc -std=c11 -o async_run_seed tests/bench/async_run_seed.c std/async/scheduler.o
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern void shu_async_run_seed_reset(void);
extern void shu_async_run_seed_push_i32(int32_t v);
extern void shu_async_run_seed_push_u32(uint32_t v);
extern void shu_async_run_seed_push_i64(int64_t v);
extern void shu_async_run_seed_push_usize(size_t v);
extern void shu_async_run_seed_set_i32(int32_t v);
extern int shu_async_run_seed_valid(void);
extern int32_t shu_async_run_seed_take_i32(void);
extern uint32_t shu_async_run_seed_take_u32(void);
extern int64_t shu_async_run_seed_take_i64(void);
extern size_t shu_async_run_seed_take_usize(void);
extern void shu_async_queue_reset(void);

/**
 * 入口：reset/push/take 与 v1 set 兼容路径。
 */
int main(void) {
    shu_async_queue_reset();
    if (shu_async_run_seed_valid() != 0) {
        fprintf(stderr, "async_run_seed: valid before set\n");
        return 1;
    }
    shu_async_run_seed_set_i32(42);
    if (shu_async_run_seed_valid() != 1) {
        fprintf(stderr, "async_run_seed: valid after set\n");
        return 2;
    }
    if (shu_async_run_seed_take_i32() != 42) {
        fprintf(stderr, "async_run_seed: take mismatch\n");
        return 3;
    }
    if (shu_async_run_seed_valid() != 0) {
        fprintf(stderr, "async_run_seed: valid after take\n");
        return 4;
    }

    shu_async_run_seed_reset();
    shu_async_run_seed_push_i32(10);
    shu_async_run_seed_push_i32(32);
    if (shu_async_run_seed_valid() != 1) {
        fprintf(stderr, "async_run_seed: valid after dual push\n");
        return 5;
    }
    if (shu_async_run_seed_take_i32() != 10) {
        fprintf(stderr, "async_run_seed: take first mismatch\n");
        return 6;
    }
    if (shu_async_run_seed_valid() != 1) {
        fprintf(stderr, "async_run_seed: valid mid dual take\n");
        return 7;
    }
    if (shu_async_run_seed_take_i32() != 32) {
        fprintf(stderr, "async_run_seed: take second mismatch\n");
        return 8;
    }
    if (shu_async_run_seed_valid() != 0) {
        fprintf(stderr, "async_run_seed: valid after dual take\n");
        return 9;
    }

    shu_async_run_seed_reset();
    shu_async_run_seed_push_u32(42u);
    if (shu_async_run_seed_take_u32() != 42u) {
        fprintf(stderr, "async_run_seed: take u32 mismatch\n");
        return 11;
    }

    shu_async_run_seed_reset();
    shu_async_run_seed_push_i64(10000000000LL);
    if (shu_async_run_seed_take_i64() != 10000000000LL) {
        fprintf(stderr, "async_run_seed: take i64 mismatch\n");
        return 12;
    }

    shu_async_run_seed_reset();
    shu_async_run_seed_push_usize((size_t)0xABCDEF01u);
    if (shu_async_run_seed_take_usize() != (size_t)0xABCDEF01u) {
        fprintf(stderr, "async_run_seed: take usize mismatch\n");
        return 13;
    }

    shu_async_queue_reset();
    if (shu_async_run_seed_valid() != 0) {
        fprintf(stderr, "async_run_seed: valid after reset\n");
        return 10;
    }
    return 0;
}
