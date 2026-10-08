// One strong pipe_modlet_bake_array_lit_elems_to_data for the Windows
// true-pack link. Body is seeds/win_bake_elems_override.c.
// runtime_pipeline_abi.x has the same name and a different body: no
// named i8/i16/u16 stride, and a non-positive named stride returns -1.
// runtime_pipeline_abi_modlet_bake_elems_thin.x is the same control
// flow in one function. That one function's frame is smash size
// 0xb40, so this TU splits the work into file-local helpers. Do not
// PREFER the thin. Do not fold this TU into the egg. Do not gcc the
// seed on the Windows or Linux path. Darwin still prepends a leftover
// object. PLATFORM: SHARED body. Linux and Windows relinks consume it.

export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_elf_ctx_data_poke_u8(ctx: *u8, off: i32, b: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out: *u8): i32;
export extern function pipe_modlet_array_lit_elem_const_val(arena: *u8, eref: i32, out_val: *i32, out_hi: *i32): i32;
export extern function pipe_modlet_bake_ptr_addr_elem_to_data(
  arena: *u8, elf_ctx: *u8, m: *u8, eref: i32, esz: i32, slot_off: i32
): i32;
export extern function pipe_modlet_bake_string_lit_elem_to_data(
  arena: *u8, elf_ctx: *u8, eref: i32, slot_off: i32
): i32;
export extern function pipe_modlet_bake_struct_lit_to_data(
  arena: *u8, elf_ctx: *u8, lit_ref: i32, elem_base: i32, m: *u8
): i32;

/**
 * True-pack named stride when force_esz still returned the Cap residual 4.
 * @param arena *u8 — AST arena; the caller already rejected null
 * @param elem_ty i32 — element type ref passed to the name copy
 * @param esz i32 — stride from glue_array_lit_force_esz_from_elem_type_c
 * @param etk i32 — element type kind; only kind 8 (TYPE_NAMED) is special
 * @return i32 — 1 for i8, 2 for i16 or u16, otherwise esz unchanged
 * Other names, including a 12-byte struct, stay on esz. The 64-byte
 * name buffer lives here so the export frame does not hold it.
 * PLATFORM: SHARED.
 */
function bake_elems_one_named(arena: *u8, elem_ty: i32, esz: i32, etk: i32): i32 {
  let sn: u8[64] = [];
  let sl: i32 = 0;
  if (etk != 8 || esz != 4) {
    return esz;
  }
  // ASCII i/8, i/1/6, u/1/6. Separate tests match the C: lengths differ,
  // so at most one name matches.
  unsafe {
    sl = pipeline_type_named_name_into(arena, elem_ty, &sn[0]);
  }
  if (sl == 2 && sn[0] == 105 && sn[1] == 56) {
    return 1;
  }
  if (sl == 3 && sn[0] == 105 && sn[1] == 49 && sn[2] == 54) {
    return 2;
  }
  if (sl == 3 && sn[0] == 117 && sn[1] == 49 && sn[2] == 54) {
    return 2;
  }
  return esz;
}

/**
 * Fold one scalar element and poke its little-endian bytes.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param eref i32 — element expr ref; caller already checked eref > 0
 * @param slot i32 — absolute data offset of this element
 * @param esz i32 — stride; only the first esz bytes are poked
 * @return i32 — 0 when the bytes are stored, -1 when the fold or a poke fails
 * Return 1 sign-fills a negative low word. Returns 2, 4, and 5 do not.
 * Returns 3 and 5 then replace that high half with out_hi.
 * PLATFORM: SHARED.
 */
