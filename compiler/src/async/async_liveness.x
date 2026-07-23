// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// async_liveness.x — pure helpers for async cross-await liveness (A3).
// R2 pure surface + Cap residual pure:
//   - type/layout/has_await/needs_cps/analyze/module_struct
//   - FILE* emit_* via shared Cap residual driver_preamble_fputs (typedef/local/codegen_comment)
// Cap residual (seed C always, G.7 single authority): driver_preamble_fputs (opaque FILE*).
// PLATFORM: SHARED — pure helper contract; prove surface IDENTICAL on mac + Ubuntu.
//
// Heap for def-name table (analyze_block_linear): avoid u8[4096] stack on xlang -E.
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
// G.7 Cap residual: opaque *u8 stream → FILE* fputs. Authority = driver_preamble_fputs
// in runtime_driver_abi (always seed); no module-local async_liveness_fputs clone.
// Returns fputs-style status (negative on error/null). .x must not cast *u8 to FILE*.
export extern "C" function driver_preamble_fputs(s: *u8, stream: *u8): i32;

// async_liveness_x_doc_anchor: see function docblock below.

/** Exported function `async_liveness_x_doc_anchor`.
 * Implements `async_liveness_x_doc_anchor`.
 * @return i32
 */
export function async_liveness_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108 / G-02f-132 / G-02f-166：await/io/block/frame helpers

/* ---- G-02f-108 / G-02f-132 / G-02f-166：async_liveness helpers ---- */

// ASTExpr layout (host C): kind@0 i32; value@24 union; binop L@24 R@32; unary@24;
// if cond@24 then@32 else@40; call callee@24 args@32 num@40 resolved_fn@72;
// method base@24 args@40 num@48; struct inits@40 num@48; array elems@24 num@32;
// match matched@24 arms@32 num@40; MatchArm size 88 result@80;
// ASTBlock: let_decls@16 num_lets@24; expr_stmts@96 num@104; final@112.
// ASTLetDecl size 48: name@0 init@16. AST_EXPR_AWAIT=54 CALL=48.

// async_live_load_func_name: see function docblock below.
/** Exported function `async_live_load_func_name`.
 * Implements `async_live_load_func_name`.
 * @param callee *u8
 * @return *u8
 */
export function async_live_load_func_name(callee: *u8): *u8 {
  if (callee == 0) { return 0 as *u8; }
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

/** Exported function `async_liveness_callee_is_io_read`.
 * Read path helper `async_liveness_callee_is_io_read`.
 * @param f *u8
 * @return i32
 */
#[no_mangle]
export function async_liveness_callee_is_io_read(f: *u8): i32 {
  let name: *u8 = async_live_load_func_name(f);
  if (name == 0) { return 0; }
  // read
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==0) { return 1; }
  // read_fd
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==95
      && name[5]==102 && name[6]==100 && name[7]==0) {
    return 1;
  }
  return 0;
}

/** Exported function `async_liveness_callee_is_io_write`.
 * Write path helper `async_liveness_callee_is_io_write`.
 * @param f *u8
 * @return i32
 */
#[no_mangle]
export function async_liveness_callee_is_io_write(f: *u8): i32 {
  let name: *u8 = async_live_load_func_name(f);
  if (name == 0) { return 0; }
  // write
  if (name[0]==119 && name[1]==114 && name[2]==105 && name[3]==116 && name[4]==101 && name[5]==0) {
    return 1;
  }
  // write_fd
  if (name[0]==119 && name[1]==114 && name[2]==105 && name[3]==116 && name[4]==101 && name[5]==95
      && name[6]==102 && name[7]==100 && name[8]==0) {
    return 1;
  }
  return 0;
}

// ---- G-02f-166：AST LE load helpers ----
/** Exported function `async_live_load_i32`.
 * Implements `async_live_load_i32`.
 * @param p *u8
 * @param off i32
 * @return i32
 */
export function async_live_load_i32(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * m * m;
  a = a + (p[off + 3] as i32) * m * m * m;
  return a;
}

/** Exported function `async_live_load_ptr`.
 * Implements `async_live_load_ptr`.
 * @param p *u8
 * @param off i32
 * @return *u8
 */
export function async_live_load_ptr(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
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

/** Exported function `async_live_ptr_at`.
 * Implements `async_live_ptr_at`.
 * @param base *u8
 * @param i i32
 * @return *u8
 */
export function async_live_ptr_at(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  return async_live_load_ptr(base, i * 8);
}

/** Exported function `async_live_expr_kind`.
 * Implements `async_live_expr_kind`.
 * @param e *u8
 * @return i32
 */
export function async_live_expr_kind(e: *u8): i32 {
  return async_live_load_i32(e, 0);
}

/** Exported function `async_live_is_binop_kind`.
 * Implements `async_live_is_binop_kind`.
 * @param k i32
 * @return i32
 */
export function async_live_is_binop_kind(k: i32): i32 {
  if (k >= 4) {
    if (k <= 21) { return 1; }
  }
  if (k >= 28) {
    if (k <= 38) { return 1; }
  }
  return 0;
}

/** Exported function `async_live_is_unary_kind`.
 * Implements `async_live_is_unary_kind`.
 * @param k i32
 * @return i32
 */
export function async_live_is_unary_kind(k: i32): i32 {
  if (k == 22) { return 1; }
  if (k == 23) { return 1; }
  if (k == 24) { return 1; }
  if (k == 41) { return 1; }
  if (k == 42) { return 1; }
  if (k == 51) { return 1; }
  if (k == 52) { return 1; }
  return 0;
}

// forward decls via mutual recursion (define block_* after expr_*)

// expr_has_await: see function docblock below.
/** Exported function `expr_has_await`.
 * Implements `expr_has_await`.
 * @param e *u8
 * @return i32
 */
#[no_mangle]
export function expr_has_await(e: *u8): i32 {
  if (e == 0) { return 0; }
  let k: i32 = async_live_expr_kind(e);
  if (k == 54) { return 1; }
  if (async_live_is_binop_kind(k) != 0) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    return 0;
  }
  if (async_live_is_unary_kind(k) != 0) {
    return expr_has_await(async_live_load_ptr(e, 24));
  }
  if (k == 53) {
    return expr_has_await(async_live_load_ptr(e, 24));
  }
  if (k == 25) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el: *u8 = async_live_load_ptr(e, 40);
    if (el != 0) {
      if (expr_has_await(el) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 27) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el2: *u8 = async_live_load_ptr(e, 40);
    if (el2 != 0) {
      if (expr_has_await(el2) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 26) {
    return block_has_await(async_live_load_ptr(e, 24));
  }
  if (k == 44) {
    return expr_has_await(async_live_load_ptr(e, 24));
  }
  if (k == 47) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    return expr_has_await(async_live_load_ptr(e, 32));
  }
  if (k == 48) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args: *u8 = async_live_load_ptr(e, 32);
    let n: i32 = async_live_load_i32(e, 40);
    let i: i32 = 0;
    while (i < n) {
      if (expr_has_await(async_live_ptr_at(args, i)) != 0) { return 1; }
      i = i + 1;
    }
    return 0;
  }
  if (k == 49) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args2: *u8 = async_live_load_ptr(e, 40);
    let n2: i32 = async_live_load_i32(e, 48);
    let j: i32 = 0;
    while (j < n2) {
      if (expr_has_await(async_live_ptr_at(args2, j)) != 0) { return 1; }
      j = j + 1;
    }
    return 0;
  }
  if (k == 45) {
    let inits: *u8 = async_live_load_ptr(e, 40);
    let nf: i32 = async_live_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      if (expr_has_await(async_live_ptr_at(inits, fi)) != 0) { return 1; }
      fi = fi + 1;
    }
    return 0;
  }
  if (k == 46) {
    let elems: *u8 = async_live_load_ptr(e, 24);
    let ne: i32 = async_live_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      if (expr_has_await(async_live_ptr_at(elems, ei)) != 0) { return 1; }
      ei = ei + 1;
    }
    return 0;
  }
  if (k == 43) {
    if (expr_has_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let arms: *u8 = async_live_load_ptr(e, 32);
    let na: i32 = async_live_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) { return 0; }
      let arm: *u8 = arms + (ai * 88);
      if (expr_has_await(async_live_load_ptr(arm, 80)) != 0) { return 1; }
      ai = ai + 1;
    }
    return 0;
  }
  return 0;
}

// G-02f-166：expr_count_await
/** Exported function `expr_count_await`.
 * Implements `expr_count_await`.
 * @param e *u8
 * @return i32
 */
