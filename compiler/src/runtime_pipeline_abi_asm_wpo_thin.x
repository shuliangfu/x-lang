// Thin pure: wave311/369b M2 — asm_wpo Cap residual C→.x (was wave274 C thin).
// WPO reach/DCE + PGO-Lite emit order; 7 exports + file-local BSS.
// G.7: bodies match runtime_pipeline_abi.x wave274 leave.
// PRODUCT inject: hard-skip BAN PREFER (wave369b); stay prior -E overlay.
// wave369: w311_* ptr helpers via unsafe (T001); PREFER g05 BRANCH26 fail.
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.
export extern "C" function pipeline_typeck_pick_overload_func_index_for_call_c(m: *u8, a: *u8, call_ref: i32): i32;

export extern function asm_module_is_backend_selfhost(m: *u8): i32;
export extern function asm_module_is_driver_compile_selfhost(m: *u8): i32;
export extern function asm_module_is_main_driver_selfhost(m: *u8): i32;
export extern function asm_module_is_parser_selfhost(m: *u8): i32;
export extern function asm_module_is_pipeline_selfhost(m: *u8): i32;
export extern function asm_module_is_typeck_selfhost(m: *u8): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_for_body_ref(arena: *u8, block_ref: i32, for_idx: i32): i32;
export extern function ast_ast_block_for_cond_ref(arena: *u8, block_ref: i32, for_idx: i32): i32;
export extern function ast_ast_block_for_init_ref(arena: *u8, block_ref: i32, for_idx: i32): i32;
export extern function ast_ast_block_for_step_ref(arena: *u8, block_ref: i32, for_idx: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_for_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_if_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_while_body_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
export extern function ast_ast_block_while_cond_ref(arena: *u8, block_ref: i32, loop_idx: i32): i32;
export extern function ast_pipeline_block_const_init_ref(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;
export extern function ast_pipeline_block_if_cond_ref(arena: *u8, block_ref: i32, if_idx: i32): i32;
export extern function ast_pipeline_block_if_else_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32;
export extern function ast_pipeline_block_if_then_body_ref(arena: *u8, block_ref: i32, if_idx: i32): i32;
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipeline_asm_module_func_is_extern_at(module: *u8, fi: i32): i32;
export extern function pipeline_block_labeled_is_goto(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_labeled_return_expr_ref(arena: *u8, block_ref: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_num_labeled_stmts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
export extern function pipeline_dep_ctx_ndep(ctx: *u8): i32;
export extern function pipeline_elf_pgo_hot_enabled(): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_callee_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_dep_index_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_method_call_base_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_method_call_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_num_args_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_body_expr_ref_at(module: *u8, fi: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *u8, fi: i32): i32;
export extern function pipeline_module_func_is_used_at(module: *u8, fi: i32): i32;
export extern function pipeline_module_func_name_equal_at(module: *u8, fi: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_module_main_func_index(module: *u8): i32;
export extern function pipeline_module_num_funcs(module: *u8): i32;


// Cap constants (private).
function asm_wpo_max_funcs(): i32 { return 2048; }
function asm_wpo_max_mods(): i32 { return 64; }
function asm_wpo_max_edges(): i32 { return 8192; }

// ExprKind ordinals used by walk (product pool).
function asm_wpo_ek_neg(): i32 { return 22; }
function asm_wpo_ek_bitnot(): i32 { return 23; }
function asm_wpo_ek_lognot(): i32 { return 24; }
function asm_wpo_ek_if(): i32 { return 25; }
function asm_wpo_ek_block(): i32 { return 26; }
function asm_wpo_ek_ternary(): i32 { return 27; }
function asm_wpo_ek_return(): i32 { return 41; }
function asm_wpo_ek_panic(): i32 { return 42; }
function asm_wpo_ek_field(): i32 { return 44; }
function asm_wpo_ek_struct_lit(): i32 { return 45; }
function asm_wpo_ek_array_lit(): i32 { return 46; }
function asm_wpo_ek_index(): i32 { return 47; }
function asm_wpo_ek_call(): i32 { return 48; }
function asm_wpo_ek_method_call(): i32 { return 49; }
function asm_wpo_ek_addr_of(): i32 { return 51; }
function asm_wpo_ek_deref(): i32 { return 52; }
function asm_wpo_ek_as(): i32 { return 54; }
function asm_wpo_ek_await(): i32 { return 55; }
function asm_wpo_ek_run(): i32 { return 56; }
function asm_wpo_ek_spawn(): i32 { return 57; }

// Cap residual callees not already declared at file top (block walk / overload).

// ---------------------------------------------------------------------------
// Flat BSS (process-local; single-threaded compile)
// ---------------------------------------------------------------------------
let g_aw_entry: u8[8] = [];
let g_aw_dep_ctx: u8[8] = [];
let g_aw_mods: u8[512] = [];
let g_aw_arenas: u8[512] = [];
let g_aw_func_mod: u8[16384] = [];
let g_aw_func_fi: i32[2048] = [];
let g_aw_reachable: u8[2048] = [];
let g_aw_edge_from: i32[8192] = [];
let g_aw_edge_to: i32[8192] = [];
let g_aw_nmods: i32 = 0;
let g_aw_nfuncs: i32 = 0;
let g_aw_nedges: i32 = 0;
let g_aw_root_id: i32 = -1;
let g_aw_valid: i32 = 0;
let g_aw_pgo_hot: u8[2048] = [];
let g_aw_pgo_depth: i32[2048] = [];
let g_aw_pgo_emit_mod: u8[8] = [];
let g_aw_pgo_emit_order: i32[2048] = [];
let g_aw_pgo_emit_n: i32 = 0;

// BFS workspace (avoid huge pure stack frames).
let g_aw_queue: i32[2048] = [];

/**
 * Clear asm WPO reach/PGO process state.
 * Called at elf emit end/fail and before each reach_compute_for_elf.
 * Matches residual memset-zero of AsmWpoReachState + hot; depth filled 0xff (-1).
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_reach_clear(): void {
  unsafe {
    memset(&g_aw_entry[0], 0, 8 as usize);
    memset(&g_aw_dep_ctx[0], 0, 8 as usize);
    memset(&g_aw_mods[0], 0, 512 as usize);
    memset(&g_aw_arenas[0], 0, 512 as usize);
    memset(&g_aw_func_mod[0], 0, 16384 as usize);
    memset(&g_aw_reachable[0], 0, 2048 as usize);
    memset(&g_aw_pgo_hot[0], 0, 2048 as usize);
    memset(&g_aw_pgo_emit_mod[0], 0, 8 as usize);
  }
  g_aw_nmods = 0;
  g_aw_nfuncs = 0;
  g_aw_nedges = 0;
  g_aw_root_id = -1;
  g_aw_valid = 0;
  g_aw_pgo_emit_n = 0;
  let i: i32 = 0;
  while (i < asm_wpo_max_funcs()) {
    g_aw_func_fi[i] = 0;
    g_aw_pgo_depth[i] = -1;
    g_aw_pgo_emit_order[i] = 0;
    i = i + 1;
  }
  i = 0;
  while (i < asm_wpo_max_edges()) {
    g_aw_edge_from[i] = 0;
    g_aw_edge_to[i] = 0;
    i = i + 1;
  }
}

// --- pointer table helpers ---
/**
 * Ptr-slot load via unsafe (T001). PLATFORM: SHARED.
 * wave369: wrap pipe_load_ptr_slot for PREFER_ASM pure-asm leave.
 */
function w311_load_ptr(base: *u8, i: i32): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, i);
  }
}

/**
 * Ptr-slot store via unsafe (T001). PLATFORM: SHARED.
 * wave369: wrap pipe_store_ptr_slot for PREFER_ASM pure-asm leave.
 */
function w311_store_ptr(base: *u8, i: i32, val: *u8): void {
  unsafe {
    pipe_store_ptr_slot(base, i, val);
  }
}

function asm_wpo_get_entry(): *u8 {
  return w311_load_ptr(&g_aw_entry[0], 0);
}
function asm_wpo_set_entry(m: *u8): void {
  w311_store_ptr(&g_aw_entry[0], 0, m);
}
function asm_wpo_get_dep_ctx(): *u8 {
  return w311_load_ptr(&g_aw_dep_ctx[0], 0);
}
function asm_wpo_set_dep_ctx(c: *u8): void {
  w311_store_ptr(&g_aw_dep_ctx[0], 0, c);
}
function asm_wpo_mod_slot(i: i32): *u8 {
  return w311_load_ptr(&g_aw_mods[0], i);
}
function asm_wpo_set_mod_slot(i: i32, m: *u8): void {
  w311_store_ptr(&g_aw_mods[0], i, m);
}
function asm_wpo_arena_slot(i: i32): *u8 {
  return w311_load_ptr(&g_aw_arenas[0], i);
}
function asm_wpo_set_arena_slot(i: i32, a: *u8): void {
  w311_store_ptr(&g_aw_arenas[0], i, a);
}
function asm_wpo_func_mod_slot(i: i32): *u8 {
  return w311_load_ptr(&g_aw_func_mod[0], i);
}
function asm_wpo_set_func_mod_slot(i: i32, m: *u8): void {
  w311_store_ptr(&g_aw_func_mod[0], i, m);
}
function asm_wpo_get_emit_mod(): *u8 {
  return w311_load_ptr(&g_aw_pgo_emit_mod[0], 0);
}
function asm_wpo_set_emit_mod(m: *u8): void {
  w311_store_ptr(&g_aw_pgo_emit_mod[0], 0, m);
}

/** Find module index in mods[]; -1 if unregistered. */
function asm_wpo_mod_index(m: *u8): i32 {
  if (m == 0 as *u8) {
    return -1;
  }
  let i: i32 = 0;
  while (i < g_aw_nmods) {
    if (asm_wpo_mod_slot(i) == m) {
      return i;
    }
    i = i + 1;
  }
  return -1;
}

/** Register module+arena; return index or -1. */
function asm_wpo_register_mod(m: *u8, a: *u8): i32 {
  if (m == 0 as *u8 || a == 0 as *u8) {
    return -1;
  }
  let ix: i32 = asm_wpo_mod_index(m);
  if (ix >= 0) {
    return ix;
  }
  if (g_aw_nmods >= asm_wpo_max_mods()) {
    return -1;
  }
  ix = g_aw_nmods;
  asm_wpo_set_mod_slot(ix, m);
  asm_wpo_set_arena_slot(ix, a);
  g_aw_nmods = g_aw_nmods + 1;
  return ix;
}

/** (module, fi) -> global func id; -1 if unregistered. */
function asm_wpo_func_id_of(m: *u8, fi: i32): i32 {
  if (m == 0 as *u8 || fi < 0) {
    return -1;
  }
  let i: i32 = 0;
  while (i < g_aw_nfuncs) {
    if (asm_wpo_func_mod_slot(i) == m && g_aw_func_fi[i] == fi) {
      return i;
    }
    i = i + 1;
  }
  return -1;
}

/** Register non-extern func node; -1 on skip/full. */
function asm_wpo_register_func(m: *u8, fi: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || fi < 0 || g_aw_nfuncs >= asm_wpo_max_funcs()) {
      return -1;
    }
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0) {
      return -1;
    }
    let id: i32 = asm_wpo_func_id_of(m, fi);
    if (id >= 0) {
      return id;
    }
    id = g_aw_nfuncs;
    asm_wpo_set_func_mod_slot(id, m);
    g_aw_func_fi[id] = fi;
    g_aw_nfuncs = g_aw_nfuncs + 1;
    return id;

  }
}