function bake_elems_one_poke(
  arena: *u8, elf_ctx: *u8, eref: i32, slot: i32, esz: i32
): i32 {
  let ev: i32 = 0;
  let ehi: i32 = 0;
  let rc: i32 = 0;
  let b0: i32 = 0;
  let b1: i32 = 0;
  let b2: i32 = 0;
  let b3: i32 = 0;
  let hi: i32 = 0;
  let h0: i32 = 0;
  let h1: i32 = 0;
  let h2: i32 = 0;
  let h3: i32 = 0;
  unsafe {
    rc = pipe_modlet_array_lit_elem_const_val(arena, eref, &ev, &ehi);
  }
  if (rc == 0) {
    return 0 - 1;
  }
  b0 = ev & 255;
  b1 = (ev >> 8) & 255;
  b2 = (ev >> 16) & 255;
  b3 = (ev >> 24) & 255;
  hi = 0;
  if (ev < 0 && rc != 2 && rc != 4 && rc != 5) {
    hi = 255;
  }
  h0 = hi;
  h1 = hi;
  h2 = hi;
  h3 = hi;
  if (rc == 3 || rc == 5) {
    h0 = ehi & 255;
    h1 = (ehi >> 8) & 255;
    h2 = (ehi >> 16) & 255;
    h3 = (ehi >> 24) & 255;
  }
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
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 4, h0);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  if (esz > 5) {
    unsafe {
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 5, h1);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  if (esz > 6) {
    unsafe {
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 6, h2);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  if (esz > 7) {
    unsafe {
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, slot + 7, h3);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Bake one element that is not itself a nested ARRAY_LIT row.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param eref i32 — element expr ref; caller already checked eref > 0
 * @param etk i32 — element type kind (9 or 18 may be an address)
 * @param esz i32 — stride used only to form the slot
 * @param slot i32 — absolute data offset of this element
 * @param m *u8 — module; null skips the address baker
 * @return i32 — 0 when this element is done, -1 when a baker or the fold fails
 * Kind 59 is a string. Kind 45 is a struct. A zero return from the
 * address baker consumes the element. Any other return falls through
 * to the scalar fold. PLATFORM: SHARED.
 */
function bake_elems_one_elem(
  arena: *u8, elf_ctx: *u8, eref: i32, etk: i32, esz: i32, slot: i32, m: *u8
): i32 {
  let ek: i32 = 0;
  let rc: i32 = 0;
  let skip: i32 = 0;
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, eref);
  }
  if (ek == 59) {
    unsafe {
      rc = pipe_modlet_bake_string_lit_elem_to_data(arena, elf_ctx, eref, slot);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    skip = 1;
  }
  if (skip == 0 && ek == 45) {
    unsafe {
      rc = pipe_modlet_bake_struct_lit_to_data(arena, elf_ctx, eref, slot, m);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    skip = 1;
  }
  if (skip == 0 && (etk == 9 || etk == 18) && m != (0 as *u8)) {
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
    return bake_elems_one_poke(arena, elf_ctx, eref, slot, esz);
  }
  return 0;
}

/**
 * Bake one module ARRAY_LIT into an already-reserved data span.
 * @param arena *u8 — AST arena; null returns 0
 * @param elf_ctx *u8 — object writer; null returns 0
 * @param init_ref i32 — ARRAY_LIT expr; <= 0 returns 0
 * @param elem_ty i32 — element type ref; 0 skips the kind check
 * @param data_base i32 — data-section offset of the reserved span
 * @param base_off i32 — offset of this row inside the span
 * @param span_bytes i32 — bytes reserved for this literal
 * @param m *u8 — module; null skips pointer-address elements
 * @return i32 — 0 when the literal is baked, -1 when it must loud-fail
 * Nested TYPE_ARRAY (kind 10) recurses on each ARRAY_LIT row. A row
 * count or element count past the span returns -1. Named i8 is 1 byte.
 * Named i16 and u16 are 2 bytes. A named stride outside 1/2/4/8 stays
 * when it is positive. File-local helpers keep each frame off the
 * smash sizes. PLATFORM: SHARED — one strong T. Linux and Windows
 * link this ahead of the egg.
 */
#[no_mangle]
export function pipe_modlet_bake_array_lit_elems_to_data(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ty: i32,
  data_base: i32, base_off: i32, span_bytes: i32, m: *u8
): i32 {
  let ne: i32 = 0;
  let ei: i32 = 0;
  let eref: i32 = 0;
  let esz: i32 = 0;
  let etk: i32 = 0;
  let inner_et: i32 = 0;
  let row_sz: i32 = 0;
  let rc: i32 = 0;
  let slot: i32 = 0;
  let ek: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0;
  }
  if (elem_ty > 0) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ty);
    }
  }
  // Nested TYPE_ARRAY. One row per element. Only kind 46 recurses.
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
  esz = bake_elems_one_named(arena, elem_ty, esz, etk);
  // A positive named stride that is not 1, 2, 4, or 8 stays. Every
  // other odd stride becomes 4, including a non-positive named stride.
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    if (etk != 8 || esz <= 0) {
      esz = 4;
    }
  }
  unsafe {
    ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  if (ne <= 0) {
    return 0;
  }
  if (esz > 0 && ne > span_bytes / esz) {
    return 0 - 1;
  }
  ei = 0;
  while (ei < ne) {
    unsafe {
      eref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ei);
    }
    if (eref > 0) {
      slot = data_base + base_off + ei * esz;
      rc = bake_elems_one_elem(arena, elf_ctx, eref, etk, esz, slot, m);
      if (rc != 0) {
        return rc;
      }
    }
    ei = ei + 1;
  }
  return 0;
}