#[no_mangle]
export function expr_count_await(e: *u8): i32 {
  if (e == 0) { return 0; }
  let k: i32 = async_live_expr_kind(e);
  if (k == 54) {
    return 1 + expr_count_await(async_live_load_ptr(e, 24));
  }
  if (async_live_is_binop_kind(k) != 0) {
    return expr_count_await(async_live_load_ptr(e, 24)) + expr_count_await(async_live_load_ptr(e, 32));
  }
  if (async_live_is_unary_kind(k) != 0) {
    return expr_count_await(async_live_load_ptr(e, 24));
  }
  if (k == 53) {
    return expr_count_await(async_live_load_ptr(e, 24));
  }
  if (k == 25) {
    let n: i32 = expr_count_await(async_live_load_ptr(e, 24)) + expr_count_await(async_live_load_ptr(e, 32));
    let el: *u8 = async_live_load_ptr(e, 40);
    if (el != 0) { n = n + expr_count_await(el); }
    return n;
  }
  if (k == 27) {
    let n2: i32 = expr_count_await(async_live_load_ptr(e, 24)) + expr_count_await(async_live_load_ptr(e, 32));
    let el2: *u8 = async_live_load_ptr(e, 40);
    if (el2 != 0) { n2 = n2 + expr_count_await(el2); }
    return n2;
  }
  if (k == 26) {
    return block_count_await(async_live_load_ptr(e, 24));
  }
  if (k == 44) {
    return expr_count_await(async_live_load_ptr(e, 24));
  }
  if (k == 47) {
    return expr_count_await(async_live_load_ptr(e, 24)) + expr_count_await(async_live_load_ptr(e, 32));
  }
  if (k == 48) {
    let n3: i32 = expr_count_await(async_live_load_ptr(e, 24));
    let args: *u8 = async_live_load_ptr(e, 32);
    let nn: i32 = async_live_load_i32(e, 40);
    let i: i32 = 0;
    while (i < nn) {
      n3 = n3 + expr_count_await(async_live_ptr_at(args, i));
      i = i + 1;
    }
    return n3;
  }
  if (k == 49) {
    let n4: i32 = expr_count_await(async_live_load_ptr(e, 24));
    let args2: *u8 = async_live_load_ptr(e, 40);
    let nn2: i32 = async_live_load_i32(e, 48);
    let j: i32 = 0;
    while (j < nn2) {
      n4 = n4 + expr_count_await(async_live_ptr_at(args2, j));
      j = j + 1;
    }
    return n4;
  }
  if (k == 45) {
    let n5: i32 = 0;
    let inits: *u8 = async_live_load_ptr(e, 40);
    let nf: i32 = async_live_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      n5 = n5 + expr_count_await(async_live_ptr_at(inits, fi));
      fi = fi + 1;
    }
    return n5;
  }
  if (k == 46) {
    let n6: i32 = 0;
    let elems: *u8 = async_live_load_ptr(e, 24);
    let ne: i32 = async_live_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      n6 = n6 + expr_count_await(async_live_ptr_at(elems, ei));
      ei = ei + 1;
    }
    return n6;
  }
  if (k == 43) {
    let n7: i32 = expr_count_await(async_live_load_ptr(e, 24));
    let arms: *u8 = async_live_load_ptr(e, 32);
    let na: i32 = async_live_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) { return n7; }
      let arm: *u8 = arms + (ai * 88);
      n7 = n7 + expr_count_await(async_live_load_ptr(arm, 80));
      ai = ai + 1;
    }
    return n7;
  }
  return 0;
}

// G-02f-168：block_count_await / block_has_await
/** Exported function `block_count_await`.
 * Implements `block_count_await`.
 * @param b *u8
 * @return i32
 */
#[no_mangle]
export function block_count_await(b: *u8): i32 {
  if (b == 0) { return 0; }
  let n: i32 = 0;
  let nlets: i32 = async_live_load_i32(b, 24);
  let lets: *u8 = async_live_load_ptr(b, 16);
  let i: i32 = 0;
  while (i < nlets) {
    if (lets != 0) {
      let ld: *u8 = lets + (i * 48);
      let init: *u8 = async_live_load_ptr(ld, 16);
      if (init != 0) {
        n = n + expr_count_await(init);
      }
    }
    i = i + 1;
  }
  let nst: i32 = async_live_load_i32(b, 104);
  let stmts: *u8 = async_live_load_ptr(b, 96);
  let j: i32 = 0;
  while (j < nst) {
    n = n + expr_count_await(async_live_ptr_at(stmts, j));
    j = j + 1;
  }
  let fin: *u8 = async_live_load_ptr(b, 112);
  if (fin != 0) {
    n = n + expr_count_await(fin);
  }
  return n;
}

/** Exported function `block_has_await`.
 * Implements `block_has_await`.
 * @param b *u8
 * @return i32
 */
#[no_mangle]
export function block_has_await(b: *u8): i32 {
  if (block_count_await(b) > 0) { return 1; }
  return 0;
}

// G-02f-167：expr_has_io_read/write_await + block_has_io_*
/** Exported function `expr_has_io_read_await`.
 * Read path helper `expr_has_io_read_await`.
 * @param e *u8
 * @return i32
 */
#[no_mangle]
export function expr_has_io_read_await(e: *u8): i32 {
  if (e == 0) { return 0; }
  let k: i32 = async_live_expr_kind(e);
  if (k == 54) {
    let op: *u8 = async_live_load_ptr(e, 24);
    if (op != 0) {
      if (async_live_expr_kind(op) == 48) {
        let cal: *u8 = async_live_load_ptr(op, 72);
        if (cal != 0) {
          if (async_liveness_callee_is_io_read(cal) != 0) { return 1; }
        }
      }
    }
  }
  if (expr_has_await(e) == 0) { return 0; }
  if (k == 54) {
    return expr_has_io_read_await(async_live_load_ptr(e, 24));
  }
  if (async_live_is_binop_kind(k) != 0) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    return expr_has_io_read_await(async_live_load_ptr(e, 32));
  }
  if (async_live_is_unary_kind(k) != 0) {
    return expr_has_io_read_await(async_live_load_ptr(e, 24));
  }
  if (k == 53) { return expr_has_io_read_await(async_live_load_ptr(e, 24)); }
  if (k == 25) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_io_read_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el: *u8 = async_live_load_ptr(e, 40);
    if (el != 0) {
      if (expr_has_io_read_await(el) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 27) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_io_read_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el2: *u8 = async_live_load_ptr(e, 40);
    if (el2 != 0) {
      if (expr_has_io_read_await(el2) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 26) { return block_has_io_read_await(async_live_load_ptr(e, 24)); }
  if (k == 44) { return expr_has_io_read_await(async_live_load_ptr(e, 24)); }
  if (k == 47) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    return expr_has_io_read_await(async_live_load_ptr(e, 32));
  }
  if (k == 48) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args: *u8 = async_live_load_ptr(e, 32);
    let n: i32 = async_live_load_i32(e, 40);
    let i: i32 = 0;
    while (i < n) {
      if (expr_has_io_read_await(async_live_ptr_at(args, i)) != 0) { return 1; }
      i = i + 1;
    }
    return 0;
  }
  if (k == 49) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args2: *u8 = async_live_load_ptr(e, 40);
    let n2: i32 = async_live_load_i32(e, 48);
    let j: i32 = 0;
    while (j < n2) {
      if (expr_has_io_read_await(async_live_ptr_at(args2, j)) != 0) { return 1; }
      j = j + 1;
    }
    return 0;
  }
  if (k == 45) {
    let inits: *u8 = async_live_load_ptr(e, 40);
    let nf: i32 = async_live_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      if (expr_has_io_read_await(async_live_ptr_at(inits, fi)) != 0) { return 1; }
      fi = fi + 1;
    }
    return 0;
  }
  if (k == 46) {
    let elems: *u8 = async_live_load_ptr(e, 24);
    let ne: i32 = async_live_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      if (expr_has_io_read_await(async_live_ptr_at(elems, ei)) != 0) { return 1; }
      ei = ei + 1;
    }
    return 0;
  }
  if (k == 43) {
    if (expr_has_io_read_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let arms: *u8 = async_live_load_ptr(e, 32);
    let na: i32 = async_live_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) { return 0; }
      let arm: *u8 = arms + (ai * 88);
      if (expr_has_io_read_await(async_live_load_ptr(arm, 80)) != 0) { return 1; }
      ai = ai + 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `expr_has_io_write_await`.
 * Write path helper `expr_has_io_write_await`.
 * @param e *u8
 * @return i32
 */
#[no_mangle]
export function expr_has_io_write_await(e: *u8): i32 {
  if (e == 0) { return 0; }
  let k: i32 = async_live_expr_kind(e);
  if (k == 54) {
    let op: *u8 = async_live_load_ptr(e, 24);
    if (op != 0) {
      if (async_live_expr_kind(op) == 48) {
        let cal: *u8 = async_live_load_ptr(op, 72);
        if (cal != 0) {
          if (async_liveness_callee_is_io_write(cal) != 0) { return 1; }
        }
      }
    }
  }
  if (expr_has_await(e) == 0) { return 0; }
  if (k == 54) {
    return expr_has_io_write_await(async_live_load_ptr(e, 24));
  }
  if (async_live_is_binop_kind(k) != 0) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    return expr_has_io_write_await(async_live_load_ptr(e, 32));
  }
  if (async_live_is_unary_kind(k) != 0) {
    return expr_has_io_write_await(async_live_load_ptr(e, 24));
  }
  if (k == 53) { return expr_has_io_write_await(async_live_load_ptr(e, 24)); }
  if (k == 25) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_io_write_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el: *u8 = async_live_load_ptr(e, 40);
    if (el != 0) {
      if (expr_has_io_write_await(el) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 27) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    if (expr_has_io_write_await(async_live_load_ptr(e, 32)) != 0) { return 1; }
    let el2: *u8 = async_live_load_ptr(e, 40);
    if (el2 != 0) {
      if (expr_has_io_write_await(el2) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 26) { return block_has_io_write_await(async_live_load_ptr(e, 24)); }
  if (k == 44) { return expr_has_io_write_await(async_live_load_ptr(e, 24)); }
  if (k == 47) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    return expr_has_io_write_await(async_live_load_ptr(e, 32));
  }
  if (k == 48) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args: *u8 = async_live_load_ptr(e, 32);
    let n: i32 = async_live_load_i32(e, 40);
    let i: i32 = 0;
    while (i < n) {
      if (expr_has_io_write_await(async_live_ptr_at(args, i)) != 0) { return 1; }
      i = i + 1;
    }
    return 0;
  }
  if (k == 49) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let args2: *u8 = async_live_load_ptr(e, 40);
    let n2: i32 = async_live_load_i32(e, 48);
    let j: i32 = 0;
    while (j < n2) {
      if (expr_has_io_write_await(async_live_ptr_at(args2, j)) != 0) { return 1; }
      j = j + 1;
    }
    return 0;
  }
  if (k == 45) {
    let inits: *u8 = async_live_load_ptr(e, 40);
    let nf: i32 = async_live_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      if (expr_has_io_write_await(async_live_ptr_at(inits, fi)) != 0) { return 1; }
      fi = fi + 1;
    }
    return 0;
  }
  if (k == 46) {
    let elems: *u8 = async_live_load_ptr(e, 24);
    let ne: i32 = async_live_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      if (expr_has_io_write_await(async_live_ptr_at(elems, ei)) != 0) { return 1; }
      ei = ei + 1;
    }
    return 0;
  }
  if (k == 43) {
    if (expr_has_io_write_await(async_live_load_ptr(e, 24)) != 0) { return 1; }
    let arms: *u8 = async_live_load_ptr(e, 32);
    let na: i32 = async_live_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) { return 0; }
      let arm: *u8 = arms + (ai * 88);
      if (expr_has_io_write_await(async_live_load_ptr(arm, 80)) != 0) { return 1; }
      ai = ai + 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `block_has_io_read_await`.
 * Read path helper `block_has_io_read_await`.
 * @param b *u8
 * @return i32
 */
