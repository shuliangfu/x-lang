// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// runtime_path_fast_x_doc_anchor: see function docblock below.


/** Exported function `runtime_path_fast_x_doc_anchor`.
 * Implements `runtime_path_fast_x_doc_anchor`.
 * @return i32
 */
export function runtime_path_fast_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */









// path_sep_c: see function docblock below.

#[no_mangle]
/** Exported function `path_sep_c`.
 * Implements `path_sep_c`.
 * @return u8
 */
export function path_sep_c(): u8 {
  // See implementation.
  return 47 as u8;
}

#[no_mangle]
/** Exported function `path_is_sep_c`.
 * Implements `path_is_sep_c`.
 * @param c u8
 * @return i32
 */
export function path_is_sep_c(c: u8): i32 {
  if (c == 47) { return 1; }
  if (c == 92) { return 1; }
  return 0;
}

#[no_mangle]
/** Exported function `path_last_sep_c`.
 * Implements `path_last_sep_c`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function path_last_sep_c(path: *u8, path_len: i32): i32 {
  let i: i32 = path_len - 1;
  while (i >= 0) {
    if (path_is_sep_c(path[i]) != 0) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

// path_last_dot_c: see function docblock below.

#[no_mangle]
/** Exported function `path_last_dot_c`.
 * Implements `path_last_dot_c`.
 * @param path *u8
 * @param start i32
 * @param len i32
 * @return i32
 */
