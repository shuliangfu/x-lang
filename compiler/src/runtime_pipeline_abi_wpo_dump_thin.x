// Thin pure: WPO_DUMP_CALLGRAPH (XLANG_WPO_DUMP_CALLGRAPH=<path>|"-").
// G.7: body MUST match pipeline_typeck_wpo_dump_callgraph in
// runtime_pipeline_abi.x (same exported symbol). After typeck, build a
// single-module call graph (main/entry root + CALL/METHOD edges) and write
// JSON v2 consumed by compiler/scripts/wpo_dce.pl. ensure injects via
// pipeline_abi_inject_wpo_dump_thin (first-wins; avoids Darwin mega -E).
// PLATFORM: SHARED freestanding WPO dump · LINUX gold + MACOS.

export extern function link_abi_getenv(name: *u8): *u8;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_body_expr_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_name_equal_at(m: *u8, fi: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_asm_module_func_is_extern_at(m: *u8, fi: i32): i32;
export extern function pipeline_module_func_is_export_at(m: *u8, fi: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_method_call_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function xlang_driver_fopen_write_opaque(path: *u8): *u8;
export extern function xlang_driver_fwrite_opaque(data: *u8, len: i32, stream: *u8): i32;
export extern function xlang_driver_fclose_opaque(stream: *u8): i32;
export extern function xlang_driver_fwrite_stdout_n(data: *u8, len: i32): i32;

/**
 * Cap for thin dump tables (S1 smoke + small fixtures).
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_max_funcs(): i32 {
  return 256;
}

/**
 * Cap for thin dump edges.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_max_edges(): i32 {
  return 1024;
}

/**
 * EXPR_CALL ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_call(): i32 {
  return 48;
}

/**
 * EXPR_METHOD_CALL ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_method(): i32 {
  return 49;
}

/**
 * EXPR_RETURN ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_return(): i32 {
  return 41;
}

/**
 * EXPR_IF ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_if(): i32 {
  return 25;
}

/**
 * EXPR_BLOCK ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_block(): i32 {
  return 26;
}

/**
 * EXPR_VAR ordinal.
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_ek_var(): i32 {
  return 3;
}

/**
 * Whether XLANG_WPO_DUMP_CALLGRAPH is set (non-empty).
 * @param out_path *u8 - receives getenv pointer when enabled; may be null
 * @return i32 - 1 enabled
 * PLATFORM: SHARED — opt-in dump; default off.
 */
function wpo_dump_env_path(out_path: *u8): i32 {
  let e: *u8 = 0 as *u8;
  let key: u8[24] = [
    88, 76, 65, 78, 71, 95, 87, 80, 79, 95, 68, 85, 77, 80, 95,
    67, 65, 76, 76, 71, 82, 65, 80, 72
  ];
  let keyz: u8[25];
  let i: i32 = 0;
  while (i < 24) {
    unsafe {
      keyz[i] = key[i];
    }
    i = i + 1;
  }
  unsafe {
    keyz[24] = 0;
    e = link_abi_getenv(&keyz[0]);
  }
  if (e == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (e[0] == 0) {
      return 0;
    }
    if (out_path != 0 as *u8) {
      // store pointer into out_path slot (LP64)
      let slot: *u8 = out_path;
      let ep: usize = 0 as usize;
      ep = e as usize;
      slot[0] = (ep & 255) as u8;
      slot[1] = ((ep >> 8) & 255) as u8;
      slot[2] = ((ep >> 16) & 255) as u8;
      slot[3] = ((ep >> 24) & 255) as u8;
      slot[4] = ((ep >> 32) & 255) as u8;
      slot[5] = ((ep >> 40) & 255) as u8;
      slot[6] = ((ep >> 48) & 255) as u8;
      slot[7] = ((ep >> 56) & 255) as u8;
    }
  }
  return 1;
}

/**
 * Load pointer previously stored by wpo_dump_env_path.
 * @param slot *u8 - 8-byte LE pointer slot
 * @return *u8
 * PLATFORM: SHARED LP64.
 */
function wpo_dump_load_path(slot: *u8): *u8 {
  let ep: usize = 0 as usize;
  unsafe {
    ep = (slot[0] as usize)
      | ((slot[1] as usize) << 8)
      | ((slot[2] as usize) << 16)
      | ((slot[3] as usize) << 24)
      | ((slot[4] as usize) << 32)
      | ((slot[5] as usize) << 40)
      | ((slot[6] as usize) << 48)
      | ((slot[7] as usize) << 56);
  }
  return ep as *u8;
}

/**
 * Resolve CALL/METHOD callee to local func index; -1 if unknown.
 * @param a *u8
 * @param m *u8
 * @param er i32
 * @param nfuncs i32
 * @return i32
 * PLATFORM: SHARED — prefer typeck resolved_func_index, else name match.
 */
function wpo_dump_callee_fi(a: *u8, m: *u8, er: i32, nfuncs: i32): i32 {
  let ko: i32 = 0;
  let rfi: i32 = -1;
  let callee_ref: i32 = 0;
  let cko: i32 = 0;
  let clen: i32 = 0;
  let cname: u8[128];
  let fi: i32 = 0;
  let eq: i32 = 0;
  let mlen: i32 = 0;
  if (a == 0 as *u8 || m == 0 as *u8 || er <= 0 || nfuncs <= 0) {
    return -1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(a, er);
  }
  if (ko == wpo_dump_ek_call()) {
    unsafe {
      rfi = pipeline_expr_call_resolved_func_index_at(a, er);
    }
    if (rfi >= 0 && rfi < nfuncs) {
      return rfi;
    }
    unsafe {
      callee_ref = pipeline_expr_call_callee_ref_at(a, er);
    }
    if (callee_ref <= 0) {
      return -1;
    }
    unsafe {
      cko = pipeline_expr_kind_ord_at(a, callee_ref);
    }
    if (cko != wpo_dump_ek_var()) {
      return -1;
    }
    unsafe {
      clen = pipeline_expr_var_name_len(a, callee_ref);
    }
    if (clen <= 0 || clen >= 128) {
      return -1;
    }
    unsafe {
      pipeline_expr_var_name_into(a, callee_ref, &cname[0]);
    }
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        eq = pipeline_module_func_name_equal_at(m, fi, &cname[0], clen);
      }
      if (eq != 0) {
        return fi;
      }
      fi = fi + 1;
    }
    return -1;
  }
  if (ko == wpo_dump_ek_method()) {
    unsafe {
      rfi = pipeline_expr_call_resolved_func_index_at(a, er);
    }
    if (rfi >= 0 && rfi < nfuncs) {
      return rfi;
    }
    unsafe {
      mlen = pipeline_expr_method_call_name_len(a, er);
    }
    if (mlen <= 0 || mlen >= 128) {
      return -1;
    }
    unsafe {
      pipeline_expr_method_call_name_into(a, er, &cname[0]);
    }
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        eq = pipeline_module_func_name_equal_at(m, fi, &cname[0], mlen);
      }
      if (eq != 0) {
        return fi;
      }
      fi = fi + 1;
    }
  }
  return -1;
}

