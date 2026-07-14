// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-268 / P2 link_abi L1：诊断 pure thin shell。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_diag_pure.from_x.c。
// hybrid 宏 SHUX_LABI_DIAG_PURE_FROM_X。
//
// Track L：
//   - link_diag_code_for_kind：真迁 strcmp + 短字面量（W-string-nul；let p 防 parser skip）
//   - reportf/va_list/长文案：thin 转发 → mega rest *_impl
// 不做 va_list；不做 diag_reportf 变参原型。

export extern "C" function strcmp(a: *u8, b: *u8): i32;

export extern "C" function link_diag_runtime_obj_resolve_fail_impl(obj_name: *u8, hint: *u8): void;
export extern "C" function link_diag_runtime_source_missing_impl(obj_name: *u8, source_path: *u8): void;
export extern "C" function link_diag_runtime_source_missing_under_impl(
  obj_name: *u8, base_dir: *u8, suffix: *u8
): void;
export extern "C" function link_diag_runtime_obj_missing_impl(obj_name: *u8, out_o: *u8): void;
export extern "C" function link_diag_freestanding_missing_impl(obj_name: *u8, symbol_name: *u8): void;
export extern "C" function link_diag_freestanding_unsupported_impl(): void;
export extern "C" function link_diag_ld_debug_push_impl(rel: *u8, stage: *u8, path: *u8): void;
export extern "C" function link_diag_ld_debug_argv_impl(label: *u8, argv: *u8): void;

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
  unsafe {
    link_diag_runtime_obj_resolve_fail_impl(obj_name, hint);
  }
}

#[no_mangle]
export function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void {
  unsafe {
    link_diag_runtime_source_missing_impl(obj_name, source_path);
  }
}

#[no_mangle]
export function link_diag_runtime_source_missing_under(
  obj_name: *u8, base_dir: *u8, suffix: *u8
): void {
  unsafe {
    link_diag_runtime_source_missing_under_impl(obj_name, base_dir, suffix);
  }
}

#[no_mangle]
export function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void {
  unsafe {
    link_diag_runtime_obj_missing_impl(obj_name, out_o);
  }
}

#[no_mangle]
export function link_diag_freestanding_missing(obj_name: *u8, symbol_name: *u8): void {
  unsafe {
    link_diag_freestanding_missing_impl(obj_name, symbol_name);
  }
}

#[no_mangle]
export function link_diag_freestanding_unsupported(): void {
  unsafe {
    link_diag_freestanding_unsupported_impl();
  }
}

#[no_mangle]
export function link_diag_ld_debug_push(rel: *u8, stage: *u8, path: *u8): void {
  unsafe {
    link_diag_ld_debug_push_impl(rel, stage, path);
  }
}

#[no_mangle]
export function link_diag_ld_debug_argv(label: *u8, argv: *u8): void {
  unsafe {
    link_diag_ld_debug_argv_impl(label, argv);
  }
}

/* Pure audit: public L1 gates in this slice (code_for_kind + 8 report thin). */
#[no_mangle]
export function labi_diag_pure_count(): i32 {
  return 9;
}
