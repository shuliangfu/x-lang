// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1140: one translation unit exits 139. The Darwin prefer compiles eight
// pieces and links them. Snap loads keep a used pad so stores stay in frame.
// PLATFORM: SHARED.
//   （-DXLANG_L2_DIAG_THIN_FROM_X）ld -r → src/diag.o
// See implementation.
//
// f-335：line_digits / kind_is_exact / kind_contains / color_prefix
// f-336：get_file/source/len / code_* / set_file / report
// f-337：push_file / restore → _impl
// f-338：should_color / color_reset / json_mode / extract_line / print_* /
// f-342：code_eq / levenshtein / json_write/report/severity / code_suggest
// f-338 cont：
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// See implementation.
export extern "C" function diag_ctx_get_use_color_impl(): i32;
export extern "C" function diag_ctx_get_file_impl(): *u8;
export extern "C" function diag_ctx_get_source_impl(): *u8;
export extern "C" function diag_ctx_get_source_len_impl(): i64;
export extern "C" function diag_ctx_set_all_impl(path: *u8, source: *u8, source_len: i64, use_color: i32): void;
export extern "C" function diag_push_file_apply_impl(path: *u8, source: *u8, source_len: i64): void;
export extern "C" function diag_should_color_impl(): i32;
export extern "C" function diag_color_reset_impl(): *u8;
export extern "C" function diag_set_json_mode_impl(enable: i32): void;
export extern "C" function link_abi_getenv(name: *u8): *u8;export extern "C" function diag_print_code_table_impl(out: *u8): void;
export extern "C" function diag_print_known_codes_impl(out: *u8): void;
export extern "C" function diag_print_code_explain_impl(out: *u8, code: *u8): void;
// ---- G-02f-335 pure helpers ----

/** Exported function `diag_line_digits`.
 * Implements `diag_line_digits`.
 * @param line i32
 * @return i32
 */
#[no_mangle]
export function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

/** Exported function `diag_cstr_len_bounded`.
 * Implements `diag_cstr_len_bounded`.
 * @param s *u8
 * @return i32
 */
export function diag_cstr_len_bounded(s: *u8): i32 {
  if (s == 0) {
    return 0;
  }
  let n: i32 = 0;
  while (n < 4096) {
    if (s[n] == 0) {
      return n;
    }
    n = n + 1;
  }
  return 4096;
}

/** Exported function `diag_bytes_match_at`.
 * Implements `diag_bytes_match_at`.
 * @param hay *u8
 * @param needle *u8
 * @param off i32
 * @param nlen i32
 * @return i32
 */
export function diag_bytes_match_at(hay: *u8, needle: *u8, off: i32, nlen: i32): i32 {
  let j: i32 = 0;
  while (j < nlen) {
    if (hay[off + j] != needle[j]) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

/** Exported function `diag_kind_is_exact`.
 * Implements `diag_kind_is_exact`.
 * @param kind *u8
 * @param needle *u8
 * @return i32
 */
#[no_mangle]
export function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  let klen: i32 = diag_cstr_len_bounded(kind);
  let nlen: i32 = diag_cstr_len_bounded(needle);
  if (klen != nlen) {
    return 0;
  }
  return diag_bytes_match_at(kind, needle, 0, nlen);
}

/** Exported function `diag_kind_contains`.
 * Implements `diag_kind_contains`.
 * @param kind *u8
 * @param needle *u8
 * @return i32
 */
#[no_mangle]
export function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  if (needle[0] == 0) {
    return 0;
  }
  let nlen: i32 = diag_cstr_len_bounded(needle);
  if (nlen <= 0) {
    return 0;
  }
  let klen: i32 = diag_cstr_len_bounded(kind);
  if (klen < nlen) {
    return 0;
  }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    if (diag_bytes_match_at(kind, needle, s, nlen) != 0) {
      return 1;
    }
    s = s + 1;
  }
  return 0;
}

/** Exported function `diag_color_prefix`.
 * Implements `diag_color_prefix`.
 * @param plain *u8
 * @param color *u8
 * @return *u8
 */
#[no_mangle]
export function diag_color_prefix(plain: *u8, color: *u8): *u8 {
  unsafe {
    if (diag_ctx_get_use_color_impl() != 0) {
      return color;
    }
    return plain;
  }
  return plain;
}

// ---- G-02f-336 context / code-table gates ----

/** Exported function `diag_get_file`.
 * Implements `diag_get_file`.
 * @return *u8
 */
#[no_mangle]
export function diag_get_file(): *u8 {
  unsafe {
    return diag_ctx_get_file_impl();
  }
}

/** Exported function `diag_get_source`.
 * Implements `diag_get_source`.
 * @return *u8
 */
#[no_mangle]
export function diag_get_source(): *u8 {
  unsafe {
    return diag_ctx_get_source_impl();
  }
}

/** Exported function `diag_get_source_len`.
 * Query helper `diag_get_source_len`.
 * @return i64
 */
#[no_mangle]
export function diag_get_source_len(): i64 {
  unsafe {
    return diag_ctx_get_source_len_impl();
  }
}
/**
 * Return 1 when code is a known diagnostic code.
 * @param code *u8
 * @return i32
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_table_has(code);
  }
}
/**
 * Kind word for a known diagnostic code, or null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_kind(code: *u8): *u8 {
  unsafe {
    return diag_entry_kind(code);
  }
}
/**
 * Summary for a known diagnostic code, or null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_summary(code: *u8): *u8 {
  unsafe {
    return diag_entry_summary(code);
  }
}
/**
 * Details for a known diagnostic code, or null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_details(code: *u8): *u8 {
  unsafe {
    return diag_entry_details(code);
  }
}

// diag_set_file: see function docblock below.
/** Exported function `diag_set_file`.
 * Implements `diag_set_file`.
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @return void
 */
#[no_mangle]
export function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    let c: i32 = diag_should_color_impl();
    diag_ctx_set_all_impl(path, source, source_len, c);
  }
}

// diag_report: see function docblock below.
/** Exported function `diag_report`.
 * Implements `diag_report`.
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param msg *u8
 * @param detail *u8
 * @return void
 */
#[no_mangle]
export function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    let z: *u8 = 0;
    diag_report_with_code(file, line, col, kind, z, msg, detail);
  }
}

// See implementation.
// diag_store_ptr_le: see function docblock below.

/** Exported function `diag_store_ptr_le`.
 * Implements `diag_store_ptr_le`.
 * @param p *u8
 * @param val *u8
 * @return void
 */
#[no_mangle]
export function diag_store_ptr_le(p: *u8, val: *u8): void {
  if (p == 0 as *u8) {
    return;
  }
  unsafe {
    let a: usize = val as usize;
    let m: usize = 256;
    let b0: usize = a % m;
    let a1: usize = a / m;
    let b1: usize = a1 % m;
    let a2: usize = a1 / m;
    let b2: usize = a2 % m;
    let a3: usize = a2 / m;
    let b3: usize = a3 % m;
    let a4: usize = a3 / m;
    let b4: usize = a4 % m;
    let a5: usize = a4 / m;
    let b5: usize = a5 % m;
    let a6: usize = a5 / m;
    let b6: usize = a6 % m;
    let a7: usize = a6 / m;
    let b7: usize = a7 % m;
    p[0] = b0 as u8;
    p[1] = b1 as u8;
    p[2] = b2 as u8;
    p[3] = b3 as u8;
    p[4] = b4 as u8;
    p[5] = b5 as u8;
    p[6] = b6 as u8;
    p[7] = b7 as u8;
  }
}

/** Exported function `diag_store_usize_le`.
 * Implements `diag_store_usize_le`.
 * @param p *u8
 * @param val usize
 * @return void
 */
