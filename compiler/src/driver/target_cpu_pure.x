// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1139: the pending-feature word is stored through a pointer slot.
// tcp_eq_at takes a byte pointer. A 12-argument call stores past the frame.
// w1528: host detect, print, and the slice marker live here. The C seed is
// gone. One pure-asm shot builds src/driver/target_cpu.o.
// Print always writes fd 1. A null out handle writes nothing.
// Linux x86_64 reads /proc/cpuinfo flags (FMA is a bit, not a printed name).
// macOS arm64 is NEON. Windows x86_64 is SSE2.
// generic_for_host uses stacked cfg(target_os) and cfg(target_arch).
// A sole cfg(target_arch) for a foreign arch SIGSEGVs the Ubuntu x86_64 compiler.
// PLATFORM: SHARED.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.

let g_driver_pending_target_cpu_features: u32 = 0;

// libc faces. Linux uses open/read/close so this file does not depend on
// the syscall numbers inside runtime_asm_io_stubs.x. Print uses write on
// POSIX and _write on Windows. O_RDONLY is 0.
// PLATFORM: LINUX open/read/close. POSIX write. WINDOWS _write.
#[cfg(target_os = "linux")]
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
#[cfg(target_os = "linux")]
extern "C" function read(fd: i32, buf: *u8, n: usize): i64;
#[cfg(target_os = "linux")]
extern "C" function close(fd: i32): i32;
#[cfg(not(target_os = "windows"))]
extern "C" function write(fd: i32, buf: *u8, n: usize): i64;
#[cfg(target_os = "windows")]
extern "C" function _write(fd: i32, buf: *u8, n: u32): i32;

/** Exported function `driver_set_pending_target_cpu_features`.
 * Implements `driver_set_pending_target_cpu_features`.
 * @param features u32
 * @return void
 */
#[no_mangle]
export function driver_set_pending_target_cpu_features(features: u32): void {
  let slot: *u32 = &g_driver_pending_target_cpu_features;
  slot[0] = features;
}

/** Exported function `driver_get_pending_target_cpu_features`.
 * Implements `driver_get_pending_target_cpu_features`.
 * @return u32
 */
#[no_mangle]
export function driver_get_pending_target_cpu_features(): u32 {
  let slot: *u32 = &g_driver_pending_target_cpu_features;
  return slot[0];
}

/* See implementation. */
#[no_mangle]
export function tcp_tolower(c: u8): u8 {
  if (c >= 65 && c <= 90) {
    return (c + 32) as u8;
  }
  return c;
}

/** Exported function `tcp_eq_at`.
 * Implements `tcp_eq_at`.
 * @param name *u8
 * @param base usize
 * @param n usize
 * @param lit0 u8
 * @param lit1 u8
 * @param lit2 u8
 * @param lit3 u8
 * @param lit4 u8
 * @param lit5 u8
 * @param lit6 u8
 * @param lit7 u8
 * @param lit8 u8
 * @return i32
 */
/** Compare name[base, base+n) with lits[0, n) after ASCII tolower on the name.
 * n is at most 9. The index is a local i32 before the subscript.
 * PLATFORM: SHARED. */
