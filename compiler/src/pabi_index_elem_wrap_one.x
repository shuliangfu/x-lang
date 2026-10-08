// Short wrapper pipeline_asm_index_elem_byte_sz. The body stays in
// pabi_index_elem_byte_sz_one.x. Same-.o dual T smashes i32, so this
// link winner is its own object. The egg also defines this name as a
// one-line forward. Windows true-pack prepends this object so the
// forward first-wins. Do not gcc -DXLANG_WIN_TRUE_PACK of
// seeds/win_index_elem_byte_sz_override.c on the Windows path.
// PLATFORM: SHARED body. Windows relink consumes this object.

export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;

/**
 * Public INDEX element-width wrapper.
 * @param arena *u8 — AST arena; forwarded, including null
 * @param index_expr_ref i32 — INDEX expr ref; forwarded
 * @return i32 — the result of pipeline_asm_index_elem_byte_sz_c
 * No second copy of the INDEX walk lives here.
 * PLATFORM: SHARED — Windows true-pack links this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32 {
  unsafe {
    return pipeline_asm_index_elem_byte_sz_c(arena, index_expr_ref);
  }
}
