/**
 * iocp_pipe_loop.c — IO-A6 perf：Windows IOCP pipe 批量 readv/writev 热循环
 *
 * 每轮：io_write_batch(2×64B) + io_read_batch(2×64B)，与 iocp_batch_smoke 同 API 路径。
 * 轮数：环境变量 SHU_IOCP_BENCH_ROUNDS（默认 65536）。
 * 用法：由 tests/run-perf-iocp.sh 编译链接 io.o 后 time 计时；仅 Windows。
 */
#if defined(_WIN32) || defined(_WIN64)

#include <fcntl.h>
#include <io.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1,
    uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch(int fd, const uint8_t *p0, size_t l0, const uint8_t *p1, size_t l1,
    const uint8_t *p2, size_t l2, const uint8_t *p3, size_t l3, int n, unsigned timeout_ms);

/** 解析正整数环境变量；非法或未设置时返回 default_val。 */
static unsigned parse_rounds_env(const char *name, unsigned default_val) {
    const char *e = getenv(name);
    char *end = NULL;
    unsigned long v;
    if (!e || !e[0])
        return default_val;
    v = strtoul(e, &end, 10);
    if (end == e || v == 0 || v > 100000000ul)
        return default_val;
    return (unsigned)v;
}

int main(void) {
    int pipefd[2];
    uint8_t wbuf[128];
    uint8_t b0[64];
    uint8_t b1[64];
    unsigned rounds;
    unsigned r;
    ptrdiff_t n;

    rounds = parse_rounds_env("SHU_IOCP_BENCH_ROUNDS", 65536u);
    if (_pipe(pipefd, 65536, _O_BINARY) != 0) {
        perror("_pipe");
        return 1;
    }

    for (r = 0; r < rounds; r++) {
        wbuf[0] = (uint8_t)(r & 255u);
        wbuf[63] = (uint8_t)((r >> 8) & 255u);
        wbuf[64] = (uint8_t)((r >> 16) & 255u);
        wbuf[127] = (uint8_t)((r >> 24) & 255u);
        n = io_write_batch(pipefd[1], wbuf, 64, wbuf + 64, 64, NULL, 0, NULL, 0, 2, 0);
        if (n != 128) {
            fprintf(stderr, "io_write_batch round %u expected 128 got %td\n", r, n);
            _close(pipefd[0]);
            _close(pipefd[1]);
            return 2;
        }
        n = io_read_batch(pipefd[0], b0, 64, b1, 64, NULL, 0, NULL, 0, 2, 0);
        if (n != 128) {
            fprintf(stderr, "io_read_batch round %u expected 128 got %td\n", r, n);
            _close(pipefd[0]);
            _close(pipefd[1]);
            return 3;
        }
        if (b0[0] != wbuf[0] || b1[0] != wbuf[64]) {
            fprintf(stderr, "io_read_batch content mismatch round %u\n", r);
            _close(pipefd[0]);
            _close(pipefd[1]);
            return 4;
        }
    }

    _close(pipefd[0]);
    _close(pipefd[1]);
    return 0;
}

#else

int main(void) {
    return 0;
}

#endif