#[no_mangle]
export function tcp_eq_at(name: *u8, base: usize, n: usize, lits: *u8): i32 {
  let s: *u8 = name;
  let w: *u8 = lits;
  let i: i32 = 0;
  let lim: i32 = n as i32;
  let b: i32 = base as i32;
  while (i < lim) {
    let k: i32 = i;
    let bk: i32 = b + k;
    let nb: u8 = tcp_tolower(s[bk]);
    let wb: u8 = w[k];
    if (nb != wb) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `tcp_set_u32`.
 * Implements `tcp_set_u32`.
 * @param out *u32
 * @param f u32
 * @return void
 */
#[no_mangle]
export function tcp_set_u32(out: *u32, f: u32): void {
  out[0] = f;
}

/**
 * Case-sensitive compare of n bytes at line[0, n) with lit[0, n).
 * Each byte is stored in a local before the compare (same frame fix as tcp_eq_at).
 * n is the prefix length, at most 8 for the callers in this file.
 * @param line *u8 — start of a NUL-terminated line; null returns 0
 * @param n i32 — byte count to compare
 * @param lit *u8 — exact bytes; not lowercased
 * @return i32 — 1 when the prefix matches, else 0
 * PLATFORM: SHARED.
 */
function tcp_prefix_at(line: *u8, n: i32, lit: *u8): i32 {
  let s: *u8 = line;
  let w: *u8 = lit;
  let i: i32 = 0;
  let nb: u8 = 0;
  let wb: u8 = 0;
  if (s == 0 as *u8) { return 0; }
  if (w == 0 as *u8) { return 0; }
  while (i < n) {
    nb = s[i];
    wb = w[i];
    if (nb != wb) { return 0; }
    i = i + 1;
  }
  return 1;
}

/**
 * True when token appears in hay as a whole flag (space, tab, comma, or
 * either end is a boundary). "avx" does not match inside "avx2".
 * @param hay *u8 — NUL-terminated text; null returns 0
 * @param token *u8 — NUL-terminated token; null or empty returns 0
 * @return i32 — 1 when the token is present, else 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function flags_has_token(hay: *u8, token: *u8): i32 {
  if (hay == 0) { return 0; }
  if (token == 0) { return 0; }
  let tlen: i32 = 0;
  while (tlen < 256) {
    if (token[tlen] == 0) { break; }
    tlen = tlen + 1;
  }
  if (tlen <= 0) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (hay[i] == 0) { break; }
    let ok: i32 = 1;
    let j: i32 = 0;
    while (j < tlen) {
      if (hay[i + j] != token[j]) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) {
      let b_ok: i32 = 0;
      if (i == 0) {
        b_ok = 1;
      } else {
        let before: u8 = hay[i - 1];
        if (before == 32) { b_ok = 1; }
        if (before == 9) { b_ok = 1; }
        if (before == 44) { b_ok = 1; }
      }
      let after: u8 = hay[i + tlen];
      let a_ok: i32 = 0;
      if (after == 0) { a_ok = 1; }
      if (after == 32) { a_ok = 1; }
      if (after == 9) { a_ok = 1; }
      if (after == 44) { a_ok = 1; }
      if (after == 10) { a_ok = 1; }
      if (b_ok != 0) {
        if (a_ok != 0) { return 1; }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * OR the x86 feature bits named on one cpuinfo flags line.
 * FMA (128) is included. The printed name list does not mention fma.
 * @param line *u8 — NUL-terminated flags line
 * @return u32 — bitmask (SSE2=1, SSE4.1=2, AVX=4, AVX2=8, AVX512F=16, POPCNT=32, BMI2=64, FMA=128)
 * PLATFORM: LINUX.
 */
#[cfg(target_os = "linux")]
function tcp_x86_bits(line: *u8): u32 {
  let f: u32 = 0;
  if (flags_has_token(line, "sse2" as *u8) != 0) { f = f | 1; }
  if (flags_has_token(line, "sse4_1" as *u8) != 0) { f = f | 2; }
  if (flags_has_token(line, "avx" as *u8) != 0) { f = f | 4; }
  if (flags_has_token(line, "avx2" as *u8) != 0) { f = f | 8; }
  if (flags_has_token(line, "avx512f" as *u8) != 0) { f = f | 16; }
  if (flags_has_token(line, "popcnt" as *u8) != 0) { f = f | 32; }
  if (flags_has_token(line, "bmi2" as *u8) != 0) { f = f | 64; }
  if (flags_has_token(line, "fma" as *u8) != 0) { f = f | 128; }
  return f;
}

/**
 * Read /proc/cpuinfo into buf, at most cap-1 bytes, then write a trailing NUL.
 * Locals are declared before the libc calls. Returns the byte count, or -1
 * when the file cannot be opened or is empty.
 * @param buf *u8 — caller buffer; not null
 * @param cap i32 — buffer capacity in bytes, including the trailing NUL
 * @return i32 — bytes stored before the NUL, or -1
 * PLATFORM: LINUX.
 */
#[cfg(target_os = "linux")]
function tcp_read_cpuinfo(buf: *u8, cap: i32): i32 {
  let path: *u8 = "/proc/cpuinfo";
  let fd: i32 = 0;
  let n: i64 = 0;
  let got: i32 = 0;
  let room: i32 = 0;
  let cr: i32 = 0;
  if (buf == 0 as *u8) { return -1; }
  if (cap < 2) { return -1; }
  unsafe {
    fd = open(path, 0, 0);
  }
  if (fd < 0) { return -1; }
  while (got < cap - 1) {
    room = (cap - 1) - got;
    unsafe {
      n = read(fd, &buf[got], room as usize);
    }
    if (n <= 0) { break; }
    got = got + (n as i32);
  }
  unsafe {
    cr = close(fd);
  }
  if (cr < 0) { cr = 0; }
  buf[got] = 0;
  if (got <= 0) { return -1; }
  return got;
}

/**
 * Host CPU bits on Linux x86_64 from the first flags line of /proc/cpuinfo.
 * A failed read or an empty mask falls back to SSE2 (1). No gcc __AVX__ macros.
 * @return u32 — feature bitmask
 * PLATFORM: LINUX x86_64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  let buf: u8[8192] = [];
  let p: *u8 = &buf[0];
  let n: i32 = 0;
  let ls: i32 = 0;
  let le: i32 = 0;
  let hit: i32 = 0;
  let mask: u32 = 0;
  n = tcp_read_cpuinfo(p, 8192);
  if (n <= 0) { return 1; }
  while (ls < n && hit == 0) {
    le = ls;
    while (le < n && buf[le] != 10) { le = le + 1; }
    buf[le] = 0;
    if (tcp_prefix_at(&buf[ls], 5, "flags" as *u8) != 0) {
      mask = tcp_x86_bits(&buf[ls]);
      hit = 1;
    }
    if (le < n) {
      ls = le + 1;
    } else {
      ls = n;
    }
  }
  if (mask == 0) { return 1; }
  return mask;
}

/**
 * Host CPU bits on Linux arm64 from the Features line. Default is NEON (256).
 * asimd or neon keeps NEON. sve adds 512.
 * @return u32 — feature bitmask
 * PLATFORM: LINUX aarch64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  let buf: u8[8192] = [];
  let p: *u8 = &buf[0];
  let n: i32 = 0;
  let ls: i32 = 0;
  let le: i32 = 0;
  let hit: i32 = 0;
  let mask: u32 = 256;
  n = tcp_read_cpuinfo(p, 8192);
  if (n <= 0) { return mask; }
  while (ls < n && hit == 0) {
    le = ls;
    while (le < n && buf[le] != 10) { le = le + 1; }
    buf[le] = 0;
    if (tcp_prefix_at(&buf[ls], 8, "Features" as *u8) != 0) {
      if (flags_has_token(&buf[ls], "asimd" as *u8) != 0) { mask = mask | 256; }
      if (flags_has_token(&buf[ls], "neon" as *u8) != 0) { mask = mask | 256; }
      if (flags_has_token(&buf[ls], "sve" as *u8) != 0) { mask = mask | 512; }
      hit = 1;
    }
    if (le < n) {
      ls = le + 1;
    } else {
      ls = n;
    }
  }
  return mask;
}

/**
 * Host CPU bits on Linux riscv64. After the isa line's colon, a 'v' byte
 * (the C seed's strchr) sets RVV (65536). A failed read returns 0.
 * @return u32 — feature bitmask
 * PLATFORM: LINUX riscv64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "riscv64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  let buf: u8[4096] = [];
  let p: *u8 = &buf[0];
  let n: i32 = 0;
  let ls: i32 = 0;
  let le: i32 = 0;
  let hit: i32 = 0;
  let k: i32 = 0;
  let c: u8 = 0;
  let mask: u32 = 0;
  n = tcp_read_cpuinfo(p, 4096);
  if (n <= 0) { return 0; }
  while (ls < n && hit == 0) {
    le = ls;
    while (le < n && buf[le] != 10) { le = le + 1; }
    buf[le] = 0;
    if (tcp_prefix_at(&buf[ls], 3, "isa" as *u8) != 0) {
      k = ls;
      while (buf[k] != 0 && buf[k] != 58) { k = k + 1; }
      if (buf[k] == 58) {
        k = k + 1;
        while (buf[k] == 32 || buf[k] == 9) { k = k + 1; }
        while (buf[k] != 0) {
          c = buf[k];
          if (c == 118) { mask = 65536; }
          k = k + 1;
        }
      }
      hit = 1;
    }
    if (le < n) {
      ls = le + 1;
    } else {
      ls = n;
    }
  }
  return mask;
}

/**
 * macOS arm64. NEON is mandatory. Consumer Apple Silicon has no SVE sysctl.
 * @return u32 — 256 (NEON)
 * PLATFORM: MACOS aarch64.
 */
#[cfg(target_os = "macos")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 256;
}

/**
 * macOS x86_64 baseline without CPUID (SSE2|SSE4.1). Intel Mac is not a gate host.
 * @return u32 — 3
 * PLATFORM: MACOS x86_64.
 */
#[cfg(target_os = "macos")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 3;
}

