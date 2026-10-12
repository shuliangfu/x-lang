// Thin pure: INDEX ko47 slice-base arm (wave479).
// G.7: part of glue_binop_index_ko47_clobbers_rbx (peer-flat).
// wave479: tip U=1/1. PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_index_base_is_slice_at(arena: *u8, expr_ref: i32): i32;

/**
 * Return 1 if INDEX base is slice.
 * @return i32 — 1 clobber; 0 not
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_ko47_slice_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if (pipeline_expr_index_base_is_slice_at(arena, expr_ref) != 0) {
      return 1;
    }
    return 0;
  }
}
