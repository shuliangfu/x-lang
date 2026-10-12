// Thin pure: wave326/364/526 M2 — block_domain Cap residual C→.x (was wave277 C thin).
// pipeline_block_* append/getters/patch/resolve/stmt_order + ast_ast_block_*.
// G.7: bodies match runtime_pipeline_abi_block_domain_thin.c / seed WAVE277.
// PRODUCT inject: wave364 PREFER; wave526 Soft Cap tip CG002+tipU heal then
//   HARD BAN tip reinject (keep prior overlay). Block 92 / Region 268 / Labeled 528.
// wave364: w326_* helpers via unsafe (T001); PREFER try + L2 gate.
// wave526: libc memmove (ban hand while-copy → Ubuntu tip CG002/SEGV);
//   pipe-cell mid-call tipU heal. Stamp → w526.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_push(v: *u8): i32;
export extern function grow_vec_ensure(v: *u8): i32;
export extern function pipeline_arena_block_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_param_name_len_at(m: *u8, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_param_name_copy32(m: *u8, fi: i32, pi: i32, dst: *u8): void;
export extern function implicit_tail_expr_disallowed_by_glue(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_apply_call_resolve(a: *u8, call_expr_ref: i32, dep_ix: i32, func_ix: i32): void;
export extern function pipeline_type_kind_ord_at(a: *u8, ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32;
export extern function pipeline_expr_struct_lit_type_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_set(a: *u8, expr_ref: i32, name: *u8, name_len: i32): void;
export extern function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function xlang_size_slot_get(arr: *u8, i: i32): i64;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function memmove(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;

/**
 * Overlap-safe byte move via libc memmove (tip Soft Cap).
 * wave526: hand while-copy loops → Ubuntu tip CG002/SEGV; keep overlap-safe
 * grow-vec insert slides. PLATFORM: SHARED Soft Cap tip CG002 heal.
 */
function w326_memmove(dst: *u8, src: *u8, n: usize): void {
  if (dst == src || n == (0 as usize)) {
    return;
  }
  unsafe {
    memmove(dst, src, n);
  }
}

/**
 * arena_sidecar_get via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_sidecar_get(key: *u8, create: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, arena_sidecar_get(key, create));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

/**
 * pipeline_arena_block_ptr via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_arena_block_ptr(a: *u8, ref: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_block_ptr(a, ref));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

/**
 * grow_vec_push via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_grow_vec_push(v: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, grow_vec_push(v));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * grow_vec_ensure via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_grow_vec_ensure(v: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, grow_vec_ensure(v));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * memcmp via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_memcmp(a: *u8, b: *u8, n: usize): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, memcmp(a, b, n));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_kind_ord_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_kind_ord_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_kind_ord_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_block_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_block_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_block_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_binop_left_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_binop_left_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_binop_right_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_binop_right_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_unary_operand_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_unary_operand_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_if_then_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_if_then_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_if_then_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_if_else_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_if_else_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_if_else_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_call_callee_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_call_callee_ref_at(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_call_callee_ref_at(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_type_kind_ord_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_type_kind_ord_at(a: *u8, ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_type_kind_ord_at(a, ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_type_named_name_into via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_type_named_name_into(arena: *u8, ref: i32, out64: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_type_named_name_into(arena, ref, out64));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_struct_lit_type_name_len via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_struct_lit_type_name_len(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_struct_lit_type_name_len(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_struct_lit_type_name_set (tipU: keep void U on Ubuntu tip).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_struct_lit_type_name_set(a: *u8, expr_ref: i32, name: *u8, name_len: i32): void {
  unsafe {
    pipeline_expr_struct_lit_type_name_set(a, expr_ref, name, name_len);
  }
}

/**
 * pipeline_module_func_body_ref_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_module_func_body_ref_at(m: *u8, fi: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_module_func_body_ref_at(m, fi));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_module_num_funcs via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_module_num_funcs(m: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_module_num_funcs(m));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_module_func_num_params_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_module_func_num_params_at(m: *u8, fi: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_module_func_num_params_at(m, fi));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_module_func_param_name_len_at via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_module_func_param_name_len_at(m: *u8, fi: i32, pi: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_module_func_param_name_len_at(m, fi, pi));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_module_func_param_name_copy32 (tipU: keep void U on Ubuntu tip).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_module_func_param_name_copy32(m: *u8, fi: i32, pi: i32, dst: *u8): void {
  unsafe {
    pipeline_module_func_param_name_copy32(m, fi, pi, dst);
  }
}

/**
 * implicit_tail_expr_disallowed_by_glue via pipe-cell (tipU mid-call ban).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_implicit_tail_disallowed(a: *u8, expr_ref: i32): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, implicit_tail_expr_disallowed_by_glue(a, expr_ref));
    return pipe_load_i32_le(&icell[0], 0);
  }
}

/**
 * pipeline_expr_apply_call_resolve (tipU: keep void U on Ubuntu tip).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_expr_apply_call_resolve(a: *u8, call_expr_ref: i32, dep_ix: i32, func_ix: i32): void {
  unsafe {
    pipeline_expr_apply_call_resolve(a, call_expr_ref, dep_ix, func_ix);
  }
}




/**
 * memcpy via pipe-cell (tipU: ban mid `memcpy()` drop on Ubuntu tip).
 * PLATFORM: SHARED Soft Cap tipU heal (wave526).
 */
function w526_memcpy(dst: *u8, src: *u8, n: usize): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, memcpy(dst, src, n));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}

const W326_GV_LEN: i32 = 12;
const W326_ARENA_NUM_BLOCKS: i32 = 8;
const W326_ARENA_NUM_EXPRS: i32 = 4;
const W326_SO_KIND: i32 = 0;
const W326_SO_IDX: i32 = 4;
const W326_SO_SZ: i32 = 8;
const W326_CONST_SZ: i32 = 268;
const W326_CD_NAME_LEN: i32 = 256;
const W326_CD_TYPE: i32 = 260;
const W326_CD_INIT: i32 = 264;
const W326_IF_COND: i32 = 0;
const W326_IF_THEN: i32 = 4;
const W326_IF_ELSE: i32 = 8;
const W326_WH_COND: i32 = 0;
const W326_WH_BODY: i32 = 4;
const W326_FOR_INIT: i32 = 0;
const W326_FOR_COND: i32 = 4;
const W326_FOR_STEP: i32 = 8;
const W326_FOR_BODY: i32 = 12;
const W326_RE_LABEL_LEN: i32 = 256;
const W326_RE_BODY: i32 = 260;
const W326_RE_CAP: i32 = 264;
const W326_RE_SZ: i32 = 268;
const W326_LE_LABEL_LEN: i32 = 256;
const W326_LE_IS_GOTO: i32 = 260;
const W326_LE_GOTO: i32 = 264;
const W326_LE_GOTO_LEN: i32 = 520;
const W326_LE_RET: i32 = 524;
const W326_LE_SZ: i32 = 528;
const W326_SC_CONSTS: i32 = 144;
const W326_SC_LETS: i32 = 176;
const W326_SC_IFS: i32 = 208;
const W326_SC_REGIONS: i32 = 240;
const W326_SC_LOOPS: i32 = 272;
const W326_SC_FOR_LOOPS: i32 = 304;
const W326_SC_DEFER: i32 = 336;
const W326_SC_LABELED: i32 = 368;
const W326_SC_EXPR_STMT: i32 = 400;
const W326_SC_STMT_ORDER: i32 = 432;
const W326_B_CONST_BASE: i32 = 0;
const W326_B_NUM_CONSTS: i32 = 4;
const W326_B_LET_BASE: i32 = 8;
const W326_B_NUM_LETS: i32 = 12;
const W326_B_NUM_EARLY_LETS: i32 = 16;
const W326_B_LOOP_BASE: i32 = 20;
const W326_B_NUM_LOOPS: i32 = 24;
const W326_B_FOR_LOOP_BASE: i32 = 28;
const W326_B_NUM_FOR_LOOPS: i32 = 32;
const W326_B_IF_BASE: i32 = 36;
const W326_B_NUM_IF_STMTS: i32 = 40;
const W326_B_REGION_BASE: i32 = 44;
const W326_B_NUM_REGIONS: i32 = 48;
const W326_B_DEFER_BASE: i32 = 52;
const W326_B_NUM_DEFERS: i32 = 56;
const W326_B_LABELED_BASE: i32 = 60;
const W326_B_NUM_LABELED_STMTS: i32 = 64;
const W326_B_EXPR_STMT_BASE: i32 = 68;
const W326_B_NUM_EXPR_STMTS: i32 = 72;
const W326_B_FINAL_EXPR_REF: i32 = 76;
const W326_B_STMT_ORDER_BASE: i32 = 80;
const W326_B_NUM_STMT_ORDER: i32 = 84;
const W326_B_PARENT_BLOCK_REF: i32 = 88;

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 */
function w326_load(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 */
function w326_store(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * GrowVec.len via unsafe LE (T001). PLATFORM: SHARED.
 */
function w326_gv_len(v: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(v, W326_GV_LEN);
  }
}

/**
 * GrowVec data ptr via unsafe (T001). PLATFORM: SHARED.
 */
function w326_gv_data(v: *u8): *u8 {
  unsafe {
    return xlang_ptr_slot_get(v, 0);
  }
}

/**
 * GrowVec elem size via unsafe (T001). PLATFORM: SHARED.
 */
function w326_gv_elem_sz(v: *u8): i64 {
  unsafe {
    return xlang_size_slot_get(v, 2);
  }
}

function w326_sc(a: *u8, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let cf: i32 = 0;
  if (a == (0 as *u8)) { return 0 as *u8; }
  if (create != 0) { cf = 1; }
  unsafe { sc = w526_sidecar_get(a, cf); }
  return sc;
}

function w326_block_at(a: *u8, br: i32): *u8 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0 as *u8; }
  unsafe { b = w526_arena_block_ptr(a, br); }
  return b;
}

function w326_arena_num_blocks(a: *u8): i32 {
  return w326_load(a, W326_ARENA_NUM_BLOCKS);
}
function w326_arena_num_exprs(a: *u8): i32 {
  return w326_load(a, W326_ARENA_NUM_EXPRS);
}

/**
 * Insert-and-shift pool append for per-block contiguous ranges.
 * PLATFORM: SHARED — matches C block_pool_append_pos.
 */
function w326_pool_append_pos(a: *u8, br: i32, pool: *u8, base_off: i32, num_before: i32): i32 {
  let b: *u8 = w326_block_at(a, br);
  let base_field: i32 = 0;
  let abs_pos: i32 = 0;
  let esz: i64 = 0;
  let move_count: i32 = 0;
  let bi: i32 = 0;
  let data: *u8 = 0 as *u8;
  let ob: *u8 = 0 as *u8;
  let ob_base: i32 = 0;
  let rc: i32 = 0;
  if (a == (0 as *u8) || pool == (0 as *u8) || b == (0 as *u8)) {
    return 0 - 1;
  }
  base_field = w326_load(b, base_off);
  if (num_before == 0) {
    unsafe { abs_pos = w526_grow_vec_push(pool); }
    if (abs_pos < 0) { return 0 - 1; }
    w326_store(b, base_off, abs_pos);
    return abs_pos;
  }
  abs_pos = base_field + num_before;
  if (abs_pos >= w326_gv_len(pool)) {
    unsafe { abs_pos = w526_grow_vec_push(pool); }
    if (abs_pos < 0) { return 0 - 1; }
    return abs_pos;
  }
  unsafe { rc = w526_grow_vec_ensure(pool); }
  if (rc == 0) { return 0 - 1; }
  esz = w326_gv_elem_sz(pool);
  data = w326_gv_data(pool);
  move_count = w326_gv_len(pool) - abs_pos;
  if (move_count > 0 && data != (0 as *u8)) {
    unsafe {
      w326_memmove(data + ((((abs_pos + 1) as i64) * esz) as usize),
                   data + (((abs_pos as i64) * esz) as usize),
                   ((move_count as i64) * esz) as usize);
    }
  }
  if (data != (0 as *u8)) {
    unsafe {
      memset(data + (((abs_pos as i64) * esz) as usize), 0, esz as usize);
    }
  }
  w326_store(pool, W326_GV_LEN, w326_gv_len(pool) + 1);
  bi = 1;
  while (bi <= w326_arena_num_blocks(a)) {
    if (bi != br) {
      ob = w326_block_at(a, bi);
      if (ob != (0 as *u8)) {
        ob_base = w326_load(ob, base_off);
        if (ob_base >= abs_pos) {
          w326_store(ob, base_off, ob_base + 1);
        }
      }
    }
    bi = bi + 1;
  }
  return abs_pos;
}

function w326_const_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_CONSTS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_CONST_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_CONSTS as usize), abs);
  }
}

