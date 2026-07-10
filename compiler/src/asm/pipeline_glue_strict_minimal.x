// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-11：pipeline_glue_strict_minimal 产品源迁 seeds/pipeline_glue_strict_minimal.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；B-strict 最小 glue 实现仍在 seed C。
// G-02f-107：+ named_equal / binding / param / field / assign_kind 薄门闩。
// G-02f-108：+ unqual/find/map/slice/ancestor/const_name 薄门闩。
// G-02f-139：named_equal / binding_name_equal / is_func_param / slice_region_conflict 真迁 .x
// G-02f-210：addr_of/resolve_call/empty_array_lit/noops 等 pure 弱壳真迁 .x

extern "C" function pipeline_type_named_name_into(arena: *u8, tr: i32, out64: *u8): i32;
extern "C" function pipeline_module_import_binding_name_len(mod: *u8, idx: i32): i32;
extern "C" function pipeline_module_import_binding_name_byte_at(mod: *u8, idx: i32, off: i32): u8;
extern "C" function parser_get_module_num_imports(mod: *u8): i32;
extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_module_func_param_name_len_at(mod: *u8, fi: i32, pix: i32): i32;
extern "C" function pipeline_module_func_param_name_copy32(mod: *u8, fi: i32, pix: i32, dst: *u8): void;
extern "C" function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
extern "C" function pipeline_type_region_label_into(arena: *u8, tr: i32, out64: *u8): i32;

function pipeline_glue_strict_minimal_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-107 / G-02f-139：strict minimal typeck helpers ---- */

// G-02f-139：TYPE_NAMED 全名或 unqualified 后缀相等
#[no_mangle]
function pipeline_typeck_named_equal_strict_minimal(arena: *u8, a: i32, b: i32): i32 {
  if (arena == 0) { return 0; }
  unsafe {
    let buf_a: u8[64] = [];
    let buf_b: u8[64] = [];
    let na: i32 = pipeline_type_named_name_into(arena, a, &buf_a[0]);
    let nb: i32 = pipeline_type_named_name_into(arena, b, &buf_b[0]);
    if (na <= 0) { return 0; }
    if (nb <= 0) { return 0; }
    if (na == nb) {
      let i: i32 = 0;
      let ok: i32 = 1;
      while (i < na) {
        if (buf_a[i] != buf_b[i]) { ok = 0; break; }
        i = i + 1;
      }
      if (ok != 0) { return 1; }
    }
    let oa: i32 = pipeline_typeck_named_unqual_offset_strict_minimal(&buf_a[0], na);
    let ob: i32 = pipeline_typeck_named_unqual_offset_strict_minimal(&buf_b[0], nb);
    let ua: i32 = na - oa;
    let ub: i32 = nb - ob;
    if (ua != ub) { return 0; }
    let j: i32 = 0;
    while (j < ua) {
      if (buf_a[oa + j] != buf_b[ob + j]) { return 0; }
      j = j + 1;
    }
    return 1;
  }
  return 0;
}

// G-02f-139：import binding 名与 name 逐字节相等
#[no_mangle]
function pipeline_typeck_import_binding_name_equal_strict_minimal(module: *u8, dep_ix: i32, name: *u8, name_len: i32): i32 {
  if (module == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  if (dep_ix < 0) { return 0; }
  unsafe {
    if (dep_ix >= parser_get_module_num_imports(module)) { return 0; }
    let bind_len: i32 = pipeline_module_import_binding_name_len(module, dep_ix);
    if (bind_len != name_len) { return 0; }
    if (bind_len <= 0) { return 0; }
    if (bind_len > 63) { return 0; }
    let i: i32 = 0;
    while (i < bind_len) {
      if (pipeline_module_import_binding_name_byte_at(module, dep_ix, i) != name[i]) { return 0; }
      i = i + 1;
    }
    return 1;
  }
  return 0;
}

// G-02f-139：VAR 是否为指定形参（EXPR_VAR=3）
#[no_mangle]
function pipeline_expr_is_func_param_at_strict_minimal(arena: *u8, mod: *u8, func_idx: i32, expr_ref: i32, param_ix: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3) { return 0; }
    let plen: i32 = pipeline_module_func_param_name_len_at(mod, func_idx, param_ix);
    let vlen: i32 = pipeline_expr_var_name_len(arena, expr_ref);
    if (plen <= 0) { return 0; }
    if (plen != vlen) { return 0; }
    let pbuf: u8[32] = [];
    let vbuf: u8[64] = [];
    pipeline_module_func_param_name_copy32(mod, func_idx, param_ix, &pbuf[0]);
    pipeline_expr_var_name_into(arena, expr_ref, &vbuf[0]);
    let k: i32 = 0;
    while (k < plen) {
      if (pbuf[k] != vbuf[k]) { return 0; }
      k = k + 1;
    }
    return 1;
  }
  return 0;
}




