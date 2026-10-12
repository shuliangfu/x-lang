// Thin pure: wave324/363/363b/385 M2 — module_func Cap residual C→.x.
// Module Func cold accessors + param sidecar + parse-impl owner BSS +
// asm/arch_arm64 rename forwarders.
// G.7: bodies match runtime_pipeline_abi_module_func_thin.c / seed WAVE280.
// PRODUCT inject: HARD BAN reinject (wave385) — stay prior overlay
//   (Darwin PREFER / Ubuntu -E from w363b; Ubuntu PREFER → undef main).
// Func LE 324 / FuncParam 264 / ModuleSc offs.
// wave363: w324_* unsafe wrappers (T001); PREFER try + L2 gate.
// wave363b: MACOS PREFER / LINUX -E.
// wave385: HARD BAN reinject both ends (stamp .pabi_w385_module_func.stamp).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function module_sidecar_get(key: *u8, create: i32): *u8;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_push(v: *u8): i32;
export extern function pipeline_arena_func_ptr(a: *u8, ref: i32): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;

// Func LE 324 (match Cap / pipe_ar_fn_* / C thin offsetof).
const W324_FUNC_SZ: i32 = 324;
const W324_FP_SZ: i32 = 264;
const W324_FN_NAME_LEN: i32 = 256;
const W324_FN_PARAM_BASE: i32 = 260;
const W324_FN_NUM_PARAMS: i32 = 264;
const W324_FN_NUM_GENERIC: i32 = 268;
const W324_FN_RET: i32 = 272;
const W324_FN_BODY: i32 = 276;
const W324_FN_BODY_EXPR: i32 = 280;
const W324_FN_IS_EXTERN: i32 = 284;
const W324_FN_IS_ASYNC: i32 = 288;
const W324_FN_IS_USED: i32 = 292;
const W324_FN_IS_NAKED: i32 = 296;
const W324_FN_IS_ENTRY: i32 = 300;
const W324_FN_IS_NO_MANGLE: i32 = 304;
const W324_FN_IS_INTERRUPT: i32 = 308;
const W324_FN_ABI_KIND: i32 = 312;
const W324_FN_IS_VARIADIC: i32 = 316;
const W324_FN_IS_EXPORT: i32 = 320;
const W324_FP_NAME_LEN: i32 = 256;
const W324_FP_TYPE_REF: i32 = 260;
const W324_GV_LEN: i32 = 12;
const W324_MSC_FUNCS: i32 = 16;
const W324_MSC_FUNC_REFS: i32 = 48;
const W324_MSC_FUNC_PARAMS: i32 = 304;
const W324_ASC_FUNC_PARAMS: i32 = 784;
const W324_ARENA_NUM_FUNCS: i32 = 12;
const W324_PMFO_MAX: i32 = 4096;

// LANG-005 impl-method owner sidecar BSS (associated-call binding).
let g_pmfo_owner: u8[262144] = [];
let g_pmfo_owner_len: i32[4096] = [];
let g_pmfo_cur_owner: u8[64] = [];
let g_pmfo_cur_len: i32 = 0;

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w324_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w324_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * GrowVec.len at sidecar+gv_off.
 */
function w324_gv_len(sc: *u8, gv_off: i32): i32 {
  return w324_load_i32(sc + (gv_off as usize), W324_GV_LEN);
}

/**
 * Module hdr num_funcs @0.
 */
function w324_mod_num_funcs(m: *u8): i32 {
  return w324_load_i32(m, 0);
}

/**
 * Arena hdr num_funcs @12.
 */
function w324_arena_num_funcs(a: *u8): i32 {
  return w324_load_i32(a, W324_ARENA_NUM_FUNCS);
}

/**
 * Module Func row pointer (sidecar funcs GrowVec @16).
 * @param m *u8 module
 * @param idx i32 0-based
 * @return *u8 Func or null
 * PLATFORM: SHARED
 */