function w326_let_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_LETS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_LET_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_LETS as usize), abs);
  }
}

function w326_if_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_IF_STMTS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_IF_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_IFS as usize), abs);
  }
}

function w326_while_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_LOOPS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_LOOP_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_LOOPS as usize), abs);
  }
}

function w326_for_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_FOR_LOOPS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_FOR_LOOP_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_FOR_LOOPS as usize), abs);
  }
}

function w326_region_at(a: *u8, br: i32, i: i32): *u8 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || i < 0 || i >= w326_load(b, W326_B_NUM_REGIONS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_REGION_BASE) + i;
  unsafe {
    return grow_vec_at(sc + (W326_SC_REGIONS as usize), abs);
  }
}

/**
 * Append const decl.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_const(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let n: i32 = 0;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) {
    return 0 - 1;
  }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_CONSTS as usize), W326_B_CONST_BASE, w326_load(b, W326_B_NUM_CONSTS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_CONSTS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_CONST_SZ as usize); }
  n = name_len;
  if (n > 255) { n = 255; }
  if (n > 0 && name != (0 as *u8)) {
    unsafe { w526_memcpy(e, name, n as usize); }
  }
  w326_store(e, W326_CD_NAME_LEN, n);
  w326_store(e, W326_CD_TYPE, type_ref);
  w326_store(e, W326_CD_INIT, init_ref);
  w326_store(b, W326_B_NUM_CONSTS, w326_load(b, W326_B_NUM_CONSTS) + 1);
  base = w326_load(b, W326_B_CONST_BASE);
  return idx - base;
}

/**
 * Append let decl.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_let(a: *u8, br: i32, name: *u8, name_len: i32, type_ref: i32, init_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let n: i32 = 0;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) {
    return 0 - 1;
  }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_LETS as usize), W326_B_LET_BASE, w326_load(b, W326_B_NUM_LETS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_LETS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_CONST_SZ as usize); }
  n = name_len;
  if (n > 255) { n = 255; }
  if (n > 0 && name != (0 as *u8)) {
    unsafe { w526_memcpy(e, name, n as usize); }
  }
  w326_store(e, W326_CD_NAME_LEN, n);
  w326_store(e, W326_CD_TYPE, type_ref);
  w326_store(e, W326_CD_INIT, init_ref);
  w326_store(b, W326_B_NUM_LETS, w326_load(b, W326_B_NUM_LETS) + 1);
  base = w326_load(b, W326_B_LET_BASE);
  return idx - base;
}

/**
 * Append if stmt.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_if(a: *u8, br: i32, cond_ref: i32, then_ref: i32, else_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_IFS as usize), W326_B_IF_BASE, w326_load(b, W326_B_NUM_IF_STMTS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_IFS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  w326_store(e, W326_IF_COND, cond_ref);
  w326_store(e, W326_IF_THEN, then_ref);
  w326_store(e, W326_IF_ELSE, else_ref);
  w326_store(b, W326_B_NUM_IF_STMTS, w326_load(b, W326_B_NUM_IF_STMTS) + 1);
  base = w326_load(b, W326_B_IF_BASE);
  return idx - base;
}

/**
 * Append region with label.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_region(a: *u8, br: i32, label: *u8, label_len: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8) || label == (0 as *u8) || label_len <= 0 || label_len > 255) {
    return 0 - 1;
  }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_REGIONS as usize), W326_B_REGION_BASE, w326_load(b, W326_B_NUM_REGIONS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_REGIONS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_RE_SZ as usize); w526_memcpy(e, label, label_len as usize); }
  w326_store(e, W326_RE_LABEL_LEN, label_len);
  w326_store(e, W326_RE_BODY, body_ref);
  w326_store(e, W326_RE_CAP, 0);
  w326_store(b, W326_B_NUM_REGIONS, w326_load(b, W326_B_NUM_REGIONS) + 1);
  base = w326_load(b, W326_B_REGION_BASE);
  return idx - base;
}

/**
 * Append with_arena region.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_with_arena(a: *u8, br: i32, cap_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8) || cap_ref <= 0 || body_ref <= 0) {
    return 0 - 1;
  }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_REGIONS as usize), W326_B_REGION_BASE, w326_load(b, W326_B_NUM_REGIONS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_REGIONS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_RE_SZ as usize); }
  w326_store(e, W326_RE_CAP, cap_ref);
  w326_store(e, W326_RE_BODY, body_ref);
  w326_store(b, W326_B_NUM_REGIONS, w326_load(b, W326_B_NUM_REGIONS) + 1);
  base = w326_load(b, W326_B_REGION_BASE);
  return idx - base;
}

/**
 * Append unsafe region (cap=-1).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_block_append_unsafe(a: *u8, br: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8) || body_ref <= 0) {
    return 0 - 1;
  }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_REGIONS as usize), W326_B_REGION_BASE, w326_load(b, W326_B_NUM_REGIONS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_REGIONS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_RE_SZ as usize); }
  w326_store(e, W326_RE_CAP, 0 - 1);
  w326_store(e, W326_RE_BODY, body_ref);
  w326_store(b, W326_B_NUM_REGIONS, w326_load(b, W326_B_NUM_REGIONS) + 1);
  base = w326_load(b, W326_B_REGION_BASE);
  return idx - base;
}

#[no_mangle]
export function pipeline_block_region_with_arena_cap_ref(a: *u8, br: i32, ri: i32): i32 {
  let rb: *u8 = w326_region_at(a, br, ri);
  let cap: i32 = 0;
  if (rb == (0 as *u8)) { return 0; }
  cap = w326_load(rb, W326_RE_CAP);
  if (cap > 0) { return cap; }
  return 0;
}
#[no_mangle]
export function pipeline_block_region_is_unsafe(a: *u8, br: i32, ri: i32): i32 {
  let rb: *u8 = w326_region_at(a, br, ri);
  if (rb == (0 as *u8)) { return 0; }
  if (w326_load(rb, W326_RE_CAP) == (0 - 1)) { return 1; }
  return 0;
}
#[no_mangle]
export function pipeline_block_region_body_ref(a: *u8, br: i32, ri: i32): i32 {
  let rb: *u8 = w326_region_at(a, br, ri);
  if (rb == (0 as *u8)) { return 0; }
  return w326_load(rb, W326_RE_BODY);
}
#[no_mangle]
export function pipeline_block_region_label_len(a: *u8, br: i32, ri: i32): i32 {
  let rb: *u8 = w326_region_at(a, br, ri);
  let n: i32 = 0;
  if (rb == (0 as *u8)) { return 0; }
  n = w326_load(rb, W326_RE_LABEL_LEN);
  if (n > 0) { return n; }
  return 0;
}
#[no_mangle]
export function pipeline_block_region_label_copy64(a: *u8, br: i32, ri: i32, dst: *u8): void {
  let rb: *u8 = 0 as *u8;
  let n: i32 = 0;
  if (dst == (0 as *u8)) { return; }
  unsafe { memset(dst, 0, 64 as usize); }
  rb = w326_region_at(a, br, ri);
  if (rb == (0 as *u8)) { return; }
  n = w326_load(rb, W326_RE_LABEL_LEN);
  if (n <= 0) { return; }
  unsafe { w526_memcpy(dst, rb, n as usize); }
}

#[no_mangle]
export function pipeline_block_append_defer(a: *u8, br: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let pr: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8) || body_ref <= 0) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_DEFER as usize), W326_B_DEFER_BASE, w326_load(b, W326_B_NUM_DEFERS));
  if (idx < 0) { return 0 - 1; }
  unsafe { pr = grow_vec_at(sc + (W326_SC_DEFER as usize), idx); }
  if (pr == (0 as *u8)) { return 0 - 1; }
  w326_store(pr, 0, body_ref);
  w326_store(b, W326_B_NUM_DEFERS, w326_load(b, W326_B_NUM_DEFERS) + 1);
  base = w326_load(b, W326_B_DEFER_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_defer_body_ref(a: *u8, br: i32, di: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  let pr: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || b == (0 as *u8) || di < 0 || di >= w326_load(b, W326_B_NUM_DEFERS)) { return 0; }
  abs = w326_load(b, W326_B_DEFER_BASE) + di;
  unsafe { pr = grow_vec_at(sc + (W326_SC_DEFER as usize), abs); }
  if (pr == (0 as *u8)) { return 0; }
  return w326_load(pr, 0);
}
#[no_mangle]
export function pipeline_block_append_expr_stmt(a: *u8, br: i32, expr_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let pr: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_EXPR_STMT as usize), W326_B_EXPR_STMT_BASE, w326_load(b, W326_B_NUM_EXPR_STMTS));
  if (idx < 0) { return 0 - 1; }
  unsafe { pr = grow_vec_at(sc + (W326_SC_EXPR_STMT as usize), idx); }
  if (pr == (0 as *u8)) { return 0 - 1; }
  w326_store(pr, 0, expr_ref);
  w326_store(b, W326_B_NUM_EXPR_STMTS, w326_load(b, W326_B_NUM_EXPR_STMTS) + 1);
  base = w326_load(b, W326_B_EXPR_STMT_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_append_stmt_order(a: *u8, br: i32, kind: u8, idx_val: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let so: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_STMT_ORDER as usize), W326_B_STMT_ORDER_BASE, w326_load(b, W326_B_NUM_STMT_ORDER));
  if (idx < 0) { return 0 - 1; }
  unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), idx); }
  if (so == (0 as *u8)) { return 0 - 1; }
  unsafe { so[0] = kind; }
  w326_store(so, W326_SO_IDX, idx_val);
  w326_store(b, W326_B_NUM_STMT_ORDER, w326_load(b, W326_B_NUM_STMT_ORDER) + 1);
  base = w326_load(b, W326_B_STMT_ORDER_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_append_while(a: *u8, br: i32, cond_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_LOOPS as usize), W326_B_LOOP_BASE, w326_load(b, W326_B_NUM_LOOPS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_LOOPS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, 8 as usize); }
  w326_store(e, W326_WH_COND, cond_ref);
  w326_store(e, W326_WH_BODY, body_ref);
  w326_store(b, W326_B_NUM_LOOPS, w326_load(b, W326_B_NUM_LOOPS) + 1);
  base = w326_load(b, W326_B_LOOP_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_append_for(a: *u8, br: i32, init_ref: i32, cond_ref: i32, step_ref: i32, body_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_FOR_LOOPS as usize), W326_B_FOR_LOOP_BASE, w326_load(b, W326_B_NUM_FOR_LOOPS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_FOR_LOOPS as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  w326_store(e, W326_FOR_INIT, init_ref);
  w326_store(e, W326_FOR_COND, cond_ref);
  w326_store(e, W326_FOR_STEP, step_ref);
  w326_store(e, W326_FOR_BODY, body_ref);
  w326_store(b, W326_B_NUM_FOR_LOOPS, w326_load(b, W326_B_NUM_FOR_LOOPS) + 1);
  base = w326_load(b, W326_B_FOR_LOOP_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_append_labeled(a: *u8, br: i32, label_len: i32, is_goto: i32, goto_target_len: i32, return_expr_ref: i32): i32 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let idx: i32 = 0;
  let e: *u8 = 0 as *u8;
  let base: i32 = 0;
  if (a == (0 as *u8) || sc == (0 as *u8) || b == (0 as *u8)) { return 0 - 1; }
  idx = w326_pool_append_pos(a, br, sc + (W326_SC_LABELED as usize), W326_B_LABELED_BASE, w326_load(b, W326_B_NUM_LABELED_STMTS));
  if (idx < 0) { return 0 - 1; }
  unsafe { e = grow_vec_at(sc + (W326_SC_LABELED as usize), idx); }
  if (e == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(e, 0, W326_LE_SZ as usize); }
  w326_store(e, W326_LE_LABEL_LEN, label_len);
  w326_store(e, W326_LE_IS_GOTO, is_goto);
  w326_store(e, W326_LE_GOTO_LEN, goto_target_len);
  w326_store(e, W326_LE_RET, return_expr_ref);
  w326_store(b, W326_B_NUM_LABELED_STMTS, w326_load(b, W326_B_NUM_LABELED_STMTS) + 1);
  base = w326_load(b, W326_B_LABELED_BASE);
  return idx - base;
}
#[no_mangle]
export function pipeline_block_labeled_ptr(a: *u8, br: i32, li: i32): *u8 {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  if (sc == (0 as *u8) || b == (0 as *u8) || li < 0 || li >= w326_load(b, W326_B_NUM_LABELED_STMTS)) {
    return 0 as *u8;
  }
  abs = w326_load(b, W326_B_LABELED_BASE) + li;
  unsafe { return grow_vec_at(sc + (W326_SC_LABELED as usize), abs); }
}

#[no_mangle]
export function pipeline_block_while_cond_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_while_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_WH_COND);
}

#[no_mangle]
export function pipeline_block_while_body_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_while_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_WH_BODY);
}

#[no_mangle]
export function pipeline_block_for_init_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_for_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_FOR_INIT);
}

#[no_mangle]
export function pipeline_block_for_cond_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_for_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_FOR_COND);
}

#[no_mangle]
export function pipeline_block_for_step_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_for_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_FOR_STEP);
}

#[no_mangle]
export function pipeline_block_for_body_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_for_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_FOR_BODY);
}

#[no_mangle]
export function pipeline_block_if_cond_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_if_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_IF_COND);
}

#[no_mangle]
export function pipeline_block_if_then_body_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_if_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_IF_THEN);
}

#[no_mangle]
export function pipeline_block_if_else_body_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_if_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_IF_ELSE);
}

#[no_mangle]
export function pipeline_block_const_init_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_const_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_INIT);
}

#[no_mangle]
export function pipeline_block_const_type_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_const_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_TYPE);
}

#[no_mangle]
export function pipeline_block_const_name_len(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_const_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_NAME_LEN);
}

#[no_mangle]
export function pipeline_block_let_init_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_let_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_INIT);
}

#[no_mangle]
export function pipeline_block_let_type_ref(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_let_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_TYPE);
}

#[no_mangle]
export function pipeline_block_let_name_len(a: *u8, br: i32, i: i32): i32 {
  let e: *u8 = w326_let_at(a, br, i);
  if (e == (0 as *u8)) { return 0; }
  return w326_load(e, W326_CD_NAME_LEN);
}

#[no_mangle]
export function pipeline_block_labeled_return_expr_ref(a: *u8, br: i32, li: i32): i32 {
  let ls: *u8 = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return 0; }
  return w326_load(ls, W326_LE_RET);
}
#[no_mangle]
export function pipeline_block_num_labeled_stmts(a: *u8, br: i32): i32 {
  let b: *u8 = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_LABELED_STMTS);
}
#[no_mangle]
export function pipeline_block_labeled_is_goto(a: *u8, br: i32, li: i32): i32 {
  let ls: *u8 = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return 0; }
  return w326_load(ls, W326_LE_IS_GOTO);
}
#[no_mangle]
export function pipeline_block_labeled_label_len(a: *u8, br: i32, li: i32): i32 {
  let ls: *u8 = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return 0; }
  return w326_load(ls, W326_LE_LABEL_LEN);
}
#[no_mangle]
export function pipeline_block_labeled_goto_target_len(a: *u8, br: i32, li: i32): i32 {
  let ls: *u8 = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return 0; }
  return w326_load(ls, W326_LE_GOTO_LEN);
}
#[no_mangle]
export function pipeline_block_labeled_label_copy32(a: *u8, br: i32, li: i32, dst: *u8): void {
  let ls: *u8 = 0 as *u8;
  let n: i32 = 0;
  if (dst == (0 as *u8)) { return; }
  unsafe { memset(dst, 0, 256 as usize); }
  ls = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return; }
  n = w326_load(ls, W326_LE_LABEL_LEN);
  if (n <= 0) { return; }
  if (n > 127) { n = 127; }
  unsafe { w526_memcpy(dst, ls, n as usize); }
}
#[no_mangle]
export function pipeline_block_labeled_goto_target_copy32(a: *u8, br: i32, li: i32, dst: *u8): void {
  let ls: *u8 = 0 as *u8;
  let n: i32 = 0;
  if (dst == (0 as *u8)) { return; }
  unsafe { memset(dst, 0, 256 as usize); }
  ls = pipeline_block_labeled_ptr(a, br, li);
  if (ls == (0 as *u8)) { return; }
  n = w326_load(ls, W326_LE_GOTO_LEN);
  if (n <= 0) { return; }
  if (n > 127) { n = 127; }
  unsafe { w526_memcpy(dst, ls + (W326_LE_GOTO as usize), n as usize); }
}
#[no_mangle]
export function pipeline_block_const_name_copy64(a: *u8, br: i32, ci: i32, dst: *u8): void {
  let e: *u8 = 0 as *u8;
  let n: i32 = 0;
  if (dst == (0 as *u8)) { return; }
  unsafe { memset(dst, 0, 256 as usize); }
  e = w326_const_at(a, br, ci);
  if (e == (0 as *u8)) { return; }
  n = w326_load(e, W326_CD_NAME_LEN);
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (n > 0) { unsafe { w526_memcpy(dst, e, n as usize); } }
}
#[no_mangle]
export function pipeline_block_let_name_copy64(a: *u8, br: i32, li: i32, dst: *u8): void {
  let e: *u8 = 0 as *u8;
  let n: i32 = 0;
  if (dst == (0 as *u8)) { return; }
  unsafe { memset(dst, 0, 256 as usize); }
  e = w326_let_at(a, br, li);
  if (e == (0 as *u8)) { return; }
  n = w326_load(e, W326_CD_NAME_LEN);
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (n > 0) { unsafe { w526_memcpy(dst, e, n as usize); } }
}
#[no_mangle]
export function pipeline_block_set_let_type_ref(a: *u8, br: i32, li: i32, type_ref: i32): i32 {
  let e: *u8 = w326_let_at(a, br, li);
  if (e == (0 as *u8)) { return 0; }
  w326_store(e, W326_CD_TYPE, type_ref);
  return 1;
}
#[no_mangle]
export function pipeline_block_set_const_type_ref(a: *u8, br: i32, ci: i32, type_ref: i32): i32 {
  let e: *u8 = w326_const_at(a, br, ci);
  if (e == (0 as *u8)) { return 0; }
  w326_store(e, W326_CD_TYPE, type_ref);
  return 1;
}
#[no_mangle]
export function pipeline_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  let pr: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || b == (0 as *u8) || ei < 0 || ei >= w326_load(b, W326_B_NUM_EXPR_STMTS)) { return 0; }
  abs = w326_load(b, W326_B_EXPR_STMT_BASE) + ei;
  unsafe { pr = grow_vec_at(sc + (W326_SC_EXPR_STMT as usize), abs); }
  if (pr == (0 as *u8)) { return 0; }
  return w326_load(pr, 0);
}
#[no_mangle]
export function pipeline_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  let so: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || b == (0 as *u8) || si < 0 || si >= w326_load(b, W326_B_NUM_STMT_ORDER)) { return 0; }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE) + si;
  unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), abs); }
  if (so == (0 as *u8)) { return 0; }
  unsafe { return so[0]; }
}
#[no_mangle]
export function pipeline_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32 {
  let sc: *u8 = w326_sc(a, 0);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  let so: *u8 = 0 as *u8;
  if (sc == (0 as *u8) || b == (0 as *u8) || si < 0 || si >= w326_load(b, W326_B_NUM_STMT_ORDER)) { return 0; }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE) + si;
  unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), abs); }
  if (so == (0 as *u8)) { return 0; }
  return w326_load(so, W326_SO_IDX);
}

/**
 * Recurse expr tree for EXPR_BLOCK parent links.
 * PLATFORM: SHARED
 */
