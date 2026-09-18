// Thin pure: ttc main PTR(*T) arm (wave483).
// G.7: part of pipeline_codegen_type_to_c_repr (peer-flat).
// wave483: tip U-complete. PRODUCT inject: LINUX PREFER (stamp w483); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * PTR arm: recurse elem then append " *".
 * wave483: no-local — pipe cells; ban `x=call()`.
 * @return i32 — bytes written, or -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function cg_ttc_main_ptr_elf_c(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let inner: u8[896] = [];
    let n_cell: i32 = 0;
    pipe_store_i32_le((&n_cell) as *u8, 0, pipeline_codegen_type_to_c_repr(arena, &inner[0], 896, elem_ref, struct_prefix, struct_prefix_len));
    if (pipe_load_i32_le((&n_cell) as *u8, 0) < 0 || pipe_load_i32_le((&n_cell) as *u8, 0) + 2 >= cap) {
      return -1;
    }
    if (cg_ttc_write_bytes(scratch, cap, &inner[0], pipe_load_i32_le((&n_cell) as *u8, 0)) < 0) {
      return -1;
    }
    scratch[pipe_load_i32_le((&n_cell) as *u8, 0)] = 32;
    scratch[pipe_load_i32_le((&n_cell) as *u8, 0) + 1] = 42;
    return pipe_load_i32_le((&n_cell) as *u8, 0) + 2;
  }
}
