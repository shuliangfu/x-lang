// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// lsp_diag.x — LSP「文本诊断」响应：parse_into_buf + typeck_x_ast（经
// pipeline），不写 codegen。
//
// 职责：收到 diagnostic 请求时对正文跑一次 .x 前端，依赖 runtime.c 在
// lsp_diag_enabled 下把 driver_diagnostic_* 转写为 lsp_diag_add；
// 再用 lsp_diag_format_diagnostics_json + lsp_build_response_with_result 产出 JSON-RPC。
// 与 lsp_diag.c 中 hover/references/definition（bootstrap 经 su_alias 走 .x
// pipeline）分离：此处开头 invalidate 缓存，避免混用两种 AST。
//
// 约束：ctx 由 lsp_diag_prepare_pipeline_ctx 填入 libRoots/entry_dir；pipeline 内装载 direct import deps 后 typeck。
//
// 根因纪律：禁止 `let e: Expr = ast_arena_expr_get` / `let ty: Type = ast_arena_type_get`。
// 大 struct 按值拷贝在自举 typeck 上字段类型为 ?（check_block failed）。统一走 pipeline_* 标量读
//（与 typeck.x 同源），kind 用 ordinal 字面量（与 ast.x 序一致）。

// Cap-T001 / LANG-007 S0: all export paths that call C/pipeline externs use
// whole-body unsafe as the FFI gate (PLATFORM: SHARED). Product still may pin C; this is M1 typeck.

/** 与 pipeline.x 经 -E 导出名 pipeline_lsp_diag_parse_typeck_buf 一致；仅用 extern
* 引用，避免 import pipeline。 */
export extern function pipeline_lsp_diag_parse_typeck_buf(module: *Module, arena: *ASTArena, source_data:
*u8, source_len: i32, ctx: *PipelineDepCtx): i32;

export extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;

/** Expr/Type 标量字段读（勿按值拷贝整颗 Expr/Type）。 */
export extern function pipeline_expr_line_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_col_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_len(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *ASTArena, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *ASTArena, type_ref: i32, out: *u8): i32;

/** C 侧：按 SHUX_LSP_LIB_ROOTS / entry_dir 填充 PipelineDepCtx。 */
export extern function lsp_diag_prepare_pipeline_ctx(ctx: *PipelineDepCtx): void;

/** 复制 n 字节（避免 extern memcpy 与 Darwin string.h 宏冲突）。 */
export function copy_bytes(dest: *u8, src: *u8, n: usize): void {
  let i: usize = 0 as usize;
  while (i < n) {
    dest[i] = src[i];
    i = i + 1 as usize;
  }
}
export extern function std_heap_alloc(size: usize): *u8;
export extern function std_heap_free(ptr: *u8): void;

/** 使 C 侧模块/诊断 JSON 缓存失效（definition 等路径将重新 parse）。 */
export extern function lsp_diag_invalidate_cache(): void;

/** 打开/关闭「诊断写入收集器」会话（转调 lsp_diag_enabled）。 */
export extern function lsp_diag_collect_begin(): void;
export extern function lsp_diag_collect_end(): void;

/** 将 arena/module/PipelineDepCtx 三块一次性缓冲清零后复用（池化 AST，勿
ast_module_free）。 */
export extern function lsp_diag_x_reset_parse_buffers(): void;

export extern function lsp_diag_x_arena_ptr(): *ASTArena;
export extern function lsp_diag_x_module_ptr(): *Module;
export extern function lsp_diag_x_ctx_ptr(): *PipelineDepCtx;

/** 将当前收集的诊断序列化为 LSP Diagnostic[] JSON（含方括号）。 */
export extern function lsp_diag_format_diagnostics_json(out: *u8, out_cap: i32): i32;

/** 组装 {"jsonrpc":"2.0","id":…,"result":…}，实现仍在 lsp_diag.c。 */
export extern function lsp_build_response_with_result(id_val: i32, result_ptr: *u8, result_len: i32,
out_buf: *u8, out_cap: i32): i32;