function w326_expr_has_inner_block(a: *u8, expr_ref: i32, parent_block: i32, depth: i32): i32 {
  let kind: i32 = 0;
  let inner_blk: i32 = 0;
  let ne: i32 = 0;
  let left: i32 = 0;
  let right: i32 = 0;
  let op: i32 = 0;
  let th: i32 = 0;
  let el: i32 = 0;
  let br: i32 = 0;
  let cal: i32 = 0;
  let ib: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || depth > 64) { return 0; }
  ne = w326_arena_num_exprs(a);
  if (expr_ref > ne) { return 0; }
  unsafe { kind = w526_expr_kind_ord_at(a, expr_ref); }
  if (kind == 26) {
    unsafe { inner_blk = w526_expr_block_ref_at(a, expr_ref); }
    if (inner_blk > 0) {
      ib = w326_block_at(a, inner_blk);
      if (ib != (0 as *u8) && w326_load(ib, W326_B_PARENT_BLOCK_REF) == 0) {
        w326_store(ib, W326_B_PARENT_BLOCK_REF, parent_block);
      }
      w326_patch_block_expr_parents(a, inner_blk);
    }
  }
  unsafe {
    left = w526_expr_binop_left_ref_at(a, expr_ref);
    right = w526_expr_binop_right_ref_at(a, expr_ref);
    op = w526_expr_unary_operand_ref_at(a, expr_ref);
    th = w526_expr_if_then_ref_at(a, expr_ref);
    el = w526_expr_if_else_ref_at(a, expr_ref);
    br = w526_expr_block_ref_at(a, expr_ref);
    cal = w526_expr_call_callee_ref_at(a, expr_ref);
  }
  if (left > 0) { w326_expr_has_inner_block(a, left, parent_block, depth + 1); }
  if (right > 0) { w326_expr_has_inner_block(a, right, parent_block, depth + 1); }
  if (op > 0) { w326_expr_has_inner_block(a, op, parent_block, depth + 1); }
  if (th > 0) { w326_expr_has_inner_block(a, th, parent_block, depth + 1); }
  if (el > 0) { w326_expr_has_inner_block(a, el, parent_block, depth + 1); }
  if (br > 0 && kind != 26) { w326_expr_has_inner_block(a, br, parent_block, depth + 1); }
  if (cal > 0) { w326_expr_has_inner_block(a, cal, parent_block, depth + 1); }
  return 0;
}

