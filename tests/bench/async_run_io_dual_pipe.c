/**
 * tests/bench/async_run_io_dual_pipe.c — 双 pipe + 两次 shux_async_run_i32 烟测
 *
 * 模拟两次 run read_chunk(fd)：各 pipe 经 seed push_i32(fd) 注入读端 fd。
 *
 * 编译：cc -std=c11 -o async_run_io_dual_pipe \
 *   tests/bench/async_run_io_dual_pipe.c std/io/io.o std/async/scheduler.o
 * 运行：SHUX_ASYNC_YIELD=1 ./async_run_io_dual_pipe
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
extern void shux_async_run_seed_reset(void);
extern void shux_async_run_seed_push_i32(int32_t v);
extern int shux_async_run_seed_valid(void);
extern int32_t shux_async_run_seed_take_i32(void);

static int g_read_fd;
static uint8_t g_buf[16];
static int32_t g_phase;
static int g_step;
static int g_slot;

/**
 * 模拟 codegen read_chunk：phase 0 从 seed 取 fd，await read_fd 三阶段。
 */
static int32_t read_chunk_task(void) {
    int32_t n;
    if (g_step == 0) {
        if (shux_async_run_seed_valid())
            g_read_fd = shux_async_run_seed_take_i32();
        g_step = 1;
        g_phase = 0;
        g_slot = shux_io_submit_read_async(g_buf, sizeof(g_buf), (size_t)(unsigned)g_read_fd);
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
 * 单次 run：reset seed → push fd → run_i32 直至完成。
 */
static int32_t run_read_on_fd(int read_fd) {
    g_step = 0;
    g_phase = 0;
    memset(g_buf, 0, sizeof(g_buf));
    shux_async_run_seed_reset();
    shux_async_run_seed_push_i32(read_fd);
    return shux_async_run_i32(read_chunk_task);
}

/**
 * 入口：双 pipe 各 run 一次，校验总字节数 2+3=5。
 */
int main(void) {
    int fds_a[2];
    int fds_b[2];
    int32_t n1;
    int32_t n2;

    if (pipe(fds_a) != 0 || pipe(fds_b) != 0) {
        fprintf(stderr, "async_run_io_dual_pipe: pipe failed\n");
        return 1;
    }
    if (write(fds_a[1], "ab", 2) != 2 || write(fds_b[1], "xyz", 3) != 3) {
        fprintf(stderr, "async_run_io_dual_pipe: write failed\n");
        return 2;
    }
    (void)close(fds_a[1]);
    (void)close(fds_b[1]);

    setenv("SHUX_ASYNC_YIELD", "1", 1);

    n1 = run_read_on_fd(fds_a[0]);
    n2 = run_read_on_fd(fds_b[0]);
    if (n1 != 2 || n2 != 3) {
        fprintf(stderr, "async_run_io_dual_pipe: n1=%d n2=%d want 2+3\n", (int)n1, (int)n2);
        return 3;
    }
    if (n1 + n2 != 5) {
        fprintf(stderr, "async_run_io_dual_pipe: sum=%d want 5\n", (int)(n1 + n2));
        return 4;
    }

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);
    return 0;
}
