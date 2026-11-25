/* seeds/runtime_net_io_batch_fast.from_x.c — G-02f-20 product TU
 * Product: ../std/net/net_io_batch_fast.o
 * w1098: Darwin arm64 product body is src/asm/runtime_net_io_batch_fast.x
 * plus src/asm/runtime_net_io_batch_fast_darwin.x (pure asm, then ld -r).
 * The Darwin _impl bridges return -1. Linux recvmmsg/sendmmsg, Windows,
 * and the pure-asm-fault backup stay this C seed.
 * PLATFORM: SHARED seed; MACOS|DARWIN arm64 prefers the .x pair.
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
/* 记253／9.1: cold under #ifndef XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X removed */
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
#endif /* !XLANG_RUNTIME_NET_IO_BATCH_FAST_FROM_X */
