// Thin pure: mega emit_one tip tail-jmp peer (w1048).
// G.7: part of w393_mega_emit_one (peer-flat; before frame/prologue).
// Detects pure `return callee(params…)` forwarders and emits a 5-byte
// x86 `jmp` stub (host-cc sibling-call shape) so tip thin matches host.
// tipU: keep leaf small — callee VAR name as link sym; walk labeled
// returns on body + unsafe region bodies (thin `unsafe { return _impl }`
// then dead `return -1` would otherwise make get_return pick -1).
// PRODUCT: LINUX+MACOS+WINDOWS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern function pipeline_asm_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_module_func_param_name_len_at(m: *u8, fi: i32, pi: i32): i32;
export extern function pipeline_asm_module_func_param_name_copy32(m: *u8, fi: i32, pi: i32, dst: *u8): void;
export extern function backend_enc_jmp_sym_arch(
    elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — w1048 tipU helper.
 */
function w499t_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Compare two name buffers for equality over n bytes.
 * @param a *u8 — left name
 * @param b *u8 — right name
 * @param n i32 — byte count
 * @return i32 — 1 equal, 0 mismatch
 * PLATFORM: SHARED — tipU-safe byte walk (no libc).
 */
function w499t_name_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) { return 1; }
  while (i < n) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/**
 * True when expr is CALL (or RETURN of CALL) whose args are formals in order.
 * @return i32 — 1 match, 0 no
 * PLATFORM: SHARED — w1048 detect helper.
 */
function w499t_is_fwd_call(a: *u8, m: *u8, fi: i32, er: i32): i32 {
  unsafe {
    let cell: u8[8];
    let ko: i32 = 0;
    let callee_ref: i32 = 0;
    let nparams: i32 = 0;
    let nargs: i32 = 0;
    let ai: i32 = 0;
    let arg_ref: i32 = 0;
    let vlen: i32 = 0;
    let plen: i32 = 0;
    let op: i32 = 0;
    let vname: u8[32] = [];
    let pname: u8[32] = [];
    if (er <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, er));
    ko = w499t_c32(&cell[0]);
    /* EXPR_RETURN = 41 — peel to operand (labeled/expr_stmt may wrap). */
    if (ko == 41) {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(a, er));
      op = w499t_c32(&cell[0]);
      if (op <= 0) { return 0; }
      er = op;
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, er));
      ko = w499t_c32(&cell[0]);
    }
    /* EXPR_CALL = 48 */
    if (ko != 48) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_callee_ref_at(a, er));
    callee_ref = w499t_c32(&cell[0]);
    if (callee_ref <= 0) { return 0; }
    /* Callee must be EXPR_VAR (3). */
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, callee_ref));
    if (w499t_c32(&cell[0]) != 3) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_num_params_at(m, fi));
    nparams = w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_num_args_at(a, er));
    nargs = w499t_c32(&cell[0]);
    if (nargs != nparams) { return 0; }
    if (nparams < 0) { return 0; }
    if (nparams > 64) { return 0; }
    ai = 0;
    while (ai < nparams) {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_arg_ref(a, er, ai));
      arg_ref = w499t_c32(&cell[0]);
      if (arg_ref <= 0) { return 0; }
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, arg_ref));
      if (w499t_c32(&cell[0]) != 3) { return 0; }
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_var_name_len(a, arg_ref));
      vlen = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_param_name_len_at(m, fi, ai));
      plen = w499t_c32(&cell[0]);
      if (vlen <= 0) { return 0; }
      if (vlen != plen) { return 0; }
      if (vlen > 31) { return 0; }
      pipeline_expr_var_name_into(a, arg_ref, &vname[0]);
      pipeline_asm_module_func_param_name_copy32(m, fi, ai, &pname[0]);
      if (w499t_name_eq(&vname[0], &pname[0], vlen) == 0) { return 0; }
      ai = ai + 1;
    }
    return 1;
  }
}

