// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-32..43/50..63：真迁 .x — pipeline dep/import/path + emit + collect/merge 门闩。
// 产品：./shux-c -E → seeds/runtime_pipeline_abi.from_x.c（+ C 尾段）。
// C 尾：存储槽数组、import resolve/snprintf、clear 槽循环、malloc buf、大 pipeline。
// G-02f-63：+ ends_with/.x 魔数真逻辑；typeck_for_ctx / lsp_free_loaded 门闩。
// G-02f-84：pipeline preprocess diag + dep slot store 门闩。
// G-02f-85：import index / path-already-out scan 门闩。
// G-02f-93：+ pctx_update_dep_slots_no_reset / debug_body_func_match 门闩。
// G-02f-95：+ pipeline_run_x_thread_fn / asm_codegen_elf_o_thread_fn 门闩。
// G-02f-223：entry_dir_pick + import_dep_dir pure；dep set/ndep 边界。
// G-02f-224：path_registry scan + seed_slots pure。
// G-02f-225：sidecar_clear + preprocess/import 诊断 pure（note + report_with_code）。
// G-02f-226：entry_lib 关键词 pure + set_dep_slots pure。
// G-02f-227：lsp free_loaded 循环 + import_open_fail_once 去重 pure。
// G-02f-228：pctx seed_dep_slots / import_paths_only / update_dep_slots_no_reset pure。

extern "C" function pipeline_diag_emitted_flag_slot(): *i32;
extern "C" function typeck_ndep_slot(): *i32;
extern "C" function typeck_ndep_store_impl(n: i32): void;
extern "C" function driver_dep_seeded_slot(i: i32): *i32;
extern "C" function typeck_dep_module_get(i: i32): *u8;
extern "C" function typeck_dep_arena_get(i: i32): *u8;
extern "C" function typeck_dep_module_set_impl(i: i32, mod: *u8): void;
extern "C" function typeck_dep_arena_set_impl(i: i32, arena: *u8): void;
extern "C" function driver_dep_arena_ptr_set_impl(i: i32, arena: *u8): void;
extern "C" function driver_dep_module_ptr_set_impl(i: i32, module: *u8): void;
extern "C" function driver_dep_path_registry_set(i: i32, path: *u8): void;
extern "C" function driver_dep_path_registry_at(i: i32): *u8;
extern "C" function driver_dep_module_buf(i: i32): *u8;
extern "C" function driver_dep_arena_buf(i: i32): *u8;
extern "C" function strchr(s: *u8, c: i32): *u8;
extern "C" function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32;
extern "C" function pipeline_asm_user_std_net_dep_path(path: *u8): i32;
extern "C" function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
/* shux_dep_prerun_entry_dir_pick：G-02f-223 下方真迁 */
extern "C" function pipeline_typeck_module_for_ctx_impl(module: *u8, arena: *u8, ctx: *u8): i32;
extern "C" function free(p: *u8): void;
extern "C" function ast_module_free(mod: *u8): void;
extern "C" function shu_lsp_ptr_slot_clear(arr: *u8, i: i32): void;
/* pctx_update_dep_slots_no_reset：G-02f-228 下方真迁 */
extern "C" function ast_pipeline_dep_ctx_reset(ctx: *u8): void;
extern "C" function ast_pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
extern "C" function ast_pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
extern "C" function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void;
extern "C" function ast_pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void;
extern "C" function pipeline_run_x_thread_fn_impl(arg: *u8): *u8;
extern "C" function shux_asm_codegen_elf_o_thread_fn_impl(arg: *u8): *u8;