/**
 * Patch EXPR_BLOCK parents in block expr stmts / final.
 * PLATFORM: SHARED
 */
function w326_patch_block_expr_parents(a: *u8, block_ref: i32): void {
  let b: *u8 = 0 as *u8;
  let i: i32 = 0;
  let ne: i32 = 0;
  let nf: i32 = 0;
  let es_ref: i32 = 0;
  if (a == (0 as *u8) || block_ref <= 0 || block_ref > w326_arena_num_blocks(a)) { return; }
  b = w326_block_at(a, block_ref);
  if (b == (0 as *u8)) { return; }
  ne = w326_load(b, W326_B_NUM_EXPR_STMTS);
  while (i < ne) {
    es_ref = pipeline_block_expr_stmt_ref(a, block_ref, i);
    if (es_ref > 0 && es_ref <= w326_arena_num_exprs(a)) {
      w326_expr_has_inner_block(a, es_ref, block_ref, 0);
    }
    i = i + 1;
  }
  nf = w326_load(b, W326_B_FINAL_EXPR_REF);
  if (nf > 0 && nf <= w326_arena_num_exprs(a)) {
    w326_expr_has_inner_block(a, nf, block_ref, 0);
  }
}

/**
 * Stamp return STRUCT_LIT with enclosing named return type.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function glue_stamp_return_lits_in_block_c(a: *u8, block_ref: i32, rty: i32): void {
  let stack_blk: i32[256] = [];
  let sp: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let ne: i32 = 0;
  let er: i32 = 0;
  let nlen: i32 = 0;
  let nbuf: u8[256] = [];
  let b: *u8 = 0 as *u8;
  let rop: i32 = 0;
  let wb: i32 = 0;
  let fb: i32 = 0;
  let tb: i32 = 0;
  let eb: i32 = 0;
  let rgb: i32 = 0;
  if (a == (0 as *u8) || block_ref <= 0 || rty <= 0) { return; }
  unsafe {
    if (w526_type_kind_ord_at(a, rty) != 8) { return; }
    nlen = w526_type_named_name_into(a, rty, &nbuf[0]);
  }
  if (nlen <= 0 || nlen > 255) { return; }
  stack_blk[0] = block_ref;
  sp = 1;
  while (sp > 0) {
    sp = sp - 1;
    cur = stack_blk[sp];
    if (cur <= 0 || cur > w326_arena_num_blocks(a)) { continue; }
    b = w326_block_at(a, cur);
    if (b == (0 as *u8)) { continue; }
    ne = ast_ast_block_num_expr_stmts(a, cur);
    i = 0;
    while (i < ne) {
      er = pipeline_block_expr_stmt_ref(a, cur, i);
      unsafe {
        if (er > 0 && w526_expr_kind_ord_at(a, er) == 41) {
          rop = w526_expr_unary_operand_ref_at(a, er);
          if (rop > 0 && w526_expr_kind_ord_at(a, rop) == 45 && w526_struct_lit_type_name_len(a, rop) <= 0) {
            w526_struct_lit_type_name_set(a, rop, &nbuf[0], nlen);
          }
        }
      }
      i = i + 1;
    }
    er = ast_ast_block_final_expr_ref(a, cur);
    unsafe {
      if (er > 0 && w526_expr_kind_ord_at(a, er) == 41) {
        rop = w526_expr_unary_operand_ref_at(a, er);
        if (rop > 0 && w526_expr_kind_ord_at(a, rop) == 45 && w526_struct_lit_type_name_len(a, rop) <= 0) {
          w526_struct_lit_type_name_set(a, rop, &nbuf[0], nlen);
        }
      }
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_LOOPS)) {
      wb = pipeline_block_while_body_ref(a, cur, i);
      if (wb > 0 && sp < 256) { stack_blk[sp] = wb; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_FOR_LOOPS)) {
      fb = pipeline_block_for_body_ref(a, cur, i);
      if (fb > 0 && sp < 256) { stack_blk[sp] = fb; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_IF_STMTS)) {
      tb = pipeline_block_if_then_body_ref(a, cur, i);
      if (tb > 0 && sp < 256) { stack_blk[sp] = tb; sp = sp + 1; }
      eb = pipeline_block_if_else_body_ref(a, cur, i);
      if (eb > 0 && sp < 256) { stack_blk[sp] = eb; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_REGIONS)) {
      rgb = pipeline_block_region_body_ref(a, cur, i);
      if (rgb > 0 && sp < 256) { stack_blk[sp] = rgb; sp = sp + 1; }
      i = i + 1;
    }
  }
}

/**
 * Patch nested block parent_block_ref (explicit stack).
 * PLATFORM: SHARED
 */
