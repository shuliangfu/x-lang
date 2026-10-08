// One strong pipeline_asm_array_lit_elem_byte_sz_c.
// Windows and Linux each build this file into array_lit_esz_true_i8.o.
// glue_array_lit_force_esz_from_elem_type_c stays in pabi_force_esz_one.x.
// Do not compile the two files together. Same-.o dual T smashes i32.
// Do not PREFER runtime_pipeline_abi_fnptr_array_esz_thin.x.
// Darwin still prepends a leftover combined force_esz_true_i8.o.
// PLATFORM: SHARED body. Linux and Windows relinks consume this file.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, type_ref: i32, depth: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
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
 * Infer an ARRAY_LIT element stride from the stamped element type.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — ARRAY_LIT expression
 * @return i32 — stride in bytes; 4 when the lit should use the default
 * Named i8 returns 1. Named i16 and u16 return 2. TYPE_FN returns 8.
 * A nested ARRAY_LIT (expr kind 46) returns count times the inner stride.
 * PLATFORM: SHARED — one strong T. Linux and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32 {
  let elem_ty: i32 = 0;
  let kind_ord: i32 = 0;
  let nested: i32 = 0;
  let first_ref: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let n_inner: i32 = 0;
  let iesz: i32 = 0;
  let fko: i32 = 0;
  let cell_i: u8[8];
  let cell_m: u8[8];
  // Export-extern calls sit in unsafe. Pipe cells keep the tip-stable
  // form: do not write `x = extern()`. PLATFORM: SHARED.
  unsafe {
    pipe_store_i32_le(&cell_i[0], 0, pipeline_asm_array_lit_elem_type_ref(arena, expr_ref));
  }
  elem_ty = w496_cell_i32(&cell_i[0]);
  if (elem_ty > 0) {
    unsafe {
      pipe_store_i32_le(&cell_i[0], 0, pipeline_type_kind_ord_at(arena, elem_ty));
    }
    kind_ord = w496_cell_i32(&cell_i[0]);
    if (kind_ord == 10) {
      unsafe {
        pipe_store_i32_le(&cell_i[0], 0, glue_fixed_array_total_bytes_c(arena, elem_ty, 0));
      }
      nested = w496_cell_i32(&cell_i[0]);
      if (nested > 0) {
        return nested;
      }
    }
    if (kind_ord == 2 || kind_ord == 1) {
      return 1;
    }
    if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14) {
      return 4;
    }
    // TYPE_FN=18 shares the opaque function-pointer width with TYPE_PTR=9.
    if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7
        || kind_ord == 9 || kind_ord == 18) {
      return 8;
    }
    if (kind_ord == 11) {
      return 16;
    }
    if (kind_ord == 8) {
      // True-pack named i8 / i16 / u16. Other named types stay on
      // glue_type_size_simple. PLATFORM: SHARED.
      let sn: u8[64] = [];
      let sl: i32 = 0;
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
      unsafe {
        pipe_store_ptr_slot(&cell_m[0], 0, pipeline_asm_emit_module_ref_c());
      }
      mod = w496_cell_ptr(&cell_m[0]);
      if (mod != (0 as *u8)) {
        unsafe {
          pipe_store_i32_le(&cell_i[0], 0, glue_type_size_simple(mod, arena, elem_ty, 0));
        }
        ssz = w496_cell_i32(&cell_i[0]);
        if (ssz > 0) {
          return ssz;
        }
      }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell_i[0], 0, pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0));
  }
  first_ref = w496_cell_i32(&cell_i[0]);
  if (first_ref > 0) {
    unsafe {
      pipe_store_i32_le(&cell_i[0], 0, pipeline_expr_kind_ord_at(arena, first_ref));
    }
    fko = w496_cell_i32(&cell_i[0]);
    if (fko == 46) {
      unsafe {
        pipe_store_i32_le(&cell_i[0], 0, pipeline_expr_array_lit_num_elems_at(arena, first_ref));
      }
      n_inner = w496_cell_i32(&cell_i[0]);
      // Self-call. Same pipe-cell form as every other extern call.
      unsafe {
        pipe_store_i32_le(&cell_i[0], 0, pipeline_asm_array_lit_elem_byte_sz_c(arena, first_ref));
      }
      iesz = w496_cell_i32(&cell_i[0]);
      if (n_inner > 0 && iesz > 0) {
        return n_inner * iesz;
      }
    }
  }
  return 4;
}
