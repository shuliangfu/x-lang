// One strong glue_index_elem_byte_sz_from_type_ref_c for the Windows
// true-pack link. Body is the -DXLANG_WIN_TRUE_PACK side of
// seeds/win_index_elem_byte_sz_override.c. Named i8 is 1, i16 is 2,
// u16 is 2. The egg function of this name has no those parks: a
// PTR-to-named goes straight to glue_type_size_simple, and an
// ARRAY/SLICE named element does too. Do not fold this TU into
// runtime_pipeline_abi.x. pipeline_asm_index_elem_byte_sz_c and the
// short wrapper are other objects: same-.o dual T smashes i32.
// File-local helpers stay here. They are not a second link winner.
// Linux sidecar still gcc's the C. Darwin does not retarget this
// object. PLATFORM: SHARED body. Windows relink consumes this object.

export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;

/**
 * True-pack width of a TYPE_NAMED ref.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param ty i32 — named type ref; caller already knows kind 8
 * @return i32 — 1 for i8, 2 for i16 or u16, layout size when positive, else 0
 * A 0 result means the caller keeps walking. This is not a link export.
 * Cap residual without XLANG_WIN_TRUE_PACK returns 4 for these names.
 * This object is the -D body, so those names do not return 4 here.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_named_pack(arena: *u8, ty: i32): i32 {
  let sl: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let sn: u8[64] = [];
  // One name read, then the three true-pack spellings. Other names
  // fall through to the module layout. PLATFORM: SHARED.
  unsafe {
    sl = pipeline_type_named_name_into(arena, ty, &sn[0]);
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
  unsafe {
    mod = pipeline_asm_emit_module_ref_c();
  }
  if (mod != (0 as *u8)) {
    unsafe {
      ssz = glue_type_size_simple(mod, arena, ty, 0);
    }
    if (ssz > 0) {
      return ssz;
    }
  }
  return 0;
}

/**
 * Width of a pointer whose pointee is TYPE_NAMED.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param pointee i32 — named pointee ref
 * @return i32 — 1 for u8, i8, or bool; 4 for i32 or u32; layout size; else 0
 * u8 is checked before i8, matching the C order. A 0 result tells the
 * PTR peel to return 4. This is not a link export.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_ptr_named(arena: *u8, pointee: i32): i32 {
  let sl: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let sn: u8[64] = [];
  unsafe {
    sl = pipeline_type_named_name_into(arena, pointee, &sn[0]);
  }
  if (sl == 2 && sn[0] == 117 && sn[1] == 56) {
    return 1;
  }
  if (sl == 2 && sn[0] == 105 && sn[1] == 56) {
    return 1;
  }
  if (sl == 4 && sn[0] == 98 && sn[1] == 111 && sn[2] == 111 && sn[3] == 108) {
    return 1;
  }
  if (sl == 3 && sn[0] == 105 && sn[1] == 51 && sn[2] == 50) {
    return 4;
  }
  if (sl == 3 && sn[0] == 117 && sn[1] == 51 && sn[2] == 50) {
    return 4;
  }
  unsafe {
    mod = pipeline_asm_emit_module_ref_c();
  }
  if (mod != (0 as *u8)) {
    unsafe {
      ssz = glue_type_size_simple(mod, arena, pointee, 0);
    }
    if (ssz > 0) {
      return ssz;
    }
  }
  return 0;
}

/**
 * Peel a TYPE_PTR (kind 9). This path always decides. It does not fall
 * through into the ARRAY/SLICE walk.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param tr i32 — pointer type ref
 * @return i32 — pointee width, or 4 when the pointee does not decide
 * A fixed-array pointee with total bytes <= 0 still returns 4 here.
 * The ARRAY walk returns 8 for that same miss. PLATFORM: SHARED.
 */
