// Thin pure: peel REST index_addr only (peers via leftover/helpers).
// G.7: body MUST match glue_binop_operand_index_addr_clobbers_rbx_elf_c
// in binop_block_peel_thin.x / mega.
// wave426: Darwin -c ~3561B; LINUX HARD BAN (Ubuntu asm -c empty .o RC=0).
//   Confirms w423 note; no product overlay.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

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
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_try_binop_load_operand_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;

/**
 * wave149 pure: G.7 authority (was pipeline_asm_emit_binop.c::glue_binop_operand_index_addr_clobbers_rbx_elf_c).
 * @param arena *u8 - parameter
 * @param expr_ref i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 */
export function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let lit_slot: i32[1] = [];
    let lit_ok_w149: i32 = 0;

    let ko: i32 = 0;
    let op_ref: i32 = 0;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      return 0;
    }
    op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    if (op_ref > 0) {
      return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if ((glue_expr_is_await_at_c(arena, expr_ref)) != 0) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if ((glue_expr_is_x_as_cast_at_c(arena, expr_ref)) != 0) {
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    /* wave625: FIELD of INDEX still runs INDEX bounds/addr in rbx (a[i].x dual-slot). */
    if (ko == 44) {
      op_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    /* DEREF of INDEX / slice: lvalue emits the operand pointer; INDEX
     * / slice operand uses rbx. Walk the operand (same as FIELD).
     * DEREF of VAR is rax-only. dest-in-rbx `*p = *q` of a 16B named
     * struct reuses this park.
     * PLATFORM: SHARED — park dest before DEREF-of-INDEX lvalue. */
    if (ko == 52) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if (ko == 47) {
      let idx_ref: i32 = 0;
      let lit_dummy: i32 = 0;
          let base_ref: i32 = 0;
      let base_ty: i32 = 0;
      let base_ko: i32 = 0;
      if (pipeline_expr_index_base_is_slice_at(arena, expr_ref) != 0) {
        return 1;
      }
      base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
      if (base_ref > 0) {
        base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
        if (base_ty > 0 && pipeline_type_kind_ord_at(arena, base_ty) == 11) {
          return 1;
        }
        /*
         * Materializing bases park payload/home in rbx while writing temps.
         * ARRAY_LIT (46): emit_array_lit mov rax→rbx for store loop.
         * STRUCT_LIT (45) / CALL (48) / METHOD (49): call_base / struct temp same.
         * Nested INDEX (47) / FIELD (44) of those: recurse via base walk below.
         * Only VAR / pure FIELD-of-VAR can take base+imm*esz without touching rbx.
         */
        base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
        if (base_ko == 46 || base_ko == 45 || base_ko == 48 || base_ko == 49) {
          return 1;
        }
        if (base_ko == 47) {
          return 1;
        }
        if (base_ko == 44) {
          let fa_base: i32 = pipeline_expr_field_access_base_ref(arena, base_ref);
          if (fa_base > 0) {
            let fa_ko: i32 = pipeline_expr_kind_ord_at(arena, fa_base);
            /* FIELD of materializing root (Wrap{}.xs[i] dual-slot) also parks rbx. */
            if (fa_ko == 46 || fa_ko == 45 || fa_ko == 48 || fa_ko == 49 || fa_ko == 47) {
              return 1;
            }
          }
        }
      }
      idx_ref = pipeline_expr_index_index_ref(arena, expr_ref);
      /* Fixed TYPE_ARRAY + lit index on VAR/FIELD base: base+imm*esz, bounds CTFE — no rbx. */
      if (idx_ref > 0 && (pipeline_asm_cmp_expr_lit_i32_at(arena, idx_ref, &lit_slot[0]) != 0)) {
        return 0;
      }
      return 1;
    }
    return 0;
  }
}