/** Func id by name inside one module among registered nodes. */
function asm_wpo_func_id_in_module(m: *u8, name: *u8, name_len: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || name == 0 as *u8 || name_len <= 0) {
      return -1;
    }
    let nf: i32 = pipeline_module_num_funcs(m);
    let fi: i32 = 0;
    while (fi < nf) {
      if (pipeline_module_func_name_equal_at(m, fi, name, name_len) != 0) {
        let id: i32 = asm_wpo_func_id_of(m, fi);
        if (id >= 0) {
          return id;
        }
      }
      fi = fi + 1;
    }
    return -1;

  }
}

/** Func id by name across registered graph (first match). */
function asm_wpo_func_id_by_name(name: *u8, name_len: i32): i32 {
  unsafe {
    if (name == 0 as *u8 || name_len <= 0) {
      return -1;
    }
    let i: i32 = 0;
    while (i < g_aw_nfuncs) {
      let fi: i32 = g_aw_func_fi[i];
      let m: *u8 = asm_wpo_func_mod_slot(i);
      if (pipeline_module_func_name_equal_at(m, fi, name, name_len) != 0) {
        return i;
      }
      i = i + 1;
    }
    return -1;

  }
}

/** Dedup edge from->to. */
function asm_wpo_add_edge(from: i32, to: i32): void {
  if (from < 0 || to < 0 || from >= g_aw_nfuncs || to >= g_aw_nfuncs) {
    return;
  }
  let i: i32 = 0;
  while (i < g_aw_nedges) {
    if (g_aw_edge_from[i] == from && g_aw_edge_to[i] == to) {
      return;
    }
    i = i + 1;
  }
  if (g_aw_nedges >= asm_wpo_max_edges()) {
    return;
  }
  g_aw_edge_from[g_aw_nedges] = from;
  g_aw_edge_to[g_aw_nedges] = to;
  g_aw_nedges = g_aw_nedges + 1;
}

/**
 * Callee name from CALL callee expr (FIELD_ACCESS field name, else VAR name).
 * @return name length; 0 if unavailable. Writes into cname[0..].
 */
