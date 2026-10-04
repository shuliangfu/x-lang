// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1530 product body of src/runtime_driver_strict_glue_stubs.o.
// One translation unit with src/runtime_heap_user.x (the ensure concatenates
// them). Darwin cannot ld -r two pure-asm objects into one MH_OBJECT, so the
// heap bodies stay in their file and this file does not copy them.
// The ensure weakens every defined global except the strong keep list.
// File-level scalars are i32[1] slots: a direct store to a file-level scalar
// fails the Darwin Mach-O writer. Alignment and hex use shifts and masks.
// Each function makes at most one call, except run_x_pipeline_fill_dep_import_path_c
// which copies then sets. Those two results live in file-level storage, and a
// pad keeps the frame off the last slot.
// PLATFORM: SHARED. macos, linux, and windows each compile one positive
// cfg of w1530_host_write. There is no cfg(not(...)).


export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function write(fd: i32, buf: *u8, n: usize): i64;
export extern "C" function cfg_eval_expr_c(start: *u8, len: i32): i32;
export extern "C" function driver_skip_codegen_dep_0_get(): i32;
export extern "C" function driver_set_current_dep_path_for_codegen(path: *u8): void;
export extern "C" function driver_diagnostic_pipe_marker(id: i32): void;
export extern "C" function pipeline_module_import_path_copy(module_ptr: *u8, idx: i32, dst: *u8, dst_cap: i32): void;

/**
 * Windows write. Count is a 32-bit unsigned value, matching the C _write tail.
 * @param fd i32 — file descriptor
 * @param buf *u8 — bytes
 * @param n u32 — byte count
 * @return i32 — bytes written, or -1
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
export extern "C" function _write(fd: i32, buf: *u8, n: u32): i32;

// 128 names of 64 bytes. Index is i * 64 + k. Cold fallback only.
// PLATFORM: SHARED.
let g_defines: u8[8192] = [];
// Count of names in g_defines. Stored as one i32 so the slot is an index store.
// PLATFORM: SHARED.
let g_ndefines: i32[1] = [0];
// 16 slots of 128 bytes. Slot s starts at s * 128.
// PLATFORM: SHARED.
let g_scratch: u8[2048] = [];
// Layout metric scalars. al starts at 1, matching the C initializer.
// PLATFORM: SHARED.
let g_sz_slot: i32[1] = [0];
let g_al_slot: i32[1] = [1];
let g_sz_depth: i32[64] = [];
let g_al_depth: i32[64] = [];
let g_dep_idx: i32[1] = [0];
let g_func_idx: i32[1] = [0];
let g_over_ret: i32[1] = [0];
// Import path staged between the copy and the dep-ctx set.
// PLATFORM: SHARED.
let g_fill_path: u8[128] = [];
let g_fill_len: i32[1] = [0];

/**
 * Anchor the ensure checks before it links this object. Always 0.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function runtime_driver_strict_glue_stubs_x_w1530_anchor(): i32 {
  return 0;
}

/**
 * Doc anchor paired with the w1530 ensure anchor. Always 0.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function runtime_driver_strict_glue_stubs_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Write n bytes. One libc call. The caller already converted a stream handle.
 * @param fd i32 — raw descriptor
 * @param buf *u8 — bytes; not null when n > 0
 * @param n i32 — byte count
 * @return i32 — bytes written, or a negative error
 * PLATFORM: MACOS|DARWIN
 */
#[cfg(target_os = "macos")]
#[no_mangle]
function w1530_host_write(fd: i32, buf: *u8, n: i32): i32 {
  unsafe {
    return write(fd, buf, n as usize) as i32;
  }
  return 0;
}

/**
 * Write n bytes. One libc call. The caller already converted a stream handle.
 * @param fd i32 — raw descriptor
 * @param buf *u8 — bytes; not null when n > 0
 * @param n i32 — byte count
 * @return i32 — bytes written, or a negative error
 * PLATFORM: LINUX
 */
#[cfg(target_os = "linux")]
#[no_mangle]
function w1530_host_write(fd: i32, buf: *u8, n: i32): i32 {
  unsafe {
    return write(fd, buf, n as usize) as i32;
  }
  return 0;
}

/**
 * Write n bytes. One libc call. The caller already converted a stream handle.
 * @param fd i32 — raw descriptor
 * @param buf *u8 — bytes; not null when n > 0
 * @param n i32 — byte count
 * @return i32 — bytes written, or a negative error
 * PLATFORM: WINDOWS
 */
#[cfg(target_os = "windows")]
#[no_mangle]
function w1530_host_write(fd: i32, buf: *u8, n: i32): i32 {
  unsafe {
    return _write(fd, buf, n as u32);
  }
  return 0;
}

/**
 * Classify an LSP path. mode 0 is lsp_io.x. mode 1 is lsp/lsp.x and not lsp_io. Loops only, no libc search.
 * @param path *u8 — path bytes, or null
 * @param mode i32 — 0 for io, 1 for main
 * @return i32 — 1 when the path matches
 * PLATFORM: SHARED
 */
