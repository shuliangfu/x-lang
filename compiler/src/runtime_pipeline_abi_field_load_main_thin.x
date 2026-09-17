// Thin pure: field_load REST load_byte_sz (layout via layout_match thin).
// G.7: body MUST match field_load_sz_thin / mega (layout delegated).
// wave433: layout walk extracted to field_load_layout_thin (Ubuntu nested
//   while omit-T / empty .o). Main tip peers layout_match as extern.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_field_access_base_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(a: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_resolved_type_ref(a: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, ty_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(a: *u8, ref: i32): i32;
export extern function glue_field_access_load_bytes_for_type_ref(a: *u8, ty_ref: i32): i32;
export extern function field_load_sz_bytes_eq(a: *u8, b: *u8, n: i32): i32;
export extern function field_load_sz_layout_match(a: *u8, m: *u8, base_tr: i32, field_name: *u8, flen: i32): i32;

/**
 * FIELD_ACCESS load width (base-layout / resolved / is_some|is_none heuristic).
 * @param a *u8 - ASTArena*
 * @param m *u8 - Module*
 * @param expr_ref i32 - FIELD_ACCESS expr ref
 * @return i32 - load byte size
 * PLATFORM: SHARED — G.7 thin twin of runtime_pipeline_abi.x authority.
 */
#[no_mangle]
export function pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32 {
  unsafe {
    let tr: i32 = 0;
    let base_tr: i32 = 0;
    let base_ref: i32 = 0;
    let flen: i32 = 0;
    let field_name: u8[256] = [];
    let kind_ord: i32 = 0;
    let nm_is_some: u8[7] = [105, 115, 95, 115, 111, 109, 101];
    let nm_is_none: u8[7] = [105, 115, 95, 110, 111, 110, 101];
    let hit: i32 = 0;
    if (a == (0 as *u8) || expr_ref <= 0) {
      return 8;
    }
    unsafe {
      base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
      flen = pipeline_expr_field_access_name_len(a, expr_ref);
    }
    if (base_ref <= 0 || flen <= 0 || flen > 255) {
      return 8;
    }
    unsafe {
      pipeline_expr_field_access_name_into(a, expr_ref, &field_name[0]);
    }
    unsafe {
      tr = pipeline_expr_resolved_type_ref(a, expr_ref);
    }
    if (tr > 0) {
      unsafe {
        kind_ord = pipeline_type_kind_ord_at(a, tr);
      }
      if (kind_ord != 8 && kind_ord != 10 && kind_ord != 11 && kind_ord != 12) {
        return glue_field_access_load_bytes_for_type_ref(a, tr);
      }
    }
    unsafe {
      base_tr = pipeline_expr_resolved_type_ref(a, base_ref);
    }
    if (base_tr > 0) {
      unsafe {
        kind_ord = pipeline_type_kind_ord_at(a, base_tr);
      }
      if (kind_ord == 9) {
        unsafe {
          let elem_tr_lbs: i32 = pipeline_type_elem_ref_at(a, base_tr);
          if (elem_tr_lbs > 0) {
            base_tr = elem_tr_lbs;
            kind_ord = pipeline_type_kind_ord_at(a, base_tr);
          }
        }
      }
      if (kind_ord == 8) {
        hit = field_load_sz_layout_match(a, m, base_tr, &field_name[0], flen);
        if (hit != 0) {
          return hit;
        }
      }
    }
    if (flen == 7 && field_load_sz_bytes_eq(&field_name[0], &nm_is_some[0], 7) != 0) {
      return 1;
    }
    if (flen == 7 && field_load_sz_bytes_eq(&field_name[0], &nm_is_none[0], 7) != 0) {
      return 1;
    }
    return 8;
  }
}
