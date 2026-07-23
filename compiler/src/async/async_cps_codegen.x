// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// async_cps_codegen.x — pure surface for async CPS switch emit (A3).
// R2 pure surface + Cap residual pure wave1–5:
//   - name gates (io / future_wait / sched wrapper)
//   - thin public wrappers for walk/hoist
//   - await expr classifiers (expr_is_io_await / await_read / await_write / await_fd / future_wait)
//   - module/sched resolve + func_uses_void_entry (no FILE*; host LE loads)
//   - walk _impl: expr_references_run_async_impl / block_has_run_async_ref_impl (host LE)
//   - FILE* emit via shared Cap residual driver_preamble_fputs: end / phase_reset / after_await / sched
//   - wave5: begin / emit_param_statics / emit_hoisted_lets_impl (type_to_c_buf + run-seed inject)
// Cap residual (seed C always, G.7 single authority): driver_preamble_fputs (opaque FILE*).
// ASTExpr host layout (PLATFORM: SHARED with async_liveness): kind@0; value@24;
//   unary.operand@24; CALL callee@24 args@32 num@40 resolved_fn@72;
//   METHOD base@24 name@32 args@40 num@48 impl@56; FIELD name@32; VAR name@24.
//   AST_EXPR_AWAIT=54 RUN=55 SPAWN=56 CALL=48 METHOD=49 FIELD=44 VAR=3.
// ASTBlock: let_decls@16 num_lets@24; loops@32 num@40; for_loops@48 num@56;
//   labeled@80 num@88; expr_stmts@96 num@104; final_expr@112.
//   ASTWhileLoop size 16 body@8; ASTForLoop size 32 body@24;
//   ASTLabeledStmt size 32 kind@8 u@24; AST_STMT_RETURN=1.
// ASTFunc host layout: name@8 params@32 num_params@40 body@56 is_extern@64 is_async@68.
// ASTParam size24: name@0 type@8; ASTLetDecl size48: name@0 type@8.
// ASTType: kind@0 (I32=0 U32=3 I64=5 USIZE=6 …).
// ASTModule host layout: funcs@152 num_funcs@160 (funcs is ASTFunc**).
// AsyncCpsCodegenCtx (LP64 size 24): func@0 layout@8 phase_next@16 switch_open@20.
// AsyncFrameLayout (size 4196): live@0 live.n@4096 num_awaits@4100 (see async_liveness).
// PLATFORM: SHARED — pure helper contract; prove surface IDENTICAL on mac + Ubuntu.
// Cold product path: cc seeds/async_cps_codegen.from_x.c (no FROM_X).
// Hybrid/PREFER (future): g05_try_x_to_o + rest (-DXLANG_ASYNC_CPS_CODEGEN_FROM_X).

// Cap residual liveness predicates / type_to_c (authority in async_liveness; G.7 single path).
export extern "C" function async_liveness_func_needs_cps_frame(f: *u8): i32;
export extern "C" function async_liveness_func_has_await(f: *u8): i32;
export extern "C" function async_liveness_type_to_c_buf(ty: *u8, buf: *u8, cap: i32): void;
// G.7 Cap residual: opaque *u8 stream → FILE* fputs. Authority = driver_preamble_fputs
// in runtime_driver_abi (always seed); no module-local async_cps_fputs clone.
// Returns fputs-style status (negative on error/null). .x must not cast *u8 to FILE*.
export extern "C" function driver_preamble_fputs(s: *u8, stream: *u8): i32;

/** Prove/doc anchor for the pure surface TU (always 0).
 * PLATFORM: SHARED — no_mangle keeps short surface name for nm IDENTICAL. */
#[no_mangle]
export function async_cps_codegen_x_doc_anchor(): i32 {
  return 0;
}

/** Load ASTFunc.name pointer from a callee ASTFunc* viewed as *u8.
 * Host C layout: name is a char* at byte offset 8 (little-endian pointer load).
 * Returns null when callee is null. Used by pure name-gate helpers only.
 * PLATFORM: SHARED — ASTFunc name slot layout must match host seed. */
