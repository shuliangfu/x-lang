// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-32..43：真迁 .x — pipeline 占位 + dep + publish + arena_buf 转发。
// 产品：./shux-c -E → seeds/runtime_pipeline_abi.from_x.c（+ C 尾段）。
// C 尾：存储槽数组、import/path、seeded_clear、malloc buf 本体、path 扫描。
// G-02f-43：+ typeck_driver_dep_arena_buf 转发。

extern "C" function pipeline_diag_emitted_flag_slot(): *i32;
extern "C" function typeck_ndep_slot(): *i32;
extern "C" function typeck_ndep_store(n: i32): void;
extern "C" function driver_dep_seeded_slot(i: i32): *i32;
extern "C" function typeck_dep_module_get(i: i32): *u8;
extern "C" function typeck_dep_arena_get(i: i32): *u8;
extern "C" function typeck_dep_module_set(i: i32, mod: *u8): void;
extern "C" function typeck_dep_arena_set(i: i32, arena: *u8): void;
extern "C" function driver_dep_arena_ptr_set(i: i32, arena: *u8): void;
extern "C" function driver_dep_module_ptr_set(i: i32, module: *u8): void;
extern "C" function driver_dep_path_registry_set(i: i32, path: *u8): void;
extern "C" function driver_dep_module_buf(i: i32): *u8;
extern "C" function driver_dep_arena_buf(i: i32): *u8;

/* ---- G-02f-32：占位 no-op ---- */

#[no_mangle]
function parser_parse_into_init(module: *u8, arena: *u8): void {
}

#[no_mangle]
function parser_get_module_num_imports(module: *u8): i32 {
  return 0;
}

#[no_mangle]
function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void {
  if (path_buf == 0 as *u8) {
    return;
  }
  unsafe {
    path_buf[0] = 0;
  }
}

#[no_mangle]
function asm_skip_heavy_set_pipeline_ctx(ctx: *u8): void {
}

#[no_mangle]
function pipeline_fill_array_lit_types_for_skipped_typeck(m: *u8, a: *u8): void {
}

#[no_mangle]
function pipeline_fill_soa_field_access_for_asm_emit(m: *u8, a: *u8): void {
}

#[no_mangle]
function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void {
}

#[no_mangle]
function asm_asm_codegen_elf_o(m: *u8, a: *u8, c: *u8, e: *u8, o: *u8): i32 {
  return 0 - 1;
}

#[no_mangle]
function pipeline_parse_set_main_from_buf_c(m: *u8, a: *u8, d: *u8, len: i32): i32 {
  return 0;
}

/* ---- G-02f-33：diag_emitted / ndep 读 ---- */

#[no_mangle]
function pipeline_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

#[no_mangle]
function pipeline_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

#[no_mangle]
function pipeline_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function get_ndep(): i32 {
  unsafe {
    let p: *i32 = typeck_ndep_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/* ---- G-02f-34：set_ndep + dep_seeded get/set ---- */

#[no_mangle]
function pipeline_set_ndep(n: i32): void {
  unsafe {
    typeck_ndep_store(n);
  }
}

#[no_mangle]
function driver_dep_seeded_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 32) {
    return 0;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function driver_dep_seeded_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    let p: *i32 = driver_dep_seeded_slot(i);
    p[0] = v;
  }
}

#[no_mangle]
function typeck_driver_dep_seeded_get(i: i32): i32 {
  return driver_dep_seeded_get(i);
}

/* ---- G-02f-40：dep module/arena get/set（数组本体 C，API 逻辑 .x）---- */

#[no_mangle]
function get_dep_module(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_module_get(i);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function get_dep_arena(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  unsafe {
    let n: i32 = get_ndep();
    if (i >= n) {
      return 0 as *u8;
    }
    let r: *u8 = typeck_dep_arena_get(i);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function typeck_get_dep_module(i: i32): *u8 {
  return get_dep_module(i);
}

#[no_mangle]
function typeck_get_dep_arena(i: i32): *u8 {
  return get_dep_arena(i);
}

#[no_mangle]
function pipeline_set_dep(i: i32, mod: *u8, arena: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    typeck_dep_module_set(i, mod);
    typeck_dep_arena_set(i, arena);
  }
}

/* ---- G-02f-42：driver dep publish + typeck buf 转发 ---- */

#[no_mangle]
function driver_dep_publish_slot(i: i32, arena: *u8, module: *u8, import_path: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 32) {
    return;
  }
  unsafe {
    driver_dep_arena_ptr_set(i, arena);
    driver_dep_module_ptr_set(i, module);
    driver_dep_seeded_set(i, 1);
    /* 始终调 path 槽：if (path!=null) 会被 -E 丢整函数；null 在 C 槽内忽略 */
    driver_dep_path_registry_set(i, import_path);
  }
}

#[no_mangle]
function typeck_driver_dep_module_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_module_buf(i);
    return r;
  }
  return 0 as *u8;
}

#[no_mangle]
function typeck_driver_dep_arena_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_arena_buf(i);
    return r;
  }
  return 0 as *u8;
}
