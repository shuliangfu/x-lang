// One strong pipeline_asm_index_elem_byte_sz_c for the Windows
// true-pack link. Body is the -DXLANG_WIN_TRUE_PACK side of
// seeds/win_index_elem_byte_sz_override.c. It calls
// glue_index_elem_byte_sz_from_type_ref_c as an extern, so that
// peeler stays in pabi_index_elem_from_type_one.x. The short wrapper
// stays in pabi_index_elem_wrap_one.x. Same-.o dual T smashes i32.
// The egg only export-externs this name. Do not fold this TU into
// runtime_pipeline_abi.x. File-local helpers stay here. They are not
// a second link winner. The named i8/i16/u16 checks in the tail are
// the same bytes as the peeler because the C writes them in both
// functions. Linux and Darwin rebuild this file into
// index_elem_true_i8.o. Do not cc or gcc
// seeds/win_index_elem_byte_sz_override.c into one object on Windows,
// Linux, or Darwin.
// PLATFORM: SHARED body. Windows, Linux, and Darwin link this object.

export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ty_ref: i32, out: *u8): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): i32;
export extern function pipeline_module_func_param_type_ref_for_name(
  mod: *u8, func_idx: i32, name: *u8, name_len: i32
): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;

/**
 * True-pack width of one TYPE_NAMED ref inside the INDEX-expr tail.
 * @param arena *u8 — AST arena; caller already has a live type
 * @param ty i32 — named type ref
 * @return i32 — 1 for i8, 2 for i16 or u16, layout size when positive, else 0
 * The peeler owns the same byte checks for the type-ref entry. This copy
 * exists because the C tail writes the checks again and this object cannot
 * call a file-local in the other TU. Not a link export.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_pack_name(arena: *u8, ty: i32): i32 {
  let sl: i32 = 0;
  let ssz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let sn: u8[64] = [];
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
 * Return 1 when the struct name ends in Vec_u8.
 * @param arena *u8 — AST arena
 * @param pty i32 — parameter type; caller already knows it is a pointer
 * @return i32 — 1 when the pointee name ends in Vec_u8, else 0
 * A pointee ref <= 0 does not call name_into. PLATFORM: SHARED.
 */
function iesz_vec_suffix(arena: *u8, pty: i32): i32 {
  let st: i32 = 0;
  let sl: i32 = 0;
  let i1: i32 = 0;
  let i2: i32 = 0;
  let i3: i32 = 0;
  let i4: i32 = 0;
  let i5: i32 = 0;
  let i6: i32 = 0;
  let sn: u8[128] = [];
  unsafe {
    st = pipeline_type_elem_ref_at(arena, pty);
  }
  if (st > 0) {
    unsafe {
      sl = pipeline_type_named_name_into(arena, st, &sn[0]);
    }
  }
  // Last six bytes are V e c _ u 8. A shorter name cannot match.
  if (sl >= 6) {
    i1 = sl - 1;
    i2 = sl - 2;
    i3 = sl - 3;
    i4 = sl - 4;
    i5 = sl - 5;
    i6 = sl - 6;
    if (sn[i1] == 56 && sn[i2] == 117 && sn[i3] == 95 && sn[i4] == 99 && sn[i5] == 101 && sn[i6] == 86) {
      return 1;
    }
  }
  return 0;
}

/**
 * Look up the VAR under .ptr and test the Vec_u8 suffix.
 * @param arena *u8 — AST arena
 * @param vref i32 — VAR expr under the field; caller already checked kind 3
 * @param mod *u8 — current module; caller already rejected null
 * @param func_idx i32 — current function index; negative skips the param lookup
 * @return i32 — 1 when the param is *Struct ending in Vec_u8, else 0
 * name_into and the param lookup run only when 0 < vl <= 63 and func_idx >= 0.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_vec_param(arena: *u8, vref: i32, mod: *u8, func_idx: i32): i32 {
  let vl: i32 = 0;
  let pty: i32 = 0;
  let pk: i32 = 0;
  let ignored: i32 = 0;
  let vn: u8[256] = [];
  unsafe {
    vl = pipeline_expr_var_name_len(arena, vref);
  }
  if (vl > 0) {
    if (vl <= 63) {
      if (func_idx >= 0) {
        unsafe {
          ignored = pipeline_expr_var_name_into(arena, vref, &vn[0]);
        }
        unsafe {
          pty = pipeline_module_func_param_type_ref_for_name(mod, func_idx, &vn[0], vl);
        }
      }
    }
  }
  if (pty > 0) {
    unsafe {
      pk = pipeline_type_kind_ord_at(arena, pty);
    }
    if (pk == 9) {
      return iesz_vec_suffix(arena, pty);
    }
  }
  return ignored - ignored;
}

/**
 * Match base.ptr where base is a *Vec_u8 parameter.
 * @param arena *u8 — AST arena
 * @param base_ref i32 — FIELD expr; caller already saw kind 44
 * @return i32 — 1 when the Vec_u8 shape matches, else 0
 * func_index is called whenever the field name is ptr, even if the
 * module is null or the base ref is not a VAR. kind of the VAR is
 * called only when the base ref is positive and the module is non-null.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_vec_field(arena: *u8, base_ref: i32): i32 {
  let flen: i32 = 0;
  let vref: i32 = 0;
  let func_idx: i32 = 0;
  let vk: i32 = 0;
  let ignored: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let fname: u8[256] = [];
  unsafe {
    flen = pipeline_expr_field_access_name_len(arena, base_ref);
  }
  if (flen == 3) {
    unsafe {
      ignored = pipeline_expr_field_access_name_into(arena, base_ref, &fname[0]);
    }
    if (fname[0] == 112 && fname[1] == 116 && fname[2] == 114) {
      unsafe {
        vref = pipeline_expr_field_access_base_ref(arena, base_ref);
      }
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
      }
      unsafe {
        func_idx = pipeline_asm_emit_func_index_c();
      }
      if (vref > 0) {
        if (mod != (0 as *u8)) {
          unsafe {
            vk = pipeline_expr_kind_ord_at(arena, vref);
          }
          if (vk == 3) {
            return iesz_vec_param(arena, vref, mod, func_idx);
          }
        }
      }
    }
  }
  return ignored - ignored;
}

/**
 * Type ref of an INDEX base. FIELD uses the field type. Anything else
 * uses the resolved type, then the decl fallback.
 * @param arena *u8 — AST arena
 * @param base_ref i32 — base expr; caller already knows it is positive
 * @return i32 — type ref, or <= 0 when neither lookup hits
 * This is the second kind_ord_at on the base. The Vec_u8 test already
 * consumed the first one. PLATFORM: SHARED.
 */