/**
 * Windows x86_64. The measured product is SSE2 only. No gcc feature macros.
 * @return u32 — 1 (SSE2)
 * PLATFORM: WINDOWS x86_64.
 */
#[cfg(target_os = "windows")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 1;
}

/**
 * Windows arm64. The C seed's non-Linux non-Apple arm64 path returns NEON.
 * @return u32 — 256
 * PLATFORM: WINDOWS aarch64.
 */
#[cfg(target_os = "windows")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_detect_host(): u32 {
  return 256;
}

/**
 * Generic feature floor on x86_64 Linux: SSE2.
 * A sole cfg(target_arch) for a foreign arch crashes the Ubuntu x86_64 compiler.
 * Stacked cfg(target_os) plus cfg(target_arch) is the form detect_host already uses.
 * @return u32 — 1 (SSE2)
 * PLATFORM: LINUX x86_64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 1;
}

/**
 * Generic feature floor on x86_64 macOS: SSE2.
 * @return u32 — 1 (SSE2)
 * PLATFORM: MACOS x86_64.
 */
#[cfg(target_os = "macos")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 1;
}

/**
 * Generic feature floor on x86_64 Windows: SSE2.
 * @return u32 — 1 (SSE2)
 * PLATFORM: WINDOWS x86_64.
 */
