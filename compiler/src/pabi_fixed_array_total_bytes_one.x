// One strong glue_fixed_array_total_bytes_c. Body matches
// seeds/fixed_array_total_bytes_true_pack_override.c.
// runtime_pipeline_abi.x has the same name and a different body: every
// TYPE_NAMED goes through glue_type_size_simple, and a null module
// yields 4. Do not fold this TU into that function. Do not gcc the
// seed on the Windows or Linux path. Darwin still compiles the C.
// PLATFORM: SHARED body. Linux and Windows relinks consume this file.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;

/**
 * Total bytes of a TYPE_ARRAY with true-pack leaf widths.
 * @param arena *u8 — AST arena; null returns 0
 * @param ty_ref i32 — type pool ref; must be TYPE_ARRAY (kind 10)
 * @param depth i32 — recursion depth; depth > 8 returns 0
 * @return i32 — N * element stride, or 0 when the type is not a usable array
 * Nested arrays recurse. Named i8, u8, and bool are 1 byte. Named i16
 * and u16 are 2 bytes. Other named types use glue_type_size_simple when
 * a module is present, else 4. A null module still keeps the five
 * true-pack names.
 * PLATFORM: SHARED — one strong T. Linux and Windows link this ahead of the egg.
 */
#[no_mangle]
export function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32 {
  let n: i32 = 0;
  let elem: i32 = 0;
  let ek: i32 = 0;
  let esz: i32 = 0;
  let sl: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let sn: u8[64] = [];
  if (arena == (0 as *u8) || ty_ref <= 0 || depth > 8) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, ty_ref);
  }
  if (ek != 10) {
    return 0;
  }
  unsafe {
    n = pipeline_type_array_size_at(arena, ty_ref);
    elem = pipeline_type_elem_ref_at(arena, ty_ref);
  }
  if (n <= 0 || elem <= 0) {
    return 0;
  }
  unsafe {
    ek = pipeline_type_kind_ord_at(arena, elem);
  }
  if (ek == 10) {
    esz = glue_fixed_array_total_bytes_c(arena, elem, depth + 1);
    if (esz <= 0) {
      return 0;
    }
    return n * esz;
  }
  if (ek == 2 || ek == 1) {
    esz = 1;
  } else if (ek == 0 || ek == 3 || ek == 13 || ek == 14) {
    esz = 4;
  } else if (ek == 15 || ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 9 || ek == 18) {
    esz = 8;
  } else if (ek == 8) {
    // True-pack named widths. Checked before glue_type_size_simple so a
    // null module still returns 1 or 2. Bytes are ASCII i/u/b/o/l/1/6/8.
    unsafe {
      sl = pipeline_type_named_name_into(arena, elem, &sn[0]);
    }
    if (sl == 2 && sn[0] == 105 && sn[1] == 56) {
      esz = 1;
    } else if (sl == 2 && sn[0] == 117 && sn[1] == 56) {
      esz = 1;
    } else if (sl == 4 && sn[0] == 98 && sn[1] == 111 && sn[2] == 111 && sn[3] == 108) {
      esz = 1;
    } else if (sl == 3 && sn[0] == 105 && sn[1] == 49 && sn[2] == 54) {
      esz = 2;
    } else if (sl == 3 && sn[0] == 117 && sn[1] == 49 && sn[2] == 54) {
      esz = 2;
    } else {
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
      }
      if (mod != (0 as *u8)) {
        unsafe {
          esz = glue_type_size_simple(mod, arena, elem, 0);
        }
        if (esz <= 0) {
          esz = 8;
        }
      } else {
        esz = 4;
      }
    }
  } else if (ek == 11) {
    esz = 16;
  } else {
    esz = 4;
  }
  return n * esz;
}