extern "C" function shux_emit_pipeline_glue_include_impl(): void;
extern "C" function shux_import_dep_dir_from_path_impl(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32;
extern "C" function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
extern "C" function driver_dep_seeded_clear_slots_impl(): void;
extern "C" function shux_get_entry_dir_impl(input_path: *u8, entry_dir: *u8, size: i64): void;
extern "C" function driver_asm_fclose_asm_out_impl(fp: *u8): void;
extern "C" function shux_import_path_to_file_path_impl(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void;
extern "C" function shux_resolve_file_import_path_impl(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void;
/* driver_dep_slot_for_path_scan：G-02f-224 下方真迁 */
extern "C" function shux_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32;
extern "C" function driver_dep_seed_slots_impl(arenas: *u8, modules: *u8, n: i32): void;
extern "C" function shux_entry_lib_name_from_path_impl(input_path: *u8): *u8;
extern "C" function shux_cstr_typeck_lit(): *u8;
extern "C" function shux_entry_lib_keyword_lit(k: i32): *u8;
extern "C" function pipeline_dep_arena_slot_set(i: i32, p: *u8): void;
extern "C" function pipeline_dep_module_slot_set(i: i32, p: *u8): void;
extern "C" function pipeline_dep_arena_slot_at(i: i32): *u8;
extern "C" function pipeline_dep_module_slot_at(i: i32): *u8;
/* import_open_fail_once：G-02f-227 下方真迁 */
extern "C" function pipeline_asm_debug_enabled_impl(): i32;
extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
/* preprocess/import diag：G-02f-225 下方真迁 */

extern "C" function pipeline_resolve_path_impl(path_ptr: *u8, path_len: i32): i32;
extern "C" function pipeline_read_file_impl(): i32;
extern "C" function pipeline_parse_into_loaded_import_impl(arena: *u8, module: *u8): i32;
extern "C" function shux_pipeline_run_x_pipeline_large_stack_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32;
extern "C" function shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32;
extern "C" function shux_pipeline_dep_prerun_parse_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32;
extern "C" function shux_pipeline_dep_prerun_typeck_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32;
extern "C" function shux_resolve_import_file_path_multi_impl(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void;
extern "C" function pipeline_set_entry_dir_impl(path: *u8): void;
extern "C" function pipeline_set_dep_slots_impl(arenas: *u8, modules: *u8): void;
extern "C" function shux_pipeline_fill_ctx_path_buffers_impl(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void;
/* pctx_seed_dep_slots / import_paths_only：G-02f-228 下方真迁 */
extern "C" function shux_pipeline_one_ctx_for_dep_prerun_impl(ctx: *u8, j: i32, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void;
extern "C" function shux_asm_codegen_elf_o_large_stack_impl(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32;
extern "C" function shux_load_direct_imports_for_asm_layout_impl(module: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, out_n: *i32): i32;
extern "C" function shux_merge_direct_then_transitive_dep_paths_impl(module: *u8, n_imports: i32, cpaths: *u8, n_closure: i32, out_paths: *u8, out_n: *i32): i32;
extern "C" function shux_merge_direct_then_transitive_deps_impl(module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32, out_src: *u8, out_lens: *u8, out_paths: *u8, out_n: *i32): i32;
extern "C" function shux_collect_deps_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32;
extern "C" function shux_collect_dep_paths_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32;
extern "C" function pipeline_debug_trace_named_func_bodies_impl(phase: *u8, module: *u8, arena: *u8): void;

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
    typeck_ndep_store_impl(n);
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
    typeck_dep_module_set_impl(i, mod);
    typeck_dep_arena_set_impl(i, arena);
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
    driver_dep_arena_ptr_set_impl(i, arena);
    driver_dep_module_ptr_set_impl(i, module);
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

/* ---- G-02f-50/63：import 路径形态 + asm dep 门闩 + object 魔数（真逻辑） ---- */

/* 真逻辑：后缀是否为 ".x"（无 strlen 语言限制；逐字节扫）。 */
#[no_mangle]
function shux_cstr_ends_with_dot_x(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i64 = 0;
    while (s[n] != 0) {
      n = n + 1;
    }
    if (n < 2) {
      return 0;
    }
    /* '.' == 46, 'x' == 120 */
    if (s[n - 2] != 46) {
      return 0;
    }
    if (s[n - 1] != 120) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* 真逻辑：Mach-O 64 / CIGAM / ELF 魔数（前 4 字节）。 */
#[no_mangle]
function shux_asm_out_buf_is_object_magic(data: *u8): i32 {
  if (data == 0 as *u8) {
    return 0;
  }
  unsafe {
    let b0: u8 = data[0];
    let b1: u8 = data[1];
    let b2: u8 = data[2];
    let b3: u8 = data[3];
    /* MH_MAGIC_64 LE: cf fa ed fe */
    if (b0 == 207) {
      if (b1 == 250) {
        if (b2 == 237) {
          if (b3 == 254) {
            return 1;
          }
        }
      }
    }
    /* MH_CIGAM_64: fe ed fa cf */
    if (b0 == 254) {
      if (b1 == 237) {
        if (b2 == 250) {
          if (b3 == 207) {
            return 1;
          }
        }
      }
    }
    /* ELF: 7f 'E' 'L' 'F' */
    if (b0 == 127) {
      if (b1 == 69) {
        if (b2 == 76) {
          if (b3 == 70) {
            return 1;
          }
        }
      }
    }
    return 0;
  }
  return 0;
}

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
  return shux_find_loaded_import_index_scan(import_path, all_paths, n_all);
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
  return shux_merge_deps_path_already_out_scan(path, out_paths, n_out);
}

#[no_mangle]
function shux_emit_pipeline_glue_include(): void {
  unsafe {
    shux_emit_pipeline_glue_include_impl();
  }
}

// G-02f-223：从 path 取目录（最后 '/' 前）；无 path 时写 "."
#[no_mangle]
function shux_import_dep_dir_from_path(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (dep_dir == 0 as *u8) { return 0 - 1; }
  if (dep_dir_size == 0) { return 0 - 1; }
  unsafe {
    let n: i64 = 0;
    while (n < 4096) {
      if (path[n] == 0) { break; }
      n = n + 1;
    }
    let last_slash: i64 = 0 - 1;
    let i: i64 = 0;
    while (i < n) {
      // '/'
      if (path[i] == 47) { last_slash = i; }
      i = i + 1;
    }
    if (last_slash < 0) {
      if (dep_dir_size < 2) { return 0 - 1; }
      dep_dir[0] = 46; // '.'
      dep_dir[1] = 0;
      return 0;
    }
    let dlen: i64 = last_slash;
    if (dlen >= dep_dir_size) { return 0 - 1; }
    let j: i64 = 0;
    while (j < dlen) {
      dep_dir[j] = path[j];
      j = j + 1;
    }
    dep_dir[dlen] = 0;
    return 0;
  }
  return 0 - 1;
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

// G-02f-225：清 typeck dep 侧车（ndep=0 + 32 槽空）
#[no_mangle]
function driver_typeck_dep_sidecar_clear(): void {
  typeck_ndep_store(0);
  let i: i32 = 0;
  while (i < 32) {
    typeck_dep_module_set(i, 0 as *u8);
    typeck_dep_arena_set(i, 0 as *u8);
    i = i + 1;
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

// G-02f-224：按 path 扫 path_registry（32 槽）
#[no_mangle]
function driver_dep_slot_for_path_scan(path: *u8): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  unsafe {
    let i: i32 = 0;
    while (i < 32) {
      let reg: *u8 = driver_dep_path_registry_at(i);
      if (reg != 0 as *u8) {
        if (pipe_cstr_eq(reg, path) != 0) { return i; }
      }
      i = i + 1;
    }
  }
  return 0 - 1;
}

#[no_mangle]
function driver_dep_slot_for_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  return driver_dep_slot_for_path_scan(path);
}

/* ---- G-02f-54：preprocess 薄封装 / dep seed_slots / entry lib name ---- */

#[no_mangle]
function shux_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32 {
  unsafe {
    return shux_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return -1;
}

// G-02f-224：批量预填 dep 槽 + seeded 标记
#[no_mangle]
function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void {
  let j: i32 = 0;
  while (j < 32) {
    if (j < n) {
      unsafe {
        let a: *u8 = 0 as *u8;
        let m: *u8 = 0 as *u8;
        if (arenas != 0 as *u8) {
          a = pipe_load_ptr_slot(arenas, j);
        }
        if (modules != 0 as *u8) {
          m = pipe_load_ptr_slot(modules, j);
        }
        driver_dep_arena_ptr_set(j, a);
        driver_dep_module_ptr_set(j, m);
        driver_dep_seeded_set(j, 1);
      }
    } else {
      driver_dep_seeded_set(j, 0);
    }
    j = j + 1;
  }
}

// G-02f-226 内部：hay 是否包含 needle（strstr 语义）
function pipe_cstr_contains(hay: *u8, needle: *u8): i32 {
  if (hay == 0 as *u8) { return 0; }
  if (needle == 0 as *u8) { return 0; }
  if (needle[0] == 0) { return 1; }
  unsafe {
    let hi: i32 = 0;
    while (hi < 4096) {
      if (hay[hi] == 0) { return 0; }
      let j: i32 = 0;
      let ok: i32 = 1;
      while (ok != 0) {
        if (needle[j] == 0) { return 1; }
        if (hay[hi + j] == 0) { ok = 0; }
        else {
          if (hay[hi + j] != needle[j]) { ok = 0; }
          else { j = j + 1; }
        }
      }
      hi = hi + 1;
    }
  }
  return 0;
}

// G-02f-226：入口路径 → lib 前缀；关键词 pure，std/ 等回落 impl
#[no_mangle]
function shux_entry_lib_name_from_path(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    unsafe {
      return shux_cstr_typeck_lit();
    }
    return 0 as *u8;
  }
  unsafe {
    // 先扫 std/：复杂 stem 仍走 impl
    let stdn: u8[8] = [];
    stdn[0]=115;stdn[1]=116;stdn[2]=100;stdn[3]=47;stdn[4]=0; // "std/"
    if (pipe_cstr_contains(input_path, &stdn[0]) != 0) {
      return shux_entry_lib_name_from_path_impl(input_path);
    }
    let k0: u8[8] = []; // main
    k0[0]=109;k0[1]=97;k0[2]=105;k0[3]=110;k0[4]=0;
    if (pipe_cstr_contains(input_path, &k0[0]) != 0) { return shux_entry_lib_keyword_lit(0); }
    let k1: u8[8] = []; // build
    k1[0]=98;k1[1]=117;k1[2]=105;k1[3]=108;k1[4]=100;k1[5]=0;
    if (pipe_cstr_contains(input_path, &k1[0]) != 0) { return shux_entry_lib_keyword_lit(1); }
    let k2: u8[16] = []; // pipeline
    k2[0]=112;k2[1]=105;k2[2]=112;k2[3]=101;k2[4]=108;k2[5]=105;k2[6]=110;k2[7]=101;k2[8]=0;
    if (pipe_cstr_contains(input_path, &k2[0]) != 0) { return shux_entry_lib_keyword_lit(2); }
    let k3: u8[8] = []; // driver
    k3[0]=100;k3[1]=114;k3[2]=105;k3[3]=118;k3[4]=101;k3[5]=114;k3[6]=0;
    if (pipe_cstr_contains(input_path, &k3[0]) != 0) { return shux_entry_lib_keyword_lit(3); }
    let k4: u8[16] = []; // codegen
    k4[0]=99;k4[1]=111;k4[2]=100;k4[3]=101;k4[4]=103;k4[5]=101;k4[6]=110;k4[7]=0;
    if (pipe_cstr_contains(input_path, &k4[0]) != 0) { return shux_entry_lib_keyword_lit(4); }
    let k5: u8[8] = []; // typeck
    k5[0]=116;k5[1]=121;k5[2]=112;k5[3]=101;k5[4]=99;k5[5]=107;k5[6]=0;
    if (pipe_cstr_contains(input_path, &k5[0]) != 0) { return shux_entry_lib_keyword_lit(5); }
    let k6: u8[8] = []; // parser
    k6[0]=112;k6[1]=97;k6[2]=114;k6[3]=115;k6[4]=101;k6[5]=114;k6[6]=0;
    if (pipe_cstr_contains(input_path, &k6[0]) != 0) { return shux_entry_lib_keyword_lit(6); }
    let k7: u8[8] = []; // token
    k7[0]=116;k7[1]=111;k7[2]=107;k7[3]=101;k7[4]=110;k7[5]=0;
    if (pipe_cstr_contains(input_path, &k7[0]) != 0) { return shux_entry_lib_keyword_lit(7); }
    let k8: u8[8] = []; // lexer
    k8[0]=108;k8[1]=101;k8[2]=120;k8[3]=101;k8[4]=114;k8[5]=0;
    if (pipe_cstr_contains(input_path, &k8[0]) != 0) { return shux_entry_lib_keyword_lit(8); }
    let k9: u8[8] = []; // ast
    k9[0]=97;k9[1]=115;k9[2]=116;k9[3]=0;
    if (pipe_cstr_contains(input_path, &k9[0]) != 0) { return shux_entry_lib_keyword_lit(9); }
    return shux_entry_lib_name_from_path_impl(input_path);
  }
  return 0 as *u8;
}

/* ---- G-02f-55：pipeline dep 槽访问 + import open 诊断门闩 ---- */

#[no_mangle]
function pipeline_get_dep_arena_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_arena_slot_at(i);
  }
  return 0 as *u8;
}

#[no_mangle]
function pipeline_get_dep_module_slot(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 32) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_dep_module_slot_at(i);
  }
  return 0 as *u8;
}

// G-02f-227：import open 失败去重诊断
let g_import_open_valid: i32 = 0;
let g_import_open_import: u8[65] = [];
let g_import_open_resolved: u8[512] = [];

function pipe_cstr_copy(dst: *u8, cap: i32, src: *u8): void {
  let i: i32 = 0;
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  unsafe {
    while (i < (cap - 1)) {
      let c: u8 = src[i];
      dst[i] = c;
      if (c == 0) { return; }
      i = i + 1;
    }
    dst[cap - 1] = 0;
  }
}

#[no_mangle]
function pipeline_diag_import_open_fail_once(import_path: *u8, resolved_path: *u8): void {
  let q: u8[2] = [];
  q[0] = 63; // '?'
  q[1] = 0;
  let import_key: *u8 = import_path;
  let resolved_key: *u8 = resolved_path;
  if (import_key == 0 as *u8) { import_key = &q[0]; }
  if (resolved_key == 0 as *u8) { resolved_key = &q[0]; }
  unsafe {
    if (g_import_open_valid != 0) {
      if (pipe_cstr_eq(&g_import_open_import[0], import_key) != 0) {
        if (pipe_cstr_eq(&g_import_open_resolved[0], resolved_key) != 0) {
          pipeline_diag_emitted_note();
          return;
        }
      }
    }
    pipe_cstr_copy(&g_import_open_import[0], 65, import_key);
    pipe_cstr_copy(&g_import_open_resolved[0], 512, resolved_key);
    g_import_open_valid = 1;
    pipeline_diag_emitted_note();
    let kind: u8[16] = [];
    let code: u8[8] = [];
    let msg: u8[32] = [];
    // "import error"
    kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
    kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
    // "IMP001"
    code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=49;code[6]=0;
    // "cannot open import"
    msg[0]=99;msg[1]=97;msg[2]=110;msg[3]=110;msg[4]=111;msg[5]=116;msg[6]=32;msg[7]=111;
    msg[8]=112;msg[9]=101;msg[10]=110;msg[11]=32;msg[12]=105;msg[13]=109;msg[14]=112;msg[15]=111;
    msg[16]=114;msg[17]=116;msg[18]=0;
    let file: *u8 = resolved_path;
    if (file == 0 as *u8) { file = import_path; }
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

/* ---- G-02f-56：resolve_path / read_file / parse loaded import ---- */

#[no_mangle]
function pipeline_resolve_path(path_ptr: *u8, path_len: i32): i32 {
  if (path_ptr == 0 as *u8) {
    return -1;
  }
  unsafe {
    return pipeline_resolve_path_impl(path_ptr, path_len);
  }
  return -1;
}

#[no_mangle]
function pipeline_read_file(): i32 {
  unsafe {
    return pipeline_read_file_impl();
  }
  return -1;
}

#[no_mangle]
function pipeline_parse_into_loaded_import(arena: *u8, module: *u8): i32 {
  if (arena == 0 as *u8) {
    return -1;
  }
  if (module == 0 as *u8) {
    return -1;
  }
  unsafe {
    return pipeline_parse_into_loaded_import_impl(arena, module);
  }
  return -1;
}

/* ---- G-02f-57：大栈 pthread 上跑 X pipeline ---- */

#[no_mangle]
function shux_pipeline_run_x_pipeline_large_stack(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    return shux_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
  }
  return -1;
}

/* ---- G-02f-58：dep 预跑 parse 门闩 ---- */

#[no_mangle]
function shux_pipeline_dep_prerun_parse_skip_typeck(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  unsafe {
    return shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return -1;
}

#[no_mangle]
function shux_pipeline_dep_prerun_parse_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return -1;
  }
  if (dep_arena == 0 as *u8) {
    return -1;
  }
  if (src == 0 as *u8) {
    return -1;
  }
  if (len == 0) {
    return -1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return -1;
}

/* ---- G-02f-59：dep prerun typeck + multi-root resolve ---- */

#[no_mangle]
function shux_pipeline_dep_prerun_typeck_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return -1;
  }
  if (dep_arena == 0 as *u8) {
    return -1;
  }
  if (src == 0 as *u8) {
    return -1;
  }
  if (len == 0) {
    return -1;
  }
  if (one_ctx == 0 as *u8) {
    return -1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return -1;
}

#[no_mangle]
function shux_pipeline_dep_prerun_for_asm_module_o(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  unsafe {
    return shux_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return -1;
}

#[no_mangle]
function shux_resolve_import_file_path_multi(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
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
    shux_resolve_import_file_path_multi_impl(lib_roots, n_lib_roots, entry_dir, import_path, path, path_size);
  }
}

/* ---- G-02f-60：entry_dir / dep 槽 / ctx path 与 dep seed ---- */

#[no_mangle]
function pipeline_set_entry_dir(path: *u8): void {
  unsafe {
    pipeline_set_entry_dir_impl(path);
  }
}

// G-02f-226：写入 32 个 pipeline dep arena/module 槽
#[no_mangle]
function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void {
  let i: i32 = 0;
  while (i < 32) {
    unsafe {
      let a: *u8 = 0 as *u8;
      let m: *u8 = 0 as *u8;
      if (arenas != 0 as *u8) {
        a = pipe_load_ptr_slot(arenas, i);
      }
      if (modules != 0 as *u8) {
        m = pipe_load_ptr_slot(modules, i);
      }
      pipeline_dep_arena_slot_set(i, a);
      pipeline_dep_module_slot_set(i, m);
    }
    i = i + 1;
  }
}

#[no_mangle]
function shux_pipeline_fill_ctx_path_buffers(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    shux_pipeline_fill_ctx_path_buffers_impl(ctx, entry_dir, lib_roots, n_lib_roots);
  }
}

// G-02f-228 内部：C 字符串长度（上限 65536）
function pipe_cstr_len(s: *u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (s[i] == 0) { return i; }
    i = i + 1;
  }
  return i;
}

// G-02f-228：reset + 写 module/arena/import_path 槽 + set_ndep
#[no_mangle]
function shux_pipeline_pctx_seed_dep_slots(ctx: *u8, dep_mods: *u8, dep_ar: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ar != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ar, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}

// G-02f-228：仅镜像 import path；ndep 保持 0（reset 后不 set_ndep）
#[no_mangle]
function shux_pipeline_pctx_seed_dep_import_paths_only(ctx: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    ast_pipeline_dep_ctx_reset(ctx);
  }
  let i: i32 = 0;
  while (i < n) {
    if (import_paths != 0 as *u8) {
      unsafe {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
}

#[no_mangle]
function shux_pipeline_one_ctx_for_dep_prerun(ctx: *u8, j: i32, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    shux_pipeline_one_ctx_for_dep_prerun_impl(ctx, j, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}

/* ---- G-02f-61：asm emit 编排 / large_stack codegen / load+merge paths ---- */

#[no_mangle]
function shux_driver_asm_prepare_entry_elf_emit(module: *u8, arena: *u8, pctx: *u8): void {
  unsafe {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}

#[no_mangle]
function shux_asm_codegen_elf_o_large_stack(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return shux_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
  }
  return -1;
}

#[no_mangle]
function shux_load_direct_imports_for_asm_layout(module: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return -1;
  }
  if (out_n == 0 as *i32) {
    return -1;
  }
  unsafe {
    return shux_load_direct_imports_for_asm_layout_impl(module, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, out_n);
  }
  return -1;
}

#[no_mangle]
function shux_merge_direct_then_transitive_dep_paths(module: *u8, n_imports: i32, cpaths: *u8, n_closure: i32, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return -1;
  }
  if (out_n == 0 as *i32) {
    return -1;
  }
  unsafe {
    return shux_merge_direct_then_transitive_dep_paths_impl(module, n_imports, cpaths, n_closure, out_paths, out_n);
  }
  return -1;
}

/* ---- G-02f-62：collect/merge 传递闭包 + debug body trace ---- */

#[no_mangle]
function shux_merge_direct_then_transitive_deps(module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32, out_src: *u8, out_lens: *u8, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return -1;
  }
  if (out_n == 0 as *i32) {
    return -1;
  }
  unsafe {
    return shux_merge_direct_then_transitive_deps_impl(module, n_imports, cls, clens, cpaths, n_closure, out_src, out_lens, out_paths, out_n);
  }
  return -1;
}

#[no_mangle]
function shux_collect_deps_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return -1;
  }
  if (n_deps == 0 as *i32) {
    return -1;
  }
  unsafe {
    return shux_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return -1;
}

#[no_mangle]
function shux_collect_dep_paths_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return -1;
  }
  if (n_deps == 0 as *i32) {
    return -1;
  }
  unsafe {
    return shux_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, n_deps);
  }
  return -1;
}

