// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_asm_io_stubs.x — user-program link stubs for -backend asm (5.7a / w1515).
//
// std.io family .x modules skip machine code in the asm pipeline; this object
// supplies the C ABI print_* / write_* / read_ptr / fmt / JSON-schema / io stub
// surface linked into user executables (and the g05 compiler link on Darwin and
// Windows). Since w1516 (5.7b) this .x is the only source; the C seed is gone.
//
// Build (scripts/g05_ensure_relink_prereqs.sh, w1516): on all three hosts this
// .x is the whole object (product pure asm, no host cc). Linux cpu detect and
// the Linux ptr_view sret faces live here since 5.7b; the old backtrace weak
// probe stubs and Linux UDP batch include were dropped (no referencing object;
// user links get the strong runtime_backtrace_platform.o / runtime_net_udp_batch.o).
//   · Weak faces: g05 passes G05_X_O_WEAK_FUNCS (Darwin/Linux: the historic
//     XLANG_WEAK io faces plus xlang_target_cpu_detect_host; Windows:
//     xlang_target_cpu_detect_host only).
//
// Helpers are named rais_* (non-export functions still emit as global T).
// Module cells use the one-element array form (g_x[0]).
//
// Struct ABI note: std_io_ptr_view / stdin_ptr_view (24B return) and
// std_io_ptr_view_valid (24B by value) follow the product call convention,
// which is what product-compiled user programs emit (not the host C ABI).
//
// PLATFORM: MACOS|DARWIN arm64 · LINUX x86_64 · WINDOWS x86_64.

// ---- platform write / read / writev (xlang_io_cap.h twin) ----

#[cfg(target_os = "macos")]
extern "C" function write(fd: i32, buf: *u8, n: usize): i64;
#[cfg(target_os = "macos")]
extern "C" function read(fd: i32, buf: *u8, n: usize): i64;
#[cfg(target_os = "macos")]
extern "C" function writev(fd: i32, iov: *u8, cnt: i32): i64;
#[cfg(target_os = "macos")]
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, off: i64): *u8;
#[cfg(target_os = "macos")]
extern "C" function munmap(addr: *u8, len: usize): i32;

#[cfg(target_os = "linux")]
extern function raw_syscall3(nr: i64, a1: i64, a2: i64, a3: i64): i64;
#[cfg(target_os = "linux")]
extern "C" function __errno_location(): *i32;
#[cfg(target_os = "linux")]
extern "C" function mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, off: i64): *u8;
#[cfg(target_os = "linux")]
extern "C" function munmap(addr: *u8, len: usize): i32;

#[cfg(target_os = "windows")]
extern "C" function _write(fd: i32, buf: *u8, n: u32): i32;
#[cfg(target_os = "windows")]
extern "C" function _read(fd: i32, buf: *u8, n: u32): i32;

/**
 * Linux x86_64 raw syscall with three arguments.
 * Kept alone in its own function: locals declared after an inline
 * raw_syscall in the same body can land outside the frame (logged debt).
 * PLATFORM: LINUX x86_64
 */
#[cfg(target_os = "linux")]
function rais_sys3(nr: i64, a1: i64, a2: i64, a3: i64): i64 {
  unsafe {
    return raw_syscall3(nr, a1, a2, a3);
  }
  return 0;
}

/**
 * Map a raw Linux syscall result: negative sets errno and returns -1.
 * PLATFORM: LINUX
 */
#[cfg(target_os = "linux")]
function rais_sys_ret(r: i64): i64 {
  if (r < 0) {
    unsafe {
      let ep: *i32 = __errno_location();
      *ep = (0 - r) as i32;
    }
    return 0 - 1;
  }
  return r;
}

/** xlang_io_write twin. PLATFORM: MACOS */
#[cfg(target_os = "macos")]
function rais_io_write(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  unsafe {
    return write(fd, buf, count);
  }
  return 0 - 1;
}

/** xlang_io_read twin. PLATFORM: MACOS */
#[cfg(target_os = "macos")]
function rais_io_read(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  unsafe {
    return read(fd, buf, count);
  }
  return 0 - 1;
}

/** xlang_io_writev twin. PLATFORM: MACOS */
#[cfg(target_os = "macos")]
function rais_io_writev(fd: i32, iov: *u8, iovcnt: i32): i64 {
  if (iovcnt == 0) { return 0; }
  if (iov == 0 as *u8) { return 0 - 1; }
  unsafe {
    return writev(fd, iov, iovcnt);
  }
  return 0 - 1;
}

/** xlang_io_write twin (syscall 1). PLATFORM: LINUX x86_64 */
#[cfg(target_os = "linux")]
function rais_io_write(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  return rais_sys_ret(rais_sys3(1, fd as i64, buf as i64, count as i64));
}

/** xlang_io_read twin (syscall 0). PLATFORM: LINUX x86_64 */
#[cfg(target_os = "linux")]
function rais_io_read(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  return rais_sys_ret(rais_sys3(0, fd as i64, buf as i64, count as i64));
}

/** xlang_io_writev twin (syscall 20). PLATFORM: LINUX x86_64 */
#[cfg(target_os = "linux")]
function rais_io_writev(fd: i32, iov: *u8, iovcnt: i32): i64 {
  if (iovcnt == 0) { return 0; }
  if (iov == 0 as *u8) { return 0 - 1; }
  return rais_sys_ret(rais_sys3(20, fd as i64, iov as i64, iovcnt as i64));
}

/** xlang_io_write twin (_write). PLATFORM: WINDOWS */
#[cfg(target_os = "windows")]
function rais_io_write(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  let r: i32 = 0;
  unsafe {
    r = _write(fd, buf, count as u32);
  }
  return r as i64;
}

/** xlang_io_read twin (_read). PLATFORM: WINDOWS */
#[cfg(target_os = "windows")]
function rais_io_read(fd: i32, buf: *u8, count: usize): i64 {
  if (count == 0) { return 0; }
  if (buf == 0 as *u8) { return 0 - 1; }
  let r: i32 = 0;
  unsafe {
    r = _read(fd, buf, count as u32);
  }
  return r as i64;
}

