// Thin pure: wave320/334 M2 — lifecycle Cap residual C→.x (was wave279 C thin).
// block_on_alloc / module|arena reset|release / drop_bodies / onefunc reset|release.
// G.7: bodies match runtime_pipeline_abi_lifecycle_thin.c / seed WAVE279.
// PRODUCT inject: wave334 PREFER_ASM via pipeline_abi_inject_lifecycle_thin
// (ALLOW_E_REPLACE + stamp). No BSS; no local fixed arrays; pipe helpers
// T001-unsafe (was -E+$CC interim). Sidecar LE offs match sidecar_pool_thin.x.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function arena_sidecar_free(sc: *u8): void;
export extern function module_sidecar_get(key: *u8, create: i32): *u8;
export extern function module_sidecar_free(sc: *u8): void;
export extern function onefunc_sidecar_get(out: *u8, create: i32): *u8;
export extern function onefunc_sidecar_free(sc: *u8): void;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_free(v: *u8): void;
export extern function pipeline_module_type_alias_storage_reset(m: *u8): void;
export extern function pipeline_module_enum_storage_reset(m: *u8): void;
export extern function pipeline_module_top_level_let_storage_reset(m: *u8): void;
export extern function pipeline_module_struct_layout_storage_reset(m: *u8): void;
export extern function pipeline_module_import_storage_release(m: *u8): void;
export extern function pipeline_module_type_alias_storage_release(m: *u8): void;
export extern function pipeline_module_enum_storage_release(m: *u8): void;
export extern function pipeline_module_top_level_let_storage_release(m: *u8): void;
export extern function pipeline_module_struct_layout_storage_release(m: *u8): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

#[cfg(target_os = "macos")]
export extern "C" function malloc_default_zone(): *u8;
#[cfg(target_os = "macos")]
export extern "C" function malloc_zone_pressure_relief(zone: *u8, goal: usize): usize;
#[cfg(target_os = "linux")]
export extern "C" function malloc_trim(pad: usize): i32;

const W320_FUNC_BODY_REF_OFF: i32 = 148;
const W320_FUNC_BODY_EXPR_REF_OFF: i32 = 152;
const W320_BLOCK_SZ: i32 = 92;
const W320_GV_LEN_OFF: i32 = 12;

/**
 * Load i32 LE from base+off.
 * @param base *u8
 * @param off i32
 * @return i32
 */
function w320_load_i32(base: *u8, off: i32): i32 {
  let v: i32 = 0;
  unsafe {
    v = pipe_load_i32_le(base, off);
  }
  return v;
}

/**
 * Store i32 LE at base+off.
 * @param base *u8
 * @param off i32
 * @param v i32
 */
function w320_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * GrowVec.len at sidecar+gv_off.
 * @param sc *u8
 * @param gv_off i32
 * @return i32
 */
function w320_gv_len(sc: *u8, gv_off: i32): i32 {
  let v: i32 = 0;
  unsafe {
    v = pipe_load_i32_le(sc + (gv_off as usize), W320_GV_LEN_OFF);
  }
  return v;
}

/**
 * Clear GrowVec.len at sidecar+gv_off.
 * @param sc *u8
 * @param gv_off i32
 */
function w320_gv_clear_len(sc: *u8, gv_off: i32): void {
  unsafe {
    pipe_store_i32_le(sc + (gv_off as usize), W320_GV_LEN_OFF, 0);
  }
}

/**
 * Module Func row pointer.
 * @param m *u8
 * @param idx i32
 * @return *u8
 */
function w320_module_func_at(m: *u8, idx: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let n: i32 = 0;
  let flen: i32 = 0;
  if (m == (0 as *u8) || idx < 0) {
    return 0 as *u8;
  }
  n = w320_load_i32(m, 0);
  if (idx >= n) {
    return 0 as *u8;
  }
  unsafe {
    sc = module_sidecar_get(m, 0);
  }
  if (sc == (0 as *u8)) {
    return 0 as *u8;
  }
  flen = w320_gv_len(sc, 16);
  if (idx >= flen) {
    return 0 as *u8;
  }
  unsafe {
    return grow_vec_at(sc + (16 as usize), idx);
  }
}

