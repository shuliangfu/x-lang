// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 migration of runtime_net_io_batch_fast: pure-computation wrappers for
// stream/UDP batch IO.
//
// Architecture (thin + rest):
//   - thin (.x): 7 public API wrappers + 3 weak io_* defaults. The stream
//     wrappers just forward to io_* (weak or strong). The UDP wrappers do
//     input validation then call _impl bridge functions (defined in rest).
//   - rest (.from_x.c): 2 _impl bridge functions containing the Linux-only
//     recvmmsg/sendmmsg syscall invocations, guarded by
//     #if defined(__linux__) && defined(__GLIBC__). On non-Linux the _impl
//     returns -1.
//
// Why thin+rest (not DIRECT): the UDP batch functions need platform-specific
// syscall calls (recvmmsg/sendmmsg) that cannot be expressed in .x. The _impl
// bridge keeps the Linux-only code in C while exposing the public API from .x.
//
// PLATFORM: SHARED net
// Build: thin+rest ld -r (see Makefile net.o rule).

// runtime_net_io_batch_fast_x_doc_anchor: see function docblock below.

/** Exported function `runtime_net_io_batch_fast_x_doc_anchor`.
 * Anchor for codegen discovery of this TU. Returns 0.
 * @return i32 always 0
 */
export function runtime_net_io_batch_fast_x_doc_anchor(): i32 {
  return 0;
}

// ---------------------------------------------------------------------------
// Weak io_* stubs. These provide default "unsupported" implementations (-1).
// When a user imports std.io.sync, the strong #[no_mangle] symbols defined
// there override these weak ones at link time (C linker prefers strong over
// weak). Mirrors the XLANG_WEAK semantics in the C seed.
// ---------------------------------------------------------------------------

/**
 * Weak default for batched read. Returns -1 (unsupported) unless overridden by
 * std.io.sync's strong #[no_mangle] definition at link time.
 * @param fd socket file descriptor
 * @param p0..p3 scatter buffers (4 slots)
 * @param l0..l3 lengths matching p0..p3
 * @param n number of buffers to read
 * @param timeout_ms max wait time in milliseconds
 * @return bytes read on success; -1 if no strong implementation is linked
 */
