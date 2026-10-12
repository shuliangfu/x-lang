// Thin pure: wave309/367b/528 M2 — dep_ctx Cap residual C→.x (was wave272 C thin).
// PipelineDepCtx accessors + DepCtxSidecar×64 BSS; 56 exports.
// G.7: bodies match runtime_pipeline_abi.x wave272 leave.
// PRODUCT inject: wave367b HARD BAN PREFER; wave528 Soft Cap tip T001 heal
//   (unsafe wrap extern calls) + tipU pipe-cell; stamp → w528;
//   tip PRODUCT reinject HARD BAN (keep prior overlay).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_store_i64_zero(base: *u8, off: i32): void;
export extern function grow_vec_init(v: *u8, elem_sz: i64, initial_cap: i32): i32;
export extern function grow_vec_free(v: *u8): void;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_push(v: *u8): i32;
export extern function grow_vec_copy_append(dst: *u8, src: *u8): void;
export extern function pipe_gv_init_cap(): i32;
export extern function pipe_gv_load_len(v: *u8): i32;
export extern function pipe_gv_store_len(v: *u8, n: i32): void;
export extern function xlang_size_slot_set(arr: *u8, i: i32, v: i64): void;
export extern "C" function driver_check_only_get(): i32;
export extern "C" function free(p: *u8): void;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;


/**
 * pipe_load_i32_le via unsafe (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * pipe_store_i32_le via unsafe (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * pipe_load_ptr_slot via unsafe (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_load_ptr(base: *u8, i: i32): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, i);
  }
}

/**
 * pipe_store_ptr_slot via unsafe (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_store_ptr(base: *u8, i: i32, val: *u8): void {
  unsafe {
    pipe_store_ptr_slot(base, i, val);
  }
}

/**
 * pipe_store_i64_zero via unsafe (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_store_i64_zero(base: *u8, off: i32): void {
  unsafe {
    pipe_store_i64_zero(base, off);
  }
}

/**
 * grow_vec_init via pipe-cell (T001 + tipU mid-call). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_gv_init(v: *u8, elem_sz: i64, initial_cap: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, grow_vec_init(v, elem_sz, initial_cap));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * grow_vec_free (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_gv_free(v: *u8): void {
  unsafe {
    grow_vec_free(v);
  }
}

/**
 * grow_vec_at via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_gv_at(v: *u8, idx: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, grow_vec_at(v, idx));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

/**
 * grow_vec_push via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_gv_push(v: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, grow_vec_push(v));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * grow_vec_copy_append (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_gv_copy_append(dst: *u8, src: *u8): void {
  unsafe {
    grow_vec_copy_append(dst, src);
  }
}

/**
 * pipe_gv_init_cap via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_gv_init_cap(): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipe_gv_init_cap());
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipe_gv_load_len via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_gv_load_len(v: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipe_gv_load_len(v));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipe_gv_store_len (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_gv_store_len(v: *u8, n: i32): void {
  unsafe {
    pipe_gv_store_len(v, n);
  }
}

/**
 * xlang_size_slot_set (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_size_slot_set(arr: *u8, i: i32, v: i64): void {
  unsafe {
    xlang_size_slot_set(arr, i, v);
  }
}

/**
 * driver_check_only_get via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_driver_check_only_get(): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, driver_check_only_get());
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * free (T001). PLATFORM: SHARED Soft Cap tip heal (wave528).
 */
function w528_free(p: *u8): void {
  unsafe {
    free(p);
  }
}

/**
 * memcpy via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, memcpy(dst, src, n));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

/**
 * memset via pipe-cell (T001 + tipU). PLATFORM: SHARED Soft Cap (wave528).
 */
function w528_memset(dst: *u8, c: i32, n: usize): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, memset(dst, c, n));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

function pipe_dep_sc_size(): i32 { return 272; }
function pipe_dep_sc_max(): i32 { return 64; }
function pipe_dep_sc_off_ctx(): i32 { return 0; }
function pipe_dep_sc_off_used(): i32 { return 8; }
function pipe_dep_sc_off_dep_modules(): i32 { return 16; }
function pipe_dep_sc_off_dep_arenas(): i32 { return 48; }
function pipe_dep_sc_off_dep_path_rows(): i32 { return 80; }
function pipe_dep_sc_off_dep_path_lens(): i32 { return 112; }
function pipe_dep_sc_off_lib_root_rows(): i32 { return 144; }
function pipe_dep_sc_off_lib_root_lens(): i32 { return 176; }
function pipe_dep_sc_off_empty_param_indices(): i32 { return 208; }
function pipe_dep_sc_off_empty_param_backup(): i32 { return 240; }

