// Thin pure overlay: VAR assign gate for Darwin + Windows (w1502, 终局待办 10.25).
// Darwin pabi is a libtool archive, so the w620 inject of the assign_var
// leaves never ran there; the live gate was a leftover host-cc body that only
// handled plain ASSIGN (kind 28). Windows used a host-cc var override (removed w1506),
// also kind 28 only. `a += 3` and every compound op (kinds 29..38) then
// returned -1 and the whole function failed with CG002.
// This gate keeps the leaf split of runtime_pipeline_abi_assign_var_thin.x
// (try_let + finish; finish calls glue_emit_assign_rhs_to_rax_elf_c, which
// dispatches compound ops) and adds the file-scope scalar path the Windows
// override had: no frame slot + shared module let → value to rax → egg store.
// It also defines glue_emit_assign_rhs_elf_c. A TYPE_SLICE VAR whose RHS
// peels to ARRAY_LIT leaves a durable pointer plus the element count for
// store_slice. Other RHS shapes still take the f32 FLOAT_LIT path or
// emit_expr. The copies in assign_thin.x and assign_helpers_thin.x are
// not linked; do not keep them in sync with this body.
// It also defines glue_emit_assign_load_lr_elf_c (replaces the unchanged
// runtime_pipeline_abi_assign_rhsrax_arms_load_lr_thin.x leaf, which calls
// glue_try_binop_left_rax_right_rbx_elf_c twice and so emits the load pair
// twice). For a VAR target the right side is loaded first into rbx, then the
// VAR into rax: a VAR load never touches rbx, so arm64 needs no frame home
// for rax (that home grew the frame cursor past the prologue's frame size,
// and `g += 5; g *= 2` in a leaf function wrote over saved x19/caller frame,
// SIGBUS). Other targets try the fast pair once, else push/pop.
// Editing the assign_var / rhsrax leaves marks pabi.o stale (FORCE pabi is
// banned), so this lives in its own file. g05_relink_env compiles it with the
// current product every relink, next to the unchanged leaves.
// w1507 (终局待办 10.34): an f32 VAR target whose value is already f32 bits
// (compound op computed in the lhs type, or plain ASSIGN of a FLOAT_LIT that
// glue_emit_assign_rhs_elf_c emits dest-typed as imm32) must not go through
// finish: its demote asks glue_binop_operand_is_scalar_f64_elf_c about the
// right side only, a FLOAT_LIT counts as f64, so cvtsd2ss / fcvt s0,d0 turned
// the f32 bits into garbage (`x = 2.25`, `x += 2.25`, `x *= 2.0` all wrong on
// all three targets). Same skip rule as the let-init path (init_f32_lit).
// Linux does not reach this gate for VAR assign (assign.o sidecar); its fix is
// runtime_pipeline_abi_f32_demote_thin.x.
// PLATFORM: MACOS|DARWIN + WINDOWS. Linux keeps the injected pabi leaves.

