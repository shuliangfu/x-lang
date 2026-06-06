/**
 * io_uring_probe.c — 探测当前 Linux 内核是否可用 io_uring（queue_init 成功即视为可用）。
 * 用于 ZC-1 provided buffers 烟测/perf 在 Mac Docker linuxkit 等无 io_uring 环境 SKIP。
 * 用法：cc -O2 io_uring_probe.c -o probe -luring && ./probe；exit 0=可用，1=不可用。
 */
#if defined(__linux__)

#include <stdio.h>
#include <liburing.h>

int main(void) {
    struct io_uring ring;
    int r;

    r = io_uring_queue_init(8, &ring, 0);
    if (r < 0) {
        /* -38 ENOSYS：Mac Docker Desktop linuxkit 等伪内核常见 */
        fprintf(stderr, "io_uring_probe: queue_init=%d (kernel lacks io_uring)\n", r);
        return 1;
    }
    io_uring_queue_exit(&ring);
    return 0;
}

#else

int main(void) {
    return 1;
}

#endif
