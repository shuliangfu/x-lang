/**
 * iocp_batch_smoke.c — IO-A6 烟测：Windows IOCP 批量读写 + registered buffer read_fixed
 *
 * 验证 std/io/io.c 在 Windows 上：
 *   1. io_write_batch / io_read_batch（timeout_ms=0 → IOCP + GetQueuedCompletionStatusEx）
 *   2. io_register_buffer + io_read_fixed（与 Linux 同 API，Windows 走 IOCP 重叠 I/O）
 *
 * 用法：由 tests/run-iocp-smoke.sh 编译链接 io.o 后运行；仅 Windows（_WIN32）。
 */
#if defined(_WIN32) || defined(_WIN64)

#include <fcntl.h>
#include <io.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1,
    uint8_t *p2, size_t l2, uint8_t *p3, size_t l3, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch(int fd, const uint8_t *p0, size_t l0, const uint8_t *p1, size_t l1,
    const uint8_t *p2, size_t l2, const uint8_t *p3, size_t l3, int n, unsigned timeout_ms);
extern int io_register_buffer(uint8_t *ptr, size_t len);
extern void io_unregister_buffers(void);
extern ptrdiff_t io_read_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);

int main(void) {
    int pipefd[2];
    uint8_t b0[16];
    uint8_t b1[16];
    uint8_t wbuf[32];
    uint8_t fixed[64];
    ptrdiff_t n;
    static const char msg0[] = "shuiocp0";
    static const char msg1[] = "shuiocp1";
    static const char msg_fix[] = "shufixd";

    /* 测试 1：IOCP 批量写（两段） */
    if (_pipe(pipefd, 4096, _O_BINARY) != 0) {
        perror("_pipe");
        return 1;
    }
    memcpy(wbuf, msg0, 8);
    memcpy(wbuf + 8, msg1, 8);
    n = io_write_batch(pipefd[1], wbuf, 8, wbuf + 8, 8, NULL, 0, NULL, 0, 2, 0);
    if (n != 16) {
        fprintf(stderr, "io_write_batch expected 16 got %td\n", n);
        return 2;
    }
    _close(pipefd[1]);

    /* 测试 2：IOCP 批量读（两段，timeout_ms=0 走 GetQueuedCompletionStatusEx） */
    memset(b0, 0, sizeof(b0));
    memset(b1, 0, sizeof(b1));
    n = io_read_batch(pipefd[0], b0, 8, b1, 8, NULL, 0, NULL, 0, 2, 0);
    if (n != 16) {
        fprintf(stderr, "io_read_batch expected 16 got %td\n", n);
        return 3;
    }
    if (memcmp(b0, msg0, 8) != 0 || memcmp(b1, msg1, 8) != 0) {
        fprintf(stderr, "io_read_batch content mismatch\n");
        return 4;
    }
    _close(pipefd[0]);

    /* 测试 3：registered buffer + read_fixed（Windows TLS 池，与 Linux 同 API） */
    if (_pipe(pipefd, 4096, _O_BINARY) != 0) {
        perror("_pipe");
        return 5;
    }
    if (_write(pipefd[1], msg_fix, 7) != 7) {
        perror("_write");
        return 6;
    }
    _close(pipefd[1]);

    memset(fixed, 0, sizeof(fixed));
    if (!io_register_buffer(fixed, sizeof(fixed))) {
        fprintf(stderr, "io_register_buffer failed\n");
        return 7;
    }
    n = io_read_fixed(pipefd[0], 0, 0, 7, 0);
    if (n != 7) {
        fprintf(stderr, "io_read_fixed expected 7 got %td\n", n);
        io_unregister_buffers();
        return 8;
    }
    if (memcmp(fixed, msg_fix, 7) != 0) {
        fprintf(stderr, "io_read_fixed content mismatch\n");
        io_unregister_buffers();
        return 9;
    }

    _close(pipefd[0]);
    io_unregister_buffers();
    return 0;
}

#else

int main(void) {
    return 0;
}

#endif
