// One strong glue_array_lit_force_esz_from_elem_type_c.
// Windows and Linux each build this file into force_esz_true_i8.o.
// The sibling pipeline_asm_array_lit_elem_byte_sz_c is pabi_elem_byte_sz_one.x.
// Do not compile the two files together. Same-.o dual T smashes i32.
// Do not PREFER runtime_pipeline_abi_fnptr_array_esz_thin.x.
// Darwin rebuilds this file into force_esz_true_i8.o. Do not cc or gcc
// the seed into one object on Windows, Linux, or Darwin.
// PLATFORM: SHARED body. Linux, Darwin, and Windows relinks consume this file.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, type_ref: i32, depth: i32): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;

/**
 * Load an i32 that was stored in a pipe cell.
 * @param base *u8 — cell base; the store wrote 4 bytes at offset 0
 * @return i32 — stored value
 * PLATFORM: SHARED — local helper, not a link export.
 */
function w496_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Load a pointer that was stored in a pipe slot.
 * @param base *u8 — cell base; the store wrote one pointer at index 0
 * @return *u8 — stored pointer
 * PLATFORM: SHARED — local helper, not a link export.
 */
function w496_cell_ptr(base: *u8): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, 0);
  }
}

/**
 * Force an ARRAY_LIT element stride from the destination element type.
 * @param arena *u8 — AST arena; null returns 0
 * @param et i32 — element type_ref; et <= 0 returns 0
 * @return i32 — stride in bytes, or 0 when the lit should infer it
 * Named i8 returns 1. Named i16 and u16 return 2. Other named types
 * use glue_type_size_simple. TYPE_FN returns 8.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32 {
  let ek: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let cell_i: u8[8];
  let cell_m: u8[8];
  if (arena == (0 as *u8) || et <= 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell_i[0], 0, pipeline_type_kind_ord_at(arena, et));
  }
  ek = w496_cell_i32(&cell_i[0]);
  if (ek == 2 || ek == 1) {
    return 1;
  }
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14) {
    return 4;
  }
  // TYPE_FN=18 shares the opaque function-pointer width with TYPE_PTR=9.
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9 || ek == 18) {
    return 8;
  }
  if (ek == 8) {
    // True-pack named i8 / i16 / u16. Other named types stay on
    // glue_type_size_simple, which still reports 4 for struct fields.
    let sn: u8[64] = [];
    let sl: i32 = 0;
    unsafe {
      sl = pipeline_type_named_name_into(arena, et, &sn[0]);
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
      pipe_store_ptr_slot(&cell_m[0], 0, pipeline_asm_emit_module_ref_c());
    }
    mod = w496_cell_ptr(&cell_m[0]);
    if (mod != (0 as *u8)) {
      unsafe {
        pipe_store_i32_le(&cell_i[0], 0, glue_type_size_simple(mod, arena, et, 0));
      }
      ssz = w496_cell_i32(&cell_i[0]);
      if (ssz > 0) {
        return ssz;
      }
    }
  }
  // TYPE_ARRAY=10: row stride is the fixed-array total, not a pointer.
  if (ek == 10) {
    unsafe {
      pipe_store_i32_le(&cell_i[0], 0, glue_fixed_array_total_bytes_c(arena, et, 0));
    }
    ssz = w496_cell_i32(&cell_i[0]);
    if (ssz > 0) {
      return ssz;
    }
  }
  if (ek == 11) {
    return 16;
  }
  return 0;
}
