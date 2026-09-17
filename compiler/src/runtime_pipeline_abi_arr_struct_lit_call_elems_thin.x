// Thin pure: arr_struct_lit CALL per-elem copy esz<=8 (wave440/442).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: MACOS pure-asm / LINUX -E (w442; pure-asm residual).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// wave440b: flatten esz/sret nests — Ubuntu emptied on nested if under while.

export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_struct_lit_call_one_elem_elf_c(elf_ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, esz: i32, spill_off: i32, ai: i32, sret_home: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * CALL/INDEX/DEREF path when esz<=8: emit to spill then per-elem stores.
 * @return i32 — 0 ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_call_elems_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let ly: *u8 = 0 as *u8;
    let spill_off: i32 = 0;
    let next_off: i32 = 0;
    let sret_home: i32 = 0;
    let rc: i32 = 0;
    let ai: i32 = 0;
    ly = pipeline_asm_ctx_layout(ctx);
    if (ly == (0 as *u8)) {
      return 0 - 1;
    }
    rc = pipe_asm_ctx_off_next_offset();
    next_off = pipe_load_i32_le(ly, rc);
    if (next_off + 16 < next_off) {
      return 0 - 1;
    }
    next_off = next_off + 16;
    rc = pipe_asm_ctx_off_next_offset();
    pipe_store_i32_le(ly, rc, next_off);
    spill_off = next_off;
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
    ai = 0;
    while (ai < n_arr) {
      rc = glue_struct_lit_call_one_elem_elf_c(elf_ctx, ta, sret_direct, field_mag, foff, esz, spill_off, ai, sret_home);
      if (rc != 0) {
        return 0 - 1;
      }
      ai = ai + 1;
    }
    return 0;
  }
}