function w324_module_func_at(m: *u8, idx: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let n: i32 = 0;
  let flen: i32 = 0;
  if (m == (0 as *u8) || idx < 0) {
    return 0 as *u8;
  }
  n = w324_mod_num_funcs(m);
  if (idx >= n) {
    return 0 as *u8;
  }
  unsafe {
    sc = module_sidecar_get(m, 0);
  }
  if (sc == (0 as *u8)) {
    return 0 as *u8;
  }
  flen = w324_gv_len(sc, W324_MSC_FUNCS);
  if (idx >= flen) {
    return 0 as *u8;
  }
  unsafe {
    return grow_vec_at(sc + (W324_MSC_FUNCS as usize), idx);
  }
}

/**
 * Copy n FuncParam slots from src sidecar pool into dst; set *dst_base.
 * PLATFORM: SHARED
 */
function w324_copy_func_params(dst: *u8, dst_base_out: *i32, n: i32, src: *u8, src_base: i32): void {
  let i: i32 = 0;
  let abs_src: i32 = 0;
  let abs_dst: i32 = 0;
  let se: *u8 = 0 as *u8;
  let de: *u8 = 0 as *u8;
  let push_rc: i32 = 0;
  if (dst == (0 as *u8) || src == (0 as *u8) || n <= 0) {
    return;
  }
  // dst is GrowVec*; len @12
  unsafe {
    *dst_base_out = pipe_load_i32_le(dst, W324_GV_LEN);
  }
  i = 0;
  while (i < n) {
    abs_src = src_base + i;
    unsafe {
      se = grow_vec_at(src, abs_src);
      push_rc = grow_vec_push(dst);
    }
    if (push_rc < 0) {
      break;
    }
    abs_dst = w324_load_i32(dst, W324_GV_LEN) - 1;
    unsafe {
      de = grow_vec_at(dst, abs_dst);
    }
    if (se != (0 as *u8) && de != (0 as *u8)) {
      unsafe {
        memcpy(de, se, W324_FP_SZ as usize);
      }
    }
    i = i + 1;
  }
}

/**
 * Read/write module func param sidecar slot; create=1 grows as needed.
 * PLATFORM: SHARED
 */
function w324_module_func_param_entry(m: *u8, fi: i32, pi: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let f: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let pb: i32 = 0;
  let np: i32 = 0;
  let plen: i32 = 0;
  let push_rc: i32 = 0;
  let create_flag: i32 = 0;
  if (m == (0 as *u8) || fi < 0 || pi < 0) {
    return 0 as *u8;
  }
  f = w324_module_func_at(m, fi);
  if (f == (0 as *u8)) {
    return 0 as *u8;
  }
  if (create != 0) {
    create_flag = 1;
  }
  unsafe {
    sc = module_sidecar_get(m, create_flag);
  }
  if (sc == (0 as *u8)) {
    return 0 as *u8;
  }
  pb = w324_load_i32(f, W324_FN_PARAM_BASE);
  np = w324_load_i32(f, W324_FN_NUM_PARAMS);
  if (create == 0) {
    if (pi >= np || pb < 0) {
      return 0 as *u8;
    }
    abs = pb + pi;
    plen = w324_gv_len(sc, W324_MSC_FUNC_PARAMS);
    if (abs < 0 || abs >= plen) {
      return 0 as *u8;
    }
    unsafe {
      return grow_vec_at(sc + (W324_MSC_FUNC_PARAMS as usize), abs);
    }
  }
  if (pb < 0) {
    pb = w324_gv_len(sc, W324_MSC_FUNC_PARAMS);
    w324_store_i32(f, W324_FN_PARAM_BASE, pb);
  }
  abs = pb + pi;
  while (w324_gv_len(sc, W324_MSC_FUNC_PARAMS) <= abs) {
    unsafe {
      push_rc = grow_vec_push(sc + (W324_MSC_FUNC_PARAMS as usize));
    }
    if (push_rc < 0) {
      return 0 as *u8;
    }
  }
  if (pi + 1 > np) {
    w324_store_i32(f, W324_FN_NUM_PARAMS, pi + 1);
  }
  unsafe {
    return grow_vec_at(sc + (W324_MSC_FUNC_PARAMS as usize), abs);
  }
}

/**
 * Read/write arena func param sidecar slot; create=1 grows as needed.
 * PLATFORM: SHARED
 */
