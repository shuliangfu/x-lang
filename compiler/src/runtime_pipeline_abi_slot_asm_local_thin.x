// Thin pure: slot REST asm_local_slot_bytes only (peers via leftover/helpers).
// G.7: body MUST match asm_local_slot_bytes in slot_bytes_thin / mega.
// wave428: LINUX PREFER — Darwin -c ~510B; Ubuntu -c ~879B; product inject
//   + true relink L2 5/5 opt=102 (md5 changed). ensure injects after helpers.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS (full slot covers).

export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_module_num_struct_layouts_at(mod: *u8): i32;
export extern function pipeline_module_struct_layout_name_len(mod: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_name_byte_at(mod: *u8, k: i32, j: i32): i32;
export extern function typeck_typeck_struct_layout_metrics(mod: *u8, arena: *u8, k: i32, a: i32, b: i32, sz: *i32, al: *i32): i32;
export extern function pipeline_module_struct_layout_num_fields(mod: *u8, k: i32): i32;
export extern function pipeline_module_struct_layout_field_offset_at(mod: *u8, k: i32, j: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(mod: *u8, k: i32, j: i32): i32;
export extern function pipeline_arena_num_types(arena: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_asm_glue_emit_module_ref(): *u8;
export extern function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32;
export extern function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, type_ref: i32, depth: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, type_ref: i32, depth: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function asm_fixed_array_total_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32;
export extern function pipe_local_slot_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32;

/**
 * Public stack slot bytes for const/let (no ctx; emit module + dep walk).
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref
 * @return i32 - slot bytes
 * wave268 pure: G.7 single product authority (was pipeline_asm_slot_bytes.c).
 * PLATFORM: SHARED freestanding stack layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32 {
  unsafe {
    return pipe_local_slot_bytes_mod(arena, type_ref, 0 as *u8);
  }
}