#[cfg(target_os = "windows")]
#[cfg(target_arch = "x86_64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 1;
}

/**
 * Generic feature floor on aarch64 Linux: NEON.
 * @return u32 — 256
 * PLATFORM: LINUX aarch64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 256;
}

/**
 * Generic feature floor on aarch64 macOS: NEON.
 * @return u32 — 256
 * PLATFORM: MACOS aarch64.
 */
#[cfg(target_os = "macos")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 256;
}

/**
 * Generic feature floor on aarch64 Windows: NEON.
 * @return u32 — 256
 * PLATFORM: WINDOWS aarch64.
 */
#[cfg(target_os = "windows")]
#[cfg(target_arch = "aarch64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 256;
}

/**
 * Generic feature floor on riscv64 Linux. No mandatory vector baseline.
 * @return u32 — 0
 * PLATFORM: LINUX riscv64.
 */
#[cfg(target_os = "linux")]
#[cfg(target_arch = "riscv64")]
#[no_mangle]
export function xlang_target_cpu_generic_for_host(): u32 {
  return 0;
}

/** Exported function `tcp_parse_named`.
 * Implements `tcp_parse_named`.
 * @param spec *u8
 * @param base usize
 * @param end usize
 * @param out *u32
 * @return i32
 */
#[no_mangle]
export function tcp_parse_named(spec: *u8, base: usize, end: usize, out: *u32): i32 {
  let n: usize = 0;
  let f: u32 = 0;
  if (end < base) {
    return -1;
  }
  n = end - base;
  /* native */
  if (n == 6 && tcp_eq_at(spec, base, 6, "native" as *u8) != 0) {
    f = xlang_target_cpu_detect_host();
    tcp_set_u32(out, f);
    return 0;
  }
  /* generic */
  if (n == 7 && tcp_eq_at(spec, base, 7, "generic" as *u8) != 0) {
    f = xlang_target_cpu_generic_for_host();
    tcp_set_u32(out, f);
    return 0;
  }
  /* sse2 */
  if (n == 4 && tcp_eq_at(spec, base, 4, "sse2" as *u8) != 0) {
    tcp_set_u32(out, 1);
    return 0;
  }
  /* sse4.1 / sse4_1 */
  if (n == 6 && (tcp_eq_at(spec, base, 6, "sse4.1" as *u8) != 0 ||
                 tcp_eq_at(spec, base, 6, "sse4_1" as *u8) != 0)) {
    tcp_set_u32(out, 1 | 2);
    return 0;
  }
  /* avx */
  if (n == 3 && tcp_eq_at(spec, base, 3, "avx" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4);
    return 0;
  }
  /* avx2 */
  if (n == 4 && tcp_eq_at(spec, base, 4, "avx2" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8);
    return 0;
  }
  /* avx512 */
  if (n == 6 && tcp_eq_at(spec, base, 6, "avx512" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16);
    return 0;
  }
  /* avx512f */
  if (n == 7 && tcp_eq_at(spec, base, 7, "avx512f" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16);
    return 0;
  }
  /* x86-64-v2 */
  if (n == 9 && tcp_eq_at(spec, base, 9, "x86-64-v2" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 32);
    return 0;
  }
  /* x86-64-v3 */
  if (n == 9 && tcp_eq_at(spec, base, 9, "x86-64-v3" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 32 | 64);
    return 0;
  }
  /* x86-64-v4 */
  if (n == 9 && tcp_eq_at(spec, base, 9, "x86-64-v4" as *u8) != 0) {
    tcp_set_u32(out, 1 | 2 | 4 | 8 | 16 | 32 | 64);
    return 0;
  }
  /* neon */
  if (n == 4 && tcp_eq_at(spec, base, 4, "neon" as *u8) != 0) {
    tcp_set_u32(out, 256);
    return 0;
  }
  /* sve */
  if (n == 3 && tcp_eq_at(spec, base, 3, "sve" as *u8) != 0) {
    tcp_set_u32(out, 256 | 512);
    return 0;
  }
  /* rvv */
  if (n == 3 && tcp_eq_at(spec, base, 3, "rvv" as *u8) != 0) {
    tcp_set_u32(out, 65536);
    return 0;
  }
  return -1;
}