function asm_wpo_call_callee_name(a: *u8, callee_ref: i32, cname: *u8): i32 {
  unsafe {
    if (a == 0 as *u8 || callee_ref <= 0 || cname == 0 as *u8) {
      return 0;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(a, callee_ref);
    if (ko == asm_wpo_ek_field()) {
      let clen: i32 = pipeline_expr_field_access_name_len(a, callee_ref);
      if (clen > 0 && clen <= 63) {
        pipeline_expr_field_access_name_into(a, callee_ref, cname);
        return clen;
      }
    }
    let clen2: i32 = pipeline_expr_var_name_len(a, callee_ref);
    if (clen2 > 0 && clen2 <= 63) {
      pipeline_expr_var_name_into(a, callee_ref, cname);
      return clen2;
    }
    return 0;

  }
}

/**
 * Resolve CALL to WPO func id (name match + overload pick + typeck resolved).
 */
function asm_wpo_call_callee_id(a: *u8, call_expr_ref: i32, caller_mod: *u8, ctx: *u8): i32 {
  unsafe {
    if (a == 0 as *u8 || call_expr_ref <= 0) {
      return -1;
    }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
    let cname: u8[256] = [];
    let clen: i32 = asm_wpo_call_callee_name(a, callee_ref, &cname[0]);
    if (clen > 0 && caller_mod != 0 as *u8) {
      let ov_n: i32 = 0;
      let fi_ov: i32 = 0;
      let nf_ov: i32 = pipeline_module_num_funcs(caller_mod);
      while (fi_ov < nf_ov) {
        if (pipeline_asm_module_func_is_extern_at(caller_mod, fi_ov) == 0) {
          if (pipeline_module_func_name_equal_at(caller_mod, fi_ov, &cname[0], clen) != 0) {
            ov_n = ov_n + 1;
          }
        }
        fi_ov = fi_ov + 1;
      }
      if (ov_n > 1) {
        let picked: i32 = pipeline_typeck_pick_overload_func_index_for_call_c(caller_mod, a, call_expr_ref);
        if (picked >= 0) {
          let cid_ov: i32 = asm_wpo_func_id_of(caller_mod, picked);
          if (cid_ov >= 0) {
            return cid_ov;
          }
        }
      }
    }
    if (clen > 0) {
      let cid: i32 = asm_wpo_func_id_in_module(caller_mod, &cname[0], clen);
      if (cid < 0) {
        cid = asm_wpo_func_id_by_name(&cname[0], clen);
      }
      if (cid >= 0) {
        return cid;
      }
    }
    let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
    if (func_ix >= 0) {
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(a, call_expr_ref);
      let callee_mod: *u8 = caller_mod;
      if (dep_ix >= 0 && ctx != 0 as *u8) {
        callee_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
      }
      if (clen > 0 && callee_mod != 0 as *u8 && dep_ix < 0) {
        if (pipeline_expr_kind_ord_at(a, callee_ref) != asm_wpo_ek_field()) {
          if (pipeline_module_func_name_equal_at(callee_mod, func_ix, &cname[0], clen) == 0) {
            return -1;
          }
        }
      }
      if (callee_mod != 0 as *u8) {
        let cid2: i32 = asm_wpo_func_id_of(callee_mod, func_ix);
        if (cid2 >= 0) {
          return cid2;
        }
      }
    }
    return -1;

  }
}



/**
 * Unified recursive walk: is_block!=0 => block_ref walk; else expr_ref walk.
 * depth caps at 64 for expr recursion (match residual).
 */
function asm_wpo_collect_walk(is_block: i32, a: *u8, ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32): void {
  unsafe {
    if (a == 0 as *u8 || ref <= 0 || caller_id < 0) {
      return;
    }
    if (is_block != 0) {
      let block_ref: i32 = ref;
      let nso: i32 = ast_ast_block_num_stmt_order(a, block_ref);
      let i: i32 = 0;
      let er: i32 = 0;
      if (nso > 0) {
        i = 0;
        while (i < nso) {

          // inlined stmt_order one (si = i) — avoid mutual forward decl
          {
            let si: i32 = i;
            let nso2: i32 = ast_ast_block_num_stmt_order(a, block_ref);
            if (si >= 0 && si < nso2) {
              let sk: i32 = ast_ast_block_stmt_order_kind(a, block_ref, si);
              let idx: i32 = ast_ast_block_stmt_order_idx(a, block_ref, si);
              let er0: i32 = 0;
              if (sk == 0 && idx >= 0 && idx < ast_ast_block_num_consts(a, block_ref)) {
                er0 = ast_pipeline_block_const_init_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 1 && idx >= 0 && idx < ast_ast_block_num_lets(a, block_ref)) {
                er0 = pipeline_block_let_init_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 2 && idx >= 0 && idx < ast_ast_block_num_expr_stmts(a, block_ref)) {
                er0 = ast_pipeline_block_expr_stmt_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 3 && idx >= 0 && idx < ast_ast_block_num_loops(a, block_ref)) {
                er0 = ast_ast_block_while_cond_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_ast_block_while_body_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(1, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 4 && idx >= 0 && idx < ast_ast_block_num_for_loops(a, block_ref)) {
                er0 = ast_ast_block_for_init_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_ast_block_for_cond_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_ast_block_for_step_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_ast_block_for_body_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(1, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 5 && idx >= 0 && idx < ast_ast_block_num_if_stmts(a, block_ref)) {
                er0 = ast_pipeline_block_if_cond_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(0, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_pipeline_block_if_then_body_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(1, a, er0, caller_id, caller_mod, ctx, 0);
                }
                er0 = ast_pipeline_block_if_else_body_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(1, a, er0, caller_id, caller_mod, ctx, 0);
                }
              } else if (sk == 6) {
                er0 = pipeline_block_region_body_ref(a, block_ref, idx);
                if (er0 > 0) {
                  asm_wpo_collect_walk(1, a, er0, caller_id, caller_mod, ctx, 0);
                }
              }
            }
          }

          i = i + 1;
        }
        // stmt_order / expr_stmt pool may desync — rescan expr_stmts.
        let nes: i32 = ast_ast_block_num_expr_stmts(a, block_ref);
        i = 0;
        while (i < nes) {
          er = ast_pipeline_block_expr_stmt_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
      } else {
        let nc: i32 = ast_ast_block_num_consts(a, block_ref);
        i = 0;
        while (i < nc) {
          er = ast_pipeline_block_const_init_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
        let nl: i32 = ast_ast_block_num_lets(a, block_ref);
        i = 0;
        while (i < nl) {
          er = pipeline_block_let_init_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
        let nlp: i32 = ast_ast_block_num_loops(a, block_ref);
        i = 0;
        while (i < nlp) {
          er = ast_ast_block_while_cond_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_ast_block_while_body_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(1, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
        let nf: i32 = ast_ast_block_num_for_loops(a, block_ref);
        i = 0;
        while (i < nf) {
          er = ast_ast_block_for_init_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_ast_block_for_cond_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_ast_block_for_step_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_ast_block_for_body_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(1, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
        let ni: i32 = ast_ast_block_num_if_stmts(a, block_ref);
        i = 0;
        while (i < ni) {
          er = ast_pipeline_block_if_cond_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_pipeline_block_if_then_body_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(1, a, er, caller_id, caller_mod, ctx, 0);
          }
          er = ast_pipeline_block_if_else_body_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(1, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
        let nes2: i32 = ast_ast_block_num_expr_stmts(a, block_ref);
        i = 0;
        while (i < nes2) {
          er = ast_pipeline_block_expr_stmt_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
          i = i + 1;
        }
      }
      // Labeled returns (C parser) not always in stmt_order.
      let nlab: i32 = pipeline_block_num_labeled_stmts(a, block_ref);
      i = 0;
      while (i < nlab) {
        if (pipeline_block_labeled_is_goto(a, block_ref, i) == 0) {
          er = pipeline_block_labeled_return_expr_ref(a, block_ref, i);
          if (er > 0) {
            asm_wpo_collect_walk(0, a, er, caller_id, caller_mod, ctx, 0);
          }
        }
        i = i + 1;
      }
      let fer: i32 = ast_ast_block_final_expr_ref(a, block_ref);
      if (fer > 0) {
        asm_wpo_collect_walk(0, a, fer, caller_id, caller_mod, ctx, 0);
      }
      return;
    }

    // ---- expr walk ----
    if (depth > 64) {
      return;
    }
    let expr_ref: i32 = ref;
    let ko: i32 = pipeline_expr_kind_ord_at(a, expr_ref);
    let i2: i32 = 0;
    if (ko == asm_wpo_ek_call()) {
      let cid: i32 = asm_wpo_call_callee_id(a, expr_ref, caller_mod, ctx);
      if (cid >= 0) {
        asm_wpo_add_edge(caller_id, cid);
      }
      let na: i32 = pipeline_expr_call_num_args_at(a, expr_ref);
      i2 = 0;
      while (i2 < na) {
        let ar: i32 = pipeline_expr_call_arg_ref(a, expr_ref, i2);
        if (ar > 0) {
          asm_wpo_collect_walk(0, a, ar, caller_id, caller_mod, ctx, depth + 1);
        }
        i2 = i2 + 1;
      }
      let cr: i32 = pipeline_expr_call_callee_ref_at(a, expr_ref);
      if (cr > 0) {
        asm_wpo_collect_walk(0, a, cr, caller_id, caller_mod, ctx, depth + 1);
      }
      return;
    }
    // METHOD_CALL exclusive path (wave358 Cap residual pure).
    if (ko == asm_wpo_ek_method_call()) {
      let r_fn: i32 = pipeline_expr_call_resolved_func_index_at(a, expr_ref);
      let r_dep: i32 = pipeline_expr_call_resolved_dep_index_at(a, expr_ref);
      let mcid: i32 = -1;
      let mlen: i32 = pipeline_expr_method_call_name_len(a, expr_ref);
      let mbase: i32 = pipeline_expr_method_call_base_ref_at(a, expr_ref);
      let mnargs: i32 = pipeline_expr_method_call_num_args_at(a, expr_ref);
      let mnm: u8[256] = [];
      if (r_fn >= 0 && r_dep < 0 && caller_mod != 0 as *u8) {
        mcid = asm_wpo_func_id_of(caller_mod, r_fn);
      }
      if (mcid < 0 && mlen > 0 && mlen <= 63) {
        pipeline_expr_method_call_name_into(a, expr_ref, &mnm[0]);
        mcid = asm_wpo_func_id_in_module(caller_mod, &mnm[0], mlen);
        if (mcid < 0) {
          mcid = asm_wpo_func_id_by_name(&mnm[0], mlen);
        }
        if (caller_mod != 0 as *u8 && mcid < 0) {
          let fi_m: i32 = 0;
          let nf_m: i32 = pipeline_module_num_funcs(caller_mod);
          while (fi_m < nf_m) {
            if (pipeline_module_func_name_equal_at(caller_mod, fi_m, &mnm[0], mlen) != 0) {
              let id_m: i32 = asm_wpo_func_id_of(caller_mod, fi_m);
              if (id_m >= 0) {
                asm_wpo_add_edge(caller_id, id_m);
              }
            }
            fi_m = fi_m + 1;
          }
        }
      }
      if (mcid >= 0) {
        asm_wpo_add_edge(caller_id, mcid);
      }
      if (mbase > 0) {
        asm_wpo_collect_walk(0, a, mbase, caller_id, caller_mod, ctx, depth + 1);
      }
      i2 = 0;
      while (i2 < mnargs) {
        let mar: i32 = pipeline_expr_method_call_arg_ref(a, expr_ref, i2);
        if (mar > 0) {
          asm_wpo_collect_walk(0, a, mar, caller_id, caller_mod, ctx, depth + 1);
        }
        i2 = i2 + 1;
      }
      return;
    }
    if (ko == asm_wpo_ek_return() || ko == asm_wpo_ek_panic() || ko == asm_wpo_ek_neg() ||
        ko == asm_wpo_ek_bitnot() || ko == asm_wpo_ek_lognot() || ko == asm_wpo_ek_addr_of() ||
        ko == asm_wpo_ek_deref() || ko == asm_wpo_ek_await() || ko == asm_wpo_ek_run() ||
        ko == asm_wpo_ek_spawn()) {
      let uop: i32 = pipeline_expr_unary_operand_ref_at(a, expr_ref);
      if (uop > 0) {
        asm_wpo_collect_walk(0, a, uop, caller_id, caller_mod, ctx, depth + 1);
      }
      return;
    }
    if (ko == asm_wpo_ek_as()) {
      let aop: i32 = pipeline_expr_as_operand_ref_at(a, expr_ref);
      if (aop > 0) {
        asm_wpo_collect_walk(0, a, aop, caller_id, caller_mod, ctx, depth + 1);
      }
      return;
    }
    if (ko == asm_wpo_ek_if() || ko == asm_wpo_ek_ternary()) {
      let ic: i32 = pipeline_expr_if_cond_ref_at(a, expr_ref);
      if (ic > 0) {
        asm_wpo_collect_walk(0, a, ic, caller_id, caller_mod, ctx, depth + 1);
      }
      let it: i32 = pipeline_expr_if_then_ref_at(a, expr_ref);
      if (it > 0) {
        asm_wpo_collect_walk(0, a, it, caller_id, caller_mod, ctx, depth + 1);
      }
      let ie: i32 = pipeline_expr_if_else_ref_at(a, expr_ref);
      if (ie > 0) {
        asm_wpo_collect_walk(0, a, ie, caller_id, caller_mod, ctx, depth + 1);
      }
      return;
    }
    if (ko == asm_wpo_ek_block()) {
      let br: i32 = pipeline_expr_block_ref_at(a, expr_ref);
      if (br > 0) {
        asm_wpo_collect_walk(1, a, br, caller_id, caller_mod, ctx, 0);
      }
      return;
    }
    let bl: i32 = pipeline_expr_binop_left_ref_at(a, expr_ref);
    let brt: i32 = pipeline_expr_binop_right_ref_at(a, expr_ref);
    if (bl > 0 || brt > 0) {
      if (bl > 0) {
        asm_wpo_collect_walk(0, a, bl, caller_id, caller_mod, ctx, depth + 1);
      }
      if (brt > 0) {
        asm_wpo_collect_walk(0, a, brt, caller_id, caller_mod, ctx, depth + 1);
      }
      return;
    }
    if (ko == asm_wpo_ek_struct_lit()) {
      let nf: i32 = pipeline_expr_struct_lit_num_fields(a, expr_ref);
      i2 = 0;
      while (i2 < nf) {
        let iref: i32 = pipeline_expr_struct_lit_init_ref(a, expr_ref, i2);
        if (iref > 0) {
          asm_wpo_collect_walk(0, a, iref, caller_id, caller_mod, ctx, depth + 1);
        }
        i2 = i2 + 1;
      }
      return;
    }
    if (ko == asm_wpo_ek_array_lit()) {
      let ne: i32 = pipeline_expr_array_lit_num_elems_at(a, expr_ref);
      i2 = 0;
      while (i2 < ne) {
        let eref: i32 = pipeline_expr_array_lit_elem_ref(a, expr_ref, i2);
        if (eref > 0) {
          asm_wpo_collect_walk(0, a, eref, caller_id, caller_mod, ctx, depth + 1);
        }
        i2 = i2 + 1;
      }
      return;
    }
    let fbase: i32 = pipeline_expr_field_access_base_ref(a, expr_ref);
    if (fbase > 0) {
      asm_wpo_collect_walk(0, a, fbase, caller_id, caller_mod, ctx, depth + 1);
    }
    let ibase: i32 = pipeline_expr_index_base_ref(a, expr_ref);
    if (ibase > 0) {
      asm_wpo_collect_walk(0, a, ibase, caller_id, caller_mod, ctx, depth + 1);
    }
    let iidx: i32 = pipeline_expr_index_index_ref(a, expr_ref);
    if (iidx > 0) {
      asm_wpo_collect_walk(0, a, iidx, caller_id, caller_mod, ctx, depth + 1);
    }

  }
}

function asm_wpo_collect_edges_from_expr(a: *u8, expr_ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8, depth: i32): void {
  asm_wpo_collect_walk(0, a, expr_ref, caller_id, caller_mod, ctx, depth);
}

function asm_wpo_collect_from_block(a: *u8, block_ref: i32, caller_id: i32, caller_mod: *u8, ctx: *u8): void {
  asm_wpo_collect_walk(1, a, block_ref, caller_id, caller_mod, ctx, 0);
}

/** User single-file + PGO_HOT and not compiler selfhost. */
function asm_wpo_is_user_single_file_pgo_entry(): i32 {
  unsafe {
    if (pipeline_elf_pgo_hot_enabled() == 0) {
      return 0;
    }
    let entry: *u8 = asm_wpo_get_entry();
    if (entry == 0 as *u8 || g_aw_nmods != 1) {
      return 0;
    }
    if (asm_module_is_main_driver_selfhost(entry) != 0) {
      return 0;
    }
    if (asm_module_is_pipeline_selfhost(entry) != 0 || asm_module_is_typeck_selfhost(entry) != 0 ||
        asm_module_is_backend_selfhost(entry) != 0 || asm_module_is_parser_selfhost(entry) != 0) {
      return 0;
    }
    return 1;

  }
}

/** User program main WPO func id; -1 if absent. */
function asm_wpo_user_main_func_id(): i32 {
  unsafe {
    let entry: *u8 = asm_wpo_get_entry();
    if (entry == 0 as *u8) {
      return -1;
    }
    let nf: i32 = pipeline_module_num_funcs(entry);
    let fi: i32 = 0;
    while (fi < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi, "main", 4) != 0) {
        let id: i32 = asm_wpo_func_id_of(entry, fi);
        if (id >= 0) {
          return id;
        }
      }
      fi = fi + 1;
    }
    return -1;

  }
}

/**
 * User executable/single-test .x (not compiler selfhost) with main.
 */
function asm_wpo_is_user_program_entry(): i32 {
  unsafe {
    let entry: *u8 = asm_wpo_get_entry();
    if (entry == 0 as *u8 || g_aw_nmods != 1) {
      return 0;
    }
    if (asm_module_is_main_driver_selfhost(entry) != 0) {
      return 0;
    }
    if (asm_module_is_pipeline_selfhost(entry) != 0 || asm_module_is_typeck_selfhost(entry) != 0 ||
        asm_module_is_backend_selfhost(entry) != 0 || asm_module_is_parser_selfhost(entry) != 0) {
      return 0;
    }
    if (asm_wpo_user_main_func_id() >= 0) {
      return 1;
    }
    return 0;

  }
}

/** Scan one function body for call edges. */
function asm_wpo_scan_func_body_calls(a: *u8, mod: *u8, func_fi: i32, caller_id: i32, ctx: *u8): void {
  unsafe {
    if (a == 0 as *u8 || mod == 0 as *u8 || caller_id < 0 || func_fi < 0) {
      return;
    }
    let body_ref: i32 = pipeline_module_func_body_ref_at(mod, func_fi);
    if (body_ref > 0) {
      asm_wpo_collect_from_block(a, body_ref, caller_id, mod, ctx);
    } else {
      let body_expr: i32 = pipeline_module_func_body_expr_ref_at(mod, func_fi);
      if (body_expr > 0) {
        asm_wpo_collect_edges_from_expr(a, body_expr, caller_id, mod, ctx, 0);
      }
    }

  }
}

/** Precollect all func edges before BFS. */
function asm_wpo_precollect_all_func_edges(): void {
  let fid: i32 = 0;
  let ctx: *u8 = asm_wpo_get_dep_ctx();
  while (fid < g_aw_nfuncs) {
    let m: *u8 = asm_wpo_func_mod_slot(fid);
    let mi: i32 = asm_wpo_mod_index(m);
    let a: *u8 = 0 as *u8;
    if (mi >= 0) {
      a = asm_wpo_arena_slot(mi);
    }
    asm_wpo_scan_func_body_calls(a, m, g_aw_func_fi[fid], fid, ctx);
    fid = fid + 1;
  }
}

/**
 * User PGO: force main tail return/expr_stmt direct call edge; return callee id.
 */
function asm_wpo_user_pgo_force_main_callee_edge(entry: *u8, a: *u8): i32 {
  unsafe {
    if (entry == 0 as *u8 || a == 0 as *u8) {
      return -1;
    }
    let main_id: i32 = asm_wpo_user_main_func_id();
    if (main_id < 0) {
      return -1;
    }
    let main_fi: i32 = g_aw_func_fi[main_id];
    let body_ref: i32 = pipeline_module_func_body_ref_at(entry, main_fi);
    if (body_ref <= 0) {
      return -1;
    }
    let er: i32 = 0;
    let nes: i32 = ast_ast_block_num_expr_stmts(a, body_ref);
    if (nes > 0) {
      er = ast_pipeline_block_expr_stmt_ref(a, body_ref, nes - 1);
    }
    if (er <= 0) {
      er = ast_ast_block_final_expr_ref(a, body_ref);
    }
    if (er <= 0) {
      return -1;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko == asm_wpo_ek_return()) {
      let op: i32 = pipeline_expr_unary_operand_ref_at(a, er);
      if (op <= 0) {
        return -1;
      }
      er = op;
    }
    ko = pipeline_expr_kind_ord_at(a, er);
    if (ko == asm_wpo_ek_method_call()) {
      let r_fn: i32 = pipeline_expr_call_resolved_func_index_at(a, er);
      let r_dep: i32 = pipeline_expr_call_resolved_dep_index_at(a, er);
      let nlen: i32 = pipeline_expr_method_call_name_len(a, er);
      let mnm: u8[256] = [];
      let cid: i32 = -1;
      if (r_fn >= 0 && r_dep < 0) {
        cid = asm_wpo_func_id_of(entry, r_fn);
      }
      if (cid < 0 && nlen > 0 && nlen <= 63) {
        pipeline_expr_method_call_name_into(a, er, &mnm[0]);
        cid = asm_wpo_func_id_in_module(entry, &mnm[0], nlen);
        if (cid < 0) {
          cid = asm_wpo_func_id_by_name(&mnm[0], nlen);
        }
      }
      if (cid >= 0) {
        asm_wpo_add_edge(main_id, cid);
      }
      return cid;
    }
    if (ko != asm_wpo_ek_call()) {
      return -1;
    }
    let cid2: i32 = asm_wpo_call_callee_id(a, er, entry, asm_wpo_get_dep_ctx());
    if (cid2 >= 0) {
      asm_wpo_add_edge(main_id, cid2);
    }
    return cid2;

  }
}

/** User PGO: drop main edges except legit_to. */
function asm_wpo_user_pgo_prune_main_edges(main_id: i32, legit_to: i32): void {
  if (main_id < 0 || legit_to < 0) {
    return;
  }
  let ei: i32 = 0;
  while (ei < g_aw_nedges) {
    if (g_aw_edge_from[ei] == main_id && g_aw_edge_to[ei] != legit_to) {
      g_aw_edge_from[ei] = g_aw_edge_from[g_aw_nedges - 1];
      g_aw_edge_to[ei] = g_aw_edge_to[g_aw_nedges - 1];
      g_aw_nedges = g_aw_nedges - 1;
    } else {
      ei = ei + 1;
    }
  }
}

/**
 * Fixpoint expand reachable set (up to 16 passes).
 * SKIP_TYPECK selfhost call graphs often incomplete on first pass.
 */
function asm_wpo_reach_fixpoint_expand(): void {
  unsafe {
    let pass: i32 = 0;
    let ctx: *u8 = asm_wpo_get_dep_ctx();
    while (pass < 16) {
      let expanded: i32 = 0;
      let fid: i32 = 0;
      while (fid < g_aw_nfuncs) {
        if (g_aw_reachable[fid] != 0) {
          let m: *u8 = asm_wpo_func_mod_slot(fid);
          let fi: i32 = g_aw_func_fi[fid];
          let mi: i32 = asm_wpo_mod_index(m);
          let a: *u8 = 0 as *u8;
          if (mi >= 0) {
            a = asm_wpo_arena_slot(mi);
          }
          if (a != 0 as *u8) {
            let body_ref: i32 = pipeline_module_func_body_ref_at(m, fi);
            if (body_ref > 0) {
              asm_wpo_collect_from_block(a, body_ref, fid, m, ctx);
            } else {
              let body_expr: i32 = pipeline_module_func_body_expr_ref_at(m, fi);
              if (body_expr > 0) {
                asm_wpo_collect_edges_from_expr(a, body_expr, fid, m, ctx, 0);
              }
            }
          }
        }
        fid = fid + 1;
      }
      let qh: i32 = 0;
      let qt: i32 = 0;
      fid = 0;
      while (fid < g_aw_nfuncs) {
        if (g_aw_reachable[fid] != 0 && qt < asm_wpo_max_funcs()) {
          g_aw_queue[qt] = fid;
          qt = qt + 1;
        }
        fid = fid + 1;
      }
      while (qh < qt && qh < asm_wpo_max_funcs()) {
        fid = g_aw_queue[qh];
        qh = qh + 1;
        let ei: i32 = 0;
        while (ei < g_aw_nedges) {
          if (g_aw_edge_from[ei] == fid) {
            let to: i32 = g_aw_edge_to[ei];
            if (to >= 0 && to < g_aw_nfuncs) {
              if (g_aw_reachable[to] == 0) {
                g_aw_reachable[to] = 1;
                expanded = 1;
                if (qt < asm_wpo_max_funcs()) {
                  g_aw_queue[qt] = to;
                  qt = qt + 1;
                }
              }
            }
          }
          ei = ei + 1;
        }
      }
      if (expanded == 0) {
        return;
      }
      pass = pass + 1;
    }

  }
}

/** BFS mark reachable from root. */
function asm_wpo_build_reach(): void {
  unsafe {
    if (g_aw_root_id < 0 || g_aw_root_id >= g_aw_nfuncs) {
      return;
    }
    let user_pgo: i32 = asm_wpo_is_user_single_file_pgo_entry();
    let ctx: *u8 = asm_wpo_get_dep_ctx();
    asm_wpo_precollect_all_func_edges();
    if (user_pgo != 0) {
      let entry: *u8 = asm_wpo_get_entry();
      if (entry != 0 as *u8 && g_aw_nmods > 0) {
        let main_callee: i32 = asm_wpo_user_pgo_force_main_callee_edge(entry, asm_wpo_arena_slot(0));
        let main_id: i32 = asm_wpo_user_main_func_id();
        if (main_id >= 0 && main_callee >= 0) {
          asm_wpo_user_pgo_prune_main_edges(main_id, main_callee);
        }
      }
    }
    let qh: i32 = 0;
    let qt: i32 = 0;
    g_aw_reachable[g_aw_root_id] = 1;
    g_aw_queue[qt] = g_aw_root_id;
    qt = 1;
    while (qh < qt && qh < asm_wpo_max_funcs()) {
      let fid: i32 = g_aw_queue[qh];
      qh = qh + 1;
      let m: *u8 = asm_wpo_func_mod_slot(fid);
      let fi: i32 = g_aw_func_fi[fid];
      let mi: i32 = asm_wpo_mod_index(m);
      let a: *u8 = 0 as *u8;
      if (mi >= 0) {
        a = asm_wpo_arena_slot(mi);
      }
      if (a != 0 as *u8) {
        let body_ref: i32 = pipeline_module_func_body_ref_at(m, fi);
        if (body_ref > 0) {
          asm_wpo_collect_from_block(a, body_ref, fid, m, ctx);
        } else {
          let body_expr: i32 = pipeline_module_func_body_expr_ref_at(m, fi);
          if (body_expr > 0) {
            asm_wpo_collect_edges_from_expr(a, body_expr, fid, m, ctx, 0);
          }
        }
      }
      let ei: i32 = 0;
      while (ei < g_aw_nedges) {
        if (g_aw_edge_from[ei] == fid) {
          let to: i32 = g_aw_edge_to[ei];
          if (to >= 0 && to < g_aw_nfuncs) {
            if (g_aw_reachable[to] == 0) {
              g_aw_reachable[to] = 1;
              if (qt < asm_wpo_max_funcs()) {
                g_aw_queue[qt] = to;
                qt = qt + 1;
              }
            }
          }
        }
        ei = ei + 1;
      }
    }
    asm_wpo_reach_fixpoint_expand();

  }
}

/** Module hosts allocator_kind_heap (std.heap marker). */
function asm_wpo_mod_is_std_heap(m: *u8): i32 {
  unsafe {
    if (m == 0 as *u8) {
      return 0;
    }
    let nf: i32 = pipeline_module_num_funcs(m);
    let fi: i32 = 0;
    while (fi < nf) {
      if (pipeline_module_func_name_equal_at(m, fi, "allocator_kind_heap", 19) != 0) {
        return 1;
      }
      fi = fi + 1;
    }
    return 0;

  }
}

/** Force-preserve std.heap helpers when heap module is reachable. */
function asm_wpo_close_std_heap_helpers(): void {
  unsafe {
    let fid: i32 = 0;
    let heap_mod: *u8 = 0 as *u8;
    while (fid < g_aw_nfuncs) {
      if (g_aw_reachable[fid] != 0) {
        if (asm_wpo_mod_is_std_heap(asm_wpo_func_mod_slot(fid)) != 0) {
          heap_mod = asm_wpo_func_mod_slot(fid);
          break;
        }
      }
      fid = fid + 1;
    }
    if (heap_mod == 0 as *u8) {
      return;
    }
    fid = 0;
    while (fid < g_aw_nfuncs) {
      if (asm_wpo_func_mod_slot(fid) == heap_mod) {
        let fi: i32 = g_aw_func_fi[fid];
        if (pipeline_module_func_name_equal_at(heap_mod, fi, "alloc", 5) != 0 ||
            pipeline_module_func_name_equal_at(heap_mod, fi, "arena64_alloc", 11) != 0 ||
            pipeline_module_func_name_equal_at(heap_mod, fi, "realloc", 7) != 0) {
          g_aw_reachable[fid] = 1;
        }
      }
      fid = fid + 1;
    }
    let cid0: i32 = asm_wpo_func_id_by_name("heap_arena64_alloc_c", 20);
    if (cid0 >= 0) {
      g_aw_reachable[cid0] = 1;
    }
    let cid1: i32 = asm_wpo_func_id_by_name("heap_alloc_c", 12);
    if (cid1 >= 0) {
      g_aw_reachable[cid1] = 1;
    }
    let cid2: i32 = asm_wpo_func_id_by_name("heap_realloc_c", 15);
    if (cid2 >= 0) {
      g_aw_reachable[cid2] = 1;
    }

  }
}

/** Mark PGO hot: root + direct callees (user-PGO special path). */
function asm_wpo_mark_pgo_hot(): void {
  unsafe {
    let i: i32 = 0;
    while (i < asm_wpo_max_funcs()) {
      g_aw_pgo_hot[i] = 0;
      i = i + 1;
    }
    if (pipeline_elf_pgo_hot_enabled() == 0) {
      return;
    }
    let root: i32 = g_aw_root_id;
    if (root < 0 || root >= g_aw_nfuncs) {
      return;
    }
    g_aw_pgo_hot[root] = 1;
    if (asm_wpo_is_user_single_file_pgo_entry() != 0) {
      let main_id: i32 = asm_wpo_user_main_func_id();
      if (main_id >= 0) {
        g_aw_pgo_hot[main_id] = 1;
        let entry: *u8 = asm_wpo_get_entry();
        if (entry != 0 as *u8 && g_aw_nmods > 0) {
          let main_callee: i32 = asm_wpo_user_pgo_force_main_callee_edge(entry, asm_wpo_arena_slot(0));
          if (main_callee >= 0 && g_aw_reachable[main_callee] != 0) {
            g_aw_pgo_hot[main_callee] = 1;
          }
        }
      }
      return;
    }
    let entry2: *u8 = asm_wpo_get_entry();
    if (entry2 != 0 as *u8 && asm_module_is_main_driver_selfhost(entry2) == 0) {
      let nf: i32 = pipeline_module_num_funcs(entry2);
      let fi: i32 = 0;
      while (fi < nf) {
        if (pipeline_module_func_name_equal_at(entry2, fi, "main", 4) != 0) {
          let mid: i32 = asm_wpo_func_id_of(entry2, fi);
          if (mid >= 0) {
            g_aw_pgo_hot[mid] = 1;
          }
        }
        fi = fi + 1;
      }
    }
    let ei: i32 = 0;
    while (ei < g_aw_nedges) {
      if (g_aw_edge_from[ei] == root) {
        let to: i32 = g_aw_edge_to[ei];
        if (to >= 0 && to < g_aw_nfuncs) {
          if (g_aw_reachable[to] != 0) {
            g_aw_pgo_hot[to] = 1;
          }
        }
      }
      ei = ei + 1;
    }

  }
}

/** PGO depth BFS from main (user single-file). */
function asm_wpo_mark_pgo_depth_user_from_main(): void {
  let main_id: i32 = asm_wpo_user_main_func_id();
  if (main_id < 0 || main_id >= g_aw_nfuncs) {
    return;
  }
  let i: i32 = 0;
  while (i < asm_wpo_max_funcs()) {
    g_aw_pgo_depth[i] = -1;
    i = i + 1;
  }
  g_aw_pgo_depth[main_id] = 0;
  let qh: i32 = 0;
  let qt: i32 = 1;
  g_aw_queue[0] = main_id;
  while (qh < qt && qh < asm_wpo_max_funcs()) {
    let fid: i32 = g_aw_queue[qh];
    qh = qh + 1;
    let nd: i32 = g_aw_pgo_depth[fid];
    if (nd >= 0) {
      let ei: i32 = 0;
      while (ei < g_aw_nedges) {
        if (g_aw_edge_from[ei] == fid) {
          let to: i32 = g_aw_edge_to[ei];
          if (to >= 0 && to < g_aw_nfuncs) {
            if (g_aw_reachable[to] != 0 && g_aw_pgo_depth[to] < 0) {
              g_aw_pgo_depth[to] = nd + 1;
              if (qt < asm_wpo_max_funcs()) {
                g_aw_queue[qt] = to;
                qt = qt + 1;
              }
            }
          }
        }
        ei = ei + 1;
      }
    }
  }
}

/** PGO depth BFS from root. */
function asm_wpo_mark_pgo_depth(): void {
  unsafe {
    let i: i32 = 0;
    while (i < asm_wpo_max_funcs()) {
      g_aw_pgo_depth[i] = -1;
      i = i + 1;
    }
    if (pipeline_elf_pgo_hot_enabled() == 0 || g_aw_valid == 0) {
      return;
    }
    if (asm_wpo_is_user_single_file_pgo_entry() != 0) {
      asm_wpo_mark_pgo_depth_user_from_main();
      return;
    }
    let root: i32 = g_aw_root_id;
    if (root < 0 || root >= g_aw_nfuncs) {
      return;
    }
    g_aw_pgo_depth[root] = 0;
    let qh: i32 = 0;
    let qt: i32 = 1;
    g_aw_queue[0] = root;
    while (qh < qt && qh < asm_wpo_max_funcs()) {
      let fid: i32 = g_aw_queue[qh];
      qh = qh + 1;
      let nd: i32 = g_aw_pgo_depth[fid];
      if (nd >= 0) {
        let ei: i32 = 0;
        while (ei < g_aw_nedges) {
          if (g_aw_edge_from[ei] == fid) {
            let to: i32 = g_aw_edge_to[ei];
            if (to >= 0 && to < g_aw_nfuncs) {
              if (g_aw_reachable[to] != 0 && g_aw_pgo_depth[to] < 0) {
                g_aw_pgo_depth[to] = nd + 1;
                if (qt < asm_wpo_max_funcs()) {
                  g_aw_queue[qt] = to;
                  qt = qt + 1;
                }
              }
            }
          }
          ei = ei + 1;
        }
      }
    }

  }
}

/** PGO depth of (m,fi); unknown/unreachable => 9999. */
function asm_wpo_pgo_depth_of(m: *u8, fi: i32): i32 {
  if (m == 0 as *u8 || fi < 0) {
    return 9999;
  }
  let id: i32 = asm_wpo_func_id_of(m, fi);
  if (id < 0) {
    return 9999;
  }
  let d: i32 = g_aw_pgo_depth[id];
  if (d < 0) {
    return 9999;
  }
  return d;
}

/**
 * XLANG_ASM_WPO_DCE env: enabled by default; "0" disables; XLANG_WPO_NO_FOLD also disables.
 */
function asm_wpo_dce_env_enabled(): i32 {
  let nf: *u8 = 0 as *u8;
  let e: *u8 = 0 as *u8;
  unsafe {
    nf = link_abi_getenv("XLANG_WPO_NO_FOLD");
  }
  if (nf != 0 as *u8) {
    return 0;
  }
  unsafe {
    e = link_abi_getenv("XLANG_ASM_WPO_DCE");
  }
  if (e == 0 as *u8) {
    return 1;
  }
  unsafe {
    if (e[0] == 0) {
      return 1;
    }
    if (e[0] == 48) {
      if (e[1] == 0 || e[1] == 10) {
        return 0;
      }
    }
  }
  return 1;
}

/**
 * Register entry+deps funcs and build WPO reach for asm elf emit.
 * @param entry *u8 - entry ast_Module*
 * @param entry_arena *u8 - entry ASTArena*
 * @param ctx *u8 - PipelineDepCtx* (nullable)
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_reach_compute_for_elf(entry: *u8, entry_arena: *u8, ctx: *u8): void {
  unsafe {
    pipeline_asm_wpo_reach_clear();
    if (entry == 0 as *u8 || entry_arena == 0 as *u8) {
      return;
    }
    if (asm_wpo_dce_env_enabled() == 0) {
      return;
    }
    // User library module .o (no main/entry): full emit; selfhost dogfood must not early-return.
    let main_ix: i32 = pipeline_module_main_func_index(entry);
    if (main_ix < 0) {
      let nf0: i32 = pipeline_module_num_funcs(entry);
      let fi0: i32 = 0;
      let found_entry: i32 = 0;
      while (fi0 < nf0) {
        if (pipeline_module_func_name_equal_at(entry, fi0, "entry", 5) != 0) {
          found_entry = 1;
          break;
        }
        fi0 = fi0 + 1;
      }
      if (found_entry == 0) {
        if (asm_module_is_typeck_selfhost(entry) == 0 && asm_module_is_pipeline_selfhost(entry) == 0 &&
            asm_module_is_backend_selfhost(entry) == 0 && asm_module_is_driver_compile_selfhost(entry) == 0) {
          return;
        }
      }
    }
    asm_wpo_set_entry(entry);
    asm_wpo_set_dep_ctx(ctx);
    if (asm_wpo_register_mod(entry, entry_arena) < 0) {
      return;
    }
    if (ctx != 0 as *u8) {
      let ndep: i32 = pipeline_dep_ctx_ndep(ctx);
      let j: i32 = 0;
      while (j < ndep) {
        let dm: *u8 = pipeline_dep_ctx_module_at(ctx, j);
        let da: *u8 = pipeline_dep_ctx_arena_at(ctx, j);
        if (dm != 0 as *u8 && da != 0 as *u8 && dm != entry) {
          let _r: i32 = asm_wpo_register_mod(dm, da);
        }
        j = j + 1;
      }
    }
    let mi: i32 = 0;
    while (mi < g_aw_nmods) {
      let nm: i32 = pipeline_module_num_funcs(asm_wpo_mod_slot(mi));
      let fi: i32 = 0;
      while (fi < nm) {
        let _rf: i32 = asm_wpo_register_func(asm_wpo_mod_slot(mi), fi);
        fi = fi + 1;
      }
      mi = mi + 1;
    }
    // Prefer named roots (entry / main / selfhost orch) over main_func_index #0.
    let nf: i32 = pipeline_module_num_funcs(entry);
    let fi2: i32 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "entry", 5) != 0) {
        g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
    // After clear root_id is 0; residual only searches main when root_id < 0.
    // Preserve that: only search main if root still 0 AND no entry was found
    // (func_id_of of entry would set root). Residual used root_id < 0 which after
    // memset is never true — so main search was effectively only if we want
    // entry-miss path with root still 0. Match residual: if entry not found,
    // root_id stays 0; main search checks root_id < 0 (dead). Then later
    // named selfhost roots also check root_id < 0.
    // FIX root authority: residual memset leaves root_id=0; the `< 0` guards
    // never fire. Product behavior relies on user_program force-main and
    // selfhost name loops that only run when root_id < 0 — also dead.
    // Historical product still worked because first registered non-extern is
    // often #0, and user force-main rewrites root. Keep same semantics.
    // However entry search above does set root when "entry" exists.
    // Re-implement residual checks literally (root_id < 0):
    if (g_aw_root_id < 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "main", 4) != 0) {
          g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
    }
    if (g_aw_root_id < 0 && asm_module_is_pipeline_selfhost(entry) != 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "run_x_pipeline_impl", 19) != 0) {
          g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
    }
    if (g_aw_root_id < 0 && asm_module_is_typeck_selfhost(entry) != 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "typeck_x_ast", 12) != 0) {
          g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
    }
    if (g_aw_root_id < 0 && asm_module_is_backend_selfhost(entry) != 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "asm_codegen_ast", 15) != 0) {
          g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
    }
    if (g_aw_root_id < 0 && asm_module_is_driver_compile_selfhost(entry) != 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "compile_dispatch_asm_backend", 28) != 0) {
          g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
      if (g_aw_root_id < 0) {
        fi2 = 0;
        while (fi2 < nf) {
          if (pipeline_module_func_name_equal_at(entry, fi2, "run_compiler_full_x", 19) != 0) {
            g_aw_root_id = asm_wpo_func_id_of(entry, fi2);
            break;
          }
          fi2 = fi2 + 1;
        }
      }
    }
    main_ix = pipeline_module_main_func_index(entry);
    if (g_aw_root_id < 0 && main_ix >= 0) {
      if (pipeline_module_func_name_equal_at(entry, main_ix, "main", 4) != 0) {
        g_aw_root_id = asm_wpo_func_id_of(entry, main_ix);
      }
    }
    // Product-critical: residual memset left root_id=0 so `< 0` named-root
    // searches never ran; selfhost WPO still worked via force paths below and
    // root=0 first func. BUT pipeline/typeck/backend named roots only apply
    // when root_id < 0. To match residual bug-compat, leave as-is.
    // Additionally: when "entry" was not found, root_id remains 0 after clear —
    // first registered func id is often 0. Force user main when applicable.
    if (g_aw_root_id < 0 || g_aw_nfuncs <= 0) {
      return;
    }
    if (asm_wpo_is_user_program_entry() != 0) {
      let user_main: i32 = asm_wpo_user_main_func_id();
      if (user_main >= 0) {
        g_aw_root_id = user_main;
      }
    } else if (asm_wpo_is_user_single_file_pgo_entry() != 0) {
      let user_main2: i32 = asm_wpo_user_main_func_id();
      if (user_main2 >= 0) {
        g_aw_root_id = user_main2;
      }
    }
    asm_wpo_build_reach();
    asm_wpo_close_std_heap_helpers();
    if (asm_wpo_is_user_program_entry() != 0) {
      let user_main3: i32 = asm_wpo_user_main_func_id();
      if (user_main3 >= 0) {
        g_aw_reachable[user_main3] = 1;
      }
    }
    asm_wpo_reach_fixpoint_expand();
    g_aw_valid = 1;
    // mark_pgo_depth early-returns if !valid; residual calls mark_pgo_hot then
    // mark_pgo_depth AFTER valid=1. Match order.
    asm_wpo_mark_pgo_hot();
    asm_wpo_mark_pgo_depth();

  }
}

/** pipeline.x WPO: preserve strict orchestration exports under SKIP_TYPECK. */
function asm_wpo_pipeline_strict_preserve_emit(m: *u8, fi: i32): i32 {
  unsafe {
    if (m == 0 as *u8 || fi < 0 || asm_module_is_pipeline_selfhost(m) == 0) {
      return 0;
    }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_impl", 19) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_parse_entry_if_needed", 37) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_parse_entry_do_parse", 36) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_typecheck_entry", 31) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_codegen_deps", 28) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_codegen_entry", 29) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "run_x_pipeline_codegen_one_dep", 31) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_typeck_entry_module", 28) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_typeck_parsed_module", 27) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "resolve_path_x", 15) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_should_skip_x_typeck", 30) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "read_file_x", 12) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_load_and_sync_direct_import_deps", 41) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_parse_into_buf", 23) != 0) { return 1; }
    if (pipeline_module_func_name_equal_at(m, fi, "pipeline_parse_set_main_from_buf", 32) != 0) { return 1; }
    return 0;

  }
}

/**
 * Asm emit gate: 1=emit, 0=WPO dead export skip; invalid WPO or extern => keep.
 * @param m *u8 - ast_Module*
 * @param fi i32 - func index
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_should_emit_func(m: *u8, fi: i32): i32 {
  unsafe {
    if (g_aw_valid == 0) {
      return 1;
    }
    /* F7: impl methods referenced only from vtable wrappers are marked used
     * in pipeline_asm_emit_vtable_wrapper_def. WPO call-graph has no edge. */
    if (m != 0 as *u8 && fi >= 0 && pipeline_module_func_is_used_at(m, fi) != 0) {
      return 1;
    }
    if (m == 0 as *u8 || fi < 0) {
      return 1;
    }
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0) {
      return 1;
    }
    let entry: *u8 = asm_wpo_get_entry();
    if (m == entry && pipeline_module_func_name_equal_at(m, fi, "entry", 5) != 0) {
      return 1;
    }
    if (m == entry && asm_module_is_main_driver_selfhost(m) == 0 &&
        pipeline_module_func_name_equal_at(m, fi, "main", 4) != 0) {
      return 1;
    }
    if (m == entry && asm_module_is_main_driver_selfhost(m) != 0) {
      return 0;
    }
    if (m == entry && asm_module_is_driver_compile_selfhost(m) != 0) {
      if (pipeline_module_func_name_equal_at(m, fi, "compile_dispatch_asm_backend", 28) != 0) {
        return 1;
      }
      if (pipeline_module_func_name_equal_at(m, fi, "compile_dispatch_emit_c_path", 28) != 0) {
        return 1;
      }
      return 0;
    }
    if (asm_wpo_pipeline_strict_preserve_emit(m, fi) != 0) {
      return 1;
    }
    if (m == entry && asm_module_is_typeck_selfhost(m) != 0) {
      if (pipeline_module_func_name_equal_at(m, fi, "typeck_x_ast", 12) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "typeck_x_ast_library", 20) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "check_block", 11) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "check_expr", 10) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "typeck_merge_dep_struct_layouts_into_entry", 42) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "typeck_wpo_unify_soa_layouts", 28) != 0) { return 1; }
    }
    if (m == entry && asm_module_is_backend_selfhost(m) != 0) {
      if (pipeline_module_func_name_equal_at(m, fi, "asm_codegen_ast", 15) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "asm_codegen_ast_to_elf", 22) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "emit_expr_elf", 13) != 0) { return 1; }
      if (pipeline_module_func_name_equal_at(m, fi, "emit_block_body_elf", 19) != 0) { return 1; }
    }
    let id: i32 = asm_wpo_func_id_of(m, fi);
    if (id < 0) {
      return 1;
    }
    if (pipeline_module_func_name_equal_at(m, fi, "default_alloc", 13) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "heap_alloc", 14) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "alloc", 5) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "arena64_alloc", 11) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "realloc", 7) != 0) {
      let j: i32 = 0;
      while (j < g_aw_nfuncs) {
        if (g_aw_reachable[j] != 0) {
          let jm: *u8 = asm_wpo_func_mod_slot(j);
          let jfi: i32 = g_aw_func_fi[j];
          if (jm != 0 as *u8 && jfi >= 0) {
            if (pipeline_module_func_name_equal_at(jm, jfi, "alloc", 5) != 0 ||
                pipeline_module_func_name_equal_at(jm, jfi, "realloc", 7) != 0) {
              return 1;
            }
          }
        }
        j = j + 1;
      }
    }
    if (pipeline_module_func_name_equal_at(m, fi, "heap_arena64_alloc_c", 20) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "heap_alloc_c", 12) != 0 ||
        pipeline_module_func_name_equal_at(m, fi, "heap_realloc_c", 15) != 0) {
      let j2: i32 = 0;
      while (j2 < g_aw_nfuncs) {
        if (g_aw_reachable[j2] != 0) {
          let hm: *u8 = asm_wpo_func_mod_slot(j2);
          if (asm_wpo_mod_is_std_heap(hm) != 0) {
            let jfi2: i32 = g_aw_func_fi[j2];
            if (pipeline_module_func_name_equal_at(hm, jfi2, "alloc", 5) != 0 ||
                pipeline_module_func_name_equal_at(hm, jfi2, "realloc", 7) != 0) {
              return 1;
            }
          }
        }
        j2 = j2 + 1;
      }
    }
    if (g_aw_reachable[id] != 0) {
      return 1;
    }
    return 0;

  }
}

