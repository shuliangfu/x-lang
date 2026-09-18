// Thin pure: wave327/365/529 M2 — expr_sidecar Cap residual C→.x (was wave278 C thin).
// call/method/match/struct_lit/array_lit + type_arg pools + Expr Cap accessors.
// G.7: bodies match deleted C thin / seed WAVE278_EXPR_SIDECAR_DOMAIN_ALWAYS.
// PRODUCT inject: pipeline_abi_inject_expr_sidecar_thin.
// wave365: w327_load/store via unsafe (T001); PREFER try + L2 gate.
// wave529 Soft Cap: tip SEGV heal — i64/f64 load/store via memcpy (ban raw
//   *i64/*f64 cast store); pipe-cell w327_expr/sc + w529_gv_at/push/block_ptr
//   (ban mid `x=call()` U-starve); drop dead grow_vec_ensure (tipU); stamp
//   w529 HARD BAN tip PRODUCT reinject (Ubuntu tip full-leaf still truncates —
//   tip emit capacity; keep prior PREFER overlay).
// Expr 1224 / MatchArm 24 / StructLitField 264.
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.
// WIN leftover STRUCT_LIT name/nf faces stay export-extern (pure/cold).

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function arena_sidecar_get(key: *u8, create: i32): *u8;
export extern function grow_vec_at(v: *u8, idx: i32): *u8;
export extern function grow_vec_push(v: *u8): i32;
export extern function pipeline_arena_expr_ptr(a: *u8, ref: i32): *u8;
export extern function pipeline_arena_block_ptr(a: *u8, ref: i32): *u8;
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;

export extern function ast_ast_block_final_expr_ref(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_consts(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_expr_stmts(a: *u8, br: i32): i32;
export extern function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern function pipeline_block_const_init_ref(a: *u8, br: i32, ci: i32): i32;
export extern function pipeline_block_expr_stmt_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_block_for_body_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_block_if_else_body_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_block_if_then_body_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_block_let_init_ref(a: *u8, br: i32, li: i32): i32;
export extern function pipeline_block_region_body_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_block_while_body_ref(a: *u8, br: i32, i: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_layout_offset(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_hi_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_lo_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_field_store_sz(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_into(a: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_struct_lit_type_name_len(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_set(a: *u8, expr_ref: i32, name: *u8, name_len: i32): void;
export extern function pipeline_module_func_param_type_ref_at(m: *u8, fi: i32, pi: i32): i32;
export extern function pipeline_module_import_append_select_name(m: *u8, idx: i32, bytes: *u8, len: i32): i32;

const W327_EXPR_SZ: i32 = 1224;
const W327_ARM_SZ: i32 = 24;
const W327_SLF_SZ: i32 = 264;
const W327_GV_LEN: i32 = 12;
const W327_ARENA_NUM_EXPRS: i32 = 4;
const W327_ARENA_NUM_BLOCKS: i32 = 8;
const W327_B_NUM_LOOPS: i32 = 24;
const W327_B_NUM_FOR_LOOPS: i32 = 32;
const W327_B_NUM_IF_STMTS: i32 = 40;
const W327_B_NUM_REGIONS: i32 = 48;
const W327_E_KIND: i32 = 0;
const W327_E_RESOLVED_TYPE_REF: i32 = 4;
const W327_E_LINE: i32 = 8;
const W327_E_COL: i32 = 12;
const W327_E_INT_VAL: i32 = 16;
const W327_E_FLOAT_VAL: i32 = 24;
const W327_E_VAR_NAME: i32 = 32;
const W327_E_VAR_NAME_LEN: i32 = 288;
const W327_E_BINOP_LEFT_REF: i32 = 292;
const W327_E_BINOP_RIGHT_REF: i32 = 296;
const W327_E_UNARY_OPERAND_REF: i32 = 300;
const W327_E_IF_COND_REF: i32 = 304;
const W327_E_IF_THEN_REF: i32 = 308;
const W327_E_IF_ELSE_REF: i32 = 312;
const W327_E_BLOCK_REF: i32 = 316;
const W327_E_MATCH_MATCHED_REF: i32 = 320;
const W327_E_MATCH_ARM_BASE: i32 = 324;
const W327_E_MATCH_NUM_ARMS: i32 = 328;
const W327_E_FIELD_ACCESS_BASE_REF: i32 = 332;
const W327_E_FIELD_ACCESS_FIELD_NAME: i32 = 336;
const W327_E_FIELD_ACCESS_FIELD_LEN: i32 = 592;
const W327_E_FIELD_ACCESS_IS_ENUM_VARIANT: i32 = 596;
const W327_E_FIELD_ACCESS_OFFSET: i32 = 600;
const W327_E_FIELD_ACCESS_SOA_STRIDE: i32 = 604;
const W327_E_INDEX_BASE_REF: i32 = 608;
const W327_E_INDEX_INDEX_REF: i32 = 612;
const W327_E_INDEX_BASE_IS_SLICE: i32 = 616;
const W327_E_CALL_CALLEE_REF: i32 = 620;
const W327_E_CALL_ARG_BASE: i32 = 624;
const W327_E_CALL_NUM_ARGS: i32 = 628;
const W327_E_CALL_NUM_TYPE_ARGS: i32 = 632;
const W327_E_METHOD_CALL_BASE_REF: i32 = 636;
const W327_E_METHOD_CALL_NAME: i32 = 640;
const W327_E_METHOD_CALL_NAME_LEN: i32 = 896;
const W327_E_METHOD_CALL_ARG_BASE: i32 = 900;
const W327_E_METHOD_CALL_NUM_ARGS: i32 = 904;
const W327_E_CONST_FOLDED_VAL: i32 = 908;
const W327_E_CONST_FOLDED_VALID: i32 = 912;
const W327_E_INDEX_PROVEN_IN_BOUNDS: i32 = 916;
const W327_E_STRUCT_LIT_STRUCT_NAME: i32 = 920;
const W327_E_STRUCT_LIT_STRUCT_NAME_LEN: i32 = 1176;
const W327_E_STRUCT_LIT_FIELD_BASE: i32 = 1180;
const W327_E_STRUCT_LIT_NUM_FIELDS: i32 = 1184;
const W327_E_ARRAY_LIT_ELEM_BASE: i32 = 1188;
const W327_E_ARRAY_LIT_NUM_ELEMS: i32 = 1192;
const W327_E_FLOAT_BITS_LO: i32 = 1196;
const W327_E_FLOAT_BITS_HI: i32 = 1200;
const W327_E_ENUM_VARIANT_TAG: i32 = 1204;
const W327_E_AS_OPERAND_REF: i32 = 1208;
const W327_E_AS_TARGET_TYPE_REF: i32 = 1212;
const W327_E_CALL_RESOLVED_FUNC_INDEX: i32 = 1216;
const W327_E_CALL_RESOLVED_DEP_INDEX: i32 = 1220;
const W327_SC_TYPES: i32 = 16;
const W327_SC_EXPRS: i32 = 48;
const W327_SC_BLOCKS: i32 = 80;
const W327_SC_FUNCS: i32 = 112;
const W327_SC_CONSTS: i32 = 144;
const W327_SC_LETS: i32 = 176;
const W327_SC_IFS: i32 = 208;
const W327_SC_REGIONS: i32 = 240;
const W327_SC_LOOPS: i32 = 272;
const W327_SC_FOR_LOOPS: i32 = 304;
const W327_SC_DEFER_BLOCK_REFS: i32 = 336;
const W327_SC_LABELED_STMTS: i32 = 368;
const W327_SC_EXPR_STMT_REFS: i32 = 400;
const W327_SC_STMT_ORDER: i32 = 432;
const W327_SC_EXPR_CALL_ARG_REFS: i32 = 464;
const W327_SC_EXPR_CALL_TYPE_ARG_REFS: i32 = 496;
const W327_SC_EXPR_CALL_TYPE_ARG_BASES: i32 = 528;
const W327_SC_TYPE_TYPE_ARG_REFS: i32 = 560;
const W327_SC_TYPE_TYPE_ARG_BASES: i32 = 592;
const W327_SC_TYPE_TYPE_ARG_COUNTS: i32 = 624;
const W327_SC_EXPR_METHOD_CALL_ARG_REFS: i32 = 656;
const W327_SC_EXPR_MATCH_ARMS: i32 = 688;
const W327_SC_EXPR_STRUCT_LIT_FIELDS: i32 = 720;
const W327_SC_EXPR_ARRAY_LIT_ELEM_REFS: i32 = 752;
const W327_SC_FUNC_PARAMS: i32 = 784;
const W327_ARM_RESULT_REF: i32 = 0;
const W327_ARM_IS_WILDCARD: i32 = 4;
const W327_ARM_LIT_VAL: i32 = 8;
const W327_ARM_IS_ENUM_VARIANT: i32 = 12;
const W327_ARM_VARIANT_INDEX: i32 = 16;
const W327_ARM_GUARD_REF: i32 = 20;
const W327_SLF_NAME: i32 = 0;
const W327_SLF_NAME_LEN: i32 = 256;
const W327_SLF_INIT_REF: i32 = 260;

/**
 * LE i32 load via unsafe (T001). PLATFORM: SHARED.
 * wave365: wrap pipe_load_i32_le for PREFER_ASM pure-asm leave.
 */
function w327_load(p: *u8, off: i32): i32 {
  if (p == (0 as *u8)) { return 0; }
  unsafe {
    return pipe_load_i32_le(p, off);
  }
}

/**
 * LE i32 store via unsafe (T001). PLATFORM: SHARED.
 * wave365: wrap pipe_store_i32_le for PREFER_ASM pure-asm leave.
 */
function w327_store(p: *u8, off: i32, v: i32): void {
  if (p == (0 as *u8)) { return; }
  unsafe {
    pipe_store_i32_le(p, off, v);
  }
}
function w327_num_exprs(a: *u8): i32 {
  if (a == (0 as *u8)) { return 0; }
  return w327_load(a, W327_ARENA_NUM_EXPRS);
}
/**
 * pipeline_arena_expr_ptr via pipe-cell (wave529 Soft Cap tipU mid-call).
 * Ban mid `p = pipeline_arena_expr_ptr(...)` — Ubuntu tip drops call (U-starve).
 * @param a Arena pointer; null or ref<=0 → null.
 * @param ref 1-based expr ref.
 * @return Expr byte pointer, or null.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w327_expr(a: *u8, ref: i32): *u8 {
  let pcell: u8[8] = [];
  if (a == (0 as *u8) || ref <= 0) { return 0 as *u8; }
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_expr_ptr(a, ref));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}
/**
 * arena_sidecar_get via pipe-cell (wave529 Soft Cap tipU mid-call).
 * Ban mid `sc = arena_sidecar_get(...)` — Ubuntu tip drops call (U-starve).
 * @param a Arena key; null → null.
 * @param create Non-zero to create sidecar.
 * @return Sidecar pointer, or null.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w327_sc(a: *u8, create: i32): *u8 {
  let pcell: u8[8] = [];
  if (a == (0 as *u8)) { return 0 as *u8; }
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, arena_sidecar_get(a, create));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}
/**
 * grow_vec_at via pipe-cell (wave529 Soft Cap tipU mid-call).
 * @param v GrowVec pointer.
 * @param idx Element index.
 * @return Element pointer, or null.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w529_gv_at(v: *u8, idx: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, grow_vec_at(v, idx));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}
/**
 * grow_vec_push via pipe-cell (wave529 Soft Cap tipU mid-call).
 * @param v GrowVec pointer.
 * @return New index, or <0 on failure.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w529_gv_push(v: *u8): i32 {
  let icell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&icell[0], 0, grow_vec_push(v));
    return pipe_load_i32_le(&icell[0], 0);
  }
}
/**
 * pipeline_arena_block_ptr via pipe-cell (wave529 Soft Cap tipU mid-call).
 * @param a Arena pointer.
 * @param ref Block ref.
 * @return Block byte pointer, or null.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w529_block_ptr(a: *u8, ref: i32): *u8 {
  let pcell: u8[8] = [];
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_arena_block_ptr(a, ref));
    return pipe_load_ptr_slot(&pcell[0], 0);
  }
}
function w327_gv_len(gv: *u8): i32 {
  if (gv == (0 as *u8)) { return 0; }
  return w327_load(gv, W327_GV_LEN);
}
/**
 * Load i64 from LE byte offset via memcpy (wave529 Soft Cap tip heal).
 * Ban raw `*((p+off) as *i64)` — Ubuntu tip SEGV at store/load cast path.
 * @param p Base pointer; null → 0.
 * @param off Byte offset from p.
 * @return i64 value copied from p+off.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w327_load_i64(p: *u8, off: i32): i64 {
  let r: i64 = 0;
  if (p == (0 as *u8)) { return 0; }
  unsafe { memcpy((&r as *u8), p + (off as usize), 8 as usize); }
  return r;
}
/**
 * Store i64 at LE byte offset via memcpy (wave529 Soft Cap tip heal).
 * Ban raw `*((p+off) as *i64)=v` — Ubuntu tip SEGV at w327_store_i64.
 * @param p Base pointer; null → no-op.
 * @param off Byte offset from p.
 * @param v Value to store.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w327_store_i64(p: *u8, off: i32, v: i64): void {
  if (p == (0 as *u8)) { return; }
  unsafe { memcpy(p + (off as usize), (&v as *u8), 8 as usize); }
}
/**
 * Store f64 at LE byte offset via memcpy (wave529 Soft Cap tip heal).
 * Peer of w327_store_i64 — ban raw *f64 cast store (same SEGV class).
 * @param p Base pointer; null → no-op.
 * @param off Byte offset from p.
 * @param v Value to store.
 * PLATFORM: SHARED Soft Cap tip heal (wave529).
 */
function w327_store_f64(p: *u8, off: i32, v: f64): void {
  if (p == (0 as *u8)) { return; }
  unsafe { memcpy(p + (off as usize), (&v as *u8), 8 as usize); }
}
function w327_gv_ensure_abs(gv: *u8, abs: i32): i32 {
  let rc: i32 = 0;
  if (gv == (0 as *u8)) { return 0; }
  while (w327_gv_len(gv) <= abs) {
    rc = w529_gv_push(gv);
    if (rc < 0) { return 0; }
  }
  return 1;
}


/**
 * Sidecar slot helper expr_match_arm_at.
 * PLATFORM: SHARED
 */
function expr_match_arm_at(a: *u8, expr_ref: i32, idx: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 as *u8; }
  abs = w327_load(ex, W327_E_MATCH_ARM_BASE) + idx;
  if (create != 0) {
    if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_MATCH_ARMS as usize), abs) == 0) { return 0 as *u8; }
  } else {
    if (idx >= w327_load(ex, W327_E_MATCH_NUM_ARMS) || abs >= w327_gv_len(sc + (W327_SC_EXPR_MATCH_ARMS as usize))) {
      return 0 as *u8;
    }
  }
  p = w529_gv_at(sc + (W327_SC_EXPR_MATCH_ARMS as usize), abs);
  return p;
}


/**
 * Sidecar slot helper expr_struct_lit_field_at.
 * PLATFORM: SHARED
 */
function expr_struct_lit_field_at(a: *u8, expr_ref: i32, idx: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 as *u8; }
  abs = w327_load(ex, W327_E_STRUCT_LIT_FIELD_BASE) + idx;
  if (create != 0) {
    if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_STRUCT_LIT_FIELDS as usize), abs) == 0) { return 0 as *u8; }
  } else {
    if (idx >= w327_load(ex, W327_E_STRUCT_LIT_NUM_FIELDS) || abs >= w327_gv_len(sc + (W327_SC_EXPR_STRUCT_LIT_FIELDS as usize))) {
      return 0 as *u8;
    }
  }
  p = w529_gv_at(sc + (W327_SC_EXPR_STRUCT_LIT_FIELDS as usize), abs);
  return p;
}


