/**
 * tests/bench/io_read_async_multi.c — IO-A5 v2 多 read in-flight 烟测
 *
 * 双 pipe 同时 submit 两个 read async，再按 slot 分别 complete。
 *
 * 编译：cc -std=c11 -o io_read_async_multi tests/bench/io_read_async_multi.c std/io/io.o
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_complete_read_async_slot(int slot);
extern unsigned shux_io_poll_async_completions(unsigned timeout_ms);

#define SHUX_IO_ASYNC_NOT_READY ((int32_t)-2)

/** Linux：双 slot submit 后 poll 一次再 complete，避免 CQE 未就绪。 */
static int32_t io_read_slot_complete_with_poll(int slot) {
    int32_t n = shux_io_complete_read_async_slot(slot);
    if (n == SHUX_IO_ASYNC_NOT_READY) {
#if defined(__linux__)
        (void)shux_io_poll_async_completions(500);
#endif
        n = shux_io_complete_read_async_slot(slot);
    }
    return n;
}

/**
 * 入口：双 pipe 并行 read async submit + slot complete。
 */
int main(void) {
    int fds_a[2];
    int fds_b[2];
    uint8_t buf_a[8];
    uint8_t buf_b[8];
    int slot_a;
    int slot_b;
    int32_t na;
    int32_t nb;

    if (pipe(fds_a) != 0 || pipe(fds_b) != 0) {
        fprintf(stderr, "io_read_async_multi: pipe failed\n");
        return 1;
    }
    if (write(fds_a[1], "ab", 2) != 2 || write(fds_b[1], "xyz", 3) != 3) {
        fprintf(stderr, "io_read_async_multi: write failed\n");
        return 2;
    }
    (void)close(fds_a[1]);
    (void)close(fds_b[1]);

    memset(buf_a, 0, sizeof(buf_a));
    memset(buf_b, 0, sizeof(buf_b));

    slot_a = shux_io_submit_read_async(buf_a, sizeof(buf_a), (size_t)(unsigned)fds_a[0]);
    slot_b = shux_io_submit_read_async(buf_b, sizeof(buf_b), (size_t)(unsigned)fds_b[0]);
    if (slot_a < 0 || slot_b < 0 || slot_a == slot_b) {
        fprintf(stderr, "io_read_async_multi: submit slots a=%d b=%d\n", slot_a, slot_b);
        return 3;
    }

    na = io_read_slot_complete_with_poll(slot_a);
    nb = io_read_slot_complete_with_poll(slot_b);

    (void)close(fds_a[0]);
    (void)close(fds_b[0]);

    if (na != 2 || nb != 3) {
        fprintf(stderr, "io_read_async_multi: complete na=%d nb=%d want 2/3\n", (int)na, (int)nb);
        return 4;
    }
    if (memcmp(buf_a, "ab", 2) != 0 || memcmp(buf_b, "xyz", 3) != 0) {
        fprintf(stderr, "io_read_async_multi: payload mismatch\n");
        return 5;
    }
    return 0;
}