#[no_mangle]
export function async_cps_load_func_name(callee: *u8): *u8 {
  if (callee == 0) {
    return 0 as *u8;
  }
  // Reconstruct pointer from 8 little-endian bytes at offset 8.
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = callee[8] as usize;
  a = a + (callee[9] as usize) * m;
  a = a + (callee[10] as usize) * m2;
  a = a + (callee[11] as usize) * (m2 * m);
  a = a + (callee[12] as usize) * m4;
  a = a + (callee[13] as usize) * (m4 * m);
  a = a + (callee[14] as usize) * (m4 * m2);
  a = a + (callee[15] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/** Thin public wrapper: hoist used lets before the CPS switch (FILE* emit).
 * Body is Cap residual pure wave5 emit_hoisted_lets_impl (fputs statics).
 * @param f ASTFunc* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — public short name matches seed cold path. */
#[no_mangle]
export function emit_hoisted_lets(f: *u8, out: *u8): void {
  emit_hoisted_lets_impl(f, out);
}

/** True when callee is an IO-A5 await target (std.io sync API / xlang_io_* C entry).
 * Pure name table: xlang_io_*, read, write, submit_*, read_fd, write_fd,
 * read_ptr, read_stdin_ptr, read_into, write_from.
 * @param callee ASTFunc* as *u8 (null-safe)
 * @return 1 if IO target, else 0
 * PLATFORM: SHARED — pure string gates; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_callee_is_io(callee: *u8): i32 {
  let name: *u8 = async_cps_load_func_name(callee);
  if (name == 0) {
    return 0;
  }
  if (name[0] == 0) {
    return 0;
  }
  // xlang_io_
  if (name[0] == 115 && name[1] == 104 && name[2] == 117 && name[3] == 120 && name[4] == 95
      && name[5] == 105 && name[6] == 111 && name[7] == 95) {
    return 1;
  }
  // read / write
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 0) {
    return 1;
  }
  if (name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101
      && name[5] == 0) {
    return 1;
  }
  // submit_read / submit_write
  if (name[0] == 115 && name[1] == 117 && name[2] == 98 && name[3] == 109 && name[4] == 105
      && name[5] == 116 && name[6] == 95 && name[7] == 114 && name[8] == 101 && name[9] == 97
      && name[10] == 100 && name[11] == 0) {
    return 1;
  }
  if (name[0] == 115 && name[1] == 117 && name[2] == 98 && name[3] == 109 && name[4] == 105
      && name[5] == 116 && name[6] == 95 && name[7] == 119 && name[8] == 114 && name[9] == 105
      && name[10] == 116 && name[11] == 101 && name[12] == 0) {
    return 1;
  }
  // read_fd / write_fd
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 95
      && name[5] == 102 && name[6] == 100 && name[7] == 0) {
    return 1;
  }
  if (name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101
      && name[5] == 95 && name[6] == 102 && name[7] == 100 && name[8] == 0) {
    return 1;
  }
  // read_ptr / read_stdin_ptr
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 95
      && name[5] == 112 && name[6] == 116 && name[7] == 114 && name[8] == 0) {
    return 1;
  }
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 95
      && name[5] == 115 && name[6] == 116 && name[7] == 100 && name[8] == 105 && name[9] == 110
      && name[10] == 95 && name[11] == 112 && name[12] == 116 && name[13] == 114 && name[14] == 0) {
    return 1;
  }
  // read_into / write_from
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 95
      && name[5] == 105 && name[6] == 110 && name[7] == 116 && name[8] == 111 && name[9] == 0) {
    return 1;
  }
  if (name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101
      && name[5] == 95 && name[6] == 102 && name[7] == 114 && name[8] == 111 && name[9] == 109
      && name[10] == 0) {
    return 1;
  }
  return 0;
}

/** Thin public wrapper: whether expr tree references run/spawn of target async.
 * Cap residual pure wave3: body is expr_references_run_async_impl (host LE walk).
 * ABI matches C: (expr, target). Do not drop the target parameter.
 * PLATFORM: SHARED */
#[no_mangle]
export function expr_references_run_async(e: *u8, target: *u8): i32 {
  return expr_references_run_async_impl(e, target);
}

/** Thin public wrapper: whether block references run/spawn of target async.
 * Cap residual pure wave3: body is block_has_run_async_ref_impl (host LE walk).
 * ABI matches C: (block, target).
 * PLATFORM: SHARED */
#[no_mangle]
export function block_has_run_async_ref(b: *u8, target: *u8): i32 {
  return block_has_run_async_ref_impl(b, target);
}

/** True when name is a Future wait entry (exact or substring).
 * Exact: future_wait, runtime_wait_future, xlang_async_future_wait_c,
 *   std_async_future_wait, std_async_runtime_wait_future.
 * Substring scan (cap 512): future_wait, runtime_wait_future.
 * @param n NUL-terminated C string or null
 * @return 1 if wait-name, else 0
 * PLATFORM: SHARED — pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_callee_is_future_wait_by_name(n: *u8): i32 {
  if (n == 0) {
    return 0;
  }
  if (n[0] == 0) {
    return 0;
  }
  // future_wait
  if (n[0] == 102 && n[1] == 117 && n[2] == 116 && n[3] == 117 && n[4] == 114 && n[5] == 101
      && n[6] == 95 && n[7] == 119 && n[8] == 97 && n[9] == 105 && n[10] == 116 && n[11] == 0) {
    return 1;
  }
  // runtime_wait_future
  if (n[0] == 114 && n[1] == 117 && n[2] == 110 && n[3] == 116 && n[4] == 105 && n[5] == 109
      && n[6] == 101 && n[7] == 95 && n[8] == 119 && n[9] == 97 && n[10] == 105 && n[11] == 116
      && n[12] == 95 && n[13] == 102 && n[14] == 117 && n[15] == 116 && n[16] == 117 && n[17] == 114
      && n[18] == 101 && n[19] == 0) {
    return 1;
  }
  // xlang_async_future_wait_c
  if (n[0] == 115 && n[1] == 104 && n[2] == 117 && n[3] == 120 && n[4] == 95 && n[5] == 97
      && n[6] == 115 && n[7] == 121 && n[8] == 110 && n[9] == 99 && n[10] == 95 && n[11] == 102
      && n[12] == 117 && n[13] == 116 && n[14] == 117 && n[15] == 114 && n[16] == 101 && n[17] == 95
      && n[18] == 119 && n[19] == 97 && n[20] == 105 && n[21] == 116 && n[22] == 95 && n[23] == 99
      && n[24] == 0) {
    return 1;
  }
  // std_async_future_wait
  if (n[0] == 115 && n[1] == 116 && n[2] == 100 && n[3] == 95 && n[4] == 97 && n[5] == 115
      && n[6] == 121 && n[7] == 110 && n[8] == 99 && n[9] == 95 && n[10] == 102 && n[11] == 117
      && n[12] == 116 && n[13] == 117 && n[14] == 114 && n[15] == 101 && n[16] == 95 && n[17] == 119
      && n[18] == 97 && n[19] == 105 && n[20] == 116 && n[21] == 0) {
    return 1;
  }
  // std_async_runtime_wait_future
  if (n[0] == 115 && n[1] == 116 && n[2] == 100 && n[3] == 95 && n[4] == 97 && n[5] == 115
      && n[6] == 121 && n[7] == 110 && n[8] == 99 && n[9] == 95 && n[10] == 114 && n[11] == 117
      && n[12] == 110 && n[13] == 116 && n[14] == 105 && n[15] == 109 && n[16] == 101 && n[17] == 95
      && n[18] == 119 && n[19] == 97 && n[20] == 105 && n[21] == 116 && n[22] == 95 && n[23] == 102
      && n[24] == 117 && n[25] == 116 && n[26] == 117 && n[27] == 114 && n[28] == 101 && n[29] == 0) {
    return 1;
  }
  // substring future_wait / runtime_wait_future (bounded scan)
  let i: i32 = 0;
  while (i < 512) {
    if (n[i] == 0) {
      break;
    }
    if (n[i] == 102 && n[i + 1] == 117 && n[i + 2] == 116 && n[i + 3] == 117 && n[i + 4] == 114
        && n[i + 5] == 101 && n[i + 6] == 95 && n[i + 7] == 119 && n[i + 8] == 97 && n[i + 9] == 105
        && n[i + 10] == 116) {
      return 1;
    }
    if (n[i] == 114 && n[i + 1] == 117 && n[i + 2] == 110 && n[i + 3] == 116 && n[i + 4] == 105
        && n[i + 5] == 109 && n[i + 6] == 101 && n[i + 7] == 95 && n[i + 8] == 119 && n[i + 9] == 97
        && n[i + 10] == 105 && n[i + 11] == 116 && n[i + 12] == 95 && n[i + 13] == 102
        && n[i + 14] == 117 && n[i + 15] == 116 && n[i + 16] == 117 && n[i + 17] == 114
        && n[i + 18] == 101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** True when callee ASTFunc name is a Future wait entry (see by_name).
 * @param callee ASTFunc* as *u8
 * PLATFORM: SHARED — pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_callee_is_future_wait(callee: *u8): i32 {
  let name: *u8 = async_cps_load_func_name(callee);
  if (name == 0) {
    return 0;
  }
  return async_cps_callee_is_future_wait_by_name(name);
}

/** True when name is a scheduler wrapper `xlang_async_sched_<async>`.
 * Prefix length 16: "xlang_async_sched_".
 * PLATFORM: SHARED — pure string gate; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_is_sched_wrapper_name(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  // xlang_async_sched_
  if (name[0] == 115 && name[1] == 104 && name[2] == 117 && name[3] == 120 && name[4] == 95
      && name[5] == 97 && name[6] == 115 && name[7] == 121 && name[8] == 110 && name[9] == 99
      && name[10] == 95 && name[11] == 115 && name[12] == 99 && name[13] == 104 && name[14] == 101
      && name[15] == 100 && name[16] == 95) {
    return 1;
  }
  return 0;
}

// ---- Cap residual pure wave1: LE load helpers + await expr classifiers ----

/** Load little-endian i32 at base+off (null-safe).
 * PLATFORM: SHARED — host AST layout loads only. */
#[no_mangle]
export function async_cps_load_i32(p: *u8, off: i32): i32 {
  if (p == 0) {
    return 0;
  }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * m * m;
  a = a + (p[off + 3] as i32) * m * m * m;
  return a;
}

/** Load little-endian pointer at base+off (null-safe).
 * PLATFORM: SHARED — host AST layout loads only. */
#[no_mangle]
export function async_cps_load_ptr(p: *u8, off: i32): *u8 {
  if (p == 0) {
    return 0 as *u8;
  }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/** Load pointer table entry base[i] (8-byte LE slots).
 * PLATFORM: SHARED — ASTExpr** / ASTFunc** tables. */
#[no_mangle]
export function async_cps_ptr_at(base: *u8, i: i32): *u8 {
  if (base == 0) {
    return 0 as *u8;
  }
  return async_cps_load_ptr(base, i * 8);
}

/** True when expr kind uses value.binop (ADD..LOGOR or ASSIGN..SHR_ASSIGN).
 * PLATFORM: SHARED — ASTExprKind ranges. */
#[no_mangle]
export function async_cps_is_binop_kind(k: i32): i32 {
  if (k >= 4) {
    if (k <= 21) {
      return 1;
    }
  }
  if (k >= 28) {
    if (k <= 38) {
      return 1;
    }
  }
  return 0;
}

/** True when expr kind uses value.unary.operand (or as_type.operand @24) in run-walk.
 * Includes NEG/BITNOT/LOGNOT/RETURN/PANIC/ADDR_OF/DEREF/AS/AWAIT/RUN/SPAWN/TRY.
 * PLATFORM: SHARED — matches seed expr_references_run_async_impl switch. */
#[no_mangle]
export function async_cps_is_walk_unary_kind(k: i32): i32 {
  if (k == 22) { return 1; }
  if (k == 23) { return 1; }
  if (k == 24) { return 1; }
  if (k == 41) { return 1; }
  if (k == 42) { return 1; }
  if (k == 51) { return 1; }
  if (k == 52) { return 1; }
  if (k == 53) { return 1; }
  if (k == 54) { return 1; }
  if (k == 55) { return 1; }
  if (k == 56) { return 1; }
  if (k == 57) { return 1; }
  return 0;
}

/** Cap residual pure wave3: walk expr tree for run/spawn of `target` async.
 * Semantics match seed C expr_references_run_async_impl (typed AST walk):
 *   1) If kind is RUN(55)/SPAWN(56) and unary.op is CALL with resolved_callee_func==target → 1
 *   2) Recurse binop/unary/if/ternary/call-args/method/field/index/struct/array/match/block
 * CALL walks args only (not callee expr) — same as seed.
 * @param e ASTExpr* as *u8
 * @param target ASTFunc* as *u8 (pointer equality on resolved_callee_func)
 * @return 1 if found, else 0
 * PLATFORM: SHARED — host LE layout; seed C under #ifndef FROM_X. */
#[no_mangle]
export function expr_references_run_async_impl(e: *u8, target: *u8): i32 {
  if (e == 0) {
    return 0;
  }
  if (target == 0) {
    return 0;
  }
  let k: i32 = async_cps_load_i32(e, 0);
  // Direct run/spawn of target: operand is CALL with resolved_callee_func == target.
  if (k == 55) {
    let op0: *u8 = async_cps_load_ptr(e, 24);
    if (op0 != 0) {
      if (async_cps_load_i32(op0, 0) == 48) {
        let res0: *u8 = async_cps_load_ptr(op0, 72);
        if (res0 == target) {
          return 1;
        }
      }
    }
  }
  if (k == 56) {
    let op1: *u8 = async_cps_load_ptr(e, 24);
    if (op1 != 0) {
      if (async_cps_load_i32(op1, 0) == 48) {
        let res1: *u8 = async_cps_load_ptr(op1, 72);
        if (res1 == target) {
          return 1;
        }
      }
    }
  }
  if (async_cps_is_binop_kind(k) != 0) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    return expr_references_run_async_impl(async_cps_load_ptr(e, 32), target);
  }
  if (async_cps_is_walk_unary_kind(k) != 0) {
    return expr_references_run_async_impl(async_cps_load_ptr(e, 24), target);
  }
  // IF (25) / TERNARY (27): cond@24 then@32 else@40
  if (k == 25) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 32), target) != 0) {
      return 1;
    }
    let el: *u8 = async_cps_load_ptr(e, 40);
    if (el != 0) {
      if (expr_references_run_async_impl(el, target) != 0) {
        return 1;
      }
    }
    return 0;
  }
  if (k == 27) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 32), target) != 0) {
      return 1;
    }
    let el2: *u8 = async_cps_load_ptr(e, 40);
    if (el2 != 0) {
      if (expr_references_run_async_impl(el2, target) != 0) {
        return 1;
      }
    }
    return 0;
  }
  // CALL (48): seed walks args only (not callee)
  if (k == 48) {
    let args: *u8 = async_cps_load_ptr(e, 32);
    let n: i32 = async_cps_load_i32(e, 40);
    let i: i32 = 0;
    while (i < n) {
      if (expr_references_run_async_impl(async_cps_ptr_at(args, i), target) != 0) {
        return 1;
      }
      i = i + 1;
    }
    return 0;
  }
  // METHOD_CALL (49): base@24 args@40 num@48
  if (k == 49) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    let args2: *u8 = async_cps_load_ptr(e, 40);
    let n2: i32 = async_cps_load_i32(e, 48);
    let j: i32 = 0;
    while (j < n2) {
      if (expr_references_run_async_impl(async_cps_ptr_at(args2, j), target) != 0) {
        return 1;
      }
      j = j + 1;
    }
    return 0;
  }
  // FIELD_ACCESS (44)
  if (k == 44) {
    return expr_references_run_async_impl(async_cps_load_ptr(e, 24), target);
  }
  // INDEX (47): base@24 index@32
  if (k == 47) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    return expr_references_run_async_impl(async_cps_load_ptr(e, 32), target);
  }
  // STRUCT_LIT (45): inits@40 num@48
  if (k == 45) {
    let inits: *u8 = async_cps_load_ptr(e, 40);
    let nf: i32 = async_cps_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      if (expr_references_run_async_impl(async_cps_ptr_at(inits, fi), target) != 0) {
        return 1;
      }
      fi = fi + 1;
    }
    return 0;
  }
  // ARRAY_LIT (46): elems@24 num@32
  if (k == 46) {
    let elems: *u8 = async_cps_load_ptr(e, 24);
    let ne: i32 = async_cps_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      if (expr_references_run_async_impl(async_cps_ptr_at(elems, ei), target) != 0) {
        return 1;
      }
      ei = ei + 1;
    }
    return 0;
  }
  // MATCH (43): matched@24 arms@32 num@40; MatchArm size 88 result@80
  if (k == 43) {
    if (expr_references_run_async_impl(async_cps_load_ptr(e, 24), target) != 0) {
      return 1;
    }
    let arms: *u8 = async_cps_load_ptr(e, 32);
    let na: i32 = async_cps_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) {
        return 0;
      }
      let arm: *u8 = arms + (ai * 88);
      if (expr_references_run_async_impl(async_cps_load_ptr(arm, 80), target) != 0) {
        return 1;
      }
      ai = ai + 1;
    }
    return 0;
  }
  // BLOCK (26): value.block @24
  if (k == 26) {
    return block_has_run_async_ref_impl(async_cps_load_ptr(e, 24), target);
  }
  return 0;
}

