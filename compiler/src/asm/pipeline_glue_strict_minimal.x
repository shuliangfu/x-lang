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
/* defined G-02f-221 */
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
/* get_dep_return defined G-02f-220 below */
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

/* ---- G-02f-216：pipeline_glue 中等 pure（import_sym / read_ptr / coerce / one_region / thin） ---- */

extern "C" function pipeline_expr_set_resolved_type_ref(arena: *u8, er: i32, ty: i32): void;
extern "C" function pipeline_block_region_body_ref(arena: *u8, br: i32, idx: i32): i32;
extern "C" function typeck_check_block(module: *u8, arena: *u8, body_ref: i32, return_type_ref: i32, ctx: *u8): i32;
/* defined G-02f-221 */
extern "C" function pipeline_lsp_diag_parse_typeck_buf_impl_c(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32;
extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_int64_val_at(arena: *u8, er: i32): i64;

// G-02f-216 内部：name[0..name_len) 与 lit[0..lit_len) 全等
function glue_name_bytes_eq_c(name: *u8, name_len: i32, lit: *u8, lit_len: i32): i32 {
  if (name == 0) { return 0; }
  if (lit == 0) { return 0; }
  if (name_len != lit_len) { return 0; }
  if (name_len <= 0) { return 0; }
  let i: i32 = 0;
  while (i < name_len) {
    if (name[i] != lit[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

// G-02f-216：import binding 符号名 = prefix? + field（同前缀则不重复）
#[no_mangle]
function pipeline_asm_build_import_binding_call_sym_c(pre: *u8, pre_len: i32, field_name: *u8, field_len: i32, out_name: *u8): i32 {
  if (field_name == 0) { return 0 - 1; }
  if (field_len <= 0) { return 0 - 1; }
  if (out_name == 0) { return 0 - 1; }
  let pos: i32 = 0;
  let pi: i32 = 0;
  let same_prefix: i32 = 0;
  if (pre != 0) {
    if (pre_len > 0) {
      if (field_len >= pre_len) {
        same_prefix = 1;
        pi = 0;
        while (pi < pre_len) {
          if (field_name[pi] != pre[pi]) {
            same_prefix = 0;
            pi = pre_len;
          } else {
            pi = pi + 1;
          }
        }
      }
    }
  }
  pi = 0;
  if (pre != 0) {
    if (pre_len > 0) {
      if (same_prefix == 0) {
        while (pi < pre_len) {
          if (pos < 63) {
            out_name[pos] = pre[pi];
            pos = pos + 1;
            pi = pi + 1;
          } else {
            pi = pre_len;
          }
        }
      }
    }
  }
  pi = 0;
  while (pi < field_len) {
    if (pos < 63) {
      out_name[pos] = field_name[pi];
      pos = pos + 1;
      pi = pi + 1;
    } else {
      pi = field_len;
    }
  }
  if (pos <= 0) { return 0 - 1; }
  return pos;
}

// G-02f-216：read_ptr_slice 族 callee 名匹配（字节比较；用字面量完整长度）
#[no_mangle]
function pipeline_typeck_is_read_ptr_slice_callee_c(name: *u8, name_len: i32): i32 {
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  // "read_ptr_slice" 14
  let n0: u8[16] = [];
  n0[0] = 114; n0[1] = 101; n0[2] = 97; n0[3] = 100; n0[4] = 95;
  n0[5] = 112; n0[6] = 116; n0[7] = 114; n0[8] = 95; n0[9] = 115;
  n0[10] = 108; n0[11] = 105; n0[12] = 99; n0[13] = 101; n0[14] = 0;
  if (glue_name_bytes_eq_c(name, name_len, &n0[0], 14) != 0) { return 1; }
  // "shux_io_read_ptr_slice" 22
  let n1: u8[24] = [];
  n1[0] = 115; n1[1] = 104; n1[2] = 117; n1[3] = 120; n1[4] = 95;
  n1[5] = 105; n1[6] = 111; n1[7] = 95; n1[8] = 114; n1[9] = 101;
  n1[10] = 97; n1[11] = 100; n1[12] = 95; n1[13] = 112; n1[14] = 116;
  n1[15] = 114; n1[16] = 95; n1[17] = 115; n1[18] = 108; n1[19] = 105;
  n1[20] = 99; n1[21] = 101; n1[22] = 0;
  if (glue_name_bytes_eq_c(name, name_len, &n1[0], 22) != 0) { return 1; }
  // "driver_read_ptr_slice" 21
  let n2: u8[24] = [];
  n2[0] = 100; n2[1] = 114; n2[2] = 105; n2[3] = 118; n2[4] = 101;
  n2[5] = 114; n2[6] = 95; n2[7] = 114; n2[8] = 101; n2[9] = 97;
  n2[10] = 100; n2[11] = 95; n2[12] = 112; n2[13] = 116; n2[14] = 114;
  n2[15] = 95; n2[16] = 115; n2[17] = 108; n2[18] = 105; n2[19] = 99;
  n2[20] = 101; n2[21] = 0;
  if (glue_name_bytes_eq_c(name, name_len, &n2[0], 21) != 0) { return 1; }
  // "io_read_ptr_slice" 17
  let n3: u8[20] = [];
  n3[0] = 105; n3[1] = 111; n3[2] = 95; n3[3] = 114; n3[4] = 101;
  n3[5] = 97; n3[6] = 100; n3[7] = 95; n3[8] = 112; n3[9] = 116;
  n3[10] = 114; n3[11] = 95; n3[12] = 115; n3[13] = 108; n3[14] = 105;
  n3[15] = 99; n3[16] = 101; n3[17] = 0;
  if (glue_name_bytes_eq_c(name, name_len, &n3[0], 17) != 0) { return 1; }
  // 兼容 seed 历史短 len 检查（19/18/16 前缀）
  if (name_len == 19) {
    if (glue_name_bytes_eq_c(name, 19, &n1[0], 19) != 0) { return 1; }
  }
  if (name_len == 18) {
    if (glue_name_bytes_eq_c(name, 18, &n2[0], 18) != 0) { return 1; }
  }
  if (name_len == 16) {
    if (glue_name_bytes_eq_c(name, 16, &n3[0], 16) != 0) { return 1; }
  }
  return 0;
}

// G-02f-216：i8/i16 TYPE_NAMED + binop/NEG 初值 → 强制 resolved 为 decl
// TYPE: I32=0 U64=4 I64=5 USIZE=6 NAMED=8
// EXPR: ADD=4 SUB=5 MUL=6 DIV=7 NEG=22
#[no_mangle]
function pipeline_typeck_coerce_init_int_binop_to_decl_c(arena: *u8, init_ref: i32, decl_ty_ref: i32, decl_kind: i32, init_kind: i32): i32 {
  if (arena == 0) { return 0; }
  if (init_ref <= 0) { return 0; }
  if (decl_kind != 0) {
    if (decl_kind != 4) {
      if (decl_kind != 5) {
        if (decl_kind != 6) {
          if (decl_kind != 8) { return 0; }
        }
      }
    }
  }
  if (init_kind != 4) {
    if (init_kind != 5) {
      if (init_kind != 6) {
        if (init_kind != 7) {
          if (init_kind != 22) { return 0; }
        }
      }
    }
  }
  if (decl_kind == 8) {
    unsafe {
      let nm: u8[64] = [];
      let nlen: i32 = pipeline_type_named_name_into(arena, decl_ty_ref, &nm[0]);
      // "i8" = [105,56] len2; "i16" = [105,49,54] len3
      let ok: i32 = 0;
      if (nlen == 2) {
        if (nm[0] == 105) {
          if (nm[1] == 56) { ok = 1; }
        }
      }
      if (nlen == 3) {
        if (nm[0] == 105) {
          if (nm[1] == 49) {
            if (nm[2] == 54) { ok = 1; }
          }
        }
      }
      if (ok == 0) { return 0; }
    }
  }
  unsafe {
    pipeline_expr_set_resolved_type_ref(arena, init_ref, decl_ty_ref);
  }
  return 1;
}

// G-02f-216：单 region body → typeck_check_block
#[no_mangle]
function pipeline_typeck_check_block_one_region_c(module: *u8, arena: *u8, block_ref: i32, region_idx: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (block_ref <= 0) { return 0; }
  if (region_idx < 0) { return 0; }
  unsafe {
    let body_ref: i32 = pipeline_block_region_body_ref(arena, block_ref, region_idx);
    if (body_ref <= 0) { return 0; }
    return typeck_check_block(module, arena, body_ref, return_type_ref, ctx);
  }
  return 0;
}

// G-02f-216：after_parse_ok thin → impl
#[no_mangle]
function pipeline_typeck_after_parse_ok(arena: *u8, module: *u8, source: *u8, ctx: *u8): i32 {
  unsafe {
    return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
  }
  return 0 - 1;
}

// G-02f-216：lsp diag parse+typeck thin → impl
#[no_mangle]
function pipeline_lsp_diag_parse_typeck_buf(module: *u8, arena: *u8, source_data: *u8, source_len: i32, ctx: *u8): i32 {
  unsafe {
    return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
  }
  return 0 - 1;
}

// G-02f-216：int lit 未 resolve 时按 i32/i64 范围设类型
// INT32_MAX=2147483647 INT32_MIN=-2147483648
#[no_mangle]
function pipeline_typeck_check_expr_int_lit_c(arena: *u8, expr_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_resolved_type_ref(arena, expr_ref) != 0) { return 0; }
    let value: i64 = pipeline_expr_int64_val_at(arena, expr_ref);
    let imax: i64 = 2147483647;
    let imin: i64 = 0 - 2147483647;
    imin = imin - 1;
    let ty: i32 = 0;
    if (value > imax) {
      // TYPE_I64=5
      ty = pipeline_type_ensure_by_kind_ord(arena, 5);
    } else {
      if (value < imin) {
        ty = pipeline_type_ensure_by_kind_ord(arena, 5);
      } else {
        // TYPE_I32=0
        ty = pipeline_type_ensure_by_kind_ord(arena, 0);
      }
    }
    if (ty > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ty);
    }
  }
  return 0;
}

/* ---- G-02f-217：reject linear / soa storage / const diag / scope borrow / stack escape ---- */

extern "C" function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, name: *u8, nlen: i32): i32;
extern "C" function typeck_x_type_size(module: *u8, arena: *u8, tr: i32, depth: i32): i32;
extern "C" function typeck_x_type_align(module: *u8, arena: *u8, tr: i32, depth: i32): i32;
extern "C" function typeck_entry_module_find_struct_layout_index(mod: *u8, nm: *u8, nlen: i32): i32;
extern "C" function pipeline_module_struct_layout_soa_at(mod: *u8, li: i32): i32;
extern "C" function pipeline_module_struct_layout_num_fields(mod: *u8, li: i32): i32;
extern "C" function pipeline_module_struct_layout_field_type_ref(mod: *u8, li: i32, j: i32): i32;
extern "C" function driver_diagnostic_typeck_linear_addr_of(line: i32, col: i32): void;
extern "C" function pipeline_module_func_param_type_ref_at(mod: *u8, fi: i32, pi: i32): i32;
extern "C" function lsp_diag_report_typeck(line: i32, col: i32, fmt: *u8): void;

// G-02f-217：&linear 拒绝（TYPE_LINEAR=12；EXPR_VAR=3）
#[no_mangle]
function pipeline_typeck_reject_addr_of_linear_c(arena: *u8, op_ref: i32, addr_expr_ref: i32, module: *u8, ctx: *u8): i32 {
  if (arena == 0) { return 0; }
  if (module == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (op_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, op_ref) != 3) { return 0; }
    let vnlen: i32 = pipeline_expr_var_name_len(arena, op_ref);
    if (vnlen <= 0) { return 0; }
    if (vnlen > 63) { return 0; }
    let vbuf: u8[64] = [];
    pipeline_expr_var_name_into(arena, op_ref, &vbuf[0]);
    let block_ref: i32 = pipeline_dep_ctx_current_block_ref_at(ctx);
    if (block_ref > 0) {
      let vd_tr: i32 = pipeline_block_resolve_var_type_ref(arena, block_ref, &vbuf[0], vnlen);
      if (vd_tr > 0) {
        if (pipeline_type_kind_ord_at(arena, vd_tr) == 12) {
          let line: i32 = 0;
          let col: i32 = 0;
          if (addr_expr_ref > 0) {
            line = pipeline_expr_line_at(arena, addr_expr_ref);
            col = pipeline_expr_col_at(arena, addr_expr_ref);
          }
          driver_diagnostic_typeck_linear_addr_of(line, col);
          return 0 - 1;
        }
      }
    }
    let func_ix: i32 = pipeline_dep_ctx_current_func_index(ctx);
    if (func_ix >= 0) {
      if (func_ix < pipeline_module_num_funcs(module)) {
        let pr: i32 = pipeline_module_func_param_type_ref_for_name(module, func_ix, &vbuf[0], vnlen);
        if (pr > 0) {
          if (pipeline_type_kind_ord_at(arena, pr) == 12) {
            let line2: i32 = 0;
            let col2: i32 = 0;
            if (addr_expr_ref > 0) {
              line2 = pipeline_expr_line_at(arena, addr_expr_ref);
              col2 = pipeline_expr_col_at(arena, addr_expr_ref);
            }
            driver_diagnostic_typeck_linear_addr_of(line2, col2);
            return 0 - 1;
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-217：SoA 数组布局存储字节（TYPE_NAMED=8）
#[no_mangle]
function typeck_soa_array_storage_size_glue(module: *u8, arena: *u8, elem_type_ref: i32, array_len: i32, depth: i32): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (elem_type_ref <= 0) { return 0; }
  if (array_len <= 0) { return 0; }
  if (depth > 64) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, elem_type_ref) != 8) { return 0; }
    let name: u8[64] = [];
    let nlen: i32 = pipeline_type_named_name_into(arena, elem_type_ref, &name[0]);
    if (nlen <= 0) { return 0; }
    let li: i32 = typeck_entry_module_find_struct_layout_index(module, &name[0], nlen);
    if (li < 0) { return 0; }
    if (pipeline_module_struct_layout_soa_at(module, li) == 0) { return 0; }
    let nf: i32 = pipeline_module_struct_layout_num_fields(module, li);
    let col: i32 = 0;
    let max_al: i32 = 1;
    let j: i32 = 0;
    while (j < nf) {
      let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, li, j);
      if (ftr > 0) {
        let al: i32 = typeck_x_type_align(module, arena, ftr, depth + 1);
        let fsize: i32 = typeck_x_type_size(module, arena, ftr, depth + 1);
        if (al <= 0) { al = 1; }
        if (fsize <= 0) { fsize = 4; }
        let rem: i32 = col % al;
        if (rem != 0) {
          col = col + (al - rem);
        }
        col = col + (array_len * fsize);
        if (al > max_al) { max_al = al; }
      }
      j = j + 1;
    }
    if (max_al > 1) {
      let rem2: i32 = col % max_al;
      if (rem2 != 0) {
        col = col + (max_al - rem2);
      }
    }
    if (col > 0) { return col; }
  }
  return 0;
}

// G-02f-217：const 初值非常量诊断
#[no_mangle]
function pipeline_typeck_const_init_not_constant_c(line: i32, col: i32): void {
  // "const init must be constant expression"
  let msg: u8[48] = [];
  msg[0] = 99; msg[1] = 111; msg[2] = 110; msg[3] = 115; msg[4] = 116;
  msg[5] = 32; msg[6] = 105; msg[7] = 110; msg[8] = 105; msg[9] = 116;
  msg[10] = 32; msg[11] = 109; msg[12] = 117; msg[13] = 115; msg[14] = 116;
  msg[15] = 32; msg[16] = 98; msg[17] = 101; msg[18] = 32; msg[19] = 99;
  msg[20] = 111; msg[21] = 110; msg[22] = 115; msg[23] = 116; msg[24] = 97;
  msg[25] = 110; msg[26] = 116; msg[27] = 32; msg[28] = 101; msg[29] = 120;
  msg[30] = 112; msg[31] = 114; msg[32] = 101; msg[33] = 115; msg[34] = 115;
  msg[35] = 105; msg[36] = 111; msg[37] = 110; msg[38] = 0;
  unsafe {
    lsp_diag_report_typeck(line, col, &msg[0]);
  }
}

// G-02f-217：scope borrow escape（&local 赋给外层左值）
#[no_mangle]
function pipeline_typeck_check_scope_borrow_assign_c(module: *u8, arena: *u8, site_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (left_ref <= 0) { return 0; }
  if (right_ref <= 0) { return 0; }
  unsafe {
    if (typeck_expr_is_addr_of_block_local_strict_minimal(module, arena, ctx, right_ref) == 0) { return 0; }
    let lname: u8[64] = [];
    let llen: i32 = 0;
    if (typeck_expr_lval_root_var_strict_minimal(arena, left_ref, &lname[0], &llen) == 0) { return 0; }
    // EXPR_ADDR_OF=51
    if (pipeline_expr_kind_ord_at(arena, right_ref) != 51) { return 0; }
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, right_ref);
    if (op_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, op_ref) != 3) { return 0; }
    let rlen: i32 = pipeline_expr_var_name_len(arena, op_ref);
    if (rlen <= 0) { return 0; }
    if (rlen > 63) { return 0; }
    let rname: u8[64] = [];
    pipeline_expr_var_name_into(arena, op_ref, &rname[0]);
    let site_block: i32 = pipeline_dep_ctx_current_block_ref_at(ctx);
    if (site_block <= 0) {
      let cfi: i32 = pipeline_dep_ctx_current_func_index(ctx);
      if (cfi >= 0) {
        site_block = pipeline_module_func_body_ref_at(module, cfi);
      }
    }
    if (site_block <= 0) { return 0; }
    let lblock: i32 = pipeline_block_find_var_decl_block_ref(arena, site_block, &lname[0], llen);
    let rblock: i32 = pipeline_block_find_var_decl_block_ref(arena, site_block, &rname[0], rlen);
    if (lblock <= 0) { return 0; }
    if (rblock <= 0) { return 0; }
    if (lblock == rblock) { return 0; }
    if (typeck_block_is_strict_ancestor_strict_minimal(arena, lblock, rblock) == 0) { return 0; }
    let line: i32 = 0;
    let col: i32 = 0;
    pipeline_typeck_expr_diag_line_col_strict_minimal(arena, site_expr_ref, &line, &col);
    // "scope borrow escape"
    let msg: u8[24] = [];
    msg[0] = 115; msg[1] = 99; msg[2] = 111; msg[3] = 112; msg[4] = 101;
    msg[5] = 32; msg[6] = 98; msg[7] = 111; msg[8] = 114; msg[9] = 114;
    msg[10] = 111; msg[11] = 119; msg[12] = 32; msg[13] = 101; msg[14] = 115;
    msg[15] = 99; msg[16] = 97; msg[17] = 112; msg[18] = 101; msg[19] = 0;
    lsp_diag_report_typeck(line, col, &msg[0]);
  }
  return 0 - 1;
}