// G-02f-152：linear 全局表仍在 seed（无 _impl 薄层）
extern "C" function pipeline_typeck_linear_name_already_moved_strict_minimal(name: *u8, nlen: i32): i32;
extern "C" function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
extern "C" function pipeline_type_region_label_len_at(arena: *u8, tr: i32): i32;
extern "C" function pipeline_arena_block_ptr(arena: *u8, br: i32): *u8;
extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
extern "C" function pipeline_dep_ctx_current_func_index(ctx: *u8): i32;
extern "C" function pipeline_dep_ctx_current_block_ref_at(ctx: *u8): i32;
extern "C" function pipeline_module_func_param_type_ref_for_name(mod: *u8, fi: i32, name: *u8, nlen: i32): i32;
extern "C" function pipeline_module_func_body_ref_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_block_find_var_decl_block_ref(arena: *u8, br: i32, name: *u8, nlen: i32): i32;
extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_type_elem_ref_at(arena: *u8, tr: i32): i32;
extern "C" function pipeline_type_array_size_at(arena: *u8, tr: i32): i32;
extern "C" function pipeline_type_find_or_alloc_slice(arena: *u8, elem: i32, rlab: *u8, rlen: i32): i32;
extern "C" function pipeline_type_find_or_alloc_compound(arena: *u8, kind: i32, elem: i32, asz: i32): i32;
extern "C" function pipeline_module_func_name_equal_at(mod: *u8, fi: i32, name: *u8, nlen: i32): i32;
extern "C" function pipeline_module_func_num_params_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
extern "C" function pipeline_typeck_get_dep_return_type_in_caller_arena_c(dep: i32, ret_ty: i32, arena: *u8, ctx: *u8): i32;
extern "C" function pipeline_module_import_kind_at(mod: *u8, dep: i32): i32;
extern "C" function pipeline_type_find_or_alloc_named(arena: *u8, name: *u8, nlen: i32): i32;
extern "C" function pipeline_type_ensure_by_kind_ord(arena: *u8, kind: i32): i32;
extern "C" function pipeline_expr_line_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_col_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_index_base_ref(arena: *u8, er: i32): i32;
// G-02f-117：pipeline_typeck_const_name_matches_strict_minimal 真迁 .x
// G-02f-140：find_func / map_binding / diag / lval_root / result_payload 真迁 .x

/* ---- G-02f-108 / G-02f-140：strict minimal more typeck helpers ---- */

// G-02f-140：按名找函数下标；want_arity>=0 时优先 arity 匹配
#[no_mangle]
function pipeline_typeck_find_func_index_in_module_by_name_strict_minimal(mod: *u8, name: *u8, name_len: i32, want_arity: i32): i32 {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (name_len <= 0) { return 0 - 1; }
  unsafe {
    let first_match: i32 = 0 - 1;
    let n: i32 = pipeline_module_num_funcs(mod);
    let j: i32 = 0;
    while (j < n) {
      if (pipeline_module_func_name_equal_at(mod, j, name, name_len) != 0) {
        if (first_match < 0) { first_match = j; }
        if (want_arity >= 0) {
          if (pipeline_module_func_num_params_at(mod, j) == want_arity) { return j; }
        }
      }
      j = j + 1;
    }
    return first_match;
  }
  return 0 - 1;
}

// G-02f-140：按名找返回类型；from_dep_index>=0 时映射到 caller arena
#[no_mangle]
function pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(
  mod: *u8, caller_arena: *u8, name: *u8, name_len: i32, from_dep_index: i32, want_arity: i32, ctx: *u8, func_index_out: *i32
): i32 {
  unsafe {
    let func_ix: i32 = pipeline_typeck_find_func_index_in_module_by_name_strict_minimal(mod, name, name_len, want_arity);
    if (func_ix < 0) { return 0; }
    if (func_index_out != 0) {
      func_index_out[0] = func_ix;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(mod, func_ix);
    if (from_dep_index < 0) { return ret_ty; }
    return pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index, ret_ty, caller_arena, ctx);
  }
  return 0;
}

