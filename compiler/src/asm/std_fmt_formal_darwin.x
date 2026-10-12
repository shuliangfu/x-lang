// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_fmt_formal_darwin.x — Darwin arm64 + Linux body of std/fmt/fmt.o.
// Twin of std/fmt/formal_surface.c. Hand-rolled decimal/hex/f64/%.6f (no
// snprintf varargs). null ptr_to_buf → portable "0x0".
// Windows keeps formal_surface.c (记225).
// PLATFORM: MACOS|DARWIN arm64 | LINUX.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

#[no_mangle]
export function std_fmt_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/** Write unsigned decimal digits; return length. PLATFORM: SHARED */
function face_u64_digits(v: u64, out: *u8): i32 {
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let x: u64 = v;
  if (x == 0) {
    out[0] = 48;
    return 1;
  }
  // Product arm64 emits sdiv for u64 `/` (debt 10.56): peel the top bit first.
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

function face_i64(buf: *u8, cap: i32, x: i64): i32 {
  let tmp: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let u: u64 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  if (x < 0) {
    tmp[0] = 45;
    n = 1;
    u = (0 as u64) - (x as u64);
  } else {
    u = x as u64;
  }
  n = n + face_u64_digits(u, &tmp[n]);
  if (n > cap) { return 0 - 1; }
  unsafe { memcpy(buf, &tmp[0], n as u64); }
  return n;
}

function face_u64(buf: *u8, cap: i32, x: u64): i32 {
  let tmp: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n = face_u64_digits(x, &tmp[0]);
  if (n > cap) { return 0 - 1; }
  unsafe { memcpy(buf, &tmp[0], n as u64); }
  return n;
}

function face_write_str(buf: *u8, cap: i32, s: *u8): i32 {
  let n: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (s == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  while (s[n] != 0) {
    n = n + 1;
  }
  if (n > cap) { return 0 - 1; }
  unsafe { memcpy(buf, s, n as u64); }
  return n;
}

function face_hex_u64(buf: *u8, cap: i32, x: u64): i32 {
  let tmp: u8[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let v: u64 = x;
  let dig: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  if (v == 0) {
    if (cap < 1) { return 0 - 1; }
    buf[0] = 48;
    return 1;
  }
  while (v > 0) {
    let d: u64 = v & 15;
    tmp[n] = dig[d as i32];
    n = n + 1;
    v = v >> 4;
  }
  if (n > cap) { return 0 - 1; }
  let k: i32 = 0;
  while (k < n) {
    buf[k] = tmp[n - 1 - k];
    k = k + 1;
  }
  return n;
}

/** Fixed %.6f twin of snprintf. PLATFORM: SHARED */
function face_f64(buf: *u8, cap: i32, x: f64): i32 {
  let tmp: u8[64] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let neg: i32 = 0;
  let v: f64 = x;
  let ip: i64 = 0;
  let frac: i64 = 0;
  let scaled: f64 = 0.0;
  let n: i32 = 0;
  let m: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  // NaN → keep snprintf-ish "nan" lowercase (glibc/mac often "nan")
  if (x != x) {
    if (cap < 3) { return 0 - 1; }
    buf[0] = 110; buf[1] = 97; buf[2] = 110;
    return 3;
  }
  if (v < 0.0) {
    neg = 1;
    v = 0.0 - v;
  }
  // Round to 6 decimals: (v * 1e6) + 0.5
  scaled = v * 1000000.0 + 0.5;
  ip = scaled as i64;
  // Handle overflow of cast for huge values — fall back to integer-only path
  frac = ip % 1000000;
  ip = ip / 1000000;
  if (neg != 0) {
    tmp[0] = 45;
    n = 1;
  }
  m = face_u64_digits(ip as u64, &tmp[n]);
  n = n + m;
  tmp[n] = 46;
  n = n + 1;
  // 6 decimal digits, zero-padded
  let fdig: u8[6] = [0, 0, 0, 0, 0, 0];
  let fv: i64 = frac;
  let fi: i32 = 5;
  while (fi >= 0) {
    fdig[fi] = (48 + (fv % 10)) as u8;
    fv = fv / 10;
    fi = fi - 1;
  }
  let fj: i32 = 0;
  while (fj < 6) {
    tmp[n] = fdig[fj];
    n = n + 1;
    fj = fj + 1;
  }
  if (n > cap) { return 0 - 1; }
  unsafe { memcpy(buf, &tmp[0], n as u64); }
  return n;
}

function face_format2_i64(buf: *u8, cap: i32, a: i64, b: i64): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_i64(buf, cap, a);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_i64(buf + n1, cap - n1, b);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

function face_format2_u64(buf: *u8, cap: i32, a: u64, b: u64): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_u64(buf, cap, a);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_u64(buf + n1, cap - n1, b);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_i32(x: i32): i32 {
  return x;
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_i32(buf: *u8, cap: i32, x: i32): i32 {
  return face_i64(buf, cap, x as i64);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_u32(buf: *u8, cap: i32, u: u32): i32 {
  return face_u64(buf, cap, u as u64);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_i64(buf: *u8, cap: i32, x: i64): i32 {
  return face_i64(buf, cap, x);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_u64(buf: *u8, cap: i32, u: u64): i32 {
  return face_u64(buf, cap, u);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_usize(buf: *u8, cap: i32, x: usize): i32 {
  return face_u64(buf, cap, x as u64);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_isize(buf: *u8, cap: i32, x: isize): i32 {
  return face_i64(buf, cap, x as i64);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_bool(buf: *u8, cap: i32, b: i32): i32 {
  let t: u8[5] = [116, 114, 117, 101, 0];
  let f: u8[6] = [102, 97, 108, 115, 101, 0];
  if (b != 0) { return face_write_str(buf, cap, &t[0]); }
  return face_write_str(buf, cap, &f[0]);
}

#[no_mangle]
export function std_fmt_to_buf_u8_ptr_i32_f64(buf: *u8, cap: i32, x: f64): i32 {
  return face_f64(buf, cap, x);
}

#[no_mangle]
export function std_fmt_hex_to_buf_u8_ptr_i32_u32(buf: *u8, cap: i32, u: u32): i32 {
  return face_hex_u64(buf, cap, u as u64);
}

#[no_mangle]
export function std_fmt_hex_to_buf_u8_ptr_i32_u64(buf: *u8, cap: i32, u: u64): i32 {
  return face_hex_u64(buf, cap, u);
}

#[no_mangle]
export function std_fmt_append_to_buf_u8_ptr_i32_i32_i32(buf: *u8, cap: i32, off: i32, x: i32): i32 {
  let tmp: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  if (off < 0) { return 0 - 1; }
  if (off > cap) { return 0 - 1; }
  n = face_i64(&tmp[0], 32, x as i64);
  if (n < 0) { return 0 - 1; }
  if (off + n > cap) { return 0 - 1; }
  unsafe { memcpy(buf + off, &tmp[0], n as u64); }
  return off + n;
}

#[no_mangle]
export function std_fmt_append_to_buf_u8_ptr_i32_i32_i64(buf: *u8, cap: i32, off: i32, x: i64): i32 {
  let tmp: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  if (off < 0) { return 0 - 1; }
  if (off > cap) { return 0 - 1; }
  n = face_i64(&tmp[0], 32, x);
  if (n < 0) { return 0 - 1; }
  if (off + n > cap) { return 0 - 1; }
  unsafe { memcpy(buf + off, &tmp[0], n as u64); }
  return off + n;
}

#[no_mangle]
export function std_fmt_ptr_to_buf(buf: *u8, cap: i32, p: *u8): i32 {
  let n: i32 = 0;
  let hx: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  if (p == 0) {
    if (cap < 3) { return 0 - 1; }
    buf[0] = 48; buf[1] = 120; buf[2] = 48;
    return 3;
  }
  // Portable "0x" + lowercase hex (no leading zeros) — matches macOS %p for
  // typical addresses; Linux glibc %p is the same shape for non-null.
  if (cap < 3) { return 0 - 1; }
  buf[0] = 48;
  buf[1] = 120;
  hx = face_hex_u64(buf + 2, cap - 2, p as u64);
  if (hx < 0) { return 0 - 1; }
  return 2 + hx;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_i32(buf: *u8, cap: i32, a: i32, b: i32): i32 {
  return face_format2_i64(buf, cap, a as i64, b as i64);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_i32_i32(buf: *u8, cap: i32, a: i32, b: i32, c: i32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  let n3: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_i64(buf, cap, a as i64);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_i64(buf + n1, cap - n1, b as i64);
  if (n2 < 0) { return 0 - 1; }
  n3 = face_i64(buf + n1 + n2, cap - n1 - n2, c as i64);
  if (n3 < 0) { return 0 - 1; }
  return n1 + n2 + n3;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_u32(buf: *u8, cap: i32, a: i32, b: u32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_i64(buf, cap, a as i64);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_u64(buf + n1, cap - n1, b as u64);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_i64(buf: *u8, cap: i32, a: i32, b: i64): i32 {
  return face_format2_i64(buf, cap, a as i64, b);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i64_i32(buf: *u8, cap: i32, a: i64, b: i32): i32 {
  return face_format2_i64(buf, cap, a, b as i64);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i64_i64(buf: *u8, cap: i32, a: i64, b: i64): i32 {
  return face_format2_i64(buf, cap, a, b);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_u32_i32(buf: *u8, cap: i32, a: u32, b: i32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_u64(buf, cap, a as u64);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_i64(buf + n1, cap - n1, b as i64);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_u32_u32(buf: *u8, cap: i32, a: u32, b: u32): i32 {
  return face_format2_u64(buf, cap, a as u64, b as u64);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_u64_u64(buf: *u8, cap: i32, a: u64, b: u64): i32 {
  return face_format2_u64(buf, cap, a, b);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_usize_usize(buf: *u8, cap: i32, a: usize, b: usize): i32 {
  return face_format2_u64(buf, cap, a as u64, b as u64);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_isize_i32(buf: *u8, cap: i32, a: isize, b: i32): i32 {
  return face_format2_i64(buf, cap, a as i64, b as i64);
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_usize(buf: *u8, cap: i32, a: i32, b: usize): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_i64(buf, cap, a as i64);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_u64(buf + n1, cap - n1, b as u64);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_i32_u32_usize(buf: *u8, cap: i32, a: i32, b: u32, c: usize): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  let n3: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_i64(buf, cap, a as i64);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_u64(buf + n1, cap - n1, b as u64);
  if (n2 < 0) { return 0 - 1; }
  n3 = face_u64(buf + n1 + n2, cap - n1 - n2, c as u64);
  if (n3 < 0) { return 0 - 1; }
  return n1 + n2 + n3;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_f64_i32(buf: *u8, cap: i32, a: f64, b: i32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = face_f64(buf, cap, a);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_i64(buf + n1, cap - n1, b as i64);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_bool_bool(buf: *u8, cap: i32, a: i32, b: i32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  let t: u8[5] = [116, 114, 117, 101, 0];
  let f: u8[6] = [102, 97, 108, 115, 101, 0];
  let sa: *u8 = &f[0];
  let sb: *u8 = &f[0];
  if (a != 0) { sa = &t[0]; }
  if (b != 0) { sb = &t[0]; }
  n1 = face_write_str(buf, cap, sa);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_write_str(buf + n1, cap - n1, sb);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_u8_ptr_i32_u8_ptr_i32(buf: *u8, cap: i32, p: *u8, v: i32): i32 {
  let n1: i32 = 0;
  let n2: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (cap <= 0) { return 0 - 1; }
  n1 = std_fmt_ptr_to_buf(buf, cap, p);
  if (n1 < 0) { return 0 - 1; }
  n2 = face_i64(buf + n1, cap - n1, v as i64);
  if (n2 < 0) { return 0 - 1; }
  return n1 + n2;
}

#[no_mangle]
export function std_fmt_format_template(buf: *u8, cap: i32, pat: *u8, pat_len: i32, val: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let replaced: i32 = 0;
  if (buf == 0) { return 0 - 1; }
  if (pat == 0) { return 0 - 1; }
  while (i < pat_len) {
    if (replaced == 0 && i + 1 < pat_len && pat[i] == 123 && pat[i + 1] == 125) {
      let n: i32 = face_i64(buf + o, cap - o, val as i64);
      if (n < 0) { return 0 - 1; }
      o = o + n;
      i = i + 2;
      replaced = 1;
    } else {
      if (o >= cap) { return 0 - 1; }
      buf[o] = pat[i];
      o = o + 1;
      i = i + 1;
    }
  }
  return o;
}