// G-02f-217：struct stack escape（&local_struct 写入 param 指针字段）
// EXPR_ADDR_OF=51 EXPR_VAR=3 EXPR_FIELD_ACCESS=44 TYPE_PTR=9
#[no_mangle]
function pipeline_typeck_check_struct_stack_escape_assign_c(module: *u8, arena: *u8, site_expr_ref: i32, left_ref: i32, right_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (left_ref <= 0) { return 0; }
  if (right_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, right_ref) != 51) { return 0; }
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, right_ref);
    if (pipeline_expr_kind_ord_at(arena, op_ref) != 3) { return 0; }
    let name_len: i32 = pipeline_expr_var_name_len(arena, op_ref);
    if (name_len <= 0) { return 0; }
    if (name_len > 63) { return 0; }
    let name_buf: u8[64] = [];
    pipeline_expr_var_name_into(arena, op_ref, &name_buf[0]);
    let br: i32 = pipeline_dep_ctx_current_block_ref_at(ctx);
    if (br <= 0) { return 0; }
    if (pipeline_block_resolve_var_type_ref(arena, br, &name_buf[0], name_len) <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, left_ref) != 44) { return 0; }
    let base_ref: i32 = pipeline_expr_field_access_base_ref(arena, left_ref);
    let func_ix: i32 = pipeline_dep_ctx_current_func_index(ctx);
    if (func_ix < 0) { return 0; }
    let np: i32 = pipeline_module_func_num_params_at(module, func_ix);
    let pi: i32 = 0;
    while (pi < np) {
      if (pipeline_expr_is_func_param_at_strict_minimal(arena, module, func_ix, base_ref, pi) != 0) {
        let pty: i32 = pipeline_module_func_param_type_ref_at(module, func_ix, pi);
        if (pipeline_type_kind_ord_at(arena, pty) == 9) {
          let line: i32 = 0;
          let col: i32 = 0;
          if (site_expr_ref > 0) {
            line = pipeline_expr_line_at(arena, site_expr_ref);
            col = pipeline_expr_col_at(arena, site_expr_ref);
          }
          // "struct stack escape: cannot store address of local struct in outer lifetime"
          let t: u8[80] = [];
          t[0]=115;t[1]=116;t[2]=114;t[3]=117;t[4]=99;t[5]=116;t[6]=32;t[7]=115;
          t[8]=116;t[9]=97;t[10]=99;t[11]=107;t[12]=32;t[13]=101;t[14]=115;t[15]=99;
          t[16]=97;t[17]=112;t[18]=101;t[19]=58;t[20]=32;t[21]=99;t[22]=97;t[23]=110;
          t[24]=110;t[25]=111;t[26]=116;t[27]=32;t[28]=115;t[29]=116;t[30]=111;t[31]=114;
          t[32]=101;t[33]=32;t[34]=97;t[35]=100;t[36]=100;t[37]=114;t[38]=101;t[39]=115;
          t[40]=115;t[41]=32;t[42]=111;t[43]=102;t[44]=32;t[45]=108;t[46]=111;t[47]=99;
          t[48]=97;t[49]=108;t[50]=32;t[51]=115;t[52]=116;t[53]=114;t[54]=117;t[55]=99;
          t[56]=116;t[57]=32;t[58]=105;t[59]=110;t[60]=32;t[61]=111;t[62]=117;t[63]=116;
          t[64]=101;t[65]=114;t[66]=32;t[67]=108;t[68]=105;t[69]=102;t[70]=101;t[71]=116;
          t[72]=105;t[73]=109;t[74]=101;t[75]=0;
          lsp_diag_report_typeck(line, col, &t[0]);
          return 0 - 1;
        }
      }
      pi = pi + 1;
    }
  }
  return 0;
}

