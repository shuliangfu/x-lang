// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.



let g_cfg_os_override: u8[32] = [];
let g_cfg_arch_override: u8[32] = [];
let g_cfg_has_target_override: i32 = 0;

let g_cfg_freestanding: i32 = 0;

// wave98 Cap residual pure (product complex #if): host OS/arch string lits are
// compile-time residual in seeds/cfg_eval_link_alias.from_x.c (C #if, same values as
// bootstrap stub). Multi-#[cfg] same-name export overloads dual-emitted under
// -E-extern (illegal C: redefinition / retu8_ptr mangle / missing bare callee) and
// forced product to pin bootstrap stub forever — dual authority vs cfg_eval.x body.
// G.7: eval/all/not/target_os/arch authority stays in this file; host lit only here as
// export-extern surface; link_alias provides strong bodies when merged into cfg_eval.o.
// PLATFORM: SHARED — mac + Ubuntu both take -E-extern+alias when pure-asm CG002 fails.
/**
 * Host target_os literal ("linux" / "macos" / "windows" / "freebsd" / "unknown").
 * @return *u8 — NUL-terminated static string; never null
 * wave98: body in cfg_eval_link_alias (C #if); not multi-cfg .x overload.
 */
export extern "C" function cfg_host_os_lit(): *u8;
/**
 * Host target_arch literal ("x86_64" / "aarch64" / "riscv64" / "unknown").
 * @return *u8 — NUL-terminated static string; never null
 * wave98: body in cfg_eval_link_alias (C #if); not multi-cfg .x overload.
 */
export extern "C" function cfg_host_arch_lit(): *u8;

/** Exported function `cfg_strlen`.
 * Implements `cfg_strlen`.
 * @param s *u8
 * @return i32
 */