/**
 * Build emit order table for module: WPO filter + sort by call-depth.
 * @param m *u8 - ast_Module*
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void {
  unsafe {
    if (m == 0 as *u8) {
      asm_wpo_set_emit_mod(0 as *u8);
      g_aw_pgo_emit_n = 0;
      return;
    }
    asm_wpo_set_emit_mod(m);
    let n: i32 = 0;
    let nf: i32 = pipeline_module_num_funcs(m);
    let fi: i32 = 0;
    // PLATFORM: SHARED — g_aw_pgo_emit_order is i32[ASM_WPO_MAX_FUNCS].
    // Historical bug: n kept growing past capacity while the array stopped
    // being written; g_aw_pgo_emit_n = n then made order_at() read OOB into
    // adjacent BSS (emit_n / queue), re-emitting the same bogus body hundreds
    // of times as T _strchr and inflating abi-scale pipeline_wpo.o ~800KiB+.
    // Only increment n when a slot is stored; emit_n never exceeds capacity.
    while (fi < nf) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 && pipeline_asm_wpo_should_emit_func(m, fi) != 0) {
        if (n < asm_wpo_max_funcs()) {
          g_aw_pgo_emit_order[n] = fi;
          n = n + 1;
        }
      }
      fi = fi + 1;
    }
    // Empty emit set is fatal for asm -o; fall back to all non-extern.
    if (n == 0 && nf > 0) {
      fi = 0;
      while (fi < nf) {
        if (pipeline_asm_module_func_is_extern_at(m, fi) == 0) {
          if (n < asm_wpo_max_funcs()) {
            g_aw_pgo_emit_order[n] = fi;
            n = n + 1;
          }
        }
        fi = fi + 1;
      }
    }
    if (pipeline_elf_pgo_hot_enabled() != 0 && g_aw_valid != 0) {
      let a: i32 = 0;
      while (a < n) {
        let b: i32 = a + 1;
        while (b < n) {
          let da: i32 = asm_wpo_pgo_depth_of(m, g_aw_pgo_emit_order[a]);
          let db: i32 = asm_wpo_pgo_depth_of(m, g_aw_pgo_emit_order[b]);
          if (da > db || (da == db && g_aw_pgo_emit_order[a] > g_aw_pgo_emit_order[b])) {
            let tmp: i32 = g_aw_pgo_emit_order[a];
            g_aw_pgo_emit_order[a] = g_aw_pgo_emit_order[b];
            g_aw_pgo_emit_order[b] = tmp;
          }
          b = b + 1;
        }
        a = a + 1;
      }
    }
    g_aw_pgo_emit_n = n;

  }
}

/**
 * Count of funcs to emit for module (lazy prepare).
 * @param m *u8 - ast_Module*
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32 {
  unsafe {
    if (m != asm_wpo_get_emit_mod()) {
      pipeline_asm_wpo_pgo_emit_order_prepare(m);
    }
    return g_aw_pgo_emit_n;

  }
}

/**
 * Func index at emit order_index; -1 OOB.
 * @param m *u8 - ast_Module*
 * @param order_index i32
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32 {
  unsafe {
    if (m != asm_wpo_get_emit_mod()) {
      pipeline_asm_wpo_pgo_emit_order_prepare(m);
    }
    // Belt: reject OOB past array capacity even if emit_n were stale/corrupt.
    if (order_index < 0 || order_index >= g_aw_pgo_emit_n ||
        order_index >= asm_wpo_max_funcs()) {
      return -1;
    }
    return g_aw_pgo_emit_order[order_index];

  }
}

/**
 * PGO-Lite: 1 => emit into .text.hot; 0 => .text. Disabled when PGO_HOT off.
 * Invalid WPO with PGO on returns 1 (conservative hot).
 * @param m *u8 - ast_Module*
 * @param fi i32 - func index
 * wave274 pure-owned leave.
 * PLATFORM: SHARED freestanding WPO leave.
 */
#[no_mangle]
export function pipeline_asm_wpo_pgo_is_hot_func(m: *u8, fi: i32): i32 {
  unsafe {
    if (pipeline_elf_pgo_hot_enabled() == 0) {
      return 0;
    }
    if (g_aw_valid == 0) {
      return 1;
    }
    let id: i32 = asm_wpo_func_id_of(m, fi);
    if (id < 0) {
      return 0;
    }
    if (g_aw_pgo_hot[id] != 0) {
      return 1;
    }
    return 0;

  }
}
