/**
 * tests/bench/async_runtime_trace_smoke.c — OBS-002 烟测：SHU_ASYNC_RUNTIME_TRACE Top-N 输出
 *
 * 提交带 suspend 的任务并 drain，验证 stderr 含 trace summary 与 rank 行。
 *
 * 编译：cc -std=gnu11 -o async_runtime_trace_smoke \
 *         tests/bench/async_runtime_trace_smoke.c std/async/scheduler.o
 * 运行：SHU_ASYNC_RUNTIME_TRACE=1 ./async_runtime_trace_smoke
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/** 与 scheduler.c SHU_ASYNC_SUSPENDED 一致。 */
#define SHU_ASYNC_SUSPENDED ((int32_t)0x41535700)

extern int shu_async_task_submit(int32_t (*fn)(void));
extern int32_t shu_async_scheduler_drain(void);
extern void shu_async_runtime_trace_flush(void);

static int g_step;

/**
 * 首次 yield，二次返回 99（与 async_scheduler_queue 同模式）。
 */
static int32_t trace_smoke_task(void) {
    if (g_step == 0) {
        g_step = 1;
        return SHU_ASYNC_SUSPENDED;
    }
    return 99;
}

/**
 * 入口：启用 trace env，跑 drain + flush，成功 exit 0。
 */
int main(void) {
    int32_t r;

    setenv("SHU_ASYNC_RUNTIME_TRACE", "1", 1);
    setenv("SHU_ASYNC_RUNTIME_TRACE_TOPN", "5", 1);
    setenv("SHU_ASYNC_RUNTIME_TRACE_SAMPLE", "1", 1);

    g_step = 0;
    if (shu_async_task_submit(trace_smoke_task) != 0) {
        fprintf(stderr, "async_runtime_trace_smoke: submit failed\n");
        return 1;
    }
    r = shu_async_scheduler_drain();
    if (r != 99) {
        fprintf(stderr, "async_runtime_trace_smoke: drain got %d want 99\n", (int)r);
        return 2;
    }
    /* drain 内已 flush；再调一次确保 harness 可 grep rank 行。 */
    shu_async_runtime_trace_flush();
    return 0;
}