/**
 * xlang_io_writev twin: loop of _write over {base,len} pairs (16B each).
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
function rais_io_writev(fd: i32, iov: *u8, iovcnt: i32): i64 {
  if (iovcnt == 0) { return 0; }
  if (iov == 0 as *u8) { return 0 - 1; }
  let pp: *u64 = iov as *u64;
  let total: u64 = 0;
  let i: i32 = 0;
  while (i < iovcnt) {
    let base: u64 = pp[i * 2];
    let ln: u64 = pp[i * 2 + 1];
    if (base != 0 && ln != 0) {
      let n: i32 = 0;
      unsafe {
        n = _write(fd, base as *u8, ln as u32);
      }
      if (n < 0) {
        if (total > 0) { return total as i64; }
        return 0 - 1;
      }
      total = total + (n as u64);
      if ((n as u64) < ln) { break; }
    }
    i = i + 1;
  }
  return total as i64;
}

// ---- integer text (snprintf %d/%u/%lld/%llu twin) ----

/** Write decimal digits of v into out; return byte count. PLATFORM: SHARED */
function rais_u64_digits(v: u64, out: *u8): i32 {
  let tmp: u8[24] = [];
  let n: i32 = 0;
  let x: u64 = v;
  if (x == 0) {
    out[0] = 48;
    return 1;
  }
  // Product arm64 emits sdiv for u64 `/` (debt 10.56): peel the top bit first.
  // 2^63 = 10 * 922337203685477580 + 8.
  if ((x as i64) < 0) {
    let h: u64 = x & 9223372036854775807;
    let r: u64 = (h % 10) + 8;
    tmp[0] = (48 + (r % 10)) as u8;
    n = 1;
    x = (h / 10) + 922337203685477580 + (r / 10);
  }
  while (x > 0) {
    let d: u64 = x % 10;
    tmp[n] = (48 + d) as u8;
    x = x / 10;
    n = n + 1;
  }
  let k: i32 = 0;
  while (k < n) {
    out[k] = tmp[n - 1 - k];
    k = k + 1;
  }
  return n;
}

/** Print unsigned v to fd 1, optional trailing newline. PLATFORM: SHARED */
function rais_print_u64(v: u64, nl: i32): void {
  let b: u8[32] = [];
  let n: i32 = rais_u64_digits(v, &b[0]);
  if (nl != 0) {
    b[n] = 10;
    n = n + 1;
  }
  rais_io_write(1, &b[0], n as usize);
}

/** Print signed v to fd 1, optional trailing newline. PLATFORM: SHARED */
function rais_print_i64(v: i64, nl: i32): void {
  let b: u8[32] = [];
  let n: i32 = 0;
  let u: u64 = v as u64;
  if (v < 0) {
    b[0] = 45;
    n = 1;
    u = (0 as u64) - u;
  }
  let m: i32 = rais_u64_digits(u, &b[n]);
  n = n + m;
  if (nl != 0) {
    b[n] = 10;
    n = n + 1;
  }
  rais_io_write(1, &b[0], n as usize);
}

/** io_cap_putc twin. PLATFORM: SHARED */
function rais_putc(c: i32): void {
  let ch: u8[1] = [0];
  ch[0] = c as u8;
  rais_io_write(1, &ch[0], 1);
}

/** io_cap_puts twin for a NUL-terminated literal. PLATFORM: SHARED */
function rais_puts(s: *u8): void {
  if (s == 0 as *u8) { return; }
  let n: usize = 0;
  while (s[n] != 0) {
    n = n + 1;
  }
  rais_io_write(1, s, n);
}

// ---- seed syscall faces / xlang_sys_* ----

/** Exported function `runtime_asm_io_stubs_x_doc_anchor` (cold tooling anchor). */
#[no_mangle]
export function runtime_asm_io_stubs_x_doc_anchor(): i32 {
  return 0;
}

/** seed write via the platform IO face. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_syscall_write_impl(fd: i32, buf: *u8, count: usize): i64 {
  return rais_io_write(fd, buf, count);
}

/** seed read via the platform IO face. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_syscall_read_impl(fd: i32, buf: *u8, count: usize): i64 {
  return rais_io_read(fd, buf, count);
}

/** Public wrapper over seed_io_syscall_write_impl. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_syscall_write(fd: i32, buf: *u8, count: usize): i64 {
  return seed_io_syscall_write_impl(fd, buf, count);
}

/** Public wrapper over seed_io_syscall_read_impl. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_syscall_read(fd: i32, buf: *u8, count: usize): i64 {
  return seed_io_syscall_read_impl(fd, buf, count);
}

/** Weak write for std.io / std.fs asm objects. PLATFORM: SHARED */
#[no_mangle]
export function xlang_sys_write(fd: i32, buf: *u8, count: usize): i64 {
  return rais_io_write(fd, buf, count);
}

/** Weak read for std.io / std.fs asm objects. PLATFORM: SHARED */
#[no_mangle]
export function xlang_sys_read(fd: i32, buf: *u8, count: usize): i64 {
  return rais_io_read(fd, buf, count);
}

/** Weak writev for std.io / std.fs asm objects. PLATFORM: SHARED */
#[no_mangle]
export function xlang_sys_writev(fd: i32, iov: *u8, iovcnt: i32): i64 {
  return rais_io_writev(fd, iov, iovcnt);
}

/**
 * Weak host CPU feature bits (strong twin src/driver/target_cpu.o).
 * Darwin arm64 is NEON (256).
 * PLATFORM: MACOS arm64
 */
#[cfg(target_os = "macos")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 256;
}

