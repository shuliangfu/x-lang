// Module-array baker for Darwin. The weak gcc body in pabi_weak.o peels
// one uint32, so an 8-byte slot's high half is always zero.
// This strong definition is the same control flow, and the high half is
// the sign fill of that i32 word. Ubuntu's modlet.o already writes a real
// high half through the 4-arg folder. Do not link this object on Linux
// or Windows: Linux would hide that baker, and the Windows egg is the
// Windows body.
// PLATFORM: MACOS|DARWIN. Do not PREFER this into runtime_pipeline_abi.o.

export extern "C" function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern "C" function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern "C" function pipeline_elf_ctx_data_poke_u8(ctx_bytes: *u8, off: i32, b: i32): i32;
export extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern "C" function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_val: *i32): i32;
export extern "C" function pipe_modlet_bake_ptr_addr_elem_to_data(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, slot_off: i32
): i32;
export extern "C" function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32;

/**
 * Bake one module ARRAY_LIT into an already-reserved data span.
 * Nested TYPE_ARRAY (kind 10) recurses on the row. STRING_LIT (ek 59)
 * and pointer or function elems (kind 9 or 18) keep the existing bakers.
 * Every other elem goes through the 3-arg folder. esz is 1, 2, 4, or 8;
 * anything else is forced to 4, matching the weak gcc body.
 * Bytes 0..3 are the little-endian i32. An arithmetic shift by 8, 16,
 * or 24 stays inside those 32 bits, so masking 255 is the byte.
 * Bytes 4..7, only when esz is 8, are 0xff when the word is negative
 * and 0 otherwise. That is the sign fill. The folder returns 0 when the
 * true 64-bit value is wider than that fill, so 2147483648.0 as i64
 * stays unfolded. (0 - 1) as i64 stores eight 0xff bytes.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — object writer; null returns 0
 * @param init_ref i32 — ARRAY_LIT expr; <= 0 returns 0
 * @param elem_ty i32 — element type ref; 0 skips the kind check
 * @param data_base i32 — data-section offset of the reserved span
 * @param base_off i32 — offset of this row inside the span
 * @param span_bytes i32 — bytes reserved for this literal
 * @param m *u8 — module; null skips pointer-address elems
 * @return i32 — 0 when the literal is baked, -1 when it must loud-fail
 * PLATFORM: MACOS|DARWIN — strong. The prepare call is one BRANCH26
 * reloc, so this definition wins over the weak gcc body.
 */
#[no_mangle]
export function pipe_modlet_bake_array_lit_elems_to_data(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32,
  data_base: i32, base_off: i32, span_bytes: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let ek: i32 = 0;
  let ev: i32 = 0;
  let esz: i32 = 4;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let skip: i32 = 0;
  let slot: i32 = 0;
  let b0: i32 = 0;
  let b1: i32 = 0;
  let b2: i32 = 0;
  let b3: i32 = 0;
  let hi: i32 = 0;
  if (arena == 0 as *u8 || elf_ctx == 0 as *u8 || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ty);
    }
  }
  // Nested array. One row per element, same baker.
  if (etk == 10) {
    unsafe {
      inner_et = pipeline_type_elem_ref_at(arena, elem_ty);
      ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
      row_sz = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
    }
    if (row_sz <= 0) {
      unsafe {
        row_sz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
      }
    }
    if (ne <= 0) {
      return 0;
    }
    if (row_sz > 0 && ne > span_bytes / row_sz) {
      return 0 - 1;
    }
    ei = 0;
    while (ei < ne) {
      unsafe {
        eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
      }
      if (eref > 0) {
        unsafe {
          ek = pipeline_expr_kind_ord_at(arena, eref);
        }
        if (ek == 46) {
          rc = pipe_modlet_bake_array_lit_elems_to_data(
            arena, elf_ctx, eref, inner_et, data_base, base_off + ei * row_sz, row_sz, m);
          if (rc != 0) {
            return rc;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
  unsafe {
    esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_ty);
  }
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    esz = 4;
  }
  unsafe {
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  if (ne <= 0) {
    return 0;
  }
  // Positive sizes. Signed division matches the unsigned check here.
  if (esz > 0 && ne > span_bytes / esz) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    }
    if (eref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, eref);
      }
      skip = 0;
      if (ek == 59) {
        slot = data_base + base_off + ei * esz;
        unsafe {
          rc = pipe_modlet_bake_string_lit_elem_to_data(arena, elf_ctx, eref, slot);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        skip = 1;
      }
      if (skip == 0 && (etk == 9 || etk == 18) && m != (0 as *u8)) {
        slot = data_base + base_off + ei * esz;
        unsafe {
          rc = pipe_modlet_bake_ptr_addr_elem_to_data(arena, elf_ctx, m, eref, esz, slot);
        }
        if (rc < 0) {
          return 0 - 1;
        }
        if (rc == 0) {
          skip = 1;
        }
      }
      if (skip == 0) {
        unsafe {
          rc = pipe_modlet_array_lit_elem_const_val(arena, eref, &ev);
        }
        if (rc == 0) {
          return 0 - 1;
        }
        // Low word, then the sign fill. esz <= 4 never reads hi.
        b0 = ev & 255;
        b1 = (ev >> 8) & 255;
        b2 = (ev >> 16) & 255;
        b3 = (ev >> 24) & 255;
        hi = 0;
        if (ev < 0) {
          hi = 255;
        }
        slot = data_base + base_off + ei * esz;
        if (esz > 0) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot, b0);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 1) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 1, b1);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 2) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 2, b2);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 3) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 3, b3);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 4) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 4, hi);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 5) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 5, hi);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 6) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 6, hi);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz > 7) {
          unsafe {
            rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 7, hi);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
      }
    }
    ei = ei + 1;
  }
  return 0;
}