/**
 * New Block alloc hook: zero slot + record GrowVec base indices.
 * @param a *u8
 * @param block_ref i32
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_block_on_alloc(a: *u8, block_ref: i32): void {
  let sc: *u8 = 0 as *u8;
  let b: *u8 = 0 as *u8;
  let nblocks: i32 = 0;
  let blen: i32 = 0;
  if (a == (0 as *u8) || block_ref <= 0) {
    return;
  }
  unsafe {
    sc = arena_sidecar_get(a, 1);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  nblocks = w320_load_i32(a, 8);
  blen = w320_gv_len(sc, 80);
  if (block_ref > nblocks || block_ref > blen) {
    return;
  }
  unsafe {
    b = grow_vec_at(sc + (80 as usize), block_ref - 1);
  }
  if (b == (0 as *u8)) {
    return;
  }
  unsafe {
    memset(b, 0, W320_BLOCK_SZ as usize);
  }
  w320_store_i32(b, 0, w320_gv_len(sc, 144));
  w320_store_i32(b, 8, w320_gv_len(sc, 176));
  w320_store_i32(b, 20, w320_gv_len(sc, 272));
  w320_store_i32(b, 28, w320_gv_len(sc, 304));
  w320_store_i32(b, 36, w320_gv_len(sc, 208));
  w320_store_i32(b, 44, w320_gv_len(sc, 240));
  w320_store_i32(b, 52, w320_gv_len(sc, 336));
  w320_store_i32(b, 60, w320_gv_len(sc, 368));
  w320_store_i32(b, 68, w320_gv_len(sc, 400));
  w320_store_i32(b, 80, w320_gv_len(sc, 432));
}

/**
 * Soft-reset ModuleSidecar pools before re-parse.
 * @param m *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_module_reset(m: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (m == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = module_sidecar_get(m, 0);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  w320_gv_clear_len(sc, 16); // funcs
  w320_gv_clear_len(sc, 48); // func_refs
  w320_gv_clear_len(sc, 80); // imports
  w320_gv_clear_len(sc, 112); // struct_layouts
  w320_gv_clear_len(sc, 144); // top_level_lets
  w320_gv_clear_len(sc, 176); // type_aliases
  w320_gv_clear_len(sc, 208); // module_enums
  w320_gv_clear_len(sc, 240); // import_select_name_rows
  w320_gv_clear_len(sc, 272); // import_select_name_lens
  w320_gv_clear_len(sc, 304); // func_params
  w320_gv_clear_len(sc, 336); // struct_layout_fields
  w320_gv_clear_len(sc, 368); // struct_layout_type_params
  w320_gv_clear_len(sc, 400); // struct_layout_type_param_meta
  unsafe {
    pipeline_module_struct_layout_storage_reset(m);
    pipeline_module_top_level_let_storage_reset(m);
    pipeline_module_type_alias_storage_reset(m);
    pipeline_module_enum_storage_reset(m);
  }
}

/**
 * Soft-reset ArenaSidecar pools before re-parse.
 * @param a *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_arena_reset(a: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (a == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = arena_sidecar_get(a, 0);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  w320_gv_clear_len(sc, 16); // types
  w320_gv_clear_len(sc, 48); // exprs
  w320_gv_clear_len(sc, 80); // blocks
  w320_gv_clear_len(sc, 112); // funcs
  w320_gv_clear_len(sc, 144); // consts
  w320_gv_clear_len(sc, 176); // lets
  w320_gv_clear_len(sc, 208); // ifs
  w320_gv_clear_len(sc, 240); // regions
  w320_gv_clear_len(sc, 272); // loops
  w320_gv_clear_len(sc, 304); // for_loops
  w320_gv_clear_len(sc, 336); // defer_block_refs
  w320_gv_clear_len(sc, 368); // labeled_stmts
  w320_gv_clear_len(sc, 400); // expr_stmt_refs
  w320_gv_clear_len(sc, 432); // stmt_order
  w320_gv_clear_len(sc, 464); // expr_call_arg_refs
  w320_gv_clear_len(sc, 496); // expr_call_type_arg_refs
  w320_gv_clear_len(sc, 528); // expr_call_type_arg_bases
  w320_gv_clear_len(sc, 560); // type_type_arg_refs
  w320_gv_clear_len(sc, 592); // type_type_arg_bases
  w320_gv_clear_len(sc, 624); // type_type_arg_counts
  w320_gv_clear_len(sc, 656); // expr_method_call_arg_refs
  w320_gv_clear_len(sc, 688); // expr_match_arms
  w320_gv_clear_len(sc, 720); // expr_struct_lit_fields
  w320_gv_clear_len(sc, 752); // expr_array_lit_elem_refs
  w320_gv_clear_len(sc, 784); // func_params
}

/**
 * Hard-free ArenaSidecar (wave275 table).
 * @param a *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_arena_release(a: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (a == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = arena_sidecar_get(a, 0);
    if (sc != (0 as *u8)) {
      arena_sidecar_free(sc);
    }
  }
}

/**
 * Hard-free pure maps + ModuleSidecar.
 * @param m *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_module_release(m: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (m == (0 as *u8)) {
    return;
  }
  unsafe {
    pipeline_module_import_storage_release(m);
    pipeline_module_type_alias_storage_release(m);
    pipeline_module_enum_storage_release(m);
    pipeline_module_top_level_let_storage_release(m);
    pipeline_module_struct_layout_storage_release(m);
    sc = module_sidecar_get(m, 0);
    if (sc != (0 as *u8)) {
      module_sidecar_free(sc);
    }
  }
}

/**
 * Drop body AST pools after dep parse_only (check RSS).
 * @param a *u8
 * @param m *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_drop_bodies_for_check(a: *u8, m: *u8): void {
  let sc: *u8 = 0 as *u8;
  let i: i32 = 0;
  let n: i32 = 0;
  let fb: *u8 = 0 as *u8;
  if (m != (0 as *u8)) {
    n = w320_load_i32(m, 0);
    while (i < n) {
      fb = w320_module_func_at(m, i);
      if (fb != (0 as *u8)) {
        w320_store_i32(fb, W320_FUNC_BODY_REF_OFF, 0);
        w320_store_i32(fb, W320_FUNC_BODY_EXPR_REF_OFF, 0);
      }
      i = i + 1;
    }
  }
  if (a == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = arena_sidecar_get(a, 0);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  unsafe {
    grow_vec_free(sc + (48 as usize));
    grow_vec_free(sc + (80 as usize));
    grow_vec_free(sc + (144 as usize));
    grow_vec_free(sc + (176 as usize));
    grow_vec_free(sc + (208 as usize));
    grow_vec_free(sc + (240 as usize));
    grow_vec_free(sc + (272 as usize));
    grow_vec_free(sc + (304 as usize));
    grow_vec_free(sc + (336 as usize));
    grow_vec_free(sc + (368 as usize));
    grow_vec_free(sc + (400 as usize));
    grow_vec_free(sc + (432 as usize));
    grow_vec_free(sc + (464 as usize));
    grow_vec_free(sc + (496 as usize));
    grow_vec_free(sc + (528 as usize));
    grow_vec_free(sc + (656 as usize));
    grow_vec_free(sc + (688 as usize));
    grow_vec_free(sc + (720 as usize));
    grow_vec_free(sc + (752 as usize));
  }
  w320_store_i32(a, 4, 0);
  w320_store_i32(a, 8, 0);
  #[cfg(target_os = "macos")]
  unsafe {
    let z: *u8 = malloc_default_zone();
    malloc_zone_pressure_relief(z, 0 as usize);
  }
  #[cfg(target_os = "linux")]
  unsafe {
    malloc_trim(0 as usize);
  }
}

/**
 * Soft-reset OneFuncSidecar scratch pools.
 * @param out *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_onefunc_reset(out: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (out == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = onefunc_sidecar_get(out, 0);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  w320_gv_clear_len(sc, 16); // if_cond_refs
  w320_gv_clear_len(sc, 48); // if_then_body_refs
  w320_gv_clear_len(sc, 80); // if_else_body_refs
  w320_gv_clear_len(sc, 112); // const_names
  w320_gv_clear_len(sc, 144); // const_name_lens
  w320_gv_clear_len(sc, 176); // const_init_vals
  w320_gv_clear_len(sc, 208); // const_init_refs
  w320_gv_clear_len(sc, 240); // const_type_refs
  w320_gv_clear_len(sc, 272); // let_names
  w320_gv_clear_len(sc, 304); // let_name_lens
  w320_gv_clear_len(sc, 336); // let_init_vals
  w320_gv_clear_len(sc, 368); // let_init_refs
  w320_gv_clear_len(sc, 400); // let_type_refs
  w320_gv_clear_len(sc, 432); // src_stmt_kind
  w320_gv_clear_len(sc, 464); // src_stmt_idx
  w320_gv_clear_len(sc, 496); // src_body_expr_stmt_refs
  w320_gv_clear_len(sc, 528); // while_cond_refs
  w320_gv_clear_len(sc, 560); // while_body_refs
  w320_gv_clear_len(sc, 592); // for_init_refs
  w320_gv_clear_len(sc, 624); // for_cond_refs
  w320_gv_clear_len(sc, 656); // for_step_refs
  w320_gv_clear_len(sc, 688); // for_body_refs
  w320_gv_clear_len(sc, 720); // param_names
  w320_gv_clear_len(sc, 752); // param_name_lens
  w320_gv_clear_len(sc, 784); // param_type_refs
  w320_gv_clear_len(sc, 816); // call_arg_vals
  w320_gv_clear_len(sc, 848); // regions
  w320_gv_clear_len(sc, 880); // defer_body_refs
  w320_gv_clear_len(sc, 912); // labeleds
}

/**
 * Hard-free OneFuncSidecar (wave275 table).
 * @param out *u8
 * @return void
 * PLATFORM: SHARED
 */
#[no_mangle]
export function ast_pool_onefunc_release(out: *u8): void {
  let sc: *u8 = 0 as *u8;
  if (out == (0 as *u8)) {
    return;
  }
  unsafe {
    sc = onefunc_sidecar_get(out, 0);
    if (sc != (0 as *u8)) {
      onefunc_sidecar_free(sc);
    }
  }
}