/**
 * Linux x86_64 host CPU bits from the /proc/cpuinfo "flags" line: SSE2 (1)
 * for " sse2" or "\tsse2", AVX2 (8) for " avx2"; no flags line or an
 * unreadable file gives the SSE2 minimum (1). Reads at most 8191 bytes like
 * the seed's xlang_proc_read_file. 5.7b (w1516) port of the seed residual.
 * PLATFORM: LINUX x86_64
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  let buf: u8[8192] = [];
  let path: *u8 = "/proc/cpuinfo";
  let fd: i64 = 0;
  let n: i64 = 0;
  let got: i32 = 0;
  let ls: i32 = 0;
  let le: i32 = 0;
  let k: i32 = 0;
  let f: u32 = 0;
  let done: i32 = 0;
  fd = rais_sys3(2, path as i64, 0, 0);
  if (fd < 0) { return 1; }
  while (got < 8191) {
    n = rais_sys3(0, fd, (&buf[got]) as i64, (8191 - got) as i64);
    if (n <= 0) { break; }
    got = got + (n as i32);
  }
  rais_sys3(3, fd, 0, 0);
  if (got <= 0) { return 1; }
  buf[got] = 0;
  while (ls < got && done == 0) {
    le = ls;
    while (le < got && buf[le] != 10) { le = le + 1; }
    if (le - ls >= 5 && buf[ls] == 102 && buf[ls + 1] == 108 && buf[ls + 2] == 97
        && buf[ls + 3] == 103 && buf[ls + 4] == 115) {
      k = ls;
      while (k + 5 <= le) {
        if ((buf[k] == 32 || buf[k] == 9) && buf[k + 1] == 115 && buf[k + 2] == 115
            && buf[k + 3] == 101 && buf[k + 4] == 50) {
          f = f | 1;
        }
        if (buf[k] == 32 && buf[k + 1] == 97 && buf[k + 2] == 118 && buf[k + 3] == 120
            && buf[k + 4] == 50) {
          f = f | 8;
        }
        k = k + 1;
      }
      done = 1;
    }
    ls = le + 1;
  }
  if (f != 0) { return f; }
  return 1;
}

/** Windows x86_64 host CPU bits: SSE2 (1). PLATFORM: WINDOWS x86_64 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 1;
}

// ---- sync io_write / io_read ----

/** Sync write; timeout ignored in the stub. PLATFORM: SHARED */
#[no_mangle]
export function io_write(fd: i32, buf: *u8, count: usize, timeout_ms: u32): i64 {
  if (buf == 0 as *u8 && count > 0) { return 0 - 1; }
  return seed_io_syscall_write(fd, buf, count);
}

/** Sync read; timeout ignored in the stub. PLATFORM: SHARED */
#[no_mangle]
export function io_read(fd: i32, buf: *u8, count: usize, timeout_ms: u32): i64 {
  if (buf == 0 as *u8 && count > 0) { return 0 - 1; }
  return seed_io_syscall_read(fd, buf, count);
}

// ---- read_ptr single buffer (G.7) ----

let g_rais_read_ptr_buf: u8[4096] = [];
let g_rais_read_ptr_len: i32[1] = [0];
let g_rais_read_ptr_gen: u64[1] = [0];
let g_rais_read_ptr_backend: i32[1] = [0];

/** Zero-copy read into the single buffer; EOF/error returns null. PLATFORM: SHARED */
#[no_mangle]
export function io_read_ptr(handle: u32, timeout_ms: u32): *u8 {
  g_rais_read_ptr_gen[0] = g_rais_read_ptr_gen[0] + 1;
  g_rais_read_ptr_backend[0] = 0;
  g_rais_read_ptr_len[0] = 0;
  let r: i64 = io_read(handle as i32, &g_rais_read_ptr_buf[0], 4096, 0);
  if (r <= 0) { return 0 as *u8; }
  g_rais_read_ptr_len[0] = r as i32;
  return &g_rais_read_ptr_buf[0];
}

/** Length of the last io_read_ptr fill. PLATFORM: SHARED */
#[no_mangle]
export function io_read_ptr_len(): i32 {
  return g_rais_read_ptr_len[0];
}

/** Single buffer registration stub. PLATFORM: SHARED */
#[no_mangle]
export function io_register_buffer(ptr: *u8, len: usize): i32 {
  return 0;
}

/** Three-arg register (weak; std/io/core.x strong wins). PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_register(ptr: *u8, len: usize, handle: usize): i32 {
  return io_register_buffer(ptr, len);
}

/** Buffer descriptor {ptr,length,handle} register. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_register_buf(buf: i64): i32 {
  if (buf == 0) { return 0 - 1; }
  let pp: *u64 = buf as *u64;
  let p: u64 = pp[0];
  let ln: u64 = pp[1];
  let h: u64 = pp[2];
  return xlang_io_register(p as *u8, ln as usize, h as usize);
}

/** submit_read stub (weak; core.x strong wins). PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_submit_read(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  return 0;
}

/** submit_write stub (weak; core.x strong wins). PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_submit_write(ptr: *u8, len: usize, handle: usize, timeout_ms: u32): i32 {
  return 0;
}

/** stdin handle 0. PLATFORM: SHARED */
#[no_mangle]
export function std_io_handle_stdin(): usize {
  return 0;
}

/** stdout handle 1. PLATFORM: SHARED */
#[no_mangle]
export function std_io_handle_stdout(): usize {
  return 1;
}

/** stderr handle 2. PLATFORM: SHARED */
#[no_mangle]
export function std_io_handle_stderr(): usize {
  return 2;
}

/** io.stdin() mangle face. PLATFORM: SHARED */
#[no_mangle]
export function std_io_stdin(): usize {
  return std_io_handle_stdin();
}

/** io.stdout() mangle face. PLATFORM: SHARED */
#[no_mangle]
export function std_io_stdout(): usize {
  return std_io_handle_stdout();
}

/** io.stderr() mangle face. PLATFORM: SHARED */
#[no_mangle]
export function std_io_stderr(): usize {
  return std_io_handle_stderr();
}

/** io.write(handle, ptr, len, timeout). PLATFORM: SHARED */
#[no_mangle]
export function std_io_write(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  let r: i64 = io_write(handle as i32, ptr, len, timeout_ms);
  if (r < 0) { return 0 - 1; }
  return r as i32;
}

