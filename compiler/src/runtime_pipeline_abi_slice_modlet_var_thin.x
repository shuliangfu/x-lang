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
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *u8, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_store_retval_pair_to_rbp_elf_c(mod: *u8, arena: *u8, elf_ctx: *u8, type_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;

/**
 * Dest-SLICE let whose init is a module TYPE_ARRAY variable.
 * Loads the COMMON address and stores the array's element count in the
 * length half. A local array, an index, a literal, or a miss delegates
 * to the previous let-init object.
 * @param arena *u8 — AST arena; null delegates
 * @param elf_ctx *u8 — ELF codegen context; null delegates
 * @param block_ref i32 — enclosing block; 0 is an ARRAY_LIT row element
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
    // block_ref 0 is an ARRAY_LIT row (`let x: [][]i32 = [A]`). The same
    // store is used. The frame-size walk adds room for that home so it
    // is not the caller's saved fp. PLATFORM: SHARED.
    if (tk != 11) {
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    let src: i32 = glue_peel_as_array_slice_ascription_c(arena, init_ref);
    if (src <= 0) {
      src = init_ref;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, src);
    // EXPR_FIELD_ACCESS = 44. `{ xs: [1, 2] }.xs` is a STRUCT_LIT field
    // whose init is an ARRAY_LIT. The previous object returns -1 (CG002).
    // Durable that literal and store N. A VAR / CALL / INDEX field stays
    // on the previous object. Name copies clear 256 bytes.
    // PLATFORM: MACOS|ARM64 · LINUX x86_64.
    if (ko == 44) {
      let base_er: i32 = pipeline_expr_field_access_base_ref(arena, src);
      if (base_er > 0 && pipeline_expr_kind_ord_at(arena, base_er) == 45) {
        let fa_len: i32 = pipeline_expr_field_access_name_len(arena, src);
        let fa_name: u8[256] = [];
        let sl_name: u8[256] = [];
        if (fa_len > 0 && fa_len <= 255) {
          pipeline_expr_field_access_name_into(arena, src, &fa_name[0]);
          let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, base_er);
          let fj: i32 = 0;
          let lit: i32 = 0;
          while (fj < nf) {
            if (lit == 0) {
              let sl_len: i32 = pipeline_expr_struct_lit_field_name_len(arena, base_er, fj);
              if (sl_len == fa_len) {
                pipeline_expr_struct_lit_field_name_into(arena, base_er, fj, &sl_name[0]);
                let bi: i32 = 0;
                let same: i32 = 1;
                while (bi < fa_len) {
                  if (fa_name[bi] != sl_name[bi]) {
                    same = 0;
                  }
                  bi = bi + 1;
                }
                if (same != 0) {
                  let init_f: i32 = pipeline_expr_struct_lit_init_ref(arena, base_er, fj);
                  if (init_f > 0 && pipeline_expr_kind_ord_at(arena, init_f) == 46) {
                    lit = init_f;
                  }
                }
              }
            }
            fj = fj + 1;
          }
          if (lit > 0) {
            let n_lit: i32 = pipeline_expr_array_lit_num_elems_at(arena, lit);
            // `let s: []i64 = W{ xs: [1025] }.xs` used to miss this
            // and fall through to CG002. 16777216 matches the durable
            // literal ceiling. An empty `xs: []` stays on the previous
            // object because n_lit is 0.
            // PLATFORM: SHARED. Mac product mov w0, #16777216 at file 0x18e24.
            if (n_lit > 0 && n_lit <= 16777216) {
              let elem_ty: i32 = pipeline_type_elem_ref_at(arena, let_type_ref);
              let esz: i32 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
              if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, lit, esz, ta, ctx, elem_ty) == 0) {
                if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0) {
                  return 0 - 1;
                }
                if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_lit, 0, ta) != 0) {
                  return 0 - 1;
                }
                let len_off: i32 = glue_slice_dual_gp_length_off_c(slice_slot_off, ta);
                if (backend_enc_store_rax_to_rbp_arch(elf_ctx, len_off, ta) != 0) {
                  return 0 - 1;
                }
                return 1;
              }
            }
          }
        }
      }
      return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
    }
    // EXPR_INDEX = 47 of TYPE_ARRAY of TYPE_SLICE (`let s = a[0]` of
    // `[2][]i64`). emit_expr already fills x0/x1; store both words.
    // The previous object wrongly took outer N and lea of the slice
    // header (length luckily 2, data pointer wrong, exit 3).
    // PLATFORM: MACOS|ARM64 · LINUX x86_64. Cap tip soft on _prev
    // skips that else at 0x1001eb258 / 0x1001eb5f4.
    if (ko == 47) {
      let base_ref: i32 = pipeline_expr_index_base_ref(arena, src);
      if (base_ref <= 0) {
        return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
      }
      let btr: i32 = pipeline_expr_resolved_type_ref(arena, base_ref);
      if (btr <= 0) {
        return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
      }
      let btk: i32 = pipeline_type_kind_ord_at(arena, btr);
      if (btk != 10) {
        return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
      }
      let etr: i32 = pipeline_type_elem_ref_at(arena, btr);
      if (etr <= 0) {
        return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
      }
      let etk: i32 = pipeline_type_kind_ord_at(arena, etr);
      if (etk != 11) {
        return glue_emit_slice_from_array_let_init_elf_c_prev(arena, elf_ctx, block_ref, let_idx, init_ref, let_type_ref, ctx, ta, slice_slot_off);
      }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta) != 0) {
        return 0 - 1;
      }
      let mod2: *u8 = glue_emit_module_from_ctx(ctx);
      if (glue_store_retval_pair_to_rbp_elf_c(mod2, arena, elf_ctx, let_type_ref, slice_slot_off, ta, src, ctx) != 0) {
        return 0 - 1;
      }
      return 1;
    }
    // EXPR_VAR = 3. ARRAY_LIT and other INDEX stay on the previous object.
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
