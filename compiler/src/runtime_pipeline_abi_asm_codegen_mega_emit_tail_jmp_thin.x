// Thin pure: mega emit_one tip tail-jmp peer (w1048).
// G.7: part of w393_mega_emit_one (peer-flat; before frame/prologue).
// Detects pure `return callee(params…)` forwarders and emits a 5-byte
// x86 `jmp` stub (host-cc sibling-call shape) so tip thin matches host.
// tipU: keep leaf small. The jmp target is glue_asm_build_call_export_sym_c
// (the normal CALL link symbol), not the callee VAR spelling. A return that
// closes a block is Block.final_expr_ref (parser does not append
// stmt_order). unsafe { return _impl } is a region; the CALL sits in
// that inner block's final_expr. Do not call get_return: the later
// dead `return -1` wins. final_expr load stays in its own leaf.
// PRODUCT: LINUX+MACOS+WINDOWS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function ast_ast_block_num_regions(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_asm_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern function glue_expr_is_func_param_at_c(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32;
export extern function backend_enc_jmp_sym_arch(
    elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
/**
 * Same-module and import CALL link symbol. Tail-jmp stubs must use this
 * rather than the callee VAR bytes. Defined in backend_call_dispatch.x.
 * @param arena *u8 — call-site AST arena
 * @param call_expr_ref i32 — EXPR_CALL
 * @param callee_ref i32 — EXPR_VAR callee
 * @param mod *u8 — emitting module
 * @param dep_pipe *u8 — dep ctx; null skips the dep search
 * @param out *u8 — destination symbol buffer
 * @param out_cap i32 — capacity; must be > 0
 * @return i32 — symbol length, or -1
 * PLATFORM: SHARED.
 */
export extern function glue_asm_build_call_export_sym_c(
    arena: *u8, call_expr_ref: i32, callee_ref: i32, mod: *u8, dep_pipe: *u8,
    out: *u8, out_cap: i32): i32;

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
    let op: i32 = 0;
    let same: i32 = 0;
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
      /* var_name_into / copy32 memset 256 bytes. A 32-byte slot
       * smashes the frame (same class as the 2026-09-13 watchpoint).
       * glue_expr_is_func_param_at_c compares through its own globals. */
      pipe_store_i32_le(&cell[0], 0, glue_expr_is_func_param_at_c(a, m, fi, arg_ref, ai));
      same = w499t_c32(&cell[0]);
      if (same == 0) { return 0; }
      ai = ai + 1;
    }
    return 1;
  }
}

/**
 * Normalize expr to CALL ref when it is a forwarder (peel RETURN).
 * @return i32 — CALL expr ref or 0
 * PLATFORM: SHARED — w1048 detect helper.
 */
function w499t_fwd_call_ref(a: *u8, m: *u8, fi: i32, er: i32): i32 {
  unsafe {
    let cell: u8[8];
    if (er <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, w499t_is_fwd_call(a, m, fi, er));
    if (w499t_c32(&cell[0]) == 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, er));
    if (w499t_c32(&cell[0]) == 41) {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_unary_operand_ref_at(a, er));
      return w499t_c32(&cell[0]);
    }
    return er;
  }
}

/**
 * Forwarder CALL in the block's trailing return (final_expr_ref).
 * Parser stores a return that is followed by `}` only in that slot and
 * does not append stmt_order. stmt_order kind 6 is the unsafe region;
 * the CALL is this slot on the region body, which the caller visits
 * after the outer block. A dead outer `return -1` is not a forwarder.
 * @param a *u8 — arena
 * @param m *u8 — module
 * @param fi i32 — function index
 * @param br i32 — block ref; <=0 returns 0
 * @return i32 — CALL expr ref, or 0 when the trailing expr is absent or not a pure forwarder
 * PLATFORM: SHARED — own leaf so tipU does not compile this call inside the larger walker. Do not call pipeline_asm_get_return_expr_ref_at.
 */
function w499t_final_fwd(a: *u8, m: *u8, fi: i32, br: i32): i32 {
  unsafe {
    let cell: u8[8];
    let er: i32 = 0;
    if (br <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_final_expr_ref(a, br));
    er = w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, w499t_fwd_call_ref(a, m, fi, er));
    return w499t_c32(&cell[0]);
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
    let hit: i32 = 0;
    if (br <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_block_num_labeled_stmts(a, br));
    nlab = w499t_c32(&cell[0]);
    j = 0;
    while (j < nlab) {
      pipe_store_i32_le(&cell[0], 0, pipeline_block_labeled_return_expr_ref(a, br, j));
      er = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, w499t_fwd_call_ref(a, m, fi, er));
      hit = w499t_c32(&cell[0]);
      if (hit > 0) { return hit; }
      j = j + 1;
    }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_expr_stmts(a, br));
    nstmt = w499t_c32(&cell[0]);
    ei = 0;
    while (ei < nstmt) {
      pipe_store_i32_le(&cell[0], 0, ast_pipeline_block_expr_stmt_ref(a, br, ei));
      er = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, w499t_fwd_call_ref(a, m, fi, er));
      hit = w499t_c32(&cell[0]);
      if (hit > 0) { return hit; }
      ei = ei + 1;
    }
    /* Closing `return` is final_expr, not stmt_order kind 2 or 7.
     * Isolated leaf: inlining ast_ast_block_final_expr_ref here tipU-SEGV'd. */
    pipe_store_i32_le(&cell[0], 0, w499t_final_fwd(a, m, fi, br));
    return w499t_c32(&cell[0]);
  }
}

