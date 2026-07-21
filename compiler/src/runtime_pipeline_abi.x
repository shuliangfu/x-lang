// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 runtime_pipeline_abi pure authority (product PREFER hybrid wave45–wave50).
// Product: g05_try_x_to_o this file + seeds/runtime_pipeline_abi.from_x.c rest
//   (-DSHUX_RUNTIME_PIPELINE_ABI_FROM_X) ld -r → src/runtime_pipeline_abi.o
// Cap residual: heavy FILE star / access / tmp_parse / paths resolve+read+preprocess /
//   thread C remains seed rest (transitive_impl pure wave50).
// wave45 root fix: never put the two-char end-comment marker inside block prose
//   (historical char**/void* truncated parse → silent drop of all later export function).
// wave46: pure merge/collect helpers (ptr/size slots, i32_store, module import cstr,
//   collect_to_load_has, preprocess directive diag codes) — seed cold twins under FROM_X.
// wave47: pure collect seed_to_load + enqueue_module_imports (strdup Cap residual).
// wave48: pure collect deps_process_one orch; Cap residual tmp_parse_and_enqueue;
//   G.7 reuses load_one_direct_import_at for resolve/read/preprocess store.
// wave49: pure collect paths_process_one orch; Cap residual paths_tmp_resolve_parse_enqueue
//   (resolve/read/preprocess + G.7 tmp_parse_and_enqueue + free prep).
// wave50: pure collect deps/paths transitive_impl orch (stack to_load[32] + process_one loop).
// PLATFORM: SHARED — pure link-name contract; verify mac + Ubuntu L2 PREFER hybrid.