function iesz_base_tr(arena: *u8, base_ref: i32): i32 {
  let k: i32 = 0;
  let tr: i32 = 0;
  let mod: *u8 = 0 as *u8;
  unsafe {
    k = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (k == 44) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
    unsafe {
      tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    }
    return tr;
  }
  unsafe {
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  }
  if (tr <= 0) {
    unsafe {
      tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
    }
  }
  return tr;
}

/**
 * Early stride from the base type. Both arms call the peeler.
 * @param arena *u8 — AST arena
 * @param tr i32 — base type; caller already knows tr > 0
 * @return i32 — peeler result when it is in 1..7, else 0 so the caller continues
 * Kind 9 and every other kind both call the peeler. The kind load is
 * what picks the arm. A result of 8 or less than 1 does not return early.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_early(arena: *u8, tr: i32): i32 {
  let k: i32 = 0;
  let esz: i32 = 0;
  unsafe {
    k = pipeline_type_kind_ord_at(arena, tr);
  }
  if (k == 9) {
    unsafe {
      esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    }
    if (esz > 0) {
      if (esz < 8) {
        return esz;
      }
    }
    return 0;
  }
  unsafe {
    esz = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  }
  if (esz > 0) {
    if (esz < 8) {
      return esz;
    }
  }
  return 0;
}

/**
 * Resolved-type path of the INDEX expr. The caller only enters when that type is positive.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — INDEX expr
 * @param tr i32 — resolved type of expr_ref
 * @return i32 — stride. This path always decides.
 * kind_ord_at is called again for the kind-9 test and again for the
 * kind-11 test. A kind-10 hit with a positive total returns before those.
 * The pointer-base comparison reloads the INDEX base. PLATFORM: SHARED.
 */
function iesz_resolved(arena: *u8, expr_ref: i32, tr: i32): i32 {
  let k: i32 = 0;
  let asz: i32 = 0;
  let esz_res: i32 = 0;
  let base2: i32 = 0;
  let bk: i32 = 0;
  let tr_base: i32 = 0;
  let tk: i32 = 0;
  let esz_pt: i32 = 0;
  let mod: *u8 = 0 as *u8;
  unsafe {
    k = pipeline_type_kind_ord_at(arena, tr);
  }
  if (k == 10) {
    unsafe {
      asz = glue_fixed_array_total_bytes_c(arena, tr, 0);
    }
    if (asz > 0) {
      return asz;
    }
  }
  unsafe {
    k = pipeline_type_kind_ord_at(arena, tr);
  }
  if (k == 9) {
    return 8;
  }
  unsafe {
    k = pipeline_type_kind_ord_at(arena, tr);
  }
  if (k == 11) {
    return 16;
  }
  unsafe {
    esz_res = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
  }
  unsafe {
    base2 = pipeline_expr_index_base_ref(arena, expr_ref);
  }
  if (base2 > 0) {
    unsafe {
      bk = pipeline_expr_kind_ord_at(arena, base2);
    }
    if (bk == 44) {
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
      }
      unsafe {
        tr_base = glue_field_access_field_type_ref_c(arena, mod, base2);
      }
    } else {
      unsafe {
        tr_base = pipeline_expr_resolved_type_ref(arena, base2);
      }
      if (tr_base <= 0) {
        unsafe {
          tr_base = glue_var_expr_type_ref_with_decl_fallback_c(arena, base2);
        }
      }
    }
    if (tr_base > 0) {
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, tr_base);
      }
      if (tk == 9) {
        unsafe {
          esz_pt = glue_index_elem_byte_sz_from_type_ref_c(arena, tr_base);
        }
        if (esz_pt > 0) {
          if (esz_res <= 0 || esz_pt < esz_res) {
            return esz_pt;
          }
        }
      }
    }
  }
  return esz_res;
}

