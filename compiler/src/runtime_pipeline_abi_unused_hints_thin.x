// Thin pure: L6 unused-binding hints (XLANG_UNUSED_HINT=1).
// G.7: body MUST match pipeline_typeck_unused_binding_hints in
// runtime_pipeline_abi.x (same exported symbol). Scan function-body
// let/const names; report via driver_diagnostic_hint_unused_binding when
// no EXPR_VAR use exists in the arena. Skip '_' prefix (intentional unused).
// ensure injects via pipeline_abi_inject_unused_hints_thin (first-wins;
// avoids Darwin mega -E). PLATFORM: SHARED freestanding lint · LINUX gold.

export extern function link_abi_getenv(name: *u8): *u8;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function pipeline_block_let_name_len(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *u8, block_ref: i32, let_idx: i32, dst: *u8): void;
export extern function ast_pipeline_block_const_name_len(arena: *u8, block_ref: i32, i: i32): i32;
export extern function ast_pipeline_block_const_name_copy64(arena: *u8, block_ref: i32, i: i32, dst: *u8): void;
export extern function driver_diagnostic_hint_unused_binding(line: i32, col: i32, name: *u8, name_len: i32): void;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;

/**
 * LP64 offsetof(ASTArena, num_exprs). Layout: num_types@0 num_exprs@4.
 * @return i32 — byte offset
 * PLATFORM: SHARED — thin-local twin of pipe_arena_off_num_exprs.
 */
function l6_arena_off_num_exprs(): i32 {
  return 4;
}

/**
 * Whether L6 unused-binding hint is enabled (XLANG_UNUSED_HINT=1).
 * @return i32 — 1 enabled, else 0
 * PLATFORM: SHARED — opt-in info lint; default off (does not spam product -o).
 */
