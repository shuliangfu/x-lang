// Thin pure: L6 unused-binding hints (XLANG_UNUSED_HINT=1).
// G.7: body MUST match pipeline_typeck_unused_binding_hints in
// runtime_pipeline_abi.x (same exported symbol). Scan function-body
// let/const names; report via driver_diagnostic_hint_unused_binding when
// no EXPR_VAR use exists in the arena. Skip '_' prefix (intentional unused).
// ensure injects via pipeline_abi_inject_unused_hints_thin (first-wins;
// avoids Darwin mega -E).
// wave398: PRODUCT PREFER_ASM both ends (stamp .pabi_w398_unused_hints.stamp);
//   standalone -c green Darwin/Ubuntu; was class-E default -E.
// wave493: no-local mid `x=call()` (tip U starved 4/14); LINUX -E (tip PREFER SEGV).
// wave738: LINUX product PREFER_ASM replace leftover gcc W (standalone T=7 U=17);
//   MACOS keep prior PREFER overlay. Do not fall back to -E for this TU.
// PLATFORM: SHARED freestanding lint · LINUX gold.

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
/** Pipe cell store i32 — tip-stable mid call result. */
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
/** Pipe cell store ptr — tip-stable mid call result. */
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
/** Pipe cell load ptr. */
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

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
 * wave493: no-local — pipe cell for getenv; ban mid `e=link_abi_getenv()`.
 */
function l6_unused_hint_enabled(): i32 {
  let cell: u8[8];
  let key: u8[18] = [
    88, 76, 65, 78, 71, 95, 85, 78, 85, 83, 69, 68, 95, 72, 73, 78, 84, 0
  ];
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `e=link_abi_getenv()`; pipe cell. */
    pipe_store_ptr_slot(&cell[0], 0, link_abi_getenv(&key[0]));
    if (pipe_load_ptr_slot(&cell[0], 0) == (0 as *u8)) {
      return 0;
    }
    if (pipe_load_ptr_slot(&cell[0], 0)[0] == 49 && pipe_load_ptr_slot(&cell[0], 0)[1] == 0) {
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
 * wave493: no-local — pipe cell for mid i32 calls; loops in unsafe (T001).
 */
function l6_binding_is_used(a: *u8, name: *u8, nlen: i32): i32 {
  let er: i32 = 1;
  /* Cap 4.2.8: var_name_into memset(out,0,256). */
  let vbuf: u8[256] = [];
  let cell: u8[8];
  if (a == 0 as *u8 || name == 0 as *u8 || nlen <= 0) {
    return 1;
  }
  unsafe {
    /* cell[0]=nexpr stable; cell[4]=ko then vlen temp. */
    pipe_store_i32_le(&cell[0], 0, pipe_load_i32_le(a, l6_arena_off_num_exprs()));
    while (er <= pipe_load_i32_le(&cell[0], 0)) {
      pipe_store_i32_le(&cell[0], 4, pipeline_expr_kind_ord_at(a, er));
      // EXPR_VAR = 3
      if (pipe_load_i32_le(&cell[0], 4) == 3) {
        pipe_store_i32_le(&cell[0], 4, pipeline_expr_var_name_len(a, er));
        if (pipe_load_i32_le(&cell[0], 4) == nlen && pipe_load_i32_le(&cell[0], 4) > 0 && pipe_load_i32_le(&cell[0], 4) < 128) {
          pipeline_expr_var_name_into(a, er, &vbuf[0]);
          if (l6_name_eq(name, nlen, &vbuf[0]) != 0) {
            return 1;
          }
        }
      }
      er = er + 1;
    }
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
 * wave493: no-local — pipe cell for mid i32 calls; loops in unsafe (T001).
 */
function l6_scan_block(a: *u8, br: i32): i32 {
  let i: i32 = 0;
  let name: u8[256] = [];
  let nh: i32 = 0;
  let cell: u8[8];
  if (a == 0 as *u8 || br <= 0) {
    return 0;
  }
  unsafe {
    /* cell[0]=n; cell[4]=nlen */
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_lets(a, br));
    i = 0;
    while (i < pipe_load_i32_le(&cell[0], 0)) {
      pipe_store_i32_le(&cell[0], 4, pipeline_block_let_name_len(a, br, i));
      if (pipe_load_i32_le(&cell[0], 4) > 0 && pipe_load_i32_le(&cell[0], 4) < 128) {
        pipeline_block_let_name_copy64(a, br, i, &name[0]);
        nh = nh + l6_maybe_report(a, &name[0], pipe_load_i32_le(&cell[0], 4));
      }
      i = i + 1;
    }
    pipe_store_i32_le(&cell[0], 0, ast_ast_block_num_consts(a, br));
    i = 0;
    while (i < pipe_load_i32_le(&cell[0], 0)) {
      pipe_store_i32_le(&cell[0], 4, ast_pipeline_block_const_name_len(a, br, i));
      if (pipe_load_i32_le(&cell[0], 4) > 0 && pipe_load_i32_le(&cell[0], 4) < 128) {
        ast_pipeline_block_const_name_copy64(a, br, i, &name[0]);
        nh = nh + l6_maybe_report(a, &name[0], pipe_load_i32_le(&cell[0], 4));
      }
      i = i + 1;
    }
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
 * wave493: no-local — pipe cell for mid i32 calls; loops in unsafe (T001).
 */
#[no_mangle]
export function pipeline_typeck_unused_binding_hints(m: *u8, a: *u8): i32 {
  let fi: i32 = 0;
  let nh: i32 = 0;
  let cell: u8[8];
  if (m == 0 as *u8 || a == 0 as *u8) {
    return 0;
  }
  if (l6_unused_hint_enabled() == 0) {
    return 0;
  }
  // M2 class A: export-extern call must sit in unsafe (-backend asm T001).
  // PLATFORM: SHARED — asm typeck contract; mega thin small-file reproduce.
  unsafe {
    /* cell[0]=nfuncs; cell[4]=br */
    pipe_store_i32_le(&cell[0], 0, pipeline_module_num_funcs(m));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return 0;
    }
    fi = 0;
    while (fi < pipe_load_i32_le(&cell[0], 0)) {
      pipe_store_i32_le(&cell[0], 4, pipeline_module_func_body_ref_at(m, fi));
      if (pipe_load_i32_le(&cell[0], 4) > 0) {
        nh = nh + l6_scan_block(a, pipe_load_i32_le(&cell[0], 4));
      }
      fi = fi + 1;
    }
  }
  return nh;
}