/* ---- G-02f-218：slice region assign/return/call + try_propagate ---- */

extern "C" function typeck_check_expr(module: *u8, arena: *u8, er: i32, ret_ty: i32, ctx: *u8): i32;
extern "C" function driver_diagnostic_typeck_try_propagate_bad_enclosing(line: i32, col: i32): void;
extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_call_num_args_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_call_arg_ref(arena: *u8, er: i32, idx: i32): i32;
extern "C" function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
extern "C" function lsp_diag_report_typeck(line: i32, col: i32, fmt: *u8): void;

// G-02f-218 内部：向 dst 追加 src[0..n)，返回新 pos
function glue_msg_append_c(dst: *u8, pos: i32, cap: i32, src: *u8, n: i32): i32 {
  if (dst == 0) { return pos; }
  if (src == 0) { return pos; }
  if (n <= 0) { return pos; }
  let i: i32 = 0;
  while (i < n) {
    if (pos >= (cap - 1)) {
      i = n;
    } else {
      dst[pos] = src[i];
      pos = pos + 1;
      i = i + 1;
    }
  }
  return pos;
}

// G-02f-218 内部：固定前缀 + <label> + 后缀
function glue_msg_with_label_c(dst: *u8, cap: i32, pre: *u8, pre_n: i32, label: *u8, label_n: i32, post: *u8, post_n: i32): void {
  let pos: i32 = 0;
  pos = glue_msg_append_c(dst, pos, cap, pre, pre_n);
  // "<"
  if (pos < (cap - 1)) {
    dst[pos] = 60;
    pos = pos + 1;
  }
  if (label_n > 0) {
    pos = glue_msg_append_c(dst, pos, cap, label, label_n);
  }
  // ">"
  if (pos < (cap - 1)) {
    dst[pos] = 62;
    pos = pos + 1;
  }
  pos = glue_msg_append_c(dst, pos, cap, post, post_n);
  if (pos < cap) {
    dst[pos] = 0;
  } else {
    if (cap > 0) { dst[cap - 1] = 0; }
  }
}

// G-02f-218：slice 赋值 region 检查（TYPE_SLICE=11）
#[no_mangle]
function pipeline_typeck_check_slice_region_assign_c(arena: *u8, site_expr_ref: i32, expect_ref: i32, src_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (expect_ref <= 0) { return 0; }
  if (src_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, expect_ref) != 11) { return 0; }
    if (pipeline_type_kind_ord_at(arena, src_ref) != 11) { return 0; }
    let line: i32 = 0;
    let col: i32 = 0;
    if (site_expr_ref > 0) {
      line = pipeline_expr_line_at(arena, site_expr_ref);
      col = pipeline_expr_col_at(arena, site_expr_ref);
    }
    if (pipeline_typeck_slice_region_escape_strict_minimal(arena, expect_ref, src_ref) != 0) {
      let sb: u8[64] = [];
      let slen: i32 = pipeline_type_region_label_into(arena, src_ref, &sb[0]);
      if (slen < 0) { slen = 0; }
      if (slen > 63) { slen = 63; }
      // "slice region escape: cannot assign " + <lab> + " slice to unbound T[]"
      let pre: u8[40] = [];
      pre[0]=115;pre[1]=108;pre[2]=105;pre[3]=99;pre[4]=101;pre[5]=32;pre[6]=114;pre[7]=101;
      pre[8]=103;pre[9]=105;pre[10]=111;pre[11]=110;pre[12]=32;pre[13]=101;pre[14]=115;pre[15]=99;
      pre[16]=97;pre[17]=112;pre[18]=101;pre[19]=58;pre[20]=32;pre[21]=99;pre[22]=97;pre[23]=110;
      pre[24]=110;pre[25]=111;pre[26]=116;pre[27]=32;pre[28]=97;pre[29]=115;pre[30]=115;pre[31]=105;
      pre[32]=103;pre[33]=110;pre[34]=32;pre[35]=0;
      let post: u8[32] = [];
      post[0]=32;post[1]=115;post[2]=108;post[3]=105;post[4]=99;post[5]=101;post[6]=32;post[7]=116;
      post[8]=111;post[9]=32;post[10]=117;post[11]=110;post[12]=98;post[13]=111;post[14]=117;post[15]=110;
      post[16]=100;post[17]=32;post[18]=84;post[19]=91;post[20]=93;post[21]=0;
      let msg: u8[160] = [];
      glue_msg_with_label_c(&msg[0], 160, &pre[0], 35, &sb[0], slen, &post[0], 21);
      lsp_diag_report_typeck(line, col, &msg[0]);
      return 0 - 1;
    }
    if (pipeline_typeck_slice_region_conflict_strict_minimal(arena, expect_ref, src_ref) != 0) {
      let eb: u8[64] = [];
      let sb2: u8[64] = [];
      let elen: i32 = pipeline_type_region_label_into(arena, expect_ref, &eb[0]);
      let slen2: i32 = pipeline_type_region_label_into(arena, src_ref, &sb2[0]);
      if (elen < 0) { elen = 0; }
      if (slen2 < 0) { slen2 = 0; }
      if (elen > 63) { elen = 63; }
      if (slen2 > 63) { slen2 = 63; }
      // "slice region mismatch: expected <e>, found <s>"
      let msg2: u8[192] = [];
      let pos: i32 = 0;
      let p0: u8[40] = [];
      p0[0]=115;p0[1]=108;p0[2]=105;p0[3]=99;p0[4]=101;p0[5]=32;p0[6]=114;p0[7]=101;
      p0[8]=103;p0[9]=105;p0[10]=111;p0[11]=110;p0[12]=32;p0[13]=109;p0[14]=105;p0[15]=115;
      p0[16]=109;p0[17]=97;p0[18]=116;p0[19]=99;p0[20]=104;p0[21]=58;p0[22]=32;p0[23]=101;
      p0[24]=120;p0[25]=112;p0[26]=101;p0[27]=99;p0[28]=116;p0[29]=101;p0[30]=100;p0[31]=32;
      p0[32]=0;
      pos = glue_msg_append_c(&msg2[0], pos, 192, &p0[0], 32);
      if (pos < 191) { msg2[pos] = 60; pos = pos + 1; }
      pos = glue_msg_append_c(&msg2[0], pos, 192, &eb[0], elen);
      if (pos < 191) { msg2[pos] = 62; pos = pos + 1; }
      let mid: u8[16] = [];
      mid[0]=44;mid[1]=32;mid[2]=102;mid[3]=111;mid[4]=117;mid[5]=110;mid[6]=100;mid[7]=32;
      mid[8]=0;
      pos = glue_msg_append_c(&msg2[0], pos, 192, &mid[0], 8);
      if (pos < 191) { msg2[pos] = 60; pos = pos + 1; }
      pos = glue_msg_append_c(&msg2[0], pos, 192, &sb2[0], slen2);
      if (pos < 191) { msg2[pos] = 62; pos = pos + 1; }
      if (pos < 192) { msg2[pos] = 0; } else { msg2[191] = 0; }
      lsp_diag_report_typeck(line, col, &msg2[0]);
      return 0 - 1;
    }
  }
  return 0;
}

