/**
 * tests/bench/async_run_i32_io_stdin.c — shux_async_run_i32 + IO await stdin 烟测
 *
 * 验证 run_i32 在 IO 等待队列非空时 wake/drain 直至完成。
 *
 * 编译：cc -std=c11 -o async_run_i32_io_stdin \
 *   tests/bench/async_run_i32_io_stdin.c std/io/io.o std/async/scheduler.o
 * 运行：printf abcd | SHUX_ASYNC_YIELD=1 ./async_run_i32_io_stdin
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SHUX_ASYNC_SUSPENDED ((int32_t)0x41535700)
#define SHUX_IO_ASYNC_NOT_READY ((int32_t)-2)

extern int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async_slot(int slot);
extern int shux_async_cps_suspend_io(int32_t *phase, int32_t next_phase);
extern int32_t shux_async_run_i32(int32_t (*fn)(void));

static uint8_t g_buf[8];
static int32_t g_phase;
static int g_step;
static int g_slot;

/**
 * 模拟 codegen：await read_fd(0, buf, 4) 协程体。
 */
static int32_t read_four_task(void) {
    int32_t n;
    if (g_step == 0) {
        g_step = 1;
        g_phase = 0;
        g_slot = shux_io_submit_read_async(g_buf, 4, 0);
        if (g_slot < 0)
            return -1;
        if (shux_async_cps_suspend_io(&g_phase, 1))
            return SHUX_ASYNC_SUSPENDED;
    }
    n = shux_io_complete_read_async_slot(g_slot);
    if (n == SHUX_IO_ASYNC_NOT_READY)
        n = shux_io_complete_read_async_slot(g_slot);
    return n;
}

/**
 * 入口：pipe 模拟 stdin 经 run_i32 读 4 字节。
 */
int main(void) {
    int32_t r;

    setenv("SHUX_ASYNC_YIELD", "1", 1);
    g_step = 0;
    g_phase = 0;
    memset(g_buf, 0, sizeof(g_buf));

    r = shux_async_run_i32(read_four_task);
    if (r != 4) {
        fprintf(stderr, "async_run_i32_io_stdin: run_i32 got %d want 4\n", (int)r);
        return 1;
    }
    if (memcmp(g_buf, "abcd", 4) != 0) {
        fprintf(stderr, "async_run_i32_io_stdin: payload mismatch\n");
        return 2;
    }
    return 0;
}
