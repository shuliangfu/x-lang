// Thin pure: slot_bytes HELPERS leaf (named + fixed_array + pipe_local).
// G.7: bodies MUST match the same symbols in runtime_pipeline_abi.x /
// runtime_pipeline_abi_slot_bytes_thin.x (full leaf keeps asm_local_slot_bytes).
// ensure: pipeline_abi_inject_slot_bytes_thin dispatches this on LINUX.
// wave415: LINUX PREFER helpers-only (full tip -c T001@asm_local MISATTRIBUTED;
//   helpers -c green ~3504B; tip .o first-wins asm_fixed_array_total_bytes_mod;
//   unused pipe_* may DCE in tip .o — leftover keeps them for asm_local).
//   MACOS still full thin PREFER. asm_local tip reinject still BAN on LINUX.
// wave590 Soft Cap: Ubuntu tip `-backend asm -c` UND=1 (kind_ord only;
//   T only asm_fixed_array_total_bytes_mod). The original body used
//   if-before-call, mid-assign of nlen/nt/asz/ko/sz, nested while
//   name-match, local u8[256] / i32[1] metrics out (*i32 SEGV class),
//   and branch-gated encoder calls, which that tip drops. Darwin
//   original kept all 22 encoders (3 T). slot_bytes_store_encoders
//   always stores each i32 encoder once; pointer-returning encoders
//   are nested as args. The export returns 0; the real path stays
//   on the w415 overlay. Never stores through *i32.
// stamp w590 HARD BAN LINUX tip PRODUCT reinject (keep w415 overlay).
//   MACOS still PREFER-injects the full thin.
// PLATFORM: SHARED freestanding slot sizing · LINUX gold · MACOS.

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
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

/**
 * Store the slot_bytes helper encoders. Each i32 encoder is
 * pipe_store_i32_le'd once. Pointer-returning encoders
 * (glue_emit_module_ref, emit_dep_pipe, dep_ctx_module_at,
 * dep_ctx_arena_at) nest as args. Metrics out pointers are
 * 0 as *i32 (never stored through). Dummy name dest is cell.
 * No locals. Each encoder runs once, not under if, while, or
 * after a mid-assign. The overlay still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param type_ref i32 — type ref; dummy type
 * @param mod *u8 — Module*; may be null
 * @param cell *u8 — at least 80 bytes; also dummy *u8 dest
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function slot_bytes_store_encoders(arena: *u8, type_ref: i32, mod: *u8, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_type_named_name_into(arena, type_ref, cell));
    pipe_store_i32_le(cell, 4, pipeline_module_num_struct_layouts_at(mod));
    pipe_store_i32_le(cell, 8, pipeline_module_struct_layout_name_len(mod, 0));
    pipe_store_i32_le(cell, 12, pipeline_module_struct_layout_name_byte_at(mod, 0, 0));
    // Never store through the *i32 metrics outs (Ubuntu x86_64 SEGV 139).
    pipe_store_i32_le(cell, 16, typeck_typeck_struct_layout_metrics(mod, arena, 0, 0, 0, 0 as *i32, 0 as *i32));
    pipe_store_i32_le(cell, 20, pipeline_module_struct_layout_num_fields(mod, 0));
    pipe_store_i32_le(cell, 24, pipeline_module_struct_layout_field_offset_at(mod, 0, 0));
    pipe_store_i32_le(cell, 28, pipeline_module_struct_layout_field_type_ref(mod, 0, 0));
    pipe_store_i32_le(cell, 32, pipeline_arena_num_types(arena));
    pipe_store_i32_le(cell, 36, pipeline_type_kind_ord_at(arena, type_ref));
    pipe_store_i32_le(cell, 40, pipeline_type_array_size_at(arena, type_ref));
    pipe_store_i32_le(cell, 44, pipeline_type_elem_ref_at(arena, type_ref));
    pipe_store_i32_le(cell, 48, typeck_soa_array_storage_size_glue(pipeline_asm_glue_emit_module_ref(), arena, type_ref, 0, 0));
    pipe_store_i32_le(cell, 52, typeck_x_type_size_from_layout_glue(pipeline_dep_ctx_module_at(pipeline_asm_emit_dep_pipe_c(), 0), pipeline_dep_ctx_arena_at(pipeline_asm_emit_dep_pipe_c(), 0), 0, 0));
    pipe_store_i32_le(cell, 56, pipeline_dep_ctx_ndep(pipeline_asm_emit_dep_pipe_c()));
    pipe_store_i32_le(cell, 60, glue_fixed_array_total_bytes_c(arena, type_ref, 0));
    pipe_store_i32_le(cell, 64, glue_type_size_simple(pipeline_asm_glue_emit_module_ref(), arena, type_ref, 0));
    pipe_store_i32_le(cell, 68, asm_type_is_simd_vector_spelling(arena, type_ref));
    return 0;
  }
}

/**
 * TYPE_NAMED struct layout stack slot bytes in one module.
 * Encoder always runs. Tip returns 0. The w415 overlay still
 * does the real path.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_NAMED type ref
 * @param mod *u8 - Module*; null -> 0
 * @return i32 - 0 on this tip
 * PLATFORM: SHARED freestanding nest ZST · LINUX gold.
 */
function pipe_slot_bytes_named_in_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  unsafe {
    let cell: u8[80] = [];
    slot_bytes_store_encoders(arena, type_ref, mod, &cell[0]);
    return 0;
  }
}

/**
 * T[N] fixed array total bytes: SoA storage or AoS N*layout (struct elem only).
 * Encoder always runs. Tip returns 0. The w415 overlay still does
 * the real path.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - TYPE_ARRAY type ref
 * @param mod *u8 - Module*; null falls back to emit module
 * @return i32 - 0 on this tip
 * PLATFORM: SHARED freestanding array layout.
 */
#[no_mangle]
export function asm_fixed_array_total_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  unsafe {
    let cell: u8[80] = [];
    let sink: i32 = 0;
    slot_bytes_store_encoders(arena, type_ref, mod, &cell[0]);
    sink = type_ref;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && mod == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}

/**
 * Single const/let stack slot bytes; mod preferred else emit module + dep walk.
 * Encoder always runs. Tip returns 0. The w415 overlay still does
 * the real path.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref; invalid -> 8
 * @param mod *u8 - Module* or null
 * @return i32 - 0 on this tip
 * PLATFORM: SHARED freestanding stack · LINUX gold · MACOS co-path.
 */
function pipe_local_slot_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32 {
  unsafe {
    let cell: u8[80] = [];
    slot_bytes_store_encoders(arena, type_ref, mod, &cell[0]);
    return 0;
  }
}