/** Cap residual pure wave3: walk block for run/spawn of `target` async.
 * Semantics match seed C block_has_run_async_ref_impl:
 *   expr_stmts[], final_expr, labeled RETURN exprs, while/for body blocks.
 * @param b ASTBlock* as *u8
 * @param target ASTFunc* as *u8
 * @return 1 if found, else 0
 * PLATFORM: SHARED — host LE layout; seed C under #ifndef FROM_X. */
#[no_mangle]
export function block_has_run_async_ref_impl(b: *u8, target: *u8): i32 {
  if (b == 0) {
    return 0;
  }
  if (target == 0) {
    return 0;
  }
  // expr_stmts @96, num_expr_stmts @104
  let stmts: *u8 = async_cps_load_ptr(b, 96);
  let ns: i32 = async_cps_load_i32(b, 104);
  let si: i32 = 0;
  while (si < ns) {
    if (expr_references_run_async_impl(async_cps_ptr_at(stmts, si), target) != 0) {
      return 1;
    }
    si = si + 1;
  }
  // final_expr @112
  let fin: *u8 = async_cps_load_ptr(b, 112);
  if (fin != 0) {
    if (expr_references_run_async_impl(fin, target) != 0) {
      return 1;
    }
  }
  // labeled_stmts @80, num @88; entry size 32: kind@8, u@24; AST_STMT_RETURN=1
  let labs: *u8 = async_cps_load_ptr(b, 80);
  let nl: i32 = async_cps_load_i32(b, 88);
  let li: i32 = 0;
  while (li < nl) {
    if (labs != 0) {
      let lab: *u8 = labs + (li * 32);
      if (async_cps_load_i32(lab, 8) == 1) {
        let ret_e: *u8 = async_cps_load_ptr(lab, 24);
        if (ret_e != 0) {
          if (expr_references_run_async_impl(ret_e, target) != 0) {
            return 1;
          }
        }
      }
    }
    li = li + 1;
  }
  // loops @32, num_loops @40; ASTWhileLoop size 16 body@8
  let loops: *u8 = async_cps_load_ptr(b, 32);
  let nloop: i32 = async_cps_load_i32(b, 40);
  let wi: i32 = 0;
  while (wi < nloop) {
    if (loops != 0) {
      let wbody: *u8 = async_cps_load_ptr(loops + (wi * 16), 8);
      if (wbody != 0) {
        if (block_has_run_async_ref_impl(wbody, target) != 0) {
          return 1;
        }
      }
    }
    wi = wi + 1;
  }
  // for_loops @48, num_for_loops @56; ASTForLoop size 32 body@24
  let fors: *u8 = async_cps_load_ptr(b, 48);
  let nfor: i32 = async_cps_load_i32(b, 56);
  let fi: i32 = 0;
  while (fi < nfor) {
    if (fors != 0) {
      let fbody: *u8 = async_cps_load_ptr(fors + (fi * 32), 24);
      if (fbody != 0) {
        if (block_has_run_async_ref_impl(fbody, target) != 0) {
          return 1;
        }
      }
    }
    fi = fi + 1;
  }
  return 0;
}

