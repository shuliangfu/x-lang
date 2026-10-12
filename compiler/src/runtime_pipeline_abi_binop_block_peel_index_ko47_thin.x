// Thin pure: peel INDEX ko47 rbx-clobber gate (wave435/w479).
// G.7: twin of glue_binop_operand_index_addr_clobbers_rbx_elf_c INDEX arm.
// wave479: peer-flat split (monolith tip U=1/8). Tip U=5/5.
//   PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_binop_index_ko47_slice_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_ty11_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_base_kind_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_fa_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_lit_elf_c(arena: *u8, expr_ref: i32): i32;

/**
 * INDEX (ko==47) rbx-clobber decision — peer cascade.
 * wave479: no-local — peer 0/1 cascade; ban `let x=call()`.
 * @return i32 — 1 if INDEX emit parks rbx; 0 if base+imm*esz path
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_binop_index_ko47_clobbers_rbx(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if (glue_binop_index_ko47_slice_elf_c(arena, expr_ref) != 0) {
      return 1;
    }
    if (glue_binop_index_ko47_ty11_elf_c(arena, expr_ref) != 0) {
      return 1;
    }
    if (glue_binop_index_ko47_base_kind_elf_c(arena, expr_ref) != 0) {
      return 1;
    }
    if (glue_binop_index_ko47_fa_elf_c(arena, expr_ref) != 0) {
      return 1;
    }
    return glue_binop_index_ko47_lit_elf_c(arena, expr_ref);
  }
}