// PipelineDepCtx field offsets (LP64) — match pure pipe_pctx_off_* where present.
function pipe_pctx_off_ndep(): i32 { return 0; }
function pipe_pctx_off_path_buf(): i32 { return 524; }
function pipe_pctx_off_loaded_buf(): i32 { return 1036; }
function pipe_pctx_off_preprocess_buf(): i32 { return 4195352; }
function pipe_pctx_off_use_asm_backend(): i32 { return 8389660; }
function pipe_pctx_off_target_arch(): i32 { return 8389664; }
function pipe_pctx_off_use_macho_o(): i32 { return 8389672; }
function pipe_pctx_off_use_coff_o(): i32 { return 8389676; }
function pipe_pctx_off_current_block_ref(): i32 { return 8389680; }
function pipe_pctx_off_typeck_loop_depth(): i32 { return 8389684; }
function pipe_pctx_off_current_func_index(): i32 { return 8389688; }
function pipe_pctx_off_entry_already_parsed(): i32 { return 8389696; }
function pipe_pctx_off_current_func_empty_param_count(): i32 { return 8389704; }
function pipe_pctx_off_current_codegen_module(): i32 { return 8389720; }
function pipe_pctx_off_current_codegen_arena(): i32 { return 8389728; }
function pipe_pctx_off_current_codegen_dep_index(): i32 { return 8389736; }
function pipe_pctx_off_current_codegen_prefix_mirror(): i32 { return 8389740; }
function pipe_pctx_off_current_codegen_prefix_len(): i32 { return 8389996; }
function pipe_pctx_off_asm_entry_module_only(): i32 { return 8390000; }


// Offsets defined outside wave272 leave in mega (shared helpers) — inlined
// here so the thin is self-contained under -E+$CC. Values match mega.
function pipe_pctx_off_entry_dir_buf(): i32 { return 4; }
function pipe_pctx_off_entry_dir_len(): i32 { return 516; }
function pipe_pctx_off_num_lib_roots(): i32 { return 520; }
function pipe_pctx_off_loaded_len(): i32 { return 4195344; }
function pipe_pctx_off_preprocess_len(): i32 { return 8389656; }


/** Byte size of PipelineDepCtx (Cap 4.2.8 name mirrors [256]). PLATFORM: SHARED LP64. */
export function pipeline_sizeof_dep_ctx(): usize {
  return 8390600 as usize;
}


// Flat BSS table: 64 * 272 = 17408 bytes. Zero-initialized; used flags start 0.
let g_pipe_dep_sc_blob: u8[17408] = [];

/**
 * Pointer to DepCtxSidecar slot i (0..63).
 * @param i i32 - slot index
 * @return *u8 - sidecar base or null if i out of range
 * PLATFORM: SHARED freestanding DepCtx table.
 */
function pipe_dep_sc_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= pipe_dep_sc_max()) {
    return 0 as *u8;
  }
  let off: i64 = (i as i64) * (pipe_dep_sc_size() as i64);
  return &g_pipe_dep_sc_blob[0] + (off as usize);
}

/**
 * GrowVec* field inside a DepCtxSidecar at given byte offset.
 * @param sc *u8 - sidecar base
 * @param field_off i32 - offset of GrowVec within sidecar
 * @return *u8 - GrowVec* or null
 */
function pipe_dep_sc_gv(sc: *u8, field_off: i32): *u8 {
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  if (field_off < 0) {
    return 0 as *u8;
  }
  return sc + (field_off as usize);
}

/**
 * Free all GrowVecs in a DepCtxSidecar and zero the slot.
 * wave528 Soft Cap: Cap-T001 whole-body unsafe (extern grow_vec_free/memset).
 * PLATFORM: SHARED Soft Cap tip heal.
 */
function pipe_dep_sc_free(sc: *u8): void {
  if (sc == 0 as *u8) {
    return;
  }
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices()));
  w528_gv_free(pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_backup()));
  w528_memset(sc, 0, pipe_dep_sc_size() as usize);
}

/**
 * Lookup or create DepCtxSidecar for PipelineDepCtx key.
 * @param ctx *u8 - PipelineDepCtx*; null -> null
 * @param create i32 - non-zero to allocate free slot + init GrowVecs
 * @return *u8 - sidecar or null
 * G.7 single process table (was residual g_xlang_depctx_sc + depctx_sidecar_get).
 * PLATFORM: SHARED freestanding DepCtx table — product matrix dual-end.
 */