/**
 * Sidecar slot helper expr_call_arg_slot.
 * PLATFORM: SHARED
 */
function expr_call_arg_slot(a: *u8, expr_ref: i32, idx: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 as *u8; }
  abs = w327_load(ex, W327_E_CALL_ARG_BASE) + idx;
  if (create != 0) {
    if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_CALL_ARG_REFS as usize), abs) == 0) { return 0 as *u8; }
  } else {
    if (idx >= w327_load(ex, W327_E_CALL_NUM_ARGS) || abs >= w327_gv_len(sc + (W327_SC_EXPR_CALL_ARG_REFS as usize))) {
      return 0 as *u8;
    }
  }
  p = w529_gv_at(sc + (W327_SC_EXPR_CALL_ARG_REFS as usize), abs);
  return p;
}


/**
 * Sidecar slot helper expr_method_call_arg_slot.
 * PLATFORM: SHARED
 */
function expr_method_call_arg_slot(a: *u8, expr_ref: i32, idx: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 as *u8; }
  abs = w327_load(ex, W327_E_METHOD_CALL_ARG_BASE) + idx;
  if (create != 0) {
    if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_METHOD_CALL_ARG_REFS as usize), abs) == 0) { return 0 as *u8; }
  } else {
    if (idx >= w327_load(ex, W327_E_METHOD_CALL_NUM_ARGS) || abs >= w327_gv_len(sc + (W327_SC_EXPR_METHOD_CALL_ARG_REFS as usize))) {
      return 0 as *u8;
    }
  }
  p = w529_gv_at(sc + (W327_SC_EXPR_METHOD_CALL_ARG_REFS as usize), abs);
  return p;
}


/**
 * Sidecar slot helper expr_array_lit_elem_slot.
 * PLATFORM: SHARED
 */
function expr_array_lit_elem_slot(a: *u8, expr_ref: i32, idx: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let abs: i32 = 0;
  let p: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 as *u8; }
  abs = w327_load(ex, W327_E_ARRAY_LIT_ELEM_BASE) + idx;
  if (create != 0) {
    if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_ARRAY_LIT_ELEM_REFS as usize), abs) == 0) { return 0 as *u8; }
  } else {
    if (idx >= w327_load(ex, W327_E_ARRAY_LIT_NUM_ELEMS) || abs >= w327_gv_len(sc + (W327_SC_EXPR_ARRAY_LIT_ELEM_REFS as usize))) {
      return 0 as *u8;
    }
  }
  p = w529_gv_at(sc + (W327_SC_EXPR_ARRAY_LIT_ELEM_REFS as usize), abs);
  return p;
}


/** Getter pipeline_expr_call_num_args_at. PLATFORM: SHARED */
export function pipeline_expr_call_num_args_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CALL_NUM_ARGS);
}


/** Getter pipeline_expr_call_callee_ref_at. PLATFORM: SHARED */
export function pipeline_expr_call_callee_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CALL_CALLEE_REF);
}


