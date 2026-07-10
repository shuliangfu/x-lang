// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：async_liveness 产品源迁 seeds/async_liveness.from_x.c。
// G-02f-161：frame_mangle_ident / frame_build_tag 真迁 .x。
// G-02f-162：frame_live_add 真迁 .x（AsyncFrameLive names@0 n@4096）。
// G-02f-164：frame_live_at_await 真迁 .x（char** defined LE 槽）。
// G-02f-165：thin _impl 批折叠。
// G-02f-166～168：expr/block await + count + io_await 真迁 .x（AST LE 偏移表）。
// G-02f-169～171：expr/block refs_var + rest_refs + analyze_block_linear 真迁 .x。
// G-02f-172：P0-2 审计 — 见 analysis/G-02f-自举剩余优先级.md §3.1 / Wave A f-172。
// 产品：cc seeds/async_liveness.from_x.c → src/async/async_liveness.o

function async_liveness_x_doc_anchor(): i32 {
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

// ASTFunc.name 偏移 8（line+col）
function async_live_load_func_name(callee: *u8): *u8 {
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

#[no_mangle]
function async_liveness_callee_is_io_read(f: *u8): i32 {
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

#[no_mangle]
function async_liveness_callee_is_io_write(f: *u8): i32 {
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
function async_live_load_i32(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * m * m;
  a = a + (p[off + 3] as i32) * m * m * m;
  return a;
}

function async_live_load_ptr(p: *u8, off: i32): *u8 {
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

function async_live_ptr_at(base: *u8, i: i32): *u8 {
  if (base == 0) { return 0 as *u8; }
  return async_live_load_ptr(base, i * 8);
}

function async_live_expr_kind(e: *u8): i32 {
  return async_live_load_i32(e, 0);
}

function async_live_is_binop_kind(k: i32): i32 {
  if (k >= 4) {
    if (k <= 21) { return 1; }
  }
  if (k >= 28) {
    if (k <= 38) { return 1; }
  }
  return 0;
}

function async_live_is_unary_kind(k: i32): i32 {
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

// G-02f-166：expr_has_await 真迁（主 kind 全表 + 递归）
#[no_mangle]
function expr_has_await(e: *u8): i32 {
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
#[no_mangle]
function expr_count_await(e: *u8): i32 {
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
#[no_mangle]
function block_count_await(b: *u8): i32 {
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

#[no_mangle]
function block_has_await(b: *u8): i32 {
  if (block_count_await(b) > 0) { return 1; }
  return 0;
}

// G-02f-167：expr_has_io_read/write_await + block_has_io_*
#[no_mangle]
function expr_has_io_read_await(e: *u8): i32 {
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

#[no_mangle]
function expr_has_io_write_await(e: *u8): i32 {
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

#[no_mangle]
function block_has_io_read_await(b: *u8): i32 {
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

#[no_mangle]
function block_has_io_write_await(b: *u8): i32 {
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
function async_live_cstr_eq(a: *u8, b: *u8): i32 {
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

function async_live_cstr_copy64(dst: *u8, src: *u8): void {
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

function async_live_def_row(defs: *u8, i: i32): *u8 {
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

// char** 槽 i：偏移 i*8（LE 指针）
function async_live_load_def_name(defs: *u8, i: i32): *u8 {
  if (defs == 0) { return 0 as *u8; }
  let off: i32 = i * 8;
  return async_live_load_ptr(defs, off);
}

#[no_mangle]
function expr_refs_var(e: *u8, name: *u8): i32 {
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

#[no_mangle]
function block_refs_var(b: *u8, name: *u8): i32 {
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
#[no_mangle]
function block_rest_refs_var(b: *u8, from_exclusive: i32, name: *u8): i32 {
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
function frame_live_load_n(out: *u8): i32 {
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

function frame_live_store_n(out: *u8, n: i32): void {
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

function frame_live_row_ptr(out: *u8, idx: i32): *u8 {
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

function frame_live_name_eq(row: *u8, name: *u8): i32 {
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

// G-02f-162：插入去重（超 64 静默丢弃）
#[no_mangle]
function frame_live_add(out: *u8, name: *u8): void {
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

/* ---- G-02f-161 / G-02f-164：async_liveness frame 真迁 ---- */

// G-02f-164：defs 为 char**；block_rest_refs_var 已真迁
#[no_mangle]
function frame_live_at_await(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void {
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

// G-02f-171：analyze_block_linear — def 名拷入本地 64×64，避免 char** 栈
function async_live_analyze_at_await(b: *u8, si: i32, defs: *u8, n_def: i32, frame: *u8): void {
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

#[no_mangle]
function analyze_block_linear(b: *u8, prefix: *u8, n_prefix: i32, frame: *u8): void {
  if (b == 0) { return; }
  if (frame == 0) { return; }
  let def_names: u8[4096] = [];
  let n_def: i32 = 0;
  let pi: i32 = 0;
  while (pi < n_prefix) {
    if (n_def >= 64) { break; }
    let pn: *u8 = async_live_load_def_name(prefix, pi);
    if (pn != 0) {
      if (pn[0] != 0) {
        async_live_cstr_copy64(async_live_def_row(&def_names[0], n_def), pn);
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
                  async_live_analyze_at_await(b, si, &def_names[0], n_def, frame);
                }
              }
              if (n_def < 64) {
                let lname: *u8 = async_live_load_ptr(ld, 0);
                if (lname != 0) {
                  if (lname[0] != 0) {
                    async_live_cstr_copy64(async_live_def_row(&def_names[0], n_def), lname);
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
                    async_live_analyze_at_await(b, si, &def_names[0], n_def, frame);
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
        async_live_analyze_at_await(b, norder - 1, &def_names[0], n_def, frame);
      }
    }
    return;
  }
  let fin2: *u8 = async_live_load_ptr(b, 112);
  if (fin2 != 0) {
    if (expr_has_await(fin2) != 0) {
      async_live_analyze_at_await(b, 0 - 1, &def_names[0], n_def, frame);
    }
  }
}


// G-02f-161：函数名 → C 标识符（非 alnum/_ → _）
#[no_mangle]
function frame_mangle_ident(in_name: *u8, out: *u8, cap: i32): void {
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

// G-02f-161：__shux_async_frame_<mangled>（f 为 ASTFunc*，name@8）
#[no_mangle]
function frame_build_tag(f: *u8, out: *u8, cap: i32): void {
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
  let pref: *u8 = "__shux_async_frame_";
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

// G-02f-119：live_name_cmp 真迁 .x

#[no_mangle]
function live_name_cmp(a: *u8, b: *u8): i32 {
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

// G-02f-168：block_has_await 见上文（真迁 + block_count_await）。

