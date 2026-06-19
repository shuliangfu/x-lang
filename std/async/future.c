/**
 * std/async/future.c — 手动 Future/Poll 运行时（STD-041 子集）
 *
 * 【文件职责】
 * 提供最小 i32 Future：create → poll（Pending/Ready）→ complete → take。
 * 供 language async/await 落地前，业务层可手动驱动 poll 循环。
 *
 * 【所属模块】标准库 std.async；与 std/async/mod.sx 同属一模块。
 * 【链接】按需链入 future.o（gate 烟测 / import std.async 且调用 future_* 时）。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

/** 未链 scheduler.o 时 drain/poll 弱桩（future_wait 仍可编译）。 */
__attribute__((weak)) int32_t shux_async_run_drain_until_idle(void) {
    return 0;
}

__attribute__((weak)) unsigned shux_io_poll_async_completions(unsigned timeout_ms) {
    (void)timeout_ms;
    return 0;
}

/** Poll 状态：与 mod.sx POLL_* 一致。 */
enum {
    SHUX_POLL_PENDING = 0,
    SHUX_POLL_READY = 1,
};

/** Future 槽错误码。 */
enum {
    FUT_OK = 0,
    FUT_ERR_NULL = -1,
    FUT_ERR_INVALID = -2,
    FUT_ERR_PENDING = -3,
    FUT_ERR_FULL = -4,
};

#define SHUX_FUTURE_MAX 64

/** 单 Future 槽：state 0=pending，1=ready。 */
typedef struct shux_future_slot {
    int32_t state;
    int32_t value;
} shux_future_slot_t;

static shux_future_slot_t shux_futures[SHUX_FUTURE_MAX];
static int32_t shux_future_count = 0;

/** handle（1..N）→ 槽指针；非法返回 NULL。 */
static shux_future_slot_t *shux_future_slot_from_handle(int64_t handle) {
    int32_t idx;
    if (handle <= 0) return NULL;
    idx = (int32_t)(handle - 1);
    if (idx < 0 || idx >= shux_future_count) return NULL;
    return &shux_futures[idx];
}

/**
 * 创建 pending Future；返回 opaque handle（≥1），池满返回 0。
 */
int64_t shux_async_future_create_c(void) {
    shux_future_slot_t *s;
    if (shux_future_count >= SHUX_FUTURE_MAX) return 0;
    s = &shux_futures[shux_future_count];
    s->state = SHUX_POLL_PENDING;
    s->value = 0;
    shux_future_count++;
    return (int64_t)shux_future_count;
}

/**
 * 轮询 Future：SHUX_POLL_PENDING / SHUX_POLL_READY；非法 handle 返回 -1。
 */
int32_t shux_async_future_poll_c(int64_t handle) {
    shux_future_slot_t *s = shux_future_slot_from_handle(handle);
    if (!s) return FUT_ERR_INVALID;
    if (s->state == SHUX_POLL_READY) return SHUX_POLL_READY;
    return SHUX_POLL_PENDING;
}

/**
 * 完成 Future 并写入 i32 结果；重复 complete 覆盖 value 并保持 Ready。
 */
void shux_async_future_complete_c(int64_t handle, int32_t value) {
    shux_future_slot_t *s = shux_future_slot_from_handle(handle);
    if (!s) return;
    s->value = value;
    s->state = SHUX_POLL_READY;
}

/**
 * Ready 时取出 value 并重置为 Pending；Pending 返回 FUT_ERR_PENDING。
 */
int32_t shux_async_future_take_c(int64_t handle, int32_t *out) {
    shux_future_slot_t *s = shux_future_slot_from_handle(handle);
    if (!out) return FUT_ERR_NULL;
    if (!s) return FUT_ERR_INVALID;
    if (s->state != SHUX_POLL_READY) return FUT_ERR_PENDING;
    *out = s->value;
    s->state = SHUX_POLL_PENDING;
    s->value = 0;
    return FUT_OK;
}

/** 重置 Future 池（单进程烟测/二次 poll 用）。 */
void shux_async_future_reset_c(void) {
    shux_future_count = 0;
    memset(shux_futures, 0, sizeof(shux_futures));
}

/**
 * 带 scheduler drain 的 Future 等待：每轮 poll → IO poll → drain_until_idle。
 * 返回 SHUX_POLL_READY / SHUX_POLL_PENDING；非法 handle 返回 -1。
 */
int32_t shux_async_future_wait_c(int64_t handle, int32_t max_rounds) {
    int32_t round = 0;
    int32_t pr;
    if (max_rounds < 0) {
        max_rounds = 0;
    }
    while (round < max_rounds) {
        pr = shux_async_future_poll_c(handle);
        if (pr == SHUX_POLL_READY) {
            return SHUX_POLL_READY;
        }
        if (pr < 0) {
            return pr;
        }
        shux_io_poll_async_completions(0);
        shux_async_run_drain_until_idle();
        round++;
    }
    return shux_async_future_poll_c(handle);
}

/** C 烟测：create → poll pending → complete → poll ready → take。 */
int32_t shux_async_future_smoke_c(void) {
    int64_t h;
    int32_t v = 0;
    int32_t pr;
    shux_async_future_reset_c();
    h = shux_async_future_create_c();
    if (h == 0) return 1;
    pr = shux_async_future_poll_c(h);
    if (pr != SHUX_POLL_PENDING) return 2;
    shux_async_future_complete_c(h, 42);
    pr = shux_async_future_poll_c(h);
    if (pr != SHUX_POLL_READY) return 3;
    if (shux_async_future_take_c(h, &v) != FUT_OK || v != 42) return 4;
    pr = shux_async_future_poll_c(h);
    if (pr != SHUX_POLL_PENDING) return 5;
    if (shux_async_future_wait_c(h, 0) != SHUX_POLL_PENDING) return 6;
    shux_async_future_complete_c(h, 55);
    if (shux_async_future_wait_c(h, 4) != SHUX_POLL_READY) return 7;
    if (shux_async_future_take_c(h, &v) != FUT_OK || v != 55) return 8;
    shux_async_future_reset_c();
    return 0;
}