/** Exported function `xlang_target_cpu_resolve`.
 * Implements `xlang_target_cpu_resolve`.
 * @param spec *u8
 * @param spec_len usize
 * @param out *u32
 * @return i32
 */
#[no_mangle]
export function xlang_target_cpu_resolve(spec: *u8, spec_len: usize, out: *u32): i32 {
  let start: usize = 0;
  let end: usize = 0;
  let f: u32 = 0;
  if (out == 0 as *u32) {
    return -1;
  }
  if (spec == 0 as *u8 || spec_len == 0) {
    f = xlang_target_cpu_detect_host();
    tcp_set_u32(out, f);
    return 0;
  }
  end = spec_len;
  while (start < end && (spec[start] == 32 || spec[start] == 9)) {
    start = start + 1;
  }
  while (end > start && (spec[end - 1] == 32 || spec[end - 1] == 9)) {
    end = end - 1;
  }
  if (end <= start) {
    f = xlang_target_cpu_detect_host();
    tcp_set_u32(out, f);
    return 0;
  }
  return tcp_parse_named(spec, start, end, out);
}

/** Exported function `tcp_eq5`.
 * Implements `tcp_eq5`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @return i32
 */
#[no_mangle]
export function tcp_eq5(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  let lit: u8[8] = [];
  let p: *u8 = &lit[0];
  p[0] = a0;
  p[1] = a1;
  p[2] = a2;
  p[3] = a3;
  p[4] = a4;
  return tcp_eq_at(name, 0, 5, p);
}

/** Exported function `tcp_eq6`.
 * Implements `tcp_eq6`.
 * @param name *u8
 * @param a0 u8
 * @param a1 u8
 * @param a2 u8
 * @param a3 u8
 * @param a4 u8
 * @param a5 u8
 * @return i32
 */
#[no_mangle]
export function tcp_eq6(name: *u8, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  let lit: u8[8] = [];
  let p: *u8 = &lit[0];
  p[0] = a0;
  p[1] = a1;
  p[2] = a2;
  p[3] = a3;
  p[4] = a4;
  p[5] = a5;
  return tcp_eq_at(name, 0, 6, p);
}

/** True when a 5-byte spelling is one of i32x4, i32x8, u32x4, u32x8.
 * PLATFORM: SHARED. */
