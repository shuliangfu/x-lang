/**
 * std/task/task.c — 任务组与结构化并发（STD-089）
 *
 * 【文件职责】
 * TaskGroup / JoinSet 封装 std.async spawn + drain；Context 取消传播；
 * 结构化并发 leak 检测；Supervisor 重试；供 mod.su 与 gate 烟测。
 *
 * 【所属模块】标准库 std.task；与 std/task/mod.su 同属一模块。
 * 【依赖】std/async/scheduler.c、std/context/context.c、std/time/time.c。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum {
    TASK_OK = 0,
    TASK_ERR_NULL = -1,
    TASK_ERR_FULL = -2,
    TASK_ERR_CANCELLED = -3,
    TASK_ERR_LEAK = -4,
    TASK_ERR_INVALID = -5,
};

#define TASK_MAX 32

typedef int32_t (*task_fn_t)(void);

extern int shu_async_spawn_i32(task_fn_t fn, int32_t seed);
extern void shu_async_run_seed_reset(void);
extern void shu_async_queue_reset(void);
extern int32_t shu_async_run_drain_until_idle(void);
extern int32_t ctx_is_cancelled_c(int64_t handle);
extern void ctx_cancel_c(int64_t handle);
extern void shu_async_bind_context_c(int64_t ctx_handle);
extern void time_sleep_ns_c(int64_t ns);

typedef struct task_group {
    int32_t capacity;
    int32_t spawned;
    int32_t joined;
    int64_t ctx_handle;
    int64_t join_total;
} task_group_t;

typedef struct join_set {
    int32_t capacity;
    int32_t spawned;
    int32_t joined;
    int64_t join_total;
} join_set_t;

static task_group_t *tg_from_handle(int64_t h) {
    if (h == 0) return NULL;
    return (task_group_t *)(uintptr_t)h;
}

static join_set_t *js_from_handle(int64_t h) {
    if (h == 0) return NULL;
    return (join_set_t *)(uintptr_t)h;
}

/** 组是否已取消（绑定 Context 时沿链检测）。 */
static int32_t tg_is_cancelled(task_group_t *g) {
    if (!g || g->ctx_handle == 0) return 0;
    return ctx_is_cancelled_c(g->ctx_handle) != 0;
}

/** 烟测/demo 任务：返回 seed*10。 */
int32_t task_echo_fn_c(void) {
    extern int32_t shu_async_run_seed_valid(void);
    extern int32_t shu_async_run_seed_take_i32(void);
    int32_t seed = 0;
    if (shu_async_run_seed_valid()) seed = shu_async_run_seed_take_i32();
    return seed * 10;
}

/** 返回 demo 任务函数指针（供 .su spawn 烟测）。 */
void *task_echo_fn_ptr_c(void) {
    return (void *)(uintptr_t)task_echo_fn_c;
}

/** 创建 TaskGroup；capacity 须 1..TASK_MAX。 */
int64_t task_group_create_c(int32_t capacity) {
    task_group_t *g;
    if (capacity <= 0 || capacity > TASK_MAX) return 0;
    g = (task_group_t *)calloc(1, sizeof(task_group_t));
    if (!g) return 0;
    g->capacity = capacity;
    return (int64_t)(uintptr_t)g;
}

/** 释放 TaskGroup；未 join 且 spawned>0 时仍释放（调用方应 check_leak）。 */
void task_group_free_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    if (g) free(g);
}

/** 绑定 Context 用于取消传播。 */
void task_group_bind_context_c(int64_t handle, int64_t ctx_handle) {
    task_group_t *g = tg_from_handle(handle);
    if (!g) return;
    g->ctx_handle = ctx_handle;
}

/** 提交单任务到 async 就绪环；0 成功。 */
int32_t task_group_spawn_c(int64_t handle, task_fn_t fn, int32_t seed) {
    task_group_t *g = tg_from_handle(handle);
    if (!g || !fn) return TASK_ERR_NULL;
    if (tg_is_cancelled(g)) return TASK_ERR_CANCELLED;
    if (g->spawned >= g->capacity) return TASK_ERR_FULL;
    {
        int spawn_r = shu_async_spawn_i32(fn, seed);
        if (spawn_r != 0) {
            if (spawn_r == -2 || tg_is_cancelled(g)) return TASK_ERR_CANCELLED;
            return TASK_ERR_INVALID;
        }
    }
    g->spawned++;
    g->joined = 0;
    return TASK_OK;
}

/** 等待组内全部任务完成；返回 drain 结果之和。 */
int32_t task_group_join_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    int32_t total;
    if (!g) return TASK_ERR_NULL;
    if (tg_is_cancelled(g)) return TASK_ERR_CANCELLED;
    if (g->spawned <= 0) {
        g->joined = 1;
        g->join_total = 0;
        return TASK_OK;
    }
    if (g->ctx_handle != 0)
        shu_async_bind_context_c(g->ctx_handle);
    total = shu_async_run_drain_until_idle();
    if (total == -3)
        return TASK_ERR_CANCELLED;
    g->join_total = total;
    g->joined = 1;
    g->spawned = 0;
    return total;
}

