// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
// path/filepath、Zig std.fs.path）
//
// See implementation.
// See implementation.
// See implementation.
// parent≈dirname、file_name≈basename、extension、file_stem、join、is_absolute；Go:
// Join、Dir、Base、Ext、Clean、IsAbs；Zig:
// join、dirname、basename、extension、sep、isAbsolute。
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/** Exported function `empty_len`.
 * Query helper `empty_len`.
 * @return i32
 */
export function empty_len(): i32 { return 0; }

/** Exported function `sep`.
 * Implements `sep`.
 * @return u8
 */
#[cfg(target_os = "windows")]
export function sep(): u8 {
  return 92 as u8;
}
/** Exported function `sep`.
 * Implements `sep`.
 * @return u8
 */
#[cfg(not(target_os = "windows"))]
export function sep(): u8 {
  return 47 as u8;
}

/** Exported function `join`.
 * Implements `join`.
 * @param out *u8
 * @param out_max i32
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return i32
 */
export function join(out: *u8, out_max: i32, a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  let need_slash: i32 = 0;
  if (a_len > 0 && a[a_len - 1] != 47) { need_slash = 1; }
  let total: i32 = a_len + need_slash + b_len;
  if (total <= 0) { return 0; }
  if (total > out_max) { return -1; }
  let k: i32 = 0;
  let ai: i32 = 0;
  while (ai < a_len) {
    out[k] = a[ai];
    k = k + 1;
    ai = ai + 1;
  }
  if (need_slash != 0) {
    let sl: u8 = 47;
    out[k] = sl;
    k = k + 1;
  }
  let bi: i32 = 0;
  while (bi < b_len) {
    out[k] = b[bi];
    k = k + 1;
    bi = bi + 1;
  }
  return k;
}

/** Exported function `last_slash`.
 * Implements `last_slash`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function last_slash(path: *u8, path_len: i32): i32 {
  let i: i32 = path_len - 1;
  while (i >= 0) {
    if (path[i] == 47) { return i; }
    i = i - 1;
  }
  return -1;
}

/** Exported function `dirname`.
 * Implements `dirname`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function dirname(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last: i32 = last_slash(path, path_len);
  if (last <= 0) { return 0; }
  if (last > out_max) { return -1; }
  let i: i32 = 0;
  while (i < last && i < out_max) {
    out[i] = path[i];
    i = i + 1;
  }
  return i;
}

/** Exported function `basename`.
 * Implements `basename`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function basename(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last: i32 = last_slash(path, path_len);
  let start: i32 = last + 1;
  let seg_len: i32 = path_len - start;
  if (seg_len <= 0) { return 0; }
  if (seg_len > out_max) { return -1; }
  let i: i32 = 0;
  while (i < seg_len) {
    out[i] = path[start + i];
    i = i + 1;
  }
  return i;
}

/** Exported function `is_absolute`.
 * Query helper `is_absolute`.
 * @param path *u8
 * @param path_len i32
 * @return i32
 */
export function is_absolute(path: *u8, path_len: i32): i32 {
  if (path_len <= 0) { return 0; }
  if (path[0] == 47) { return 1; }
  /** UNC：\\server\share */
  if (path_len >= 2 && path[0] == 92 && path[1] == 92) { return 1; }
  /* See implementation. */
  if (path_len >= 3 && path[1] == 58) {
    let c0: u8 = path[0];
    if ((c0 >= 65 && c0 <= 90) || (c0 >= 97 && c0 <= 122)) {
      if (path[2] == 92 || path[2] == 47) { return 1; }
    }
  }
  return 0;
}

/** Exported function `is_sep`.
 * Query helper `is_sep`.
 * @param c u8
 * @return i32
 */
export function is_sep(c: u8): i32 {
  if (c == 47) { return 1; }
  if (c == 92) { return 1; }
  return 0;
}

/** Exported function `last_dot`.
 * Implements `last_dot`.
 * @param path *u8
 * @param start i32
 * @param len i32
 * @return i32
 */
export function last_dot(path: *u8, start: i32, len: i32): i32 {
  let i: i32 = start + len - 1;
  while (i >= start) {
    if (path[i] == 46) { return i - start; }
    i = i - 1;
  }
  return -1;
}