#[no_mangle]
export function pipeline_patch_block_parent_links(a: *u8, block_ref: i32, parent_ref: i32): void {
  let stack_blk: i32[256] = [];
  let stack_par: i32[256] = [];
  let sp: i32 = 0;
  let cur: i32 = 0;
  let par: i32 = 0;
  let i: i32 = 0;
  let b: *u8 = 0 as *u8;
  let wb: i32 = 0;
  let fb: i32 = 0;
  let tb: i32 = 0;
  let eb: i32 = 0;
  let rgb: i32 = 0;
  if (a == (0 as *u8) || block_ref <= 0 || block_ref > w326_arena_num_blocks(a)) { return; }
  stack_blk[0] = block_ref;
  stack_par[0] = parent_ref;
  sp = 1;
  while (sp > 0) {
    sp = sp - 1;
    cur = stack_blk[sp];
    par = stack_par[sp];
    if (cur <= 0 || cur > w326_arena_num_blocks(a)) { continue; }
    if (par != 0) {
      b = w326_block_at(a, cur);
      if (b != (0 as *u8) && w326_load(b, W326_B_PARENT_BLOCK_REF) == 0) {
        w326_store(b, W326_B_PARENT_BLOCK_REF, par);
      }
    }
    b = w326_block_at(a, cur);
    if (b == (0 as *u8)) { continue; }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_LOOPS)) {
      wb = pipeline_block_while_body_ref(a, cur, i);
      if (wb > 0 && sp < 256) { stack_blk[sp] = wb; stack_par[sp] = cur; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_FOR_LOOPS)) {
      fb = pipeline_block_for_body_ref(a, cur, i);
      if (fb > 0 && sp < 256) { stack_blk[sp] = fb; stack_par[sp] = cur; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_IF_STMTS)) {
      tb = pipeline_block_if_then_body_ref(a, cur, i);
      if (tb > 0 && sp < 256) { stack_blk[sp] = tb; stack_par[sp] = cur; sp = sp + 1; }
      eb = pipeline_block_if_else_body_ref(a, cur, i);
      if (eb > 0 && sp < 256) { stack_blk[sp] = eb; stack_par[sp] = cur; sp = sp + 1; }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_REGIONS)) {
      rgb = pipeline_block_region_body_ref(a, cur, i);
      if (rgb > 0 && sp < 256) { stack_blk[sp] = rgb; stack_par[sp] = cur; sp = sp + 1; }
      i = i + 1;
    }
    w326_patch_block_expr_parents(a, cur);
  }
}