#[no_mangle]
function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies_impl(phase, module, arena);
  }
}

/* ---- G-02f-63：typeck_for_ctx / lsp free_loaded 门闩 ---- */

#[no_mangle]
function pipeline_typeck_module_for_ctx(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return pipeline_typeck_module_for_ctx_impl(module, arena, ctx);
  }
  return 0 - 1;
}

// G-02f-227：释放 LSP 已加载 dep mods/paths 列表
#[no_mangle]
function shu_lsp_free_loaded_imports(all_dep_mods: *u8, all_dep_paths: *u8, n_all: i32): void {
  if (all_dep_mods == 0 as *u8) { return; }
  if (all_dep_paths == 0 as *u8) { return; }
  if (n_all <= 0) { return; }
  let i: i32 = 0;
  while (i < n_all) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(all_dep_paths, i);
      if (p != 0 as *u8) {
        free(p);
        shu_lsp_ptr_slot_clear(all_dep_paths, i);
      }
      let m: *u8 = pipe_load_ptr_slot(all_dep_mods, i);
      if (m != 0 as *u8) {
        ast_module_free(m);
        shu_lsp_ptr_slot_clear(all_dep_mods, i);
      }
    }
    i = i + 1;
  }
}


/* ---- G-02f-84：preprocess diag / asm debug / dep slot store 门闩 ---- */