#[no_mangle]
export function io_read_batch(fd: i32, p0: *u8, l0: u64, p1: *u8, l1: u64, p2: *u8, l2: u64, p3: *u8, l3: u64, n: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/**
 * Weak default for batched write. Returns -1 (unsupported) unless overridden by
 * std.io.sync's strong #[no_mangle] definition at link time.
 * @param fd socket file descriptor
 * @param p0..p3 gather buffers (4 slots)
 * @param l0..l3 lengths matching p0..p3
 * @param n number of buffers to write
 * @param timeout_ms max wait time in milliseconds
 * @return bytes written on success; -1 if no strong implementation is linked
 */
#[no_mangle]
export function io_write_batch(fd: i32, p0: *u8, l0: u64, p1: *u8, l1: u64, p2: *u8, l2: u64, p3: *u8, l3: u64, n: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/**
 * Weak default for "provided buffer" batched read. Returns -1 (unsupported)
 * unless overridden by std.io.sync's strong #[no_mangle] definition at link time.
 * @param fd socket file descriptor
 * @param n number of buffers to read
 * @param timeout_ms max wait time in milliseconds
 * @param out_bids output buffer IDs (caller-allocated, n slots)
 * @param out_lens output lengths (caller-allocated, n slots)
 * @return buffers read on success; -1 if no strong implementation is linked
 */
#[no_mangle]
export function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  return 0 - 1;
}

// ---------------------------------------------------------------------------
// Stream batch wrappers — forward to io_read_batch/io_write_batch/
// io_read_batch_provided. These are the public API consumed by std.net.
// ---------------------------------------------------------------------------

/**
 * Batched write to a stream socket. Forwards to the (possibly weak)
 * io_write_batch implementation.
 * @param stream_fd connected stream socket fd
 * @param p0..p3 gather buffers (4 slots)
 * @param l0..l3 lengths matching p0..p3
 * @param n number of buffers to write
 * @param timeout_ms max wait time in milliseconds
 * @return bytes written, or -1 on error / unsupported
 */
#[no_mangle]
export function net_stream_write_batch_c(stream_fd: i32, p0: *u8, l0: u64, p1: *u8, l1: u64, p2: *u8, l2: u64, p3: *u8, l3: u64, n: i32, timeout_ms: u32): i32 {
  return io_write_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

/**
 * Batched read from a stream socket. Forwards to the (possibly weak)
 * io_read_batch implementation.
 * @param stream_fd connected stream socket fd
 * @param p0..p3 scatter buffers (4 slots)
 * @param l0..l3 lengths matching p0..p3
 * @param n number of buffers to read
 * @param timeout_ms max wait time in milliseconds
 * @return bytes read, or -1 on error / unsupported
 */
#[no_mangle]
export function net_stream_read_batch_c(stream_fd: i32, p0: *u8, l0: u64, p1: *u8, l1: u64, p2: *u8, l2: u64, p3: *u8, l3: u64, n: i32, timeout_ms: u32): i32 {
  return io_read_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

/**
 * Batched read from a stream socket using caller-provided buffer slots.
 * Forwards to the (possibly weak) io_read_batch_provided implementation.
 * @param stream_fd connected stream socket fd
 * @param n number of buffers to read
 * @param timeout_ms max wait time in milliseconds
 * @param out_bids output buffer IDs (caller-allocated, n slots)
 * @param out_lens output lengths (caller-allocated, n slots)
 * @return buffers read, or -1 on error / unsupported
 */
#[no_mangle]
export function net_stream_read_batch_provided_c(stream_fd: i32, n: i32, timeout_ms: u32, out_bids: *u32, out_lens: *u32): i32 {
  return io_read_batch_provided(stream_fd, n, timeout_ms, out_bids, out_lens);
}

// ---------------------------------------------------------------------------
// UDP batch recv/send: input validation in thin, syscall invocation in rest.
// The _impl bridges live in rest (.from_x.c) and contain the Linux-only
// recvmmsg/sendmmsg syscalls (guarded by #if defined(__linux__) && __GLIBC__).
// ---------------------------------------------------------------------------

// Bridge declarations for the rest-side _impl functions. The rest side keeps
// the platform-specific syscall code in C, returning -1 on non-Linux.
export extern "C" function net_udp_recv_many_buf_impl(fd: i32, bufs: *u8, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32;
export extern "C" function net_udp_send_many_buf_impl(fd: i32, addrs: *u32, ports: *u32, bufs: *u8, n: i32): i32;

/**
 * Batched UDP receive via Buffer slices. Validates inputs then forwards to
 * net_udp_recv_many_buf_impl (rest). Linux uses recvmmsg (single syscall);
 * non-Linux _impl returns -1 (unsupported).
 *
 * Invariant: n in [1, 8]; bufs/out_sizes/out_addrs/out_ports each have at
 * least n elements.
 *
 * @param fd UDP socket fd
 * @param bufs output Buffer slices (caller-allocated, n slots)
 * @param n number of buffers (must be in [1, 8])
 * @param timeout_ms max wait time in milliseconds
 * @param out_sizes output received sizes (n slots)
 * @param out_addrs output source IPv4 addresses (n slots)
 * @param out_ports output source ports (n slots)
 * @return number of packets received, or -1 on error / non-Linux
 */
#[no_mangle]
export function net_udp_recv_many_buf_c(fd: i32, bufs: *u8, n: i32, timeout_ms: u32, out_sizes: *i32, out_addrs: *u32, out_ports: *u32): i32 {
  if (n <= 0) { return 0 - 1; }
  if (n > 8) { return 0 - 1; }
  if (bufs == 0) { return 0 - 1; }
  if (out_sizes == 0) { return 0 - 1; }
  if (out_addrs == 0) { return 0 - 1; }
  if (out_ports == 0) { return 0 - 1; }
  unsafe { return net_udp_recv_many_buf_impl(fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports); }
}

/**
 * Batched UDP send via Buffer slices. Validates inputs then forwards to
 * net_udp_send_many_buf_impl (rest). Linux uses sendmmsg (single syscall);
 * non-Linux _impl returns -1 (unsupported).
 *
 * Invariant: n in [1, 8]; addrs/ports/bufs each have at least n elements.
 *
 * @param fd UDP socket fd
 * @param addrs destination IPv4 addresses (n slots)
 * @param ports destination ports (n slots)
 * @param bufs Buffer slices to send (n slots)
 * @param n number of buffers (must be in [1, 8])
 * @return number of packets sent, or -1 on error / non-Linux
 */
#[no_mangle]
export function net_udp_send_many_buf_c(fd: i32, addrs: *u32, ports: *u32, bufs: *u8, n: i32): i32 {
  if (n <= 0) { return 0 - 1; }
  if (n > 8) { return 0 - 1; }
  if (addrs == 0) { return 0 - 1; }
  if (ports == 0) { return 0 - 1; }
  if (bufs == 0) { return 0 - 1; }
  unsafe { return net_udp_send_many_buf_impl(fd, addrs, ports, bufs, n); }
}
