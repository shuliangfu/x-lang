// Thin pure: mega emit_one tip tail-jmp peer (w1048).
// G.7: part of w393_mega_emit_one (peer-flat; before frame/prologue).
// Detects pure `return callee(params…)` forwarders and emits a 5-byte
// x86 `jmp` stub (host-cc sibling-call shape) so tip thin matches host.
// tipU: keep leaf small — use callee VAR name as link sym (no build_call
// / dep_pipe; covers `return *_impl(params)` host trampoline shape).
// PRODUCT: LINUX+MACOS+WINDOWS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_asm_get_return_expr_ref_at(a: *u8, m: *u8, func_index: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
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
 * Try to emit a pure param-forwarder as a host-like jmp stub.
 * Pattern: body has no lets/consts; return expr is CALL whose args are
 * exactly the formals in order (EXPR_VAR name == param i). On match,
 * emit E9+reloc to the callee VAR name and skip prologue/body/epilogue.
 * @param m *u8 — module
 * @param a *u8 — arena
 * @param elf_ctx *u8 — emit context (label already placed by emit_one)
 * @param bctx *u8 — asm emit ctx (unused; kept for peer signature parity)
 * @param ta i32 — target arch (only 0 / x86_64 emits; else return 0)
 * @param i i32 — function index
 * @param body_ref i32 — function body block (0 → not applicable)
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
    let ko: i32 = 0;
    let callee_ref: i32 = 0;
    let nparams: i32 = 0;
    let nargs: i32 = 0;
    let ai: i32 = 0;
    let arg_ref: i32 = 0;
    let ako: i32 = 0;
    let vlen: i32 = 0;
    let plen: i32 = 0;
    let clen: i32 = 0;
    let nlet: i32 = 0;
    let nconst: i32 = 0;
    let vname: u8[32] = [];
    let pname: u8[32] = [];
    let cname: u8[64] = [];
    /* Silence unused-param (peer signature matches frame). */
    if (bctx == (0 as *u8)) { return 0; }
    /* ARM64 / other: keep fat path (host jmp is an x86 sibling-call shape). */
    if (ta != 0) { return 0; }
    if (body_ref <= 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_lets(a, body_ref));
    nlet = w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_consts(a, body_ref));
    nconst = w499t_c32(&cell[0]);
    /* Side-effect lets/consts must not be skipped by a bare jmp. */
    if (nlet != 0) { return 0; }
    if (nconst != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_get_return_expr_ref_at(a, m, i));
    ret_ref = w499t_c32(&cell[0]);
    if (ret_ref <= 0) { return 0; }
    /* EXPR_CALL = 48 */
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, ret_ref));
    ko = w499t_c32(&cell[0]);
    if (ko != 48) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_callee_ref_at(a, ret_ref));
    callee_ref = w499t_c32(&cell[0]);
    if (callee_ref <= 0) { return 0; }
    /* Callee must be EXPR_VAR (3) — no field/method forwarder. */
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, callee_ref));
    if (w499t_c32(&cell[0]) != 3) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_num_params_at(m, i));
    nparams = w499t_c32(&cell[0]);
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_num_args_at(a, ret_ref));
    nargs = w499t_c32(&cell[0]);
    if (nargs != nparams) { return 0; }
    if (nparams < 0) { return 0; }
    if (nparams > 64) { return 0; }
    ai = 0;
    while (ai < nparams) {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_call_arg_ref(a, ret_ref, ai));
      arg_ref = w499t_c32(&cell[0]);
      if (arg_ref <= 0) { return 0; }
      /* EXPR_VAR = 3 — must reuse the formal (call_spill==0 shape). */
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(a, arg_ref));
      ako = w499t_c32(&cell[0]);
      if (ako != 3) { return 0; }
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_var_name_len(a, arg_ref));
      vlen = w499t_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_param_name_len_at(m, i, ai));
      plen = w499t_c32(&cell[0]);
      if (vlen <= 0) { return 0; }
      if (vlen != plen) { return 0; }
      if (vlen > 31) { return 0; }
      pipeline_expr_var_name_into(a, arg_ref, &vname[0]);
      pipeline_asm_module_func_param_name_copy32(m, i, ai, &pname[0]);
      if (w499t_name_eq(&vname[0], &pname[0], vlen) == 0) { return 0; }
      ai = ai + 1;
    }
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