/** Getter pipeline_expr_method_call_base_ref_at. PLATFORM: SHARED */
export function pipeline_expr_method_call_base_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_METHOD_CALL_BASE_REF);
}


/** Getter pipeline_expr_method_call_num_args_at. PLATFORM: SHARED */
export function pipeline_expr_method_call_num_args_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_METHOD_CALL_NUM_ARGS);
}


/** Getter pipeline_expr_method_call_name_len. PLATFORM: SHARED */
export function pipeline_expr_method_call_name_len(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_METHOD_CALL_NAME_LEN);
}


/** Getter pipeline_expr_match_num_arms_at. PLATFORM: SHARED */
export function pipeline_expr_match_num_arms_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_MATCH_NUM_ARMS);
}


/** Getter pipeline_expr_array_lit_num_elems_at. PLATFORM: SHARED */
export function pipeline_expr_array_lit_num_elems_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_ARRAY_LIT_NUM_ELEMS);
}


/** Getter pipeline_expr_as_operand_ref_at. PLATFORM: SHARED */
export function pipeline_expr_as_operand_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_AS_OPERAND_REF);
}


/** Getter pipeline_expr_as_target_type_ref_at. PLATFORM: SHARED */
export function pipeline_expr_as_target_type_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_AS_TARGET_TYPE_REF);
}


/** Getter pipeline_expr_enum_variant_tag_at. PLATFORM: SHARED */
export function pipeline_expr_enum_variant_tag_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_ENUM_VARIANT_TAG);
}


/** Getter pipeline_expr_if_cond_ref_at. PLATFORM: SHARED */
export function pipeline_expr_if_cond_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_IF_COND_REF);
}


/** Getter pipeline_expr_if_then_ref_at. PLATFORM: SHARED */
export function pipeline_expr_if_then_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_IF_THEN_REF);
}


/** Getter pipeline_expr_if_else_ref_at. PLATFORM: SHARED */
export function pipeline_expr_if_else_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_IF_ELSE_REF);
}


/** Getter pipeline_expr_block_ref_at. PLATFORM: SHARED */
export function pipeline_expr_block_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_BLOCK_REF);
}


/** Getter pipeline_expr_match_matched_ref_at. PLATFORM: SHARED */
export function pipeline_expr_match_matched_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_MATCH_MATCHED_REF);
}


/** Getter pipeline_expr_const_folded_valid_at. PLATFORM: SHARED */
export function pipeline_expr_const_folded_valid_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CONST_FOLDED_VALID);
}


/** Getter pipeline_expr_const_folded_val_at. PLATFORM: SHARED */
export function pipeline_expr_const_folded_val_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CONST_FOLDED_VAL);
}


/** Getter pipeline_expr_index_base_ref. PLATFORM: SHARED */
export function pipeline_expr_index_base_ref(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_INDEX_BASE_REF);
}


/** Getter pipeline_expr_index_index_ref. PLATFORM: SHARED */
export function pipeline_expr_index_index_ref(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_INDEX_INDEX_REF);
}


/** Getter pipeline_expr_resolved_type_ref. PLATFORM: SHARED */
export function pipeline_expr_resolved_type_ref(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_RESOLVED_TYPE_REF);
}


/** Getter pipeline_expr_line_at. PLATFORM: SHARED */
export function pipeline_expr_line_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_LINE);
}


/** Getter pipeline_expr_col_at. PLATFORM: SHARED */
export function pipeline_expr_col_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_COL);
}


/** Getter pipeline_expr_field_access_offset. PLATFORM: SHARED */
export function pipeline_expr_field_access_offset(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_FIELD_ACCESS_OFFSET);
}


/** Getter pipeline_expr_field_access_soa_stride. PLATFORM: SHARED */
export function pipeline_expr_field_access_soa_stride(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_FIELD_ACCESS_SOA_STRIDE);
}


/** Getter pipeline_expr_int_val_at. PLATFORM: SHARED */
export function pipeline_expr_int_val_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load_i64(ex, W327_E_INT_VAL) as i32;
}


/** Getter pipeline_expr_unary_operand_ref_at. PLATFORM: SHARED */
export function pipeline_expr_unary_operand_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_UNARY_OPERAND_REF);
}


/** Getter pipeline_expr_binop_left_ref_at. PLATFORM: SHARED */
export function pipeline_expr_binop_left_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_BINOP_LEFT_REF);
}


/** Getter pipeline_expr_binop_right_ref_at. PLATFORM: SHARED */
export function pipeline_expr_binop_right_ref_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_BINOP_RIGHT_REF);
}


/** Getter pipeline_expr_call_resolved_dep_index_at. PLATFORM: SHARED */
export function pipeline_expr_call_resolved_dep_index_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return 0; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CALL_RESOLVED_DEP_INDEX);
}


/** Getter pipeline_expr_call_resolved_func_index_at. PLATFORM: SHARED */
export function pipeline_expr_call_resolved_func_index_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return 0; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CALL_RESOLVED_FUNC_INDEX);
}


/** Getter pipeline_expr_index_base_is_slice_at. PLATFORM: SHARED */
export function pipeline_expr_index_base_is_slice_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return 0; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_INDEX_BASE_IS_SLICE);
}


/** Getter pipeline_expr_index_proven_in_bounds_at. PLATFORM: SHARED */
export function pipeline_expr_index_proven_in_bounds_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return 0; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_INDEX_PROVEN_IN_BOUNDS);
}


/** Getter pipeline_expr_int64_val_at. PLATFORM: SHARED */
export function pipeline_expr_int64_val_at(a: *u8, expr_ref: i32): i64 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load_i64(ex, W327_E_INT_VAL);
}


/** Setter pipeline_expr_set_index_base_is_slice. PLATFORM: SHARED */
export function pipeline_expr_set_index_base_is_slice(a: *u8, er: i32, v: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_INDEX_BASE_IS_SLICE, v);
}


/** Setter pipeline_expr_set_index_proven_in_bounds. PLATFORM: SHARED */
export function pipeline_expr_set_index_proven_in_bounds(a: *u8, er: i32, v: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_INDEX_PROVEN_IN_BOUNDS, v);
}


/** Setter pipeline_expr_set_field_access_offset. PLATFORM: SHARED */
export function pipeline_expr_set_field_access_offset(a: *u8, expr_ref: i32, v: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_FIELD_ACCESS_OFFSET, v);
}


/** Setter pipeline_expr_set_int_val. PLATFORM: SHARED */
export function pipeline_expr_set_int_val(a: *u8, er: i32, v: i64): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store_i64(ex, W327_E_INT_VAL, v);
}


/** Setter pipeline_expr_set_float_val. PLATFORM: SHARED */
export function pipeline_expr_set_float_val(a: *u8, er: i32, v: f64): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store_f64(ex, W327_E_FLOAT_VAL, v);
}


/** Setter pipeline_expr_set_kind. PLATFORM: SHARED */
export function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_KIND, kind);
}


/** Setter pipeline_expr_set_line_col. PLATFORM: SHARED */
export function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_LINE, line);
  w327_store(ex, W327_E_COL, col);
}


/** Setter pipeline_expr_set_resolved_type_ref. PLATFORM: SHARED */
export function pipeline_expr_set_resolved_type_ref(a: *u8, expr_ref: i32, type_ref: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_RESOLVED_TYPE_REF, type_ref);
}


/** Setter pipeline_expr_set_const_folded. PLATFORM: SHARED */
export function pipeline_expr_set_const_folded(a: *u8, expr_ref: i32, val: i32, valid: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0 || expr_ref > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_CONST_FOLDED_VAL, val);
  w327_store(ex, W327_E_CONST_FOLDED_VALID, valid);
}


/** Match-arm getter pipeline_expr_match_arm_result_ref. PLATFORM: SHARED */
export function pipeline_expr_match_arm_result_ref(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_RESULT_REF);
}


/** Match-arm getter pipeline_expr_match_arm_is_wildcard. PLATFORM: SHARED */
export function pipeline_expr_match_arm_is_wildcard(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_IS_WILDCARD);
}


/** Match-arm getter pipeline_expr_match_arm_lit_val. PLATFORM: SHARED */
export function pipeline_expr_match_arm_lit_val(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_LIT_VAL);
}


/** Match-arm getter pipeline_expr_match_arm_is_enum_variant. PLATFORM: SHARED */
export function pipeline_expr_match_arm_is_enum_variant(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_IS_ENUM_VARIANT);
}


/** Match-arm getter pipeline_expr_match_arm_variant_index. PLATFORM: SHARED */
export function pipeline_expr_match_arm_variant_index(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_VARIANT_INDEX);
}


/** Match-arm getter pipeline_expr_match_arm_guard_ref. PLATFORM: SHARED */
export function pipeline_expr_match_arm_guard_ref(a: *u8, expr_ref: i32, i: i32): i32 {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm == (0 as *u8)) { return 0; }
  return w327_load(arm, W327_ARM_GUARD_REF);
}


/** Match-arm setter pipeline_expr_match_arm_set_wildcard. PLATFORM: SHARED */
export function pipeline_expr_match_arm_set_wildcard(a: *u8, expr_ref: i32, i: i32, v: i32): void {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 1);
  if (arm == (0 as *u8)) { return; }
  w327_store(arm, W327_ARM_IS_WILDCARD, v);
}


/** Match-arm setter pipeline_expr_match_arm_set_lit_val. PLATFORM: SHARED */
export function pipeline_expr_match_arm_set_lit_val(a: *u8, expr_ref: i32, i: i32, v: i32): void {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 1);
  if (arm == (0 as *u8)) { return; }
  w327_store(arm, W327_ARM_LIT_VAL, v);
}