/**
 * Add edge from->to if capacity remains (dedupe not required for reach BFS).
 * @param edge_from *i32
 * @param edge_to *i32
 * @param nedges *i32
 * @param from i32
 * @param to i32
 * PLATFORM: SHARED.
 */
function wpo_dump_add_edge(edge_from: *i32, edge_to: *i32, nedges: *i32, from: i32, to: i32): void {
  let n: i32 = 0;
  if (edge_from == 0 as *i32 || edge_to == 0 as *i32 || nedges == 0 as *i32) {
    return;
  }
  if (from < 0 || to < 0) {
    return;
  }
  unsafe {
    n = nedges[0];
  }
  if (n >= wpo_dump_max_edges()) {
    return;
  }
  unsafe {
    edge_from[n] = from;
    edge_to[n] = to;
    nedges[0] = n + 1;
  }
}

/**
 * Recursively collect CALL/METHOD edges from an expression.
 * @param a *u8
 * @param m *u8
 * @param er i32
 * @param caller i32
 * @param nfuncs i32
 * @param edge_from *i32
 * @param edge_to *i32
 * @param nedges *i32
 * @param depth i32
 * PLATFORM: SHARED — depth-capped walk of common expr shapes.
 */
function wpo_dump_collect_expr(
  a: *u8, m: *u8, er: i32, caller: i32, nfuncs: i32,
  edge_from: *i32, edge_to: *i32, nedges: *i32, depth: i32
): void {
  let ko: i32 = 0;
  let to: i32 = -1;
  let nargs: i32 = 0;
  let ai: i32 = 0;
  let arg: i32 = 0;
  let op: i32 = 0;
  let left: i32 = 0;
  let right: i32 = 0;
  let br: i32 = 0;
  if (a == 0 as *u8 || m == 0 as *u8 || er <= 0 || depth > 64) {
    return;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(a, er);
  }
  if (ko == wpo_dump_ek_call() || ko == wpo_dump_ek_method()) {
    to = wpo_dump_callee_fi(a, m, er, nfuncs);
    if (to >= 0) {
      wpo_dump_add_edge(edge_from, edge_to, nedges, caller, to);
    }
    if (ko == wpo_dump_ek_call()) {
      unsafe {
        nargs = pipeline_expr_call_num_args_at(a, er);
      }
      ai = 0;
      while (ai < nargs) {
        unsafe {
          arg = pipeline_expr_call_arg_ref(a, er, ai);
        }
        wpo_dump_collect_expr(a, m, arg, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
        ai = ai + 1;
      }
    } else {
      unsafe {
        op = pipeline_expr_method_call_base_ref_at(a, er);
      }
      wpo_dump_collect_expr(a, m, op, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
      unsafe {
        nargs = pipeline_expr_method_call_num_args_at(a, er);
      }
      ai = 0;
      while (ai < nargs) {
        unsafe {
          arg = pipeline_expr_method_call_arg_ref(a, er, ai);
        }
        wpo_dump_collect_expr(a, m, arg, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
        ai = ai + 1;
      }
    }
    return;
  }
  if (ko == wpo_dump_ek_return()) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(a, er);
    }
    wpo_dump_collect_expr(a, m, op, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    return;
  }
  if (ko == wpo_dump_ek_if()) {
    unsafe {
      left = pipeline_expr_if_cond_ref_at(a, er);
      right = pipeline_expr_if_then_ref_at(a, er);
      op = pipeline_expr_if_else_ref_at(a, er);
    }
    wpo_dump_collect_expr(a, m, left, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    wpo_dump_collect_expr(a, m, right, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    wpo_dump_collect_expr(a, m, op, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    return;
  }
  if (ko == wpo_dump_ek_block()) {
    unsafe {
      br = pipeline_expr_block_ref_at(a, er);
    }
    wpo_dump_collect_block(a, m, br, caller, nfuncs, edge_from, edge_to, nedges);
    return;
  }
  // Binops / assigns share left/right accessors for a useful subset.
  if (ko >= 4 && ko <= 21) {
    unsafe {
      left = pipeline_expr_binop_left_ref_at(a, er);
      right = pipeline_expr_binop_right_ref_at(a, er);
    }
    wpo_dump_collect_expr(a, m, left, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    wpo_dump_collect_expr(a, m, right, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 51 || ko == 52 || ko == 42) {
    unsafe {
      op = pipeline_expr_unary_operand_ref_at(a, er);
    }
    wpo_dump_collect_expr(a, m, op, caller, nfuncs, edge_from, edge_to, nedges, depth + 1);
  }
}

/**
 * Collect CALL/METHOD edges from a block body.
 * @param a *u8
 * @param m *u8
 * @param br i32
 * @param caller i32
 * @param nfuncs i32
 * @param edge_from *i32
 * @param edge_to *i32
 * @param nedges *i32
 * PLATFORM: SHARED.
 */
function wpo_dump_collect_block(
  a: *u8, m: *u8, br: i32, caller: i32, nfuncs: i32,
  edge_from: *i32, edge_to: *i32, nedges: *i32
): void {
  let nes: i32 = 0;
  let i: i32 = 0;
  let er: i32 = 0;
  let fin: i32 = 0;
  if (a == 0 as *u8 || br <= 0) {
    return;
  }
  unsafe {
    nes = ast_ast_block_num_expr_stmts(a, br);
  }
  i = 0;
  while (i < nes) {
    unsafe {
      er = ast_pipeline_block_expr_stmt_ref(a, br, i);
    }
    wpo_dump_collect_expr(a, m, er, caller, nfuncs, edge_from, edge_to, nedges, 0);
    i = i + 1;
  }
  unsafe {
    fin = ast_ast_block_final_expr_ref(a, br);
  }
  wpo_dump_collect_expr(a, m, fin, caller, nfuncs, edge_from, edge_to, nedges, 0);
}

/**
 * Write raw bytes to dump stream (file or stdout).
 * @param fp *u8 - FILE* or null for stdout mode
 * @param use_stdout i32
 * @param data *u8
 * @param len i32
 * PLATFORM: SHARED.
 */
function wpo_dump_write(fp: *u8, use_stdout: i32, data: *u8, len: i32): void {
  if (data == 0 as *u8 || len <= 0) {
    return;
  }
  if (use_stdout != 0) {
    unsafe {
      xlang_driver_fwrite_stdout_n(data, len);
    }
    return;
  }
  if (fp == 0 as *u8) {
    return;
  }
  unsafe {
    xlang_driver_fwrite_opaque(data, len, fp);
  }
}

/**
 * Append decimal i32 into buf; return new length.
 * @param buf *u8
 * @param cap i32
 * @param len i32
 * @param v i32
 * @return i32 - updated length
 * PLATFORM: SHARED.
 */
function wpo_dump_append_i32(buf: *u8, cap: i32, len: i32, v: i32): i32 {
  let tmp: u8[16];
  let n: i32 = 0;
  let x: i32 = v;
  let neg: i32 = 0;
  let i: i32 = 0;
  if (buf == 0 as *u8 || cap <= 0 || len < 0 || len >= cap) {
    return len;
  }
  if (x == 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = 48;
    }
    return len + 1;
  }
  if (x < 0) {
    neg = 1;
    x = 0 - x;
  }
  while (x > 0 && n < 16) {
    unsafe {
      tmp[n] = ((x % 10) + 48) as u8;
    }
    n = n + 1;
    x = x / 10;
  }
  if (neg != 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = 45;
    }
    len = len + 1;
  }
  i = n - 1;
  while (i >= 0) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = tmp[i];
    }
    len = len + 1;
    i = i - 1;
  }
  return len;
}

/**
 * Append ASCII literal into buf; return new length.
 * @param buf *u8
 * @param cap i32
 * @param len i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 * PLATFORM: SHARED.
 */
function wpo_dump_append_lit(buf: *u8, cap: i32, len: i32, lit: *u8, lit_len: i32): i32 {
  let i: i32 = 0;
  if (buf == 0 as *u8 || lit == 0 as *u8 || lit_len <= 0) {
    return len;
  }
  while (i < lit_len) {
    if (len + 1 >= cap) {
      return len;
    }
    unsafe {
      buf[len] = lit[i];
    }
    len = len + 1;
    i = i + 1;
  }
  return len;
}

/**
 * Flush buf[0..len) to stream and reset length to 0.
 * @param fp *u8
 * @param use_stdout i32
 * @param buf *u8
 * @param len *i32
 * PLATFORM: SHARED.
 */
function wpo_dump_flush(fp: *u8, use_stdout: i32, buf: *u8, len: *i32): void {
  let n: i32 = 0;
  if (len == 0 as *i32) {
    return;
  }
  unsafe {
    n = len[0];
  }
  if (n > 0) {
    wpo_dump_write(fp, use_stdout, buf, n);
    unsafe {
      len[0] = 0;
    }
  }
}

/**
 * WPO-S1 callgraph dump after successful typeck.
 * Gated by XLANG_WPO_DUMP_CALLGRAPH=<path> or "-" (stdout).
 * Writes JSON version 2 (modules/functions/edges/call_sites/root) for wpo_dce.pl.
 * @param m *u8 - Module*
 * @param a *u8 - ASTArena*
 * @param ctx *u8 - PipelineDepCtx* (unused in v1 single-module dump; reserved)
 * @return i32 - 1 if dumped, 0 if skipped/failed open
 * G.7 sole product authority; thin twin runtime_pipeline_abi_wpo_dump_thin.x.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_typeck_wpo_dump_callgraph(m: *u8, a: *u8, ctx: *u8): i32 {
  let path_slot: u8[8];
  let path: *u8 = 0 as *u8;
  let use_stdout: i32 = 0;
  let fp: *u8 = 0 as *u8;
  let nfuncs: i32 = 0;
  let fi: i32 = 0;
  let root: i32 = -1;
  let edge_from: i32[1024];
  let edge_to: i32[1024];
  let nedges: i32 = 0;
  let reach: u8[256];
  let queue: i32[256];
  let qh: i32 = 0;
  let qt: i32 = 0;
  let br: i32 = 0;
  let ber: i32 = 0;
  let ei: i32 = 0;
  let to: i32 = 0;
  let name: u8[128];
  let nlen: i32 = 0;
  let is_ext: i32 = 0;
  let buf: u8[512];
  let blen: i32 = 0;
  let first: i32 = 0;
  let _ctx_unused: *u8 = ctx;
  // Named ASCII fragments (no array reassignment → no host memcpy).
  let s_ver: u8[18] = [123, 10, 32, 32, 34, 118, 101, 114, 115, 105, 111, 110, 34, 58, 32, 50, 44, 10];
  let s_entry: u8[15] = [32, 32, 34, 101, 110, 116, 114, 121, 34, 58, 32, 34, 34, 44, 10];
  let s_mods: u8[46] = [
    32, 32, 34, 109, 111, 100, 117, 108, 101, 115, 34, 58, 32, 91, 10,
    32, 32, 32, 32, 123, 34, 105, 100, 34, 58, 32, 48, 44, 32, 34, 112, 97, 116, 104, 34, 58, 32, 34, 34, 125, 10,
    32, 32, 93, 44, 10
  ];
  let s_funcs_open: u8[17] = [32, 32, 34, 102, 117, 110, 99, 116, 105, 111, 110, 115, 34, 58, 32, 91, 10];
  let s_comma_nl: u8[2] = [44, 10];
  let s_fn_head: u8[11] = [32, 32, 32, 32, 123, 34, 105, 100, 34, 58, 32];
  let s_fn_mid: u8[24] = [44, 32, 34, 109, 111, 100, 117, 108, 101, 34, 58, 32, 48, 44, 32, 34, 110, 97, 109, 101, 34, 58, 32, 34];
  let s_ext_key: u8[13] = [34, 44, 32, 34, 101, 120, 116, 101, 114, 110, 34, 58, 32];
  let s_true: u8[4] = [116, 114, 117, 101];
  let s_false: u8[5] = [102, 97, 108, 115, 101];
  let s_reach_key: u8[15] = [44, 32, 34, 114, 101, 97, 99, 104, 97, 98, 108, 101, 34, 58, 32];
  let s_close_obj: u8[1] = [125];
  let s_arr_close: u8[6] = [10, 32, 32, 93, 44, 10];
  let s_edges_open: u8[13] = [32, 32, 34, 101, 100, 103, 101, 115, 34, 58, 32, 91, 10];
  let s_edge_from: u8[13] = [32, 32, 32, 32, 123, 34, 102, 114, 111, 109, 34, 58, 32];
  let s_edge_to: u8[8] = [44, 32, 34, 116, 111, 34, 58, 32];
  let s_tail: u8[30] = [
    32, 32, 34, 99, 97, 108, 108, 95, 115, 105, 116, 101, 115, 34, 58, 32, 91, 93, 44, 10,
    32, 32, 34, 114, 111, 111, 116, 34, 58, 32
  ];
  let s_end: u8[3] = [10, 125, 10];
  if (m == 0 as *u8 || a == 0 as *u8) {
    return 0;
  }
  if (wpo_dump_env_path(&path_slot[0]) == 0) {
    return 0;
  }
  path = wpo_dump_load_path(&path_slot[0]);
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (path[0] == 45 && path[1] == 0) {
      use_stdout = 1;
    } else {
      fp = xlang_driver_fopen_write_opaque(path);
    }
  }
  if (use_stdout == 0 && fp == 0 as *u8) {
    return 0;
  }
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0) {
    if (use_stdout == 0) {
      unsafe {
        xlang_driver_fclose_opaque(fp);
      }
    }
    return 0;
  }
  if (nfuncs > wpo_dump_max_funcs()) {
    nfuncs = wpo_dump_max_funcs();
  }
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      reach[fi] = 0;
    }
    fi = fi + 1;
  }
  // Prefer main, then entry, then first export as root.
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      if (pipeline_module_func_name_equal_at(m, fi, "main", 4) != 0) {
        root = fi;
        break;
      }
    }
    fi = fi + 1;
  }
  if (root < 0) {
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        if (pipeline_module_func_name_equal_at(m, fi, "entry", 5) != 0) {
          root = fi;
          break;
        }
      }
      fi = fi + 1;
    }
  }
  if (root < 0) {
    fi = 0;
    while (fi < nfuncs) {
      unsafe {
        if (pipeline_module_func_is_export_at(m, fi) != 0) {
          root = fi;
          break;
        }
      }
      fi = fi + 1;
    }
  }
  if (root < 0) {
    root = 0;
  }
  // Collect edges from every function body (reach BFS filters later).
  nedges = 0;
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      br = pipeline_module_func_body_ref_at(m, fi);
    }
    if (br > 0) {
      wpo_dump_collect_block(a, m, br, fi, nfuncs, &edge_from[0], &edge_to[0], &nedges);
    } else {
      unsafe {
        ber = pipeline_module_func_body_expr_ref_at(m, fi);
      }
      wpo_dump_collect_expr(a, m, ber, fi, nfuncs, &edge_from[0], &edge_to[0], &nedges, 0);
    }
    fi = fi + 1;
  }
  // BFS reach from root.
  unsafe {
    reach[root] = 1;
    queue[0] = root;
  }
  qh = 0;
  qt = 1;
  while (qh < qt) {
    let cur: i32 = 0;
    unsafe {
      cur = queue[qh];
    }
    qh = qh + 1;
    ei = 0;
    while (ei < nedges) {
      unsafe {
        if (edge_from[ei] == cur) {
          to = edge_to[ei];
          if (to >= 0 && to < nfuncs && reach[to] == 0) {
            reach[to] = 1;
            if (qt < wpo_dump_max_funcs()) {
              queue[qt] = to;
              qt = qt + 1;
            }
          }
        }
      }
      ei = ei + 1;
    }
  }
  // Emit JSON v2 (call_sites empty — S1 wpo_dce only needs functions/reachable).
  blen = 0;
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_ver[0], 18);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_entry[0], 15);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_mods[0], 46);
  wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_funcs_open[0], 17);
  wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
  first = 1;
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      nlen = pipeline_module_func_name_len_at(m, fi);
      is_ext = pipeline_asm_module_func_is_extern_at(m, fi);
    }
    if (nlen < 0) {
      nlen = 0;
    }
    if (nlen >= 128) {
      nlen = 127;
    }
    if (nlen > 0) {
      unsafe {
        pipeline_module_func_name_copy64(m, fi, &name[0]);
      }
    }
    blen = 0;
    if (first == 0) {
      blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_comma_nl[0], 2);
    }
    first = 0;
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_fn_head[0], 11);
    blen = wpo_dump_append_i32(&buf[0], 512, blen, fi);
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_fn_mid[0], 24);
    if (nlen > 0) {
      blen = wpo_dump_append_lit(&buf[0], 512, blen, &name[0], nlen);
    }
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_ext_key[0], 13);
    if (is_ext != 0) {
      blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_true[0], 4);
    } else {
      blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_false[0], 5);
    }
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_reach_key[0], 15);
    unsafe {
      if (reach[fi] != 0) {
        blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_true[0], 4);
      } else {
        blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_false[0], 5);
      }
    }
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_close_obj[0], 1);
    wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
    fi = fi + 1;
  }
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_arr_close[0], 6);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_edges_open[0], 13);
  wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
  first = 1;
  ei = 0;
  while (ei < nedges) {
    blen = 0;
    if (first == 0) {
      blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_comma_nl[0], 2);
    }
    first = 0;
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_edge_from[0], 13);
    unsafe {
      blen = wpo_dump_append_i32(&buf[0], 512, blen, edge_from[ei]);
    }
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_edge_to[0], 8);
    unsafe {
      blen = wpo_dump_append_i32(&buf[0], 512, blen, edge_to[ei]);
    }
    blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_close_obj[0], 1);
    wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
    ei = ei + 1;
  }
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_arr_close[0], 6);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_tail[0], 30);
  blen = wpo_dump_append_i32(&buf[0], 512, blen, root);
  blen = wpo_dump_append_lit(&buf[0], 512, blen, &s_end[0], 3);
  wpo_dump_flush(fp, use_stdout, &buf[0], &blen);
  if (use_stdout == 0) {
    unsafe {
      xlang_driver_fclose_opaque(fp);
    }
  }
  return 1;
}
