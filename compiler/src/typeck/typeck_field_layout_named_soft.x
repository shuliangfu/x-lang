// knife256/10.2 Cap tip: after skip-typeck dep prerun, Result_i32.value T001.
// Soft field_layout_named: demoted first; if still unresolved and type is
// Result_*/Option_*, stamp offset + scalar type for known fields.
// PLATFORM: SHARED — Cap tip L2 sidecar only.

export extern "C" function typeck_field_layout_named__demoted(
  module: *u8, arena: *u8, expr_ref: i32, base_ref: i32, ctx: *u8): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function pipeline_expr_set_field_access_offset(arena: *u8, expr_ref: i32, off: i32): void;
export extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern "C" function typeck_ensure_i32_type_ref(arena: *u8): i32;
export extern "C" function typeck_ensure_bool_type_ref(arena: *u8): i32;

#[no_mangle]
export function typeck_field_layout_named(
  module: *u8, arena: *u8, expr_ref: i32, base_ref: i32, ctx: *u8): i32 {
  unsafe {
    let rc: i32 = 0;
    let got: i32 = 0;
    let base_ty: i32 = 0;
    let bt: i32 = 0;
    let named: i32 = 0;
    let nlen: i32 = 0;
    let fl: i32 = 0;
    let nm: u8[256] = [];
    let fnm: u8[256] = [];
    let i32r: i32 = 0;
    let boolr: i32 = 0;
    let si: i32 = 0;
    let dot: i32 = 0;
    if (module == 0 as *u8 || arena == 0 as *u8 || expr_ref <= 0 || base_ref <= 0) {
      return 0;
    }
    rc = typeck_field_layout_named__demoted(module, arena, expr_ref, base_ref, ctx);
    got = pipeline_expr_resolved_type_ref(arena, expr_ref);
    if (got > 0) {
      return rc;
    }
    base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (base_ty <= 0) {
      return rc;
    }
    bt = pipeline_type_kind_ord_at(arena, base_ty);
    named = base_ty;
    if (bt == 9) {
      named = pipeline_type_elem_ref_at(arena, base_ty);
      if (named <= 0) {
        return rc;
      }
      bt = pipeline_type_kind_ord_at(arena, named);
    }
    if (bt != 8) {
      return rc;
    }
    nlen = pipeline_type_named_name_into(arena, named, &nm[0]);
    if (nlen <= 0 || nlen > 255) {
      return rc;
    }
    /* strip last mod. */
    dot = 0 - 1;
    si = 0;
    while (si < nlen) {
      if (nm[si] == 46) {
        dot = si;
      }
      si = si + 1;
    }
    if (dot >= 0 && dot + 1 < nlen) {
      si = 0;
      while (si < nlen - (dot + 1)) {
        nm[si] = nm[dot + 1 + si];
        si = si + 1;
      }
      nlen = nlen - (dot + 1);
      nm[nlen] = 0;
    }
    fl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (fl <= 0 || fl > 255) {
      return rc;
    }
    pipeline_expr_field_access_name_into(arena, expr_ref, &fnm[0]);
    /* Result_i32 */
    if (nlen == 10 && nm[0] == 82 && nm[1] == 101 && nm[2] == 115 && nm[3] == 117 &&
        nm[4] == 108 && nm[5] == 116 && nm[6] == 95 && nm[7] == 105 && nm[8] == 51 &&
        nm[9] == 50) {
      i32r = typeck_ensure_i32_type_ref(arena);
      if (fl == 5 && fnm[0] == 118 && fnm[1] == 97 && fnm[2] == 108 && fnm[3] == 117 &&
          fnm[4] == 101) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
        if (i32r != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r);
        }
        return 0;
      }
      if (fl == 3 && fnm[0] == 101 && fnm[1] == 114 && fnm[2] == 114) {
        pipeline_expr_set_field_access_offset(arena, expr_ref, 8);
        if (i32r != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r);
        }
        return 0;
      }
    }
    /* Option_i32 */
    if (nlen == 10 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105 &&
        nm[4] == 111 && nm[5] == 110 && nm[6] == 95 && nm[7] == 105 && nm[8] == 51 &&
        nm[9] == 50) {
      if (fl == 7 && fnm[0] == 105 && fnm[1] == 115 && fnm[2] == 95 && fnm[3] == 115 &&
          fnm[4] == 111 && fnm[5] == 109 && fnm[6] == 101) {
        boolr = typeck_ensure_bool_type_ref(arena);
        pipeline_expr_set_field_access_offset(arena, expr_ref, 0);
        if (boolr != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, boolr);
        }
        return 0;
      }
      if (fl == 5 && fnm[0] == 118 && fnm[1] == 97 && fnm[2] == 108 && fnm[3] == 117 &&
          fnm[4] == 101) {
        i32r = typeck_ensure_i32_type_ref(arena);
        pipeline_expr_set_field_access_offset(arena, expr_ref, 4);
        if (i32r != 0) {
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, i32r);
        }
        return 0;
      }
    }
    return rc;
  }
}