#[no_mangle]
export function pipeline_block_set_parent_if_zero(a: *u8, block_ref: i32, parent_ref: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || block_ref <= 0 || block_ref > w326_arena_num_blocks(a) || parent_ref <= 0) { return 0; }
  b = w326_block_at(a, block_ref);
  if (b == (0 as *u8)) { return 0; }
  if (w326_load(b, W326_B_PARENT_BLOCK_REF) == 0) {
    w326_store(b, W326_B_PARENT_BLOCK_REF, parent_ref);
    return 1;
  }
  return 0;
}

#[no_mangle]
export function pipeline_block_parent_block_ref_at(a: *u8, block_ref: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || block_ref <= 0 || block_ref > w326_arena_num_blocks(a)) { return 0; }
  b = w326_block_at(a, block_ref);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_PARENT_BLOCK_REF);
}

#[no_mangle]
export function pipeline_block_resolve_var_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  let b: *u8 = 0 as *u8;
  let cur: i32 = block_ref;
  let depth: i32 = 0;
  let i: i32 = 0;
  let e: *u8 = 0 as *u8;
  let cmp: i32 = 0;
  if (a == (0 as *u8) || vname == (0 as *u8) || vlen <= 0) { return 0; }
  while (cur > 0 && cur <= w326_arena_num_blocks(a) && depth < 128) {
    b = w326_block_at(a, cur);
    if (b == (0 as *u8)) { break; }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_CONSTS)) {
      e = w326_const_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_TYPE) != 0 && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return w326_load(e, W326_CD_TYPE); }
      }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_LETS)) {
      e = w326_let_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_TYPE) != 0 && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return w326_load(e, W326_CD_TYPE); }
      }
      i = i + 1;
    }
    cur = w326_load(b, W326_B_PARENT_BLOCK_REF);
    depth = depth + 1;
  }
  return 0;
}

#[no_mangle]
export function pipeline_block_name_binding_kind(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  let b: *u8 = 0 as *u8;
  let cur: i32 = block_ref;
  let depth: i32 = 0;
  let i: i32 = 0;
  let e: *u8 = 0 as *u8;
  let cmp: i32 = 0;
  if (a == (0 as *u8) || vname == (0 as *u8) || vlen <= 0) { return 0 - 1; }
  while (cur > 0 && cur <= w326_arena_num_blocks(a) && depth < 128) {
    b = w326_block_at(a, cur);
    if (b == (0 as *u8)) { break; }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_CONSTS)) {
      e = w326_const_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return 1; }
      }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_LETS)) {
      e = w326_let_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return 0; }
      }
      i = i + 1;
    }
    cur = w326_load(b, W326_B_PARENT_BLOCK_REF);
    depth = depth + 1;
  }
  return 0 - 1;
}

#[no_mangle]
export function pipeline_block_local_name_redecl_c(a: *u8, block_ref: i32, vname: *u8, vlen: i32, kind: i32, idx: i32, m: *u8, func_index: i32): i32 {
  let b: *u8 = 0 as *u8;
  let i: i32 = 0;
  let e: *u8 = 0 as *u8;
  let cmp: i32 = 0;
  let body: i32 = 0;
  let np: i32 = 0;
  let pi: i32 = 0;
  let nl: i32 = 0;
  let pbuf: u8[256] = [];
  let k: i32 = 0;
  if (a == (0 as *u8) || vname == (0 as *u8) || vlen <= 0 || block_ref <= 0) { return 0; }
  b = w326_block_at(a, block_ref);
  if (b == (0 as *u8)) { return 0; }
  i = 0;
  while (i < w326_load(b, W326_B_NUM_LETS)) {
    if (!(kind == 0 && i == idx)) {
      e = w326_let_at(a, block_ref, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return 1; }
      }
    }
    i = i + 1;
  }
  i = 0;
  while (i < w326_load(b, W326_B_NUM_CONSTS)) {
    if (!(kind == 1 && i == idx)) {
      e = w326_const_at(a, block_ref, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return 1; }
      }
    }
    i = i + 1;
  }
  if (m != (0 as *u8) && func_index >= 0) {
    unsafe { body = w526_module_func_body_ref_at(m, func_index); }
    if (body == block_ref) {
      unsafe { np = w526_module_func_num_params_at(m, func_index); }
      pi = 0;
      while (pi < np) {
        unsafe { nl = w526_module_func_param_name_len_at(m, func_index, pi); }
        if (nl == vlen) {
          if (nl > 255) { nl = 255; }
          unsafe { w526_module_func_param_name_copy32(m, func_index, pi, &pbuf[0]); }
          k = 0;
          while (k < nl) {
            if (pbuf[k] != vname[k]) { break; }
            k = k + 1;
          }
          if (k == nl) { return 1; }
        }
        pi = pi + 1;
      }
    }
  }
  return 0;
}

#[no_mangle]
export function pipeline_block_find_var_decl_block_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  let b: *u8 = 0 as *u8;
  let cur: i32 = block_ref;
  let depth: i32 = 0;
  let i: i32 = 0;
  let e: *u8 = 0 as *u8;
  let cmp: i32 = 0;
  if (a == (0 as *u8) || vname == (0 as *u8) || vlen <= 0) { return 0; }
  while (cur > 0 && cur <= w326_arena_num_blocks(a) && depth < 128) {
    b = w326_block_at(a, cur);
    if (b == (0 as *u8)) { break; }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_CONSTS)) {
      e = w326_const_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return cur; }
      }
      i = i + 1;
    }
    i = 0;
    while (i < w326_load(b, W326_B_NUM_LETS)) {
      e = w326_let_at(a, cur, i);
      if (e != (0 as *u8) && w326_load(e, W326_CD_NAME_LEN) == vlen) {
        unsafe { cmp = w526_memcmp(e, vname, vlen as usize); }
        if (cmp == 0) { return cur; }
      }
      i = i + 1;
    }
    cur = w326_load(b, W326_B_PARENT_BLOCK_REF);
    depth = depth + 1;
  }
  return 0;
}

/**
 * Insert n_items stmt_order at pos (parallel kind/idx arrays).
 * PLATFORM: SHARED
 */