export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_var_try_let_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32;
export extern function pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_slot(off: i32): void;
export extern function glue_index_scratch_spill_invalidate_var(arena: *u8, elf_ctx: *u8, ctx: *u8, var_ref: i32, ta: i32): void;
export extern function glue_assign_lhs_f32_type_ref_elf_c(arena: *u8, ctx: *u8, left_ref: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function glue_try_binop_left_rax_right_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_binop_var_slot_cache_invalidate_rbx(): void;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_var_store_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;

/**
 * File-scope scalar assign: value (plain or compound) into rax, then store
 * into the module cell. Only names the egg table marks shared.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — ASSIGN / compound assign expr
 * @param left_ref i32 — VAR lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 not a shared module let or emit failure
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows).
 */
function w1502_assign_modlet(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let vname: u8[256] = [];
    let vlen: i32 = pipeline_expr_var_name_len(arena, left_ref);
    if (vlen <= 0 || vlen > 255) {
      return 0 - 1;
    }
    pipeline_expr_var_name_into(arena, left_ref, &vname[0]);
    if (pipeline_asm_modlet_name_is_shared(&vname[0], vlen) == 0) {
      return 0 - 1;
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    // The module cell store is 8 bytes. mov w0 of an i32 zero-extends,
    // so -7 sits in x0 as 0x00000000fffffff9. A later cmp x against
    // the sign-extended -7 does not match. u32 must stay zero-extended.
    // Kind 0 is i32. PLATFORM: SHARED.
    let tr: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
    if (tr > 0) {
      let tk: i32 = pipeline_type_kind_ord_at(arena, tr);
      if (tk == 0) {
        if (glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
      }
    }
    return pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
  }
}

/**
 * w1507 (终局待办 10.34): does rhs_to_rax already leave f32 bits for an f32
 * VAR target? Compound ops (kinds 29..38) compute in the lhs type; plain
 * ASSIGN (28) of a FLOAT_LIT is emitted dest-typed as imm32. Those skip the
 * finish demote (it would treat the f32 bits as f64 and convert again).
 * @param arena *u8 — AST arena
 * @param ctx *u8 — AsmFuncCtx*
 * @param ek i32 — assign expr kind
 * @param left_ref i32 — assign target
 * @param right_ref i32 — right side
 * @return i32 — 1 when the store must skip the demote; 0 otherwise
 * PLATFORM: SHARED freestanding.
 */
function w1507_f32_bits_ready(arena: *u8, ctx: *u8, ek: i32, left_ref: i32, right_ref: i32): i32 {
  unsafe {
    if (glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref) <= 0) {
      return 0;
    }
    if (ek >= 29 && ek <= 38) {
      return 1;
    }
    if (ek == 28 && pipeline_expr_kind_ord_at(arena, right_ref) == 1) {
      return 1;
    }
    return 0;
  }
}

/**
 * VAR lvalue assign gate. Frame local: kind 28 tries try_let, then finish
 * (plain + compound 29..38 via rhs_to_rax, typed store). No frame slot:
 * shared module let path. Drops the binop var-slot cache and index scratch
 * spill for the slot before and after the store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — ASSIGN / compound assign expr
 * @param left_ref i32 — VAR lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows).
 */
#[no_mangle]
export function glue_emit_assign_var_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (left_ref <= 0 || right_ref <= 0) {
      return 0 - 1;
    }
    let off: i32 = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
    if (off < 0) {
      return w1502_assign_modlet(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    glue_index_scratch_spill_invalidate_var(arena, elf_ctx, ctx, left_ref, ta);
    glue_binop_var_slot_cache_invalidate_slot(off);
    let rc: i32 = 0 - 1;
    let ek: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (w1507_f32_bits_ready(arena, ctx, ek, left_ref, right_ref) != 0) {
      rc = glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
      if (rc == 0) {
        rc = glue_emit_assign_var_store_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta);
      }
      glue_binop_var_slot_cache_invalidate_slot(off);
      return rc;
    }
    if (ek == 28) {
      rc = glue_emit_assign_var_try_let_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (rc != 0) {
      rc = glue_emit_assign_var_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    glue_binop_var_slot_cache_invalidate_slot(off);
    return rc;
  }
}

/**
 * Assign RHS emit. A VAR whose declared type is TYPE_SLICE (kind 11) and
 * whose RHS peels to ARRAY_LIT (kind 46, bare or `as []T`) leaves the
 * durable data pointer in rax/x0 and the element count in x1 (arm64) or
 * rdx (ta==0, including Windows). store_slice writes those two registers.
 * emit_expr of the ascription writes the ints on the caller frame and
 * leaves that address in both registers, so the length slot receives the
 * pointer. Other RHS kinds, a non-VAR lhs, and a durable-helper failure
 * fall through: an f32 lhs plus FLOAT_LIT uses the imm32 path, otherwise
 * pipeline_asm_emit_expr_elf_c. A length-encoder failure after the durable
 * helper has already emitted returns -1 and does not emit the RHS again.
 * Linux VAR assign does not reach this gate (assign.o sidecar).
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param left_ref i32 — lhs
 * @param right_ref i32 — rhs
 * @param ctx *u8 — emit context (AsmFuncCtx*)
 * @param ta i32 — target arch (0 = x86_64, 1 = arm64)
 * @return i32 — 0 when the RHS is in rax (and rdx/x1 for a slice literal); -1 on failure
 * PLATFORM: SHARED freestanding (linked on Darwin + Windows). The length
 * register is the one backend_enc_store_rdx_to_rbp_arch stores.
 */
#[no_mangle]
export function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || right_ref <= 0) {
      return 0 - 1;
    }
    // TYPE_SLICE = 11. Decl-type lookup returns 0 unless the lhs is a VAR,
    // so a field or index assign stays on emit_expr. ta 0 and 1 only:
    // store_slice reads x1 on arm64 and rdx on x86_64, Windows included.
    // The return arm's Windows exclusion does not apply to this store.
    if (ta == 0 || ta == 1) {
      let decl_ty: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
      if (decl_ty > 0 && pipeline_type_kind_ord_at(arena, decl_ty) == 11) {
        let peel: i32 = glue_peel_as_array_slice_ascription_c(arena, right_ref);
        if (peel <= 0) {
          peel = right_ref;
        }
        // ARRAY_LIT = 46. A call or a slice variable stays on emit_expr.
        if (pipeline_expr_kind_ord_at(arena, peel) == 46) {
          let n_arr: i32 = pipeline_expr_array_lit_num_elems_at(arena, peel);
          if (n_arr >= 0 && n_arr <= 1024) {
            let elem_ty: i32 = pipeline_type_elem_ref_at(arena, decl_ty);
            let esz: i32 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
            let rc: i32 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, peel, esz, ta, ctx, elem_ty);
            if (rc == 0) {
              if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0) {
                return 0 - 1;
              }
              let len_reg: i32 = 2;
              if (ta == 1) {
                len_reg = 1;
              }
              if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
              return 0;
            }
          }
        }
        // VAR of [N]T. emit_expr leaves the array address and no length,
        // so store_slice writes a stale x1 and `s = a` keeps length 1.
        // Lea the slot and put N in the length register, same as ARRAY_LIT.
        if (pipeline_expr_kind_ord_at(arena, peel) == 3) {
          let rty: i32 = glue_var_decl_type_ref_elf_c(arena, ctx, peel);
          if (rty > 0 && pipeline_type_kind_ord_at(arena, rty) == 10) {
            let n_arr: i32 = pipeline_type_array_size_at(arena, rty);
            let roff: i32 = glue_var_expr_stack_off_elf_c(arena, ctx, peel);
            if (n_arr > 0 && roff >= 0) {
              if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, roff, ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0) {
                return 0 - 1;
              }
              let len_reg: i32 = 2;
              if (ta == 1) {
                len_reg = 1;
              }
              if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta) != 0) {
                return 0 - 1;
              }
              if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
              return 0;
            }
          }
        }
      }
    }
    if (pipeline_expr_kind_ord_at(arena, right_ref) == 1) {
      let lhs_f32: i32 = glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref);
      if (lhs_f32 > 0) {
        return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0);
      }
    }
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
  }
}