function tcp_simd_len5_a(name: *u8): i32 {
  let pad: u8[128] = [];
  pad[0] = 0;
  if (tcp_eq5(name, 105, 51, 50, 120, 52) != 0) { return 1; }
  if (tcp_eq5(name, 105, 51, 50, 120, 56) != 0) { return 1; }
  if (tcp_eq5(name, 117, 51, 50, 120, 52) != 0) { return 1; }
  if (tcp_eq5(name, 117, 51, 50, 120, 56) != 0) { return 1; }
  return 0;
}

/** True when a 5-byte spelling is one of f32x4, f32x8, vec4f, vec8i.
 * PLATFORM: SHARED. */
function tcp_simd_len5_b(name: *u8): i32 {
  let pad: u8[128] = [];
  pad[0] = 0;
  if (tcp_eq5(name, 102, 51, 50, 120, 52) != 0) { return 1; }
  if (tcp_eq5(name, 102, 51, 50, 120, 56) != 0) { return 1; }
  if (tcp_eq5(name, 118, 101, 99, 52, 102) != 0) { return 1; }
  if (tcp_eq5(name, 118, 101, 99, 56, 105) != 0) { return 1; }
  return 0;
}

/** True when a 6-byte spelling is i32x16 or u32x16.
 * PLATFORM: SHARED. */
function tcp_simd_len6(name: *u8): i32 {
  let pad: u8[96] = [];
  pad[0] = 0;
  if (tcp_eq6(name, 105, 51, 50, 120, 49, 54) != 0) { return 1; }
  if (tcp_eq6(name, 117, 51, 50, 120, 49, 54) != 0) { return 1; }
  return 0;
}

/** Exported function `xlang_simd_is_vector_type_spelling`.
 * Implements `xlang_simd_is_vector_type_spelling`.
 * @param name *u8
 * @param name_len usize
 * @return i32
 */
#[no_mangle]
export function xlang_simd_is_vector_type_spelling(name: *u8, name_len: usize): i32 {
  if (name == 0 as *u8 || name_len == 0) {
    return 0;
  }
  if (name_len == 5) {
    if (tcp_simd_len5_a(name) != 0) { return 1; }
    if (tcp_simd_len5_b(name) != 0) { return 1; }
  }
  if (name_len == 6) {
    if (tcp_simd_len6(name) != 0) { return 1; }
  }
  return 0;
}

/** Exported function `xlang_simd_vector_lanes_esz_from_spelling`.
 * Implements `xlang_simd_vector_lanes_esz_from_spelling`.
 * @param name *u8
 * @param name_len usize
 * @param out_lanes *i32
 * @param out_esz *i32
 * @return i32
 */
#[no_mangle]
export function xlang_simd_vector_lanes_esz_from_spelling(name: *u8, name_len: usize, out_lanes: *i32, out_esz: *i32): i32 {
  let lanes: i32 = 4;
  let esz: i32 = 4;
  let s: *u8 = name;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (out_lanes == 0 as *i32 || out_esz == 0 as *i32) {
    return -1;
  }
  if (xlang_simd_is_vector_type_spelling(s, name_len) == 0) {
    return -1;
  }
  if (name_len == 5 && s[4] == 56) {
    lanes = 8;
  }
  if (name_len == 6 && s[4] == 49 && s[5] == 54) {
    lanes = 16;
  }
  if (name_len == 5 && tcp_eq5(s, 118, 101, 99, 56, 105) != 0) {
    lanes = 8;
  }
  out_lanes[0] = lanes;
  out_esz[0] = esz;
  return 0;
}

/* See implementation. */

// append_feat_name: see function docblock below.
/** Exported function `append_feat_name`.
 * Implements `append_feat_name`.
 * @param buf *u8
 * @param cap usize
 * @param pos *usize
 * @param name *u8
 * @return void
 */
#[no_mangle]
export function append_feat_name(buf: *u8, cap: usize, pos: *usize, name: *u8): void {
  if (buf == 0) { return; }
  if (pos == 0) { return; }
  if (name == 0) { return; }
  let p: usize = pos[0];
  if (p >= cap) { return; }
  if (p > 0) {
    if (p + 1 < cap) {
      buf[p as i32] = 44;
      p = p + 1;
    }
  }
  let nlen: usize = 0;
  while (nlen < 256) {
    if (name[nlen as i32] == 0) { break; }
    nlen = nlen + 1;
  }
  if (p + nlen >= cap) { return; }
  let i: usize = 0;
  while (i < nlen) {
    buf[(p + i) as i32] = name[i as i32];
    i = i + 1;
  }
  p = p + nlen;
  buf[p as i32] = 0;
  pos[0] = p;
}