// G-02f-225：preprocess / import 诊断 pure（先 note 再 report_with_code）
// kind="preprocess error" / "pipeline error" / "import error"；code=PP001/PP002/XP005/IMP002/IMP004

#[no_mangle]
function pipeline_diag_preprocess_unclosed_if(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[16] = [];
  // "preprocess error"
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  // "PP001"
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=49;code[5]=0;
  // "unclosed #if"
  msg[0]=117;msg[1]=110;msg[2]=99;msg[3]=108;msg[4]=111;msg[5]=115;msg[6]=101;msg[7]=100;
  msg[8]=32;msg[9]=35;msg[10]=105;msg[11]=102;msg[12]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

#[no_mangle]
function pipeline_diag_preprocess_fail(path_diag: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=80;code[1]=80;code[2]=48;code[3]=48;code[4]=50;code[5]=0; // PP002
  // ".x preprocess failed"
  msg[0]=46;msg[1]=120;msg[2]=32;msg[3]=112;msg[4]=114;msg[5]=101;msg[6]=112;msg[7]=114;
  msg[8]=111;msg[9]=99;msg[10]=101;msg[11]=115;msg[12]=115;msg[13]=32;msg[14]=102;msg[15]=97;
  msg[16]=105;msg[17]=108;msg[18]=101;msg[19]=100;msg[20]=0;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

#[no_mangle]
function pipeline_diag_import_preprocess_fail(import_path: *u8, resolved_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[40] = [];
  kind[0]=112;kind[1]=114;kind[2]=101;kind[3]=112;kind[4]=114;kind[5]=111;kind[6]=99;kind[7]=101;
  kind[8]=115;kind[9]=115;kind[10]=32;kind[11]=101;kind[12]=114;kind[13]=114;kind[14]=111;kind[15]=114;kind[16]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=50;code[6]=0; // IMP002
  // "import preprocess failed"
  msg[0]=105;msg[1]=109;msg[2]=112;msg[3]=111;msg[4]=114;msg[5]=116;msg[6]=32;msg[7]=112;
  msg[8]=114;msg[9]=101;msg[10]=112;msg[11]=114;msg[12]=111;msg[13]=99;msg[14]=101;msg[15]=115;
  msg[16]=115;msg[17]=32;msg[18]=102;msg[19]=97;msg[20]=105;msg[21]=108;msg[22]=101;msg[23]=100;msg[24]=0;
  let file: *u8 = resolved_path;
  if (file == 0 as *u8) { file = import_path; }
  unsafe {
    diag_report_with_code(file, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

#[no_mangle]
function pipeline_diag_preprocess_alloc_fail(path_diag: *u8, what: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  // "pipeline error"
  kind[0]=112;kind[1]=105;kind[2]=112;kind[3]=101;kind[4]=108;kind[5]=105;kind[6]=110;kind[7]=101;
  kind[8]=32;kind[9]=101;kind[10]=114;kind[11]=114;kind[12]=111;kind[13]=114;kind[14]=0;
  code[0]=88;code[1]=80;code[2]=48;code[3]=48;code[4]=53;code[5]=0; // XP005
  // "allocation failed during preprocess"
  msg[0]=97;msg[1]=108;msg[2]=108;msg[3]=111;msg[4]=99;msg[5]=97;msg[6]=116;msg[7]=105;
  msg[8]=111;msg[9]=110;msg[10]=32;msg[11]=102;msg[12]=97;msg[13]=105;msg[14]=108;msg[15]=101;
  msg[16]=100;msg[17]=32;msg[18]=100;msg[19]=117;msg[20]=114;msg[21]=105;msg[22]=110;msg[23]=103;
  msg[24]=32;msg[25]=112;msg[26]=114;msg[27]=101;msg[28]=112;msg[29]=114;msg[30]=111;msg[31]=99;
  msg[32]=101;msg[33]=115;msg[34]=115;msg[35]=0;
  let _w: *u8 = what;
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
}

#[no_mangle]
function pipeline_diag_merge_dep_missing(import_path: *u8): void {
  pipeline_diag_emitted_note();
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[48] = [];
  let note_k: u8[8] = [];
  let note_m: u8[64] = [];
  // "import error"
  kind[0]=105;kind[1]=109;kind[2]=112;kind[3]=111;kind[4]=114;kind[5]=116;kind[6]=32;kind[7]=101;
  kind[8]=114;kind[9]=114;kind[10]=111;kind[11]=114;kind[12]=0;
  code[0]=73;code[1]=77;code[2]=80;code[3]=48;code[4]=48;code[5]=52;code[6]=0; // IMP004
  // "direct import missing from dependency closure"
  msg[0]=100;msg[1]=105;msg[2]=114;msg[3]=101;msg[4]=99;msg[5]=116;msg[6]=32;msg[7]=105;
  msg[8]=109;msg[9]=112;msg[10]=111;msg[11]=114;msg[12]=116;msg[13]=32;msg[14]=109;msg[15]=105;
  msg[16]=115;msg[17]=115;msg[18]=105;msg[19]=110;msg[20]=103;msg[21]=32;msg[22]=102;msg[23]=114;
  msg[24]=111;msg[25]=109;msg[26]=32;msg[27]=100;msg[28]=101;msg[29]=112;msg[30]=32;msg[31]=99;
  msg[32]=108;msg[33]=111;msg[34]=115;msg[35]=117;msg[36]=114;msg[37]=101;msg[38]=0;
  note_k[0]=110;note_k[1]=111;note_k[2]=116;note_k[3]=101;note_k[4]=0;
  // "dependency closure construction failed before merge_deps completed"
  note_m[0]=100;note_m[1]=101;note_m[2]=112;note_m[3]=101;note_m[4]=110;note_m[5]=100;note_m[6]=101;note_m[7]=110;
  note_m[8]=99;note_m[9]=121;note_m[10]=32;note_m[11]=99;note_m[12]=108;note_m[13]=111;note_m[14]=115;note_m[15]=117;
  note_m[16]=114;note_m[17]=101;note_m[18]=32;note_m[19]=99;note_m[20]=111;note_m[21]=110;note_m[22]=115;note_m[23]=116;
  note_m[24]=114;note_m[25]=117;note_m[26]=99;note_m[27]=116;note_m[28]=105;note_m[29]=111;note_m[30]=110;note_m[31]=32;
  note_m[32]=102;note_m[33]=97;note_m[34]=105;note_m[35]=108;note_m[36]=101;note_m[37]=100;note_m[38]=0;
  unsafe {
    diag_report_with_code(import_path, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
    diag_report(0 as *u8, 0, 0, &note_k[0], &note_m[0], 0 as *u8);
  }
}

// G-02f-223：ndep 上限 32
#[no_mangle]
function typeck_ndep_store(n: i32): void {
  let v: i32 = n;
  if (v > 32) { v = 32; }
  if (v < 0) { v = 0; }
  unsafe {
    typeck_ndep_store_impl(v);
  }
}

// G-02f-223：dep module 槽写（边界 + 槽 API）
#[no_mangle]
function typeck_dep_module_set(i: i32, mod: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
  }
}

// G-02f-223：dep arena 槽写
#[no_mangle]
function typeck_dep_arena_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_arena_set_impl(i, arena);
  }
}

// G-02f-224：driver dep 指针槽边界
#[no_mangle]
function driver_dep_arena_ptr_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
  }
}

#[no_mangle]
function driver_dep_module_ptr_set(i: i32, module: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_module_ptr_set_impl(i, module);
  }
}


