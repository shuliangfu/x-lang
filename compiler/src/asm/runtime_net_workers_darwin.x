// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_net_workers_darwin.x — Darwin arm64 whole body of
// runtime_net_workers.o.
//
// The cold ensure path pure-asms this file and does not pass
// seeds/runtime_net_workers.from_x.c to host cc. Linux and Windows
// still compile that seed. The accept loop there is a static C
// function, and the public entry returns its address.
//
// src/asm/runtime_net_workers.x stays the shared thin: it forwards to
// the C _impl. Compiling that thin still leaves the C rest on host cc.
// Darwin does not compile that thin. This file is the only Darwin body.
//
// A function name used as a pointer value makes this compiler exit 139.
// The entry looks the loop up with dlsym(RTLD_DEFAULT). RTLD_DEFAULT is
// the pointer value -2. The entry also calls the loop with a null
// argument so the symbol is a real reference and is not dropped by
// dead_strip. A null argument returns at once. A real worker argument
// does not.
//
// The C loop keeps a 64-wide i32 array on the stack. That array is 256
// bytes, and this compiler's frame does not cover a slot that large.
// The Darwin loop mallocs 256 bytes once and reuses that buffer. The
// bytes are the same int32_t[64] the accept call fills.
//
// Each function has one loop at most. Two loop headers in one function
// replace the length register with the compare result. A pointer
// argument of an extern call is loaded in a helper. Putting that
// pointer in the same call as a field load makes this compiler return
// -5 and emit no object.
//
// thread_set_affinity_self_c is the weak no-op. std.thread's strong
// definition wins when that object is linked. The ensure path weakens
// only this name.
//
// This object is a user / STD_AND_PANIC companion. It is not in the g05
// compiler image. A missing object after pure-asm faults falls back to
// the C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Worker argument. Same layout as struct xlang_net_worker_arg in the
 * C seed: three 4-byte fields, no padding.
 * PLATFORM: SHARED
 */
struct NetWorkerArg {
  listener_fd: i32;
  timeout_ms: i32;
  worker_index: i32;
}

/**
 * Heap buffer for one accept batch. 64 i32 slots are 256 bytes.
 * @param n usize — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: usize): *u8;

/**
 * Accept up to n sockets on listener_fd into out_fds.
 * @param listener_fd i32 — listening socket
 * @param out_fds *u8 — int32_t[n] buffer
 * @param n i32 — capacity in elements
 * @param timeout_ms i32 — wait budget; bits match the C uint32_t
 * @return i32 — count, or a negative error
 * PLATFORM: SHARED
 */
export extern "C" function net_accept_many_c(listener_fd: i32, out_fds: *u8, n: i32, timeout_ms: i32): i32;

/**
 * Close one accepted socket.
 * @param fd i32 — socket
 * @return i32 — 0 on success
 * PLATFORM: SHARED
 */
export extern "C" function net_close_socket_c(fd: i32): i32;

/**
 * libSystem dlsym. RTLD_DEFAULT is the pointer value -2.
 * @param handle *u8 — RTLD_DEFAULT or a dlopen handle
 * @param name *u8 — NUL-terminated symbol, no leading underscore
 * @return *u8 — symbol address, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlsym(handle: *u8, name: *u8): *u8;

/**
 * Doc anchor for this translation unit.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_net_workers_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Weak default for thread CPU affinity. Returns 0. The strong
 * thread_set_affinity_self_c in the thread object replaces this
 * when both are linked. The ensure path weakens this name.
 * @param cpu_index i32 — logical CPU; ignored by the weak body
 * @return i32 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function thread_set_affinity_self_c(cpu_index: i32): i32 {
  if (cpu_index < 0) {
    return 0;
  }
  return 0;
}

/**
 * Darwin RTLD_DEFAULT.
 * @return *u8 — pointer value -2
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function net_worker_rtld_default(): *u8 {
  let n: i64 = 0 - 2;
  return n as *u8;
}

/**
 * Load fds[i] as a little-endian i32. The compiler zero-extends each
 * byte. A normal socket fd has a zero high half, so the 32-bit
 * multiply of that half stays in range.
 * @param fds *u8 — int32_t array
 * @param i i32 — element index
 * @return i32 — the element
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function net_worker_load_fd(fds: *u8, i: i32): i32 {
  let b: i32 = i * 4;
  let b0: i32 = fds[b] as i32;
  let b1: i32 = fds[b + 1] as i32;
  let b2: i32 = fds[b + 2] as i32;
  let b3: i32 = fds[b + 3] as i32;
  return b0 + (b1 * 256) + (b2 * 65536) + (b3 * 16777216);
}

/**
 * Close the first n accepted fds. One loop. n <= 0 closes nothing.
 * @param fds *u8 — int32_t array filled by net_accept_many_c
 * @param n i32 — count returned by accept
 * @return i32 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function net_worker_close_n(fds: *u8, n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let fd: i32 = net_worker_load_fd(fds, i);
    unsafe { net_close_socket_c(fd); }
    i = i + 1;
  }
  return 0;
}

/**
 * One 256-byte batch buffer. 64 i32 slots.
 * @return *u8 — buffer, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function net_worker_alloc_fds(): *u8 {
  let nbuf: usize = 256;
  unsafe { return malloc(nbuf); }
}

/**
 * Call net_accept_many_c. The buffer is a parameter so the call does
 * not also load a struct field. That pairing makes this compiler
 * return -5.
 * @param fd i32 — listener
 * @param fds *u8 — int32_t[64] buffer
 * @param n i32 — element capacity
 * @param ms i32 — timeout
 * @return i32 — accept count, or a negative error
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function net_worker_call_accept(fd: i32, fds: *u8, n: i32, ms: i32): i32 {
  unsafe { return net_accept_many_c(fd, fds, n, ms); }
}

/**
 * Accept-worker thread body. A null arg returns null so the entry can
 * reference this symbol. Otherwise arg is a NetWorkerArg. The loop
 * accepts and closes until the process exits. One loop.
 * @param arg *u8 — null, or the address of a NetWorkerArg
 * @return *u8 — null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_worker_accept_loop(arg: *u8): *u8 {
  if (arg == 0) {
    return 0;
  }
  let a: *NetWorkerArg = arg as *NetWorkerArg;
  let cpu: i32 = a.worker_index;
  thread_set_affinity_self_c(cpu);
  let raw: *u8 = net_worker_alloc_fds();
  if (raw == 0) {
    return 0;
  }
  // One loop. The flag is a local that this body does not clear.
  let spin: i32 = 1;
  while (spin == 1) {
    let fd: i32 = a.listener_fd;
    let ms: i32 = a.timeout_ms;
    let n: i32 = net_worker_call_accept(fd, raw, 64, ms);
    net_worker_close_n(raw, n);
  }
  return 0;
}

/**
 * Address of the accept loop, as a pointer-sized integer.
 * dlsym avoids using the function name as a pointer value.
 * A direct null call keeps the loop in the link.
 * @return u64 — address, or 0 if dlsym fails
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_worker_accept_entry_ptr_impl_c(): u64 {
  xlang_net_worker_accept_loop(0);
  unsafe {
    let handle: *u8 = net_worker_rtld_default();
    let name: *u8 = "xlang_net_worker_accept_loop";
    let fp: *u8 = dlsym(handle, name);
    if (fp == 0) {
      return 0;
    }
    return fp as u64;
  }
}

/**
 * Public entry. Same bits as the _impl.
 * @return u64 — address of xlang_net_worker_accept_loop
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_net_worker_accept_entry_ptr_c(): u64 {
  return xlang_net_worker_accept_entry_ptr_impl_c();
}