/**
 * Run parse+typeck on a mutable source buffer for LSP diagnostics.
 * Resets pooled arena/module/ctx, fills lib roots, then calls pipeline glue.
 * Split out so -E does not drop the pipeline_lsp_diag_parse_typeck_buf call.
 * PLATFORM: SHARED — LANG-007 S0 whole-body unsafe FFI gate (Cap-T001).
 */
export function lsp_diag_run_pipeline_on_buf(mut_buf: *u8, sl: i32): i32 {
  // PLATFORM: SHARED — Cap-T001: all callees below are C/pipeline externs.
  unsafe {
    lsp_diag_x_reset_parse_buffers();
    let arena: *ASTArena = lsp_diag_x_arena_ptr();
    let module: *Module = lsp_diag_x_module_ptr();
    let ctx: *PipelineDepCtx = lsp_diag_x_ctx_ptr();
    lsp_diag_prepare_pipeline_ctx(ctx);
    return pipeline_lsp_diag_parse_typeck_buf(module, arena, mut_buf, sl, ctx);
  }
  return 0;
}

/**
* 构建 diagnostic 的 JSON-RPC 响应正文；失败或缓冲区不足返回 -1。
* id_val 为请求 id；source/source_len 为 UTF-8 文档字节（可为空文档）。
*/
export function lsp_build_diagnostics_response(id_val: i32, source: *u8, source_len: i32, out_buf: *u8,
out_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (source == 0 as *u8 || out_buf == 0 as *u8 || out_cap <= 0) {
    return -1;
  }
  let sl: i32 = source_len;
  if (sl < 0) {
    sl = 0;
  }
  lsp_diag_invalidate_cache();
  let ncopy: usize = sl as usize;
  let alloc_bytes: usize = ncopy + 1 as usize;
  if (alloc_bytes == 0 as usize) {
    alloc_bytes = 1 as usize;
  }
  let mut_buf: *u8 = std_heap_alloc(alloc_bytes);
  if (mut_buf == 0 as *u8) {
    return -1;
  }
  if (sl > 0) {
    copy_bytes(mut_buf, source, ncopy);
  }
  mut_buf[sl] = 0 as u8;
  
  lsp_diag_collect_begin();
  let rc: i32 = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
  lsp_diag_collect_end();
  std_heap_free(mut_buf);
  let diag_cap: i32 = 65536 + rc * 0;
  let diag_buf: *u8 = std_heap_alloc(diag_cap as usize);
  if (diag_buf == 0 as *u8) {
    return -1;
  }
  let dn: i32 = lsp_diag_format_diagnostics_json(diag_buf, diag_cap);
  let result_len: i32 = dn;
  if (result_len <= 0) {
    diag_buf[0] = 91 as u8;
    diag_buf[1] = 93 as u8;
    result_len = 2;
  }
  let resp_len: i32 = lsp_build_response_with_result(id_val, diag_buf, result_len, out_buf,
  out_cap);
  std_heap_free(diag_buf);
  return resp_len;
  }
  return 0;
}

/* ============ hover（arena 全量扫描，无递归） ============ */

/**
* 扫描 arena 所有表达式，找 (line_1, col_1) 处首个有 resolved_type_ref 的节点。
* 返回 type_ref（在调用方 arena 中有效）；未找到返回 0。
*/
export function lsp_find_type_ref_at_pos(arena: *ASTArena, line_1: i32, col_1: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (arena == 0 as *ASTArena) {
    return 0;
  }
  let ei: i32 = 1;
  while (ei <= arena.num_exprs) {
    let el: i32 = pipeline_expr_line_at(arena, ei);
    let ec: i32 = pipeline_expr_col_at(arena, ei);
    if (el == line_1 && ec == col_1) {
      let tr: i32 = pipeline_expr_resolved_type_ref(arena, ei);
      if (tr != 0) {
        return tr;
      }
    }
    ei = ei + 1;
  }
  return 0;
  }
  return 0;
}

