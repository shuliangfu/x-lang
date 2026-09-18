// Thin pure: ttc REST pipeline_codegen_type_to_c_repr dispatcher (wave434/w483).
// G.7: body MUST match type_to_c_repr_thin / mega (ARRAY/SLICE/NAMED delegated).
// wave428: Darwin -c ~10124B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// wave434: LINUX PREFER — NAMED/ARRAY/SLICE via peer thins (co-file XT001/empty).
// wave483: peer-flat no-local (monolith tip U=2/10→8/12). Tip U=12/12.
//   PRODUCT inject: LINUX PREFER (stamp w483); MACOS full thin.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function cg_ttc_write_bytes(dst: *u8, cap: i32, src: *u8, n: i32): i32;
export extern function cg_ttc_write_array_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, arr_sz: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_write_slice_tag(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_main_ptr_elf_c(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function cg_ttc_main_vec_elf_c(arena: *u8, scratch: *u8, cap: i32, elem_ref: i32, arr_sz: i32): i32;
export extern function cg_ttc_main_named_fb_elf_c(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, tk: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Recursive type_to_c_repr dispatcher — peer-flat arms.
 * wave483: no-local — pipe cells + peer cascade; ban `x=call()`.
 * @return i32 - byte count, or -1 on overflow
 * PLATFORM: SHARED host-C type_to_c_repr authority.
 */
#[no_mangle]
export function pipeline_codegen_type_to_c_repr(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let nt_cell: i32 = 0;
    let tk_cell: i32 = 0;
    let elem_cell: i32 = 0;
    let arr_cell: i32 = 0;
    if (cap < 16) {
      return -1;
    }
    if (scratch == 0 as *u8) {
      return -1;
    }
    if (arena != 0 as *u8) {
      pipe_store_i32_le((&nt_cell) as *u8, 0, pipeline_arena_num_types(arena));
    }
    if (arena == 0 as *u8 || type_ref <= 0 || type_ref > pipe_load_i32_le((&nt_cell) as *u8, 0)) {
      return cg_ttc_write_bytes(scratch, cap, "int32_t", 7);
    }
    pipe_store_i32_le((&tk_cell) as *u8, 0, pipeline_type_kind_ord_at(arena, type_ref));
    pipe_store_i32_le((&elem_cell) as *u8, 0, pipeline_type_elem_ref_at(arena, type_ref));
    pipe_store_i32_le((&arr_cell) as *u8, 0, pipeline_type_array_size_at(arena, type_ref));
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 9 && pipe_load_i32_le((&elem_cell) as *u8, 0) > 0) {
      return cg_ttc_main_ptr_elf_c(arena, scratch, cap, pipe_load_i32_le((&elem_cell) as *u8, 0), struct_prefix, struct_prefix_len);
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 10 && pipe_load_i32_le((&elem_cell) as *u8, 0) > 0) {
      return cg_ttc_write_array_tag(arena, scratch, cap, pipe_load_i32_le((&elem_cell) as *u8, 0), pipe_load_i32_le((&arr_cell) as *u8, 0), struct_prefix, struct_prefix_len);
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 13 && pipe_load_i32_le((&elem_cell) as *u8, 0) > 0) {
      return cg_ttc_main_vec_elf_c(arena, scratch, cap, pipe_load_i32_le((&elem_cell) as *u8, 0), pipe_load_i32_le((&arr_cell) as *u8, 0));
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 12 && pipe_load_i32_le((&elem_cell) as *u8, 0) > 0) {
      return pipeline_codegen_type_to_c_repr(arena, scratch, cap, pipe_load_i32_le((&elem_cell) as *u8, 0), struct_prefix, struct_prefix_len);
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 17) {
      return cg_ttc_write_bytes(scratch, cap, "struct xlang_dyn_obj", 20);
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 18) {
      return cg_ttc_write_bytes(scratch, cap, "uint8_t *", 9);
    }
    if (pipe_load_i32_le((&tk_cell) as *u8, 0) == 11 && pipe_load_i32_le((&elem_cell) as *u8, 0) > 0) {
      return cg_ttc_write_slice_tag(arena, scratch, cap, pipe_load_i32_le((&elem_cell) as *u8, 0), struct_prefix, struct_prefix_len);
    }
    return cg_ttc_main_named_fb_elf_c(arena, scratch, cap, type_ref, pipe_load_i32_le((&tk_cell) as *u8, 0), struct_prefix, struct_prefix_len);
  }
}