// G-02f-140：import binding 限定名 → caller arena TYPE_NAMED
#[no_mangle]
function pipeline_typeck_map_import_binding_named_to_caller_strict_minimal(
  entry_mod: *u8, dep_ix: i32, caller_arena: *u8, nm: *u8, nlen: i32
): i32 {
  if (caller_arena == 0) { return 0; }
  if (nm == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    if (entry_mod == 0) {
      return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
    }
    if (dep_ix < 0) {
      return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
    }
    if (pipeline_module_import_kind_at(entry_mod, dep_ix) != 1) {
      return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
    }
    let bl: i32 = pipeline_module_import_binding_name_len(entry_mod, dep_ix);
    if (bl <= 0) {
      return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
    }
    if (bl + 1 + nlen > 63) {
      return pipeline_type_find_or_alloc_named(caller_arena, nm, nlen);
    }
    let qnm: u8[64] = [];
    let i: i32 = 0;
    while (i < bl) {
      qnm[i] = pipeline_module_import_binding_name_byte_at(entry_mod, dep_ix, i);
      i = i + 1;
    }
    qnm[bl] = 46; // '.'
    let k: i32 = 0;
    while (k < nlen) {
      qnm[bl + 1 + k] = nm[k];
      k = k + 1;
    }
    let qlen: i32 = bl + 1 + nlen;
    return pipeline_type_find_or_alloc_named(caller_arena, &qnm[0], qlen);
  }
  return 0;
}

// public 实现于 seed C（全局 moved 表）；.x 仅锚点/文档（无薄 _impl）

// G-02f-139：两 SLICE region label 均有且不等 → conflict
#[no_mangle]
function pipeline_typeck_slice_region_conflict_strict_minimal(arena: *u8, expect_ref: i32, src_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (expect_ref <= 0) { return 0; }
  if (src_ref <= 0) { return 0; }
  unsafe {
    // TYPE_SLICE=11
    if (pipeline_type_kind_ord_at(arena, expect_ref) != 11) { return 0; }
    if (pipeline_type_kind_ord_at(arena, src_ref) != 11) { return 0; }
    let ek: i32 = pipeline_type_region_label_len_at(arena, expect_ref);
    let sk: i32 = pipeline_type_region_label_len_at(arena, src_ref);
    if (ek <= 0) { return 0; }
    if (sk <= 0) { return 0; }
    let eb: u8[64] = [];
    let sb: u8[64] = [];
    if (pipeline_type_region_label_into(arena, expect_ref, &eb[0]) != ek) { return 0; }
    if (pipeline_type_region_label_into(arena, src_ref, &sb[0]) != sk) { return 0; }
    if (ek != sk) { return 1; }
    let i: i32 = 0;
    while (i < ek) {
      if (eb[i] != sb[i]) { return 1; }
      i = i + 1;
    }
  }
  return 0;
}

// G-02f-135：SLICE=11；src 有 region 而 expect 无 → escape
#[no_mangle]
function pipeline_typeck_slice_region_escape_strict_minimal(arena: *u8, expect_ref: i32, src_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (expect_ref <= 0) { return 0; }
  if (src_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, expect_ref) != 11) { return 0; }
    if (pipeline_type_kind_ord_at(arena, src_ref) != 11) { return 0; }
    let sl: i32 = pipeline_type_region_label_len_at(arena, src_ref);
    let el: i32 = pipeline_type_region_label_len_at(arena, expect_ref);
    if (sl > 0) {
      if (el <= 0) { return 1; }
    }
  }
  return 0;
}

// G-02f-140：expr 诊断行列
#[no_mangle]
function pipeline_typeck_expr_diag_line_col_strict_minimal(arena: *u8, expr_ref: i32, line: *i32, col: *i32): void {
  if (line != 0) { line[0] = 0; }
  if (col != 0) { col[0] = 0; }
  if (arena == 0) { return; }
  if (expr_ref <= 0) { return; }
  unsafe {
    if (line != 0) { line[0] = pipeline_expr_line_at(arena, expr_ref); }
    if (col != 0) { col[0] = pipeline_expr_col_at(arena, expr_ref); }
  }
}

// G-02f-142：block 祖先链；ast_Block.parent_block_ref @ offset 88（22×i32）
function g02f_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

