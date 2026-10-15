// knife256/10.2 Cap tip linked body of glue_func_return_byte_size_c.
// The mega body returns 8 for every TYPE_ARRAY, so a [2]Vec8i return
// is an 8-byte register value. The payload is 64 bytes. Lane 7 never
// lands in the caller. This thin returns the fixed-array total when
// the element is a TYPE_VECTOR of i32 wider than 16 bytes, then the
// existing sret copy moves that many bytes. Every other array stays
// 8 bytes. Named i32x8 is kind 8 and stays on the demoted body.
// PLATFORM: SHARED — the size rule is the same on macOS, Ubuntu, and Windows.
// The demote step that makes this symbol win is Mach-O only.

export extern "C" function glue_func_return_byte_size_c__demoted(
  mod: *u8, arena: *u8, func_index: i32): i32;
export extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
export extern "C" function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern "C" function pipeline_arena_num_types(arena: *u8): i32;
export extern "C" function glue_index_simd_elem_bytes_c(arena: *u8, ty: i32): i32;
export extern "C" function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;

/**
 * Byte count of a fixed array of a wide i32 vector, or 0.
 * @param arena *u8 — AST arena; null returns 0
 * @param rty i32 — function return type; not an array returns 0
 * @return i32 — payload bytes when the element is a TYPE_VECTOR of i32
 *   wider than 16 bytes and the array total is wider than 16; otherwise 0
 * Kind 8, a TYPE_VECTOR of f32, and a vector of 16 bytes or fewer stay 0
 * so the caller keeps the 8-byte array return. A null arena returns 0.
 * Two compares, not a chained &&.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_wide_i32_vec_array_bytes(arena: *u8, rty: i32): i32 {
  unsafe {
    let ord_array: i32 = 10;
    let ord_vector: i32 = 13;
    let ord_i32: i32 = 0;
    let k: i32 = 0;
    let elem: i32 = 0;
    let ek: i32 = 0;
    let inner: i32 = 0;
    let ik: i32 = 0;
    let width: i32 = 0;
    let tot: i32 = 0;
    let ntypes: i32 = 0;
    if (arena == 0 as *u8 || rty <= 0) {
      return 0;
    }
    ntypes = pipeline_arena_num_types(arena);
    if (rty > ntypes) {
      return 0;
    }
    k = pipeline_type_kind_ord_at(arena, rty);
    if (k != ord_array) {
      return 0;
    }
    elem = pipeline_type_elem_ref_at(arena, rty);
    if (elem <= 0 || elem > ntypes) {
      return 0;
    }
    ek = pipeline_type_kind_ord_at(arena, elem);
    if (ek != ord_vector) {
      return 0;
    }
    inner = pipeline_type_elem_ref_at(arena, elem);
    if (inner <= 0 || inner > ntypes) {
      return 0;
    }
    ik = pipeline_type_kind_ord_at(arena, inner);
    if (ik != ord_i32) {
      return 0;
    }
    width = glue_index_simd_elem_bytes_c(arena, elem);
    if (width <= 16) {
      return 0;
    }
    tot = glue_fixed_array_total_bytes_c(arena, rty, 0);
    if (tot <= 16) {
      return 0;
    }
    return tot;
  }
}

/**
 * Function return size, with a wide i32-vector array as its payload.
 * @param mod *u8 — module; null defers to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param func_index i32 — function index; out of range defers to demoted
 * @return i32 — payload bytes, or the demoted size
 * A [2]Vec8i return is 64 bytes, so the existing sret path copies it.
 * A [2]i32 return stays 8 bytes. A miss calls the demoted body.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function glue_func_return_byte_size_c(mod: *u8, arena: *u8, func_index: i32): i32 {
  unsafe {
    let rty: i32 = 0;
    let wide: i32 = 0;
    let nf: i32 = 0;
    if (mod != 0 as *u8) {
      if (arena != 0 as *u8) {
        if (func_index >= 0) {
          nf = pipeline_module_num_funcs(mod);
          if (func_index < nf) {
            rty = pipeline_module_func_return_type_at(mod, func_index);
            if (rty > 0) {
              wide = glue_wide_i32_vec_array_bytes(arena, rty);
              if (wide > 16) {
                return wide;
              }
            }
          }
        }
      }
    }
    return glue_func_return_byte_size_c__demoted(mod, arena, func_index);
  }
}