function iesz_ptr_peel(arena: *u8, tr: i32): i32 {
  let pointee: i32 = 0;
  let kind_ord: i32 = 0;
  let asz: i32 = 0;
  let hit: i32 = 0;
  unsafe {
    pointee = pipeline_type_elem_ref_at(arena, tr);
  }
  if (pointee > 0) {
    unsafe {
      kind_ord = pipeline_type_kind_ord_at(arena, pointee);
    }
    if (kind_ord == 2 || kind_ord == 1) {
      return 1;
    }
    if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14) {
      return 4;
    }
    if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7) {
      return 8;
    }
    if (kind_ord == 9) {
      return 8;
    }
    if (kind_ord == 10) {
      unsafe {
        asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
      }
      if (asz > 0) {
        return asz;
      }
    }
    if (kind_ord == 8) {
      hit = iesz_ptr_named(arena, pointee);
      if (hit > 0) {
        return hit;
      }
    }
  }
  return 4;
}

/**
 * Width of an ARRAY or SLICE element when the pointee kind decides.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param pointee i32 — element type ref
 * @param pk i32 — pointee kind, already loaded by the caller
 * @return i32 — decided width, or 0 when the caller must keep the pointee kind and fall through
 * Kind 15, 9, and 18 return 8 here. Kind 4, 5, 6, and 7 do not: those
 * fall through and the tail returns 8. Kind 18 is not special in the
 * INDEX-expr tail. PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_arr_pointee(arena: *u8, pointee: i32, pk: i32): i32 {
  let asz: i32 = 0;
  if (pk == 2 || pk == 1) {
    return 1;
  }
  if (pk == 0 || pk == 3 || pk == 13 || pk == 14) {
    return 4;
  }
  if (pk == 15) {
    return 8;
  }
  if (pk == 9 || pk == 18) {
    return 8;
  }
  if (pk == 10) {
    unsafe {
      asz = glue_fixed_array_total_bytes_c(arena, pointee, 0);
    }
    if (asz > 0) {
      return asz;
    }
    return 0;
  }
  if (pk == 11) {
    return 16;
  }
  if (pk == 8) {
    return iesz_named_pack(arena, pointee);
  }
  return 0;
}

/**
 * Width after the PTR and ARRAY/SLICE peels, using the kind those peels left behind.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param tr i32 — original type ref, not the pointee
 * @param kind_ord i32 — kind still in force; an ARRAY miss overwrites this with the pointee kind
 * @return i32 — stride in bytes; 8 when nothing matches
 * A named miss looks up tr, not the pointee. PLATFORM: SHARED.
 */
function iesz_rest(arena: *u8, tr: i32, kind_ord: i32): i32 {
  let hit: i32 = 0;
  if (kind_ord == 2 || kind_ord == 1) {
    return 1;
  }
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14) {
    return 4;
  }
  if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7) {
    return 8;
  }
  if (kind_ord == 11) {
    return 16;
  }
  if (kind_ord == 8) {
    hit = iesz_named_pack(arena, tr);
    if (hit > 0) {
      return hit;
    }
  }
  return 8;
}

/**
 * Element stride of a type ref for INDEX true-pack.
 * @param arena *u8 — AST arena; null returns 4
 * @param tr i32 — type pool ref; tr <= 0 returns 4
 * @return i32 — stride in bytes
 * TYPE_PTR always returns from the peel (miss is 4). TYPE_ARRAY and
 * TYPE_SLICE overwrite the walking kind with the pointee kind when the
 * pointee does not decide, then fall through. Bare TYPE_SLICE with no
 * pointee returns 16. Bare TYPE_ARRAY with no pointee returns 8.
 * PLATFORM: SHARED — one strong T. Windows links this ahead of the egg.
 */
#[no_mangle]
export function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32 {
  let kind_ord: i32 = 0;
  let pointee: i32 = 0;
  let pk: i32 = 0;
  let hit: i32 = 0;
  if (tr <= 0) {
    return 4;
  }
  if (arena == (0 as *u8)) {
    return 4;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  }
  if (kind_ord == 9) {
    return iesz_ptr_peel(arena, tr);
  }
  if (kind_ord == 10 || kind_ord == 11) {
    unsafe {
      pointee = pipeline_type_elem_ref_at(arena, tr);
    }
    if (pointee > 0) {
      unsafe {
        pk = pipeline_type_kind_ord_at(arena, pointee);
      }
      hit = iesz_arr_pointee(arena, pointee, pk);
      if (hit > 0) {
        return hit;
      }
      // C keeps the pointee kind for the later named / primitive tests.
      kind_ord = pk;
    }
  }
  return iesz_rest(arena, tr, kind_ord);
}
