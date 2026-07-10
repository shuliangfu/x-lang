// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-364/367：backend_call_dispatch L2 thin — pure 门闩（weak）。
// PREFER_X_O：thin.o + seed-rest（-DSHUX_L2_CALL_DISPATCH_THIN_FROM_X）ld -r
//   → backend_call_dispatch.o
//

extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_len_for_string_lit_c(arena: *u8, er: i32): i32;

#[no_mangle]
function glue_asm_call_reg_max(ta: i32): i32 {
  if (ta == 0) {
    return 6;
  }
  return 8;
}

#[no_mangle]
function glue_asm_call_stack_cleanup_bytes(ta: i32, nargs: i32): i32 {
  if (nargs <= 0) {
    return 0;
  }
  if (ta == 0) {
    if (nargs <= 6) {
      return 0;
    }
    if (((nargs - 6) & 1) != 0) {
      return (nargs - 6) * 8 + 8;
    }
    return (nargs - 6) * 8;
  }
  if (ta == 2) {
    return 0 - 1;
  }
  if (nargs <= 8) {
    return 0;
  }
  return (((nargs - 8) * 8 + 15) & (0 - 16));
}

#[no_mangle]
function glue_asm_append_export_c_suffix(sym: *u8, sym_len: i32, cap: i32): i32 {
  if (sym == 0 as *u8) {
    return sym_len;
  }
  if (sym_len <= 0) {
    return sym_len;
  }
  if (sym_len + 2 >= cap) {
    return sym_len;
  }
  unsafe {
    sym[sym_len] = 95;
    sym[sym_len + 1] = 99;
  }
  return sym_len + 2;
}

// GLUE_EXPR_STRING_LIT_ORD = 59
#[no_mangle]
function glue_asm_string_lit_len(arena: *u8, expr_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 59) {
      return 0;
    }
    return pipeline_expr_var_name_len_for_string_lit_c(arena, expr_ref);
  }
  return 0;
}

// ---- G-02f-366：f32 type / param type_ref / path segment count ----
extern "C" function pipeline_asm_call_param_type_ref_at_c(arena: *u8, call_expr_ref: i32, param_index: i32): i32;


#[no_mangle]
function glue_call_param_type_ref_at(arena: *u8, call_expr_ref: i32, param_index: i32): i32 {
  unsafe {
    return pipeline_asm_call_param_type_ref_at_c(arena, call_expr_ref, param_index);
  }
  return 0;
}

// ---- G-02f-367：f32 判定 + build_ 前缀冗余 ----
extern "C" function pipeline_type_kind_ord_at(arena: *u8, ty: i32): i32;

#[no_mangle]
function glue_call_param_is_f32_c(arena: *u8, type_ref: i32): i32 {
  if (arena == 0 as *u8) {
    return 0;
  }
  if (type_ref <= 0) {
    return 0;
  }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, type_ref) != 14) {
      return 0;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
function glue_asm_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (prefix_len != 6) {
    return 0;
  }
  if (name_len < 6) {
    return 0;
  }
  unsafe {
    if (prefix[0] != 98) {
      return 0;
    }
    if (prefix[1] != 117) {
      return 0;
    }
    if (prefix[2] != 105) {
      return 0;
    }
    if (prefix[3] != 108) {
      return 0;
    }
    if (prefix[4] != 100) {
      return 0;
    }
    if (prefix[5] != 95) {
      return 0;
    }
    if (name[0] != 98) {
      return 0;
    }
    if (name[1] != 117) {
      return 0;
    }
    if (name[2] != 105) {
      return 0;
    }
    if (name[3] != 108) {
      return 0;
    }
    if (name[4] != 100) {
      return 0;
    }
    if (name[5] != 95) {
      return 0;
    }
    return 1;
  }
  return 0;
}