/**
* 在 source 中 (line_0, col_0) 处悬停类型查询。
* parse+typeck 后扫描 arena 取类型，格式化为可读名称写入 out_buf。
* 返回写入字节数；未找到返回 0。供 lsp_diag.c / lsp_diag.stub.c 通过 extern
* 调用。
*/
export function lsp_diag_hover_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_buf: *u8,
out_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (source == 0 as *u8 || out_buf == 0 as *u8 || out_cap <= 0 || source_len < 0) {
    return 0;
  }
  let sl: i32 = source_len;
  if (sl < 0) { sl = 0; }
  /* copy source into heap buffer for pipeline */
  let ncopy: usize = sl as usize;
  let ab: usize = ncopy + 1 as usize;
  if (ab == 0 as usize) { ab = 1 as usize; }
  let mut_buf: *u8 = std_heap_alloc(ab);
  if (mut_buf == 0 as *u8) { return 0; }
  if (sl > 0) { copy_bytes(mut_buf, source, ncopy); }
  mut_buf[sl] = 0 as u8;
  lsp_diag_invalidate_cache();
  lsp_diag_collect_begin();
  let rc: i32 = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
  lsp_diag_collect_end();
  if (rc != 0) { std_heap_free(mut_buf); return 0; }
  let arena: *ASTArena = lsp_diag_x_arena_ptr();
  std_heap_free(mut_buf);
  let type_ref: i32 = lsp_find_type_ref_at_pos(arena, line_0 + 1, col_0 + 1);
  if (type_ref == 0) { return 0; }
  /* 取 type 池 kind 序（pipeline_type_*）；禁止 Type 按值拷贝。 */
  if (type_ref <= 0 || type_ref > arena.num_types) { return 0; }
  let ko: i32 = pipeline_type_kind_ord_at(arena, type_ref);
  /* TypeKind 序：I32=0 BOOL=1 U8=2 U32=3 U64=4 I64=5 USIZE=6 NAMED=8 PTR=9 F32=14 F64=15 VOID=16 */
  if (ko == 0 && out_cap >= 4) {
    out_buf[0] = 105; out_buf[1] = 51; out_buf[2] = 50; return 3;
  }
  if (ko == 1 && out_cap >= 5) {
    out_buf[0] = 98; out_buf[1] = 111; out_buf[2] = 111; out_buf[3] = 108; return 4;
  }
  if (ko == 2 && out_cap >= 3) {
    out_buf[0] = 117; out_buf[1] = 56; return 2;
  }
  if (ko == 3 && out_cap >= 4) {
    out_buf[0] = 117; out_buf[1] = 51; out_buf[2] = 50; return 3;
  }
  if (ko == 4 && out_cap >= 4) {
    out_buf[0] = 117; out_buf[1] = 54; out_buf[2] = 52; return 3;
  }
  if (ko == 5 && out_cap >= 4) {
    out_buf[0] = 105; out_buf[1] = 54; out_buf[2] = 52; return 3;
  }
  if (ko == 6 && out_cap >= 6) {
    out_buf[0] = 117; out_buf[1] = 115; out_buf[2] = 105; out_buf[3] = 122; out_buf[4] = 101;
    return 5;
  }
  if (ko == 14 && out_cap >= 4) {
    out_buf[0] = 102; out_buf[1] = 51; out_buf[2] = 50; return 3;
  }
  if (ko == 15 && out_cap >= 4) {
    out_buf[0] = 102; out_buf[1] = 54; out_buf[2] = 52; return 3;
  }
  if (ko == 16 && out_cap >= 5) {
    out_buf[0] = 118; out_buf[1] = 111; out_buf[2] = 105; out_buf[3] = 100; return 4;
  }
  /* ptr: "*" + 不做递归；只输出 "*" */
  if (ko == 9 && out_cap >= 2) {
    out_buf[0] = 42; return 1;
  }
  /* named: 直接输出名字 */
  if (ko == 8 && out_cap > 0) {
    let nm: u8[64] = [];
    let nlen: i32 = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
    if (nlen > 0 && nlen <= 64 && out_cap > nlen) {
      let i: i32 = 0;
      while (i < nlen) {
        out_buf[i] = nm[i];
        i = i + 1;
      }
      return nlen;
    }
  }
  /* fallback */
  if (out_cap >= 2) { out_buf[0] = 63; return 1; }
  return 0;
  }
  return 0;
}

/* ============ references（arena 全量扫描） ============ */