#[no_mangle]
function w1530_path_class(path: *u8, mode: i32): i32 {

  if (path == 0 as *u8) {
    return 0;
  }

  if (mode == 0) {

  let io_nlen: i32 = 0;
  let io_needle: *u8 = "lsp_io.x";
  let io_i: i32 = 0;
  let io_k: i32 = 0;
  let io_ok: i32 = 0;
  let io_hk: u8 = 0;
  let io_found: i32 = 0;
  while (io_needle[io_nlen] != 0) {
    io_nlen = io_nlen + 1;
  }
  io_i = 0;
  while (path[io_i] != 0 && io_found == 0) {
    io_k = 0;
    io_ok = 1;
    while (io_k < io_nlen) {
      io_hk = path[io_i + io_k];
      if (io_hk == 0) {
        io_ok = 0;
      }
      if (io_hk != io_needle[io_k]) {
        io_ok = 0;
      }
      if (io_ok == 0) {
        io_k = io_nlen;
      }
      if (io_ok == 1) {
        io_k = io_k + 1;
      }
    }
    if (io_ok == 1) {
      io_found = 1;
    }
    if (io_found == 0) {
      io_i = io_i + 1;
    }
  }

    return io_found;
  }

  let a_nlen: i32 = 0;
  let a_needle: *u8 = "/lsp/lsp.x";
  let a_i: i32 = 0;
  let a_k: i32 = 0;
  let a_ok: i32 = 0;
  let a_hk: u8 = 0;
  let a_found: i32 = 0;
  while (a_needle[a_nlen] != 0) {
    a_nlen = a_nlen + 1;
  }
  a_i = 0;
  while (path[a_i] != 0 && a_found == 0) {
    a_k = 0;
    a_ok = 1;
    while (a_k < a_nlen) {
      a_hk = path[a_i + a_k];
      if (a_hk == 0) {
        a_ok = 0;
      }
      if (a_hk != a_needle[a_k]) {
        a_ok = 0;
      }
      if (a_ok == 0) {
        a_k = a_nlen;
      }
      if (a_ok == 1) {
        a_k = a_k + 1;
      }
    }
    if (a_ok == 1) {
      a_found = 1;
    }
    if (a_found == 0) {
      a_i = a_i + 1;
    }
  }

  let b_nlen: i32 = 0;
  let b_needle: *u8 = "\\lsp\\lsp.x";
  let b_i: i32 = 0;
  let b_k: i32 = 0;
  let b_ok: i32 = 0;
  let b_hk: u8 = 0;
  let b_found: i32 = 0;
  while (b_needle[b_nlen] != 0) {
    b_nlen = b_nlen + 1;
  }
  b_i = 0;
  while (path[b_i] != 0 && b_found == 0) {
    b_k = 0;
    b_ok = 1;
    while (b_k < b_nlen) {
      b_hk = path[b_i + b_k];
      if (b_hk == 0) {
        b_ok = 0;
      }
      if (b_hk != b_needle[b_k]) {
        b_ok = 0;
      }
      if (b_ok == 0) {
        b_k = b_nlen;
      }
      if (b_ok == 1) {
        b_k = b_k + 1;
      }
    }
    if (b_ok == 1) {
      b_found = 1;
    }
    if (b_found == 0) {
      b_i = b_i + 1;
    }
  }

  let c_nlen: i32 = 0;
  let c_needle: *u8 = "lsp/lsp.x";
  let c_i: i32 = 0;
  let c_k: i32 = 0;
  let c_ok: i32 = 0;
  let c_hk: u8 = 0;
  let c_found: i32 = 0;
  while (c_needle[c_nlen] != 0) {
    c_nlen = c_nlen + 1;
  }
  c_i = 0;
  while (path[c_i] != 0 && c_found == 0) {
    c_k = 0;
    c_ok = 1;
    while (c_k < c_nlen) {
      c_hk = path[c_i + c_k];
      if (c_hk == 0) {
        c_ok = 0;
      }
      if (c_hk != c_needle[c_k]) {
        c_ok = 0;
      }
      if (c_ok == 0) {
        c_k = c_nlen;
      }
      if (c_ok == 1) {
        c_k = c_k + 1;
      }
    }
    if (c_ok == 1) {
      c_found = 1;
    }
    if (c_found == 0) {
      c_i = c_i + 1;
    }
  }

  let d_nlen: i32 = 0;
  let d_needle: *u8 = "lsp_io";
  let d_i: i32 = 0;
  let d_k: i32 = 0;
  let d_ok: i32 = 0;
  let d_hk: u8 = 0;
  let d_found: i32 = 0;
  while (d_needle[d_nlen] != 0) {
    d_nlen = d_nlen + 1;
  }
  d_i = 0;
  while (path[d_i] != 0 && d_found == 0) {
    d_k = 0;
    d_ok = 1;
    while (d_k < d_nlen) {
      d_hk = path[d_i + d_k];
      if (d_hk == 0) {
        d_ok = 0;
      }
      if (d_hk != d_needle[d_k]) {
        d_ok = 0;
      }
      if (d_ok == 0) {
        d_k = d_nlen;
      }
      if (d_ok == 1) {
        d_k = d_k + 1;
      }
    }
    if (d_ok == 1) {
      d_found = 1;
    }
    if (d_found == 0) {
      d_i = d_i + 1;
    }
  }

  if (a_found == 1) {
    return 1;
  }
  if (b_found == 1) {
    return 1;
  }
  if (c_found == 1) {
    if (d_found == 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Cold fallback `asm_skip_heavy_set_pipeline_ctx`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function asm_skip_heavy_set_pipeline_ctx(): void {
  return;
}

/**
 * Cold fallback `ast_module_free`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_module_free(): void {
  return;
}

/**
 * Cold fallback `ast_pipeline_dep_ctx_reset`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_reset(): void {
  return;
}

/**
 * Cold fallback `ast_pipeline_dep_ctx_set_arena`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_arena(): void {
  return;
}

/**
 * Cold fallback `ast_pipeline_dep_ctx_set_import_path`. Arguments are ignored.
 * @param ctx *u8 — ignored
 * @param idx i32 — ignored
 * @param bytes_ptr *u8 — ignored
 * @param len i32 — ignored
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes_ptr: *u8, len: i32): void {
  return;
}

/**
 * Cold fallback `ast_pipeline_dep_ctx_set_module`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_module(): void {
  return;
}

/**
 * Cold fallback `ast_pipeline_dep_ctx_set_ndep`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_dep_ctx_set_ndep(): void {
  return;
}

/**
 * Cold fallback `codegen_emit_builtin_inline_decls`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_emit_builtin_inline_decls(): void {
  return;
}

/**
 * Cold fallback `codegen_emit_fmt_json_helpers_once`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_emit_fmt_json_helpers_once(): void {
  return;
}

/**
 * Cold fallback `codegen_or_preamble_skip_mask`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_or_preamble_skip_mask(): void {
  return;
}

/**
 * Cold fallback `codegen_reset_preamble_skip_mask`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_reset_preamble_skip_mask(): void {
  return;
}

/**
 * Cold fallback `codegen_set_dep_slots_for_x_pipeline`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_set_dep_slots_for_x_pipeline(): void {
  return;
}

/**
 * Cold fallback `codegen_set_eextern_entry_path`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_set_eextern_entry_path(): void {
  return;
}

/**
 * Cold fallback `codegen_set_preamble_has_core_option_result`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_set_preamble_has_core_option_result(): void {
  return;
}

/**
 * Cold fallback `lexer_free`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lexer_free(): void {
  return;
}

/**
 * Cold fallback `parser_parse_into_init`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_parse_into_init(): void {
  return;
}

/**
 * Cold fallback `pipeline_fill_array_lit_types_for_skipped_typeck`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_fill_array_lit_types_for_skipped_typeck(): void {
  return;
}

/**
 * Cold fallback `pipeline_fill_soa_field_access_for_asm_emit`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_fill_soa_field_access_for_asm_emit(): void {
  return;
}

/**
 * Cold fallback `pipeline_module_fixup_with_arena_stmt_orders`. Arguments are ignored.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_fixup_with_arena_stmt_orders(): void {
  return;
}

/**
 * Cold fallback `ast_ast_block_final_expr_ref`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_final_expr_ref(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_ast_block_num_consts`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_num_consts(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_ast_block_num_if_stmts`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_num_if_stmts(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_ast_block_num_lets`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_num_lets(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_ast_block_num_regions`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_num_regions(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_ast_block_num_stmt_order`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_ast_block_num_stmt_order(): i32 {
  return 0;
}

/**
 * Cold fallback `ast_pipeline_ctx_append_lib_root`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pipeline_ctx_append_lib_root(): i32 {
  return 0;
}

/**
 * Cold fallback `codegen_get_preamble_skip_mask`. Arguments are ignored.
 * @return i32 — 0; the C return is unsigned 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_get_preamble_skip_mask(): i32 {
  return 0;
}

/**
 * Cold fallback `codegen_wpo_reach_is_reachable`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_wpo_reach_is_reachable(): i32 {
  return 0;
}

/**
 * Cold fallback `driver_get_module_num_funcs`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function driver_get_module_num_funcs(): i32 {
  return 0;
}

/**
 * Cold fallback `parser_get_module_num_imports`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_get_module_num_imports(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_asm_user_dep_skip_x_typeck`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_user_dep_skip_x_typeck(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_asm_user_std_net_dep_path`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_user_std_net_dep_path(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_codegen_path_is_std_io_driver_bytes`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_codegen_path_is_std_io_driver_bytes(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_dep_ctx_ndep`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_dep_ctx_ndep(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_module_func_body_ref_at`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_body_ref_at(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_module_func_is_extern_at`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_extern_at(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_module_func_name_len_at`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_len_at(): i32 {
  return 0;
}

/**
 * Cold fallback `pipeline_module_num_funcs`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_num_funcs(): i32 {
  return 0;
}

/**
 * Cold fallback `typeck_set_allow_legacy_extern_calls`. Arguments are ignored.
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_set_allow_legacy_extern_calls(): i32 {
  return 0;
}

/**
 * Cold fallback `codegen_emit_dep_types_only`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_emit_dep_types_only(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `codegen_library_module_to_c`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_library_module_to_c(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `codegen_module_to_c`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_module_to_c(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `codegen_wpo_mono_sym_format`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_wpo_mono_sym_format(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `driver_get_module_main_func_index`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function driver_get_module_main_func_index(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `parse`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parse(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_load_and_sync_direct_import_deps_c`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_load_and_sync_direct_import_deps_c(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_module_main_func_index`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_main_func_index(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_parse_set_main_from_buf_c`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_parse_set_main_from_buf_c(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_run_x_pipeline`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_run_x_pipeline(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_typeck_dep_prerun_module_c`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_dep_prerun_module_c(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `pipeline_typeck_module_for_ctx`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_typeck_module_for_ctx(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `typeck_module`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_module(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `typeck_one_function`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_one_function(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `xlang_c_resolve_and_load_imports`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_c_resolve_and_load_imports(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `xlang_lsp_resolve_and_load_imports`. Arguments are ignored. Returns failure.
 * @return i32 — -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_lsp_resolve_and_load_imports(): i32 {
  return 0 - 1;
}

/**
 * Cold fallback `codegen_entry_root_func`. Arguments are ignored.
 * @return *u8 — null
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_entry_root_func(): *u8 {
  return 0 as *u8;
}

/**
 * Cold fallback `lexer_new`. Arguments are ignored.
 * @return *u8 — null
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lexer_new(): *u8 {
  return 0 as *u8;
}

/**
 * Cold fallback `pipeline_block_labeled_ptr`. Arguments are ignored.
 * @param arena_ptr *u8 — ignored
 * @param br i32 — ignored
 * @param li i32 — ignored
 * @return *u8 — null
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_labeled_ptr(arena_ptr: *u8, br: i32, li: i32): *u8 {
  return 0 as *u8;
}

/**
 * True when path contains lsp_io.x. Strong product body. One call.
 * @param path *u8 — file path, or null
 * @return i32 — 1 when the needle is present
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_path_is_lsp_io_x(path: *u8): i32 {
  return w1530_path_class(path, 0);
}

/**
 * True for /lsp/lsp.x, \\lsp\\lsp.x, or lsp/lsp.x that is not lsp_io. Strong product body. One call.
 * @param path *u8 — file path, or null
 * @return i32 — 1 when this is the lsp main path
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_path_is_lsp_main_x(path: *u8): i32 {
  return w1530_path_class(path, 1);
}

/**
 * Append text to a CodegenOutBuf. The length field is at byte 9437184. Loops only, so this strong body has no call.
 * @param out_buf *u8 — CodegenOutBuf, or null
 * @param text *u8 — NUL-terminated text, or null
 * @return i32 — 0, or -1 when null or the 9MiB cap would overflow
 * PLATFORM: SHARED
 */
#[no_mangle]
export function append_text_to_codegen_buf(out_buf: *u8, text: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let length: i32 = 0;
  let lenp: *i32 = 0 as *i32;
  if (out_buf == 0 as *u8) {
    return 0 - 1;
  }
  if (text == 0 as *u8) {
    return 0 - 1;
  }
  // CodegenOutBuf.length sits after unsigned char data[9 * 1024 * 1024].
  // PLATFORM: SHARED.
  lenp = (out_buf + 9437184) as *i32;
  length = lenp[0];
  if (length < 0) {
    return 0 - 1;
  }
  while (text[n] != 0) {
    n = n + 1;
  }
  if ((length as usize) + (n as usize) >= 9437184) {
    return 0 - 1;
  }
  while (i < n) {
    out_buf[length + i] = text[i];
    i = i + 1;
  }
  lenp[0] = length + n;
  return 0;
}

/**
 * Write the heap-alias -E-extern block. Bytes match the C seed. One write.
 * @param out_ptr *u8 — stream handle, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_heap_alias_block(out_ptr: *u8): void {
  let s: *u8 = "\n/* lsp_codegen_extern: std.heap typeck 链接别名（C-04 v0；std_io extern 由 codegen 自动生成） */\nextern uint8_t *typeck_std_heap_alloc(size_t size);\nextern void typeck_std_heap_free(uint8_t *ptr);\n#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n";
  let n: i32 = 0;
  let h: i64 = 0;
  let fd: i32 = 0 - 1;
  if (out_ptr == 0 as *u8) {
    return;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  h = out_ptr as i64;
  if (h != 0) {
    fd = (h as i32) - 1;
  }
  w1530_host_write(fd, s, n);
}

/**
 * Write the io-extern -E-extern block. Bytes match the C seed. One write.
 * @param out_ptr *u8 — stream handle, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_io_extern_block(out_ptr: *u8): void {
  let s: *u8 = "\n/* lsp_codegen_extern: deprecated full io block — 保留给旧 bootstrap 路径 */\nextern int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\nextern int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\nextern void lsp_debug_u32(uint32_t n);\n#define typeck_lsp_debug_u32 lsp_debug_u32\nextern void lsp_debug_ptr(uint8_t *p);\n#define typeck_lsp_debug_ptr lsp_debug_ptr\nextern uint8_t *typeck_std_heap_alloc(size_t size);\nextern void typeck_std_heap_free(uint8_t *ptr);\n#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n";
  let n: i32 = 0;
  let h: i64 = 0;
  let fd: i32 = 0 - 1;
  if (out_ptr == 0 as *u8) {
    return;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  h = out_ptr as i64;
  if (h != 0) {
    fd = (h as i32) - 1;
  }
  w1530_host_write(fd, s, n);
}

/**
 * Write the gen-extern -E-extern block. Bytes match the C seed. One write.
 * @param out_ptr *u8 — stream handle, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_gen_extern_block(out_ptr: *u8): void {
  let s: *u8 = "\n/* lsp_codegen_extern: lsp.x -E-extern stubs (lsp_io_x.o 符号桥接) */\nextern ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);\nextern ptrdiff_t typeck_write_fd(int32_t fd, uint8_t *ptr, size_t count);\nextern uint8_t *typeck_lsp_alloc(size_t size);\nextern void typeck_lsp_free(uint8_t *ptr);\nextern int32_t typeck_lsp_is_null(uint8_t *ptr);\nextern int32_t typeck_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap);\nstatic inline ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {\n  return typeck_read_message(fd, body_out, body_cap, state_buf);\n}\nstatic inline ptrdiff_t lsp_io_write_fd(int32_t fd, uint8_t *ptr, size_t count) {\n  return typeck_write_fd(fd, ptr, count);\n}\nstatic inline uint8_t *lsp_io_lsp_alloc(size_t size) {\n  return typeck_lsp_alloc(size);\n}\nstatic inline void lsp_io_lsp_free(uint8_t *ptr) {\n  typeck_lsp_free(ptr);\n}\nstatic inline int32_t lsp_io_lsp_is_null(uint8_t *ptr) {\n  return typeck_lsp_is_null(ptr);\n}\nstatic inline int32_t lsp_io_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap) {\n  return typeck_extract_document_text(body, body_len, out_buf, out_cap);\n}\n";
  let n: i32 = 0;
  let h: i64 = 0;
  let fd: i32 = 0 - 1;
  if (out_ptr == 0 as *u8) {
    return;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  h = out_ptr as i64;
  if (h != 0) {
    fd = (h as i32) - 1;
  }
  w1530_host_write(fd, s, n);
}