function w324_arena_func_param_entry(a: *u8, func_ref: i32, pi: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let f: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let pb: i32 = 0;
  let np: i32 = 0;
  let plen: i32 = 0;
  let push_rc: i32 = 0;
  let nfuncs: i32 = 0;
  let create_flag: i32 = 0;
  if (a == (0 as *u8) || func_ref <= 0 || pi < 0) {
    return 0 as *u8;
  }
  nfuncs = w324_arena_num_funcs(a);
  if (func_ref > nfuncs) {
    return 0 as *u8;
  }
  unsafe {
    f = pipeline_arena_func_ptr(a, func_ref);
  }
  if (f == (0 as *u8)) {
    return 0 as *u8;
  }
  if (create != 0) {
    create_flag = 1;
  }
  unsafe {
    sc = arena_sidecar_get(a, create_flag);
  }
  if (sc == (0 as *u8)) {
    return 0 as *u8;
  }
  pb = w324_load_i32(f, W324_FN_PARAM_BASE);
  np = w324_load_i32(f, W324_FN_NUM_PARAMS);
  if (create == 0) {
    if (pi >= np || pb < 0) {
      return 0 as *u8;
    }
    abs = pb + pi;
    plen = w324_gv_len(sc, W324_ASC_FUNC_PARAMS);
    if (abs < 0 || abs >= plen) {
      return 0 as *u8;
    }
    unsafe {
      return grow_vec_at(sc + (W324_ASC_FUNC_PARAMS as usize), abs);
    }
  }
  if (pb < 0) {
    pb = w324_gv_len(sc, W324_ASC_FUNC_PARAMS);
    w324_store_i32(f, W324_FN_PARAM_BASE, pb);
  }
  abs = pb + pi;
  while (w324_gv_len(sc, W324_ASC_FUNC_PARAMS) <= abs) {
    unsafe {
      push_rc = grow_vec_push(sc + (W324_ASC_FUNC_PARAMS as usize));
    }
    if (push_rc < 0) {
      return 0 as *u8;
    }
  }
  if (pi + 1 > np) {
    w324_store_i32(f, W324_FN_NUM_PARAMS, pi + 1);
  }
  unsafe {
    return grow_vec_at(sc + (W324_ASC_FUNC_PARAMS as usize), abs);
  }
}

