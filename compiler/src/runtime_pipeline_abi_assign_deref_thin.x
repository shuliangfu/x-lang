// Thin pure: DEREF arm gate/dispatcher (wave441/w472).
// G.7: body MUST match pipeline_asm_emit_assign_elf_c DEREF path (peer-flat).
// wave449: LINUX PREFER tip pure-asm (product si green alone + with peers).
// wave441b: monolithic tip `let x=call()` → U-starved 1/15 (L2 假绿 if PREFER).
// wave472: gate + peel + peel_var + finish + after_addr + vec_gate no-local
//   split. Tip U=5/5. PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// wave598: do not call leftover peel. Ubuntu `unsafe { *p = 1 }` hits peel
//   because DEREF resolved_type_ref is 0; leftover peel then calls scalar
//   and smashes rbp (gdb: epilogue pop %rbx, rbp=1, unwind at 0x9). Peel
//   PRODUCT reinject is HARD BAN (w596). Missing type and non-aggregate
//   kinds dispatch to leftover scalar (the emit peel already reached).
//   Aggregates 8/11/13/10 still finish. PLATFORM: SHARED · LINUX gold.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_assign_deref_scalar_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_assign_deref_finish_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, ltr: i32, ltk: i32): i32;

/**
 * DEREF lvalue assign gate — ta check, ARRAY/VEC/SLICE/STRUCT finish,
 *   else leftover scalar. wave472: no-local — type kind via re-call.
 * wave598: skip leftover peel (BAN w596). `*p=` DEREF often has
 *   resolved_type_ref 0; peel called scalar then smashed its frame.
 * @param arena *u8 — ASTArena*; forwarded
 * @param elf_ctx *u8 — ElfCodegenCtx*; forwarded
 * @param expr_ref i32 — ASSIGN expr ref
 * @param left_ref i32 — DEREF lhs expr ref
 * @param right_ref i32 — ASSIGN rhs expr ref
 * @param ctx *u8 — PipelineDepCtx*; forwarded
 * @param ta i32 — target arch (0/1 keep x86_64/arm64 path)
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (ta != 0) {
      if (ta != 1) {
        return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
      }
    }
    if (pipeline_expr_resolved_type_ref(arena, left_ref) <= 0) {
      return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 8) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 8);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 11) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 11);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 13) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 13);
    }
    if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, left_ref)) == 10) {
      return glue_emit_assign_deref_finish_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, pipeline_expr_resolved_type_ref(arena, left_ref), 10);
    }
    return glue_emit_assign_deref_scalar_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta);
  }
}
