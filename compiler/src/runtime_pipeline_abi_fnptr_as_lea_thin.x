// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: LINUX -E (w606 smash leftover as_cast) / MACOS overlay keep.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_module_func_index_by_name_c(mod: *u8, name: *u8, name_len: i32): i32;
export extern function pipe_modlet_lea_fn_sym_to_rax(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;

/**
 * Cap-fn-ptr LEA, or emit the operand and zero-extend a u8 cast.
 * A local stack slot wins over a same-named function. Otherwise the
 * operand is emitted and rax is masked when the cast produces a byte
 * or widens a byte/bool into a larger integer.
 * i64 as i32 stays a low-32 truncation and does not take the mask.
 * Float-to-integer stays in the f2i arm and does not reach this mask.
 * @param arena *u8 — AST arena; null is rejected by the callees
 * @param elf_ctx *u8 — code byte sink
 * @param op i32 — operand expression of the cast
 * @param ctx *u8 — asm function context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @param tgt i32 — target type ref of the cast
 * @return i32 — 0 on success, -1 on an encode failure
 * PLATFORM: SHARED — the mask is glue_enc_zxt_u8_result_to_rax_elf_c
 * (x86_64 and $0xff, arm64 uxtb). LINUX links this sidecar ahead of the egg.
 */
#[no_mangle]
export function glue_emit_as_fnptr_or_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32 {
  let fnptr_vname: u8[256] = [];
  let rc_as: i32 = 0;
  let src_tr: i32 = 0;
  let src_kind: i32 = 0 - 1;
  let tgt_kind: i32 = 0 - 1;
  let zxt: i32 = 0;
  unsafe {
    if ((pipeline_type_kind_ord_at(arena, tgt) == 9 || pipeline_type_kind_ord_at(arena, tgt) == 18)
        && pipeline_expr_kind_ord_at(arena, op) == 3) {
      if (glue_var_expr_stack_off_elf_c(arena, ctx, op) < 0) {
        if (pipeline_expr_var_name_len(arena, op) > 0 && pipeline_expr_var_name_len(arena, op) < 256) {
          pipeline_expr_var_name_into(arena, op, &fnptr_vname[0]);
          if (glue_emit_module_from_ctx(ctx) != (0 as *u8)) {
            if (glue_module_func_index_by_name_c(glue_emit_module_from_ctx(ctx), &fnptr_vname[0], pipeline_expr_var_name_len(arena, op)) >= 0) {
              return pipe_modlet_lea_fn_sym_to_rax(elf_ctx, &fnptr_vname[0], pipeline_expr_var_name_len(arena, op), ta);
            }
          }
        }
      }
    }
    rc_as = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    if (rc_as != 0) { return rc_as; }
    // TypeKind: I32=0 BOOL=1 U8=2 U32=3 U64=4 I64=5 USIZE=6 ISIZE=7 F32=14 F64=15.
    // A cast to u8 keeps only the low byte. A u8 or bool widened to a
    // larger integer does the same, so an extern u8 return whose high
    // bits were never defined becomes a clean i32/i64. A float source
    // is left alone: f2i already returned, and masking IEEE bits is not
    // a byte cast.
    if (tgt > 0) {
      tgt_kind = pipeline_type_kind_ord_at(arena, tgt);
    }
    src_tr = pipeline_expr_resolved_type_ref(arena, op);
    if (src_tr > 0) {
      src_kind = pipeline_type_kind_ord_at(arena, src_tr);
    }
    // Narrow to u8. Skip a float source so IEEE bits are not masked.
    if (tgt_kind == 2) {
      if (src_kind != 14) {
        if (src_kind != 15) {
          zxt = 1;
        }
      }
    }
    // Widen a byte or a bool into i32/u32/u64/i64/usize/isize.
    if (src_kind == 1) {
      if (tgt_kind == 0) { zxt = 1; }
      if (tgt_kind == 3) { zxt = 1; }
      if (tgt_kind == 4) { zxt = 1; }
      if (tgt_kind == 5) { zxt = 1; }
      if (tgt_kind == 6) { zxt = 1; }
      if (tgt_kind == 7) { zxt = 1; }
    }
    if (src_kind == 2) {
      if (tgt_kind == 0) { zxt = 1; }
      if (tgt_kind == 3) { zxt = 1; }
      if (tgt_kind == 4) { zxt = 1; }
      if (tgt_kind == 5) { zxt = 1; }
      if (tgt_kind == 6) { zxt = 1; }
      if (tgt_kind == 7) { zxt = 1; }
    }
    if (zxt != 0) {
      return glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx, ta);
    }
    return 0;
  }
}