/** io.read(handle, ptr, len, timeout). PLATFORM: SHARED */
#[no_mangle]
export function std_io_read(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32 {
  let r: i64 = io_read(handle as i32, ptr, len, timeout_ms);
  if (r < 0) { return 0 - 1; }
  return r as i32;
}

/** from_fd is identity (std/io/mod.x). PLATFORM: SHARED */
#[no_mangle]
export function std_io_from_fd(fd: i32, unused: i32): usize {
  return fd as usize;
}

/** read_fd with timeout 0. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return std_io_read(fd as usize, ptr, len, 0);
}

/** write_fd with timeout 0. PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_fd(fd: i32, ptr: *u8, len: usize): i32 {
  return std_io_write(fd as usize, ptr, len, 0);
}

/** stdout write used by write_stdout / write_with_timeout. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_write_fd1_impl(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  if (ptr == 0 as *u8 && len > 0) { return 0 - 1; }
  let r: i64 = io_write(1, ptr, len, timeout_ms);
  if (r < 0) { return 0 - 1; }
  return r as i32;
}

/** Public wrapper over seed_io_write_fd1_impl. PLATFORM: SHARED */
#[no_mangle]
export function seed_io_write_fd1(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return seed_io_write_fd1_impl(ptr, len, timeout_ms);
}

/** io.print(i32) with newline. PLATFORM: SHARED */
#[no_mangle]
export function std_io_print_i32(x: i32): i32 {
  rais_print_i64(x as i64, 1);
  return 0;
}

/** io.print(u32) with newline. PLATFORM: SHARED */
#[no_mangle]
export function std_io_print_u32(x: u32): i32 {
  rais_print_u64(x as u64, 1);
  return 0;
}

/** io.print(i64) with newline. PLATFORM: SHARED */
#[no_mangle]
export function std_io_print_i64(x: i64): i32 {
  rais_print_i64(x, 1);
  return 0;
}

/** Weak stdout write. PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_stdout(ptr: *u8, len: usize): i32 {
  return seed_io_write_fd1(ptr, len, 0);
}

/** Weak stdout write with timeout. PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_with_timeout(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return seed_io_write_fd1(ptr, len, timeout_ms);
}

/** Overload mid io.write(ptr,len,timeout). PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_u8_ptr_usize_u32(ptr: *u8, len: usize, timeout_ms: u32): i32 {
  return seed_io_write_fd1(ptr, len, timeout_ms);
}

/** std.io.print(ptr,len). PLATFORM: SHARED */
#[no_mangle]
export function std_io_print_u8_ptr_usize(ptr: *u8, len: usize): i32 {
  let r: i32 = std_io_write_stdout(ptr, len);
  if (r >= 0) { return 0; }
  return 0 - 1;
}

/** Legacy link name std_io_print_str. PLATFORM: SHARED */
#[no_mangle]
export function std_io_print_str(ptr: *u8, len: usize): i32 {
  return std_io_print_u8_ptr_usize(ptr, len);
}

/** std.fmt.print(ptr,len) without newline. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print(ptr: *u8, len: usize): i32 {
  let r: i32 = std_io_print_str(ptr, len);
  if (r >= 0) { return 0; }
  return 0 - 1;
}

/** Overload mid print(*u8, i32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_u8_ptr_i32(ptr: *u8, len: i32): i32 {
  if (len < 0) { return 0 - 1; }
  return std_fmt_print(ptr, len as usize);
}

/** std.fmt.println(ptr,len): print plus one newline. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println(ptr: *u8, len: usize): i32 {
  let r: i32 = std_io_write_stdout(ptr, len);
  if (r < 0) { return 0 - 1; }
  let nl: u8[1] = [10];
  let rn: i32 = std_io_write_stdout(&nl[0], 1);
  if (rn >= 0) { return 0; }
  return 0 - 1;
}

/** Overload mid println(*u8, i32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_u8_ptr_i32(ptr: *u8, len: i32): i32 {
  if (len < 0) { return 0 - 1; }
  return std_fmt_println(ptr, len as usize);
}

/** NUL length capped at 1 MiB; -1 when over the cap. PLATFORM: SHARED */
function rais_cstr_len_cap(s: *u8): i64 {
  let len: u64 = 0;
  while (s[len] != 0) {
    len = len + 1;
    if (len > 1048576) { return 0 - 1; }
  }
  return len as i64;
}

/** println(*u8) NUL-terminated overload. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_u8_ptr(s: *u8): i32 {
  if (s == 0 as *u8) { return 0 - 1; }
  let n: i64 = rais_cstr_len_cap(s);
  if (n < 0) { return 0 - 1; }
  return std_fmt_println(s, n as usize);
}

/** print(*u8) NUL-terminated overload. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_u8_ptr(s: *u8): i32 {
  if (s == 0 as *u8) { return 0 - 1; }
  let n: i64 = rais_cstr_len_cap(s);
  if (n < 0) { return 0 - 1; }
  return std_fmt_print(s, n as usize);
}

/** fmt.print(i32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_i32(x: i32): i32 {
  rais_print_i64(x as i64, 0);
  return 0;
}

/** fmt.println(i32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_i32(x: i32): i32 {
  rais_print_i64(x as i64, 1);
  return 0;
}

/** fmt.print(u32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_u32(x: u32): i32 {
  rais_print_u64(x as u64, 0);
  return 0;
}

/** fmt.println(u32). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_u32(x: u32): i32 {
  rais_print_u64(x as u64, 1);
  return 0;
}

/** fmt.print(i64). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_i64(x: i64): i32 {
  rais_print_i64(x, 0);
  return 0;
}

/** fmt.println(i64). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_i64(x: i64): i32 {
  rais_print_i64(x, 1);
  return 0;
}

/** fmt.print(u64). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_u64(x: u64): i32 {
  rais_print_u64(x, 0);
  return 0;
}

/** fmt.println(u64). PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_u64(x: u64): i32 {
  rais_print_u64(x, 1);
  return 0;
}

/** u8[] slice {data,length}; passed by pointer to the slc mids. */
struct RaisSliceU8 {
  data: *u8;
  length: usize;
}

/** fmt.print(u8[]) — slice passed by address. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_print_u8_slc(s: *RaisSliceU8): i32 {
  if (s == 0 as *RaisSliceU8) { return 0 - 1; }
  return std_fmt_print(s.data, s.length);
}

/** fmt.println(u8[]) — slice passed by address. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_println_u8_slc(s: *RaisSliceU8): i32 {
  if (s == 0 as *RaisSliceU8) { return 0 - 1; }
  return std_fmt_println(s.data, s.length);
}

// ---- std.fmt JSON "print any" schema interpreter (seed twin) ----
// Schema: i@OFF · b@OFF · u@OFF,LEN · a@OFF,LEN · A@OFF · ?SOFF:VAL · {k:VAL,...}

/** Emit one JSON string byte with escapes. PLATFORM: SHARED */
function rais_json_escape_byte(c: i32): void {
  if (c == 92 || c == 34) {
    rais_putc(92);
    rais_putc(c);
    return;
  }
  if (c == 10) {
    rais_putc(92);
    rais_putc(110);
    return;
  }
  if (c == 13) {
    rais_putc(92);
    rais_putc(114);
    return;
  }
  if (c == 9) {
    rais_putc(92);
    rais_putc(116);
    return;
  }
  if (c < 32) {
    let b: u8[4] = [92, 120, 48, 48];
    let hi: i32 = (c >> 4) & 15;
    let lo: i32 = c & 15;
    if (hi < 10) { b[2] = (48 + hi) as u8; } else { b[2] = (87 + hi) as u8; }
    if (lo < 10) { b[3] = (48 + lo) as u8; } else { b[3] = (87 + lo) as u8; }
    rais_io_write(1, &b[0], 4);
    return;
  }
  rais_putc(c);
}

/** Parse optional '-' and decimal digits; store into *out; return the end. PLATFORM: SHARED */
function rais_parse_dec(p0: *u8, out: *i32): *u8 {
  let p: *u8 = p0;
  let v: i32 = 0;
  let neg: i32 = 0;
  if (p == 0 as *u8 || out == 0 as *i32) { return p; }
  let c: i32 = p[0] as i32;
  if (c == 45) {
    neg = 1;
    p = p + 1;
    c = p[0] as i32;
  }
  while (c >= 48 && c <= 57) {
    v = v * 10 + (c - 48);
    p = p + 1;
    c = p[0] as i32;
  }
  if (neg != 0) { out[0] = 0 - v; } else { out[0] = v; }
  return p;
}

/** Read the i32 at base+off+4*i. PLATFORM: SHARED */
function rais_i32_at(base: *u8, off: i32, i: i32): i32 {
  let q: *u8 = base + off;
  let ap: *i32 = q as *i32;
  return ap[i];
}

/** Emit one schema value; return the schema cursor after it. PLATFORM: SHARED */
function rais_json_emit_val(base: *u8, sch0: *u8): *u8 {
  let sch: *u8 = sch0;
  let off: i32[1] = [0];
  let len: i32[1] = [0];
  let i: i32 = 0;
  if (sch == 0 as *u8) { return sch; }
  let c0: i32 = sch[0] as i32;
  let c1: i32 = 0;
  if (c0 != 0) { c1 = sch[1] as i32; }
  if (c0 == 105 && c1 == 64) {
    sch = rais_parse_dec(sch + 2, &off[0]);
    if (base != 0 as *u8) {
      rais_print_i64(rais_i32_at(base, off[0], 0) as i64, 0);
    } else {
      rais_putc(48);
    }
    return sch;
  }
  if (c0 == 98 && c1 == 64) {
    sch = rais_parse_dec(sch + 2, &off[0]);
    let bv: i32 = 0;
    if (base != 0 as *u8) { bv = base[off[0]] as i32; }
    if (bv != 0) { rais_puts("true"); } else { rais_puts("false"); }
    return sch;
  }
  if (c0 == 117 && c1 == 64) {
    sch = rais_parse_dec(sch + 2, &off[0]);
    if (sch[0] == 44) { sch = sch + 1; }
    sch = rais_parse_dec(sch, &len[0]);
    rais_putc(34);
    if (base != 0 as *u8 && len[0] > 0) {
      i = 0;
      while (i < len[0]) {
        let ub: i32 = base[off[0] + i] as i32;
        rais_json_escape_byte(ub);
        i = i + 1;
      }
    }
    rais_putc(34);
    return sch;
  }
  if (c0 == 97 && c1 == 64) {
    sch = rais_parse_dec(sch + 2, &off[0]);
    if (sch[0] == 44) { sch = sch + 1; }
    sch = rais_parse_dec(sch, &len[0]);
    rais_putc(91);
    if (base != 0 as *u8 && len[0] > 0) {
      i = 0;
      while (i < len[0]) {
        if (i != 0) { rais_putc(44); }
        rais_print_i64(rais_i32_at(base, off[0], i) as i64, 0);
        i = i + 1;
      }
    }
    rais_putc(93);
    return sch;
  }
  if (c0 == 65 && c1 == 64) {
    sch = rais_parse_dec(sch + 2, &off[0]);
    rais_putc(91);
    if (base != 0 as *u8) {
      let fat: *u8 = base + off[0];
      let fp: *u64 = fat as *u64;
      let arr: u64 = fp[0];
      let n64: u64 = fp[1];
      if (arr != 0 && n64 > 0 && n64 <= 1000000) {
        let an: i32 = n64 as i32;
        i = 0;
        while (i < an) {
          if (i != 0) { rais_putc(44); }
          rais_print_i64(rais_i32_at(arr as *u8, 0, i) as i64, 0);
          i = i + 1;
        }
      }
    }
    rais_putc(93);
    return sch;
  }
  if (c0 == 63) {
    sch = rais_parse_dec(sch + 1, &off[0]);
    if (sch[0] == 58) { sch = sch + 1; }
    let flag: i32 = 0;
    if (base != 0 as *u8) { flag = base[off[0]] as i32; }
    if (flag == 0) {
      rais_puts("null");
      let s0: i32 = sch[0] as i32;
      if (s0 == 123) {
        let depth: i32 = 0;
        let go: i32 = 1;
        while (go != 0) {
          let sc: i32 = sch[0] as i32;
          if (sc == 123) { depth = depth + 1; } else if (sc == 125) { depth = depth - 1; }
          sch = sch + 1;
          let nx: i32 = sch[0] as i32;
          if (nx == 0 || depth <= 0) { go = 0; }
        }
        return sch;
      }
      let s1: i32 = 0;
      if (s0 != 0) { s1 = sch[1] as i32; }
      if (s1 == 64) {
        if (s0 == 105 || s0 == 98 || s0 == 65) {
          sch = rais_parse_dec(sch + 2, &off[0]);
          return sch;
        }
        if (s0 == 117 || s0 == 97) {
          sch = rais_parse_dec(sch + 2, &off[0]);
          if (sch[0] == 44) { sch = sch + 1; }
          sch = rais_parse_dec(sch, &len[0]);
          return sch;
        }
      }
      return sch;
    }
    return rais_json_emit_val(base, sch);
  }
  if (c0 == 123) {
    sch = sch + 1;
    rais_putc(123);
    let first: i32 = 1;
    let oc: i32 = sch[0] as i32;
    while (oc != 0 && oc != 125) {
      if (oc == 44) {
        sch = sch + 1;
        oc = sch[0] as i32;
        continue;
      }
      let key: *u8 = sch;
      let ki: i32 = 0;
      let kc: i32 = sch[0] as i32;
      while (kc != 0 && kc != 58 && kc != 125 && kc != 44 && ki < 63) {
        ki = ki + 1;
        sch = sch + 1;
        kc = sch[0] as i32;
      }
      if (kc == 58) { sch = sch + 1; }
      if (first == 0) { rais_putc(44); }
      first = 0;
      rais_putc(34);
      if (ki > 0) { rais_io_write(1, key, ki as usize); }
      rais_putc(34);
      rais_putc(58);
      sch = rais_json_emit_val(base, sch);
      oc = sch[0] as i32;
    }
    if (oc == 125) { sch = sch + 1; }
    rais_putc(125);
    return sch;
  }
  return sch;
}

/** JSON for base per schema, then newline. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_json_println_schema(base: *u8, schema: *u8): i32 {
  let s: *u8 = schema;
  if (s == 0 as *u8) { s = "null"; }
  rais_json_emit_val(base, s);
  rais_putc(10);
  return 0;
}

/** JSON for base per schema, no newline. PLATFORM: SHARED */
#[no_mangle]
export function std_fmt_json_print_schema(base: *u8, schema: *u8): i32 {
  let s: *u8 = schema;
  if (s == 0 as *u8) { s = "null"; }
  rais_json_emit_val(base, s);
  return 0;
}

/** Fallback link name print_str. PLATFORM: SHARED */
#[no_mangle]
export function print_str(ptr: *u8, len: usize): i32 {
  return std_io_print_str(ptr, len);
}

/** read_ptr on stdin. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_stdin_ptr(): *u8 {
  return io_read_ptr(0, 0);
}

/** Length of the last read_ptr fill. PLATFORM: SHARED */
#[no_mangle]
export function std_io_ptr_len(): i32 {
  return io_read_ptr_len();
}

/** Legacy name for std_io_ptr_len. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_ptr_len(): i32 {
  return std_io_ptr_len();
}

/** preamble / co-emit read_ptr length. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_read_ptr_len(): i32 {
  return io_read_ptr_len();
}

/** preamble / co-emit read_ptr. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr(handle as u32, timeout_ms);
}

/** Product import io.read_ptr. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_ptr(handle: usize, timeout_ms: u32): *u8 {
  return io_read_ptr(handle as u32, timeout_ms);
}

/** Last read_ptr generation. PLATFORM: SHARED */
#[no_mangle]
export function std_io_ptr_gen(): u64 {
  return g_rais_read_ptr_gen[0];
}

/** 1 when saved equals the generation cell. PLATFORM: SHARED */
#[no_mangle]
export function std_io_ptr_valid(saved: u64): i32 {
  let g: u64 = g_rais_read_ptr_gen[0];
  if (saved == g) { return 1; }
  return 0;
}

/** Backend cell (always 0 here). PLATFORM: SHARED */
#[no_mangle]
export function std_io_ptr_backend(): i32 {
  return g_rais_read_ptr_backend[0];
}

/** ReadPtrView {ptr, length, pad, gen} (24B, std/io/mod.x layout). */
struct RaisReadPtrView {
  ptr: *u8;
  length: i32;
  pad0: i32;
  gen: u64;
}

/**
 * io.ptr_view on Linux x86_64 (5.7b / w1516): SysV returns this 24B struct
 * through a hidden sret pointer in rdi and hands it back in rax. Product
 * callers already follow that; the product callee side does not write the
 * sret for `return v` (debt 10.57), so spell the sret out as an explicit
 * first parameter. Same machine ABI as the C seed this replaces.
 * PLATFORM: LINUX
 */
#[cfg(target_os = "linux")]
#[no_mangle]
export function std_io_ptr_view(out: *RaisReadPtrView, handle: usize, timeout_ms: u32): *RaisReadPtrView {
  let p: *u8 = io_read_ptr(handle as u32, timeout_ms);
  let n: i32 = io_read_ptr_len();
  let g: u64 = g_rais_read_ptr_gen[0];
  out.ptr = p;
  out.length = n;
  out.pad0 = 0;
  out.gen = g;
  return out;
}

/** io.ptr_view: pack the last read_ptr / len / gen. PLATFORM: MACOS|DARWIN · WINDOWS */
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function std_io_ptr_view(handle: usize, timeout_ms: u32): RaisReadPtrView {
  let p: *u8 = io_read_ptr(handle as u32, timeout_ms);
  let n: i32 = io_read_ptr_len();
  let g: u64 = g_rais_read_ptr_gen[0];
  let v: RaisReadPtrView = RaisReadPtrView { ptr: p, length: n, pad0: 0, gen: g };
  return v;
}

/** io.ptr_view_valid: non-null ptr and current gen. PLATFORM: SHARED */
#[no_mangle]
export function std_io_ptr_view_valid(v: RaisReadPtrView): i32 {
  if (v.ptr == 0 as *u8) { return 0; }
  return std_io_ptr_valid(v.gen);
}

/** io.stdin_ptr_view on Linux x86_64: explicit sret, see std_io_ptr_view. PLATFORM: LINUX */
#[cfg(target_os = "linux")]
#[no_mangle]
export function std_io_stdin_ptr_view(out: *RaisReadPtrView): *RaisReadPtrView {
  return std_io_ptr_view(out, std_io_stdin(), 0);
}

/** io.stdin_ptr_view. PLATFORM: MACOS|DARWIN · WINDOWS */
#[cfg(not(target_os = "linux"))]
#[no_mangle]
export function std_io_stdin_ptr_view(): RaisReadPtrView {
  return std_io_ptr_view(std_io_stdin(), 0);
}

/** register_provided stub: always 0. PLATFORM: SHARED */
#[no_mangle]
export function std_io_register_provided(nr: u32, bufsz: u32): i32 {
  return 0;
}

/** unregister_provided stub: no-op. PLATFORM: SHARED */
#[no_mangle]
export function std_io_unregister_provided(): void {
  return;
}

/** Zero-copy stdin slice. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_stdin_ptr_slice(): RaisSliceU8 {
  let d: *u8 = io_read_ptr(0, 0);
  let n: usize = 0;
  if (d != 0 as *u8) { n = g_rais_read_ptr_len[0] as usize; }
  let s: RaisSliceU8 = RaisSliceU8 { data: d, length: n };
  return s;
}

/** io.stdin_slice. PLATFORM: SHARED */
#[no_mangle]
export function std_io_stdin_slice(): RaisSliceU8 {
  return std_io_read_stdin_ptr_slice();
}

/** Zero-copy slice on a handle. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_ptr_slice(handle: usize, timeout_ms: u32): RaisSliceU8 {
  let d: *u8 = io_read_ptr(handle as u32, timeout_ms);
  let n: usize = 0;
  if (d != 0 as *u8) { n = g_rais_read_ptr_len[0] as usize; }
  let s: RaisSliceU8 = RaisSliceU8 { data: d, length: n };
  return s;
}

// ---- batch / uring / fixed / driver / backend stubs ----

/** Batch read: first segment only (stub v1). PLATFORM: SHARED */
#[no_mangle]
export function io_read_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8,
                              l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i64 {
  return io_read(fd, p0, l0, timeout_ms);
}

/** Batch write: first segment only (stub v1). PLATFORM: SHARED */
#[no_mangle]
export function io_write_batch(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8,
                               l2: usize, p3: *u8, l3: usize, n: i32, timeout_ms: u32): i64 {
  return io_write(fd, p0, l0, timeout_ms);
}

/** Per-segment read over {ptr,length} pairs; timeout on the first only. PLATFORM: SHARED */
#[no_mangle]
export function io_read_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): i64 {
  if (bufs == 0 as *u8 || n <= 0) { return 0 - 1; }
  let pp: *u64 = bufs as *u64;
  let total: i64 = 0;
  let i: i32 = 0;
  while (i < n) {
    let bp: u64 = pp[i * 2];
    let bl: u64 = pp[i * 2 + 1];
    let tmo: u32 = 0;
    if (i == 0) { tmo = timeout_ms; }
    let r: i64 = io_read(fd, bp as *u8, bl as usize, tmo);
    if (r < 0) { return r; }
    total = total + r;
    if ((r as u64) < bl) { break; }
    i = i + 1;
  }
  return total;
}