/**
* 扫描 arena 中所有 EXPR_CALL，收集 call_resolved_func_index==func_index 且 line>0
* 的调用点。
* 写入 out_lines/out_cols（1-based），返回条目数，最多 max_refs。
*/
export function lsp_collect_call_refs(arena: *ASTArena, func_index: i32, out_lines: *i32, out_cols: *i32,
max_refs: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (arena == 0 as *ASTArena || out_lines == 0 as *i32 || out_cols == 0 as *i32 || max_refs <= 0) {
    return 0;
  }
  let ord_call: i32 = 48;
  let count: i32 = 0;
  let ei: i32 = 1;
  while (ei <= arena.num_exprs && count < max_refs) {
    let ek: i32 = pipeline_expr_kind_ord_at(arena, ei);
    let el: i32 = pipeline_expr_line_at(arena, ei);
    let fri: i32 = pipeline_expr_call_resolved_func_index_at(arena, ei);
    if (ek == ord_call && fri == func_index && el > 0) {
      out_lines[count] = el;
      out_cols[count] = pipeline_expr_col_at(arena, ei);
      count = count + 1;
    }
    ei = ei + 1;
  }
  return count;
  }
  return 0;
}

/**
* 在 source 中 (line_0, col_0) 处找引用，收集所有调用点。
* parse+typeck 后先定位 (line,col) 处的 CALL 节点取 func_index，再全量扫描收集。
* 输入/输出坐标为 0-based。返回条目数。供 C 侧调用。
*/
export function lsp_diag_references_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_lines:
*i32, out_cols: *i32, max_refs: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (source == 0 as *u8 || out_lines == 0 as *i32 || out_cols == 0 as *i32 || max_refs <= 0 ||
  source_len < 0) {
    return 0;
  }
  let sl: i32 = source_len;
  if (sl < 0) { sl = 0; }
  let ncopy: usize = sl as usize;
  let ab: usize = ncopy + 1 as usize;
  if (ab == 0 as usize) { ab = 1 as usize; }
  let mut_buf: *u8 = std_heap_alloc(ab);
  if (mut_buf == 0 as *u8) { return 0; }
  if (sl > 0) { copy_bytes(mut_buf, source, ncopy); }
  mut_buf[sl] = 0 as u8;
  lsp_diag_invalidate_cache();
  lsp_diag_collect_begin();
  let rc: i32 = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
  lsp_diag_collect_end();
  if (rc != 0) { std_heap_free(mut_buf); return 0; }
  let arena: *ASTArena = lsp_diag_x_arena_ptr();
  std_heap_free(mut_buf);
  /* 先定位 (line,col) 处的 CALL，取 func_index */
  let line_1: i32 = line_0 + 1;
  let col_1: i32 = col_0 + 1;
  let ord_call: i32 = 48;
  let func_index: i32 = -1;
  let ei: i32 = 1;
  while (ei <= arena.num_exprs) {
    let el: i32 = pipeline_expr_line_at(arena, ei);
    let ec: i32 = pipeline_expr_col_at(arena, ei);
    let ek: i32 = pipeline_expr_kind_ord_at(arena, ei);
    let fri: i32 = pipeline_expr_call_resolved_func_index_at(arena, ei);
    if (el == line_1 && ec == col_1 && ek == ord_call && fri >= 0) {
      func_index = fri;
      break;
    }
    ei = ei + 1;
  }
  if (func_index < 0) { return 0; }
  /* 收集所有调用点（1-based），转 0-based 输出 */
  let tmp_lines: i32[512] = [];
  let tmp_cols: i32[512] = [];
  let n: i32 = lsp_collect_call_refs(arena, func_index, &tmp_lines[0], &tmp_cols[0], 512);
  let out_n: i32 = n;
  if (out_n > max_refs) { out_n = max_refs; }
  let oi: i32 = 0;
  while (oi < out_n) {
    out_lines[oi] = tmp_lines[oi] - 1;
    out_cols[oi] = tmp_cols[oi] - 1;
    oi = oi + 1;
  }
  return out_n;
  }
  return 0;
}

/* ============ definition（parse_into_buf + 源码扫描 function 名） ============ */

