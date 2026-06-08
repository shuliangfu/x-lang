/**
 * tests/bench/io_read_async.c — IO-A5 v1 submit_read_async + complete_read_async 烟测
 *
 * 用 pipe 写入 3 字节；submit 后 complete 读回。非 Linux 走 io_read 回退同步 complete。
 *
 * 编译：cc -std=c11 -o io_read_async tests/bench/io_read_async.c std/io/io.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int shu_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_complete_read_async(void);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);

#define SHU_IO_ASYNC_NOT_READY ((int32_t)-2)

/** Linux io_uring：complete 返回 NOT_READY 时先 poll CQE 再重试。 */
static int32_t io_read_async_complete_with_poll(void) {
    int32_t n = shu_io_complete_read_async();
    if (n == SHU_IO_ASYNC_NOT_READY) {
#if defined(__linux__)
        (void)shu_io_poll_async_completions(500);
#endif
        n = shu_io_complete_read_async();
    }
    return n;
}

/**
 * 入口：pipe + submit/complete 读路径。
 */
int main(void) {
    int fds[2];
    uint8_t buf[16];
    int32_t n;

    if (pipe(fds) != 0) {
        fprintf(stderr, "io_read_async: pipe failed\n");
        return 1;
    }
    if (write(fds[1], "abc", 3) != 3) {
        fprintf(stderr, "io_read_async: write failed\n");
        return 2;
    }
    (void)close(fds[1]);

    memset(buf, 0, sizeof(buf));
    if (shu_io_submit_read_async(buf, sizeof(buf), (size_t)(unsigned)fds[0]) != 0) {
        fprintf(stderr, "io_read_async: submit failed\n");
        return 3;
    }

    n = io_read_async_complete_with_poll();
    (void)close(fds[0]);

    if (n != 3) {
        fprintf(stderr, "io_read_async: complete got %d want 3\n", (int)n);
        return 4;
    }
    if (buf[0] != 'a' || buf[1] != 'b' || buf[2] != 'c') {
        fprintf(stderr, "io_read_async: bad payload\n");
        return 5;
    }
    return 0;
}
