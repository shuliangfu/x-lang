// Thin pure: INDEX generic try_* simple cascade (wave471).
// G.7: part of pipeline_asm_emit_assign_elf_c INDEX generic path
//   (peer-flat; esz in {1,4,8} lit/idx/plus/minus/mul/var tries).
// wave441b: monolithic generic tip `let x=call()` U-starved (1/171);
//   dead locals + 170 unused externs.
// wave471: try peer — eq-cascade no-local (stores class); Tip U=9/9.
//   PRODUCT: LINUX PREFER with disp+try2+scaled.
// wave607: leftover PREFER smash (`sub $0x1098`, no endbr64) emits every
//   finish_store arm (extra pop overwrites u8 dest). LINUX -E is product.
//   HARD BAN PREFER. MACOS keep overlay. Do not Soft-Cap.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_try_index_var_lit_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_index_assign_finish_store_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32, ta: i32): i32;

// INDEX generic try_* simple — lit/idx/plus/minus/mul/var addr to rbx then finish.
// wave471: no-local eq-cascade (no let-bound call); esz must be 1/4/8.
// @return i32 — 0 ok; -1 err from finish; -3 not handled
// PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
#[no_mangle]
export function glue_emit_assign_index_generic_try_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  unsafe {
    if (esz != 1) {
      if (esz != 4) {
        if (esz != 8) {
          return 0 - 3;
        }
      }
    }
    if (glue_try_index_var_lit_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_plus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_plus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_minus_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_mul_lit_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    if (glue_try_index_var_mul_var_idx_addr_to_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz) == 0) {
      return glue_index_assign_finish_store_elf_c(arena, elf_ctx, ctx, base_ref, idx_ref, esz, ta);
    }
    return 0 - 3;
  }
}