/**
* 判断 (line_1,col_1) 是否落在 [span_col, span_col+span_len) 同一行上（均为
* 1-based）。
*/
export function lsp_col_in_ident_span(line_1: i32, col_1: i32, span_line: i32, span_col: i32, span_len:
i32): i32 {
  if (line_1 != span_line || span_len <= 0) {
    return 0;
  }
  if (col_1 >= span_col && col_1 < span_col + span_len) {
    return 1;
  }
  return 0;
}

/**
* 在 source 中扫描 "function <name>"，找到则写出 name
* 起始行列（1-based）；未找到返回 0。
*/
export function lsp_source_find_function_def(source: *u8, sl: i32, name: *u8, name_len: i32, out_line:
*i32, out_col: *i32): i32 {
  if (source == 0 as *u8 || name == 0 as *u8 || name_len <= 0 || sl <= 0 || out_line == 0 as *i32
  || out_col == 0 as *i32) {
    return 0;
  }
  let kw: u8[9] = [102, 117, 110, 99, 116, 105, 111, 110, 32];
  let line: i32 = 1;
  let col: i32 = 1;
  let i: i32 = 0;
  while (i < sl) {
    let boundary: i32 = 0;
    if (i == 0) {
      boundary = 1;
    } else {
      let prev: u8 = source[i - 1];
      if (prev == 32 as u8 || prev == 9 as u8 || prev == 10 as u8) {
        boundary = 1;
      }
    }
    if (boundary != 0 && i + 9 + name_len <= sl) {
      let ki: i32 = 0;
      let kw_ok: i32 = 1;
      while (ki < 9) {
        if (source[i + ki] != kw[ki]) {
          kw_ok = 0;
          break;
        }
        ki = ki + 1;
      }
      if (kw_ok != 0) {
        let ni: i32 = 0;
        let name_ok: i32 = 1;
        while (ni < name_len) {
          if (source[i + 9 + ni] != name[ni]) {
            name_ok = 0;
            break;
          }
          ni = ni + 1;
        }
        if (name_ok != 0) {
          let after: i32 = i + 9 + name_len;
          if (after >= sl) {
            out_line[0] = line;
            out_col[0] = col + 9;
            return 1;
          }
          let ac: u8 = source[after];
          if (ac == 32 as u8 || ac == 40 as u8 || ac == 10 as u8 || ac == 9 as u8) {
            out_line[0] = line;
            out_col[0] = col + 9;
            return 1;
          }
        }
      }
    }
    if (source[i] == 10 as u8) {
      line = line + 1;
      col = 1;
    } else {
      col = col + 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
* 在 module 中按 func_index 查源码定义行列（1-based）；Func 池无 line
* 字段，故扫描 "function name"。
*/
export function lsp_func_def_pos_in_source(source: *u8, sl: i32, module: *Module, func_index: i32,
out_line: *i32, out_col: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
    return 0;
  }
  let nl: i32 = pipeline_module_func_name_len_at(module, func_index);
  if (nl <= 0 || nl > 64) {
    return 0;
  }
  let nm: u8[64] = [];
  pipeline_module_func_name_copy64(module, func_index, &nm[0]);
  return lsp_source_find_function_def(source, sl, &nm[0], nl, out_line, out_col);
  }
  return 0;
}

/**
* 在 (line_0,col_0)（0-based）处查找定义；成功返回 1 并写 0-based out_line/out_col。
* 走 parse_into_buf + typeck；Func 定义位置由源码扫描 "function name" 得到。
*/
export function lsp_diag_definition_at(source: *u8, source_len: i32, line_0: i32, col_0: i32, out_line:
*i32, out_col: *i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (source == 0 as *u8 || out_line == 0 as *i32 || out_col == 0 as *i32 || source_len < 0) {
    return 0;
  }
  let sl: i32 = source_len;
  let ncopy: usize = sl as usize;
  let ab: usize = ncopy + 1 as usize;
  if (ab == 0 as usize) { ab = 1 as usize; }
  let mut_buf: *u8 = std_heap_alloc(ab);
  if (mut_buf == 0 as *u8) { return 0; }
  if (sl > 0) { copy_bytes(mut_buf, source, ncopy); }
  mut_buf[sl] = 0 as u8;
  lsp_diag_invalidate_cache();
  lsp_diag_collect_begin();
  let rc: i32 = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
  lsp_diag_collect_end();
  if (rc != 0) { std_heap_free(mut_buf); return 0; }
  let module: *Module = lsp_diag_x_module_ptr();
  let arena: *ASTArena = lsp_diag_x_arena_ptr();
  let line_1: i32 = line_0 + 1;
  let col_1: i32 = col_0 + 1;
  let def_l1: i32 = 0;
  let def_c1: i32 = 0;
  /* 光标在函数名上：定义即该函数（含 extern）。 */
  let fi: i32 = 0;
  while (fi < module.num_funcs) {
    if (lsp_func_def_pos_in_source(mut_buf, sl, module, fi, &def_l1, &def_c1) != 0) {
      let nl2: i32 = pipeline_module_func_name_len_at(module, fi);
      if (lsp_col_in_ident_span(line_1, col_1, def_l1, def_c1, nl2) != 0) {
        out_line[0] = def_l1 - 1;
        out_col[0] = def_c1 - 1;
        std_heap_free(mut_buf);
        return 1;
      }
    }
    fi = fi + 1;
  }
  /* 调用处：找 (line,col) 的 CALL，跳转到 resolved 函数定义。 */
  let ord_call: i32 = 48;
  let func_index: i32 = -1;
  let ei: i32 = 1;
  while (ei <= arena.num_exprs) {
    let el: i32 = pipeline_expr_line_at(arena, ei);
    let ec: i32 = pipeline_expr_col_at(arena, ei);
    let ek: i32 = pipeline_expr_kind_ord_at(arena, ei);
    let fri: i32 = pipeline_expr_call_resolved_func_index_at(arena, ei);
    if (el == line_1 && ec == col_1 && ek == ord_call && fri >= 0) {
      func_index = fri;
      break;
    }
    ei = ei + 1;
  }
  if (func_index >= 0 && lsp_func_def_pos_in_source(mut_buf, sl, module, func_index, &def_l1,
  &def_c1) != 0) {
    out_line[0] = def_l1 - 1;
    out_col[0] = def_c1 - 1;
    std_heap_free(mut_buf);
    return 1;
  }
  std_heap_free(mut_buf);
  return 0;
  }
  return 0;
}

