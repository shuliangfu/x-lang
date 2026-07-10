// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-18：async_cps_codegen 产品源迁 seeds/async_cps_codegen.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/async_cps_codegen.from_x.c → src/async/async_cps_codegen.o
// G-02f-105：+ emit_hoisted_lets / callee_is_io / future_wait 薄门闩。

extern "C" function emit_hoisted_lets_impl(f: *u8, out: *u8): void;

function async_cps_codegen_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-105 / G-02f-132：async cps helpers ---- */

// ASTFunc: line:i32 + col:i32 + name:*char → name 在偏移 8
function async_cps_load_func_name(callee: *u8): *u8 {
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
function emit_hoisted_lets(f: *u8, out: *u8): void {
  unsafe {
    emit_hoisted_lets_impl(f, out);
  }
}

// G-02f-132：IO await 目标名表真迁 .x
#[no_mangle]
function async_cps_callee_is_io(callee: *u8): i32 {
  let name: *u8 = async_cps_load_func_name(callee);
  if (name == 0) { return 0; }
  if (name[0] == 0) { return 0; }
  // shux_io_
  if (name[0]==115 && name[1]==104 && name[2]==117 && name[3]==120 && name[4]==95
      && name[5]==105 && name[6]==111 && name[7]==95) {
    return 1;
  }
  // read / write
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==0) { return 1; }
  if (name[0]==119 && name[1]==114 && name[2]==105 && name[3]==116 && name[4]==101 && name[5]==0) { return 1; }
  // submit_read / submit_write
  if (name[0]==115 && name[1]==117 && name[2]==98 && name[3]==109 && name[4]==105 && name[5]==116
      && name[6]==95 && name[7]==114 && name[8]==101 && name[9]==97 && name[10]==100 && name[11]==0) {
    return 1;
  }
  if (name[0]==115 && name[1]==117 && name[2]==98 && name[3]==109 && name[4]==105 && name[5]==116
      && name[6]==95 && name[7]==119 && name[8]==114 && name[9]==105 && name[10]==116 && name[11]==101
      && name[12]==0) {
    return 1;
  }
  // read_fd / write_fd
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==95 && name[5]==102
      && name[6]==100 && name[7]==0) {
    return 1;
  }
  if (name[0]==119 && name[1]==114 && name[2]==105 && name[3]==116 && name[4]==101 && name[5]==95
      && name[6]==102 && name[7]==100 && name[8]==0) {
    return 1;
  }
  // read_ptr / read_stdin_ptr
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==95 && name[5]==112
      && name[6]==116 && name[7]==114 && name[8]==0) {
    return 1;
  }
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==95 && name[5]==115
      && name[6]==116 && name[7]==100 && name[8]==105 && name[9]==110 && name[10]==95 && name[11]==112
      && name[12]==116 && name[13]==114 && name[14]==0) {
    return 1;
  }
  // read_into / write_from
  if (name[0]==114 && name[1]==101 && name[2]==97 && name[3]==100 && name[4]==95 && name[5]==105
      && name[6]==110 && name[7]==116 && name[8]==111 && name[9]==0) {
    return 1;
  }
  if (name[0]==119 && name[1]==114 && name[2]==105 && name[3]==116 && name[4]==101 && name[5]==95
      && name[6]==102 && name[7]==114 && name[8]==111 && name[9]==109 && name[10]==0) {
    return 1;
  }
  return 0;
}

// G-02f-111：+ run_async ref scan 薄门闩。

extern "C" function expr_references_run_async_impl(e: *u8): i32;
extern "C" function block_has_run_async_ref_impl(b: *u8): i32;

/* ---- G-02f-111：async_cps run_async scan 门闩 ---- */

#[no_mangle]
function expr_references_run_async(e: *u8): i32 { unsafe { return expr_references_run_async_impl(e); } return 0; }
#[no_mangle]
function block_has_run_async_ref(b: *u8): i32 { unsafe { return block_has_run_async_ref_impl(b); } return 0; }

// G-02f-120：async_cps_callee_is_future_wait_by_name 真迁 .x

