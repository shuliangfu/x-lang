// knife256/10.2 Cap tip body of the Darwin byref call-arg address.
// The linked mega symbol is
// backend_call_dispatch_glue_emit_arm64_host_mem_arg_addr_to_rax_c.
// That spelling is 64 bytes and the cap-tip checker rejects it, so this
// file defines glue_vec_arg_addr. The Darwin link aliases that symbol
// onto the mega name and aliases glue_vec_arg_addr__demoted onto the
// old body. A VAR, FIELD, INDEX, or DEREF is copied by that body.
// A lane binop, a unary, a block, or an array literal is not an address.
// The mega points x8 at an empty temp and emits the expr, which stores
// a scalar in x0. `id(a + a)` then reads lane 0 as 0. This entry fills
// a real vector temp with the same let-init a `let` uses, restores the
// outer sret in x8, and leas the temp. A binop usually has no resolved
// type; the existing float-source resolver reads the VAR's let. Kind
// 51 is an address and stays on the demoted body. Let-init -3 falls
// through. Every other shape calls the demoted body.
// PLATFORM: MACOS|ARM64. The alias step is Mach-O only.

export extern "C" function glue_vec_arg_addr__demoted(
  arena: *u8, elf_ctx: *u8, ctx: *u8, arg_ref: i32, sz: i32, ta: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern "C" function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern "C" function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern "C" function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern "C" function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_off: i32, type_ref: i32): i32;
export extern "C" function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern "C" function glue_arm64_mov_x8_to_x0_elf_c(elf_ctx: *u8): i32;
export extern "C" function glue_arm64_mov_x0_to_x8_elf_c(elf_ctx: *u8): i32;
export extern "C" function pipe_asm_ctx_off_next_offset(): i32;
export extern "C" function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Pass a wide SIMD value by reference, else the old byref copy.
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param elf_ctx *u8 — encoder; null defers
 * @param ctx *u8 — function frame; null defers
 * @param arg_ref i32 — argument expr; <= 0 defers
 * @param sz i32 — formal size in bytes; the byref caller passes > 16
 * @param ta i32 — target arch; only 1 (Darwin arm64) materializes here
 * @return i32 — 0 when x0 holds the argument address; -1 on failure
 * Kind 3, 44, 47, 48, 49, and 52 stay on the demoted copy. Kind 51 is
 * an address: the lane-binop predicate treats it as add, so it is
 * excluded before that call. Kinds 4..13, 22, 23, 25, 26, 27, and 46
 * use the same filler as a frame let. The type is the expr stamp when
 * that stamp spells as SIMD. A binop or unary usually has no stamp;
 * the left or operand VAR is resolved by glue_float_promote_src_ty_ref_c,
 * which already reads the function-body let. Named i32x8 and f32x8
 * take that path. The original expr_ref is what let-init receives.
 * Incoming x8 is the outer sret and is restored after the fill.
 * Let-init -3 restores x8 and falls through. Any other filler failure
 * returns -1 and does not pass an empty slot.
 * PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_vec_arg_addr(
  arena: *u8, elf_ctx: *u8, ctx: *u8, arg_ref: i32, sz: i32, ta: i32): i32 {
  unsafe {
    let ord_lit: i32 = 0;
    let ord_neg: i32 = 22;
    let ord_bitnot: i32 = 23;
    let go: i32 = 0;
    let ko: i32 = 0;
    let lane_bin: i32 = 0;
    let tr: i32 = 0;
    let simd: i32 = 0;
    let child: i32 = 0;
    let slot: i32 = 0;
    let save_off: i32 = 0;
    let next_off: i32 = 0;
    let rc: i32 = 0;
    if (arena != 0 as *u8) {
      if (elf_ctx != 0 as *u8) {
        if (ctx != 0 as *u8) {
          if (arg_ref > 0) {
            if (sz > 16) {
              if (ta == 1) {
                ko = pipeline_expr_kind_ord_at(arena, arg_ref);
                // Kind 51 is ADDR_OF. The predicate maps it to add.
                if (ko != 51) {
                  lane_bin = glue_is_vector_lane_scalar_binop_ko(ko);
                }
                if (ko == ord_lit) {
                  go = 1;
                }
                if (ko == ord_neg) {
                  go = 1;
                }
                if (ko == ord_bitnot) {
                  go = 1;
                }
                if (ko == 25) {
                  go = 1;
                }
                if (ko == 26) {
                  go = 1;
                }
                if (ko == 27) {
                  go = 1;
                }
                if (ko == 46) {
                  go = 1;
                }
                if (lane_bin != 0) {
                  go = 1;
                }
                if (go != 0) {
                  tr = pipeline_expr_resolved_type_ref(arena, arg_ref);
                  if (tr > 0) {
                    simd = asm_type_is_simd_vector_spelling(arena, tr);
                  }
                  // No stamp on a+a or ~a. One VAR child, not a walk.
                  if (simd == 0) {
                    if (lane_bin != 0) {
                      child = pipeline_expr_binop_left_ref_at(arena, arg_ref);
                    }
                    if (child <= 0) {
                      if (ko == ord_neg) {
                        child = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
                      }
                      if (ko == ord_bitnot) {
                        child = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
                      }
                    }
                    if (child > 0) {
                      tr = glue_float_promote_src_ty_ref_c(arena, child);
                      if (tr > 0) {
                        simd = asm_type_is_simd_vector_spelling(arena, tr);
                      }
                    }
                  }
                  if (simd != 0) {
                    slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, tr);
                    if (slot < 0) {
                      return 0 - 1;
                    }
                    // Outer let sret lives in x8. The fill may reuse it.
                    next_off = pipe_asm_ctx_off_next_offset();
                    save_off = pipe_load_i32_le(ctx, next_off);
                    pipe_store_i32_le(ctx, next_off, save_off + 8);
                    rc = glue_arm64_mov_x8_to_x0_elf_c(elf_ctx);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, save_off, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    rc = glue_emit_vector_type_let_init_elf_c(
                      arena, elf_ctx, arg_ref, ctx, ta, slot, tr);
                    if (rc == 0) {
                      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, save_off, ta);
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      rc = glue_arm64_mov_x0_to_x8_elf_c(elf_ctx);
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot, ta);
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      return 0;
                    }
                    if (rc != (0 - 3)) {
                      return 0 - 1;
                    }
                    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, save_off, ta);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    rc = glue_arm64_mov_x0_to_x8_elf_c(elf_ctx);
                    if (rc != 0) {
                      return 0 - 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return glue_vec_arg_addr__demoted(arena, elf_ctx, ctx, arg_ref, sz, ta);
  }
}