#[no_mangle]
export function block_has_io_read_await(b: *u8): i32 {
  if (b == 0) { return 0; }
  let nlets: i32 = async_live_load_i32(b, 24);
  let lets: *u8 = async_live_load_ptr(b, 16);
  let i: i32 = 0;
  while (i < nlets) {
    if (lets != 0) {
      let ld: *u8 = lets + (i * 48);
      let init: *u8 = async_live_load_ptr(ld, 16);
      if (init != 0) {
        if (expr_has_io_read_await(init) != 0) { return 1; }
      }
    }
    i = i + 1;
  }
  let nst: i32 = async_live_load_i32(b, 104);
  let stmts: *u8 = async_live_load_ptr(b, 96);
  let j: i32 = 0;
  while (j < nst) {
    if (expr_has_io_read_await(async_live_ptr_at(stmts, j)) != 0) { return 1; }
    j = j + 1;
  }
  let fin: *u8 = async_live_load_ptr(b, 112);
  if (fin != 0) {
    if (expr_has_io_read_await(fin) != 0) { return 1; }
  }
  return 0;
}

/** Exported function `block_has_io_write_await`.
 * Write path helper `block_has_io_write_await`.
 * @param b *u8
 * @return i32
 */
#[no_mangle]
export function block_has_io_write_await(b: *u8): i32 {
  if (b == 0) { return 0; }
  let nlets: i32 = async_live_load_i32(b, 24);
  let lets: *u8 = async_live_load_ptr(b, 16);
  let i: i32 = 0;
  while (i < nlets) {
    if (lets != 0) {
      let ld: *u8 = lets + (i * 48);
      let init: *u8 = async_live_load_ptr(ld, 16);
      if (init != 0) {
        if (expr_has_io_write_await(init) != 0) { return 1; }
      }
    }
    i = i + 1;
  }
  let nst: i32 = async_live_load_i32(b, 104);
  let stmts: *u8 = async_live_load_ptr(b, 96);
  let j: i32 = 0;
  while (j < nst) {
    if (expr_has_io_write_await(async_live_ptr_at(stmts, j)) != 0) { return 1; }
    j = j + 1;
  }
  let fin: *u8 = async_live_load_ptr(b, 112);
  if (fin != 0) {
    if (expr_has_io_write_await(fin) != 0) { return 1; }
  }
  return 0;
}

// ---- G-02f-169：cstr + expr_refs_var / block_refs_var ----
/** Exported function `async_live_cstr_eq`.
 * Implements `async_live_cstr_eq`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
export function async_live_cstr_eq(a: *u8, b: *u8): i32 {
  if (a == 0) { return 0; }
  if (b == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let ca: u8 = a[i];
    let cb: u8 = b[i];
    if (ca != cb) { return 0; }
    if (ca == 0) { return 1; }
    i = i + 1;
  }
  return 1;
}

/** Exported function `async_live_cstr_copy64`.
 * Implements `async_live_cstr_copy64`.
 * @param dst *u8
 * @param src *u8
 * @return void
 */
export function async_live_cstr_copy64(dst: *u8, src: *u8): void {
  if (dst == 0) { return; }
  if (src == 0) {
    dst[0] = 0;
    return;
  }
  let j: i32 = 0;
  while (j < 63) {
    let c: u8 = src[j];
    if (c == 0) { break; }
    dst[j] = c;
    j = j + 1;
  }
  dst[j] = 0;
}

/** Exported function `async_live_def_row`.
 * Implements `async_live_def_row`.
 * @param defs *u8
 * @param i i32
 * @return *u8
 */
export function async_live_def_row(defs: *u8, i: i32): *u8 {
  if (defs == 0) { return 0 as *u8; }
  let q: *u8 = defs;
  let off: i32 = i * 64;
  let k: i32 = 0;
  while (k < off) {
    q = q + 1;
    k = k + 1;
  }
  return q;
}

// async_live_load_def_name: see function docblock below.
/** Exported function `async_live_load_def_name`.
 * Implements `async_live_load_def_name`.
 * @param defs *u8
 * @param i i32
 * @return *u8
 */