#[no_mangle]
export function diag_store_usize_le(p: *u8, val: usize): void {
  if (p == 0 as *u8) {
    return;
  }
  unsafe {
    let a: usize = val;
    let m: usize = 256;
    let b0: usize = a % m;
    let a1: usize = a / m;
    let b1: usize = a1 % m;
    let a2: usize = a1 / m;
    let b2: usize = a2 % m;
    let a3: usize = a2 / m;
    let b3: usize = a3 % m;
    let a4: usize = a3 / m;
    let b4: usize = a4 % m;
    let a5: usize = a4 / m;
    let b5: usize = a5 % m;
    let a6: usize = a5 / m;
    let b6: usize = a6 % m;
    let a7: usize = a6 / m;
    let b7: usize = a7 % m;
    p[0] = b0 as u8;
    p[1] = b1 as u8;
    p[2] = b2 as u8;
    p[3] = b3 as u8;
    p[4] = b4 as u8;
    p[5] = b5 as u8;
    p[6] = b6 as u8;
    p[7] = b7 as u8;
  }
}

/** Exported function `diag_snap_store_ptr`.
 * Implements `diag_snap_store_ptr`.
 * @param snap *u8
 * @param off i32
 * @param val *u8
 * @return void
 */
#[no_mangle]
export function diag_snap_store_ptr(snap: *u8, off: i32, val: *u8): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_ptr_le(q, val);
  }
}

/** Exported function `diag_snap_store_usize`.
 * Implements `diag_snap_store_usize`.
 * @param snap *u8
 * @param off i32
 * @param val usize
 * @return void
 */
#[no_mangle]
export function diag_snap_store_usize(snap: *u8, off: i32, val: usize): void {
  if (snap == 0 as *u8) {
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    diag_store_usize_le(q, val);
  }
}

/** Exported function `diag_snap_store_i32`.
 * Implements `diag_snap_store_i32`.
 * @param snap *u8
 * @param off i32
 * @param val i32
 * @return void
 */
#[no_mangle]
export function diag_snap_store_i32(snap: *u8, off: i32, val: i32): void {
  if (snap == 0 as *u8) {
    return;
  }
  if (val < 0) {
    unsafe {
      let q: *u8 = snap + off;
      q[0] = 0;
      q[1] = 0;
      q[2] = 0;
      q[3] = 0;
    }
    return;
  }
  unsafe {
    let q: *u8 = snap + off;
    let a: i32 = val;
    let b0: i32 = a % 256;
    let a1: i32 = a / 256;
    let b1: i32 = a1 % 256;
    let a2: i32 = a1 / 256;
    let b2: i32 = a2 % 256;
    let a3: i32 = a2 / 256;
    let b3: i32 = a3 % 256;
    q[0] = b0 as u8;
    q[1] = b1 as u8;
    q[2] = b2 as u8;
    q[3] = b3 as u8;
  }
}

/** Exported function `diag_snap_load_ptr`.
 * Implements `diag_snap_load_ptr`.
 * @param snap *u8
 * @param off i32
 * @return *u8
 */
#[no_mangle]
export function diag_snap_load_ptr(snap: *u8, off: i32): *u8 {
  // The eight live multiplies store past a short frame. The pad widens it.
  let pad: u8[128] = [];
  pad[0] = 0;
  if (snap == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: usize = 256;
    let m2: usize = m * m;
    let m4: usize = m2 * m2;
    let a0: usize = q[0] as usize;
    let a1: usize = a0 + (q[1] as usize) * m;
    let a2: usize = a1 + (q[2] as usize) * m2;
    let a3: usize = a2 + (q[3] as usize) * (m2 * m);
    let a4: usize = a3 + (q[4] as usize) * m4;
    let a5: usize = a4 + (q[5] as usize) * (m4 * m);
    let a6: usize = a5 + (q[6] as usize) * (m4 * m2);
    let a7: usize = a6 + (q[7] as usize) * (m4 * m2 * m);
    return a7 as *u8;
  }
  return 0 as *u8;
}

/** Exported function `diag_snap_load_usize`.
 * Implements `diag_snap_load_usize`.
 * @param snap *u8
 * @param off i32
 * @return usize
 */
#[no_mangle]
export function diag_snap_load_usize(snap: *u8, off: i32): usize {
  // Same frame widen as diag_snap_load_ptr. PLATFORM: SHARED.
  let pad: u8[128] = [];
  pad[0] = 0;
  if (snap == 0 as *u8) {
    return 0;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: usize = 256;
    let m2: usize = m * m;
    let m4: usize = m2 * m2;
    let a0: usize = q[0] as usize;
    let a1: usize = a0 + (q[1] as usize) * m;
    let a2: usize = a1 + (q[2] as usize) * m2;
    let a3: usize = a2 + (q[3] as usize) * (m2 * m);
    let a4: usize = a3 + (q[4] as usize) * m4;
    let a5: usize = a4 + (q[5] as usize) * (m4 * m);
    let a6: usize = a5 + (q[6] as usize) * (m4 * m2);
    let a7: usize = a6 + (q[7] as usize) * (m4 * m2 * m);
    return a7;
  }
  return 0;
}

/** Exported function `diag_snap_load_i32`.
 * Implements `diag_snap_load_i32`.
 * @param snap *u8
 * @param off i32
 * @return i32
 */
#[no_mangle]
export function diag_snap_load_i32(snap: *u8, off: i32): i32 {
  // Four live multiplies store at the end of a short frame. PLATFORM: SHARED.
  let pad: u8[64] = [];
  pad[0] = 0;
  if (snap == 0 as *u8) {
    return 0;
  }
  unsafe {
    let q: *u8 = snap + off;
    let m: i32 = 256;
    let a0: i32 = q[0] as i32;
    let a1: i32 = a0 + (q[1] as i32) * m;
    let a2: i32 = a1 + (q[2] as i32) * m * m;
    let a3: i32 = a2 + (q[3] as i32) * m * m * m;
    return a3;
  }
  return 0;
}


// See implementation.

// diag_push_snap_save: see function docblock below.
/** Exported function `diag_push_snap_save`.
 * Implements `diag_push_snap_save`.
 * @param snapshot *u8
 * @return void
 */
#[no_mangle]
export function diag_push_snap_save(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file_impl());
    diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source_impl());
    diag_snap_store_usize(snapshot, 16, diag_ctx_get_source_len_impl() as usize);
    diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color_impl());
  }
}

/** Exported function `diag_push_file`.
 * Implements `diag_push_file`.
 * @param snapshot *u8
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @return void
 */
#[no_mangle]
export function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  diag_push_snap_save(snapshot);
  unsafe {
    diag_push_file_apply_impl(path, source, source_len);
  }
}

/** Exported function `diag_restore`.
 * Implements `diag_restore`.
 * @param snapshot *u8
 * @return void
 */
#[no_mangle]
export function diag_restore(snapshot: *u8): void {
  if (snapshot == 0 as *u8) {
    return;
  }
  unsafe {
    let p: *u8 = diag_snap_load_ptr(snapshot, 0);
    let s: *u8 = diag_snap_load_ptr(snapshot, 8);
    let sl: usize = diag_snap_load_usize(snapshot, 16);
    let c: i32 = diag_snap_load_i32(snapshot, 24);
    diag_ctx_set_all_impl(p, s, sl as i64, c);
  }
}

// diag_should_color: see function docblock below.

/** Exported function `diag_should_color`.
 * Implements `diag_should_color`.
 * @return i32
 */
#[no_mangle]
export function diag_should_color(): i32 {
  unsafe {
    return diag_should_color_impl();
  }
}

/** Exported function `diag_color_reset`.
 * Implements `diag_color_reset`.
 * @return *u8
 */
#[no_mangle]
export function diag_color_reset(): *u8 {
  unsafe {
    return diag_color_reset_impl();
  }
}

/** Exported function `diag_set_json_mode`.
 * Implements `diag_set_json_mode`.
 * @param enable i32
 * @return void
 */
#[no_mangle]
export function diag_set_json_mode(enable: i32): void {
  unsafe {
    diag_set_json_mode_impl(enable);
  }
}

