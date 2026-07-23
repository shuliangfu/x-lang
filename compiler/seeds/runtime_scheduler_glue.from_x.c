/* seeds/runtime_scheduler_glue.from_x.c — G-02f-18 product TU
 * G-02f-117 true .x pure helpers.
 * G-02f-116 true .x pure helpers.
 * G-02f-115 true .x pure helpers.
 * G-02f-108 helper gates.
 * G-02f-107 helper gates.
 * G-02f-106 helper gates.
 * Product: runtime_scheduler_glue.o; logic still C until full .x port.
 * wave230 G.7: all product env lookup → link_abi_getenv (not raw getenv);
 * host residual only link_abi_getenv_impl. Cold pure twins + mega residual same commit.
 */
/**
 * runtime_scheduler_glue.c — F-ZC：自 std/async/scheduler_glue.c 迁入 — A1/A2 协作调度胶层（F-async v1）
 *
 * 【文件职责】协作帧、computed-goto dispatch、MPSC 环、CPS suspend、IO 等待队列；
 * 经 ld -r 与 scheduler.x 合并为 scheduler.o；末尾 #include async_net_fs.from_x.c。
 * 【链接】-pthread（MPSC 烟测）；按需链入；环境变量见原 scheduler.c 注释。
 */
#include <xlang_weak.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdatomic.h>
#include <time.h>

/* wave230 G.7: public pure thin link_abi_getenv (wave222 → _impl host getenv).
 * PLATFORM: SHARED — scheduler env gates share single host getenv residual. */
extern char *link_abi_getenv(const char *name);

#if defined(__GNUC__) || defined(__clang__)
/**
 * 可选绑核：未链 std/thread 时用 weak 桩；链 thread.o 时强符号覆盖。
 */
XLANG_WEAK int32_t thread_set_affinity_self_c(int32_t cpu_index) {
    (void)cpu_index;
    return -1;
}
/** IO-A5 v3：未链 io.o 时 poll 桩（run_i32 回退 wake_all）。 */
XLANG_WEAK unsigned xlang_io_poll_async_completions(unsigned timeout_ms) {
    (void)timeout_ms;
    return 0;
}
/** STD-090：未链 context.o 时取消检测桩（始终未取消）。 */
XLANG_WEAK int32_t ctx_is_cancelled_c(int64_t handle) {
    (void)handle;
    return 0;
}
XLANG_WEAK int64_t ctx_background_c(void) {
    return 0;
}
XLANG_WEAK int64_t ctx_with_cancel_c(int64_t parent) {
    (void)parent;
    return 0;
}
XLANG_WEAK void ctx_cancel_c(int64_t handle) {
    (void)handle;
}
XLANG_WEAK void ctx_free_c(int64_t handle) {
    (void)handle;
}
#endif

/** OBS-002：async/runtime trace 采样（XLANG_ASYNC_RUNTIME_TRACE=1 启用；默认零开销）。 */
#define XLANG_ASYNC_TRACE_RING_CAP 64
#define XLANG_ASYNC_TRACE_PREFIX "xlang: [XLANG_ASYNC_RUNTIME_TRACE]"

/** v1 事件 kind 字符串（manifest event_kind 锚点）。 */
static const char xlang_async_trace_kind_task_run[] = "task_run";
static const char xlang_async_trace_kind_suspend[] = "suspend";
static const char xlang_async_trace_kind_io_wake[] = "io_wake";
static const char xlang_async_trace_kind_poll[] = "poll_completions";
static const char xlang_async_trace_kind_idle[] = "drain_idle";

typedef struct {
    const char *kind;
    uint32_t worker;
    uint32_t extra;
    uint64_t us;
    void *fn;
} xlang_async_trace_event_t;

static xlang_async_trace_event_t xlang_async_trace_ring[XLANG_ASYNC_TRACE_RING_CAP];
static unsigned xlang_async_trace_ring_n;
static unsigned xlang_async_trace_events_total;
static unsigned xlang_async_trace_sample_tick;

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
int xlang_async_runtime_trace_enabled(void);
unsigned xlang_async_trace_topn(void);
unsigned xlang_async_trace_sample_rate(void);
uint64_t xlang_async_trace_slow_us(void);
uint64_t xlang_async_trace_now_us(void);
void xlang_async_init_workers(void);
int xlang_async_bound_ctx_cancelled(void);
int xlang_async_take_suspend_io_flag(void);
int xlang_async_io_wait_enabled(void);
int xlang_async_affinity_enabled(void);
void xlang_async_maybe_bind_worker(uint32_t worker_id);
int32_t xlang_async_spawn_ctx_echo_task(void);
uint32_t xlang_async_q_occupancy(uint32_t head, uint32_t tail);