export function path_last_dot_c(path: *u8, start: i32, len: i32): i32 {
  let i: i32 = start + len - 1;
  while (i >= start) {
    if (path[i] == 46) { return i - start; }
    i = i - 1;
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function std_path_empty_len(): i32 {
  return 0;
}

#[no_mangle]
/** Exported function `std_path_sep`.
 * Implements `std_path_sep`.
 * @return u8
 */
export function std_path_sep(): u8 {
  return path_sep_c();
}

#[no_mangle]
/** Exported function `std_path_join`.
 * Implements `std_path_join`.
 * @param out *u8
 * @param out_max i32
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return i32
 */
export function std_path_join(out: *u8, out_max: i32, a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  let need_sep: i32 = 0;
  let total: i32 = 0;
  let k: i32 = 0;
  let i: i32 = 0;
  if (a_len > 0) {
    if (path_is_sep_c(a[a_len - 1]) == 0) { need_sep = 1; }
  }
  total = a_len + need_sep + b_len;
  if (total <= 0) { return 0; }
  if (total > out_max) { return 0 - 1; }
  k = 0;
  i = 0;
  while (i < a_len) {
    out[k] = a[i];
    k = k + 1;
    i = i + 1;
  }
  if (need_sep != 0) {
    out[k] = path_sep_c();
    k = k + 1;
  }
  i = 0;
  while (i < b_len) {
    out[k] = b[i];
    k = k + 1;
    i = i + 1;
  }
  return k;
}

#[no_mangle]
/** Exported function `std_path_dirname`.
 * Implements `std_path_dirname`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function std_path_dirname(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last: i32 = path_last_sep_c(path, path_len);
  let i: i32 = 0;
  if (last <= 0) { return 0; }
  if (last > out_max) { return 0 - 1; }
  while (i < last) {
    if (i >= out_max) { break; }
    out[i] = path[i];
    i = i + 1;
  }
  return i;
}

#[no_mangle]
/** Exported function `std_path_basename`.
 * Implements `std_path_basename`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function std_path_basename(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last: i32 = path_last_sep_c(path, path_len);
  let start: i32 = last + 1;
  let seg_len: i32 = path_len - start;
  let i: i32 = 0;
  if (seg_len <= 0) { return 0; }
  if (seg_len > out_max) { return 0 - 1; }
  while (i < seg_len) {
    out[i] = path[start + i];
    i = i + 1;
  }
  return i;
}

#[no_mangle]
/** Exported function `std_path_is_absolute`.
 * Implements `std_path_is_absolute`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function std_path_is_absolute(path: *u8, path_len: i32): i32 {
  let c0: u8 = 0;
  let is_alpha: i32 = 0;
  if (path_len <= 0) { return 0; }
  if (path[0] == 47) { return 1; }
  if (path_len >= 2) {
    if (path[0] == 92) {
      if (path[1] == 92) { return 1; }
    }
  }
  if (path_len >= 3) {
    if (path[1] == 58) {
      c0 = path[0];
      is_alpha = 0;
      if (c0 >= 65) {
        if (c0 <= 90) { is_alpha = 1; }
      }
      if (is_alpha == 0) {
        if (c0 >= 97) {
          if (c0 <= 122) { is_alpha = 1; }
        }
      }
      if (is_alpha != 0) {
        if (path[2] == 92) { return 1; }
        if (path[2] == 47) { return 1; }
      }
    }
  }
  return 0;
}

#[no_mangle]
/** Exported function `std_path_is_sep`.
 * Implements `std_path_is_sep`.
 * @param c u8
 * @return i32
 */
export function std_path_is_sep(c: u8): i32 {
  return path_is_sep_c(c);
}

#[no_mangle]
/** Exported function `std_path_extension`.
 * Implements `std_path_extension`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function std_path_extension(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last_sl: i32 = path_last_sep_c(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  let dot_rel: i32 = 0;
  let ext_len: i32 = 0;
  let i: i32 = 0;
  if (base_len <= 0) { return 0; }
  dot_rel = path_last_dot_c(path, base_start, base_len);
  if (dot_rel < 0) { return 0; }
  if (dot_rel == 0) { return 0; }
  if (dot_rel >= base_len - 1) { return 0; }
  ext_len = base_len - dot_rel;
  if (ext_len > out_max) { return 0 - 1; }
  while (i < ext_len) {
    out[i] = path[base_start + dot_rel + i];
    i = i + 1;
  }
  return i;
}

#[no_mangle]
/** Exported function `std_path_stem`.
 * Implements `std_path_stem`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function std_path_stem(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last_sl: i32 = path_last_sep_c(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  let dot_rel: i32 = 0;
  let stem_len: i32 = 0;
  let i: i32 = 0;
  if (base_len <= 0) { return 0; }
  dot_rel = path_last_dot_c(path, base_start, base_len);
  stem_len = base_len;
  if (dot_rel >= 0) {
    if (dot_rel > 0) {
      if (dot_rel < base_len - 1) { stem_len = dot_rel; }
    }
  }
  if (stem_len > out_max) { return 0 - 1; }
  while (i < stem_len) {
    out[i] = path[base_start + i];
    i = i + 1;
  }
  return i;
}

#[no_mangle]
/** Function `std_path_extension_and_stem`.
 * Purpose: implements `std_path_extension_and_stem`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function std_path_extension_and_stem(path: *u8, path_len: i32, ext_out: *u8, ext_max: i32,
                                     stem_out: *u8, stem_max: i32): i32 {
  let last_sl: i32 = path_last_sep_c(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  let dot_rel: i32 = 0;
  let stem_len: i32 = 0;
  let ext_len: i32 = 0;
  let i: i32 = 0;
  if (base_len <= 0) { return 0; }
  dot_rel = path_last_dot_c(path, base_start, base_len);
  stem_len = base_len;
  ext_len = 0;
  if (dot_rel >= 0) {
    if (dot_rel > 0) {
      if (dot_rel < base_len - 1) {
        stem_len = dot_rel;
        ext_len = base_len - dot_rel;
      }
    }
  }
  if (stem_len > stem_max) { return 0 - 1; }
  if (ext_len > ext_max) { return 0 - 1; }
  i = 0;
  while (i < stem_len) {
    stem_out[i] = path[base_start + i];
    i = i + 1;
  }
  i = 0;
  while (i < ext_len) {
    ext_out[i] = path[base_start + dot_rel + i];
    i = i + 1;
  }
  return (stem_len << 16) | (ext_len & 65535);
}

#[no_mangle]
/** Exported function `std_path_clean`.
 * Implements `std_path_clean`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function std_path_clean(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let seg_starts: i32[64] = [];
  let nseg: i32 = 0;
  let out_len: i32 = 0;
  let i: i32 = 0;
  let started_with_sep: i32 = 0;
  let emit_double_sep_next: i32 = 0;
  let main_sep: u8 = path_sep_c();
  let seg_begin: i32 = 0;
  let seg_len: i32 = 0;
  let k: i32 = 0;
  if (path_len <= 0) { return 0; }
  if (out_max <= 0) { return 0; }
  if (path_is_sep_c(path[0]) != 0) {
    started_with_sep = 1;
    out[0] = main_sep;
    out_len = 1;
    while (i < path_len) {
      if (path_is_sep_c(path[i]) == 0) { break; }
      i = i + 1;
    }
  }
  while (i < path_len) {
    while (i < path_len) {
      if (path_is_sep_c(path[i]) == 0) { break; }
      i = i + 1;
    }
    if (i >= path_len) { break; }
    seg_begin = i;
    while (i < path_len) {
      if (path_is_sep_c(path[i]) != 0) { break; }
      i = i + 1;
    }
    seg_len = i - seg_begin;
    if (seg_len == 1) {
      if (path[seg_begin] == 46) { continue; }
    }
    if (seg_len == 2) {
      if (path[seg_begin] == 46) {
        if (path[seg_begin + 1] == 46) {
          if (nseg > 0) {
            out_len = seg_starts[nseg - 1];
            nseg = nseg - 1;
            if (started_with_sep == 0) {
              if (out_len > 0) { emit_double_sep_next = 1; }
            }
          }
          continue;
        }
      }
    }
    if (out_len > 0) {
      if (out[out_len - 1] != main_sep) {
        if (out_len >= out_max) { return 0 - 1; }
        out[out_len] = main_sep;
        out_len = out_len + 1;
      } else {
        if (emit_double_sep_next != 0) {
          if (out_len >= out_max) { return 0 - 1; }
          out[out_len] = main_sep;
          out_len = out_len + 1;
        }
      }
    }
    emit_double_sep_next = 0;
    if (nseg < 63) {
      seg_starts[nseg] = out_len;
      nseg = nseg + 1;
    }
    k = 0;
    while (k < seg_len) {
      if (out_len >= out_max) { return 0 - 1; }
      out[out_len] = path[seg_begin + k];
      out_len = out_len + 1;
      k = k + 1;
    }
  }
  if (out_len > 1) {
    if (out[out_len - 1] == main_sep) { out_len = out_len - 1; }
  }
  return out_len;
}

#[no_mangle]
/** Function `std_path_resolve`.
 * Purpose: implements `std_path_resolve`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function std_path_resolve(out: *u8, out_max: i32, base: *u8, base_len: i32,
                          ref: *u8, ref_len: i32): i32 {
  let dir_buf: u8[256] = [];
  let tmp: u8[512] = [];
  let dir_len: i32 = 0;
  let jlen: i32 = 0;
  if (ref_len > 0) {
    if (std_path_is_absolute(ref, ref_len) != 0) {
      return std_path_clean(ref, ref_len, out, out_max);
    }
  }
  dir_len = std_path_dirname(base, base_len, &dir_buf[0], 256);
  jlen = std_path_join(&tmp[0], 512, &dir_buf[0], dir_len, ref, ref_len);
  if (jlen < 0) { return 0 - 1; }
  return std_path_clean(&tmp[0], jlen, out, out_max);
}
