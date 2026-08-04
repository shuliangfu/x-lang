/**
 * provided_buffers_smoke.c — ZC-1 烟测：pipe + IORING_OP_PROVIDE_BUFFERS + IOSQE_BUFFER_SELECT
 * 用法：由 tests/run-provided-buffers.sh 编译链接 io.o 后运行；仅 Linux + liburing。
 */
#if defined(__linux__)

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int io_register_provided_buffers(unsigned nr, unsigned bufsz);
extern void io_unregister_provided_buffers(void);
extern uint8_t *io_provided_buffer_ptr(unsigned bid);
extern ptrdiff_t io_read_provided(int fd, unsigned timeout_ms, unsigned *out_bid, unsigned *out_len);

int main(void) {
    int pipefd[2];
    unsigned bid = 0, blen = 0;
    uint8_t *p;
    ptrdiff_t n;

    if (pipe(pipefd) != 0) {
        perror("pipe");
        return 1;
    }
    if (write(pipefd[1], "shuzc1", 6) != 6) {
        perror("write");
        return 2;
    }
    (void)close(pipefd[1]);

    if (!io_register_provided_buffers(8, 4096)) {
        fprintf(stderr, "io_register_provided_buffers failed (need Linux 5.19+ io_uring provide)\n");
        return 3;
    }

    n = io_read_provided(pipefd[0], 0, &bid, &blen);
    if (n != 6) {
        fprintf(stderr, "io_read_provided expected 6 got %td\n", n);
        io_unregister_provided_buffers();
        return 4;
    }
    p = io_provided_buffer_ptr(bid);
    if (!p || memcmp(p, "shuzc1", 6) != 0) {
        fprintf(stderr, "provided buffer content mismatch\n");
        io_unregister_provided_buffers();
        return 5;
    }

    (void)close(pipefd[0]);
    io_unregister_provided_buffers();
    return 0;
}

#else

int main(void) {
    return 0;
}

#endif