#[no_mangle]
function typeck_block_is_strict_ancestor_strict_minimal(arena: *u8, ancestor: i32, descendant: i32): i32 {
  if (arena == 0) { return 0; }
  if (ancestor <= 0) { return 0; }
  if (descendant <= 0) { return 0; }
  if (ancestor == descendant) { return 0; }
  unsafe {
    let cur: i32 = descendant;
    let depth: i32 = 0;
    while (cur > 0) {
      if (depth >= 128) { break; }
      let bp: *u8 = pipeline_arena_block_ptr(arena, cur);
      if (bp == 0) { break; }
      let parent: i32 = g02f_load_i32_le(bp, 88);
      if (parent == ancestor) { return 1; }
      cur = parent;
      depth = depth + 1;
    }
  }
  return 0;
}

// G-02f-140：lval 根 VAR 名；FIELD_ACCESS=44 INDEX=47 VAR=3
#[no_mangle]
function typeck_expr_lval_root_var_strict_minimal(arena: *u8, expr_ref: i32, out: *u8, out_len: *i32): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  if (out == 0) { return 0; }
  if (out_len == 0) { return 0; }
  unsafe {
    let cur: i32 = expr_ref;
    while (1 == 1) {
      let kind: i32 = pipeline_expr_kind_ord_at(arena, cur);
      if (kind == 3) {
        let nlen: i32 = pipeline_expr_var_name_len(arena, cur);
        out_len[0] = nlen;
        if (nlen <= 0) { return 0; }
        if (nlen > 63) { return 0; }
        pipeline_expr_var_name_into(arena, cur, out);
        return 1;
      }
      if (kind == 44) {
        cur = pipeline_expr_field_access_base_ref(arena, cur);
      } else {
        if (kind == 47) {
          cur = pipeline_expr_index_base_ref(arena, cur);
        } else {
          return 0;
        }
      }
      if (cur <= 0) { return 0; }
    }
  }
  return 0;
}

// G-02f-141：名是否块局部 let（非形参）
#[no_mangle]
function typeck_name_is_block_local_strict_minimal(module: *u8, arena: *u8, ctx: *u8, name: *u8, name_len: i32): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  unsafe {
    let func_ix: i32 = pipeline_dep_ctx_current_func_index(ctx);
    if (func_ix >= 0) {
      if (pipeline_module_func_param_type_ref_for_name(module, func_ix, name, name_len) > 0) {
        return 0;
      }
    }
    let site_block: i32 = pipeline_dep_ctx_current_block_ref_at(ctx);
    if (site_block <= 0) {
      if (func_ix >= 0) {
        site_block = pipeline_module_func_body_ref_at(module, func_ix);
      }
    }
    if (site_block <= 0) { return 0; }
    if (pipeline_block_find_var_decl_block_ref(arena, site_block, name, name_len) > 0) {
      return 1;
    }
  }
  return 0;
}

// G-02f-141：&block_local；ADDR_OF=51
#[no_mangle]
function typeck_expr_is_addr_of_block_local_strict_minimal(module: *u8, arena: *u8, ctx: *u8, expr_ref: i32): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 51) { return 0; }
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0) { return 0; }
    let vbuf: u8[64] = [];
    let vlen: i32 = 0;
    if (typeck_expr_lval_root_var_strict_minimal(arena, op_ref, &vbuf[0], &vlen) == 0) {
      return 0;
    }
    return typeck_name_is_block_local_strict_minimal(module, arena, ctx, &vbuf[0], vlen);
  }
  return 0;
}


// G-02f-110：+ dep_return/const_expr/result_payload/debug_propagate 薄门闩。
// G-02f-141：dep_return_type 真迁 .x
// G-02f-155：debug_try_propagate 折叠 seed _impl；curl/system 体仍在 seed（语言限制）

extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, er: i32, i: i32): i32;
extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, er: i32): i32;

