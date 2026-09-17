// Thin pure: peel REST try_binop_load_operand only.
// G.7: body MUST match glue_try_binop_load_operand_elf_c in peel_thin / mega.
// wave426: Darwin -c ~8633B; LINUX HARD BAN (Ubuntu asm -c empty .o RC=0).
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
export extern function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;

/**
 * wave149 pure: G.7 authority (was pipeline_asm_emit_binop.c::glue_try_binop_load_operand_elf_c).
 * @param arena *u8 - parameter
 * @param elf_ctx *u8 - parameter
 * @param expr_ref i32 - parameter
 * @param ctx *u8 - parameter
 * @param ta i32 - parameter
 * @param to_rbx i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 */
export function glue_try_binop_load_operand_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let ko: i32 = 0;
    let blk_inner: i32 = 0;
    let off: i32 = 0;
    let vr: i32 = 0;
    let base_ref: i32 = 0;
    if ((arena == (0 as *u8)) || (elf_ctx == (0 as *u8)) || (ctx == (0 as *u8)) || expr_ref <= 0) {
      return -2;
    }
    /* Peel unsafe { e } / { e } so DEREF/INDEX load as themselves (not BLOCK). */
    blk_inner = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    if (blk_inner > 0) {
      return glue_try_binop_load_operand_elf_c(arena, elf_ctx, blk_inner, ctx, ta, to_rbx);
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (ko == 3) {
      off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
      if (off < 0) {
        /*
         * Stage 12.2.6: module-level export const has no stack slot. Left-assoc
         * nested binops ((A+B)+C, W|C|T) call load_operand(to_rbx) after left@rax;
         * prior -2 made `rc != 0` hard-fail → CG002 on non-first funcs (first
         * often const-folds; later funcs still emit multi-const trees). Align with
         * emit_expr_elf_fast VAR path: top-level const lit → imm into rax/rbx.
         * PLATFORM: SHARED freestanding emit.
         */
        let vname: u8[256] = [];
        let vlen: i32 = pipeline_expr_var_name_len(arena, expr_ref);
        let mod_imm: i32 = 0;
        let mod: *u8 = 0 as *u8;
        if (vlen <= 0) {
          return -2;
        }
        pipeline_expr_var_name_into(arena, expr_ref, &vname[0]);
        mod = pipeline_asm_emit_module_ref_c();
        if (mod != 0 as *u8) {
          if (asm_module_top_level_const_lit_i32(mod, arena, &vname[0], vlen, &mod_imm) != 0) {
            if (to_rbx != 0) {
              if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, mod_imm, ta) != 0) {
                return -1;
              }
            } else {
              if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, mod_imm, ta) != 0) {
                return -1;
              }
            }
            return 0;
          }
        }
        return -2;
      }
      glue_asm73_evict_cache_if_live_pressure_elf_c(ta, elf_ctx);
      if (to_rbx != 0) {
        if ((glue_binop_var_slot_cache_hit_rbx(ctx, off) != 0)) {
          return 0;
        }
        vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 1);
        if (vr < 0) {
          return -1;
        }
        if (vr != 0) {
          return 0;
        }
        {
          let vtr: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
          if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
            if (glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0) {
              return -1;
            }
          } else if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, off, ta) != 0) {
            return -1;
          }
        }
        if (glue_asm73_var_prefers_stack_spill(off) != 0) {
          if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 1) != 0) {
            return -1;
          }
          glue_binop_var_slot_cache_set_ctx_key(ctx);
          return 0;
        }
        glue_binop_var_slot_cache_set_rbx(ctx, off);
        return 0;
      }
      if ((glue_binop_var_slot_cache_hit_rax(ctx, off) != 0)) {
        return 0;
      }
      vr = glue_binop_try_reload_spill_off_elf_c(elf_ctx, ctx, off, ta, 0);
      if (vr < 0) {
        return -1;
      }
      if (vr != 0) {
        return 0;
      }
      {
        let vtr: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
        if (vtr > 0 && pipeline_type_kind_ord_at(arena, vtr) == 14) {
          if (glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta) != 0) {
            return -1;
          }
        } else if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0) {
          return -1;
        }
      }
      if (glue_asm73_var_prefers_stack_spill(off) != 0) {
        if (glue_binop_stack_spill_push_elf_c(elf_ctx, ta, off, 0) != 0) {
          return -1;
        }
        glue_binop_var_slot_cache_set_ctx_key(ctx);
        return 0;
      }
      glue_binop_var_slot_cache_set_rax(ctx, off);
      return 0;
    }
    if (ko == 44) {
      if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0) {
        return -2;
      }
      base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
      /*c*/
      if (base_ref > 0 && pipeline_expr_kind_ord_at(arena, base_ref) == 47) {
        glue_binop_var_slot_cache_clear();
        vr = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
        if (vr == -99) {
          return -2;
        }
        if (vr != 0) {
          return -1;
        }
        if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
          return -1;
        }
        return 0;
      }
      if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3) {
        return -2;
      }
      glue_binop_var_slot_cache_clear();
      /*c*/
      vr = pipeline_asm_emit_field_access_elf_fast_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr == -99) {
        return -2;
      }
      if (vr != 0) {
        return -1;
      }
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
        return -1;
      }
      return 0;
    }
    if (ko == 47) {
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr != 0) {
        return -2;
      }
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
        return -1;
      }
      return 0;
    }
    /** wave323: *p as binop operand — emit load [ptr], not pointer bits. */
    if (ko == 52) {
      glue_binop_var_slot_cache_clear();
      vr = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr != 0) {
        return -1;
      }
      if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
        return -1;
      }
      return 0;
    }
    /*c*/
    if ((glue_expr_is_await_at_c(arena, expr_ref)) != 0) {
      let await_op: i32 = 0;
      await_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (await_op <= 0) {
        return -2;
      }
      return glue_try_binop_load_operand_elf_c(arena, elf_ctx, await_op, ctx, ta, to_rbx);
    }
    if ((glue_expr_is_x_as_cast_at_c(arena, expr_ref)) != 0) {
      let op_ref: i32 = 0;
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      if (op_ref <= 0) {
        return -2;
      }
      /*
       * wave301 Cap residual pure: peel only integer-result AS (e.g. u8[i] as i32).
       * Float-target AS must not peel — dual-slot would load raw integer/source bits
       * and skip cvtsi2ss / cvtsi2sd / cvtsd2ss / cvtss2sd from pipeline_asm_emit_as_elf.
       * Soft residual after wave299/300: `(u64 as f32) * f32_var` run=0 while bare
       * `(u64 as f32) as i32` stayed green. G.7: complete loader authority next to
       * emit_as (reuse pipeline_asm_emit_as_elf_impl; no new encoder / no second cast path).
       * PLATFORM: SHARED cast semantics / LINUX+MACOS x86_64 freestanding exposes; mac host-gcc hid.
       *
       * wave620 Cap residual pure: float→int AS must not peel either.
       * Top-level `return z as i32` hits pipeline_asm_emit_as_elf_impl (cvttss2si green),
       * but dual-slot binop `(x as i32)+(y as i32)` / `(a[0] as i32)+(a[1] as i32)` peeled
       * AS → integer ADD of IEEE bits (mac/Ubuntu pure-asm run=0 via 8-bit $?; host-C hid).
       * G.7: glue_binop_as_needs_full_emit_elf_c + same full-AS authority — no second path.
       * PLATFORM: SHARED freestanding dual-slot; LINUX x86_64 + MACOS|ARM64 both expose.
       */
      if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
        glue_binop_var_slot_cache_clear();
        if (pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
          return -1;
        }
        if (to_rbx != 0 && backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
          return -1;
        }
        return 0;
      }
      return glue_try_binop_load_operand_elf_c(arena, elf_ctx, op_ref, ctx, ta, to_rbx);
    }
    return -2;
  }
}
