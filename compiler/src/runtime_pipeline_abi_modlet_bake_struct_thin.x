// STRUCT_LIT baker for Darwin and Windows module arrays.
// Ubuntu's pipe_modlet_bake_struct_lit_to_data lives in the Linux
// modlet thin and folds floats through pipe_modlet_fold_f64_elem_bits.
// This body calls the Darwin/Windows folder instead. Return 4 is one
// f32 word. Return 5 is both f64 halves. Do not link this object on
// Linux, and do not paste that helper here.
// PLATFORM: MACOS|DARWIN / WINDOWS.

export extern "C" function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern "C" function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, field_ix: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_offset_at(arena: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_type_ref_at(arena: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
/**
 * Copy a TYPE_NAMED spelling into out. Cap residual i8/i16/u16 have no
 * TypeKind; the baker uses the same name bytes as typeck_int_family_id.
 * PLATFORM: SHARED.
 */
export extern "C" function pipeline_type_named_name_into(arena: *u8, ref: i32, out: *u8): i32;
export extern "C" function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_val: *i32, out_hi: *i32): i32;
export extern "C" function pipe_modlet_bake_array_lit_elems_to_data(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32,
  data_base: i32, base_off: i32, span_bytes: i32, m: *u8
): i32;
export extern "C" function pipe_modlet_bake_ptr_addr_elem_to_data(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, slot_off: i32
): i32;
export extern "C" function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32;

/**
 * Poke one STRUCT_LIT into an already-zeroed data span.
 * Each field init goes through the existing bakers. A scalar field
 * calls pipe_modlet_array_lit_elem_const_val. Return 1 sign-fills an
 * 8-byte slot. Return 2 keeps a zero high half. Return 3 stores
 * out_hi. Return 4 stores one f32 word and leaves the high half 0.
 * Return 5 stores both f64 halves and does not sign-fill a negative
 * low word. S { v: 1.0 } for an f64 field is 000000000000f03f.
 * 0.1 keeps high 0x3fb99999. Nested STRUCT_LIT recurses. STRING_LIT,
 * ARRAY_LIT, and pointer or function fields keep their bakers.
 * TYPE_NAMED Cap residual i8/i16/u16 are scalar fields: typeck sizes
 * them as 4 today (named_builtin_size falls through to 4), so this
 * baker peels four bytes. Other named spellings stay loud-fail.
 * Padding stays the reserved zero. More than 64 fields loud-fails.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — object writer; null returns -1
 * @param lit_ref i32 — STRUCT_LIT expr; <= 0 returns -1
 * @param elem_base i32 — data offset of this struct; < 0 returns -1
 * @param m *u8 — module that owns the layout; null returns -1
 * @return i32 — 0 when the literal is baked, -1 when it must loud-fail
 * PLATFORM: MACOS|DARWIN / WINDOWS — do not link this object on Linux.
 */
#[no_mangle]
export function pipe_modlet_bake_struct_lit_to_data(
  arena: *u8, elf_ctx: *u8, lit_ref: i32, elem_base: i32, m: *u8
): i32 {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let iref: i32 = 0;
  let ik: i32 = 0;
  let foff: i32 = 0;
  let fsz: i32 = 0;
  let fty: i32 = 0;
  let fk: i32 = 0;
  let et: i32 = 0;
  let span: i32 = 0;
  let ev: i32 = 0;
  let ehi: i32 = 0;
  let rc: i32 = 0;
  let done: i32 = 0;
  let hi: i32 = 0;
  let b0: i32 = 0;
  let b1: i32 = 0;
  let b2: i32 = 0;
  let b3: i32 = 0;
  let h0: i32 = 0;
  let h1: i32 = 0;
  let h2: i32 = 0;
  let h3: i32 = 0;
  let slot: i32 = 0;
  let nlen: i32 = 0;
  let named_ok: i32 = 0;
  let nm: u8[8] = [];
  if (arena == 0 as *u8 || elf_ctx == 0 as *u8 || m == 0 as *u8 || lit_ref <= 0 || elem_base < 0) {
    return 0 - 1;
  }
  unsafe {
    nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  }
  if (nf < 0 || nf > 64) {
    return 0 - 1;
  }
  fi = 0;
  while (fi < nf) {
    unsafe {
      iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi);
    }
    if (iref > 0) {
      unsafe {
        ik = pipeline_expr_kind_ord_at(arena, iref);
        foff = pipeline_expr_struct_lit_field_offset_at(arena, m, lit_ref, fi);
      }
      if (foff < 0) {
        return 0 - 1;
      }
      slot = elem_base + foff;
      done = 0;
      // Nested struct. Same baker, field offset added to the base.
      if (ik == 45) {
        unsafe {
          rc = pipe_modlet_bake_struct_lit_to_data(arena, elf_ctx, iref, slot, m);
        }
        if (rc != 0) {
          return rc;
        }
        done = 1;
      }
      if (done == 0 && ik == 59) {
        unsafe {
          rc = pipe_modlet_bake_string_lit_elem_to_data(arena, elf_ctx, iref, slot);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        done = 1;
      }
      if (done == 0 && ik == 46) {
        fty = 0;
        span = 0;
        et = 0;
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi);
        }
        if (fty <= 0) {
          return 0 - 1;
        }
        unsafe {
          span = glue_fixed_array_total_bytes_c(arena, fty, 0);
          et = pipeline_type_elem_ref_at(arena, fty);
        }
        if (span <= 0) {
          return 0 - 1;
        }
        unsafe {
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            arena, elf_ctx, iref, et, slot, 0, span, m);
        }
        if (rc != 0) {
          return rc;
        }
        done = 1;
      }
      if (done == 0) {
        fk = 0;
        fty = 0;
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, m, lit_ref, fi);
        }
        if (fty > 0) {
          unsafe {
            fk = pipeline_type_kind_ord_at(arena, fty);
          }
        }
        // TYPE_PTR (9) and TYPE_FN (18). A return of 0 means the
        // address baker wrote the slot.
        if (fk == 9 || fk == 18) {
          unsafe {
            rc = pipe_modlet_bake_ptr_addr_elem_to_data(arena, elf_ctx, m, iref, 8, slot);
          }
          if (rc < 0) {
            return 0 - 1;
          }
          if (rc == 0) {
            done = 1;
          }
        }
      }
      if (done == 0) {
        // 1 bool, 2 u8, 0 i32, 3 u32, 13 the 4-byte kind the Linux
        // width helper accepts, 14 f32. 4 u64, 5 i64, 6 usize,
        // 7 isize, 15 f64. TYPE_NAMED (8) Cap residual i8/i16/u16:
        // typeck sizes them as 4 today, so peel four bytes. Other
        // named spellings are not scalar fields.
        // PLATFORM: SHARED — name bytes match typeck_int_family_id.
        fsz = 0;
        if (fk == 1 || fk == 2) {
          fsz = 1;
        }
        if (fk == 0 || fk == 3 || fk == 13 || fk == 14) {
          fsz = 4;
        }
        if (fk == 4 || fk == 5 || fk == 6 || fk == 7 || fk == 15) {
          fsz = 8;
        }
        if (fk == 8) {
          named_ok = 0;
          unsafe {
            nlen = pipeline_type_named_name_into(arena, fty, &(nm[0]));
          }
          // "i8"
          if (nlen == 2) {
            if (nm[0] == 105) {
              if (nm[1] == 56) {
                named_ok = 1;
              }
            }
          }
          // "i16"
          if (nlen == 3) {
            if (nm[0] == 105) {
              if (nm[1] == 49) {
                if (nm[2] == 54) {
                  named_ok = 1;
                }
              }
            }
          }
          // "u16"
          if (nlen == 3) {
            if (nm[0] == 117) {
              if (nm[1] == 49) {
                if (nm[2] == 54) {
                  named_ok = 1;
                }
              }
            }
          }
          if (named_ok == 1) {
            fsz = 4;
          }
        }
        if (fsz <= 0) {
          return 0 - 1;
        }
        ev = 0;
        ehi = 0;
        unsafe {
          rc = pipe_modlet_array_lit_elem_const_val(arena, iref, &ev, &ehi);
        }
        if (rc == 0) {
          return 0 - 1;
        }
        // Same high-half rule as the array baker. Return 4 is f32
        // bits. Return 5 is f64 bits. A negative low word of an f64
        // is a mantissa bit. 0.1 stores high 0x3fb99999.
        b0 = ev & 255;
        b1 = (ev >> 8) & 255;
        b2 = (ev >> 16) & 255;
        b3 = (ev >> 24) & 255;
        hi = 0;
        if (ev < 0) {
          if (rc != 2) {
            if (rc != 4) {
              if (rc != 5) {
                hi = 255;
              }
            }
          }
        }
        h0 = hi;
        h1 = hi;
        h2 = hi;
        h3 = hi;
        if (rc == 3) {
          h0 = ehi & 255;
          h1 = (ehi >> 8) & 255;
          h2 = (ehi >> 16) & 255;
          h3 = (ehi >> 24) & 255;
        }
        if (rc == 5) {
          h0 = ehi & 255;
          h1 = (ehi >> 8) & 255;
          h2 = (ehi >> 16) & 255;
          h3 = (ehi >> 24) & 255;
        }
        if (fsz > 0) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot, b0);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 1) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 1, b1);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 2) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 2, b2);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 3) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 3, b3);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 4) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 4, h0);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 5) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 5, h1);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 6) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 6, h2);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (fsz > 7) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 7, h3);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
      }
    }
    fi = fi + 1;
  }
  return 0;
}