/**
 * One POSIX write or Windows _write. Locals are declared before the call.
 * @param fd i32 — file descriptor; print uses 1
 * @param buf *u8 — bytes to write
 * @param n i32 — byte count; zero or negative returns 0
 * @return i32 — bytes written, or <= 0 on error
 * PLATFORM: POSIX write. WINDOWS _write.
 */
#[cfg(not(target_os = "windows"))]
function tcp_host_write(fd: i32, buf: *u8, n: i32): i32 {
  let r: i64 = 0;
  if (n <= 0) { return 0; }
  unsafe {
    r = write(fd, buf, n as usize);
  }
  return r as i32;
}

/**
 * One Windows _write. Locals are declared before the call.
 * @param fd i32 — file descriptor; print uses 1
 * @param buf *u8 — bytes to write
 * @param n i32 — byte count; zero or negative returns 0
 * @return i32 — bytes written, or <= 0 on error
 * PLATFORM: WINDOWS.
 */
#[cfg(target_os = "windows")]
function tcp_host_write(fd: i32, buf: *u8, n: i32): i32 {
  let r: i32 = 0;
  if (n <= 0) { return 0; }
  unsafe {
    r = _write(fd, buf, n as u32);
  }
  return r;
}

/**
 * Write len bytes to fd 1, retrying a short write. Stops on n <= 0.
 * @param buf *u8 — bytes to emit
 * @param len i32 — byte count
 * @return void
 * PLATFORM: SHARED.
 */
function tcp_write_all(buf: *u8, len: i32): void {
  let off: i32 = 0;
  let n: i32 = 0;
  let left: i32 = 0;
  while (off < len) {
    left = len - off;
    n = tcp_host_write(1, &buf[off], left);
    if (n <= 0) { break; }
    off = off + n;
  }
}

/**
 * Format v as 8 lowercase hex digits into dst[0, 8). No trailing NUL.
 * Nibbles are (v >> 28), (v >> 24), ... (v >> 0), masked with 15.
 * A variable divisor would emit a div-by-zero check that calls xlang_panic_,
 * and this object is rejected if that symbol is undefined.
 * @param v u32 — value to format
 * @param dst *u8 — 8-byte destination; caller owns
 * @return void
 * PLATFORM: SHARED.
 */
function tcp_fmt_u32_hex8(v: u32, dst: *u8): void {
  let n: u32 = v;
  let sh: i32 = 28;
  let i: i32 = 0;
  let d: u32 = 0;
  let b: u8 = 0;
  while (i < 8) {
    d = (n >> sh) & 15;
    if (d < 10) {
      b = (48 + d) as u8;
    } else {
      b = (87 + d) as u8;
    }
    dst[i] = b;
    sh = sh - 4;
    i = i + 1;
  }
}

/**
 * Write prefix + "=0x" + 8 hex digits + newline to fd 1.
 * The line buffer is 64 bytes and lives only in this function.
 * @param prefix *u8 — key text, not null
 * @param plen i32 — prefix length; plen + 12 must fit in 64
 * @param val u32 — value printed in hex
 * @return void
 * PLATFORM: SHARED.
 */
function tcp_print_hex_line(prefix: *u8, plen: i32, val: u32): void {
  let line: u8[64] = [];
  let hex: u8[8] = [];
  let p: *u8 = &line[0];
  let h: *u8 = &hex[0];
  let i: i32 = 0;
  let pos: i32 = 0;
  if (prefix == 0 as *u8) { return; }
  if (plen + 12 > 64) { return; }
  while (i < plen) {
    p[i] = prefix[i];
    i = i + 1;
  }
  pos = plen;
  p[pos] = 61;
  pos = pos + 1;
  p[pos] = 48;
  pos = pos + 1;
  p[pos] = 120;
  pos = pos + 1;
  tcp_fmt_u32_hex8(val, h);
  i = 0;
  while (i < 8) {
    p[pos + i] = h[i];
    i = i + 1;
  }
  pos = pos + 8;
  p[pos] = 10;
  pos = pos + 1;
  tcp_write_all(p, pos);
}