/** 未 join 的 spawn 数。 */
int32_t task_group_pending_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    if (!g) return TASK_ERR_NULL;
    return g->spawned;
}

/** 结构化并发：未 join 且仍有 pending 时返回 TASK_ERR_LEAK。 */
int32_t task_group_check_leak_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    if (!g) return TASK_ERR_NULL;
    if (g->spawned > 0 && !g->joined) return TASK_ERR_LEAK;
    return TASK_OK;
}

/** 取消绑定 Context。 */
void task_group_cancel_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    if (!g || g->ctx_handle == 0) return;
    ctx_cancel_c(g->ctx_handle);
}

/** 读取上次 join 累计结果。 */
int64_t task_group_join_total_c(int64_t handle) {
    task_group_t *g = tg_from_handle(handle);
    if (!g) return 0;
    return g->join_total;
}

/** 创建 JoinSet。 */
int64_t join_set_create_c(int32_t capacity) {
    join_set_t *s;
    if (capacity <= 0 || capacity > TASK_MAX) return 0;
    s = (join_set_t *)calloc(1, sizeof(join_set_t));
    if (!s) return 0;
    s->capacity = capacity;
    return (int64_t)(uintptr_t)s;
}

/** 释放 JoinSet。 */
void join_set_free_c(int64_t handle) {
    join_set_t *s = js_from_handle(handle);
    if (s) free(s);
}

/** JoinSet spawn。 */
int32_t join_set_spawn_c(int64_t handle, task_fn_t fn, int32_t seed) {
    join_set_t *s = js_from_handle(handle);
    if (!s || !fn) return TASK_ERR_NULL;
    if (s->spawned >= s->capacity) return TASK_ERR_FULL;
    if (shu_async_spawn_i32(fn, seed) != 0) return TASK_ERR_INVALID;
    s->spawned++;
    s->joined = 0;
    return TASK_OK;
}

/** JoinSet 等待全部完成。 */
int32_t join_set_join_c(int64_t handle) {
    join_set_t *s = js_from_handle(handle);
    int32_t total;
    if (!s) return TASK_ERR_NULL;
    if (s->spawned <= 0) {
        s->joined = 1;
        s->join_total = 0;
        return TASK_OK;
    }
    total = shu_async_run_drain_until_idle();
    s->join_total = total;
    s->joined = 1;
    s->spawned = 0;
    return total;
}

/** JoinSet leak 检测。 */
int32_t join_set_check_leak_c(int64_t handle) {
    join_set_t *s = js_from_handle(handle);
    if (!s) return TASK_ERR_NULL;
    if (s->spawned > 0 && !s->joined) return TASK_ERR_LEAK;
    return TASK_OK;
}

/** Supervisor：失败时重试 fn(seed)；成功返回最终 drain 结果。 */
int32_t task_supervise_retry_c(task_fn_t fn, int32_t seed, int32_t max_attempts, int64_t backoff_ns) {
    int32_t attempt;
    int32_t total;
    if (!fn || max_attempts <= 0) return TASK_ERR_NULL;
    for (attempt = 0; attempt < max_attempts; attempt++) {
        shu_async_run_seed_reset();
        shu_async_queue_reset();
        if (shu_async_spawn_i32(fn, seed) != 0) return TASK_ERR_INVALID;
        total = shu_async_run_drain_until_idle();
        if (total >= 0) return total;
        if (backoff_ns > 0) time_sleep_ns_c(backoff_ns);
    }
    return TASK_ERR_INVALID;
}

/** 烟测：双任务 spawn + join + leak 检测 + supervise。 */
int32_t task_smoke_c(void) {
    int64_t grp = task_group_create_c(4);
    int64_t js = join_set_create_c(2);
    int32_t r;
    if (grp == 0 || js == 0) return 1;
    shu_async_run_seed_reset();
    shu_async_queue_reset();
    if (task_group_spawn_c(grp, task_echo_fn_c, 2) != TASK_OK) return 2;
    if (task_group_spawn_c(grp, task_echo_fn_c, 3) != TASK_OK) return 3;
    if (task_group_check_leak_c(grp) != TASK_ERR_LEAK) return 4;
    r = task_group_join_c(grp);
    if (r != 50) return 5;
    if (task_group_check_leak_c(grp) != TASK_OK) return 6;
    shu_async_run_seed_reset();
    shu_async_queue_reset();
    if (join_set_spawn_c(js, task_echo_fn_c, 4) != TASK_OK) return 7;
    r = join_set_join_c(js);
    if (r != 40) return 8;
    shu_async_run_seed_reset();
    shu_async_queue_reset();
    r = task_supervise_retry_c(task_echo_fn_c, 5, 3, 0);
    if (r != 50) return 9;
    task_group_free_c(grp);
    join_set_free_c(js);
    return 0;
}