/** 是否启用 trace（XLANG_ASYNC_RUNTIME_TRACE 非空且非 0）。 */
/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin（src/asm/runtime_scheduler_glue.x）直接实现 */
int xlang_async_runtime_trace_enabled(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE");
  return e && e[0] && !(e[0] == '0' && e[1] == '\0');
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** 解析 XLANG_ASYNC_RUNTIME_TRACE_TOPN（1..64，默认 20）。 */
/* G-02f-117：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
unsigned xlang_async_trace_topn(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_TOPN");
  long v = (e && e[0]) ? strtol(e, NULL, 10) : 20;
  if (v < 1)
    v = 1;
  if (v > 64)
    v = 64;
  return (unsigned)v;
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** 解析 XLANG_ASYNC_RUNTIME_TRACE_SAMPLE（默认 1 = 每条）。 */
/* G-02f-117：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
unsigned xlang_async_trace_sample_rate(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_SAMPLE");
  long v = (e && e[0]) ? strtol(e, NULL, 10) : 1;
  if (v < 1)
    v = 1;
  return (unsigned)v;
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** 解析 XLANG_ASYNC_RUNTIME_TRACE_SLOW_US（默认 500）。 */
/* G-02f-117：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
uint64_t xlang_async_trace_slow_us(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_RUNTIME_TRACE_SLOW_US");
  long v = (e && e[0]) ? strtol(e, NULL, 10) : 500;
  if (v < 0)
    v = 0;
  return (uint64_t)v;
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** 单调时钟微秒（trace 耗时）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
uint64_t xlang_async_trace_now_us_impl(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0)
        return 0;
    return (uint64_t)ts.tv_sec * 1000000ull + (uint64_t)ts.tv_nsec / 1000ull;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
uint64_t xlang_async_trace_now_us(void) { return xlang_async_trace_now_us_impl(); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/**
 * 记录一条 trace 事件（采样 + 慢路径必录；ring 满时丢弃最慢旧项）。
 * kind 须为 "task_run" / "suspend" / "io_wake" / "poll_completions" / "drain_idle"。
 */
void xlang_async_trace_push(const char *kind, uint32_t worker, uint32_t extra, uint64_t us, void *fn) {
    unsigned i;
    unsigned min_i = 0;
    uint64_t min_us;
    if (!xlang_async_runtime_trace_enabled() || !kind)
        return;
    xlang_async_trace_events_total++;
    if (us < xlang_async_trace_slow_us()) {
        xlang_async_trace_sample_tick++;
        if (xlang_async_trace_sample_tick % xlang_async_trace_sample_rate() != 0)
            return;
    }
    if (xlang_async_trace_ring_n < XLANG_ASYNC_TRACE_RING_CAP) {
        xlang_async_trace_event_t *ev = &xlang_async_trace_ring[xlang_async_trace_ring_n++];
        ev->kind = kind;
        ev->worker = worker;
        ev->extra = extra;
        ev->us = us;
        ev->fn = fn;
        return;
    }
    min_us = xlang_async_trace_ring[0].us;
    for (i = 1; i < XLANG_ASYNC_TRACE_RING_CAP; i++) {
        if (xlang_async_trace_ring[i].us < min_us) {
            min_us = xlang_async_trace_ring[i].us;
            min_i = i;
        }
    }
    if (us <= min_us)
        return;
    xlang_async_trace_ring[min_i].kind = kind;
    xlang_async_trace_ring[min_i].worker = worker;
    xlang_async_trace_ring[min_i].extra = extra;
    xlang_async_trace_ring[min_i].us = us;
    xlang_async_trace_ring[min_i].fn = fn;
}

/** flush：stderr 输出 summary + Top-N 慢事件（按 us 降序）。 */
void xlang_async_runtime_trace_flush(void) {
    unsigned n;
    unsigned topn;
    unsigned i;
    unsigned j;
    xlang_async_trace_event_t tmp;
    if (!xlang_async_runtime_trace_enabled())
        return;
    n = xlang_async_trace_ring_n;
    topn = xlang_async_trace_topn();
    if (topn > n)
        topn = n;
    /* 简单降序排序（n ≤ 64）。 */
    for (i = 0; i + 1 < n; i++) {
        for (j = i + 1; j < n; j++) {
            if (xlang_async_trace_ring[j].us > xlang_async_trace_ring[i].us) {
                tmp = xlang_async_trace_ring[i];
                xlang_async_trace_ring[i] = xlang_async_trace_ring[j];
                xlang_async_trace_ring[j] = tmp;
            }
        }
    }
    fprintf(stderr, "%s summary events=%u slow_top=%u\n",
            XLANG_ASYNC_TRACE_PREFIX, xlang_async_trace_events_total, topn);
    for (i = 0; i < topn; i++) {
        fprintf(stderr, "%s rank=%u kind=%s worker=%u us=%llu extra=%u fn=%p\n",
                XLANG_ASYNC_TRACE_PREFIX, i + 1, xlang_async_trace_ring[i].kind,
                (unsigned)xlang_async_trace_ring[i].worker,
                (unsigned long long)xlang_async_trace_ring[i].us,
                (unsigned)xlang_async_trace_ring[i].extra, xlang_async_trace_ring[i].fn);
    }
    xlang_async_trace_ring_n = 0;
    xlang_async_trace_events_total = 0;
    xlang_async_trace_sample_tick = 0;
}

/** 就绪队列容量（2 的幂便于取模；保留 1 空槽区分满/空）。 */
#define XLANG_ASYNC_TASK_Q_CAP 64

/** per-worker 就绪环数量上限（A4 v2）。 */
#define XLANG_ASYNC_MAX_WORKERS 8

/** IO 等待队列容量（v0 单 worker；completion 唤醒后 re-queue 就绪环）。 */
#define XLANG_ASYNC_IO_WAIT_CAP 64

/** async 任务入口：返回 XLANG_ASYNC_SUSPENDED 表示 yield，其它值为完成结果。 */
typedef int32_t (*xlang_async_task_fn_t)(void);

/**
 * A4：MPSC 就绪 ring（head/tail atomic + align(64)；每 worker 单 consumer drain）。
 */
typedef struct {
    atomic_uint_fast32_t head __attribute__((aligned(64)));
    atomic_uint_fast32_t tail __attribute__((aligned(64)));
    xlang_async_task_fn_t slots[XLANG_ASYNC_TASK_Q_CAP] __attribute__((aligned(64)));
} xlang_async_task_queue_t;

/* thin+rest Group B：依赖 xlang_async_task_fn_t / xlang_async_task_queue_t 的 thin 前向声明 */
int xlang_async_io_wait_push(xlang_async_task_fn_t fn);
int32_t xlang_async_drain_queue(xlang_async_task_queue_t *q, uint32_t worker_id, int32_t *acc);

/** per-worker 就绪环（XLANG_ASYNC_WORKERS>1 时多 consumer 各 drain 一环）。 */
static xlang_async_task_queue_t xlang_async_worker_q[XLANG_ASYNC_MAX_WORKERS];

/** 默认 submit 轮询选 worker；suspend re-queue 用 TLS 当前 worker。 */
static atomic_uint_fast32_t xlang_async_submit_rr;
static uint32_t xlang_async_n_workers = 1;
static int xlang_async_workers_inited;

/** drain 路径标记当前 worker，suspend 任务 re-queue 回同一环。 */
static _Thread_local uint32_t xlang_async_tls_worker;

/** 解析 XLANG_ASYNC_WORKERS（1..XLANG_ASYNC_MAX_WORKERS，默认 1）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void xlang_async_init_workers_impl(void) {
    const char *e;
    long v;
    if (xlang_async_workers_inited)
        return;
    xlang_async_workers_inited = 1;
    xlang_async_n_workers = 1;
    e = link_abi_getenv("XLANG_ASYNC_WORKERS");
    if (!e || !e[0])
        return;
    v = strtol(e, NULL, 10);
    if (v >= 1 && v <= XLANG_ASYNC_MAX_WORKERS)
        xlang_async_n_workers = (uint32_t)v;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
void xlang_async_init_workers(void) { xlang_async_init_workers_impl(); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/** 返回配置的 worker 数（lazy init）。 */
uint32_t xlang_async_worker_count(void) {
    xlang_async_init_workers();
    return xlang_async_n_workers;
}

/** A4：就绪环入队（前向声明，供 IO-A5 wake 路径调用）。 */
int xlang_async_task_submit(xlang_async_task_fn_t fn);
int xlang_async_task_submit_to(uint32_t worker_id, xlang_async_task_fn_t fn);

/** IO 等待队列（XLANG_ASYNC_IO_WAIT=1 时 suspend 任务暂存于此）。 */
static xlang_async_task_fn_t xlang_async_io_wait[XLANG_ASYNC_IO_WAIT_CAP];
static uint32_t xlang_async_io_wait_n;

/** XLANG_ASYNC_IO_WAIT=1 时 suspend 任务进入 IO 等待队列而非就绪环。 */
/* G-02f-117：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
int xlang_async_io_wait_enabled(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_IO_WAIT");
  return e && e[0] == '1' && e[1] == '\0';
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** IO-A5：最近一次 suspend 来自 await IO（由 xlang_async_cps_suspend_io 置位，drain 消费）。 */
static int xlang_async_suspend_io_flag;

/** run v4：实参 seed 队列（i32/u32/i64/usize；内部 int64 存储）。 */
#define XLANG_ASYNC_RUN_SEED_MAX 8
static int xlang_async_run_seed_on;
static int xlang_async_run_seed_n;
static int xlang_async_run_seed_take_i;
static int64_t xlang_async_run_seed_vals[XLANG_ASYNC_RUN_SEED_MAX];

/** 清空 run seed 队列（run 表达式 emit 在 push 前调用）。 */
void xlang_async_run_seed_reset(void) {
    xlang_async_run_seed_on = 0;
    xlang_async_run_seed_n = 0;
    xlang_async_run_seed_take_i = 0;
}

/** 追加 int64 seed（内部）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void xlang_async_run_seed_push_i64(int64_t v) {
    if (xlang_async_run_seed_n >= XLANG_ASYNC_RUN_SEED_MAX)
        return;
    xlang_async_run_seed_vals[xlang_async_run_seed_n++] = v;
    xlang_async_run_seed_on = 1;
}


/** 追加 i32 实参到 seed 队列。 */
void xlang_async_run_seed_push_i32(int32_t v) {
    xlang_async_run_seed_push_i64((int64_t)v);
}

/** 追加 u32 实参到 seed 队列。 */
void xlang_async_run_seed_push_u32(uint32_t v) {
    xlang_async_run_seed_push_i64((int64_t)(uint64_t)v);
}

/** 追加 i64 实参到 seed 队列。 */


/** 追加 usize 实参到 seed 队列（IO handle / fd 等；内部按 uint64 存储）。 */
void xlang_async_run_seed_push_usize(size_t v) {
    xlang_async_run_seed_push_i64((int64_t)(uint64_t)v);
}

/**
 * IO-A5 v5：push 单 i32 seed 并 submit 协程体（spawn 语义；不 reset 队列/seed 队列外状态）。
 * 返回 xlang_async_task_submit 结果：0 成功，-1 失败。
 */
/** spawn 时 Context 已取消（与 std.context CTX_CANCELLED 对齐）。 */
#define XLANG_ASYNC_ERR_CTX_SUBMIT_ABORT ((int32_t)-2)
/** drain 检测到 Context 已取消（task_group_join 识别 -3）。 */
#define XLANG_ASYNC_ERR_CTX_ABORT ((int32_t)-3)

/** 绑定 Context 栈深度上限（嵌套 bind/unbind）。 */
#define XLANG_ASYNC_CTX_SLOTS 8

/** 当前异步运行时绑定的 Context 句柄栈（无 malloc；STD-090/093）。 */
static int64_t ctx_slots[XLANG_ASYNC_CTX_SLOTS];
static int ctx_slots_depth;

/** 烟测：spawn 任务期望继承的 Context 句柄（仅 xlang_async_spawn_ctx_smoke_c 使用）。 */
static int64_t xlang_async_spawn_ctx_expected;

/** std.context：沿链检测取消（链 context.o 时强符号覆盖 weak 桩）。 */
extern int32_t ctx_is_cancelled_c(int64_t handle);

/** 检测栈顶绑定 Context 是否已取消；无绑定返回 0。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int xlang_async_bound_ctx_cancelled_impl(void) {
    int64_t h;
    if (ctx_slots_depth <= 0)
        return 0;
    h = ctx_slots[ctx_slots_depth - 1];
    if (h == 0)
        return 0;
    return ctx_is_cancelled_c(h) != 0;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int xlang_async_bound_ctx_cancelled(void) { return xlang_async_bound_ctx_cancelled_impl(); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/** 绑定 Context 供后续 spawn/drain 取消传播（STD-090）。 */
void xlang_async_bind_context_c(int64_t ctx_handle) {
    if (ctx_slots_depth >= XLANG_ASYNC_CTX_SLOTS)
        return;
    ctx_slots[ctx_slots_depth++] = ctx_handle;
}

/** 弹出最近一次 bind（STD-090）。 */
void xlang_async_unbind_context_c(void) {
    if (ctx_slots_depth > 0)
        ctx_slots_depth--;
}

/** 返回栈顶绑定的 Context 句柄；未绑定返回 0。 */
int64_t xlang_async_current_context_c(void) {
    if (ctx_slots_depth <= 0)
        return 0;
    return ctx_slots[ctx_slots_depth - 1];
}

int xlang_async_spawn_i32(int32_t (*fn)(void), int32_t seed) {
    if (!fn)
        return -1;
    if (xlang_async_bound_ctx_cancelled())
        return XLANG_ASYNC_ERR_CTX_SUBMIT_ABORT;
    xlang_async_run_seed_push_i32(seed);
    return xlang_async_task_submit(fn);
}

/** 取出并清除 IO await suspend 标记；drain 见 SUSPENDED 时用于选 IO 等待队列。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int xlang_async_take_suspend_io_flag_impl(void) {
    int v = xlang_async_suspend_io_flag;
    xlang_async_suspend_io_flag = 0;
    return v;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int xlang_async_take_suspend_io_flag(void) { return xlang_async_take_suspend_io_flag_impl(); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/** 将任务放入 IO 等待队列；返回 0 成功。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int xlang_async_io_wait_push_impl(xlang_async_task_fn_t fn) {
    if (!fn || xlang_async_io_wait_n >= XLANG_ASYNC_IO_WAIT_CAP)
        return -1;
    xlang_async_io_wait[xlang_async_io_wait_n++] = fn;
    return 0;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int xlang_async_io_wait_push(xlang_async_task_fn_t fn) { return xlang_async_io_wait_push_impl(fn); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/** 队列占用（tail - head；计数器可绕回 uint32）。 */
/* G-02f-115：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
uint32_t xlang_async_q_occupancy(uint32_t head, uint32_t tail) {
  return tail - head;
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** 协作任务帧：phase 为状态机下标，ops 为步进计数。 */
typedef struct {
    int32_t phase;
    int64_t ops;
} xlang_coop_frame_t;

/* thin+rest Group C：依赖 xlang_coop_frame_t 的 thin 前向声明 */
int xlang_coop_frame_step_jmp(xlang_coop_frame_t *f);
int xlang_coop_frame_step_switch(xlang_coop_frame_t *f);

/**
 * 单任务一步（computed goto 跳转表）：phase 0↔1 交替并 ops++。
 * 返回 0=可继续，1=结束（本 bench 永不返回 1）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int xlang_coop_frame_step_jmp_impl(xlang_coop_frame_t *f) {
    if (!f)
        return 1;
#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
    static const void *const dispatch[3] = { &&coop_s0, &&coop_s1, &&coop_done };
    if (f->phase < 0 || f->phase > 1)
        f->phase = 0;
    goto *dispatch[f->phase];
coop_s0:
    f->ops++;
    f->phase = 1;
    return 0;
coop_s1:
    f->ops++;
    f->phase = 0;
    return 0;
coop_done:
    return 1;
#else
    switch (f->phase) {
    case 0:
        f->ops++;
        f->phase = 1;
        return 0;
    case 1:
        f->ops++;
        f->phase = 0;
        return 0;
    default:
        f->phase = 0;
        f->ops++;
        return 0;
    }
#endif
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int xlang_coop_frame_step_jmp(xlang_coop_frame_t *f) { return xlang_coop_frame_step_jmp_impl(f); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/**
 * A1/A2：双任务 computed-goto ping-pong，共 rounds 轮（每轮 ping+pong 各一步）。
 * 返回总 ops（应为 2*rounds）。
 */
int64_t xlang_async_coop_pingpong_jmp(int64_t rounds) {
    xlang_coop_frame_t ping = {0, 0};
    xlang_coop_frame_t pong = {0, 0};
    int64_t i;
    if (rounds <= 0)
        return 0;
    for (i = 0; i < rounds; i++) {
        (void)xlang_coop_frame_step_jmp(&ping);
        (void)xlang_coop_frame_step_jmp(&pong);
    }
    return ping.ops + pong.ops;
}

/** A1：switch 版单帧步进（对照 jmp 路径开销）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int xlang_coop_frame_step_switch_impl(xlang_coop_frame_t *f) {
    if (!f)
        return 1;
    switch (f->phase) {
    case 0:
        f->ops++;
        f->phase = 1;
        return 0;
    case 1:
        f->ops++;
        f->phase = 0;
        return 0;
    default:
        f->phase = 0;
        f->ops++;
        return 0;
    }
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int xlang_coop_frame_step_switch(xlang_coop_frame_t *f) { return xlang_coop_frame_step_switch_impl(f); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/**
 * A1：双任务 switch dispatch ping-pong（与 jmp 版同语义，便于 A/B）。
 */
int64_t xlang_async_coop_pingpong(int64_t rounds) {
    xlang_coop_frame_t ping = {0, 0};
    xlang_coop_frame_t pong = {0, 0};
    int64_t i;
    if (rounds <= 0)
        return 0;
    for (i = 0; i < rounds; i++) {
        (void)xlang_coop_frame_step_switch(&ping);
        (void)xlang_coop_frame_step_switch(&pong);
    }
    return ping.ops + pong.ops;
}

/** async 函数 suspend 哨兵返回值（与正常 i32 结果区分）。 */
#define XLANG_ASYNC_SUSPENDED ((int32_t)0x41535700)

/**
 * A3：CPS await 边界 suspend；XLANG_ASYNC_YIELD=1 时 yield，否则 sync fallthrough。
 * 参数 phase 指向协程帧 __phase；next_phase 为下一段 phase 值。
 * 返回值：1 须 return XLANG_ASYNC_SUSPENDED；0 同栈 fallthrough。
 */
int xlang_async_cps_suspend(int32_t *phase, int32_t next_phase) {
    const char *yield_env;
    if (phase)
        *phase = next_phase;
    yield_env = link_abi_getenv("XLANG_ASYNC_YIELD");
    if (yield_env && yield_env[0] == '1' && yield_env[1] == '\0')
        return 1;
    return 0;
}

/**
 * IO-A5：await IO 边界 suspend；yield 时 drain 将任务放入 IO 等待队列（无需 XLANG_ASYNC_IO_WAIT）。
 * v0：IO 调用仍为同步 blocking emit，非阻塞 submit 待后续。
 */
int xlang_async_cps_suspend_io(int32_t *phase, int32_t next_phase) {
    const char *yield_env;
    if (phase)
        *phase = next_phase;
    xlang_async_suspend_io_flag = 1;
    yield_env = link_abi_getenv("XLANG_ASYNC_YIELD");
    if (yield_env && yield_env[0] == '1' && yield_env[1] == '\0')
        return 1;
    xlang_async_suspend_io_flag = 0;
    return 0;
}

/**
 * A4：清空就绪队列与 IO 等待队列；clear_seed=0 时保留 run seed（run_i32 路径）。
 */
static void xlang_async_queue_reset_impl(int clear_seed) {
    uint32_t n = xlang_async_worker_count();
    for (uint32_t w = 0; w < n; w++) {
        atomic_store_explicit(&xlang_async_worker_q[w].head, 0, memory_order_release);
        atomic_store_explicit(&xlang_async_worker_q[w].tail, 0, memory_order_release);
    }
    xlang_async_io_wait_n = 0;
    if (clear_seed)
        xlang_async_run_seed_reset();
}

/**
 * A4：清空就绪队列（drain 完成后可选调用，便于同进程二次 run）。
 */
void xlang_async_queue_reset(void) {
    xlang_async_queue_reset_impl(1);
}

/** 设置 run 单实参 seed（v1 兼容：等价 reset + push）。 */
void xlang_async_run_seed_set_i32(int32_t v) {
    xlang_async_run_seed_reset();
    xlang_async_run_seed_push_i32(v);
}

/** phase==0 首次进入 async 时是否还有待注入的 seed。 */
int xlang_async_run_seed_valid(void) {
    return xlang_async_run_seed_on && xlang_async_run_seed_take_i < xlang_async_run_seed_n;
}

/** 按 FIFO 取出一个 i64 seed。 */
int64_t xlang_async_run_seed_take_i64(void) {
    if (xlang_async_run_seed_take_i >= xlang_async_run_seed_n)
        return 0;
    int64_t v = xlang_async_run_seed_vals[xlang_async_run_seed_take_i++];
    if (xlang_async_run_seed_take_i >= xlang_async_run_seed_n)
        xlang_async_run_seed_on = 0;
    return v;
}

/** 按 FIFO 取出一个 i32 seed。 */
int32_t xlang_async_run_seed_take_i32(void) {
    return (int32_t)xlang_async_run_seed_take_i64();
}

/** 按 FIFO 取出一个 u32 seed。 */
uint32_t xlang_async_run_seed_take_u32(void) {
    return (uint32_t)xlang_async_run_seed_take_i64();
}

/** 按 FIFO 取出一个 usize seed（IO handle / fd 等）。 */
size_t xlang_async_run_seed_take_usize(void) {
    return (size_t)(uint64_t)xlang_async_run_seed_take_i64();
}

/**
 * A4：返回就绪队列中待执行任务数（烟测/观测用）。
 */
uint32_t xlang_async_scheduler_pending(void) {
    uint32_t n = xlang_async_worker_count();
    uint32_t sum = 0;
    for (uint32_t w = 0; w < n; w++) {
        uint32_t h = atomic_load_explicit(&xlang_async_worker_q[w].head, memory_order_acquire);
        uint32_t t = atomic_load_explicit(&xlang_async_worker_q[w].tail, memory_order_acquire);
        sum += xlang_async_q_occupancy(h, t);
    }
    return sum;
}

/** A4 v2：指定 worker 就绪环待执行任务数。 */
uint32_t xlang_async_worker_pending(uint32_t worker_id) {
    uint32_t h;
    uint32_t t;
    if (worker_id >= xlang_async_worker_count())
        return 0;
    h = atomic_load_explicit(&xlang_async_worker_q[worker_id].head, memory_order_acquire);
    t = atomic_load_explicit(&xlang_async_worker_q[worker_id].tail, memory_order_acquire);
    return xlang_async_q_occupancy(h, t);
}

/** IO-A5：IO 等待队列中任务数（烟测/观测用）。 */
uint32_t xlang_async_io_waiters_pending(void) {
    return xlang_async_io_wait_n;
}

/**
 * IO-A5：将最多 n 个 IO 等待任务移入就绪环（n=0 表示全部）。
 * 由 io_uring completion hook 或测试 harness 调用。
 */
void xlang_async_io_wake(unsigned n) {
    unsigned moved = 0;
    unsigned limit = n;
    uint64_t t0;
    uint64_t dt;
    if (limit == 0)
        limit = (unsigned)xlang_async_io_wait_n;
    t0 = xlang_async_trace_now_us();
    while (xlang_async_io_wait_n > 0 && moved < limit) {
        xlang_async_task_fn_t fn = xlang_async_io_wait[--xlang_async_io_wait_n];
        if (xlang_async_task_submit(fn) != 0) {
            xlang_async_io_wait[xlang_async_io_wait_n++] = fn;
            break;
        }
        moved++;
    }
    dt = xlang_async_trace_now_us() - t0;
    if (moved > 0)
        xlang_async_trace_push(xlang_async_trace_kind_io_wake, xlang_async_tls_worker, moved, dt, NULL);
}

/** IO-A5：唤醒全部 IO 等待任务。 */
void xlang_async_io_wake_all(void) {
    xlang_async_io_wake(0);
}

/**
 * IO-A5：io_uring 完成回调（强符号；io.c 弱 stub，链 scheduler.o 时覆盖）。
 * 每个 completion 唤醒一个 IO 等待任务。
 */
void xlang_async_io_completions_ready(unsigned n) {
    if (n == 0)
        return;
    xlang_async_io_wake(n);
}

/**
 * A4：将任务提交到指定 worker 就绪环；fn 帧须 static 持久化。
 * 返回 0 成功，-1 队列满、worker_id 无效或 fn 为空。
 */
int xlang_async_task_submit_to(uint32_t worker_id, xlang_async_task_fn_t fn) {
    xlang_async_task_queue_t *q;
    uint32_t t;
    uint32_t h;
    if (!fn || worker_id >= xlang_async_worker_count())
        return -1;
    q = &xlang_async_worker_q[worker_id];
    t = (uint32_t)atomic_fetch_add_explicit(&q->tail, 1, memory_order_acq_rel);
    h = (uint32_t)atomic_load_explicit(&q->head, memory_order_acquire);
    if (t - h >= XLANG_ASYNC_TASK_Q_CAP - 1) {
        atomic_fetch_sub_explicit(&q->tail, 1, memory_order_acq_rel);
        return -1;
    }
    q->slots[t % XLANG_ASYNC_TASK_Q_CAP] = fn;
    return 0;
}

/**
 * A4：将就绪 async 任务入队（MPSC round-robin 选 worker）。
 * 返回 0 成功，-1 队列满或 fn 为空。
 */
int xlang_async_task_submit(xlang_async_task_fn_t fn) {
    uint32_t n = xlang_async_worker_count();
    uint32_t w = (uint32_t)atomic_fetch_add_explicit(&xlang_async_submit_rr, 1, memory_order_relaxed) % n;
    return xlang_async_task_submit_to(w, fn);
}

/**
 * 提交任务并绑定 Context（STD-093）；ctx 已取消时返回 XLANG_ASYNC_ERR_CTX_SUBMIT_ABORT。
 */
int xlang_async_task_submit_with_ctx(xlang_async_task_fn_t fn, int64_t ctx_handle) {
    if (!fn)
        return -1;
    if (ctx_handle != 0 && ctx_is_cancelled_c(ctx_handle))
        return XLANG_ASYNC_ERR_CTX_SUBMIT_ABORT;
    xlang_async_bind_context_c(ctx_handle);
    return xlang_async_task_submit(fn);
}

/** XLANG_ASYNC_AFFINITY=1 时 worker drain 尝试绑核。 */
/* G-02f-117：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：DIRECT 模式，thin 直接实现 */
int xlang_async_affinity_enabled(void) {
  const char *e = link_abi_getenv("XLANG_ASYNC_AFFINITY");
  return e && e[0] == '1' && e[1] == '\0';
}
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */



/** worker drain 前绑核（XLANG_ASYNC_AFFINITY=1 时调用 thread_set_affinity_self_c）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void xlang_async_maybe_bind_worker_impl(uint32_t worker_id) {
#if defined(__GNUC__) || defined(__clang__)
    if (!xlang_async_affinity_enabled())
        return;
    (void)thread_set_affinity_self_c((int32_t)worker_id);
#else
    (void)worker_id;
#endif
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
void xlang_async_maybe_bind_worker(uint32_t worker_id) { xlang_async_maybe_bind_worker_impl(worker_id); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/** 单 worker 就绪环 drain；suspend 任务 re-queue 到 tls worker；acc 非空时累加已完成任务返回值。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t xlang_async_drain_queue_impl(xlang_async_task_queue_t *q, uint32_t worker_id, int32_t *acc) {
    int32_t last = 0;
    xlang_async_maybe_bind_worker(worker_id);
    xlang_async_tls_worker = worker_id;
    if (xlang_async_bound_ctx_cancelled())
        return XLANG_ASYNC_ERR_CTX_ABORT;
    for (;;) {
        if (xlang_async_bound_ctx_cancelled())
            return XLANG_ASYNC_ERR_CTX_ABORT;
        uint32_t h = (uint32_t)atomic_load_explicit(&q->head, memory_order_acquire);
        uint32_t t = (uint32_t)atomic_load_explicit(&q->tail, memory_order_acquire);
        xlang_async_task_fn_t fn;
        int32_t r;
        if (h == t)
            break;
        fn = q->slots[h % XLANG_ASYNC_TASK_Q_CAP];
        atomic_store_explicit(&q->head, h + 1, memory_order_release);
        if (!fn)
            continue;
        {
            uint64_t t0 = xlang_async_trace_now_us();
            r = fn();
            xlang_async_trace_push(xlang_async_trace_kind_task_run, worker_id, 0,
                                 xlang_async_trace_now_us() - t0, (void *)(uintptr_t)fn);
        }
        if (r == XLANG_ASYNC_SUSPENDED) {
            xlang_async_trace_push(xlang_async_trace_kind_suspend, worker_id, 0, 0,
                                 (void *)(uintptr_t)fn);
            if (xlang_async_io_wait_enabled() || xlang_async_take_suspend_io_flag()) {
                if (xlang_async_io_wait_push(fn) != 0)
                    return XLANG_ASYNC_SUSPENDED;
            } else if (xlang_async_task_submit_to(xlang_async_tls_worker, fn) != 0) {
                return XLANG_ASYNC_SUSPENDED;
            }
            continue;
        }
        last = r;
        if (acc && r != 0)
            *acc += r;
    }
    return last;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t xlang_async_drain_queue(xlang_async_task_queue_t *q, uint32_t worker_id, int32_t *acc) { return xlang_async_drain_queue_impl(q, worker_id, acc); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/**
 * A4 v2：单 consumer  drain 指定 worker 就绪环直至为空。
 */
int32_t xlang_async_worker_drain(uint32_t worker_id) {
    if (worker_id >= xlang_async_worker_count())
        return 0;
    return xlang_async_drain_queue(&xlang_async_worker_q[worker_id], worker_id, NULL);
}

/**
 * A4：轮询全部 worker 就绪环直至为空（兼容 v1 单线程 drain）。
 */
int32_t xlang_async_scheduler_drain(void) {
    int32_t last = 0;
    uint32_t n = xlang_async_worker_count();
    for (uint32_t w = 0; w < n; w++) {
        int32_t r = xlang_async_drain_queue(&xlang_async_worker_q[w], w, NULL);
        if (r != 0)
            last = r;
    }
    xlang_async_runtime_trace_flush();
    return last;
}

/**
 * A3/A4/IO-A5 v4：poll + drain 直至就绪环空且无 IO 等待者；返回已完成任务返回值之和。
 */
int32_t xlang_async_run_drain_until_idle(void) {
    int32_t sum = 0;
    unsigned stall = 0;
    for (;;) {
        int32_t batch = 0;
        uint32_t n = xlang_async_worker_count();
        uint32_t w;
        unsigned polled;
        for (w = 0; w < n; w++) {
            int32_t dr = xlang_async_drain_queue(&xlang_async_worker_q[w], w, &batch);
            if (dr == XLANG_ASYNC_ERR_CTX_ABORT) {
                xlang_async_runtime_trace_flush();
                return XLANG_ASYNC_ERR_CTX_ABORT;
            }
        }
        sum += batch;
        if (xlang_async_scheduler_pending() == 0 && xlang_async_io_waiters_pending() == 0) {
            xlang_async_runtime_trace_flush();
            return sum;
        }
        {
            uint64_t t0 = xlang_async_trace_now_us();
            polled = xlang_io_poll_async_completions(50);
            if (polled > 0) {
                xlang_async_trace_push(xlang_async_trace_kind_poll, xlang_async_tls_worker, stall,
                                     xlang_async_trace_now_us() - t0, NULL);
            }
        }
        if (polled > 0) {
            /* poll 窥视未消费 CQE 时可能反复 >0 却无任务进展，需有界退出。 */
            if (batch != 0)
                stall = 0;
            else
                stall++;
            continue;
        }
        /*
         * Linux io_uring：无 CQE 时勿 wake IO 等待者，否则 resume 后 complete 得 NOT_READY
         * 会被当作任务结束（累加 -2），spawn 并行 drain 出现 total=1/-2。
         * macOS 同步 complete 路径仍依赖 wake_all 推进。
         */
#if !defined(__linux__)
        xlang_async_io_wake_all();
#else
        if (xlang_async_io_waiters_pending() == 0)
            xlang_async_io_wake_all();
#endif
        stall++;
        xlang_async_trace_push(xlang_async_trace_kind_idle, xlang_async_tls_worker, stall, 0, NULL);
        /* 有界退出：poll=0 且仅 wake_all 时最多 64 轮（避免 CI 8min 挂死）。 */
        if (stall >= 64u) {
            xlang_async_runtime_trace_flush();
            return sum;
        }
    }
}

/**
 * A3/A4：submit + drain 驱动单帧 async 函数直至完成（帧须 static 持久化）。
 * IO await 路径：poll io_uring CQE 唤醒 IO 等待队列；无 completion 时回退 wake_all（macOS 同步 complete）。
 */
int32_t xlang_async_run_i32(int32_t (*fn)(void)) {
    if (!fn)
        return 0;
    xlang_async_queue_reset_impl(0);
    if (xlang_async_task_submit(fn) != 0)
        return 0;
    return xlang_async_run_drain_until_idle();
}

/** spawn 烟测 echo 任务：校验继承 Context 并返回 seed*10。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
int32_t xlang_async_spawn_ctx_echo_task_impl(void) {
    int32_t seed = 0;
    if (xlang_async_run_seed_valid())
        seed = xlang_async_run_seed_take_i32();
    if (xlang_async_spawn_ctx_expected != 0 &&
        xlang_async_current_context_c() != xlang_async_spawn_ctx_expected)
        return -99;
    return seed * 10;
}

#ifndef XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X
/* G-02f-20 thin+rest：IMPL 模式，thin 提供 wrapper 调用 _impl */
int32_t xlang_async_spawn_ctx_echo_task(void) { return xlang_async_spawn_ctx_echo_task_impl(); }
#endif /* XLANG_RUNTIME_SCHEDULER_GLUE_FROM_X */




/**
 * F-task v2：返回 task.o 中 task_echo_fn_c 入口（.x 同模块尚不能取函数址）。
 * 链入 task.o 时由链接器解析；未链 task.o 时返回 NULL。
 */
void *xlang_async_task_echo_fn_ptr_c(void) {
    extern int32_t task_echo_fn_c(void);
    return (void *)(uintptr_t)task_echo_fn_c;
}

/**
 * STD-093 C 烟测：bind_context + spawn 自动继承 + 取消传播。
 * 0 通过；非 0 失败码。
 */
int32_t xlang_async_spawn_ctx_smoke_c(void) {
    extern int64_t ctx_background_c(void);
    extern int64_t ctx_with_cancel_c(int64_t parent);
    extern void ctx_cancel_c(int64_t handle);
    extern void ctx_free_c(int64_t handle);
    int64_t bg;
    int64_t child;
    int64_t live;
    int32_t total;

    bg = ctx_background_c();
    child = ctx_with_cancel_c(bg);
    live = ctx_with_cancel_c(bg);
    if (bg == 0 || child == 0 || live == 0)
        return 10;

    xlang_async_queue_reset();
    xlang_async_run_seed_reset();
    xlang_async_bind_context_c(child);
    ctx_cancel_c(child);
    if (xlang_async_spawn_i32(xlang_async_spawn_ctx_echo_task, 1) != XLANG_ASYNC_ERR_CTX_SUBMIT_ABORT) {
        ctx_free_c(child);
        ctx_free_c(live);
        return 1;
    }

    xlang_async_queue_reset();
    xlang_async_run_seed_reset();
    xlang_async_bind_context_c(live);
    xlang_async_spawn_ctx_expected = live;
    if (xlang_async_spawn_i32(xlang_async_spawn_ctx_echo_task, 2) != 0) {
        ctx_free_c(child);
        ctx_free_c(live);
        return 2;
    }
    total = xlang_async_run_drain_until_idle();
    xlang_async_spawn_ctx_expected = 0;
    if (total != 20) {
        ctx_free_c(child);
        ctx_free_c(live);
        return 3;
    }

    ctx_free_c(child);
    ctx_free_c(live);
    return 0;
}

/** asm CPS 帧槽数量（WPO-S3；按 fn_id 哈希，无 malloc）。 */
#define XLANG_ASYNC_ASM_FRAME_SLOTS 8

/** 单槽：fn_id + phase + live data blob（phase 与 C __xlang_frame.__phase 对齐）。 */
typedef struct {
    uint32_t fn_id;
    int32_t phase;
    uint8_t data[120];
} xlang_async_asm_frame_slot_t;

static xlang_async_asm_frame_slot_t xlang_async_asm_frames[XLANG_ASYNC_ASM_FRAME_SLOTS];

/** 按 fn_id 查找或分配帧槽。 */
static xlang_async_asm_frame_slot_t *xlang_async_asm_frame_slot(uint32_t fn_id) {
    int i;
    if (fn_id == 0)
        fn_id = 1u;
    for (i = 0; i < XLANG_ASYNC_ASM_FRAME_SLOTS; i++) {
        if (xlang_async_asm_frames[i].fn_id == fn_id)
            return &xlang_async_asm_frames[i];
    }
    for (i = 0; i < XLANG_ASYNC_ASM_FRAME_SLOTS; i++) {
        if (xlang_async_asm_frames[i].fn_id == 0) {
            xlang_async_asm_frames[i].fn_id = fn_id;
            xlang_async_asm_frames[i].phase = 0;
            return &xlang_async_asm_frames[i];
        }
    }
    return &xlang_async_asm_frames[0];
}

/**
 * asm 后端：按 fn_id 取 phase 指针（&slot->phase）。
 * 供 emit 调 xlang_async_cps_suspend(&phase, next)。
 */
int32_t *xlang_async_asm_frame_phase_by_id(uint32_t fn_id) {
    return &xlang_async_asm_frame_slot(fn_id)->phase;
}

/** asm 后端：live data 区起始（slot->data，与 phase 分离存储）。 */
uint8_t *xlang_async_asm_frame_data_by_id(uint32_t fn_id) {
    return xlang_async_asm_frame_slot(fn_id)->data;
}

/** async 正常 return 前 reset phase，便于同进程二次 poll。 */
void xlang_async_asm_frame_reset_by_id(uint32_t fn_id) {
    xlang_async_asm_frame_slot(fn_id)->phase = 0;
}

/** asm emit：frame data 区 ← 栈/memory（src 指向 live 变量）。 */
void xlang_async_asm_frame_store_from_ptr(uint32_t fn_id, int32_t data_off, void *src, int32_t nbytes) {
    xlang_async_asm_frame_slot_t *s;
    if (!src || nbytes <= 0 || data_off < 0)
        return;
    s = xlang_async_asm_frame_slot(fn_id);
    if ((size_t)data_off + (size_t)nbytes > sizeof(s->data))
        return;
    memcpy(s->data + data_off, src, (size_t)nbytes);
}

/** asm emit：frame data 区 → 栈/memory（dst 指向 live 变量）。 */
void xlang_async_asm_frame_load_to_ptr(uint32_t fn_id, int32_t data_off, void *dst, int32_t nbytes) {
    xlang_async_asm_frame_slot_t *s;
    if (!dst || nbytes <= 0 || data_off < 0)
        return;
    s = xlang_async_asm_frame_slot(fn_id);
    if ((size_t)data_off + (size_t)nbytes > sizeof(s->data))
        return;
    memcpy(dst, s->data + data_off, (size_t)nbytes);
}

#include "seeds/async_net_fs.from_x.c"