function w326_stmt_order_insert_at(a: *u8, br: i32, pos: i32, kinds: *u8, idxs: *i32, n_items: i32): void {
  let sc: *u8 = w326_sc(a, 1);
  let b: *u8 = w326_block_at(a, br);
  let abs: i32 = 0;
  let move_count: i32 = 0;
  let bi: i32 = 0;
  let esz: i64 = W326_SO_SZ as i64;
  let data: *u8 = 0 as *u8;
  let i: i32 = 0;
  let so: *u8 = 0 as *u8;
  let ob: *u8 = 0 as *u8;
  let p: i32 = pos;
  let rc: i32 = 0;
  if (a == (0 as *u8) || br <= 0 || kinds == (0 as *u8) || idxs == (0 as *i32) || n_items <= 0 || sc == (0 as *u8) || b == (0 as *u8)) {
    return;
  }
  if (p < 0) { p = 0; }
  if (p > w326_load(b, W326_B_NUM_STMT_ORDER)) { p = w326_load(b, W326_B_NUM_STMT_ORDER); }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE) + p;
  move_count = w326_gv_len(sc + (W326_SC_STMT_ORDER as usize)) - abs;
  i = 0;
  while (i < n_items) {
    unsafe { rc = w526_grow_vec_ensure(sc + (W326_SC_STMT_ORDER as usize)); }
    if (rc == 0) { return; }
    i = i + 1;
  }
  data = w326_gv_data(sc + (W326_SC_STMT_ORDER as usize));
  if (move_count > 0 && data != (0 as *u8)) {
    unsafe {
      w326_memmove(data + ((((abs + n_items) as i64) * esz) as usize),
                   data + (((abs as i64) * esz) as usize),
                   ((move_count as i64) * esz) as usize);
    }
  }
  data = w326_gv_data(sc + (W326_SC_STMT_ORDER as usize));
  i = 0;
  while (i < n_items) {
    so = data + ((((abs + i) as i64) * esz) as usize);
    unsafe { so[0] = kinds[i]; }
    w326_store(so, W326_SO_IDX, idxs[i]);
    i = i + 1;
  }
  w326_store(sc + (W326_SC_STMT_ORDER as usize), W326_GV_LEN, w326_gv_len(sc + (W326_SC_STMT_ORDER as usize)) + n_items);
  w326_store(b, W326_B_NUM_STMT_ORDER, w326_load(b, W326_B_NUM_STMT_ORDER) + n_items);
  bi = 1;
  while (bi <= w326_arena_num_blocks(a)) {
    if (bi != br) {
      ob = w326_block_at(a, bi);
      if (ob != (0 as *u8) && w326_load(ob, W326_B_STMT_ORDER_BASE) >= abs) {
        w326_store(ob, W326_B_STMT_ORDER_BASE, w326_load(ob, W326_B_STMT_ORDER_BASE) + n_items);
      }
    }
    bi = bi + 1;
  }
}

#[no_mangle]
export function pipeline_block_stmt_order_prepend_lets(a: *u8, br: i32, let_start_idx: i32, let_count: i32): void {
  let kinds: u8[64] = [];
  let idxs: i32[64] = [];
  let li: i32 = 0;
  if (a == (0 as *u8) || br <= 0 || let_count <= 0 || let_count > 64) { return; }
  while (li < let_count) {
    kinds[li] = 1;
    idxs[li] = let_start_idx + li;
    li = li + 1;
  }
  w326_stmt_order_insert_at(a, br, 0, &kinds[0], &idxs[0], let_count);
}

#[no_mangle]
export function pipeline_block_stmt_order_fix_prefix_lets(a: *u8, br: i32, prefix_n: i32): void {
  let b: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let old_k: u8[512] = [];
  let old_i: i32[512] = [];
  let neu_k: u8[512] = [];
  let neu_i: i32[512] = [];
  let nso: i32 = 0;
  let i: i32 = 0;
  let nn: i32 = 0;
  let pi: i32 = 0;
  let lets_seen: i32 = 0;
  let need_fix: i32 = 0;
  let abs: i32 = 0;
  let so: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0 || prefix_n <= 0 || prefix_n > 64) { return; }
  b = w326_block_at(a, br);
  sc = w326_sc(a, 1);
  if (b == (0 as *u8) || sc == (0 as *u8) || w326_load(b, W326_B_NUM_STMT_ORDER) <= 0) { return; }
  nso = w326_load(b, W326_B_NUM_STMT_ORDER);
  if (nso > 512) { return; }
  i = 0;
  while (i < nso) {
    old_k[i] = pipeline_block_stmt_order_kind(a, br, i);
    old_i[i] = pipeline_block_stmt_order_idx(a, br, i);
    i = i + 1;
  }
  need_fix = 0;
  lets_seen = 0;
  i = 0;
  while (i < nso) {
    if (old_k[i] == 0) { i = i + 1; continue; }
    if (old_k[i] == 1 && old_i[i] >= 0 && old_i[i] < prefix_n) {
      if (lets_seen != old_i[i]) { need_fix = 1; }
      lets_seen = lets_seen + 1;
      i = i + 1;
      continue;
    }
    if (lets_seen < prefix_n) { need_fix = 1; }
    break;
  }
  if (need_fix == 0 && lets_seen >= prefix_n) { return; }
  nn = 0;
  i = 0;
  while (i < nso) {
    if (old_k[i] == 0) { neu_k[nn] = old_k[i]; neu_i[nn] = old_i[i]; nn = nn + 1; }
    i = i + 1;
  }
  pi = 0;
  while (pi < prefix_n) {
    neu_k[nn] = 1;
    neu_i[nn] = pi;
    nn = nn + 1;
    pi = pi + 1;
  }
  i = 0;
  while (i < nso) {
    if (old_k[i] != 0) {
      if (!(old_k[i] == 1 && old_i[i] >= 0 && old_i[i] < prefix_n)) {
        neu_k[nn] = old_k[i];
        neu_i[nn] = old_i[i];
        nn = nn + 1;
      }
    }
    i = i + 1;
  }
  if (nn != nso) { return; }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE);
  i = 0;
  while (i < nn) {
    unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), abs + i); }
    if (so != (0 as *u8)) {
      unsafe { so[0] = neu_k[i]; }
      w326_store(so, W326_SO_IDX, neu_i[i]);
    }
    i = i + 1;
  }
}

#[no_mangle]
export function pipeline_block_with_arena_fixup_stmt_order(a: *u8, br: i32): void {
  let b: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let ri: i32 = 0;
  let wa_ri: i32 = 0 - 1;
  let inner: i32 = 0;
  let i: i32 = 0;
  let abs: i32 = 0;
  let so: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return; }
  b = w326_block_at(a, br);
  sc = w326_sc(a, 1);
  if (b == (0 as *u8) || sc == (0 as *u8) || w326_load(b, W326_B_NUM_REGIONS) <= 0) { return; }
  ri = 0;
  while (ri < w326_load(b, W326_B_NUM_REGIONS)) {
    if (pipeline_block_region_with_arena_cap_ref(a, br, ri) > 0) {
      wa_ri = ri;
      inner = pipeline_block_region_body_ref(a, br, ri);
      break;
    }
    ri = ri + 1;
  }
  if (wa_ri < 0 || inner <= 0 || inner == br) { return; }
  i = 0;
  while (i < w326_load(b, W326_B_NUM_STMT_ORDER)) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 6) { return; }
    i = i + 1;
  }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE);
  if (abs < 0) { return; }
  w326_store(b, W326_B_NUM_STMT_ORDER, 1);
  unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), abs); }
  if (so == (0 as *u8)) { return; }
  unsafe { so[0] = 6; }
  w326_store(so, W326_SO_IDX, wa_ri);
}

