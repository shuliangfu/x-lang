// Thin pure: enum namespace FIELD_ACCESS tag
// (pipeline_expr_enum_namespace_field_tag) and the compare RHS enum tag
// (pipeline_asm_cmp_enum_rhs_tag_c), copied from runtime_pipeline_abi.x.
// Both old pabi bodies use a 32-byte base_buf.
// w2055: the Darwin pabi object keeps an old C body from before w1653 with a
// 32-byte base_buf. pipeline_expr_var_name_into zeros 256 bytes, so that
// body writes past its frame; Darwin's stack guard aborts the compiler on
// parser.x (stack buffer overflow in this function). Darwin compiles this
// file with the current product, weakens the pabi copy, and links it first.
// PLATFORM: SHARED source; MACOS|DARWIN sidecar.

export extern "C" function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern "C" function wave151_bytes_eq(a: *u8, b: *u8, len: i32): i32;
export extern "C" function glue_enum_field_name_equal(field_buf: *u8, flen: i32, expect: *u8, elen: i32): i32;
export extern "C" function pipeline_token_kind_variant_tag(variant_name: *u8, variant_len: i32): i32;
export extern "C" function pipeline_expr_enum_field_tag_via_module(enum_name: *u8, enum_len: i32, variant_name: *u8, variant_len: i32): i32;
export extern "C" function pipeline_asm_typekind_variant_tag(field_buf: *u8, flen: i32): i32;

/**
 * Enum namespace FIELD_ACCESS tag (ExprKind/TypeKind/TokenKind + module sidecar).
 * @param a *u8 - ASTArena*
 * @param expr_ref i32 - FIELD_ACCESS expr ref
 * @return i32 - tag or -1
 * wave151 pure: G.7 authority (was pipeline_expr_enum_namespace_field_tag).
 * pipeline_expr_var_name_into zeros 256 bytes before copying the name.
 * base_buf matches that contract. The blen > 31 gate still rejects names
 * this table does not compare.
 * Enum.VARIANT keeps the VAR name as the enum name.
 * module.Enum.VARIANT is one nested FIELD_ACCESS: the inner field name is
 * the enum name, and that inner base must be a VAR (the module qualifier).
 * The qualifier name is not compared. PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_expr_enum_namespace_field_tag(a: *u8, expr_ref: i32): i32 {
  let base_buf: u8[256] = [];
  let field_buf: u8[256] = [];
  let blen: i32 = 0;
  let flen: i32 = 0;
  let base_ref: i32 = 0;
  let inner_ref: i32 = 0;
  let ko: i32 = 0;
  let tk: i32 = 0;
  let mod_tag: i32 = 0;
  let nm_exprkind: u8[8] = [69, 120, 112, 114, 75, 105, 110, 100];
  let nm_typekind: u8[8] = [84, 121, 112, 101, 75, 105, 110, 100];
  let nm_tokenkind: u8[9] = [84, 111, 107, 101, 110, 75, 105, 110, 100];
  // ExprKind variants
  let e_lit: u8[8] = [69, 88, 80, 82, 95, 76, 73, 84];
  let e_fa: u8[17] = [69, 88, 80, 82, 95, 70, 73, 69, 76, 68, 95, 65, 67, 67, 69, 83, 83];
  let e_call: u8[9] = [69, 88, 80, 82, 95, 67, 65, 76, 76];
  let e_var: u8[8] = [69, 88, 80, 82, 95, 86, 65, 82];
  let e_block: u8[10] = [69, 88, 80, 82, 95, 66, 76, 79, 67, 75];
  // TypeKind variants (byte tables)
  let t_i32: u8[8] = [84, 89, 80, 69, 95, 73, 51, 50];
  let t_bool: u8[9] = [84, 89, 80, 69, 95, 66, 79, 79, 76];
  let t_u8: u8[7] = [84, 89, 80, 69, 95, 85, 56];
  let t_u32: u8[8] = [84, 89, 80, 69, 95, 85, 51, 50];
  let t_u64: u8[8] = [84, 89, 80, 69, 95, 85, 54, 52];
  let t_i64: u8[8] = [84, 89, 80, 69, 95, 73, 54, 52];
  let t_usize: u8[10] = [84, 89, 80, 69, 95, 85, 83, 73, 90, 69];
  let t_isize: u8[10] = [84, 89, 80, 69, 95, 73, 83, 73, 90, 69];
  let t_named: u8[10] = [84, 89, 80, 69, 95, 78, 65, 77, 69, 68];
  let t_ptr: u8[8] = [84, 89, 80, 69, 95, 80, 84, 82];
  let t_arr: u8[10] = [84, 89, 80, 69, 95, 65, 82, 82, 65, 89];
  let t_sli: u8[10] = [84, 89, 80, 69, 95, 83, 76, 73, 67, 69];
  let t_vec: u8[11] = [84, 89, 80, 69, 95, 86, 69, 67, 84, 79, 82];
  let t_f32: u8[8] = [84, 89, 80, 69, 95, 70, 51, 50];
  let t_f64: u8[8] = [84, 89, 80, 69, 95, 70, 54, 52];
  let t_void: u8[9] = [84, 89, 80, 69, 95, 86, 79, 73, 68];
  if (a == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    if (pipeline_expr_kind_ord_at(a, expr_ref) != 44) {
      return 0 - 1;
    }
    base_ref = pipeline_expr_field_access_base_ref(a, expr_ref);
    if (base_ref <= 0) {
      return 0 - 1;
    }
    ko = pipeline_expr_kind_ord_at(a, base_ref);
    // FIELD_ACCESS base is module.Enum. The enum name is that field.
    // Its base must be a VAR. A bare Enum.VARIANT stays the VAR arm.
    // PLATFORM: SHARED.
    if (ko == 44) {
      inner_ref = pipeline_expr_field_access_base_ref(a, base_ref);
      if (inner_ref <= 0 || pipeline_expr_kind_ord_at(a, inner_ref) != 3) {
        return 0 - 1;
      }
      blen = pipeline_expr_field_access_name_len(a, base_ref);
      if (blen <= 0 || blen > 31) {
        return 0 - 1;
      }
      pipeline_expr_field_access_name_into(a, base_ref, &base_buf[0]);
    } else {
      if (ko != 3) {
        return 0 - 1;
      }
      blen = pipeline_expr_var_name_len(a, base_ref);
      if (blen <= 0 || blen > 31) {
        return 0 - 1;
      }
      pipeline_expr_var_name_into(a, base_ref, &base_buf[0]);
    }
    flen = pipeline_expr_field_access_name_len(a, expr_ref);
    if (flen <= 0 || flen > 255) {
      return 0 - 1;
    }
    pipeline_expr_field_access_name_into(a, expr_ref, &field_buf[0]);
  }
  // Calls below are extern here (local in runtime_pipeline_abi.x). PLATFORM: SHARED.
  unsafe {
    if (blen == 8 && wave151_bytes_eq(&base_buf[0], &nm_exprkind[0], 8) != 0) {
      if (glue_enum_field_name_equal(&field_buf[0], flen, &e_lit[0], 8) != 0) { return 0; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &e_fa[0], 17) != 0) { return 44; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &e_call[0], 9) != 0) { return 48; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &e_var[0], 8) != 0) { return 3; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &e_block[0], 10) != 0) { return 26; }
    }
    if (blen == 8 && wave151_bytes_eq(&base_buf[0], &nm_typekind[0], 8) != 0) {
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_i32[0], 8) != 0) { return 0; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_bool[0], 9) != 0) { return 1; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_u8[0], 7) != 0) { return 2; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_u32[0], 8) != 0) { return 3; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_u64[0], 8) != 0) { return 4; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_i64[0], 8) != 0) { return 5; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_usize[0], 10) != 0) { return 6; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_isize[0], 10) != 0) { return 7; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_named[0], 10) != 0) { return 8; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_ptr[0], 8) != 0) { return 9; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_arr[0], 10) != 0) { return 10; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_sli[0], 10) != 0) { return 11; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_vec[0], 11) != 0) { return 12; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_f32[0], 8) != 0) { return 13; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_f64[0], 8) != 0) { return 14; }
      if (glue_enum_field_name_equal(&field_buf[0], flen, &t_void[0], 9) != 0) { return 15; }
    }
    if (blen == 9 && wave151_bytes_eq(&base_buf[0], &nm_tokenkind[0], 9) != 0) {
      tk = pipeline_token_kind_variant_tag(&field_buf[0], flen);
      if (tk >= 0) {
        return tk;
      }
    }
    mod_tag = pipeline_expr_enum_field_tag_via_module(&base_buf[0], blen, &field_buf[0], flen);
    if (mod_tag >= 0) {
      return mod_tag;
    }
  }
  return 0 - 1;
}

/**
 * RHS is TypeKind./ExprKind. FIELD_ACCESS → enum tag; else -1.
 * Does not consult module fields (avoids module.x false hits).
 * @param arena *u8 - ASTArena*
 * @param expr_ref i32 - candidate field-access expr
 * @return i32 - tag >= 0 or -1
 * wave137 pure: was static pipeline_asm_cmp_enum_rhs_tag_c.
 * pipeline_expr_var_name_into zeros 256 bytes before copying the name.
 * base_buf matches that contract. A 32-byte buffer on the Windows shifted
 * frame covers the saved rbp and the return address (72 bytes past the
 * buffer). field_buf is already 256. PLATFORM: SHARED.
 */
