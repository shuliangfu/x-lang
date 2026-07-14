// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-302/450 / P2 runtime rest：errno 诊断族。
// R2 full：.x 吃满 code_for_kind + errno{,_path,_path_pair} + cli_usage_note；
// 产品 PREFER_X_O 下 rest 仅 marker（业务 H=0）。
// 🔒 诊断用 diag_report_with_code（无 va_list / reportf）；
// 诊断码串经一次 malloc 池常驻（避免 -E 把 string lit return 编成自动期 compound literal）。
// errno：linux `__errno_location` / macos `__error`（cfg）；err 文案经 strerror。

export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function strerror(e: i32): *u8;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

#[cfg(target_os = "linux")]
export extern "C" function __errno_location(): *i32;
#[cfg(target_os = "macos")]
export extern "C" function __error(): *i32;

/** 诊断码常驻池（首次 ensure 后只读）。 */
export let g_rt_diag_codes_ready: i32 = 0;
export let g_rt_diag_io001: *u8 = 0 as *u8;
export let g_rt_diag_prc001: *u8 = 0 as *u8;
export let g_rt_diag_bld001: *u8 = 0 as *u8;

#[cfg(target_os = "linux")]
export function rt_diag_get_errno(): i32 {
  let p: *i32 = 0 as *i32;
  unsafe {
    p = __errno_location();
  }
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

#[cfg(target_os = "macos")]
export function rt_diag_get_errno(): i32 {
  let p: *i32 = 0 as *i32;
  unsafe {
    p = __error();
  }
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

/** 一次分配 IO001/PRC001/BLD001，供 code_for_kind 返回稳定 *u8。 */
export function rt_diag_ensure_codes(): void {
  let p: *u8 = 0 as *u8;
  if (g_rt_diag_codes_ready != 0) {
    return;
  }
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 73;
    p[1] = 79;
    p[2] = 48;
    p[3] = 48;
    p[4] = 49;
    p[5] = 0;
    g_rt_diag_io001 = p;
  }
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 80;
    p[1] = 82;
    p[2] = 67;
    p[3] = 48;
    p[4] = 48;
    p[5] = 49;
    p[6] = 0;
    g_rt_diag_prc001 = p;
  }
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 66;
    p[1] = 76;
    p[2] = 68;
    p[3] = 48;
    p[4] = 48;
    p[5] = 49;
    p[6] = 0;
    g_rt_diag_bld001 = p;
  }
  g_rt_diag_codes_ready = 1;
}

/** 把 src 接到 dst 尾（cap 含尾 0）；返回新长度（不含 0）。 */
export function rt_diag_append(dst: *u8, cap: i32, src: *u8): i32 {
  let i: i32 = 0;
  let j: i32 = 0;
  if (dst == 0 as *u8) {
    return 0;
  }
  if (src == 0 as *u8) {
    while (i < cap) {
      if (dst[i as usize] == 0) {
        return i;
      }
      i = i + 1;
    }
    return 0;
  }
  while (i < cap) {
    if (dst[i as usize] == 0) {
      break;
    }
    i = i + 1;
  }
  if (i >= cap) {
    dst[(cap - 1) as usize] = 0;
    return cap - 1;
  }
  j = 0;
  while (i + 1 < cap) {
    let c: u8 = src[j as usize];
    if (c == 0) {
      break;
    }
    dst[i as usize] = c;
    i = i + 1;
    j = j + 1;
  }
  dst[i as usize] = 0;
  return i;
}

/** kind 文案 → 诊断码（稳定指针；未知 kind 返回 null）。 */
#[no_mangle]
export function runtime_diag_code_for_kind(kind: *u8): *u8 {
  rt_diag_ensure_codes();
  if (kind == 0 as *u8) {
    return g_rt_diag_bld001;
  }
  unsafe {
    if (strcmp(kind, "io error") == 0) {
      return g_rt_diag_io001;
    }
    if (strcmp(kind, "process error") == 0) {
      return g_rt_diag_prc001;
    }
    if (strcmp(kind, "build error") == 0) {
      return g_rt_diag_bld001;
    }
  }
  return 0 as *u8;
}

/** 无 path：`{op} failed: {strerror}`。 */
#[no_mangle]
export function runtime_diag_errno(file: *u8, kind: *u8, op: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[256] = [];
  let s: *u8 = 0 as *u8;
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 256, s);
  rt_diag_append(&msg[0], 256, " failed: ");
  rt_diag_append(&msg[0], 256, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/** 有 path：`{op} failed for '{path}': {strerror}`；空 path 回退 errno。 */
#[no_mangle]
export function runtime_diag_errno_path(file: *u8, kind: *u8, op: *u8, path: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[384] = [];
  let s: *u8 = 0 as *u8;
  if (path == 0 as *u8) {
    runtime_diag_errno(file, kind, op);
    return;
  }
  if (path[0 as usize] == 0 as u8) {
    runtime_diag_errno(file, kind, op);
    return;
  }
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 384, s);
  rt_diag_append(&msg[0], 384, " failed for '");
  rt_diag_append(&msg[0], 384, path);
  rt_diag_append(&msg[0], 384, "': ");
  rt_diag_append(&msg[0], 384, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/** 双 path：`{op} failed for '{from}' -> '{to}': {strerror}`。 */
#[no_mangle]
export function runtime_diag_errno_path_pair(
  file: *u8, kind: *u8, op: *u8, from_path: *u8, to_path: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[512] = [];
  let s: *u8 = 0 as *u8;
  let from_s: *u8 = 0 as *u8;
  let to_s: *u8 = 0 as *u8;
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  if (from_path != 0 as *u8) {
    from_s = from_path;
  } else {
    from_s = "?";
  }
  if (to_path != 0 as *u8) {
    to_s = to_path;
  } else {
    to_s = "?";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 512, s);
  rt_diag_append(&msg[0], 512, " failed for '");
  rt_diag_append(&msg[0], 512, from_s);
  rt_diag_append(&msg[0], 512, "' -> '");
  rt_diag_append(&msg[0], 512, to_s);
  rt_diag_append(&msg[0], 512, "': ");
  rt_diag_append(&msg[0], 512, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/** CLI usage note（固定句式 + argv0；无 va）。 */
#[no_mangle]
export function runtime_diag_cli_usage_note(argv0: *u8): void {
  let msg: u8[256] = [];
  let name: *u8 = 0 as *u8;
  let note_kind: *u8 = 0 as *u8;
  if (argv0 != 0 as *u8) {
    name = argv0;
  } else {
    name = "shux";
  }
  note_kind = "note";
  msg[0] = 0;
  rt_diag_append(&msg[0], 256, "usage: ");
  rt_diag_append(&msg[0], 256, name);
  rt_diag_append(&msg[0], 256, " [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] ");
  rt_diag_append(&msg[0], 256, "[ -O 0|1|2|3|s ] [ -flto ] <file.x> [ -o <out> ]");
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, note_kind, 0 as *u8, &msg[0], 0 as *u8);
  }
}