/** Provided-buffer batch read: -1 (no io_uring here). PLATFORM: SHARED */
#[no_mangle]
export function io_read_batch_provided(fd: i32, n: i32, timeout_ms: u32, out_bids: *u32,
                                       out_lens: *u32): i32 {
  return 0 - 1;
}

/** io_uring connect stub. PLATFORM: SHARED */
#[no_mangle]
export function io_uring_connect(addr_u32: u32, port_u32: u32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/** io_uring accept stub. PLATFORM: SHARED */
#[no_mangle]
export function io_uring_accept(listener_fd: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/** io_uring accept_many stub. PLATFORM: SHARED */
#[no_mangle]
export function io_uring_accept_many(listener_fd: i32, out_fds: *i32, n: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/** io_uring connect_many stub. PLATFORM: SHARED */
#[no_mangle]
export function io_uring_connect_many(addr_u32: u32, port_u32: u32, out_fds: *i32, n: i32,
                                      timeout_ms: u32): i32 {
  return 0 - 1;
}

/** io_uring prefetch stub. PLATFORM: SHARED */
#[no_mangle]
export function io_uring_prefetch_fd(fd: i32): i32 {
  return 0;
}

/** Per-segment write over {ptr,length} pairs. PLATFORM: SHARED */
#[no_mangle]
export function io_write_batch_buf(fd: i32, bufs: *u8, n: i32, timeout_ms: u32): i64 {
  if (bufs == 0 as *u8 || n <= 0) { return 0 - 1; }
  let pp: *u64 = bufs as *u64;
  let total: i64 = 0;
  let i: i32 = 0;
  while (i < n) {
    let bp: u64 = pp[i * 2];
    let bl: u64 = pp[i * 2 + 1];
    let tmo: u32 = 0;
    if (i == 0) { tmo = timeout_ms; }
    let r: i64 = io_write(fd, bp as *u8, bl as usize, tmo);
    if (r < 0) { return r; }
    total = total + r;
    if ((r as u64) < bl) { break; }
    i = i + 1;
  }
  return total;
}

/** read_ptr backend cell. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_read_ptr_backend(): i32 {
  return g_rais_read_ptr_backend[0];
}

/** Fixed-buffer read stub. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_read_fixed(handle: usize, buf_index: u32, offset: usize, len: usize,
                                    timeout_ms: u32): i32 {
  return 0 - 1;
}

/** Fixed-buffer write stub. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_write_fixed(handle: usize, buf_index: u32, offset: usize, len: usize,
                                     timeout_ms: u32): i32 {
  return 0 - 1;
}

/** Async submit stub. PLATFORM: SHARED */
#[no_mangle]
export function xlang_io_submit_read_async(ptr: *u8, len: usize, handle: usize): i32 {
  return 0 - 1;
}

/** Register four buffers stub. PLATFORM: SHARED */
#[no_mangle]
export function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize,
                                      p3: *u8, l3: usize, nr: u32): i32 {
  return 0 - 1;
}

/** Unregister buffers stub. PLATFORM: SHARED */
#[no_mangle]
export function io_unregister_buffers(): void {
  return;
}

/** Wait readable stub. PLATFORM: SHARED */
#[no_mangle]
export function io_wait_readable(fds: *i32, n: i32, timeout_ms: u32): i32 {
  return 0;
}

/** driver submit_read_batch stub. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_submit_read_batch(buffers: *u8, n: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/** driver submit_write_batch stub. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_submit_write_batch(buffers: *u8, n: i32, timeout_ms: u32): i32 {
  return 0 - 1;
}

/** driver submit_read_batch_buf stub. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_submit_read_batch_buf(handle: usize, bufs: *u8, n: i32,
                                                    timeout_ms: u32): i32 {
  return 0 - 1;
}

/** driver submit_write_batch_buf stub. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_submit_write_batch_buf(handle: usize, bufs: *u8, n: i32,
                                                     timeout_ms: u32): i32 {
  return 0 - 1;
}

/** driver read_ptr gen. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_driver_read_ptr_gen(): u64 {
  return g_rais_read_ptr_gen[0];
}

/** driver read_ptr backend. PLATFORM: SHARED */
#[no_mangle]
export function std_io_driver_driver_read_ptr_backend(): i32 {
  return g_rais_read_ptr_backend[0];
}

/** sync read_fixed fallback. PLATFORM: SHARED */
#[no_mangle]
export function std_io_sync_io_read_fixed(fd: i32, buf_index: u32, offset: usize, len: usize,
                                          timeout_ms: u32): i64 {
  return 0 - 1;
}

/** sync write_fixed fallback. PLATFORM: SHARED */
#[no_mangle]
export function std_io_sync_io_write_fixed(fd: i32, buf_index: u32, offset: usize, len: usize,
                                           timeout_ms: u32): i64 {
  return 0 - 1;
}

/** backend read_ptr backend cell. PLATFORM: SHARED */
#[no_mangle]
export function std_io_backend_io_read_ptr_backend(): i32 {
  return g_rais_read_ptr_backend[0];
}

/** backend handle_from_fd: fd as usize. PLATFORM: SHARED */
#[no_mangle]
export function std_io_backend_handle_from_fd(fd: i32, unused: i32): usize {
  return fd as usize;
}

/** read_fixed_fd forwards to xlang_io_read_fixed. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_fixed_fd(fd: i32, buf_index: u32, offset: usize, len: usize,
                                     timeout_ms: u32): i32 {
  return xlang_io_read_fixed(fd as usize, buf_index, offset, len, timeout_ms);
}

/** write_fixed_fd forwards to xlang_io_write_fixed. PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_fixed_fd(fd: i32, buf_index: u32, offset: usize, len: usize,
                                      timeout_ms: u32): i32 {
  return xlang_io_write_fixed(fd as usize, buf_index, offset, len, timeout_ms);
}

/** C-path preamble _impl face. PLATFORM: SHARED */
#[no_mangle]
export function std_io_read_fixed_fd_impl(fd: i32, buf_index: u32, offset: usize, len: usize,
                                          timeout_ms: u32): i32 {
  return std_io_read_fixed_fd(fd, buf_index, offset, len, timeout_ms);
}

/** C-path preamble _impl face. PLATFORM: SHARED */
#[no_mangle]
export function std_io_write_fixed_fd_impl(fd: i32, buf_index: u32, offset: usize, len: usize,
                                           timeout_ms: u32): i32 {
  return std_io_write_fixed_fd(fd, buf_index, offset, len, timeout_ms);
}

// ---- xlang_sys_mmap / munmap (libc; not on Windows) ----

/** Weak mmap fallback to libc. PLATFORM: MACOS */
#[cfg(target_os = "macos")]
#[no_mangle]
export function xlang_sys_mmap(addr: *u8, length: usize, prot: i32, flags: i32, fd: i32,
                               offset: i64): *u8 {
  unsafe {
    return mmap(addr, length, prot, flags, fd, offset);
  }
  return 0 as *u8;
}

/** Weak munmap fallback to libc. PLATFORM: MACOS */
#[cfg(target_os = "macos")]
#[no_mangle]
export function xlang_sys_munmap(addr: *u8, length: usize): i32 {
  unsafe {
    return munmap(addr, length);
  }
  return 0 - 1;
}

/** Weak mmap fallback to libc. PLATFORM: LINUX */
#[cfg(target_os = "linux")]
#[no_mangle]
export function xlang_sys_mmap(addr: *u8, length: usize, prot: i32, flags: i32, fd: i32,
                               offset: i64): *u8 {
  unsafe {
    return mmap(addr, length, prot, flags, fd, offset);
  }
  return 0 as *u8;
}

/** Weak munmap fallback to libc. PLATFORM: LINUX */
#[cfg(target_os = "linux")]
#[no_mangle]
export function xlang_sys_munmap(addr: *u8, length: usize): i32 {
  unsafe {
    return munmap(addr, length);
  }
  return 0 - 1;
}
