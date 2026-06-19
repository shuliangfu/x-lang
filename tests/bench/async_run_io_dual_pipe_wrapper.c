/**
 * tests/bench/async_run_io_dual_pipe_wrapper.c — 双 pipe 注入 fd 3/4 后 exec .sx 二进制
 *
 * 为 async_run_io_dual_pipe.sx 提供可读 pipe 端：fd 3 ← "ab"，fd 4 ← "xyz"。
 *
 * 编译：cc -std=c11 -Wall -Wextra -o async_run_io_dual_pipe_wrapper \
 *   tests/bench/async_run_io_dual_pipe_wrapper.c
 * 用法：SHUX_ASYNC_YIELD=1 ./async_run_io_dual_pipe_wrapper /tmp/shux_async_run_io_dual_pipe
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/** 将 pipe 读端固定到 target_fd（3 或 4），写端写入 payload 后关闭。 */
static int setup_pipe_on_fd(int target_fd, const char *payload, int payload_len) {
    int fds[2];
    if (pipe(fds) != 0)
        return -1;
    if (payload_len > 0 && write(fds[1], payload, (size_t)payload_len) != payload_len) {
        (void)close(fds[0]);
        (void)close(fds[1]);
        return -2;
    }
    (void)close(fds[1]);
    if (dup2(fds[0], target_fd) < 0) {
        (void)close(fds[0]);
        return -3;
    }
    /* dup2 后 read 端已在 target_fd；若 fds[0]==target_fd 则不可 close（会关掉注入的 fd）。 */
    if (fds[0] != target_fd)
        (void)close(fds[0]);
    return 0;
}

/**
 * 入口：建双 pipe → dup2 到 fd 3/4 → exec 用户 .sx 可执行文件。
 */
int main(int argc, char **argv) {
    const char *exe;
    int chk;

    if (argc < 2) {
        fprintf(stderr, "usage: %s <async_run_io_dual_pipe_binary>\n", argv[0]);
        return 1;
    }
    exe = argv[1];

    chk = setup_pipe_on_fd(3, "ab", 2);
    if (chk != 0) {
        fprintf(stderr, "async_run_io_dual_pipe_wrapper: pipe fd3 failed %d\n", chk);
        return 2;
    }
    chk = setup_pipe_on_fd(4, "xyz", 3);
    if (chk != 0) {
        fprintf(stderr, "async_run_io_dual_pipe_wrapper: pipe fd4 failed %d\n", chk);
        return 3;
    }

    setenv("SHUX_ASYNC_YIELD", "1", 1);
    execv(exe, argv + 1);
    fprintf(stderr, "async_run_io_dual_pipe_wrapper: execv %s: %s\n", exe, strerror(errno));
    return 4;
}