/* ---- G-02f-85 / G-02f-134：import path scan ---- */

function pipe_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (a[i] != b[i]) { return 0; }
    if (a[i] == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// char** 槽位：all_paths 为指针数组首地址
function pipe_load_ptr_slot(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = base[off] as usize;
  a = a + (base[off + 1] as usize) * m;
  a = a + (base[off + 2] as usize) * m2;
  a = a + (base[off + 3] as usize) * (m2 * m);
  a = a + (base[off + 4] as usize) * m4;
  a = a + (base[off + 5] as usize) * (m4 * m);
  a = a + (base[off + 6] as usize) * (m4 * m2);
  a = a + (base[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

// G-02f-223：-L lib_roots[0] 优先于 main_entry_dir
#[no_mangle]
function shux_dep_prerun_entry_dir_pick(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  if (lib_roots == 0 as *u8) { return main_entry_dir; }
  if (n_lib_roots <= 0) { return main_entry_dir; }
  unsafe {
    let r0: *u8 = pipe_load_ptr_slot(lib_roots, 0);
    if (r0 != 0 as *u8) {
      if (r0[0] != 0) { return r0; }
    }
  }
  return main_entry_dir;
}

#[no_mangle]
function shux_find_loaded_import_index_scan(path: *u8, all_paths: *u8, n_all: i32): i32 {
  if (path == 0 as *u8) { return 0 - 1; }
  if (all_paths == 0 as *u8) { return 0 - 1; }
  if (n_all <= 0) { return 0 - 1; }
  let i: i32 = 0;
  while (i < n_all) {
    let p: *u8 = pipe_load_ptr_slot(all_paths, i);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return i; }
    }
    i = i + 1;
  }
  return 0 - 1;
}

#[no_mangle]
function shux_merge_deps_path_already_out_scan(path: *u8, out_paths: *u8, n_out: i32): i32 {
  if (path == 0 as *u8) { return 0; }
  if (out_paths == 0 as *u8) { return 0; }
  if (n_out <= 0) { return 0; }
  let j: i32 = 0;
  while (j < n_out) {
    let p: *u8 = pipe_load_ptr_slot(out_paths, j);
    if (p != 0) {
      if (pipe_cstr_eq(p, path) != 0) { return 1; }
    }
    j = j + 1;
  }
  return 0;
}

/* ---- G-02f-93 / G-02f-228：pctx dep-slot update（无 reset，保留 lib_root 等） ---- */

// G-02f-228：写 module/arena/import_path + set_ndep，不 reset
#[no_mangle]
function shux_pipeline_pctx_update_dep_slots_no_reset(ctx: *u8, dep_mods: *u8, dep_ars: *u8, import_paths: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < n) {
    unsafe {
      let m: *u8 = 0 as *u8;
      let a: *u8 = 0 as *u8;
      if (dep_mods != 0 as *u8) {
        m = pipe_load_ptr_slot(dep_mods, i);
      }
      if (dep_ars != 0 as *u8) {
        a = pipe_load_ptr_slot(dep_ars, i);
      }
      ast_pipeline_dep_ctx_set_module(ctx, i, m);
      ast_pipeline_dep_ctx_set_arena(ctx, i, a);
      if (import_paths != 0 as *u8) {
        let p: *u8 = pipe_load_ptr_slot(import_paths, i);
        if (p != 0 as *u8) {
          let pl: i32 = pipe_cstr_len(p);
          ast_pipeline_dep_ctx_set_import_path(ctx, i, p, pl);
        }
      }
    }
    i = i + 1;
  }
  unsafe {
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
  }
}



/* ---- G-02f-95：pipeline large-stack thread fns 门闩 ---- */

#[no_mangle]
function pipeline_run_x_thread_fn(arg: *u8): *u8 {
  unsafe {
    return pipeline_run_x_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

#[no_mangle]
function shux_asm_codegen_elf_o_thread_fn(arg: *u8): *u8 {
  unsafe {
    return shux_asm_codegen_elf_o_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
function pipeline_asm_debug_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_DEBUG");
    if (e != 0) { return 1; }
  }
  return 0;
}

// G-02f-118：pipeline_debug_body_func_match 真迁 .x

#[no_mangle]
function pipeline_debug_body_func_match(filter: *u8, name: *u8): i32 {
  if (filter == 0) { return 0; }
  if (filter[0] == 0) { return 0; }
  if (filter[0] == 48) { return 0; } // '0'
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  // name_len
  let name_len: i32 = 0;
  while (name_len < 512) {
    if (name[name_len] == 0) { break; }
    name_len = name_len + 1;
  }
  let p: i32 = 0;
  while (p < 4096) {
    let c: u8 = filter[p];
    if (c == 0) { break; }
    // skip spaces/tabs/commas
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 32) { p = p + 1; continue; }
      if (c == 9) { p = p + 1; continue; }
      if (c == 44) { p = p + 1; continue; }
      break;
    }
    c = filter[p];
    if (c == 0) { break; }
    let start: i32 = p;
    while (p < 4096) {
      c = filter[p];
      if (c == 0) { break; }
      if (c == 44) { break; }
      p = p + 1;
    }
    let end: i32 = p;
    // trim trailing space/tab
    while (end > start) {
      let pc: u8 = filter[end - 1];
      if (pc == 32) { end = end - 1; continue; }
      if (pc == 9) { end = end - 1; continue; }
      break;
    }
    let tok_len: i32 = end - start;
    if (tok_len > 0) {
      if (tok_len == name_len) {
        let k: i32 = 0;
        let eq: i32 = 1;
        while (k < tok_len) {
          if (filter[start + k] != name[k]) { eq = 0; break; }
          k = k + 1;
        }
        if (eq != 0) { return 1; }
      }
    }
  }
  return 0;
}

