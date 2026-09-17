// Thin pure: arr_return dispatcher (wave439).
// G.7: body MUST match pipeline_asm_emit_return_elf_impl (peer-flat).
// wave427: Darwin -c green; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// wave439: LINUX PREFER — flat peer path helpers + this dispatcher.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_return_path_a0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_a2_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_a_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_b0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_b_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_d_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;

/**
 * EXPR_RETURN ELF emit impl (sret / slice escape / ARRAY_LIT dual-GP / float / tail_join).
 * wave439: flat peer dispatch — Ubuntu emptied on co-located Path arms.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param expr_ref i32 — EXPR_RETURN
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let ly: *u8 = 0 as *u8;
    let ret_op: i32 = 0;
    let sret_act: i32 = 0;
    let sret_sz: i32 = 0;
    let ko: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let fi: i32 = 0;
    let rc: i32 = 0;
    let tj_len: i32 = 0;
    let tj_lbl: u8[128] = [];
    let ti: i32 = 0;
    ly = pipeline_asm_ctx_layout(ctx);
    ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (ret_op != 0) {
      ret_op = glue_peel_as_array_slice_ascription_c(arena, ret_op);
      sret_act = pipeline_asm_emit_ctx_sret_active_get();
      sret_sz = pipeline_asm_emit_ctx_sret_ret_sz_get();
      ko = pipeline_expr_kind_ord_at(arena, ret_op);
      mod = pipeline_asm_emit_module_ref_c();
      fi = pipeline_asm_emit_func_index_c();
      // Flat sequential try — first non-zero wins (1=ok, -1=err).
      rc = glue_emit_return_path_a0_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      if (rc == 0) {
        rc = glue_emit_return_path_a_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc == 0) {
        rc = glue_emit_return_path_a2_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc == 0) {
        rc = glue_emit_return_path_b0_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc == 0) {
        rc = glue_emit_return_path_b_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc == 0) {
        rc = glue_emit_return_path_c_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc == 0) {
        rc = glue_emit_return_path_d_elf_c(arena, elf_ctx, ret_op, ctx, ta, ko, sret_act, sret_sz, mod, fi);
      }
      if (rc < 0) {
        return 0 - 1;
      }
    }
    rc = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_async_cps_emit_phase_reset(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ly == (0 as *u8)) {
      return 0 - 1;
    }
    tj_len = pipe_load_i32_le(ly, 1520);
    if (tj_len <= 0) {
      return 0 - 1;
    }
    ti = 0;
    while (ti < tj_len && ti < 128) {
      tj_lbl[ti] = ly[1392 + ti];
      ti = ti + 1;
    }
    return backend_enc_jmp_arch(elf_ctx, &tj_lbl[0], tj_len, ta);
  }
}