// G-02f-218：return 时 slice region
#[no_mangle]
function pipeline_typeck_check_return_slice_region_c(arena: *u8, ret_site_ref: i32, op_ref: i32, func_return_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (op_ref <= 0) { return 0; }
  if (func_return_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, func_return_ref) != 11) { return 0; }
    let got_ref: i32 = pipeline_expr_resolved_type_ref(arena, op_ref);
    if (got_ref <= 0) { return 0; }
    if (pipeline_type_kind_ord_at(arena, got_ref) != 11) { return 0; }
    let line: i32 = 0;
    let col: i32 = 0;
    pipeline_typeck_expr_diag_line_col_strict_minimal(arena, ret_site_ref, &line, &col);
    if (pipeline_typeck_slice_region_escape_strict_minimal(arena, func_return_ref, got_ref) != 0) {
      let sb: u8[64] = [];
      let slen: i32 = pipeline_type_region_label_into(arena, got_ref, &sb[0]);
      if (slen < 0) { slen = 0; }
      if (slen > 63) { slen = 63; }
      // "slice region escape: cannot return " + <lab> + " slice as unbound T[]"
      let pre: u8[40] = [];
      pre[0]=115;pre[1]=108;pre[2]=105;pre[3]=99;pre[4]=101;pre[5]=32;pre[6]=114;pre[7]=101;
      pre[8]=103;pre[9]=105;pre[10]=111;pre[11]=110;pre[12]=32;pre[13]=101;pre[14]=115;pre[15]=99;
      pre[16]=97;pre[17]=112;pre[18]=101;pre[19]=58;pre[20]=32;pre[21]=99;pre[22]=97;pre[23]=110;
      pre[24]=110;pre[25]=111;pre[26]=116;pre[27]=32;pre[28]=114;pre[29]=101;pre[30]=116;pre[31]=117;
      pre[32]=114;pre[33]=110;pre[34]=32;pre[35]=0;
      let post: u8[32] = [];
      post[0]=32;post[1]=115;post[2]=108;post[3]=105;post[4]=99;post[5]=101;post[6]=32;post[7]=97;
      post[8]=115;post[9]=32;post[10]=117;post[11]=110;post[12]=98;post[13]=111;post[14]=117;post[15]=110;
      post[16]=100;post[17]=32;post[18]=84;post[19]=91;post[20]=93;post[21]=0;
      let msg: u8[160] = [];
      glue_msg_with_label_c(&msg[0], 160, &pre[0], 35, &sb[0], slen, &post[0], 21);
      lsp_diag_report_typeck(line, col, &msg[0]);
      return 0 - 1;
    }
    if (pipeline_typeck_slice_region_conflict_strict_minimal(arena, func_return_ref, got_ref) != 0) {
      let eb: u8[64] = [];
      let sb2: u8[64] = [];
      let elen: i32 = pipeline_type_region_label_into(arena, func_return_ref, &eb[0]);
      let slen2: i32 = pipeline_type_region_label_into(arena, got_ref, &sb2[0]);
      if (elen < 0) { elen = 0; }
      if (slen2 < 0) { slen2 = 0; }
      if (elen > 63) { elen = 63; }
      if (slen2 > 63) { slen2 = 63; }
      // "slice region mismatch in return: expected <e>, found <s>"
      let msg2: u8[192] = [];
      let pos: i32 = 0;
      let p0: u8[48] = [];
      p0[0]=115;p0[1]=108;p0[2]=105;p0[3]=99;p0[4]=101;p0[5]=32;p0[6]=114;p0[7]=101;
      p0[8]=103;p0[9]=105;p0[10]=111;p0[11]=110;p0[12]=32;p0[13]=109;p0[14]=105;p0[15]=115;
      p0[16]=109;p0[17]=97;p0[18]=116;p0[19]=99;p0[20]=104;p0[21]=32;p0[22]=105;p0[23]=110;
      p0[24]=32;p0[25]=114;p0[26]=101;p0[27]=116;p0[28]=117;p0[29]=114;p0[30]=110;p0[31]=58;
      p0[32]=32;p0[33]=101;p0[34]=120;p0[35]=112;p0[36]=101;p0[37]=99;p0[38]=116;p0[39]=101;
      p0[40]=100;p0[41]=32;p0[42]=0;
      pos = glue_msg_append_c(&msg2[0], pos, 192, &p0[0], 42);
      if (pos < 191) { msg2[pos] = 60; pos = pos + 1; }
      pos = glue_msg_append_c(&msg2[0], pos, 192, &eb[0], elen);
      if (pos < 191) { msg2[pos] = 62; pos = pos + 1; }
      let mid: u8[16] = [];
      mid[0]=44;mid[1]=32;mid[2]=102;mid[3]=111;mid[4]=117;mid[5]=110;mid[6]=100;mid[7]=32;
      mid[8]=0;
      pos = glue_msg_append_c(&msg2[0], pos, 192, &mid[0], 8);
      if (pos < 191) { msg2[pos] = 60; pos = pos + 1; }
      pos = glue_msg_append_c(&msg2[0], pos, 192, &sb2[0], slen2);
      if (pos < 191) { msg2[pos] = 62; pos = pos + 1; }
      if (pos < 192) { msg2[pos] = 0; } else { msg2[191] = 0; }
      lsp_diag_report_typeck(line, col, &msg2[0]);
      return 0 - 1;
    }
  }
  return 0;
}

// G-02f-218：call 参数 slice region
#[no_mangle]
function pipeline_typeck_check_call_slice_region_c(module: *u8, arena: *u8, call_expr_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (call_expr_ref <= 0) { return 0; }
  unsafe {
    let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
    let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, call_expr_ref);
    if (func_ix < 0) {
      func_ix = pipeline_typeck_resolve_call_func_index_c(module, arena, call_expr_ref);
    }
    if (func_ix < 0) { return 0; }
    let callee_mod: *u8 = module;
    if (dep_ix >= 0) {
      if (ctx != 0) {
        let dm: *u8 = pipeline_dep_ctx_module_at(ctx, dep_ix);
        if (dm != 0) { callee_mod = dm; }
      }
    }
    let num_args: i32 = pipeline_expr_call_num_args_at(arena, call_expr_ref);
    let np: i32 = pipeline_module_func_num_params_at(callee_mod, func_ix);
    if (num_args != np) { return 0; }
    let i: i32 = 0;
    while (i < num_args) {
      let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, i);
      let param_ref: i32 = pipeline_module_func_param_type_ref_at(callee_mod, func_ix, i);
      let arg_ty: i32 = pipeline_expr_resolved_type_ref(arena, arg_ref);
      if (pipeline_typeck_check_slice_region_assign_c(arena, arg_ref, param_ref, arg_ty) != 0) {
        return 0 - 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

// G-02f-218：try? 传播（Result_ 前缀 + payload resolve）
// TYPE_NAMED=8
#[no_mangle]
function pipeline_typeck_check_expr_try_propagate_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let op_ref: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    let line: i32 = pipeline_expr_line_at(arena, expr_ref);
    let col: i32 = pipeline_expr_col_at(arena, expr_ref);
    if (typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) != 0) {
      return 0 - 1;
    }
    let op_ty: i32 = pipeline_expr_resolved_type_ref(arena, op_ref);
    let enclosing: i32 = return_type_ref;
    let func_ret: i32 = 0;
    let func_ix: i32 = 0 - 1;
    if (ctx != 0) {
      func_ix = pipeline_dep_ctx_current_func_index(ctx);
    }
    if (func_ix >= 0) {
      if (func_ix < pipeline_module_num_funcs(module)) {
        func_ret = pipeline_module_func_return_type_at(module, func_ix);
        if (func_ret > 0) { enclosing = func_ret; }
      }
    }
    // debug no-op (seed 侧 getenv 冷路径)
    if (op_ty <= 0) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (pipeline_type_kind_ord_at(arena, op_ty) != 8) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    let rname: u8[64] = [];
    let rlen: i32 = pipeline_type_named_name_into(arena, op_ty, &rname[0]);
    // "Result_" len 7
    if (rlen < 7) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[0] != 82) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[1] != 101) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[2] != 115) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[3] != 117) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[4] != 108) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[5] != 116) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (rname[6] != 95) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (enclosing <= 0) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    if (pipeline_typeck_type_refs_equal_c(arena, enclosing, op_ty) == 0) {
      driver_diagnostic_typeck_try_propagate_bad_enclosing(line, col);
      return 0 - 1;
    }
    let payload_ty: i32 = pipeline_typeck_result_payload_type_from_name_strict_minimal(arena, &rname[0], rlen);
    if (payload_ty > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, payload_ty);
    } else {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, op_ty);
    }
  }
  return 0;
}

