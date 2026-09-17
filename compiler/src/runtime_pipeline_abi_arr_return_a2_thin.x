// Thin pure: arr_return path a2 (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl authority.
// PRODUCT: LINUX PREFER peer chain for arr_return.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx: *u8, nbytes: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Path A2: sret return INDEX of large struct.
 * @return i32 — 0 not taken; 1 handled ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_a2_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let rc: i32 = 0;
    // Keep signature parity; mod/fi unused on this arm.
    if (mod == (0 as *u8) && fi < (0 - 1)) {
      return 0;
    }
    if (sret_act == 0 || sret_sz <= 16 || (ta != 0 && ta != 1) || ko != 47) {
      return 0;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx, sret_sz, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 1;
  }
}