/** True when name is exact ASCII "read" (NUL-terminated).
 * PLATFORM: SHARED — pure string gate. */
#[no_mangle]
export function async_cps_name_is_read(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 0) {
    return 1;
  }
  return 0;
}

/** True when name is exact ASCII "write" (NUL-terminated).
 * PLATFORM: SHARED — pure string gate. */
#[no_mangle]
export function async_cps_name_is_write(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  if (name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101
      && name[5] == 0) {
    return 1;
  }
  return 0;
}

/** True when name is exact ASCII "read_fd" (NUL-terminated).
 * PLATFORM: SHARED — pure string gate. */
#[no_mangle]
export function async_cps_name_is_read_fd(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  if (name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100 && name[4] == 95
      && name[5] == 102 && name[6] == 100 && name[7] == 0) {
    return 1;
  }
  return 0;
}

/** True when name is exact ASCII "write_fd" (NUL-terminated).
 * PLATFORM: SHARED — pure string gate. */
#[no_mangle]
export function async_cps_name_is_write_fd(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  if (name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101
      && name[5] == 95 && name[6] == 102 && name[7] == 100 && name[8] == 0) {
    return 1;
  }
  return 0;
}

/** True when await_expr is `await <io-call>` (IO-A5 target via resolved callee).
 * Requires kind==AST_EXPR_AWAIT (54), unary.operand CALL (48) with resolved_fn@72.
 * @param await_expr ASTExpr* as *u8
 * @return 1 if IO await, else 0
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_io_await(await_expr: *u8): i32 {
  if (await_expr == 0) {
    return 0;
  }
  // AST_EXPR_AWAIT = 54
  if (async_cps_load_i32(await_expr, 0) != 54) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  // AST_EXPR_CALL = 48
  if (async_cps_load_i32(op, 0) != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved == 0) {
    return 0;
  }
  return async_cps_callee_is_io(resolved);
}

/** True when await is `await read(handle, ptr, len, ...)` (num_args >= 3).
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_await_read(await_expr: *u8): i32 {
  if (async_cps_expr_is_io_await(await_expr) == 0) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 0) != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved == 0) {
    return 0;
  }
  let name: *u8 = async_cps_load_func_name(resolved);
  if (async_cps_name_is_read(name) == 0) {
    return 0;
  }
  // call.num_args @40
  if (async_cps_load_i32(op, 40) < 3) {
    return 0;
  }
  return 1;
}

/** True when await is `await read_fd(fd, ptr, len)` (num_args >= 3).
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_await_read_fd(await_expr: *u8): i32 {
  if (async_cps_expr_is_io_await(await_expr) == 0) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 0) != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved == 0) {
    return 0;
  }
  let name: *u8 = async_cps_load_func_name(resolved);
  if (async_cps_name_is_read_fd(name) == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 40) < 3) {
    return 0;
  }
  return 1;
}

/** True when await is `await write_fd(fd, ptr, len)` (num_args >= 3).
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_await_write_fd(await_expr: *u8): i32 {
  if (async_cps_expr_is_io_await(await_expr) == 0) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 0) != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved == 0) {
    return 0;
  }
  let name: *u8 = async_cps_load_func_name(resolved);
  if (async_cps_name_is_write_fd(name) == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 40) < 3) {
    return 0;
  }
  return 1;
}

/** True when await is `await write(handle, ptr, len, ...)` (num_args >= 3).
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_await_write(await_expr: *u8): i32 {
  if (async_cps_expr_is_io_await(await_expr) == 0) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 0) != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved == 0) {
    return 0;
  }
  let name: *u8 = async_cps_load_func_name(resolved);
  if (async_cps_name_is_write(name) == 0) {
    return 0;
  }
  if (async_cps_load_i32(op, 40) < 3) {
    return 0;
  }
  return 1;
}

/** True when await is future_wait (method / call resolved / field / var name).
 * METHOD: method_name@32 or resolved_impl@56 via future_wait name gate.
 * CALL: resolved_fn@72, or callee FIELD field_name@32, or callee VAR name@24.
 * PLATFORM: SHARED — Cap residual pure wave1; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_expr_is_await_future_wait(await_expr: *u8): i32 {
  if (await_expr == 0) {
    return 0;
  }
  // AST_EXPR_AWAIT = 54
  if (async_cps_load_i32(await_expr, 0) != 54) {
    return 0;
  }
  let op: *u8 = async_cps_load_ptr(await_expr, 24);
  if (op == 0) {
    return 0;
  }
  let ok: i32 = async_cps_load_i32(op, 0);
  // AST_EXPR_METHOD_CALL = 49
  if (ok == 49) {
    let method_name: *u8 = async_cps_load_ptr(op, 32);
    if (method_name != 0) {
      if (async_cps_callee_is_future_wait_by_name(method_name) != 0) {
        return 1;
      }
    }
    let implf: *u8 = async_cps_load_ptr(op, 56);
    if (implf != 0) {
      if (async_cps_callee_is_future_wait(implf) != 0) {
        return 1;
      }
    }
    return 0;
  }
  // AST_EXPR_CALL = 48
  if (ok != 48) {
    return 0;
  }
  let resolved: *u8 = async_cps_load_ptr(op, 72);
  if (resolved != 0) {
    if (async_cps_callee_is_future_wait(resolved) != 0) {
      return 1;
    }
  }
  let call_callee: *u8 = async_cps_load_ptr(op, 24);
  if (call_callee == 0) {
    return 0;
  }
  let ck: i32 = async_cps_load_i32(call_callee, 0);
  // AST_EXPR_FIELD_ACCESS = 44
  if (ck == 44) {
    let field_name: *u8 = async_cps_load_ptr(call_callee, 32);
    if (field_name != 0) {
      if (async_cps_callee_is_future_wait_by_name(field_name) != 0) {
        return 1;
      }
    }
    return 0;
  }
  // AST_EXPR_VAR = 3
  if (ck == 3) {
    let vname: *u8 = async_cps_load_ptr(call_callee, 24);
    if (vname != 0) {
      if (async_cps_callee_is_future_wait_by_name(vname) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

// ---- Cap residual pure wave2: module/sched resolve + void entry (no FILE*) ----

/** NUL-terminated C string equality (bounded scan, max 4096).
 * Null either side → 0. Used by sched resolve name matches only.
 * PLATFORM: SHARED — pure; local to this TU (prove surface self-contained). */