// G-02f-143：从 char** 槽读指针（64 位 LE）
function g02f_load_ptr_at(p: *u8, off: i32): *u8 {
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

/* ---- G-02f-110 / G-02f-140 / G-02f-141：pipeline remaining typeck ---- */

// 产品路径链 seed C（含 getenv/fopen/curl/system）；.x 仅逻辑锚点 / 签名对齐
#[no_mangle]
function debug_try_propagate_report_strict_minimal(arena: *u8, er: i32, fi: i32, rt: i32, f: i32): void {
  let _a: *u8 = arena;
  let _e: i32 = er;
  let _f: i32 = fi;
  let _r: i32 = rt;
  let _x: i32 = f;
  if (_a == 0) { return; }
  if (_e == 0 - 1) { return; }
  if (_f == 0 - 1) { return; }
  if (_r == 0 - 1) { return; }
  if (_x == 0 - 1) { return; }
  // seed 实现启用 SHUX_DEBUG_RESULT_TRY 时上报；此处 no-op
}

// G-02f-141：dep 返回类型映射到 caller arena
// TYPE: I32=0 BOOL=1 U8=2 U32=3 U64=4 I64=5 USIZE=6 ISIZE=7 NAMED=8 PTR=9 ARRAY=10 SLICE=11 LINEAR=12 VECTOR=13 F32=14 F64=15 VOID=16
#[no_mangle]
function pipeline_typeck_dep_return_type_to_caller_strict_minimal(dep_arena: *u8, dep_return_type_ref: i32, caller_arena: *u8): i32 {
  if (dep_return_type_ref <= 0) { return 0; }
  if (dep_arena == 0) { return 0; }
  if (caller_arena == 0) { return 0; }
  unsafe {
    let kind: i32 = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
    if (kind < 0) { return 0; }
    // scalar kinds
    if (kind == 0) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 1) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 2) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 3) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 4) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 5) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 6) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 7) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 14) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 15) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 16) { return pipeline_type_ensure_by_kind_ord(caller_arena, kind); }
    if (kind == 8) {
      let nm: u8[64] = [];
      let nlen: i32 = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, &nm[0]);
      if (nlen <= 0) { return 0; }
      return pipeline_type_find_or_alloc_named(caller_arena, &nm[0], nlen);
    }
    let elem_ref: i32 = pipeline_type_elem_ref_at(dep_arena, dep_return_type_ref);
    let inner_mapped: i32 = 0;
    if (elem_ref > 0) {
      inner_mapped = pipeline_typeck_dep_return_type_to_caller_strict_minimal(dep_arena, elem_ref, caller_arena);
      if (inner_mapped == 0) { return 0; }
    }
    let array_size: i32 = pipeline_type_array_size_at(dep_arena, dep_return_type_ref);
    if (kind == 11) {
      let rlen: i32 = pipeline_type_region_label_len_at(dep_arena, dep_return_type_ref);
      let rbuf: u8[64] = [];
      if (rlen > 0) {
        pipeline_type_region_label_into(dep_arena, dep_return_type_ref, &rbuf[0]);
        return pipeline_type_find_or_alloc_slice(caller_arena, inner_mapped, &rbuf[0], rlen);
      }
      return pipeline_type_find_or_alloc_slice(caller_arena, inner_mapped, 0 as *u8, 0);
    }
    if (kind == 9) {
      return pipeline_type_find_or_alloc_compound(caller_arena, 9, inner_mapped, 0);
    }
    if (kind == 13) {
      return pipeline_type_find_or_alloc_compound(caller_arena, 13, inner_mapped, array_size);
    }
    if (kind == 10) {
      if (elem_ref <= 0) { return 0; }
      if (array_size <= 0) { return 0; }
      return pipeline_type_find_or_alloc_compound(caller_arena, 10, inner_mapped, array_size);
    }
    if (elem_ref > 0) { return 0; }
    if (array_size != 0) { return 0; }
    let nm2: u8[64] = [];
    let nlen2: i32 = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, &nm2[0]);
    if (nlen2 != 0) { return 0; }
    return pipeline_type_ensure_by_kind_ord(caller_arena, kind);
  }
  return 0;
}

// G-02f-143：常量表达式判定；const_names 为 *u8 数组（char** LE 槽）
// LIT=0 FLOAT=1 BOOL=2 VAR=3 ADD..LOGOR=4..21 NEG=22 BITNOT=23 LOGNOT=24 ARRAY_LIT=46
#[no_mangle]
function pipeline_typeck_const_expr_ref_strict_minimal(arena: *u8, expr_ref: i32, const_names: *u8, n_const_names: i32): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == 0) { return 1; }
    if (kind == 1) { return 1; }
    if (kind == 2) { return 1; }
    if (kind == 3) {
      let name_len: i32 = pipeline_expr_var_name_len(arena, expr_ref);
      if (name_len <= 0) { return 0; }
      if (name_len > 63) { return 0; }
      let name_buf: u8[64] = [];
      pipeline_expr_var_name_into(arena, expr_ref, &name_buf[0]);
      if (const_names == 0) { return 0; }
      let i: i32 = 0;
      while (i < n_const_names) {
        // const_names[i] 指针槽 @ i*8
        let lit: *u8 = g02f_load_ptr_at(const_names, i * 8);
        if (lit != 0) {
          if (pipeline_typeck_const_name_matches_strict_minimal(&name_buf[0], name_len, lit) != 0) {
            return 1;
          }
        }
        i = i + 1;
      }
      return 0;
    }
    if (kind >= 4) {
      if (kind <= 21) {
        let L: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
        let R: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
        if (pipeline_typeck_const_expr_ref_strict_minimal(arena, L, const_names, n_const_names) == 0) {
          return 0;
        }
        return pipeline_typeck_const_expr_ref_strict_minimal(arena, R, const_names, n_const_names);
      }
    }
    if (kind == 22) {
      return pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), const_names, n_const_names);
    }
    if (kind == 23) {
      return pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), const_names, n_const_names);
    }
    if (kind == 24) {
      return pipeline_typeck_const_expr_ref_strict_minimal(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), const_names, n_const_names);
    }
    if (kind == 46) {
      let ne: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      let j: i32 = 0;
      while (j < ne) {
        let el: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, j);
        if (pipeline_typeck_const_expr_ref_strict_minimal(arena, el, const_names, n_const_names) == 0) {
          return 0;
        }
        j = j + 1;
      }
      return 1;
    }
  }
  return 0;
}