/**
 * First forwarder CALL among labeled returns and expr_stmt RETURNs in block br.
 * @return i32 — CALL expr ref (not RETURN wrapper) or 0
 * PLATFORM: SHARED — w1048 detect helper.
 */
function w499t_find_fwd_in_block(a: *u8, m: *u8, fi: i32, br: i32): i32 {
  unsafe {
    let cell: u8[8];
    let nlab: i32 = 0;
    let j: i32 = 0;
    let er: i32 = 0;
    let nstmt: i32 = 0;
    let ei: i32 = 0;
    let ko: i32 = 0;
    let op: i32 = 0;
    if (br <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_block_num_labeled_stmts(a, br));
    nlab = w499t_c32(&cell[0]);
    j = 0;
    while (j < nlab) {
      pipe_store_i32_le(&cell[0], 0, pipeline_block_labeled_return_expr_ref(a, br, j));
      er = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, w499t_is_fwd_call(a, m, fi, er));
      if (w499t_c32(&cell[0]) != 0) {
        /* Normalize to CALL node if RETURN-wrapped. */
        pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, er));
        if (w499t_c32(&cell[0]) == 41) {
          pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(a, er));
          return w499t_c32(&cell[0]);
        }
        return er;
      }
      j = j + 1;
    }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_expr_stmts(a, br));
    nstmt = w499t_c32(&cell[0]);
    ei = 0;
    while (ei < nstmt) {
      pipe_store_i32_le(&cell[0], 0, ast_pipeline_block_expr_stmt_ref(a, br, ei));
      er = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, w499t_is_fwd_call(a, m, fi, er));
      if (w499t_c32(&cell[0]) != 0) {
        pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, er));
        ko = w499t_c32(&cell[0]);
        if (ko == 41) {
          pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(a, er));
          return w499t_c32(&cell[0]);
        }
        return er;
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * Try to emit a pure param-forwarder as a host-like jmp stub.
 * @return i32 — 1 emitted (caller done), 0 not applicable, -1 emit failure
 * PLATFORM: SHARED — x86_64 product; ARM64 keeps fat forwarder path.
 */
#[no_mangle]
export function w499_mega_try_tail_jmp(
    m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let ret_ref: i32 = 0;
    let callee_ref: i32 = 0;
    let clen: i32 = 0;
    let nreg: i32 = 0;
    let ri: i32 = 0;
    let ch: i32 = 0;
    let cname: u8[64] = [];
    if (bctx == (0 as *u8)) { return 0; }
    if (ta != 0) { return 0; }
    if (body_ref <= 0) { return 0; }
    /* Prefer first forwarder CALL among labeled returns (body + unsafe regions). */
    pipe_store_i32_le(&cell[0], 0, w499t_find_fwd_in_block(a, m, i, body_ref));
    ret_ref = w499t_c32(&cell[0]);
    if (ret_ref <= 0) {
      pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_regions(a, body_ref));
      nreg = w499t_c32(&cell[0]);
      ri = 0;
      while (ri < nreg) {
        pipe_store_i32_le(&cell[0], 0, pipeline_block_region_body_ref(a, body_ref, ri));
        ch = w499t_c32(&cell[0]);
        pipe_store_i32_le(&cell[0], 0, w499t_find_fwd_in_block(a, m, i, ch));
        ret_ref = w499t_c32(&cell[0]);
        if (ret_ref > 0) { break; }
        ri = ri + 1;
      }
    }
    if (ret_ref <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_callee_ref_at(a, ret_ref));
    callee_ref = w499t_c32(&cell[0]);
    if (callee_ref <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_var_name_len(a, callee_ref));
    clen = w499t_c32(&cell[0]);
    if (clen <= 0) { return 0; }
    if (clen > 63) { return 0; }
    pipeline_expr_var_name_into(a, callee_ref, &cname[0]);
    pipe_store_i32_le(&cell[0], 0, backend_enc_jmp_sym_arch(elf_ctx, &cname[0], clen, ta));
    if (w499t_c32(&cell[0]) != 0) { return neg1; }
    return 1;
  }
}