/**
 * True when block br holds exactly one statement (w1483 gate).
 * A forwarder body is one `return callee(formals…)` (or one unsafe
 * region wrapping it). Any let / const / if / loop / extra expr_stmt
 * means the call is not the whole body: w1048 used to pick the first
 * matching CALL anywhere (e.g. a 0-arg `reset();` in a 0-param fn)
 * and replaced the whole function with `jmp reset` (Ubuntu tip
 * rt_ab_step_read_pp 8-byte body).
 * @param a *u8 — arena
 * @param br i32 — block ref; <=0 returns 0
 * @return i32 — 1 single statement, 0 otherwise
 * PLATFORM: SHARED — w1483 forwarder gate.
 */
function w499t_single_stmt(a: *u8, br: i32): i32 {
  unsafe {
    let cell: u8[8];
    let n: i32 = 0;
    let fe: i32 = 0;
    if (br <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_lets(a, br));
    if (w499t_c32(&cell[0]) != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_consts(a, br));
    if (w499t_c32(&cell[0]) != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_if_stmts(a, br));
    if (w499t_c32(&cell[0]) != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_loops(a, br));
    if (w499t_c32(&cell[0]) != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_for_loops(a, br));
    if (w499t_c32(&cell[0]) != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_stmt_order(a, br));
    if (w499t_c32(&cell[0]) > 1) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_expr_stmts(a, br));
    n = w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, pipeline_block_num_labeled_stmts(a, br));
    n = n + w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_regions(a, br));
    n = n + w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_final_expr_ref(a, br));
    fe = w499t_c32(&cell[0]);
    if (fe > 0) { n = n + 1; }
    if (n != 1) { return 0; }
    return 1;
  }
}

/**
 * Try to emit a pure param-forwarder as a host-like jmp stub.
 * The jmp reloc is glue_asm_build_call_export_sym_c of that CALL, so a
 * same-module body uses the definition link symbol (parse_assign_into
 * becomes parser_parse_assign_into). A bare extern with no local body
 * stays the source name. Length <= 0 skips the stub; the caller emits
 * the full body instead of a jmp to the VAR spelling.
 * @param m *u8 — emitting module
 * @param a *u8 — AST arena
 * @param elf_ctx *u8 — code buffer
 * @param bctx *u8 — backend ctx; null returns 0
 * @param ta i32 — 0 is x86_64; any other arch returns 0
 * @param i i32 — function index of the forwarder
 * @param body_ref i32 — body block ref; <=0 returns 0
 * @return i32 — 1 emitted, 0 not applicable, -1 emit failure
 * PLATFORM: SHARED — x86_64 product, including Windows. g05 links this
 * body; the old Windows host-cc overlay that always returned 0 is not a
 * build input. ARM64 keeps the fat forwarder (ta != 0).
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
    /* Symbol buffer. glue_asm_build_call_export_sym_c writes the link
     * name here; backend_enc_jmp_sym_arch consumes the returned length. */
    let cname: u8[256] = [];
    let dep: *u8 = 0 as *u8;
    if (bctx == (0 as *u8)) { return 0; }
    if (ta != 0) { return 0; }
    if (body_ref <= 0) { return 0; }
    /* w1483: body must be exactly one statement (the forwarder, or one
     * unsafe region whose body is exactly the forwarder). */
    pipe_store_i32_le(&cell[0], 0, w499t_single_stmt(a, body_ref));
    if (w499t_c32(&cell[0]) == 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, w499t_find_fwd_in_block(a, m, i, body_ref));
    ret_ref = w499t_c32(&cell[0]);
    if (ret_ref <= 0) {
      pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_regions(a, body_ref));
      nreg = w499t_c32(&cell[0]);
      if (nreg != 1) { return 0; }
      ri = 0;
      pipe_store_i32_le(&cell[0], 0, pipeline_block_region_body_ref(a, body_ref, ri));
      ch = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, w499t_single_stmt(a, ch));
      if (w499t_c32(&cell[0]) == 0) { return 0; }
      pipe_store_i32_le(&cell[0], 0, w499t_find_fwd_in_block(a, m, i, ch));
      ret_ref = w499t_c32(&cell[0]);
    }
    if (ret_ref <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_callee_ref_at(a, ret_ref));
    callee_ref = w499t_c32(&cell[0]);
    if (callee_ref <= 0) { return 0; }
    // PLATFORM: SHARED — one link-name authority with normal CALL emit.
    // Do not fall back to the VAR spelling: that left parse_assign_into,
    // parse_cond_expr_into, and skip_one_enum_register_into_buf raw.
    dep = pipeline_asm_emit_dep_pipe_c();
    pipe_store_i32_le(&cell[0], 0, glue_asm_build_call_export_sym_c(
        a, ret_ref, callee_ref, m, dep, &cname[0], 256));
    clen = w499t_c32(&cell[0]);
    if (clen <= 0) { return 0; }
    if (clen > 255) { return 0; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_jmp_sym_arch(elf_ctx, &cname[0], clen, ta));
    if (w499t_c32(&cell[0]) != 0) { return neg1; }
    return 1;
  }
}
