// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-21：runtime_path_fast 产品源迁 seeds/runtime_path_fast.from_x.c。
// G-02f-98：+ path_sep / is_sep / last_sep / last_dot 薄门闩。
// G-02f-rest：rest→.x 迁移：std_path_* 12 个函数真迁 .x，seed 进入 DIRECT 模式。
//   Why：消除 seed 中 rest 函数，使 runtime_path_fast 进入 DIRECT 模式（无 ld -r）
//   Invariant：与 seed 同语义（字节级路径操作，无 libc 依赖，无平台 ifdef）
//   Perf：纯字节循环，无热路径分支冗余


function runtime_path_fast_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-98：path pure helpers 门闩 ---- */









// G-02f-119：path pure helper 真迁 .x

#[no_mangle]
function path_sep_c(): u8 {
  // 产品 seed 在 Win 下为 '\\'；posix 验收路径为 '/'
  return 47 as u8;
}

#[no_mangle]
function path_is_sep_c(c: u8): i32 {
  if (c == 47) { return 1; }
  if (c == 92) { return 1; }
  return 0;
}

#[no_mangle]
function path_last_sep_c(path: *u8, path_len: i32): i32 {
  let i: i32 = path_len - 1;
  while (i >= 0) {
    if (path_is_sep_c(path[i]) != 0) { return i; }
    i = i - 1;
  }
  return 0 - 1;
}

// G-02f-123：path_last_dot_c 真迁 .x

#[no_mangle]
function path_last_dot_c(path: *u8, start: i32, len: i32): i32 {
  let i: i32 = start + len - 1;
  while (i >= start) {
    if (path[i] == 46) { return i - start; }
    i = i - 1;
  }
  return 0 - 1;
}

/* ---- G-02f-rest：rest→.x 迁移（原 seed 中 12 个 rest 函数） ---- */

#[no_mangle]
function std_path_empty_len(): i32 {
  return 0;
}

#[no_mangle]
function std_path_sep(): u8 {
  return path_sep_c();
}

#[no_mangle]
function std_path_join(out: *u8, out_max: i32, a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
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
function std_path_dirname(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
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
function std_path_basename(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
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
function std_path_is_absolute(path: *u8, path_len: i32): i32 {
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
function std_path_is_sep(c: u8): i32 {
  return path_is_sep_c(c);
}

#[no_mangle]
function std_path_extension(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
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
function std_path_stem(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
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
function std_path_extension_and_stem(path: *u8, path_len: i32, ext_out: *u8, ext_max: i32,
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
function std_path_clean(path: *u8, path_len: i32, out: *u8, out_max: i32): i32 {
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
function std_path_resolve(out: *u8, out_max: i32, base: *u8, base_len: i32,
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
