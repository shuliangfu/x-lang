// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：async_liveness 产品源迁 seeds/async_liveness.from_x.c。
// G-02f-161：frame_mangle_ident / frame_build_tag 真迁 .x。
// G-02f-162：frame_live_add 真迁 .x（AsyncFrameLive names@0 n@4096）。
// 产品：cc seeds/async_liveness.from_x.c → src/async/async_liveness.o

function async_liveness_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108 / G-02f-132：await/io/block/frame helpers

extern "C" function block_count_await_impl(b: *u8): i32;
extern "C" function block_has_io_read_await_impl(b: *u8): i32;
extern "C" function block_has_io_write_await_impl(b: *u8): i32;
extern "C" function block_refs_var_impl(b: *u8, name: *u8): i32;
extern "C" function block_rest_refs_var_impl(b: *u8, from: i32, name: *u8): i32;

/* ---- G-02f-108 / G-02f-132：async_liveness helpers ---- */

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



#[no_mangle]
function block_count_await(b: *u8): i32 {
  unsafe { return block_count_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_has_io_read_await(b: *u8): i32 {
  unsafe { return block_has_io_read_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_has_io_write_await(b: *u8): i32 {
  unsafe { return block_has_io_write_await_impl(b); }
  return 0;
}

#[no_mangle]
function block_refs_var(b: *u8, name: *u8): i32 {
  unsafe { return block_refs_var_impl(b, name); }
  return 0;
}

#[no_mangle]
function block_rest_refs_var(b: *u8, from: i32, name: *u8): i32 {
  unsafe { return block_rest_refs_var_impl(b, from, name); }
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

// G-02f-110：+ expr await/refs + frame analyze 薄门闩。

extern "C" function expr_has_await_impl(e: *u8): i32;
extern "C" function expr_count_await_impl(e: *u8): i32;
extern "C" function expr_has_io_read_await_impl(e: *u8): i32;
extern "C" function expr_has_io_write_await_impl(e: *u8): i32;
extern "C" function expr_refs_var_impl(e: *u8, name: *u8): i32;
extern "C" function frame_live_at_await_impl(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void;
extern "C" function analyze_block_linear_impl(b: *u8, out: *u8): void;

/* ---- G-02f-110 / G-02f-161：async_liveness expr/frame 门闩 ---- */

#[no_mangle]
function expr_has_await(e: *u8): i32 { unsafe { return expr_has_await_impl(e); } return 0; }
#[no_mangle]
function expr_count_await(e: *u8): i32 { unsafe { return expr_count_await_impl(e); } return 0; }
#[no_mangle]
function expr_has_io_read_await(e: *u8): i32 { unsafe { return expr_has_io_read_await_impl(e); } return 0; }
#[no_mangle]
function expr_has_io_write_await(e: *u8): i32 { unsafe { return expr_has_io_write_await_impl(e); } return 0; }
#[no_mangle]
function expr_refs_var(e: *u8, name: *u8): i32 { unsafe { return expr_refs_var_impl(e, name); } return 0; }
#[no_mangle]
function frame_live_at_await(b: *u8, idx: i32, defs: *u8, nd: i32, out: *u8): void { unsafe { frame_live_at_await_impl(b, idx, defs, nd, out); } }

#[no_mangle]
function analyze_block_linear(b: *u8, out: *u8): void { unsafe { analyze_block_linear_impl(b, out); } }

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

// G-02f-127：block_has_await 真迁 .x（组合 block_count_await）

extern "C" function block_count_await(b: *u8): i32;

#[no_mangle]
function block_has_await(b: *u8): i32 {
  unsafe {
    if (block_count_await(b) > 0) { return 1; }
  }
  return 0;
}