#[no_mangle]
export function pipeline_block_stmt_order_rebuild_sparse_ifs(a: *u8, br: i32): void {
  let b: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let neu_k: u8[512] = [];
  let neu_i: i32[512] = [];
  let saved_k: u8[512] = [];
  let saved_i: i32[512] = [];
  let nso: i32 = 0;
  let nif: i32 = 0;
  let i: i32 = 0;
  let j: i32 = 0;
  let nn: i32 = 0;
  let if_in_order: i32 = 0;
  let emitted_ifs: i32 = 0;
  let abs: i32 = 0;
  let k: u8 = 0;
  let idx: i32 = 0;
  let sn: i32 = 0;
  let si: i32 = 0;
  let so: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return; }
  b = w326_block_at(a, br);
  sc = w326_sc(a, 1);
  if (b == (0 as *u8) || sc == (0 as *u8) || w326_load(b, W326_B_NUM_IF_STMTS) <= 0) { return; }
  nso = w326_load(b, W326_B_NUM_STMT_ORDER);
  nif = w326_load(b, W326_B_NUM_IF_STMTS);
  if (nso > 512) { return; }
  if_in_order = 0;
  i = 0;
  while (i < nso) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 5) { if_in_order = if_in_order + 1; }
    i = i + 1;
  }
  if (if_in_order >= nif) { return; }
  nn = 0;
  emitted_ifs = 0;
  i = 0;
  while (i < nso) {
    k = pipeline_block_stmt_order_kind(a, br, i);
    idx = pipeline_block_stmt_order_idx(a, br, i);
    if (k == 2 && if_in_order > 0) { i = i + 1; continue; }
    if (k == 5) {
      if (emitted_ifs == 0) {
        j = 0;
        while (j < nif) {
          if (nn >= 512) { return; }
          neu_k[nn] = 5;
          neu_i[nn] = j;
          nn = nn + 1;
          j = j + 1;
        }
        emitted_ifs = 1;
      }
      i = i + 1;
      continue;
    }
    if (nn >= 512) { return; }
    neu_k[nn] = k;
    neu_i[nn] = idx;
    nn = nn + 1;
    i = i + 1;
  }
  if (emitted_ifs == 0) {
    sn = nn;
    if (sn > 512) { return; }
    si = 0;
    while (si < sn) {
      saved_k[si] = neu_k[si];
      saved_i[si] = neu_i[si];
      si = si + 1;
    }
    nn = 0;
    j = 0;
    while (j < nif) {
      if (nn >= 512) { return; }
      neu_k[nn] = 5;
      neu_i[nn] = j;
      nn = nn + 1;
      j = j + 1;
    }
    si = 0;
    while (si < sn) {
      if (nn >= 512) { return; }
      neu_k[nn] = saved_k[si];
      neu_i[nn] = saved_i[si];
      nn = nn + 1;
      si = si + 1;
    }
  }
  abs = w326_load(b, W326_B_STMT_ORDER_BASE);
  if (abs < 0) { return; }
  w326_store(b, W326_B_NUM_STMT_ORDER, nn);
  i = 0;
  while (i < nn) {
    unsafe { so = grow_vec_at(sc + (W326_SC_STMT_ORDER as usize), abs + i); }
    if (so != (0 as *u8)) {
      unsafe { so[0] = neu_k[i]; }
      w326_store(so, W326_SO_IDX, neu_i[i]);
    }
    i = i + 1;
  }
}

#[no_mangle]
export function pipeline_module_fixup_with_arena_stmt_orders(m: *u8, a: *u8): void {
  let fi: i32 = 0;
  let br: i32 = 0;
  let b: *u8 = 0 as *u8;
  let ri: i32 = 0;
  let inner: i32 = 0;
  let ib: *u8 = 0 as *u8;
  let early: i32 = 0;
  let nf: i32 = 0;
  if (m == (0 as *u8) || a == (0 as *u8)) { return; }
  unsafe { nf = w526_module_num_funcs(m); }
  while (fi < nf) {
    unsafe { br = w526_module_func_body_ref_at(m, fi); }
    if (br > 0) {
      b = w326_block_at(a, br);
      pipeline_block_with_arena_fixup_stmt_order(a, br);
      pipeline_block_stmt_order_rebuild_sparse_ifs(a, br);
      if (b != (0 as *u8)) {
        ri = 0;
        while (ri < w326_load(b, W326_B_NUM_REGIONS)) {
          inner = pipeline_block_region_body_ref(a, br, ri);
          if (inner > 0 && inner != br) {
            ib = w326_block_at(a, inner);
            early = 0;
            if (ib != (0 as *u8)) {
              early = w326_load(ib, W326_B_NUM_EARLY_LETS);
              if (early < 0) { early = 0; }
              if (early > w326_load(ib, W326_B_NUM_LETS)) { early = w326_load(ib, W326_B_NUM_LETS); }
            }
            pipeline_block_stmt_order_fix_prefix_lets(a, inner, early);
            pipeline_block_stmt_order_rebuild_sparse_ifs(a, inner);
          }
          ri = ri + 1;
        }
      }
    }
    fi = fi + 1;
  }
}

#[no_mangle]
export function ast_ast_block_num_consts(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_CONSTS);
}

#[no_mangle]
export function ast_ast_block_num_lets(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_LETS);
}

#[no_mangle]
export function ast_ast_block_num_loops(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_LOOPS);
}

#[no_mangle]
export function ast_ast_block_num_for_loops(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_FOR_LOOPS);
}

#[no_mangle]
export function ast_ast_block_num_if_stmts(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_IF_STMTS);
}

#[no_mangle]
export function ast_ast_block_num_regions(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_REGIONS);
}

#[no_mangle]
export function ast_ast_block_num_expr_stmts(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_EXPR_STMTS);
}

#[no_mangle]
export function ast_ast_block_num_stmt_order(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_NUM_STMT_ORDER);
}

#[no_mangle]
export function ast_ast_arena_patch_block_parent_links(arena: *u8, block_ref: i32, parent_ref: i32): void {
  pipeline_patch_block_parent_links(arena, block_ref, parent_ref);
}
#[no_mangle]
export function ast_ast_block_region_body_ref(a: *u8, br: i32, ri: i32): i32 {
  return pipeline_block_region_body_ref(a, br, ri);
}
#[no_mangle]
export function ast_ast_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8 {
  return pipeline_block_stmt_order_kind(a, br, si);
}
#[no_mangle]
export function ast_ast_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32 {
  return pipeline_block_stmt_order_idx(a, br, si);
}
#[no_mangle]
export function ast_ast_block_const_init_ref(a: *u8, br: i32, ci: i32): i32 {
  return pipeline_block_const_init_ref(a, br, ci);
}
#[no_mangle]
export function ast_ast_block_const_type_ref(a: *u8, br: i32, ci: i32): i32 {
  return pipeline_block_const_type_ref(a, br, ci);
}
#[no_mangle]
export function ast_ast_block_let_init_ref(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_let_init_ref(a, br, li);
}
#[no_mangle]
export function ast_ast_block_let_type_ref(a: *u8, br: i32, li: i32): i32 {
  return pipeline_block_let_type_ref(a, br, li);
}
#[no_mangle]
export function ast_ast_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32 {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
#[no_mangle]
export function ast_ast_block_final_expr_ref(a: *u8, br: i32): i32 {
  let b: *u8 = 0 as *u8;
  if (a == (0 as *u8) || br <= 0) { return 0; }
  b = w326_block_at(a, br);
  if (b == (0 as *u8)) { return 0; }
  return w326_load(b, W326_B_FINAL_EXPR_REF);
}
#[no_mangle]
export function ast_ast_block_while_cond_ref(a: *u8, br: i32, wi: i32): i32 {
  return pipeline_block_while_cond_ref(a, br, wi);
}
#[no_mangle]
export function ast_ast_block_while_body_ref(a: *u8, br: i32, wi: i32): i32 {
  return pipeline_block_while_body_ref(a, br, wi);
}
#[no_mangle]
export function ast_ast_block_for_init_ref(a: *u8, br: i32, fi: i32): i32 {
  return pipeline_block_for_init_ref(a, br, fi);
}
#[no_mangle]
export function ast_ast_block_for_cond_ref(a: *u8, br: i32, fi: i32): i32 {
  return pipeline_block_for_cond_ref(a, br, fi);
}
#[no_mangle]
export function ast_ast_block_for_step_ref(a: *u8, br: i32, fi: i32): i32 {
  return pipeline_block_for_step_ref(a, br, fi);
}
#[no_mangle]
export function ast_ast_block_for_body_ref(a: *u8, br: i32, fi: i32): i32 {
  return pipeline_block_for_body_ref(a, br, fi);
}
#[no_mangle]
export function ast_ast_block_if_cond_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_cond_ref(a, br, ii);
}
#[no_mangle]
export function ast_ast_block_if_then_body_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
#[no_mangle]
export function ast_ast_block_if_else_body_ref(a: *u8, br: i32, ii: i32): i32 {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
#[no_mangle]
export function ast_ast_block_resolve_var_to_type_ref(a: *u8, block_ref: i32, vname: *u8, vlen: i32): i32 {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
#[no_mangle]
export function ast_ast_expr_disallows_implicit_tail(a: *u8, expr_ref: i32): i32 {
  unsafe { return w526_implicit_tail_disallowed(a, expr_ref); }
}
#[no_mangle]
export function ast_ast_expr_apply_call_resolve(a: *u8, call_expr_ref: i32, dep_ix: i32, func_ix: i32): void {
  unsafe { w526_expr_apply_call_resolve(a, call_expr_ref, dep_ix, func_ix); }
}
