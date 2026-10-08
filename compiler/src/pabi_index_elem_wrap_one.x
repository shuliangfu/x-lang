// Short wrapper pipeline_asm_index_elem_byte_sz. The body stays in
// pabi_index_elem_byte_sz_one.x. Same-.o dual T smashes i32, so this
// link winner is its own object. The egg also defines this name as a
// one-line forward. Windows true-pack prepends this object so the
// forward first-wins. Do not gcc -DXLANG_WIN_TRUE_PACK of
// seeds/win_index_elem_byte_sz_override.c on the Windows path.
// Linux and Darwin rebuild this file into index_elem_wrap.o.
// Do not cc or gcc that seed into one object on Windows, Linux, or
// Darwin.
// PLATFORM: SHARED body. Windows, Linux, and Darwin link this object.

export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;

/**
 * Public INDEX element-width wrapper.
 * @param arena *u8 — AST arena; forwarded, including null
 * @param index_expr_ref i32 — INDEX expr ref; forwarded
 * @return i32 — the result of pipeline_asm_index_elem_byte_sz_c
 * No second copy of the INDEX walk lives here.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32 {
  unsafe {
    return pipeline_asm_index_elem_byte_sz_c(arena, index_expr_ref);
  }
}