/** Match-arm setter pipeline_expr_match_arm_set_guard_ref. PLATFORM: SHARED */
export function pipeline_expr_match_arm_set_guard_ref(a: *u8, expr_ref: i32, i: i32, v: i32): void {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 1);
  if (arm == (0 as *u8)) { return; }
  w327_store(arm, W327_ARM_GUARD_REF, v);
}


/** Match-arm set enum variant. PLATFORM: SHARED */
export function pipeline_expr_match_arm_set_enum_variant(a: *u8, expr_ref: i32, i: i32, is_var: i32, variant_index: i32): void {
  let arm: *u8 = expr_match_arm_at(a, expr_ref, i, 1);
  if (arm == (0 as *u8)) { return; }
  w327_store(arm, W327_ARM_IS_ENUM_VARIANT, is_var);
  w327_store(arm, W327_ARM_VARIANT_INDEX, variant_index);
}


/** Slot ref pipeline_expr_call_arg_ref. PLATFORM: SHARED */
export function pipeline_expr_call_arg_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  let slot: *u8 = expr_call_arg_slot(a, expr_ref, idx, 0);
  if (slot == (0 as *u8)) { return 0; }
  return w327_load(slot, 0);
}


/** Slot ref pipeline_expr_method_call_arg_ref. PLATFORM: SHARED */
export function pipeline_expr_method_call_arg_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  let slot: *u8 = expr_method_call_arg_slot(a, expr_ref, idx, 0);
  if (slot == (0 as *u8)) { return 0; }
  return w327_load(slot, 0);
}


/** Slot ref pipeline_expr_array_lit_elem_ref. PLATFORM: SHARED */
export function pipeline_expr_array_lit_elem_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  let slot: *u8 = expr_array_lit_elem_slot(a, expr_ref, idx, 0);
  if (slot == (0 as *u8)) { return 0; }
  return w327_load(slot, 0);
}


/** Struct lit field init_ref. PLATFORM: SHARED */
export function pipeline_expr_struct_lit_init_ref(a: *u8, expr_ref: i32, j: i32): i32 {
  let fe: *u8 = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (fe == (0 as *u8)) { return 0; }
  return w327_load(fe, W327_SLF_INIT_REF);
}


/** Struct lit field name_len. PLATFORM: SHARED */
export function pipeline_expr_struct_lit_field_name_len(a: *u8, expr_ref: i32, j: i32): i32 {
  let fe: *u8 = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (fe == (0 as *u8)) { return 0; }
  return w327_load(fe, W327_SLF_NAME_LEN);
}


/**
 * Fix call_arg_base when CALL node is created.
 * PLATFORM: SHARED
 */
export function pipeline_expr_on_call_created(a: *u8, expr_ref: i32): void {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  if (a == (0 as *u8) || expr_ref <= 0) { return; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_CALL_ARG_BASE, w327_gv_len(sc + (W327_SC_EXPR_CALL_ARG_REFS as usize)));
}

/**
 * Grow call-arg pool to next slot index.
 * PLATFORM: SHARED
 */
export function pipeline_expr_prepare_call_arg_slot(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let abs: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  if (w327_load(ex, W327_E_CALL_NUM_ARGS) == 0) {
    pipeline_expr_on_call_created(a, expr_ref);
  }
  abs = w327_load(ex, W327_E_CALL_ARG_BASE) + w327_load(ex, W327_E_CALL_NUM_ARGS);
  if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_CALL_ARG_REFS as usize), abs) == 0) { return 0 - 1; }
  return abs;
}

/**
 * Append one call arg ref.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_call_arg(a: *u8, expr_ref: i32, arg_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  if (pipeline_expr_prepare_call_arg_slot(a, expr_ref) < 0) { return 0 - 1; }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0 - 1; }
  idx = w327_load(ex, W327_E_CALL_NUM_ARGS);
  slot = expr_call_arg_slot(a, expr_ref, idx, 1);
  if (slot == (0 as *u8)) { return 0 - 1; }
  w327_store(slot, 0, arg_ref);
  w327_store(ex, W327_E_CALL_NUM_ARGS, idx + 1);
  return idx;
}

/**
 * Append method call arg.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_method_call_arg(a: *u8, expr_ref: i32, arg_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  idx = w327_load(ex, W327_E_METHOD_CALL_NUM_ARGS);
  if (idx == 0) {
    w327_store(ex, W327_E_METHOD_CALL_ARG_BASE, w327_gv_len(sc + (W327_SC_EXPR_METHOD_CALL_ARG_REFS as usize)));
  }
  slot = expr_method_call_arg_slot(a, expr_ref, idx, 1);
  if (slot == (0 as *u8)) { return 0 - 1; }
  w327_store(slot, 0, arg_ref);
  w327_store(ex, W327_E_METHOD_CALL_NUM_ARGS, idx + 1);
  return idx;
}

/**
 * Append array lit elem.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_array_lit_elem(a: *u8, expr_ref: i32, elem_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  idx = w327_load(ex, W327_E_ARRAY_LIT_NUM_ELEMS);
  if (idx == 0) {
    w327_store(ex, W327_E_ARRAY_LIT_ELEM_BASE, w327_gv_len(sc + (W327_SC_EXPR_ARRAY_LIT_ELEM_REFS as usize)));
  }
  slot = expr_array_lit_elem_slot(a, expr_ref, idx, 1);
  if (slot == (0 as *u8)) { return 0 - 1; }
  w327_store(slot, 0, elem_ref);
  w327_store(ex, W327_E_ARRAY_LIT_NUM_ELEMS, idx + 1);
  return idx;
}

/**
 * Append match arm.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_match_arm(a: *u8, expr_ref: i32, result_ref: i32,
    is_wildcard: i32, lit_val: i32, is_enum_variant: i32, variant_index: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let arm: *u8 = 0 as *u8;
  let idx: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  idx = w327_load(ex, W327_E_MATCH_NUM_ARMS);
  if (idx == 0) {
    w327_store(ex, W327_E_MATCH_ARM_BASE, w327_gv_len(sc + (W327_SC_EXPR_MATCH_ARMS as usize)));
  }
  arm = expr_match_arm_at(a, expr_ref, idx, 1);
  if (arm == (0 as *u8)) { return 0 - 1; }
  w327_store(arm, W327_ARM_RESULT_REF, result_ref);
  w327_store(arm, W327_ARM_IS_WILDCARD, is_wildcard);
  w327_store(arm, W327_ARM_LIT_VAL, lit_val);
  w327_store(arm, W327_ARM_IS_ENUM_VARIANT, is_enum_variant);
  w327_store(arm, W327_ARM_VARIANT_INDEX, variant_index);
  w327_store(arm, W327_ARM_GUARD_REF, 0);
  w327_store(ex, W327_E_MATCH_NUM_ARMS, idx + 1);
  return idx;
}

/**
 * Append struct lit field.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_struct_lit_field(a: *u8, expr_ref: i32, name_bytes: *u8,
    name_len: i32, init_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let sc: *u8 = 0 as *u8;
  let fe: *u8 = 0 as *u8;
  let idx: i32 = 0;
  let n: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  idx = w327_load(ex, W327_E_STRUCT_LIT_NUM_FIELDS);
  if (idx == 0) {
    w327_store(ex, W327_E_STRUCT_LIT_FIELD_BASE, w327_gv_len(sc + (W327_SC_EXPR_STRUCT_LIT_FIELDS as usize)));
  }
  fe = expr_struct_lit_field_at(a, expr_ref, idx, 1);
  if (fe == (0 as *u8)) { return 0 - 1; }
  unsafe { memset(fe, 0, W327_SLF_SZ as usize); }
  n = name_len;
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (name_bytes != (0 as *u8) && n > 0) {
    unsafe { memcpy(fe, name_bytes, n as usize); }
  }
  w327_store(fe, W327_SLF_NAME_LEN, n);
  w327_store(fe, W327_SLF_INIT_REF, init_ref);
  w327_store(ex, W327_E_STRUCT_LIT_NUM_FIELDS, idx + 1);
  return idx;
}

/**
 * Init call resolve indices to -1 on Expr pointer.
 * PLATFORM: SHARED
 */
export function pipeline_expr_ptr_init_call_resolve(e: *u8): void {
  if (e == (0 as *u8)) { return; }
  w327_store(e, W327_E_CALL_RESOLVED_FUNC_INDEX, 0 - 1);
  w327_store(e, W327_E_CALL_RESOLVED_DEP_INDEX, 0 - 1);
}

/**
 * Init call resolve at expr_ref.
 * PLATFORM: SHARED
 */
export function pipeline_expr_init_call_resolve_at_ref(a: *u8, expr_ref: i32): void {
  pipeline_expr_ptr_init_call_resolve(w327_expr(a, expr_ref));
}

/**
 * Apply call resolve dep/func indices.
 * PLATFORM: SHARED
 */
export function pipeline_expr_apply_call_resolve(a: *u8, expr_ref: i32, dep_ix: i32, func_ix: i32): void {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_CALL_RESOLVED_DEP_INDEX, dep_ix);
  w327_store(ex, W327_E_CALL_RESOLVED_FUNC_INDEX, func_ix);
}


