// Thin pure: arr_struct_lit ARRAY_LIT arm (wave440).
// G.7: part of glue_struct_lit_store_fixed_array_field_elf_c authority.
// PRODUCT: LINUX PREFER peer chain for arr_struct_lit.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.
// wave440: early-return flatten — Ubuntu CG002 on else-if / continue nest.

export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_vector_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

/**
 * ARRAY_LIT (iko==46) store into fixed-array struct field.
 * @return i32 — 0 handled; 2 empty lit (caller zero-fills); -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_struct_lit_arrlit_field_elf_c(arena: *u8, elf_ctx: *u8, src: i32, ctx: *u8, ta: i32, sret_direct: i32, field_mag: i32, foff: i32, n_arr: i32, esz: i32): i32 {
  unsafe {
    let lit_n: i32 = 0;
    let ai: i32 = 0;
    let elem_ref: i32 = 0;
    let sret_home: i32 = 0;
    let rc: i32 = 0;
    lit_n = pipeline_expr_array_lit_num_elems_at(arena, src);
    if (lit_n == 0) {
      return 2;
    }
    if (n_arr > 1024) {
      return 0 - 1;
    }
    if (sret_direct == 0) {
      return pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, src, ctx, ta, field_mag);
    }
    sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
    ai = 0;
    while (ai < n_arr) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, src, ai);
      if (elem_ref != 0) {
        rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        rc = backend_enc_push_rax_arch(elf_ctx, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        rc = backend_enc_pop_rax_arch(elf_ctx, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta);
        if (rc != 0) {
          return 0 - 1;
        }
      }
      ai = ai + 1;
    }
    return 0;
  }
}