/**
 * Append the heap-alias block. Strong. One call.
 * @param out_buf *u8 — CodegenOutBuf, or null
 * @return i32 — 0, or -1 from append_text_to_codegen_buf
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_heap_alias_to_buf(out_buf: *u8): i32 {
  let s: *u8 = "\n/* lsp_codegen_extern: std.heap typeck 链接别名（C-04 v0；std_io extern 由 codegen 自动生成） */\nextern uint8_t *typeck_std_heap_alloc(size_t size);\nextern void typeck_std_heap_free(uint8_t *ptr);\n#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n";
  return append_text_to_codegen_buf(out_buf, s);
}

/**
 * Append the io-extern block. Strong. One call.
 * @param out_buf *u8 — CodegenOutBuf, or null
 * @return i32 — 0, or -1 from append_text_to_codegen_buf
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_io_extern_to_buf(out_buf: *u8): i32 {
  let s: *u8 = "\n/* lsp_codegen_extern: deprecated full io block — 保留给旧 bootstrap 路径 */\nextern int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\nextern int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\nextern void lsp_debug_u32(uint32_t n);\n#define typeck_lsp_debug_u32 lsp_debug_u32\nextern void lsp_debug_ptr(uint8_t *p);\n#define typeck_lsp_debug_ptr lsp_debug_ptr\nextern uint8_t *typeck_std_heap_alloc(size_t size);\nextern void typeck_std_heap_free(uint8_t *ptr);\n#define std_heap_alloc typeck_std_heap_alloc\n#define std_heap_free typeck_std_heap_free\n";
  return append_text_to_codegen_buf(out_buf, s);
}

