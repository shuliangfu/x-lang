// Thin pure: INDEX generic dispatcher (wave441/w471).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX path (fallback peer).
// wave441b: monolithic tip `let x=call()` → U-starved 1/171 (L2 假绿 if PREFER);
//   ~170 dead export-externs + large unused locals.
// wave471: strip dead surface; split try/try2/scaled; no-local dispatcher
//   (rhs→rax, push, may_clobber clear, cache hit, try cascade, scaled).
//   Tip U=12/12. PRODUCT inject: LINUX PREFER (stamp w471); MACOS skip.
// wave607: leftover PREFER smash (`sub $0x1238`, no endbr64). LINUX -E of
//   this complete family is the product path. HARD BAN PREFER.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_finish_store_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32, ta: i32): i32;
export extern function glue_emit_assign_index_generic_try_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_emit_assign_index_generic_try2_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_emit_assign_index_generic_scaled_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32;

/**
 * INDEX generic dispatcher — rhs→rax, push, try cascade, scaled fallback.
 * wave471: no-local — base/idx/esz via re-call; try via 0/-1 eq-cascade;
 *   no `let x=call()`. Dead STRUCT_LIT comment locals removed (unused).
 * @return i32 — 0 ok; -1 err; -3 not handled (propagated from peers)
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_generic_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (pipeline_expr_index_base_ref(arena, left_ref) <= 0) {
      return 0 - 1;
    }
    if (pipeline_expr_index_index_ref(arena, left_ref) <= 0) {
      return 0 - 1;
    }
    if (glue_emit_assign_rhs_to_rax_elf_c(arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_expr_emit_may_clobber_rbx_elf_c(arena, right_ref) != 0) {
      glue_index_assign_addr_cache_clear();
    }
    if (glue_index_assign_addr_cache_hit(arena, ctx, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref)) != 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref), ta);
    }
    if (glue_emit_assign_index_generic_try_elf_c(arena, elf_ctx, ctx, ta, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref)) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_generic_try_elf_c(arena, elf_ctx, ctx, ta, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref)) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_index_generic_try2_elf_c(arena, elf_ctx, ctx, ta, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref)) == 0) {
      return 0;
    }
    if (glue_emit_assign_index_generic_try2_elf_c(arena, elf_ctx, ctx, ta, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref)) == (0 - 1)) {
      return 0 - 1;
    }
    return glue_emit_assign_index_generic_scaled_elf_c(arena, elf_ctx, left_ref, ctx, ta, pipeline_expr_index_base_ref(arena, left_ref), pipeline_expr_index_index_ref(arena, left_ref), pipeline_asm_index_elem_byte_sz_c(arena, left_ref));
  }
}
