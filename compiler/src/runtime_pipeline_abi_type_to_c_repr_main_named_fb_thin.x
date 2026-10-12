// Thin pure: ttc main NAMED + kind fallback arm (wave483).
// G.7: part of pipeline_codegen_type_to_c_repr (peer-flat).
// wave483: tip U-complete. PRODUCT inject: LINUX PREFER (stamp w483); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function cg_ttc_write_named_tag(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
export extern function pipeline_codegen_type_kind_copy(dst: *u8, cap: i32, kind: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * NAMED try then kind_copy(tk) then kind_copy(0).
 * wave483: no-local — pipe cells; ban `x=call()`.
 * @return i32 — bytes written
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function cg_ttc_main_named_fb_elf_c(arena: *u8, scratch: *u8, cap: i32, type_ref: i32, tk: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  unsafe {
    let n_cell: i32 = 0;
    if (tk == 8) {
      pipe_store_i32_le((&n_cell) as *u8, 0, cg_ttc_write_named_tag(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len));
      if (pipe_load_i32_le((&n_cell) as *u8, 0) >= 0) {
        return pipe_load_i32_le((&n_cell) as *u8, 0);
      }
    }
    pipe_store_i32_le((&n_cell) as *u8, 0, pipeline_codegen_type_kind_copy(scratch, cap, tk));
    if (pipe_load_i32_le((&n_cell) as *u8, 0) > 0) {
      return pipe_load_i32_le((&n_cell) as *u8, 0);
    }
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
}