/**
 * Return 1 when JSON diagnostics are on.
 * The cached state lives in the seed. -2 means not decided yet: read
 * XLANG_DIAG_JSON once through link_abi_getenv. A non-empty value that
 * does not start with '0' turns JSON on. An explicit diag_set_json_mode
 * writes 0 or 1 first, and that value wins over the environment.
 * @return i32 — 1 when JSON mode is on, otherwise 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_json_enabled(): i32 {
  let s: i32 = 0;
  let v: i32 = 0;
  let e: *u8 = 0 as *u8;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    s = diag_json_get_state();
    if (s == 0 - 2) {
      e = link_abi_getenv("XLANG_DIAG_JSON");
      if (e != 0 as *u8) {
        if (e[0] != 0) {
          if (e[0] != 48) {
            v = 1;
          }
        }
      }
      diag_json_set_state(v);
      s = v;
    }
    if (s == 1) {
      return 1;
    }
  }
  return 0;
}

/**
 * Find source line `line_no` (1-based) in the diag context.
 * Writes the line start pointer and the byte length, not counting the
 * newline. A missing line, a null out, or a non-positive line returns -1.
 * An empty source still returns line 1 as a zero-length span.
 * The index is i32. A source longer than 2147483647 bytes is clipped.
 * Storage stays in the seed context; this function only walks bytes.
 * @param line_no i32 — 1-based line
 * @param line_start_out *u8 — address of the pointer slot, or null
 * @param line_len_out *u8 — address of the size slot, or null
 * @return i32 — 0 when the line exists, -1 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
  let src: *u8 = 0 as *u8;
  let len64: i64 = 0;
  let len: i32 = 0;
  let line: i32 = 1;
  let i: i32 = 0;
  let start: i32 = 0;
  let c: i32 = 0;
  let p: *u8 = 0 as *u8;
  let ln: usize = 0;
  if (line_no <= 0 || line_start_out == 0 as *u8 || line_len_out == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    src = diag_ctx_get_source_impl();
    len64 = diag_ctx_get_source_len_impl();
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len64 > 2147483647) {
    len = 2147483647;
  } else {
    if (len64 > 0) {
      len = len64 as i32;
    }
  }
  while (i < len) {
    if (line == line_no) {
      break;
    }
    unsafe {
      c = src[i] as i32;
    }
    if (c == 10) {
      line = line + 1;
      start = i + 1;
    }
    i = i + 1;
  }
  if (line != line_no) {
    return 0 - 1;
  }
  while (i < len) {
    unsafe {
      c = src[i] as i32;
    }
    if (c == 10 || c == 13) {
      break;
    }
    i = i + 1;
  }
  unsafe {
    p = src + start;
    ln = (i - start) as usize;
    diag_store_ptr_le(line_start_out, p);
    diag_store_usize_le(line_len_out, ln);
  }
  return 0;
}

/**
 * Write the diagnostic header to stderr.
 * Empty kind prints only the message and a newline. A non-empty code is
 * wrapped in brackets. Byte order matches the former printf:
 * color, kind, optional [code], reset, ": ", message, newline.
 * Null strings are treated as empty. The fd write stays in the seed.
 * @param kind *u8 — severity word, or null
 * @param code *u8 — diagnostic code, or null
 * @param msg *u8 — message, or null
 * @param kind_color *u8 — ANSI prefix, or null
 * @param reset *u8 — ANSI reset, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  let err: *u8 = 0 as *u8;
  let m: *u8 = msg;
  let k: *u8 = kind;
  let kc: *u8 = kind_color;
  let rs: *u8 = reset;
  if (m == 0 as *u8) {
    m = "";
  }
  if (k == 0 as *u8) {
    k = "";
  }
  if (kc == 0 as *u8) {
    kc = "";
  }
  if (rs == 0 as *u8) {
    rs = "";
  }
  unsafe {
    err = diag_stderr();
    if (k[0] == 0) {
      diag_io_fputs(m, err);
      diag_io_fputc(err, 10);
      return;
    }
    diag_io_fputs(kc, err);
    diag_io_fputs(k, err);
    if (code != 0 as *u8) {
      if (code[0] != 0) {
        diag_io_fputc(err, 91);
        diag_io_fputs(code, err);
        diag_io_fputc(err, 93);
      }
    }
    diag_io_fputs(rs, err);
    diag_io_fputs(": ", err);
    diag_io_fputs(m, err);
    diag_io_fputc(err, 10);
  }
}

/** Exported function `diag_print_code_table`.
 * Implements `diag_print_code_table`.
 * @param out *u8
 * @return void
 */
#[no_mangle]
export function diag_print_code_table(out: *u8): void {
  unsafe {
    diag_print_code_table_impl(out);
  }
}

/** Exported function `diag_print_known_codes`.
 * Implements `diag_print_known_codes`.
 * @param out *u8
 * @return void
 */
#[no_mangle]
export function diag_print_known_codes(out: *u8): void {
  unsafe {
    diag_print_known_codes_impl(out);
  }
}

/** Exported function `diag_print_code_explain`.
 * Implements `diag_print_code_explain`.
 * @param out *u8
 * @param code *u8
 * @return void
 */
#[no_mangle]
export function diag_print_code_explain(out: *u8, code: *u8): void {
  unsafe {
    diag_print_code_explain_impl(out, code);
  }
}