#[no_mangle]
function async_cps_callee_is_future_wait_by_name(n: *u8): i32 {
  if (n == 0) { return 0; }
  if (n[0] == 0) { return 0; }
  // exact names (byte compare via short literals hard-coded)
  // future_wait
  if (n[0]==102 && n[1]==117 && n[2]==116 && n[3]==117 && n[4]==114 && n[5]==101
      && n[6]==95 && n[7]==119 && n[8]==97 && n[9]==105 && n[10]==116 && n[11]==0) {
    return 1;
  }
  // runtime_wait_future
  if (n[0]==114 && n[1]==117 && n[2]==110 && n[3]==116 && n[4]==105 && n[5]==109 && n[6]==101
      && n[7]==95 && n[8]==119 && n[9]==97 && n[10]==105 && n[11]==116 && n[12]==95
      && n[13]==102 && n[14]==117 && n[15]==116 && n[16]==117 && n[17]==114 && n[18]==101 && n[19]==0) {
    return 1;
  }
  // shux_async_future_wait_c
  if (n[0]==115 && n[1]==104 && n[2]==117 && n[3]==120 && n[4]==95 && n[5]==97 && n[6]==115
      && n[7]==121 && n[8]==110 && n[9]==99 && n[10]==95 && n[11]==102 && n[12]==117 && n[13]==116
      && n[14]==117 && n[15]==114 && n[16]==101 && n[17]==95 && n[18]==119 && n[19]==97 && n[20]==105
      && n[21]==116 && n[22]==95 && n[23]==99 && n[24]==0) {
    return 1;
  }
  // std_async_future_wait
  if (n[0]==115 && n[1]==116 && n[2]==100 && n[3]==95 && n[4]==97 && n[5]==115 && n[6]==121
      && n[7]==110 && n[8]==99 && n[9]==95 && n[10]==102 && n[11]==117 && n[12]==116 && n[13]==117
      && n[14]==114 && n[15]==101 && n[16]==95 && n[17]==119 && n[18]==97 && n[19]==105 && n[20]==116
      && n[21]==0) {
    return 1;
  }
  // std_async_runtime_wait_future
  if (n[0]==115 && n[1]==116 && n[2]==100 && n[3]==95 && n[4]==97 && n[5]==115 && n[6]==121
      && n[7]==110 && n[8]==99 && n[9]==95 && n[10]==114 && n[11]==117 && n[12]==110 && n[13]==116
      && n[14]==105 && n[15]==109 && n[16]==101 && n[17]==95 && n[18]==119 && n[19]==97 && n[20]==105
      && n[21]==116 && n[22]==95 && n[23]==102 && n[24]==117 && n[25]==116 && n[26]==117 && n[27]==114
      && n[28]==101 && n[29]==0) {
    return 1;
  }
  // substring future_wait / runtime_wait_future
  let i: i32 = 0;
  while (i < 512) {
    if (n[i] == 0) { break; }
    // future_wait at i
    if (n[i]==102 && n[i+1]==117 && n[i+2]==116 && n[i+3]==117 && n[i+4]==114 && n[i+5]==101
        && n[i+6]==95 && n[i+7]==119 && n[i+8]==97 && n[i+9]==105 && n[i+10]==116) {
      return 1;
    }
    // runtime_wait_future at i
    if (n[i]==114 && n[i+1]==117 && n[i+2]==110 && n[i+3]==116 && n[i+4]==105 && n[i+5]==109
        && n[i+6]==101 && n[i+7]==95 && n[i+8]==119 && n[i+9]==97 && n[i+10]==105 && n[i+11]==116
        && n[i+12]==95 && n[i+13]==102 && n[i+14]==117 && n[i+15]==116 && n[i+16]==117 && n[i+17]==114
        && n[i+18]==101) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// G-02f-132：future_wait 经 by_name（须在 by_name 之后）
#[no_mangle]
function async_cps_callee_is_future_wait(callee: *u8): i32 {
  let name: *u8 = async_cps_load_func_name(callee);
  if (name == 0) { return 0; }
  return async_cps_callee_is_future_wait_by_name(name);
}
