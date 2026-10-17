// A typed `let f: function(i32): i32 = inc` never loaded the address of
// `inc`. The fast VAR arm only folds module consts; a same-module
// function fell through to a frame slot (the spilled entry register)
// and the call `blr` jumped at that garbage.
// This face runs before that slot load. A local that is not a
// function still uses the previous fast arm.
// PLATFORM: SHARED.

export extern "C" function pipeline_asm_emit_expr_elf_fast_mega(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern "C" function pipeline_asm_emit_module_ref_c(): *u8;
export extern "C" function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern "C" function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern "C" function glue_asm_local_var_stack_off_scoped(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern "C" function pipeline_expr_const_folded_valid_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_const_folded_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern "C" function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;
export extern "C" function backend_enc_append_u8_c(elf_ctx: *u8, b: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;

/**
 * Sign-extend w0 into x0 after a negative i32 immediate.
 * @param elf_ctx *u8 — code sink
 * @param imm i32 — the immediate just written into w0
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param signed_i32 i32 — 1 when the value is a signed 32-bit integer
 * @return i32 — 0 ok, -1 the extra instruction did not encode
 * mov w0 zero-extends. A later 64-bit cmp then treats -3 as 4294967293.
 * arm64 appends sxtw x0, w0. x86_64 appends cdqe.
 * PLATFORM: SHARED.
 */
function fast_sxt_neg_i32(elf_ctx: *u8, imm: i32, ta: i32, signed_i32: i32): i32 {
  if (signed_i32 == 0 || imm >= 0) {
    return 0;
  }
  unsafe {
    if (ta == 1) {
      return backend_enc_append_u32_le_c(elf_ctx, 2470476800 as u32);
    }
    if (ta == 0) {
      if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
        return 0 - 1;
      }
      return backend_enc_append_u8_c(elf_ctx, 152);
    }
  }
  return 0;
}

/**
 * Emit a VAR, or the address of a same-module function.
 * @param arena *u8 — expression pool; null is rejected by the mega
 * @param elf_ctx *u8 — code sink
 * @param expr_ref i32 — expression; EXPR_VAR is kind 3
 * @param ctx *u8 — asm function context; supplies the module
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when a function address was emitted, else the mega result
 * Name buffer is 256 because pipeline_expr_var_name_into clears 256 bytes.
 * A declared local wins, including a local that shadows a function.
 * A name that is not a module function is unchanged.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  // PLATFORM: SHARED — function address before the frame-slot load.
  unsafe {
    let nlen: i32 = 0;
    let fi: i32 = 0;
    let kind: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let name: u8[256] = [];
    // LANG-006: `const N: i32 = [1, 2, 3, 4]` is already folded to the
    // element count. Emit that integer. A variable name and a float
    // literal keep their own arms; the fold word on those is stale.
    if (arena != 0 as *u8 && expr_ref > 0 && pipeline_expr_const_folded_valid_at(arena, expr_ref) != 0) {
      kind = pipeline_expr_kind_ord_at(arena, expr_ref);
      if (kind != 1 && kind != 3) {
        let folded: i32 = pipeline_expr_const_folded_val_at(arena, expr_ref);
        let frc: i32 = backend_enc_mov_imm32_to_w0_arch(elf_ctx, folded, ta);
        if (frc != 0) {
          return frc;
        }
        return fast_sxt_neg_i32(elf_ctx, folded, ta, 1);
      }
    }
    if (arena != 0 as *u8 && expr_ref > 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 0) {
      let rc_lit: i32 = pipeline_asm_emit_expr_elf_fast_mega(arena, elf_ctx, expr_ref, ctx, ta);
      let tr_lit: i32 = 0;
      let tk_lit: i32 = 0 - 1;
      let signed_lit: i32 = 0;
      if (rc_lit != 0) {
        return rc_lit;
      }
      tr_lit = pipeline_expr_resolved_type_ref(arena, expr_ref);
      if (tr_lit > 0) {
        tk_lit = pipeline_type_kind_ord_at(arena, tr_lit);
      }
      if (tr_lit <= 0 || tk_lit == 0 || tk_lit == 5 || tk_lit == 7) {
        signed_lit = 1;
      }
      return fast_sxt_neg_i32(elf_ctx, pipeline_expr_int_val_at(arena, expr_ref), ta, signed_lit);
    }
    if (arena != 0 as *u8 && expr_ref > 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 3) {
      nlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (nlen > 0 && nlen <= 255) {
        pipeline_expr_var_name_into(arena, expr_ref, &name[0]);
        mod = 0 as *u8;
        if (ctx != 0 as *u8) {
          mod = glue_emit_module_from_ctx(ctx);
        }
        if (mod == 0 as *u8) {
          mod = pipeline_asm_emit_module_ref_c();
        }
        if (ctx != 0 as *u8) {
          if (glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref) >= 0) {
            return pipeline_asm_emit_expr_elf_fast_mega(arena, elf_ctx, expr_ref, ctx, ta);
          }
        }
        if (mod != 0 as *u8) {
          fi = glue_module_func_index_by_name_c(mod, &name[0], nlen);
          if (fi >= 0) {
            return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &name[0], nlen, ta);
          }
        }
      }
    }
    return pipeline_asm_emit_expr_elf_fast_mega(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