// G-02f-140：Result_<payload> → payload type ref；prefix "Result_"=7
// TYPE_I32=0 BOOL=1 U8=2 U64=4 I64=5 USIZE=6 ISIZE=7
#[no_mangle]
function pipeline_typeck_result_payload_type_from_name_strict_minimal(arena: *u8, name: *u8, name_len: i32): i32 {
  if (arena == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  if (name_len < 7) { return 0; }
  // "Result_"
  if (name[0] != 82) { return 0; }
  if (name[1] != 101) { return 0; }
  if (name[2] != 115) { return 0; }
  if (name[3] != 117) { return 0; }
  if (name[4] != 108) { return 0; }
  if (name[5] != 116) { return 0; }
  if (name[6] != 95) { return 0; }
  let suffix_off: i32 = 7;
  let suffix_len: i32 = name_len - suffix_off;
  unsafe {
    // i32
    if (suffix_len == 3) {
      if (name[suffix_off] == 105) {
        if (name[suffix_off + 1] == 51) {
          if (name[suffix_off + 2] == 50) {
            return pipeline_type_ensure_by_kind_ord(arena, 0);
          }
        }
      }
    }
    // u8
    if (suffix_len == 2) {
      if (name[suffix_off] == 117) {
        if (name[suffix_off + 1] == 56) {
          return pipeline_type_ensure_by_kind_ord(arena, 2);
        }
      }
    }
    // i64
    if (suffix_len == 3) {
      if (name[suffix_off] == 105) {
        if (name[suffix_off + 1] == 54) {
          if (name[suffix_off + 2] == 52) {
            return pipeline_type_ensure_by_kind_ord(arena, 5);
          }
        }
      }
    }
    // u64
    if (suffix_len == 3) {
      if (name[suffix_off] == 117) {
        if (name[suffix_off + 1] == 54) {
          if (name[suffix_off + 2] == 52) {
            return pipeline_type_ensure_by_kind_ord(arena, 4);
          }
        }
      }
    }
    // usize
    if (suffix_len == 5) {
      if (name[suffix_off] == 117) {
        if (name[suffix_off + 1] == 115) {
          if (name[suffix_off + 2] == 105) {
            if (name[suffix_off + 3] == 122) {
              if (name[suffix_off + 4] == 101) {
                return pipeline_type_ensure_by_kind_ord(arena, 6);
              }
            }
          }
        }
      }
    }
    // isize
    if (suffix_len == 5) {
      if (name[suffix_off] == 105) {
        if (name[suffix_off + 1] == 115) {
          if (name[suffix_off + 2] == 105) {
            if (name[suffix_off + 3] == 122) {
              if (name[suffix_off + 4] == 101) {
                return pipeline_type_ensure_by_kind_ord(arena, 7);
              }
            }
          }
        }
      }
    }
    // bool
    if (suffix_len == 4) {
      if (name[suffix_off] == 98) {
        if (name[suffix_off + 1] == 111) {
          if (name[suffix_off + 2] == 111) {
            if (name[suffix_off + 3] == 108) {
              return pipeline_type_ensure_by_kind_ord(arena, 1);
            }
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-113：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

// ast_ExprKind: EXPR_ASSIGN=28, EXPR_ADD_ASSIGN=29, EXPR_SHR_ASSIGN=38
#[no_mangle]
function pipeline_typeck_expr_is_any_assign_kind_strict_minimal(kind: i32): i32 {
  if (kind == 28) {
    return 1;
  }
  if (kind >= 29) {
    if (kind <= 38) {
      return 1;
    }
  }
  return 0;
}

// G-02f-117：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

#[no_mangle]
function pipeline_typeck_const_name_matches_strict_minimal(name: *u8, name_len: i32, lit: *u8): i32 {
  if (name == 0) { return 0; }
  if (lit == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  let i: i32 = 0;
  while (i < name_len) {
    if (lit[i] == 0) { return 0; }
    if (name[i] != lit[i]) { return 0; }
    i = i + 1;
  }
  if (lit[name_len] != 0) { return 0; }
  return 1;
}

// G-02f-119：named_unqual_offset 真迁 .x

#[no_mangle]
function pipeline_typeck_named_unqual_offset_strict_minimal(buf: *u8, len: i32): i32 {
  let i: i32 = len - 1;
  while (i > 0) {
    if (buf[i] == 46) { return i + 1; } // '.'
    i = i - 1;
  }
  return 0;
}

// G-02f-123：field_name_equal_strict_minimal 真迁 .x

#[no_mangle]
function field_name_equal_strict_minimal(buf: *u8, len: i32, lit: *u8): i32 {
  if (buf == 0) { return 0; }
  if (lit == 0) { return 0; }
  if (len <= 0) { return 0; }
  let i: i32 = 0;
  while (i < len) {
    if (lit[i] == 0) { return 0; }
    if (buf[i] != lit[i]) { return 0; }
    i = i + 1;
  }
  if (lit[len] != 0) { return 0; }
  return 1;
}

extern "C" function parser_parse_into_init(module: *u8, arena: *u8): void;
extern "C" function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_call_callee_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_apply_call_resolve(arena: *u8, call_er: i32, dep: i32, fi: i32): void;
extern "C" function typeck_typeck_struct_layout_metrics(module: *u8, arena: *u8, li: i32, depth: i32, flags: i32, out_sz: *i32, out_al: *i32): i32;
extern "C" function pipeline_typeck_type_refs_equal_c(arena: *u8, a: i32, b: i32): i32;
extern "C" function driver_run_compiler_full(argc: i32, argv: *u8): i32;

/* ---- G-02f-210：pure weak / residual shells ---- */

// G-02f-210：parse bridge
#[no_mangle]
function parse_into_init(module: *u8, arena: *u8): void {
  if (module == 0) { return; }
  if (arena == 0) { return; }
  unsafe {
    parser_parse_into_init(module, arena);
  }
}

// G-02f-210：&var / &field / &index → lvalue eff addr；否则 -99
#[no_mangle]
function pipeline_asm_emit_addr_of_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0 - 1; }
  if (elf_ctx == 0) { return 0 - 1; }
  if (ctx == 0) { return 0 - 1; }
  if (expr_ref <= 0) { return 0 - 1; }
  unsafe {
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0) { return 0 - 1; }
    let op_kind: i32 = pipeline_expr_kind_ord_at(arena, op_ref);
    // EXPR_VAR=3 FIELD=44 INDEX=47
    if (op_kind == 3) {
      return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op_ref, ctx, ta);
    }
    if (op_kind == 44) {
      return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op_ref, ctx, ta);
    }
    if (op_kind == 47) {
      return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op_ref, ctx, ta);
    }
  }
  return 0 - 99;
}

// G-02f-210：按 callee 名 resolve call 函数下标
#[no_mangle]
function pipeline_typeck_resolve_call_func_index_c(m: *u8, a: *u8, call_expr_ref: i32): i32 {
  if (m == 0) { return 0 - 1; }
  if (a == 0) { return 0 - 1; }
  if (call_expr_ref <= 0) { return 0 - 1; }
  unsafe {
    let fx: i32 = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
    if (fx >= 0) { return fx; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
    if (callee_ref <= 0) { return 0 - 1; }
    if (pipeline_expr_kind_ord_at(a, callee_ref) != 3) { return 0 - 1; }
    let callee_name_len: i32 = pipeline_expr_var_name_len(a, callee_ref);
    if (callee_name_len <= 0) { return 0 - 1; }
    if (callee_name_len > 63) { return 0 - 1; }
    let callee_name: u8[64] = [];
    pipeline_expr_var_name_into(a, callee_ref, &callee_name[0]);
    let i: i32 = 0;
    let n: i32 = pipeline_module_num_funcs(m);
    while (i < n) {
      if (pipeline_module_func_name_equal_at(m, i, &callee_name[0], callee_name_len) != 0) {
        pipeline_expr_apply_call_resolve(a, call_expr_ref, 0 - 1, i);
        return i;
      }
      i = i + 1;
    }
  }
  return 0 - 1;
}

#[no_mangle]
function pipeline_typeck_resolve_call_func_index_for_emit_c(m: *u8, a: *u8, call_expr_ref: i32): i32 {
  return pipeline_typeck_resolve_call_func_index_c(m, a, call_expr_ref);
}

// G-02f-210：空 array lit 初值？
#[no_mangle]
function pipeline_asm_init_is_empty_array_lit_c(arena: *u8, init_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (init_ref <= 0) { return 0; }
  unsafe {
    // EXPR_ARRAY_LIT=46
    if (pipeline_expr_kind_ord_at(arena, init_ref) != 46) { return 0; }
    if (pipeline_expr_array_lit_num_elems_at(arena, init_ref) == 0) { return 1; }
  }
  return 0;
}

// G-02f-210：layout metrics → size/align glue
#[no_mangle]
function typeck_x_type_size_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32 {
  if (li < 0) { return 0; }
  unsafe {
    let sz: i32 = 0;
    let al: i32 = 1;
    if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &sz, &al) != 0) { return 0; }
    return sz;
  }
  return 0;
}

#[no_mangle]
function typeck_x_type_align_from_layout_glue(module: *u8, arena: *u8, li: i32, depth: i32): i32 {
  if (li < 0) { return 1; }
  unsafe {
    let sz: i32 = 0;
    let al: i32 = 1;
    if (typeck_typeck_struct_layout_metrics(module, arena, li, depth, 0, &sz, &al) != 0) { return 1; }
    if (al > 0) { return al; }
  }
  return 1;
}

// G-02f-210：read_ptr_slice 返回类型 []u8 @io_read_ptr
#[no_mangle]
function pipeline_typeck_read_ptr_slice_return_ref_c(arena: *u8): i32 {
  if (arena == 0) { return 0; }
  unsafe {
    // TYPE_U8=2
    let u8_ref: i32 = pipeline_type_ensure_by_kind_ord(arena, 2);
    if (u8_ref <= 0) { return 0; }
    // "io_read_ptr" 11 bytes
    let lbl: u8[16] = [];
    lbl[0] = 105; lbl[1] = 111; lbl[2] = 95; lbl[3] = 114; lbl[4] = 101;
    lbl[5] = 97; lbl[6] = 100; lbl[7] = 95; lbl[8] = 112; lbl[9] = 116;
    lbl[10] = 114; lbl[11] = 0;
    return pipeline_type_find_or_alloc_slice(arena, u8_ref, &lbl[0], 11);
  }
  return 0;
}

// G-02f-210：linear init 接受（decl LINEAR 且 refs equal 或 elem equal）
#[no_mangle]
function pipeline_typeck_linear_accepts_init_c(arena: *u8, decl_ref: i32, init_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (decl_ref <= 0) { return 0; }
  if (init_ref <= 0) { return 0; }
  unsafe {
    // TYPE_LINEAR=12
    if (pipeline_type_kind_ord_at(arena, decl_ref) != 12) { return 0; }
    if (pipeline_typeck_type_refs_equal_c(arena, decl_ref, init_ref) != 0) { return 1; }
    let elem: i32 = pipeline_type_elem_ref_at(arena, decl_ref);
    return pipeline_typeck_type_refs_equal_c(arena, elem, init_ref);
  }
  return 0;
}

// G-02f-210：layout warn noops
#[no_mangle]
function pipeline_typeck_pad_fields_warn_layout(module: *u8, arena: *u8, li: i32): void {
  return;
}

#[no_mangle]
function pipeline_typeck_hot_reorder_warn_layout(module: *u8, arena: *u8, li: i32): void {
  return;
}

#[no_mangle]
function pipeline_type_stamp_block_let_region_c(arena: *u8, block_ref: i32, let_idx: i32, ctx: *u8): i32 {
  return 0;
}

#[no_mangle]
function pipeline_typeck_check_allocator_region_assign_c(module: *u8, arena: *u8, site_expr_ref: i32, left_ref: i32, ctx: *u8): i32 {
  return 0;
}

// G-02f-210：codegen_x_ast stub
#[no_mangle]
function codegen_x_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8, dep_index: i32): i32 {
  return 0 - 1;
}

// G-02f-210：main entry thin bridges
#[no_mangle]
function main_entry(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, argv);
  }
  return 0 - 1;
}

#[no_mangle]
function main_run_compiler_c(argc: i32, argv: *u8): i32 {
  unsafe {
    return driver_run_compiler_full(argc, argv);
  }
  return 0 - 1;
}
