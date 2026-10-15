// knife256/10.2 Cap tip linked body of typeck_check_expr_struct_lit
// and typeck_ensure_struct_layout_from_struct_lit.
//
// `let n: i32x8 = { u }[1]` parses `{ u }` as an anonymous STRUCT_LIT.
// The index checker forwards the let's expected type into that base.
// The demoted struct-lit body then copies the name i32x8 onto the lit,
// stamps the lit's resolved type to that named type, and
// ensure_struct_layout_from_struct_lit registers a module layout whose
// name is exactly i32x8 and whose size is 0. glue_type_size_simple
// prefers a matching layout over the SIMD spelling, so every i32x8 in
// the module, including lits in other functions, collapses to a 4-byte
// stride. This file refuses that pair before the demoted bodies run.
// A real struct name still calls the demoted bodies. This file does not
// add a second spelling table: the expected type goes through
// asm_type_is_simd_vector_spelling, and a lit type name goes through
// xlang_simd_vector_lanes_esz_from_spelling.
// PLATFORM: SHARED — the type rule is the same on macOS, Ubuntu, and
// Windows. The weaken step that makes these symbols win is Mach-O only.

export extern "C" function typeck_check_expr_struct_lit__demoted(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32;
export extern "C" function typeck_ensure_struct_layout_from_struct_lit__demoted(
  module: *u8, arena: *u8, expr_ref: i32): i32;
export extern "C" function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern "C" function xlang_simd_vector_lanes_esz_from_spelling(
  name: *u8, name_len: usize, out_lanes: *i32, out_esz: *i32): i32;
export extern "C" function pipeline_expr_struct_lit_type_name_len(arena: *u8, expr_ref: i32): i32;
export extern "C" function pipeline_expr_struct_lit_type_name_into(
  arena: *u8, expr_ref: i32, out: *u8): void;

/**
 * Report whether a struct literal's own type name is a SIMD spelling.
 * @param arena *u8 — AST arena; null returns 0
 * @param expr_ref i32 — EXPR_STRUCT_LIT; <= 0 returns 0
 * @return i32 — 1 when xlang_simd_vector_lanes_esz_from_spelling returns
 *   0 for the lit type name. 0 when the name is empty, longer than 255
 *   bytes, or not a SIMD spelling.
 * An anonymous `{ field }` has name_len 0 and returns 0, so the demoted
 * ensure stays a no-op until some other path writes a name. The 256-byte
 * buffer is the struct-lit name cap. This function does not copy the
 * spelling table. PLATFORM: SHARED.
 */
function typeck_struct_lit_soft_name_is_simd(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let nlen: i32 = 0;
    let name: u8[256] = [];
    let lanes: i32 = 0;
    let esz: i32 = 0;
    let rc: i32 = 0;
    if (arena == 0 as *u8) {
      return 0;
    }
    if (expr_ref <= 0) {
      return 0;
    }
    nlen = pipeline_expr_struct_lit_type_name_len(arena, expr_ref);
    if (nlen <= 0) {
      return 0;
    }
    if (nlen > 255) {
      return 0;
    }
    pipeline_expr_struct_lit_type_name_into(arena, expr_ref, &name[0]);
    rc = xlang_simd_vector_lanes_esz_from_spelling(&name[0], nlen as usize, &lanes, &esz);
    if (rc == 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * Refuse a struct literal whose expected type or own type name is a SIMD
 * vector spelling, then otherwise run the demoted checker.
 * @param module *u8 — caller module; passed through to the demoted body
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — EXPR_STRUCT_LIT; passed through
 * @param return_type_ref i32 — expected type. A SIMD spelling returns -1
 *   before the demoted body can copy that name onto an anonymous lit or
 *   stamp the lit's resolved type.
 * @param ctx *u8 — dep context; passed through
 * @return i32 — -1 when the expected type or the lit type name is a SIMD
 *   spelling. Otherwise the demoted check result. 0 is success.
 * Returning before the demoted body keeps `{ u }` anonymous, so the index
 * base is not a vector and ensure never sees the name i32x8. A Point lit
 * still calls the demoted body. PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_check_expr_struct_lit(
  module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    if (arena != 0 as *u8) {
      if (return_type_ref > 0) {
        if (asm_type_is_simd_vector_spelling(arena, return_type_ref) != 0) {
          return 0 - 1;
        }
      }
      if (typeck_struct_lit_soft_name_is_simd(arena, expr_ref) != 0) {
        return 0 - 1;
      }
    }
    return typeck_check_expr_struct_lit__demoted(
      module, arena, expr_ref, return_type_ref, ctx);
  }
}

/**
 * Refuse a struct-layout registration whose lit type name is a SIMD spelling.
 * @param module *u8 — owning struct_layouts table; passed through
 * @param arena *u8 — AST arena; null defers to the demoted body
 * @param expr_ref i32 — EXPR_STRUCT_LIT
 * @return i32 — -1 when the lit type name is a SIMD spelling, so no layout
 *   named i32x8 is added. Otherwise the demoted ensure result. 0 is success.
 * The soa emit walk calls this public symbol and discards the code. The
 * refusal still skips the demoted body, so the 0-size layout is not
 * inserted. An empty anonymous name and a real struct name call the
 * demoted body. PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_ensure_struct_layout_from_struct_lit(
  module: *u8, arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if (typeck_struct_lit_soft_name_is_simd(arena, expr_ref) != 0) {
      return 0 - 1;
    }
    return typeck_ensure_struct_layout_from_struct_lit__demoted(module, arena, expr_ref);
  }
}
