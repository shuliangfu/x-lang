// Thin pure: ttc main VECTOR arm (wave483).
// G.7: part of pipeline_codegen_type_to_c_repr (peer-flat).
// wave483: tip U-complete. PRODUCT inject: LINUX PREFER (stamp w483); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32;
export extern function pipeline_codegen_vector_type_copy(dst: *u8, cap: i32, elem_kind: i32, lanes: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * VECTOR arm: vector_type_copy else kind_copy(0).
 * wave483: no-local — pipe cells; ban `x=call()`.
 * @return i32 — bytes written, or -1 path via kind_copy
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function cg_ttc_main_vec_elf_c(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, arr_sz: i32): i32 {
  unsafe {
    let n_cell: i32 = 0;
    pipe_store_i32_le((&n_cell) as *u8, 0, pipeline_codegen_vector_type_copy(scratch, cap, pipeline_type_kind_ord_at(arena, elem_ref), arr_sz));
    if (pipe_load_i32_le((&n_cell) as *u8, 0) >= 0) {
      return pipe_load_i32_le((&n_cell) as *u8, 0);
    }
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
}
