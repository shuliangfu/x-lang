// Thin pure: wave325/363/379 M2 — onefunc Cap residual C→.x.
// pipeline_onefunc_* mutators + pipeline_block_fill_*_from_onefunc.
// G.7: bodies match runtime_pipeline_abi_onefunc_thin.c / seed WAVE281.
// PRODUCT inject: HARD BAN PREFER (wave379) — stay prior -E overlay.
// wave335 PREFER SEGV; wave379 PREFER → L2 XP001 parse (opt/si/hello).
// wave363: w325_* unsafe wrappers (T001) kept.
// PLATFORM: SHARED freestanding Cap leave · BAN PREFER both ends.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function onefunc_sidecar_get(out: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_push(v: *u8): i32;
export extern function grow_vec_copy_append(dst: *u8, src: *u8): void;
export extern function ast_pool_onefunc_reset(out: *u8): void;
export extern function pipeline_arena_block_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_block_append_defer(a: *u8, br: i32, body_ref: i32): i32;
export extern function pipeline_block_append_labeled(a: *u8, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32;
export extern function pipeline_block_labeled_ptr(a: *u8, br: i32, li: i32): *u8;
export extern function pipeline_block_append_if(a: *u8, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32;
export extern function pipeline_block_append_with_arena(a: *u8, br: i32, cap_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_unsafe(a: *u8, br: i32, body_ref: i32): i32;
export extern function pipeline_block_append_region(a: *u8, br: i32, label: *u8, label_len: i32, body_ref: i32): i32;
export extern function pipeline_block_append_stmt_order(a: *u8, br: i32, kind: u8, idx_val: i32): i32;
export extern function pipeline_block_append_expr_stmt(a: *u8, br: i32, expr_ref: i32): i32;
export extern function pipeline_block_append_while(a: *u8, br: i32, cond_ref: i32, body_ref: i32): i32;
export extern function pipeline_block_append_for(a: *u8, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;


/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w325_load_i32(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w325_store_i32(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}


const W325_GV_LEN: i32 = 12;
const W325_REGION_SZ: i32 = 268;
const W325_LABELED_SZ: i32 = 528;
const W325_RE_LABEL_LEN: i32 = 256;
const W325_RE_BODY: i32 = 260;
const W325_RE_CAP: i32 = 264;
const W325_LE_LABEL_LEN: i32 = 256;
const W325_LE_IS_GOTO: i32 = 260;
const W325_LE_GOTO: i32 = 264;
const W325_LE_GOTO_LEN: i32 = 520;
const W325_LE_RET: i32 = 524;
const W325_BLK_NUM_IF: i32 = 40;
const W325_BLK_NUM_LABELED: i32 = 64;
const W325_IF_COND: i32 = 16;
const W325_IF_THEN: i32 = 48;
const W325_IF_ELSE: i32 = 80;
const W325_CONST_NAMES: i32 = 112;
const W325_CONST_NAME_LENS: i32 = 144;
const W325_CONST_INIT_VALS: i32 = 176;
const W325_CONST_INIT_REFS: i32 = 208;
const W325_CONST_TYPE_REFS: i32 = 240;
const W325_LET_NAMES: i32 = 272;
const W325_LET_NAME_LENS: i32 = 304;
const W325_LET_INIT_VALS: i32 = 336;
const W325_LET_INIT_REFS: i32 = 368;
const W325_LET_TYPE_REFS: i32 = 400;
const W325_SRC_STMT_KIND: i32 = 432;
const W325_SRC_STMT_IDX: i32 = 464;
const W325_SRC_BODY: i32 = 496;
const W325_WHILE_COND: i32 = 528;
const W325_WHILE_BODY: i32 = 560;
const W325_FOR_INIT: i32 = 592;
const W325_FOR_COND: i32 = 624;
const W325_FOR_STEP: i32 = 656;
const W325_FOR_BODY: i32 = 688;
const W325_PARAM_NAMES: i32 = 720;
const W325_PARAM_NAME_LENS: i32 = 752;
const W325_PARAM_TYPE_REFS: i32 = 784;
const W325_CALL_ARG_VALS: i32 = 816;
const W325_REGIONS: i32 = 848;
const W325_DEFER_BODY: i32 = 880;
const W325_LABELEDS: i32 = 912;

/**
 * GrowVec.len at sidecar+gv_off.
 */
function w325_gv_len(sc: *u8, gv_off: i32): i32 {
  return w325_load_i32(sc + (gv_off as usize), W325_GV_LEN);
}

/**
 * Get OneFunc sidecar (create flag).
 */
function w325_sc(out: *u8, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let cf: i32 = 0;
  if (out == (0 as *u8)) {
    return 0 as *u8;
  }
  if (create != 0) {
    cf = 1;
  }
  unsafe {
    sc = onefunc_sidecar_get(out, cf);
  }
  return sc;
}

/**
 * Push i32 into GrowVec at sc+gv_off; return index or -1.
 */
function w325_push_i32(sc: *u8, gv_off: i32, v: i32): i32 {
  let p: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  unsafe {
    rc = grow_vec_push(sc + (gv_off as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, gv_off) - 1;
  unsafe {
    p = grow_vec_at(sc + (gv_off as usize), idx);
  }
  if (p == (0 as *u8)) {
    return 0 - 1;
  }
  w325_store_i32(p, 0, v);
  return idx;
}

/**
 * Load i32 slot from GrowVec at sc+gv_off[i]; 0 if OOB.
 */
function w325_get_i32(sc: *u8, gv_off: i32, i: i32): i32 {
  let p: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, gv_off)) {
    return 0;
  }
  unsafe {
    p = grow_vec_at(sc + (gv_off as usize), i);
  }
  if (p == (0 as *u8)) {
    return 0;
  }
  return w325_load_i32(p, 0);
}

/**
 * Push name row (256B) + companion lens; copy name bytes. Returns name index or -1.
 */
function w325_push_name_row(sc: *u8, names_off: i32, name: *u8, name_len: i32): i32 {
  let row: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  unsafe {
    rc = grow_vec_push(sc + (names_off as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, names_off) - 1;
  unsafe {
    row = grow_vec_at(sc + (names_off as usize), idx);
  }
  if (row == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memset(row, 0, 256 as usize);
    memcpy(row, name, name_len as usize);
  }
  return idx;
}

/**
 * Append OneFunc const (name/init_val/init_ref/type_ref).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_const(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (out == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  idx = w325_push_name_row(sc, W325_CONST_NAMES, name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_CONST_NAME_LENS, name_len) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_CONST_INIT_VALS, init_val) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_CONST_INIT_REFS, init_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_CONST_TYPE_REFS, type_ref) < 0) {
    return 0 - 1;
  }
  return idx;
}

/**
 * Append const with init_ref/type_ref=0.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_const_name(out: *u8, name: *u8, name_len: i32, init_val: i32): i32 {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, 0, 0);
}

/**
 * Read const init_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_init_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_CONST_INIT_REFS, i);
}

/**
 * Read const type_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_type_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_CONST_TYPE_REFS, i);
}

/**
 * Read const name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_name_len(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_CONST_NAME_LENS, i);
}

/**
 * Read const init_val.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_init_val(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_CONST_INIT_VALS, i);
}

/**
 * Count consts.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_consts(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_CONST_NAME_LENS);
}

/**
 * Read const name byte.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_name_byte_at(out: *u8, i: i32, off: i32): u8 {
  let sc: *u8 = w325_sc(out, 0);
  let row: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_CONST_NAMES) || off < 0 || off >= 255) {
    return 0;
  }
  nlen = w325_get_i32(sc, W325_CONST_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_CONST_NAMES as usize), i);
  }
  if (row == (0 as *u8) || off >= nlen) {
    return 0;
  }
  unsafe {
    return row[off];
  }
}

/**
 * Copy const name (≤127).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_const_name_copy64(out: *u8, i: i32, dst: *u8): void {
  let sc: *u8 = 0 as *u8;
  let row: *u8 = 0 as *u8;
  let n: i32 = 0;
  let k: i32 = 0;
  if (dst == (0 as *u8)) {
    return;
  }
  unsafe {
    memset(dst, 0, 256 as usize);
  }
  sc = w325_sc(out, 0);
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_CONST_NAMES)) {
    return;
  }
  n = w325_get_i32(sc, W325_CONST_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_CONST_NAMES as usize), i);
  }
  if (row == (0 as *u8)) {
    return;
  }
  if (n > 127) {
    n = 127;
  }
  k = 0;
  while (k < n) {
    unsafe {
      dst[k] = row[k];
    }
    k = k + 1;
  }
}

/**
 * Append OneFunc let.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_let(out: *u8, name: *u8, name_len: i32, init_val: i32, init_ref: i32, type_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (out == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  idx = w325_push_name_row(sc, W325_LET_NAMES, name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_LET_NAME_LENS, name_len) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_LET_INIT_VALS, init_val) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_LET_INIT_REFS, init_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_LET_TYPE_REFS, type_ref) < 0) {
    return 0 - 1;
  }
  return idx;
}

/**
 * Read let name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_name_len(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_LET_NAME_LENS, i);
}

/**
 * Read let init_val.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_init_val(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_LET_INIT_VALS, i);
}

/**
 * Read let init_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_init_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_LET_INIT_REFS, i);
}

/**
 * Read let type_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_type_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_LET_TYPE_REFS, i);
}

/**
 * Count lets.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_lets(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_LET_NAME_LENS);
}

/**
 * Read let name byte.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_name_byte_at(out: *u8, i: i32, off: i32): u8 {
  let sc: *u8 = w325_sc(out, 0);
  let row: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_LET_NAMES) || off < 0 || off >= 255) {
    return 0;
  }
  nlen = w325_get_i32(sc, W325_LET_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_LET_NAMES as usize), i);
  }
  if (row == (0 as *u8) || off >= nlen) {
    return 0;
  }
  unsafe {
    return row[off];
  }
}

/**
 * Copy let name (≤127).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_let_name_copy64(out: *u8, i: i32, dst: *u8): void {
  let sc: *u8 = 0 as *u8;
  let row: *u8 = 0 as *u8;
  let n: i32 = 0;
  let k: i32 = 0;
  if (dst == (0 as *u8)) {
    return;
  }
  unsafe {
    memset(dst, 0, 256 as usize);
  }
  sc = w325_sc(out, 0);
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_LET_NAMES)) {
    return;
  }
  n = w325_get_i32(sc, W325_LET_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_LET_NAMES as usize), i);
  }
  if (row == (0 as *u8)) {
    return;
  }
  if (n > 127) {
    n = 127;
  }
  k = 0;
  while (k < n) {
    unsafe {
      dst[k] = row[k];
    }
    k = k + 1;
  }
}

/**
 * Append parse-scratch param.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_param(out: *u8, name: *u8, name_len: i32, type_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (out == (0 as *u8) || name == (0 as *u8) || name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  idx = w325_push_name_row(sc, W325_PARAM_NAMES, name, name_len);
  if (idx < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_PARAM_NAME_LENS, name_len) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_PARAM_TYPE_REFS, type_ref) < 0) {
    return 0 - 1;
  }
  return w325_gv_len(sc, W325_PARAM_NAME_LENS) - 1;
}

/**
 * Set param type_ref at i.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_set_param_type_ref(out: *u8, i: i32, type_ref: i32): void {
  let sc: *u8 = w325_sc(out, 0);
  let p: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_PARAM_TYPE_REFS)) {
    return;
  }
  unsafe {
    p = grow_vec_at(sc + (W325_PARAM_TYPE_REFS as usize), i);
  }
  if (p != (0 as *u8)) {
    w325_store_i32(p, 0, type_ref);
  }
}

/**
 * Read param name_len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_param_name_len(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_PARAM_NAME_LENS, i);
}

/**
 * Read param type_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_param_type_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_PARAM_TYPE_REFS, i);
}

/**
 * Count params.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_params_from_pool(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_PARAM_NAME_LENS);
}

/**
 * Read param name byte.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_param_name_byte_at(out: *u8, i: i32, off: i32): u8 {
  let sc: *u8 = w325_sc(out, 0);
  let row: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_PARAM_NAMES) || off < 0 || off >= 256) {
    return 0;
  }
  nlen = w325_get_i32(sc, W325_PARAM_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_PARAM_NAMES as usize), i);
  }
  if (row == (0 as *u8) || off >= nlen) {
    return 0;
  }
  unsafe {
    return row[off];
  }
}

/**
 * Copy param name (≤255).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_param_name_copy32(out: *u8, i: i32, dst: *u8): void {
  let sc: *u8 = 0 as *u8;
  let row: *u8 = 0 as *u8;
  let n: i32 = 0;
  let k: i32 = 0;
  if (dst == (0 as *u8)) {
    return;
  }
  unsafe {
    memset(dst, 0, 256 as usize);
  }
  sc = w325_sc(out, 0);
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_PARAM_NAMES)) {
    return;
  }
  n = w325_get_i32(sc, W325_PARAM_NAME_LENS, i);
  unsafe {
    row = grow_vec_at(sc + (W325_PARAM_NAMES as usize), i);
  }
  if (row == (0 as *u8)) {
    return;
  }
  if (n > 255) {
    n = 255;
  }
  k = 0;
  while (k < n) {
    unsafe {
      dst[k] = row[k];
    }
    k = k + 1;
  }
}

/**
 * Append call_arg_val.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_call_arg_val(out: *u8, val: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  return w325_push_i32(sc, W325_CALL_ARG_VALS, val);
}

/**
 * Read call_arg_val.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_call_arg_val_at(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_CALL_ARG_VALS, i);
}

/**
 * Clear call_arg_vals.len.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_reset_call_args(out: *u8): void {
  let sc: *u8 = w325_sc(out, 0);
  if (sc != (0 as *u8)) {
    w325_store_i32(sc + (W325_CALL_ARG_VALS as usize), W325_GV_LEN, 0);
  }
}

/**
 * Copy OneFunc sidecar pools (match C: no regions/defer).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_copy_sidecar(dst: *u8, src: *u8): void {
  let dsc: *u8 = 0 as *u8;
  let ssc: *u8 = 0 as *u8;
  if (dst == (0 as *u8) || src == (0 as *u8) || dst == src) {
    return;
  }
  ssc = w325_sc(src, 0);
  if (ssc == (0 as *u8)) {
    return;
  }
  unsafe {
    ast_pool_onefunc_reset(dst);
  }
  dsc = w325_sc(dst, 0);
  if (dsc == (0 as *u8)) {
    return;
  }
  unsafe {
    grow_vec_copy_append(dsc + (W325_IF_COND as usize), ssc + (W325_IF_COND as usize));
    grow_vec_copy_append(dsc + (W325_IF_THEN as usize), ssc + (W325_IF_THEN as usize));
    grow_vec_copy_append(dsc + (W325_IF_ELSE as usize), ssc + (W325_IF_ELSE as usize));
    grow_vec_copy_append(dsc + (W325_CONST_NAMES as usize), ssc + (W325_CONST_NAMES as usize));
    grow_vec_copy_append(dsc + (W325_CONST_NAME_LENS as usize), ssc + (W325_CONST_NAME_LENS as usize));
    grow_vec_copy_append(dsc + (W325_CONST_INIT_VALS as usize), ssc + (W325_CONST_INIT_VALS as usize));
    grow_vec_copy_append(dsc + (W325_CONST_INIT_REFS as usize), ssc + (W325_CONST_INIT_REFS as usize));
    grow_vec_copy_append(dsc + (W325_CONST_TYPE_REFS as usize), ssc + (W325_CONST_TYPE_REFS as usize));
    grow_vec_copy_append(dsc + (W325_LET_NAMES as usize), ssc + (W325_LET_NAMES as usize));
    grow_vec_copy_append(dsc + (W325_LET_NAME_LENS as usize), ssc + (W325_LET_NAME_LENS as usize));
    grow_vec_copy_append(dsc + (W325_LET_INIT_VALS as usize), ssc + (W325_LET_INIT_VALS as usize));
    grow_vec_copy_append(dsc + (W325_LET_INIT_REFS as usize), ssc + (W325_LET_INIT_REFS as usize));
    grow_vec_copy_append(dsc + (W325_LET_TYPE_REFS as usize), ssc + (W325_LET_TYPE_REFS as usize));
    grow_vec_copy_append(dsc + (W325_SRC_STMT_KIND as usize), ssc + (W325_SRC_STMT_KIND as usize));
    grow_vec_copy_append(dsc + (W325_SRC_STMT_IDX as usize), ssc + (W325_SRC_STMT_IDX as usize));
    grow_vec_copy_append(dsc + (W325_SRC_BODY as usize), ssc + (W325_SRC_BODY as usize));
    grow_vec_copy_append(dsc + (W325_WHILE_COND as usize), ssc + (W325_WHILE_COND as usize));
    grow_vec_copy_append(dsc + (W325_WHILE_BODY as usize), ssc + (W325_WHILE_BODY as usize));
    grow_vec_copy_append(dsc + (W325_FOR_INIT as usize), ssc + (W325_FOR_INIT as usize));
    grow_vec_copy_append(dsc + (W325_FOR_COND as usize), ssc + (W325_FOR_COND as usize));
    grow_vec_copy_append(dsc + (W325_FOR_STEP as usize), ssc + (W325_FOR_STEP as usize));
    grow_vec_copy_append(dsc + (W325_FOR_BODY as usize), ssc + (W325_FOR_BODY as usize));
    grow_vec_copy_append(dsc + (W325_PARAM_NAMES as usize), ssc + (W325_PARAM_NAMES as usize));
    grow_vec_copy_append(dsc + (W325_PARAM_NAME_LENS as usize), ssc + (W325_PARAM_NAME_LENS as usize));
    grow_vec_copy_append(dsc + (W325_PARAM_TYPE_REFS as usize), ssc + (W325_PARAM_TYPE_REFS as usize));
    grow_vec_copy_append(dsc + (W325_CALL_ARG_VALS as usize), ssc + (W325_CALL_ARG_VALS as usize));
    grow_vec_copy_append(dsc + (W325_LABELEDS as usize), ssc + (W325_LABELEDS as usize));
  }
}

/**
 * Append while (cond, body).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_while(out: *u8, cond_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_WHILE_COND, cond_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_WHILE_BODY, body_ref) < 0) {
    return 0 - 1;
  }
  return w325_gv_len(sc, W325_WHILE_COND) - 1;
}

/**
 * Read while cond.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_while_cond_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_WHILE_COND, i);
}

/**
 * Read while body.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_while_body_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_WHILE_BODY, i);
}

/**
 * Count whiles.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_whiles(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_WHILE_COND);
}

/**
 * Append for (init/cond/step/body).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_for(out: *u8, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_FOR_INIT, init_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_FOR_COND, cond_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_FOR_STEP, step_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_FOR_BODY, body_ref) < 0) {
    return 0 - 1;
  }
  return w325_gv_len(sc, W325_FOR_INIT) - 1;
}

/**
 * Read for init.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_for_init_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_FOR_INIT, i);
}

/**
 * Read for cond.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_for_cond_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_FOR_COND, i);
}

/**
 * Read for step.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_for_step_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_FOR_STEP, i);
}

/**
 * Read for body.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_for_body_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_FOR_BODY, i);
}

/**
 * Count fors.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_fors(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_FOR_INIT);
}

/**
 * Append defer body_ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_defer(out: *u8, body_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  if (out == (0 as *u8) || body_ref <= 0) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  return w325_push_i32(sc, W325_DEFER_BODY, body_ref);
}

/**
 * Count defers.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_defers(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_DEFER_BODY);
}

/**
 * Flush defer chain into Block pool.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_defers_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let sc: *u8 = w325_sc(out, 0);
  let i: i32 = 0;
  let pr: i32 = 0;
  if (a == (0 as *u8) || out == (0 as *u8) || sc == (0 as *u8)) {
    return;
  }
  while (i < count && i < w325_gv_len(sc, W325_DEFER_BODY)) {
    pr = w325_get_i32(sc, W325_DEFER_BODY, i);
    if (pr > 0) {
      unsafe {
        pipeline_block_append_defer(a, br, pr);
      }
    }
    i = i + 1;
  }
}

/**
 * Append labeled entry (goto/label/return).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_labeled(out: *u8, label: *u8, label_len: i32, is_goto: i32, goto_target: *u8, goto_target_len: i32, return_expr_ref: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  let le: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  let n: i32 = 0;
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    rc = grow_vec_push(sc + (W325_LABELEDS as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, W325_LABELEDS) - 1;
  unsafe {
    le = grow_vec_at(sc + (W325_LABELEDS as usize), idx);
  }
  if (le == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memset(le, 0, W325_LABELED_SZ as usize);
  }
  w325_store_i32(le, W325_LE_IS_GOTO, is_goto);
  w325_store_i32(le, W325_LE_RET, return_expr_ref);
  if (label != (0 as *u8) && label_len > 0) {
    n = label_len;
    if (n > 255) {
      n = 127;
    }
    unsafe {
      memcpy(le, label, n as usize);
    }
    w325_store_i32(le, W325_LE_LABEL_LEN, n);
  }
  if (goto_target != (0 as *u8) && goto_target_len > 0) {
    n = goto_target_len;
    if (n > 255) {
      n = 127;
    }
    unsafe {
      memcpy(le + (W325_LE_GOTO as usize), goto_target, n as usize);
    }
    w325_store_i32(le, W325_LE_GOTO_LEN, n);
  }
  return idx;
}

/**
 * Count labeleds.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_labeleds(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_LABELEDS);
}

/**
 * Flush labeled pool into Block.labeled_stmts.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_labeled_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let sc: *u8 = w325_sc(out, 0);
  let b: *u8 = 0 as *u8;
  let le: *u8 = 0 as *u8;
  let ls: *u8 = 0 as *u8;
  let i: i32 = 0;
  let li: i32 = 0;
  let n: i32 = 0;
  let llen: i32 = 0;
  let glen: i32 = 0;
  let is_goto: i32 = 0;
  let ret: i32 = 0;
  if (a == (0 as *u8) || out == (0 as *u8) || sc == (0 as *u8)) {
    return;
  }
  if (br > 0) {
    unsafe {
      b = pipeline_arena_block_ptr(a, br);
    }
    if (b != (0 as *u8)) {
      w325_store_i32(b, W325_BLK_NUM_LABELED, 0);
    }
  }
  while (i < count && i < w325_gv_len(sc, W325_LABELEDS)) {
    unsafe {
      le = grow_vec_at(sc + (W325_LABELEDS as usize), i);
    }
    if (le != (0 as *u8)) {
      llen = w325_load_i32(le, W325_LE_LABEL_LEN);
      is_goto = w325_load_i32(le, W325_LE_IS_GOTO);
      glen = w325_load_i32(le, W325_LE_GOTO_LEN);
      ret = w325_load_i32(le, W325_LE_RET);
      unsafe {
        li = pipeline_block_append_labeled(a, br, llen, is_goto, glen, ret);
      }
      if (li >= 0) {
        unsafe {
          ls = pipeline_block_labeled_ptr(a, br, li);
        }
        if (ls != (0 as *u8)) {
          if (llen > 0) {
            n = llen;
            if (n > 127) {
              n = 127;
            }
            unsafe {
              memcpy(ls, le, n as usize);
              ls[n] = 0;
            }
            w325_store_i32(ls, W325_LE_LABEL_LEN, n);
          }
          if (glen > 0) {
            n = glen;
            if (n > 127) {
              n = 127;
            }
            unsafe {
              memcpy(ls + (W325_LE_GOTO as usize), le + (W325_LE_GOTO as usize), n as usize);
              (ls + ((W325_LE_GOTO + n) as usize))[0] = 0;
            }
            w325_store_i32(ls, W325_LE_GOTO_LEN, n);
          }
        }
      }
    }
    i = i + 1;
  }
}

/**
 * Append if (cond/then/else).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_if(out: *u8, cond: i32, then_ref: i32, else_ref: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_IF_COND, cond) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_IF_THEN, then_ref) < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_IF_ELSE, else_ref) < 0) {
    return 0 - 1;
  }
  return w325_gv_len(sc, W325_IF_COND) - 1;
}

/**
 * Read if cond.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_if_cond_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_IF_COND, i);
}

/**
 * Read if then.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_if_then_body_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_IF_THEN, i);
}

/**
 * Read if else.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_if_else_body_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_IF_ELSE, i);
}

/**
 * Count ifs.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_if_stmts(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_IF_COND);
}

/**
 * Append region with label.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_region(out: *u8, label: *u8, label_len: i32, body_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let re: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  if (out == (0 as *u8) || label == (0 as *u8) || label_len <= 0 || label_len > 255) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    rc = grow_vec_push(sc + (W325_REGIONS as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, W325_REGIONS) - 1;
  unsafe {
    re = grow_vec_at(sc + (W325_REGIONS as usize), idx);
  }
  if (re == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memset(re, 0, W325_REGION_SZ as usize);
    memcpy(re, label, label_len as usize);
  }
  w325_store_i32(re, W325_RE_LABEL_LEN, label_len);
  w325_store_i32(re, W325_RE_BODY, body_ref);
  w325_store_i32(re, W325_RE_CAP, 0);
  return idx;
}

/**
 * Append with_arena region.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_with_arena(out: *u8, cap_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let re: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  if (out == (0 as *u8) || cap_ref <= 0 || body_ref <= 0) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    rc = grow_vec_push(sc + (W325_REGIONS as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, W325_REGIONS) - 1;
  unsafe {
    re = grow_vec_at(sc + (W325_REGIONS as usize), idx);
  }
  if (re == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memset(re, 0, W325_REGION_SZ as usize);
  }
  w325_store_i32(re, W325_RE_CAP, cap_ref);
  w325_store_i32(re, W325_RE_BODY, body_ref);
  return idx;
}

/**
 * Append unsafe region (cap_ref = -1).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_append_unsafe(out: *u8, body_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let re: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let idx: i32 = 0;
  if (out == (0 as *u8) || body_ref <= 0) {
    return 0 - 1;
  }
  sc = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    rc = grow_vec_push(sc + (W325_REGIONS as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  idx = w325_gv_len(sc, W325_REGIONS) - 1;
  unsafe {
    re = grow_vec_at(sc + (W325_REGIONS as usize), idx);
  }
  if (re == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    memset(re, 0, W325_REGION_SZ as usize);
  }
  w325_store_i32(re, W325_RE_CAP, 0 - 1);
  w325_store_i32(re, W325_RE_BODY, body_ref);
  return idx;
}

/**
 * Count regions.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_regions(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_REGIONS);
}

/**
 * Flush region chain into Block pool.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_regions_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let sc: *u8 = w325_sc(out, 0);
  let re: *u8 = 0 as *u8;
  let i: i32 = 0;
  let cap: i32 = 0;
  let body: i32 = 0;
  let llen: i32 = 0;
  if (a == (0 as *u8) || out == (0 as *u8) || sc == (0 as *u8)) {
    return;
  }
  while (i < count && i < w325_gv_len(sc, W325_REGIONS)) {
    unsafe {
      re = grow_vec_at(sc + (W325_REGIONS as usize), i);
    }
    if (re != (0 as *u8)) {
      cap = w325_load_i32(re, W325_RE_CAP);
      body = w325_load_i32(re, W325_RE_BODY);
      llen = w325_load_i32(re, W325_RE_LABEL_LEN);
      if (cap > 0) {
        unsafe {
          pipeline_block_append_with_arena(a, br, cap, body);
        }
      } else if (cap == (0 - 1)) {
        unsafe {
          pipeline_block_append_unsafe(a, br, body);
        }
      } else if (llen > 0) {
        unsafe {
          pipeline_block_append_region(a, br, re, llen, body);
        }
      }
    }
    i = i + 1;
  }
}

/**
 * Push stmt_order (kind, idx).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_push_stmt_order(out: *u8, kind: u8, idx: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  let pk: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let ki: i32 = 0;
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    rc = grow_vec_push(sc + (W325_SRC_STMT_KIND as usize));
  }
  if (rc < 0) {
    return 0 - 1;
  }
  if (w325_push_i32(sc, W325_SRC_STMT_IDX, idx) < 0) {
    return 0 - 1;
  }
  ki = w325_gv_len(sc, W325_SRC_STMT_KIND) - 1;
  unsafe {
    pk = grow_vec_at(sc + (W325_SRC_STMT_KIND as usize), ki);
  }
  if (pk == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    *pk = kind;
  }
  return ki;
}

/**
 * Count stmt_order.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_src_stmt_order(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_SRC_STMT_KIND);
}

/**
 * Read src_stmt_kind byte.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_src_stmt_kind(out: *u8, i: i32): u8 {
  let sc: *u8 = w325_sc(out, 0);
  let pk: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || i < 0 || i >= w325_gv_len(sc, W325_SRC_STMT_KIND)) {
    return 0;
  }
  unsafe {
    pk = grow_vec_at(sc + (W325_SRC_STMT_KIND as usize), i);
  }
  if (pk == (0 as *u8)) {
    return 0;
  }
  unsafe {
    return *pk;
  }
}

/**
 * Read src_stmt_idx.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_src_stmt_idx(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_SRC_STMT_IDX, i);
}

/**
 * Push body expr_stmt ref.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_push_body_expr_stmt(out: *u8, expr_ref: i32): i32 {
  let sc: *u8 = w325_sc(out, 1);
  if (sc == (0 as *u8)) {
    return 0 - 1;
  }
  return w325_push_i32(sc, W325_SRC_BODY, expr_ref);
}

/**
 * Read body expr_stmt.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_body_expr_stmt_ref(out: *u8, i: i32): i32 {
  let sc: *u8 = w325_sc(out, 0);
  return w325_get_i32(sc, W325_SRC_BODY, i);
}

/**
 * Count body expr_stmts.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_onefunc_num_body_expr_stmts(out: *u8): i32 {
  let sc: *u8 = w325_sc(out, 0);
  if (sc == (0 as *u8)) {
    return 0;
  }
  return w325_gv_len(sc, W325_SRC_BODY);
}

/**
 * Flush ifs into Block (reset num_if_stmts first).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_ifs_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let b: *u8 = 0 as *u8;
  let i: i32 = 0;
  if (a != (0 as *u8) && br > 0) {
    unsafe {
      b = pipeline_arena_block_ptr(a, br);
    }
    if (b != (0 as *u8)) {
      w325_store_i32(b, W325_BLK_NUM_IF, 0);
    }
  }
  while (i < count) {
    unsafe {
      pipeline_block_append_if(a, br, pipeline_onefunc_if_cond_ref(out, i),
                               pipeline_onefunc_if_then_body_ref(out, i),
                               pipeline_onefunc_if_else_body_ref(out, i));
    }
    i = i + 1;
  }
}

/**
 * Flush stmt_order into Block.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_stmt_order_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let i: i32 = 0;
  while (i < count) {
    unsafe {
      pipeline_block_append_stmt_order(a, br, pipeline_onefunc_src_stmt_kind(out, i),
                                       pipeline_onefunc_src_stmt_idx(out, i));
    }
    i = i + 1;
  }
}

/**
 * Flush expr_stmts into Block.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_expr_stmts_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let i: i32 = 0;
  while (i < count) {
    unsafe {
      pipeline_block_append_expr_stmt(a, br, pipeline_onefunc_body_expr_stmt_ref(out, i));
    }
    i = i + 1;
  }
}

/**
 * Flush whiles into Block (debug getenv omitted).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_whiles_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let i: i32 = 0;
  while (i < count) {
    unsafe {
      pipeline_block_append_while(a, br, pipeline_onefunc_while_cond_ref(out, i),
                                  pipeline_onefunc_while_body_ref(out, i));
    }
    i = i + 1;
  }
}

/**
 * Flush fors into Block (debug getenv omitted).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_fill_fors_from_onefunc(a: *u8, br: i32, out: *u8, count: i32): void {
  let i: i32 = 0;
  while (i < count) {
    unsafe {
      pipeline_block_append_for(a, br, pipeline_onefunc_for_init_ref(out, i),
                                pipeline_onefunc_for_cond_ref(out, i),
                                pipeline_onefunc_for_step_ref(out, i),
                                pipeline_onefunc_for_body_ref(out, i));
    }
    i = i + 1;
  }
}