/** Exported function `extension`.
 * Implements `extension`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function extension(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last_sl: i32 = last_slash(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  if (base_len <= 0) { return 0; }
  let dot_rel: i32 = last_dot(path, base_start, base_len);
  if (dot_rel < 0) { return 0; }
  if (dot_rel == 0) { return 0; }
  if (dot_rel >= base_len - 1) { return 0; }
  let ext_len: i32 = base_len - dot_rel;
  if (ext_len > out_max) { return -1; }
  let i: i32 = 0;
  while (i < ext_len) {
    out[i] = path[base_start + dot_rel + i];
    i = i + 1;
  }
  return i;
}

/** Exported function `stem`.
 * Implements `stem`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function stem(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  let last_sl: i32 = last_slash(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  if (base_len <= 0) { return 0; }
  let dot_rel: i32 = last_dot(path, base_start, base_len);
  let stem_len: i32 = base_len;
  if (dot_rel >= 0 && dot_rel > 0 && dot_rel < base_len - 1) {
    stem_len = dot_rel;
  }
  if (stem_len > out_max) { return -1; }
  let i: i32 = 0;
  while (i < stem_len) {
    out[i] = path[base_start + i];
    i = i + 1;
  }
  return i;
}

/** Exported function `extension_and_stem`.
 * Implements `extension_and_stem`.
 * @param path *u8
 * @param path_len i32
 * @param ext_out *u8
 * @param ext_max i32
 * @param stem_out *u8
 * @param stem_max i32
 * @return i32
 */
export function extension_and_stem(path: *u8, path_len: i32, ext_out: *u8, ext_max: i32, stem_out: *u8, stem_max: i32): i32 {
  let last_sl: i32 = last_slash(path, path_len);
  let base_start: i32 = last_sl + 1;
  let base_len: i32 = path_len - base_start;
  if (base_len <= 0) { return 0; }
  let dot_rel: i32 = last_dot(path, base_start, base_len);
  let stem_len: i32 = base_len;
  let ext_len: i32 = 0;
  if (dot_rel >= 0 && dot_rel > 0 && dot_rel < base_len - 1) {
    stem_len = dot_rel;
    ext_len = base_len - dot_rel;
  }
  if (stem_len > stem_max) { return -1; }
  if (ext_len > ext_max) { return -1; }
  let i: i32 = 0;
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

/** Exported function `clean`.
 * Implements `clean`.
 * @param path *u8
 * @param path_len i32
 * @param out *u8
 * @param out_max i32
 * @return i32
 */
export function clean(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
  if (path_len <= 0 || out_max <= 0) { return 0; }
  let seg_starts: i32[64] = []; // start index of each segment in out; must use = [] or parser may skip the whole function
  let nseg: i32 = 0;
  let out_len: i32 = 0;
  let i: i32 = 0;
  let at_start: i32 = 1;
  let started_with_slash: i32 = 0;
  while (i < path_len && out_len < out_max) {
    if (is_sep(path[i]) != 0) {
      if (at_start != 0 && out_len == 0) { started_with_slash = 1; }
      if (at_start == 0) {
        out[out_len] = 47;
        out_len = out_len + 1;
        at_start = 1;
      }
      i = i + 1;
      continue;
    }
    at_start = 0;
    let seg_begin: i32 = i;
    while (i < path_len && is_sep(path[i]) == 0) { i = i + 1; }
    let seg_len: i32 = i - seg_begin;
    if (seg_len == 0) { continue; }
    if (seg_len == 1 && path[seg_begin] == 46) { continue; }
    if (seg_len == 2 && path[seg_begin] == 46 && path[seg_begin + 1] == 46) {
      if (nseg > 0) {
        out_len = seg_starts[nseg - 1] - 1;
        if (out_len < 0) { out_len = 0; }
        nseg = nseg - 1;
      }
      if (started_with_slash != 0 && out_len == 0 && out_max > 0) { out[0] = 47; out_len = 1; }
      continue;
    }
    if (out_len > 0 && (out[out_len - 1] != 47)) {
      if (out_len >= out_max) { return -1; }
      out[out_len] = 47;
      out_len = out_len + 1;
    }
    if (out_len == 0 && started_with_slash != 0) { out[0] = 47; out_len = 1; }
    if (nseg < 63) { seg_starts[nseg] = out_len; nseg = nseg + 1; }
    let k: i32 = 0;
    while (k < seg_len && out_len < out_max) {
      out[out_len] = path[seg_begin + k];
      out_len = out_len + 1;
      k = k + 1;
    }
    if (k < seg_len) { return -1; }
  }
  if (out_len > 1 && out[out_len - 1] == 47) { out_len = out_len - 1; }
  return out_len;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function resolve(out: *u8, out_max: i32, base: *u8, base_len: i32, ref: *u8, ref_len: i32): i32 {
  let rc: i32 = 0;
  if (ref_len > 0 && is_absolute(ref, ref_len) != 0) {
    rc = clean(ref, ref_len, out, out_max);
    return rc;
  }
  let dir_buf: u8[256] = [];
  let dir_len: i32 = dirname(base, base_len, &dir_buf[0], 256);
  let tmp: u8[512] = [];
  let jlen: i32 = join(&tmp[0], 512, &dir_buf[0], dir_len, ref, ref_len);
  if (jlen < 0) { return -1; }
  rc = clean(&tmp[0], jlen, out, out_max);
  return rc;
}

/** Exported function `module_anchor`.
 * Implements `module_anchor`.
 * @return i32
 */
export function module_anchor(): i32 { return 0; }


