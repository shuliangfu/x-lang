// Thin pure overlay (w1521, 终局待办 10.57): INDEX base effective address
// for `v.p[i]` where p is a *T struct field. The pabi body peels the pointer
// field once inside the FIELD branch (glue_index_deref_ptr_field_slot_rax_elf_c)
// and then again in the trailing non-slice arm (base_ko == 44), so the element
// load read *(*(v.p)) (read_ptr_view_smoke / p_pv: address = string bytes).
// Same body as runtime_pipeline_abi.x glue_emit_index_eff_addr_base_elf_c,
// except the trailing FIELD peel is skipped when the field type is PTR (9):
// that peel already happened. SLICE fields and every other base are unchanged.
// Why an overlay: the impl lives in runtime_pipeline_abi.x (pabi, frozen;
// Darwin / Linux / Win link the pabi_weak object). Merge back list: 10.26.
// Linked by g05_relink_env (_g05_pure_overlay index_base_field) before
// seeds; pabi_weak.o _glue_emit_index_eff_addr_base_elf_c weakened.
// PLATFORM: SHARED (ELF / Mach-O / COFF emit, all ta).

export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(
  arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function glue_index_deref_ptr_field_slot_rax_elf_c(arena: *u8, elf_ctx: *u8, fa_ref: i32, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function glue_emit_import_module_const_field_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, arr_sz_out: *i32
): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, base_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_asm_emit_ctx_module_get(): *u8;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;

/**
 * 1 when FIELD_ACCESS fa_ref has a PTR (9) field type, else 0.
 * PLATFORM: SHARED.
 */
function w1521_ib_field_is_ptr(arena: *u8, fa_ref: i32): i32 {
  let mod: *u8 = 0 as *u8;
  let ftr: i32 = 0;
  let fk: i32 = 0;
  unsafe {
    mod = pipeline_asm_emit_ctx_module_get();
    ftr = glue_field_access_field_type_ref_c(arena, mod, fa_ref);
  }
  if (ftr <= 0) {
    return 0;
  }
  unsafe {
    fk = pipeline_type_kind_ord_at(arena, ftr);
  }
  if (fk == 9) {
    return 1;
  }
  return 0;
}

/**
 * INDEX base effective address into x0.
 * A VAR field base (`h.v[i]`) is the local slot address plus the field
 * offset. A nested FIELD base (`w.h.v[i]`) uses the lvalue address of
 * the parent field. emit_expr of that parent loads the by-value bits, and
 * the lane load then uses those bits as a pointer (Darwin `w.h.v[0]`
 * exit 10). A PTR parent stays on emit_expr: that rvalue is already the
 * pointee address. An INDEX base (`arr[0][i]`) uses the lvalue address
 * of that inner INDEX. emit_expr of the inner INDEX loads the by-value
 * element, and the outer lane load then uses those bits as a pointer
 * (Darwin `arr[0][0]` exit 1). PTR and SLICE elements stay on emit_expr.
 * A slice-typed INDEX already ran deref_struct16, so x0 is the data
 * pointer. The trailing header load is skipped for that base. A VAR
 * slice still holds the header address and still loads.
 * A CALL or METHOD base still uses emit_expr. When that rvalue is a
 * 16-byte SIMD, the pair is spilled with the existing stp and x0 becomes
 * the slot address. emit_expr left the bits in x0:x1, and the lane load
 * then used those bits as a pointer (Darwin `add4(a,b)[1]` SIGBUS).
 * A fixed array of at most 8 bytes is the same class. The value sits in
 * x0, so the lane load treats those bits as a pointer (Darwin `pick()[0]`
 * where pick returns `[2]i32`, SIGBUS). str x0, [sp, #-16]! then
 * add x0, sp, #0 makes x0 the slot address. A pointer, a slice, and an
 * array larger than 8 bytes stay the rvalue emit_expr left. This base
 * does not add sp back: the lane load still reads the slot.
 * pipeline_asm_emit_index_elf_c adds 16 after that load. A nested
 * arr[add4(...)[0]] would otherwise pop the vector as the array base
 * (SIGBUS). An lvalue that keeps the slot address still relies on the
 * epilogue.
 * DEREF stays an rvalue. A vector wider than 16 bytes is not spilled.
 * Slice and pointer fields of the indexed field still peel through
 * glue_index_deref_ptr_field_slot_rax_elf_c.
 * @param arena *u8 — AST arena; null is not expected (callers checked)
 * @param elf_ctx *u8 — encoder context
 * @param ix_ref i32 — INDEX expression; base ref <= 0 returns -1
 * @param ctx *u8 — asm function context; null is not expected
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when x0 holds the element base address; -1 on a bad
 *   base or an encoder error
 * PLATFORM: SHARED body. Darwin ARM64 measured the nested-FIELD fail,
 * the nested-INDEX fail, the 16-byte CALL-base SIGBUS, and the 8-byte
 * array CALL-base SIGBUS. Both spills are ta == 1 only; x86_64 does not
 * emit those words.
 */
#[no_mangle]
export function glue_emit_index_eff_addr_base_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, ctx: *u8, ta: i32): i32 {
  let base_ref: i32 = 0;
  let base_ko: i32 = 0;
  let tr: i32 = 0;
  let trk: i32 = 0;
  let lanes_buf: i32[1] = [];
  let esz_buf: i32[1] = [];
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let simd: i32 = 0;
  let abytes: i32 = 0;
  let fb_ref: i32 = 0;
  let field_off: i32 = 0;
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0;
  let is_enum: i32 = 0;
  let fb_ko: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let peeled_ptr: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (base_ko == 44) {
    unsafe {
      is_enum = pipeline_expr_field_access_is_enum_variant(arena, base_ref);
    }
  }
  if (base_ko == 44 && is_enum == 0) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
      field_off = glue_field_access_effective_offset_c(arena, mod, base_ref);
    }
    if (fb_ref > 0) {
      unsafe {
        fb_ko = pipeline_expr_kind_ord_at(arena, fb_ref);
      }
    } else {
      fb_ko = 0;
    }
    if (fb_ref > 0 && fb_ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(arena, fb_ref);
      }
      if (vlen <= 0 || vlen > 255) {
        return 0 - 1;
      }
      unsafe {
        pipeline_expr_var_name_into(arena, fb_ref, &vname[0]);
        off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
      }
      if (off < 0) {
        // `dep.A[i]`: the base name is an import binding, not a local.
        // The helper leaves the array address in x0. It is not a struct
        // member, so do not add field_off or deref a pointer slot.
        // A miss stays -1 (CG002). PLATFORM: MACOS|ARM64 · LINUX x86_64.
        let arr_cell: i32[1] = [];
        arr_cell[0] = 0;
        unsafe {
          rc = glue_emit_import_module_const_field_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta, &arr_cell[0]);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        return 0;
      }
      unsafe {
        rc = glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, fb_ref, off, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      if (fb_ref <= 0) {
        return 0 - 1;
      }
      // Nested FIELD only. CALL and DEREF stay rvalues.
      // PTR parent: emit_expr is the pointee address. By-value parent:
      // lvalue address, then the field offset below. Do not call lvalue
      // on base_ref itself — that already includes this field's offset.
      // PLATFORM: SHARED. Darwin ARM64 measured w.h.v[0].
      tr = 0;
      trk = 0;
      if (fb_ko == 44) {
        unsafe {
          tr = glue_field_access_field_type_ref_c(arena, mod, fb_ref);
        }
        if (tr > 0) {
          unsafe {
            trk = pipeline_type_kind_ord_at(arena, tr);
          }
        }
      }
      if (fb_ko == 44 && trk != 9) {
        unsafe {
          rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, fb_ref, ctx, ta);
        }
      } else {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, fb_ref, ctx, ta);
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    if (field_off != 0) {
      unsafe {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    peeled_ptr = w1521_ib_field_is_ptr(arena, base_ref);
  } else {
    if (base_ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(arena, base_ref);
      }
      if (vlen <= 0 || vlen > 255) {
        return 0 - 1;
      }
      unsafe {
        pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
        off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
      }
      if (off < 0) {
        unsafe {
          rc = pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &vname[0], vlen, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        unsafe {
          rc = glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    } else {
      // INDEX base (`arr[0][i]`). emit_expr loads the by-value element
      // into x0:x1; the outer lane load then uses those bits as a
      // pointer. lvalue of the inner INDEX is its element address
      // (scaled lea). The inner base is not this INDEX, so this does
      // not recurse. PTR (9) and SLICE (11) stay on emit_expr. A slice
      // INDEX already leaves the data pointer in x0 (deref_struct16).
      // The trailing load below is for a header address, so kind 47
      // skips it. CALL and METHOD stay rvalues here. A 16-byte SIMD pair
      // and a fixed array of at most 8 bytes are spilled below, after
      // this emit. DEREF stays an rvalue.
      // PLATFORM: SHARED. Darwin ARM64 measured arr[0][0].
      tr = 0;
      trk = 0;
      if (base_ko == 47) {
        unsafe {
          tr = pipeline_expr_resolved_type_ref(arena, base_ref);
        }
        if (tr <= 0) {
          unsafe {
            tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
          }
        }
        if (tr > 0) {
          unsafe {
            trk = pipeline_type_kind_ord_at(arena, tr);
          }
        }
      }
      if (base_ko == 47 && trk != 9 && trk != 11) {
        unsafe {
          rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
        }
      } else {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta);
        }
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  if (peeled_ptr != 0) {
    return 0;
  }
  unsafe {
    tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  }
  if (tr <= 0) {
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
  }
  if (tr > 0) {
    unsafe {
      trk = pipeline_type_kind_ord_at(arena, tr);
    }
  } else {
    trk = 0;
  }
  if (tr > 0 && trk == 11) {
    /* VAR and other header addresses still need load_64 to fetch the
     * data pointer. Kind 47 already did that inside emit_expr
     * (deref_struct16: ldr x0,[x1] and the length at +8). Another
     * load_64 treats the payload as a pointer (SIGBUS on x[0][0]).
     * Kind 52 is a deref of *[]T: emit_expr already left the slice
     * data pointer in x0. Another load_64 reads the i32 element as
     * an address (`(*p)[0]` SIGSEGV). PLATFORM: SHARED. Darwin ARM64
     * measured [2][]i32 and *[]i32. */
    if (base_ko != 47 && base_ko != 52) {
      unsafe {
        rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  } else {
    if (base_ko == 44) {
      unsafe {
        rc = glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  // CALL (48) or METHOD (49) on arm64. emit_expr left a 16-byte SIMD
  // in x0:x1. stp stores that pair and add x0, sp, #0 makes x0 the
  // slot address the lane load expects. Same two words as the pair
  // address in assign_index_one_pair_finish. Do not add sp back: the
  // load still reads the slot, and the epilogue restores sp from x29.
  // Slice (trk 11) is excluded: its header was already loaded. A
  // pointer is not a SIMD spelling, so it is not spilled. DEREF (52)
  // stays an rvalue. Wider than 16 stays a value.
  // TYPE_ARRAY (10) of 1 to 8 bytes is also in x0, not a pointer.
  // str x0, [sp, #-16]! then the same add x0, sp, #0. An array larger
  // than 8 bytes stays the rvalue: sret already left a pointer in x0.
  // PLATFORM: MACOS|ARM64. ta != 1 skips this. Measured add4(a,b)[1]
  // and pick()[0] where pick returns [2]i32.
  if (ta == 1 && trk != 11 && (base_ko == 48 || base_ko == 49) && tr > 0) {
    unsafe {
      simd = asm_type_is_simd_vector_spelling(arena, tr);
    }
    if (simd != 0) {
      rc = 0;
      unsafe {
        rc = glue_vector_type_lanes_esz_c(arena, tr, &lanes_buf[0], &esz_buf[0]);
      }
      if (rc == 0) {
        lanes = lanes_buf[0];
        esz = esz_buf[0];
        if (lanes > 0 && esz > 0 && lanes * esz == 16) {
          unsafe {
            rc = backend_enc_append_u32_le_c(elf_ctx, 2847868896 as u32);
          }
          if (rc == 0) {
            unsafe {
              rc = backend_enc_append_u32_le_c(elf_ctx, 2432697312 as u32);
            }
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
      }
    }
    if (simd == 0) {
      if (trk == 10) {
        unsafe {
          mod = pipeline_asm_emit_module_ref_c();
          abytes = glue_type_size_simple(mod, arena, tr, 0);
        }
      }
    }
    if (abytes > 0) {
      if (abytes <= 8) {
        rc = 0;
        unsafe {
          rc = backend_enc_push_rax_arch(elf_ctx, ta);
        }
        if (rc == 0) {
          unsafe {
            rc = backend_enc_append_u32_le_c(elf_ctx, 2432697312 as u32);
          }
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
  }
  return 0;
}
