// Thin override: pipeline_asm_emit_expr_elf_rec + EXPR_ASM (60) slice0.
// G.7: body matches seeds/runtime_pipeline_abi.from_x.c emit_expr_elf_rec
// with ko==60 → pipeline_asm_try_emit_inline_asm_expr_elf_c.
// ensure injects first-wins over weak pure (skip full mega -E).
// PLATFORM: SHARED freestanding emit · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_if_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_if_arm_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_match_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_panic_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_array_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_addr_of_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_method_call_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_asm_emit_string_lit_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32;
export extern function pipeline_asm_try_emit_inline_asm_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32): i32;
export extern function pipeline_asm_emit_cmp_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_break_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_continue_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_neg_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_bitnot_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lognot_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_await_sync_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_try_propagate_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_assign_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_logand_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_logor_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_enum_namespace_field_tag(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_emit_expr_elf_slow(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * Freestanding expr ELF recursion with EXPR_ASM (60) slice0.
 * Fast path first; kind dispatch includes asm!("template") → try_emit.
 * Omits XLANG_DEBUG_REGEX_EMIT fprintf (wave106 style).
 * @return i32 — 0 ok; negative error; -99 unhandled from slow
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let r: i32 = 0;
  let ko: i32 = 0 - 1;
  let out_rc: i32 = 0;
  let ns_tag: i32 = 0;
  if (expr_ref > 0) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    }
  }
  unsafe {
    r = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
  }
  if (r != (0 - 99)) {
    return r;
  }
  if (ko == 25 || ko == 27) {
    unsafe {
      return pipeline_asm_emit_expr_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 26) {
    unsafe {
      return pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 43) {
    unsafe {
      return pipeline_asm_emit_match_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 42) {
    unsafe {
      return pipeline_asm_emit_panic_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 45) {
    unsafe {
      return pipeline_asm_emit_struct_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 46) {
    unsafe {
      return pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 47) {
    unsafe {
      return pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 51) {
    unsafe {
      return pipeline_asm_emit_addr_of_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 52) {
    unsafe {
      return pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 48) {
    unsafe {
      return pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 49) {
    unsafe {
      return pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 59) {
    unsafe {
      return glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    }
  }
  /* Stage10 10.2.1 slice0: EXPR_ASM */
  if (ko == 60) {
    unsafe {
      return pipeline_asm_try_emit_inline_asm_expr_elf_c(arena, elf_ctx, expr_ref, ta);
    }
  }
  if (ko >= 14 && ko <= 19) {
    unsafe {
      return pipeline_asm_emit_cmp_elf(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 41) {
    unsafe {
      return pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 39) {
    unsafe {
      return pipeline_asm_emit_break_elf_c(arena, elf_ctx, ctx, ta);
    }
  }
  if (ko == 40) {
    unsafe {
      return pipeline_asm_emit_continue_elf_c(arena, elf_ctx, ctx, ta);
    }
  }
  if (ko == 22) {
    unsafe {
      return pipeline_asm_emit_neg_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 23) {
    unsafe {
      return pipeline_asm_emit_bitnot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 24) {
    unsafe {
      return pipeline_asm_emit_lognot_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  unsafe {
    if (glue_expr_is_await_at_c(arena, expr_ref) != 0) {
      return pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
    if (glue_expr_is_x_as_cast_at_c(arena, expr_ref) != 0) {
      return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 58 || ko == 57) {
    unsafe {
      return pipeline_asm_emit_try_propagate_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 28 || (ko >= 29 && ko <= 38)) {
    unsafe {
      return pipeline_asm_emit_assign_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 20) {
    unsafe {
      return pipeline_asm_emit_logand_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 21) {
    unsafe {
      return pipeline_asm_emit_logor_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
  }
  if (ko == 44) {
    unsafe {
      ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
      if (ns_tag >= 0) {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
      }
    }
    return 0 - 1;
  }
  unsafe {
    out_rc = backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
  }
  return out_rc;
}