/**
 * Append the gen-extern block. Strong. One call.
 * @param out_buf *u8 — CodegenOutBuf, or null
 * @return i32 — 0, or -1 from append_text_to_codegen_buf
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lsp_codegen_emit_gen_extern_to_buf(out_buf: *u8): i32 {
  let s: *u8 = "\n/* lsp_codegen_extern: lsp.x -E-extern stubs (lsp_io_x.o 符号桥接) */\nextern ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);\nextern ptrdiff_t typeck_write_fd(int32_t fd, uint8_t *ptr, size_t count);\nextern uint8_t *typeck_lsp_alloc(size_t size);\nextern void typeck_lsp_free(uint8_t *ptr);\nextern int32_t typeck_lsp_is_null(uint8_t *ptr);\nextern int32_t typeck_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap);\nstatic inline ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {\n  return typeck_read_message(fd, body_out, body_cap, state_buf);\n}\nstatic inline ptrdiff_t lsp_io_write_fd(int32_t fd, uint8_t *ptr, size_t count) {\n  return typeck_write_fd(fd, ptr, count);\n}\nstatic inline uint8_t *lsp_io_lsp_alloc(size_t size) {\n  return typeck_lsp_alloc(size);\n}\nstatic inline void lsp_io_lsp_free(uint8_t *ptr) {\n  typeck_lsp_free(ptr);\n}\nstatic inline int32_t lsp_io_lsp_is_null(uint8_t *ptr) {\n  return typeck_lsp_is_null(ptr);\n}\nstatic inline int32_t lsp_io_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap) {\n  return typeck_extract_document_text(body, body_len, out_buf, out_cap);\n}\n";
  return append_text_to_codegen_buf(out_buf, s);
}

