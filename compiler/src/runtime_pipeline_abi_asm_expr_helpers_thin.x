// Thin pure: asm_expr HELPERS leaf (pipeline_asm_emit_expr_elf_rec only).
// G.7: the Linux rec body must match pipeline_asm_emit_expr_elf_rec in
// asm_expr_thin.x. Darwin links that full thin. Linux links this file.
// The full thin stays HARD BAN PREFER on Linux (frame smash).
// w1738: the 9..16 named-field pair load is copied here. The Linux egg
// fast path does not call pipeline_asm_deref_struct16_rax_ptr_elf_c
// (measured: zero calls in that function). Do not also copy the w1504
// wide-int pre-check; the Linux fast path already emits that imm64.
// wave431: LINUX -E PREFER (pure-asm product opt=255; -E L2 5/5).
//   MACOS still uses full asm_expr_thin PREFER_ASM.
// wave495: tipU heal; helpers PREFER L2 FAIL → LINUX stayed -E+$CC.
// wave739: LINUX product PREFER_ASM replace leftover gcc W rec
//   (standalone T=2 U=35); MACOS keep full thin overlay.
//   Do not fall back to -E for this TU. Full emit_expr_elf_c tip still BAN.
// wave752: tip classify — live tip leftover gcc W wrapper; full tip -c
//   smash; HARD BAN PREFER tip (helpers PREFER already on LINUX).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

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
export extern function pipeline_asm_try_emit_inline_asm_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
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
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;

export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

/**
 * Load i32 from pipe cell (local; tip-stable mid `x=cell_load()`).
 * @param base *u8 — cell base
 * @return i32 — stored value
 * PLATFORM: SHARED — wave495 tipU heal helper.
 */
function w495_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}


/**
 * Load a field whose own named layout is 9 to 16 bytes as an rax:rdx pair.
 * The fast field path keeps one qword and leaves rdx stale. A one-statement
 * return of that field is the field node, so the return impl never sees it.
 * Only the field's own type is consulted. The function return type is not:
 * a nested block must not borrow the enclosing function's result size.
 * Layouts of at most 8 bytes stay on the fast path.
 * This is the Linux copy of w1738_named16_field_pair in asm_expr_thin.x.
 * Keep the two bodies the same. Darwin links the other file.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — EXPR_FIELD_ACCESS; <=0 returns 0
 * @param ctx *u8 — asm function context for the address
 * @param ta i32 — target arch
 * @return i32 — 1 when the pair was emitted; 0 when this is not a 9..16
 *   named field or the address could not be formed (caller uses fast);
 *   -1 when the pair encoder failed
 * PLATFORM: SHARED — rax:rdx on x86_64, x0:x1 on arm64, same deref helper.
 * Linux links this helpers object. Darwin links asm_expr_thin.x.
 */
function w1738_named16_field_pair(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let ty: i32 = 0;
  let k: i32 = 0;
  let sz: i32 = 0;
  let rc: i32 = 0;
  let cell: u8[8];
  let mod: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || expr_ref <= 0) {
    return 0;
  }
  // Resolved type first. TYPE_NAMED = 8. Size is meaningful only above 8.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_resolved_type_ref(arena, expr_ref));
  }
  ty = w495_cell_i32(&cell[0]);
  if (ty > 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, ty));
    }
    k = w495_cell_i32(&cell[0]);
    if (k == 8) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, glue_type_named_layout_size_any_module_elf_c(arena, ty));
      }
      sz = w495_cell_i32(&cell[0]);
    }
  }
  // Struct-layout field type when the resolved type is not already 9..16.
  if (sz <= 8 || sz > 16) {
    sz = 0;
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      pipe_store_i32_le(&cell[0], 0, glue_field_access_field_type_ref_c(arena, mod, expr_ref));
    }
    ty = w495_cell_i32(&cell[0]);
    if (ty > 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, ty));
      }
      k = w495_cell_i32(&cell[0]);
      if (k == 8) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_type_named_layout_size_any_module_elf_c(arena, ty));
        }
        sz = w495_cell_i32(&cell[0]);
      }
    }
  }
  if (sz <= 8 || sz > 16) {
    return 0;
  }
  // Address, then the existing pair load. A failed address stays on fast.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta));
  }
  rc = w495_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta));
  }
  rc = w495_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Freestanding expr ELF recursion with EXPR_ASM (60) slice0.
 * A named field of 9 to 16 bytes is pair-loaded before the fast path.
 * The fast path keeps one qword and leaves rdx stale. Layouts outside
 * that range, and a failed address, fall through to fast. The later
 * kind-44 arm still handles an enum namespace tag when fast returns -99.
 * Fast path first for every other kind. Kind dispatch includes
 * asm!("template") to try_emit.
 * Omits XLANG_DEBUG_REGEX_EMIT fprintf (wave106 style).
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — ELF emit context
 * @param expr_ref i32 — expression ref; <= 0 skips the kind load
 * @param ctx *u8 — asm function context passed through to callees
 * @param ta i32 — target arch; 0 is x86_64, 1 is arm64, 2 is RISC-V
 * @return i32 — 0 ok; negative error; -99 unhandled from slow
 * PLATFORM: SHARED body. Linux links this helpers object. Darwin links
 * the same pre-check from asm_expr_thin.x. Do not PREFER the full thin
 * on Linux (frame smash).
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  /* wave495: no-local — pipe cells + w495_cell_i32 (ban mid `x=extern()`). */
  let r: i32 = 0;
  let ko: i32 = 0 - 1;
  let out_rc: i32 = 0;
  let ns_tag: i32 = 0;
  let cell_ko: u8[8];
  let cell_r: u8[8];
  let cell_ns: u8[8];
  if (expr_ref > 0) {
    unsafe {
      /* PLATFORM: SHARED — tip drops mid `ko=pipeline_expr_kind_ord_at()`; pipe cell. */
      pipe_store_i32_le(&cell_ko[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
    }
    ko = w495_cell_i32(&cell_ko[0]);
  }
  // EXPR_FIELD_ACCESS = 44. A 9..16 named field is rax:rdx. The fast path
  // loads one qword. Do not consult the function return type here.
  // Same pre-check as asm_expr_thin.x. PLATFORM: SHARED.
  if (ko == 44) {
    unsafe {
      pipe_store_i32_le(&cell_r[0], 0, w1738_named16_field_pair(arena, elf_ctx, expr_ref, ctx, ta));
    }
    r = w495_cell_i32(&cell_r[0]);
    if (r == 1) {
      return 0;
    }
    if (r < 0) {
      return 0 - 1;
    }
  }
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `r=pipeline_asm_emit_expr_elf_fast()`; pipe cell. */
    pipe_store_i32_le(&cell_r[0], 0, pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta));
  }
  r = w495_cell_i32(&cell_r[0]);
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
  /* Stage10 10.2.1: EXPR_ASM (slice1 in-operand needs ctx) */
  if (ko == 60) {
    unsafe {
      return pipeline_asm_try_emit_inline_asm_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
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
      /* PLATFORM: SHARED — tip drops mid `ns_tag=pipeline_expr_enum_namespace_field_tag()`; pipe cell. */
      pipe_store_i32_le(&cell_ns[0], 0, pipeline_expr_enum_namespace_field_tag(arena, expr_ref));
    }
    ns_tag = w495_cell_i32(&cell_ns[0]);
    if (ns_tag >= 0) {
      unsafe {
        return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
      }
    }
    return 0 - 1;
  }
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `out_rc=backend_emit_expr_elf_slow()`; direct return. */
    return backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
  }
}