function pipe_depctx_sidecar_get(ctx: *u8, create: i32): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  let i: i32 = 0;
  while (i < pipe_dep_sc_max()) {
    let sc: *u8 = pipe_dep_sc_at(i);
    let used: i32 = w528_load_i32(sc, pipe_dep_sc_off_used());
    if (used != 0) {
      let k: *u8 = w528_load_ptr(sc, 0);
      if (k == ctx) {
        return sc;
      }
    }
    i = i + 1;
  }
  if (create == 0) {
    return 0 as *u8;
  }
  i = 0;
  while (i < pipe_dep_sc_max()) {
    let sc2: *u8 = pipe_dep_sc_at(i);
    let used2: i32 = w528_load_i32(sc2, pipe_dep_sc_off_used());
    if (used2 == 0) {
      // bind key + mark used before init so partial fail can free
      w528_store_ptr(sc2, 0, ctx);
      w528_store_i32(sc2, pipe_dep_sc_off_used(), 1);
      let ic: i32 = w528_gv_init_cap();
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_modules()), 8, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_arenas()), 8, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      // path rows: 128-byte elems (wave579)
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_path_rows()), 256, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_dep_path_lens()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      // lib_root rows: 256-byte elems
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_lib_root_rows()), 256, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_lib_root_lens()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_empty_param_indices()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      if (w528_gv_init(pipe_dep_sc_gv(sc2, pipe_dep_sc_off_empty_param_backup()), 4, ic) == 0) {
        pipe_dep_sc_free(sc2);
        return 0 as *u8;
      }
      return sc2;
    }
    i = i + 1;
  }
  return 0 as *u8;
}

/**
 * Ensure dep slot pools have at least idx+1 entries (modules/arenas/paths).
 * @param sc *u8 - DepCtxSidecar*
 * @param idx i32 - required index
 * @return i32 - 1 ok, 0 fail
 */
function pipe_depctx_ensure_slot(sc: *u8, idx: i32): i32 {
  if (sc == 0 as *u8) {
    return 0;
  }
  if (idx < 0) {
    return 0;
  }
  let need: i32 = idx + 1;
  let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
  let ars: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas());
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens());
  while (w528_gv_load_len(mods) < need) {
    if (w528_gv_push(mods) < 0) {
      return 0;
    }
    let pm: *u8 = w528_gv_at(mods, w528_gv_load_len(mods) - 1);
    if (pm != 0 as *u8) {
      w528_store_ptr(pm, 0, 0 as *u8);
    }
    if (w528_gv_push(ars) < 0) {
      return 0;
    }
    let pa: *u8 = w528_gv_at(ars, w528_gv_load_len(ars) - 1);
    if (pa != 0 as *u8) {
      w528_store_ptr(pa, 0, 0 as *u8);
    }
    if (w528_gv_push(rows) < 0) {
      return 0;
    }
    let row: *u8 = w528_gv_at(rows, w528_gv_load_len(rows) - 1);
    if (row != 0 as *u8) {
      unsafe {
        w528_memset(row, 0, 128 as usize);
      }
    }
    if (w528_gv_push(lens) < 0) {
      return 0;
    }
    let pl: *u8 = w528_gv_at(lens, w528_gv_load_len(lens) - 1);
    if (pl != 0 as *u8) {
      w528_store_i32(pl, 0, 0);
    }
  }
  return 1;
}