/**
 * Fill list with the printed feature names for features. FMA (bit 128) is
 * not named. Commas come from append_feat_name. list[0] is 0 when empty.
 * @param features u32 — bitmask
 * @param list *u8 — 256-byte buffer; caller owns
 * @return void
 * PLATFORM: SHARED.
 */
function tcp_fill_feat_list(features: u32, list: *u8): void {
  let pos: usize = 0;
  let slot: *usize = &pos;
  let bit: u32 = 0;
  list[0] = 0;
  bit = features & 1;
  if (bit != 0) { append_feat_name(list, 256, slot, "sse2" as *u8); }
  bit = features & 2;
  if (bit != 0) { append_feat_name(list, 256, slot, "sse4.1" as *u8); }
  bit = features & 4;
  if (bit != 0) { append_feat_name(list, 256, slot, "avx" as *u8); }
  bit = features & 8;
  if (bit != 0) { append_feat_name(list, 256, slot, "avx2" as *u8); }
  bit = features & 16;
  if (bit != 0) { append_feat_name(list, 256, slot, "avx512f" as *u8); }
  bit = features & 32;
  if (bit != 0) { append_feat_name(list, 256, slot, "popcnt" as *u8); }
  bit = features & 64;
  if (bit != 0) { append_feat_name(list, 256, slot, "bmi2" as *u8); }
  bit = features & 256;
  if (bit != 0) { append_feat_name(list, 256, slot, "neon" as *u8); }
  bit = features & 512;
  if (bit != 0) { append_feat_name(list, 256, slot, "sve" as *u8); }
  bit = features & 65536;
  if (bit != 0) { append_feat_name(list, 256, slot, "rvv" as *u8); }
}

/**
 * Write "target_cpu_features_list=" plus the name list, or "(none)", and a newline.
 * The 320-byte line lives only in this function.
 * @param list *u8 — NUL-terminated names from tcp_fill_feat_list; empty when list[0] is 0
 * @return void
 * PLATFORM: SHARED.
 */
function tcp_print_list_line(list: *u8): void {
  let line: u8[320] = [];
  let p: *u8 = &line[0];
  let prefix: *u8 = "target_cpu_features_list=";
  let none: *u8 = "(none)";
  let i: i32 = 0;
  let pos: i32 = 0;
  let c: u8 = 0;
  while (i < 25) {
    p[i] = prefix[i];
    i = i + 1;
  }
  pos = 25;
  if (list[0] == 0) {
    i = 0;
    while (i < 6) {
      p[pos] = none[i];
      pos = pos + 1;
      i = i + 1;
    }
  } else {
    i = 0;
    while (i < 256) {
      c = list[i];
      if (c == 0) { break; }
      p[pos] = c;
      pos = pos + 1;
      i = i + 1;
    }
  }
  p[pos] = 10;
  pos = pos + 1;
  tcp_write_all(p, pos);
}

/**
 * Print the feature mask as three stable lines on fd 1.
 * A null out handle returns without writing. The handle itself is ignored.
 * The 256-byte name buffer lives only here; the hex line and the list line
 * each own their own buffer.
 * @param out *u8 — opaque stdout handle; null means do not print
 * @param features u32 — feature bitmask to print on the first line
 * @return void
 * PLATFORM: SHARED. Writes fd 1 on LINUX, MACOS, and WINDOWS.
 */
#[no_mangle]
export function xlang_target_cpu_print(out: *u8, features: u32): void {
  let list: u8[256] = [];
  let p: *u8 = &list[0];
  let host: u32 = 0;
  if (out == 0 as *u8) { return; }
  tcp_print_hex_line("target_cpu_features" as *u8, 19, features);
  tcp_fill_feat_list(features, p);
  tcp_print_list_line(p);
  host = xlang_target_cpu_detect_host();
  tcp_print_hex_line("target_cpu_host_features" as *u8, 24, host);
}

/**
 * Slice marker. The business bodies, host detect, and print are all in this file.
 * @return i32 — always 1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function target_cpu_pure_slice_marker(): i32 {
  return 1;
}

/**
 * w1528 anchor. g05 refuses to link an object that does not define this.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function target_cpu_pure_x_w1528_anchor(): i32 {
  return 0;
}