/**
 * Write the stub usage line to fd 1. The text is 43 bytes, so this is one write and no length call.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function driver_print_usage_c(): void {
  let s: *u8 = "Xlang (stub)\nUsage: xlang [options] file.x\n";
  w1530_host_write(1, s, 43);
}

/**
 * Cold dump of an empty WPO graph. Ignores the module arguments. One write.
 * @param out_ptr *u8 — stream handle, or null
 * @param entry_ptr *u8 — ignored
 * @param entry_path *u8 — ignored
 * @param all_mods *u8 — ignored
 * @param all_paths *u8 — ignored
 * @param n_all i32 — ignored
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_dump_wpo_callgraph_json(out_ptr: *u8, entry_ptr: *u8, entry_path: *u8, all_mods: *u8, all_paths: *u8, n_all: i32): void {
  let s: *u8 = "{\"version\":2,\"nodes\":[]}\n";
  let n: i32 = 0;
  let h: i64 = 0;
  let fd: i32 = 0 - 1;
  if (out_ptr == 0 as *u8) {
    return;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  h = out_ptr as i64;
  if (h != 0) {
    fd = (h as i32) - 1;
  }
  w1530_host_write(fd, s, n);
}

/**
 * Cold lexer step. Writes TOKEN_EOF at line 1 col 1. lex is ignored.
 * @param lex *u8 — ignored lexer
 * @param out_tok *u8 — Token out, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function lexer_next(lex: *u8, out_tok: *u8): void {
  let p: *i32 = 0 as *i32;
  if (out_tok == 0 as *u8) {
    return;
  }
  // Token on a 64-bit ABI: kind 0, line 4, col 8, ident_len 24.
  // Written as i32 slots so X struct padding is not the layout.
  // PLATFORM: SHARED.
  p = out_tok as *i32;
  p[0] = 0;
  p[1] = 1;
  p[2] = 1;
  p[6] = 0;
}

/**
 * Cold preprocess. Returns null and writes 0 through out_length when it is non-null.
 * @param source *u8 — ignored
 * @param source_len usize — ignored
 * @param defines *u8 — ignored
 * @param ndefines i32 — ignored
 * @param out_length *usize — optional length out
 * @return *u8 — null
 * PLATFORM: SHARED
 */
#[no_mangle]
export function preprocess(source: *u8, source_len: usize, defines: *u8, ndefines: i32, out_length: *usize): *u8 {
  if (out_length != 0 as *usize) {
    out_length[0] = 0;
  }
  return 0 as *u8;
}

/**
 * Cold import-path stub. Writes a NUL when path_buf is non-null.
 * @param module_ptr *u8 — ignored
 * @param idx i32 — ignored
 * @param path_buf *u8 — first byte cleared, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_get_module_import_path(module_ptr: *u8, idx: i32, path_buf: *u8): void {
  if (path_buf != 0 as *u8) {
    path_buf[0] = 0;
  }
}

/**
 * Cold parse. ok is 0 and main_idx is -1, packed into the register C uses for that struct.
 * @param arena_ptr *u8 — ignored
 * @param module_ptr *u8 — ignored
 * @param source *u8 — ignored
 * @return i64 — ok in the low half, main_idx -1 in the high half
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_parse_into(arena_ptr: *u8, module_ptr: *u8, source: *u8): i64 {
  let hi: i64 = 0 - 1;
  // C returns struct { i32 ok; i32 main_idx } in one register.
  // An X struct return is a stack pointer, so the two i32s are packed:
  // low 32 bits are 0, high 32 bits are -1.
  // PLATFORM: SHARED.
  return hi << 32;
}

/**
 * Cold used-set. Writes 0 through n_used_out when it is non-null.
 * @param entry_ptr *u8 — ignored
 * @param dep_mods *u8 — ignored
 * @param ndep i32 — ignored
 * @param used_out *u8 — ignored
 * @param n_used_out *i32 — optional count out
 * @param max_used i32 — ignored
 * @param used_mono *u8 — ignored
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_compute_used(entry_ptr: *u8, dep_mods: *u8, ndep: i32, used_out: *u8, n_used_out: *i32, max_used: i32, used_mono: *u8): void {
  if (n_used_out != 0 as *i32) {
    n_used_out[0] = 0;
  }
}

/**
 * Cold used-type set. Writes 0 through n_out when it is non-null.
 * @param entry_ptr *u8 — ignored
 * @param dep_mods *u8 — ignored
 * @param ndep i32 — ignored
 * @param used_funcs *u8 — ignored
 * @param n_used i32 — ignored
 * @param names_out *u8 — ignored
 * @param n_out *i32 — optional count out
 * @param max_types i32 — ignored
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_compute_used_types(entry_ptr: *u8, dep_mods: *u8, ndep: i32, used_funcs: *u8, n_used: i32, names_out: *u8, n_out: *i32, max_types: i32): void {
  if (n_out != 0 as *i32) {
    n_out[0] = 0;
  }
}

/**
 * Cold WPO reach. Zeros 69648 bytes and sets root_id to -1. One memset.
 * @param out_ptr *u8 — CodegenWpoReach, or null
 * @param entry_ptr *u8 — ignored
 * @param all_mods *u8 — ignored
 * @param n_all i32 — ignored
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function codegen_wpo_reach_compute(out_ptr: *u8, entry_ptr: *u8, all_mods: *u8, n_all: i32): void {
  let rp: *i32 = 0 as *i32;
  if (out_ptr == 0 as *u8) {
    return;
  }
  // CodegenWpoReach is 69648 bytes. root_id is the i32 at byte 69636.
  // One memset, then the -1 store. PLATFORM: SHARED.
  unsafe {
    memset(out_ptr, 0, 69648);
  }
  rp = (out_ptr + 69636) as *i32;
  rp[0] = 0 - 1;
}

/**
 * Forward skip to driver_skip_codegen_dep_0_get. The ensure weakens this so runtime_asm_build.o's strong copy wins when both are linked. One call.
 * @return i32 — the driver skip flag
 * PLATFORM: SHARED
 */
