// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-268 / P2 link_abi L1 → R2 full：诊断 pure。
// 产品 PREFER_X_O：g05_try_x_to_o；冷启动 seeds/labi_diag_pure.from_x.c。
// hybrid 宏 SHUX_LABI_DIAG_PURE_FROM_X：FROM_X rest 仅 marker（业务 H=0）。
//
// R2 full：
//   - link_diag_code_for_kind：strcmp + 短字面量
//   - 7 个 report 消息体：栈缓冲拼装 + diag_report_with_code（无 va_list / reportf）
// Cap residual（mega rest 常驻 _impl）：
//   - link_diag_ld_debug_argv：argv 为 char** 遍历 🔒 Cap-fn-ptr
// 长文案 freestanding_unsupported 拆 ≤64 段 append（禁单 lit >64）。

export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8
): void;

/** Cap residual：char** argv 遍历在 mega rest _impl。 */
export extern "C" function link_diag_ld_debug_argv_impl(label: *u8, argv: *u8): void;

/** 把 src 接到 dst 尾（cap 含尾 0）；返回新长度（不含 0）。 */
export function labi_diag_append(dst: *u8, cap: i32, src: *u8): i32 {
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

/* Pure：kind → 诊断码（PRC001 / BLD001）。禁止函数体仅 return "lit"。 */
#[no_mangle]
export function link_diag_code_for_kind(kind: *u8): *u8 {
  if (kind == 0 as *u8) {
    let p: *u8 = "PRC001";
    return p;
  }
  unsafe {
    let be: *u8 = "build error";
    if (strcmp(kind, be) == 0) {
      let p: *u8 = "BLD001";
      return p;
    }
    let pe: *u8 = "process error";
    if (strcmp(kind, pe) == 0) {
      let p: *u8 = "PRC001";
      return p;
    }
  }
  return 0 as *u8;
}

#[no_mangle]
export function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void {
  let on: *u8 = obj_name;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "cannot resolve compiler directory to build ");
  labi_diag_append(&msg[0], 320, on);
  if (hint != 0 as *u8) {
    if (hint[0 as usize] != 0) {
      labi_diag_append(&msg[0], 320, " (");
      labi_diag_append(&msg[0], 320, hint);
      labi_diag_append(&msg[0], 320, ")");
    }
  }
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void {
  let on: *u8 = obj_name;
  let sp: *u8 = source_path;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (sp == 0 as *u8) {
    sp = "?";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, on);
  labi_diag_append(&msg[0], 320, " source not found at ");
  labi_diag_append(&msg[0], 320, sp);
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_runtime_source_missing_under(
  obj_name: *u8, base_dir: *u8, suffix: *u8
): void {
  let on: *u8 = obj_name;
  let bd: *u8 = base_dir;
  let sf: *u8 = suffix;
  let msg: u8[384] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (bd == 0 as *u8) {
    bd = "?";
  }
  if (sf == 0 as *u8) {
    sf = "";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 384, on);
  labi_diag_append(&msg[0], 384, " source not found under ");
  labi_diag_append(&msg[0], 384, bd);
  labi_diag_append(&msg[0], 384, sf);
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void {
  let on: *u8 = obj_name;
  let oo: *u8 = out_o;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  if (oo == 0 as *u8) {
    oo = "?";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, on);
  labi_diag_append(&msg[0], 320, " missing after cc -c (expected near ");
  labi_diag_append(&msg[0], 320, oo);
  labi_diag_append(&msg[0], 320, ")");
  kind = "build error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_freestanding_missing(obj_name: *u8, symbol_name: *u8): void {
  let on: *u8 = obj_name;
  let sn: *u8 = symbol_name;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  if (on == 0 as *u8) {
    on = "runtime object";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "freestanding link missing ");
  labi_diag_append(&msg[0], 320, on);
  if (sn != 0 as *u8) {
    if (sn[0 as usize] != 0) {
      labi_diag_append(&msg[0], 320, " (user references ");
      labi_diag_append(&msg[0], 320, sn);
      labi_diag_append(&msg[0], 320, ")");
    }
  }
  kind = "link error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_freestanding_unsupported(): void {
  let msg: u8[192] = [];
  let kind: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  msg[0] = 0;
  /* 拆段 ≤64：禁单 lit 超限。 */
  labi_diag_append(&msg[0], 192, "-freestanding / SHUX_FREESTANDING is only supported for ");
  labi_diag_append(&msg[0], 192, "Linux ELF x86_64 (-o prog, not .o/.obj on macOS/COFF)");
  kind = "link error";
  code = "BLD001";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, code, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_ld_debug_push(rel: *u8, stage: *u8, path: *u8): void {
  let r: *u8 = rel;
  let st: *u8 = stage;
  let p: *u8 = path;
  let msg: u8[320] = [];
  let kind: *u8 = 0 as *u8;
  if (r == 0 as *u8) {
    r = "(null)";
  }
  if (st == 0 as *u8) {
    st = "path";
  }
  if (p == 0 as *u8) {
    p = "(null)";
  }
  msg[0] = 0;
  labi_diag_append(&msg[0], 320, "ld debug: push ");
  labi_diag_append(&msg[0], 320, r);
  labi_diag_append(&msg[0], 320, " ");
  labi_diag_append(&msg[0], 320, st);
  labi_diag_append(&msg[0], 320, "=");
  labi_diag_append(&msg[0], 320, p);
  kind = "note";
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, kind, 0 as *u8, &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function link_diag_ld_debug_argv(label: *u8, argv: *u8): void {
  /* 🔒 Cap residual：char** 遍历在 mega rest。 */
  unsafe {
    link_diag_ld_debug_argv_impl(label, argv);
  }
}

/* Pure audit: public L1 gates in this slice (code_for_kind + 8 report). */
#[no_mangle]
export function labi_diag_pure_count(): i32 {
  return 9;
}