#[no_mangle]
export function async_cps_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) {
    return 0;
  }
  if (b == 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 4096) {
    let ca: u8 = a[i];
    let cb: u8 = b[i];
    if (ca != cb) {
      return 0;
    }
    if (ca == 0) {
      return 1;
    }
    i = i + 1;
  }
  return 1;
}

/** Advance a C string pointer by n bytes (null-safe).
 * Used for sched_name + 16 after "xlang_async_sched_" prefix.
 * PLATFORM: SHARED — host pointer arithmetic via usize. */
#[no_mangle]
export function async_cps_cstr_skip(p: *u8, n: i32): *u8 {
  if (p == 0) {
    return 0 as *u8;
  }
  if (n <= 0) {
    return p;
  }
  let a: usize = p as usize;
  a = a + (n as usize);
  return a as *u8;
}

/** Load ASTFunc* at funcs[i] from ASTModule.funcs (ASTFunc** @152).
 * @param m ASTModule* as *u8
 * @param i function index (0-based)
 * PLATFORM: SHARED — pointer table stride 8 on LP64 host. */
#[no_mangle]
export function async_cps_module_func_at(m: *u8, i: i32): *u8 {
  if (m == 0) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  let funcs: *u8 = async_cps_load_ptr(m, 152);
  if (funcs == 0) {
    return 0 as *u8;
  }
  return async_cps_load_ptr(funcs, i * 8);
}

/** True when async CPS coroutine uses void (*)(void) entry (needs CPS frame).
 * ABI matches C: (f, m); m is unused (kept for call-site compatibility).
 * @param f ASTFunc* as *u8
 * @param m ASTModule* as *u8 (ignored)
 * @return 1 if f->is_async && async_liveness_func_needs_cps_frame(f)
 * PLATFORM: SHARED — Cap residual pure wave2; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_func_uses_void_entry(f: *u8, m: *u8): i32 {
  // m is unused (C seed uses (void)m); parameter retained for C ABI (f, m).
  if (f == 0) {
    return 0;
  }
  // ASTFunc.is_async @68
  if (async_cps_load_i32(f, 68) == 0) {
    return 0;
  }
  // Reference m so the second formal is not DCE'd by frontend (ABI lock).
  if (m != 0) {
    // no-op: product ignores module for void-entry decision
  }
  unsafe {
    return async_liveness_func_needs_cps_frame(f);
  }
  return 0;
}

/** True when any non-extern function body in module references run/spawn of async_fn.
 * Walks m->funcs[0..num_funcs); skips is_extern or null body.
 * Calls public block_has_run_async_ref (thin → seed _impl).
 * PLATFORM: SHARED — Cap residual pure wave2; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_module_references_run_async(m: *u8, async_fn: *u8): i32 {
  if (m == 0) {
    return 0;
  }
  if (async_fn == 0) {
    return 0;
  }
  // ASTModule.num_funcs @160
  let n: i32 = async_cps_load_i32(m, 160);
  if (n <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n) {
    let f: *u8 = async_cps_module_func_at(m, i);
    i = i + 1;
    if (f == 0) {
      continue;
    }
    // is_extern @64
    if (async_cps_load_i32(f, 64) != 0) {
      continue;
    }
    // body @56
    let body: *u8 = async_cps_load_ptr(f, 56);
    if (body == 0) {
      continue;
    }
    if (block_has_run_async_ref(body, async_fn) != 0) {
      return 1;
    }
  }
  return 0;
}

/** Resolve scheduler wrapper name `xlang_async_sched_<async>` to the async ASTFunc*.
 * Requires is_sched_wrapper_name; strips 16-byte prefix; matches f->name + is_async
 * + async_liveness_func_has_await. Skips extern funcs.
 * @return ASTFunc* as *u8, or null
 * PLATFORM: SHARED — Cap residual pure wave2; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_resolve_sched_target(m: *u8, sched_name: *u8): *u8 {
  if (m == 0) {
    return 0 as *u8;
  }
  if (sched_name == 0) {
    return 0 as *u8;
  }
  if (async_cps_is_sched_wrapper_name(sched_name) == 0) {
    return 0 as *u8;
  }
  // "xlang_async_sched_" length 16
  let async_name: *u8 = async_cps_cstr_skip(sched_name, 16);
  if (async_name == 0) {
    return 0 as *u8;
  }
  if (async_name[0] == 0) {
    return 0 as *u8;
  }
  let n: i32 = async_cps_load_i32(m, 160);
  if (n <= 0) {
    return 0 as *u8;
  }
  let i: i32 = 0;
  while (i < n) {
    let f: *u8 = async_cps_module_func_at(m, i);
    i = i + 1;
    if (f == 0) {
      continue;
    }
    let fname: *u8 = async_cps_load_func_name(f);
    if (fname == 0) {
      continue;
    }
    // is_extern @64
    if (async_cps_load_i32(f, 64) != 0) {
      continue;
    }
    if (async_cps_cstr_eq(fname, async_name) == 0) {
      continue;
    }
    // is_async @68
    if (async_cps_load_i32(f, 68) == 0) {
      continue;
    }
    let has: i32 = 0;
    unsafe {
      has = async_liveness_func_has_await(f);
    }
    if (has != 0) {
      return f;
    }
  }
  return 0 as *u8;
}

/** True when module has `extern "C" function xlang_async_sched_<async_fn.name>`.
 * Pure equivalent of seed snprintf+strcmp: prefix gate + cstr_eq(name+16, async name).
 * Requires async_fn->is_async and async_liveness_func_has_await.
 * PLATFORM: SHARED — Cap residual pure wave2; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_module_has_sched_extern(m: *u8, async_fn: *u8): i32 {
  if (m == 0) {
    return 0;
  }
  if (async_fn == 0) {
    return 0;
  }
  let async_name: *u8 = async_cps_load_func_name(async_fn);
  if (async_name == 0) {
    return 0;
  }
  if (async_name[0] == 0) {
    return 0;
  }
  // is_async @68
  if (async_cps_load_i32(async_fn, 68) == 0) {
    return 0;
  }
  let has: i32 = 0;
  unsafe {
    has = async_liveness_func_has_await(async_fn);
  }
  if (has == 0) {
    return 0;
  }
  let n: i32 = async_cps_load_i32(m, 160);
  if (n <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n) {
    let ef: *u8 = async_cps_module_func_at(m, i);
    i = i + 1;
    if (ef == 0) {
      continue;
    }
    // is_extern @64 — only extern decls count
    if (async_cps_load_i32(ef, 64) == 0) {
      continue;
    }
    let ename: *u8 = async_cps_load_func_name(ef);
    if (ename == 0) {
      continue;
    }
    if (async_cps_is_sched_wrapper_name(ename) == 0) {
      continue;
    }
    let rest: *u8 = async_cps_cstr_skip(ename, 16);
    if (async_cps_cstr_eq(rest, async_name) != 0) {
      return 1;
    }
  }
  return 0;
}

// ---- Cap residual pure wave4: FILE* emit via opaque fputs bridge ----
// AsyncCpsCodegenCtx LP64: func@0 layout@8 phase_next@16 switch_open@20 (size 24).
// AsyncFrameLive names[64][64]@0 n@4096; name row i at layout+(i*64).

/** Store little-endian i32 at p+off (null-safe). Used for phase_next / switch_open.
 * PLATFORM: SHARED — host LE; mirrors async_live_store_i32 pattern in-module. */
