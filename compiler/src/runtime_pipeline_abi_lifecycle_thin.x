// Thin pure: wave522 M2 — lifecycle release peers (peer-flat Soft Cap).
// Ubuntu tip CG002 when reset/release/block/drop share one tip TU
// (num_funcs≈27). Release trio lives here; reset/block/drop are peer leaves.
// tipU: pipe-cell mid `sc=call()` (ban mid `x=call()` starve).
// G.7: freestanding twin of historic w320/334 lifecycle release surface.
// PRODUCT: cold PREFER inject with peers; stamp w522 HARD BAN tip reinject.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function arena_sidecar_free(sc: *u8): void;
export extern function module_sidecar_get(key: *u8, create: i32): *u8;
export extern function module_sidecar_free(sc: *u8): void;
export extern function pipeline_module_import_storage_release(m: *u8): void;
export extern function pipeline_module_type_alias_storage_release(m: *u8): void;
export extern function pipeline_module_enum_storage_release(m: *u8): void;
export extern function pipeline_module_top_level_let_storage_release(m: *u8): void;
export extern function pipeline_module_struct_layout_storage_release(m: *u8): void;
export extern function onefunc_sidecar_get(out: *u8, create: i32): *u8;
export extern function onefunc_sidecar_free(sc: *u8): void;

/**
 * Release arena sidecar for pool arena `a` (null-safe).
 * pipe-cell holds sidecar pointer across free (tipU mid-call ban).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_arena_release(a: *u8): void {
  let scell: u8[8] = [];
  if (a == (0 as *u8)) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, arena_sidecar_get(a, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) != (0 as *u8)) {
      arena_sidecar_free(pipe_load_ptr_slot(&scell[0], 0));
    }
  }
}

/**
 * Release module import/type/enum/let/layout storage then module sidecar.
 * Null `m` is a no-op. PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_module_release(m: *u8): void {
  let scell: u8[8] = [];
  if (m == (0 as *u8)) { return; }
  unsafe {
    pipeline_module_import_storage_release(m);
    pipeline_module_type_alias_storage_release(m);
    pipeline_module_enum_storage_release(m);
    pipeline_module_top_level_let_storage_release(m);
    pipeline_module_struct_layout_storage_release(m);
    pipe_store_ptr_slot(&scell[0], 0, module_sidecar_get(m, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) != (0 as *u8)) {
      module_sidecar_free(pipe_load_ptr_slot(&scell[0], 0));
    }
  }
}

/**
 * Release onefunc sidecar for `out` (null-safe).
 * PLATFORM: SHARED freestanding Cap leave.
 */
#[no_mangle]
export function ast_pool_onefunc_release(out: *u8): void {
  let scell: u8[8] = [];
  if (out == (0 as *u8)) { return; }
  unsafe {
    pipe_store_ptr_slot(&scell[0], 0, onefunc_sidecar_get(out, 0));
    if (pipe_load_ptr_slot(&scell[0], 0) != (0 as *u8)) {
      onefunc_sidecar_free(pipe_load_ptr_slot(&scell[0], 0));
    }
  }
}