#[no_mangle]
export function asm_driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    return driver_skip_codegen_dep_0_get();
  }
  return 0;
}

/**
 * Forward the dep path. Weakened with the skip getter. One call.
 * @param path *u8 — dep path bytes
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function asm_driver_set_current_dep_path_for_codegen(path: *u8): void {
  unsafe {
    driver_set_current_dep_path_for_codegen(path);
  }
}

/**
 * Write a labeled statement's name and goto target. Strong. One call, to pipeline_block_labeled_ptr, then copy loops.
 * @param arena_ptr *u8 — arena, or null
 * @param br i32 — block ref
 * @param li i32 — labeled index; negative returns
 * @param label *u8 — label bytes, or null
 * @param label_len i32 — label byte count
 * @param goto_target *u8 — goto target bytes, or null
 * @param goto_target_len i32 — goto target byte count
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_labeled_set_names(arena_ptr: *u8, br: i32, li: i32, label: *u8, label_len: i32, goto_target: *u8, goto_target_len: i32): void {
  let ls: *u8 = 0 as *u8;
  let i: i32 = 0;
  let lp: *i32 = 0 as *i32;
  if (arena_ptr == 0 as *u8) {
    return;
  }
  if (li < 0) {
    return;
  }
  ls = pipeline_block_labeled_ptr(arena_ptr, br, li);
  if (ls == 0 as *u8) {
    return;
  }
  // LabeledStmt: label[256] at 0, label_len at 256, goto_target[256] at 264,
  // goto_target_len at 520. Lengths above 255 clamp to 127, matching the C.
  // PLATFORM: SHARED.
  if (label != 0 as *u8 && label_len > 0) {
    if (label_len > 255) {
      label_len = 127;
    }
    i = 0;
    while (i < label_len) {
      ls[i] = label[i];
      i = i + 1;
    }
    ls[label_len] = 0;
    lp = (ls + 256) as *i32;
    lp[0] = label_len;
  }
  if (goto_target != 0 as *u8 && goto_target_len > 0) {
    if (goto_target_len > 255) {
      goto_target_len = 127;
    }
    i = 0;
    while (i < goto_target_len) {
      ls[264 + i] = goto_target[i];
      i = i + 1;
    }
    ls[264 + goto_target_len] = 0;
    lp = (ls + 520) as *i32;
    lp[0] = goto_target_len;
  }
}

/**
 * Copy one import path and return its length, at most 64. One call.
 * @param module_ptr *u8 — module, or null
 * @param idx i32 — import index
 * @param out_buf *u8 — at least 64 bytes, or null
 * @return i32 — byte count before the NUL, or 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_copy_module_import_path64(module_ptr: *u8, idx: i32, out_buf: *u8): i32 {
  let n: i32 = 0;
  if (out_buf == 0 as *u8) {
    return 0;
  }
  if (module_ptr == 0 as *u8) {
    out_buf[0] = 0;
    return 0;
  }
  unsafe {
    pipeline_module_import_path_copy(module_ptr, idx, out_buf, 64);
  }
  while (n < 64) {
    if (out_buf[n] == 0) {
      return n;
    }
    n = n + 1;
  }
  return n;
}

/**
 * Forward to ast_pipeline_dep_ctx_set_import_path so a strong body of that name still runs. One call.
 * @param ctx *u8 — dep context
 * @param idx i32 — dep index
 * @param bytes_ptr *u8 — path bytes
 * @param len i32 — path length
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes_ptr: *u8, len: i32): void {
  ast_pipeline_dep_ctx_set_import_path(ctx, idx, bytes_ptr, len);
}

/**
 * Cold dep-path copy. Zeros 64 bytes. The context is ignored.
 * @param ctx *u8 — ignored
 * @param idx i32 — ignored
 * @param dst *u8 — 64 bytes cleared, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void {
  let i: i32 = 0;
  if (dst == 0 as *u8) {
    return;
  }
  while (i < 64) {
    dst[i] = 0;
    i = i + 1;
  }
}

/**
 * Cold function-name copy. Zeros 64 bytes.
 * @param module_ptr *u8 — ignored
 * @param fi i32 — ignored
 * @param dst *u8 — 64 bytes cleared, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_copy64(module_ptr: *u8, fi: i32, dst: *u8): void {
  let i: i32 = 0;
  if (dst == 0 as *u8) {
    return;
  }
  while (i < 64) {
    dst[i] = 0;
    i = i + 1;
  }
}

/**
 * Cold function-name byte. Always 0.
 * @param module_ptr *u8 — ignored
 * @param fi i32 — ignored
 * @param i i32 — ignored
 * @return u8 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_byte_at(module_ptr: *u8, fi: i32, i: i32): u8 {
  return 0;
}

/**
 * Cold arena size. The product value is 4096.
 * @return usize — 4096
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_sizeof_arena(): usize {
  return 4096;
}

/**
 * Cold module size. The product value is 4096.
 * @return usize — 4096
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_sizeof_module(): usize {
  return 4096;
}

/**
 * Clear the cold -D count. The 8192-byte table is left in place.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function preprocess_define_reset(): void {
  g_ndefines[0] = 0;
}

/**
 * Append one -D name, including its NUL, when the count is below 128 and the name fits in 63 bytes. Loops only.
 * @param name *u8 — NUL-terminated name, or null
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function preprocess_define_add(name: *u8): void {
  let n: i32 = 0;
  let i: i32 = 0;
  let base: i32 = 0;
  if (name == 0 as *u8) {
    return;
  }
  if (g_ndefines[0] >= 128) {
    return;
  }
  while (name[n] != 0) {
    n = n + 1;
  }
  if (n == 0) {
    return;
  }
  if (n >= 64) {
    return;
  }
  base = g_ndefines[0] * 64;
  while (i <= n) {
    g_defines[base + i] = name[i];
    i = i + 1;
  }
  g_ndefines[0] = g_ndefines[0] + 1;
}

/**
 * True when sym[0..sym_len) is a stored -D name. The compare is a loop, not a call.
 * @param sym *u8 — name bytes, or null
 * @param sym_len i32 — byte count
 * @return i32 — 1 when the name is present
 * PLATFORM: SHARED
 */
