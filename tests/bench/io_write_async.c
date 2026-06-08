/**
 * tests/bench/io_write_async.c — IO-A5 v1 submit_write_async + complete_write_async 烟测
 *
 * pipe 写端 submit/complete 写入 3 字节；读端校验 payload。
 *
 * 编译：cc -std=c11 -o io_write_async tests/bench/io_write_async.c std/io/io.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int shu_io_submit_write_async(const uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_complete_write_async(void);
extern unsigned shu_io_poll_async_completions(unsigned timeout_ms);

#define SHU_IO_ASYNC_NOT_READY ((int32_t)-2)

/** Linux io_uring：complete 返回 NOT_READY 时先 poll CQE 再重试。 */
static int32_t io_write_async_complete_with_poll(void) {
    int32_t n = shu_io_complete_write_async();
    if (n == SHU_IO_ASYNC_NOT_READY) {
#if defined(__linux__)
        (void)shu_io_poll_async_completions(500);
#endif
        n = shu_io_complete_write_async();
    }
    return n;
}

/**
 * 入口：pipe + submit/complete 写路径。
 */
int main(void) {
    int fds[2];
    uint8_t payload[4] = {'a', 'b', 'c', 'd'};
    uint8_t buf[8];
    int32_t n;
    ssize_t nr;

    if (pipe(fds) != 0) {
        fprintf(stderr, "io_write_async: pipe failed\n");
        return 1;
    }

    if (shu_io_submit_write_async(payload, 3, (size_t)(unsigned)fds[1]) < 0) {
        fprintf(stderr, "io_write_async: submit failed\n");
        return 2;
    }

    n = io_write_async_complete_with_poll();
    (void)close(fds[1]);

    if (n != 3) {
        fprintf(stderr, "io_write_async: complete got %d want 3\n", (int)n);
        return 3;
    }

    memset(buf, 0, sizeof(buf));
    nr = read(fds[0], buf, sizeof(buf));
    (void)close(fds[0]);
    if (nr != 3 || buf[0] != 'a' || buf[1] != 'b' || buf[2] != 'c') {
        fprintf(stderr, "io_write_async: readback mismatch\n");
        return 4;
    }
    return 0;
}
