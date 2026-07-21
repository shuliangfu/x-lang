// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// async_cps_codegen.x — pure surface for async CPS switch emit (A3).
// R2 pure surface + Cap residual pure wave1 + wave2:
//   - name gates (io / future_wait / sched wrapper)
//   - thin public wrappers for walk/hoist (call Cap residual _impl in seed C)
//   - await expr classifiers (expr_is_io_await / await_read|write|fd / future_wait)
//   - module/sched resolve + func_uses_void_entry (no FILE*; host LE loads)
// Cap residual (seed C always): FILE* emit begin/end/after_await/sched,
//   walk _impl (typed AST walk), emit_param_statics / emit_hoisted_lets_impl.
// ASTExpr host layout (PLATFORM: SHARED with async_liveness): kind@0; value@24;
//   unary.operand@24; CALL callee@24 args@32 num@40 resolved_fn@72;
//   METHOD base@24 name@32 args@40 num@48 impl@56; FIELD name@32; VAR name@24.
//   AST_EXPR_AWAIT=54 CALL=48 METHOD=49 FIELD=44 VAR=3.
// ASTFunc host layout: name@8 body@56 is_extern@64 is_async@68 (size 176).
// ASTModule host layout: funcs@152 num_funcs@160 (funcs is ASTFunc**).
// PLATFORM: SHARED — pure helper contract; prove surface IDENTICAL on mac + Ubuntu.
// Cold product path: cc seeds/async_cps_codegen.from_x.c (no FROM_X).
// Hybrid/PREFER (future): g05_try_x_to_o + rest (-DSHUX_ASYNC_CPS_CODEGEN_FROM_X).

// Cap residual C bodies (always linked from seed; thin wrappers call these).
export extern "C" function emit_hoisted_lets_impl(f: *u8, out: *u8): void;
export extern "C" function expr_references_run_async_impl(e: *u8, target: *u8): i32;
export extern "C" function block_has_run_async_ref_impl(b: *u8, target: *u8): i32;
// Cap residual liveness predicates (still seed C; used by pure module/sched helpers).
export extern "C" function async_liveness_func_needs_cps_frame(f: *u8): i32;
export extern "C" function async_liveness_func_has_await(f: *u8): i32;

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
 * Cap residual body lives in seed emit_hoisted_lets_impl (fprintf statics).
 * @param f ASTFunc* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — public short name matches seed cold path. */
#[no_mangle]
export function emit_hoisted_lets(f: *u8, out: *u8): void {
  unsafe {
    emit_hoisted_lets_impl(f, out);
  }
}

/** True when callee is an IO-A5 await target (std.io sync API / shux_io_* C entry).
 * Pure name table: shux_io_*, read, write, submit_*, read_fd, write_fd,
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
  // shux_io_
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
 * Cap residual body: seed expr_references_run_async_impl (typed AST walk).
 * ABI matches C: (expr, target). Do not drop the target parameter.
 * PLATFORM: SHARED */
#[no_mangle]
export function expr_references_run_async(e: *u8, target: *u8): i32 {
  unsafe {
    return expr_references_run_async_impl(e, target);
  }
  return 0;
}

/** Thin public wrapper: whether block references run/spawn of target async.
 * Cap residual body: seed block_has_run_async_ref_impl.
 * ABI matches C: (block, target).
 * PLATFORM: SHARED */
#[no_mangle]
export function block_has_run_async_ref(b: *u8, target: *u8): i32 {
  unsafe {
    return block_has_run_async_ref_impl(b, target);
  }
  return 0;
}

/** True when name is a Future wait entry (exact or substring).
 * Exact: future_wait, runtime_wait_future, shux_async_future_wait_c,
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
  // shux_async_future_wait_c
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

/** True when name is a scheduler wrapper `shux_async_sched_<async>`.
 * Prefix length 16: "shux_async_sched_".
 * PLATFORM: SHARED — pure string gate; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_cps_is_sched_wrapper_name(name: *u8): i32 {
  if (name == 0) {
    return 0;
  }
  // shux_async_sched_
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
 * Used for sched_name + 16 after "shux_async_sched_" prefix.
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

/** Resolve scheduler wrapper name `shux_async_sched_<async>` to the async ASTFunc*.
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
  // "shux_async_sched_" length 16
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

/** True when module has `extern "C" function shux_async_sched_<async_fn.name>`.
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