#[no_mangle]
export function async_cps_store_i32(p: *u8, off: i32, v: i32): void {
  if (p == 0) {
    return;
  }
  if (off < 0) {
    return;
  }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}

/** Emit non-negative i32 as decimal digits through driver_preamble_fputs.
 * Phase counters are always >= 0 in seed semantics; negative is a no-op.
 * @param out FILE* as *u8
 * @param v value to print (only v >= 0)
 * PLATFORM: SHARED — Cap residual pure wave4; uses opaque fputs bridge. */
#[no_mangle]
export function async_cps_fputs_i32_dec(out: *u8, v: i32): void {
  if (out == 0) {
    return;
  }
  if (v < 0) {
    return;
  }
  // Special-case 0 so the digit loop can assume v > 0.
  if (v == 0) {
    let z: u8[2] = [48, 0];
    unsafe {
      driver_preamble_fputs(&z[0], out);
    }
    return;
  }
  // Count digits, then write most-significant first into a small stack buffer.
  let cnt: i32 = 0;
  let tc: i32 = v;
  while (tc > 0) {
    cnt = cnt + 1;
    tc = tc / 10;
  }
  // Cap 16 digits covers i32 max; +1 for NUL.
  let buf: u8[17];
  let k: i32 = cnt - 1;
  let tm: i32 = v;
  while (tm > 0) {
    let d: i32 = tm % 10;
    tm = tm / 10;
    if (k >= 0) {
      if (k < 16) {
        buf[k] = ((d + 48) as u8);
      }
    }
    k = k - 1;
  }
  if (cnt > 0) {
    if (cnt < 17) {
      buf[cnt] = 0;
      unsafe {
        driver_preamble_fputs(&buf[0], out);
      }
    }
  }
}

/** Close CPS switch after function body (seed async_cps_codegen_end).
 * Emits "    break;\\n  }\\n" and clears switch_open when open.
 * @param ctx AsyncCpsCodegenCtx* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure wave4; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_end(ctx: *u8, out: *u8): void {
  if (ctx == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  // switch_open @20
  if (async_cps_load_i32(ctx, 20) == 0) {
    return;
  }
  unsafe {
    driver_preamble_fputs("    break;\n", out);
    driver_preamble_fputs("  }\n", out);
  }
  async_cps_store_i32(ctx, 20, 0);
}

/** Emit phase reset before normal return (re-enter static frame).
 * Writes pad + "__xlang_frame.__phase = 0;\\n". Null pad defaults to two spaces.
 * @param out FILE* as *u8
 * @param pad optional indent cstr (may be null)
 * PLATFORM: SHARED — Cap residual pure wave4; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_emit_phase_reset(out: *u8, pad: *u8): void {
  if (out == 0) {
    return;
  }
  // Default indent matches seed: two spaces (lifetime covers whole function).
  let def: u8[3] = [32, 32, 0];
  let p: *u8 = pad;
  if (p == 0) {
    p = &def[0];
  }
  unsafe {
    driver_preamble_fputs(p, out);
    driver_preamble_fputs("__xlang_frame.__phase = 0;\n", out);
  }
}

/** Shared await-boundary emit (seed async_cps_codegen_after_await_impl).
 * Saves live locals into __xlang_frame, advances phase, emits suspend call + next case,
 * then restores live locals. Mutates ctx.phase_next (post-increment).
 * @param ctx AsyncCpsCodegenCtx* as *u8
 * @param out FILE* as *u8
 * @param pad indent cstr (null → two spaces)
 * @param suspend_fn C function name (e.g. xlang_async_cps_suspend)
 * @return 0 success, -1 bad args
 * PLATFORM: SHARED — host AsyncFrameLayout LE; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_after_await_impl(ctx: *u8, out: *u8, pad: *u8, suspend_fn: *u8): i32 {
  if (ctx == 0) {
    return -1;
  }
  if (out == 0) {
    return -1;
  }
  if (suspend_fn == 0) {
    return -1;
  }
  // layout @8; require non-null layout and func
  let layout: *u8 = async_cps_load_ptr(ctx, 8);
  if (layout == 0) {
    return -1;
  }
  if (async_cps_load_ptr(ctx, 0) == 0) {
    return -1;
  }
  // Default indent: two spaces (lifetime covers whole function).
  let def: u8[3] = [32, 32, 0];
  let p: *u8 = pad;
  if (p == 0) {
    p = &def[0];
  }
  // phase = phase_next++
  let phase: i32 = async_cps_load_i32(ctx, 16);
  async_cps_store_i32(ctx, 16, phase + 1);
  // live.n @4096; each name row is 64 bytes at layout + i*64
  let n: i32 = async_cps_load_i32(layout, 4096);
  if (n < 0) {
    n = 0;
  }
  if (n > 64) {
    n = 64;
  }
  let i: i32 = 0;
  while (i < n) {
    let v: *u8 = layout + (i * 64);
    i = i + 1;
    if (v == 0) {
      continue;
    }
    if (v[0] == 0) {
      continue;
    }
    // pad __xlang_frame.name = name;\n
    unsafe {
      driver_preamble_fputs(p, out);
      driver_preamble_fputs("__xlang_frame.", out);
      driver_preamble_fputs(v, out);
      driver_preamble_fputs(" = ", out);
      driver_preamble_fputs(v, out);
      driver_preamble_fputs(";\n", out);
    }
  }
  // pad __xlang_frame.__phase = PHASE;\n
  unsafe {
    driver_preamble_fputs(p, out);
    driver_preamble_fputs("__xlang_frame.__phase = ", out);
  }
  async_cps_fputs_i32_dec(out, phase);
  unsafe {
    driver_preamble_fputs(";\n", out);
  }
  // pad if (suspend_fn(&__xlang_frame.__phase, PHASE)) return (int32_t)XLANG_ASYNC_SUSPENDED;\n
  unsafe {
    driver_preamble_fputs(p, out);
    driver_preamble_fputs("if (", out);
    driver_preamble_fputs(suspend_fn, out);
    driver_preamble_fputs("(&__xlang_frame.__phase, ", out);
  }
  async_cps_fputs_i32_dec(out, phase);
  unsafe {
    driver_preamble_fputs(")) return (int32_t)XLANG_ASYNC_SUSPENDED;\n", out);
  }
  // pad /* XLANG_ASYNC_CPS fallthrough phase=PHASE */\n
  unsafe {
    driver_preamble_fputs(p, out);
    driver_preamble_fputs("/* XLANG_ASYNC_CPS fallthrough phase=", out);
  }
  async_cps_fputs_i32_dec(out, phase);
  unsafe {
    driver_preamble_fputs(" */\n", out);
  }
  // pad case PHASE:\n
  unsafe {
    driver_preamble_fputs(p, out);
    driver_preamble_fputs("case ", out);
  }
  async_cps_fputs_i32_dec(out, phase);
  unsafe {
    driver_preamble_fputs(":\n", out);
  }
  // restore live: pad name = __xlang_frame.name;\n
  let j: i32 = 0;
  while (j < n) {
    let v2: *u8 = layout + (j * 64);
    j = j + 1;
    if (v2 == 0) {
      continue;
    }
    if (v2[0] == 0) {
      continue;
    }
    unsafe {
      driver_preamble_fputs(p, out);
      driver_preamble_fputs(v2, out);
      driver_preamble_fputs(" = __xlang_frame.", out);
      driver_preamble_fputs(v2, out);
      driver_preamble_fputs(";\n", out);
    }
  }
  return 0;
}

