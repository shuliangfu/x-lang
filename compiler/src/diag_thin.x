// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-335：diag L2 thin — 纯 helper 子集（无字符串字面量，-E 稳定）。
// 产品 PREFER_X_O：g05_try_x_to_o → thin.o + seeds/diag.from_x.c rest
//   （-DSHUX_L2_DIAG_THIN_FROM_X）ld -r → src/diag.o
// 完整逻辑源仍见 src/diag.x（整文件 -E 仍会截断/挂起）。

extern "C" function diag_ctx_get_use_color(): i32;

// G-02f-96 / G-02f-335：行号十进制位数
#[no_mangle]
function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

// G-02f-116 / G-02f-335：kind 与 needle 精确相等
#[no_mangle]
function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = kind[i];
    let b: u8 = needle[i];
    if (a != b) {
      return 0;
    }
    if (a == 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// G-02f-130 / G-02f-335：kind 是否含子串 needle
#[no_mangle]
function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) {
    return 0;
  }
  if (needle == 0) {
    return 0;
  }
  if (needle[0] == 0) {
    return 0;
  }
  let nlen: i32 = 0;
  while (nlen < 4096) {
    if (needle[nlen] == 0) {
      break;
    }
    nlen = nlen + 1;
  }
  if (nlen <= 0) {
    return 0;
  }
  let klen: i32 = 0;
  while (klen < 4096) {
    if (kind[klen] == 0) {
      break;
    }
    klen = klen + 1;
  }
  if (klen < nlen) {
    return 0;
  }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      if (kind[s + j] != needle[j]) {
        ok = 0;
        break;
      }
      j = j + 1;
    }
    if (ok != 0) {
      return 1;
    }
    s = s + 1;
  }
  return 0;
}

// G-02f-154 / G-02f-335：use_color ? color : plain
#[no_mangle]
function diag_color_prefix(plain: *u8, color: *u8): *u8 {
  unsafe {
    if (diag_ctx_get_use_color() != 0) {
      return color;
    }
    return plain;
  }
  return plain;
}