#[no_mangle]
export function preprocess_define_has(sym: *u8, sym_len: i32): i32 {
  // Repeated here so this function makes no call. The exported
  // preprocess_define_has is the same loop; this compiler's frame does not
  // cover a second call in preprocess_eval_condition_c.
  // PLATFORM: SHARED.
  let hi: i32 = 0;
  let hk: i32 = 0;
  let hhit: i32 = 0;
  if (sym != 0 as *u8 && sym_len > 0 && sym_len < 64) {
    hi = 0;
    while (hi < g_ndefines[0]) {
      hk = 0;
      while (hk < sym_len) {
        if (g_defines[hi * 64 + hk] != sym[hk]) {
          hk = sym_len + 1;
        }
        if (hk <= sym_len) {
          if (g_defines[hi * 64 + hk] == 0) {
            hk = sym_len + 1;
          }
        }
        if (hk <= sym_len) {
          hk = hk + 1;
        }
      }
      if (hk == sym_len) {
        if (g_defines[hi * 64 + hk] == 0) {
          hhit = 1;
          hi = g_ndefines[0];
        }
      }
      if (hhit == 0) {
        hi = hi + 1;
      }
    }
  }
  return hhit;
}

/**
 * Cold #if condition. Trims space and tab, sends a complex expression to cfg_eval_expr_c, accepts a decimal literal, and otherwise uses the inlined -D loop. One call.
 * @param cond *u8 — condition bytes, or null
 * @param cond_len i32 — byte count
 * @return i32 — 1 when the condition is true
 * PLATFORM: SHARED
 */
#[no_mangle]
export function preprocess_eval_condition_c(cond: *u8, cond_len: i32): i32 {
  let k: i32 = 0;
  let c: u8 = 0;
  let trimming: i32 = 1;
  let all_digits: i32 = 0;
  let lit_true: i32 = 0;
  let complex: i32 = 0;
  let ev: i32 = 0;
  if (cond == 0 as *u8) {
    return 0;
  }
  if (cond_len <= 0) {
    return 0;
  }
  while (cond_len > 0 && trimming == 1) {
    c = cond[0];
    if (c == 32 || c == 9) {
      cond = cond + 1;
      cond_len = cond_len - 1;
    }
    if (c != 32 && c != 9) {
      trimming = 0;
    }
  }
  trimming = 1;
  while (cond_len > 0 && trimming == 1) {
    c = cond[cond_len - 1];
    if (c == 32 || c == 9) {
      cond_len = cond_len - 1;
    }
    if (c != 32 && c != 9) {
      trimming = 0;
    }
  }
  if (cond_len <= 0) {
    return 0;
  }
  k = 0;
  while (k < cond_len) {
    c = cond[k];
    if (c == 32 || c == 9 || c == 61 || c == 33 || c == 40 || c == 41) {
      complex = 1;
      k = cond_len;
    }
    if (complex == 0) {
      k = k + 1;
    }
  }
  if (complex == 1) {
    unsafe {
      ev = cfg_eval_expr_c(cond, cond_len);
    }
    if (ev != 0) {
      return 1;
    }
    return 0;
  }
  all_digits = 1;
  lit_true = 0;
  k = 0;
  while (k < cond_len) {
    c = cond[k];
    if (c < 48 || c > 57) {
      all_digits = 0;
      k = cond_len;
    }
    if (all_digits == 1) {
      if (c != 48) {
        lit_true = 1;
      }
      k = k + 1;
    }
  }
  if (all_digits == 1) {
    return lit_true;
  }
  // Repeated here so this function makes no call. The exported
  // preprocess_define_has is the same loop; this compiler's frame does not
  // cover a second call in preprocess_eval_condition_c.
  // PLATFORM: SHARED.
  let hi: i32 = 0;
  let hk: i32 = 0;
  let hhit: i32 = 0;
  if (cond != 0 as *u8 && cond_len > 0 && cond_len < 64) {
    hi = 0;
    while (hi < g_ndefines[0]) {
      hk = 0;
      while (hk < cond_len) {
        if (g_defines[hi * 64 + hk] != cond[hk]) {
          hk = cond_len + 1;
        }
        if (hk <= cond_len) {
          if (g_defines[hi * 64 + hk] == 0) {
            hk = cond_len + 1;
          }
        }
        if (hk <= cond_len) {
          hk = hk + 1;
        }
      }
      if (hk == cond_len) {
        if (g_defines[hi * 64 + hk] == 0) {
          hhit = 1;
          hi = g_ndefines[0];
        }
      }
      if (hhit == 0) {
        hi = hi + 1;
      }
    }
  }
  return hhit;

}

/**
 * Copy one import path into g_fill_path and store its length. One call.
 * @param module_ptr *u8 — module
 * @param dep_j i32 — dep index
 * @return i32 — path length
 * PLATFORM: SHARED
 */