/**
 * Dispatch one diagnostic after the message text is already formatted.
 * JSON mode prints actual_file (the argument, or the context path).
 * Human mode receives the original file pointer, which may be null.
 * va_list formatting stays in the seed and calls this function.
 * @param file *u8 — path, or null to use the context path for JSON
 * @param line i32
 * @param col i32
 * @param kind *u8
 * @param code *u8 — diagnostic code, or null
 * @param msg *u8 — already formatted message
 * @param detail *u8 — caret note, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  let actual_file: *u8 = file;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    if (actual_file == 0 as *u8) {
      actual_file = diag_ctx_get_file();
    }
    if (diag_json_enabled() != 0) {
      diag_report_json(actual_file, line, col, kind, code, msg);
      return;
    }
    diag_report_human(file, line, col, kind, code, msg, detail);
  }
}

/**
 * Print one human diagnostic: header, location, source line, caret.
 * Colors match the seed palette (error, warning, info, note, help, hint).
 * Formatted pieces stay in the seed fd helpers. This function does not
 * flush; the fd writes are unbuffered. A missing source line returns
 * after the location line.
 * @param file *u8 — path, or null to use the context path
 * @param line i32 — 1-based line; 0 still prints file:0:0
 * @param col i32 — 1-based column; non-positive skips the caret
 * @param kind *u8 — severity word
 * @param code *u8 — diagnostic code, or null
 * @param msg *u8 — message
 * @param detail *u8 — caret note, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_report_human(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  let err: *u8 = 0 as *u8;
  let actual_file: *u8 = file;
  let kind_color: *u8 = 0 as *u8;
  let caret_color: *u8 = 0 as *u8;
  let path_color: *u8 = 0 as *u8;
  let reset: *u8 = 0 as *u8;
  let line_start_slot: u8[8] = [];
  let line_len_slot: u8[8] = [];
  let have_line: i32 = 0;
  let line_start: *u8 = 0 as *u8;
  let line_len_u: usize = 0;
  let width: i32 = 1;
  let caret_col: i32 = 0;
  let i: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  line_start_slot[0] = 0;
  line_len_slot[0] = 0;
  unsafe {
    err = diag_stderr();
    if (actual_file == 0 as *u8) {
      actual_file = diag_ctx_get_file();
    }
    kind_color = diag_color_prefix("", "\x1b[1;37m");
    caret_color = diag_color_prefix("", "\x1b[37m");
    if (kind != 0 as *u8) {
      if (kind[0] != 0) {
        if (diag_kind_contains(kind, "error") != 0) {
          kind_color = diag_color_prefix("", "\x1b[1;31m");
          caret_color = diag_color_prefix("", "\x1b[31m");
        } else {
          if (diag_kind_contains(kind, "warning") != 0) {
            kind_color = diag_color_prefix("", "\x1b[1;33m");
            caret_color = diag_color_prefix("", "\x1b[33m");
          } else {
            if (diag_kind_is_exact(kind, "info") != 0) {
              kind_color = diag_color_prefix("", "\x1b[1;36m");
              caret_color = diag_color_prefix("", "\x1b[36m");
            } else {
              if (diag_kind_is_exact(kind, "note") != 0) {
                kind_color = diag_color_prefix("", "\x1b[1;34m");
                caret_color = diag_color_prefix("", "\x1b[34m");
              } else {
                if (diag_kind_is_exact(kind, "help") != 0 || diag_kind_is_exact(kind, "hint") != 0) {
                  kind_color = diag_color_prefix("", "\x1b[1;32m");
                  caret_color = diag_color_prefix("", "\x1b[32m");
                }
              }
            }
          }
        }
      }
    }
    path_color = diag_color_prefix("", "\x1b[34m");
    reset = diag_color_reset();
    if (line > 0) {
      if (diag_extract_line(line, &line_start_slot[0], &line_len_slot[0]) == 0) {
        have_line = 1;
      }
    }
    diag_print_header(kind, code, msg, kind_color, reset);
    if (actual_file != 0 as *u8) {
      diag_io_fprint_loc_file_line_col(err, path_color, actual_file, line, col, reset);
    } else {
      if (line > 0 || col > 0) {
        diag_io_fprint_loc_line_col(err, path_color, line, col, reset);
      }
    }
    if (have_line == 0 || line <= 0 || col <= 0) {
      return;
    }
    line_start = diag_snap_load_ptr(&line_start_slot[0], 0);
    line_len_u = diag_snap_load_usize(&line_len_slot[0], 0);
    width = diag_line_digits(line);
    diag_io_fprint_gutter_blank(err, width);
    diag_io_fprint_src_line(err, line, line_start, line_len_u as i32);
    diag_io_fprint_gutter_bar(err, width);
    if (col > 1) {
      caret_col = col - 1;
    }
    while (i < caret_col) {
      if ((i as usize) < line_len_u && line_start != 0 as *u8 && line_start[i] == 9) {
        diag_io_fputc(err, 9);
      } else {
        diag_io_fputc(err, 32);
      }
      i = i + 1;
    }
    diag_io_fprint_caret_mark(err, caret_color, reset, detail);
  }
}

// See implementation.
/**
 * Case-insensitive ASCII compare of two diagnostic codes.
 * A null pointer returns 0. Bytes a-z fold to A-Z. The match
 * stops at the first NUL on either side; both must end together.
 * Strings longer than 4096 bytes without a NUL compare as unequal.
 * @param lhs *u8 — left code, or null
 * @param rhs *u8 — right code, or null
 * @return i32 — 1 when equal, 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
  let i: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (lhs == 0 as *u8) {
    return 0;
  }
  if (rhs == 0 as *u8) {
    return 0;
  }
  unsafe {
    while (i < 4096) {
      let a: u8 = lhs[i];
      let b: u8 = rhs[i];
      if (a >= 97) {
        if (a <= 122) {
          a = a - 32;
        }
      }
      if (b >= 97) {
        if (b <= 122) {
          b = b - 32;
        }
      }
      if (a != b) {
        return 0;
      }
      if (a == 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

/**
 * Case-insensitive Levenshtein distance for short diagnostic codes.
 * A null pointer returns 999. A side of 64 bytes or more without a
 * NUL also returns 999. An empty side returns the other side's length.
 * a-z folds to A-Z. The distance is the usual insert, delete, and
 * substitute minimum. Only the first 63 bytes of each side are read.
 * @param a *u8 — left code, or null
 * @param b *u8 — right code, or null
 * @return i32 — edit distance, or 999 when the inputs are unusable
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
  let la: i32 = 0;
  let lb: i32 = 0;
  let prev: i32[64] = [];
  let cur: i32[64] = [];
  let i: i32 = 1;
  let j: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (a == 0 as *u8) {
    return 999;
  }
  if (b == 0 as *u8) {
    return 999;
  }
  unsafe {
    while (la < 64) {
      if (a[la] == 0) {
        break;
      }
      la = la + 1;
    }
    while (lb < 64) {
      if (b[lb] == 0) {
        break;
      }
      lb = lb + 1;
    }
    if (la >= 64) {
      return 999;
    }
    if (lb >= 64) {
      return 999;
    }
    if (la == 0) {
      return lb;
    }
    if (lb == 0) {
      return la;
    }
    while (j <= lb) {
      prev[j] = j;
      j = j + 1;
    }
    while (i <= la) {
      cur[0] = i;
      j = 1;
      while (j <= lb) {
        let ca: u8 = a[i - 1];
        let cb: u8 = b[j - 1];
        let cost: i32 = 1;
        let del: i32 = 0;
        let ins: i32 = 0;
        let sub: i32 = 0;
        let m: i32 = 0;
        if (ca >= 97) {
          if (ca <= 122) {
            ca = ca - 32;
          }
        }
        if (cb >= 97) {
          if (cb <= 122) {
            cb = cb - 32;
          }
        }
        if (ca == cb) {
          cost = 0;
        }
        del = prev[j] + 1;
        ins = cur[j - 1] + 1;
        sub = prev[j - 1] + cost;
        m = del;
        if (ins < m) {
          m = ins;
        }
        if (sub < m) {
          m = sub;
        }
        cur[j] = m;
        j = j + 1;
      }
      j = 0;
      while (j <= lb) {
        prev[j] = cur[j];
        j = j + 1;
      }
      i = i + 1;
    }
    return prev[lb];
  }
  return 999;
}

/**
 * Write one JSON string literal, including the surrounding quotes.
 * Escapes quote, backslash, and the usual controls. Bytes below 32
 * go through diag_io_fputs_u04x, which still formats in the seed.
 * A null pointer is an empty string. Stops at the first NUL, or at
 * 1048576 bytes if the buffer is not terminated.
 * @param out *u8 — opaque fd handle
 * @param s *u8 — source bytes, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_json_write_str(out: *u8, s: *u8): void {
  let p: *u8 = s;
  let i: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (p == 0 as *u8) {
    p = "";
  }
  unsafe {
    diag_io_fputc(out, 34);
    while (i < 1048576) {
      let c: u8 = p[i];
      if (c == 0) {
        break;
      }
      if (c == 34) {
        diag_io_fputs("\\\"", out);
      } else {
        if (c == 92) {
          diag_io_fputs("\\\\", out);
        } else {
          if (c == 8) {
            diag_io_fputs("\\b", out);
          } else {
            if (c == 12) {
              diag_io_fputs("\\f", out);
            } else {
              if (c == 10) {
                diag_io_fputs("\\n", out);
              } else {
                if (c == 13) {
                  diag_io_fputs("\\r", out);
                } else {
                  if (c == 9) {
                    diag_io_fputs("\\t", out);
                  } else {
                    if (c < 32) {
                      diag_io_fputs_u04x(out, c as u32);
                    } else {
                      diag_io_fputc(out, c as i32);
                    }
                  }
                }
              }
            }
          }
        }
      }
      i = i + 1;
    }
    diag_io_fputc(out, 34);
  }
}

/**
 * Emit one diagnostic as a single NDJSON object on stderr.
 * line and col are printed by diag_io_fprint_line_col (seed printf).
 * Does not flush; fd 2 writes are unbuffered.
 * @param file *u8 — path, or null / empty for JSON null
 * @param line i32 — printed even when 0
 * @param col i32 — printed even when 0
 * @param kind *u8 — mapped by diag_json_severity
 * @param code *u8 — code, or null / empty for JSON null
 * @param msg *u8 — message, or null for an empty string
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  let err: *u8 = 0 as *u8;
  let sev: *u8 = 0 as *u8;
  let m: *u8 = msg;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (m == 0 as *u8) {
    m = "";
  }
  unsafe {
    err = diag_stderr();
    sev = diag_json_severity(kind);
    diag_io_fputs("{\"severity\":", err);
    diag_json_write_str(err, sev);
    diag_io_fputs(",\"code\":", err);
    if (code != 0 as *u8 && code[0] != 0) {
      diag_json_write_str(err, code);
    } else {
      diag_io_fputs("null", err);
    }
    diag_io_fputs(",\"file\":", err);
    if (file != 0 as *u8 && file[0] != 0) {
      diag_json_write_str(err, file);
    } else {
      diag_io_fputs("null", err);
    }
    diag_io_fprint_line_col(err, line, col);
    diag_json_write_str(err, m);
    diag_io_fputs("}\n", err);
  }
}

/**
 * Map a diagnostic kind word to the JSON severity string.
 * A kind that contains "warning" is warning. Exact info and note
 * keep their names. Exact help and hint both become "help".
 * Anything else, including a null or empty kind, is "error".
 * @param kind *u8 — severity word, or null
 * @return *u8 — static severity literal
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_json_severity(kind: *u8): *u8 {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (kind == 0 as *u8) {
    return "error";
  }
  unsafe {
    if (kind[0] == 0) {
      return "error";
    }
    if (diag_kind_contains(kind, "warning") != 0) {
      return "warning";
    }
    if (diag_kind_is_exact(kind, "info") != 0) {
      return "info";
    }
    if (diag_kind_is_exact(kind, "note") != 0) {
      return "note";
    }
    if (diag_kind_is_exact(kind, "help") != 0 || diag_kind_is_exact(kind, "hint") != 0) {
      return "help";
    }
  }
  return "error";
}

/**
 * Suggest the closest known diagnostic code.
 * A null code, an empty code, or an empty table returns null and
 * does not write out. Distance above 3, or above the query length
 * plus one, also returns null without writing. When out is non-null
 * and out_cap is positive, the suggestion is copied and out is
 * returned. When out is null, the table pointer is returned.
 * The query length stops at 256 bytes if there is no NUL.
 * @param code *u8 — unknown code, or null
 * @param out *u8 — destination, or null to query only
 * @param out_cap i64 — byte capacity of out
 * @return *u8 — out, the table code, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_suggest(code: *u8, out: *u8, out_cap: i64): *u8 {
  let n: i64 = 0;
  let code_len: i32 = 0;
  let best_dist: i32 = 999;
  let best: *u8 = 0 as *u8;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (code == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    n = diag_code_table_len();
    if (n <= 0) {
      return 0 as *u8;
    }
    while (code_len < 256) {
      if (code[code_len] == 0) {
        break;
      }
      code_len = code_len + 1;
    }
    if (code_len <= 0) {
      return 0 as *u8;
    }
    while (i < n) {
      let cand: *u8 = diag_code_table_code_at(i);
      if (cand != 0 as *u8) {
        let d: i32 = diag_levenshtein_ci(code, cand);
        if (d < best_dist) {
          best_dist = d;
          best = cand;
        }
      }
      i = i + 1;
    }
    if (best == 0 as *u8) {
      return 0 as *u8;
    }
    if (best_dist > 3) {
      return 0 as *u8;
    }
    if (best_dist > code_len + 1) {
      return 0 as *u8;
    }
    if (out != 0 as *u8 && out_cap > 0) {
      let lim: i64 = out_cap - 1;
      let j: i64 = 0;
      while (j < lim) {
        let ch: u8 = best[j as i32];
        if (ch == 0) {
          break;
        }
        out[j as i32] = ch;
        j = j + 1;
      }
      out[j as i32] = 0;
    }
    if (out != 0 as *u8) {
      return out;
    }
    return best;
  }
  return 0 as *u8;
}

// ---- G-02f-386：ctx color / code_table_has / json state → seed impl ----
export extern "C" function diag_json_get_state_impl(): i32;
export extern "C" function diag_json_set_state_impl(v: i32): i32;

/** Exported function `diag_ctx_get_use_color`.
 * Implements `diag_ctx_get_use_color`.
 * @return i32
 */