/** Copy name bytes: pipeline_expr_var_name_into. PLATFORM: SHARED */
export function pipeline_expr_var_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  let ex: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (out64 == (0 as *u8)) { return; }
  unsafe { memset(out64, 0, 256 as usize); }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  nlen = w327_load(ex, W327_E_VAR_NAME_LEN);
  if (nlen < 0) { nlen = 0; }
  if (nlen > 255) { nlen = 255; }
  if (nlen > 0) {
    unsafe { memcpy(out64, ex + (W327_E_VAR_NAME as usize), nlen as usize); }
  }
}


/** Copy name bytes: pipeline_expr_field_access_name_into. PLATFORM: SHARED */
export function pipeline_expr_field_access_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  let ex: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (out64 == (0 as *u8)) { return; }
  unsafe { memset(out64, 0, 256 as usize); }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  nlen = w327_load(ex, W327_E_FIELD_ACCESS_FIELD_LEN);
  if (nlen < 0) { nlen = 0; }
  if (nlen > 255) { nlen = 255; }
  if (nlen > 0) {
    unsafe { memcpy(out64, ex + (W327_E_FIELD_ACCESS_FIELD_NAME as usize), nlen as usize); }
  }
}


/** Copy name bytes: pipeline_expr_field_name_into. PLATFORM: SHARED */
export function pipeline_expr_field_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  let ex: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (out64 == (0 as *u8)) { return; }
  unsafe { memset(out64, 0, 256 as usize); }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  nlen = w327_load(ex, W327_E_FIELD_ACCESS_FIELD_LEN);
  if (nlen < 0) { nlen = 0; }
  if (nlen > 255) { nlen = 255; }
  if (nlen > 0) {
    unsafe { memcpy(out64, ex + (W327_E_FIELD_ACCESS_FIELD_NAME as usize), nlen as usize); }
  }
}


/** Copy name bytes: pipeline_expr_method_call_name_into. PLATFORM: SHARED */
export function pipeline_expr_method_call_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  let ex: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (out64 == (0 as *u8)) { return; }
  unsafe { memset(out64, 0, 256 as usize); }
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  nlen = w327_load(ex, W327_E_METHOD_CALL_NAME_LEN);
  if (nlen < 0) { nlen = 0; }
  if (nlen > 255) { nlen = 255; }
  if (nlen > 0) {
    unsafe { memcpy(out64, ex + (W327_E_METHOD_CALL_NAME as usize), nlen as usize); }
  }
}


/** Copy name bytes: pipeline_expr_struct_lit_field_name_into. PLATFORM: SHARED */
export function pipeline_expr_struct_lit_field_name_into(a: *u8, expr_ref: i32, j: i32, out64: *u8): void {
  let fe: *u8 = 0 as *u8;
  let nlen: i32 = 0;
  if (out64 == (0 as *u8)) { return; }
  unsafe { memset(out64, 0, 256 as usize); }
  fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (fe == (0 as *u8)) { return; }
  nlen = w327_load(fe, W327_SLF_NAME_LEN);
  if (nlen < 0) { nlen = 0; }
  if (nlen > 255) { nlen = 255; }
  if (nlen > 0) {
    unsafe { memcpy(out64, fe, nlen as usize); }
  }
}


/** Set var_name bytes. PLATFORM: SHARED */
export function pipeline_expr_set_var_name(a: *u8, er: i32, nm: *u8, nlen: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  unsafe { memset(ex + (W327_E_VAR_NAME as usize), 0, 256 as usize); }
  n = nlen;
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  i = 0;
  while (i < n) {
    if (nm != (0 as *u8)) {
      unsafe { *((ex + (W327_E_VAR_NAME as usize)) + (i as usize)) = *(nm + (i as usize)); }
    }
    i = i + 1;
  }
  w327_store(ex, W327_E_VAR_NAME_LEN, n);
}


/** True if EXPR_LIT encodes null keyword. PLATFORM: SHARED */
export function pipeline_expr_is_null_keyword_c(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = 0 as *u8;
  let p: *u8 = 0 as *u8;
  let b0: u8 = 0 as u8;
  let b1: u8 = 0 as u8;
  let b2: u8 = 0 as u8;
  let b3: u8 = 0 as u8;
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8) || w327_load(ex, W327_E_KIND) != 0) { return 0; }
  if (w327_load_i64(ex, W327_E_INT_VAL) != 0 || w327_load(ex, W327_E_VAR_NAME_LEN) != 4) { return 0; }
  p = ex + (W327_E_VAR_NAME as usize);
  unsafe {
    b0 = *p;
    b1 = *(p + (1 as usize));
    b2 = *(p + (2 as usize));
    b3 = *(p + (3 as usize));
  }
  if (b0 == (110 as u8) && b1 == (117 as u8) && b2 == (108 as u8) && b3 == (108 as u8)) { return 1; }
  return 0;
}


/** Tag expr as null keyword LIT. PLATFORM: SHARED */
export function pipeline_expr_tag_null_keyword_c(a: *u8, expr_ref: i32): void {
  let ex: *u8 = 0 as *u8;
  let p: *u8 = 0 as *u8;
  let zi: i32 = 0;
  ex = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return; }
  w327_store_i64(ex, W327_E_INT_VAL, 0);
  p = ex + (W327_E_VAR_NAME as usize);
  unsafe {
    *(p + (0 as usize)) = 110 as u8;
    *(p + (1 as usize)) = 117 as u8;
    *(p + (2 as usize)) = 108 as u8;
    *(p + (3 as usize)) = 108 as u8;
  }
  w327_store(ex, W327_E_VAR_NAME_LEN, 4);
  zi = 4;
  while (zi < 256) {
    unsafe { *(p + (zi as usize)) = 0 as u8; }
    zi = zi + 1;
  }
}


/** Wipe common Expr ref/base/count fields. PLATFORM: SHARED */
export function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void {
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_RESOLVED_TYPE_REF, 0);
  w327_store(ex, W327_E_BINOP_LEFT_REF, 0);
  w327_store(ex, W327_E_BINOP_RIGHT_REF, 0);
  w327_store(ex, W327_E_UNARY_OPERAND_REF, 0);
  w327_store(ex, W327_E_IF_COND_REF, 0);
  w327_store(ex, W327_E_IF_THEN_REF, 0);
  w327_store(ex, W327_E_IF_ELSE_REF, 0);
  w327_store(ex, W327_E_BLOCK_REF, 0);
  w327_store(ex, W327_E_MATCH_MATCHED_REF, 0);
  w327_store(ex, W327_E_MATCH_ARM_BASE, 0);
  w327_store(ex, W327_E_MATCH_NUM_ARMS, 0);
  w327_store(ex, W327_E_ENUM_VARIANT_TAG, 0);
  w327_store(ex, W327_E_FIELD_ACCESS_BASE_REF, 0);
  w327_store(ex, W327_E_FIELD_ACCESS_FIELD_LEN, 0);
  w327_store(ex, W327_E_FIELD_ACCESS_IS_ENUM_VARIANT, 0);
  w327_store(ex, W327_E_FIELD_ACCESS_OFFSET, 0);
  w327_store(ex, W327_E_INDEX_BASE_REF, 0);
  w327_store(ex, W327_E_INDEX_INDEX_REF, 0);
  w327_store(ex, W327_E_INDEX_BASE_IS_SLICE, 0);
  w327_store(ex, W327_E_CALL_CALLEE_REF, 0);
  w327_store(ex, W327_E_CALL_ARG_BASE, 0);
  w327_store(ex, W327_E_CALL_NUM_ARGS, 0);
  w327_store(ex, W327_E_CALL_NUM_TYPE_ARGS, 0);
  w327_store(ex, W327_E_VAR_NAME_LEN, 0);
}


/** Compound setter pipeline_expr_set_call_c. PLATFORM: SHARED */
export function pipeline_expr_set_call_c(a: *u8, er: i32, callee_ref: i32, num_type_args: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_CALL_CALLEE_REF, callee_ref);
  w327_store(ex, W327_E_CALL_NUM_TYPE_ARGS, num_type_args);
}


/** Compound setter pipeline_expr_set_index_c. PLATFORM: SHARED */
export function pipeline_expr_set_index_c(a: *u8, er: i32, base_ref: i32, index_ref: i32, is_slice: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_INDEX_BASE_REF, base_ref);
  w327_store(ex, W327_E_INDEX_INDEX_REF, index_ref);
  w327_store(ex, W327_E_INDEX_BASE_IS_SLICE, is_slice);
}


/** Compound setter pipeline_expr_set_field_access_c. PLATFORM: SHARED */
export function pipeline_expr_set_field_access_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_FIELD_ACCESS_BASE_REF, base_ref);
  w327_store(ex, W327_E_FIELD_ACCESS_FIELD_LEN, nlen);
  unsafe { memset(ex + (W327_E_FIELD_ACCESS_FIELD_NAME as usize), 0, 256 as usize); }
  unsafe { memset(ex + (W327_E_FIELD_ACCESS_FIELD_NAME as usize), 0, 256 as usize); }
  n = nlen;
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (nm != (0 as *u8) && n > 0) {
    unsafe { memcpy(ex + (W327_E_FIELD_ACCESS_FIELD_NAME as usize), nm, n as usize); }
  }
  w327_store(ex, W327_E_FIELD_ACCESS_FIELD_LEN, n);
}


