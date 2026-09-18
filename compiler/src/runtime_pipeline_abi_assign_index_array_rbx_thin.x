// Thin pure: INDEX TYPE_ARRAY runtime dest-in-rbx (wave441/w464).
// wave464: esz-only no-local — tip drops mid-peer U on `let x=call()` and on
//   dual-tail total_bytes vs esz (w463 probe U=2/6); total_bytes-preserving
//   reshape SEGV tip. Stride = caller `esz` from
//   `pipeline_asm_index_elem_byte_sz_c` (same as index setup / array dispatcher).
// PRODUCT inject: LINUX PREFER (stamp w464); MACOS skip (g05 mega UNDEF peers).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, arr_ty: i32, stack_off: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;

/**
 * Runtime/non-VAR INDEX TYPE_ARRAY assign via INDEX-lea dest-in-rbx.
 * wave464: no-local — kind/esz guards + scaled lea + mov rbx via
 *   `if (call()!=0)`; fixed-array init via 0/-1 re-call eq-cascade (no
 *   `let rc = call()`); tip otherwise drops mid-peer U. Scale uses caller
 *   `esz` (setup elem byte size); drop `glue_fixed_array_total_bytes_c`
 *   dual-tail which tip eats.
 * @return i32 — 0 ok; -1 err; -3 not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_rbx_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32, ltr: i32): i32 {
  unsafe {
    if (pipeline_type_kind_ord_at(arena, ltr) != 10) {
      return 0 - 3;
    }
    if (esz <= 0) {
      return 0 - 3;
    }
    if (glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, esz) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == 0) {
      glue_index_assign_addr_cache_clear();
      return 0;
    }
    if (glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, ltr, 0 - 3) == (0 - 1)) {
      glue_index_assign_addr_cache_clear();
      return 0 - 1;
    }
    return 0 - 3;
  }
}
