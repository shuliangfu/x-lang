// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Cap tip ALE overlay: ast_to_elf_c that calls Cap mega_body (0xcb0 / ctx 1528).
// Replaces pabi_weak same-TU bl→stubdead after ALE prefer. PLATFORM: MACOS tip cold.

export extern function pipeline_elf_ctx_reset_data(elf_ctx: *u8): void;
export extern function pipeline_elf_ctx_emit_data_len(elf_ctx: *u8): i32;
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, m: *u8, a: *u8): void;
export extern function pipe_mod_get_num_top_level_lets(m: *u8): i32;
export extern function pipeline_module_hoist_top_level_lets_into_main(m: *u8, a: *u8): void;
export extern function typeck_merge_dep_struct_layouts_into_entry(m: *u8, a: *u8, pipeline_ctx: *u8): void;
export extern function typeck_wpo_unify_soa_layouts(m: *u8, pipeline_ctx: *u8): void;
export extern function pipeline_asm_emit_set_dep_pipe(pipeline_ctx: *u8): void;
export extern function pipeline_fill_array_lit_types_for_skipped_typeck(m: *u8, a: *u8): void;
export extern function pipeline_dep_ctx_target_arch(pipeline_ctx: *u8): i32;
export extern function pipeline_asm_emit_module_vtable_statics(elf_ctx: *u8, ta: i32, m: *u8, a: *u8): i32;
export extern function typeck_soa_fill_field_access_for_asm_emit(m: *u8, a: *u8): void;
export extern function glue_wpo_mono_reset_pending(): void;
export extern function pipeline_elf_label_mod_scope_begin_module(): void;
export extern function pipeline_asm_emit_set_module(m: *u8): void;
export extern function pipeline_asm_emit_set_arena(a: *u8): void;
export extern function pipeline_asm_emit_set_elf_ctx(elf_ctx: *u8): void;
export extern function pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8): i32;
export extern function pipeline_asm_emit_wpo_mono_thunks_elf_c(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8): i32;

/**
 * Cap tip ALE face: same contract as runtime_pipeline_abi.x ast_to_elf_c.
 * @return i32 — mega_body/wpo rc; -1 null
 * PLATFORM: MACOS tip cold · ALE overlay.
 */
#[no_mangle]
export function pipeline_backend_asm_codegen_ast_to_elf_c(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8): i32 {
  unsafe {
  if (m == (0 as *u8) || a == (0 as *u8) || elf_ctx == (0 as *u8) || pipeline_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  // A dep module shares this Mach-O object. Resetting a buffer that
  // already holds Lxml_ payload drops the bytes and leaves those symbols
  // as n_sect=2 with no __DATA segment (ld: section index out of bounds).
  // Reset only the empty buffer. PLATFORM: MACOS|DARWIN.
  let data_now: i32 = pipeline_elf_ctx_emit_data_len(elf_ctx);
  if (data_now <= 0) {
    pipeline_elf_ctx_reset_data(elf_ctx);
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  }
  let nlets: i32 = pipe_mod_get_num_top_level_lets(m);
  if (nlets > 0) {
    unsafe {
      pipeline_module_hoist_top_level_lets_into_main(m, a);
    }
  }
  unsafe {
    pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
    pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
    typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
    pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
    typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
    pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
    pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  }
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  {
    let ta_vtable: i32 = pipeline_dep_ctx_target_arch(pipeline_ctx);
    let vt_rc: i32 = pipeline_asm_emit_module_vtable_statics(elf_ctx, ta_vtable, m, a);
    if (vt_rc != 0) { return vt_rc; }
  }
  unsafe {
    typeck_soa_fill_field_access_for_asm_emit(m, a);
    glue_wpo_mono_reset_pending();
    pipeline_elf_label_mod_scope_begin_module();
    pipeline_asm_emit_set_module(m);
    pipeline_asm_emit_set_arena(a);
    pipeline_asm_emit_set_elf_ctx(elf_ctx);
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
    pipeline_asm_emit_set_elf_ctx(0 as *u8);
  }
  if (rc != 0) {
    return rc;
  }
  rc = pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
  return rc;
  }
}