/** Compound setter pipeline_expr_set_method_call_c. PLATFORM: SHARED */
export function pipeline_expr_set_method_call_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_METHOD_CALL_BASE_REF, base_ref);
  w327_store(ex, W327_E_METHOD_CALL_NAME_LEN, nlen);
  unsafe { memset(ex + (W327_E_METHOD_CALL_NAME as usize), 0, 256 as usize); }
  n = nlen;
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (nm != (0 as *u8) && n > 0) {
    unsafe { memcpy(ex + (W327_E_METHOD_CALL_NAME as usize), nm, n as usize); }
  }
  w327_store(ex, W327_E_METHOD_CALL_NAME_LEN, n);
}


/** Compound setter pipeline_expr_set_struct_lit_finish_c. PLATFORM: SHARED */
export function pipeline_expr_set_struct_lit_finish_c(a: *u8, er: i32, nm: *u8, nlen: i32): void {
  let ex: *u8 = 0 as *u8;
  let n: i32 = 0;
  let i: i32 = 0;
  if (a == (0 as *u8) || er <= 0 || er > w327_num_exprs(a)) { return; }
  ex = w327_expr(a, er);
  if (ex == (0 as *u8)) { return; }
  w327_store(ex, W327_E_KIND, 45);
  w327_store(ex, W327_E_STRUCT_LIT_STRUCT_NAME_LEN, nlen);
  w327_store(ex, W327_E_STRUCT_LIT_FIELD_BASE, 0);
  w327_store(ex, W327_E_STRUCT_LIT_NUM_FIELDS, 0);
  unsafe { memset(ex + (W327_E_STRUCT_LIT_STRUCT_NAME as usize), 0, 256 as usize); }
  n = nlen;
  if (n < 0) { n = 0; }
  if (n > 255) { n = 255; }
  if (nm != (0 as *u8) && n > 0) {
    unsafe { memcpy(ex + (W327_E_STRUCT_LIT_STRUCT_NAME as usize), nm, n as usize); }
  }
  w327_store(ex, W327_E_STRUCT_LIT_STRUCT_NAME_LEN, n);
}


/**
 * Ensure expr_call_type_arg_bases has slot for expr_ref; return i32 cell ptr.
 * PLATFORM: SHARED
 */
function expr_call_type_arg_base_cell(a: *u8, expr_ref: i32, create: i32): *u8 {
  let sc: *u8 = 0 as *u8;
  let gv: *u8 = 0 as *u8;
  let cell: *u8 = 0 as *u8;
  let idx: i32 = 0;
  let neg1: i32 = 0 - 1;
  if (a == (0 as *u8) || expr_ref <= 0) { return 0 as *u8; }
  sc = w327_sc(a, create);
  if (sc == (0 as *u8)) { return 0 as *u8; }
  gv = sc + (W327_SC_EXPR_CALL_TYPE_ARG_BASES as usize);
  if (create == 0 && expr_ref >= w327_gv_len(gv)) {
    return 0 as *u8;
  }
  while (expr_ref >= w327_gv_len(gv)) {
    idx = w529_gv_push(gv);
    if (idx < 0) { return 0 as *u8; }
    cell = w529_gv_at(gv, idx);
    if (cell == (0 as *u8)) { return 0 as *u8; }
    w327_store(cell, 0, neg1);
  }
  cell = w529_gv_at(gv, expr_ref);
  return cell;
}


/**
 * Append CALL turbofish type arg.
 * PLATFORM: SHARED
 */
export function pipeline_expr_append_call_type_arg(a: *u8, expr_ref: i32, type_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let base_cell: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let base: i32 = 0;
  let abs: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0 || type_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0 - 1; }
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 1);
  if (base_cell == (0 as *u8)) { return 0 - 1; }
  if (w327_load(base_cell, 0) < 0) {
    w327_store(base_cell, 0, w327_gv_len(sc + (W327_SC_EXPR_CALL_TYPE_ARG_REFS as usize)));
    w327_store(ex, W327_E_CALL_NUM_TYPE_ARGS, 0);
  }
  base = w327_load(base_cell, 0);
  abs = base + w327_load(ex, W327_E_CALL_NUM_TYPE_ARGS);
  if (w327_gv_ensure_abs(sc + (W327_SC_EXPR_CALL_TYPE_ARG_REFS as usize), abs) == 0) { return 0 - 1; }
  slot = w529_gv_at(sc + (W327_SC_EXPR_CALL_TYPE_ARG_REFS as usize), abs);
  if (slot == (0 as *u8)) { return 0 - 1; }
  w327_store(slot, 0, type_ref);
  w327_store(ex, W327_E_CALL_NUM_TYPE_ARGS, w327_load(ex, W327_E_CALL_NUM_TYPE_ARGS) + 1);
  return 0;
}

/**
 * CALL type arg ref at idx.
 * PLATFORM: SHARED
 */
export function pipeline_expr_call_type_arg_ref_at(a: *u8, expr_ref: i32, idx: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let ex: *u8 = 0 as *u8;
  let base_cell: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let base: i32 = 0;
  let abs: i32 = 0;
  if (a == (0 as *u8) || expr_ref <= 0 || idx < 0) { return 0; }
  sc = w327_sc(a, 0);
  ex = w327_expr(a, expr_ref);
  if (sc == (0 as *u8) || ex == (0 as *u8)) { return 0; }
  if (idx >= w327_load(ex, W327_E_CALL_NUM_TYPE_ARGS)) { return 0; }
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 0);
  if (base_cell == (0 as *u8) || w327_load(base_cell, 0) < 0) { return 0; }
  base = w327_load(base_cell, 0);
  abs = base + idx;
  if (abs < 0 || abs >= w327_gv_len(sc + (W327_SC_EXPR_CALL_TYPE_ARG_REFS as usize))) { return 0; }
  slot = w529_gv_at(sc + (W327_SC_EXPR_CALL_TYPE_ARG_REFS as usize), abs);
  if (slot == (0 as *u8)) { return 0; }
  return w327_load(slot, 0);
}

/**
 * Append TYPE_NAMED type-position type arg.
 * PLATFORM: SHARED
 */
export function pipeline_type_append_type_arg(a: *u8, type_ref: i32, arg_ref: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let base_cell: *u8 = 0 as *u8;
  let count_cell: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let base: i32 = 0;
  let n: i32 = 0;
  let abs: i32 = 0;
  let idx: i32 = 0;
  if (a == (0 as *u8) || type_ref <= 0 || arg_ref <= 0) { return 0 - 1; }
  sc = w327_sc(a, 1);
  if (sc == (0 as *u8)) { return 0 - 1; }
  while (type_ref >= w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize))) {
    idx = w529_gv_push(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize));
    if (idx < 0) { return 0 - 1; }
    base_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize), idx);
    if (base_cell == (0 as *u8)) { return 0 - 1; }
    w327_store(base_cell, 0, 0 - 1);
  }
  while (type_ref >= w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize))) {
    idx = w529_gv_push(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize));
    if (idx < 0) { return 0 - 1; }
    count_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize), idx);
    if (count_cell == (0 as *u8)) { return 0 - 1; }
    w327_store(count_cell, 0, 0);
  }
  base_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize), type_ref);
  count_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize), type_ref);
  if (base_cell == (0 as *u8) || count_cell == (0 as *u8)) { return 0 - 1; }
  if (w327_load(base_cell, 0) < 0) {
    w327_store(base_cell, 0, w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_REFS as usize)));
    w327_store(count_cell, 0, 0);
  }
  base = w327_load(base_cell, 0);
  n = w327_load(count_cell, 0);
  abs = base + n;
  if (w327_gv_ensure_abs(sc + (W327_SC_TYPE_TYPE_ARG_REFS as usize), abs) == 0) { return 0 - 1; }
  slot = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_REFS as usize), abs);
  if (slot == (0 as *u8)) { return 0 - 1; }
  w327_store(slot, 0, arg_ref);
  w327_store(count_cell, 0, n + 1);
  return 0;
}

/**
 * TYPE_NAMED type-pos arg at idx.
 * PLATFORM: SHARED
 */
export function pipeline_type_type_arg_ref_at(a: *u8, type_ref: i32, idx: i32): i32 {
  let sc: *u8 = 0 as *u8;
  let base_cell: *u8 = 0 as *u8;
  let count_cell: *u8 = 0 as *u8;
  let slot: *u8 = 0 as *u8;
  let base: i32 = 0;
  let abs: i32 = 0;
  if (a == (0 as *u8) || type_ref <= 0 || idx < 0) { return 0; }
  sc = w327_sc(a, 0);
  if (sc == (0 as *u8)) { return 0; }
  if (type_ref >= w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize))) { return 0; }
  if (type_ref >= w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize))) { return 0; }
  base_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_BASES as usize), type_ref);
  count_cell = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_COUNTS as usize), type_ref);
  if (base_cell == (0 as *u8) || count_cell == (0 as *u8)) { return 0; }
  if (w327_load(base_cell, 0) < 0) { return 0; }
  if (idx >= w327_load(count_cell, 0)) { return 0; }
  base = w327_load(base_cell, 0);
  abs = base + idx;
  if (abs < 0 || abs >= w327_gv_len(sc + (W327_SC_TYPE_TYPE_ARG_REFS as usize))) { return 0; }
  slot = w529_gv_at(sc + (W327_SC_TYPE_TYPE_ARG_REFS as usize), abs);
  if (slot == (0 as *u8)) { return 0; }
  return w327_load(slot, 0);
}


/** Getter pipeline_expr_call_num_type_args_at. PLATFORM: SHARED */
export function pipeline_expr_call_num_type_args_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_CALL_NUM_TYPE_ARGS);
}