/* ============ semanticTokens（arena 全量扫描，产出 LSP delta 五元组） ============ */

/**
* 扫描 arena 中所有表达式，产出 LSP SemanticTokens delta 编码的五元组：
* (deltaLine, deltaStart, length, tokenType, tokenModifiers)。
* 写入 out_data（i32 数组），返回写入的 i32 个数（= 5 * token_count）。
*/
export function lsp_collect_semantic_tokens(arena: *ASTArena, out_data: *i32, out_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (arena == 0 as *ASTArena || out_data == 0 as *i32 || out_cap < 5) {
    return 0;
  }
  /* ExprKind 序：LIT=0 FLOAT=1 VAR=3 FIELD=44 STRUCT_LIT=45 CALL=48 METHOD=49 ENUM_VARIANT=50 AS=54 */
  let ord_lit: i32 = 0;
  let ord_float: i32 = 1;
  let ord_var: i32 = 3;
  let ord_field: i32 = 44;
  let ord_struct_lit: i32 = 45;
  let ord_call: i32 = 48;
  let ord_method: i32 = 49;
  let ord_enum_var: i32 = 50;
  let ord_as: i32 = 54;
  let count: i32 = 0;
  let prev_line: i32 = 0;
  let prev_start: i32 = 0;
  /* 遍历 arena 中所有表达式（标量读，勿 Expr 按值） */
  let ei: i32 = 1;
  while (ei <= arena.num_exprs && count + 5 <= out_cap) {
    let el: i32 = pipeline_expr_line_at(arena, ei);
    let ec: i32 = pipeline_expr_col_at(arena, ei);
    if (el <= 0 || ec <= 0) { ei = ei + 1; continue; }
    let line0: i32 = el - 1; /* 0-based */
    let start0: i32 = ec - 1;
    let vlen: i32 = pipeline_expr_var_name_len(arena, ei);
    let len: i32 = vlen;
    if (len <= 0) { len = 1; }
    let token_type: i32 = -1;
    let modifiers: i32 = 0;
    let ek: i32 = pipeline_expr_kind_ord_at(arena, ei);

    if (ek == ord_var) {
      token_type = 8; /* variable */
      if (pipeline_expr_resolved_type_ref(arena, ei) != 0) {
        modifiers = 4; /* readonly */
      }
    }
    if (ek == ord_call || ek == ord_method) {
      token_type = 12; /* function */
      if (vlen > 0) { len = vlen; }
    }
    if (ek == ord_struct_lit) {
      token_type = 5; /* struct */
      let sn: i32 = pipeline_expr_struct_lit_type_name_len(arena, ei);
      if (sn > 0) { len = sn; }
    }
    if (ek == ord_enum_var) {
      token_type = 3; /* enum */
      if (vlen > 0) { len = vlen; }
    }
    if (ek == ord_lit) {
      token_type = 19; /* number */
      len = 1;
    }
    if (ek == ord_float) {
      token_type = 19; /* number */
      len = 1;
    }
    if (ek == ord_field) {
      token_type = 9; /* property */
      let flen: i32 = pipeline_expr_field_access_name_len(arena, ei);
      if (flen > 0) { len = flen; }
    }
    if (ek == ord_as) {
      token_type = 8; /* variable */
    }

    if (token_type >= 0) {
      /* 计算 delta */
      let delta_line: i32 = line0 - prev_line;
      let delta_start: i32 = 0;
      if (delta_line == 0) { delta_start = start0 - prev_start; }
      else { delta_start = start0; }
      out_data[count] = delta_line;     count = count + 1;
      out_data[count] = delta_start;    count = count + 1;
      out_data[count] = len;            count = count + 1;
      out_data[count] = token_type;     count = count + 1;
      out_data[count] = modifiers;      count = count + 1;
      prev_line = line0;
      prev_start = start0;
    }
    ei = ei + 1;
  }
  return count;
  }
  return 0;
}