/** Await boundary with normal suspend (xlang_async_cps_suspend).
 * @param ctx AsyncCpsCodegenCtx* as *u8
 * @param out FILE* as *u8
 * @param pad indent cstr
 * @return 0 / -1
 * PLATFORM: SHARED — Cap residual pure wave4; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_after_await(ctx: *u8, out: *u8, pad: *u8): i32 {
  8, 24, 120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 99, 112, 115, 95, 115, 117, 115, 112, 101, 110, 100, 0, 0, 0
}

/** Await boundary with IO suspend (xlang_async_cps_suspend_io).
 * @param ctx AsyncCpsCodegenCtx* as *u8
 * @param out FILE* as *u8
 * @param pad indent cstr
 * @return 0 / -1
 * PLATFORM: SHARED — Cap residual pure wave4; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_after_await_io(ctx: *u8, out: *u8, pad: *u8): i32 {
  8, 27, 120, 108, 97, 110, 103, 95, 97, 115, 121, 110, 99, 95, 99, 112, 115, 95, 115, 117, 115, 112, 101, 110, 100, 95, 105, 111, 0, 0, 0
}

/** Emit global scheduler wrapper xlang_async_sched_<name> calling xlang_async_run_i32.
 * Matches seed async_cps_codegen_emit_sched_wrapper fprintf sequence.
 * @param f ASTFunc* as *u8 (requires f->name)
 * @param c_fname C mangled coroutine entry name
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure wave4; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_emit_sched_wrapper(f: *u8, c_fname: *u8, out: *u8): void {
  if (f == 0) {
    return;
  }
  if (c_fname == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  let name: *u8 = async_cps_load_func_name(f);
  if (name == 0) {
    return;
  }
  if (name[0] == 0) {
    return;
  }
  unsafe {
    driver_preamble_fputs("/* A4: scheduler entry xlang_async_sched_", out);
    driver_preamble_fputs(name, out);
    driver_preamble_fputs(" */\n", out);
    driver_preamble_fputs("#ifndef XLANG_ASYNC_SCHED_RT_DECL\n", out);
    driver_preamble_fputs("#define XLANG_ASYNC_SCHED_RT_DECL\n", out);
    driver_preamble_fputs("extern int32_t xlang_async_run_i32(int32_t (*fn)(void));\n", out);
    driver_preamble_fputs("#endif\n", out);
    driver_preamble_fputs("int32_t xlang_async_sched_", out);
    driver_preamble_fputs(name, out);
    driver_preamble_fputs("(void) {\n", out);
    driver_preamble_fputs("  return xlang_async_run_i32((int32_t (*)(void))", out);
    driver_preamble_fputs(c_fname, out);
    driver_preamble_fputs(");\n", out);
    driver_preamble_fputs("}\n", out);
  }
}

// ---- Cap residual pure wave5: begin / param_statics / hoist_impl ----
// ASTFunc: params@32 num_params@40 body@56; ASTParam size24 name@0 type@8;
// ASTBlock: let_decls@16 num_lets@24; ASTLetDecl size48 name@0 type@8;
// ASTType kind@0; AsyncFrameLayout num_awaits@4100.
// G.7: type string authority = async_liveness_type_to_c_buf (no second table here).

/** Store little-endian pointer (usize) at p+off (null-safe).
 * Used to write AsyncCpsCodegenCtx.func / layout fields from pure .x.
 * PLATFORM: SHARED — LP64 host LE. */
#[no_mangle]
export function async_cps_store_ptr(p: *u8, off: i32, v: *u8): void {
  if (p == 0) {
    return;
  }
  if (off < 0) {
    return;
  }
  let a: usize = v as usize;
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  p[off] = (a % m) as u8;
  p[off + 1] = ((a / m) % m) as u8;
  p[off + 2] = ((a / m2) % m) as u8;
  p[off + 3] = ((a / (m2 * m)) % m) as u8;
  p[off + 4] = ((a / m4) % m) as u8;
  p[off + 5] = ((a / (m4 * m)) % m) as u8;
  p[off + 6] = ((a / (m4 * m2)) % m) as u8;
  p[off + 7] = ((a / (m4 * m2 * m)) % m) as u8;
}

/** Emit "  static <ctype> <name>;\\n" via fputs + type_to_c_buf.
 * Shared by param_statics and hoist_impl (G.7 single emit path).
 * @param out FILE* as *u8
 * @param ty ASTType* as *u8 (null-safe: type_to_c falls back)
 * @param name cstr variable name
 * PLATFORM: SHARED — Cap residual pure wave5. */
#[no_mangle]
export function async_cps_emit_static_decl(out: *u8, ty: *u8, name: *u8): void {
  if (out == 0) {
    return;
  }
  if (name == 0) {
    return;
  }
  if (name[0] == 0) {
    return;
  }
  // 96 bytes matches seed char cty[96].
  let cty: u8[96] = [];
  unsafe {
    async_liveness_type_to_c_buf(ty, &cty[0], 96);
  }
  unsafe {
    driver_preamble_fputs("  static ", out);
    driver_preamble_fputs(&cty[0], out);
    driver_preamble_fputs(" ", out);
    driver_preamble_fputs(name, out);
    driver_preamble_fputs(";\n", out);
  }
}

/** True when ASTType kind is a run-seed scalar (I32/U32/I64/USIZE).
 * Matches seed has_seed_param filter in async_cps_codegen_begin.
 * AST_TYPE_I32=0 U32=3 I64=5 USIZE=6.
 * PLATFORM: SHARED — Cap residual pure wave5. */
#[no_mangle]
export function async_cps_type_is_run_seed_scalar(ty: *u8): i32 {
  if (ty == 0) {
    return 0;
  }
  let kind: i32 = async_cps_load_i32(ty, 0);
  if (kind == 0) {
    return 1;
  }
  if (kind == 3) {
    return 1;
  }
  if (kind == 5) {
    return 1;
  }
  if (kind == 6) {
    return 1;
  }
  return 0;
}

