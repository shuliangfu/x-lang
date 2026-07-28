/* seeds/runtime_net_io_batch_fast.from_x.c — G-02f-20 product TU
 * Product: ../std/net/net_io_batch_fast.o
 *
 * R2 migration architecture:
 *   - thin (.x): public _c wrappers + weak io_* stubs (XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X)
 *   - rest (this file, always compiled): _impl bridge functions containing the
 *     Linux-only recvmmsg/sendmmsg syscalls (guarded by __linux__/__GLIBC__).
 *
 * Cold path (no guard): this file provides both _c wrappers + _impl bridges.
 * R2 path: this file provides only _impl bridges; _c wrappers come from .x.
 */
#include <xlang_weak.h>
#include <stdint.h>

#ifndef XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X
/* 【Why 根源】net.o 的 net_stream_*_batch_c 引用 io_read_batch/io_write_batch/
 * io_read_batch_provided，定义在 std.io.sync（可选依赖）。用户程序若不 import io.sync，
 * DCE 剔除 sync.x 的定义，链接报 undefined。弱桩提供默认实现（返回 -1=不支持），
 * 让 net.o 自包含；用户 import io.sync 时，sync.x 的强符号（#[no_mangle]）覆盖弱桩。
 * 【Invariant】弱符号与强符号同名时，C 链接器优先选强符号；弱桩仅在无强符号时生效。
 * 【Asm/Perf】弱桩直接 return -1，无副作用；被覆盖时不进入最终可执行文件。
 *
 * R2 mode (XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X defined): these weak stubs
 * are provided by the thin (.x) side. This block is skipped. */
XLANG_WEAK int32_t io_read_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                             uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    (void)fd; (void)p0; (void)l0; (void)p1; (void)l1; (void)p2; (void)l2; (void)p3; (void)n; (void)timeout_ms;
    return -1;
}
XLANG_WEAK int32_t io_write_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                              uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    (void)fd; (void)p0; (void)l0; (void)p1; (void)l1; (void)p2; (void)l2; (void)p3; (void)l3; (void)n; (void)timeout_ms;
    return -1;
}
XLANG_WEAK int32_t io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                                      uint32_t *out_lens) {
    (void)fd; (void)n; (void)timeout_ms; (void)out_bids; (void)out_lens;
    return -1;
}

int32_t net_stream_write_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                 uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    return io_write_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1, uint8_t *p2,
                                uintptr_t l2, uint8_t *p3, uintptr_t l3, int32_t n, uint32_t timeout_ms) {
    return io_read_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_provided_c(int32_t stream_fd, int32_t n, uint32_t timeout_ms, uint32_t *out_bids,
                                         uint32_t *out_lens) {
    return io_read_batch_provided(stream_fd, n, timeout_ms, out_bids, out_lens);
}
#endif /* !XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X */

/* ——— UDP 批量 recv/send（Buffer 切片）；从 net_import_alias.c 迁入（F-闭合） ——— */

/* 与 std.io.driver Buffer 布局一致（24 字节）。 */
typedef struct XlangBuffer {
  uint8_t *ptr;
  uintptr_t len;
  uintptr_t handle;
} XlangBuffer;

#if defined(__linux__) && defined(__GLIBC__)
extern int xlang_net_udp_recvmmsg_buf_c(int32_t fd, XlangBuffer *bufs, int n, uint32_t timeout_ms,
                                      int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports);
extern int xlang_net_udp_sendmmsg_buf_c(int32_t fd, const uint32_t *addrs_u32, const uint32_t *ports,
                                      const XlangBuffer *bufs, int n);
#endif

/* 【Why 根源】asm 对 `n > UDP_BATCH_BUF_MAX` 等常量比较 codegen 有误，batch 入口须走 C。
 * 从 net_import_alias.c 迁入（F-闭合消除 *_import_alias.c 命名）。
 * 【Invariant】n ∈ [1,8]；bufs/out_sizes/out_addrs/out_ports 各至少 n 个元素。
 * 【Asm/Perf】Linux 走 recvmmsg 单 syscall 批量收割；非 Linux 返回 -1。
 *
 * R2 mode: thin (.x) does input validation and calls _impl_c. This _impl_c
 * function contains the platform-specific syscall invocation. Always compiled
 * (both cold and R2 paths use it). */
int32_t net_udp_recv_many_buf_impl_c(int32_t fd, XlangBuffer *bufs, int32_t n, uint32_t timeout_ms,
                                int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
#if defined(__linux__) && defined(__GLIBC__)
    return (int32_t)xlang_net_udp_recvmmsg_buf_c(fd, bufs, (int)n, timeout_ms, out_sizes, out_addrs, out_ports);
#else
    (void)fd;
    (void)bufs;
    (void)n;
    (void)timeout_ms;
    (void)out_sizes;
    (void)out_addrs;
    (void)out_ports;
    return -1;
#endif
}

/* 【Why 根源】同 net_udp_recv_many_buf_c；Linux 走 sendmmsg 单 syscall 批量发送。
 * R2 mode: thin (.x) does input validation and calls _impl_c. Always compiled. */
int32_t net_udp_send_many_buf_impl_c(int32_t fd, uint32_t *addrs, uint32_t *ports, XlangBuffer *bufs, int32_t n) {
#if defined(__linux__) && defined(__GLIBC__)
    return (int32_t)xlang_net_udp_sendmmsg_buf_c(fd, addrs, ports, bufs, (int)n);
#else
    (void)fd;
    (void)addrs;
    (void)ports;
    (void)bufs;
    (void)n;
    return -1;
#endif
}

#ifndef XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X
/* Cold path wrappers: when XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X is NOT
 * defined, these _c wrappers provide the full implementation (validation +
 * syscall). When the guard IS defined, the thin (.x) provides the _c
 * wrappers and calls the _impl_c functions above. */
int32_t net_udp_recv_many_buf_c(int32_t fd, XlangBuffer *bufs, int32_t n, uint32_t timeout_ms,
                                int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
    if (n <= 0 || n > 8 || !bufs || !out_sizes || !out_addrs || !out_ports)
        return -1;
    return net_udp_recv_many_buf_impl_c(fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports);
}

int32_t net_udp_send_many_buf_c(int32_t fd, uint32_t *addrs, uint32_t *ports, XlangBuffer *bufs, int32_t n) {
    if (n <= 0 || n > 8 || !addrs || !ports || !bufs)
        return -1;
    return net_udp_send_many_buf_impl_c(fd, addrs, ports, bufs, n);
}
#endif /* !XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X */
