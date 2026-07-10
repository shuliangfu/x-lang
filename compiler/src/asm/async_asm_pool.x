// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f：async_asm_pool 产品源迁 seeds/async_asm_pool.from_x.c。
// G-02f-104：+ await/var/live helpers 薄门闩。
// G-02f-142：await/var/refs/block_rest pure helpers 真迁 .x

extern "C" function pipeline_expr_kind_ord_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_unary_operand_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_as_operand_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_as_target_type_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_left_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_right_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_base_ref(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_index_base_ref(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_index_index_ref(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_len(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_into(a: *u8, er: i32, out: *u8): void;
extern "C" function ast_ast_block_num_lets(a: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_expr_stmts(a: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_stmt_order(a: *u8, br: i32): i32;
extern "C" function ast_ast_block_stmt_order_kind(a: *u8, br: i32, si: i32): u8;
extern "C" function ast_ast_block_stmt_order_idx(a: *u8, br: i32, si: i32): i32;
extern "C" function pipeline_block_let_init_ref(a: *u8, br: i32, li: i32): i32;
extern "C" function ast_pipeline_block_expr_stmt_ref(a: *u8, br: i32, ei: i32): i32;
extern "C" function pipeline_asm_block_final_expr_ref_at(a: *u8, br: i32): i32;
extern "C" function asm_pool_type_size_bytes_impl(a: *u8, m: *u8, type_ref: i32): i32;
extern "C" function asm_pool_live_add_impl(lay: *u8, name: *u8, nlen: i32, sz: i32): void;

function async_asm_pool_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-142：async asm pool pure helpers ---- */

// C AST_EXPR_AWAIT(54) 与 X EXPR_AS 碰撞；X EXPR_AWAIT=55
// G-02f-142：expr 是否 await
#[no_mangle]
function asm_pool_expr_is_await(a: *u8, er: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko == 55) {
      let uop: i32 = pipeline_expr_unary_operand_ref_at(a, er);
      if (uop > 0) { return 1; }
      return 0;
    }
    if (ko != 54) { return 0; }
    if (pipeline_expr_as_target_type_ref_at(a, er) > 0) { return 0; }
    if (pipeline_expr_as_operand_ref_at(a, er) > 0) { return 0; }
    let uop2: i32 = pipeline_expr_unary_operand_ref_at(a, er);
    if (uop2 > 0) { return 1; }
  }
  return 0;
}

// G-02f-142：表达式树是否含 await
#[no_mangle]
function asm_pool_expr_has_await(a: *u8, er: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  unsafe {
    if (asm_pool_expr_is_await(a, er) != 0) { return 1; }
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko >= 4) {
      if (ko <= 21) {
        if (asm_pool_expr_has_await(a, pipeline_expr_binop_left_ref_at(a, er)) != 0) { return 1; }
        return asm_pool_expr_has_await(a, pipeline_expr_binop_right_ref_at(a, er));
      }
    }
    if (ko == 22) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 23) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 24) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 54) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 55) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 51) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 52) {
      return asm_pool_expr_has_await(a, pipeline_expr_unary_operand_ref_at(a, er));
    }
    if (ko == 44) {
      return asm_pool_expr_has_await(a, pipeline_expr_field_access_base_ref(a, er));
    }
    if (ko == 47) {
      if (asm_pool_expr_has_await(a, pipeline_expr_index_base_ref(a, er)) != 0) { return 1; }
      return asm_pool_expr_has_await(a, pipeline_expr_index_index_ref(a, er));
    }
  }
  return 0;
}

// G-02f-142：VAR=3 是否给定名
#[no_mangle]
function asm_pool_expr_is_var_named(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(a, er) != 3) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(a, er);
    if (vlen != nlen) { return 0; }
    let vbuf: u8[64] = [];
    pipeline_expr_var_name_into(a, er, &vbuf[0]);
    let i: i32 = 0;
    while (i < nlen) {
      if (vbuf[i] != name[i]) { return 0; }
      i = i + 1;
    }
    return 1;
  }
  return 0;
}

// G-02f-142：表达式是否引用变量名
#[no_mangle]
function asm_pool_expr_refs_name(a: *u8, er: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    if (asm_pool_expr_is_var_named(a, er, name, nlen) != 0) { return 1; }
    let ko: i32 = pipeline_expr_kind_ord_at(a, er);
    if (ko >= 4) {
      if (ko <= 21) {
        if (asm_pool_expr_refs_name(a, pipeline_expr_binop_left_ref_at(a, er), name, nlen) != 0) { return 1; }
        return asm_pool_expr_refs_name(a, pipeline_expr_binop_right_ref_at(a, er), name, nlen);
      }
    }
    if (ko == 22) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 23) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 24) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 54) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 55) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 51) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 52) {
      return asm_pool_expr_refs_name(a, pipeline_expr_unary_operand_ref_at(a, er), name, nlen);
    }
    if (ko == 44) {
      return asm_pool_expr_refs_name(a, pipeline_expr_field_access_base_ref(a, er), name, nlen);
    }
    if (ko == 47) {
      if (asm_pool_expr_refs_name(a, pipeline_expr_index_base_ref(a, er), name, nlen) != 0) { return 1; }
      return asm_pool_expr_refs_name(a, pipeline_expr_index_index_ref(a, er), name, nlen);
    }
  }
  return 0;
}

// G-02f-142：stmt_order 后段是否仍引用 name
#[no_mangle]
function asm_pool_block_rest_refs_name(a: *u8, br: i32, from_exclusive: i32, name: *u8, nlen: i32): i32 {
  if (a == 0) { return 0; }
  if (br <= 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let nso: i32 = ast_ast_block_num_stmt_order(a, br);
    let si: i32 = from_exclusive + 1;
    while (si < nso) {
      let kind: u8 = ast_ast_block_stmt_order_kind(a, br, si);
      let idx: i32 = ast_ast_block_stmt_order_idx(a, br, si);
      if (kind == 1) {
        if (idx >= 0) {
          if (idx < ast_ast_block_num_lets(a, br)) {
            let init: i32 = pipeline_block_let_init_ref(a, br, idx);
            if (init > 0) {
              if (asm_pool_expr_refs_name(a, init, name, nlen) != 0) { return 1; }
            }
          }
        }
      } else {
        if (kind == 2) {
          if (idx >= 0) {
            if (idx < ast_ast_block_num_expr_stmts(a, br)) {
              let ex: i32 = ast_pipeline_block_expr_stmt_ref(a, br, idx);
              if (ex > 0) {
                if (asm_pool_expr_refs_name(a, ex, name, nlen) != 0) { return 1; }
              }
            }
          }
        }
      }
      si = si + 1;
    }
    let fin: i32 = pipeline_asm_block_final_expr_ref_at(a, br);
    if (fin > 0) {
      if (asm_pool_expr_refs_name(a, fin, name, nlen) != 0) { return 1; }
    }
  }
  return 0;
}

// type_size / live_add 仍 seed（layout / grow 结构）
#[no_mangle]
function asm_pool_type_size_bytes(a: *u8, m: *u8, type_ref: i32): i32 {
  unsafe {
    return asm_pool_type_size_bytes_impl(a, m, type_ref);
  }
  return 0;
}

#[no_mangle]
function asm_pool_live_add(lay: *u8, name: *u8, nlen: i32, sz: i32): void {
  unsafe {
    asm_pool_live_add_impl(lay, name, nlen, sz);
  }
}