/** Emit one run-seed take assignment for a param (case 0 inject).
 * Writes "      name = xlang_async_run_seed_take_<kind>();\\n" by type kind.
 * Only I32/U32/I64/USIZE; others are no-ops (seed same).
 * @param out FILE* as *u8
 * @param pname param name cstr
 * @param ty ASTType* as *u8
 * PLATFORM: SHARED — Cap residual pure wave5. */
#[no_mangle]
export function async_cps_emit_run_seed_take(out: *u8, pname: *u8, ty: *u8): void {
  if (out == 0) {
    return;
  }
  if (pname == 0) {
    return;
  }
  if (ty == 0) {
    return;
  }
  let kind: i32 = async_cps_load_i32(ty, 0);
  // U32
  if (kind == 3) {
    unsafe {
      driver_preamble_fputs("      ", out);
      driver_preamble_fputs(pname, out);
      driver_preamble_fputs(" = xlang_async_run_seed_take_u32();\n", out);
    }
    return;
  }
  // I64
  if (kind == 5) {
    unsafe {
      driver_preamble_fputs("      ", out);
      driver_preamble_fputs(pname, out);
      driver_preamble_fputs(" = xlang_async_run_seed_take_i64();\n", out);
    }
    return;
  }
  // USIZE
  if (kind == 6) {
    unsafe {
      driver_preamble_fputs("      ", out);
      driver_preamble_fputs(pname, out);
      driver_preamble_fputs(" = xlang_async_run_seed_take_usize();\n", out);
    }
    return;
  }
  // I32
  if (kind == 0) {
    unsafe {
      driver_preamble_fputs("      ", out);
      driver_preamble_fputs(pname, out);
      driver_preamble_fputs(" = xlang_async_run_seed_take_i32();\n", out);
    }
    return;
  }
}

/** CPS async params emit as static locals (run seed inject; not C param ABI).
 * Seed: async_cps_codegen_emit_param_statics.
 * @param f ASTFunc* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure wave5; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_emit_param_statics(f: *u8, out: *u8): void {
  if (f == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  let nparams: i32 = async_cps_load_i32(f, 40);
  let params: *u8 = async_cps_load_ptr(f, 32);
  if (params == 0) {
    return;
  }
  if (nparams < 0) {
    return;
  }
  let pi: i32 = 0;
  while (pi < nparams) {
    let pr: *u8 = params + (pi * 24);
    pi = pi + 1;
    let pname: *u8 = async_cps_load_ptr(pr, 0);
    let pty: *u8 = async_cps_load_ptr(pr, 8);
    if (pname == 0) {
      continue;
    }
    if (pname[0] == 0) {
      continue;
    }
    if (pty == 0) {
      continue;
    }
    async_cps_emit_static_decl(out, pty, pname);
  }
}

/** Hoist block used lets to statics before the CPS switch (A3 linear functions).
 * Seed: emit_hoisted_lets_impl. Public emit_hoisted_lets is a thin wrapper.
 * @param f ASTFunc* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure wave5; seed C under #ifndef FROM_X. */
#[no_mangle]
export function emit_hoisted_lets_impl(f: *u8, out: *u8): void {
  if (f == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  // body @56
  let body: *u8 = async_cps_load_ptr(f, 56);
  if (body == 0) {
    return;
  }
  // let_decls @16
  let lets: *u8 = async_cps_load_ptr(body, 16);
  if (lets == 0) {
    return;
  }
  let nlets: i32 = async_cps_load_i32(body, 24);
  if (nlets < 0) {
    return;
  }
  let i: i32 = 0;
  while (i < nlets) {
    let ld: *u8 = lets + (i * 48);
    i = i + 1;
    let name: *u8 = async_cps_load_ptr(ld, 0);
    if (name == 0) {
      continue;
    }
    if (name[0] == 0) {
      continue;
    }
    let ty: *u8 = async_cps_load_ptr(ld, 8);
    async_cps_emit_static_decl(out, ty, name);
  }
}

/** Open CPS switch for an async function (seed async_cps_codegen_begin).
 * Initializes ctx, hoists lets, optionally resets phase when run-seed is valid,
 * emits switch/default/case 0, injects seed takes for scalar params, marks switch_open.
 * @param ctx AsyncCpsCodegenCtx* as *u8
 * @param f ASTFunc* as *u8
 * @param layout AsyncFrameLayout* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure wave5; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_codegen_begin(ctx: *u8, f: *u8, layout: *u8, out: *u8): void {
  if (ctx == 0) {
    return;
  }
  if (f == 0) {
    return;
  }
  if (layout == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  // ctx.func@0 layout@8 phase_next@16=1 switch_open@20=0
  async_cps_store_ptr(ctx, 0, f);
  async_cps_store_ptr(ctx, 8, layout);
  async_cps_store_i32(ctx, 16, 1);
  async_cps_store_i32(ctx, 20, 0);
  emit_hoisted_lets(f, out);
  // Scan params for run-seed scalars (I32/U32/I64/USIZE).
  let nparams: i32 = async_cps_load_i32(f, 40);
  let params: *u8 = async_cps_load_ptr(f, 32);
  let has_seed_param: i32 = 0;
  if (params != 0) {
    let pi: i32 = 0;
    while (pi < nparams) {
      let pr: *u8 = params + (pi * 24);
      pi = pi + 1;
      let pname: *u8 = async_cps_load_ptr(pr, 0);
      let pty: *u8 = async_cps_load_ptr(pr, 8);
      if (pname == 0) {
        continue;
      }
      if (pty == 0) {
        continue;
      }
      if (async_cps_type_is_run_seed_scalar(pty) != 0) {
        has_seed_param = 1;
      }
    }
  }
  if (has_seed_param != 0) {
    unsafe {
      driver_preamble_fputs("  if (xlang_async_run_seed_valid())\n", out);
      driver_preamble_fputs("    __xlang_frame.__phase = 0;\n", out);
    }
  }
  // num_awaits @4100
  let num_awaits: i32 = async_cps_load_i32(layout, 4100);
  unsafe {
    driver_preamble_fputs("  /* XLANG_ASYNC_CPS switch=1 awaits=", out);
  }
  async_cps_fputs_i32_dec(out, num_awaits);
  unsafe {
    driver_preamble_fputs(" */\n", out);
    driver_preamble_fputs("  switch (__xlang_frame.__phase) {\n", out);
    driver_preamble_fputs("  default:\n", out);
    driver_preamble_fputs("  case 0:\n", out);
  }
  if (has_seed_param != 0) {
    unsafe {
      driver_preamble_fputs("    if (__xlang_frame.__phase == 0 && xlang_async_run_seed_valid()) {\n", out);
    }
    if (params != 0) {
      let pj: i32 = 0;
      while (pj < nparams) {
        let pr2: *u8 = params + (pj * 24);
        pj = pj + 1;
        let pname2: *u8 = async_cps_load_ptr(pr2, 0);
        let pty2: *u8 = async_cps_load_ptr(pr2, 8);
        if (pname2 == 0) {
          continue;
        }
        if (pty2 == 0) {
          continue;
        }
        async_cps_emit_run_seed_take(out, pname2, pty2);
      }
    }
    unsafe {
      driver_preamble_fputs("    }\n", out);
    }
  }
  async_cps_store_i32(ctx, 20, 1);
}