#[no_mangle]
export function diag_ctx_get_use_color(): i32 {
  unsafe {
    return diag_ctx_get_use_color_impl();
  }
}
/**
 * Return 1 when code matches a table row, using case-insensitive equality.
 * A null or empty code returns 0.
 * @param code *u8
 * @return i32
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_has(code: *u8): i32 {
  let n: i64 = 0;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    n = diag_code_table_len();
    while (i < n) {
      if (diag_code_eq(code, diag_code_table_code_at(i)) != 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

/** Exported function `diag_json_get_state`.
 * Implements `diag_json_get_state`.
 * @return i32
 */
#[no_mangle]
export function diag_json_get_state(): i32 {
  unsafe {
    return diag_json_get_state_impl();
  }
  return 0 - 2;
}

/** Exported function `diag_json_set_state`.
 * Implements `diag_json_set_state`.
 * @param v i32
 * @return i32
 */
#[no_mangle]
export function diag_json_set_state(v: i32): i32 {
  unsafe {
    return diag_json_set_state_impl(v);
  }
}

// See implementation.
export extern "C" function diag_io_fputc_impl(o: *u8, c: i32): i32;
export extern "C" function diag_io_fputs_impl(s: *u8, o: *u8): i32;
export extern "C" function diag_io_fputs_u04x_impl(o: *u8, c: u32): void;
export extern "C" function diag_io_fflush_impl(o: *u8): void;
export extern "C" function diag_io_fprint_line_col_impl(o: *u8, line: i32, col: i32): void;
export extern "C" function diag_io_fprint_loc_file_line_col_impl(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file_line_impl(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file_impl(o: *u8, pc: *u8, file: *u8, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_line_col_impl(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_gutter_blank_impl(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_src_line_impl(o: *u8, line: i32, start: *u8, len: i32): void;
export extern "C" function diag_io_fprint_gutter_bar_impl(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_caret_mark_impl(o: *u8, cc: *u8, rs: *u8, detail: *u8): void;
export extern "C" function diag_io_fprint_unknown_code_impl(out: *u8, code: *u8): void;
export extern "C" function diag_io_fprint_code_table_hdr_impl(out: *u8): void;
export extern "C" function diag_io_fprint_code_table_row_impl(out: *u8, code: *u8, kind: *u8, summary: *u8): void;

/** Exported function `diag_io_fputc`.
 * Implements `diag_io_fputc`.
 * @param o *u8
 * @param c i32
 * @return i32
 */
#[no_mangle]
export function diag_io_fputc(o: *u8, c: i32): i32 {
  unsafe { return diag_io_fputc_impl(o, c); }
}

/** Exported function `diag_io_fputs`.
 * Implements `diag_io_fputs`.
 * @param s *u8
 * @param o *u8
 * @return i32
 */
#[no_mangle]
export function diag_io_fputs(s: *u8, o: *u8): i32 {
  unsafe { return diag_io_fputs_impl(s, o); }
}

/** Exported function `diag_io_fputs_u04x`.
 * Implements `diag_io_fputs_u04x`.
 * @param o *u8
 * @param c u32
 * @return void
 */
#[no_mangle]
export function diag_io_fputs_u04x(o: *u8, c: u32): void {
  unsafe { diag_io_fputs_u04x_impl(o, c); }
}

/** Exported function `diag_io_fflush`.
 * Implements `diag_io_fflush`.
 * @param o *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fflush(o: *u8): void {
  unsafe { diag_io_fflush_impl(o); }
}

/** Exported function `diag_io_fprint_line_col`.
 * Implements `diag_io_fprint_line_col`.
 * @param o *u8
 * @param line i32
 * @param col i32
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_line_col(o: *u8, line: i32, col: i32): void {
  unsafe { diag_io_fprint_line_col_impl(o, line, col); }
}

/** Exported function `diag_io_fprint_loc_file_line_col`.
 * Implements `diag_io_fprint_loc_file_line_col`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param line i32
 * @param col i32
 * @param rs *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_loc_file_line_col(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_col_impl(o, pc, file, line, col, rs); }
}

/** Exported function `diag_io_fprint_loc_file_line`.
 * Implements `diag_io_fprint_loc_file_line`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param line i32
 * @param rs *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_loc_file_line(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_line_impl(o, pc, file, line, rs); }
}

/** Exported function `diag_io_fprint_loc_file`.
 * Implements `diag_io_fprint_loc_file`.
 * @param o *u8
 * @param pc *u8
 * @param file *u8
 * @param rs *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_loc_file(o: *u8, pc: *u8, file: *u8, rs: *u8): void {
  unsafe { diag_io_fprint_loc_file_impl(o, pc, file, rs); }
}

/** Exported function `diag_io_fprint_loc_line_col`.
 * Implements `diag_io_fprint_loc_line_col`.
 * @param o *u8
 * @param pc *u8
 * @param line i32
 * @param col i32
 * @param rs *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_loc_line_col(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void {
  unsafe { diag_io_fprint_loc_line_col_impl(o, pc, line, col, rs); }
}

/** Exported function `diag_io_fprint_gutter_blank`.
 * Implements `diag_io_fprint_gutter_blank`.
 * @param o *u8
 * @param width i32
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_gutter_blank(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_blank_impl(o, width); }
}

/** Exported function `diag_io_fprint_src_line`.
 * Implements `diag_io_fprint_src_line`.
 * @param o *u8
 * @param line i32
 * @param start *u8
 * @param len i32
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_src_line(o: *u8, line: i32, start: *u8, len: i32): void {
  unsafe { diag_io_fprint_src_line_impl(o, line, start, len); }
}

/** Exported function `diag_io_fprint_gutter_bar`.
 * Implements `diag_io_fprint_gutter_bar`.
 * @param o *u8
 * @param width i32
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_gutter_bar(o: *u8, width: i32): void {
  unsafe { diag_io_fprint_gutter_bar_impl(o, width); }
}

/** Exported function `diag_io_fprint_caret_mark`.
 * Implements `diag_io_fprint_caret_mark`.
 * @param o *u8
 * @param cc *u8
 * @param rs *u8
 * @param detail *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_caret_mark(o: *u8, cc: *u8, rs: *u8, detail: *u8): void {
  unsafe { diag_io_fprint_caret_mark_impl(o, cc, rs, detail); }
}
/**
 * Number of rows in the diagnostic code table.
 * @return i64 — 43
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_len(): i64 {
  let pad: u8[32] = [];
  pad[0] = 0;
  return 43;
}

/** Exported function `diag_io_fprint_unknown_code`.
 * Implements `diag_io_fprint_unknown_code`.
 * @param out *u8
 * @param code *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_unknown_code(out: *u8, code: *u8): void {
  unsafe { diag_io_fprint_unknown_code_impl(out, code); }
}

/** Exported function `diag_io_fprint_code_table_hdr`.
 * Implements `diag_io_fprint_code_table_hdr`.
 * @param out *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_code_table_hdr(out: *u8): void {
  unsafe { diag_io_fprint_code_table_hdr_impl(out); }
}

/** Exported function `diag_io_fprint_code_table_row`.
 * Implements `diag_io_fprint_code_table_row`.
 * @param out *u8
 * @param code *u8
 * @param kind *u8
 * @param summary *u8
 * @return void
 */
#[no_mangle]
export function diag_io_fprint_code_table_row(out: *u8, code: *u8, kind: *u8, summary: *u8): void {
  unsafe { diag_io_fprint_code_table_row_impl(out, code, kind, summary); }
}

// ---- G-02f-420：ctx field get/set → seed impl pure forward ----
/** Exported function `diag_ctx_get_file`.
 * Implements `diag_ctx_get_file`.
 * @return *u8
 */
#[no_mangle]
export function diag_ctx_get_file(): *u8 {
  unsafe { return diag_ctx_get_file_impl(); }
}

/** Exported function `diag_ctx_get_source`.
 * Implements `diag_ctx_get_source`.
 * @return *u8
 */
#[no_mangle]
export function diag_ctx_get_source(): *u8 {
  unsafe { return diag_ctx_get_source_impl(); }
}

/** Exported function `diag_ctx_get_source_len`.
 * Query helper `diag_ctx_get_source_len`.
 * @return i64
 */
#[no_mangle]
export function diag_ctx_get_source_len(): i64 {
  unsafe { return diag_ctx_get_source_len_impl(); }
}

/** Exported function `diag_ctx_set_all`.
 * Implements `diag_ctx_set_all`.
 * @param path *u8
 * @param source *u8
 * @param source_len i64
 * @param use_color i32
 * @return void
 */
#[no_mangle]
export function diag_ctx_set_all(path: *u8, source: *u8, source_len: i64, use_color: i32): void {
  unsafe { diag_ctx_set_all_impl(path, source, source_len, use_color); }
}

// ---- G-02f-421：code table / entry / stdio handles → seed impl ----
export extern "C" function diag_stderr_impl(): *u8;
export extern "C" function diag_stdout_impl(): *u8;
/**
 * Diagnostic code at this table index.
 * Index is 0-based. A negative or out-of-range index returns null.
 * The strings are the diagnostic code table. Count is 43.
 * @param i i64
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_code_at(i: i64): *u8 {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (i == 0) { return "P001"; }
  if (i == 1) { return "T001"; }
  if (i == 2) { return "ARG001"; }
  if (i == 3) { return "ARG002"; }
  if (i == 4) { return "IO001"; }
  if (i == 5) { return "PRC001"; }
  if (i == 6) { return "BLD001"; }
  if (i == 7) { return "PP001"; }
  if (i == 8) { return "PP002"; }
  if (i == 9) { return "L001"; }
  if (i == 10) { return "L002"; }
  if (i == 11) { return "L003"; }
  if (i == 12) { return "L004"; }
  if (i == 13) { return "L005"; }
  if (i == 14) { return "L006"; }
  if (i == 15) { return "L007"; }
  if (i == 16) { return "L008"; }
  if (i == 17) { return "L009"; }
  if (i == 18) { return "L010"; }
  if (i == 19) { return "L011"; }
  if (i == 20) { return "L012"; }
  if (i == 21) { return "IMP001"; }
  if (i == 22) { return "IMP002"; }
  if (i == 23) { return "IMP003"; }
  if (i == 24) { return "IMP004"; }
  if (i == 25) { return "XP001"; }
  if (i == 26) { return "XP002"; }
  if (i == 27) { return "XP003"; }
  if (i == 28) { return "XP004"; }
  if (i == 29) { return "XP005"; }
  if (i == 30) { return "XP006"; }
  if (i == 31) { return "XP007"; }
  if (i == 32) { return "XP008"; }
  if (i == 33) { return "XT001"; }
  if (i == 34) { return "CG001"; }
  if (i == 35) { return "CG002"; }
  if (i == 36) { return "CG003"; }
  if (i == 37) { return "CG004"; }
  if (i == 38) { return "CHK001"; }
  if (i == 39) { return "CHK002"; }
  if (i == 40) { return "FMT001"; }
  if (i == 41) { return "SMOKE001"; }
  if (i == 42) { return "SMOKE002"; }
  return 0 as *u8;
}
/**
 * Kind word at this table index.
 * Index is 0-based. A negative or out-of-range index returns null.
 * The strings are the diagnostic code table. Count is 43.
 * @param i i64
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_kind_at(i: i64): *u8 {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (i == 0) { return "parse error"; }
  if (i == 1) { return "typeck error"; }
  if (i == 2) { return "usage error"; }
  if (i == 3) { return "argument error"; }
  if (i == 4) { return "io error"; }
  if (i == 5) { return "process error"; }
  if (i == 6) { return "build error"; }
  if (i == 7) { return "preprocess error"; }
  if (i == 8) { return "preprocess error"; }
  if (i == 9) { return "lexer error"; }
  if (i == 10) { return "lexer error"; }
  if (i == 11) { return "lexer error"; }
  if (i == 12) { return "lexer error"; }
  if (i == 13) { return "lexer error"; }
  if (i == 14) { return "lexer error"; }
  if (i == 15) { return "lexer error"; }
  if (i == 16) { return "lexer error"; }
  if (i == 17) { return "lexer error"; }
  if (i == 18) { return "lexer error"; }
  if (i == 19) { return "lexer error"; }
  if (i == 20) { return "lexer error"; }
  if (i == 21) { return "import error"; }
  if (i == 22) { return "preprocess error"; }
  if (i == 23) { return "import error"; }
  if (i == 24) { return "import error"; }
  if (i == 25) { return "pipeline error"; }
  if (i == 26) { return "pipeline error"; }
  if (i == 27) { return "pipeline error"; }
  if (i == 28) { return "pipeline error"; }
  if (i == 29) { return "pipeline error"; }
  if (i == 30) { return "pipeline error"; }
  if (i == 31) { return "pipeline error"; }
  if (i == 32) { return "pipeline error"; }
  if (i == 33) { return "typeck error"; }
  if (i == 34) { return "codegen error"; }
  if (i == 35) { return "codegen error"; }
  if (i == 36) { return "codegen error"; }
  if (i == 37) { return "codegen error"; }
  if (i == 38) { return "check error"; }
  if (i == 39) { return "check error"; }
  if (i == 40) { return "fmt error"; }
  if (i == 41) { return "info"; }
  if (i == 42) { return "info"; }
  return 0 as *u8;
}
/**
 * Summary sentence at this table index.
 * Index is 0-based. A negative or out-of-range index returns null.
 * The strings are the diagnostic code table. Count is 43.
 * @param i i64
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_summary_at(i: i64): *u8 {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (i == 0) { return "Parser detected invalid syntax or unrecoverable parse failure."; }
  if (i == 1) { return "Type checker rejected a construct after successful parse."; }
  if (i == 2) { return "CLI command or option is missing a required argument."; }
  if (i == 3) { return "CLI argument value is unknown or unsupported."; }
  if (i == 4) { return "A file operation failed before the requested compiler step could continue."; }
  if (i == 5) { return "A child process or system-level process operation failed."; }
  if (i == 6) { return "An external build or link step failed before producing a usable artifact."; }
  if (i == 7) { return "Preprocessor found an unclosed conditional directive."; }
  if (i == 8) { return "Preprocessor failed before producing a usable source buffer."; }
  if (i == 9) { return "Lexer found an unclosed block comment."; }
  if (i == 10) { return "Lexer found an unclosed string literal."; }
  if (i == 11) { return "Lexer found an illegal character."; }
  if (i == 12) { return "Lexer found an incomplete hex literal."; }
  if (i == 13) { return "Lexer found an incomplete float exponent."; }
  if (i == 14) { return "Lexer found an incomplete binary literal."; }
  if (i == 15) { return "Lexer found an incomplete octal literal."; }
  if (i == 16) { return "Lexer found an invalid digit separator."; }
  if (i == 17) { return "Lexer found an invalid type suffix on a numeric literal."; }
  if (i == 18) { return "Lexer found an invalid escape sequence in a string literal."; }
  if (i == 19) { return "Lexer found a string literal that exceeds AST storage capacity."; }
  if (i == 20) { return "Lexer found an identifier that exceeds AST name storage capacity."; }
  if (i == 21) { return "Import path could not be opened from the resolved candidate path."; }
  if (i == 22) { return "Imported module failed during preprocessing before parse."; }
  if (i == 23) { return "Imported module failed to parse after preprocessing."; }
  if (i == 24) { return "Import pipeline failed in a later dependency-resolution stage."; }
  if (i == 25) { return ".x pipeline parse stage failed before building a usable module."; }
  if (i == 26) { return ".x pipeline parse commit failed while committing a parsed function."; }
  if (i == 27) { return ".x pipeline terminated with a non-zero runtime status code."; }
  if (i == 28) { return ".x pipeline path resolution trace for a failed import or entry lookup."; }
  if (i == 29) { return ".x pipeline failed while allocating required runtime structures."; }
  if (i == 30) { return ".x pipeline failed while allocating output or dependency context state."; }
  if (i == 31) { return ".x pipeline refused an input buffer that exceeds parser size limits."; }
  if (i == 32) { return ".x dependency sub-pipeline failed while prerunning an imported module."; }
  if (i == 33) { return ".x pipeline type checking failed for a specific function."; }
  if (i == 34) { return "Code generation could not emit C output because no main entry was available."; }
  if (i == 35) { return "ASM object emission failed before producing a usable .o payload."; }
  if (i == 36) { return "Code generator failed while emitting a specific function body."; }
  if (i == 37) { return "Code generation produced an empty output buffer after a non-failing pipeline."; }
  if (i == 38) { return "`xlang check` failed without a more specific structured diagnostic."; }
  if (i == 39) { return "`xlang check` found no .x files to inspect."; }
  if (i == 40) { return "`xlang fmt` failed or found no format candidates."; }
  if (i == 41) { return "Parse-stage smoke summary: source parsed successfully."; }
  if (i == 42) { return "Typeck-stage smoke summary: type checking passed."; }
  return 0 as *u8;
}
/**
 * Details paragraph at this table index.
 * Index is 0-based. A negative or out-of-range index returns null.
 * The strings are the diagnostic code table. Count is 43.
 * @param i i64
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_code_table_details_at(i: i64): *u8 {
  let pad: u8[32] = [];
  pad[0] = 0;
  if (i == 0) { return "Used for parser-side syntax errors and parser fatal conditions such as out-of-memory. Typical action: inspect the reported token/statement boundary and surrounding source line."; }
  if (i == 1) { return "Used for regular C-path type checking failures such as mismatched types, invalid assignments, or non-bool conditions. Typical action: compare inferred and expected types at the caret location."; }
  if (i == 2) { return "Used when a command such as `--explain` or another CLI option is present but the required value is missing. Typical action: re-run with the required operand shown in the usage hint."; }
  if (i == 3) { return "Used when a user-provided CLI argument cannot be recognized, such as an unknown diagnostic code for `--explain`. Typical action: inspect the suggested valid values and retry with one of them."; }
  if (i == 4) { return "Used for common runtime file-operation failures such as open, read, write, rename, or temp-file setup. Typical action: inspect the path in the diagnostic and verify permissions, existence, and parent directories."; }
  if (i == 5) { return "Used for waitpid, system(), or child-process termination failures in compiler helper paths. Typical action: inspect the named tool or script and any paired stderr emitted before this summary."; }
  if (i == 6) { return "Used for compiler/linker/tool invocations and runtime object build failures summarized at the driver layer. Typical action: inspect the failing tool name, exit status, and any preceding build stderr."; }
  if (i == 7) { return "Used when `#if` / `#elseif` / `#else` nesting does not terminate cleanly before end-of-file. Typical action: inspect nearby conditional compilation directives and ensure every `#if` is closed."; }
  if (i == 8) { return "Used for directive errors or generic preprocess failures that are not covered by a more specific code. Typical action: inspect the reported source file and nearby conditional compilation directives."; }
  if (i == 9) { return "Used when a nested `/* ... */` block comment reaches end-of-file with nesting depth still greater than zero. Typical action: add the matching `*/` closers for every true nest-open `/*` (path globs like `src/*.x` do not nest-open)."; }
  if (i == 10) { return "Used when a double-quoted string reaches end-of-file without a closing quote. Typical action: add the matching `\"` at the end of the string (multi-line strings are allowed if closed)."; }
  if (i == 11) { return "Used when a source byte is not a recognized token introducer (for example `$`, bare `'`, or other non-ASCII/punct noise). Typical action: remove or replace the illegal character; character literals are not part of the product lexical surface."; }
  if (i == 12) { return "Used when a hex integer introducer `0x` or `0X` is not followed by at least one hex digit (0-9, a-f, A-F). Typical action: complete the literal (e.g. `0x0`, `0xFF`) or remove the incomplete `0x` prefix."; }
  if (i == 13) { return "Used when a float exponent introducer `e` or `E` (optionally followed by `+` or `-`) is not followed by at least one decimal digit. Typical action: complete the exponent (e.g. `1e0`, `1.5e+2`) or remove the incomplete exponent suffix."; }
  if (i == 14) { return "Used when a binary integer introducer `0b` or `0B` is not followed by at least one binary digit (0 or 1). Typical action: complete the literal (e.g. `0b0`, `0b1010`) or remove the incomplete `0b` prefix."; }
  if (i == 15) { return "Used when an octal integer introducer `0o` or `0O` is not followed by at least one octal digit (0-7). Typical action: complete the literal (e.g. `0o0`, `0o52`) or remove the incomplete `0o` prefix."; }
  if (i == 16) { return "Used when `_` appears in a numeric literal without a following valid digit for that radix (trailing `_`, consecutive `__`, or `_` before a non-digit). Typical action: remove the underscore or place it only between digits (e.g. `1_000`, `0x2_A`)."; }
  if (i == 17) { return "Used when a complete integer or float literal is immediately followed by alphabetic characters (for example `42u32`, `0x2Ai64`, `1.5f32`, or `42foo`). The language has no C/Rust-style type suffixes on numerics; use context type coerce (e.g. `let n: u32 = 42`) or `as T`. Typical action: remove the suffix or rewrite with `as` / annotated `let`."; }
  if (i == 18) { return "Used when a string escape is not one of the product set `\\n \\t \\r \\0 \\\\ \\\" \\xHH` (for example `\\q`, incomplete `\\x`, or `\\xG`). Typical action: use a supported escape or write the byte as `\\xHH`."; }
  if (i == 19) { return "Used when a decoded string literal (including C-style adjacent concatenation) would exceed 127 semantic bytes stored in Expr.var_name. Prior soft residual silently truncated. Typical action: shorten the literal, split into multiple strings with runtime concat (std.string), or await a future larger AST string pool."; }
  if (i == 20) { return "Used when a non-keyword identifier span is longer than 255 bytes (AST name[256] content cap). Prior soft residual could silent-clamp names or fail with opaque XP003/typeck mismatch. Typical action: shorten the identifier, or await a future larger AST name layout."; }
  if (i == 21) { return "Used when an import target cannot be opened after path resolution. Typical action: verify the import name, library roots, and the resolved on-disk file path shown in the diagnostic."; }
  if (i == 22) { return "Used when an imported file was found but preprocessing of that import failed. Typical action: inspect the imported file for conditional-compilation errors such as unclosed directives."; }
  if (i == 23) { return "Used when an import file was read and preprocessed successfully but parse still failed. Typical action: inspect the imported module with the reported parser diagnostics."; }
  if (i == 24) { return "Used for import-side failures such as path normalization limits, unresolved dependency closure, or imported module type-check failure summaries. Typical action: inspect the paired import diagnostics emitted earlier."; }
  if (i == 25) { return "Used when the .x pipeline cannot finish parse/module construction. Typical action: inspect the preceding parse diagnostics and the failing module entry."; }
  if (i == 26) { return "Used for stricter .x parse/commit failures after a function was tentatively parsed but could not be committed into the module. Typical action: inspect nearby function boundaries and parse-recovery logs."; }
  if (i == 27) { return "Used for generic .x pipeline summary failures reported as `pipeline failed rc=...` after a deeper stage returned an error code. Typical action: inspect preceding parser/typeck/import/codegen diagnostics."; }
  if (i == 28) { return "Used for the follow-up `resolve path tried:` diagnostic that lists the concrete path attempted before pipeline failure. Typical action: inspect the shown path and verify library roots and import naming."; }
  if (i == 29) { return "Used for allocation failures covering arena/module buffers, ELF context, or dependency-side arena/module storage before the pipeline can proceed. Typical action: inspect memory pressure and the specific pipeline stage."; }
  if (i == 30) { return "Used when `CodegenOutBuf`, `PipelineDepCtx`, or dependency-local output/context buffers cannot be allocated. Typical action: inspect memory pressure and whether a large-output path is being exercised."; }
  if (i == 31) { return "Used for `source too large for parser` failures when the source buffer exceeds the current `int32_t` parser boundary. Typical action: reduce input size or change the parser limit handling."; }
  if (i == 32) { return "Used for `pipeline failed for import` summaries emitted after a dependency prerun returns non-zero. Typical action: inspect earlier diagnostics for the referenced import path and its transitive dependencies."; }
  if (i == 33) { return "Used when .x type checking fails inside a concrete function, often with function index/name attached. Typical action: inspect the named function body and any accompanying type diagnostics."; }
  if (i == 34) { return "Used when executable-oriented C emission requires a `main` function but the module only contains library items or no callable entry. Typical action: add a `main` entry or switch to a library/module emission path."; }
  if (i == 35) { return "Used for `asm_codegen_elf_o failed` summaries where the backend or ELF writer returned a failing status or produced an empty object buffer. Typical action: inspect paired ELF context notes and earlier backend diagnostics."; }
  if (i == 36) { return "Used for `failed to emit function` summaries tied to a concrete function name or index. Typical action: inspect that function body and any preceding backend/type diagnostics for unsupported constructs."; }
  if (i == 37) { return "Used when the C-path `.x -E` pipeline returns success but the codegen output buffer is empty, indicating a codegen/pipeline wiring gap rather than a reported typeck/codegen error. Typical action: inspect the CodegenOutBuf wiring and any earlier typeck/codegen diagnostics."; }
  if (i == 38) { return "Fallback check-mode code used when compilation/check failed but no detailed parser/typeck/import diagnostic was emitted. Typical action: inspect prior stderr output and the target file path."; }
  if (i == 39) { return "Used when the provided path set, or the current directory, contains no discoverable .x sources. Typical action: verify input paths and whether ignored filters removed all candidates."; }
  if (i == 40) { return "Used for format-mode failures such as missing input files, unreadable files, or no .x files found. Typical action: verify the path list, file accessibility, and whether `--check` reported unformatted files."; }
  if (i == 41) { return "Emitted as an info-level smoke marker after a successful parse/typeck pass on the no-`-o` smoke path. Only emitted when structured smoke output is opted in (`--diag-json` or `XLANG_SMOKE_DIAG=1`); the legacy `parse OK` stdout line remains for grep/golden compatibility. Typical action: none (success marker)."; }
  if (i == 42) { return "Emitted as an info-level smoke marker after type checking succeeds on the no-`-o` smoke path. Only emitted when structured smoke output is opted in (`--diag-json` or `XLANG_SMOKE_DIAG=1`); the legacy `typeck OK` stdout line remains for grep/golden compatibility. Typical action: none (success marker)."; }
  return 0 as *u8;
}
/**
 * Canonical code spelling for a matching row.
 * Comparison is diag_code_eq, so the match is case-insensitive.
 * A null or unknown code returns null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_entry_code(code: *u8): *u8 {
  let n: i64 = 0;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    n = diag_code_table_len();
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      if (diag_code_eq(code, c) != 0) {
        return diag_code_table_code_at(i);
      }
      i = i + 1;
    }
  }
  return 0 as *u8;
}
/**
 * Kind word for a matching row.
 * Comparison is diag_code_eq, so the match is case-insensitive.
 * A null or unknown code returns null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_entry_kind(code: *u8): *u8 {
  let n: i64 = 0;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    n = diag_code_table_len();
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      if (diag_code_eq(code, c) != 0) {
        return diag_code_table_kind_at(i);
      }
      i = i + 1;
    }
  }
  return 0 as *u8;
}
/**
 * Summary for a matching row.
 * Comparison is diag_code_eq, so the match is case-insensitive.
 * A null or unknown code returns null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_entry_summary(code: *u8): *u8 {
  let n: i64 = 0;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    n = diag_code_table_len();
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      if (diag_code_eq(code, c) != 0) {
        return diag_code_table_summary_at(i);
      }
      i = i + 1;
    }
  }
  return 0 as *u8;
}
/**
 * Details for a matching row.
 * Comparison is diag_code_eq, so the match is case-insensitive.
 * A null or unknown code returns null.
 * @param code *u8
 * @return *u8
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function diag_entry_details(code: *u8): *u8 {
  let n: i64 = 0;
  let i: i64 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    n = diag_code_table_len();
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      if (diag_code_eq(code, c) != 0) {
        return diag_code_table_details_at(i);
      }
      i = i + 1;
    }
  }
  return 0 as *u8;
}

/** Exported function `diag_stderr`.
 * Implements `diag_stderr`.
 * @return *u8
 */
#[no_mangle]
export function diag_stderr(): *u8 {
  unsafe { return diag_stderr_impl(); }
}

/** Exported function `diag_stdout`.
 * Implements `diag_stdout`.
 * @return *u8
 */
#[no_mangle]
export function diag_stdout(): *u8 {
  unsafe { return diag_stdout_impl(); }
}