/**
 * Release process-wide DepCtx sidecar for this PipelineDepCtx pointer.
 * @param ctx *u8 - PipelineDepCtx*; null -> no-op
 * @return void
 * Call before w528_free(ctx). G.7 single teardown for batch check (wave1228).
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_sidecar_release(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < pipe_dep_sc_max()) {
    let sc: *u8 = pipe_dep_sc_at(i);
    let used: i32 = w528_load_i32(sc, pipe_dep_sc_off_used());
    if (used != 0) {
      let k: *u8 = w528_load_ptr(sc, 0);
      if (k == ctx) {
        pipe_dep_sc_free(sc);
        return;
      }
    }
    i = i + 1;
  }
}


/**
 * Reset dep / lib_root GrowVec lens and header ndep / num_lib_roots.
 * @param ctx *u8 - PipelineDepCtx*
 * @return void
 * wave272 pure-owned leave (was pipeline_dep_ctx_reset).
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_reset(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc != 0 as *u8) {
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules()), 0);
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas()), 0);
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows()), 0);
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens()), 0);
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows()), 0);
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens()), 0);
  }
  w528_store_i32(ctx, pipe_pctx_off_ndep(), 0);
  w528_store_i32(ctx, pipe_pctx_off_num_lib_roots(), 0);
}

/**
 * Set dep module pointer at idx (create slot if needed).
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32 - dep index; <0 ignored
 * @param m *u8 - Module* (may be null)
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_module(ctx: *u8, idx: i32, m: *u8): void {
  if (ctx == 0 as *u8 || idx < 0) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return;
  }
  if (pipe_depctx_ensure_slot(sc, idx) == 0) {
    return;
  }
  let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
  let pm: *u8 = w528_gv_at(mods, idx);
  if (pm != 0 as *u8) {
    w528_store_ptr(pm, 0, m);
  }
  let nd: i32 = w528_load_i32(ctx, pipe_pctx_off_ndep());
  if (idx + 1 > nd) {
    w528_store_i32(ctx, pipe_pctx_off_ndep(), idx + 1);
  }
}

/**
 * Set dep arena pointer at idx.
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @param a *u8 - ASTArena*
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_arena(ctx: *u8, idx: i32, a: *u8): void {
  if (ctx == 0 as *u8 || idx < 0) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return;
  }
  if (pipe_depctx_ensure_slot(sc, idx) == 0) {
    return;
  }
  let ars: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas());
  let pa: *u8 = w528_gv_at(ars, idx);
  if (pa != 0 as *u8) {
    w528_store_ptr(pa, 0, a);
  }
}

/**
 * Read dep Module* at idx.
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @return *u8 - Module* or null
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8 {
  if (ctx == 0 as *u8 || idx < 0) {
    return 0 as *u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
  if (idx >= w528_gv_load_len(mods)) {
    return 0 as *u8;
  }
  let pm: *u8 = w528_gv_at(mods, idx);
  if (pm == 0 as *u8) {
    return 0 as *u8;
  }
  return w528_load_ptr(pm, 0);
}

/**
 * Read dep ASTArena* at idx.
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @return *u8 - ASTArena* or null
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8 {
  if (ctx == 0 as *u8 || idx < 0) {
    return 0 as *u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as *u8;
  }
  let ars: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_arenas());
  if (idx >= w528_gv_load_len(ars)) {
    return 0 as *u8;
  }
  let pa: *u8 = w528_gv_at(ars, idx);
  if (pa == 0 as *u8) {
    return 0 as *u8;
  }
  return w528_load_ptr(pa, 0);
}

/**
 * Store import path bytes for dep idx (cap 127 + NUL in 128-byte row).
 * @param ctx *u8 - PipelineDepCtx*
 * @param idx i32
 * @param bytes *u8 - path bytes
 * @param len i32 - byte count; <=0 ignored
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_import_path(ctx: *u8, idx: i32, bytes: *u8, len: i32): void {
  if (ctx == 0 as *u8 || idx < 0 || bytes == 0 as *u8 || len <= 0) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return;
  }
  if (pipe_depctx_ensure_slot(sc, idx) == 0) {
    return;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens());
  let row: *u8 = w528_gv_at(rows, idx);
  let pl: *u8 = w528_gv_at(lens, idx);
  if (row == 0 as *u8 || pl == 0 as *u8) {
    return;
  }
  let n: i32 = len;
  if (n > 255) {
    n = 255;
  }
  unsafe {
    w528_memset(row, 0, 128 as usize);
    w528_memcpy(row, bytes, n as usize);
  }
  row[n] = 0;
  w528_store_i32(pl, 0, n);
}

/**
 * Import path length at dep idx.
 * @param ctx *u8
 * @param idx i32
 * @return i32 - length or 0
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_import_path_len(ctx: *u8, idx: i32): i32 {
  if (ctx == 0 as *u8 || idx < 0) {
    return 0;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0;
  }
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens());
  if (idx >= w528_gv_load_len(lens)) {
    return 0;
  }
  let pl: *u8 = w528_gv_at(lens, idx);
  if (pl == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(pl, 0);
}

/**
 * Byte at off of dep import path.
 * @param ctx *u8
 * @param idx i32
 * @param off i32
 * @return u8 - byte or 0
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_import_path_byte_at(ctx: *u8, idx: i32, off: i32): u8 {
  if (ctx == 0 as *u8 || idx < 0 || off < 0) {
    return 0 as u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as u8;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens());
  if (idx >= w528_gv_load_len(rows)) {
    return 0 as u8;
  }
  let pl: *u8 = w528_gv_at(lens, idx);
  let row: *u8 = w528_gv_at(rows, idx);
  if (pl == 0 as *u8 || row == 0 as *u8) {
    return 0 as u8;
  }
  let n: i32 = w528_load_i32(pl, 0);
  if (off >= n) {
    return 0 as u8;
  }
  return row[off];
}

/**
 * Copy dep import path into dst (zero first 128 bytes). Historical name copy64.
 * @param ctx *u8
 * @param idx i32
 * @param dst *u8 - caller provides >=128 bytes
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_import_path_copy64(ctx: *u8, idx: i32, dst: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  unsafe {
    w528_memset(dst, 0, 256 as usize);
  }
  if (ctx == 0 as *u8 || idx < 0) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_path_lens());
  if (idx >= w528_gv_load_len(rows)) {
    return;
  }
  let pl: *u8 = w528_gv_at(lens, idx);
  let row: *u8 = w528_gv_at(rows, idx);
  if (pl == 0 as *u8 || row == 0 as *u8) {
    return;
  }
  let n: i32 = w528_load_i32(pl, 0);
  if (n > 255) {
    n = 255;
  }
  let k: i32 = 0;
  while (k < n) {
    dst[k] = row[k];
    k = k + 1;
  }
}

/**
 * Soft-sync ndep from sidecar modules.len if larger; return ndep.
 * @param ctx *u8
 * @return i32 - ndep or 0
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_ndep(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  let nd: i32 = w528_load_i32(ctx, pipe_pctx_off_ndep());
  if (sc != 0 as *u8) {
    let mods: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_dep_modules());
    let ml: i32 = w528_gv_load_len(mods);
    if (ml > nd) {
      w528_store_i32(ctx, pipe_pctx_off_ndep(), ml);
      nd = ml;
    }
  }
  return nd;
}

/**
 * Write ctx.ndep.
 * @param ctx *u8
 * @param n i32 - clamped to >=0
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_ndep(ctx: *u8, n: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let v: i32 = n;
  if (v < 0) {
    v = 0;
  }
  w528_store_i32(ctx, pipe_pctx_off_ndep(), v);
}

/**
 * Read current_codegen_prefix_len.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_codegen_prefix_len(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_current_codegen_prefix_len());
}

/**
 * Read current_codegen_prefix_mirror[off].
 * @param ctx *u8
 * @param off i32
 * @return u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_codegen_prefix_byte_at(ctx: *u8, off: i32): u8 {
  if (ctx == 0 as *u8 || off < 0) {
    return 0 as u8;
  }
  let n: i32 = w528_load_i32(ctx, pipe_pctx_off_current_codegen_prefix_len());
  if (off >= n || off >= 64) {
    return 0 as u8;
  }
  let base: *u8 = ctx + (pipe_pctx_off_current_codegen_prefix_mirror() as usize);
  return base[off];
}

/**
 * Copy prefix_mirror into dst (NUL-terminated, max cap-1).
 * @param ctx *u8
 * @param dst *u8
 * @param cap i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_codegen_prefix_copy(ctx: *u8, dst: *u8, cap: i32): void {
  if (ctx == 0 as *u8 || dst == 0 as *u8 || cap <= 0) {
    return;
  }
  let n: i32 = w528_load_i32(ctx, pipe_pctx_off_current_codegen_prefix_len());
  if (n >= cap) {
    n = cap - 1;
  }
  let base: *u8 = ctx + (pipe_pctx_off_current_codegen_prefix_mirror() as usize);
  let k: i32 = 0;
  while (k < n) {
    dst[k] = base[k];
    k = k + 1;
  }
  dst[n] = 0;
}

/**
 * Write current_codegen_prefix_mirror + len (max 127).
 * @param ctx *u8
 * @param bytes *u8
 * @param len i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_codegen_prefix_mirror(ctx: *u8, bytes: *u8, len: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let n: i32 = len;
  if (n > 255) {
    n = 255;
  }
  if (n < 0) {
    n = 0;
  }
  w528_store_i32(ctx, pipe_pctx_off_current_codegen_prefix_len(), 0);
  let base: *u8 = ctx + (pipe_pctx_off_current_codegen_prefix_mirror() as usize);
  let k: i32 = 0;
  while (k < n) {
    if (bytes != 0 as *u8) {
      base[k] = bytes[k];
    } else {
      base[k] = 0 as u8;
    }
    k = k + 1;
  }
  base[n] = 0;
  w528_store_i32(ctx, pipe_pctx_off_current_codegen_prefix_len(), n);
}

/**
 * Return path_buf base pointer.
 * @param ctx *u8
 * @return *u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_path_buf_ptr(ctx: *u8): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  return ctx + (pipe_pctx_off_path_buf() as usize);
}

/**
 * path_buf[off] read.
 * @param ctx *u8
 * @param off i32
 * @return u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_path_buf_byte_at(ctx: *u8, off: i32): u8 {
  if (ctx == 0 as *u8 || off < 0 || off >= 512) {
    return 0 as u8;
  }
  let base: *u8 = ctx + (pipe_pctx_off_path_buf() as usize);
  return base[off];
}

/**
 * path_buf[off] write.
 * @param ctx *u8
 * @param off i32
 * @param b u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_path_buf_byte(ctx: *u8, off: i32, b: u8): void {
  if (ctx == 0 as *u8 || off < 0 || off >= 512) {
    return;
  }
  let base: *u8 = ctx + (pipe_pctx_off_path_buf() as usize);
  base[off] = b;
}

/**
 * entry_dir_len read.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_entry_dir_len(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_entry_dir_len());
}

/**
 * Copy entry_dir_buf into dst (NUL-terminated).
 * @param ctx *u8
 * @param dst *u8
 * @param cap i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_entry_dir_copy(ctx: *u8, dst: *u8, cap: i32): void {
  if (ctx == 0 as *u8 || dst == 0 as *u8 || cap <= 0) {
    return;
  }
  let n: i32 = w528_load_i32(ctx, pipe_pctx_off_entry_dir_len());
  if (n >= cap) {
    n = cap - 1;
  }
  let base: *u8 = ctx + (pipe_pctx_off_entry_dir_buf() as usize);
  let k: i32 = 0;
  while (k < n) {
    dst[k] = base[k];
    k = k + 1;
  }
  dst[n] = 0;
}

/**
 * Ensure source buffers present (embedded in ctx; always ok if non-null).
 * @param ctx *u8
 * @return i32 - 0 ok, -1 null
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_ensure_source_buffers(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Clear loaded_len / preprocess_len (embedded buffers; no free).
 * @param ctx *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_free_source_buffers(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  w528_store_i64_zero(ctx, pipe_pctx_off_loaded_len());
  w528_store_i32(ctx, pipe_pctx_off_preprocess_len(), 0);
}

/**
 * Release sidecar + clear lens + w528_free(ctx) for heap-allocated PipelineDepCtx.
 * @param ctx *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_heap_destroy(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  pipeline_dep_ctx_sidecar_release(ctx);
  pipeline_dep_ctx_free_source_buffers(ctx);
  // free is export extern "C" — typeck T001 requires unsafe for extern calls.
  unsafe {
    w528_free(ctx);
  }
}

/**
 * loaded_buf base.
 * @param ctx *u8
 * @return *u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_loaded_buf_ptr(ctx: *u8): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  return ctx + (pipe_pctx_off_loaded_buf() as usize);
}

/**
 * preprocess_buf base.
 * @param ctx *u8
 * @return *u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_preprocess_buf_ptr(ctx: *u8): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  return ctx + (pipe_pctx_off_preprocess_buf() as usize);
}

/**
 * Store loaded_len (i64 / ptrdiff_t).
 * @param ctx *u8
 * @param n i64
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_loaded_len(ctx: *u8, n: i64): void {
  if (ctx == 0 as *u8) {
    return;
  }
  // loaded_len at offset 4195344 = size_t slot index 524418
  w528_size_slot_set(ctx, 524418, n);
}

/**
 * entry_already_parsed flag.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_entry_already_parsed(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_entry_already_parsed());
}

/**
 * asm_entry_module_only flag.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_asm_entry_module_only(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_asm_entry_module_only());
}

/**
 * xlang check mode from driver slot (ctx unused).
 * @param ctx *u8 - ignored
 * @return i32 - driver_check_only_get
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_check_only_mode(ctx: *u8): i32 {
  let _c: *u8 = ctx;
  let co: i32 = 0;
  // driver_check_only_get is export extern "C" — T001 requires unsafe.
  unsafe {
    co = w528_driver_check_only_get();
  }
  return co;
}

/**
 * use_asm_backend flag.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_use_asm_backend(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_use_asm_backend());
}

/**
 * use_macho_o flag.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_use_macho_o(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_use_macho_o());
}

/**
 * use_coff_o flag.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_use_coff_o(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_use_coff_o());
}

/**
 * target_arch field.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_target_arch(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_target_arch());
}

/**
 * entry_dir_buf[off].
 * @param ctx *u8
 * @param off i32
 * @return u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_entry_dir_byte_at(ctx: *u8, off: i32): u8 {
  if (ctx == 0 as *u8 || off < 0) {
    return 0 as u8;
  }
  let n: i32 = w528_load_i32(ctx, pipe_pctx_off_entry_dir_len());
  if (off >= n || off >= 512) {
    return 0 as u8;
  }
  let base: *u8 = ctx + (pipe_pctx_off_entry_dir_buf() as usize);
  return base[off];
}

/**
 * current_codegen_dep_index (-1 if null).
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_current_codegen_dep_index(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  return w528_load_i32(ctx, pipe_pctx_off_current_codegen_dep_index());
}

/**
 * current_codegen_module pointer.
 * @param ctx *u8
 * @return *u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_current_codegen_module(ctx: *u8): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  // offset 8389720 / 8 = slot 1048715
  return w528_load_ptr(ctx + (pipe_pctx_off_current_codegen_module() as usize), 0);
}

/**
 * current_codegen_arena pointer.
 * @param ctx *u8
 * @return *u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_current_codegen_arena(ctx: *u8): *u8 {
  if (ctx == 0 as *u8) {
    return 0 as *u8;
  }
  return w528_load_ptr(ctx + (pipe_pctx_off_current_codegen_arena() as usize), 0);
}

/**
 * current_func_index (-1 if null).
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_current_func_index(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  return w528_load_i32(ctx, pipe_pctx_off_current_func_index());
}

/**
 * current_block_ref (0 if null).
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_current_block_ref_at(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_current_block_ref());
}

/**
 * Set current_codegen_module.
 * @param ctx *u8
 * @param m *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_current_codegen_module(ctx: *u8, m: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  w528_store_ptr(ctx + (pipe_pctx_off_current_codegen_module() as usize), 0, m);
}

/**
 * Set current_codegen_arena.
 * @param ctx *u8
 * @param a *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_current_codegen_arena(ctx: *u8, a: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  w528_store_ptr(ctx + (pipe_pctx_off_current_codegen_arena() as usize), 0, a);
}

/**
 * Set current_codegen_dep_index.
 * @param ctx *u8
 * @param ix i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_current_codegen_dep_index(ctx: *u8, ix: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  w528_store_i32(ctx, pipe_pctx_off_current_codegen_dep_index(), ix);
}

/**
 * Set current_func_index.
 * @param ctx *u8
 * @param ix i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_set_current_func_index(ctx: *u8, ix: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  w528_store_i32(ctx, pipe_pctx_off_current_func_index(), ix);
}

/**
 * Append -L lib_root path (256-byte row, max 255 bytes).
 * @param ctx *u8
 * @param path *u8
 * @param len i32
 * @return i32 - new index or -1
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_ctx_append_lib_root(ctx: *u8, path: *u8, len: i32): i32 {
  if (ctx == 0 as *u8 || path == 0 as *u8 || len <= 0) {
    return 0 - 1;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return 0 - 1;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens());
  let idx: i32 = w528_gv_push(rows);
  if (idx < 0) {
    return 0 - 1;
  }
  if (w528_gv_push(lens) < 0) {
    return 0 - 1;
  }
  let row: *u8 = w528_gv_at(rows, idx);
  let pl: *u8 = w528_gv_at(lens, idx);
  if (row == 0 as *u8 || pl == 0 as *u8) {
    return 0 - 1;
  }
  let n: i32 = len;
  if (n > 255) {
    n = 255;
  }
  unsafe {
    w528_memset(row, 0, 256 as usize);
    w528_memcpy(row, path, n as usize);
  }
  w528_store_i32(pl, 0, n);
  w528_store_i32(ctx, pipe_pctx_off_num_lib_roots(), w528_gv_load_len(rows));
  return idx;
}

/**
 * lib_root count from sidecar (0 if none).
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_ctx_lib_root_count(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0;
  }
  return w528_gv_load_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows()));
}

/**
 * lib_root path length at i.
 * @param ctx *u8
 * @param i i32
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_ctx_lib_root_len(ctx: *u8, i: i32): i32 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0;
  }
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens());
  if (i >= w528_gv_load_len(lens)) {
    return 0;
  }
  let pl: *u8 = w528_gv_at(lens, i);
  if (pl == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(pl, 0);
}

/**
 * Copy lib_root path i into dst.
 * @param ctx *u8
 * @param i i32
 * @param dst *u8
 * @param cap i32
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_ctx_lib_root_copy(ctx: *u8, i: i32, dst: *u8, cap: i32): void {
  if (dst == 0 as *u8 || cap <= 0) {
    return;
  }
  unsafe {
    w528_memset(dst, 0, cap as usize);
  }
  if (ctx == 0 as *u8 || i < 0) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens());
  if (i >= w528_gv_load_len(rows)) {
    return;
  }
  let pl: *u8 = w528_gv_at(lens, i);
  let row: *u8 = w528_gv_at(rows, i);
  if (pl == 0 as *u8 || row == 0 as *u8) {
    return;
  }
  let n: i32 = w528_load_i32(pl, 0);
  if (n >= cap) {
    n = cap - 1;
  }
  let k: i32 = 0;
  while (k < n) {
    dst[k] = row[k];
    k = k + 1;
  }
}

/**
 * lib_root path byte at (i, off).
 * @param ctx *u8
 * @param i i32
 * @param off i32
 * @return u8
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_ctx_lib_root_byte_at(ctx: *u8, i: i32, off: i32): u8 {
  if (ctx == 0 as *u8 || i < 0 || off < 0) {
    return 0 as u8;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 as u8;
  }
  let rows: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_rows());
  let lens: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_lib_root_lens());
  if (i >= w528_gv_load_len(rows)) {
    return 0 as u8;
  }
  let pl: *u8 = w528_gv_at(lens, i);
  let row: *u8 = w528_gv_at(rows, i);
  if (pl == 0 as *u8 || row == 0 as *u8) {
    return 0 as u8;
  }
  let n: i32 = w528_load_i32(pl, 0);
  if (off >= n) {
    return 0 as u8;
  }
  return row[off];
}

/**
 * Reset empty-param index pool + header count.
 * @param ctx *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_empty_param_reset(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc != 0 as *u8) {
    w528_gv_store_len(pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices()), 0);
  }
  w528_store_i32(ctx, pipe_pctx_off_current_func_empty_param_count(), 0);
}

/**
 * Append empty-param index pi.
 * @param ctx *u8
 * @param pi i32
 * @return i32 - new index or -1
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_empty_param_append(ctx: *u8, pi: i32): i32 {
  if (ctx == 0 as *u8) {
    return 0 - 1;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return 0 - 1;
  }
  let idxv: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices());
  if (w528_gv_push(idxv) < 0) {
    return 0 - 1;
  }
  let slot: *u8 = w528_gv_at(idxv, w528_gv_load_len(idxv) - 1);
  if (slot == 0 as *u8) {
    return 0 - 1;
  }
  w528_store_i32(slot, 0, pi);
  let n: i32 = w528_gv_load_len(idxv);
  w528_store_i32(ctx, pipe_pctx_off_current_func_empty_param_count(), n);
  return n - 1;
}

/**
 * empty-param index at i (-1 if OOB).
 * @param ctx *u8
 * @param i i32
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_empty_param_at(ctx: *u8, i: i32): i32 {
  if (ctx == 0 as *u8 || i < 0) {
    return 0 - 1;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return 0 - 1;
  }
  let idxv: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices());
  if (i >= w528_gv_load_len(idxv)) {
    return 0 - 1;
  }
  let slot: *u8 = w528_gv_at(idxv, i);
  if (slot == 0 as *u8) {
    return 0 - 1;
  }
  return w528_load_i32(slot, 0);
}

/**
 * Backup empty-param indices into backup GrowVec.
 * @param ctx *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_empty_param_backup(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 1);
  if (sc == 0 as *u8) {
    return;
  }
  let bak: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_backup());
  let idxv: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices());
  w528_gv_store_len(bak, 0);
  w528_gv_copy_append(bak, idxv);
}

/**
 * Restore empty-param indices from backup.
 * @param ctx *u8
 * @return void
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_empty_param_restore(ctx: *u8): void {
  if (ctx == 0 as *u8) {
    return;
  }
  let sc: *u8 = pipe_depctx_sidecar_get(ctx, 0);
  if (sc == 0 as *u8) {
    return;
  }
  let bak: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_backup());
  let idxv: *u8 = pipe_dep_sc_gv(sc, pipe_dep_sc_off_empty_param_indices());
  w528_gv_store_len(idxv, 0);
  w528_gv_copy_append(idxv, bak);
  w528_store_i32(ctx, pipe_pctx_off_current_func_empty_param_count(), w528_gv_load_len(idxv));
}

/**
 * typeck_loop_depth field read.
 * @param ctx *u8
 * @return i32
 * wave272 pure-owned leave.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */
#[no_mangle]
export function pipeline_dep_ctx_typeck_loop_depth_at(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return w528_load_i32(ctx, pipe_pctx_off_typeck_loop_depth());
}
