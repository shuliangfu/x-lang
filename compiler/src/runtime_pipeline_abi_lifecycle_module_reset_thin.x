// Thin pure: wave522 M2 — lifecycle module_reset peer (peer-flat Soft Cap).
// Alone tipU-green; combining with arena/onefunc reset → Ubuntu tip CG002.
// tipU: pipe-cell mid sidecar get; clear GrowVec.len slots then storage reset.
// G.7: freestanding twin of historic w320 ast_pool_module_reset.
// PRODUCT: cold PREFER inject with lifecycle peers; stamp w522 HARD BAN.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function module_sidecar_get(key: *u8, create: i32): *u8;
export extern function pipeline_module_struct_layout_storage_reset(m: *u8): void;
export extern function pipeline_module_top_level_let_storage_reset(m: *u8): void;
export extern function pipeline_module_type_alias_storage_reset(m: *u8): void;
export extern function pipeline_module_enum_storage_reset(m: *u8): void;

const GV_LEN_OFF: i32 = 12;

/**
 * Reset module sidecar GrowVec lens and module storage tables for `m`.
 * Null / missing sidecar → no-op. PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_module_reset(m: *u8): void {
  let scell: u8[8] = [];
  if (m == (0 as *u8)) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, module_sidecar_get(m, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) == (0 as *u8)) { return; }
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (16 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (48 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (80 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (112 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (144 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (176 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (208 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (240 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (272 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (304 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (336 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (368 as usize), GV_LEN_OFF, 0);
    pipe_store_i32_le(pipe_load_ptr_slot(&scell[0], 0) + (400 as usize), GV_LEN_OFF, 0);
    pipeline_module_struct_layout_storage_reset(m);
    pipeline_module_top_level_let_storage_reset(m);
    pipeline_module_type_alias_storage_reset(m);
    pipeline_module_enum_storage_reset(m);
  }
}