function l6_unused_hint_enabled(): i32 {
  let e: *u8 = 0 as *u8;
  let key: u8[18] = [
    88, 76, 65, 78, 71, 95, 85, 78, 85, 83, 69, 68, 95, 72, 73, 78, 84, 0
  ];
  unsafe {
    e = link_abi_getenv(&key[0]);
  }
  if (e == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (e[0] == 49 && e[1] == 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * Compare name[0..nlen) to buf[0..nlen); 1 if equal.
 * @param name *u8 — binding name
 * @param nlen i32 — length
 * @param buf *u8 — candidate bytes
 * @return i32 — 1 equal
 * PLATFORM: SHARED.
 */
function l6_name_eq(name: *u8, nlen: i32, buf: *u8): i32 {
  let i: i32 = 0;
  if (name == 0 as *u8 || buf == 0 as *u8 || nlen <= 0) {
    return 0;
  }
  while (i < nlen) {
    unsafe {
      if (name[i] != buf[i]) {
        return 0;
      }
    }
    i = i + 1;
  }
  return 1;
}

/**
 * True if any EXPR_VAR in the arena spells the given binding name.
 * @param a *u8 — ASTArena*
 * @param name *u8 — binding name bytes
 * @param nlen i32 — length
 * @return i32 — 1 used, 0 unused
 * PLATFORM: SHARED — arena-wide VAR scan (EXPR_VAR kind_ord == 3).
 */
function l6_binding_is_used(a: *u8, name: *u8, nlen: i32): i32 {
  let nexpr: i32 = 0;
  let er: i32 = 1;
  let ko: i32 = 0;
  let vlen: i32 = 0;
  let vbuf: u8[128] = [];
  if (a == 0 as *u8 || name == 0 as *u8 || nlen <= 0) {
    return 1;
  }
  unsafe {
    nexpr = pipe_load_i32_le(a, l6_arena_off_num_exprs());
  }
  while (er <= nexpr) {
    unsafe {
      ko = pipeline_expr_kind_ord_at(a, er);
    }
    // EXPR_VAR = 3
    if (ko == 3) {
      unsafe {
        vlen = pipeline_expr_var_name_len(a, er);
      }
      if (vlen == nlen && vlen > 0 && vlen < 128) {
        unsafe {
          pipeline_expr_var_name_into(a, er, &vbuf[0]);
        }
        if (l6_name_eq(name, nlen, &vbuf[0]) != 0) {
          return 1;
        }
      }
    }
    er = er + 1;
  }
  return 0;
}

/**
 * Report one unused binding if not '_' prefixed and never used as VAR.
 * @param a *u8 — ASTArena*
 * @param name *u8 — binding name
 * @param nlen i32 — length
 * @return i32 — 1 if reported, else 0
 * PLATFORM: SHARED — '_' prefix = intentional unused (Rust-like).
 */
function l6_maybe_report(a: *u8, name: *u8, nlen: i32): i32 {
  let c0: u8 = 0;
  if (name == 0 as *u8 || nlen <= 0) {
    return 0;
  }
  unsafe {
    c0 = name[0];
  }
  // '_' (95) → intentional unused
  if (c0 == 95) {
    return 0;
  }
  if (l6_binding_is_used(a, name, nlen) != 0) {
    return 0;
  }
  unsafe {
    driver_diagnostic_hint_unused_binding(1, 1, name, nlen);
  }
  return 1;
}

/**
 * Scan one block's let + const bindings for unused names.
 * @param a *u8 — ASTArena*
 * @param br i32 — block ref
 * @return i32 — hint count
 * PLATFORM: SHARED.
 */
function l6_scan_block(a: *u8, br: i32): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let nlen: i32 = 0;
  let name: u8[128] = [];
  let nh: i32 = 0;
  if (a == 0 as *u8 || br <= 0) {
    return 0;
  }
  unsafe {
    n = ast_ast_block_num_lets(a, br);
  }
  i = 0;
  while (i < n) {
    unsafe {
      nlen = pipeline_block_let_name_len(a, br, i);
    }
    if (nlen > 0 && nlen < 128) {
      unsafe {
        pipeline_block_let_name_copy64(a, br, i, &name[0]);
      }
      nh = nh + l6_maybe_report(a, &name[0], nlen);
    }
    i = i + 1;
  }
  unsafe {
    n = ast_ast_block_num_consts(a, br);
  }
  i = 0;
  while (i < n) {
    unsafe {
      nlen = ast_pipeline_block_const_name_len(a, br, i);
    }
    if (nlen > 0 && nlen < 128) {
      unsafe {
        ast_pipeline_block_const_name_copy64(a, br, i, &name[0]);
      }
      nh = nh + l6_maybe_report(a, &name[0], nlen);
    }
    i = i + 1;
  }
  return nh;
}

/**
 * L6 unused-binding hints for a typed module (info; never fails typeck).
 * Gated by XLANG_UNUSED_HINT=1. Walks each function body block's let/const
 * and emits driver_diagnostic_hint_unused_binding for names with no EXPR_VAR use.
 * @param m *u8 — Module*
 * @param a *u8 — ASTArena*
 * @return i32 — number of hints emitted
 * PLATFORM: SHARED — G.7 sole product authority (thin twin of abi.x).
 */
#[no_mangle]
export function pipeline_typeck_unused_binding_hints(m: *u8, a: *u8): i32 {
  let nfuncs: i32 = 0;
  let fi: i32 = 0;
  let br: i32 = 0;
  let nh: i32 = 0;
  if (m == 0 as *u8 || a == 0 as *u8) {
    return 0;
  }
  if (l6_unused_hint_enabled() == 0) {
    return 0;
  }
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0) {
    return 0;
  }
  fi = 0;
  while (fi < nfuncs) {
    unsafe {
      br = pipeline_module_func_body_ref_at(m, fi);
    }
    if (br > 0) {
      nh = nh + l6_scan_block(a, br);
    }
    fi = fi + 1;
  }
  return nh;
}