/**
 * Pointee width inside the INDEX tail's ARRAY/SLICE arm.
 * @param arena *u8 — AST arena
 * @param pointee i32 — element type
 * @param pk i32 — pointee kind, already loaded
 * @return i32 — decided width, or 0 when the caller keeps pk and falls through
 * Kind 18 does not return 8 here. The type-ref peeler does. Kind 15 does
 * not return 8 here either. PLATFORM: SHARED — local helper.
 */
function iesz_tail_pointee(arena: *u8, pointee: i32, pk: i32): i32 {
  let asz: i32 = 0;
  if (pk == 2 || pk == 1) {
    return 1;
  }
  if (pk == 0 || pk == 3 || pk == 13 || pk == 14) {
    return 4;
  }
  if (pk == 9) {
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
    return iesz_pack_name(arena, pointee);
  }
  return 0;
}

/**
 * Tail used when the INDEX expr itself has no resolved type.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — INDEX expr
 * @return i32 — stride; 4 when the base is missing or a field has no type
 * FIELD prefers the field type and returns the peeler result, including
 * values that are not in 1..7. A non-field prefers the decl fallback,
 * then the resolved type. Kind 9 returns the peeler with no 1..7 filter.
 * PLATFORM: SHARED — local helper, not a link export.
 */
function iesz_tail(arena: *u8, expr_ref: i32): i32 {
  let base_ref: i32 = 0;
  let bk: i32 = 0;
  let tr: i32 = 0;
  let kind_ord: i32 = 0;
  let pointee: i32 = 0;
  let pk: i32 = 0;
  let hit: i32 = 0;
  let mod: *u8 = 0 as *u8;
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 4;
  }
  unsafe {
    bk = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (bk == 44) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
    unsafe {
      tr = glue_field_access_field_type_ref_c(arena, mod, base_ref);
    }
    if (tr > 0) {
      unsafe {
        hit = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
      }
      return hit;
    }
    return 4;
  }
  unsafe {
    tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  }
  if (tr <= 0) {
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
  }
  if (tr <= 0) {
    return 4;
  }
  unsafe {
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  }
  if (kind_ord == 9) {
    unsafe {
      hit = glue_index_elem_byte_sz_from_type_ref_c(arena, tr);
    }
    return hit;
  }
  if (kind_ord == 10 || kind_ord == 11) {
    unsafe {
      pointee = pipeline_type_elem_ref_at(arena, tr);
    }
    if (pointee > 0) {
      unsafe {
        pk = pipeline_type_kind_ord_at(arena, pointee);
      }
      hit = iesz_tail_pointee(arena, pointee, pk);
      if (hit > 0) {
        return hit;
      }
      kind_ord = pk;
    }
  }
  if (kind_ord == 8) {
    hit = iesz_pack_name(arena, tr);
    if (hit > 0) {
      return hit;
    }
  }
  if (kind_ord == 13) {
    unsafe {
      pointee = pipeline_type_elem_ref_at(arena, tr);
    }
    if (pointee > 0) {
      unsafe {
        hit = glue_index_elem_byte_sz_from_type_ref_c(arena, pointee);
      }
      return hit;
    }
    return 4;
  }
  return 8;
}

/**
 * INDEX expression element byte size, true-pack.
 * @param arena *u8 — AST arena; forwarded to the pool, including null
 * @param expr_ref i32 — INDEX expr ref
 * @return i32 — element stride in bytes
 * A base whose kind is 44 is tested for .ptr of *Vec_u8 before the
 * ordinary type walk. The early walk returns only a peeler result in
 * 1..7. The resolved-type walk and the tail are separate.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32 {
  let base_ref: i32 = 0;
  let bk: i32 = 0;
  let tr: i32 = 0;
  let early: i32 = 0;
  let rtr: i32 = 0;
  unsafe {
    base_ref = pipeline_expr_index_base_ref(arena, expr_ref);
  }
  if (base_ref > 0) {
    unsafe {
      bk = pipeline_expr_kind_ord_at(arena, base_ref);
    }
    if (bk == 44) {
      if (iesz_vec_field(arena, base_ref) == 1) {
        return 1;
      }
    }
    tr = iesz_base_tr(arena, base_ref);
    if (tr > 0) {
      early = iesz_early(arena, tr);
      if (early > 0) {
        return early;
      }
    }
  }
  unsafe {
    rtr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  }
  if (rtr > 0) {
    return iesz_resolved(arena, expr_ref, rtr);
  }
  return iesz_tail(arena, expr_ref);
}
