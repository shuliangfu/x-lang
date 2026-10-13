// knife256/10.2 Cap tip soft: demoted first (#[repr(compatible)]).
// ADDR_OF same-arena *NAMED: inline last-segment name match only
// (PairA≠PairC; does NOT call type_refs_equal — Cap tip equal soft is broader
// for get_dep/assign). Cap tip dep formal (not PTR in caller arena): soft-accept.
// PLATFORM: SHARED — Cap tip L2 sidecar.
export extern "C" function typeck_call_arg_repr_compatible_ok__demoted(module: *u8, arena: *u8,
param_ref: i32, arg_ref: i32): i32;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;

#[no_mangle]
export function typeck_call_arg_repr_compatible_ok(module: *u8, arena: *u8, param_ref: i32,
arg_ref: i32): i32 {
  unsafe {
    let param_elem: i32 = 0;
    let arg_elem: i32 = 0;
    let arg_ty: i32 = 0;
    let op: i32 = 0;
    let ak: i32 = 0;
    let pk: i32 = 0;
    let al: i32 = 0;
    let bl: i32 = 0;
    let ao: i32 = 0;
    let bo: i32 = 0;
    let n: i32 = 0;
    let i: i32 = 0;
    let an: u8[256] = [];
    let bn: u8[256] = [];
    if (module == 0 as *u8 || arena == 0 as *u8 || param_ref <= 0 || arg_ref <= 0) {
      return 0;
    }
    if (typeck_call_arg_repr_compatible_ok__demoted(module, arena, param_ref, arg_ref) != 0) {
      return 1;
    }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) != 51) {
      return 0;
    }
    pk = pipeline_type_kind_ord_at(arena, param_ref);
    if (pk == 9) {
      param_elem = pipeline_type_elem_ref_at(arena, param_ref);
      if (param_elem <= 0) {
        return 0;
      }
      op = pipeline_expr_unary_operand_ref_at(arena, arg_ref);
      if (op <= 0) {
        return 0;
      }
      arg_ty = pipeline_expr_resolved_type_ref(arena, op);
      if (arg_ty <= 0) {
        arg_ty = pipeline_expr_resolved_type_ref(arena, arg_ref);
      }
      if (arg_ty <= 0) {
        return 0;
      }
      ak = pipeline_type_kind_ord_at(arena, arg_ty);
      if (ak == 8) {
        arg_elem = arg_ty;
      } else if (ak == 9) {
        arg_elem = pipeline_type_elem_ref_at(arena, arg_ty);
      } else {
        return 0;
      }
      if (arg_elem <= 0) {
        return 0;
      }
      if (pipeline_type_kind_ord_at(arena, param_elem) != 8
          || pipeline_type_kind_ord_at(arena, arg_elem) != 8) {
        return 0;
      }
      al = pipeline_type_named_name_into(arena, param_elem, &an[0]);
      bl = pipeline_type_named_name_into(arena, arg_elem, &bn[0]);
      if (al <= 0 || bl <= 0 || al > 255 || bl > 255) {
        return 0;
      }
      if (al == bl) {
        i = 0;
        while (i < al) {
          if (an[i] != bn[i]) {
            i = al + 1;
          } else {
            i = i + 1;
          }
        }
        if (i == al) {
          return 1;
        }
      }
      ao = 0;
      i = 0;
      while (i < al) {
        if (an[i] == 46) {
          ao = i + 1;
        }
        i = i + 1;
      }
      bo = 0;
      i = 0;
      while (i < bl) {
        if (bn[i] == 46) {
          bo = i + 1;
        }
        i = i + 1;
      }
      n = al - ao;
      if (n <= 0 || n != (bl - bo)) {
        return 0;
      }
      i = 0;
      while (i < n) {
        if (an[ao + i] != bn[bo + i]) {
          return 0;
        }
        i = i + 1;
      }
      return 1;
    }
    /* Cap tip dep formal not PTR in caller arena */
    return 1;
  }
}
