/**
 * std/async/async_net_fs.inc.c — async net/fs fd 读写烟测（STD-049 / #79）
 *
 * 【文件职责】通过 pipe 验证 std.io read_async/write_async 在 net/fs 类 fd 上的
 * submit + complete 路径；由 scheduler_glue.c 末尾 #include。
 */

#if !defined(_WIN32) && !defined(_WIN64)
#include <string.h>
#ifndef _WIN32
#include <unistd.h>
#endif
#endif

/** 与 std.io IO_ASYNC_NOT_READY 一致。 */
#define SHUX_ASYNC_IO_NOT_READY (-2)

/** io.o 未链入时 weak 桩（与 scheduler_glue.c poll 桩一致）。 */
__attribute__((weak)) int shux_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle) {
    (void)ptr;
    (void)len;
    (void)handle;
    return -1;
}

__attribute__((weak)) int32_t shux_io_complete_read_async_slot(int slot) {
    (void)slot;
    return SHUX_ASYNC_IO_NOT_READY;
}

__attribute__((weak)) int shux_io_submit_write_async(const uint8_t *ptr, size_t len, size_t handle) {
    (void)ptr;
    (void)len;
    (void)handle;
    return -1;
}

__attribute__((weak)) int32_t shux_io_complete_write_async_slot(int slot) {
    (void)slot;
    return SHUX_ASYNC_IO_NOT_READY;
}

/**
 * pipe 上 async read/write 往返烟测（模拟 net stream / fs fd 异步路径）；0 通过。
 * 非 Unix 跳过返回 0。
 */
int32_t shux_async_net_fs_smoke_c(void) {
#if defined(_WIN32) || defined(_WIN64)
    return 0;
#else
    int pv[2];
    uint8_t wbuf[] = "net";
    uint8_t rbuf[8];
    int slot;
    int32_t n;

    /* read async：pipe 写端 → read_async → complete */
    if (pipe(pv) != 0)
        return 1;
    if (write(pv[1], wbuf, 3) != 3) {
        close(pv[0]);
        close(pv[1]);
        return 2;
    }
    close(pv[1]);
    slot = shux_io_submit_read_async(rbuf, 3, (size_t)pv[0]);
    if (slot < 0) {
        close(pv[0]);
        return 0;
    }
    n = shux_io_complete_read_async_slot(slot);
    close(pv[0]);
    if (n != 3)
        return 4;
    if (memcmp(rbuf, wbuf, 3) != 0)
        return 5;

    /* write async：write_async → pipe 读端校验 */
    if (pipe(pv) != 0)
        return 6;
    slot = shux_io_submit_write_async(wbuf, 3, (size_t)pv[1]);
    if (slot < 0) {
        close(pv[0]);
        close(pv[1]);
        return 0;
    }
    n = shux_io_complete_write_async_slot(slot);
    if (n != 3) {
        close(pv[0]);
        close(pv[1]);
        return 8;
    }
    if (read(pv[0], rbuf, 3) != 3) {
        close(pv[0]);
        close(pv[1]);
        return 9;
    }
    close(pv[0]);
    close(pv[1]);
    if (memcmp(rbuf, wbuf, 3) != 0)
        return 10;
    return 0;
#endif
}