export function cfg_strlen(s: *u8): i32 {
  let n: i32 = 0;
  if (s == 0) {
    return 0;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  return n;
}

/** Exported function `cfg_tolower_c`.
 * Implements `cfg_tolower_c`.
 * @param c u8
 * @return u8
 */
export function cfg_tolower_c(c: u8): u8 {
  if (c < 65) { return c; }
  if (c > 90) { return c; }
  return (c + 32) as u8;
}

/** Exported function `cfg_copy_cstr`.
 * Implements `cfg_copy_cstr`.
 * @param dest *u8
 * @param dest_sz i32
 * @param src *u8
 * @return void
 */
export function cfg_copy_cstr(dest: *u8, dest_sz: i32, src: *u8): void {
  let i: i32 = 0;
  if (dest == 0) { return; }
  if (dest_sz <= 0) { return; }
  if (src == 0) { return; }
  while (i < dest_sz - 1) {
    if (src[i] == 0) { break; }
    dest[i] = src[i];
    i = i + 1;
  }
  dest[i] = 0;
}

/** Exported function `cfg_range_eq_ci`.
 * Implements `cfg_range_eq_ci`.
 * @param buf *u8
 * @param b i32
 * @param e i32
 * @param lit *u8
 * @return i32
 */
export function cfg_range_eq_ci(buf: *u8, b: i32, e: i32, lit: *u8): i32 {
  let blen: i32 = e - b;
  let llen: i32 = cfg_strlen(lit);
  let i: i32 = 0;
  if (buf == 0) { return 0; }
  if (lit == 0) { return 0; }
  if (blen != llen) { return 0; }
  while (i < blen) {
    let ca: u8 = cfg_tolower_c(buf[b + i]);
    let cb: u8 = cfg_tolower_c(lit[i]);
    if (ca != cb) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** Exported function `cfg_triple_contains_ci`.
 * Implements `cfg_triple_contains_ci`.
 * @param buf *u8
 * @param b i32
 * @param e i32
 * @param needle *u8
 * @return i32
 */
export function cfg_triple_contains_ci(buf: *u8, b: i32, e: i32, needle: *u8): i32 {
  let nlen: i32 = cfg_strlen(needle);
  let i: i32 = b;
  if (buf == 0) { return 0; }
  if (needle == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  if (e - b < nlen) { return 0; }
  while (i + nlen <= e) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      let a: u8 = cfg_tolower_c(buf[i + j]);
      let nb: u8 = cfg_tolower_c(needle[j]);
      if (a != nb) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `cfg_triple_has`.
 * Implements `cfg_triple_has`.
 * @param triple *u8
 * @param tlen i32
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function cfg_triple_has(triple: *u8, tlen: i32, a: *u8, b: *u8): i32 {
  if (cfg_triple_contains_ci(triple, 0, tlen, a) != 0) { return 1; }
  if (cfg_triple_contains_ci(triple, 0, tlen, b) != 0) { return 1; }
  return 0;
}

/** Exported function `cfg_parse_triple_literals`.
 * Implements `cfg_parse_triple_literals`.
 * @param triple *u8
 * @param tlen i32
 * @param os_out *u8
 * @param os_sz i32
 * @param arch_out *u8
 * @param arch_sz i32
 * @return void
 */
export function cfg_parse_triple_literals(triple: *u8, tlen: i32, os_out: *u8, os_sz: i32, arch_out: *u8, arch_sz: i32): void {
  let lit_linux: u8[6] = [108, 105, 110, 117, 120, 0];
  let lit_macos: u8[6] = [109, 97, 99, 111, 115, 0];
  let lit_darwin: u8[7] = [100, 97, 114, 119, 105, 110, 0];
  let lit_windows: u8[8] = [119, 105, 110, 100, 111, 119, 115, 0];
  let lit_freebsd: u8[8] = [102, 114, 101, 101, 98, 115, 100, 0];
  let lit_win32: u8[6] = [119, 105, 110, 51, 50, 0];
  let lit_aarch64: u8[8] = [97, 97, 114, 99, 104, 54, 52, 0];
  let lit_arm64: u8[6] = [97, 114, 109, 54, 52, 0];
  let lit_x86_64: u8[7] = [120, 56, 54, 95, 54, 52, 0];
  let lit_amd64: u8[6] = [97, 109, 100, 54, 52, 0];
  let lit_riscv64: u8[8] = [114, 105, 115, 99, 118, 54, 52, 0];
  if (os_out == 0) { return; }
  if (os_sz <= 0) { return; }
  if (arch_out == 0) { return; }
  if (arch_sz <= 0) { return; }
  // wave98: host lit is export-extern (link_alias C #if) — T001 requires unsafe FFI.
  unsafe {
    cfg_copy_cstr(os_out, os_sz, cfg_host_os_lit());
    cfg_copy_cstr(arch_out, arch_sz, cfg_host_arch_lit());
  }
  if (triple == 0) { return; }
  if (tlen <= 0) { return; }
  if (cfg_triple_contains_ci(triple, 0, tlen, &lit_linux[0]) != 0) {
    cfg_copy_cstr(os_out, os_sz, &lit_linux[0]);
  } else if (cfg_triple_has(triple, tlen, &lit_darwin[0], &lit_macos[0]) != 0) {
    cfg_copy_cstr(os_out, os_sz, &lit_macos[0]);
  } else if (cfg_triple_contains_ci(triple, 0, tlen, &lit_freebsd[0]) != 0) {
    cfg_copy_cstr(os_out, os_sz, &lit_freebsd[0]);
  } else if (cfg_triple_has(triple, tlen, &lit_windows[0], &lit_win32[0]) != 0) {
    cfg_copy_cstr(os_out, os_sz, &lit_windows[0]);
  }
  if (cfg_triple_has(triple, tlen, &lit_aarch64[0], &lit_arm64[0]) != 0) {
    cfg_copy_cstr(arch_out, arch_sz, &lit_aarch64[0]);
  } else if (cfg_triple_has(triple, tlen, &lit_x86_64[0], &lit_amd64[0]) != 0) {
    cfg_copy_cstr(arch_out, arch_sz, &lit_x86_64[0]);
  } else if (cfg_triple_contains_ci(triple, 0, tlen, &lit_riscv64[0]) != 0) {
    cfg_copy_cstr(arch_out, arch_sz, &lit_riscv64[0]);
  }
}

/** Exported function `cfg_effective_os_lit`.
 * Implements `cfg_effective_os_lit`.
 * @return *u8
 */
export function cfg_effective_os_lit(): *u8 {
  // wave98: host lit export-extern — T001 unsafe FFI gate.
  if (g_cfg_has_target_override == 0) {
    unsafe { return cfg_host_os_lit(); }
  }
  if (g_cfg_os_override[0] == 0) {
    unsafe { return cfg_host_os_lit(); }
  }
  return &g_cfg_os_override[0];
}

/** Exported function `cfg_effective_arch_lit`.
 * Implements `cfg_effective_arch_lit`.
 * @return *u8
 */
export function cfg_effective_arch_lit(): *u8 {
  // wave98: host lit export-extern — T001 unsafe FFI gate.
  if (g_cfg_has_target_override == 0) {
    unsafe { return cfg_host_arch_lit(); }
  }
  if (g_cfg_arch_override[0] == 0) {
    unsafe { return cfg_host_arch_lit(); }
  }
  return &g_cfg_arch_override[0];
}

/** Exported function `cfg_skip_ws`.
 * Implements `cfg_skip_ws`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @return i32
 */
export function cfg_skip_ws(buf: *u8, p: i32, end: i32): i32 {
  while (p < end) {
    let c: u8 = buf[p];
    let is_ws: i32 = 0;
    if (c == 32) { is_ws = 1; }
    if (c == 9) { is_ws = 1; }
    if (c == 10) { is_ws = 1; }
    if (c == 13) { is_ws = 1; }
    if (is_ws == 0) { break; }
    p = p + 1;
  }
  return p;
}

/** Exported function `cfg_prefix4`.
 * Implements `cfg_prefix4`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @param c0 u8
 * @param c1 u8
 * @param c2 u8
 * @param c3 u8
 * @return i32
 */
export function cfg_prefix4(buf: *u8, p: i32, end: i32, c0: u8, c1: u8, c2: u8, c3: u8): i32 {
  if (p + 4 > end) {
    return 0;
  }
  if (buf[p] != c0) { return 0; }
  if (buf[p + 1] != c1) { return 0; }
  if (buf[p + 2] != c2) { return 0; }
  if (buf[p + 3] != c3) { return 0; }
  return 1;
}

/** Exported function `cfg_is_ident_char`.
 * Implements `cfg_is_ident_char`.
 * @param c u8
 * @return i32
 */
export function cfg_is_ident_char(c: u8): i32 {
  if (c == 95) { return 1; }
  if (c < 48) { return 0; }
  if (c > 122) { return 0; }
  if (c <= 57) { return 1; }
  if (c < 65) { return 0; }
  if (c <= 90) { return 1; }
  if (c < 97) { return 0; }
  return 1;
}

/** Exported function `cfg_scan_delim`.
 * Implements `cfg_scan_delim`.
 * @param c u8
 * @param depth i32
 * @return i32
 */
export function cfg_scan_delim(c: u8, depth: i32): i32 {
  if (c == 41) { if (depth == 0) { return 1; } return 2; }
  if (c == 44) { if (depth == 0) { return 1; } return 3; }
  return 0;
}

/** Exported function `cfg_buf_eq_at`.
 * Implements `cfg_buf_eq_at`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @param c u8
 * @return i32
 */
export function cfg_buf_eq_at(buf: *u8, p: i32, end: i32, c: u8): i32 {
  if (p >= end) { return 0; }
  if (buf[p] == c) { return 1; }
  return 0;
}

/** Exported function `cfg_eval_all`.
 * Implements `cfg_eval_all`.
 * @param buf *u8
 * @param b i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_all(buf: *u8, b: i32, end: i32): i32 {
  let p: i32 = b + 4;
  while (p < end) {
    let part: i32 = 0;
    let depth: i32 = 0;
    p = cfg_skip_ws(buf, p, end);
    if (p >= end) { break; }
    if (buf[p] == 41) { return 1; }
    part = p;
    depth = 0;
    while (p < end) {
      if (buf[p] == 40) { depth = depth + 1; p = p + 1; continue; }
      let sd: i32 = cfg_scan_delim(buf[p], depth);
      if (sd == 1) { break; }
      if (sd == 2) { depth = depth - 1; p = p + 1; continue; }
      if (sd == 3) { p = p + 1; continue; }
      p = p + 1;
    }
    if (cfg_eval_expr_range(buf, part, p) == 0) { return 0; }
    if (cfg_buf_eq_at(buf, p, end, 41) != 0) { return 1; }
  }
  return 1;
}

/** Exported function `cfg_eval_not`.
 * Implements `cfg_eval_not`.
 * @param buf *u8
 * @param b i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_not(buf: *u8, b: i32, end: i32): i32 {
  let inner: i32 = b + 4;
  let close: i32 = inner;
  let depth: i32 = 1;
  while (close < end) {
    if (depth <= 0) { break; }
    if (buf[close] == 40) {
      depth = depth + 1;
    } else if (buf[close] == 41) {
      depth = depth - 1;
    }
    if (depth > 0) { close = close + 1; }
  }
  if (cfg_eval_expr_range(buf, inner, close) != 0) { return 0; }
  return 1;
}

/** Exported function `cfg_eval_target_os`.
 * Implements `cfg_eval_target_os`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_target_os(buf: *u8, p: i32, end: i32): i32 {
  let lit_target_os: u8[10] = [116, 97, 114, 103, 101, 116, 95, 111, 115, 0];
  if (p + 9 > end) { return -1; }
  if (cfg_range_eq_ci(buf, p, p + 9, &lit_target_os[0]) == 0) { return -1; }
  p = p + 9;
  p = cfg_skip_ws(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 61) { return 0; }
  p = p + 1;
  if (p < end) {
    if (buf[p] == 61) { p = p + 1; }
  }
  p = cfg_skip_ws(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 34) { return 0; }
  p = p + 1;
  let lit: i32 = p;
  while (p < end) {
    if (buf[p] == 34) { break; }
    p = p + 1;
  }
  if (cfg_range_eq_ci(buf, lit, p, cfg_effective_os_lit()) != 0) { return 1; }
  return 0;
}

/** Exported function `cfg_eval_target_arch`.
 * Implements `cfg_eval_target_arch`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_target_arch(buf: *u8, p: i32, end: i32): i32 {
  let lit_target_arch: u8[12] = [116, 97, 114, 103, 101, 116, 95, 97, 114, 99, 104, 0];
  if (p + 11 > end) { return -1; }
  if (cfg_range_eq_ci(buf, p, p + 11, &lit_target_arch[0]) == 0) { return -1; }
  p = p + 11;
  p = cfg_skip_ws(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 61) { return 0; }
  p = p + 1;
  if (p < end) {
    if (buf[p] == 61) { p = p + 1; }
  }
  p = cfg_skip_ws(buf, p, end);
  if (p >= end) { return 0; }
  if (buf[p] != 34) { return 0; }
  p = p + 1;
  let lit: i32 = p;
  while (p < end) {
    if (buf[p] == 34) { break; }
    p = p + 1;
  }
  if (cfg_range_eq_ci(buf, lit, p, cfg_effective_arch_lit()) != 0) { return 1; }
  return 0;
}

/** Exported function `cfg_eval_freestanding_flag`.
 * Memory management helper `cfg_eval_freestanding_flag`.
 * @param buf *u8
 * @param p i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_freestanding_flag(buf: *u8, p: i32, end: i32): i32 {
  let lit_freestanding: u8[13] = [102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 0];
  let q: i32 = p;
  while (q < end) {
    let c: u8 = buf[q];
    if (cfg_is_ident_char(c) == 0) { break; }
    q = q + 1;
  }
  if (cfg_range_eq_ci(buf, p, q, &lit_freestanding[0]) != 0) {
    return g_cfg_freestanding;
  }
  return 0;
}

/** Exported function `cfg_eval_expr_range`.
 * Implements `cfg_eval_expr_range`.
 * @param buf *u8
 * @param b i32
 * @param end i32
 * @return i32
 */
export function cfg_eval_expr_range(buf: *u8, b: i32, end: i32): i32 {
  let p: i32 = cfg_skip_ws(buf, b, end);
  let r: i32 = 0;
  if (p >= end) { return 0; }
  if (cfg_prefix4(buf, p, end, 97, 108, 108, 40) != 0) {
    return cfg_eval_all(buf, p, end);
  }
  if (cfg_prefix4(buf, p, end, 110, 111, 116, 40) != 0) {
    return cfg_eval_not(buf, p, end);
  }
  r = cfg_eval_target_os(buf, p, end);
  if (r != -1) { return r; }
  r = cfg_eval_target_arch(buf, p, end);
  if (r != -1) { return r; }
  return cfg_eval_freestanding_flag(buf, p, end);
}

/** Exported function `cfg_eval_expr_c`.
 * Implements `cfg_eval_expr_c`.
 * @param start *u8
 * @param len i32
 * @return i32
 */
export function cfg_eval_expr_c(start: *u8, len: i32): i32 {
  if (start == 0) { return 0; }
  if (len <= 0) { return 0; }
  if (cfg_eval_expr_range(start, 0, len) != 0) {
    return 1;
  }
  return 0;
}

/** Exported function `cfg_apply_compile_target_from_triple`.
 * Implements `cfg_apply_compile_target_from_triple`.
 * @param triple *u8
 * @param len i32
 * @return void
 */
export function cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void {
  cfg_parse_triple_literals(triple, len, &g_cfg_os_override[0], 32, &g_cfg_arch_override[0], 32);
  g_cfg_has_target_override = 1;
}

/** Exported function `cfg_reset_compile_target`.
 * Implements `cfg_reset_compile_target`.
 * @return void
 */
export function cfg_reset_compile_target(): void {
  g_cfg_has_target_override = 0;
  g_cfg_os_override[0] = 0;
  g_cfg_arch_override[0] = 0;
}

/** Exported function `cfg_set_freestanding`.
 * Memory management helper `cfg_set_freestanding`.
 * @param v i32
 * @return void
 */
export function cfg_set_freestanding(v: i32): void {
  g_cfg_freestanding = v;
}