/**
 * Compound assign: load target to rax and right side to rbx.
 * VAR target (kind 3): right side first, mov rax to rbx, drop the rbx VAR
 * cache, then the VAR load (touches only rax). Other targets: one call of
 * the fast pair; on -2 emit left, push, emit right, pop rbx.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — emit context
 * @param left_ref i32 — assign target
 * @param right_ref i32 — right side
 * @param ctx *u8 — AsmFuncCtx*
 * @param ta i32 — target arch
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: MACOS|ARM64 + WINDOWS x86_64.
 */
#[no_mangle]
export function glue_emit_assign_load_lr_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, left_ref) == 3) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
        return 0 - 1;
      }
      glue_binop_var_slot_cache_invalidate_rbx();
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
        return 0 - 1;
      }
      return 0;
    }
    return w1502_load_lr_other(arena, elf_ctx, left_ref, right_ref, ctx, ta, glue_try_binop_left_rax_right_rbx_elf_c(arena, elf_ctx, left_ref, right_ref, ctx, ta));
  }
}

/**
 * Non-VAR tail of glue_emit_assign_load_lr_elf_c: r is the single fast-pair
 * result (0 done, -1 fail, -2 not handled and nothing emitted).
 * @return i32 — 0 ok; -1 failure
 * PLATFORM: MACOS|ARM64 + WINDOWS x86_64.
 */
export function w1502_load_lr_other(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, r: i32): i32 {
  unsafe {
    if (r == 0) {
      return 0;
    }
    if (r != (0 - 2)) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_pop_rbx_arch(elf_ctx, ta) != 0) {
      return 0 - 1;
    }
    return 0;
  }
}
