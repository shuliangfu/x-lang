// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Runtime fmt-one helpers (G.9 English; body is authoritative).
// Runtime fmt-one helpers (G.9 English; body is authoritative).
// Runtime fmt-one helpers (G.9 English; body is authoritative).
// Runtime fmt-one helpers (G.9 English; body is authoritative).

export extern "C" function runtime_read_file_malloc(path: *u8, out_len: *usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;
export extern "C" function xlang_format_x_document(
  doc: *u8, doc_len: i32, out_buf: *u8, out_cap: i32): i32;
export extern "C" function driver_fmt_check_only_get(): i32;
export extern "C" function xlang_write_path_bytes(path: *u8, data: *u8, len: usize): i32;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** Format one value into the driver emit path; see signature and body for contracts. */
#[no_mangle]
export function rt_fmt_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32 {
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  if (path_len >= 512) {
    return 0;
  }
  while (i < path_len) {
    path_buf[i as usize] = path[i as usize];
    i = i + 1;
  }
  path_buf[path_len as usize] = 0;
  return 1;
}

/** Exported function `rt_fmt_path_ends_x`.
 * Implements `rt_fmt_path_ends_x`.
 * @param path_buf *u8
 * @param path_len i32
 * @return i32
 */
#[no_mangle]
export function rt_fmt_path_ends_x(path_buf: *u8, path_len: i32): i32 {
  if (path_len < 2) {
    return 0;
  }
  if (path_buf[(path_len - 2) as usize] != 46) {
    return 0;
  }
  if (path_buf[(path_len - 1) as usize] != 120) {
    return 0;
  }
  return 1;
}

/**
 * See signature and body for params/returns/contracts.
 * See signature and body for params/returns/contracts.
 */
#[no_mangle]
export function driver_fmt_one_file(path: *u8, path_len: i32): i32 {
  let path_buf: u8[512] = [];
  let raw: *u8 = 0 as *u8;
  let raw_len: usize = 0;
  let cap: usize = 0;
  let out: *u8 = 0 as *u8;
  let fmt_len: i32 = 0;
  let changed: i32 = 0;
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  let info_kind: u8[8] = [];
  let ok_msg: u8[16] = [];

  if (rt_fmt_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 1;
  }
  if (rt_fmt_path_ends_x(&path_buf[0], path_len) == 0) {
    return 1;
  }

  /* "fmt error" */
  kind[0] = 102;
  kind[1] = 109;
  kind[2] = 116;
  kind[3] = 32;
  kind[4] = 101;
  kind[5] = 114;
  kind[6] = 114;
  kind[7] = 111;
  kind[8] = 114;
  kind[9] = 0;
  /* "FMT001" */
  code[0] = 70;
  code[1] = 77;
  code[2] = 84;
  code[3] = 48;
  code[4] = 48;
  code[5] = 49;
  code[6] = 0;

  unsafe {
    raw = runtime_read_file_malloc(&path_buf[0], &raw_len);
  }
  if (raw == 0 as *u8) {
    /* "cannot read file" */
    msg[0] = 99;
    msg[1] = 97;
    msg[2] = 110;
    msg[3] = 110;
    msg[4] = 111;
    msg[5] = 116;
    msg[6] = 32;
    msg[7] = 114;
    msg[8] = 101;
    msg[9] = 97;
    msg[10] = 100;
    msg[11] = 32;
    msg[12] = 102;
    msg[13] = 105;
    msg[14] = 108;
    msg[15] = 101;
    msg[16] = 0;
    unsafe {
      diag_report_with_code(&path_buf[0], 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    }
    return 1;
  }

  cap = raw_len * (2 as usize) + (4096 as usize);
  if (cap < (65536 as usize)) {
    cap = 65536 as usize;
  }
  unsafe {
    out = malloc(cap);
  }
  if (out == 0 as *u8) {
    unsafe {
      free(raw);
    }
    /* "out of memory while formatting" */
    msg[0] = 111;
    msg[1] = 117;
    msg[2] = 116;
    msg[3] = 32;
    msg[4] = 111;
    msg[5] = 102;
    msg[6] = 32;
    msg[7] = 109;
    msg[8] = 101;
    msg[9] = 109;
    msg[10] = 111;
    msg[11] = 114;
    msg[12] = 121;
    msg[13] = 32;
    msg[14] = 119;
    msg[15] = 104;
    msg[16] = 105;
    msg[17] = 108;
    msg[18] = 101;
    msg[19] = 32;
    msg[20] = 102;
    msg[21] = 111;
    msg[22] = 114;
    msg[23] = 109;
    msg[24] = 97;
    msg[25] = 116;
    msg[26] = 116;
    msg[27] = 105;
    msg[28] = 110;
    msg[29] = 103;
    msg[30] = 0;
    unsafe {
      diag_report_with_code(&path_buf[0], 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    }
    return 1;
  }

  unsafe {
    fmt_len = xlang_format_x_document(raw, raw_len as i32, out, cap as i32);
  }
  if (fmt_len < 0) {
    unsafe {
      free(out);
      free(raw);
    }
    /* "format failed" */
    msg[0] = 102;
    msg[1] = 111;
    msg[2] = 114;
    msg[3] = 109;
    msg[4] = 97;
    msg[5] = 116;
    msg[6] = 32;
    msg[7] = 102;
    msg[8] = 97;
    msg[9] = 105;
    msg[10] = 108;
    msg[11] = 101;
    msg[12] = 100;
    msg[13] = 0;
    unsafe {
      diag_report_with_code(&path_buf[0], 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    }
    return 1;
  }

  changed = 0;
  if ((fmt_len as usize) != raw_len) {
    changed = 1;
  } else {
    let cmp: i32 = 0;
    unsafe {
      cmp = memcmp(raw, out, raw_len);
    }
    if (cmp != 0) {
      changed = 1;
    }
  }

  // Runtime fmt-one helpers (G.9 English; body is authoritative).
  let check_only: i32 = 0;
  unsafe {
    check_only = driver_fmt_check_only_get();
  }
  if (check_only != 0) {
    unsafe {
      free(out);
      free(raw);
    }
    if (changed != 0) {
      return 1;
    }
    return 0;
  }

  if (changed != 0) {
    let wr: i32 = 0;
    unsafe {
      wr = xlang_write_path_bytes(&path_buf[0], out, fmt_len as usize);
    }
    if (wr != 0) {
      unsafe {
        free(out);
        free(raw);
      }
      /* "write failed" */
      msg[0] = 119;
      msg[1] = 114;
      msg[2] = 105;
      msg[3] = 116;
      msg[4] = 101;
      msg[5] = 32;
      msg[6] = 102;
      msg[7] = 97;
      msg[8] = 105;
      msg[9] = 108;
      msg[10] = 101;
      msg[11] = 100;
      msg[12] = 0;
      unsafe {
        diag_report_with_code(&path_buf[0], 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
      }
      return 1;
    }
    /* Local step; behavior follows surrounding code. */
    info_kind[0] = 105;
    info_kind[1] = 110;
    info_kind[2] = 102;
    info_kind[3] = 111;
    info_kind[4] = 0;
    ok_msg[0] = 102;
    ok_msg[1] = 109;
    ok_msg[2] = 116;
    ok_msg[3] = 32;
    ok_msg[4] = 79;
    ok_msg[5] = 75;
    ok_msg[6] = 0;
    unsafe {
      diag_report_with_code(0 as *u8, 0, 0, &info_kind[0], 0 as *u8, &ok_msg[0], &path_buf[0]);
    }
  }

  unsafe {
    free(out);
    free(raw);
  }
  return 0;
}
