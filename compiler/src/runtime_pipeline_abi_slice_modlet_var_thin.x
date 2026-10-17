// Overlay for glue_emit_slice_from_array_let_init_elf_c.
// The mega body already recovers N for `let s: []T = ModuleArray` from the
// module top-level table and loads the COMMON cell. The linked object is
// older and returns 0, so the let-init fallback stores whatever is in x1
// as the length (`const v: []i32 = B` exits 4). This prefix handles only
// that VAR. Every other init calls the previous object.
// The name buffer is 256 bytes: pipeline_expr_var_name_into memsets 256.
// PLATFORM: MACOS|ARM64 · LINUX x86_64.

export extern function glue_emit_slice_from_array_let_init_elf_c_prev(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_module_top_level_let_name_len(module: *u8, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *u8, idx: i32, off: i32): i32;
export extern function pipeline_module_top_level_let_type_ref(module: *u8, idx: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_modlet_find(name: *u8, name_len: i32): i32;
export extern function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;

/**
 * Dest-SLICE let whose init is a module TYPE_ARRAY variable.
 * Loads the COMMON address and stores the array's element count in the
 * length half. A local array, an index, a literal, or a miss delegates
 * to the previous let-init object.
 * @param arena *u8 — AST arena; null delegates
 * @param elf_ctx *u8 — ELF codegen context; null delegates
 * @param block_ref i32 — enclosing block; <=0 delegates (nested row)
 * @param let_idx i32 — let index; unused on this arm
 * @param init_ref i32 — init expr
 * @param let_type_ref i32 — dest type; must be TYPE_SLICE to enter
 * @param ctx *u8 — AsmFuncCtx; null delegates
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param slice_slot_off i32 — frame offset of the data half
 * @return i32 — 1 written; 0 not this arm (previous object); -1 encoder failure
 * PLATFORM: MACOS|ARM64 · LINUX x86_64.
 */
#[no_mangle]
export function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32 {
  unsafe {
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || let_type_ref <= 0 || init_ref <= 0) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    let tk: i32 = pipeline_type_kind_ord_at(arena, let_type_ref);
    // TYPE_SLICE = 11. Anything else is the previous object's job.
    // block_ref 0 is an ARRAY_LIT row calling back for one element. That
    // slot can sit past the frame this object reserved. Writing it smashes
    // the caller (`let x: [][]i32 = [A]`). Those rows stay on the previous
    // object. A real let has block_ref > 0.
    // PLATFORM: SHARED.
    if (tk != 11 || block_ref <= 0) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    let src: i32 = glue_peel_as_array_slice_ascription_c(arena, init_ref);
    if (src <= 0) {
      src = init_ref;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, src);
    // EXPR_VAR = 3. INDEX and ARRAY_LIT stay on the previous object.
    if (ko != 3) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    let vlen: i32 = pipeline_expr_var_name_len(arena, src);
    if (vlen <= 0 || vlen > 255) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    // name_into clears 256 bytes. A shorter buffer overwrites the frame.
    let vname: u8[256] = [];
    pipeline_expr_var_name_into(arena, src, &vname[0]);
    let mod: *u8 = pipeline_asm_emit_module_ref_c();
    let arr_sz: i32 = 0;
    if (mod != (0 as *u8)) {
      // Hoist leaves TYPE_ARRAY rows in this table and copies dest-SLICE
      // rows into main. Scan a fixed prefix; a zero name length is a hole,
      // not the end. PLATFORM: SHARED.
      let li: i32 = 0;
      while (li < 64) {
        if (arr_sz <= 0) {
          let nlen: i32 = pipeline_module_top_level_let_name_len(mod, li);
          if (nlen == vlen) {
            let matched: i32 = 1;
            let ci: i32 = 0;
            while (ci < nlen) {
              let nb: i32 = pipeline_module_top_level_let_name_byte_at(mod, li, ci);
              if ((nb as u8) != vname[ci]) {
                matched = 0;
              }
              ci = ci + 1;
            }
            if (matched != 0) {
              let tr: i32 = pipeline_module_top_level_let_type_ref(mod, li);
              if (tr > 0) {
                tk = pipeline_type_kind_ord_at(arena, tr);
                // TYPE_ARRAY = 10. A slice module let is not this arm.
                if (tk == 10) {
                  arr_sz = pipeline_type_array_size_at(arena, tr);
                }
              }
            }
          }
        }
        li = li + 1;
      }
    }
    let found: i32 = 0 - 1;
    if (arr_sz > 0 && arr_sz <= 1024) {
      found = pipeline_asm_modlet_find(&vname[0], vlen);
    }
    if (found < 0 || arr_sz <= 0) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    if (pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &vname[0], vlen, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0) {
      return 0 - 1;
    }
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0) {
      return 0 - 1;
    }
    let len_off: i32 = glue_slice_dual_gp_length_off_c(slice_slot_off, ta);
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, len_off, ta) != 0) {
      return 0 - 1;
    }
    return 1;
  }
}