/**
 * Allocate a new module Func slot; return 0-based index or -1.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_alloc_slot(m: *u8): i32 {
  let sc: *u8 = 0 as *u8;
  let f: *u8 = 0 as *u8;
  let pr: *u8 = 0 as *u8;
  let idx: i32 = 0;
  let push_rc: i32 = 0;
  if (m == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    sc = module_sidecar_get(m, 1);
  }
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    idx = grow_vec_push(sc + (W324_MSC_FUNCS as usize));
  }
  if (idx < 0) {
    return 0 - 1;
  }
  unsafe {
    f = grow_vec_at(sc + (W324_MSC_FUNCS as usize), idx);
  }
  if (f != (0 as *u8)) {
    unsafe {
      memset(f, 0, W324_FUNC_SZ as usize);
    }
    w324_store_i32(f, W324_FN_PARAM_BASE, 0 - 1);
  }
  unsafe {
    push_rc = grow_vec_push(sc + (W324_MSC_FUNC_REFS as usize));
  }
  if (push_rc >= 0) {
    unsafe {
      pr = grow_vec_at(sc + (W324_MSC_FUNC_REFS as usize), idx);
    }
    if (pr != (0 as *u8)) {
      w324_store_i32(pr, 0, 0);
    }
  }
  w324_store_i32(m, 0, w324_gv_len(sc, W324_MSC_FUNCS));
  return idx;
}

/**
 * Read module func_refs[func_index].
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_ref_at(m: *u8, func_index: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let pr: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  unsafe {
    sc = module_sidecar_get(m, 0);
  }
  if (sc == (0 as *u8)) {
    return 0;
  }
  unsafe {
    pr = grow_vec_at(sc + (W324_MSC_FUNC_REFS as usize), func_index);
  }
  if (pr == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(pr, 0);
}

/**
 * Write module func_refs[func_index].
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_ref_set(m: *u8, func_index: i32, func_ref: i32): void {
  let sc: *u8 = 0 as *u8;
  let pr: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return;
  }
  unsafe {
    sc = module_sidecar_get(m, 0);
  }
  if (sc == (0 as *u8)) {
    return;
  }
  unsafe {
    pr = grow_vec_at(sc + (W324_MSC_FUNC_REFS as usize), func_index);
  }
  if (pr != (0 as *u8)) {
    w324_store_i32(pr, 0, func_ref);
  }
}

/**
 * Copy arena Func into a new module slot (+ params); return module index or -1.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_register_from_arena(m: *u8, arena: *u8, func_ref: i32): i32 {
  let fi: i32 = 0;
  let dst: *u8 = 0 as *u8;
  let src: *u8 = 0 as *u8;
  let msc: *u8 = 0 as *u8;
  let asc: *u8 = 0 as *u8;
  let dst_base: i32 = 0;
  let nparams: i32 = 0;
  let src_pb: i32 = 0;
  if (m == (0 as *u8) || arena == (0 as *u8) || func_ref <= 0 || func_ref > w324_arena_num_funcs(arena)) {
    return 0 - 1;
  }
  fi = pipeline_module_func_alloc_slot(m);
  if (fi < 0) {
    return 0 - 1;
  }
  dst = w324_module_func_at(m, fi);
  unsafe {
    src = pipeline_arena_func_ptr(arena, func_ref);
    msc = module_sidecar_get(m, 1);
    asc = arena_sidecar_get(arena, 0);
  }
  if (dst == (0 as *u8) || src == (0 as *u8) || msc == (0 as *u8) || asc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memcpy(dst, src, W324_FUNC_SZ as usize);
  }
  nparams = w324_load_i32(src, W324_FN_NUM_PARAMS);
  src_pb = w324_load_i32(src, W324_FN_PARAM_BASE);
  w324_copy_func_params(msc + (W324_MSC_FUNC_PARAMS as usize), &dst_base, nparams,
                        asc + (W324_ASC_FUNC_PARAMS as usize), src_pb);
  w324_store_i32(dst, W324_FN_PARAM_BASE, dst_base);
  pipeline_module_func_ref_set(m, fi, func_ref);
  return fi;
}

/**
 * Module Func row pointer export.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_ptr(m: *u8, func_index: i32): *u8 {
  return w324_module_func_at(m, func_index);
}

/**
 * Write Func.type_ref on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_return_type(m: *u8, fi: i32, type_ref: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_RET, type_ref);
  }
}

/**
 * Write Func.body_ref on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_body_ref(m: *u8, fi: i32, body_ref: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_BODY, body_ref);
  }
}

/**
 * Write Func.body_expr_ref on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_body_expr_ref(m: *u8, fi: i32, body_expr_ref: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_BODY_EXPR, body_expr_ref);
  }
}

/**
 * Write Func.is_extern on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_extern(m: *u8, fi: i32, is_extern: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_EXTERN, is_extern);
  }
}

/**
 * Write Func.is_async on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_async(m: *u8, fi: i32, is_async: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_ASYNC, is_async);
  }
}

/**
 * Write Func.is_used on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_used(m: *u8, fi: i32, is_used: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_USED, is_used);
  }
}

/**
 * Write Func.is_naked on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_naked(m: *u8, fi: i32, is_naked: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_NAKED, is_naked);
  }
}

/**
 * Write Func.is_entry on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_entry(m: *u8, fi: i32, is_entry: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_ENTRY, is_entry);
  }
}

/**
 * Write Func.is_no_mangle on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_no_mangle(m: *u8, fi: i32, is_no_mangle: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_NO_MANGLE, is_no_mangle);
  }
}

/**
 * Write Func.is_interrupt on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_interrupt(m: *u8, fi: i32, is_interrupt: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_INTERRUPT, is_interrupt);
  }
}

/**
 * Write Func.is_variadic on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_variadic(m: *u8, fi: i32, is_variadic: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_VARIADIC, is_variadic);
  }
}

/**
 * Write Func.abi_kind on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_abi_kind(m: *u8, fi: i32, abi_kind: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_ABI_KIND, abi_kind);
  }
}

/**
 * Write Func.is_export on module row fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_is_export(m: *u8, fi: i32, is_export: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8)) {
    w324_store_i32(f, W324_FN_IS_EXPORT, is_export);
  }
}

/**
 * Read Func field via W324_FN_IS_USED on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_used_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_USED);
}

/**
 * Read Func field via W324_FN_IS_NAKED on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_naked_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_NAKED);
}

/**
 * Read Func field via W324_FN_IS_ENTRY on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_entry_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_ENTRY);
}

/**
 * Read Func field via W324_FN_IS_NO_MANGLE on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_no_mangle_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_NO_MANGLE);
}

/**
 * Read Func field via W324_FN_IS_INTERRUPT on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_interrupt_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_INTERRUPT);
}

/**
 * Read Func field via W324_FN_ABI_KIND on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_abi_kind_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_ABI_KIND);
}

/**
 * Read Func field via W324_FN_IS_VARIADIC on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_variadic_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_VARIADIC);
}

/**
 * Read Func field via W324_FN_IS_EXPORT on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_export_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_EXPORT);
}

/**
 * Read Func field via W324_FN_IS_ASYNC on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_async_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_ASYNC);
}

/**
 * Read Func field via W324_FN_NUM_PARAMS on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_num_params_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_NUM_PARAMS);
}

/**
 * Read Func field via W324_FN_NUM_GENERIC on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_num_generic_params_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_NUM_GENERIC);
}

/**
 * Read Func field via W324_FN_RET on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_return_type_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_RET);
}

/**
 * Read Func field via W324_FN_BODY_EXPR on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_body_expr_ref_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_BODY_EXPR);
}

/**
 * Read Func field via W324_FN_IS_EXTERN on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_is_extern_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_IS_EXTERN);
}

/**
 * Read Func field via W324_FN_BODY on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_body_ref_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_BODY);
}

/**
 * Read Func field via W324_FN_NAME_LEN on module row.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_len_at(m: *u8, func_index: i32): i32 {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(f, W324_FN_NAME_LEN);
}

/**
 * Set num_params (n >= 0).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_num_params(m: *u8, fi: i32, n: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8) && n >= 0) {
    w324_store_i32(f, W324_FN_NUM_PARAMS, n);
  }
}

/**
 * Set num_generic_params (n >= 0). Debug getenv branch omitted (C pabi_trace no-op).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_set_num_generic_params(m: *u8, fi: i32, n: i32): void {
  let f: *u8 = w324_module_func_at(m, fi);
  if (f != (0 as *u8) && n >= 0) {
    w324_store_i32(f, W324_FN_NUM_GENERIC, n);
  }
}

/**
 * Lookup param type_ref by name bytes.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_param_type_ref_for_name(m: *u8, func_index: i32, var_name: *u8, var_name_len: i32): i32 {
  let f: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  let pe: *u8 = 0 as *u8;
  let pe_len: i32 = 0;
  let pe_ty: i32 = 0;
  let cmp: i32 = 0;
  if (m == (0 as *u8) || var_name == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m)) {
    return 0;
  }
  if (var_name_len <= 0 || var_name_len > 255) {
    return 0;
  }
  f = w324_module_func_at(m, func_index);
  if (f == (0 as *u8)) {
    return 0;
  }
  n = w324_load_i32(f, W324_FN_NUM_PARAMS);
  i = 0;
  while (i < n) {
    pe = w324_module_func_param_entry(m, func_index, i, 0);
    if (pe != (0 as *u8)) {
      pe_ty = w324_load_i32(pe, W324_FP_TYPE_REF);
      pe_len = w324_load_i32(pe, W324_FP_NAME_LEN);
      if (pe_ty != 0 && pe_len == var_name_len && pe_len > 0 && pe_len <= 255) {
        unsafe {
          cmp = memcmp(pe, var_name, var_name_len as usize);
        }
        if (cmp == 0) {
          return pe_ty;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Read param type_ref at (fi, pi).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_param_type_ref_at(m: *u8, func_index: i32, param_index: i32): i32 {
  let pe: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m) || param_index < 0) {
    return 0;
  }
  pe = w324_module_func_param_entry(m, func_index, param_index, 0);
  if (pe == (0 as *u8)) {
    return 0;
  }
  return w324_load_i32(pe, W324_FP_TYPE_REF);
}

/**
 * Write param name+type into module sidecar (create grows).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_param_write(m: *u8, func_index: i32, param_index: i32, name_bytes: *u8, name_len: i32, type_ref: i32): void {
  let pe: *u8 = 0 as *u8;
  if (m == (0 as *u8) || name_bytes == (0 as *u8) || func_index < 0 || param_index < 0) {
    return;
  }
  if (name_len < 0 || name_len > 255) {
    return;
  }
  pe = w324_module_func_param_entry(m, func_index, param_index, 1);
  if (pe == (0 as *u8)) {
    return;
  }
  w324_store_i32(pe, W324_FP_NAME_LEN, name_len);
  w324_store_i32(pe, W324_FP_TYPE_REF, type_ref);
  unsafe {
    memset(pe, 0, 256 as usize);
  }
  if (name_len > 0) {
    unsafe {
      memcpy(pe, name_bytes, name_len as usize);
    }
  }
}

/**
 * Read param name_len (legal 1..255).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_param_name_len_at(m: *u8, func_index: i32, param_index: i32): i32 {
  let pe: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (m == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m) || param_index < 0) {
    return 0;
  }
  pe = w324_module_func_param_entry(m, func_index, param_index, 0);
  if (pe == (0 as *u8)) {
    return 0;
  }
  nlen = w324_load_i32(pe, W324_FP_NAME_LEN);
  if (nlen > 0 && nlen <= 255) {
    return nlen;
  }
  return 0;
}

/**
 * Copy FuncParam.name[256] into dst (ABI name copy32; Cap payload 256).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_param_name_copy32(m: *u8, func_index: i32, param_index: i32, dst: *u8): void {
  let pe: *u8 = 0 as *u8;
  if (m == (0 as *u8) || dst == (0 as *u8) || func_index < 0 || func_index >= w324_mod_num_funcs(m) || param_index < 0) {
    return;
  }
  pe = w324_module_func_param_entry(m, func_index, param_index, 0);
  if (pe == (0 as *u8)) {
    unsafe {
      memset(dst, 0, 256 as usize);
    }
    return;
  }
  unsafe {
    memcpy(dst, pe, 256 as usize);
  }
}

/**
 * Write arena FuncParam name+type (create grows).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_arena_func_param_write(arena: *u8, func_ref: i32, param_index: i32, name_bytes: *u8, name_len: i32, type_ref: i32): void {
  let pe: *u8 = 0 as *u8;
  if (arena == (0 as *u8) || name_bytes == (0 as *u8) || func_ref <= 0 || func_ref > w324_arena_num_funcs(arena) || param_index < 0) {
    return;
  }
  if (name_len < 0 || name_len > 255) {
    return;
  }
  pe = w324_arena_func_param_entry(arena, func_ref, param_index, 1);
  if (pe == (0 as *u8)) {
    return;
  }
  w324_store_i32(pe, W324_FP_NAME_LEN, name_len);
  w324_store_i32(pe, W324_FP_TYPE_REF, type_ref);
  unsafe {
    memset(pe, 0, 256 as usize);
  }
  if (name_len > 0) {
    unsafe {
      memcpy(pe, name_bytes, name_len as usize);
    }
  }
}

/**
 * Copy module.funcs[fi] scalar + param sidecar into arena Func slot.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_arena_func_copy_slot_from_module(arena: *u8, func_ref: i32, m: *u8, fi: i32): void {
  let src: *u8 = 0 as *u8;
  let dst: *u8 = 0 as *u8;
  let msc: *u8 = 0 as *u8;
  let asc: *u8 = 0 as *u8;
  let dst_base: i32 = 0;
  let nparams: i32 = 0;
  let src_pb: i32 = 0;
  if (arena == (0 as *u8) || m == (0 as *u8) || func_ref <= 0 || func_ref > w324_arena_num_funcs(arena)) {
    return;
  }
  if (fi < 0 || fi >= w324_mod_num_funcs(m)) {
    return;
  }
  src = w324_module_func_at(m, fi);
  unsafe {
    dst = pipeline_arena_func_ptr(arena, func_ref);
    msc = module_sidecar_get(m, 0);
    asc = arena_sidecar_get(arena, 1);
  }
  if (src == (0 as *u8) || dst == (0 as *u8) || msc == (0 as *u8) || asc == (0 as *u8)) {
    return;
  }
  unsafe {
    memcpy(dst, src, W324_FUNC_SZ as usize);
  }
  nparams = w324_load_i32(src, W324_FN_NUM_PARAMS);
  src_pb = w324_load_i32(src, W324_FN_PARAM_BASE);
  w324_copy_func_params(asc + (W324_ASC_FUNC_PARAMS as usize), &dst_base, nparams,
                        msc + (W324_MSC_FUNC_PARAMS as usize), src_pb);
  w324_store_i32(dst, W324_FN_PARAM_BASE, dst_base);
}

/**
 * Latch current impl owner name for associated-call binding.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_parse_impl_owner_set(nm: *u8, nlen: i32): void {
  let i: i32 = 0;
  let n: i32 = nlen;
  if (n < 0) {
    n = 0;
  }
  if (n > 63) {
    n = 63;
  }
  g_pmfo_cur_len = n;
  i = 0;
  while (i < 64) {
    if (nm != (0 as *u8) && i < n) {
      unsafe {
        g_pmfo_cur_owner[i] = nm[i];
      }
    } else {
      unsafe {
        g_pmfo_cur_owner[i] = 0;
      }
    }
    i = i + 1;
  }
}

/**
 * Clear latched impl owner.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_parse_impl_owner_clear(): void {
  g_pmfo_cur_len = 0;
}

/**
 * Stamp latched owner onto func slot fi.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_owner_from_impl(m: *u8, fi: i32): void {
  let base: i32 = 0;
  let i: i32 = 0;
  if (m == (0 as *u8) || fi < 0 || fi >= W324_PMFO_MAX) {
    return;
  }
  if (g_pmfo_cur_len <= 0) {
    return;
  }
  base = fi * 64;
  i = 0;
  while (i < 64) {
    unsafe {
      g_pmfo_owner[base + i] = g_pmfo_cur_owner[i];
    }
    i = i + 1;
  }
  unsafe {
    g_pmfo_owner_len[fi] = g_pmfo_cur_len;
  }
}

/**
 * 1 when row fi may bind associated call on base; empty owner = free/UFCS/legacy.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_owner_binds_base_at(m: *u8, fi: i32, base: *u8, base_len: i32): i32 {
  let i: i32 = 0;
  let olen: i32 = 0;
  let off: i32 = 0;
  if (m == (0 as *u8) || fi < 0 || fi >= W324_PMFO_MAX) {
    return 1;
  }
  unsafe {
    olen = g_pmfo_owner_len[fi];
  }
  if (olen <= 0) {
    return 1;
  }
  if (base == (0 as *u8) || base_len <= 0 || base_len > 63) {
    return 0;
  }
  if (olen != base_len) {
    return 0;
  }
  off = fi * 64;
  i = 0;
  while (i < base_len) {
    unsafe {
      if (g_pmfo_owner[off + i] != base[i]) {
        return 0;
      }
    }
    i = i + 1;
  }
  return 1;
}

/**
 * Compare module func name to external bytes; 1 if equal.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_equal_at(m: *u8, fi: i32, name: *u8, name_len: i32): i32 {
  let f: *u8 = 0 as *u8;
  let flen: i32 = 0;
  let cmp: i32 = 0;
  if (m == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0;
  }
  f = w324_module_func_at(m, fi);
  if (f == (0 as *u8)) {
    return 0;
  }
  flen = w324_load_i32(f, W324_FN_NAME_LEN);
  if (flen != name_len) {
    return 0;
  }
  unsafe {
    cmp = memcmp(f, name, name_len as usize);
  }
  if (cmp == 0) {
    return 1;
  }
  return 0;
}

/**
 * Read module func name byte (0..name_len-1); OOB → 0.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_byte_at(m: *u8, fi: i32, i: i32): u8 {
  let f: *u8 = 0 as *u8;
  let flen: i32 = 0;
  if (m == (0 as *u8) || i < 0 || i >= 256) {
    return 0;
  }
  f = w324_module_func_at(m, fi);
  if (f == (0 as *u8)) {
    return 0;
  }
  flen = w324_load_i32(f, W324_FN_NAME_LEN);
  if (i >= flen) {
    return 0;
  }
  unsafe {
    return f[i];
  }
}

/**
 * Write Func.name[256] (content ≤255 + NUL pad).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_write(m: *u8, func_index: i32, name_bytes: *u8, name_len: i32): void {
  let f: *u8 = 0 as *u8;
  if (m == (0 as *u8) || func_index < 0) {
    return;
  }
  if (name_len < 0 || name_len > 255) {
    return;
  }
  if (name_len > 0 && name_bytes == (0 as *u8)) {
    return;
  }
  f = pipeline_module_func_ptr(m, func_index);
  if (f == (0 as *u8)) {
    return;
  }
  w324_store_i32(f, W324_FN_NAME_LEN, name_len);
  unsafe {
    memset(f, 0, 256 as usize);
  }
  if (name_len > 0) {
    unsafe {
      memcpy(f, name_bytes, name_len as usize);
    }
  }
}

/**
 * Copy Func.name[256] into dst (256 bytes, NUL-padded).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_module_func_name_copy64(m: *u8, func_index: i32, dst: *u8): void {
  let f: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (m == (0 as *u8) || dst == (0 as *u8) || func_index < 0) {
    return;
  }
  if (func_index >= w324_mod_num_funcs(m)) {
    return;
  }
  f = pipeline_module_func_ptr(m, func_index);
  if (f == (0 as *u8)) {
    return;
  }
  nlen = w324_load_i32(f, W324_FN_NAME_LEN);
  if (nlen < 0) {
    nlen = 0;
  }
  if (nlen > 255) {
    nlen = 255;
  }
  unsafe {
    memset(dst, 0, 256 as usize);
  }
  if (nlen > 0) {
    unsafe {
      memcpy(dst, f, nlen as usize);
    }
  }
}

/**
 * asm_ forwarder: is_extern.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_is_extern_at(m: *u8, func_index: i32): i32 {
  return pipeline_module_func_is_extern_at(m, func_index);
}

/**
 * asm_ forwarder: body_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_body_ref_at(m: *u8, func_index: i32): i32 {
  return pipeline_module_func_body_ref_at(m, func_index);
}

/**
 * asm_ forwarder: name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_name_len_at(m: *u8, func_index: i32): i32 {
  return pipeline_module_func_name_len_at(m, func_index);
}

/**
 * asm_ forwarder: name_copy64.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_name_copy64(m: *u8, func_index: i32, dst: *u8): void {
  pipeline_module_func_name_copy64(m, func_index, dst);
}

/**
 * asm_ forwarder: num_params.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_num_params_at(m: *u8, func_index: i32): i32 {
  return pipeline_module_func_num_params_at(m, func_index);
}

/**
 * asm_ forwarder: param_name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_param_name_len_at(m: *u8, func_index: i32, param_index: i32): i32 {
  return pipeline_module_func_param_name_len_at(m, func_index, param_index);
}

/**
 * asm_ forwarder: param_name_copy32.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_asm_module_func_param_name_copy32(m: *u8, func_index: i32, param_index: i32, dst: *u8): void {
  pipeline_module_func_param_name_copy32(m, func_index, param_index, dst);
}

/**
 * arch_arm64 forwarder: is_extern.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function arch_arm64_pipeline_asm_module_func_is_extern_at(m: *u8, func_index: i32): i32 {
  return pipeline_asm_module_func_is_extern_at(m, func_index);
}

/**
 * arch_arm64 forwarder: body_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function arch_arm64_pipeline_asm_module_func_body_ref_at(m: *u8, func_index: i32): i32 {
  return pipeline_asm_module_func_body_ref_at(m, func_index);
}

/**
 * arch_arm64 forwarder: name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function arch_arm64_pipeline_asm_module_func_name_len_at(m: *u8, func_index: i32): i32 {
  return pipeline_asm_module_func_name_len_at(m, func_index);
}

/**
 * arch_arm64 forwarder: name_copy64.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function arch_arm64_pipeline_asm_module_func_name_copy64(m: *u8, func_index: i32, dst: *u8): void {
  pipeline_asm_module_func_name_copy64(m, func_index, dst);
}
