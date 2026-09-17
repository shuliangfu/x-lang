// Thin pure: binop_block_peel HELPERS leaf (transparent EXPR_BLOCK peel only).
// G.7: body MUST match glue_expr_block_transparent_value_ref_at in
// runtime_pipeline_abi.x / runtime_pipeline_abi_binop_block_peel_thin.x.
// ensure: pipeline_abi_inject_binop_block_peel_thin dispatches this on LINUX.
// wave417: LINUX PREFER first-export-only (full tip -c T001/XT001 misattr;
//   peel_e1 -c green ~3294B). MACOS still full thin PREFER.
//   Remaining peel exports tip reinject still BAN on LINUX.
// PLATFORM: SHARED freestanding asm emit · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function asm_module_top_level_const_lit_i32(mod: *u8, arena: *u8, name: *u8, nlen: i32, out: *i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function glue_asm73_evict_cache_if_live_pressure_elf_c(ta: i32, elf_ctx: *u8): void;
export extern function glue_binop_var_slot_cache_hit_rbx(ctx: *u8, off: i32): i32;
export extern function glue_binop_try_reload_spill_off_elf_c(elf_ctx: *u8, ctx: *u8, off: i32, ta: i32, to_rbx: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_asm73_var_prefers_stack_spill(off: i32): i32;
export extern function glue_binop_stack_spill_push_elf_c(elf_ctx: *u8, ta: i32, off: i32, which: i32): i32;
export extern function glue_binop_var_slot_cache_set_ctx_key(ctx: *u8): void;
export extern function glue_binop_var_slot_cache_set_rbx(ctx: *u8, off: i32): void;
export extern function glue_binop_var_slot_cache_hit_rax(ctx: *u8, off: i32): i32;
export extern function glue_load_f32_var_slot_to_rax_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_set_rax(ctx: *u8, off: i32): void;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_field_access_elf_fast_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_as_needs_full_emit_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_index_base_is_slice_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_expr_lit_i32_at_c(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;

/**
 * Transparent EXPR_BLOCK value for binop dual-slot.
 * `unsafe { e }` / `{ e }` parse as EXPR_BLOCK (26). Load_operand used to
 * return -2, so `x + unsafe { *q }` / `self.v + unsafe { *p[0] }` fell
 * through to emit_expr(BLOCK) after ARM64 rax frame-spill and CG002.
 * Only peel a single value expr with no lets/loops (no extra emit).
 * G.7: one peel helper, same role as await/AS unwrap. Walkers recurse.
 * @param arena *u8 — ASTArena*; null → 0
 * @param expr_ref i32 — candidate expr; <=0 → 0
 * @return i32 — inner value expr ref, or 0 if not a transparent block
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 exposes CG002
 */
export function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32 {
  let ko: i32 = 0;
  let br: i32 = 0;
  let nlet: i32 = 0;
  let nloop: i32 = 0;
  let nexpr: i32 = 0;
  let nso: i32 = 0;
  let so_k: i32 = 0;
  let so_idx: i32 = 0;
  let inner: i32 = 0;
  let fin: i32 = 0;
  if ((arena == (0 as *u8)) || expr_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  /* EXPR_BLOCK = 26 */
  if (ko != 26) {
    return 0;
  }
  unsafe {
    br = pipeline_expr_block_ref_at(arena, expr_ref);
  }
  if (br <= 0) {
    return 0;
  }
  unsafe {
    nlet = ast_ast_block_num_lets(arena, br);
    nloop = ast_ast_block_num_loops(arena, br);
    nexpr = ast_ast_block_num_expr_stmts(arena, br);
    nso = ast_ast_block_num_stmt_order(arena, br);
    fin = ast_ast_block_final_expr_ref(arena, br);
  }
  /* Extra lets/loops need body_sync — not a dual-slot peel. */
  if (nlet != 0 || nloop != 0) {
    return 0;
  }
  /* `unsafe { e }` primary: wrapper block, stmt_order kind 6 (region
   * pool; with_arena_cap=-1). Value is the inner body's final_expr.
   * Same region walk as dest-in-rbx BLOCK peel / typeck_block_expr_value_ref.
   * PLATFORM: SHARED — parser_asm_primary_parse_unsafe_expr_c. */
  if (nso == 1 && nexpr == 0 && fin <= 0) {
    unsafe {
      so_k = ast_ast_block_stmt_order_kind(arena, br, 0);
      so_idx = ast_ast_block_stmt_order_idx(arena, br, 0);
    }
    if (so_k == 6 && so_idx >= 0) {
      unsafe {
        inner = pipeline_block_region_body_ref(arena, br, so_idx);
      }
      if (inner > 0) {
        unsafe {
          nlet = ast_ast_block_num_lets(arena, inner);
          nloop = ast_ast_block_num_loops(arena, inner);
          fin = ast_ast_block_final_expr_ref(arena, inner);
        }
        if (nlet == 0 && nloop == 0 && fin > 0) {
          return fin;
        }
      }
    }
    return 0;
  }
  /* Bare `{ e }` block-expr: final_expr is the value. */
  if (nexpr <= 1 && fin > 0) {
    return fin;
  }
  return 0;
}