export extern "C" function pipeline_diag_emitted_flag_slot(): *i32;
export extern "C" function typeck_ndep_slot(): *i32;
export extern "C" function typeck_ndep_store_impl(n: i32): void;
export extern "C" function driver_dep_seeded_slot(i: i32): *i32;
export extern "C" function typeck_dep_module_get(i: i32): *u8;
export extern "C" function typeck_dep_arena_get(i: i32): *u8;
export extern "C" function typeck_dep_module_set_impl(i: i32, mod: *u8): void;
export extern "C" function typeck_dep_arena_set_impl(i: i32, arena: *u8): void;
export extern "C" function driver_dep_arena_ptr_set_impl(i: i32, arena: *u8): void;
export extern "C" function driver_dep_module_ptr_set_impl(i: i32, module: *u8): void;
export extern "C" function driver_dep_path_registry_set(i: i32, path: *u8): void;
export extern "C" function driver_dep_path_registry_at(i: i32): *u8;
export extern "C" function driver_dep_module_buf(i: i32): *u8;
export extern "C" function driver_dep_arena_buf(i: i32): *u8;
export extern "C" function strchr(s: *u8, c: i32): *u8;
export extern "C" function pipeline_asm_user_dep_skip_x_typeck(path: *u8): i32;
export extern "C" function pipeline_asm_user_std_net_dep_path(path: *u8): i32;
export extern "C" function pipeline_codegen_path_is_std_io_driver_bytes(path: *u8): i32;
/* See implementation. */
/* See implementation. */
export extern "C" function typeck_module_entry_only(module: *u8): i32;
export extern "C" function typeck_module_with_sidecar(module: *u8): i32;
export extern "C" function free(p: *u8): void;
// wave47 Cap residual: owned C-string copy for collect queue (seed wraps libc strdup).
// Do not export-extern libc strdup by name — conflicts with string.h after -E preamble.
// PLATFORM: SHARED — pure orch owns queue logic; free() still releases ownership.
export extern "C" function shux_collect_strdup(s: *u8): *u8;
// wave48 Cap residual: malloc/memset tmp arena+module, parse prep, enqueue sub-imports.
// PLATFORM: SHARED — parser slice / ParseIntoResult stay seed; pure process_one orch calls this.
export extern "C" function shux_collect_tmp_parse_and_enqueue(tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, prep: *u8, prep_len: i64, debug_path: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void;
// wave49 Cap residual: ensure tmp; resolve/read/preprocess path_c; parse+enqueue; free prep.
// PLATFORM: SHARED — FILE view / PATH_MAX / preprocess stay seed; pure paths_process_one orch.
export extern "C" function shux_collect_paths_tmp_resolve_parse_enqueue(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): i32;
export extern "C" function ast_module_free(mod: *u8): void;
export extern "C" function shu_lsp_ptr_slot_clear(arr: *u8, i: i32): void;
/* See implementation. */
export extern "C" function ast_pipeline_dep_ctx_reset(ctx: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void;
export extern "C" function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void;
export extern "C" function ast_pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void;
export extern "C" function pipeline_run_x_thread_fn_impl(arg: *u8): *u8;
export extern "C" function shux_asm_codegen_elf_o_thread_fn_impl(arg: *u8): *u8;

/* See implementation. */
export extern "C" function shux_fputs_stdout(s: *u8): void;
export extern "C" function shux_import_dep_dir_from_path_impl(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32;
/* wave45: do not export-extern pipeline_debug_trace_named_func_bodies here —
 * pure export function below is the single authority (#[no_mangle]).
 * A prior export extern + export function dual caused call sites to emit the
 * mangled name while the def stayed short → UNDEF under hybrid. */
/* See implementation. */
/* See implementation. */
/* See implementation. */
export extern "C" function driver_asm_fp_is_stdout(fp: *u8): i32;
export extern "C" function driver_asm_fflush_stdout(): void;
export extern "C" function driver_asm_fclose_file(fp: *u8): void;
/* See implementation. */
export extern "C" function shux_path_try_realpath_inplace(path: *u8, path_size: i64): void;
export extern "C" function pipeline_dep_ctx_path_bufs_reset(ctx: *u8): void;
export extern "C" function pipeline_dep_ctx_copy_entry_dir(ctx: *u8, entry_dir: *u8): void;
export extern "C" function ast_pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32;
/* See implementation. */
export extern "C" function shux_preprocess_raw_to_malloc_impl(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32, emit_diag: i32): i32;
export extern "C" function driver_dep_seed_slots_impl(arenas: *u8, modules: *u8, n: i32): void;
export extern "C" function shux_entry_lib_name_from_path_impl(input_path: *u8): *u8;
export extern "C" function shux_cstr_typeck_lit(): *u8;
export extern "C" function shux_entry_lib_keyword_lit(k: i32): *u8;
export extern "C" function pipeline_dep_arena_slot_set(i: i32, p: *u8): void;
export extern "C" function pipeline_dep_module_slot_set(i: i32, p: *u8): void;
export extern "C" function pipeline_dep_arena_slot_at(i: i32): *u8;
export extern "C" function pipeline_dep_module_slot_at(i: i32): *u8;
/* See implementation. */
export extern "C" function pipeline_asm_debug_enabled_impl(): i32;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
/* See implementation. */

/* See implementation. */
export extern "C" function pipeline_resolve_path_into_static(path_c: *u8): void;
/* See implementation. */
export extern "C" function pipeline_read_file_stage_prep(): i32;
export extern "C" function pipeline_read_file_commit_prep(): i32;
/* See implementation. */
export extern "C" function pipeline_loaded_import_data(): *u8;
export extern "C" function pipeline_loaded_import_len_get(): i64;
export extern "C" function pipeline_parse_into_bytes(arena: *u8, module: *u8, data: *u8, len: i64): i32;
export extern "C" function shux_pipeline_run_x_pipeline_large_stack_impl(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32;
export extern "C" function shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32;
export extern "C" function shux_pipeline_dep_prerun_parse_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32;
export extern "C" function shux_pipeline_dep_prerun_typeck_only_impl(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32;
/* See implementation. */
export extern "C" function access(path: *u8, mode: i32): i32;
export extern "C" function shux_cstr_offset(s: *u8, off: i32): *u8;
/* See implementation. */
export extern "C" function pipeline_entry_dir_copy(path: *u8): void;
export extern "C" function pipeline_entry_dir_set_dot(): void;
export extern "C" function pipeline_set_dep_slots_impl(arenas: *u8, modules: *u8): void;
/* See implementation. */
/* See implementation. */
/* See implementation. */
export extern "C" function pipeline_dep_ctx_set_use_asm_backend(ctx: *u8, v: i32): void;
export extern "C" function shux_pipeline_one_ctx_for_dep_prerun_map_impl(ctx: *u8, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void;
export extern "C" function shux_asm_codegen_elf_o_large_stack_impl(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32;
/* See implementation. */
/* wave46: shux_module_num_imports / import_path_cstr / ptr+size slots / i32_store
 * are pure export function below (not export-extern Cap residual). */
export extern "C" function shux_load_one_direct_import_at(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_key: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, mi: i32): i32;
export extern "C" function shux_load_direct_fail_cleanup(dep_sources: *u8, dep_paths: *u8, mi: i32): void;
// wave50: shux_collect_deps_transitive_impl / shux_collect_dep_paths_transitive_impl
// are pure export function below (not export-extern Cap residual).
export extern "C" function pipeline_debug_trace_named_func_bodies_impl(phase: *u8, module: *u8, arena: *u8): void;

/* See implementation. */

#[no_mangle]
export function parser_parse_into_init(module: *u8, arena: *u8): void {
}

/** Exported function `parser_get_module_num_imports`.
 * Implements `parser_get_module_num_imports`.
 * @param module *u8
 * @return i32
 */
#[no_mangle]
export function parser_get_module_num_imports(module: *u8): i32 {
  return 0;
}

/** Exported function `parser_get_module_import_path`.
 * Implements `parser_get_module_import_path`.
 * @param module *u8
 * @param idx i32
 * @param path_buf *u8
 * @return void
 */
#[no_mangle]
export function parser_get_module_import_path(module: *u8, idx: i32, path_buf: *u8): void {
  if (path_buf == 0 as *u8) {
    return;
  }
  unsafe {
    path_buf[0] = 0;
  }
}

/** Exported function `asm_skip_heavy_set_pipeline_ctx`.
 * Implements `asm_skip_heavy_set_pipeline_ctx`.
 * @param ctx *u8
 * @return void
 */
#[no_mangle]
export function asm_skip_heavy_set_pipeline_ctx(ctx: *u8): void {
}

/** Exported function `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * Implements `pipeline_fill_array_lit_types_for_skipped_typeck`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_fill_array_lit_types_for_skipped_typeck(m: *u8, a: *u8): void {
}

/** Exported function `pipeline_fill_soa_field_access_for_asm_emit`.
 * Implements `pipeline_fill_soa_field_access_for_asm_emit`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_fill_soa_field_access_for_asm_emit(m: *u8, a: *u8): void {
}

/** Exported function `pipeline_module_fixup_with_arena_stmt_orders`.
 * Implements `pipeline_module_fixup_with_arena_stmt_orders`.
 * @param m *u8
 * @param a *u8
 * @return void
 */
#[no_mangle]
export function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void {
}

/** Exported function `asm_asm_codegen_elf_o`.
 * Implements `asm_asm_codegen_elf_o`.
 * @param m *u8
 * @param a *u8
 * @param c *u8
 * @param e *u8
 * @param o *u8
 * @return i32
 */
#[no_mangle]
export function asm_asm_codegen_elf_o(m: *u8, a: *u8, c: *u8, e: *u8, o: *u8): i32 {
  return 0 - 1;
}

/** Exported function `pipeline_parse_set_main_from_buf_c`.
 * Implements `pipeline_parse_set_main_from_buf_c`.
 * @param m *u8
 * @param a *u8
 * @param d *u8
 * @param len i32
 * @return i32
 */
#[no_mangle]
export function pipeline_parse_set_main_from_buf_c(m: *u8, a: *u8, d: *u8, len: i32): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function pipeline_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

/** Exported function `pipeline_diag_emitted_note`.
 * Implements `pipeline_diag_emitted_note`.
 * @return void
 */
#[no_mangle]
export function pipeline_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

/** Exported function `pipeline_diag_emitted_get`.
 * Implements `pipeline_diag_emitted_get`.
 * @return i32
 */
#[no_mangle]
export function pipeline_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = pipeline_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `get_ndep`.
 * Query helper `get_ndep`.
 * @return i32
 */
#[no_mangle]
export function get_ndep(): i32 {
  unsafe {
    let p: *i32 = typeck_ndep_slot();
    let r: i32 = p[0];
    return r;
  }
  return 0;
}

/* ---- G-02f-34：set_ndep + dep_seeded get/set ---- */

// pipeline_set_ndep: see function docblock below.
/** Exported function `pipeline_set_ndep`.
 * Implements `pipeline_set_ndep`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function pipeline_set_ndep(n: i32): void {
  typeck_ndep_store(n);
}

/** Exported function `driver_dep_seeded_get`.
 * Implements `driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function driver_dep_seeded_get(i: i32): i32 {
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

/** Exported function `driver_dep_seeded_set`.
 * Implements `driver_dep_seeded_set`.
 * @param i i32
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_set(i: i32, v: i32): void {
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

/** Exported function `typeck_driver_dep_seeded_get`.
 * Implements `typeck_driver_dep_seeded_get`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function typeck_driver_dep_seeded_get(i: i32): i32 {
  return driver_dep_seeded_get(i);
}

/* See implementation. */

#[no_mangle]
export function get_dep_module(i: i32): *u8 {
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

/** Exported function `get_dep_arena`.
 * Query helper `get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function get_dep_arena(i: i32): *u8 {
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

/** Exported function `typeck_get_dep_module`.
 * Implements `typeck_get_dep_module`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_module(i: i32): *u8 {
  return get_dep_module(i);
}

/** Exported function `typeck_get_dep_arena`.
 * Implements `typeck_get_dep_arena`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_get_dep_arena(i: i32): *u8 {
  return get_dep_arena(i);
}

/** Exported function `pipeline_set_dep`.
 * Implements `pipeline_set_dep`.
 * @param i i32
 * @param mod *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_set_dep(i: i32, mod: *u8, arena: *u8): void {
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

/* See implementation. */

#[no_mangle]
export function driver_dep_publish_slot(i: i32, arena: *u8, module: *u8, import_path: *u8): void {
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
    /* See implementation. */
    driver_dep_path_registry_set(i, import_path);
  }
}

/** Exported function `typeck_driver_dep_module_buf`.
 * Implements `typeck_driver_dep_module_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_module_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_module_buf(i);
    return r;
  }
  return 0 as *u8;
}

/** Exported function `typeck_driver_dep_arena_buf`.
 * Implements `typeck_driver_dep_arena_buf`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function typeck_driver_dep_arena_buf(i: i32): *u8 {
  unsafe {
    let r: *u8 = driver_dep_arena_buf(i);
    return r;
  }
  return 0 as *u8;
}

/* See implementation. */

/* See implementation. */
#[no_mangle]
export function shux_cstr_ends_with_dot_x(s: *u8): i32 {
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

/* See implementation. */
#[no_mangle]
export function shux_asm_out_buf_is_object_magic(data: *u8): i32 {
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

/** Exported function `shux_import_path_is_file_path`.
 * Implements `shux_import_path_is_file_path`.
 * @param import_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_import_path_is_file_path(import_path: *u8): i32 {
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

/** Exported function `shux_asm_user_std_dep_skip_x_typeck`.
 * Implements `shux_asm_user_std_dep_skip_x_typeck`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_dep_skip_x_typeck(dep_path: *u8): i32 {
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

/** Exported function `shux_asm_user_std_net_dep_path`.
 * Implements `shux_asm_user_std_net_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_net_dep_path(dep_path: *u8): i32 {
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

/** Exported function `shux_asm_user_std_io_driver_dep_path`.
 * Implements `shux_asm_user_std_io_driver_dep_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_std_io_driver_dep_path(dep_path: *u8): i32 {
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

/** Exported function `shux_asm_user_dep_parse_skip_typeck_path`.
 * Implements `shux_asm_user_dep_parse_skip_typeck_path`.
 * @param dep_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_dep_parse_skip_typeck_path(dep_path: *u8): i32 {
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

/** Exported function `shux_asm_out_buf_is_object`.
 * Implements `shux_asm_out_buf_is_object`.
 * @param data *u8
 * @param len i64
 * @return i32
 */
#[no_mangle]
export function shux_asm_out_buf_is_object(data: *u8, len: i64): i32 {
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

/* See implementation. */

#[no_mangle]
export function shux_dep_prerun_entry_dir(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
  unsafe {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return shux_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}

/** Exported function `shux_find_loaded_import_index`.
 * Implements `shux_find_loaded_import_index`.
 * @param import_path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function shux_find_loaded_import_index(import_path: *u8, all_paths: *u8, n_all: i32): i32 {
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

/** Exported function `shux_merge_deps_path_already_out`.
 * Read path helper `shux_merge_deps_path_already_out`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_deps_path_already_out(path: *u8, out_paths: *u8, n_out: i32): i32 {
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

// shux_emit_pipeline_glue_include: see function docblock below.
/** Exported function `shux_emit_pipeline_glue_include`.
 * Implements `shux_emit_pipeline_glue_include`.
 * @return void
 */
#[no_mangle]
export function shux_emit_pipeline_glue_include(): void {
  // "\n#include \"pipeline_glue.c\"\n"
  let s: u8[32] = [];
  s[0]=10;s[1]=35;s[2]=105;s[3]=110;s[4]=99;s[5]=108;s[6]=117;s[7]=100;
  s[8]=101;s[9]=32;s[10]=34;s[11]=112;s[12]=105;s[13]=112;s[14]=101;s[15]=108;
  s[16]=105;s[17]=110;s[18]=101;s[19]=95;s[20]=103;s[21]=108;s[22]=117;s[23]=101;
  s[24]=46;s[25]=99;s[26]=34;s[27]=10;s[28]=0;
  unsafe {
    shux_fputs_stdout(&s[0]);
  }
}

// shux_import_dep_dir_from_path: see function docblock below.
/** Exported function `shux_import_dep_dir_from_path`.
 * Implements `shux_import_dep_dir_from_path`.
 * @param path *u8
 * @param dep_dir *u8
 * @param dep_dir_size i64
 * @return i32
 */
#[no_mangle]
export function shux_import_dep_dir_from_path(path: *u8, dep_dir: *u8, dep_dir_size: i64): i32 {
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

/* See implementation. */

#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_reset`.
 * Implements `pipeline_debug_trace_body_x_mega_post_reset`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_reset(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_params`.
 * Implements `pipeline_debug_trace_body_x_mega_post_params`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_params(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_frame`.
 * Implements `pipeline_debug_trace_body_x_mega_post_frame`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_frame(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_post_locals`.
 * Implements `pipeline_debug_trace_body_x_mega_post_locals`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_post_locals(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}

/** Exported function `pipeline_debug_trace_body_x_mega_pre_emit`.
 * Implements `pipeline_debug_trace_body_x_mega_pre_emit`.
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_body_x_mega_pre_emit(module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}

// driver_typeck_dep_sidecar_clear: see function docblock below.
/** Exported function `driver_typeck_dep_sidecar_clear`.
 * Implements `driver_typeck_dep_sidecar_clear`.
 * @return void
 */
#[no_mangle]
export function driver_typeck_dep_sidecar_clear(): void {
  typeck_ndep_store(0);
  let i: i32 = 0;
  while (i < 32) {
    typeck_dep_module_set(i, 0 as *u8);
    typeck_dep_arena_set(i, 0 as *u8);
    i = i + 1;
  }
}

// driver_dep_seeded_clear_slots: see function docblock below.
/** Exported function `driver_dep_seeded_clear_slots`.
 * Implements `driver_dep_seeded_clear_slots`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_slots(): void {
  let i: i32 = 0;
  while (i < 32) {
    driver_dep_seeded_set(i, 0);
    unsafe {
      driver_dep_path_registry_set(i, 0 as *u8);
      driver_dep_arena_ptr_set(i, 0 as *u8);
      driver_dep_module_ptr_set(i, 0 as *u8);
    }
    i = i + 1;
  }
}

// driver_dep_seeded_clear_all: see function docblock below.
/** Exported function `driver_dep_seeded_clear_all`.
 * Implements `driver_dep_seeded_clear_all`.
 * @return void
 */
#[no_mangle]
export function driver_dep_seeded_clear_all(): void {
  driver_dep_seeded_clear_slots();
  driver_typeck_dep_sidecar_clear();
}

// shux_get_entry_dir: see function docblock below.
/** Exported function `shux_get_entry_dir`.
 * Implements `shux_get_entry_dir`.
 * @param input_path *u8
 * @param entry_dir *u8
 * @param size i64
 * @return void
 */
#[no_mangle]
export function shux_get_entry_dir(input_path: *u8, entry_dir: *u8, size: i64): void {
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
    let last: i32 = 0 - 1;
    let i: i32 = 0;
    while (i < 65536) {
      if (input_path[i] == 0) {
        break;
      }
      if (input_path[i] == 47) {
        last = i;
      }
      i = i + 1;
    }
    if (last < 0) {
      if (size >= 2) {
        entry_dir[0] = 46;
        entry_dir[1] = 0;
      } else {
        entry_dir[0] = 0;
      }
      return;
    }
    let len: i32 = last;
    let cap: i32 = size as i32;
    if (cap <= 0) {
      return;
    }
    if (len >= cap) {
      len = cap - 1;
    }
    let k: i32 = 0;
    while (k < len) {
      entry_dir[k] = input_path[k];
      k = k + 1;
    }
    entry_dir[len] = 0;
  }
}

// driver_asm_fclose_asm_out: see function docblock below.
/** Exported function `driver_asm_fclose_asm_out`.
 * Implements `driver_asm_fclose_asm_out`.
 * @param fp *u8
 * @return void
 */
#[no_mangle]
export function driver_asm_fclose_asm_out(fp: *u8): void {
  unsafe {
    if (fp == 0 as *u8) {
      driver_asm_fflush_stdout();
      return;
    }
    if (driver_asm_fp_is_stdout(fp) != 0) {
      driver_asm_fflush_stdout();
      return;
    }
    driver_asm_fclose_file(fp);
  }
}

/* See implementation. */

// G-02f-229：lib_root + import（'.'→'/'）+ ".x"
/** Exported function `shux_import_path_to_file_path`.
 * Implements `shux_import_path_to_file_path`.
 * @param lib_root *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function shux_import_path_to_file_path(lib_root: *u8, import_path: *u8, path: *u8, path_size: i64): void {
  if (path == 0 as *u8) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  unsafe {
    let cap: i32 = path_size as i32;
    if (cap <= 0) {
      return;
    }
    let r: *u8 = lib_root;
    if (r == 0 as *u8) {
      // "."
      r = 0 as *u8;
    } else {
      if (r[0] == 0) {
        r = 0 as *u8;
      }
    }
    let off: i32 = 0;
    if (r == 0 as *u8) {
      if (off + 1 < cap) {
        path[off] = 46;
        off = off + 1;
      }
    } else {
      let ri: i32 = 0;
      while (ri < 4096) {
        if (r[ri] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        path[off] = r[ri];
        off = off + 1;
        ri = ri + 1;
      }
    }
    if (off + 1 < cap) {
      path[off] = 47;
      off = off + 1;
    }
    if (import_path != 0 as *u8) {
      let s: i32 = 0;
      while (s < 4096) {
        if (import_path[s] == 0) {
          break;
        }
        if (off + 1 >= cap) {
          break;
        }
        let ch: u8 = import_path[s];
        if (ch == 46) {
          path[off] = 47;
        } else {
          path[off] = ch;
        }
        off = off + 1;
        s = s + 1;
      }
    }
    // ".x"
    if (off + 2 < cap) {
      path[off] = 46;
      path[off + 1] = 120;
      path[off + 2] = 0;
    } else {
      if (off < cap) {
        path[off] = 0;
      } else {
        if (cap > 0) {
          path[cap - 1] = 0;
        }
      }
    }
  }
}

// pipe_cstr_join_slash: see function docblock below.
/** Exported function `pipe_cstr_join_slash`.
 * Implements `pipe_cstr_join_slash`.
 * @param dst *u8
 * @param cap i32
 * @param a *u8
 * @param b *u8
 * @return void
 */
export function pipe_cstr_join_slash(dst: *u8, cap: i32, a: *u8, b: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (a != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (a[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = a[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) {
      dst[off] = 47;
      off = off + 1;
    }
    if (b != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (b[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = b[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

// shux_resolve_file_import_path: see function docblock below.
/** Exported function `shux_resolve_file_import_path`.
 * Implements `shux_resolve_file_import_path`.
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function shux_resolve_file_import_path(entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
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
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  unsafe {
    // absolute
    if (import_path[0] == 47) {
      pipe_cstr_copy(path, cap, import_path);
    } else {
      if (entry_dir != 0 as *u8) {
        if (entry_dir[0] != 0) {
          pipe_cstr_join_slash(path, cap, entry_dir, import_path);
        } else {
          pipe_cstr_copy(path, cap, import_path);
        }
      } else {
        pipe_cstr_copy(path, cap, import_path);
      }
    }
    shux_path_try_realpath_inplace(path, path_size);
  }
}

// driver_dep_slot_for_path_scan: see function docblock below.
/** Exported function `driver_dep_slot_for_path_scan`.
 * Implements `driver_dep_slot_for_path_scan`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path_scan(path: *u8): i32 {
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

/** Exported function `driver_dep_slot_for_path`.
 * Implements `driver_dep_slot_for_path`.
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function driver_dep_slot_for_path(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  return driver_dep_slot_for_path_scan(path);
}

/* See implementation. */

// shux_preprocess_raw_to_malloc: see function docblock below.
/** Exported function `shux_preprocess_raw_to_malloc`.
 * Memory management helper `shux_preprocess_raw_to_malloc`.
 * @param raw *u8
 * @param raw_len i64
 * @param out_src *u8
 * @param out_src_len *u8
 * @param path_diag *u8
 * @param defines *u8
 * @param ndefines i32
 * @return i32
 */
#[no_mangle]
export function shux_preprocess_raw_to_malloc(raw: *u8, raw_len: i64, out_src: *u8, out_src_len: *u8, path_diag: *u8, defines: *u8, ndefines: i32): i32 {
  if (raw_len < 0) {
    return 0 - 1;
  }
  if (raw == 0 as *u8) {
    if (raw_len > 0) {
      return 0 - 1;
    }
  }
  if (ndefines < 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return 0 - 1;
}

// driver_dep_seed_slots: see function docblock below.
/** Exported function `driver_dep_seed_slots`.
 * Implements `driver_dep_seed_slots`.
 * @param arenas *u8
 * @param modules *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function driver_dep_seed_slots(arenas: *u8, modules: *u8, n: i32): void {
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

// pipe_cstr_contains: see function docblock below.
/** Exported function `pipe_cstr_contains`.
 * Implements `pipe_cstr_contains`.
 * @param hay *u8
 * @param needle *u8
 * @return i32
 */
export function pipe_cstr_contains(hay: *u8, needle: *u8): i32 {
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

// shux_entry_lib_name_from_path: see function docblock below.
/** Exported function `shux_entry_lib_name_from_path`.
 * Implements `shux_entry_lib_name_from_path`.
 * @param input_path *u8
 * @return *u8
 */
#[no_mangle]
export function shux_entry_lib_name_from_path(input_path: *u8): *u8 {
  if (input_path == 0 as *u8) {
    unsafe {
      return shux_cstr_typeck_lit();
    }
    return 0 as *u8;
  }
  unsafe {
    // See implementation.
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

/* See implementation. */

#[no_mangle]
export function pipeline_get_dep_arena_slot(i: i32): *u8 {
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

/** Exported function `pipeline_get_dep_module_slot`.
 * Implements `pipeline_get_dep_module_slot`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function pipeline_get_dep_module_slot(i: i32): *u8 {
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

// See implementation.
let g_import_open_valid: i32 = 0;
let g_import_open_import: u8[65] = [];
let g_import_open_resolved: u8[512] = [];

/** Exported function `pipe_cstr_copy`.
 * Implements `pipe_cstr_copy`.
 * @param dst *u8
 * @param cap i32
 * @param src *u8
 * @return void
 */
export function pipe_cstr_copy(dst: *u8, cap: i32, src: *u8): void {
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

/** Exported function `pipeline_diag_import_open_fail_once`.
 * Implements `pipeline_diag_import_open_fail_once`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_open_fail_once(import_path: *u8, resolved_path: *u8): void {
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

// pipeline_resolve_path: see function docblock below.
/** Exported function `pipeline_resolve_path`.
 * Implements `pipeline_resolve_path`.
 * @param path_ptr *u8
 * @param path_len i32
 * @return i32
 */
#[no_mangle]
export function pipeline_resolve_path(path_ptr: *u8, path_len: i32): i32 {
  if (path_ptr == 0 as *u8) {
    return 0 - 1;
  }
  let plen: i32 = path_len;
  if (plen <= 0) {
    plen = 64;
  }
  if (plen > 64) {
    plen = 64;
  }
  let path_c: u8[65] = [];
  let k: i32 = 0;
  unsafe {
    while (k < plen) {
      if (path_ptr[k] == 0) {
        break;
      }
      path_c[k] = path_ptr[k];
      k = k + 1;
    }
    path_c[k] = 0;
    pipeline_resolve_path_into_static(&path_c[0]);
  }
  return 0;
}

// pipeline_read_file: see function docblock below.
/** Exported function `pipeline_read_file`.
 * Read path helper `pipeline_read_file`.
 * @return i32
 */
#[no_mangle]
export function pipeline_read_file(): i32 {
  unsafe {
    if (pipeline_read_file_stage_prep() != 0) {
      return 0 - 1;
    }
    if (pipeline_read_file_commit_prep() != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

// pipeline_parse_into_loaded_import: see function docblock below.
/** Exported function `pipeline_parse_into_loaded_import`.
 * Implements `pipeline_parse_into_loaded_import`.
 * @param arena *u8
 * @param module *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_parse_into_loaded_import(arena: *u8, module: *u8): i32 {
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    let data: *u8 = pipeline_loaded_import_data();
    if (data == 0 as *u8) {
      return 0 - 1;
    }
    let len: i64 = pipeline_loaded_import_len_get();
    return pipeline_parse_into_bytes(arena, module, data, len);
  }
  return 0 - 1;
}

/* See implementation. */

// shux_pipeline_run_x_pipeline_large_stack: see function docblock below.
/** Exported function `shux_pipeline_run_x_pipeline_large_stack`.
 * Implements `shux_pipeline_run_x_pipeline_large_stack`.
 * @param module *u8
 * @param arena *u8
 * @param source_data *u8
 * @param source_len i64
 * @param out_buf *u8
 * @param ctx *u8
 * @return i32
 */
#[no_mangle]
export function shux_pipeline_run_x_pipeline_large_stack(module: *u8, arena: *u8, source_data: *u8, source_len: i64, out_buf: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (source_data == 0 as *u8) {
    return 0 - 1;
  }
  if (source_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
  }
  return 0 - 1;
}

/* See implementation. */

// shux_pipeline_dep_prerun_parse_skip_typeck: see function docblock below.
/** Exported function `shux_pipeline_dep_prerun_parse_skip_typeck`.
 * Implements `shux_pipeline_dep_prerun_parse_skip_typeck`.
 * @param dep_mod *u8
 * @param dep_arena *u8
 * @param src *u8
 * @param len i64
 * @param dep_out *u8
 * @param one_ctx *u8
 * @return i32
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_skip_typeck(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

/** Exported function `shux_pipeline_dep_prerun_parse_only`.
 * Implements `shux_pipeline_dep_prerun_parse_only`.
 * @param dep_mod *u8
 * @param dep_arena *u8
 * @param src *u8
 * @param len i64
 * @return i32
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_parse_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return 0 - 1;
}

/* ---- G-02f-59 / G-02f-239：dep prerun typeck ---- */

#[no_mangle]
export function shux_pipeline_dep_prerun_typeck_only(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  if (dep_mod == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_arena == 0 as *u8) {
    return 0 - 1;
  }
  if (src == 0 as *u8) {
    return 0 - 1;
  }
  if (len <= 0) {
    return 0 - 1;
  }
  if (one_ctx == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return 0 - 1;
}

// shux_pipeline_dep_prerun_for_asm_module_o: see function docblock below.
/** Exported function `shux_pipeline_dep_prerun_for_asm_module_o`.
 * Implements `shux_pipeline_dep_prerun_for_asm_module_o`.
 * @param dep_mod *u8
 * @param dep_arena *u8
 * @param src *u8
 * @param len i64
 * @param dep_out *u8
 * @param one_ctx *u8
 * @return i32
 */
#[no_mangle]
export function shux_pipeline_dep_prerun_for_asm_module_o(dep_mod: *u8, dep_arena: *u8, src: *u8, len: i64, dep_out: *u8, one_ctx: *u8): i32 {
  return shux_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}

// pipe_path_readable: see function docblock below.
/** Exported function `pipe_path_readable`.
 * Read path helper `pipe_path_readable`.
 * @param path *u8
 * @return i32
 */
export function pipe_path_readable(path: *u8): i32 {
  if (path == 0 as *u8) { return 0; }
  unsafe {
    if (access(path, 4) == 0) { return 1; }
  }
  return 0;
}

/** Exported function `pipe_cstr_has_char`.
 * Implements `pipe_cstr_has_char`.
 * @param s *u8
 * @param ch u8
 * @return i32
 */
export function pipe_cstr_has_char(s: *u8, ch: u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    if (s[i] == 0) { return 0; }
    if (s[i] == ch) { return 1; }
    i = i + 1;
  }
  return 0;
}

// pipe_write_nested_name_x: see function docblock below.
/** Exported function `pipe_write_nested_name_x`.
 * Write path helper `pipe_write_nested_name_x`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param name *u8
 * @return void
 */
export function pipe_write_nested_name_x(dst: *u8, cap: i32, root: *u8, name: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (name[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[j];
        off = off + 1;
        j = j + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (name != 0 as *u8) {
      let k: i32 = 0;
      while (k < 4096) {
        if (name[k] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = name[k];
        off = off + 1;
        k = k + 1;
      }
    }
    if (off + 2 < cap) {
      dst[off] = 46; dst[off + 1] = 120; dst[off + 2] = 0;
    } else if (off < cap) {
      dst[off] = 0;
    } else {
      dst[cap - 1] = 0;
    }
  }
}

// pipe_write_root_dotted_imp: see function docblock below.
/** Exported function `pipe_write_root_dotted_imp`.
 * Write path helper `pipe_write_root_dotted_imp`.
 * @param dst *u8
 * @param cap i32
 * @param root *u8
 * @param imp *u8
 * @return i32
 */
export function pipe_write_root_dotted_imp(dst: *u8, cap: i32, root: *u8, imp: *u8): i32 {
  if (dst == 0 as *u8) { return 0; }
  if (cap <= 0) { return 0; }
  let off: i32 = 0;
  unsafe {
    if (root != 0 as *u8) {
      let i: i32 = 0;
      while (i < 4096) {
        if (root[i] == 0) { break; }
        if (off + 1 >= cap) { break; }
        dst[off] = root[i];
        off = off + 1;
        i = i + 1;
      }
    }
    if (off + 1 < cap) { dst[off] = 47; off = off + 1; }
    if (imp != 0 as *u8) {
      let j: i32 = 0;
      while (j < 4096) {
        if (imp[j] == 0) { break; }
        if (off + 1 >= cap) { break; }
        let ch: u8 = imp[j];
        if (ch == 46) { dst[off] = 47; } else { dst[off] = ch; }
        off = off + 1;
        j = j + 1;
      }
    }
    if (off < cap) { dst[off] = 0; } else { dst[cap - 1] = 0; }
  }
  return off;
}

/** Exported function `pipe_append_suffix`.
 * Implements `pipe_append_suffix`.
 * @param dst *u8
 * @param cap i32
 * @param off i32
 * @param suf *u8
 * @return void
 */
export function pipe_append_suffix(dst: *u8, cap: i32, off: i32, suf: *u8): void {
  if (dst == 0 as *u8) { return; }
  if (suf == 0 as *u8) { return; }
  if (cap <= 0) { return; }
  let o: i32 = off;
  let si: i32 = 0;
  unsafe {
    while (si < 16) {
      if (suf[si] == 0) { break; }
      if (o + 1 >= cap) { break; }
      dst[o] = suf[si];
      o = o + 1;
      si = si + 1;
    }
    if (o < cap) { dst[o] = 0; } else { dst[cap - 1] = 0; }
  }
}

// pipe_dir_tail: see function docblock below.
/** Exported function `pipe_dir_tail`.
 * Implements `pipe_dir_tail`.
 * @param entry_dir *u8
 * @return *u8
 */
export function pipe_dir_tail(entry_dir: *u8): *u8 {
  if (entry_dir == 0 as *u8) { return 0 as *u8; }
  let last: i32 = 0 - 1;
  let i: i32 = 0;
  unsafe {
    while (i < 4096) {
      if (entry_dir[i] == 0) { break; }
      if (entry_dir[i] == 47) { last = i; }
      i = i + 1;
    }
    if (last < 0) { return entry_dir; }
    return shux_cstr_offset(entry_dir, last + 1);
  }
  return entry_dir;
}

// pipe_strip_prefix_seg: see function docblock below.
/** Exported function `pipe_strip_prefix_seg`.
 * Implements `pipe_strip_prefix_seg`.
 * @param import_path *u8
 * @param dir_tail *u8
 * @return *u8
 */
export function pipe_strip_prefix_seg(import_path: *u8, dir_tail: *u8): *u8 {
  if (import_path == 0 as *u8) { return import_path; }
  if (dir_tail == 0 as *u8) { return import_path; }
  unsafe {
    let tl: i32 = pipe_cstr_len(dir_tail);
    let i: i32 = 0;
    while (i < tl) {
      if (import_path[i] == 0) { return import_path; }
      if (import_path[i] != dir_tail[i]) { return import_path; }
      i = i + 1;
    }
    if (import_path[tl] == 46) {
      return shux_cstr_offset(import_path, tl + 1);
    }
  }
  return import_path;
}

// shux_resolve_import_file_path_multi: see function docblock below.
/** Exported function `shux_resolve_import_file_path_multi`.
 * Implements `shux_resolve_import_file_path_multi`.
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param import_path *u8
 * @param path *u8
 * @param path_size i64
 * @return void
 */
#[no_mangle]
export function shux_resolve_import_file_path_multi(lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, import_path: *u8, path: *u8, path_size: i64): void {
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
  let cap: i32 = path_size as i32;
  if (cap <= 0) {
    return;
  }
  // See implementation.
  if (shux_import_path_is_file_path(import_path) != 0) {
    shux_resolve_file_import_path(entry_dir, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    unsafe {
      if (import_path[0] != 47) {
        pipe_cstr_copy(path, cap, import_path);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
  }
  // -L roots
  let r: i32 = 0;
  while (r < n_lib_roots) {
    let lib_root: *u8 = 0 as *u8;
    unsafe {
      if (lib_roots != 0 as *u8) {
        lib_root = pipe_load_ptr_slot(lib_roots, r);
      }
    }
    let use_root: *u8 = lib_root;
    let dot: u8[2] = [];
    dot[0] = 46;
    dot[1] = 0;
    if (use_root == 0 as *u8) {
      use_root = &dot[0];
    } else {
      unsafe {
        if (use_root[0] == 0) { use_root = &dot[0]; }
      }
    }
    shux_import_path_to_file_path(use_root, import_path, path, path_size);
    if (pipe_path_readable(path) != 0) { return; }
    // See implementation.
    if (pipe_cstr_has_char(import_path, 46) == 0) {
      if (path_size >= 16) {
        let n: i32 = pipe_cstr_len(import_path);
        if (n > 0) {
          if (n < 64) {
            pipe_write_nested_name_x(path, cap, use_root, import_path);
            if (pipe_path_readable(path) != 0) { return; }
          }
        }
      }
    } else {
      if (path_size >= 16) {
        let off: i32 = pipe_write_root_dotted_imp(path, cap, use_root, import_path);
        let modx: u8[8] = [];
        modx[0] = 47; modx[1] = 109; modx[2] = 111; modx[3] = 100; modx[4] = 46; modx[5] = 120; modx[6] = 0;
        if (off + 8 <= cap) {
          pipe_append_suffix(path, cap, off, &modx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        }
        shux_import_path_to_file_path(use_root, import_path, path, path_size);
        if (pipe_path_readable(path) != 0) { return; }
      }
    }
    r = r + 1;
  }
  // See implementation.
  if (entry_dir != 0 as *u8) {
    unsafe {
      if (entry_dir[0] != 0) {
        if (pipe_cstr_has_char(import_path, 46) == 0) {
          let off2: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, import_path);
          // pipe_write already did entry/import with dots; for no-dot it's entry/import
          // need entry/import.x
          let dx: u8[4] = [];
          dx[0] = 46; dx[1] = 120; dx[2] = 0;
          pipe_append_suffix(path, cap, off2, &dx[0]);
          if (pipe_path_readable(path) != 0) { return; }
        } else {
          if (path_size >= 16) {
            let tail: *u8 = pipe_dir_tail(entry_dir);
            let eff: *u8 = pipe_strip_prefix_seg(import_path, tail);
            let off3: i32 = pipe_write_root_dotted_imp(path, cap, entry_dir, eff);
            let dx2: u8[4] = [];
            dx2[0] = 46; dx2[1] = 120; dx2[2] = 0;
            if (off3 + 3 <= cap) {
              pipe_append_suffix(path, cap, off3, &dx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
            let modx2: u8[8] = [];
            modx2[0] = 47; modx2[1] = 109; modx2[2] = 111; modx2[3] = 100;
            modx2[4] = 46; modx2[5] = 120; modx2[6] = 0;
            if (off3 + 8 <= cap) {
              pipe_append_suffix(path, cap, off3, &modx2[0]);
              if (pipe_path_readable(path) != 0) { return; }
            }
          }
        }
      }
    }
  }
}

/* See implementation. */

// pipeline_set_entry_dir: see function docblock below.
/** Exported function `pipeline_set_entry_dir`.
 * Implements `pipeline_set_entry_dir`.
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_set_entry_dir(path: *u8): void {
  unsafe {
    if (path == 0 as *u8) {
      pipeline_entry_dir_set_dot();
      return;
    }
    if (path[0] == 0) {
      pipeline_entry_dir_set_dot();
      return;
    }
    pipeline_entry_dir_copy(path);
  }
}

// pipeline_set_dep_slots: see function docblock below.
/** Exported function `pipeline_set_dep_slots`.
 * Implements `pipeline_set_dep_slots`.
 * @param arenas *u8
 * @param modules *u8
 * @return void
 */
#[no_mangle]
export function pipeline_set_dep_slots(arenas: *u8, modules: *u8): void {
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

// shux_pipeline_fill_ctx_path_buffers: see function docblock below.
/** Exported function `shux_pipeline_fill_ctx_path_buffers`.
 * Implements `shux_pipeline_fill_ctx_path_buffers`.
 * @param ctx *u8
 * @param entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_fill_ctx_path_buffers(ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  unsafe {
    pipeline_dep_ctx_path_bufs_reset(ctx);
    if (entry_dir != 0 as *u8) {
      pipeline_dep_ctx_copy_entry_dir(ctx, entry_dir);
    }
  }
  if (lib_roots == 0 as *u8) {
    return;
  }
  if (n_lib_roots <= 0) {
    return;
  }
  let i: i32 = 0;
  while (i < n_lib_roots) {
    unsafe {
      let p: *u8 = pipe_load_ptr_slot(lib_roots, i);
      if (p != 0 as *u8) {
        let ll: i32 = pipe_cstr_len(p);
        if (ll > 255) {
          ll = 255;
        }
        if (ll > 0) {
          let _r: i32 = ast_pipeline_ctx_append_lib_root(ctx, p, ll);
        }
      }
    }
    i = i + 1;
  }
}

// pipe_cstr_len: see function docblock below.
/** Exported function `pipe_cstr_len`.
 * Query helper `pipe_cstr_len`.
 * @param s *u8
 * @return i32
 */
export function pipe_cstr_len(s: *u8): i32 {
  if (s == 0 as *u8) { return 0; }
  let i: i32 = 0;
  while (i < 65536) {
    if (s[i] == 0) { return i; }
    i = i + 1;
  }
  return i;
}

// shux_pipeline_pctx_seed_dep_slots: see function docblock below.
/** Exported function `shux_pipeline_pctx_seed_dep_slots`.
 * Implements `shux_pipeline_pctx_seed_dep_slots`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ar *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_seed_dep_slots(ctx: *u8, dep_mods: *u8, dep_ar: *u8, import_paths: *u8, n: i32): void {
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

// shux_pipeline_pctx_seed_dep_import_paths_only: see function docblock below.
/** Exported function `shux_pipeline_pctx_seed_dep_import_paths_only`.
 * Implements `shux_pipeline_pctx_seed_dep_import_paths_only`.
 * @param ctx *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_seed_dep_import_paths_only(ctx: *u8, import_paths: *u8, n: i32): void {
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

// shux_pipeline_one_ctx_for_dep_prerun: see function docblock below.
/** Exported function `shux_pipeline_one_ctx_for_dep_prerun`.
 * Implements `shux_pipeline_one_ctx_for_dep_prerun`.
 * @param ctx *u8
 * @param j i32
 * @param dep_mods *u8
 * @param dep_ars *u8
 * @param dep_paths *u8
 * @param ndep i32
 * @param dep_src *u8
 * @param dep_src_len i64
 * @return void
 */
#[no_mangle]
export function shux_pipeline_one_ctx_for_dep_prerun(ctx: *u8, j: i32, dep_mods: *u8, dep_ars: *u8, dep_paths: *u8, ndep: i32, dep_src: *u8, dep_src_len: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  // See implementation.
  let _j: i32 = j;
  unsafe {
    pipeline_dep_ctx_set_use_asm_backend(ctx, 0);
  }
  if (dep_mods == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_ars == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_paths == 0 as *u8) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (ndep <= 0) {
    unsafe { ast_pipeline_dep_ctx_set_ndep(ctx, 0); }
    return;
  }
  if (dep_src == 0 as *u8) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  if (dep_src_len <= 0) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  // INT32_MAX
  let imax: i64 = 2147483647;
  if (dep_src_len > imax) {
    shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
    return;
  }
  unsafe {
    shux_pipeline_one_ctx_for_dep_prerun_map_impl(ctx, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}

/* See implementation. */

// shux_driver_asm_prepare_entry_elf_emit: see function docblock below.
/** Exported function `shux_driver_asm_prepare_entry_elf_emit`.
 * Implements `shux_driver_asm_prepare_entry_elf_emit`.
 * @param module *u8
 * @param arena *u8
 * @param pctx *u8
 * @return void
 */
#[no_mangle]
export function shux_driver_asm_prepare_entry_elf_emit(module: *u8, arena: *u8, pctx: *u8): void {
  if (module == 0 as *u8) {
    return;
  }
  if (arena == 0 as *u8) {
    return;
  }
  unsafe {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}

// shux_asm_codegen_elf_o_large_stack: see function docblock below.
/** Exported function `shux_asm_codegen_elf_o_large_stack`.
 * Implements `shux_asm_codegen_elf_o_large_stack`.
 * @param module *u8
 * @param arena *u8
 * @param ctx *u8
 * @param elf_ctx *u8
 * @param out_buf *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_large_stack(module: *u8, arena: *u8, ctx: *u8, elf_ctx: *u8, out_buf: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (arena == 0 as *u8) {
    return 0 - 1;
  }
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
  }
  return 0 - 1;
}

// shux_load_direct_imports_for_asm_layout: see function docblock below.
/** Exported function `shux_load_direct_imports_for_asm_layout`.
 * Implements `shux_load_direct_imports_for_asm_layout`.
 * @param module *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_sources *u8
 * @param dep_lens *u8
 * @param dep_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function shux_load_direct_imports_for_asm_layout(module: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  unsafe {
    shux_i32_store(out_n, 0);
  }
  let n_imports: i32 = 0;
  unsafe {
    n_imports = shux_module_num_imports(module);
  }
  if (n_imports <= 0) {
    return 0;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let rc: i32 = 0;
    unsafe {
      rc = shux_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, &path_c[0], defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
    }
    if (rc != 0) {
      unsafe {
        shux_load_direct_fail_cleanup(dep_sources, dep_paths, mi);
        shux_i32_store(out_n, 0);
      }
      return 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

// shux_merge_direct_then_transitive_dep_paths: see function docblock below.
/** Exported function `shux_merge_direct_then_transitive_dep_paths`.
 * Implements `shux_merge_direct_then_transitive_dep_paths`.
 * @param module *u8
 * @param n_imports i32
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_direct_then_transitive_dep_paths(module: *u8, n_imports: i32, cpaths: *u8, n_closure: i32, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = pipe_load_ptr_slot(cpaths, found);
      shux_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (shux_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              shux_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            shux_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

/* See implementation. */

// shux_merge_direct_then_transitive_deps: see function docblock below.
/** Exported function `shux_merge_direct_then_transitive_deps`.
 * Implements `shux_merge_direct_then_transitive_deps`.
 * @param module *u8
 * @param n_imports i32
 * @param cls *u8
 * @param clens *u8
 * @param cpaths *u8
 * @param n_closure i32
 * @param out_src *u8
 * @param out_lens *u8
 * @param out_paths *u8
 * @param out_n *i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_direct_then_transitive_deps(module: *u8, n_imports: i32, cls: *u8, clens: *u8, cpaths: *u8, n_closure: i32, out_src: *u8, out_lens: *u8, out_paths: *u8, out_n: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (out_n == 0 as *i32) {
    return 0 - 1;
  }
  if (out_paths == 0 as *u8) {
    return 0 - 1;
  }
  let used: u8[32] = [];
  let ui: i32 = 0;
  while (ui < 32) {
    used[ui] = 0;
    ui = ui + 1;
  }
  let mi: i32 = 0;
  let i: i32 = 0;
  while (i < n_imports) {
    if (i >= 32) { break; }
    if (mi >= 32) { break; }
    let path_c: u8[65] = [];
    unsafe {
      shux_module_import_path_cstr(module, i, &path_c[0], 65);
    }
    let found: i32 = 0 - 1;
    let kk: i32 = 0;
    while (kk < n_closure) {
      unsafe {
        let cp: *u8 = 0 as *u8;
        if (cpaths != 0 as *u8) {
          cp = pipe_load_ptr_slot(cpaths, kk);
        }
        if (cp != 0 as *u8) {
          if (pipe_cstr_eq(cp, &path_c[0]) != 0) {
            found = kk;
          }
        }
      }
      if (found >= 0) { break; }
      kk = kk + 1;
    }
    if (found < 0) {
      pipeline_diag_merge_dep_missing(&path_c[0]);
      return 1;
    }
    unsafe {
      let pfound: *u8 = 0 as *u8;
      let sfound: *u8 = 0 as *u8;
      let lfound: i64 = 0;
      if (cpaths != 0 as *u8) {
        pfound = pipe_load_ptr_slot(cpaths, found);
      }
      if (cls != 0 as *u8) {
        sfound = pipe_load_ptr_slot(cls, found);
      }
      if (clens != 0 as *u8) {
        lfound = shux_size_slot_get(clens, found);
      }
      if (out_src != 0 as *u8) {
        shux_ptr_slot_set(out_src, mi, sfound);
      }
      if (out_lens != 0 as *u8) {
        shux_size_slot_set(out_lens, mi, lfound);
      }
      shux_ptr_slot_set(out_paths, mi, pfound);
    }
    if (found < 32) {
      used[found] = 1;
    }
    mi = mi + 1;
    i = i + 1;
  }
  let kj: i32 = 0;
  while (kj < n_closure) {
    if (mi >= 32) { break; }
    if (kj < 32) {
      if (used[kj] == 0) {
        unsafe {
          let cp2: *u8 = 0 as *u8;
          if (cpaths != 0 as *u8) {
            cp2 = pipe_load_ptr_slot(cpaths, kj);
          }
          if (cp2 != 0 as *u8) {
            if (shux_merge_deps_path_already_out(cp2, out_paths, mi) != 0) {
              used[kj] = 1;
            } else {
              let s2: *u8 = 0 as *u8;
              let l2: i64 = 0;
              if (cls != 0 as *u8) {
                s2 = pipe_load_ptr_slot(cls, kj);
              }
              if (clens != 0 as *u8) {
                l2 = shux_size_slot_get(clens, kj);
              }
              if (out_src != 0 as *u8) {
                shux_ptr_slot_set(out_src, mi, s2);
              }
              if (out_lens != 0 as *u8) {
                shux_size_slot_set(out_lens, mi, l2);
              }
              shux_ptr_slot_set(out_paths, mi, cp2);
              mi = mi + 1;
            }
          } else {
            let s3: *u8 = 0 as *u8;
            let l3: i64 = 0;
            if (cls != 0 as *u8) {
              s3 = pipe_load_ptr_slot(cls, kj);
            }
            if (clens != 0 as *u8) {
              l3 = shux_size_slot_get(clens, kj);
            }
            if (out_src != 0 as *u8) {
              shux_ptr_slot_set(out_src, mi, s3);
            }
            if (out_lens != 0 as *u8) {
              shux_size_slot_set(out_lens, mi, l3);
            }
            shux_ptr_slot_set(out_paths, mi, cp2);
            mi = mi + 1;
          }
        }
      }
    }
    kj = kj + 1;
  }
  unsafe {
    shux_i32_store(out_n, mi);
  }
  return 0;
}

// shux_collect_deps_transitive: see function docblock below.
/** Exported function `shux_collect_deps_transitive`.
 * Implements `shux_collect_deps_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_sources *u8
 * @param dep_lens *u8
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function shux_collect_deps_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = shux_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      shux_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return shux_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return 0 - 1;
}

// shux_collect_dep_paths_transitive: see function docblock below.
/** Exported function `shux_collect_dep_paths_transitive`.
 * Implements `shux_collect_dep_paths_transitive`.
 * @param module *u8
 * @param arena_sz i64
 * @param module_sz i64
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param entry_dir *u8
 * @param defines *u8
 * @param ndefines i32
 * @param dep_paths *u8
 * @param n_deps *i32
 * @return i32
 */
#[no_mangle]
export function shux_collect_dep_paths_transitive(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  if (n_deps == 0 as *i32) {
    return 0 - 1;
  }
  let nimp: i32 = 0;
  unsafe {
    nimp = shux_module_num_imports(module);
  }
  if (nimp <= 0) {
    unsafe {
      shux_i32_store(n_deps, 0);
    }
    return 0;
  }
  unsafe {
    return shux_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, n_deps);
  }
  return 0 - 1;
}

/** Exported function `pipeline_debug_trace_named_func_bodies`.
 * Implements `pipeline_debug_trace_named_func_bodies`.
 * @param phase *u8
 * @param module *u8
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void {
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

/* ---- G-02f-63 / G-02f-242：typeck_for_ctx / lsp free_loaded ---- */

// pipeline_typeck_module_for_ctx: see function docblock below.
/** Exported function `pipeline_typeck_module_for_ctx`.
 * Implements `pipeline_typeck_module_for_ctx`.
 * @param module *u8
 * @param arena *u8
 * @param ctx *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx(module: *u8, arena: *u8, ctx: *u8): i32 {
  if (module == 0 as *u8) {
    return 0 - 1;
  }
  // See implementation.
  let _a: *u8 = arena;
  let _c: *u8 = ctx;
  let n: i32 = get_ndep();
  unsafe {
    if (n > 0) {
      return typeck_module_with_sidecar(module);
    }
    return typeck_module_entry_only(module);
  }
  return 0 - 1;
}

// shu_lsp_free_loaded_imports: see function docblock below.
/** Exported function `shu_lsp_free_loaded_imports`.
 * Memory management helper `shu_lsp_free_loaded_imports`.
 * @param all_dep_mods *u8
 * @param all_dep_paths *u8
 * @param n_all i32
 * @return void
 */
#[no_mangle]
export function shu_lsp_free_loaded_imports(all_dep_mods: *u8, all_dep_paths: *u8, n_all: i32): void {
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


/* See implementation. */


// See implementation.
// kind="preprocess error" / "pipeline error" / "import error"；code=PP001/PP002/XP005/IMP002/IMP004

/** Exported function `pipeline_diag_preprocess_unclosed_if`.
 * Implements `pipeline_diag_preprocess_unclosed_if`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_unclosed_if(path_diag: *u8): void {
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

/** Exported function `pipeline_diag_preprocess_fail`.
 * Implements `pipeline_diag_preprocess_fail`.
 * @param path_diag *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_fail(path_diag: *u8): void {
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

/** Exported function `pipeline_diag_import_preprocess_fail`.
 * Implements `pipeline_diag_import_preprocess_fail`.
 * @param import_path *u8
 * @param resolved_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_import_preprocess_fail(import_path: *u8, resolved_path: *u8): void {
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

/** Exported function `pipeline_diag_preprocess_alloc_fail`.
 * Memory management helper `pipeline_diag_preprocess_alloc_fail`.
 * @param path_diag *u8
 * @param what *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_preprocess_alloc_fail(path_diag: *u8, what: *u8): void {
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

/** Exported function `pipeline_diag_merge_dep_missing`.
 * Implements `pipeline_diag_merge_dep_missing`.
 * @param import_path *u8
 * @return void
 */
#[no_mangle]
export function pipeline_diag_merge_dep_missing(import_path: *u8): void {
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

// typeck_ndep_store: see function docblock below.
/** Exported function `typeck_ndep_store`.
 * Implements `typeck_ndep_store`.
 * @param n i32
 * @return void
 */
#[no_mangle]
export function typeck_ndep_store(n: i32): void {
  let v: i32 = n;
  if (v > 32) { v = 32; }
  if (v < 0) { v = 0; }
  unsafe {
    typeck_ndep_store_impl(v);
  }
}

// typeck_dep_module_set: see function docblock below.
/** Exported function `typeck_dep_module_set`.
 * Implements `typeck_dep_module_set`.
 * @param i i32
 * @param mod *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_module_set(i: i32, mod: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_module_set_impl(i, mod);
  }
}

// typeck_dep_arena_set: see function docblock below.
/** Exported function `typeck_dep_arena_set`.
 * Implements `typeck_dep_arena_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function typeck_dep_arena_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    typeck_dep_arena_set_impl(i, arena);
  }
}

// driver_dep_arena_ptr_set: see function docblock below.
/** Exported function `driver_dep_arena_ptr_set`.
 * Implements `driver_dep_arena_ptr_set`.
 * @param i i32
 * @param arena *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_arena_ptr_set(i: i32, arena: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_arena_ptr_set_impl(i, arena);
  }
}

/** Exported function `driver_dep_module_ptr_set`.
 * Implements `driver_dep_module_ptr_set`.
 * @param i i32
 * @param module *u8
 * @return void
 */
#[no_mangle]
export function driver_dep_module_ptr_set(i: i32, module: *u8): void {
  if (i < 0) { return; }
  if (i >= 32) { return; }
  unsafe {
    driver_dep_module_ptr_set_impl(i, module);
  }
}


/* ---- G-02f-85 / G-02f-134：import path scan ---- */

export function pipe_cstr_eq(a: *u8, b: *u8): i32 {
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

// pipe_load_ptr_slot: see function docblock below.
/** Exported function `pipe_load_ptr_slot`.
 * Implements `pipe_load_ptr_slot`.
 * @param base *u8
 * @param i i32
 * @return *u8
 */
export function pipe_load_ptr_slot(base: *u8, i: i32): *u8 {
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

/**
 * Store little-endian pointer into base[i] (LP64 8-byte cell).
 * Module-local pair of pipe_load_ptr_slot (no second G.7 path).
 * @param base *u8 — table base; null → no-op
 * @param i i32 — slot index; i < 0 → no-op
 * @param val *u8 — pointer bits to store (may be null)
 * @return void
 * PLATFORM: SHARED LP64 little-endian.
 */
function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void {
  if (base == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  let off: i32 = i * 8;
  unsafe {
    let m: usize = 256 as usize;
    let b255: usize = 255 as usize;
    let u0: usize = val as usize;
    base[off] = (u0 & b255) as u8;
    let u1: usize = u0 / m;
    base[off + 1] = (u1 & b255) as u8;
    let u2: usize = u1 / m;
    base[off + 2] = (u2 & b255) as u8;
    let u3: usize = u2 / m;
    base[off + 3] = (u3 & b255) as u8;
    let u4: usize = u3 / m;
    base[off + 4] = (u4 & b255) as u8;
    let u5: usize = u4 / m;
    base[off + 5] = (u5 & b255) as u8;
    let u6: usize = u5 / m;
    base[off + 6] = (u6 & b255) as u8;
    let u7: usize = u6 / m;
    base[off + 7] = (u7 & b255) as u8;
  }
}

/**
 * Load size_t / i64 slot i from an array of LP64 8-byte cells (LE).
 * @param arr *u8 — size_t* base as bytes; null → 0
 * @param i i32 — index; i < 0 → 0
 * @return i64 — cell value as signed i64 (path lengths fit)
 * wave46 pure Cap residual; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_size_slot_get(arr: *u8, i: i32): i64 {
  if (arr == 0 as *u8) {
    return 0;
  }
  if (i < 0) {
    return 0;
  }
  // Same LE reconstruct as pipe_load_ptr_slot; cast pointer bits → i64 length.
  let p: *u8 = pipe_load_ptr_slot(arr, i);
  return p as i64;
}

/**
 * Store size_t / i64 into arr[i] (LP64 8-byte LE cell).
 * @param arr *u8 — size_t* base as bytes; null → no-op
 * @param i i32 — index; i < 0 → no-op
 * @param v i64 — value (path length / buffer size)
 * @return void
 * wave46 pure; pairs shux_size_slot_get. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function shux_size_slot_set(arr: *u8, i: i32, v: i64): void {
  if (arr == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  pipe_store_ptr_slot(arr, i, v as *u8);
}

/**
 * Write pointer p into char-star / void-star array slot i (G.7 product authority).
 * @param arr *u8 — void** / char** table base as bytes; null → no-op
 * @param i i32 — slot index; i < 0 → no-op
 * @param p *u8 — pointer to store (may be null)
 * @return void
 * wave46 pure; driver_abi / fmt_check call this as Cap residual surface.
 * PLATFORM: SHARED LP64 — single authority in this TU under PREFER hybrid.
 */
#[no_mangle]
export function shux_ptr_slot_set(arr: *u8, i: i32, p: *u8): void {
  pipe_store_ptr_slot(arr, i, p);
}

/**
 * Load pointer slot i from a char-star / void-star array base (G.7 pair with set).
 * @param arr *u8 — table base; null → null
 * @param i i32 — index; i < 0 → null
 * @return *u8 — pointer at slot (may be null)
 * wave46 pure. PLATFORM: SHARED LP64.
 * Note: never put the two-char end-comment marker inside prose (truncates the block).
 */
#[no_mangle]
export function shux_ptr_slot_get(arr: *u8, i: i32): *u8 {
  if (arr == 0 as *u8) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  return pipe_load_ptr_slot(arr, i);
}

/**
 * Store i32 v through pointer p (null-safe).
 * @param p *i32 — destination; null → no-op
 * @param v i32 — value
 * @return void
 * wave46 pure Cap residual (merge out_n / n_deps). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_i32_store(p: *i32, v: i32): void {
  if (p == 0 as *i32) {
    return;
  }
  unsafe {
    p[0] = v;
  }
}

/**
 * Return module import count (null module → 0).
 * @param module *u8 — opaque AST module; null → 0
 * @return i32 — import count from parser authority
 * wave46 pure thin over parser_get_module_num_imports (strong from parser_x at final link).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_module_num_imports(module: *u8): i32 {
  if (module == 0 as *u8) {
    return 0;
  }
  return parser_get_module_num_imports(module);
}

/**
 * Copy import path at idx into buf as a C string (NUL-terminated).
 * @param module *u8 — opaque AST module; null → buf[0]=0 when buf valid
 * @param idx i32 — import index
 * @param buf *u8 — destination; null or cap<=0 → no-op
 * @param cap i32 — capacity including NUL; copies min(path, cap-1)
 * @return void
 * wave46 pure: parser path bytes then copy loop (no libc). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_module_import_path_cstr(module: *u8, idx: i32, buf: *u8, cap: i32): void {
  if (buf == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  unsafe {
    buf[0] = 0;
  }
  if (module == 0 as *u8) {
    return;
  }
  let path_buf: u8[64] = [];
  unsafe {
    parser_get_module_import_path(module, idx, &path_buf[0]);
  }
  let k: i32 = 0;
  while (k < 64) {
    let ch: u8 = 0;
    unsafe {
      ch = path_buf[k];
    }
    if (ch == 0) {
      break;
    }
    if (k + 1 >= cap) {
      break;
    }
    unsafe {
      buf[k] = ch;
    }
    k = k + 1;
  }
  unsafe {
    buf[k] = 0;
  }
}

/**
 * True if to_load[0..to_load_n) already contains path (C-string eq).
 * @param to_load *u8 — char** queue base as bytes; null → 0
 * @param to_load_n i32 — live count
 * @param path *u8 — candidate C string; null → 0
 * @return i32 — 1 if found, 0 otherwise
 * wave46 pure; used by Cap residual collect enqueue. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_to_load_has(to_load: *u8, to_load_n: i32, path: *u8): i32 {
  if (to_load == 0 as *u8) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (to_load_n <= 0) {
    return 0;
  }
  let t: i32 = 0;
  while (t < to_load_n) {
    let p: *u8 = pipe_load_ptr_slot(to_load, t);
    if (p != 0 as *u8) {
      if (pipe_cstr_eq(p, path) != 0) {
        return 1;
      }
    }
    t = t + 1;
  }
  return 0;
}

/**
 * Seed the collect to_load queue from module direct imports (owned strdup keys).
 * @param module *u8 — opaque AST module; null → empty queue + 0
 * @param to_load *u8 — char** queue base as bytes; null → fail 1
 * @param to_load_n *i32 — out live count; null → fail 1; reset to 0 first
 * @return i32 — 0 success; 1 OOM (queue freed and count cleared)
 * wave47 pure Cap residual: G.7 reuses shux_module_num_imports / import_path_cstr /
 *   pipe_store_ptr_slot; Cap residual shux_collect_strdup for ownership (free on fail).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_seed_to_load(module: *u8, to_load: *u8, to_load_n: *i32): i32 {
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  unsafe {
    to_load_n[0] = 0;
  }
  if (module == 0 as *u8) {
    return 0;
  }
  let slot_max: i32 = 32;
  let n_imports: i32 = shux_module_num_imports(module);
  let j: i32 = 0;
  while (j < n_imports) {
    if (j >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let path_c: u8[65] = [];
    shux_module_import_path_cstr(module, j, &path_c[0], 65);
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = shux_collect_strdup(&path_c[0]);
    }
    if (owned == 0 as *u8) {
      // Free partial queue on OOM (same contract as seed cold twin).
      while (n > 0) {
        n = n - 1;
        let p: *u8 = pipe_load_ptr_slot(to_load, n);
        if (p != 0 as *u8) {
          unsafe {
            free(p);
          }
        }
        pipe_store_ptr_slot(to_load, n, 0 as *u8);
      }
      unsafe {
        to_load_n[0] = 0;
      }
      return 1;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    j = j + 1;
  }
  return 0;
}

/**
 * Process one owned to_load path into dep_sources/lens/paths and enqueue its sub-imports.
 * @param path_c *u8 — owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 — char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources; written at slot *n
 * @param dep_lens *u8 — size_t array base as bytes; written at slot *n
 * @param dep_paths *u8 — char star-star owned keys; written at slot *n
 * @param n *i32 — live loaded count (in/out); null → fail 1
 * @param to_load *u8 — char star-star queue base; null → fail 1
 * @param to_load_n *i32 — live queue count (in/out for enqueue); null → fail 1
 * @param tmp_arena *u8 — void star-star tmp arena slot; null → fail 1
 * @param tmp_module *u8 — void star-star tmp module slot; null → fail 1
 * @param arena_sz i64 — malloc size for tmp arena when first needed
 * @param module_sz i64 — malloc size for tmp module when first needed
 * @return i32 — 0 continue; 1 fail (caller cleans queue + partial deps)
 * wave48 pure Cap residual orch:
 *   already-loaded → free path_c + 0;
 *   G.7 load_one_direct_import_at stores prep/path at mi=*n (resolve/read/preprocess Cap);
 *   free path_c; *n = mi+1;
 *   Cap residual shux_collect_tmp_parse_and_enqueue for parse + enqueue.
 * wave50: called from pure transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_deps_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (shux_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Cap residual: resolve + read file view + preprocess → dep_sources/lens/paths[mi].
  let rc: i32 = 0;
  unsafe {
    rc = shux_load_one_direct_import_at(lib_roots, n_lib_roots, entry_dir, path_c, defines, ndefines, dep_sources, dep_lens, dep_paths, mi);
  }
  unsafe {
    free(path_c);
  }
  if (rc != 0) {
    return 1;
  }
  let key: *u8 = pipe_load_ptr_slot(dep_paths, mi);
  if (key == 0 as *u8) {
    return 1;
  }
  unsafe {
    n[0] = mi + 1;
  }
  let prep: *u8 = pipe_load_ptr_slot(dep_sources, mi);
  let prep_len: i64 = shux_size_slot_get(dep_lens, mi);
  let n_loaded: i32 = mi + 1;
  unsafe {
    shux_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, key, to_load, to_load_n, dep_paths, n_loaded);
  }
  return 0;
}

/**
 * Paths-only process one owned to_load path into dep_paths and enqueue sub-imports.
 * Unlike deps_process_one, does not keep prep sources/lens — only owned path keys.
 * @param path_c *u8 — owned C-string import key; consumed (freed) on all return paths
 * @param lib_roots *u8 — char star-star lib roots for resolve; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_paths *u8 — char star-star owned keys; written at slot *n
 * @param n *i32 — live loaded count (in/out); null → fail 1
 * @param to_load *u8 — char star-star queue base; null → fail 1
 * @param to_load_n *i32 — live queue count (in/out for enqueue); null → fail 1
 * @param tmp_arena *u8 — void star-star tmp arena slot; null → fail 1
 * @param tmp_module *u8 — void star-star tmp module slot; null → fail 1
 * @param arena_sz i64 — malloc size for tmp arena when first needed
 * @param module_sz i64 — malloc size for tmp module when first needed
 * @return i32 — 0 continue; 1 fail (caller cleans queue + partial paths)
 * wave49 pure Cap residual orch:
 *   already-loaded → free path_c + 0;
 *   Cap residual shux_collect_strdup stores owned key at mi=*n; *n = mi+1;
 *   Cap residual shux_collect_paths_tmp_resolve_parse_enqueue
 *     (ensure tmp; resolve/read/preprocess; G.7 tmp_parse_and_enqueue; free prep);
 *   free path_c. If tmp malloc fails residual no-ops success (path still registered).
 * wave50: called from pure paths transitive_impl orch. PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_paths_process_one(path_c: *u8, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n: *i32, to_load: *u8, to_load_n: *i32, tmp_arena: *u8, tmp_module: *u8, arena_sz: i64, module_sz: i64): i32 {
  if (path_c == 0 as *u8) {
    return 1;
  }
  if (n == 0 as *i32) {
    return 1;
  }
  if (to_load == 0 as *u8) {
    return 1;
  }
  if (to_load_n == 0 as *i32) {
    return 1;
  }
  if (tmp_arena == 0 as *u8) {
    return 1;
  }
  if (tmp_module == 0 as *u8) {
    return 1;
  }
  let mi: i32 = 0;
  unsafe {
    mi = n[0];
  }
  // Already loaded: drop owned path and continue (same as cold twin).
  if (shux_find_loaded_import_index(path_c, dep_paths, mi) >= 0) {
    unsafe {
      free(path_c);
    }
    return 0;
  }
  // Register owned path key before resolve (fail paths leave key for caller cleanup).
  let key: *u8 = 0 as *u8;
  unsafe {
    key = shux_collect_strdup(path_c);
  }
  if (key == 0 as *u8) {
    unsafe {
      free(path_c);
    }
    return 1;
  }
  pipe_store_ptr_slot(dep_paths, mi, key);
  unsafe {
    n[0] = mi + 1;
  }
  let n_loaded: i32 = mi + 1;
  let rc: i32 = 0;
  unsafe {
    rc = shux_collect_paths_tmp_resolve_parse_enqueue(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, tmp_arena, tmp_module, arena_sz, module_sz, to_load, to_load_n, dep_paths, n_loaded);
  }
  unsafe {
    free(path_c);
  }
  return rc;
}

/**
 * Transitive collect of dep sources/lens/paths: seed queue, drain via process_one, free leftovers.
 * @param module *u8 — entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 — tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 — tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_sources *u8 — char star-star prep sources out slots
 * @param dep_lens *u8 — size_t array base as bytes for prep lengths
 * @param dep_paths *u8 — char star-star owned path keys out slots
 * @param n_deps *i32 — out live count; null → fail 1
 * @return i32 — 0 success; 1 fail (partial deps freed; queue/tmp freed)
 * wave50 pure Cap residual orch:
 *   stack char star-star to_load[32] as 256B + two void-star tmp cells as 16B
 *   (G.7 same stack-ptr pattern as check_one_file argv);
 *   G.7 shux_collect_seed_to_load then drain with pure process_one;
 *   success: free remaining queue + tmp, store *n_deps;
 *   fail: free queue + tmp + dep_sources/paths[0..n).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_deps_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_sources: *u8, dep_lens: *u8, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  // char* to_load[32] as 32×8 pointer slots on stack (LP64).
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  // void* tmp_arena / tmp_module as two pointer cells (void star-star for process_one).
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (shux_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    // Fail: free any partial queue (seed_to_load already clears on OOM; still drain).
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = shux_collect_deps_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      // Fail path: free remaining queue, tmp, and partial deps.
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      if (ta != 0 as *u8) {
        unsafe {
          free(ta);
        }
      }
      if (tm != 0 as *u8) {
        unsafe {
          free(tm);
        }
      }
      while (n > 0) {
        n = n - 1;
        let s: *u8 = pipe_load_ptr_slot(dep_sources, n);
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (s != 0 as *u8) {
          unsafe {
            free(s);
          }
        }
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_sources, n, 0 as *u8);
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  // Success: free leftover queue entries and tmp arena/module.
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  if (ta_ok != 0 as *u8) {
    unsafe {
      free(ta_ok);
    }
  }
  if (tm_ok != 0 as *u8) {
    unsafe {
      free(tm_ok);
    }
  }
  unsafe {
    shux_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Paths-only transitive collect: seed queue, drain via paths_process_one, free leftovers.
 * @param module *u8 — entry AST module; may be null (seed_to_load then empty)
 * @param arena_sz i64 — tmp arena malloc size for first process_one that needs parse
 * @param module_sz i64 — tmp module malloc size for first process_one that needs parse
 * @param lib_roots *u8 — char star-star lib roots; may be null if n_lib_roots==0
 * @param n_lib_roots i32 — lib root count
 * @param entry_dir *u8 — entry directory C string; may be null
 * @param defines *u8 — char star-star define names; may be null if ndefines==0
 * @param ndefines i32 — define count
 * @param dep_paths *u8 — char star-star owned path keys out slots
 * @param n_deps *i32 — out live count; null → fail 1
 * @return i32 — 0 success; 1 fail (partial paths freed; queue/tmp freed)
 * wave50 pure Cap residual orch: same stack to_load + tmp_cells as deps transitive;
 *   G.7 seed_to_load + pure paths_process_one; fail frees only dep_paths (no sources).
 * Slot max = SHUX_DRIVER_DEP_SLOT_MAX (32). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_dep_paths_transitive_impl(module: *u8, arena_sz: i64, module_sz: i64, lib_roots: *u8, n_lib_roots: i32, entry_dir: *u8, defines: *u8, ndefines: i32, dep_paths: *u8, n_deps: *i32): i32 {
  if (n_deps == 0 as *i32) {
    return 1;
  }
  let to_load: u8[256] = [];
  let z: i32 = 0;
  while (z < 256) {
    to_load[z] = 0;
    z = z + 1;
  }
  let to_load_n: i32 = 0;
  let tmp_cells: u8[16] = [];
  z = 0;
  while (z < 16) {
    tmp_cells[z] = 0;
    z = z + 1;
  }
  let n: i32 = 0;
  let slot_max: i32 = 32;
  if (shux_collect_seed_to_load(module, &to_load[0], &to_load_n) != 0) {
    while (to_load_n > 0) {
      to_load_n = to_load_n - 1;
      let p: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
      if (p != 0 as *u8) {
        unsafe {
          free(p);
        }
      }
      pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    }
    return 1;
  }
  while (to_load_n > 0) {
    if (n >= slot_max) {
      break;
    }
    to_load_n = to_load_n - 1;
    let path_c: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
    let rc: i32 = 0;
    unsafe {
      rc = shux_collect_paths_process_one(path_c, lib_roots, n_lib_roots, entry_dir, defines, ndefines, dep_paths, &n, &to_load[0], &to_load_n, &tmp_cells[0], &tmp_cells[8], arena_sz, module_sz);
    }
    if (rc != 0) {
      while (to_load_n > 0) {
        to_load_n = to_load_n - 1;
        let p2: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
        if (p2 != 0 as *u8) {
          unsafe {
            free(p2);
          }
        }
        pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
      }
      let ta: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
      let tm: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
      if (ta != 0 as *u8) {
        unsafe {
          free(ta);
        }
      }
      if (tm != 0 as *u8) {
        unsafe {
          free(tm);
        }
      }
      while (n > 0) {
        n = n - 1;
        let k: *u8 = pipe_load_ptr_slot(dep_paths, n);
        if (k != 0 as *u8) {
          unsafe {
            free(k);
          }
        }
        pipe_store_ptr_slot(dep_paths, n, 0 as *u8);
      }
      return 1;
    }
  }
  while (to_load_n > 0) {
    to_load_n = to_load_n - 1;
    let p3: *u8 = pipe_load_ptr_slot(&to_load[0], to_load_n);
    if (p3 != 0 as *u8) {
      unsafe {
        free(p3);
      }
    }
    pipe_store_ptr_slot(&to_load[0], to_load_n, 0 as *u8);
  }
  let ta_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 0);
  let tm_ok: *u8 = pipe_load_ptr_slot(&tmp_cells[0], 1);
  if (ta_ok != 0 as *u8) {
    unsafe {
      free(ta_ok);
    }
  }
  if (tm_ok != 0 as *u8) {
    unsafe {
      free(tm_ok);
    }
  }
  unsafe {
    shux_i32_store(n_deps, n);
  }
  return 0;
}

/**
 * Enqueue sub-imports from a parsed tmp_module into to_load (skip loaded / already queued).
 * @param tmp_module *u8 — parsed dep module; null → no-op
 * @param to_load *u8 — char** queue base; null → no-op
 * @param to_load_n *i32 — live queue count (in/out); null → no-op
 * @param dep_paths *u8 — already-loaded import keys as char star-star; may be null if n_loaded==0
 * @param n_loaded i32 — count of dep_paths already committed
 * @return void
 * wave47 pure Cap residual: G.7 reuses module_num_imports / import_path_cstr /
 *   shux_find_loaded_import_index / shux_collect_to_load_has / pipe slots;
 *   Cap residual shux_collect_strdup.
 * OOM on one strdup: skip that import (same as cold twin continue). PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_collect_enqueue_module_imports(tmp_module: *u8, to_load: *u8, to_load_n: *i32, dep_paths: *u8, n_loaded: i32): void {
  if (tmp_module == 0 as *u8) {
    return;
  }
  if (to_load == 0 as *u8) {
    return;
  }
  if (to_load_n == 0 as *i32) {
    return;
  }
  let slot_max: i32 = 32;
  let n_imp: i32 = 0;
  unsafe {
    n_imp = parser_get_module_num_imports(tmp_module);
  }
  if (n_imp <= 0) {
    return;
  }
  let jj: i32 = 0;
  while (jj < n_imp) {
    if (jj >= slot_max) {
      break;
    }
    let n: i32 = 0;
    unsafe {
      n = to_load_n[0];
    }
    if (n >= slot_max) {
      break;
    }
    let sub_c: u8[65] = [];
    shux_module_import_path_cstr(tmp_module, jj, &sub_c[0], 65);
    // Skip if already loaded or already queued.
    if (shux_find_loaded_import_index(&sub_c[0], dep_paths, n_loaded) >= 0) {
      jj = jj + 1;
      continue;
    }
    if (shux_collect_to_load_has(to_load, n, &sub_c[0]) != 0) {
      jj = jj + 1;
      continue;
    }
    let owned: *u8 = 0 as *u8;
    unsafe {
      owned = shux_collect_strdup(&sub_c[0]);
    }
    if (owned == 0 as *u8) {
      jj = jj + 1;
      continue;
    }
    pipe_store_ptr_slot(to_load, n, owned);
    unsafe {
      to_load_n[0] = n + 1;
    }
    jj = jj + 1;
  }
}

/**
 * Map preprocess_x_buf negative directive codes to fixed diag strings (PP002).
 * @param path_diag *u8 — path for report; may be null
 * @param code i32 — negative directive fail code (-2..-7 known; else generic fail)
 * @return void
 * wave46 pure: fixed msgs via stack byte lits + diag_report_with_code (no va_list).
 * PLATFORM: SHARED — Cap residual was always-seed; hybrid pure authority.
 */
#[no_mangle]
export function pipeline_diag_preprocess_directive_code(path_diag: *u8, code: i32): void {
  // Known codes -2..-7; anything else → generic preprocess fail.
  if (code != (0 - 2)) {
    if (code != (0 - 3)) {
      if (code != (0 - 4)) {
        if (code != (0 - 5)) {
          if (code != (0 - 6)) {
            if (code != (0 - 7)) {
              pipeline_diag_preprocess_fail(path_diag);
              return;
            }
          }
        }
      }
    }
  }
  pipeline_diag_emitted_note();
  let kind: u8[24] = [];
  let dcode: u8[8] = [];
  // "preprocess error"
  kind[0] = 112; kind[1] = 114; kind[2] = 101; kind[3] = 112;
  kind[4] = 114; kind[5] = 111; kind[6] = 99; kind[7] = 101;
  kind[8] = 115; kind[9] = 115; kind[10] = 32; kind[11] = 101;
  kind[12] = 114; kind[13] = 114; kind[14] = 111; kind[15] = 114; kind[16] = 0;
  // "PP002"
  dcode[0] = 80; dcode[1] = 80; dcode[2] = 48; dcode[3] = 48; dcode[4] = 50; dcode[5] = 0;
  let msg: u8[32] = [];
  // Fill msg by code (ASCII byte tables; keep under ~63 lit cap).
  if (code == (0 - 2)) {
    // "#else without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 32; msg[6] = 119; msg[7] = 105; msg[8] = 116; msg[9] = 104;
    msg[10] = 111; msg[11] = 117; msg[12] = 116; msg[13] = 32; msg[14] = 35;
    msg[15] = 105; msg[16] = 102; msg[17] = 0;
  } else if (code == (0 - 3)) {
    // "#endif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 110; msg[3] = 100; msg[4] = 105;
    msg[5] = 102; msg[6] = 32; msg[7] = 119; msg[8] = 105; msg[9] = 116;
    msg[10] = 104; msg[11] = 111; msg[12] = 117; msg[13] = 116; msg[14] = 32;
    msg[15] = 35; msg[16] = 105; msg[17] = 102; msg[18] = 0;
  } else if (code == (0 - 4)) {
    // "#elseif without #if"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 119; msg[9] = 105;
    msg[10] = 116; msg[11] = 104; msg[12] = 111; msg[13] = 117; msg[14] = 116;
    msg[15] = 32; msg[16] = 35; msg[17] = 105; msg[18] = 102; msg[19] = 0;
  } else if (code == (0 - 5)) {
    // "#elseif after #else"
    msg[0] = 35; msg[1] = 101; msg[2] = 108; msg[3] = 115; msg[4] = 101;
    msg[5] = 105; msg[6] = 102; msg[7] = 32; msg[8] = 97; msg[9] = 102;
    msg[10] = 116; msg[11] = 101; msg[12] = 114; msg[13] = 32; msg[14] = 35;
    msg[15] = 101; msg[16] = 108; msg[17] = 115; msg[18] = 101; msg[19] = 0;
  } else if (code == (0 - 6)) {
    // "duplicate #else"
    msg[0] = 100; msg[1] = 117; msg[2] = 112; msg[3] = 108; msg[4] = 105;
    msg[5] = 99; msg[6] = 97; msg[7] = 116; msg[8] = 101; msg[9] = 32;
    msg[10] = 35; msg[11] = 101; msg[12] = 108; msg[13] = 115; msg[14] = 101;
    msg[15] = 0;
  } else {
    // code == -7: "#if nesting too deep"
    msg[0] = 35; msg[1] = 105; msg[2] = 102; msg[3] = 32; msg[4] = 110;
    msg[5] = 101; msg[6] = 115; msg[7] = 116; msg[8] = 105; msg[9] = 110;
    msg[10] = 103; msg[11] = 32; msg[12] = 116; msg[13] = 111; msg[14] = 111;
    msg[15] = 32; msg[16] = 100; msg[17] = 101; msg[18] = 101; msg[19] = 112;
    msg[20] = 0;
  }
  unsafe {
    diag_report_with_code(path_diag, 0, 0, &kind[0], &dcode[0], &msg[0], 0 as *u8);
  }
}

// shux_dep_prerun_entry_dir_pick: see function docblock below.
/** Exported function `shux_dep_prerun_entry_dir_pick`.
 * Implements `shux_dep_prerun_entry_dir_pick`.
 * @param main_entry_dir *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return *u8
 */
#[no_mangle]
export function shux_dep_prerun_entry_dir_pick(main_entry_dir: *u8, lib_roots: *u8, n_lib_roots: i32): *u8 {
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

/** Exported function `shux_find_loaded_import_index_scan`.
 * Implements `shux_find_loaded_import_index_scan`.
 * @param path *u8
 * @param all_paths *u8
 * @param n_all i32
 * @return i32
 */
#[no_mangle]
export function shux_find_loaded_import_index_scan(path: *u8, all_paths: *u8, n_all: i32): i32 {
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

/** Exported function `shux_merge_deps_path_already_out_scan`.
 * Read path helper `shux_merge_deps_path_already_out_scan`.
 * @param path *u8
 * @param out_paths *u8
 * @param n_out i32
 * @return i32
 */
#[no_mangle]
export function shux_merge_deps_path_already_out_scan(path: *u8, out_paths: *u8, n_out: i32): i32 {
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

/* See implementation. */

// shux_pipeline_pctx_update_dep_slots_no_reset: see function docblock below.
/** Exported function `shux_pipeline_pctx_update_dep_slots_no_reset`.
 * Implements `shux_pipeline_pctx_update_dep_slots_no_reset`.
 * @param ctx *u8
 * @param dep_mods *u8
 * @param dep_ars *u8
 * @param import_paths *u8
 * @param n i32
 * @return void
 */
#[no_mangle]
export function shux_pipeline_pctx_update_dep_slots_no_reset(ctx: *u8, dep_mods: *u8, dep_ars: *u8, import_paths: *u8, n: i32): void {
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



/* ---- G-02f-95 / G-02f-241：pipeline large-stack thread fns ---- */

// pipeline_run_x_thread_fn: see function docblock below.
/** Exported function `pipeline_run_x_thread_fn`.
 * Read path helper `pipeline_run_x_thread_fn`.
 * @param arg *u8
 * @return *u8
 */
#[no_mangle]
export function pipeline_run_x_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return pipeline_run_x_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

// shux_asm_codegen_elf_o_thread_fn: see function docblock below.
/** Exported function `shux_asm_codegen_elf_o_thread_fn`.
 * Read path helper `shux_asm_codegen_elf_o_thread_fn`.
 * @param arg *u8
 * @return *u8
 */
#[no_mangle]
export function shux_asm_codegen_elf_o_thread_fn(arg: *u8): *u8 {
  if (arg == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    return shux_asm_codegen_elf_o_thread_fn_impl(arg);
  }
  return 0 as *u8;
}

// See implementation.

export extern "C" function getenv(name: *u8): *u8;

/** Exported function `pipeline_asm_debug_enabled`.
 * Implements `pipeline_asm_debug_enabled`.
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_debug_enabled(): i32 {
  unsafe {
    let e: *u8 = getenv("SHUX_ASM_DEBUG");
    if (e != 0) { return 1; }
  }
  return 0;
}

// pipeline_debug_body_func_match: see function docblock below.

/** Exported function `pipeline_debug_body_func_match`.
 * Implements `pipeline_debug_body_func_match`.
 * @param filter *u8
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_debug_body_func_match(filter: *u8, name: *u8): i32 {
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