/** Getter pipeline_expr_field_access_base_ref. PLATFORM: SHARED */
export function pipeline_expr_field_access_base_ref(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_FIELD_ACCESS_BASE_REF);
}


/** Getter pipeline_expr_field_access_name_len. PLATFORM: SHARED */
export function pipeline_expr_field_access_name_len(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_FIELD_ACCESS_FIELD_LEN);
}


/** Getter pipeline_expr_field_name_len_at. PLATFORM: SHARED */
export function pipeline_expr_field_name_len_at(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_FIELD_ACCESS_FIELD_LEN);
}


/** Getter pipeline_expr_var_name_len. PLATFORM: SHARED */
export function pipeline_expr_var_name_len(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_VAR_NAME_LEN);
}


/** Getter pipeline_expr_var_name_len_for_string_lit_c. PLATFORM: SHARED */
export function pipeline_expr_var_name_len_for_string_lit_c(a: *u8, expr_ref: i32): i32 {
  let ex: *u8 = w327_expr(a, expr_ref);
  if (ex == (0 as *u8)) { return 0; }
  return w327_load(ex, W327_E_VAR_NAME_LEN);
}


/**
 * Recurse expr tree stamping block_ref on VAR nodes.
 * PLATFORM: SHARED
 */
function glue_var_blk_walk_expr(a: *u8, er: i32, blk: i32): void {
  let ko: i32 = 0;
  let l: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let ex: *u8 = 0 as *u8;
  if (a == (0 as *u8) || er <= 0) { return; }
  unsafe { ko = pipeline_expr_kind_ord_at(a, er); }
  if (ko == 3) {
    ex = w327_expr(a, er);
    if (ex != (0 as *u8) && w327_load(ex, W327_E_BLOCK_REF) == 0) {
      w327_store(ex, W327_E_BLOCK_REF, blk);
    }
    return;
  }
  if ((ko >= 4 && ko <= 21) || (ko >= 28 && ko <= 38)) {
    unsafe { l = pipeline_expr_binop_left_ref_at(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    unsafe { l = pipeline_expr_binop_right_ref_at(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 50 || ko == 51) {
    unsafe { l = pipeline_expr_unary_operand_ref_at(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  unsafe { l = pipeline_expr_as_operand_ref_at(a, er); }
  if (l > 0) {
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  if (ko == 44) {
    unsafe { l = pipeline_expr_field_access_base_ref(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  if (ko == 46) {
    unsafe { n = pipeline_expr_array_lit_num_elems_at(a, er); }
    i = 0;
    while (i < n) {
      unsafe { l = pipeline_expr_array_lit_elem_ref(a, er, i); }
      glue_var_blk_walk_expr(a, l, blk);
      i = i + 1;
    }
    return;
  }
  if (ko == 45) {
    unsafe { n = pipeline_expr_struct_lit_num_fields(a, er); }
    i = 0;
    while (i < n) {
      unsafe { l = pipeline_expr_struct_lit_init_ref(a, er, i); }
      glue_var_blk_walk_expr(a, l, blk);
      i = i + 1;
    }
    return;
  }
  if (ko == 47) {
    unsafe { l = pipeline_expr_index_base_ref(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    unsafe { l = pipeline_expr_index_index_ref(a, er); }
    glue_var_blk_walk_expr(a, l, blk);
    return;
  }
  if (ko == 48 || ko == 49) {
    unsafe { n = pipeline_expr_call_num_args_at(a, er); }
    i = 0;
    while (i < n) {
      unsafe { l = pipeline_expr_call_arg_ref(a, er, i); }
      glue_var_blk_walk_expr(a, l, blk);
      i = i + 1;
    }
    return;
  }
}

/**
 * Stamp block_ref on VAR exprs under block tree.
 * PLATFORM: SHARED
 */
export function glue_fill_var_block_refs_c(a: *u8, block_ref: i32): void {
  let stack_blk: i32[256] = [];
  let sp: i32 = 0;
  let cur: i32 = 0;
  let i: i32 = 0;
  let n: i32 = 0;
  let er: i32 = 0;
  let b: *u8 = 0 as *u8;
  let wb: i32 = 0;
  let fb: i32 = 0;
  let tb: i32 = 0;
  let eb: i32 = 0;
  let rgb: i32 = 0;
  let nblocks: i32 = 0;
  if (a == (0 as *u8) || block_ref <= 0) { return; }
  stack_blk[0] = block_ref;
  sp = 1;
  while (sp > 0) {
    sp = sp - 1;
    cur = stack_blk[sp];
    nblocks = w327_load(a, W327_ARENA_NUM_BLOCKS);
    if (cur <= 0 || cur > nblocks) { continue; }
    b = w529_block_ptr(a, cur);
    if (b == (0 as *u8)) { continue; }
    unsafe { n = ast_ast_block_num_expr_stmts(a, cur); }
    i = 0;
    while (i < n) {
      unsafe { er = pipeline_block_expr_stmt_ref(a, cur, i); }
      glue_var_blk_walk_expr(a, er, cur);
      i = i + 1;
    }
    unsafe { er = ast_ast_block_final_expr_ref(a, cur); }
    if (er > 0) { glue_var_blk_walk_expr(a, er, cur); }
    unsafe { n = ast_ast_block_num_lets(a, cur); }
    i = 0;
    while (i < n) {
      unsafe { er = pipeline_block_let_init_ref(a, cur, i); }
      glue_var_blk_walk_expr(a, er, cur);
      i = i + 1;
    }
    unsafe { n = ast_ast_block_num_consts(a, cur); }
    i = 0;
    while (i < n) {
      unsafe { er = pipeline_block_const_init_ref(a, cur, i); }
      glue_var_blk_walk_expr(a, er, cur);
      i = i + 1;
    }
    n = w327_load(b, W327_B_NUM_LOOPS);
    i = 0;
    while (i < n) {
      unsafe { wb = pipeline_block_while_body_ref(a, cur, i); }
      if (wb > 0 && sp < 256) { stack_blk[sp] = wb; sp = sp + 1; }
      i = i + 1;
    }
    n = w327_load(b, W327_B_NUM_FOR_LOOPS);
    i = 0;
    while (i < n) {
      unsafe { fb = pipeline_block_for_body_ref(a, cur, i); }
      if (fb > 0 && sp < 256) { stack_blk[sp] = fb; sp = sp + 1; }
      i = i + 1;
    }
    n = w327_load(b, W327_B_NUM_IF_STMTS);
    i = 0;
    while (i < n) {
      unsafe { tb = pipeline_block_if_then_body_ref(a, cur, i); }
      if (tb > 0 && sp < 256) { stack_blk[sp] = tb; sp = sp + 1; }
      unsafe { eb = pipeline_block_if_else_body_ref(a, cur, i); }
      if (eb > 0 && sp < 256) { stack_blk[sp] = eb; sp = sp + 1; }
      i = i + 1;
    }
    n = w327_load(b, W327_B_NUM_REGIONS);
    i = 0;
    while (i < n) {
      unsafe { rgb = pipeline_block_region_body_ref(a, cur, i); }
      if (rgb > 0 && sp < 256) { stack_blk[sp] = rgb; sp = sp + 1; }
      i = i + 1;
    }
  }
}


/** Shim ast_pipeline_expr_ptr_init_call_resolve. PLATFORM: SHARED */
export function ast_pipeline_expr_ptr_init_call_resolve(e: *u8): void {
  pipeline_expr_ptr_init_call_resolve(e);
}


/** Shim ast_pipeline_expr_init_call_resolve_at_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_init_call_resolve_at_ref(a: *u8, expr_ref: i32): void {
  pipeline_expr_init_call_resolve_at_ref(a, expr_ref);
}


/** Shim ast_pipeline_expr_apply_call_resolve. PLATFORM: SHARED */
export function ast_pipeline_expr_apply_call_resolve(a: *u8, expr_ref: i32, dep_ix: i32, func_ix: i32): void {
  pipeline_expr_apply_call_resolve(a, expr_ref, dep_ix, func_ix);
}


/** Shim ast_pipeline_expr_set_const_folded. PLATFORM: SHARED */
export function ast_pipeline_expr_set_const_folded(a: *u8, expr_ref: i32, valid: i32, val: i32): void {
  pipeline_expr_set_const_folded(a, expr_ref, valid, val);
}


/** Shim ast_pipeline_expr_as_operand_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_as_operand_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_as_operand_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_enum_variant_tag_at. PLATFORM: SHARED */
export function ast_pipeline_expr_enum_variant_tag_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_enum_variant_tag_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_if_cond_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_if_cond_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_if_cond_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_if_then_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_if_then_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_if_then_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_if_else_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_if_else_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_if_else_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_block_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_block_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_block_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_match_matched_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_match_matched_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_match_matched_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_const_folded_valid_at. PLATFORM: SHARED */
export function ast_pipeline_expr_const_folded_valid_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_const_folded_valid_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_const_folded_val_at. PLATFORM: SHARED */
export function ast_pipeline_expr_const_folded_val_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_const_folded_val_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_index_base_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_index_base_ref(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_index_base_ref(a, expr_ref);
}


/** Shim ast_pipeline_expr_index_index_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_index_index_ref(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_index_index_ref(a, expr_ref);
}


/** Shim ast_pipeline_expr_field_access_offset. PLATFORM: SHARED */
export function ast_pipeline_expr_field_access_offset(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_field_access_offset(a, expr_ref);
}


/** Shim codegen_pipeline_module_func_param_type_ref_at. PLATFORM: SHARED */
export function codegen_pipeline_module_func_param_type_ref_at(m: *u8, func_index: i32, param_index: i32): i32 {
  unsafe {
    return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
  }
}


/** Shim ast_pipeline_expr_append_call_arg. PLATFORM: SHARED */
export function ast_pipeline_expr_append_call_arg(a: *u8, expr_ref: i32, arg_ref: i32): i32 {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}


/** Shim ast_pipeline_expr_on_call_created. PLATFORM: SHARED */
export function ast_pipeline_expr_on_call_created(a: *u8, expr_ref: i32): void {
  pipeline_expr_on_call_created(a, expr_ref);
}


/** Shim ast_pipeline_expr_prepare_call_arg_slot. PLATFORM: SHARED */
export function ast_pipeline_expr_prepare_call_arg_slot(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_prepare_call_arg_slot(a, expr_ref);
}


/** Shim ast_pipeline_expr_call_arg_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_call_arg_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}


/** Shim ast_pipeline_expr_call_num_args_at. PLATFORM: SHARED */
export function ast_pipeline_expr_call_num_args_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_append_method_call_arg. PLATFORM: SHARED */
export function ast_pipeline_expr_append_method_call_arg(a: *u8, expr_ref: i32, arg_ref: i32): i32 {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}


/** Shim ast_pipeline_expr_method_call_arg_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_method_call_arg_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}


/** Shim ast_pipeline_expr_append_match_arm. PLATFORM: SHARED */
export function ast_pipeline_expr_append_match_arm(a: *u8, expr_ref: i32, result_ref: i32, is_wildcard: i32, lit_val: i32, is_enum_variant: i32, variant_index: i32): i32 {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}


/** Shim ast_pipeline_expr_match_num_arms_at. PLATFORM: SHARED */
export function ast_pipeline_expr_match_num_arms_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_match_arm_result_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_result_ref(a: *u8, expr_ref: i32, i: i32): i32 {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}


/** Shim ast_pipeline_expr_match_arm_is_wildcard. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_is_wildcard(a: *u8, expr_ref: i32, i: i32): i32 {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}


/** Shim ast_pipeline_expr_match_arm_lit_val. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_lit_val(a: *u8, expr_ref: i32, i: i32): i32 {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}


/** Shim ast_pipeline_expr_match_arm_is_enum_variant. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_is_enum_variant(a: *u8, expr_ref: i32, i: i32): i32 {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}


/** Shim ast_pipeline_expr_match_arm_variant_index. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_variant_index(a: *u8, expr_ref: i32, i: i32): i32 {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}


/** Shim ast_pipeline_expr_match_arm_set_wildcard. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_set_wildcard(a: *u8, expr_ref: i32, i: i32, v: i32): void {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}


/** Shim ast_pipeline_expr_match_arm_set_lit_val. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_set_lit_val(a: *u8, expr_ref: i32, i: i32, v: i32): void {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}


/** Shim ast_pipeline_expr_match_arm_set_enum_variant. PLATFORM: SHARED */
export function ast_pipeline_expr_match_arm_set_enum_variant(a: *u8, expr_ref: i32, i: i32, is_var: i32, variant_index: i32): void {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}


/** Shim ast_pipeline_expr_append_struct_lit_field. PLATFORM: SHARED */
export function ast_pipeline_expr_append_struct_lit_field(a: *u8, expr_ref: i32, name_bytes: *u8, name_len: i32, init_ref: i32): i32 {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}


/** Shim ast_pipeline_expr_struct_lit_num_fields. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_num_fields(a, expr_ref);
  }
}


/** Shim ast_pipeline_expr_struct_lit_init_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_init_ref(a: *u8, expr_ref: i32, j: i32): i32 {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}


/** Shim ast_pipeline_expr_struct_lit_field_name_len. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_field_name_len(a: *u8, expr_ref: i32, j: i32): i32 {
  return pipeline_expr_struct_lit_field_name_len(a, expr_ref, j);
}


/** Shim ast_pipeline_expr_struct_lit_field_name_into. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_field_name_into(a: *u8, expr_ref: i32, j: i32, out64: *u8): void {
  pipeline_expr_struct_lit_field_name_into(a, expr_ref, j, out64);
}


/** Shim ast_pipeline_expr_struct_lit_type_name_len. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_type_name_len(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_type_name_len(a, expr_ref);
  }
}


/** Shim ast_pipeline_expr_struct_lit_type_name_into. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_type_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  unsafe {
    pipeline_expr_struct_lit_type_name_into(a, expr_ref, out64);
  }
}


/** Shim ast_pipeline_expr_struct_lit_type_name_set. PLATFORM: SHARED */
export function ast_pipeline_expr_struct_lit_type_name_set(a: *u8, expr_ref: i32, name: *u8, name_len: i32): void {
  unsafe {
    pipeline_expr_struct_lit_type_name_set(a, expr_ref, name, name_len);
  }
}


/** Shim ast_pipeline_expr_append_array_lit_elem. PLATFORM: SHARED */
export function ast_pipeline_expr_append_array_lit_elem(a: *u8, expr_ref: i32, elem_ref: i32): i32 {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}


/** Shim ast_pipeline_expr_array_lit_elem_ref. PLATFORM: SHARED */
export function ast_pipeline_expr_array_lit_elem_ref(a: *u8, expr_ref: i32, idx: i32): i32 {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}


/** Shim ast_pipeline_expr_array_lit_num_elems_at. PLATFORM: SHARED */
export function ast_pipeline_expr_array_lit_num_elems_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_float_bits_lo_at. PLATFORM: SHARED */
export function ast_pipeline_expr_float_bits_lo_at(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_float_bits_lo_at(a, expr_ref);
  }
}


/** Shim ast_pipeline_expr_float_bits_hi_at. PLATFORM: SHARED */
export function ast_pipeline_expr_float_bits_hi_at(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_float_bits_hi_at(a, expr_ref);
  }
}


/** Shim ast_pipeline_expr_call_callee_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_call_callee_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_call_callee_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_method_call_base_ref_at. PLATFORM: SHARED */
export function ast_pipeline_expr_method_call_base_ref_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_method_call_base_ref_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_method_call_num_args_at. PLATFORM: SHARED */
export function ast_pipeline_expr_method_call_num_args_at(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_method_call_num_args_at(a, expr_ref);
}


/** Shim ast_pipeline_expr_method_call_name_len. PLATFORM: SHARED */
export function ast_pipeline_expr_method_call_name_len(a: *u8, expr_ref: i32): i32 {
  return pipeline_expr_method_call_name_len(a, expr_ref);
}


/** Shim ast_pipeline_expr_method_call_name_into. PLATFORM: SHARED */
export function ast_pipeline_expr_method_call_name_into(a: *u8, expr_ref: i32, out64: *u8): void {
  pipeline_expr_method_call_name_into(a, expr_ref, out64);
}


/** Shim ast_pipeline_expr_field_access_is_enum_variant. PLATFORM: SHARED */
export function ast_pipeline_expr_field_access_is_enum_variant(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
  }
}


/** Shim ast_pipeline_expr_field_access_layout_offset. PLATFORM: SHARED */
export function ast_pipeline_expr_field_access_layout_offset(a: *u8, m: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_field_access_layout_offset(a, m, expr_ref);
  }
}


/** Shim ast_pipeline_expr_field_access_load_byte_sz. PLATFORM: SHARED */
export function ast_pipeline_expr_field_access_load_byte_sz(a: *u8, m: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_field_access_load_byte_sz(a, m, expr_ref);
  }
}


/** Shim ast_pipeline_module_import_append_select_name. PLATFORM: SHARED */
export function ast_pipeline_module_import_append_select_name(m: *u8, idx: i32, bytes: *u8, len: i32): i32 {
  unsafe {
    return pipeline_module_import_append_select_name(m, idx, bytes, len);
  }
}


/** Shim codegen_pipeline_expr_kind_ord_at. PLATFORM: SHARED */
export function codegen_pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_kind_ord_at(a, expr_ref);
  }
}


/** Shim codegen_pipeline_expr_struct_lit_num_fields. PLATFORM: SHARED */
export function codegen_pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_num_fields(a, expr_ref);
  }
}


/** Shim codegen_pipeline_expr_struct_lit_init_ref. PLATFORM: SHARED */
export function codegen_pipeline_expr_struct_lit_init_ref(a: *u8, expr_ref: i32, j: i32): i32 {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}


/** Shim backend_pipeline_expr_struct_lit_num_fields. PLATFORM: SHARED */
export function backend_pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_num_fields(a, expr_ref);
  }
}


/** Shim backend_pipeline_expr_struct_lit_init_ref. PLATFORM: SHARED */
export function backend_pipeline_expr_struct_lit_init_ref(a: *u8, expr_ref: i32, j: i32): i32 {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}


/** Shim codegen_pipeline_expr_struct_lit_field_offset_at. PLATFORM: SHARED */
export function codegen_pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
  }
}


/** Shim codegen_pipeline_expr_struct_lit_field_store_sz. PLATFORM: SHARED */
export function codegen_pipeline_expr_struct_lit_field_store_sz(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
  }
}


/** Shim backend_pipeline_expr_struct_lit_field_offset_at. PLATFORM: SHARED */
export function backend_pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
  }
}


/** Shim backend_pipeline_expr_struct_lit_field_store_sz. PLATFORM: SHARED */
export function backend_pipeline_expr_struct_lit_field_store_sz(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32 {
  unsafe {
    return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
  }
}