/* ---- G-02f-219：match / field_access / method_call / expr_impl dispatch ---- */

extern "C" function typeck_check_expr(module: *u8, arena: *u8, er: i32, ret_ty: i32, ctx: *u8): i32;
extern "C" function driver_diagnostic_typeck_enum_no_variant(line: i32, col: i32): void;
extern "C" function pipeline_expr_match_matched_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_match_num_arms_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_match_arm_is_enum_variant(arena: *u8, er: i32, idx: i32): i32;
extern "C" function pipeline_expr_match_arm_variant_index(arena: *u8, er: i32, idx: i32): i32;
extern "C" function pipeline_expr_match_arm_result_ref(arena: *u8, er: i32, idx: i32): i32;
extern "C" function pipeline_expr_field_access_name_len(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_name_into(arena: *u8, er: i32, out: *u8): void;
extern "C" function pipeline_expr_set_field_access_offset(arena: *u8, er: i32, off: i32): void;
extern "C" function typeck_get_field_offset_from_layout_deps(module: *u8, ctx: *u8, tname: *u8, tlen: i32, fname: *u8, flen: i32): i32;
extern "C" function typeck_get_field_type_ref_from_layout_deps(module: *u8, arena: *u8, ctx: *u8, tname: *u8, tlen: i32, fname: *u8, flen: i32): i32;
extern "C" function pipeline_expr_init_call_resolve_at_ref(arena: *u8, er: i32): void;
extern "C" function pipeline_expr_method_call_base_ref_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_method_call_name_len(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_method_call_name_into(arena: *u8, er: i32, out: *u8): void;
extern "C" function pipeline_expr_method_call_num_args_at(arena: *u8, er: i32): i32;
extern "C" function pipeline_expr_method_call_arg_ref(arena: *u8, er: i32, idx: i32): i32;
extern "C" function pipeline_dep_ctx_module_at(ctx: *u8, idx: i32): *u8;
extern "C" function typeck_check_expr_assign(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_return(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_panic(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_index(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_call(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_binop(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_unary(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_addr_of(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_deref(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_var(module: *u8, arena: *u8, er: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_as(module: *u8, arena: *u8, er: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_struct_lit(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_float_lit(arena: *u8, er: i32): i32;
extern "C" function typeck_check_expr_bool_lit(arena: *u8, er: i32): i32;
extern "C" function typeck_check_expr_break_continue(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_enum_variant(arena: *u8, er: i32): i32;
extern "C" function typeck_check_expr_if_ternary(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function typeck_check_expr_block(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;

// G-02f-219：match 表达式
#[no_mangle]
function pipeline_typeck_check_expr_match_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let matched_ref: i32 = pipeline_expr_match_matched_ref_at(arena, expr_ref);
    let num_arms: i32 = pipeline_expr_match_num_arms_at(arena, expr_ref);
    let line: i32 = pipeline_expr_line_at(arena, expr_ref);
    let col: i32 = pipeline_expr_col_at(arena, expr_ref);
    if (typeck_check_expr(module, arena, matched_ref, return_type_ref, ctx) != 0) {
      return 0 - 1;
    }
    let arm_i: i32 = 0;
    while (arm_i < num_arms) {
      if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, arm_i) != 0) {
        if (pipeline_expr_match_arm_variant_index(arena, expr_ref, arm_i) < 0) {
          driver_diagnostic_typeck_enum_no_variant(line, col);
          return 0 - 1;
        }
      }
      let arm_res: i32 = pipeline_expr_match_arm_result_ref(arena, expr_ref, arm_i);
      if (typeck_check_expr(module, arena, arm_res, return_type_ref, ctx) != 0) {
        return 0 - 1;
      }
      arm_i = arm_i + 1;
    }
    if (return_type_ref > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, return_type_ref);
    }
  }
  return 0;
}

// G-02f-219：field access（slice length/data + 已知 ASTArena/Module + layout deps）
// SLICE=11 PTR=9 NAMED=8 USIZE=6 I32=0
#[no_mangle]
function pipeline_typeck_check_expr_field_access_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let base_ref: i32 = pipeline_expr_field_access_base_ref(arena, expr_ref);
    if (base_ref <= 0) { return 0 - 1; }
    // EXPR_VAR=3
    if (pipeline_expr_kind_ord_at(arena, base_ref) == 3) {
      if (pipeline_expr_resolved_type_ref(arena, base_ref) == 0) {
        let prebind_len: i32 = pipeline_expr_var_name_len(arena, base_ref);
        if (prebind_len > 0) {
          if (prebind_len <= 63) {
            let prebind_name: u8[64] = [];
            pipeline_expr_var_name_into(arena, base_ref, &prebind_name[0]);
            let do_prebind: i32 = 1;
            if (ctx != 0) {
              let cfi: i32 = pipeline_dep_ctx_current_func_index(ctx);
              if (cfi >= 0) {
                if (pipeline_module_func_param_type_ref_for_name(module, cfi, &prebind_name[0], prebind_len) > 0) {
                  do_prebind = 0;
                }
              }
            }
            if (do_prebind != 0) {
              let nt: i32 = pipeline_type_find_or_alloc_named(arena, &prebind_name[0], prebind_len);
              pipeline_expr_set_resolved_type_ref(arena, base_ref, nt);
            }
          }
        }
      }
    }
    if (typeck_check_expr(module, arena, base_ref, return_type_ref, ctx) != 0) {
      return 0 - 1;
    }
    let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, base_ref);
    if (base_ty <= 0) { return 0; }
    let field_len: i32 = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (field_len <= 0) { return 0; }
    if (field_len > 63) { return 0; }
    let field_name: u8[64] = [];
    pipeline_expr_field_access_name_into(arena, expr_ref, &field_name[0]);
    let bt_kind: i32 = pipeline_type_kind_ord_at(arena, base_ty);
    if (bt_kind == 11) {
      let elem_ty: i32 = pipeline_type_elem_ref_at(arena, base_ty);
      let lit_len: u8[16] = [];
      lit_len[0]=108;lit_len[1]=101;lit_len[2]=110;lit_len[3]=103;lit_len[4]=116;lit_len[5]=104;lit_len[6]=0;
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &lit_len[0]) != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, pipeline_type_ensure_by_kind_ord(arena, 6));
        return 0;
      }
      let lit_data: u8[8] = [];
      lit_data[0]=100;lit_data[1]=97;lit_data[2]=116;lit_data[3]=97;lit_data[4]=0;
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &lit_data[0]) != 0) {
        if (elem_ty > 0) {
          let ptr_ty: i32 = pipeline_type_find_or_alloc_compound(arena, 9, elem_ty, 0);
          pipeline_expr_set_resolved_type_ref(arena, expr_ref, ptr_ty);
          return 0;
        }
      }
    }
    let work_ty: i32 = base_ty;
    if (bt_kind == 9) {
      let elem2: i32 = pipeline_type_elem_ref_at(arena, base_ty);
      if (elem2 > 0) {
        if (pipeline_type_kind_ord_at(arena, elem2) == 8) {
          work_ty = elem2;
        }
      }
    }
    if (pipeline_type_kind_ord_at(arena, work_ty) != 8) { return 0; }
    let type_name: u8[64] = [];
    let type_name_len: i32 = pipeline_type_named_name_into(arena, work_ty, &type_name[0]);
    if (type_name_len <= 0) { return 0; }
    // "ASTArena"
    let lit_aa: u8[16] = [];
    lit_aa[0]=65;lit_aa[1]=83;lit_aa[2]=84;lit_aa[3]=65;lit_aa[4]=114;lit_aa[5]=101;lit_aa[6]=110;lit_aa[7]=97;lit_aa[8]=0;
    if (field_name_equal_strict_minimal(&type_name[0], type_name_len, &lit_aa[0]) != 0) {
      let ok_i32: i32 = 0;
      let l1: u8[16] = [];
      l1[0]=110;l1[1]=117;l1[2]=109;l1[3]=95;l1[4]=116;l1[5]=121;l1[6]=112;l1[7]=101;l1[8]=115;l1[9]=0;
      let l2: u8[16] = [];
      l2[0]=110;l2[1]=117;l2[2]=109;l2[3]=95;l2[4]=101;l2[5]=120;l2[6]=112;l2[7]=114;l2[8]=115;l2[9]=0;
      let l3: u8[16] = [];
      l3[0]=110;l3[1]=117;l3[2]=109;l3[3]=95;l3[4]=98;l3[5]=108;l3[6]=111;l3[7]=99;l3[8]=107;l3[9]=115;l3[10]=0;
      let l4: u8[16] = [];
      l4[0]=110;l4[1]=117;l4[2]=109;l4[3]=95;l4[4]=102;l4[5]=117;l4[6]=110;l4[7]=99;l4[8]=115;l4[9]=0;
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &l1[0]) != 0) { ok_i32 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &l2[0]) != 0) { ok_i32 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &l3[0]) != 0) { ok_i32 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &l4[0]) != 0) { ok_i32 = 1; }
      if (ok_i32 != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, pipeline_type_ensure_by_kind_ord(arena, 0));
        return 0;
      }
    }
    // "Module"
    let lit_mod: u8[8] = [];
    lit_mod[0]=77;lit_mod[1]=111;lit_mod[2]=100;lit_mod[3]=117;lit_mod[4]=108;lit_mod[5]=101;lit_mod[6]=0;
    if (field_name_equal_strict_minimal(&type_name[0], type_name_len, &lit_mod[0]) != 0) {
      let ok2: i32 = 0;
      let m1: u8[16] = [];
      m1[0]=110;m1[1]=117;m1[2]=109;m1[3]=95;m1[4]=102;m1[5]=117;m1[6]=110;m1[7]=99;m1[8]=115;m1[9]=0;
      let m2: u8[24] = [];
      m2[0]=109;m2[1]=97;m2[2]=105;m2[3]=110;m2[4]=95;m2[5]=102;m2[6]=117;m2[7]=110;m2[8]=99;m2[9]=95;
      m2[10]=105;m2[11]=110;m2[12]=100;m2[13]=101;m2[14]=120;m2[15]=0;
      let m3: u8[16] = [];
      m3[0]=110;m3[1]=117;m3[2]=109;m3[3]=95;m3[4]=105;m3[5]=109;m3[6]=112;m3[7]=111;m3[8]=114;m3[9]=116;
      m3[10]=115;m3[11]=0;
      let m4: u8[24] = [];
      m4[0]=110;m4[1]=117;m4[2]=109;m4[3]=95;m4[4]=116;m4[5]=111;m4[6]=112;m4[7]=95;m4[8]=108;m4[9]=101;
      m4[10]=118;m4[11]=101;m4[12]=108;m4[13]=95;m4[14]=108;m4[15]=101;m4[16]=116;m4[17]=115;m4[18]=0;
      let m5: u8[24] = [];
      m5[0]=110;m5[1]=117;m5[2]=109;m5[3]=95;m5[4]=115;m5[5]=116;m5[6]=114;m5[7]=117;m5[8]=99;m5[9]=116;
      m5[10]=95;m5[11]=108;m5[12]=97;m5[13]=121;m5[14]=111;m5[15]=117;m5[16]=116;m5[17]=115;m5[18]=0;
      let m6: u8[24] = [];
      m6[0]=110;m6[1]=117;m6[2]=109;m6[3]=95;m6[4]=109;m6[5]=111;m6[6]=100;m6[7]=117;m6[8]=108;m6[9]=101;
      m6[10]=95;m6[11]=101;m6[12]=110;m6[13]=117;m6[14]=109;m6[15]=115;m6[16]=0;
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m1[0]) != 0) { ok2 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m2[0]) != 0) { ok2 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m3[0]) != 0) { ok2 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m4[0]) != 0) { ok2 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m5[0]) != 0) { ok2 = 1; }
      if (field_name_equal_strict_minimal(&field_name[0], field_len, &m6[0]) != 0) { ok2 = 1; }
      if (ok2 != 0) {
        pipeline_expr_set_resolved_type_ref(arena, expr_ref, pipeline_type_ensure_by_kind_ord(arena, 0));
        return 0;
      }
    }
    let field_off: i32 = typeck_get_field_offset_from_layout_deps(module, ctx, &type_name[0], type_name_len, &field_name[0], field_len);
    if (field_off >= 0) {
      pipeline_expr_set_field_access_offset(arena, expr_ref, field_off);
    }
    let field_ty: i32 = typeck_get_field_type_ref_from_layout_deps(module, arena, ctx, &type_name[0], type_name_len, &field_name[0], field_len);
    if (field_ty > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, field_ty);
    }
  }
  return 0;
}