export function async_live_load_def_name(defs: *u8, i: i32): *u8 {
  if (defs == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  return async_live_load_ptr(defs, off);
}

/** Exported function `expr_refs_var`.
 * Implements `expr_refs_var`.
 * @param e *u8
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function expr_refs_var(e: *u8, name: *u8): i32 {
  if (e == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  let k: i32 = async_live_expr_kind(e);
  // AST_EXPR_VAR = 3；value.var.name @24
  if (k == 3) {
    let vn: *u8 = async_live_load_ptr(e, 24);
    if (vn != 0) {
      if (async_live_cstr_eq(vn, name) != 0) { return 1; }
    }
    return 0;
  }
  if (async_live_is_binop_kind(k) != 0) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    return expr_refs_var(async_live_load_ptr(e, 32), name);
  }
  // unary + AWAIT(54)
  if (async_live_is_unary_kind(k) != 0) {
    return expr_refs_var(async_live_load_ptr(e, 24), name);
  }
  if (k == 54) {
    return expr_refs_var(async_live_load_ptr(e, 24), name);
  }
  if (k == 53) {
    return expr_refs_var(async_live_load_ptr(e, 24), name);
  }
  if (k == 25) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    if (expr_refs_var(async_live_load_ptr(e, 32), name) != 0) { return 1; }
    let el: *u8 = async_live_load_ptr(e, 40);
    if (el != 0) {
      if (expr_refs_var(el, name) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 27) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    if (expr_refs_var(async_live_load_ptr(e, 32), name) != 0) { return 1; }
    let el2: *u8 = async_live_load_ptr(e, 40);
    if (el2 != 0) {
      if (expr_refs_var(el2, name) != 0) { return 1; }
    }
    return 0;
  }
  if (k == 26) {
    return block_refs_var(async_live_load_ptr(e, 24), name);
  }
  if (k == 44) {
    return expr_refs_var(async_live_load_ptr(e, 24), name);
  }
  if (k == 47) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    return expr_refs_var(async_live_load_ptr(e, 32), name);
  }
  if (k == 48) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    let args: *u8 = async_live_load_ptr(e, 32);
    let n: i32 = async_live_load_i32(e, 40);
    let i: i32 = 0;
    while (i < n) {
      if (expr_refs_var(async_live_ptr_at(args, i), name) != 0) { return 1; }
      i = i + 1;
    }
    return 0;
  }
  if (k == 49) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    let args2: *u8 = async_live_load_ptr(e, 40);
    let n2: i32 = async_live_load_i32(e, 48);
    let j: i32 = 0;
    while (j < n2) {
      if (expr_refs_var(async_live_ptr_at(args2, j), name) != 0) { return 1; }
      j = j + 1;
    }
    return 0;
  }
  if (k == 45) {
    let inits: *u8 = async_live_load_ptr(e, 40);
    let nf: i32 = async_live_load_i32(e, 48);
    let fi: i32 = 0;
    while (fi < nf) {
      if (expr_refs_var(async_live_ptr_at(inits, fi), name) != 0) { return 1; }
      fi = fi + 1;
    }
    return 0;
  }
  if (k == 46) {
    let elems: *u8 = async_live_load_ptr(e, 24);
    let ne: i32 = async_live_load_i32(e, 32);
    let ei: i32 = 0;
    while (ei < ne) {
      if (expr_refs_var(async_live_ptr_at(elems, ei), name) != 0) { return 1; }
      ei = ei + 1;
    }
    return 0;
  }
  if (k == 43) {
    if (expr_refs_var(async_live_load_ptr(e, 24), name) != 0) { return 1; }
    let arms: *u8 = async_live_load_ptr(e, 32);
    let na: i32 = async_live_load_i32(e, 40);
    let ai: i32 = 0;
    while (ai < na) {
      if (arms == 0) { return 0; }
      let arm: *u8 = arms + (ai * 88);
      if (expr_refs_var(async_live_load_ptr(arm, 80), name) != 0) { return 1; }
      ai = ai + 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `block_refs_var`.
 * Implements `block_refs_var`.
 * @param b *u8
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function block_refs_var(b: *u8, name: *u8): i32 {
  if (b == 0) { return 0; }
  if (name == 0) { return 0; }
  let nlets: i32 = async_live_load_i32(b, 24);
  let lets: *u8 = async_live_load_ptr(b, 16);
  let i: i32 = 0;
  while (i < nlets) {
    if (lets != 0) {
      let ld: *u8 = lets + (i * 48);
      let init: *u8 = async_live_load_ptr(ld, 16);
      if (init != 0) {
        if (expr_refs_var(init, name) != 0) { return 1; }
      }
    }
    i = i + 1;
  }
  let nst: i32 = async_live_load_i32(b, 104);
  let stmts: *u8 = async_live_load_ptr(b, 96);
  let j: i32 = 0;
  while (j < nst) {
    if (expr_refs_var(async_live_ptr_at(stmts, j), name) != 0) { return 1; }
    j = j + 1;
  }
  let fin: *u8 = async_live_load_ptr(b, 112);
  if (fin != 0) {
    if (expr_refs_var(fin, name) != 0) { return 1; }
  }
  return 0;
}

// G-02f-170：block_rest_refs_var — stmt_order@172 entry size 8 kind@0 idx@4
/** Exported function `block_rest_refs_var`.
 * Implements `block_rest_refs_var`.
 * @param b *u8
 * @param from_exclusive i32
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function block_rest_refs_var(b: *u8, from_exclusive: i32, name: *u8): i32 {
  if (b == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  let norder: i32 = async_live_load_i32(b, 120);
  if (norder > 0) {
    let nlets: i32 = async_live_load_i32(b, 24);
    let lets: *u8 = async_live_load_ptr(b, 16);
    let nst: i32 = async_live_load_i32(b, 104);
    let stmts: *u8 = async_live_load_ptr(b, 96);
    let si: i32 = from_exclusive + 1;
    while (si < norder) {
      let base: i32 = 172 + si * 8;
      let sk: i32 = b[base] as i32;
      let idx: i32 = async_live_load_i32(b, base + 4);
      if (sk == 1) {
        if (lets != 0) {
          if (idx >= 0) {
            if (idx < nlets) {
              let ld: *u8 = lets + (idx * 48);
              let init: *u8 = async_live_load_ptr(ld, 16);
              if (init != 0) {
                if (expr_refs_var(init, name) != 0) { return 1; }
              }
            }
          }
        }
      } else {
        if (sk == 2) {
          if (stmts != 0) {
            if (idx >= 0) {
              if (idx < nst) {
                if (expr_refs_var(async_live_ptr_at(stmts, idx), name) != 0) { return 1; }
              }
            }
          }
        }
      }
      si = si + 1;
    }
    let fin: *u8 = async_live_load_ptr(b, 112);
    if (fin != 0) {
      if (expr_refs_var(fin, name) != 0) { return 1; }
    }
    return 0;
  }
  let fin2: *u8 = async_live_load_ptr(b, 112);
  if (fin2 != 0) {
    if (expr_refs_var(fin2, name) != 0) { return 1; }
  }
  return 0;
}

// G-02f-162：AsyncFrameLive — names[64][64] @0，n:i32 @4096
/** Exported function `frame_live_load_n`.
 * Implements `frame_live_load_n`.
 * @param out *u8
 * @return i32
 */
export function frame_live_load_n(out: *u8): i32 {
  if (out == 0) { return 0; }
  let q: *u8 = out;
  let i: i32 = 0;
  while (i < 4096) {
    q = q + 1;
    i = i + 1;
  }
  let m: i32 = 256;
  let a: i32 = q[0] as i32;
  a = a + (q[1] as i32) * m;
  a = a + (q[2] as i32) * m * m;
  a = a + (q[3] as i32) * m * m * m;
  return a;
}

/** Exported function `frame_live_store_n`.
 * Implements `frame_live_store_n`.
 * @param out *u8
 * @param n i32
 * @return void
 */
export function frame_live_store_n(out: *u8, n: i32): void {
  if (out == 0) { return; }
  let q: *u8 = out;
  let i: i32 = 0;
  while (i < 4096) {
    q = q + 1;
    i = i + 1;
  }
  let a: i32 = n;
  let m: i32 = 256;
  if (a < 0) { a = 0; }
  q[0] = (a % m) as u8;
  a = a / m;
  q[1] = (a % m) as u8;
  a = a / m;
  q[2] = (a % m) as u8;
  a = a / m;
  q[3] = (a % m) as u8;
}

/** Exported function `frame_live_row_ptr`.
 * Implements `frame_live_row_ptr`.
 * @param out *u8
 * @param idx i32
 * @return *u8
 */
export function frame_live_row_ptr(out: *u8, idx: i32): *u8 {
  if (out == 0) { return 0 as *u8; }
  let q: *u8 = out;
  let off: i32 = idx * 64;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  return q;
}

/** Exported function `frame_live_name_eq`.
 * Implements `frame_live_name_eq`.
 * @param row *u8
 * @param name *u8
 * @return i32
 */
export function frame_live_name_eq(row: *u8, name: *u8): i32 {
  if (row == 0) { return 0; }
  if (name == 0) { return 0; }
  let i: i32 = 0;
  while (i < 64) {
    let a: u8 = row[i];
    let b: u8 = name[i];
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    i = i + 1;
  }
  return 1;
}

// frame_live_add: see function docblock below.
/** Exported function `frame_live_add`.
 * Implements `frame_live_add`.
 * @param out *u8
 * @param name *u8
 * @return void
 */
#[no_mangle]
export function frame_live_add(out: *u8, name: *u8): void {
  if (out == 0) { return; }
  if (name == 0) { return; }
  if (name[0] == 0) { return; }
  let n: i32 = frame_live_load_n(out);
  if (n < 0) { n = 0; }
  if (n > 64) { n = 64; }
  let i: i32 = 0;
  while (i < n) {
    let row: *u8 = frame_live_row_ptr(out, i);
    if (frame_live_name_eq(row, name) != 0) { return; }
    i = i + 1;
  }
  if (n >= 64) { return; }
  let dst: *u8 = frame_live_row_ptr(out, n);
  if (dst == 0) { return; }
  let j: i32 = 0;
  while (j < 63) {
    let c: u8 = name[j];
    if (c == 0) { break; }
    dst[j] = c;
    j = j + 1;
  }
  dst[j] = 0;
  frame_live_store_n(out, n + 1);
}

/* See implementation. */

// frame_live_at_await: see function docblock below.
/** Exported function `frame_live_at_await`.
 * Implements `frame_live_at_await`.
 * @param b *u8
 * @param idx i32
 * @param defs *u8
 * @param nd i32
 * @param out *u8
 * @return void
 */
#[no_mangle]
export function frame_live_at_await(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void {
  if (nd <= 0) { return; }
  if (defs == 0) { return; }
  if (out == 0) { return; }
  let i: i32 = 0;
  while (i < nd) {
    let name: *u8 = async_live_load_def_name(defs, i);
    if (name != 0) {
      if (block_rest_refs_var(b, idx, name) != 0) {
        frame_live_add(out, name);
      }
    }
    i = i + 1;
  }
}

// async_live_analyze_at_await: see function docblock below.
/** Exported function `async_live_analyze_at_await`.
 * Implements `async_live_analyze_at_await`.
 * @param b *u8
 * @param si i32
 * @param defs *u8
 * @param n_def i32
 * @param frame *u8
 * @return void
 */
export function async_live_analyze_at_await(b: *u8, si: i32, defs: *u8, n_def: i32, frame: *u8): void {
  if (n_def <= 0) { return; }
  if (defs == 0) { return; }
  if (frame == 0) { return; }
  let i: i32 = 0;
  while (i < n_def) {
    let name: *u8 = async_live_def_row(defs, i);
    if (name != 0) {
      if (name[0] != 0) {
        if (block_rest_refs_var(b, si, name) != 0) {
          frame_live_add(frame, name);
        }
      }
    }
    i = i + 1;
  }
}

/** Linear liveness scan over stmt_order: at each await, add defs still referenced after.
 * prefix is a char** view (64-byte name rows via async_live_load_def_name).
 * Stack discipline: heap-allocate the 64×64 def-name table (malloc 4096) — a
 * `u8[4096]` local flaked Ubuntu `xlang -E` (SIGSEGV), same class as async_asm_pool.
 * PLATFORM: SHARED — pure liveness walk; Cap residual layout/emit stay in seed C.
 * @param b AST block (opaque)
 * @param prefix param-name table (opaque rows)
 * @param n_prefix number of prefix names
 * @param frame AsyncFrameLive out (opaque)
 */
#[no_mangle]
export function analyze_block_linear(b: *u8, prefix: *u8, n_prefix: i32, frame: *u8): void {
  if (b == 0) { return; }
  if (frame == 0) { return; }
  // 64 names × 64 bytes; heap avoids large stack frame on xlang -E (Ubuntu gold).
  let def_names: *u8 = 0 as *u8;
  unsafe { def_names = malloc(4096 as usize); }
  if (def_names == 0) { return; }
  let n_def: i32 = 0;
  let pi: i32 = 0;
  while (pi < n_prefix) {
    if (n_def >= 64) { break; }
    let pn: *u8 = async_live_load_def_name(prefix, pi);
    if (pn != 0) {
      if (pn[0] != 0) {
        async_live_cstr_copy64(async_live_def_row(def_names, n_def), pn);
        n_def = n_def + 1;
      }
    }
    pi = pi + 1;
  }
  let norder: i32 = async_live_load_i32(b, 120);
  if (norder > 0) {
    let nlets: i32 = async_live_load_i32(b, 24);
    let lets: *u8 = async_live_load_ptr(b, 16);
    let nst: i32 = async_live_load_i32(b, 104);
    let stmts: *u8 = async_live_load_ptr(b, 96);
    let si: i32 = 0;
    while (si < norder) {
      let base: i32 = 172 + si * 8;
      let sk: i32 = b[base] as i32;
      let idx: i32 = async_live_load_i32(b, base + 4);
      if (sk == 1) {
        if (lets != 0) {
          if (idx >= 0) {
            if (idx < nlets) {
              let ld: *u8 = lets + (idx * 48);
              let init: *u8 = async_live_load_ptr(ld, 16);
              if (init != 0) {
                if (expr_has_await(init) != 0) {
                  async_live_analyze_at_await(b, si, def_names, n_def, frame);
                }
              }
              if (n_def < 64) {
                let lname: *u8 = async_live_load_ptr(ld, 0);
                if (lname != 0) {
                  if (lname[0] != 0) {
                    async_live_cstr_copy64(async_live_def_row(def_names, n_def), lname);
                    n_def = n_def + 1;
                  }
                }
              }
            }
          }
        }
      } else {
        if (sk == 2) {
          if (stmts != 0) {
            if (idx >= 0) {
              if (idx < nst) {
                let ex: *u8 = async_live_ptr_at(stmts, idx);
                if (ex != 0) {
                  if (expr_has_await(ex) != 0) {
                    async_live_analyze_at_await(b, si, def_names, n_def, frame);
                  }
                }
              }
            }
          }
        }
      }
      si = si + 1;
    }
    let fin: *u8 = async_live_load_ptr(b, 112);
    if (fin != 0) {
      if (expr_has_await(fin) != 0) {
        async_live_analyze_at_await(b, norder - 1, def_names, n_def, frame);
      }
    }
    unsafe { free(def_names); }
    return;
  }
  let fin2: *u8 = async_live_load_ptr(b, 112);
  if (fin2 != 0) {
    if (expr_has_await(fin2) != 0) {
      async_live_analyze_at_await(b, 0 - 1, def_names, n_def, frame);
    }
  }
  unsafe { free(def_names); }
}


// frame_mangle_ident: see function docblock below.
/** Exported function `frame_mangle_ident`.
 * Implements `frame_mangle_ident`.
 * @param in_name *u8
 * @param out *u8
 * @param cap i32
 * @return void
 */
#[no_mangle]
export function frame_mangle_ident(in_name: *u8, out: *u8, cap: i32): void {
  if (out == 0) { return; }
  if (cap <= 0) { return; }
  if (in_name == 0) {
    if (cap > 2) {
      out[0] = 102;
      out[1] = 110;
      out[2] = 0;
    } else {
      out[0] = 0;
    }
    return;
  }
  if (in_name[0] == 0) {
    if (cap > 2) {
      out[0] = 102;
      out[1] = 110;
      out[2] = 0;
    } else {
      out[0] = 0;
    }
    return;
  }
  let j: i32 = 0;
  let i: i32 = 0;
  while (i < 4096) {
    if (in_name[i] == 0) { break; }
    if (j + 1 >= cap) { break; }
    let c: u8 = in_name[i];
    let ok: i32 = 0;
    if (c >= 97) {
      if (c <= 122) { ok = 1; }
    }
    if (c >= 65) {
      if (c <= 90) { ok = 1; }
    }
    if (c >= 48) {
      if (c <= 57) { ok = 1; }
    }
    if (c == 95) { ok = 1; }
    if (ok != 0) {
      out[j] = c;
    } else {
      out[j] = 95;
    }
    j = j + 1;
    i = i + 1;
  }
  out[j] = 0;
}

// frame_build_tag: see function docblock below.
/** Exported function `frame_build_tag`.
 * Implements `frame_build_tag`.
 * @param f *u8
 * @param out *u8
 * @param cap i32
 * @return void
 */
#[no_mangle]
export function frame_build_tag(f: *u8, out: *u8, cap: i32): void {
  if (out == 0) { return; }
  if (cap <= 1) { return; }
  let name: *u8 = 0 as *u8;
  if (f != 0) {
    name = async_live_load_func_name(f);
  }
  if (name == 0) {
    name = "fn";
  } else {
    if (name[0] == 0) { name = "fn"; }
  }
  let m: u8[64] = [];
  frame_mangle_ident(name, &m[0], 64);
  let pref: *u8 = "__xlang_async_frame_";
  let j: i32 = 0;
  let i: i32 = 0;
  while (j + 1 < cap) {
    if (pref[i] == 0) { break; }
    out[j] = pref[i];
    j = j + 1;
    i = i + 1;
  }
  i = 0;
  while (j + 1 < cap) {
    if (m[i] == 0) { break; }
    out[j] = m[i];
    j = j + 1;
    i = i + 1;
  }
  out[j] = 0;
}

// live_name_cmp: see function docblock below.

/** Exported function `live_name_cmp`.
 * Comparison/utility `live_name_cmp`.
 * @param a *u8
 * @param b *u8
 * @return i32
 */
#[no_mangle]
export function live_name_cmp(a: *u8, b: *u8): i32 {
  if (a == 0) {
    if (b == 0) { return 0; }
    return 0 - 1;
  }
  if (b == 0) { return 1; }
  let i: i32 = 0;
  while (i < 4096) {
    let ca: u8 = a[i];
    let cb: u8 = b[i];
    if (ca != cb) {
      return (ca as i32) - (cb as i32);
    }
    if (ca == 0) { return 0; }
    i = i + 1;
  }
  return 0;
}

// ---- Cap residual pure: type / layout / has_await / needs_cps / analyze / module_struct ----
// Host LE layout (LP64; mac arm64 + Ubuntu x86_64 identical for these fields):
//   ASTType: kind@0 name@8 elem_type@16
//   ASTParam size24: name@0 type@8; ASTLetDecl size48: name@0 type@8
//   ASTFunc: name@8 params@32 num_params@40 body@56 is_async@68
//   ASTBlock: let_decls@16 num_lets@24
//   ASTModule: struct_defs@88 num_structs@96 impl@136 num_impl@144 funcs@152 num_funcs@160
//   ASTStructDef: name@0 struct_size@568; ASTImplBlock: funcs@24 num_funcs@32
//   AsyncFrameLive: names[64][64]@0 n@4096; AsyncFrameLayout size 4196:
//     live@0 num_awaits@4100 frame_bytes@4104 frame_tag@4108 has_io_rd@4188 has_io_wr@4192
// AST_TYPE_*: I32=0 BOOL=1 U8=2 U32=3 U64=4 I64=5 USIZE=6 ISIZE=7 NAMED=8 PTR=9 F32=15 F64=16
// PLATFORM: SHARED — Cap residual pure; FILE* emit via opaque fputs bridge.

/** Store little-endian i32 at p+off (null-safe).
 * PLATFORM: SHARED — host LE; used for AsyncFrameLayout field writes. */
export function async_live_store_i32(p: *u8, off: i32, v: i32): void {
  if (p == 0) { return; }
  if (off < 0) { return; }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}

/** Store little-endian pointer (usize) at p+off.
 * PLATFORM: SHARED — LP64 host. */
export function async_live_store_ptr(p: *u8, off: i32, v: *u8): void {
  if (p == 0) { return; }
  if (off < 0) { return; }
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

/** Copy NUL-terminated src into dst (cap bytes, always NUL-terminate if cap>0).
 * PLATFORM: SHARED — replaces strncpy for type_to_c_buf. */
export function async_live_cstr_copy_cap(dst: *u8, src: *u8, cap: i32): void {
  if (dst == 0) { return; }
  if (cap <= 0) { return; }
  if (src == 0) {
    dst[0] = 0;
    return;
  }
  let i: i32 = 0;
  while (i + 1 < cap) {
    let c: u8 = src[i];
    if (c == 0) { break; }
    dst[i] = c;
    i = i + 1;
  }
  dst[i] = 0;
}

/** True when a equals prefix of length plen and a[plen] may continue (prefix match).
 * Used for "struct " check on NAMED type names. */
export function async_live_cstr_has_prefix(a: *u8, pref: *u8, plen: i32): i32 {
  if (a == 0) { return 0; }
  if (pref == 0) { return 0; }
  if (plen <= 0) { return 1; }
  let i: i32 = 0;
  while (i < plen) {
    if (a[i] != pref[i]) { return 0; }
    if (a[i] == 0) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Sort AsyncFrameLive.names[0..n) lexicographically (insertion sort, 64-byte rows).
 * Avoids qsort function-pointer ABI from .x.
 * PLATFORM: SHARED — same order as seed qsort+live_name_cmp. */
#[no_mangle]
export function async_live_sort_frame_names(out: *u8): void {
  if (out == 0) { return; }
  let n: i32 = frame_live_load_n(out);
  if (n <= 1) { return; }
  let i: i32 = 1;
  while (i < n) {
    let key: u8[64] = [];
    let src: *u8 = frame_live_row_ptr(out, i);
    let k: i32 = 0;
    while (k < 64) {
      key[k] = src[k];
      k = k + 1;
    }
    let j: i32 = i - 1;
    while (j >= 0) {
      let row: *u8 = frame_live_row_ptr(out, j);
      if (live_name_cmp(row, &key[0]) <= 0) { break; }
      let dst: *u8 = frame_live_row_ptr(out, j + 1);
      let t: i32 = 0;
      while (t < 64) {
        dst[t] = row[t];
        t = t + 1;
      }
      j = j - 1;
    }
    let dest: *u8 = frame_live_row_ptr(out, j + 1);
    k = 0;
    while (k < 64) {
      dest[k] = key[k];
      k = k + 1;
    }
    i = i + 1;
  }
}

/** Look up variable type in f params then body let_decls (name match).
 * Returns ASTType* as *u8, or null.
 * PLATFORM: SHARED — Cap residual pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_liveness_lookup_var_type(f: *u8, name: *u8): *u8 {
  if (f == 0) { return 0 as *u8; }
  if (name == 0) { return 0 as *u8; }
  if (name[0] == 0) { return 0 as *u8; }
  let nparams: i32 = async_live_load_i32(f, 40);
  let params: *u8 = async_live_load_ptr(f, 32);
  if (params != 0) {
    let i: i32 = 0;
    while (i < nparams) {
      let pr: *u8 = params + (i * 24);
      let pn: *u8 = async_live_load_ptr(pr, 0);
      if (pn != 0) {
        if (async_live_cstr_eq(pn, name) != 0) {
          return async_live_load_ptr(pr, 8);
        }
      }
      i = i + 1;
    }
  }
  let body: *u8 = async_live_load_ptr(f, 56);
  if (body != 0) {
    let lets: *u8 = async_live_load_ptr(body, 16);
    let nlets: i32 = async_live_load_i32(body, 24);
    if (lets != 0) {
      let i: i32 = 0;
      while (i < nlets) {
        let ld: *u8 = lets + (i * 48);
        let ln: *u8 = async_live_load_ptr(ld, 0);
        if (ln != 0) {
          if (async_live_cstr_eq(ln, name) != 0) {
            return async_live_load_ptr(ld, 8);
          }
        }
        i = i + 1;
      }
    }
  }
  return 0 as *u8;
}

/** AST type → C type string into buf (cap bytes). Covers A3 scalars/ptr/named.
 * Null ty → "int32_t". PTR recurses on elem_type.
 * PLATFORM: SHARED — Cap residual pure; no FILE*. */
#[no_mangle]
export function async_liveness_type_to_c_buf(ty: *u8, buf: *u8, cap: i32): void {
  if (buf == 0) { return; }
  if (cap <= 0) { return; }
  if (ty == 0) {
    async_live_cstr_copy_cap(buf, "int32_t", cap);
    return;
  }
  let kind: i32 = async_live_load_i32(ty, 0);
  // AST_TYPE_I32=0 BOOL=1 U8=2 U32=3 U64=4 I64=5 USIZE=6 ISIZE=7 NAMED=8 PTR=9 F32=15 F64=16
  if (kind == 0) {
    async_live_cstr_copy_cap(buf, "int32_t", cap);
    return;
  }
  if (kind == 1) {
    async_live_cstr_copy_cap(buf, "int32_t", cap);
    return;
  }
  if (kind == 2) {
    async_live_cstr_copy_cap(buf, "uint8_t", cap);
    return;
  }
  if (kind == 3) {
    async_live_cstr_copy_cap(buf, "uint32_t", cap);
    return;
  }
  if (kind == 4) {
    async_live_cstr_copy_cap(buf, "uint64_t", cap);
    return;
  }
  if (kind == 5) {
    async_live_cstr_copy_cap(buf, "int64_t", cap);
    return;
  }
  if (kind == 6) {
    async_live_cstr_copy_cap(buf, "uintptr_t", cap);
    return;
  }
  if (kind == 7) {
    async_live_cstr_copy_cap(buf, "intptr_t", cap);
    return;
  }
  if (kind == 15) {
    async_live_cstr_copy_cap(buf, "float", cap);
    return;
  }
  if (kind == 16) {
    async_live_cstr_copy_cap(buf, "double", cap);
    return;
  }
  if (kind == 9) {
    let elem: *u8 = async_live_load_ptr(ty, 16);
    if (elem != 0) {
      let inner: u8[64] = [];
      async_liveness_type_to_c_buf(elem, &inner[0], 64);
      // "%s *"
      let j: i32 = 0;
      while (j + 1 < cap) {
        if (inner[j] == 0) { break; }
        buf[j] = inner[j];
        j = j + 1;
      }
      if (j + 1 < cap) {
        buf[j] = 32; // space
        j = j + 1;
      }
      if (j + 1 < cap) {
        buf[j] = 42; // *
        j = j + 1;
      }
      buf[j] = 0;
    } else {
      async_live_cstr_copy_cap(buf, "void *", cap);
    }
    return;
  }
  if (kind == 8) {
    let nm: *u8 = async_live_load_ptr(ty, 8);
    if (nm != 0) {
      // if name already starts with "struct " copy as-is; else "struct %s"
      if (async_live_cstr_has_prefix(nm, "struct ", 7) != 0) {
        async_live_cstr_copy_cap(buf, nm, cap);
      } else {
        let pref: *u8 = "struct ";
        let j: i32 = 0;
        let i: i32 = 0;
        while (j + 1 < cap) {
          if (pref[i] == 0) { break; }
          buf[j] = pref[i];
          j = j + 1;
          i = i + 1;
        }
        i = 0;
        while (j + 1 < cap) {
          if (nm[i] == 0) { break; }
          buf[j] = nm[i];
          j = j + 1;
          i = i + 1;
        }
        buf[j] = 0;
      }
    } else {
      async_live_cstr_copy_cap(buf, "int32_t", cap);
    }
    return;
  }
  async_live_cstr_copy_cap(buf, "int32_t", cap);
}

/** Estimate type size in bytes; NAMED struct uses module struct_size when set.
 * PLATFORM: SHARED — Cap residual pure. */
#[no_mangle]
export function async_liveness_type_size_bytes_module(ty: *u8, m: *u8): i32 {
  if (ty == 0) { return 4; }
  let kind: i32 = async_live_load_i32(ty, 0);
  if (kind == 8) {
    let nm: *u8 = async_live_load_ptr(ty, 8);
    if (nm != 0) {
      if (m != 0) {
        let sdefs: *u8 = async_live_load_ptr(m, 88);
        let ns: i32 = async_live_load_i32(m, 96);
        if (sdefs != 0) {
          let i: i32 = 0;
          while (i < ns) {
            let sd: *u8 = async_live_load_ptr(sdefs, i * 8);
            if (sd != 0) {
              let sn: *u8 = async_live_load_ptr(sd, 0);
              if (sn != 0) {
                if (async_live_cstr_eq(sn, nm) != 0) {
                  let sz: i32 = async_live_load_i32(sd, 568);
                  if (sz > 0) { return sz; }
                }
              }
            }
            i = i + 1;
          }
        }
      }
    }
    return 8;
  }
  // I64 U64 F64 USIZE ISIZE PTR → 8
  if (kind == 5) { return 8; }
  if (kind == 4) { return 8; }
  if (kind == 16) { return 8; }
  if (kind == 6) { return 8; }
  if (kind == 7) { return 8; }
  if (kind == 9) { return 8; }
  return 4;
}

/** True when async f has await in body.
 * PLATFORM: SHARED — Cap residual pure. */
#[no_mangle]
export function async_liveness_func_has_await(f: *u8): i32 {
  if (f == 0) { return 0; }
  if (async_live_load_i32(f, 68) == 0) { return 0; }
  let body: *u8 = async_live_load_ptr(f, 56);
  if (body == 0) { return 0; }
  return block_has_await(body);
}

/** Thin wrapper: expr_has_await for public API name.
 * PLATFORM: SHARED — Cap residual pure. */
#[no_mangle]
export function async_liveness_expr_has_await(e: *u8): i32 {
  return expr_has_await(e);
}

/** Layout async frame into out (AsyncFrameLayout*, size 4196).
 * Builds param-name char** prefix for analyze_block_linear; sorts live names;
 * fills await count, IO slots, frame_tag, frame_bytes.
 * PLATFORM: SHARED — Cap residual pure; heap prefix table (no large stack). */
#[no_mangle]
export function async_liveness_layout_func_module(f: *u8, m: *u8, out: *u8): i32 {
  if (out == 0) { return 0 - 1; }
  // memset out 4196 bytes
  unsafe { memset(out, 0, 4196 as usize); }
  if (f == 0) { return 0; }
  if (async_live_load_i32(f, 68) == 0) { return 0; }
  let body: *u8 = async_live_load_ptr(f, 56);
  if (body == 0) { return 0; }
  if (block_has_await(body) == 0) { return 0; }

  // char** prefix: 64 slots × 8
  let prefix: *u8 = 0 as *u8;
  unsafe { prefix = malloc(512 as usize); }
  if (prefix == 0) { return 0 - 1; }
  unsafe { memset(prefix, 0, 512 as usize); }
  let n_pre: i32 = 0;
  let nparams: i32 = async_live_load_i32(f, 40);
  let params: *u8 = async_live_load_ptr(f, 32);
  if (params != 0) {
    let i: i32 = 0;
    while (i < nparams) {
      if (n_pre >= 64) { break; }
      let pr: *u8 = params + (i * 24);
      let pn: *u8 = async_live_load_ptr(pr, 0);
      if (pn != 0) {
        async_live_store_ptr(prefix, n_pre * 8, pn);
        n_pre = n_pre + 1;
      }
      i = i + 1;
    }
  }

  // out->live is at offset 0
  analyze_block_linear(body, prefix, n_pre, out);
  unsafe { free(prefix); }

  let ln: i32 = frame_live_load_n(out);
  if (ln > 1) {
    async_live_sort_frame_names(out);
  }

  let na: i32 = block_count_await(body);
  async_live_store_i32(out, 4100, na);
  let ird: i32 = block_has_io_read_await(body);
  let iwr: i32 = block_has_io_write_await(body);
  async_live_store_i32(out, 4188, ird);
  async_live_store_i32(out, 4192, iwr);

  // frame_tag @4108, cap 80
  frame_build_tag(f, out + 4108, 80);

  let fb: i32 = 4;
  if (ird != 0) { fb = fb + 4; }
  if (iwr != 0) { fb = fb + 4; }
  let li: i32 = 0;
  while (li < ln) {
    let row: *u8 = frame_live_row_ptr(out, li);
    let ty: *u8 = async_liveness_lookup_var_type(f, row);
    fb = fb + async_liveness_type_size_bytes_module(ty, m);
    li = li + 1;
  }
  async_live_store_i32(out, 4104, fb);
  return 0;
}

/** Layout without module (struct sizes default). */
#[no_mangle]
export function async_liveness_layout_func(f: *u8, out: *u8): i32 {
  return async_liveness_layout_func_module(f, 0 as *u8, out);
}

/** Whether CPS frame is required (IO/multi-await/lets/loops or non-param live).
 * Heap-allocates temporary AsyncFrameLayout (4196) — avoid stack blow on -E.
 * PLATFORM: SHARED — Cap residual pure. */
#[no_mangle]
export function async_liveness_func_needs_cps_frame(f: *u8): i32 {
  if (f == 0) { return 0; }
  if (async_live_load_i32(f, 68) == 0) { return 0; }
  let body: *u8 = async_live_load_ptr(f, 56);
  if (body == 0) { return 0; }
  if (block_has_await(body) == 0) { return 0; }
  if (block_has_io_read_await(body) != 0) { return 1; }
  if (block_has_io_write_await(body) != 0) { return 1; }
  if (block_count_await(body) > 1) { return 1; }
  // num_lets@24 num_loops@40 num_for_loops@56
  if (async_live_load_i32(body, 24) > 0) { return 1; }
  if (async_live_load_i32(body, 40) > 0) { return 1; }
  if (async_live_load_i32(body, 56) > 0) { return 1; }

  let layout: *u8 = 0 as *u8;
  unsafe { layout = malloc(4196 as usize); }
  if (layout == 0) { return 0; }
  if (async_liveness_layout_func_module(f, 0 as *u8, layout) != 0) {
    unsafe { free(layout); }
    return 0;
  }
  let ln: i32 = frame_live_load_n(layout);
  if (ln <= 0) {
    unsafe { free(layout); }
    return 0;
  }
  let nparams: i32 = async_live_load_i32(f, 40);
  let params: *u8 = async_live_load_ptr(f, 32);
  let i: i32 = 0;
  while (i < ln) {
    let row: *u8 = frame_live_row_ptr(layout, i);
    let is_param: i32 = 0;
    if (params != 0) {
      let pi: i32 = 0;
      while (pi < nparams) {
        let pr: *u8 = params + (pi * 24);
        let pn: *u8 = async_live_load_ptr(pr, 0);
        if (pn != 0) {
          if (async_live_cstr_eq(pn, row) != 0) {
            is_param = 1;
            break;
          }
        }
        pi = pi + 1;
      }
    }
    if (is_param == 0) {
      unsafe { free(layout); }
      return 1;
    }
    i = i + 1;
  }
  unsafe { free(layout); }
  return 0;
}

/** True if struct_name appears as NAMED type in any async frame live set.
 * Walks module funcs and impl_blocks methods.
 * PLATFORM: SHARED — Cap residual pure; heap layout temp. */
#[no_mangle]
export function async_liveness_module_struct_in_frame(m: *u8, struct_name: *u8): i32 {
  if (m == 0) { return 0; }
  if (struct_name == 0) { return 0; }
  if (struct_name[0] == 0) { return 0; }
  let layout: *u8 = 0 as *u8;
  unsafe { layout = malloc(4196 as usize); }
  if (layout == 0) { return 0; }

  let funcs: *u8 = async_live_load_ptr(m, 152);
  let nfuncs: i32 = async_live_load_i32(m, 160);
  if (funcs != 0) {
    let fi: i32 = 0;
    while (fi < nfuncs) {
      let f: *u8 = async_live_load_ptr(funcs, fi * 8);
      if (f != 0) {
        if (async_live_load_i32(f, 68) != 0) {
          if (async_liveness_func_has_await(f) != 0) {
            if (async_liveness_layout_func_module(f, m, layout) == 0) {
              let ln: i32 = frame_live_load_n(layout);
              let li: i32 = 0;
              while (li < ln) {
                let row: *u8 = frame_live_row_ptr(layout, li);
                let ty: *u8 = async_liveness_lookup_var_type(f, row);
                if (ty != 0) {
                  if (async_live_load_i32(ty, 0) == 8) {
                    let tn: *u8 = async_live_load_ptr(ty, 8);
                    if (tn != 0) {
                      if (async_live_cstr_eq(tn, struct_name) != 0) {
                        unsafe { free(layout); }
                        return 1;
                      }
                    }
                  }
                }
                li = li + 1;
              }
            }
          }
        }
      }
      fi = fi + 1;
    }
  }

  let impls: *u8 = async_live_load_ptr(m, 136);
  let nimpl: i32 = async_live_load_i32(m, 144);
  if (impls != 0) {
    let k: i32 = 0;
    while (k < nimpl) {
      let ib: *u8 = async_live_load_ptr(impls, k * 8);
      if (ib != 0) {
        let ifuncs: *u8 = async_live_load_ptr(ib, 24);
        let nif: i32 = async_live_load_i32(ib, 32);
        if (ifuncs != 0) {
          let j: i32 = 0;
          while (j < nif) {
            let f: *u8 = async_live_load_ptr(ifuncs, j * 8);
            if (f != 0) {
              if (async_live_load_i32(f, 68) != 0) {
                if (async_liveness_func_has_await(f) != 0) {
                  if (async_liveness_layout_func_module(f, m, layout) == 0) {
                    let ln: i32 = frame_live_load_n(layout);
                    let li: i32 = 0;
                    while (li < ln) {
                      let row: *u8 = frame_live_row_ptr(layout, li);
                      let ty: *u8 = async_liveness_lookup_var_type(f, row);
                      if (ty != 0) {
                        if (async_live_load_i32(ty, 0) == 8) {
                          let tn: *u8 = async_live_load_ptr(ty, 8);
                          if (tn != 0) {
                            if (async_live_cstr_eq(tn, struct_name) != 0) {
                              unsafe { free(layout); }
                              return 1;
                            }
                          }
                        }
                      }
                      li = li + 1;
                    }
                  }
                }
              }
            }
            j = j + 1;
          }
        }
      }
      k = k + 1;
    }
  }
  unsafe { free(layout); }
  return 0;
}

/** Compat: fill AsyncFrameLive only via layout_func.
 * PLATFORM: SHARED — Cap residual pure. */
#[no_mangle]
export function async_liveness_analyze_func(f: *u8, out: *u8): i32 {
  if (out == 0) { return 0 - 1; }
  let layout: *u8 = 0 as *u8;
  unsafe { layout = malloc(4196 as usize); }
  if (layout == 0) { return 0 - 1; }
  if (async_liveness_layout_func(f, layout) != 0) {
    unsafe { free(layout); }
    return 0 - 1;
  }
  // copy live (4100 bytes: names + n)
  let i: i32 = 0;
  while (i < 4100) {
    out[i] = layout[i];
    i = i + 1;
  }
  unsafe { free(layout); }
  return 0;
}

// ---- Cap residual pure: FILE* emit_* via opaque driver_preamble_fputs ----
// Matches seed async_liveness_emit_frame_typedef / emit_frame_local / emit_codegen_comment.
// Host LE: layout num_awaits@4100 frame_bytes@4104 frame_tag@4108 has_io_rd@4188 has_io_wr@4192;
// live.n@4096 name row i at layout+(i*64); ASTFunc name@8.
// G.7: type_to_c_buf + lookup_var_type authority (no second type table).

/** Emit non-negative i32 as decimal digits through driver_preamble_fputs.
 * Used by emit_codegen_comment for slots/bytes/awaits counters.
 * @param out FILE* as *u8
 * @param v value to print (only v >= 0; negative is a no-op)
 * PLATFORM: SHARED — Cap residual pure emit helper; opaque fputs bridge. */
#[no_mangle]
export function async_liveness_fputs_i32_dec(out: *u8, v: i32): void {
  if (out == 0) { return; }
  if (v < 0) { return; }
  if (v == 0) {
    let z: u8[2] = [48, 0];
    unsafe { driver_preamble_fputs(&z[0], out); }
    return;
  }
  let cnt: i32 = 0;
  let tc: i32 = v;
  while (tc > 0) {
    cnt = cnt + 1;
    tc = tc / 10;
  }
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
      unsafe { driver_preamble_fputs(&buf[0], out); }
    }
  }
}

/** Emit `typedef struct __xlang_async_frame_* { ... }` and CPS/IO RT decls before the func.
 * No-op when f/layout/out null or layout.num_awaits <= 0.
 * @param f ASTFunc* as *u8
 * @param layout AsyncFrameLayout* as *u8
 * @param out FILE* as *u8
 * PLATFORM: SHARED — Cap residual pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_liveness_emit_frame_typedef(f: *u8, layout: *u8, out: *u8): void {
  if (f == 0) { return; }
  if (layout == 0) { return; }
  if (out == 0) { return; }
  // num_awaits @4100
  if (async_live_load_i32(layout, 4100) <= 0) { return; }
  // frame_tag @4108; empty → default "__xlang_async_frame_fn" (seed fprintf fallback).
  let tag: *u8 = layout + 4108;
  if (layout[4108] == 0) {
    tag = "__xlang_async_frame_fn";
  }
  // String literal cap ~63 bytes in current -E; split long RT decls (G.9: host product cold
  // path still uses seed fprintf; pure .x must still emit complete text for hybrid).
  unsafe {
    driver_preamble_fputs("#ifndef XLANG_ASYNC_CPS_RT_DECL\n", out);
    driver_preamble_fputs("#define XLANG_ASYNC_CPS_RT_DECL\n", out);
    driver_preamble_fputs("extern int xlang_async_cps_suspend(", out);
    driver_preamble_fputs("int32_t *phase, int32_t next_phase);\n", out);
    driver_preamble_fputs("extern int xlang_async_cps_suspend_io(", out);
    driver_preamble_fputs("int32_t *phase, int32_t next_phase);\n", out);
    driver_preamble_fputs("extern int xlang_io_submit_read_async(", out);
    driver_preamble_fputs("uint8_t *ptr, size_t len, size_t handle);\n", out);
    driver_preamble_fputs("extern int32_t xlang_io_complete_read_async(void);\n", out);
    driver_preamble_fputs("extern int32_t xlang_io_complete_read_async_slot(int slot);\n", out);
    driver_preamble_fputs("extern int xlang_io_submit_write_async(", out);
    driver_preamble_fputs("const uint8_t *ptr, size_t len, size_t handle);\n", out);
    driver_preamble_fputs("extern int32_t xlang_io_complete_write_async(void);\n", out);
    driver_preamble_fputs("extern int32_t xlang_io_complete_write_async_slot(int slot);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_reset(void);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_push_i32(int32_t v);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_push_u32(uint32_t v);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_push_i64(int64_t v);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_push_usize(size_t v);\n", out);
    driver_preamble_fputs("extern void xlang_async_run_seed_set_i32(int32_t v);\n", out);
    driver_preamble_fputs("extern int xlang_async_run_seed_valid(void);\n", out);
    driver_preamble_fputs("extern int32_t xlang_async_run_seed_take_i32(void);\n", out);
    driver_preamble_fputs("extern uint32_t xlang_async_run_seed_take_u32(void);\n", out);
    driver_preamble_fputs("extern int64_t xlang_async_run_seed_take_i64(void);\n", out);
    driver_preamble_fputs("extern size_t xlang_async_run_seed_take_usize(void);\n", out);
    driver_preamble_fputs("extern int xlang_async_task_submit(int32_t (*fn)(void));\n", out);
    driver_preamble_fputs("extern int32_t xlang_async_run_drain_until_idle(void);\n", out);
    driver_preamble_fputs("extern void xlang_async_queue_reset(void);\n", out);
    driver_preamble_fputs("extern unsigned xlang_io_poll_async_completions(", out);
    driver_preamble_fputs("unsigned timeout_ms);\n", out);
    driver_preamble_fputs("#define XLANG_ASYNC_SUSPENDED ((int32_t)0x41535700)\n", out);
    driver_preamble_fputs("#define XLANG_IO_ASYNC_NOT_READY ((int32_t)-2)\n", out);
    driver_preamble_fputs("#endif\n", out);
    driver_preamble_fputs("typedef struct ", out);
    driver_preamble_fputs(tag, out);
    driver_preamble_fputs(" {\n", out);
    driver_preamble_fputs("  int32_t __phase;\n", out);
  }
  // has_io_rd_slot @4188
  if (async_live_load_i32(layout, 4188) != 0) {
    unsafe { driver_preamble_fputs("  int32_t __io_rd_slot;\n", out); }
  }
  // has_io_wr_slot @4192
  if (async_live_load_i32(layout, 4192) != 0) {
    unsafe { driver_preamble_fputs("  int32_t __io_wr_slot;\n", out); }
  }
  let n: i32 = frame_live_load_n(layout);
  let i: i32 = 0;
  while (i < n) {
    let row: *u8 = frame_live_row_ptr(layout, i);
    let ty: *u8 = async_liveness_lookup_var_type(f, row);
    let cty: u8[96];
    async_liveness_type_to_c_buf(ty, &cty[0], 96);
    unsafe {
      driver_preamble_fputs("  ", out);
      driver_preamble_fputs(&cty[0], out);
      driver_preamble_fputs(" ", out);
      driver_preamble_fputs(row, out);
      driver_preamble_fputs(";\n", out);
    }
    i = i + 1;
  }
  unsafe {
    driver_preamble_fputs("} ", out);
    driver_preamble_fputs(tag, out);
    driver_preamble_fputs(";\n", out);
  }
}

/** Emit `static <tag> __xlang_frame;` at function body start (sync stub frame local).
 * No-op when f/layout/out null or layout.num_awaits <= 0.
 * PLATFORM: SHARED — Cap residual pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_liveness_emit_frame_local(f: *u8, layout: *u8, out: *u8): void {
  if (f == 0) { return; }
  if (layout == 0) { return; }
  if (out == 0) { return; }
  if (async_live_load_i32(layout, 4100) <= 0) { return; }
  // frame_tag @4108; empty → default (same as seed).
  let tag: *u8 = layout + 4108;
  if (layout[4108] == 0) {
    tag = "__xlang_async_frame_fn";
  }
  unsafe {
    driver_preamble_fputs("  static ", out);
    driver_preamble_fputs(tag, out);
    driver_preamble_fputs(" __xlang_frame;\n", out);
  }
}

/** Emit XLANG_ASYNC_FRAME layout comment for grep gates (slots/bytes/awaits/vars/tag).
 * No-op only when f/layout/out is null (unlike typedef, allows num_awaits==0).
 * PLATFORM: SHARED — Cap residual pure; seed C under #ifndef FROM_X. */
#[no_mangle]
export function async_liveness_emit_codegen_comment(f: *u8, layout: *u8, out: *u8): void {
  if (f == 0) { return; }
  if (layout == 0) { return; }
  if (out == 0) { return; }
  // ASTFunc name @8
  let fn: *u8 = async_live_load_ptr(f, 8);
  if (fn == 0) {
    fn = "?";
  } else {
    if (fn[0] == 0) {
      fn = "?";
    }
  }
  let slots: i32 = frame_live_load_n(layout);
  let bytes: i32 = async_live_load_i32(layout, 4104);
  let awaits: i32 = async_live_load_i32(layout, 4100);
  let has_rd: i32 = async_live_load_i32(layout, 4188);
  let has_wr: i32 = async_live_load_i32(layout, 4192);
  unsafe {
    driver_preamble_fputs("  /* XLANG_ASYNC_FRAME func=", out);
    driver_preamble_fputs(fn, out);
    driver_preamble_fputs(" slots=", out);
  }
  async_liveness_fputs_i32_dec(out, slots);
  unsafe { driver_preamble_fputs(" bytes=", out); }
  async_liveness_fputs_i32_dec(out, bytes);
  unsafe { driver_preamble_fputs(" awaits=", out); }
  async_liveness_fputs_i32_dec(out, awaits);
  if (has_rd != 0 || has_wr != 0) {
    unsafe { driver_preamble_fputs(" io_slots=", out); }
    if (has_rd != 0) {
      unsafe { driver_preamble_fputs("rd", out); }
    }
    if (has_wr != 0) {
      if (has_rd != 0) {
        unsafe { driver_preamble_fputs("+", out); }
      }
      unsafe { driver_preamble_fputs("wr", out); }
    }
  }
  if (slots > 0) {
    unsafe { driver_preamble_fputs(" vars=", out); }
    let i: i32 = 0;
    while (i < slots) {
      if (i != 0) {
        unsafe { driver_preamble_fputs(",", out); }
      }
      let row: *u8 = frame_live_row_ptr(layout, i);
      unsafe { driver_preamble_fputs(row, out); }
      i = i + 1;
    }
  }
  unsafe { driver_preamble_fputs(" tag=", out); }
  // frame_tag@4108 or "?"
  if (layout[4108] != 0) {
    unsafe { driver_preamble_fputs(layout + 4108, out); }
  } else {
    unsafe { driver_preamble_fputs("?", out); }
  }
  unsafe { driver_preamble_fputs(" */\n", out); }
}