#[no_mangle]
function w1530_fill_copy(module_ptr: *u8, dep_j: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let p: *u8 = 0 as *u8;
  while (i < 128) {
    g_fill_path[i] = 0;
    i = i + 1;
  }
  p = &g_fill_path[0];
  parser_copy_module_import_path64(module_ptr, dep_j, p);
  while (n < 64) {
    if (g_fill_path[n] == 0) {
      g_fill_len[0] = n;
      return n;
    }
    n = n + 1;
  }
  g_fill_len[0] = n;
  return n;
}

/**
 * Set the staged import path when its length is positive. One call.
 * @param ctx *u8 — dep context
 * @param dep_j i32 — dep index
 * @return i32 — 0
 * PLATFORM: SHARED
 */
#[no_mangle]
function w1530_fill_set(ctx: *u8, dep_j: i32): i32 {
  let n: i32 = 0;
  let p: *u8 = 0 as *u8;
  n = g_fill_len[0];
  if (n > 0) {
    p = &g_fill_path[0];
    pipeline_dep_ctx_set_import_path(ctx, dep_j, p, n);
  }
  return 0;
}

/**
 * Cold fill of one dep import path. Returns -1 when module, ctx, or the index is unusable.
 * @param module_ptr *u8 — module, or null
 * @param ctx *u8 — dep context, or null
 * @param dep_j i32 — dep index
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
#[no_mangle]
export function run_x_pipeline_fill_dep_import_path_c(module_ptr: *u8, ctx: *u8, dep_j: i32): i32 {
  let pad: u8[64] = [];
  pad[0] = 0;
  if (module_ptr == 0 as *u8) {
    return 0 - 1;
  }
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  if (dep_j < 0) {
    return 0 - 1;
  }
  // The path lives in g_fill_path, not in this frame. The pad is the slot
  // the Darwin frame does not cover. Copy then set.
  // PLATFORM: SHARED.
  w1530_fill_copy(module_ptr, dep_j);
  return w1530_fill_set(ctx, dep_j);
}

/**
 * Pointer to one 128-byte scratch slot. slot is clamped to 0..15.
 * @param slot i32 — slot index
 * @return *u8 — slot address
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_scratch64_slot(slot: i32): *u8 {
  if (slot < 0) {
    slot = 0;
  }
  if (slot >= 16) {
    slot = 15;
  }
  return &g_scratch[slot * 128];
}

/**
 * Pointer to the size metric slot.
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_sz_slot(): *i32 {
  return &g_sz_slot[0];
}

/**
 * Pointer to the align metric slot. The slot starts at 1.
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_al_slot(): *i32 {
  return &g_al_slot[0];
}

/**
 * Pointer to the size metric at depth. depth is clamped to 0..63.
 * @param depth i32 — depth
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_sz_slot_depth(depth: i32): *i32 {
  let d: i32 = depth;
  if (d < 0) { d = 0; }
  if (d >= 64) { d = 63; }
  return &g_sz_depth[d];
}

/**
 * Pointer to the align metric at depth. depth is clamped to 0..63.
 * @param depth i32 — depth
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_al_slot_depth(depth: i32): *i32 {
  let d: i32 = depth;
  if (d < 0) { d = 0; }
  if (d >= 64) { d = 63; }
  return &g_al_depth[d];
}

/**
 * Set the size metric at depth to 0 and the align metric to 1. No call.
 * @param depth i32 — depth
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_init_depth(depth: i32): void {
  let d: i32 = depth;
  if (d < 0) { d = 0; }
  if (d >= 64) { d = 63; }
  g_sz_depth[d] = 0;
  g_al_depth[d] = 1;
}

/**
 * Read the align metric at depth.
 * @param depth i32 — depth
 * @return i32 — stored align
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_al_read_depth(depth: i32): i32 {
  let d: i32 = depth;
  if (d < 0) { d = 0; }
  if (d >= 64) { d = 63; }
  return g_al_depth[d];
}

/**
 * Read the size metric at depth.
 * @param depth i32 — depth
 * @return i32 — stored size
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_sz_read_depth(depth: i32): i32 {
  let d: i32 = depth;
  if (d < 0) { d = 0; }
  if (d >= 64) { d = 63; }
  return g_sz_depth[d];
}

/**
 * Set the scalar size metric to 0 and the align metric to 1.
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_layout_metrics_init_slot(): void {
  g_sz_slot[0] = 0;
  g_al_slot[0] = 1;
}

/**
 * Store v through p when p is non-null.
 * @param p *i32 — slot, or null
 * @param v i32 — value
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_i32_ptr_store(p: *i32, v: i32): void {
  if (p != 0 as *i32) {
    p[0] = v;
  }
}

/**
 * Read through p. A null p returns 0.
 * @param p *i32 — slot, or null
 * @return i32 — stored value, or 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_i32_ptr_read(p: *i32): i32 {
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

/**
 * Forward a diagnostic marker. One call.
 * @param id i32 — marker id
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_driver_diagnostic_pipe_marker(id: i32): void {
  unsafe {
    driver_diagnostic_pipe_marker(id);
  }
}

/**
 * Pointer to the call-resolve dep index.
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_call_resolve_dep_idx_slot(): *i32 {
  return &g_dep_idx[0];
}

/**
 * Pointer to the call-resolve func index.
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_call_resolve_func_idx_slot(): *i32 {
  return &g_func_idx[0];
}

/**
 * Pointer to the overload expected-return slot.
 * @return *i32 — slot
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_overload_expected_ret_slot(): *i32 {
  return &g_over_ret[0];
}

/**
 * Read the call-resolve dep index.
 * @return i32 — stored index
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_call_resolve_dep_idx_peek(): i32 {
  return g_dep_idx[0];
}

/**
 * Read the call-resolve func index.
 * @return i32 — stored index
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_call_resolve_func_idx_peek(): i32 {
  return g_func_idx[0];
}

/**
 * Read the overload expected-return slot.
 * @return i32 — stored type id
 * PLATFORM: SHARED
 */
#[no_mangle]
export function typeck_overload_expected_ret_peek(): i32 {
  return g_over_ret[0];
}

