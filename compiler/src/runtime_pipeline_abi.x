// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-32..43/50..54：真迁 .x — pipeline dep/import/path + preprocess/seed/entry_lib。
// 产品：./shux-c -E → seeds/runtime_pipeline_abi.from_x.c（+ C 尾段）。
// C 尾：存储槽数组、import resolve/snprintf、clear 槽循环、malloc buf、大 pipeline。
// G-02f-54：+ preprocess_raw_to_malloc / dep_seed_slots / entry_lib_name_from_path。

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
extern "C" function strchr(s: *u8, c: i32): *u8;
extern "C" function shux_cstr_ends_with_dot_x(s: *u8): i32;
extern "C" function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32;
extern "C" function pipeline_asm_user_std_net_dep_path(path: *u8): i32;
extern "C" function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
extern "C" function shux_asm_out_buf_is_object_magic(data: *u8): i32;
extern "C" function shux_dep_prerun_entry_dir_pick(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8;
extern "C" function shux_find_loaded_import_index_scan(path: *u8, all_paths: *u8, n_all: i32): i32;
extern "C" function shux_merge_deps_path_already_out_scan(path: *u8, out_paths: *u8, n_out: i32): i32;
extern "C" function shux_emit_pipeline_glue_include_impl(): void;
extern "C" function shux_import_dep_dir_from_path_impl(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32;
extern "C" function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
extern "C" function driver_typeck_dep_sidecar_clear_impl(): void;
extern "C" function driver_dep_seeded_clear_slots_impl(): void;
extern "C" function shux_get_entry_dir_impl(input_path: *u8, entry_dir: *u8, size: i64): void;
extern "C" function driver_asm_fclose_asm_out_impl(fp: *u8): void;
extern "C" function shux_import_path_to_file_path_impl(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void;
extern "C" function shux_resolve_file_import_path_impl(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void;
extern "C" function driver_dep_slot_for_path_scan(path: *u8): i32;
extern "C" function shux_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32;
extern "C" function driver_dep_seed_slots_impl(arenas: *u8, modules: *u8, n: i32): void;
extern "C" function shux_entry_lib_name_from_path_impl(input_path: *u8): *u8;
extern "C" function shux_cstr_typeck_lit(): *u8;

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

/* ---- G-02f-50：import 路径形态 + asm dep 门闩 + object 魔数 ---- */

#[no_mangle]
function shux_import_path_is_file_path(import_path: *u8): i32 {
  if (import_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (import_path[0] == 0) {
      return 0;
    }
    /* '/' or '.' */
    if (import_path[0] == 47) {
      return 1;
    }
    if (import_path[0] == 46) {
      return 1;
    }
    if (strchr(import_path, 47) != 0 as *u8) {
      return 1;
    }
    if (shux_cstr_ends_with_dot_x(import_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function shux_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_dep_skip_x_typeck(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function shux_asm_user_std_net_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function shux_asm_user_std_io_driver_dep_path(dep_path: *u8): i32 {
  if (dep_path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_codegen_path_is_std_io_driver_bytes(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function shux_asm_user_dep_parse_skip_typeck_path(dep_path: *u8): i32 {
  unsafe {
    if (shux_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    if (shux_asm_user_std_io_driver_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function shux_asm_out_buf_is_object(data: *u8, len: i64): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  if (len < 4) {
    return 0;
  }
  unsafe {
    return shux_asm_out_buf_is_object_magic(data);
  }
  return 0;
}

/* ---- G-02f-51：prerun entry_dir / import 查找去重 / glue include / dep_dir ---- */

#[no_mangle]
function shux_dep_prerun_entry_dir(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  unsafe {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return shux_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}

#[no_mangle]
function shux_find_loaded_import_index(import_path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (import_path == 0 as *u8) {
    return -1;
  }
  if (all_paths == 0 as *u8) {
    return -1;
  }
  if (n_all <= 0) {
    return -1;
  }
  unsafe {
    return shux_find_loaded_import_index_scan(import_path, all_paths, n_all);
  }
  return -1;
}

#[no_mangle]
function shux_merge_deps_path_already_out(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  if (out_paths == 0 as *u8) {
    return 0;
  }
  if (n_out <= 0) {
    return 0;
  }
  unsafe {
    return shux_merge_deps_path_already_out_scan(path, out_paths, n_out);
  }
  return 0;
}

#[no_mangle]
function shux_emit_pipeline_glue_include(): void {
  unsafe {
    shux_emit_pipeline_glue_include_impl();
  }
}

#[no_mangle]
function shux_import_dep_dir_from_path(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  if (dep_dir == 0 as *u8) {
    return -1;
  }
  if (dep_dir_size == 0) {
    return -1;
  }
  unsafe {
    return shux_import_dep_dir_from_path_impl(path, dep_dir, dep_dir_size);
  }
  return -1;
}

/* ---- G-02f-52：mega debug 转发 / clear / entry_dir / fclose ---- */

#[no_mangle]
function pipeline_debug_trace_body_x_mega_pre_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}

#[no_mangle]
function pipeline_debug_trace_body_x_mega_post_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}

#[no_mangle]
function pipeline_debug_trace_body_x_mega_post_params(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}

#[no_mangle]
function pipeline_debug_trace_body_x_mega_post_frame(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}

#[no_mangle]
function pipeline_debug_trace_body_x_mega_post_locals(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}

#[no_mangle]
function pipeline_debug_trace_body_x_mega_pre_emit(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}

#[no_mangle]
function driver_typeck_dep_sidecar_clear(): void {
  unsafe {
    driver_typeck_dep_sidecar_clear_impl();
  }
}

#[no_mangle]
function driver_dep_seeded_clear_all(): void {
  unsafe {
    driver_dep_seeded_clear_slots_impl();
    driver_typeck_dep_sidecar_clear();
  }
}

#[no_mangle]
function shux_get_entry_dir(input_path: *u8, entry_dir: *u8, size: i64): void {
  if (entry_dir == 0 as *u8) {
    return;
  }
  if (size == 0) {
    return;
  }
  if (input_path == 0 as *u8) {
    unsafe {
      entry_dir[0] = 0;
    }
    return;
  }
  unsafe {
    shux_get_entry_dir_impl(input_path, entry_dir, size);
  }
}

#[no_mangle]
function driver_asm_fclose_asm_out(fp: *u8): void {
  unsafe {
    driver_asm_fclose_asm_out_impl(fp);
  }
}

/* ---- G-02f-53：import 路径转换 / resolve 文件 import / dep 槽查路径 ---- */

#[no_mangle]
function shux_import_path_to_file_path(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    shux_import_path_to_file_path_impl(lib_root, import_path, path, path_size);
  }
}

#[no_mangle]
function shux_resolve_file_import_path(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == 0 as *u8) {
    unsafe {
      path[0] = 0;
    }
    return;
  }
  unsafe {
    shux_resolve_file_import_path_impl(entry_dir, import_path, path, path_size);
  }
}

#[no_mangle]
function driver_dep_slot_for_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return -1;
  }
  unsafe {
    return driver_dep_slot_for_path_scan(path);
  }
  return -1;
}

/* ---- G-02f-54：preprocess 薄封装 / dep seed_slots / entry lib name ---- */

#[no_mangle]
function shux_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32 {
  unsafe {
    return shux_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return -1;
}

#[no_mangle]
function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void {
  unsafe {
    driver_dep_seed_slots_impl(arenas, modules, n);
  }
}

#[no_mangle]
function shux_entry_lib_name_from_path(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    unsafe {
      return shux_cstr_typeck_lit();
    }
    return 0 as *u8;
  }
  unsafe {
    return shux_entry_lib_name_from_path_impl(input_path);
  }
  return 0 as *u8;
}