export function pipeline_asm_cmp_enum_rhs_tag_c(arena: *u8, expr_ref: i32): i32 {
  let base_buf: u8[256] = [];
  let field_buf: u8[256] = [];
  let blen: i32 = 0;
  let flen: i32 = 0;
  let tag: i32 = 0;
  let ko: i32 = 0;
  let base_ref: i32 = 0;
  let k: i32 = 0;
  if (arena == 0 as *u8 || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  // EXPR_FIELD_ACCESS = 44
  if (ko != 44) {
    return 0 - 1;
  }
  unsafe {
    base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  }
  if (base_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  // EXPR_VAR = 3
  if (ko != 3) {
    return 0 - 1;
  }
  unsafe {
    blen = pipeline_expr_var_name_len(arena, base_ref);
  }
  if (blen != 8) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, base_ref, &base_buf[0]);
    flen = pipeline_expr_field_access_name_len(arena, expr_ref);
  }
  if (flen <= 0 || flen > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_field_access_name_into(arena, expr_ref, &field_buf[0]);
  }
  // base "TypeKind"
  if (base_buf[0] == 84 as u8 && base_buf[1] == 121 as u8 && base_buf[2] == 112 as u8 && base_buf[3] == 101 as u8 && base_buf[4] == 75 as u8 && base_buf[5] == 105 as u8 && base_buf[6] == 110 as u8 && base_buf[7] == 100 as u8) {
    unsafe {
      tag = pipeline_asm_typekind_variant_tag(&field_buf[0], flen);
    }
    return tag;
  }
  // base "ExprKind"
  if (base_buf[0] == 69 as u8 && base_buf[1] == 120 as u8 && base_buf[2] == 112 as u8 && base_buf[3] == 114 as u8 && base_buf[4] == 75 as u8 && base_buf[5] == 105 as u8 && base_buf[6] == 110 as u8 && base_buf[7] == 100 as u8) {
    unsafe {
      tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    }
    return tag;
  }
  return 0 - 1;
}