// G-02f-219：method call（i32.double + import binding 方法）
#[no_mangle]
function pipeline_typeck_check_expr_method_call_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (module == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    pipeline_expr_init_call_resolve_at_ref(arena, expr_ref);
    let base_ref: i32 = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    let base_rc: i32 = typeck_check_expr(module, arena, base_ref, 0, ctx);
    let base_kind: i32 = pipeline_expr_kind_ord_at(arena, base_ref);
    let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, base_ref);
    let method_nlen: i32 = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (method_nlen <= 0) { return 0 - 1; }
    if (method_nlen > 63) { return 0 - 1; }
    let method_nm: u8[64] = [];
    pipeline_expr_method_call_name_into(arena, expr_ref, &method_nm[0]);
    let ret_ty: i32 = 0;
    // TYPE_I32=0; "double" 6
    if (base_ty > 0) {
      if (pipeline_type_kind_ord_at(arena, base_ty) == 0) {
        if (method_nlen == 6) {
          if (method_nm[0] == 100) {
            if (method_nm[1] == 111) {
              if (method_nm[2] == 117) {
                if (method_nm[3] == 98) {
                  if (method_nm[4] == 108) {
                    if (method_nm[5] == 101) {
                      ret_ty = pipeline_type_ensure_by_kind_ord(arena, 0);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    let num_args: i32 = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    let arg_i: i32 = 0;
    while (arg_i < num_args) {
      let arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, arg_i);
      if (typeck_check_expr(module, arena, arg_ref, return_type_ref, ctx) != 0) {
        return 0 - 1;
      }
      arg_i = arg_i + 1;
    }
    let dep_ix: i32 = 0 - 1;
    let func_ix: i32 = 0 - 1;
    let import_ret_ty: i32 = 0;
    if (ctx != 0) {
      if (base_kind == 3) {
        let base_nlen: i32 = pipeline_expr_var_name_len(arena, base_ref);
        if (base_nlen > 0) {
          if (base_nlen <= 63) {
            let base_nm: u8[64] = [];
            pipeline_expr_var_name_into(arena, base_ref, &base_nm[0]);
            let nimp: i32 = parser_get_module_num_imports(module);
            let ii: i32 = 0;
            while (ii < nimp) {
              let import_kind: i32 = pipeline_module_import_kind_at(module, ii);
              if (import_kind == 1) {
                if (pipeline_typeck_import_binding_name_equal_strict_minimal(module, ii, &base_nm[0], base_nlen) != 0) {
                  let dm: *u8 = pipeline_dep_ctx_module_at(ctx, ii);
                  if (dm == 0) {
                    ii = nimp;
                  } else {
                    let fout: i32 = 0 - 1;
                    import_ret_ty = pipeline_typeck_find_func_return_type_in_module_by_name_strict_minimal(
                      dm, arena, &method_nm[0], method_nlen, ii, num_args, ctx, &fout
                    );
                    if (import_ret_ty > 0) {
                      dep_ix = ii;
                      func_ix = fout;
                      ii = nimp;
                    } else {
                      ii = nimp;
                    }
                  }
                } else {
                  ii = ii + 1;
                }
              } else {
                ii = ii + 1;
              }
            }
          }
        }
      }
    }
    if (import_ret_ty > 0) {
      pipeline_expr_apply_call_resolve(arena, expr_ref, dep_ix, func_ix);
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, import_ret_ty);
      return 0;
    }
    if (ret_ty > 0) {
      pipeline_expr_set_resolved_type_ref(arena, expr_ref, ret_ty);
      return 0;
    }
    if (base_rc != 0) { return 0 - 1; }
  }
  return 0 - 1;
}

// G-02f-219：expr kind mega 分派
// RETURN=41 PANIC=42 MATCH=43 FIELD=44 INDEX=47 CALL=48 METHOD=49 ADD..LOGOR=4..21
// NEG=22 BITNOT=23 LOGNOT=24 ADDR_OF=51 DEREF=52 VAR=3 AS=54 STRUCT_LIT=45 try=57/58
#[no_mangle]
function pipeline_typeck_check_expr_impl_mega_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (pipeline_typeck_expr_is_any_assign_kind_strict_minimal(kind) != 0) {
      return typeck_check_expr_assign(module, arena, expr_ref, return_type_ref, ctx);
    }
    if (kind == 41) { return typeck_check_expr_return(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 42) { return typeck_check_expr_panic(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 43) { return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 44) { return pipeline_typeck_check_expr_field_access_c(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 47) { return typeck_check_expr_index(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 48) { return typeck_check_expr_call(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 49) { return pipeline_typeck_check_expr_method_call_c(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind >= 4) {
      if (kind <= 21) {
        return typeck_check_expr_binop(module, arena, expr_ref, return_type_ref, ctx);
      }
    }
    if (kind == 22) { return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 23) { return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 24) { return typeck_check_expr_unary(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 51) { return typeck_check_expr_addr_of(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 52) { return typeck_check_expr_deref(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 3) { return typeck_check_expr_var(module, arena, expr_ref, ctx); }
    if (kind == 54) { return typeck_check_expr_as(module, arena, expr_ref, ctx); }
    if (kind == 45) { return typeck_check_expr_struct_lit(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 58) { return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 57) { return pipeline_typeck_check_expr_try_propagate_c(module, arena, expr_ref, return_type_ref, ctx); }
  }
  return 0;
}

// G-02f-219：expr kind 入口分派
// FLOAT=1 LIT=0 BOOL=2 BREAK=39 CONTINUE=40 ENUM=50 IF=25 TERNARY=27 BLOCK=26 MATCH=43
#[no_mangle]
function pipeline_typeck_check_expr_impl_c(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let kind: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (kind == 1) { return typeck_check_expr_float_lit(arena, expr_ref); }
    if (kind == 0) { return pipeline_typeck_check_expr_int_lit_c(arena, expr_ref); }
    if (kind == 2) { return typeck_check_expr_bool_lit(arena, expr_ref); }
    if (kind == 39) { return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 40) { return typeck_check_expr_break_continue(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 50) { return typeck_check_expr_enum_variant(arena, expr_ref); }
    if (kind == 25) { return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 27) { return typeck_check_expr_if_ternary(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 26) { return typeck_check_expr_block(module, arena, expr_ref, return_type_ref, ctx); }
    if (kind == 43) { return pipeline_typeck_check_expr_match_c(module, arena, expr_ref, return_type_ref, ctx); }
    return pipeline_typeck_check_expr_impl_mega_c(module, arena, expr_ref, return_type_ref, ctx);
  }
  return 0;
}

/* ---- G-02f-220：check_block_impl + dep map entry + generic_params ---- */

extern "C" function pipeline_typeck_block_impl_bind_ctx_c(ctx: *u8, block_ref: i32): i32;
extern "C" function pipeline_typeck_block_impl_restore_ctx_c(ctx: *u8, saved: i32): void;
extern "C" function typeck_check_block_stmt_order_one(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, si: i32, nso: i32, nc: i32, nl: i32, nes: i32, nlp: i32, nfp: i32, nif: i32, nreg: i32): i32;
extern "C" function typeck_check_block_one_const(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, idx: i32): i32;
extern "C" function typeck_check_block_one_let(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, idx: i32): i32;
extern "C" function typeck_check_block_one_while(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, idx: i32): i32;
extern "C" function typeck_check_block_one_for(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, idx: i32): i32;
extern "C" function typeck_check_block_one_if(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, idx: i32): i32;
extern "C" function typeck_check_block_final(module: *u8, arena: *u8, br: i32, rt: i32, ctx: *u8, fin0: i32): i32;
extern "C" function typeck_check_expr(module: *u8, arena: *u8, er: i32, rt: i32, ctx: *u8): i32;
extern "C" function ast_ast_block_num_consts(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_lets(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_loops(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_for_loops(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_if_stmts(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_regions(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_expr_stmts(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_num_stmt_order(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_final_expr_ref(arena: *u8, br: i32): i32;
extern "C" function ast_ast_block_expr_stmt_ref(arena: *u8, br: i32, idx: i32): i32;
extern "C" function pipeline_dep_ctx_arena_at(ctx: *u8, idx: i32): *u8;
extern "C" function pipeline_dep_ctx_ndep(ctx: *u8): i32;
extern "C" function pipeline_get_dep_arena_slot(ix: i32): *u8;
extern "C" function pipeline_module_func_num_generic_params_at(mod: *u8, fi: i32): i32;
extern "C" function getenv(name: *u8): *u8;

// G-02f-220：dep map 入口 module 指针（与 seed 全局表语义对齐）
let g_typeck_entry_module_for_dep_map_x: *u8 = 0;

// G-02f-220：set entry module for dep named map
#[no_mangle]
function pipeline_typeck_set_entry_module_for_dep_map_c(module: *u8): void {
  g_typeck_entry_module_for_dep_map_x = module;
}

// G-02f-220：dep 返回类型 → caller arena（含 entry_mod TYPE_NAMED map）
#[no_mangle]
function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32 {
  if (from_dep_index < 0) { return 0; }
  if (ctx == 0) { return 0; }
  unsafe {
    let dep_arena: *u8 = pipeline_dep_ctx_arena_at(ctx, from_dep_index);
    if (dep_arena == 0) {
      dep_arena = pipeline_get_dep_arena_slot(from_dep_index);
      if (dep_arena == 0) { return 0; }
    }
    let ndep: i32 = pipeline_dep_ctx_ndep(ctx);
    if (from_dep_index >= ndep) {
      if (pipeline_dep_ctx_module_at(ctx, from_dep_index) == 0) { return 0; }
    }
    if (g_typeck_entry_module_for_dep_map_x != 0) {
      if (dep_return_type_ref > 0) {
        let kind: i32 = pipeline_type_kind_ord_at(dep_arena, dep_return_type_ref);
        // TYPE_NAMED=8
        if (kind == 8) {
          let nm: u8[64] = [];
          let nlen: i32 = pipeline_type_named_name_into(dep_arena, dep_return_type_ref, &nm[0]);
          if (nlen > 0) {
            return pipeline_typeck_map_import_binding_named_to_caller_strict_minimal(
              g_typeck_entry_module_for_dep_map_x, from_dep_index, caller_arena, &nm[0], nlen
            );
          }
        }
      }
    }
    return pipeline_typeck_dep_return_type_to_caller_strict_minimal(dep_arena, dep_return_type_ref, caller_arena);
  }
  return 0;
}

// G-02f-220：generic params 计数（debug 文案冷路径仍在 seed getenv+diag）
#[no_mangle]
function ast_pipeline_module_func_num_generic_params_at(m: *u8, fi: i32): i32 {
  if (m == 0) { return 0; }
  unsafe {
    return pipeline_module_func_num_generic_params_at(m, fi);
  }
  return 0;
}

// G-02f-220：check_block_impl — 用 bind/restore，不直写 PipelineDepCtx 字段
#[no_mangle]
function pipeline_typeck_check_block_impl_c(module: *u8, arena: *u8, block_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  if (arena == 0) { return 0 - 1; }
  if (ctx == 0) { return 0 - 1; }
  if (block_ref <= 0) { return 0 - 1; }
  unsafe {
    let saved_block_ref: i32 = pipeline_typeck_block_impl_bind_ctx_c(ctx, block_ref);
    let nc: i32 = ast_ast_block_num_consts(arena, block_ref);
    let nl: i32 = ast_ast_block_num_lets(arena, block_ref);
    let nlp: i32 = ast_ast_block_num_loops(arena, block_ref);
    let nfp: i32 = ast_ast_block_num_for_loops(arena, block_ref);
    let nif: i32 = ast_ast_block_num_if_stmts(arena, block_ref);
    let nreg: i32 = ast_ast_block_num_regions(arena, block_ref);
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, block_ref);
    let nso: i32 = ast_ast_block_num_stmt_order(arena, block_ref);
    let fin0: i32 = ast_ast_block_final_expr_ref(arena, block_ref);
    if (nso > 0) {
      let i: i32 = 0;
      while (i < nso) {
        if (i < 96) {
          if (typeck_check_block_stmt_order_one(module, arena, block_ref, return_type_ref, ctx, i, nso, nc, nl, nes, nlp, nfp, nif, nreg) != 0) {
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return 0 - 1;
          }
          i = i + 1;
        } else {
          i = nso;
        }
      }
    } else {
      let i2: i32 = 0;
      while (i2 < nc) {
        if (typeck_check_block_one_const(module, arena, block_ref, return_type_ref, ctx, i2) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nl) {
        if (typeck_check_block_one_let(module, arena, block_ref, return_type_ref, ctx, i2) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nlp) {
        if (typeck_check_block_one_while(module, arena, block_ref, return_type_ref, ctx, i2) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nfp) {
        if (typeck_check_block_one_for(module, arena, block_ref, return_type_ref, ctx, i2) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nif) {
        if (typeck_check_block_one_if(module, arena, block_ref, return_type_ref, ctx, i2) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nreg) {
        if (pipeline_typeck_check_block_one_region_c(module, arena, block_ref, i2, return_type_ref, ctx) != 0) {
          pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
          return 0 - 1;
        }
        i2 = i2 + 1;
      }
      i2 = 0;
      while (i2 < nes) {
        if (i2 < 32) {
          let es: i32 = ast_ast_block_expr_stmt_ref(arena, block_ref, i2);
          if (typeck_check_expr(module, arena, es, return_type_ref, ctx) != 0) {
            pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
            return 0 - 1;
          }
          i2 = i2 + 1;
        } else {
          i2 = nes;
        }
      }
    }
    if (typeck_check_block_final(module, arena, block_ref, return_type_ref, ctx, fin0) != 0) {
      pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
      return 0 - 1;
    }
    pipeline_typeck_block_impl_restore_ctx_c(ctx, saved_block_ref);
  }
  return 0;
}

/* ---- G-02f-221：linear moved 表 + after_parse_ok_impl + block_const_init ---- */

extern "C" function pipeline_strict_parse_into_init(arena: *u8, module: *u8): void;
extern "C" function pipeline_parse_into_with_init_slice_scalars_sidecar(arena: *u8, module: *u8, source: *u8): void;
extern "C" function pipeline_parse_scalars_ok_get(): i32;
extern "C" function pipeline_parse_scalars_main_idx_get(): i32;
extern "C" function pipeline_module_set_main_func_index(module: *u8, idx: i32): void;
extern "C" function pipeline_typeck_set_active_ctx_c(module: *u8, ctx: *u8): void;
extern "C" function pipeline_module_main_func_index(module: *u8): i32;
extern "C" function typeck_typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
extern "C" function typeck_typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
extern "C" function driver_diagnostic_typeck_fail(): void;
extern "C" function pipeline_block_const_name_len(arena: *u8, br: i32, idx: i32): i32;
extern "C" function pipeline_block_const_name_copy64(arena: *u8, br: i32, idx: i32, dst: *u8): void;
extern "C" function pipeline_block_const_init_ref(arena: *u8, br: i32, idx: i32): i32;
extern "C" function lsp_diag_report_typeck(line: i32, col: i32, fmt: *u8): void;

// G-02f-221：linear moved 全局表（max 128 × 64）
let g_lin_moved_n: i32 = 0;
let g_lin_moved_names: u8[8192] = [];
let g_lin_moved_lens: i32[128] = [];

// G-02f-221 内部：槽 base = i*64
function glue_lin_name_base(i: i32): i32 {
  return i * 64;
}

// G-02f-221：名字是否已 move
#[no_mangle]
function pipeline_typeck_linear_name_already_moved_strict_minimal(name: *u8, name_len: i32): i32 {
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  let i: i32 = 0;
  while (i < g_lin_moved_n) {
    if (g_lin_moved_lens[i] == name_len) {
      let base: i32 = glue_lin_name_base(i);
      let j: i32 = 0;
      let ok: i32 = 1;
      while (j < name_len) {
        if (g_lin_moved_names[base + j] != name[j]) {
          ok = 0;
          j = name_len;
        } else {
          j = j + 1;
        }
      }
      if (ok != 0) { return 1; }
    }
    i = i + 1;
  }
  return 0;
}

// G-02f-221：清空 linear moved 表
#[no_mangle]
function pipeline_typeck_linear_reset_c(): void {
  g_lin_moved_n = 0;
}

// G-02f-221：linear 使用点 — 已 move 则报错，否则登记
// TYPE_LINEAR=12
#[no_mangle]
function pipeline_typeck_linear_use_var_c(arena: *u8, type_ref: i32, expr_ref: i32, name: *u8, name_len: i32): i32 {
  if (arena == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  if (name_len > 63) { return 0; }
  if (type_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, type_ref) != 12) { return 0; }
    if (pipeline_typeck_linear_name_already_moved_strict_minimal(name, name_len) != 0) {
      let line: i32 = 0;
      let col: i32 = 0;
      if (expr_ref > 0) {
        line = pipeline_expr_line_at(arena, expr_ref);
        col = pipeline_expr_col_at(arena, expr_ref);
      }
      // "linear value used after move"
      let msg: u8[40] = [];
      msg[0]=108;msg[1]=105;msg[2]=110;msg[3]=101;msg[4]=97;msg[5]=114;msg[6]=32;msg[7]=118;
      msg[8]=97;msg[9]=108;msg[10]=117;msg[11]=101;msg[12]=32;msg[13]=117;msg[14]=115;msg[15]=101;
      msg[16]=100;msg[17]=32;msg[18]=97;msg[19]=102;msg[20]=116;msg[21]=101;msg[22]=114;msg[23]=32;
      msg[24]=109;msg[25]=111;msg[26]=118;msg[27]=101;msg[28]=0;
      lsp_diag_report_typeck(line, col, &msg[0]);
      return 0 - 1;
    }
    if (g_lin_moved_n < 128) {
      let base: i32 = glue_lin_name_base(g_lin_moved_n);
      let j: i32 = 0;
      while (j < name_len) {
        g_lin_moved_names[base + j] = name[j];
        j = j + 1;
      }
      g_lin_moved_lens[g_lin_moved_n] = name_len;
      g_lin_moved_n = g_lin_moved_n + 1;
    }
  }
  return 0;
}

// G-02f-221：after_parse 成功后 typeck 编排
#[no_mangle]
function pipeline_typeck_after_parse_ok_impl_c(arena: *u8, module: *u8, source: *u8, ctx: *u8): i32 {
  if (arena == 0) { return 0 - 1; }
  if (module == 0) { return 0 - 1; }
  if (source == 0) { return 0 - 1; }
  if (ctx == 0) { return 0 - 1; }
  unsafe {
    pipeline_strict_parse_into_init(arena, module);
    pipeline_parse_into_with_init_slice_scalars_sidecar(arena, module, source);
    let ok: i32 = pipeline_parse_scalars_ok_get();
    let main_idx: i32 = pipeline_parse_scalars_main_idx_get();
    if (ok != 0) { return main_idx; }
    pipeline_module_set_main_func_index(module, main_idx);
    pipeline_typeck_set_active_ctx_c(module, ctx);
    if (pipeline_module_main_func_index(module) < 0) {
      let tc: i32 = typeck_typeck_x_ast_library(module, arena, ctx);
      if (tc != 0) {
        driver_diagnostic_typeck_fail();
        return tc;
      }
      return tc;
    }
    let tc2: i32 = typeck_typeck_x_ast(module, arena, ctx);
    if (tc2 != 0) {
      driver_diagnostic_typeck_fail();
      return tc2;
    }
    return tc2;
  }
  return 0 - 1;
}

// G-02f-221 内部：block 前 const_idx 个 const 名是否匹配 name
function glue_block_prior_const_name_match(arena: *u8, block_ref: i32, const_idx: i32, name: *u8, name_len: i32): i32 {
  if (arena == 0) { return 0; }
  if (name == 0) { return 0; }
  if (name_len <= 0) { return 0; }
  unsafe {
    let i: i32 = 0;
    while (i < const_idx) {
      let clen: i32 = pipeline_block_const_name_len(arena, block_ref, i);
      if (clen == name_len) {
        if (clen > 0) {
          if (clen < 64) {
            let cbuf: u8[64] = [];
            pipeline_block_const_name_copy64(arena, block_ref, i, &cbuf[0]);
            let j: i32 = 0;
            let ok: i32 = 1;
            while (j < name_len) {
              if (cbuf[j] != name[j]) {
                ok = 0;
                j = name_len;
              } else {
                j = j + 1;
              }
            }
            if (ok != 0) { return 1; }
          }
        }
      }
      i = i + 1;
    }
  }
  return 0;
}

// G-02f-221 内部：常量表达式（VAR 对照 block 前序 const 名）
// LIT=0 FLOAT=1 BOOL=2 VAR=3 ADD..LOGOR=4..21 NEG=22 BITNOT=23 LOGNOT=24 ARRAY_LIT=46
function glue_block_const_expr_is_const(arena: *u8, expr_ref: i32, block_ref: i32, const_idx: i32): i32 {
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
      return glue_block_prior_const_name_match(arena, block_ref, const_idx, &name_buf[0], name_len);
    }
    if (kind >= 4) {
      if (kind <= 21) {
        let L: i32 = pipeline_expr_binop_left_ref_at(arena, expr_ref);
        let R: i32 = pipeline_expr_binop_right_ref_at(arena, expr_ref);
        if (glue_block_const_expr_is_const(arena, L, block_ref, const_idx) == 0) { return 0; }
        return glue_block_const_expr_is_const(arena, R, block_ref, const_idx);
      }
    }
    if (kind == 22) {
      return glue_block_const_expr_is_const(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), block_ref, const_idx);
    }
    if (kind == 23) {
      return glue_block_const_expr_is_const(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), block_ref, const_idx);
    }
    if (kind == 24) {
      return glue_block_const_expr_is_const(arena, pipeline_expr_unary_operand_ref_at(arena, expr_ref), block_ref, const_idx);
    }
    if (kind == 46) {
      let ne: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
      let j: i32 = 0;
      while (j < ne) {
        let el: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, j);
        if (glue_block_const_expr_is_const(arena, el, block_ref, const_idx) == 0) { return 0; }
        j = j + 1;
      }
      return 1;
    }
  }
  return 0;
}

// G-02f-221：block const 初值是否为常量表达式
#[no_mangle]
function pipeline_typeck_block_const_init_is_const_c(arena: *u8, block_ref: i32, const_idx: i32): i32 {
  if (arena == 0) { return 0; }
  if (const_idx < 0) { return 0; }
  unsafe {
    let init_ref: i32 = pipeline_block_const_init_ref(arena, block_ref, const_idx);
    if (init_ref <= 0) { return 1; }
    return glue_block_const_expr_is_const(arena, init_ref, block_ref, const_idx);
  }
  return 0;
}