/**
* 构建 semanticTokens/full 的 JSON-RPC 响应正文：
* {"jsonrpc":"2.0","id":ID,"result":{"data":[...]}}
* doc_buf/doc_len 为当前文档内容；out_buf/out_cap 为输出缓冲。
* 返回写入长度，失败返回 -1。
*/
export function lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8,
out_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // C glue / pipeline_* / heap externs only; no second evaluation path.
  unsafe {
  if (doc_buf == 0 as *u8 || out_buf == 0 as *u8 || out_cap <= 0 || doc_len < 0) {
    return -1;
  }
  let sl: i32 = doc_len;
  let ncopy: usize = sl as usize;
  let ab: usize = ncopy + 1 as usize;
  if (ab == 0 as usize) { ab = 1 as usize; }
  let mut_buf: *u8 = std_heap_alloc(ab);
  if (mut_buf == 0 as *u8) { return -1; }
  if (sl > 0) { copy_bytes(mut_buf, doc_buf, ncopy); }
  mut_buf[sl] = 0 as u8;
  lsp_diag_invalidate_cache();
  lsp_diag_collect_begin();
  let rc: i32 = lsp_diag_run_pipeline_on_buf(mut_buf, sl);
  lsp_diag_collect_end();
  if (rc != 0) { std_heap_free(mut_buf); return -1; }
  let arena: *ASTArena = lsp_diag_x_arena_ptr();
  std_heap_free(mut_buf);
  
  /* 收集 token 五元组 */
  let token_cap: i32 = 4096;
  let token_bytes: usize = (token_cap * 4) as usize;
  let token_data_raw: *u8 = std_heap_alloc(token_bytes);
  let token_data: *i32 = token_data_raw as *i32;
  if (token_data == 0 as *i32) { return -1; }
  let n_tokens: i32 = lsp_collect_semantic_tokens(arena, token_data, token_cap);
  
  /* 构建 JSON: {"jsonrpc":"2.0","id":ID,"result":{"data":[...]}} */
  let json_cap: i32 = 262144;
  let json_ptr: *u8 = std_heap_alloc(json_cap as usize);
  if (json_ptr == 0 as *u8) { std_heap_free(token_data as *u8); return -1; }
  
  /* 手写 JSON 前缀 */
  let prefix: u8[64] = [];
  let pi: i32 = 0;
  prefix[0]=123; prefix[1]=34; prefix[2]=106; prefix[3]=115; prefix[4]=111; prefix[5]=110; prefix[6]=114;
  prefix[7]=112; prefix[8]=99; prefix[9]=34; prefix[10]=58; prefix[11]=34; prefix[12]=50; prefix[13]=46;
  prefix[14]=48; prefix[15]=34; prefix[16]=44; prefix[17]=34; prefix[18]=105; prefix[19]=100;
  prefix[20]=34; prefix[21]=58;
  pi = 22;
  /* 写入 id */
  let id_str: u8[12] = [];
  let id_len: i32 = 0;
  let tmp: i32 = id_val;
  if (tmp == 0) { id_str[0] = 48; id_len = 1; }
  else {
    let ds: i32[12] = [];
    let dn: i32 = 0;
    while (tmp > 0) { ds[dn] = tmp % 10; tmp = tmp / 10; dn = dn + 1; }
    let di: i32 = dn - 1;
    while (di >= 0) { id_str[id_len] = (ds[di] + 48) as u8; id_len = id_len + 1; di = di - 1; }
  }
  let ji: i32 = 0;
  while (ji < id_len && pi < 64) { prefix[pi] = id_str[ji]; pi = pi + 1; ji = ji + 1; }
  prefix[pi]=44; pi=pi+1;
  prefix[pi]=34; pi=pi+1;
  prefix[pi]=114; pi=pi+1;
  prefix[pi]=101; pi=pi+1;
  prefix[pi]=115; pi=pi+1;
  prefix[pi]=117; pi=pi+1;
  prefix[pi]=108; pi=pi+1;
  prefix[pi]=116; pi=pi+1;
  prefix[pi]=34; pi=pi+1;
  prefix[pi]=58; pi=pi+1;
  prefix[pi]=123; pi=pi+1;
  prefix[pi]=34; pi=pi+1;
  prefix[pi]=100; pi=pi+1;
  prefix[pi]=97; pi=pi+1;
  prefix[pi]=116; pi=pi+1;
  prefix[pi]=97; pi=pi+1;
  prefix[pi]=34; pi=pi+1;
  prefix[pi]=58; pi=pi+1;
  prefix[pi]=91; pi=pi+1; /* data: [ */
  /* 复制到 json_ptr */
  let pj: i32 = 0;
  while (pj < pi) { json_ptr[pj] = prefix[pj]; pj = pj + 1; }
  
  /* 填 token 数值（逗号分隔） */
  let ti: i32 = 0;
  let first: i32 = 1;
  while (ti < n_tokens) {
    let val: i32 = token_data[ti];
    if (first == 0 && pj < json_cap) { json_ptr[pj] = 44; pj = pj + 1; }
    first = 0;
    /* 手动数字转字符串 */
    if (val < 0) { if (pj < json_cap) { json_ptr[pj] = 45; pj = pj + 1; val = -val; } }
    let digits: i32[12] = [];
    let dn: i32 = 0;
    if (val == 0) { digits[0] = 0; dn = 1; }
    else { let v2: i32 = val; while (v2 > 0) { digits[dn] = v2 % 10; v2 = v2 / 10; dn = dn + 1; } }
    let di: i32 = dn - 1;
    while (di >= 0 && pj < json_cap) { json_ptr[pj] = (digits[di] + 48) as u8; pj = pj + 1; di = di
      - 1; }
    ti = ti + 1;
  }
  /* 关闭 data]  }
  return 0;
}
} */
if (pj < json_cap) { json_ptr[pj] = 93; pj = pj + 1; }
if (pj < json_cap) { json_ptr[pj] = 125; pj = pj + 1; }
if (pj < json_cap) { json_ptr[pj] = 125; pj = pj + 1; }

let resp_len: i32 = pj;
/* 复制到 out_buf */
let ri: i32 = 0;
while (ri < resp_len && ri < out_cap) { out_buf[ri] = json_ptr[ri]; ri = ri + 1; }
std_heap_free(json_ptr);
std_heap_free(token_data as *u8);
return resp_len;
}
