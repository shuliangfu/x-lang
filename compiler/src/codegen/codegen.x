// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// codegen.x — 代码生成（纯 .x，完全自举）
//
// 10.4.2 进展：import 前缀、std.io 判定、should_skip_emit、call_num_args_override 均在 .x；
// asm backend.x 经 import codegen 直调 codegen_call_num_args_override，不再依赖 runtime.c。
//
// 职责：将 .x AST（Module + Arena）生成 C 源码，全部逻辑在 .x，不依赖任何 C 业务接口。
// 输出：写入内存缓冲区 CodegenOutBuf，由 C 在调用 pipeline 后将 data[0..len-1] 写到 FILE*。
// 依赖：import ast。
//
// ABI / 可维护性（P3 审计摘要）：用户 struct 字段类型发射走 pipeline_* glue + emit_struct_field_type_via_pipeline，避免 ast_arena_type_get 撕裂；
// emit_expr / FIELD_ACCESS / CALL 等路径仍局部使用 ast_arena_type_get(Expr/Type)，后续可按 pipeline_glue.c 模式逐步收口；
// parser/typeck 中大 StructLayout/Type 写入已由 pipeline_module_struct_layout_* / pipeline_type_* 补丁覆盖，残余按值返回见各模块注释。

const ast = import("ast");

/** dep 池 import 路径读写（定义在 pipeline_glue.c / ast_pool.c）。 */
extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;

/** glue：按池 ref 安全读类型 kind / elem_ref / array_size，避免 X 对大 Type 按值返回撕裂（与 typeck 同源）。 */
extern function pipeline_type_named_name_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
extern function pipeline_type_kind_ord_at(arena: *ASTArena, ref: i32): i32;
extern function pipeline_type_elem_ref_at(arena: *ASTArena, ref: i32): i32;
extern function pipeline_type_array_size_at(arena: *ASTArena, ref: i32): i32;
/** glue：type_to_c_repr 全逻辑在 C，避免 dep prerun 全量 typeck 时 X 大函数 check_block 失败。 */
extern function pipeline_codegen_type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** glue：emit_struct_field_type_via_pipeline 全逻辑在 C，同上。 */
extern function pipeline_codegen_emit_struct_field_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** glue：发射完整 struct 字段声明，修正数组字段 `type name[n]` 顺序。 */
extern function pipeline_codegen_emit_struct_field_decl(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** build_seed_asm_host：SHUX_EMIT_SEED_MEGA=1 时勿跳过 seed_mega emit。 */
extern function pipeline_codegen_emit_seed_mega_enabled(): i32;
/** runtime_driver_diagnostic.c：emit_func 失败时打印函数名下标，便于定位 -E codegen fail。 */
extern function driver_diagnostic_codegen_emit_func_fail(module: *Module, func_index: i32): void;
/** glue：按槽读 Module.struct_layouts，避免 X 对大 StructLayout 按值拷贝读字段不稳。 */
extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out64: *u8): void;
extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
extern function pipeline_module_struct_layout_field_type_ref(module: *Module, layout_idx: i32, field_idx: i32): i32;
extern function pipeline_module_struct_layout_field_name_len(module: *Module, layout_idx: i32, field_idx: i32): i32;
extern function pipeline_module_struct_layout_field_name_into(module: *Module, layout_idx: i32, field_idx: i32, out64: *u8): void;
extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32, off: i32): u8;
extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32, off: i32): u8;
extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
extern function parser_get_module_num_imports(module: *Module): i32;
extern function driver_dep_arena_buf(i: i32): *u8;
extern function driver_dep_module_buf(i: i32): *u8;
extern function driver_dep_seeded_get(i: i32): i32;
extern function driver_dep_slot_for_path(path: *u8): i32;
/** runtime.c：当前 codegen 单元的 dep 逻辑路径（如 std.io.core），dep 池 prefix 不可用时的回退。 */
extern function driver_get_current_dep_path_for_codegen(): *u8;
/** Expr 变长附属池读 API。 */
extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_expr_struct_lit_field_name_len(arena: *ASTArena, expr_ref: i32, j: i32): i32;
extern function pipeline_expr_struct_lit_field_name_into(arena: *ASTArena, expr_ref: i32, j: i32, out: *u8): void;
extern function pipeline_expr_struct_lit_init_ref(arena: *ASTArena, expr_ref: i32, j: i32): i32;
extern function pipeline_expr_struct_lit_num_fields(arena: *ASTArena, expr_ref: i32): i32;
extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
extern function pipeline_module_enum_num_variants(module: *Module, idx: i32): i32;
extern function pipeline_module_enum_variant_name_len(module: *Module, idx: i32, variant_idx: i32): i32;
extern function pipeline_module_enum_variant_name_byte_at(module: *Module, idx: i32, variant_idx: i32, off: i32): u8;
extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
extern function pipeline_codegen_dep_skip_x_bootstrap_partial(path: *u8): i32;
/** glue：C 指针读 module.funcs[fi].name / params[pi].name，避免 .x 嵌套下标 typeck 与 asm GEP 问题。 */
extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
extern function pipeline_module_func_param_name_copy32(module: *Module, fi: i32, pi: i32, dst: *u8): void;
/** glue：读 funcs[fi].num_params 与 params[pi].name_len，供 expr_var_matches_func_param_index 等避免 mod.funcs[fi].params[pi] 下标 typeck。 */
extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_param_name_len_at(module: *Module, fi: i32, pi: i32): i32;
extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
/** codegen 无名形参下标 sidecar 池（ast_pool.c）。 */
extern function pipeline_dep_ctx_empty_param_reset(ctx: *PipelineDepCtx): void;
extern function pipeline_dep_ctx_empty_param_append(ctx: *PipelineDepCtx, pi: i32): i32;
extern function pipeline_dep_ctx_empty_param_at(ctx: *PipelineDepCtx, i: i32): i32;
extern function pipeline_dep_ctx_empty_param_backup(ctx: *PipelineDepCtx): void;
extern function pipeline_dep_ctx_empty_param_restore(ctx: *PipelineDepCtx): void;
extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_used_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_naked_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_entry_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_no_mangle_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_is_interrupt_at(module: *Module, fi: i32): i32;
extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
/** Block 池读（ast_pool.c）；emit_block 经 glue 访问 const/let/if/expr。 */
extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
extern function pipeline_block_const_type_ref(arena: *ASTArena, br: i32, ci: i32): i32;
extern function pipeline_block_const_init_ref(arena: *ASTArena, br: i32, ci: i32): i32;
extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
extern function pipeline_block_let_type_ref(arena: *ASTArena, br: i32, li: i32): i32;
extern function pipeline_block_let_init_ref(arena: *ASTArena, br: i32, li: i32): i32;
extern function pipeline_block_if_cond_ref(arena: *ASTArena, br: i32, ii: i32): i32;
extern function pipeline_block_if_then_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
extern function pipeline_block_if_else_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
/** MEM-B0：defer 子块 body ref（逆序 emit 用）。 */
extern function pipeline_block_defer_body_ref(arena: *ASTArena, br: i32, di: i32): i32;
extern function pipeline_module_func_ref_at(module: *Module, func_index: i32): i32;
/** asm backend：`import a.b.c` + `a.b.c.method` 形式解析 C ABI 符号（backend_call_dispatch.c）。 */
extern function pipeline_asm_resolve_whole_import_qualified_symbol_c(arena: *ASTArena, cur_mod: *Module, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32;
extern function pipeline_block_stmt_order_kind(arena: *ASTArena, br: i32, si: i32): u8;
extern function pipeline_block_stmt_order_idx(arena: *ASTArena, br: i32, si: i32): i32;

/**
 * path 指向的 NUL 结尾字节是否与 "std.io.core" 完全一致（ codegen.c 同名逻辑迁入 .x，减少一处 extern）。
 */
/** import 路径是否为 std.io.driver（与 codegen.c 一致）。 */
function codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
  let expect: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 14) {
    if (path[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

function codegen_path_is_std_io_core_bytes(path: *u8): i32 {
  let expect: u8[12] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101, 0];
  let i: i32 = 0;
  /** asm 后端仅稳定追踪 i32 局部；u8 槽不在 ctx（pi/ei 须 i32 再与 expect 字节比）。 */
  let pi: i32 = 0;
  let ei: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (i < 12) {
    pi = path[i] as i32;
    ei = expect[i] as i32;
    if (pi != ei) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * 将 import 路径转为 C 符号前缀（ASCII：`.`→`_`，末尾再补 `_`），与 codegen.c import_path_to_c_prefix 对齐。
 * path 为空指针视作空路径；buf_cap≤0 时不写入；缓冲区内保证写入结尾 NUL。
 */
function codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void {
  if (buf == 0 as *u8 || buf_cap <= 0) {
    return;
  }
  let off: i32 = 0;
  let pi: i32 = 0;
  while (path != 0 as *u8) {
    let ch: u8 = path[pi];
    if (ch == 0 as u8) {
      break;
    }
    if (off + 2 >= buf_cap) {
      break;
    }
    if (ch == 46 as u8) {
      buf[off] = 95 as u8;
    } else {
      buf[off] = ch;
    }
    off = off + 1;
    pi = pi + 1;
  }
  if (off + 1 < buf_cap) {
    buf[off] = 95 as u8;
    off = off + 1;
  }
  buf[off] = 0 as u8;
}

/**
 * 将 dep 池第 idx 个逻辑 import 路径拷入 dst（64 字节）；无路径返回 0，否则返回字节长度。
 */
function codegen_dep_import_path_len_at(ctx: *PipelineDepCtx, idx: i32, dst: *u8): i32 {
  let plen: i32 = pipeline_dep_ctx_import_path_len(ctx, idx);
  if (plen <= 0) {
    return 0;
  }
  pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
  return plen;
}

/**
 * 在 dep 池中查找 current_codegen_module，路径写入 dst；返回长度，0 表示未找到或无路径。
 */
function codegen_ctx_dep_path_for_current_codegen_module_into(ctx: *PipelineDepCtx, dst: *u8): i32 {
  if (ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  let nd: i32 = pipeline_dep_ctx_ndep(ctx);
  let j: i32 = 0;
  while (j < nd) {
    if (pipeline_dep_ctx_module_at(ctx, j) == ctx.current_codegen_module) {
      return codegen_dep_import_path_len_at(ctx, j, dst);
    }
    j = j + 1;
  }
  return 0;
}

/**
 * 读取当前 codegen 模块第 import_idx 条 import 的原始 import path。
 * 返回长度，0 表示当前模块为空、索引无效或未记录路径。
 */
function codegen_module_import_path_len_at(module: *Module, import_idx: i32, dst: *u8): i32 {
  if (module == 0 as *Module || dst == 0 as *u8 || import_idx < 0) {
    return 0;
  }
  let plen: i32 = pipeline_module_import_path_len(module, import_idx);
  if (plen <= 0) {
    return 0;
  }
  pipeline_module_import_path_copy(module, import_idx, dst, 64);
  return plen;
}

/**
 * 以 import path 精确匹配 dep_ctx 中的全局 dep 槽位，返回 dep index；找不到返回 -1。
 */
function codegen_find_dep_index_by_path(ctx: *PipelineDepCtx, path: *u8, path_len: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx || path == 0 as *u8 || path_len <= 0) {
    return -1;
  }
  let di: i32 = 0;
  let nd: i32 = pipeline_dep_ctx_ndep(ctx);
  while (di < nd) {
    let dep_path: u8[64] = [];
    let dep_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
    if (dep_len == path_len) {
      let eq: bool = true;
      let k: i32 = 0;
      while (k < path_len && k < 64) {
        if (dep_path[k] != path[k]) {
          eq = false;
          break;
        }
        k = k + 1;
      }
      if (eq) {
        return di;
      }
    }
    di = di + 1;
  }
  return -1;
}

function codegen_find_seeded_global_dep_slot_by_path(path: *u8, path_len: i32): i32 {
  if (path == 0 as *u8 || path_len <= 0 || path_len > 63) {
    return -1;
  }
  let path_buf: u8[64] = [];
  let i: i32 = 0;
  while (i < path_len && i < 63) {
    path_buf[i] = path[i];
    i = i + 1;
  }
  path_buf[i] = 0 as u8;
  let gs: i32 = driver_dep_slot_for_path(&path_buf[0]);
  if (gs >= 0 && driver_dep_seeded_get(gs) != 0) {
    return gs;
  }
  return -1;
}

function codegen_module_num_imports(module: *Module): i32 {
  if (module == 0 as *Module) {
    return 0;
  }
  let n_imp: i32 = parser_get_module_num_imports(module);
  if (n_imp > 0) {
    return n_imp;
  }
  return module.num_imports;
}

/**
 * 根据当前 codegen 模块在 dep 池中的逻辑路径，写入与 emit_func 一致的 C 符号前缀（buf 内 NUL 结尾），返回前缀字节长度（不含 NUL）。
 * 主模块未出现在 dep 池中时路径为空，返回 0；std.io.core 与 codegen_x_ast 一致不加前缀。
 */
function codegen_emit_prefix_len_from_ctx(ctx: *PipelineDepCtx, buf: *u8, buf_cap: i32): i32 {
  if (buf == 0 as *u8 || buf_cap <= 0 || ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  buf[0] = 0 as u8;
  if (ctx.current_codegen_prefix_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.current_codegen_prefix_len && pi < buf_cap - 1) {
      buf[pi] = ctx.current_codegen_prefix_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
  let path_buf: u8[64] = [];
  let path_len: i32 = 0;
  if (ctx.current_codegen_dep_index >= 0) {
    path_len = codegen_dep_import_path_len_at(ctx, ctx.current_codegen_dep_index, &path_buf[0]);
  }
  if (path_len == 0) {
    path_len = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &path_buf[0]);
  }
  if (path_len == 0) {
    return 0;
  }
  if (codegen_path_is_std_io_core_bytes(&path_buf[0]) != 0) {
    return 0;
  }
  codegen_import_path_to_c_prefix_into(&path_buf[0], buf, buf_cap);
  let i: i32 = 0;
  while (i < buf_cap && buf[i] != 0 as u8) {
    i = i + 1;
  }
  return i;
}

/** 按形参类型选择 run v4 seed push 入口；与 codegen.c codegen_run_seed_push_fn 对齐。 */
function codegen_emit_async_run_seed_push_name(out: *CodegenOutBuf, arena: *ASTArena, type_ref: i32): i32 {
  let push_i32: u8[28] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 51, 50];
  let push_u32: u8[28] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 51, 50];
  let push_i64: u8[28] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 105, 54, 52];
  let push_usize: u8[30] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 112, 117, 115, 104, 95, 117, 115, 105, 122, 101];
  let kind_ord: i32 = TypeKind.TYPE_I32 as i32;
  if (arena != 0 as *ASTArena && !ast.ref_is_null(type_ref)) {
    kind_ord = pipeline_type_kind_ord_at(arena, type_ref);
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    return emit_bytes_from_ptr(out, &push_u32[0], 28);
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    return emit_bytes_from_ptr(out, &push_i64[0], 28);
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    return emit_bytes_from_ptr(out, &push_usize[0], 30);
  }
  return emit_bytes_from_ptr(out, &push_i32[0], 28);
}

/** 输出 async 调度 wrapper 调用 `shux_async_sched_<fn>()`。 */
function codegen_emit_async_sched_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  let sched_prefix: u8[17] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
  let fn_name: u8[64] = [];
  let fn_len: i32 = 0;
  if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
    return -1;
  }
  fn_len = pipeline_module_func_name_len_at(module, func_index);
  if (fn_len <= 0) {
    return -1;
  }
  pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
  if (emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  return append_byte(out, 41);
}

/** 输出 async 调度 wrapper 调用 `shux_async_sched_<name>()`。 */
function codegen_emit_async_sched_call_by_name(out: *CodegenOutBuf, fn_name: *u8, fn_len: i32): i32 {
  let sched_prefix: u8[17] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 115, 99, 104, 101, 100, 95];
  if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &sched_prefix[0], 17) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  return append_byte(out, 41);
}

/** 输出 `shux_async_task_submit((int32_t (*)(void))fn)`；与 C 路径 spawn 对齐。 */
function codegen_emit_async_task_submit_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  let submit_name: u8[22] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
  let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
  let fn_name: u8[64] = [];
  let fn_len: i32 = 0;
  if (module == 0 as *Module || func_index < 0 || func_index >= module.num_funcs) {
    return -1;
  }
  fn_len = pipeline_module_func_name_len_at(module, func_index);
  if (fn_len <= 0) {
    return -1;
  }
  pipeline_module_func_name_copy64(module, func_index, &fn_name[0]);
  if (emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 41) != 0) {
    return -1;
  }
  return 0;
}

/** 输出 `shux_async_task_submit((int32_t (*)(void))prefix_name)`；spawn 的 binding import 回退路径复用。 */
function codegen_emit_async_task_submit_call_by_symbol(out: *CodegenOutBuf, prefix: *u8, prefix_len: i32, fn_name: *u8, fn_len: i32): i32 {
  let submit_name: u8[22] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 116, 97, 115, 107, 95, 115, 117, 98, 109, 105, 116];
  let cast_prefix: u8[19] = [40, 105, 110, 116, 51, 50, 95, 116, 32, 40, 42, 41, 40, 118, 111, 105, 100, 41, 41];
  if (out == 0 as *CodegenOutBuf || fn_name == 0 as *u8 || fn_len <= 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &submit_name[0], 22) != 0) {
    return -1;
  }
  if (append_byte(out, 40) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, &cast_prefix[0], 19) != 0) {
    return -1;
  }
  if (prefix != 0 as *u8 && prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, fn_name, fn_len) == 0 && emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, fn_name, fn_len) != 0) {
    return -1;
  }
  if (append_byte(out, 41) != 0) {
    return -1;
  }
  return 0;
}

/** binding import 的 run/spawn 回退：直接按 `binding.fn(...)` 的字段名与 import 前缀发射，避免依赖 dep module 元数据。 */
function codegen_emit_async_binding_import_call(arena: *ASTArena, out: *CodegenOutBuf, call_expr_ref: i32, ctx: *PipelineDepCtx, is_spawn: i32): i32 {
  let reset_name: u8[25] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
  let comma: u8[3] = [44, 32, 0];
  let dep_path: u8[64] = [];
  let prefix_buf: u8[128] = [];
  let dep_ix: i32 = -1;
  let n_args: i32 = 0;
  let ai: i32 = 0;
  let prefix_len: i32 = 0;
  if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
    return -1;
  }
  let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
  if (call_e.kind != ExprKind.EXPR_CALL || ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
    return -1;
  }
  let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
  if (callee_e.kind != ExprKind.EXPR_FIELD_ACCESS || callee_e.field_access_field_len <= 0) {
    return -1;
  }
  n_args = call_e.call_num_args;
  if (n_args < 0) {
    return -1;
  }
  if (is_spawn == 0) {
    if (n_args > 0) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      ai = 0;
      while (ai < n_args) {
        let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
        let arg_type_ref: i32 = 0;
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref)) {
          arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return codegen_emit_async_sched_call_by_name(out, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
  }
  dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, call_e.call_callee_ref);
  if (dep_ix < 0 || dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
    return -1;
  }
  pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
  codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
  while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
    prefix_len = prefix_len + 1;
  }
  if (n_args > 0) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    ai = 0;
    while (ai < n_args) {
      let arg_ref2: i32 = pipeline_expr_call_arg_ref(arena, call_expr_ref, ai);
      let arg_type_ref2: i32 = 0;
      if (ai > 0 && emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(arg_ref2)) {
        arg_type_ref2 = pipeline_expr_resolved_type_ref(arena, arg_ref2);
      }
      if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref2) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(arg_ref2) && emit_expr(arena, out, arg_ref2, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    if (emit_bytes_3(out, comma, 2) != 0) {
      return -1;
    }
    if (codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  return codegen_emit_async_task_submit_call_by_symbol(out, &prefix_buf[0], prefix_len, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
}

/** `run dep.fn(args)` 等 METHOD_CALL async 回退：run 仅依赖 method 名，不需要 dep 前缀。 */
function codegen_emit_async_method_call_run(arena: *ASTArena, out: *CodegenOutBuf, method_expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  let reset_name: u8[25] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
  let comma: u8[3] = [44, 32, 0];
  let ai: i32 = 0;
  if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return -1;
  }
  if (ast.ref_is_null(method_expr_ref) || method_expr_ref <= 0 || method_expr_ref > arena.num_exprs) {
    return -1;
  }
  let method_e: Expr = ast.ast_arena_expr_get(arena, method_expr_ref);
  if (method_e.kind != ExprKind.EXPR_METHOD_CALL || method_e.method_call_name_len <= 0) {
    return -1;
  }
  if (method_e.method_call_num_args > 0) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    while (ai < method_e.method_call_num_args) {
      let arg_ref: i32 = pipeline_expr_method_call_arg_ref(arena, method_expr_ref, ai);
      let arg_type_ref: i32 = 0;
      if (emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(arg_ref)) {
        arg_type_ref = pipeline_expr_resolved_type_ref(arena, arg_ref);
      }
      if (codegen_emit_async_run_seed_push_name(out, arena, arg_type_ref) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    if (emit_bytes_3(out, comma, 2) != 0) {
      return -1;
    }
    if (codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  return codegen_emit_async_sched_call_by_name(out, &method_e.method_call_name[0], method_e.method_call_name_len);
}

/** 线性扫描 module.funcs，按 ASCII 函数名返回下标；找不到返回 -1。 */
function codegen_find_module_func_index_by_name(module: *Module, nm: *u8, nm_len: i32): i32 {
  if (module == 0 as *Module || nm == 0 as *u8 || nm_len <= 0) {
    return -1;
  }
  let fi: i32 = 0;
  while (fi < module.num_funcs) {
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len == nm_len && fn_len > 0) {
      let fn_name: u8[64] = [];
      let matched: i32 = 1;
      let bi: i32 = 0;
      pipeline_module_func_name_copy64(module, fi, &fn_name[0]);
      while (bi < fn_len) {
        if (fn_name[bi] != nm[bi]) {
          matched = 0;
          bi = fn_len;
        } else {
          bi = bi + 1;
        }
      }
      if (matched != 0) {
        return fi;
      }
    }
    fi = fi + 1;
  }
  return -1;
}

/** 绑定 import（`const dep = import("...")`）的 `dep.fn(...)` 回退解析依赖槽，找不到返回 -1。 */
function codegen_resolve_binding_import_dep_index(ctx: *PipelineDepCtx, arena: *ASTArena, callee_expr_ref: i32): i32 {
  if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || ctx.current_codegen_module == 0 as *Module) {
    return -1;
  }
  if (ast.ref_is_null(callee_expr_ref) || callee_expr_ref <= 0 || callee_expr_ref > arena.num_exprs) {
    return -1;
  }
  let callee_e: Expr = ast.ast_arena_expr_get(arena, callee_expr_ref);
  if (callee_e.kind != ExprKind.EXPR_FIELD_ACCESS || callee_e.field_access_base_ref <= 0 || callee_e.field_access_base_ref > arena.num_exprs) {
    return -1;
  }
  let base_e: Expr = ast.ast_arena_expr_get(arena, callee_e.field_access_base_ref);
  if (base_e.kind != ExprKind.EXPR_VAR || base_e.var_name_len <= 0 || base_e.var_name_len > 63) {
    return -1;
  }
  let cur_mod: *Module = ctx.current_codegen_module;
  let nd: i32 = pipeline_dep_ctx_ndep(ctx);
  let j: i32 = 0;
  let n_imp: i32 = codegen_module_num_imports(cur_mod);
  while (j < n_imp && j < nd) {
    if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
      let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
      if (bind_len == base_e.var_name_len) {
        let matched: i32 = 1;
        let kk: i32 = 0;
        while (kk < bind_len) {
          if (base_e.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
            matched = 0;
            kk = bind_len;
          } else {
            kk = kk + 1;
          }
        }
        if (matched != 0) {
          let import_path: u8[64] = [];
          let import_path_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &import_path[0]);
          if (import_path_len <= 0) {
            return -1;
          }
          return codegen_find_dep_index_by_path(ctx, &import_path[0], import_path_len);
        }
      }
    }
    j = j + 1;
  }
  return -1;
}

/** run/spawn 的 resolved_func_index 未填稳时，回退按 callee/method 名在线性扫描目标模块函数。 */
function codegen_resolve_call_target_func_index(arena: *ASTArena, module: *Module, call_expr_ref: i32): i32 {
  let func_ix: i32 = -1;
  if (module == 0 as *Module || arena == 0 as *ASTArena) {
    return -1;
  }
  func_ix = pipeline_expr_call_resolved_func_index_at(arena, call_expr_ref);
  if (func_ix >= 0 && func_ix < module.num_funcs) {
    return func_ix;
  }
  if (ast.ref_is_null(call_expr_ref) || call_expr_ref <= 0 || call_expr_ref > arena.num_exprs) {
    return -1;
  }
  let call_e: Expr = ast.ast_arena_expr_get(arena, call_expr_ref);
  if (call_e.kind == ExprKind.EXPR_CALL) {
    if (ast.ref_is_null(call_e.call_callee_ref) || call_e.call_callee_ref <= 0 || call_e.call_callee_ref > arena.num_exprs) {
      return -1;
    }
    let callee_e: Expr = ast.ast_arena_expr_get(arena, call_e.call_callee_ref);
    if (callee_e.kind == ExprKind.EXPR_VAR && callee_e.var_name_len > 0) {
      return codegen_find_module_func_index_by_name(module, &callee_e.var_name[0], callee_e.var_name_len);
    }
    if (callee_e.kind == ExprKind.EXPR_FIELD_ACCESS && callee_e.field_access_field_len > 0) {
      return codegen_find_module_func_index_by_name(module, &callee_e.field_access_field_name[0], callee_e.field_access_field_len);
    }
    return -1;
  }
  if (call_e.kind == ExprKind.EXPR_METHOD_CALL && call_e.method_call_name_len > 0) {
    return codegen_find_module_func_index_by_name(module, &call_e.method_call_name[0], call_e.method_call_name_len);
  }
  return -1;
}

/**
 * 判断 field_access 的 base 是否为指向函数第 param_idx 个形参的 EXPR_VAR（含「恰好一个无名形参」时的无名 VAR）。
 * 多无名形参时不尝试绑定，避免与 current_emit_empty_var_next_index 顺序耦合。
 * 自举：勿将 module.funcs[func_index] 或 Param 按值拷入局部，改经 mod.funcs[func_index].params[param_idx] 逐字段读。
 */
function expr_var_matches_func_param_index(arena: *ASTArena, var_ref: i32, mod: *Module, func_index: i32, param_idx: i32, ctx: *PipelineDepCtx): i32 {
  if (ast.ref_is_null(var_ref) || var_ref <= 0 || var_ref > arena.num_exprs) {
    return 0;
  }
  if (func_index < 0 || func_index >= mod.num_funcs) {
    return 0;
  }
  /** 经 glue 读 num_params / 形参名，勿 mod.funcs[fi].params[pi] 嵌套下标（typeck 报 subscript base）。 */
  let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
  if (param_idx < 0 || param_idx >= np) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, var_ref);
  if (base.kind != ExprKind.EXPR_VAR) {
    return 0;
  }
  let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, param_idx);
  if (p_name_len > 0) {
    let pname_buf: u8[32] = [];
    pipeline_module_func_param_name_copy32(mod, func_index, param_idx, &pname_buf[0]);
    if (pname_buf[0] > 32) {
      if (base.var_name_len != p_name_len) {
        return 0;
      }
      if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
        return 0;
      }
      let j: i32 = 0;
      while (j < p_name_len) {
        if (base.var_name[j] != pname_buf[j]) {
          return 0;
        }
        j = j + 1;
      }
      return 1;
    }
  }
  if (ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  if (ctx.current_func_single_empty_param_index != param_idx) {
    return 0;
  }
  if (base.var_name_len <= 0 || (base.var_name[0] <= 32)) {
    return 1;
  }
  return 0;
}

/** prefix+name 拼成的完整 C 符号与字面量逐字节比较；长度不一或指针为空则不相等。 */
function codegen_symbuf_bytes_eq(buf: *u8, buf_len: i32, lit: *u8, lit_len: i32): i32 {
  if (buf == 0 as *u8 || lit == 0 as *u8 || buf_len != lit_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < lit_len) {
    if (buf[i] != lit[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * 对已知 0/1 参封装强制发射的实参个数（避免 0 参生成 (0,0)、单参族在 AST 误多参时压到 1）。
 * prefix/name 与已写 C 符号的前缀+标识符一致；逐字节拼接后与已知全名表匹配（无 strcmp）。
 */
function codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
  if (num_args <= 0) {
    return num_args;
  }
  let buf: u8[96] = [];
  let full: i32 = 0;
  let i: i32 = 0;
  if (prefix != 0 as *u8 && prefix_len > 0) {
    i = 0;
    while (i < prefix_len && full < 96) {
      buf[full] = prefix[i];
      full = full + 1;
      i = i + 1;
    }
  }
  if (name != 0 as *u8 && name_len > 0) {
    i = 0;
    while (i < name_len && full < 96) {
      buf[full] = name[i];
      full = full + 1;
      i = i + 1;
    }
  }
  let z0: u8[13] = [118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z1: u8[21] = [115,116,100,95,118,101,99,95,118,101,99,95,108,101,110,95,101,109,112,116,121];
  let z2: u8[15] = [97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z3: u8[24] = [115,116,100,95,104,101,97,112,95,97,108,108,111,99,95,115,105,122,101,95,122,101,114,111];
  let z4: u8[13] = [114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z5: u8[25] = [115,116,100,95,114,117,110,116,105,109,101,95,114,117,110,116,105,109,101,95,114,101,97,100,121];
  let z6: u8[10] = [115,116,114,105,110,103,95,110,101,119];
  let z7: u8[21] = [115,116,100,95,115,116,114,105,110,103,95,115,116,114,105,110,103,95,110,101,119];
  let z8: u8[11] = [112,108,97,99,101,104,111,108,100,101,114];
  let z9: u8[22] = [115,116,100,95,115,116,114,105,110,103,95,112,108,97,99,101,104,111,108,100,101,114];
  let z10: u8[11] = [116,104,114,101,97,100,95,115,101,108,102];
  let z11: u8[22] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,115,101,108,102];
  let z12: u8[22] = [116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z13: u8[33] = [115,116,100,95,116,104,114,101,97,100,95,116,104,114,101,97,100,95,100,117,109,109,121,95,101,110,116,114,121,95,112,116,114];
  let z14: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z15: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,110,115];
  let z16: u8[16] = [110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  let z17: u8[25] = [115,116,100,95,116,105,109,101,95,110,111,119,95,109,111,110,111,116,111,110,105,99,95,109,115];
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z0[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z1[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z2[0], 15) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z3[0], 24) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z4[0], 13) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z5[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z6[0], 10) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z7[0], 21) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z8[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z9[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z10[0], 11) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z11[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z12[0], 22) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z13[0], 33) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z14[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z15[0], 25) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z16[0], 16) != 0) {
    return 0;
  }
  if (codegen_symbuf_bytes_eq(&buf[0], full, &z17[0], 25) != 0) {
    return 0;
  }
  if (num_args >= 1) {
    let o0: u8[7] = [102,109,116,95,105,51,50];
    let o1: u8[16] = [99,111,114,101,95,102,109,116,95,102,109,116,95,105,51,50];
    let o2: u8[9] = [112,114,105,110,116,95,105,51,50];
    let o3: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,51,50];
    let o4: u8[9] = [112,114,105,110,116,95,117,51,50];
    let o5: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,117,51,50];
    let o6: u8[9] = [112,114,105,110,116,95,105,54,52];
    let o7: u8[16] = [115,116,100,95,105,111,95,112,114,105,110,116,95,105,54,52];
    let o8: u8[6] = [111,107,95,105,51,50];
    let o9: u8[18] = [99,111,114,101,95,114,101,115,117,108,116,95,111,107,95,105,51,50];
    let o10: u8[7] = [101,114,114,95,105,51,50];
    let o11: u8[19] = [99,111,114,101,95,114,101,115,117,108,116,95,101,114,114,95,105,51,50];
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o0[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o1[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o2[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o3[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o4[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o5[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o6[0], 9) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o7[0], 16) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o8[0], 6) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o9[0], 18) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o10[0], 7) != 0) {
      return 1;
    }
    if (codegen_symbuf_bytes_eq(&buf[0], full, &o11[0], 19) != 0) {
      return 1;
    }
  }
  return num_args;
}

/**
 * 判断 name 的前 exp_len 字节是否与 expect 所指前缀逐字节相等；空指针或 name_len 不足时返回 0。
 */
function codegen_name_bytes_prefix_eq(name: *u8, name_len: i32, expect: *u8, exp_len: i32): i32 {
  if (name == 0 as *u8 || expect == 0 as *u8 || name_len < exp_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < exp_len) {
    if (name[i] != expect[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * 判断是否为 std_io_driver 在 preamble/runtime ABI 中已提供的桥接函数名（X codegen 不得生成函数体）。
 * name_len 允许与标识符长度或 AST 上报多 1（与 driver_read_ptr 等一致）。
 */
function codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8) {
    return 0;
  }
  /* register — 8 */
  let nm8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  if ((name_len == 8 || name_len == 9) && codegen_name_bytes_prefix_eq(name, name_len, &nm8[0], 8) != 0) {
    return 1;
  }
  /* submit_read — 11 */
  let nm11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  if ((name_len == 11 || name_len == 12) && codegen_name_bytes_prefix_eq(name, name_len, &nm11[0], 11) != 0) {
    return 1;
  }
  /* submit_write — 12 */
  let nm12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &nm12[0], 12) != 0) {
    return 1;
  }
  /* wait_readable — 13 */
  let nm13: u8[13] = [119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101];
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &nm13[0], 13) != 0) {
    return 1;
  }
  /* register_fixed_buffers — 22 */
  let nm22: u8[22] = [114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115];
  if ((name_len == 22 || name_len == 23) && codegen_name_bytes_prefix_eq(name, name_len, &nm22[0], 22) != 0) {
    return 1;
  }
  /* submit_read_batch — 17（标识符 submit_read_batch，非 21） */
  let nm17: u8[17] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104];
  if ((name_len == 17 || name_len == 18) && codegen_name_bytes_prefix_eq(name, name_len, &nm17[0], 17) != 0) {
    return 1;
  }
  /* submit_write_batch — 18（write 比 read 多 1 字符） */
  let nm18w: u8[18] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104];
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &nm18w[0], 18) != 0) {
    return 1;
  }
  return 0;
}

/**
 * std.io.core 的 shux_io_read_fixed 等与 io.o 强符号重复；X 内联 std.io 时仍链 io.o，须跳过 core 段这些函数体。
 */
function codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_core: u8[11] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101];
  let n_rf: u8[17] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100];
  let n_wf: u8[18] = [115, 104, 117, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100];
  let n_srb: u8[24] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104];
  let n_swb: u8[25] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104];
  let n_sr: u8[18] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let n_sw: u8[19] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let di: i32 = 0;
  if (dep_path == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  while (di < 11) {
    if (dep_path[di] != path_core[di]) {
      return 0;
    }
    di = di + 1;
  }
  if ((name_len == 17 || name_len == 18) && codegen_name_bytes_prefix_eq(name, name_len, &n_rf[0], 17) != 0) {
    return 1;
  }
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &n_wf[0], 18) != 0) {
    return 1;
  }
  if ((name_len == 24 || name_len == 25) && codegen_name_bytes_prefix_eq(name, name_len, &n_srb[0], 24) != 0) {
    return 1;
  }
  if ((name_len == 25 || name_len == 26) && codegen_name_bytes_prefix_eq(name, name_len, &n_swb[0], 25) != 0) {
    return 1;
  }
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &n_sr[0], 18) != 0) {
    return 1;
  }
  if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &n_sw[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * std.io 的 handle_stdin/stdout/stderr/from_fd 为字面量返回；若 dep 槽误用 std_io_driver_ 前缀再生成会与 std_io_handle_* 重复。
 * dep_path 非空时须为 std.io（path_io）；prefix-only 分支传 dep_path=0，仅按 name 判断。
 */
function codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  let h_stdin: u8[12] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 105, 110];
  let h_stdout: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 111, 117, 116];
  let h_stderr: u8[13] = [104, 97, 110, 100, 108, 101, 95, 115, 116, 100, 101, 114, 114];
  let h_from_fd: u8[15] = [104, 97, 110, 100, 108, 101, 95, 102, 114, 111, 109, 95, 102, 100, 0];
  let di: i32 = 0;
  if (name == 0 as *u8) {
    return 0;
  }
  if (dep_path != 0 as *u8) {
    while (di < 7) {
      if (dep_path[di] != path_io[di]) {
        return 0;
      }
      di = di + 1;
    }
  }
  if ((name_len == 12 || name_len == 13) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdin[0], 12) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stdout[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 13 || name_len == 14) && codegen_name_bytes_prefix_eq(name, name_len, &h_stderr[0], 13) != 0) {
    return 1;
  }
  if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &h_from_fd[0], 15) != 0) {
    return 1;
  }
  return 0;
}

/**
 * 合并原 driver_should_skip_emit_* 三套逻辑：优先按 prefix+name 拼接是否等于 std_io_driver_driver_read_ptr(_len)；
 * 否则按 dep_path 是否为 std.io.driver/std.io 且 name 为 driver_read_ptr(_len) 判断。
 * dep_path/prefix 可为空指针；prefix_len≤0 时不走前缀拼接分支。
 */
function codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  /* Case A：拼接 prefix+name 等于完整 mangled 名 std_io_driver_driver_read_ptr_len（33）或 std_io_driver_driver_read_ptr（29）。 */
  let full33: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let full29: u8[29] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* Case B：import 路径 NUL 结尾（与 codegen_path_is_std_io_core_bytes 同样逐字节含末尾 NUL）。 */
  let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  /* Case B：标识符本体为 19/15 字节；AST 可能上报 name_len 20/16，与 runtime.c strncmp 上限一致。 */
  let nm_len19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let nm_len15: u8[15] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  let pi: i32 = 0;
  let ni: i32 = 0;
  let ok_path: i32 = 0;
  let di: i32 = 0;
  if (prefix != 0 as *u8 && prefix_len > 0 && name != 0 as *u8 && name_len > 0) {
    let total_len: i32 = prefix_len + name_len;
    if (total_len == 33) {
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full33[pi]) {
          return 0;
        }
        pi = pi + 1;
      }
      ni = 0;
      while (ni < name_len) {
        if (name[ni] != full33[prefix_len + ni]) {
          return 0;
        }
        ni = ni + 1;
      }
      return 1;
    }
    if (total_len == 29) {
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full29[pi]) {
          return 0;
        }
        pi = pi + 1;
      }
      ni = 0;
      while (ni < name_len) {
        if (name[ni] != full29[prefix_len + ni]) {
          return 0;
        }
        ni = ni + 1;
      }
      return 1;
    }
  }
  if (dep_path != 0 as *u8) {
    ok_path = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_path = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_path = 1;
    }
    if (ok_path == 0) {
      di = 0;
      while (di < 7) {
        if (dep_path[di] != path_io[di]) {
          ok_path = 0;
          break;
        }
        di = di + 1;
      }
      if (di == 7) {
        ok_path = 1;
      }
    }
    if (ok_path != 0 && name != 0 as *u8) {
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len19[0], 19) != 0) {
        return 1;
      }
      if ((name_len == 15 || name_len == 16) && codegen_name_bytes_prefix_eq(name, name_len, &nm_len15[0], 15) != 0) {
        return 1;
      }
    }
  }
  /* std_io_driver：preamble 已提供的桥接函数，禁止再生成函数体（prefix 为 std_io_driver_ 或 dep 为 std.io.driver）。 */
  let pref_abi14: u8[14] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95];
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8 && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
    if (codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    let ok_drv_only: i32 = 0;
    di = 0;
    while (di < 14) {
      if (dep_path[di] != path_driver[di]) {
        ok_drv_only = 0;
        break;
      }
      di = di + 1;
    }
    if (di == 14) {
      ok_drv_only = 1;
    }
    if (ok_drv_only != 0 && codegen_is_std_io_driver_bridge_name(name, name_len) != 0) {
      return 1;
    }
  }
  /* dep 误标为 std.io.driver 时 mod 的 handle_* 会以 std_io_driver_handle_* 再生成一次，与 std_io_handle_* 重复。 */
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8) {
    if (codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  if (dep_path != 0 as *u8 && name != 0 as *u8) {
    if (codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len) != 0) {
      return 1;
    }
    let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
    let di2: i32 = 0;
    while (di2 < 14) {
      if (dep_path[di2] != path_driver[di2]) {
        break;
      }
      di2 = di2 + 1;
    }
    if (di2 == 14 && codegen_should_skip_emit_std_io_trivial_handle(0 as *u8, name, name_len) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * 校验 C 前缀是否为 std_io_driver（前 13 字节）；若 prefix_len > 13，则第 14 字节（index 13）须为 NUL 或 '_'。
 * prefix_len == 13 时表示恰好 13 字节字面量，无额外第 14 字节要求。
 */
function codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
  let exp13: u8[13] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114];
  if (prefix == 0 as *u8 || prefix_len < 13) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 13) {
    if (prefix[i] != exp13[i]) {
      return 0;
    }
    i = i + 1;
  }
  if (prefix_len > 13) {
    let b14: u8 = prefix[13];
    if (b14 != 0 as u8 && b14 != 95 as u8) {
      return 0;
    }
  }
  return 1;
}

/**
 * 生成函数定义时：prefix 为 std_io_driver 族且函数为 submit_*_batch_buf 时首参强制 size_t；仅 param_index==0 时可能返回 1。
 */
function codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * io.print 第二参在 .x 为 usize；dep 末尾用于衔接的 extern 桩若误为 int32_t 会与实现体 size_t 冲突。
 * 要求 C 符号前缀前 7 字节为 std_io_（与 codegen_import_path_to_c_prefix 对 std.io 一致）。
 */
function codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  if (param_index != 1) {
    return 0;
  }
  if (name == 0 as *u8 || name_len != 5) {
    return 0;
  }
  /* "print" */
  if (name[0] != 112 || name[1] != 114 || name[2] != 105 || name[3] != 110 || name[4] != 116) {
    return 0;
  }
  let exp7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  if (prefix == 0 as *u8 || prefix_len < 7) {
    return 0;
  }
  let i: i32 = 0;
  while (i < 7) {
    if (prefix[i] != exp7[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/**
 * 生成函数定义时：prefix 为 std_io_driver 族且函数为 register / submit_read / submit_write 时首参强制 ptrdiff_t；仅 param_index==0 时可能返回 1。
 */
function codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (param_index != 0) {
    return 0;
  }
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    return 1;
  }
  return 0;
}

/**
 * 生成函数定义时：prefix 为 std_io_driver 族时按函数名与参数下标强制 uint32_t（timeout_ms/nr 等）；param_index==1 或 ==3 时可能返回 1。
 */
function codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let reg_fixed_buf: u8[33] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 102, 105, 120, 101, 100, 95, 98, 117, 102, 102, 101, 114, 115, 95, 98, 117, 102];
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  if (name == 0 as *u8) {
    return 0;
  }
  if (param_index == 1) {
    if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
      return 1;
    }
    if (name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
      return 1;
    }
    if (name_len == 33 && codegen_name_bytes_prefix_eq(name, name_len, &reg_fixed_buf[0], 33) != 0) {
      return 1;
    }
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
      return 1;
    }
    if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * std.io.core：对 shux_io_register（1 实参）或 shux_io_submit_read / shux_io_submit_write（2 实参）在发射调用名时追加 `_buf`，与 runtime 侧宏一致。
 */
function codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
  let reg15: u8[15] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114];
  let rd18: u8[18] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr19: u8[19] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, &reg15[0], 15) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 18 && codegen_name_bytes_prefix_eq(name, name_len, &rd18[0], 18) != 0) {
    return 1;
  }
  if (num_args == 2 && name_len == 19 && codegen_name_bytes_prefix_eq(name, name_len, &wr19[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * std.io.driver 短名 register/submit_read/submit_write：调用处发射 preamble 的 shux_io_*_buf 包装，避免 struct 实参传给 ptrdiff_t 形参。
 * 返回 1 表示已写入完整 callee 符号名。
 */
function codegen_emit_io_driver_buf_call_name(out: *CodegenOutBuf, name: *u8, name_len: i32, num_args: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let sym_reg: u8[19] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
  let sym_rd: u8[22] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
  let sym_wr: u8[23] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    if (emit_bytes_from_ptr(out, &sym_reg[0], 19) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    if (emit_bytes_from_ptr(out, &sym_rd[0], 22) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    if (emit_bytes_from_ptr(out, &sym_wr[0], 23) != 0) {
      return -1;
    }
    return 1;
  }
  return 0;
}

/**
 * std.io.driver 的 register/submit_read/submit_write 函数体：C 侧首参已为 ptrdiff_t，直接调 shux_io_*_buf 包装。
 * 返回 1 表示已写入完整函数体（含闭合 `}`），调用方应 return 0；0 表示非此类函数。
 */
function codegen_try_emit_std_io_driver_buf_body(out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32): i32 {
  let fn_local: u8[64] = [];
  let fn_len: i32 = 0;
  let nparams: i32 = 0;
  let p0: u8[32] = [98, 117, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let p1: u8[32] = [116, 105, 109, 101, 111, 117, 116, 95, 109, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  let sym_reg: u8[19] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
  let sym_rd: u8[22] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
  let sym_wr: u8[23] = [115, 104, 117, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
  let ret_kw: u8[8] = [32, 32, 114, 101, 116, 117, 114, 110];
  let close_b: u8[3] = [10, 125, 0];
  if (codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) == 0) {
    return 0;
  }
  let p0_len: i32 = 3;
  let p1_len: i32 = 10;
  pipeline_module_func_name_copy64(module, fi, &fn_local[0]);
  fn_len = pipeline_module_func_name_len_at(module, fi);
  nparams = pipeline_module_func_num_params_at(module, fi);
  if (pipeline_module_func_param_name_len_at(module, fi, 0) > 0) {
    pipeline_module_func_param_name_copy32(module, fi, 0, &p0[0]);
    p0_len = pipeline_module_func_param_name_len_at(module, fi, 0);
  }
  if (nparams > 1 && pipeline_module_func_param_name_len_at(module, fi, 1) > 0) {
    pipeline_module_func_param_name_copy32(module, fi, 1, &p1[0]);
    p1_len = pipeline_module_func_param_name_len_at(module, fi, 1);
  }
  if (fn_len == 8 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &reg8[0], 8) != 0 && nparams == 1) {
    if (emit_indent(out, 2) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &sym_reg[0], 19) != 0) { return -1; }
    if (append_byte(out, 40) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
    if (append_byte(out, 41) != 0) { return -1; }
    if (append_byte(out, 59) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
    return 1;
  }
  if (fn_len == 11 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &rd11[0], 11) != 0 && nparams == 2) {
    if (emit_indent(out, 2) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &sym_rd[0], 22) != 0) { return -1; }
    if (append_byte(out, 40) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
    let comma: u8[3] = [44, 32, 0];
    if (emit_bytes_3(out, comma, 2) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
    if (append_byte(out, 41) != 0) { return -1; }
    if (append_byte(out, 59) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
    return 1;
  }
  if (fn_len == 12 && codegen_name_bytes_prefix_eq(&fn_local[0], fn_len, &wr12[0], 12) != 0 && nparams == 2) {
    if (emit_indent(out, 2) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &ret_kw[0], 8) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &sym_wr[0], 23) != 0) { return -1; }
    if (append_byte(out, 40) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &p0[0], p0_len) != 0) { return -1; }
    let comma2: u8[3] = [44, 32, 0];
    if (emit_bytes_3(out, comma2, 2) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &p1[0], p1_len) != 0) { return -1; }
    if (append_byte(out, 41) != 0) { return -1; }
    if (append_byte(out, 59) != 0) { return -1; }
    if (emit_bytes_from_ptr(out, &close_b[0], 2) != 0) { return -1; }
    return 1;
  }
  return 0;
}

/** 从 arena 判断 base 是否为指针，或 slice 形参名 source/out_buf（按指针传）；局部 slice 值用 `.`。 */
function field_access_base_is_pointer_ref(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  let ty: Type = ast.ast_arena_type_get(arena, base.resolved_type_ref);
  if (ty.kind == TypeKind.TYPE_PTR) {
    return 1;
  }
  return 0;
}

/**
 * 回退：base 为已知指针/slice 形参名时字段访问输出 ->。
 * typeck 未填 resolved_type_ref 时仍能生成 (module->field) 等合法 C。
 */
function field_access_base_is_slice_param_name(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
    return 0;
  }
  /* "source" 6 字节：115,111,117,114,99,101 */
  if (base.var_name_len == 6) {
    if (base.var_name[0] == 115 && base.var_name[1] == 111 && base.var_name[2] == 117 && base.var_name[3] == 114 && base.var_name[4] == 99 && base.var_name[5] == 101) {
      return 1;
    }
  }
  /* "out_buf" 7 字节：111,117,116,95,98,117,102 */
  if (base.var_name_len == 7) {
    if (base.var_name[0] == 111 && base.var_name[1] == 117 && base.var_name[2] == 116 && base.var_name[3] == 95 && base.var_name[4] == 98 && base.var_name[5] == 117 && base.var_name[6] == 102) {
      return 1;
    }
  }
  /* 常见 *Module / *ASTArena / *PipelineDepCtx / *CodegenOutBuf / *ElfCodegenCtx 形参名 */
  if (base.var_name_len == 6 && base.var_name[0] == 109 && base.var_name[1] == 111 && base.var_name[2] == 100 && base.var_name[3] == 117 && base.var_name[4] == 108 && base.var_name[5] == 101) {
    return 1;
  }
  if (base.var_name_len == 5 && base.var_name[0] == 97 && base.var_name[1] == 114 && base.var_name[2] == 101 && base.var_name[3] == 110 && base.var_name[4] == 97) {
    return 1;
  }
  if (base.var_name_len == 8 && base.var_name[0] == 101 && base.var_name[1] == 108 && base.var_name[2] == 102 && base.var_name[3] == 95 && base.var_name[4] == 99 && base.var_name[5] == 116 && base.var_name[6] == 120 && base.var_name[7] == 120) {
    return 1;
  }
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  if (base.var_name_len == 3 && base.var_name[0] == 99 && base.var_name[1] == 116 && base.var_name[2] == 120) {
    return 1;
  }
  if (base.var_name_len == 3 && base.var_name[0] == 111 && base.var_name[1] == 117 && base.var_name[2] == 116) {
    return 1;
  }
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  return 0;
}

/** stmt_order 是否已包含块内第 li 条 let（kind=1）。 */
function block_stmt_order_has_let(arena: *ASTArena, block_ref: i32, let_idx: i32): i32 {
  let nso: i32 = ast.ast_block_num_stmt_order(arena, block_ref);
  let si: i32 = 0;
  while (si < nso) {
    if (pipeline_block_stmt_order_kind(arena, block_ref, si) == 1 && pipeline_block_stmt_order_idx(arena, block_ref, si) == let_idx) {
      return 1;
    }
    si = si + 1;
  }
  return 0;
}

/**
 * 返回非 0 表示 name 已以 prefix 开头且应跳过再次前置 prefix。
 * 仅当前缀为 ASCII「build_」（6 字节）时启用：与 build.x 约定一致；preprocess_ 等仍须叠写以匹配链接 shim。
 */
function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  if (prefix_len != 6) {
    return 0;
  }
  if (prefix[0] != 98 || prefix[1] != 117 || prefix[2] != 105 || prefix[3] != 108 || prefix[4] != 100 || prefix[5] != 95) {
    return 0;
  }
  if (name_len < prefix_len) {
    return 0;
  }
  let i: i32 = 0;
  while (i < prefix_len) {
    if (name[i] != prefix[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

/** 代码生成输出缓冲区：data 为已写内容，len 为长度。C 侧在 pipeline 返回后将 data[0..len-1] 写入 FILE*。 */
/* 9MiB：须 ≥ code_data + ELF 元数据；与 runtime.c / ast_pool PIPELINE_CODEGEN_OUTBUF_CAP 同步。 */
struct CodegenOutBuf {
  data: u8[9437184];
  len: i32;
}

/** 向缓冲区追加一字节（b 为 i32，取低 8 位，经查找表转为 u8）。返回 0 成功，缓冲区满返回 -1。 */
function append_byte(out: *CodegenOutBuf, b: i32): i32 {
  if (out.len >= 9437184) {
    return -1;
  }
  /** 勿 `let lo = b & 255` 再写 out.data：与下一赋值同体时 parse_into_buf 多函数模块会丢 append_byte body_ref。 */
  out.data[out.len] = (b & 255) as u8;
  out.len = out.len + 1;
  return 0;
}

/** 向缓冲区追加一字节（b 为 u8）：转调 append_byte，避免 u8 直接写入 data[out.len] 在 parse_into_buf AST 上与 typeck 不兼容。 */
function append_byte_u8(out: *CodegenOutBuf, b: u8): i32 {
  return append_byte(out, b as i32);
}

/** 从 ptr[0..len-1] 逐字节追加到 out，用于库前缀等变长内容。 */
function emit_bytes_from_ptr(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, ptr[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * 将 ptr..ptr+len-1 写入 out。第二参用 *u8 而非 u8[64]：大块按值传参在自举 codegen 上会撕裂/截断，导致 C 里函数名等标识符变成一串 NUL。
 */
function emit_bytes_64(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  return emit_bytes_from_ptr(out, ptr, len);
}
function emit_bytes_32(out: *CodegenOutBuf, buf: u8[32], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_22(out: *CodegenOutBuf, buf: u8[22], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_9(out: *CodegenOutBuf, buf: u8[9], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_8(out: *CodegenOutBuf, buf: u8[8], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_7(out: *CodegenOutBuf, buf: u8[7], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_6(out: *CodegenOutBuf, buf: u8[6], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_5(out: *CodegenOutBuf, buf: u8[5], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_4(out: *CodegenOutBuf, buf: u8[4], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_3(out: *CodegenOutBuf, buf: u8[3], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
function emit_bytes_2(out: *CodegenOutBuf, buf: u8[2], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/** 将非负整数 val 的十进制表示追加到 out（先高位后当前位）。 */
function format_uint(out: *CodegenOutBuf, val: i32): i32 {
  if (val >= 10) {
    let q: i32 = val / 10;
    let r: i32 = val % 10;
    if (format_uint(out, q) != 0) {
      return -1;
    }
    if (append_byte(out, 48 + r) != 0) {
      return -1;
    }
    return 0;
  }
  if (append_byte(out, 48 + val) != 0) {
    return -1;
  }
  return 0;
}

/** 将 i32 整数的十进制表示写入 out（含负号；INT_MIN 特判）。 */
function format_int(out: *CodegenOutBuf, val: i32): i32 {
  if (val >= 0) {
    return format_uint(out, val);
  }
  let u: i32 = 0 - val;
  if (u < 0) {
    if (append_byte(out, 45) != 0) {
      return -1;
    }
    let d: u8[11] = [50, 49, 52, 55, 52, 56, 51, 54, 52, 56, 0];
    let i: i32 = 0;
    while (i < 10) {
      /** u8 元素直接 append_byte_u8，勿 let b: i32 = d[i]（while 体内 mid-let 与 u8→i32 在 typeck 不通过）。 */
      if (append_byte_u8(out, d[i]) != 0) {
        return -1;
      }
      i = i + 1;
    }
    return 0;
  }
  if (append_byte(out, 45) != 0) {
    return -1;
  }
  return format_uint(out, u);
}

/** 写 indent 个空格。 */
function emit_indent(out: *CodegenOutBuf, indent: i32): i32 {
  let i: i32 = 0;
  while (i < indent) {
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}

/** 写 break;\n（含缩进）。 */
function emit_break_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
  return emit_bytes_8(out, br, 7);
}

/** 写 continue;\n（含缩进）。 */
function emit_continue_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
  return emit_bytes_from_ptr(out, &co[0], 10);
}

/** 将 pipeline_type_kind_ord_at 序数委托 emit_type_kind（勿 ast_arena_type_get 按值 Type）。 */
function emit_type_kind_ord(out: *CodegenOutBuf, tk: i32): i32 {
  return emit_type_kind(out, tk);
}

/** 根据 TypeKind 写 C 类型名到 out（仅内建类型）；纯 .x，按数组尺寸调用对应 emit_bytes_N。 */
function emit_type_kind(out: *CodegenOutBuf, kind_ord: i32): i32 {
  if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[4] = [105, 110, 116, 0];
    return emit_bytes_4(out, s, 3);
  }
  if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    return emit_bytes_9(out, s, 7);
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_9(out, s, 8);
  }
  if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
    return emit_bytes_9(out, s, 8);
  }
  if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[6] = [102, 108, 111, 97, 116, 0];
    return emit_bytes_6(out, s, 5);
  }
  if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
    return emit_bytes_7(out, s, 6);
  }
  if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
    let s: u8[5] = [118, 111, 105, 100, 0];
    return emit_bytes_5(out, s, 4);
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
    return emit_bytes_7(out, s, 6);
  }
  if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  return -1;
}

/** 将 TypeKind 对应内建类型写入 scratch[w..)，返回下一写位置；-1 表示溢出 cap。对齐 emit_type_kind 的字符串。 */
function type_kind_append_to_scratch(scratch: *u8, cap: i32, w: i32, kind_ord: i32): i32 {
  if (kind_ord == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[8] = [105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[4] = [105, 110, 116, 0];
    let i: i32 = 0;
    while (i < 3) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 51, 50, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[9] = [117, 105, 110, 116, 54, 52, 95, 116, 0];
    let i: i32 = 0;
    while (i < 8) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[6] = [102, 108, 111, 97, 116, 0];
    let i: i32 = 0;
    while (i < 5) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[7] = [100, 111, 117, 98, 108, 101, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_VOID as i32)) {
    let s: u8[5] = [118, 111, 105, 100, 0];
    let i: i32 = 0;
    while (i < 4) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[7] = [115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 6) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  if (kind_ord == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[8] = [115, 115, 105, 122, 101, 95, 116, 0];
    let i: i32 = 0;
    while (i < 7) {
      if (w >= cap - 1) {
        return -1;
      }
      scratch[w] = s[i];
      w = w + 1;
      i = i + 1;
    }
    return w;
  }
  return -1;
}

/** 向量 C typedef 名字写入 out（与 codegen.c vector_c_type_name 一致；typedef 体由 preamble / 宿主 C 保证）。 */
function emit_vector_c_type_out(out: *CodegenOutBuf, elem_kind_ord: i32, lanes: i32): i32 {
  if (elem_kind_ord == (TypeKind.TYPE_I32 as i32)) {
    if (lanes == 4) {
      let s: u8[8] = [105, 51, 50, 120, 52, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 8) {
      let s: u8[8] = [105, 51, 50, 120, 56, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 16) {
      let sa: u8[9] = [105, 51, 50, 120, 49, 54, 95, 116, 0];
      return emit_bytes_from_ptr(out, &sa[0], 8);
    }
  }
  if (elem_kind_ord == (TypeKind.TYPE_U32 as i32)) {
    if (lanes == 4) {
      let s: u8[8] = [117, 51, 50, 120, 52, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 8) {
      let s: u8[8] = [117, 51, 50, 120, 56, 95, 116, 0];
      return emit_bytes_from_ptr(out, &s[0], 7);
    }
    if (lanes == 16) {
      let sa: u8[9] = [117, 51, 50, 120, 49, 54, 95, 116, 0];
      return emit_bytes_from_ptr(out, &sa[0], 8);
    }
  }
  let df: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
  return emit_bytes_from_ptr(out, &df[0], 7);
}

/** 将 pipeline_type_kind_ord_at 序数委托 type_kind_append_to_scratch（勿 ast_arena_type_get 按值 Type）。 */
function type_kind_append_to_scratch_ord(scratch: *u8, cap: i32, w: i32, tk: i32): i32 {
  let w2: i32 = type_kind_append_to_scratch(scratch, cap, w, tk);
  if (w2 < 0) {
    return type_kind_append_to_scratch(scratch, cap, w, TypeKind.TYPE_I32 as i32);
  }
  return w2;
}

/** 写入 C c_type_str 等价串至 scratch（无 NUL）；逻辑在 pipeline_codegen_type_to_c_repr（C glue）。 */
function type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}

/** 写类型到 out（glue 读 kind/elem/array/name，勿 ast_arena_type_get 按值 Type）。 */
function emit_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  let tk: i32 = 0;
  let elem_ref: i32 = 0;
  let arr_sz: i32 = 0;
  let elem_kind: i32 = 0;
  let name_len: i32 = 0;
  let nm: u8[64] = [];

  if (ast.ref_is_null(type_ref)) {
    let s: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_8(out, s, 7);
  }
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (tk == TypeKind.TYPE_PTR && !ast.ref_is_null(elem_ref)) {
    if (emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    return append_byte(out, 42);
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, &nm[0]);
  if (tk == TypeKind.TYPE_NAMED && name_len > 0) {
    let dep_prefix_buf: u8[128] = [];
    let dep_prefix_len: i32 = 0;
    /* 解构 import("std.io.driver") 的 Buffer：与 preamble typedef std_io_Buffer / struct std_io_driver_Buffer 一致。 */
    if (name_len == 6 && nm[0] == 66 && nm[1] == 117 && nm[2] == 102 && nm[3] == 102
        && nm[4] == 101 && nm[5] == 114) {
      let io_buf: u8[22] = [115, 116, 114, 117, 99, 116, 32, 115, 116, 100, 95, 105, 111, 95, 66, 117, 102, 102, 101, 114, 0, 0];
      return emit_bytes_from_ptr(out, &io_buf[0], 20);
    }
    /** 用户顶层 enum：C 无对应 tag 时按 int32_t 存储（与 typeck 布局一致）。 */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && codegen_type_is_module_user_enum(ctx.current_codegen_module, arena, type_ref) != 0) {
      let i32_enum: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return emit_bytes_8(out, i32_enum, 7);
    }
    let s: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
    if (emit_bytes_8(out, s, 7) != 0) {
      return -1;
    }
    dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &dep_prefix_buf[0], 128);
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
        return -1;
      }
    } else if (dep_prefix_len > 0) {
      if (emit_bytes_from_ptr(out, &dep_prefix_buf[0], dep_prefix_len) != 0) {
        return -1;
      }
    } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, type_ref) != 0) {
      if (ctx.current_codegen_dep_index >= 0) {
        let cur_pre: u8[128] = [];
        let cur_pre_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre[0], 128);
        if (cur_pre_len > 0 && emit_bytes_from_ptr(out, &cur_pre[0], cur_pre_len) != 0) {
          return -1;
        }
      }
    } else {
      /* 无前缀时默认 ast_，生成 struct ast_ASTArena / struct ast_Type 等 */
      let ast_p: u8[4] = [97, 115, 116, 95];
      if (emit_bytes_4(out, ast_p, 4) != 0) {
        return -1;
      }
    }
    /* 【Why 根源】跨模块 struct 引用：typeck 存限定名（page_mmap.PageMmapHeap），C 需裸名（PageMmapHeap）。
     * 取最后一个 '.' 之后的部分发射，与 dep struct_layout name / struct 定义一致，避免 C 非法点号。
     * 【Asm/Perf】逐字节发射避免大块按值传参撕裂（对齐 emit_bytes_from_ptr 注释）。 */
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < name_len && bi < 64) {
      if (nm[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let ci: i32 = bare_off;
    while (ci < name_len && ci < 64) {
      if (append_byte_u8(out, nm[ci]) != 0) {
        return -1;
      }
      ci = ci + 1;
    }
    return 0;
  }
  /* C 中数组形参退化为指针，输出 elem_type * 以便 extern/定义一致，避免 build 对 preprocess_x_buf 签名的补丁 */
  if (tk == TypeKind.TYPE_ARRAY && !ast.ref_is_null(elem_ref)) {
    if (emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    return append_byte(out, 42);
  }
  /* T[] → struct shux_slice_<elem>（对齐 codegen.c c_type_to_buf） */
  if (tk == TypeKind.TYPE_SLICE && !ast.ref_is_null(elem_ref)) {
    let slb: u8[256] = [];
    let nl: i32 = type_to_c_repr(arena, &slb[0], 256, type_ref, struct_prefix, struct_prefix_len);
    if (nl <= 0) {
      return -1;
    }
    let si: i32 = 0;
    while (si < nl) {
      if (append_byte_u8(out, slb[si]) != 0) {
        return -1;
      }
      si = si + 1;
    }
    return 0;
  }
  /* 向量 SIMD 别名（如 i32x4_t）；typedef 须在 preamble / 宿主 C 与 codegen.c 一致 */
  if (tk == TypeKind.TYPE_VECTOR && !ast.ref_is_null(elem_ref)) {
    elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    return emit_vector_c_type_out(out, elem_kind, arr_sz);
  }
  /** M-4：Linear(T) 与内层 T 同 C 布局，零 RT 开销（对齐 codegen.c c_type_to_buf）。 */
  if (tk == TypeKind.TYPE_LINEAR && !ast.ref_is_null(elem_ref)) {
    return emit_type(arena, out, elem_ref, struct_prefix, struct_prefix_len, ctx);
  }
  return emit_type_kind_ord(out, tk);
}

/**
 * 入口模块 codegen 时，若 TYPE_NAMED 实际来自某个 dep 模块的 struct_layouts，
 * 则返回该 dep 的 C 前缀长度并写入 dst（如 lexer_ / std_io_driver_）。
 * 这与宿主 C codegen 的 dep struct 前缀解析保持一致，避免错误回退为 ast_。
 */
function codegen_type_dep_struct_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  let name_len: i32 = 0;
  let ty_nm: u8[64] = [];
  let di: i32 = 0;
  if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || dst == 0 as *u8 || dst_cap <= 0 || ast.ref_is_null(type_ref)) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
    return 0;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
  if (name_len <= 0) {
    return 0;
  }
  /* 【Why 根源】typeck 存储限定名（如 page_mmap.PageMmapHeap），dep struct_layout name 是裸名（PageMmapHeap）。
   * 取最后一个 '.' 之后的裸名偏移，用裸名与 dep layout name 比较（对齐 asm_slot_bytes_named_in_mod 修复 commit 45f97d71）。
   * 【Invariant】bare_off 指向最后一个 '.' 之后首字节；bare_len = name_len - bare_off。 */
  let bare_off: i32 = 0;
  let bi: i32 = 0;
  while (bi < name_len && bi < 64) {
    if (ty_nm[bi] == 46) {
      bare_off = bi + 1;
    }
    bi = bi + 1;
  }
  let bare_len: i32 = name_len - bare_off;
  di = 0;
  while (di < pipeline_dep_ctx_ndep(ctx)) {
    let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
    if (dep_mod != 0 as *Module) {
      let li: i32 = 0;
      while (li < dep_mod.num_struct_layouts) {
        let dep_name_len: i32 = pipeline_module_struct_layout_name_len(dep_mod, li);
        if (dep_name_len == bare_len) {
          let dep_nm: u8[64] = [];
          let eq: bool = true;
          let j: i32 = 0;
          pipeline_module_struct_layout_name_into(dep_mod, li, &dep_nm[0]);
          while (j < bare_len && j < 64) {
            if (dep_nm[j] != ty_nm[bare_off + j]) {
              eq = false;
              break;
            }
            j = j + 1;
          }
          if (eq) {
            let dep_path: u8[64] = [];
            let plen: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
            if (plen > 0) {
              codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
              let out_len: i32 = 0;
              while (out_len < dst_cap && dst[out_len] != 0 as u8) {
                out_len = out_len + 1;
              }
              return out_len;
            }
          }
        }
        li = li + 1;
      }
    }
    di = di + 1;
  }
  return 0;
}

/**
 * 固定数组元素是否为 u8（u8[N] 走 uint8_t* 初值路径，与 hello 的 msg 缓冲一致）。
 */
function type_array_elem_is_u8(arena: *ASTArena, type_ref: i32): i32 {
  let inner: i32 = 0;
  if (ast.ref_is_null(type_ref) || type_ref <= 0 || type_ref > arena.num_types) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_ARRAY) {
    return 0;
  }
  inner = pipeline_type_elem_ref_at(arena, type_ref);
  if (ast.ref_is_null(inner) || inner <= 0 || inner > arena.num_types) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, inner) == TypeKind.TYPE_U8) {
    return 1;
  }
  return 0;
}

/**
 * 局部固定数组：仅发射元素类型（如 int32_t）；[N] 须在变量名之后由 emit_local_fixed_array_suffix 输出。
 */
function emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32 {
  let inner: i32 = pipeline_type_elem_ref_at(arena, type_ref);
  if (ast.ref_is_null(inner) || emit_type(arena, out, inner, 0 as *u8, 0, ctx) != 0) {
    let fb: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
    return emit_bytes_8(out, fb, 7);
  }
  return 0;
}

/** 局部固定数组维度后缀：[N]，写在变量名之后（int32_t a[N]）。 */
function emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32 {
  let asz: i32 = pipeline_type_array_size_at(arena, type_ref);
  if (append_byte(out, 91) != 0) {
    return -1;
  }
  if (format_int(out, asz) != 0) {
    return -1;
  }
  return append_byte(out, 93);
}

/**
 * 切片 let s: T[] = arr：生成 { .data = arr, .length = N }（对齐 codegen.c codegen_init）。
 * @return 1 已写出初值；0 不适用（走 emit_expr）；-1 失败。
 */
function try_emit_slice_init_from_array_var(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, let_idx: i32, let_type_ref: i32, linit_ref: i32): i32 {
  /** TYPE_SLICE 序数与 ast.TypeKind / pipeline_type_kind_ord_at 一致。 */
  if (ast.ref_is_null(let_type_ref) || pipeline_type_kind_ord_at(arena, let_type_ref) != 11) {
    return 0;
  }
  if (ast.ref_is_null(linit_ref) || linit_ref <= 0 || linit_ref > arena.num_exprs) {
    return 0;
  }
  let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
  if (init_e.kind != ExprKind.EXPR_VAR || init_e.var_name_len <= 0) {
    return 0;
  }
  let arr_sz: i32 = 0;
  let li: i32 = 0;
  while (li < let_idx) {
    let nlen: i32 = pipeline_block_let_name_len(arena, block_ref, li);
    if (nlen == init_e.var_name_len && nlen > 0) {
      let matched: i32 = 1;
      let nb: u8[64] = [];
      pipeline_block_let_name_copy64(arena, block_ref, li, &nb[0]);
      let ci: i32 = 0;
      while (ci < nlen) {
        if (nb[ci] != init_e.var_name[ci]) {
          matched = 0;
          ci = nlen;
        } else {
          ci = ci + 1;
        }
      }
      if (matched != 0) {
        let tr: i32 = pipeline_block_let_type_ref(arena, block_ref, li);
        if (pipeline_type_kind_ord_at(arena, tr) == 10) {
          arr_sz = pipeline_type_array_size_at(arena, tr);
          li = let_idx;
        }
      }
    }
    li = li + 1;
  }
  if (arr_sz <= 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0) {
    if (pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == 10) {
      arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
    }
  }
  if (arr_sz <= 0) {
    return 0;
  }
  if (append_byte(out, 123) != 0) {
    return -1;
  }
  let d1: u8[9] = [32, 46, 100, 97, 116, 97, 32, 61, 32];
  if (emit_bytes_from_ptr(out, &d1[0], 9) != 0) {
    return -1;
  }
  if (emit_bytes_64(out, &init_e.var_name[0], init_e.var_name_len) != 0) {
    return -1;
  }
  let d2: u8[12] = [44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32];
  if (emit_bytes_from_ptr(out, &d2[0], 12) != 0) {
    return -1;
  }
  if (format_int(out, arr_sz) != 0) {
    return -1;
  }
  let d3: u8[4] = [32, 125, 0, 0];
  return emit_bytes_4(out, d3, 2);
}

/**
 * 数组字面量初值：{ e0, e1, ... }（用于 int32_t a[N] = { ... }，避免 (T[]){ } 赋给栈数组）。
 */
function emit_braced_array_lit_init(arena: *ASTArena, out: *CodegenOutBuf, init_ref: i32, ctx: *PipelineDepCtx): i32 {
  if (ast.ref_is_null(init_ref) || init_ref <= 0 || init_ref > arena.num_exprs) {
    let z: u8[4] = [123, 32, 48, 0];
    if (emit_bytes_4(out, z, 3) != 0) {
      return -1;
    }
    return 0;
  }
  /** 勿 `let e: Expr = ast_arena_expr_get`：大 Expr 按值拷贝在自举 typeck 撕裂 kind。 */
  if (pipeline_expr_kind_ord_at(arena, init_ref) != (46 as i32)) {
    if (emit_expr(arena, out, init_ref, ctx) != 0) {
      return -1;
    }
    return 0;
  }
  if (append_byte(out, 123) != 0) {
    return -1;
  }
  let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  let ai: i32 = 0;
  while (ai < n) {
    if (ai > 0) {
      let comma: u8[3] = [44, 32, 0];
      if (emit_bytes_3(out, comma, 2) == 0) {
        ai = ai;
      } else {
        return -1;
      }
    }
    /** while 体内须 `if (f()==0) { ... } else { return -1 }`；`if (f()!=0) return -1` 在自举 typeck 会 segfault。 */
    if (emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, init_ref, ai), ctx) == 0) {
      ai = ai + 1;
    } else {
      return -1;
    }
  }
  if (append_byte(out, 125) == 0) {
    return 0;
  }
  return -1;
}

/**
 * 发射「结构体定义」用的字段类型串；逻辑在 pipeline_codegen_emit_struct_field_type（C glue）。
 */
function emit_struct_field_type_via_pipeline(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

/**
 * pipeline_module_struct_layout_name_into 给出的 struct 尾部名若与 IO 异步 ABI 固定名相同，则跳过 codegen 发射：
 * runtime.c / preamble 已定义完整的 ast_* 与 std_io_driver_* 等 tag，再输出会重复完整定义导致 C 编译失败。
 * 仅匹配裸名 Buffer、Completion、AsyncContext（与任意 struct_prefix 拼接后均由 ABI 层提供）。
 */
function codegen_should_skip_emit_struct_layout_for_abi_dup(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  let nm_buffer: u8[7] = [66, 117, 102, 102, 101, 114, 0];
  let nm_completion: u8[11] = [67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0];
  let nm_async_ctx: u8[13] = [65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0];
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_buffer[0], 6) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_completion[0], 10) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_async_ctx[0], 12) != 0) {
    return 1;
  }
  return 0;
}

/** 当前模块 struct_layouts 中是否存在与 type 同名的 NAMED 类型（入口用户 struct，非 ast_ 前缀）。 */
function codegen_type_is_module_user_struct(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  let name_len: i32 = 0;
  let ty_nm: u8[64] = [];
  if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
    return 0;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
  if (name_len <= 0) {
    return 0;
  }
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
    if (nl == name_len) {
      let lay_nm: u8[64] = [];
      pipeline_module_struct_layout_name_into(module, k, &lay_nm[0]);
      let eq: bool = true;
      let j: i32 = 0;
      while (j < nl && j < 64) {
        if (lay_nm[j] != ty_nm[j]) {
          eq = false;
          break;
        }
        j = j + 1;
      }
      if (eq) {
        return 1;
      }
    }
    k = k + 1;
  }
  return 0;
}

/** 当前模块登记的顶层 enum 名是否与 type_ref 的 TYPE_NAMED 一致（C 侧按 int32_t 表示）。 */
function codegen_type_is_module_user_enum(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  let name_len: i32 = 0;
  let ty_nm: u8[64] = [];
  if (module == 0 as *Module || arena == 0 as *ASTArena || ast.ref_is_null(type_ref)) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, type_ref) != TypeKind.TYPE_NAMED) {
    return 0;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, &ty_nm[0]);
  if (name_len <= 0) {
    return 0;
  }
  let ei: i32 = 0;
  while (ei < module.num_module_enums) {
    let enl: i32 = pipeline_module_enum_name_len(module, ei);
    if (enl == name_len) {
      let eq: bool = true;
      let j: i32 = 0;
      while (j < name_len && j < 64) {
        if (pipeline_module_enum_name_byte_at(module, ei, j) != ty_nm[j]) {
          eq = false;
          break;
        }
        j = j + 1;
      }
      if (eq) {
        return 1;
      }
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * 发射完整 struct 字段声明，支持多维数组的 `type name[N][M]` 顺序；
 * 与旧 C glue 的职责相同，但改在 X 侧走 emit_type(ctx) 以正确解析 dep struct 前缀。
 */
function codegen_emit_struct_field_decl_x(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  let base_ref: i32 = type_ref;
  if (ast.ref_is_null(type_ref) || field_name == 0 as *u8 || field_name_len <= 0) {
    return -1;
  }
  while (!ast.ref_is_null(base_ref) && pipeline_type_kind_ord_at(arena, base_ref) == TypeKind.TYPE_ARRAY) {
    let inner: i32 = pipeline_type_elem_ref_at(arena, base_ref);
    if (ast.ref_is_null(inner)) {
      break;
    }
    base_ref = inner;
  }
  if (emit_type(arena, out, base_ref, struct_prefix, struct_prefix_len, ctx) != 0) {
    return -1;
  }
  if (append_byte(out, 32) != 0) {
    return -1;
  }
  if (emit_bytes_from_ptr(out, field_name, field_name_len) != 0) {
    return -1;
  }
  let dims_ref: i32 = type_ref;
  while (!ast.ref_is_null(dims_ref) && pipeline_type_kind_ord_at(arena, dims_ref) == TypeKind.TYPE_ARRAY) {
    let lbr: u8[2] = [91, 0];
    let rbr: u8[2] = [93, 0];
    if (emit_bytes_2(out, lbr, 1) != 0) {
      return -1;
    }
    if (format_int(out, pipeline_type_array_size_at(arena, dims_ref)) != 0) {
      return -1;
    }
    if (emit_bytes_2(out, rbr, 1) != 0) {
      return -1;
    }
    dims_ref = pipeline_type_elem_ref_at(arena, dims_ref);
  }
  return 0;
}

/**
 * 遍历 module.struct_layouts，发射完整 C struct（须在首次使用类型之前）；名称与字段名由 glue 读出。
 */
function codegen_emit_module_struct_definitions(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  let k: i32 = 0;
  while (k < module.num_struct_layouts) {
    let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
    let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
    if (nf <= 0 || nl <= 0) {
      k = k + 1;
      continue;
    }
    let ty_nm: u8[64] = [];
    pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
    if (codegen_should_skip_emit_struct_layout_for_abi_dup(&ty_nm[0], nl) != 0) {
      k = k + 1;
      continue;
    }
    let hdr_top: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
    if (emit_bytes_8(out, hdr_top, 7) != 0) {
      return -1;
    }
    if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
      if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
        return -1;
      }
    } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0) {
      /* 入口用户 struct：struct Point { ... }，不加 ast_ 前缀。 */
    } else {
      let ast_top: u8[4] = [97, 115, 116, 95];
      if (emit_bytes_4(out, ast_top, 4) != 0) {
        return -1;
      }
    }
    if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
      return -1;
    }
    let br1: u8[4] = [32, 123, 10, 0];
    if (emit_bytes_4(out, br1, 3) != 0) {
      return -1;
    }
    let j: i32 = 0;
    while (j < nf) {
      let flen: i32 = pipeline_module_struct_layout_field_name_len(module, k, j);
      let ftr: i32 = pipeline_module_struct_layout_field_type_ref(module, k, j);
      if (flen <= 0) {
        j = j + 1;
        continue;
      }
      if (emit_indent(out, 2) != 0) {
        return -1;
      }
      let fnm: u8[64] = [];
      pipeline_module_struct_layout_field_name_into(module, k, j, &fnm[0]);
      if (codegen_emit_struct_field_decl_x(arena, out, ftr, &fnm[0], flen, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      let semi_nl: u8[3] = [59, 10, 0];
      if (emit_bytes_3(out, semi_nl, 2) != 0) {
        return -1;
      }
      j = j + 1;
    }
    let close_ty: u8[4] = [125, 59, 10, 10];
    if (emit_bytes_4(out, close_ty, 4) != 0) {
      return -1;
    }
    k = k + 1;
  }
  return 0;
}

/**
 * 遍历 module.enums，按 `enum prefix_Name { prefix_Name_Variant, ... };` 发射完整 C enum。
 * 供 entry 单文件模式为“被跳过或纯类型 dep”补齐类型定义，避免 dep struct 字段引用不完整 enum。
 */
function codegen_emit_module_enum_definitions(module: *Module, out: *CodegenOutBuf, enum_prefix: *u8, enum_prefix_len: i32): i32 {
  let ei: i32 = 0;
  while (ei < module.num_module_enums) {
    let enl: i32 = pipeline_module_enum_name_len(module, ei);
    if (enl <= 0) {
      ei = ei + 1;
      continue;
    }
    let enm: u8[64] = [];
    let hdr: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
    let open: u8[4] = [32, 123, 32, 0];
    let close: u8[6] = [32, 125, 59, 10, 0, 0];
    let comma: u8[3] = [44, 32, 0];
    pipeline_module_enum_name_byte_at(module, ei, 0);
    let nk: i32 = 0;
    while (nk < enl && nk < 64) {
      enm[nk] = pipeline_module_enum_name_byte_at(module, ei, nk);
      nk = nk + 1;
    }
    if (emit_bytes_from_ptr(out, &hdr[0], 5) != 0) {
      return -1;
    }
    if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
      if (emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
        return -1;
      }
    }
    if (emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
      return -1;
    }
    if (emit_bytes_4(out, open, 3) != 0) {
      return -1;
    }
    let nv: i32 = pipeline_module_enum_num_variants(module, ei);
    let vi: i32 = 0;
    while (vi < nv) {
      let vlen: i32 = pipeline_module_enum_variant_name_len(module, ei, vi);
      let vnm: u8[64] = [];
      let vk: i32 = 0;
      if (vi > 0) {
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      while (vk < vlen && vk < 64) {
        vnm[vk] = pipeline_module_enum_variant_name_byte_at(module, ei, vi, vk);
        vk = vk + 1;
      }
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, enum_prefix, enum_prefix_len) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &enm[0], enl) != 0) {
        return -1;
      }
      if (append_byte(out, 95) != 0) {
        return -1;
      }
      if (vlen > 0 && emit_bytes_from_ptr(out, &vnm[0], vlen) != 0) {
        return -1;
      }
      vi = vi + 1;
    }
    if (emit_bytes_from_ptr(out, &close[0], 4) != 0) {
      return -1;
    }
    ei = ei + 1;
  }
  return 0;
}

/**
 * entry 单文件模式下，某些 dep 会被 pipeline 层整块跳过（如 lexer/ast/parser/bootstrap partial），
 * 或者仅含类型而无函数体（如 token）。这些 dep 的 enum/struct 仍需先发射，否则 entry C 会因不完整类型失败。
 */
function codegen_emit_skipped_dep_type_definitions(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
    return 0;
  }
  let saved_module: *Module = ctx.current_codegen_module;
  let saved_arena: *ASTArena = ctx.current_codegen_arena;
  let saved_dep_index: i32 = ctx.current_codegen_dep_index;
  let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
  let saved_prefix: u8[64] = [];
  let sp: i32 = 0;
  while (sp < 64) {
    saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
    sp = sp + 1;
  }
  let nd: i32 = pipeline_dep_ctx_ndep(ctx);
  let phase: i32 = 0;
  while (phase < 2) {
    let di: i32 = 0;
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
      let dep_path: u8[64] = [];
      let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
      if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_path_len > 0) {
        let should_emit_types: i32 = 0;
        if (phase == 0 && dep_mod.num_funcs <= 0) {
          should_emit_types = 1;
        } else if (phase == 1 && dep_mod.num_funcs > 0 && pipeline_codegen_dep_skip_x_bootstrap_partial(&dep_path[0]) != 0) {
          should_emit_types = 1;
        }
        if (should_emit_types != 0) {
          let seen_before: i32 = 0;
          let pj: i32 = 0;
          while (pj < di) {
            let prev_path: u8[64] = [];
            let prev_len: i32 = codegen_dep_import_path_len_at(ctx, pj, &prev_path[0]);
            if (prev_len == dep_path_len) {
              let eq_prev: bool = true;
              let pk: i32 = 0;
              while (pk < dep_path_len && pk < 64) {
                if (prev_path[pk] != dep_path[pk]) {
                  eq_prev = false;
                  break;
                }
                pk = pk + 1;
              }
              if (eq_prev) {
                seen_before = 1;
                break;
              }
            }
            pj = pj + 1;
          }
          if (seen_before == 0) {
            let prefix_buf: u8[128] = [];
            let prefix_len: i32 = 0;
            if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
              codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
              while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
                prefix_len = prefix_len + 1;
              }
            }
            ctx.current_codegen_module = dep_mod;
            ctx.current_codegen_arena = dep_arena;
            ctx.current_codegen_dep_index = di;
            ctx.current_codegen_prefix_len = 0;
            let px: i32 = 0;
            while (px < prefix_len && px < 63) {
              ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
              px = px + 1;
            }
            ctx.current_codegen_prefix_mirror[px] = 0 as u8;
            ctx.current_codegen_prefix_len = px;
            if (codegen_emit_module_enum_definitions(dep_mod, out, &prefix_buf[0], prefix_len) != 0) {
              return -1;
            }
            if (codegen_emit_module_struct_definitions(dep_mod, dep_arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
              return -1;
            }
          }
        }
      }
      di = di + 1;
    }
    phase = phase + 1;
  }
  ctx.current_codegen_module = saved_module;
  ctx.current_codegen_arena = saved_arena;
  ctx.current_codegen_dep_index = saved_dep_index;
  ctx.current_codegen_prefix_len = saved_prefix_len;
  sp = 0;
  while (sp < 64) {
    ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
    sp = sp + 1;
  }
  return 0;
}

/**
 * 若字段访问形如 binding.field，且 binding 为当前模块 import 绑定名，则把该 import 的路径写入 dst 并返回长度。
 * 仅做 binding->path 解析，不校验 field 是否真为 const / function。
 */
function codegen_resolve_binding_import_path_for_field_access(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
    return 0;
  }
  if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  if (e.kind != ExprKind.EXPR_FIELD_ACCESS) {
    return 0;
  }
  if (e.field_access_base_ref <= 0 || e.field_access_base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, e.field_access_base_ref);
  if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
    return 0;
  }
  let cur_mod: *Module = ctx.current_codegen_module;
  let j: i32 = 0;
  let n_imp: i32 = codegen_module_num_imports(cur_mod);
  while (j < n_imp) {
    if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
      j = j + 1;
      continue;
    }
    let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
    if (bind_len != base.var_name_len) {
      j = j + 1;
      continue;
    }
    let eq: bool = true;
    let kk: i32 = 0;
    while (kk < base.var_name_len) {
      if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
        eq = false;
        break;
      }
      kk = kk + 1;
    }
    if (!eq) {
      j = j + 1;
      continue;
    }
    return codegen_module_import_path_len_at(cur_mod, j, dst);
  }
  return 0;
}

/**
 * 若方法调用形如 binding.method(...)，且 binding 为当前模块 import 绑定名，则把该 import 的路径写入 dst 并返回长度。
 * 仅做 binding->path 解析，不依赖 typeck 已写入 resolved dep。
 */
function codegen_resolve_binding_import_path_for_method_call(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
    return 0;
  }
  if (arena == 0 as *ASTArena || dst == 0 as *u8 || expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  if (e.kind != ExprKind.EXPR_METHOD_CALL) {
    return 0;
  }
  if (e.method_call_base_ref <= 0 || e.method_call_base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, e.method_call_base_ref);
  if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
    return 0;
  }
  let cur_mod: *Module = ctx.current_codegen_module;
  let j: i32 = 0;
  let n_imp: i32 = codegen_module_num_imports(cur_mod);
  while (j < n_imp) {
    if (pipeline_module_import_kind_at(cur_mod, j) != 1) {
      j = j + 1;
      continue;
    }
    let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
    if (bind_len != base.var_name_len) {
      j = j + 1;
      continue;
    }
    let eq: bool = true;
    let kk: i32 = 0;
    while (kk < base.var_name_len) {
      if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
        eq = false;
        break;
      }
      kk = kk + 1;
    }
    if (!eq) {
      j = j + 1;
      continue;
    }
    return codegen_module_import_path_len_at(cur_mod, j, dst);
  }
  return 0;
}

/**
 * binding.field：将 import binding 上的字段访问扁平化为 prefix+field（如 heap_libc.heap_alloc_c -> std_heap_libc_heap_alloc_c）。
 * 仅在字段访问确实落到 import binding 时成功；否则返回 -1。
 */
function emit_import_module_field_symbol(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  if (ctx == 0 as *PipelineDepCtx || arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf) {
    return -1;
  }
  if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return -1;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  let dep_path: u8[64] = [];
  let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
  if (e.kind != ExprKind.EXPR_FIELD_ACCESS || dep_path_len <= 0) {
    return -1;
  }
  let pre: u8[128] = [];
  codegen_import_path_to_c_prefix_into(&dep_path[0], &pre[0], 128);
  let plen: i32 = 0;
  while (plen < 128 && pre[plen] != 0) {
    plen = plen + 1;
  }
  if (plen > 0 && codegen_c_prefix_redundant_with_name(&pre[0], plen, &e.field_access_field_name[0], e.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre[0], plen) != 0) {
    return -1;
  }
  if (e.field_access_field_len > 0 && emit_bytes_from_ptr(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
    return -1;
  }
  return 0;
}

/**
 * binding.CONST：将 dep 模块顶层 const 生成为 prefix+const_name（如 async_mod.POLL_PENDING）。
 * 非 import binding 常量访问时返回 -1。
 */
function emit_import_module_const_field(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
    return -1;
  }
  if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return -1;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  let dep_path: u8[64] = [];
  let dep_path_len: i32 = codegen_resolve_binding_import_path_for_field_access(ctx, arena, expr_ref, &dep_path[0]);
  if (e.kind != ExprKind.EXPR_FIELD_ACCESS || dep_path_len <= 0) {
    return -1;
  }
  let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
  if (dep_ix < 0 || dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
    return -1;
  }
  let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
  if (dep_mod == 0 as *Module) {
    return -1;
  }
  let ti: i32 = 0;
  while (ti < dep_mod.num_top_level_lets) {
    if (pipeline_module_top_level_let_is_const(dep_mod, ti) == 0) {
      ti = ti + 1;
      continue;
    }
    let nlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, ti);
    if (nlen != e.field_access_field_len) {
      ti = ti + 1;
      continue;
    }
    let nm_eq: bool = true;
    let ni: i32 = 0;
    while (ni < nlen) {
      if (pipeline_module_top_level_let_name_byte_at(dep_mod, ti, ni) != e.field_access_field_name[ni]) {
        nm_eq = false;
        break;
      }
      ni = ni + 1;
    }
    if (!nm_eq) {
      ti = ti + 1;
      continue;
    }
    return emit_import_module_field_symbol(arena, out, expr_ref, ctx);
  }
  return -1;
}

/**
 * 写表达式到 out；仅支持当前 .x AST 中已用到的节点（LIT、VAR、二元、一元、BLOCK、RETURN 等）。
 * ctx 非空且 ndep>0 时，EXPR_CALL 会解析跨 dep 调用并输出 dep 的 C 前缀。
 */
function emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  if (ast.ref_is_null(expr_ref)) {
    return 0;
  }
  if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
    return 0;
  }
  let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
  if (pipeline_expr_kind_ord_at(arena, expr_ref) == 59) {
    let slen: i32 = e.var_name_len;
    let emit_slice: bool = false;
    if (slen < 0) {
      slen = 0;
    }
    if (slen > 63) {
      slen = 63;
    }
    if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
      let sty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
      if (sty.kind == TypeKind.TYPE_SLICE) {
        emit_slice = true;
      }
    }
    if (emit_slice) {
      let slice_mid: u8[13] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0];
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &slice_mid[0], 12) != 0) {
        return -1;
      }
    } else {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
    }
    let u8ty: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
    if (emit_bytes_9(out, u8ty, 7) != 0) {
      return -1;
    }
    let arr_head: u8[5] = [91, 93, 41, 123, 0];
    if (emit_bytes_5(out, arr_head, 4) != 0) {
      return -1;
    }
    if (slen == 0) {
      if (append_byte(out, 48) != 0) {
        return -1;
      }
    } else {
      let si: i32 = 0;
      while (si < slen) {
        if (si > 0) {
          let comma: u8[3] = [44, 32, 0];
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
        }
        if (format_int(out, e.var_name[si] as i32) != 0) {
          return -1;
        }
        si = si + 1;
      }
    }
    if (emit_slice) {
      let slice_tail: u8[18] = [32, 125, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0];
      if (emit_bytes_from_ptr(out, &slice_tail[0], 14) != 0) {
        return -1;
      }
      if (format_int(out, slen) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      if (append_byte(out, 125) != 0) {
        return -1;
      }
      return 0;
    }
    let close: u8[4] = [32, 125, 0, 0];
    return emit_bytes_4(out, close, 2);
  }
  if (e.kind == ExprKind.EXPR_LIT) {
    return format_int(out, e.int_val);
  }
  if (e.kind == ExprKind.EXPR_BOOL_LIT) {
    if (e.int_val != 0) {
      return append_byte(out, 49);
    }
    return append_byte(out, 48);
  }
  if (e.kind == ExprKind.EXPR_VAR) {
    /* 无名或首字符为空格时：若当前在发射 call 的 callee（emit_expr_as_callee），只输出 _0 不占 _pN；否则恰一个无名形参用 _pN，多个按顺序 _p0,_p1,...。 */
    if (e.var_name_len > 0 && (e.var_name[0] > 32)) {
      /* 首个 let 无名时占位名为 _l0；仅在此情况下把源码里的 "msg" 引用映射到 _l0，与 emit_block 声明一致（有 import 不改名）。 */
      if (e.var_name_len == 3 && e.var_name[0] == 109 && e.var_name[1] == 115 && e.var_name[2] == 103 && ctx != 0 as *PipelineDepCtx) {
        let use_l0: bool = false;
        if (ctx.current_block_ref != 0 && ctx.current_block_ref <= arena.num_blocks) {
          if (ast.ast_block_num_lets(arena, ctx.current_block_ref) >= 1 && pipeline_block_let_name_len(arena, ctx.current_block_ref, 0) == 0) {
            use_l0 = true;
          }
        }
        if (use_l0) {
          let l0: u8[4] = [95, 108, 48, 0];
          return emit_bytes_4(out, l0, 3);
        }
      }
      return emit_bytes_64(out, &e.var_name[0], e.var_name_len);
    }
    if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0) {
      let fallback: u8[3] = [95, 48, 0];
      return emit_bytes_3(out, fallback, 2);
    }
    if (ctx != 0 as *PipelineDepCtx) {
      if (ctx.current_func_single_empty_param_index >= 0) {
        let place: u8[4] = [95, 112, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        return format_int(out, ctx.current_func_single_empty_param_index);
      }
      if (ctx.current_func_empty_param_count >= 2 && ctx.current_emit_empty_var_next_index < ctx.current_func_empty_param_count) {
        let param_idx: i32 = pipeline_dep_ctx_empty_param_at(ctx, ctx.current_emit_empty_var_next_index);
        let place: u8[4] = [95, 112, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        if (format_int(out, param_idx) != 0) {
          return -1;
        }
        ctx.current_emit_empty_var_next_index = ctx.current_emit_empty_var_next_index + 1;
        return 0;
      }
    }
    let fallback: u8[3] = [95, 48, 0];
    return emit_bytes_3(out, fallback, 2);
  }
  /* expr as type：C 侧 ((target_t)(operand)) */
  if (e.kind == ExprKind.EXPR_AS) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_type(arena, out, e.as_target_type_ref, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.as_operand_ref) && emit_expr(arena, out, e.as_operand_ref, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
  if (e.kind == ExprKind.EXPR_RETURN) {
    let op: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
    if (emit_bytes_9(out, op, 7) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.unary_operand_ref) && emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return 0;
  }
  if (e.kind == ExprKind.EXPR_BLOCK) {
    let open: u8[4] = [40, 123, 32, 0];
    if (emit_bytes_4(out, open, 3) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.block_ref) && emit_block(arena, out, e.block_ref, 2, ctx) != 0) {
      return -1;
    }
    let tail: u8[8] = [32, 125, 41, 0, 0, 0, 0, 0];
    return emit_bytes_8(out, tail, 3);
  }
  if (e.kind == ExprKind.EXPR_ADD) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 43, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_SUB) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 45, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_ASSIGN) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 61, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 复合赋值 +=, -=, *=, /=, %=, &=, |=, ^=, <<=, >>=：生成 ( left op right ) */
  if (e.kind == ExprKind.EXPR_ADD_ASSIGN || e.kind == ExprKind.EXPR_SUB_ASSIGN || e.kind == ExprKind.EXPR_MUL_ASSIGN || e.kind == ExprKind.EXPR_DIV_ASSIGN || e.kind == ExprKind.EXPR_MOD_ASSIGN
      || e.kind == ExprKind.EXPR_BITAND_ASSIGN || e.kind == ExprKind.EXPR_BITOR_ASSIGN || e.kind == ExprKind.EXPR_BITXOR_ASSIGN || e.kind == ExprKind.EXPR_SHL_ASSIGN || e.kind == ExprKind.EXPR_SHR_ASSIGN) {
    let op_buf: u8[8] = [32, 43, 61, 32, 0, 0, 0, 0];
    let op_len: i32 = 4;
    if (e.kind == ExprKind.EXPR_ADD_ASSIGN) {
      op_buf[1] = 43;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_SUB_ASSIGN) {
      op_buf[1] = 45;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_MUL_ASSIGN) {
      op_buf[1] = 42;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_DIV_ASSIGN) {
      op_buf[1] = 47;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_MOD_ASSIGN) {
      op_buf[1] = 37;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_BITAND_ASSIGN) {
      op_buf[1] = 38;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_BITOR_ASSIGN) {
      op_buf[1] = 124;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_BITXOR_ASSIGN) {
      op_buf[1] = 94;
      op_buf[2] = 61;
      op_len = 4;
    }
    if (e.kind == ExprKind.EXPR_SHL_ASSIGN) {
      op_buf[1] = 60;
      op_buf[2] = 60;
      op_buf[3] = 61;
      op_buf[4] = 32;
      op_len = 5;
    }
    if (e.kind == ExprKind.EXPR_SHR_ASSIGN) {
      op_buf[1] = 62;
      op_buf[2] = 62;
      op_buf[3] = 61;
      op_buf[4] = 32;
      op_len = 5;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    /* op_buf 为 u8[8]，统一用 emit_bytes_8 按 op_len 写出（3 或 5 字节），避免 u8[4] 与 u8[8] 类型不匹配 */
    if (emit_bytes_8(out, op_buf, op_len) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_NEG) {
    let pre: u8[3] = [45, 40, 0];
    if (emit_bytes_3(out, pre, 2) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* C 后端：&(expr)，左值括号由 codegen 外层保证可读性（与 negate 对齐）。 */
  if (e.kind == ExprKind.EXPR_ADDR_OF) {
    let pre_a: u8[3] = [38, 40, 0];
    if (emit_bytes_3(out, pre_a, 2) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* C 后端：*(expr)；操作数常为指针括号表达式。 */
  if (e.kind == ExprKind.EXPR_DEREF) {
    let pre_d: u8[3] = [42, 40, 0];
    if (emit_bytes_3(out, pre_d, 2) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* Result `?`：降成 GNU statement-expression。
   * ({ Result_T tmp = op; if (tmp.err != 0) { return tmp; } tmp.value; })
   */
  if (e.kind == ExprKind.EXPR_TRY_PROPAGATE) {
    let op_ref: i32 = e.unary_operand_ref;
    let op_ty_ref: i32 = 0;
    let open: u8[4] = [40, 123, 32, 0];
    let tmp_name: u8[15] = [95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 0];
    let assign_mid: u8[5] = [32, 61, 32, 0, 0];
    let if_open: u8[37] = [59, 32, 105, 102, 32, 40, 40, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 41, 46, 101, 114, 114, 32, 33, 61, 32, 48, 41, 32, 123, 32, 114, 101];
    let turn_mid: u8[39] = [116, 117, 114, 110, 32, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 59, 32, 125, 32, 40, 95, 95, 115, 104, 117, 120, 95, 116, 114, 121, 95, 116, 109, 112, 0];
    let value_tail: u8[7] = [41, 46, 118, 97, 108, 117, 101];
    let close_tail: u8[4] = [59, 32, 125, 41];
    if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
      return -1;
    }
    op_ty_ref = pipeline_expr_resolved_type_ref(arena, op_ref);
    if (ast.ref_is_null(op_ty_ref)) {
      return -1;
    }
    if (emit_bytes_4(out, open, 3) != 0) {
      return -1;
    }
    if (emit_type(arena, out, op_ty_ref, 0 as *u8, 0, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &tmp_name[0], 14) != 0) {
      return -1;
    }
    if (emit_bytes_5(out, assign_mid, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, op_ref, ctx) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &if_open[0], 37) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &turn_mid[0], 38) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &value_tail[0], 7) != 0) {
      return -1;
    }
    if (emit_bytes_4(out, close_tail, 4) != 0) {
      return -1;
    }
    return 0;
  }
  if (e.kind == ExprKind.EXPR_AWAIT) {
    if (!ast.ref_is_null(e.unary_operand_ref) && emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return 0;
  }
  if (e.kind == ExprKind.EXPR_RUN || e.kind == ExprKind.EXPR_SPAWN) {
    let op_ref: i32 = e.unary_operand_ref;
    let dep_ix: i32 = -1;
    let func_ix: i32 = -1;
    let target_mod: *Module = 0 as *Module;
    let n_args: i32 = 0;
    let num_params: i32 = 0;
    let ai: i32 = 0;
    let op_is_call: i32 = 0;
    let reset_name: u8[25] = [115, 104, 117, 120, 95, 97, 115, 121, 110, 99, 95, 114, 117, 110, 95, 115, 101, 101, 100, 95, 114, 101, 115, 101, 116];
    let comma: u8[3] = [44, 32, 0];
    if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
      return -1;
    }
    if (ast.ref_is_null(op_ref) || op_ref <= 0 || op_ref > arena.num_exprs) {
      return -1;
    }
    let op: Expr = ast.ast_arena_expr_get(arena, op_ref);
    if (op.kind == ExprKind.EXPR_CALL) {
      op_is_call = 1;
    } else if (op.kind != ExprKind.EXPR_METHOD_CALL) {
      return -1;
    }
    if (e.kind == ExprKind.EXPR_RUN && op.kind == ExprKind.EXPR_METHOD_CALL && codegen_emit_async_method_call_run(arena, out, op_ref, ctx) == 0) {
      return 0;
    }
    if (op_is_call != 0 && op.call_callee_ref > 0 && op.call_callee_ref <= arena.num_exprs) {
      let fast_callee: Expr = ast.ast_arena_expr_get(arena, op.call_callee_ref);
      if (fast_callee.kind == ExprKind.EXPR_FIELD_ACCESS && codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if (e.kind == ExprKind.EXPR_SPAWN) { 1 } else { 0 }) == 0) {
        return 0;
      }
    }
    dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, op_ref);
    if (dep_ix < 0 && op_is_call != 0) {
      dep_ix = codegen_resolve_binding_import_dep_index(ctx, arena, op.call_callee_ref);
    }
    if (dep_ix >= 0) {
      if (dep_ix >= pipeline_dep_ctx_ndep(ctx)) {
        return -1;
      }
      target_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    } else {
      target_mod = ctx.current_codegen_module;
    }
    if (target_mod != 0 as *Module) {
      func_ix = codegen_resolve_call_target_func_index(arena, target_mod, op_ref);
    }
    if (dep_ix >= 0 && (target_mod == 0 as *Module || func_ix < 0 || func_ix >= target_mod.num_funcs)) {
      return codegen_emit_async_binding_import_call(arena, out, op_ref, ctx, if (e.kind == ExprKind.EXPR_SPAWN) { 1 } else { 0 });
    }
    if (target_mod == 0 as *Module) {
      return -1;
    }
    if (func_ix < 0 || func_ix >= target_mod.num_funcs) {
      return -1;
    }
    if (op_is_call != 0) {
      n_args = op.call_num_args;
    } else {
      n_args = op.method_call_num_args;
    }
    if (n_args < 0) {
      return -1;
    }
    num_params = pipeline_module_func_num_params_at(target_mod, func_ix);
    if (e.kind == ExprKind.EXPR_RUN) {
      if (n_args > 0) {
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_bytes_from_ptr(out, &reset_name[0], 25) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = 0;
        while (ai < n_args) {
          let arg_ref: i32 = 0;
          let param_type_ref: i32 = 0;
          if (emit_bytes_3(out, comma, 2) != 0) {
            return -1;
          }
          if (op_is_call != 0) {
            arg_ref = pipeline_expr_call_arg_ref(arena, op_ref, ai);
          } else {
            arg_ref = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
          }
          if (ai < num_params) {
            param_type_ref = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
          }
          if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(arg_ref) && emit_expr(arena, out, arg_ref, ctx) != 0) {
            return -1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (codegen_emit_async_sched_call(out, target_mod, func_ix) != 0) {
          return -1;
        }
        return append_byte(out, 41);
      }
      return codegen_emit_async_sched_call(out, target_mod, func_ix);
    }
    if (n_args > 0) {
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      ai = 0;
      while (ai < n_args) {
        let arg_ref2: i32 = 0;
        let param_type_ref2: i32 = 0;
        if (ai > 0 && emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
        if (op_is_call != 0) {
          arg_ref2 = pipeline_expr_call_arg_ref(arena, op_ref, ai);
        } else {
          arg_ref2 = pipeline_expr_method_call_arg_ref(arena, op_ref, ai);
        }
        if (ai < num_params) {
          param_type_ref2 = pipeline_module_func_param_type_ref_at(target_mod, func_ix, ai);
        }
        if (codegen_emit_async_run_seed_push_name(out, arena, param_type_ref2) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (!ast.ref_is_null(arg_ref2) && emit_expr(arena, out, arg_ref2, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        ai = ai + 1;
      }
      if (emit_bytes_3(out, comma, 2) != 0) {
        return -1;
      }
      if (codegen_emit_async_task_submit_call(out, target_mod, func_ix) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return codegen_emit_async_task_submit_call(out, target_mod, func_ix);
  }
  if (e.kind == ExprKind.EXPR_IF) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_cond_ref) && emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
      return -1;
    }
    let q: u8[4] = [32, 63, 32, 0];
    if (emit_bytes_4(out, q, 3) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_then_ref) && emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
      return -1;
    }
    let colon: u8[4] = [32, 58, 32, 0];
    if (emit_bytes_4(out, colon, 3) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_else_ref) && emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 阶段 5：函数调用 callee(arg0, arg1, ...)；跨 dep 时加 dep 的 C 前缀（如 std_io_driver_）。
   * 绑定 import（const process = import("std.process")）：callee 为 EXPR_FIELD_ACCESS(base=VAR "process", field）时按 import_binding_name 找 dep，生成 dep_prefix + field_name( args )。 */
  if (e.kind == ExprKind.EXPR_CALL) {
    let callee_ref: i32 = e.call_callee_ref;
    /* `import a.b` + `a.b.method(args)`：优先解析为单一 C ABI 符号（asm backend enc 分派等）。 */
    if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
      let sym_buf: u8[128] = [];
      let imp_j: i32 = -1;
      let sym_len: i32 = pipeline_asm_resolve_whole_import_qualified_symbol_c(arena, ctx.current_codegen_module, callee_ref, &sym_buf[0], &imp_j);
      if (sym_len > 0 && sym_len < 128) {
        if (emit_bytes_from_ptr(out, &sym_buf[0], sym_len) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        let n_q: i32 = e.call_num_args;
        let ai_q: i32 = 0;
        while (ai_q < n_q) {
          if (ai_q > 0) {
            let comma_q: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma_q, 2) != 0) {
              return -1;
            }
          }
          if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_q))) {
            if (append_byte(out, 48) != 0) {
              return -1;
            }
          } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) != 0) {
            return -1;
          }
          ai_q = ai_q + 1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        return 0;
      }
    }
    /* 优先吃 typeck 已解析好的 dep 槽位，避免在 dep 模块内再次按 import 表重猜而漏掉 binding 调用。 */
    if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0) {
      let dep_ix_fast: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      let callee_fast: Expr = ast.ast_arena_expr_get(arena, callee_ref);
      if (dep_ix_fast >= 0 && dep_ix_fast < pipeline_dep_ctx_ndep(ctx) && callee_fast.kind == ExprKind.EXPR_FIELD_ACCESS && callee_fast.field_access_field_len > 0) {
        let dep_path_fast: u8[64] = [];
        pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &dep_path_fast[0]);
        let pre_fast: u8[128] = [];
        codegen_import_path_to_c_prefix_into(&dep_path_fast[0], &pre_fast[0], 128);
        let pre_fast_len: i32 = 0;
        while (pre_fast_len < 128 && pre_fast[pre_fast_len] != 0) {
          pre_fast_len = pre_fast_len + 1;
        }
        if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fast[0], pre_fast_len, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_fast[0], pre_fast_len) != 0) {
          return -1;
        }
        if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        let ai_fast: i32 = 0;
        while (ai_fast < e.call_num_args) {
          if (ai_fast > 0) {
            let comma_fast: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma_fast, 2) != 0) {
              return -1;
            }
          }
          if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
            if (append_byte(out, 48) != 0) {
              return -1;
            }
          } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) != 0) {
            return -1;
          }
          ai_fast = ai_fast + 1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        return 0;
      }
    }
    if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0 && ctx.current_codegen_module != 0 as *Module) {
      let callee: Expr = ast.ast_arena_expr_get(arena, callee_ref);
      let cur_mod: *Module = ctx.current_codegen_module;
      /* 绑定形式 process.getenv(...)：callee 为 FIELD_ACCESS，base 为 VAR "process" */
      if (callee.kind == ExprKind.EXPR_FIELD_ACCESS && callee.field_access_base_ref > 0 && callee.field_access_base_ref <= arena.num_exprs) {
        let base: Expr = ast.ast_arena_expr_get(arena, callee.field_access_base_ref);
        if (base.kind == ExprKind.EXPR_VAR && base.var_name_len > 0 && base.var_name_len <= 63) {
          let j: i32 = 0;
          let nd_bind: i32 = pipeline_dep_ctx_ndep(ctx);
          let n_imp: i32 = codegen_module_num_imports(cur_mod);
          while (j < n_imp && j < nd_bind) {
            if (pipeline_module_import_kind_at(cur_mod, j) == 1) {
              let bind_len: i32 = pipeline_module_import_binding_name_len(cur_mod, j);
              if (bind_len != base.var_name_len) {
                j = j + 1;
                continue;
              }
              let eq: bool = true;
              let kk: i32 = 0;
              while (kk < base.var_name_len && kk < 64) {
                if (base.var_name[kk] != pipeline_module_import_binding_name_byte_at(cur_mod, j, kk)) {
                  eq = false;
                  break;
                }
                kk = kk + 1;
              }
              if (eq) {
                let dep_path_bind: u8[64] = [];
                let dep_path_bind_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_bind[0]);
                if (dep_path_bind_len <= 0) {
                  j = j + 1;
                  continue;
                }
                let pre_buf: u8[128] = [];
                codegen_import_path_to_c_prefix_into(&dep_path_bind[0], &pre_buf[0], 128);
                let pre_len: i32 = 0;
                while (pre_len < 128 && pre_buf[pre_len] != 0) {
                  pre_len = pre_len + 1;
                }
                if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, &callee.field_access_field_name[0], callee.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                  return -1;
                }
                if (callee.field_access_field_len > 0 && codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.field_access_field_name[0], callee.field_access_field_len) != 0) {
                  return -1;
                }
                if (append_byte(out, 40) != 0) {
                  return -1;
                }
                let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                let ai: i32 = 0;
                while (ai < n_dep) {
                  if (ai > 0) {
                    let comma: u8[3] = [44, 32, 0];
                    if (emit_bytes_3(out, comma, 2) != 0) {
                      return -1;
                    }
                  }
                  if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                    if (append_byte(out, 48) != 0) {
                      return -1;
                    }
                  } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                    return -1;
                  }
                  ai = ai + 1;
                }
                if (append_byte(out, 41) != 0) {
                  return -1;
                }
                return 0;
              }
            }
            j = j + 1;
          }
        }
      }
      if (callee.kind == ExprKind.EXPR_VAR && callee.var_name_len > 0) {
        /* 解构形式 const { getenv } = import("std.process")；裸名 getenv 在 dep j 的 import_select_names 中 */
        let j: i32 = 0;
        let nd_sel: i32 = pipeline_dep_ctx_ndep(ctx);
        let n_imp: i32 = codegen_module_num_imports(cur_mod);
        while (j < n_imp && j < nd_sel) {
          if (pipeline_module_import_kind_at(cur_mod, j) == 2) {
            let k: i32 = 0;
            let sel_cnt: i32 = pipeline_module_import_select_count_at(cur_mod, j);
            while (k < sel_cnt) {
              let sel_len: i32 = pipeline_module_import_select_name_len(cur_mod, j, k);
              if (sel_len == callee.var_name_len) {
                let eq: bool = true;
                let kk: i32 = 0;
                while (kk < callee.var_name_len && kk < 64) {
                  if (callee.var_name[kk] != pipeline_module_import_select_name_byte_at(cur_mod, j, k, kk)) {
                    eq = false;
                    break;
                  }
                  kk = kk + 1;
                }
                if (eq) {
                  let dep_path_sel: u8[64] = [];
                  let dep_path_sel_len: i32 = codegen_module_import_path_len_at(cur_mod, j, &dep_path_sel[0]);
                  if (dep_path_sel_len <= 0) {
                    k = k + 1;
                    continue;
                  }
                  let pre_buf: u8[128] = [];
                  codegen_import_path_to_c_prefix_into(&dep_path_sel[0], &pre_buf[0], 128);
                  let pre_len: i32 = 0;
                  while (pre_len < 128 && pre_buf[pre_len] != 0) {
                    pre_len = pre_len + 1;
                  }
                  if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                    return -1;
                  }
                  if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                    return -1;
                  }
                  if (append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                  let ai: i32 = 0;
                  while (ai < n_dep) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (emit_bytes_3(out, comma, 2) != 0) {
                        return -1;
                      }
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if (append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
                      return -1;
                    }
                    ai = ai + 1;
                  }
                  if (append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
              k = k + 1;
            }
          }
          j = j + 1;
        }
        j = 0;
        let nd_call: i32 = pipeline_dep_ctx_ndep(ctx);
        while (j < nd_call) {
          let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, j);
          let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, j);
          if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
            let fi: i32 = 0;
            while (fi < dep_mod.num_funcs) {
              let func_ref: i32 = pipeline_module_func_ref_at(dep_mod, fi);
              if (ast.ref_is_null(func_ref) || func_ref <= 0 || func_ref > dep_arena.num_funcs) {
                fi = fi + 1;
                continue;
              }
              let df: Func = ast.ast_arena_func_get(dep_arena, func_ref);
              if (df.name_len == callee.var_name_len) {
                let eq: bool = true;
                let k: i32 = 0;
                while (k < callee.var_name_len && k < 64) {
                  if (callee.var_name[k] != df.name[k]) {
                    eq = false;
                    break;
                  }
                  k = k + 1;
                }
                if (eq && pipeline_dep_ctx_import_path_len(ctx, j) > 0) {
                  /* 【Why extern 裸名】dep 池匹配到 extern function 时，调用站点须用裸名，
     与 emit_func_extern_declaration 声明符号一致，否则链接器找不到符号。 */
                  let callee_is_extern: i32 = pipeline_module_func_is_extern_at(dep_mod, fi);
                  let dep_path_call: u8[64] = [];
                  pipeline_dep_ctx_import_path_copy64(ctx, j, &dep_path_call[0]);
                  let pre_buf: u8[128] = [];
                  codegen_import_path_to_c_prefix_into(&dep_path_call[0], &pre_buf[0], 128);
                  let pre_len: i32 = 0;
                  while (pre_len < 128 && pre_buf[pre_len] != 0) {
                    pre_len = pre_len + 1;
                  }
                  if (callee_is_extern != 0) {
                    pre_len = 0;
                  }
                  let drv_buf_call: i32 = 0;
                  if (codegen_path_is_std_io_driver_bytes(&dep_path_call[0]) != 0) {
                    drv_buf_call = codegen_emit_io_driver_buf_call_name(out, &callee.var_name[0], callee.var_name_len, e.call_num_args);
                    if (drv_buf_call < 0) {
                      return -1;
                    }
                  }
                  if (drv_buf_call == 0) {
                    if (pre_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
                      return -1;
                    }
                    if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee.var_name[0], callee.var_name_len) != 0) {
                      return -1;
                    }
                    if (codegen_path_is_std_io_core_bytes(&dep_path_call[0]) != 0 && codegen_use_buf_wrapper(&callee.var_name[0], callee.var_name_len, e.call_num_args) != 0) {
                      let suf_buf: u8[8] = [95, 98, 117, 102, 0, 0, 0, 0];
                      if (emit_bytes_from_ptr(out, &suf_buf[0], 4) != 0) {
                        return -1;
                      }
                    }
                  }
                  if (append_byte(out, 40) != 0) {
                    return -1;
                  }
                  let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, callee.var_name, callee.var_name_len, e.call_num_args);
                  let fmt_i32_second_dep: i32 = 0;
                  if (e.call_num_args == 2 && n_dep == 1 && callee.var_name_len == 7 && callee.var_name[0] == 102 && callee.var_name[1] == 109 && callee.var_name[2] == 116 && callee.var_name[3] == 95 && callee.var_name[4] == 105 && callee.var_name[5] == 51 && callee.var_name[6] == 50) {
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                      fmt_i32_second_dep = 1;
                    }
                  }
                  let cast_buf0: i32 = drv_buf_call;
                  let ai: i32 = 0;
                  while (ai < n_dep) {
                    if (ai > 0) {
                      let comma: u8[3] = [44, 32, 0];
                      if (emit_bytes_3(out, comma, 2) != 0) {
                        return -1;
                      }
                    }
                    let arg_idx_dep: i32 = ai;
                    if (fmt_i32_second_dep != 0 && ai == 0) {
                      arg_idx_dep = 1;
                    }
                    if (cast_buf0 != 0 && ai == 0) {
                      let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                      if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                        return -1;
                      }
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep))) {
                      if (append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) != 0) {
                      return -1;
                    }
                    ai = ai + 1;
                  }
                  if (codegen_is_submit_batch_buf_call(callee.var_name, callee.var_name_len) != 0 && e.call_num_args == 3) {
                    let comma0: u8[4] = [44, 32, 48, 0];
                    if (emit_bytes_4(out, comma0, 3) != 0) {
                      return -1;
                    }
                  }
                  if (append_byte(out, 41) != 0) {
                    return -1;
                  }
                  return 0;
                }
              }
              fi = fi + 1;
            }
          }
          j = j + 1;
        }
      }
    }
    /* 兜底：entry 调用 print_str 时若 dep 未解析到（如 dep_paths 未设或 std.io 结构不同），仍生成 std_io_print_str 使 hello.x 可编译。 */
    if (ctx != 0 as *PipelineDepCtx && ctx.ndep > 0 && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
      let callee_fb: Expr = ast.ast_arena_expr_get(arena, callee_ref);
      if (callee_fb.kind == ExprKind.EXPR_VAR && callee_fb.var_name_len == 9
          && callee_fb.var_name[0] == 112 && callee_fb.var_name[1] == 114 && callee_fb.var_name[2] == 105 && callee_fb.var_name[3] == 110
          && callee_fb.var_name[4] == 116 && callee_fb.var_name[5] == 95 && callee_fb.var_name[6] == 115 && callee_fb.var_name[7] == 116 && callee_fb.var_name[8] == 114) {
        let std_io: u8[8] = [115, 116, 100, 95, 105, 111, 95, 0];
        if (emit_bytes_from_ptr(out, &std_io[0], 7) != 0) {
          return -1;
        }
        if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        let ai: i32 = 0;
        while (ai < e.call_num_args) {
          if (ai > 0) {
            let comma: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma, 2) != 0) {
              return -1;
            }
          }
          if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
            if (append_byte(out, 48) != 0) {
              return -1;
            }
          } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
            return -1;
          }
          ai = ai + 1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        return 0;
      }
    }
    /* 未在 dep 中解析到：若 callee 为当前正在生成 C 的模块内函数，则加当前 C 前缀（与 emit_func 定义一致）。 */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena != 0 as *ASTArena && !ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs) {
      let callee2: Expr = ast.ast_arena_expr_get(arena, callee_ref);
      if (callee2.kind == ExprKind.EXPR_VAR && callee2.var_name_len > 0) {
        let cur_mod: *Module = ctx.current_codegen_module;
        let cur_arena: *ASTArena = ctx.current_codegen_arena;
        let fi: i32 = 0;
        while (fi < cur_mod.num_funcs) {
          let func_ref: i32 = pipeline_module_func_ref_at(cur_mod, fi);
          if (!ast.ref_is_null(func_ref) && func_ref > 0 && func_ref <= cur_arena.num_funcs) {
            let df: Func = ast.ast_arena_func_get(cur_arena, func_ref);
            if (df.name_len == callee2.var_name_len) {
              let eq: bool = true;
              let k: i32 = 0;
              while (k < callee2.var_name_len && k < 64) {
                if (callee2.var_name[k] != df.name[k]) {
                  eq = false;
                  break;
                }
                k = k + 1;
              }
              if (eq) {
                let cur_pre: u8[128] = [];
                let cur_dep_path_buf: u8[128] = [];
                let cur_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &cur_dep_path_buf[0]);
                if (cur_dep_plen > 0) {
                  codegen_import_path_to_c_prefix_into(&cur_dep_path_buf[0], &cur_pre[0], 128);
                } else {
                  cur_pre[0] = 0 as u8;
                }
                let pl: i32 = 0;
                while (pl < 128 && cur_pre[pl] != 0) {
                  pl = pl + 1;
                }
                /* 【Why extern 裸名】同模块 extern function 调用也须用裸名，与声明符号一致 */
                if (pipeline_module_func_is_extern_at(cur_mod, fi) != 0) {
                  pl = 0;
                }
                if (pl > 0 && codegen_c_prefix_redundant_with_name(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len) == 0 && emit_bytes_from_ptr(out, &cur_pre[0], pl) != 0) {
                  return -1;
                }
                if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, cur_mod, &callee2.var_name[0], callee2.var_name_len) != 0) {
                  return -1;
                }
                if (append_byte(out, 40) != 0) {
                  return -1;
                }
                let n_cur: i32 = codegen_call_num_args_override(&cur_pre[0], pl, callee2.var_name, callee2.var_name_len, e.call_num_args);
                let fmt_i32_second_cur: i32 = 0;
                if (e.call_num_args == 2 && n_cur == 1 && callee2.var_name_len == 7 && callee2.var_name[0] == 102 && callee2.var_name[1] == 109 && callee2.var_name[2] == 116 && callee2.var_name[3] == 95 && callee2.var_name[4] == 105 && callee2.var_name[5] == 51 && callee2.var_name[6] == 50) {
                  if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0))) {
                    fmt_i32_second_cur = 1;
                  }
                }
                let ai: i32 = 0;
                while (ai < n_cur) {
                  if (ai > 0) {
                    let comma: u8[3] = [44, 32, 0];
                    if (emit_bytes_3(out, comma, 2) != 0) {
                      return -1;
                    }
                  }
                  let arg_idx_cur: i32 = ai;
                  if (fmt_i32_second_cur != 0 && ai == 0) {
                    arg_idx_cur = 1;
                  }
                  if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur))) {
                    if (append_byte(out, 48) != 0) {
                      return -1;
                    }
                  } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) != 0) {
                    return -1;
                  }
                  ai = ai + 1;
                }
                if (codegen_is_submit_batch_buf_call(callee2.var_name, callee2.var_name_len) != 0 && e.call_num_args == 3) {
                  let comma0: u8[4] = [44, 32, 48, 0];
                  if (emit_bytes_4(out, comma0, 3) != 0) {
                    return -1;
                  }
                }
                if (append_byte(out, 41) != 0) {
                  return -1;
                }
                return 0;
              }
            }
          }
          fi = fi + 1;
        }
      }
    }
    /* 特例：map_*_find_c(m, key) 在 .x 中为 2 参，C ABI 为 (keys, occupied, cap, key)，展开为 (m).keys, (m).occupied, (m).cap, key。 */
    if (!ast.ref_is_null(e.call_callee_ref) && e.call_num_args == 2 && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
      let callee_fb: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
      if (callee_fb.kind == ExprKind.EXPR_VAR && callee_fb.var_name_len >= 10) {
        let prefix_ok: bool = callee_fb.var_name[0] == 109 && callee_fb.var_name[1] == 97 && callee_fb.var_name[2] == 112 && callee_fb.var_name[3] == 95;
        let off: i32 = callee_fb.var_name_len - 6;
        let suffix_ok: bool = off >= 0 && callee_fb.var_name[off] == 102 && callee_fb.var_name[off + 1] == 105 && callee_fb.var_name[off + 2] == 110 && callee_fb.var_name[off + 3] == 100 && callee_fb.var_name[off + 4] == 95 && callee_fb.var_name[off + 5] == 99;
        if (prefix_ok && suffix_ok) {
          if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, ctx.current_codegen_module, &callee_fb.var_name[0], callee_fb.var_name_len) != 0) {
            return -1;
          }
          let open: u8[3] = [40, 40, 0];
          if (emit_bytes_3(out, open, 2) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
            return -1;
          }
          /* ").keys, (" 9 字节 */
          let mid1: u8[10] = [41, 46, 107, 101, 121, 115, 44, 32, 40, 0];
          if (emit_bytes_from_ptr(out, &mid1[0], 9) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
            return -1;
          }
          /* ").occupied, (" 13 字节 */
          let mid2: u8[14] = [41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0];
          if (emit_bytes_from_ptr(out, &mid2[0], 13) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
            return -1;
          }
          /* ").cap, " 7 字节 */
          let mid3: u8[8] = [41, 46, 99, 97, 112, 44, 32, 0];
          if (emit_bytes_8(out, mid3, 7) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) != 0) {
            return -1;
          }
          if (append_byte(out, 41) != 0) {
            return -1;
          }
          return 0;
        }
      }
    }
    let need_4th: i32 = 0;
    if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs && e.call_num_args == 3) {
      let callee_f4: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
      if (callee_f4.kind == ExprKind.EXPR_VAR && codegen_is_submit_batch_buf_call(callee_f4.var_name, callee_f4.var_name_len) != 0) {
        need_4th = 1;
      }
    }
    let saved_callee_flag: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      saved_callee_flag = ctx.emit_expr_as_callee;
      ctx.emit_expr_as_callee = 1;
    }
    if (!ast.ref_is_null(e.call_callee_ref) && emit_expr(arena, out, e.call_callee_ref, ctx) != 0) {
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.emit_expr_as_callee = saved_callee_flag;
      }
      return -1;
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.emit_expr_as_callee = saved_callee_flag;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    let fallback_pre: u8[64] = [];
    let fallback_pl: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      let fb_dep_path_buf: u8[128] = [];
      let fb_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &fb_dep_path_buf[0]);
      if (fb_dep_plen > 0) {
        codegen_import_path_to_c_prefix_into(&fb_dep_path_buf[0], &fallback_pre[0], 64);
      } else {
        fallback_pre[0] = 0 as u8;
      }
      while (fallback_pl < 64 && fallback_pre[fallback_pl] != 0) {
        fallback_pl = fallback_pl + 1;
      }
    }
    let n_fb: i32 = e.call_num_args;
    /* 单参函数：若 driver 返回 1 且 AST 误成两参且首参为 null，只输出第二参，避免 print_i32(0,42)/ok_i32(0,42) 等编译错误。 */
    let use_second_arg: i32 = 0;
    if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
      let callee_expr: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
      if (callee_expr.kind == ExprKind.EXPR_VAR) {
        n_fb = codegen_call_num_args_override(&fallback_pre[0], fallback_pl, callee_expr.var_name, callee_expr.var_name_len, e.call_num_args);
        if (e.call_num_args == 2 && n_fb == 1 && ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, 0)) != 0) {
          use_second_arg = 1;
        }
      }
    }
    let ai: i32 = 0;
    while (ai < n_fb) {
      if (ai > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      let arg_idx: i32 = ai;
      if (use_second_arg != 0 && ai == 0) {
        arg_idx = 1;
      }
      if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx))) {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
      } else if (emit_expr(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    if (need_4th != 0) {
      let comma0: u8[4] = [44, 32, 48, 0];
      if (emit_bytes_4(out, comma0, 3) != 0) {
        return -1;
      }
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    return 0;
  }
  /* 浮点字面量：简单输出 0.0 或整部.小数（无 sprintf 时用最小实现）。 */
  if (e.kind == ExprKind.EXPR_FLOAT_LIT) {
    if (e.float_val == 0.0) {
      let z: u8[4] = [48, 46, 48, 0];
      return emit_bytes_4(out, z, 3);
    }
    /* 非零暂用 0.0 占位，后续可接 format_float 实现 */
    let z: u8[4] = [48, 46, 48, 0];
    return emit_bytes_4(out, z, 3);
  }
  /* 二元运算：MUL/DIV/MOD/SHL/SHR/BITAND/BITOR/BITXOR/EQ/NE/LT/LE/GT/GE/LOGAND/LOGOR，统一 ( left op right )。 */
  if (e.kind == ExprKind.EXPR_MUL) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 42, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_DIV) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 47, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_MOD) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 37, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 比较运算：== != < <= > >= */
  if (e.kind == ExprKind.EXPR_EQ) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 61, 61, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_NE) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 33, 61, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_LT) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 60, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_LE) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 60, 61, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_GT) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 62, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_GE) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 62, 61, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_LOGAND) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[5] = [32, 38, 38, 32, 0];
    if (emit_bytes_5(out, op, 4) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_LOGOR) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[5] = [32, 124, 124, 32, 0];
    if (emit_bytes_5(out, op, 4) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_SHL) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 60, 60, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_SHR) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 62, 62, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_BITAND) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 38, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_BITOR) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 124, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_BITXOR) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_left_ref, ctx) != 0) {
      return -1;
    }
    let op: u8[4] = [32, 94, 32, 0];
    if (emit_bytes_4(out, op, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.binop_right_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 一元：BITNOT ~(operand)，LOGNOT !(operand) */
  if (e.kind == ExprKind.EXPR_BITNOT) {
    let pre: u8[3] = [126, 40, 0];
    if (emit_bytes_3(out, pre, 2) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  if (e.kind == ExprKind.EXPR_LOGNOT) {
    let pre: u8[3] = [33, 40, 0];
    if (emit_bytes_3(out, pre, 2) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 三元：cond ? then : else，与 EXPR_IF 同形 */
  if (e.kind == ExprKind.EXPR_TERNARY) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_cond_ref) && emit_expr(arena, out, e.if_cond_ref, ctx) != 0) {
      return -1;
    }
    let q: u8[4] = [32, 63, 32, 0];
    if (emit_bytes_4(out, q, 3) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_then_ref) && emit_expr(arena, out, e.if_then_ref, ctx) != 0) {
      return -1;
    }
    let colon: u8[4] = [32, 58, 32, 0];
    if (emit_bytes_4(out, colon, 3) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.if_else_ref) && emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* 下标：base[index] 或 base.data[index]（切片时） */
  if (e.kind == ExprKind.EXPR_INDEX) {
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.index_base_ref) && emit_expr(arena, out, e.index_base_ref, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    if (e.index_base_is_slice != 0) {
      let dot: u8[6] = [46, 100, 97, 116, 97, 0];
      if (emit_bytes_6(out, dot, 5) != 0) {
        return -1;
      }
    }
    if (append_byte(out, 91) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.index_index_ref) && emit_expr(arena, out, e.index_index_ref, ctx) != 0) {
      return -1;
    }
    return append_byte(out, 93);
  }
  /* 字段访问：(base).field 或 (base)->field（base 为指针/slice 时用 ->，C 中 slice 按指针传） */
  if (e.kind == ExprKind.EXPR_FIELD_ACCESS) {
    if (e.field_access_is_enum_variant != 0) {
      /** 枚举变体：输出 typeck 填好的 tag 整数字面量（C 侧无 enum 声明时仍合法）。 */
      return format_int(out, e.enum_variant_tag);
    }
    /** callee 位置的 binding.func：直接扁平化为 dep 前缀 C 符号，避免回落成 `(binding).func`。 */
    if (ctx != 0 as *PipelineDepCtx && ctx.emit_expr_as_callee != 0 && emit_import_module_field_symbol(arena, out, expr_ref, ctx) == 0) {
      return 0;
    }
    /** binding.CONST：如 async_mod.POLL_PENDING → std_async_POLL_PENDING */
    if (emit_import_module_const_field(arena, out, expr_ref, ctx) == 0) {
      return 0;
    }
    /*
     * std.io.driver 的 register/submit_read/submit_write 首参在 C 侧已强制为 ptrdiff_t 句柄，
     * * 函数体内仍写 buf.ptr / buf.len 会形成对标量取字段；若 base 即该首参变量，只发射变量名。
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_codegen_arena == arena && ctx.current_func_index >= 0) {
      let mod: *Module = ctx.current_codegen_module;
      if (ctx.current_func_index < mod.num_funcs) {
        let cfi: i32 = ctx.current_func_index;
        let pref: u8[128] = [];
        let plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &pref[0], 128);
        let cfn: u8[64] = [];
        pipeline_module_func_name_copy64(mod, cfi, &cfn[0]);
        let cfn_len: i32 = pipeline_module_func_name_len_at(mod, cfi);
        if (codegen_force_param_ptrdiff_t(&pref[0], plen, &cfn[0], cfn_len, 0) != 0) {
          if (expr_var_matches_func_param_index(arena, e.field_access_base_ref, mod, cfi, 0, ctx) != 0) {
            return emit_expr(arena, out, e.field_access_base_ref, ctx);
          }
        }
      }
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.field_access_base_ref) && emit_expr(arena, out, e.field_access_base_ref, ctx) != 0) {
      return -1;
    }
    /* base 为指针或 slice 时输出 ->，否则输出 .；类型由 arena+resolved_type_ref 判断；无类型时回退为形参名 source/out_buf 用 ->，从源头避免 (source).length 补丁 */
    if (field_access_base_is_pointer_ref(arena, e.field_access_base_ref) != 0 || field_access_base_is_slice_param_name(arena, e.field_access_base_ref) != 0) {
      let arrow: u8[3] = [45, 62, 0];
      if (emit_bytes_3(out, arrow, 2) != 0) {
        return -1;
      }
    } else {
      let dot: u8[2] = [46, 0];
      if (emit_bytes_2(out, dot, 1) != 0) {
        return -1;
      }
    }
    if (emit_bytes_64(out, &e.field_access_field_name[0], e.field_access_field_len) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* panic 或 panic(expr)：输出 shux_panic_(0,0) 或 shux_panic_(1, expr) */
  if (e.kind == ExprKind.EXPR_PANIC) {
    let p: u8[22] = [115, 104, 117, 108, 97, 110, 103, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0];
    if (emit_bytes_22(out, p, 15) != 0) {
      return -1;
    }
    if (ast.ref_is_null(e.unary_operand_ref)) {
      if (append_byte(out, 48) != 0) {
        return -1;
      }
      if (append_byte(out, 44) != 0) {
        return -1;
      }
      if (append_byte(out, 48) != 0) {
        return -1;
      }
    } else {
      if (append_byte(out, 49) != 0) {
        return -1;
      }
      if (append_byte(out, 44) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, e.unary_operand_ref, ctx) != 0) {
        return -1;
      }
    }
    return append_byte(out, 41);
  }
  /* break; / continue; 仅作表达式占位，实际在语句中生成；此处输出 0 避免缺值 */
  if (e.kind == ExprKind.EXPR_BREAK) {
    return append_byte(out, 48);
  }
  if (e.kind == ExprKind.EXPR_CONTINUE) {
    return append_byte(out, 48);
  }
  /* 方法调用：base.method_name(arg0, ...) */
  if (e.kind == ExprKind.EXPR_METHOD_CALL) {
    if (ctx != 0 as *PipelineDepCtx) {
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
      if (dep_ix >= 0 && func_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
        if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
          let dep_path: u8[64] = [];
          pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
          let pre_buf: u8[128] = [];
          codegen_import_path_to_c_prefix_into(&dep_path[0], &pre_buf[0], 128);
          let pre_len: i32 = 0;
          while (pre_len < 128 && pre_buf[pre_len] != 0) {
            pre_len = pre_len + 1;
          }
          let fn_name: u8[64] = [];
          let fn_len: i32 = pipeline_module_func_name_len_at(dep_mod, func_ix);
          if (fn_len > 0) {
            pipeline_module_func_name_copy64(dep_mod, func_ix, &fn_name[0]);
          }
          if (pre_len > 0 && fn_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], pre_len, &fn_name[0], fn_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], pre_len) != 0) {
            return -1;
          }
          if (fn_len > 0 && emit_bytes_from_ptr(out, &fn_name[0], fn_len) != 0) {
            return -1;
          }
          if (append_byte(out, 40) != 0) {
            return -1;
          }
          let n_dep: i32 = codegen_call_num_args_override(&pre_buf[0], pre_len, &fn_name[0], fn_len, e.method_call_num_args);
          let ai: i32 = 0;
          while (ai < n_dep) {
            if (ai > 0) {
              let comma_dep: u8[3] = [44, 32, 0];
              if (emit_bytes_3(out, comma_dep, 2) != 0) {
                return -1;
              }
            }
            let dep_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
            if (ast.ref_is_null(dep_arg)) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_expr(arena, out, dep_arg, ctx) != 0) {
              return -1;
            }
            ai = ai + 1;
          }
          return append_byte(out, 41);
        }
      }
      let dep_path_fb: u8[64] = [];
      let dep_path_fb_len: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &dep_path_fb[0]);
      if (dep_path_fb_len > 0) {
        let pre_fb: u8[128] = [];
        codegen_import_path_to_c_prefix_into(&dep_path_fb[0], &pre_fb[0], 128);
        let pre_fb_len: i32 = 0;
        while (pre_fb_len < 128 && pre_fb[pre_fb_len] != 0) {
          pre_fb_len = pre_fb_len + 1;
        }
        if (pre_fb_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len) == 0 && emit_bytes_from_ptr(out, &pre_fb[0], pre_fb_len) != 0) {
          return -1;
        }
        /* 【Why 根源】按 import path 匹配 dep 模块，用 codegen_emit_call_func_name 走 mangling。
           【Invariant】dep_path_fb 与各 dep 的 import_path 逐字节比较；找到唯一匹配则搜索。 */
        let fb_dep_mod: *Module = 0 as *Module;
        let dj: i32 = 0;
        while (dj < pipeline_dep_ctx_ndep(ctx)) {
          let dj_path: u8[64] = [];
          pipeline_dep_ctx_import_path_copy64(ctx, dj, &dj_path[0]);
          let dj_plen: i32 = pipeline_dep_ctx_import_path_len(ctx, dj);
          if (dj_plen == dep_path_fb_len && dj_plen > 0) {
            let dj_eq: i32 = 1;
            let dk: i32 = 0;
            while (dk < dj_plen) {
              if (dj_path[dk] != dep_path_fb[dk]) {
                dj_eq = 0;
                dk = dj_plen;
              } else {
                dk = dk + 1;
              }
            }
            if (dj_eq != 0) {
              fb_dep_mod = pipeline_dep_ctx_module_at(ctx, dj);
              dj = pipeline_dep_ctx_ndep(ctx);
            }
          }
          dj = dj + 1;
        }
        if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, fb_dep_mod, &e.method_call_name[0], e.method_call_name_len) != 0) {
          return -1;
        }
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        let n_fb: i32 = codegen_call_num_args_override(&pre_fb[0], pre_fb_len, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
        let ai_fb: i32 = 0;
        while (ai_fb < n_fb) {
          if (ai_fb > 0) {
            let comma_fb: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma_fb, 2) != 0) {
              return -1;
            }
          }
          let arg_fb: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
          if (ast.ref_is_null(arg_fb)) {
            if (append_byte(out, 48) != 0) {
              return -1;
            }
          } else if (emit_expr(arena, out, arg_fb, ctx) != 0) {
            return -1;
          }
          ai_fb = ai_fb + 1;
        }
        return append_byte(out, 41);
      }
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(e.method_call_base_ref) && emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
      return -1;
    }
    let dot: u8[2] = [46, 0];
    if (emit_bytes_2(out, dot, 1) != 0) {
      return -1;
    }
    if (emit_bytes_64(out, &e.method_call_name[0], e.method_call_name_len) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    let mi: i32 = 0;
    while (mi < e.method_call_num_args) {
      if (mi > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      let m_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, mi);
      if (ast.ref_is_null(m_arg)) {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
      } else if (emit_expr(arena, out, m_arg, ctx) != 0) {
        return -1;
      }
      mi = mi + 1;
    }
    if (append_byte(out, 41) != 0) {
      return -1;
    }
    return append_byte(out, 41);
  }
  /* match：ast.x 暂无 per-arm 模式（is_wildcard/lit_val/variant_index），仅输出首 arm 的 result 占位；完整实现需 ast 扩展后做 switch/三元链。 */
  if (e.kind == ExprKind.EXPR_MATCH) {
    if (e.match_num_arms <= 0) {
      return append_byte(out, 48);
    }
    let m0: i32 = pipeline_expr_match_arm_result_ref(arena, expr_ref, 0);
    if (!ast.ref_is_null(m0) && emit_expr(arena, out, m0, ctx) != 0) {
      return -1;
    }
    return 0;
  }
  /* STRUCT_LIT：纯 .x 实现。(struct prefix+Name){ .f1 = e1, ... }，前缀与 emit_func 一致。 */
  if (e.kind == ExprKind.EXPR_STRUCT_LIT) {
    let sl_pfx: u8[128] = [];
    let sl_plen: i32 = codegen_emit_prefix_len_from_ctx(ctx, &sl_pfx[0], 128);
    let bare_user_lit: i32 = 0;
    if (sl_plen == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0 && ctx.current_codegen_module != 0 as *Module) {
      let modu: *Module = ctx.current_codegen_module;
      let sk: i32 = 0;
      while (sk < modu.num_struct_layouts) {
        let snl: i32 = pipeline_module_struct_layout_name_len(modu, sk);
        if (snl == e.struct_lit_struct_name_len && snl > 0) {
          let snm: u8[64] = [];
          pipeline_module_struct_layout_name_into(modu, sk, &snm[0]);
          let eq2: bool = true;
          let sj: i32 = 0;
          while (sj < snl && sj < 64) {
            if (snm[sj] != e.struct_lit_struct_name[sj]) {
              eq2 = false;
              break;
            }
            sj = sj + 1;
          }
          if (eq2) {
            bare_user_lit = 1;
            break;
          }
        }
        sk = sk + 1;
      }
    }
    let open: u8[9] = [40, 115, 116, 114, 117, 99, 116, 32, 0];
    if (emit_bytes_9(out, open, 8) != 0) {
      return -1;
    }
    if (bare_user_lit == 0 && sl_plen > 0 && emit_bytes_from_ptr(out, &sl_pfx[0], sl_plen) != 0) {
      return -1;
    }
    if (emit_bytes_64(out, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len) != 0) {
      return -1;
    }
    let open2: u8[5] = [41, 123, 32, 0, 0];
    if (emit_bytes_5(out, open2, 3) != 0) {
      return -1;
    }
    let fi: i32 = 0;
    let nf_codegen: i32 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    while (fi < nf_codegen) {
      if (fi > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      if (append_byte(out, 46) != 0) {
        return -1;
      }
      let sl_fnbuf: u8[64] = [];
      pipeline_expr_struct_lit_field_name_into(arena, expr_ref, fi, &sl_fnbuf[0]);
      let flen: i32 = pipeline_expr_struct_lit_field_name_len(arena, expr_ref, fi);
      if (flen > 64) {
        if (emit_bytes_64(out, &sl_fnbuf[0], 64) != 0) {
          return -1;
        }
      } else {
        if (emit_bytes_64(out, &sl_fnbuf[0], flen) != 0) {
          return -1;
        }
      }
      let eq: u8[4] = [32, 61, 32, 0];
      if (emit_bytes_4(out, eq, 3) != 0) {
        return -1;
      }
      /* 结构体字段为数组且初值为空 [] 时，C 不允许 .field = (ty[]){ }，改为 .field = { 0 } 零初始化 */
      let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
      if (!ast.ref_is_null(init_ref)) {
        let init_e: Expr = ast.ast_arena_expr_get(arena, init_ref);
        if (init_e.kind == ExprKind.EXPR_ARRAY_LIT && init_e.array_lit_num_elems == 0) {
          let zero_init: u8[6] = [123, 32, 48, 32, 125, 0];
          if (emit_bytes_6(out, zero_init, 5) != 0) {
            return -1;
          }
        } else {
          if (emit_expr(arena, out, init_ref, ctx) != 0) {
            return -1;
          }
        }
      }
      fi = fi + 1;
    }
    let close: u8[4] = [32, 125, 0, 0];
    return emit_bytes_4(out, close, 2);
  }
  /* ARRAY_LIT：纯 .x 实现。(elem_ty[]){ e1, e2, ... }；若 resolved_type 为 SLICE 则 (SliceTy){ .data = (elem[]){ ... }, .length = n } */
  if (e.kind == ExprKind.EXPR_ARRAY_LIT) {
    let n: i32 = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    let elem_type_ref: i32 = 0;
    let is_slice: i32 = 0;
    if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
      let ty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
      if (ty.kind == TypeKind.TYPE_SLICE) {
        is_slice = 1;
        elem_type_ref = ty.elem_type_ref;
      } else if (ty.kind == TypeKind.TYPE_ARRAY) {
        elem_type_ref = ty.elem_type_ref;
      }
    }
    if (elem_type_ref == 0 && n > 0) {
      let first_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
      if (!ast.ref_is_null(first_ref)) {
        let first_e: Expr = ast.ast_arena_expr_get(arena, first_ref);
        elem_type_ref = first_e.resolved_type_ref;
      }
    }
    if (is_slice != 0) {
      let lp: u8[3] = [40, 0, 0];
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
        let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
        if (emit_bytes_9(out, fallback, 7) != 0) {
          return -1;
        }
      }
      let slice_mid: u8[22] = [41, 123, 32, 46, 100, 97, 116, 97, 32, 61, 32, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_22(out, slice_mid, 11) != 0) {
        return -1;
      }
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (!ast.ref_is_null(elem_type_ref) && emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
        let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
        if (emit_bytes_9(out, fallback, 7) != 0) {
          return -1;
        }
      }
      let arr: u8[5] = [91, 93, 41, 123, 0];
      if (emit_bytes_5(out, arr, 4) != 0) {
        return -1;
      }
    } else {
      /* 非 slice 数组字面量：(elem_ty[]){ ... }；elem_type_ref 为空时须输出类型否则 C 报错 ([]){ } */
      if (append_byte(out, 40) != 0) {
        return -1;
      }
      if (ast.ref_is_null(elem_type_ref) || emit_type(arena, out, elem_type_ref, 0 as *u8, 0, ctx) != 0) {
        let fallback: u8[9] = [117, 105, 110, 116, 56, 95, 116, 0, 0];
        if (emit_bytes_9(out, fallback, 7) != 0) {
          return -1;
        }
      }
      let arr: u8[5] = [91, 93, 41, 123, 0];
      if (emit_bytes_5(out, arr, 4) != 0) {
        return -1;
      }
    }
    let ai: i32 = 0;
    while (ai < n) {
      if (ai > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai)) && emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai), ctx) != 0) {
        return -1;
      }
      ai = ai + 1;
    }
    if (is_slice != 0) {
      let slice_end: u8[22] = [32, 125, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_22(out, slice_end, 14) != 0) {
        return -1;
      }
      if (format_int(out, ai) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      if (append_byte(out, 125) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    let close: u8[4] = [32, 125, 0, 0];
    return emit_bytes_4(out, close, 2);
  }
  /* EXPR_ENUM_VARIANT：枚举变体现多用 EXPR_FIELD_ACCESS + field_access_is_enum_variant；此处占位输出 0。 */
  if (e.kind == ExprKind.EXPR_ENUM_VARIANT) {
    return append_byte(out, 48);
  }
  return -1;
}

/**
 * 判断 EXPR_VAR 形 callee 是否为 string_new 或 std_string_string_new；
 * 拆成独立函数并用循环比较，避免超长 if 在 -E-extern 路径 parse 失败。
 */
function codegen_callee_var_is_string_new(e: Expr): i32 {
  if (e.kind != ExprKind.EXPR_VAR) {
    return 0;
  }
  if (e.var_name_len == 10) {
    let expect_sn: u8[10] = [115, 116, 114, 105, 110, 95, 110, 101, 119, 0];
    let i_sn: i32 = 0;
    while (i_sn < 9) {
      if (e.var_name[i_sn] != expect_sn[i_sn]) {
        return 0;
      }
      i_sn = i_sn + 1;
    }
    return 1;
  }
  if (e.var_name_len == 22) {
    let expect_ssn: u8[22] = [115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 95, 110, 101, 119, 0, 0];
    let i_ssn: i32 = 0;
    while (i_ssn < 20) {
      if (e.var_name[i_ssn] != expect_ssn[i_ssn]) {
        return 0;
      }
      i_ssn = i_ssn + 1;
    }
    return 1;
  }
  return 0;
}

/**
 * MEM-B0：逆序输出块内 defer 子块体（编译期静态内联，零运行时栈）。
 */
function emit_run_defers(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  let ndef: i32 = 0;
  while (ndef < 256) {
    if (pipeline_block_defer_body_ref(arena, block_ref, ndef) <= 0) {
      break;
    }
    ndef = ndef + 1;
  }
  let di: i32 = ndef - 1;
  while (di >= 0) {
    let dbody: i32 = pipeline_block_defer_body_ref(arena, block_ref, di);
    if (dbody > 0) {
      if (emit_block(arena, out, dbody, indent, ctx) != 0) {
        return -1;
      }
    }
    di = di - 1;
  }
  return 0;
}

function codegen_current_func_returns_void(arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module || ctx.current_codegen_arena != arena || ctx.current_func_index < 0) {
    return 0;
  }
  let mod: *Module = ctx.current_codegen_module;
  if (ctx.current_func_index >= mod.num_funcs) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(mod, ctx.current_func_index)) == (TypeKind.TYPE_VOID as i32)) {
    return 1;
  }
  return 0;
}

function emit_return_stmt_with_context(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, operand_ref: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  if (fn_ret_void != 0) {
    if (!ast.ref_is_null(operand_ref)) {
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
      if (emit_bytes_9(out, v, 7) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, operand_ref, ctx) != 0) {
        return -1;
      }
      let scv: u8[4] = [41, 59, 10, 0];
      if (emit_bytes_4(out, scv, 3) != 0) {
        return -1;
      }
    }
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let retv: u8[9] = [114, 101, 116, 117, 114, 110, 59, 10, 0];
    return emit_bytes_9(out, retv, 8);
  }
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let ret: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
  if (emit_bytes_8(out, ret, 7) != 0) {
    return -1;
  }
  if (!ast.ref_is_null(operand_ref) && emit_expr(arena, out, operand_ref, ctx) != 0) {
    return -1;
  }
  let sc: u8[4] = [59, 10, 0, 0];
  return emit_bytes_4(out, sc, 2);
}

/**
 * 写块体到 out：const/let 声明、while/for、表达式语句、最终表达式。
 * 当 num_stmt_order > 0 时按 stmt_order 源码顺序输出，保证 let/if/return 等顺序正确，避免递归或提前 return 等错误。
 */
function emit_block(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  let blk_prefix: u8[128] = [];
  let blk_prefix_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &blk_prefix[0], 128);
  let fn_ret_void: i32 = codegen_current_func_returns_void(arena, ctx);
  if (ast.ref_is_null(block_ref)) {
    return 0;
  }
  if (block_ref <= 0 || block_ref > arena.num_blocks) {
    return 0;
  }
  if (ast.ast_block_num_stmt_order(arena, block_ref) > 0) {
    /* stmt_order 路径可能漏 emit 部分 let（types.x format_* 等）；先补发缺失 let。 */
    let pre_li: i32 = 0;
    while (pre_li < ast.ast_block_num_lets(arena, block_ref)) {
      if (block_stmt_order_has_let(arena, block_ref, pre_li) == 0) {
        let lname_pre: u8[64] = [];
        pipeline_block_let_name_copy64(arena, block_ref, pre_li, &lname_pre[0]);
        let lname_len_pre: i32 = pipeline_block_let_name_len(arena, block_ref, pre_li);
        let let_type_pre: i32 = pipeline_block_let_type_ref(arena, block_ref, pre_li);
        let linit_pre: i32 = pipeline_block_let_init_ref(arena, block_ref, pre_li);
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        let type_emitted_pre: i32 = 0;
        let use_local_array_pre: i32 = 0;
        if (!ast.ref_is_null(let_type_pre) && pipeline_type_kind_ord_at(arena, let_type_pre) == 10) {
          use_local_array_pre = 1;
        }
        if (use_local_array_pre != 0) {
          if (emit_local_fixed_array_elem_type(arena, out, let_type_pre, ctx) != 0) {
            return -1;
          }
          type_emitted_pre = 1;
        }
        if (type_emitted_pre == 0) {
          if (emit_type(arena, out, let_type_pre, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
        }
        if (append_byte(out, 32) != 0) {
          return -1;
        }
        if (lname_len_pre > 0 && (lname_pre[0] > 32)) {
          if (emit_bytes_64(out, &lname_pre[0], lname_len_pre) != 0) {
            return -1;
          }
        } else {
          let place_pre: u8[4] = [95, 108, 48, 0];
          if (emit_bytes_4(out, place_pre, 2) != 0) {
            return -1;
          }
          if (format_int(out, pre_li) != 0) {
            return -1;
          }
        }
        if (use_local_array_pre != 0) {
          if (emit_local_fixed_array_suffix(arena, out, let_type_pre) != 0) {
            return -1;
          }
        }
        let eq_pre: u8[4] = [32, 61, 32, 0];
        if (emit_bytes_4(out, eq_pre, 3) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, linit_pre, ctx) != 0) {
          return -1;
        }
        let sc_pre: u8[3] = [59, 10, 0];
        if (emit_bytes_3(out, sc_pre, 2) != 0) {
          return -1;
        }
      }
      pre_li = pre_li + 1;
    }
    let si: i32 = 0;
    while (si < ast.ast_block_num_stmt_order(arena, block_ref)) {
      let k: u8 = ast.ast_block_stmt_order_kind(arena, block_ref, si);
      let idx: i32 = ast.ast_block_stmt_order_idx(arena, block_ref, si);
      if (k == 0) {
        if (idx >= 0 && idx < ast.ast_block_num_consts(arena, block_ref)) {
          let cname_buf: u8[64] = [];
          pipeline_block_const_name_copy64(arena, block_ref, idx, &cname_buf[0]);
          let cname_len: i32 = pipeline_block_const_name_len(arena, block_ref, idx);
          let ctype_ref: i32 = pipeline_block_const_type_ref(arena, block_ref, idx);
          let cinit_ref: i32 = pipeline_block_const_init_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          if (emit_type(arena, out, ctype_ref, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          let sp: u8[3] = [32, 0, 0];
          if (emit_bytes_3(out, sp, 1) != 0) {
            return -1;
          }
          /* 无名或首字符为空格时用 _c0, _c1, ... 占位。 */
          if (cname_len > 0 && (cname_buf[0] > 32)) {
            if (emit_bytes_64(out, &cname_buf[0], cname_len) != 0) {
              return -1;
            }
          } else {
            let place: u8[4] = [95, 99, 48, 0];
            if (emit_bytes_4(out, place, 2) != 0) {
              return -1;
            }
            if (format_int(out, idx) != 0) {
              return -1;
            }
          }
          let eq: u8[4] = [32, 61, 32, 0];
          if (emit_bytes_4(out, eq, 3) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, cinit_ref, ctx) != 0) {
            return -1;
          }
          let sc: u8[3] = [59, 10, 0];
          if (emit_bytes_3(out, sc, 2) != 0) {
            return -1;
          }
        }
      } else if (k == 1) {
        if (idx >= 0 && idx < ast.ast_block_num_lets(arena, block_ref)) {
          let lname_buf: u8[64] = [];
          pipeline_block_let_name_copy64(arena, block_ref, idx, &lname_buf[0]);
          let lname_len: i32 = pipeline_block_let_name_len(arena, block_ref, idx);
          let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, idx);
          let linit_ref: i32 = pipeline_block_let_init_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          /* T[N] 局部数组用 elem[N]；仅 u8[N] 字面量仍用 uint8_t*；string_new 等见下。 */
          let type_emitted: i32 = 0;
          let use_local_array: i32 = 0;
          if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
            use_local_array = 1;
          }
          if (use_local_array != 0) {
            if (emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
              return -1;
            }
            type_emitted = 1;
          }
          if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
            let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
            if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_ARRAY_LIT && type_array_elem_is_u8(arena, let_type_ref) != 0) {
              let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
              if (emit_bytes_9(out, u8ptr, 7) != 0) {
                return -1;
              }
              if (append_byte(out, 42) != 0) {
                return -1;
              }
              type_emitted = 1;
            }
            /* init 为返回 String 的 call（如 string_new）时，强制用 String 类型，与 preamble 一致；通过 callee 名或 resolved_type 名判断。 */
            if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
              let rt: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
              if (rt.kind == TypeKind.TYPE_NAMED && rt.name_len >= 6) {
                let n0: i32 = rt.name_len - 6;
                if (rt.name[n0] == 83 && rt.name[n0 + 1] == 116 && rt.name[n0 + 2] == 114 && rt.name[n0 + 3] == 105 && rt.name[n0 + 4] == 110 && rt.name[n0 + 5] == 103) {
                  let str_ty: u8[8] = [83, 116, 114, 105, 110, 103, 32, 0];
                  if (emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                    return -1;
                  }
                  if (append_byte(out, 32) != 0) {
                    return -1;
                  }
                  type_emitted = 1;
                }
              }
            }
            if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_CALL && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
              let callee_let: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
              if (callee_let.kind == ExprKind.EXPR_VAR) {
                if (codegen_callee_var_is_string_new(callee_let) != 0) {
                  let str_ty: u8[8] = [83, 116, 114, 105, 110, 103, 32, 0];
                  if (emit_bytes_from_ptr(out, &str_ty[0], 6) != 0) {
                    return -1;
                  }
                  if (append_byte(out, 32) != 0) {
                    return -1;
                  }
                  type_emitted = 1;
                }
              }
            }
          }
          if (type_emitted == 0) {
            if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
              let init_e: Expr = ast.ast_arena_expr_get(arena, linit_ref);
              if (!ast.ref_is_null(init_e.resolved_type_ref)) {
                let_type_ref = init_e.resolved_type_ref;
              }
            }
            if (emit_type(arena, out, let_type_ref, 0 as *u8, 0, ctx) != 0) {
              return -1;
            }
          }
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          /* 无名或首字符为空格时用 _l0, _l1, ... 占位。 */
          if (lname_len > 0 && (lname_buf[0] > 32)) {
            if (emit_bytes_64(out, &lname_buf[0], lname_len) != 0) {
              return -1;
            }
          } else {
            let place: u8[4] = [95, 108, 48, 0];
            if (emit_bytes_4(out, place, 2) != 0) {
              return -1;
            }
            if (format_int(out, idx) != 0) {
              return -1;
            }
          }
          if (use_local_array != 0) {
            if (emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
              return -1;
            }
          }
          let eq: u8[4] = [32, 61, 32, 0];
          if (emit_bytes_4(out, eq, 3) != 0) {
            return -1;
          }
          let slice_init: i32 = 0;
          if (!ast.ref_is_null(linit_ref)) {
            slice_init = try_emit_slice_init_from_array_var(arena, out, block_ref, idx, let_type_ref, linit_ref);
          }
          /** let x: T; 无 init：C 零初始化 { 0 }。 */
          if (ast.ref_is_null(linit_ref)) {
            let zinit_omit2: u8[6] = [123, 32, 48, 32, 125, 0];
            if (emit_bytes_6(out, zinit_omit2, 5) != 0) {
              return -1;
            }
          } else if (slice_init == 1) {
            /* slice from array var 已写出 */
          } else if (slice_init < 0) {
            return -1;
          } else if (use_local_array != 0 && !ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs) {
            let init_e2: Expr = ast.ast_arena_expr_get(arena, linit_ref);
            if (init_e2.kind == ExprKind.EXPR_ARRAY_LIT) {
              if (emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
                return -1;
              }
            } else if (init_e2.kind == ExprKind.EXPR_LIT && init_e2.int_val == 0) {
              let zinit: u8[6] = [123, 32, 48, 32, 125, 0];
              if (emit_bytes_6(out, zinit, 5) != 0) {
                return -1;
              }
            } else {
              if (emit_expr(arena, out, linit_ref, ctx) != 0) {
                return -1;
              }
            }
          } else {
            if (emit_expr(arena, out, linit_ref, ctx) != 0) {
              return -1;
            }
          }
          let sc: u8[3] = [59, 10, 0];
          if (emit_bytes_3(out, sc, 2) != 0) {
            return -1;
          }
        }
      } else if (k == 2) {
        if (idx >= 0 && idx < ast.ast_block_num_expr_stmts(arena, block_ref)) {
          let ex_ref: i32 = ast.ast_block_expr_stmt_ref(arena, block_ref, idx);
          let st: Expr = ast.ast_arena_expr_get(arena, ex_ref);
          if (st.kind == ExprKind.EXPR_RETURN) {
            if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
              return -1;
            }
          } else if (st.kind == ExprKind.EXPR_BREAK) {
            if (emit_break_stmt(out, indent) != 0) {
              return -1;
            }
          } else if (st.kind == ExprKind.EXPR_CONTINUE) {
            if (emit_continue_stmt(out, indent) != 0) {
              return -1;
            }
          } else {
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
            let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
            if (emit_bytes_9(out, v, 7) != 0) {
              return -1;
            }
            if (emit_expr(arena, out, ex_ref, ctx) != 0) {
              return -1;
            }
            let sc: u8[4] = [41, 59, 10, 0];
            if (emit_bytes_4(out, sc, 3) != 0) {
              return -1;
            }
          }
        }
      } else if (k == 3) {
        if (idx >= 0 && idx < ast.ast_block_num_loops(arena, block_ref)) {
          let w_cr: i32 = ast.ast_block_while_cond_ref(arena, block_ref, idx);
          let w_br: i32 = ast.ast_block_while_body_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
          if (emit_bytes_8(out, wh, 7) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, w_cr, ctx) != 0) {
            return -1;
          }
          let paren: u8[5] = [41, 32, 123, 10, 0];
          if (emit_bytes_5(out, paren, 4) != 0) {
            return -1;
          }
          if (emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
            return -1;
          }
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let close: u8[3] = [125, 10, 0];
          if (emit_bytes_3(out, close, 2) != 0) {
            return -1;
          }
        }
      } else if (k == 4) {
        if (idx >= 0 && idx < ast.ast_block_num_for_loops(arena, block_ref)) {
          let fl_ir: i32 = ast.ast_block_for_init_ref(arena, block_ref, idx);
          let fl_cr: i32 = ast.ast_block_for_cond_ref(arena, block_ref, idx);
          let fl_sr: i32 = ast.ast_block_for_step_ref(arena, block_ref, idx);
          let fl_br: i32 = ast.ast_block_for_body_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let fk: u8[6] = [102, 111, 114, 32, 40, 0];
          if (emit_bytes_6(out, fk, 5) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(fl_ir)) {
            if (emit_expr(arena, out, fl_ir, ctx) != 0) {
              return -1;
            }
          }
          let sc1: u8[3] = [59, 32, 0];
          if (emit_bytes_3(out, sc1, 2) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(fl_cr)) {
            if (emit_expr(arena, out, fl_cr, ctx) != 0) {
              return -1;
            }
          }
          let sc2: u8[3] = [59, 32, 0];
          if (emit_bytes_3(out, sc2, 2) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(fl_sr)) {
            if (emit_expr(arena, out, fl_sr, ctx) != 0) {
              return -1;
            }
          }
          let paren: u8[5] = [41, 32, 123, 10, 0];
          if (emit_bytes_5(out, paren, 4) != 0) {
            return -1;
          }
          if (!ast.ref_is_null(fl_br) && emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
            return -1;
          }
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let close: u8[3] = [125, 10, 0];
          if (emit_bytes_3(out, close, 2) != 0) {
            return -1;
          }
        }
      } else if (k == 5) {
        if (idx >= 0 && idx < ast.ast_block_num_if_stmts(arena, block_ref)) {
          let if_cond_r: i32 = ast.ast_block_if_cond_ref(arena, block_ref, idx);
          let if_then_r: i32 = ast.ast_block_if_then_body_ref(arena, block_ref, idx);
          let if_else_r: i32 = ast.ast_block_if_else_body_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let ikw: u8[5] = [105, 102, 32, 40, 0];
          if (emit_bytes_5(out, ikw, 4) != 0) {
            return -1;
          }
          if (emit_expr(arena, out, if_cond_r, ctx) != 0) {
            return -1;
          }
          let paren_if: u8[5] = [41, 32, 123, 10, 0];
          if (emit_bytes_5(out, paren_if, 4) != 0) {
            return -1;
          }
          if (emit_block(arena, out, if_then_r, indent + 2, ctx) != 0) {
            return -1;
          }
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          if (if_else_r != 0) {
            /* `} else {\n`：then 已闭合，续接 else 分支 */
            let else_brace: u8[9] = [125, 32, 101, 108, 115, 101, 32, 123, 10];
            if (emit_bytes_9(out, else_brace, 9) != 0) {
              return -1;
            }
            if (emit_block(arena, out, if_else_r, indent + 2, ctx) != 0) {
              return -1;
            }
            if (emit_indent(out, indent) != 0) {
              return -1;
            }
          }
          let cif: u8[3] = [125, 10, 0];
          if (emit_bytes_3(out, cif, 2) != 0) {
            return -1;
          }
        }
      } else if (k == 6) {
        /** M-3：region 块运行时等价嵌套 { }（零开销域标签）。 */
        if (idx >= 0 && idx < ast.ast_block_num_regions(arena, block_ref)) {
          let reg_body: i32 = ast.ast_block_region_body_ref(arena, block_ref, idx);
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let ob: u8[2] = [123, 10];
          if (emit_bytes_2(out, ob, 2) != 0) {
            return -1;
          }
          if (emit_block(arena, out, reg_body, indent + 2, ctx) != 0) {
            return -1;
          }
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          let cb: u8[3] = [125, 10, 0];
          if (emit_bytes_3(out, cb, 2) != 0) {
            return -1;
          }
        }
      }
      si = si + 1;
    }
    if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
      return -1;
    }
    let final_ref: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
    if (!ast.ref_is_null(final_ref)) {
      /* 块尾已输出 return；若 final_expr 本身是 EXPR_RETURN，emit_expr 会再打 return，剥壳只发 unary 操作数。 */
      let fe_ordered: Expr = ast.ast_arena_expr_get(arena, final_ref);
      if (fe_ordered.kind == ExprKind.EXPR_RETURN) {
        if (emit_return_stmt_with_context(arena, out, indent, fe_ordered.unary_operand_ref, ctx, fn_ret_void) != 0) {
          return -1;
        }
      } else {
        if (emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void) != 0) {
          return -1;
        }
      }
    }
    return 0;
  }
  /* 无 stmt_order 时：先 const、再 let、再 expr_stmts、再 loop/for、最后 final_expr；expr_stmts 先于 loop 保证 parse_into 等「先 collect_imports 再 while」顺序正确。 */
  let i: i32 = 0;
  while (i < ast.ast_block_num_consts(arena, block_ref)) {
    let cname_fb: u8[64] = [];
    pipeline_block_const_name_copy64(arena, block_ref, i, &cname_fb[0]);
    let cname_len_fb: i32 = pipeline_block_const_name_len(arena, block_ref, i);
    let ctype_fb: i32 = pipeline_block_const_type_ref(arena, block_ref, i);
    let cinit_fb: i32 = pipeline_block_const_init_ref(arena, block_ref, i);
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    if (emit_type(arena, out, ctype_fb, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
      return -1;
    }
    let sp: u8[3] = [32, 0, 0];
    if (emit_bytes_3(out, sp, 1) != 0) {
      return -1;
    }
    /* 无名或首字符为空格时用 _c0, _c1, ... 占位。 */
    if (cname_len_fb > 0 && (cname_fb[0] > 32)) {
      if (emit_bytes_64(out, &cname_fb[0], cname_len_fb) != 0) {
        return -1;
      }
    } else {
      let place: u8[4] = [95, 99, 48, 0];
      if (emit_bytes_4(out, place, 2) != 0) {
        return -1;
      }
      if (format_int(out, i) != 0) {
        return -1;
      }
    }
    let eq: u8[4] = [32, 61, 32, 0];
    if (emit_bytes_4(out, eq, 3) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, cinit_fb, ctx) != 0) {
      return -1;
    }
    let sc: u8[3] = [59, 10, 0];
    if (emit_bytes_3(out, sc, 2) != 0) {
      return -1;
    }
    i = i + 1;
  }
  i = 0;
  while (i < ast.ast_block_num_lets(arena, block_ref)) {
    let lname_fb: u8[64] = [];
    pipeline_block_let_name_copy64(arena, block_ref, i, &lname_fb[0]);
    let lname_len_fb: i32 = pipeline_block_let_name_len(arena, block_ref, i);
    let let_type_ref: i32 = pipeline_block_let_type_ref(arena, block_ref, i);
    let linit_fb: i32 = pipeline_block_let_init_ref(arena, block_ref, i);
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    /* T[N] 局部数组用 elem[N]；仅 u8[N] 字面量仍用 uint8_t*。 */
    let type_emitted: i32 = 0;
    let use_local_array: i32 = 0;
    if (!ast.ref_is_null(let_type_ref) && pipeline_type_kind_ord_at(arena, let_type_ref) == 10) {
      use_local_array = 1;
    }
    if (use_local_array != 0) {
      if (emit_local_fixed_array_elem_type(arena, out, let_type_ref, ctx) != 0) {
        return -1;
      }
      type_emitted = 1;
    }
    if (!ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
      let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
      if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_ARRAY_LIT && type_array_elem_is_u8(arena, let_type_ref) != 0) {
        let u8ptr: u8[9] = [117, 105, 110, 116, 56, 95, 116, 32, 0];
        if (emit_bytes_9(out, u8ptr, 7) != 0) {
          return -1;
        }
        if (append_byte(out, 42) != 0) {
          return -1;
        }
        type_emitted = 1;
      }
      if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
        let rt2: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
        if (rt2.kind == TypeKind.TYPE_NAMED && rt2.name_len >= 6) {
          let n02: i32 = rt2.name_len - 6;
          if (rt2.name[n02] == 83 && rt2.name[n02 + 1] == 116 && rt2.name[n02 + 2] == 114 && rt2.name[n02 + 3] == 105 && rt2.name[n02 + 4] == 110 && rt2.name[n02 + 5] == 103) {
            let str_ty2a: u8[8] = [83, 116, 114, 105, 110, 103, 32, 0];
            if (emit_bytes_from_ptr(out, &str_ty2a[0], 6) != 0) {
              return -1;
            }
            if (append_byte(out, 32) != 0) {
              return -1;
            }
            type_emitted = 1;
          }
        }
      }
      if (type_emitted == 0 && init_e.kind == ExprKind.EXPR_CALL && !ast.ref_is_null(init_e.call_callee_ref) && init_e.call_callee_ref > 0 && init_e.call_callee_ref <= arena.num_exprs) {
        let callee_let2: Expr = ast.ast_arena_expr_get(arena, init_e.call_callee_ref);
        if (callee_let2.kind == ExprKind.EXPR_VAR) {
          if (codegen_callee_var_is_string_new(callee_let2) != 0) {
            let str_ty2: u8[8] = [83, 116, 114, 105, 110, 103, 32, 0];
            if (emit_bytes_from_ptr(out, &str_ty2[0], 6) != 0) {
              return -1;
            }
            if (append_byte(out, 32) != 0) {
              return -1;
            }
            type_emitted = 1;
          }
        }
      }
    }
    if (type_emitted == 0) {
      if (ast.ref_is_null(let_type_ref) && !ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
        let init_e: Expr = ast.ast_arena_expr_get(arena, linit_fb);
        if (!ast.ref_is_null(init_e.resolved_type_ref)) {
          let_type_ref = init_e.resolved_type_ref;
        }
      }
      if (emit_type(arena, out, let_type_ref, &blk_prefix[0], blk_prefix_len, ctx) != 0) {
        return -1;
      }
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    /* 无名或首字符为空格时用 _l0, _l1, ... 占位。 */
    if (lname_len_fb > 0 && (lname_fb[0] > 32)) {
      if (emit_bytes_64(out, &lname_fb[0], lname_len_fb) != 0) {
        return -1;
      }
    } else {
      let place: u8[4] = [95, 108, 48, 0];
      if (emit_bytes_4(out, place, 2) != 0) {
        return -1;
      }
      if (format_int(out, i) != 0) {
        return -1;
      }
    }
    if (use_local_array != 0) {
      if (emit_local_fixed_array_suffix(arena, out, let_type_ref) != 0) {
        return -1;
      }
    }
    let eq: u8[4] = [32, 61, 32, 0];
    if (emit_bytes_4(out, eq, 3) != 0) {
      return -1;
    }
    /** let x: T; 无 init：C 零初始化 { 0 }（与 asm 栈 prologue 清零一致）。 */
    if (ast.ref_is_null(linit_fb)) {
      let zinit_omit: u8[6] = [123, 32, 48, 32, 125, 0];
      if (emit_bytes_6(out, zinit_omit, 5) != 0) {
        return -1;
      }
    } else if (use_local_array != 0 && !ast.ref_is_null(linit_fb) && linit_fb > 0 && linit_fb <= arena.num_exprs) {
      let init_e3: Expr = ast.ast_arena_expr_get(arena, linit_fb);
      if (init_e3.kind == ExprKind.EXPR_ARRAY_LIT) {
        if (emit_braced_array_lit_init(arena, out, linit_fb, ctx) != 0) {
          return -1;
        }
      } else if (init_e3.kind == ExprKind.EXPR_LIT && init_e3.int_val == 0) {
        let zinit2: u8[6] = [123, 32, 48, 32, 125, 0];
        if (emit_bytes_6(out, zinit2, 5) != 0) {
          return -1;
        }
      } else {
        if (emit_expr(arena, out, linit_fb, ctx) != 0) {
          return -1;
        }
      }
    } else {
      if (emit_expr(arena, out, linit_fb, ctx) != 0) {
        return -1;
      }
    }
    let sc: u8[3] = [59, 10, 0];
    if (emit_bytes_3(out, sc, 2) != 0) {
      return -1;
    }
    i = i + 1;
  }
  /* expr_stmts 先于 loop/for 输出；若为 EXPR_RETURN 则生成 return expr;\n，否则 (void)(expr);\n（避免 main { return 42; } 被写成 (void)(42); return 0;）。 */
  i = 0;
  while (i < ast.ast_block_num_expr_stmts(arena, block_ref)) {
    let ex_fb: i32 = ast.ast_block_expr_stmt_ref(arena, block_ref, i);
    let st: Expr = ast.ast_arena_expr_get(arena, ex_fb);
    if (st.kind == ExprKind.EXPR_RETURN) {
      if (emit_return_stmt_with_context(arena, out, indent, st.unary_operand_ref, ctx, fn_ret_void) != 0) {
        return -1;
      }
    } else if (st.kind == ExprKind.EXPR_BREAK) {
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
      if (emit_bytes_8(out, br, 7) != 0) {
        return -1;
      }
    } else if (st.kind == ExprKind.EXPR_CONTINUE) {
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
      if (emit_bytes_from_ptr(out, &co[0], 10) != 0) {
        return -1;
      }
    } else {
      if (emit_indent(out, indent) != 0) {
        return -1;
      }
      let v: u8[9] = [40, 118, 111, 105, 100, 41, 40, 0, 0];
      if (emit_bytes_9(out, v, 7) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, ex_fb, ctx) != 0) {
        return -1;
      }
      let sc: u8[4] = [41, 59, 10, 0];
      if (emit_bytes_4(out, sc, 3) != 0) {
        return -1;
      }
    }
    i = i + 1;
  }
  i = 0;
  while (i < ast.ast_block_num_loops(arena, block_ref)) {
    let w_cr: i32 = ast.ast_block_while_cond_ref(arena, block_ref, i);
    let w_br: i32 = ast.ast_block_while_body_ref(arena, block_ref, i);
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let wh: u8[8] = [119, 104, 105, 108, 101, 32, 40, 0];
    if (emit_bytes_8(out, wh, 7) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, w_cr, ctx) != 0) {
      return -1;
    }
    let paren: u8[5] = [41, 32, 123, 10, 0];
    if (emit_bytes_5(out, paren, 4) != 0) {
      return -1;
    }
    if (emit_block(arena, out, w_br, indent + 2, ctx) != 0) {
      return -1;
    }
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let close: u8[3] = [125, 10, 0];
    if (emit_bytes_3(out, close, 2) != 0) {
      return -1;
    }
    i = i + 1;
  }
  i = 0;
  while (i < ast.ast_block_num_for_loops(arena, block_ref)) {
    let fl_ir: i32 = ast.ast_block_for_init_ref(arena, block_ref, i);
    let fl_cr: i32 = ast.ast_block_for_cond_ref(arena, block_ref, i);
    let fl_sr: i32 = ast.ast_block_for_step_ref(arena, block_ref, i);
    let fl_br: i32 = ast.ast_block_for_body_ref(arena, block_ref, i);
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let fk: u8[6] = [102, 111, 114, 32, 40, 0];
    if (emit_bytes_6(out, fk, 5) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(fl_ir)) {
      if (emit_expr(arena, out, fl_ir, ctx) != 0) {
        return -1;
      }
    }
    let sc1: u8[3] = [59, 32, 0];
    if (emit_bytes_3(out, sc1, 2) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(fl_cr)) {
      if (emit_expr(arena, out, fl_cr, ctx) != 0) {
        return -1;
      }
    }
    let sc2: u8[3] = [59, 32, 0];
    if (emit_bytes_3(out, sc2, 2) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(fl_sr)) {
      if (emit_expr(arena, out, fl_sr, ctx) != 0) {
        return -1;
      }
    }
    let paren: u8[5] = [41, 32, 123, 10, 0];
    if (emit_bytes_5(out, paren, 4) != 0) {
      return -1;
    }
    if (!ast.ref_is_null(fl_br) && emit_block(arena, out, fl_br, indent + 2, ctx) != 0) {
      return -1;
    }
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    let close: u8[3] = [125, 10, 0];
    if (emit_bytes_3(out, close, 2) != 0) {
      return -1;
    }
    i = i + 1;
  }
  if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
    return -1;
  }
  /* 函数体块：最终表达式以 return expr;\n 形式输出 */
  let final_ref_plain: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
  if (!ast.ref_is_null(final_ref_plain)) {
    /* 同上：外层已写 return，内层勿再经由 emit_expr(EXPR_RETURN) 重复输出 return。 */
    let fe_plain: Expr = ast.ast_arena_expr_get(arena, final_ref_plain);
    if (fe_plain.kind == ExprKind.EXPR_RETURN) {
      if (emit_return_stmt_with_context(arena, out, indent, fe_plain.unary_operand_ref, ctx, fn_ret_void) != 0) {
        return -1;
      }
    } else {
      if (emit_return_stmt_with_context(arena, out, indent, final_ref_plain, ctx, fn_ret_void) != 0) {
        return -1;
      }
    }
  }
  return 0;
}

/**
 * 【Why 根源】将 src[0..len-1] 拷贝到 dst 并返回 len，供 codegen_type_ref_to_suffix 写基本类型后缀。
 * 【Invariant】dst 须 >= len 字节；不写 NUL（调用方按返回长度使用）。
 */
function emit_suffix_bytes(dst: *u8, src: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    dst[i] = src[i];
    i = i + 1;
  }
  return len;
}

/**
 * 【Why 根源】将类型 ref 写成 mangle 后缀（i32->"i32", *u8->"u8_ptr"），与 codegen.c type_to_suffix 对齐。
 * 【Invariant】buf 须 >= 8 字节；返回写入长度（不含 NUL）；type_ref<=0 时返回 0。
 * 【Asm/Perf】PTR 递归深度 = 指针层数，通常 1-2 层。
 */
function codegen_type_ref_to_suffix(arena: *ASTArena, type_ref: i32, buf: *u8, buf_cap: i32): i32 {
  if (type_ref <= 0 || buf == 0 as *u8 || buf_cap <= 0) {
    return 0;
  }
  let tk: i32 = pipeline_type_kind_ord_at(arena, type_ref);
  /* PTR: 先写元素类型后缀，再追加 "_ptr" */
  if (tk == (TypeKind.TYPE_PTR as i32)) {
    let elem_ref: i32 = pipeline_type_elem_ref_at(arena, type_ref);
    let n: i32 = codegen_type_ref_to_suffix(arena, elem_ref, buf, buf_cap);
    if (n > 0 && n + 4 < buf_cap) {
      buf[n] = 95;
      buf[n + 1] = 112;
      buf[n + 2] = 116;
      buf[n + 3] = 114;
      return n + 4;
    }
    return n;
  }
  /* NAMED: 用类型名 */
  if (tk == (TypeKind.TYPE_NAMED as i32)) {
    let nl: i32 = pipeline_type_named_name_into(arena, type_ref, buf);
    if (nl > 0 && nl < buf_cap) {
      return nl;
    }
    return 0;
  }
  /* 基本类型：i32/i64/u8/u32/u64/f32/f64/bool/usize/isize */
  if (tk == (TypeKind.TYPE_I32 as i32)) {
    let s: u8[4] = [105, 51, 50, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_I64 as i32)) {
    let s: u8[4] = [105, 54, 52, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_U8 as i32)) {
    let s: u8[3] = [117, 56, 0];
    return emit_suffix_bytes(buf, &s[0], 2);
  }
  if (tk == (TypeKind.TYPE_U32 as i32)) {
    let s: u8[4] = [117, 51, 50, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_U64 as i32)) {
    let s: u8[4] = [117, 54, 52, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_F32 as i32)) {
    let s: u8[4] = [102, 51, 50, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_F64 as i32)) {
    let s: u8[4] = [102, 54, 52, 0];
    return emit_suffix_bytes(buf, &s[0], 3);
  }
  if (tk == (TypeKind.TYPE_BOOL as i32)) {
    let s: u8[5] = [98, 111, 111, 108, 0];
    return emit_suffix_bytes(buf, &s[0], 4);
  }
  if (tk == (TypeKind.TYPE_USIZE as i32)) {
    let s: u8[6] = [117, 115, 105, 122, 101, 0];
    return emit_suffix_bytes(buf, &s[0], 5);
  }
  if (tk == (TypeKind.TYPE_ISIZE as i32)) {
    let s: u8[6] = [105, 115, 105, 122, 101, 0];
    return emit_suffix_bytes(buf, &s[0], 5);
  }
  return 0;
}

/**
 * 【Why 根源】统计模块内同名函数个数（>1 时须 mangled C 符号），与 codegen.c module_func_overload_count 对齐。
 * 【Invariant】仅按 name 比较；返回值用于判断是否需 mangle。
 */
function codegen_module_func_overload_count(module: *Module, name_ptr: *u8, name_len: i32): i32 {
  let c: i32 = 0;
  if (module == 0 as *Module || name_ptr == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < module.num_funcs) {
    let fn_len: i32 = pipeline_module_func_name_len_at(module, i);
    if (fn_len == name_len && fn_len > 0) {
      let fn_name: u8[64] = [];
      let matched: i32 = 1;
      let bi: i32 = 0;
      pipeline_module_func_name_copy64(module, i, &fn_name[0]);
      while (bi < fn_len) {
        if (fn_name[bi] != name_ptr[bi]) {
          matched = 0;
          bi = fn_len;
        } else {
          bi = bi + 1;
        }
      }
      if (matched != 0) {
        c = c + 1;
      }
    }
    i = i + 1;
  }
  return c;
}

/**
 * 【Why 根源】比较两个函数的参数签名是否相同（用 type_to_suffix 逐参比较），与 codegen.c func_param_sig_equal 对齐。
 * 【Invariant】参数个数不同直接返回 0；mod_a/fi_a 与 mod_b/fi_b 可指向不同模块（dep 调用场景）。
 */
function codegen_func_param_sig_equal(arena: *ASTArena, mod_a: *Module, fi_a: i32, mod_b: *Module, fi_b: i32): i32 {
  let np_a: i32 = pipeline_module_func_num_params_at(mod_a, fi_a);
  let np_b: i32 = pipeline_module_func_num_params_at(mod_b, fi_b);
  if (np_a != np_b) {
    return 0;
  }
  let pi: i32 = 0;
  while (pi < np_a) {
    let sa: u8[64] = [];
    let sb: u8[64] = [];
    let na: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_a, fi_a, pi), &sa[0], 64);
    let nb: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(mod_b, fi_b, pi), &sb[0], 64);
    if (na != nb) {
      return 0;
    }
    let k: i32 = 0;
    while (k < na) {
      if (sa[k] != sb[k]) {
        return 0;
      }
      k = k + 1;
    }
    pi = pi + 1;
  }
  return 1;
}

/**
 * 【Why 根源】统计模块内与 fi 同名且参数签名相同的函数个数，与 codegen.c module_overload_param_sig_count 对齐。
 * 【Invariant】签名相同个数 >1 时须追加 _ret_<T> 后缀避免链接冲突。
 */
function codegen_module_overload_param_sig_count(arena: *ASTArena, module: *Module, fi: i32): i32 {
  let c: i32 = 0;
  if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
    return 0;
  }
  let fn_local: u8[64] = [];
  codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
  let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
  if (fn_len <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < module.num_funcs) {
    let g_len: i32 = pipeline_module_func_name_len_at(module, i);
    if (g_len == fn_len && g_len > 0) {
      let g_name: u8[64] = [];
      let matched: i32 = 1;
      let bi: i32 = 0;
      pipeline_module_func_name_copy64(module, i, &g_name[0]);
      while (bi < g_len) {
        if (g_name[bi] != fn_local[bi]) {
          matched = 0;
          bi = g_len;
        } else {
          bi = bi + 1;
        }
      }
      if (matched != 0) {
        if (codegen_func_param_sig_equal(arena, module, fi, module, i) != 0) {
          c = c + 1;
        }
      }
    }
    i = i + 1;
  }
  return c;
}

/**
 * 【Why 根源】输出函数的 C 链接符号名：无 overload 时用原名，否则 mangled（name_t1_t2）。
 * 与 codegen.c func_link_name 对齐。#[no_mangle] 函数始终用原名。
 * 【Invariant】须在所有函数符号生成点（定义/声明/CALL）统一调用，保证三者一致。
 * 【Asm/Perf】仅当 overload_count>1 时遍历参数写后缀，单定义函数零开销。
 */
function codegen_emit_func_link_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32): i32 {
  if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
    return -1;
  }
  let fn_local: u8[64] = [];
  codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
  let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
  if (fn_len <= 0) {
    return -1;
  }
  /* #[no_mangle] 用原名 */
  if (pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
    return emit_bytes_64(out, &fn_local[0], fn_len);
  }
  /* 统计同名函数个数 */
  let overload_count: i32 = codegen_module_func_overload_count(module, &fn_local[0], fn_len);
  if (overload_count <= 1) {
    return emit_bytes_64(out, &fn_local[0], fn_len);
  }
  /* 需要 mangle: name_t1_t2... */
  if (emit_bytes_64(out, &fn_local[0], fn_len) != 0) {
    return -1;
  }
  let np: i32 = pipeline_module_func_num_params_at(module, fi);
  let pi: i32 = 0;
  while (pi < np) {
    let suf: u8[64] = [];
    let sl: i32 = codegen_type_ref_to_suffix(arena, pipeline_module_func_param_type_ref_at(module, fi, pi), &suf[0], 64);
    if (sl > 0) {
      if (append_byte(out, 95) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &suf[0], sl) != 0) {
        return -1;
      }
    }
    pi = pi + 1;
  }
  /* 参数签名相同时追加 _ret_<T>（参考 codegen.c line 1063） */
  let sig_count: i32 = codegen_module_overload_param_sig_count(arena, module, fi);
  if (sig_count > 1) {
    let ret_ref: i32 = pipeline_module_func_return_type_at(module, fi);
    let rs: u8[64] = [];
    let rsl: i32 = codegen_type_ref_to_suffix(arena, ret_ref, &rs[0], 64);
    if (rsl > 0) {
      /* "_ret_" */
      let ret_kw: u8[5] = [95, 114, 101, 116, 0];
      if (emit_bytes_from_ptr(out, &ret_kw[0], 4) != 0) {
        return -1;
      }
      if (emit_bytes_from_ptr(out, &rs[0], rsl) != 0) {
        return -1;
      }
    }
  }
  return 0;
}

/**
 * 【Why 根源】CALL 端输出目标函数 C 符号名：typeck 已解析时用 mangled 名，否则回退原名。
 * 【Invariant】resolved_func_index/resolved_dep_index 同时可用时走 mangled 路径，保证与定义/声明一致；
 * 未解析时用 fallback_name（callee.var_name 或 field_access_field_name），保持旧行为不回归。
 */
function codegen_emit_call_func_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, current_module: *Module, fallback_name: *u8, fallback_len: i32): i32 {
  if (ctx != 0 as *PipelineDepCtx && arena != 0 as *ASTArena) {
    let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    if (func_ix >= 0) {
      if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
        if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
          return codegen_emit_func_link_name(out, arena, dep_mod, func_ix);
        }
      } else {
        /* resolved_dep_index < 0：目标为本模块 */
        if (current_module != 0 as *Module && func_ix < current_module.num_funcs) {
          return codegen_emit_func_link_name(out, arena, current_module, func_ix);
        }
      }
    }
  }
  /* 未解析：回退原名 */
  return emit_bytes_from_ptr(out, fallback_name, fallback_len);
}

/**
 * 自举：勿将 module.funcs[fi].name 整 u8[64] 按值传给 emit_bytes_64 或作 *u8 来源传给带名检查的帮助函数（asm 生成路径易成空名）。
 * 逐标量读入局部缓冲区再传递。
 */
function codegen_copy_func_name64_from_module(module: *Module, fi: i32, dst: *u8): void {
  pipeline_module_func_name_copy64(module, fi, dst);
}

/**
 * 形参名 u8[32]：同上，避免按值撕裂。
 */
function codegen_copy_param_name32_from_module(module: *Module, fi: i32, pi: i32, dst: *u8): void {
  pipeline_module_func_param_name_copy32(module, fi, pi, dst);
}

/**
 * 写单个函数到 out：返回类型 + 名称 + (参数) + { 体 }。
 * call_init_globals 非 0 且 is_entry 且 main 时，在函数体开头输出 init_globals();（与 C 流水线一致）。
 */
function emit_func(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, is_entry: bool, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx, call_init_globals: i32): i32 {
  /* 自举：禁止整 Func 按值拷贝；一律 module.funcs[fi]. 访问。 */
  if (fi < 0 || fi >= module.num_funcs) {
    return -1;
  }
  let fn_local: u8[64] = [];
  codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
  let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
  /* K10：#[used] 不被 C 编译器消除，外部链接 */
  if (pipeline_module_func_is_used_at(module, fi) != 0) {
    let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
  }
  /* K3：#[naked] 无 prologue/epilogue */
  if (pipeline_module_func_is_naked_at(module, fi) != 0) {
    let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
  }
  /* K5：#[entry] 入口不返回 */
  if (pipeline_module_func_is_entry_at(module, fi) != 0) {
    let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
  }
  /* A1：#[interrupt] 中断处理 */
  if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
    let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
  }
  if (emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) != 0) {
    return -1;
  }
  if (append_byte(out, 32) != 0) {
    return -1;
  }
  /* 仅当函数名确为 "main"(4 字节) 时输出 C 符号 "main"，避免库模块首函数被误命名为 main 导致链接冲突；库模块加 prefix 避免与 C 关键字（如 register）冲突。
   * 若 is_entry 且名为空（自举路径偶发 name_len 丢失）且本模块仅一函数，仍发射 main，避免生成 int32_t (void) 非法 C。 */
  let main_name: u8[4] = [109, 97, 105, 110];
  let name_is_main: bool = (fn_len == 4 && fn_local[0] == 109 && fn_local[1] == 97 && fn_local[2] == 105 && fn_local[3] == 110);
  /* name_len 与 name64 偶发不一致（如 len=4 但前导为 NUL）：单函数入口仍发 main，避免非法 C 函数名。
   * 勿写 (is_entry && a) || b — X→C 会丢括号变成 is_entry && a || b，语义错误。 */
  let force_entry_main: bool = false;
  if (is_entry && module.num_funcs == 1) {
    if (fn_len <= 0) {
      force_entry_main = true;
    }
    if (fn_local[0] == 0) {
      force_entry_main = true;
    }
  }
  let emit_c_main_symbol: bool = false;
  if (is_entry) {
    if (name_is_main) {
      emit_c_main_symbol = true;
    }
  }
  if (force_entry_main) {
    emit_c_main_symbol = true;
  }
  if (emit_c_main_symbol) {
    if (emit_bytes_4(out, main_name, 4) != 0) {
      return -1;
    }
  } else {
    if (prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, prefix_len, &fn_local[0], fn_len) == 0 && emit_bytes_from_ptr(out, prefix, prefix_len) != 0) {
      return -1;
    }
    /* 重载函数 mangle：同名 >1 时输出 name_t1_t2，与 extern 声明/CALL 三端一致（对齐 codegen.c func_link_name）。 */
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
      let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
      if (emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
        return -1;
      }
    }
  }
  let lpar: u8[2] = [40, 0];
  if (emit_bytes_2(out, lpar, 1) != 0) {
    return -1;
  }
  if (pipeline_module_func_num_params_at(module, fi) == 0) {
    let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
    if (emit_bytes_7(out, v, 4) != 0) {
      return -1;
    }
  } else {
    let p: i32 = 0;
    while (p < pipeline_module_func_num_params_at(module, fi)) {
      if (p > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      /* std.io.driver 的 submit_*_batch_buf 首参 size_t；register/submit_read/submit_write 首参 ptrdiff_t；timeout_ms/nr 为 uint32_t；其余或 int32_t 或自然类型。 */
      if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let size_t_ps: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, size_t_ps, 7) != 0) {
          return -1;
        }
      } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, size_t_buf, 7) != 0) {
          return -1;
        }
      } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {
          return -1;
        }
      } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, u32_buf, 9) != 0) {
          return -1;
        }
      } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
        if (emit_bytes_8(out, i32_str, 7) != 0) {
          return -1;
        }
      } else if (emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      /* 无名或首字符为空格/控制字符时用 _p0, _p1, ... 占位，避免生成非法 C（如 "int32_t   "）。 */
      if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
        let plocal: u8[32] = [];
        codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
        if (plocal[0] > 32 && emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
          return -1;
        }
      } else {
        let place: u8[4] = [95, 112, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        if (format_int(out, p) != 0) {
          return -1;
        }
      }
      p = p + 1;
    }
  }
  let rpar: u8[3] = [41, 32, 0];
  if (emit_bytes_3(out, rpar, 2) != 0) {
    return -1;
  }
  let brace: u8[3] = [123, 10, 0];
  if (emit_bytes_3(out, brace, 2) != 0) {
    return -1;
  }
  /* std.io.driver register/submit_*：首参 ptrdiff_t，函数体直接调 shux_io_*_buf（与 codegen.c 一致）。 */
  if (codegen_try_emit_std_io_driver_buf_body(out, module, fi, prefix, prefix_len) != 0) {
    return 0;
  }
  /* void 函数不可生成「return expr」；仅有 body_expr_ref 时写成表达式语句。 */
  let fn_ret_void: bool = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi)) == (TypeKind.TYPE_VOID as i32);
  /* 入口 main 且 call_init_globals 非 0（确有非 const 顶层 let）时，先调用 init_globals()。
   * 注意：勿写单 if 内 (a && b && (c||d)) — X→C 展开会弄乱 &&/|| 优先级，导致无 init_globals 定义却插入调用。 */
  if (call_init_globals != 0) {
    if (is_entry) {
      if (emit_c_main_symbol) {
        if (emit_indent(out, 2) != 0) {
          return -1;
        }
        let init_globals_call: u8[22] = [105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 41, 59, 10, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_from_ptr(out, &init_globals_call[0], 16) != 0) {
          return -1;
        }
      }
    }
  }
  /* 供 emit_expr 中无名 EXPR_VAR 输出 _pN：恰一个无名形参记 single_empty；多个则按出现顺序用对应 param 下标 _p1,_p2,...。 */
  let saved_empty: i32 = -1;
  let saved_count: i32 = 0;
  let saved_next: i32 = 0;
  if (ctx != 0 as *PipelineDepCtx) {
    pipeline_dep_ctx_empty_param_backup(ctx);
    saved_empty = ctx.current_func_single_empty_param_index;
    saved_count = ctx.current_func_empty_param_count;
    saved_next = ctx.current_emit_empty_var_next_index;
    let empty_count: i32 = 0;
    let empty_idx: i32 = -1;
    let pi: i32 = 0;
    while (pi < pipeline_module_func_num_params_at(module, fi)) {
      if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
        empty_count = empty_count + 1;
        empty_idx = pi;
      }
      pi = pi + 1;
    }
    if (empty_count == 1) {
      ctx.current_func_single_empty_param_index = empty_idx;
      ctx.current_func_empty_param_count = 0;
      ctx.current_emit_empty_var_next_index = 0;
    } else if (empty_count >= 2) {
      ctx.current_func_single_empty_param_index = -1;
      pipeline_dep_ctx_empty_param_reset(ctx);
      ctx.current_func_empty_param_count = empty_count;
      let ei: i32 = 0;
      pi = 0;
      while (pi < pipeline_module_func_num_params_at(module, fi)) {
        if (pipeline_module_func_param_name_len_at(module, fi, pi) <= 0) {
          pipeline_dep_ctx_empty_param_append(ctx, pi);
          ei = ei + 1;
        }
        pi = pi + 1;
      }
      ctx.current_emit_empty_var_next_index = 0;
    } else {
      ctx.current_func_single_empty_param_index = -1;
      ctx.current_func_empty_param_count = 0;
      ctx.current_emit_empty_var_next_index = 0;
    }
  }
  if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
    let saved_block: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx) {
      saved_block = ctx.current_block_ref;
      ctx.current_block_ref = pipeline_module_func_body_ref_at(module, fi);
    }
    if (emit_block(arena, out, pipeline_module_func_body_ref_at(module, fi), 2, ctx) != 0) {
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_block_ref = saved_block;
      }
      return -1;
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_block_ref = saved_block;
    }
  } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
    /* parse_into_buf 的 expr-only 路径：仅有 body_expr_ref 无 body_ref */
    if (fn_ret_void) {
      if (emit_indent(out, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 59) != 0) {
        return -1;
      }
      if (append_byte(out, 10) != 0) {
        return -1;
      }
    } else {
      if (emit_indent(out, 2) != 0) {
        return -1;
      }
      let ret_keyword: u8[9] = [114, 101, 116, 117, 114, 110, 32, 0, 0];
      if (emit_bytes_9(out, ret_keyword, 7) != 0) {
        return -1;
      }
      /* parse_into 表达式体已包 return；若 body_expr_ref 仍为 EXPR_RETURN，避免双层 return。 */
      let body_e: Expr = ast.ast_arena_expr_get(arena, pipeline_module_func_body_expr_ref_at(module, fi));
      if (body_e.kind == ExprKind.EXPR_RETURN) {
        if (!ast.ref_is_null(body_e.unary_operand_ref) && emit_expr(arena, out, body_e.unary_operand_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (emit_expr(arena, out, pipeline_module_func_body_expr_ref_at(module, fi), ctx) != 0) {
          return -1;
        }
      }
      if (append_byte(out, 59) != 0) {
        return -1;
      }
      if (append_byte(out, 10) != 0) {
        return -1;
      }
    }
  }
  if (ctx != 0 as *PipelineDepCtx) {
    ctx.current_func_single_empty_param_index = saved_empty;
    ctx.current_func_empty_param_count = saved_count;
    ctx.current_emit_empty_var_next_index = saved_next;
    pipeline_dep_ctx_empty_param_restore(ctx);
  }
  /* 仅非 void 函数在块体无 final_expr 且无 expr_stmt 为 return 时补 "  return 0;\n"。
   * void 函数自然落到结尾即合法，避免 bootstrap 同步不稳时误发射 `return 0;`。 */
  let need_fallback_return: bool = true;
  if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
    need_fallback_return = false;
  }
  if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
    let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
    if (!ast.ref_is_null(ast.ast_block_final_expr_ref(arena, body_br))) {
      need_fallback_return = false;
    }
    let ji: i32 = 0;
    let nes: i32 = ast.ast_block_num_expr_stmts(arena, body_br);
    while (ji < nes) {
      let se: Expr = ast.ast_arena_expr_get(arena, ast.ast_block_expr_stmt_ref(arena, body_br, ji));
      if (se.kind == ExprKind.EXPR_RETURN) {
        need_fallback_return = false;
        break;
      }
      ji = ji + 1;
    }
  }
  if (fn_ret_void) {
    need_fallback_return = false;
  }
  if (need_fallback_return) {
    if (emit_indent(out, 2) != 0) {
      return -1;
    }
    let ret0: u8[9] = [114, 101, 116, 117, 114, 110, 32, 48, 59];
    if (emit_bytes_9(out, ret0, 9) != 0) {
      return -1;
    }
    if (append_byte(out, 10) != 0) {
      return -1;
    }
  }
  let close: u8[3] = [125, 10, 0];
  if (emit_bytes_3(out, close, 2) != 0) {
    return -1;
  }
  return 0;
}

/**
 * 为 is_extern 函数发射一行 C extern 原型（与同模块 CALL、emit_func 的符号名与形参 ABI 一致）。
 * 不产出函数体：定义在其它编译单元或由链接库提供；-E-extern / 单片 C 时需此声明才可编译。
 */
function emit_func_extern_declaration(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  /* 自举：经 module.funcs[fi] 逐字段读，避免整 Func 按值拷贝截断。 */
  if (fi < 0 || fi >= module.num_funcs) {
    return -1;
  }
  let fn_local: u8[64] = [];
  codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
  let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
  /* "extern " */
  let kw: u8[8] = [101, 120, 116, 101, 114, 110, 32, 0];
  if (emit_bytes_from_ptr(out, &kw[0], 7) != 0) {
    return -1;
  }
  /* K10：#[used] 不被 C 编译器消除，外部链接 */
  if (pipeline_module_func_is_used_at(module, fi) != 0) {
    let used_attr: u8[27] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 117, 115, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &used_attr[0], 22) != 0) { return -1; }
  }
  /* K3：#[naked] 无 prologue/epilogue */
  if (pipeline_module_func_is_naked_at(module, fi) != 0) {
    let naked_attr: u8[29] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 97, 107, 101, 100, 41, 41, 32, 0, 0, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &naked_attr[0], 23) != 0) { return -1; }
  }
  /* K5：#[entry] 入口不返回 */
  if (pipeline_module_func_is_entry_at(module, fi) != 0) {
    let entry_attr: u8[30] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 110, 111, 114, 101, 116, 117, 114, 110, 41, 41, 32, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &entry_attr[0], 26) != 0) { return -1; }
  }
  /* A1：#[interrupt] 中断处理 */
  if (pipeline_module_func_is_interrupt_at(module, fi) != 0) {
    let int_attr: u8[31] = [95, 95, 97, 116, 116, 114, 105, 98, 117, 116, 101, 95, 95, 40, 40, 105, 110, 116, 101, 114, 114, 117, 112, 116, 41, 41, 32, 0, 0, 0, 0];
    if (emit_bytes_from_ptr(out, &int_attr[0], 27) != 0) { return -1; }
  }
  if (emit_type(arena, out, pipeline_module_func_return_type_at(module, fi), prefix, prefix_len, ctx) != 0) {
    return -1;
  }
  if (append_byte(out, 32) != 0) {
    return -1;
  }
  /* 声明阶段不把库符号写成特殊入口名 main（与对本模块函数的 CALL 前缀规则一致）。 */
  /* 【Why extern 裸名】extern function 符号由外部链接库提供（如 freestanding_io_x86_64.s），
     须用裸名（shux_sys_mmap），不加 dep 前缀（std_sys_linux_shux_sys_mmap 会导致链接失败）。
     类型 emit 仍用 prefix_len 以支持 dep 模块自定义类型参数。
     【Invariant】name_prefix_len 仅影响函数名 emit，不影响返回类型/参数类型的 prefix 传递。 */
  let name_prefix_len: i32 = prefix_len;
  if (pipeline_module_func_is_extern_at(module, fi) != 0) {
    name_prefix_len = 0;
  }
  if (name_prefix_len > 0 && codegen_c_prefix_redundant_with_name(prefix, name_prefix_len, &fn_local[0], fn_len) == 0 && emit_bytes_from_ptr(out, prefix, name_prefix_len) != 0) {
    return -1;
  }
  /* 重载函数 mangle：与 emit_func 定义端一致，避免 extern 声明同名冲突（conflicting types）。 */
  if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
    return -1;
  }
  if (codegen_std_io_fixed_fd_emit_impl(prefix, prefix_len, &fn_local[0], fn_len) != 0) {
    let impl_suffix: u8[6] = [95, 105, 109, 112, 108, 0];
    if (emit_bytes_from_ptr(out, &impl_suffix[0], 5) != 0) {
      return -1;
    }
  }
  let lpar: u8[2] = [40, 0];
  if (emit_bytes_2(out, lpar, 1) != 0) {
    return -1;
  }
  if (pipeline_module_func_num_params_at(module, fi) == 0) {
    let v: u8[7] = [118, 111, 105, 100, 0, 0, 0];
    if (emit_bytes_7(out, v, 4) != 0) {
      return -1;
    }
  } else {
    let p: i32 = 0;
    while (p < pipeline_module_func_num_params_at(module, fi)) {
      if (p > 0) {
        let comma: u8[3] = [44, 32, 0];
        if (emit_bytes_3(out, comma, 2) != 0) {
          return -1;
        }
      }
      if (codegen_force_param_size_t_std_io_print_str_second(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let size_t_buf2: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, size_t_buf2, 7) != 0) {
          return -1;
        }
      } else if (codegen_force_param_size_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let size_t_buf: u8[32] = [115, 105, 122, 101, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, size_t_buf, 7) != 0) {
          return -1;
        }
      } else if (codegen_force_param_ptrdiff_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let ptrdiff_t_buf: u8[32] = [112, 116, 114, 100, 105, 102, 102, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, ptrdiff_t_buf, 10) != 0) {
          return -1;
        }
      } else if (codegen_force_param_uint32_t(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let u32_buf: u8[32] = [117, 105, 110, 116, 51, 50, 95, 116, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        if (emit_bytes_32(out, u32_buf, 9) != 0) {
          return -1;
        }
      } else if (codegen_force_param_i32(prefix, prefix_len, &fn_local[0], fn_len, p) != 0) {
        let i32_str: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
        if (emit_bytes_8(out, i32_str, 7) != 0) {
          return -1;
        }
      } else if (emit_type(arena, out, pipeline_module_func_param_type_ref_at(module, fi, p), prefix, prefix_len, ctx) != 0) {
        return -1;
      }
      if (append_byte(out, 32) != 0) {
        return -1;
      }
      if (pipeline_module_func_param_name_len_at(module, fi, p) > 0) {
        let plocal: u8[32] = [];
        codegen_copy_param_name32_from_module(module, fi, p, &plocal[0]);
        if (plocal[0] > 32 && emit_bytes_32(out, plocal, pipeline_module_func_param_name_len_at(module, fi, p)) != 0) {
          return -1;
        }
      } else {
        let place: u8[4] = [95, 112, 48, 0];
        if (emit_bytes_4(out, place, 2) != 0) {
          return -1;
        }
        if (format_int(out, p) != 0) {
          return -1;
        }
      }
      p = p + 1;
    }
  }
  let end_proto: u8[3] = [41, 59, 10];
  if (emit_bytes_from_ptr(out, &end_proto[0], 3) != 0) {
    return -1;
  }
  return 0;
}

/**
 * 为当前模块直接 import 的 dep 预发函数原型。
 * 单文件/partial bootstrap 时，某些被跳过或未 co-emit 的 dep 仍会被调用；先补 extern，避免 C99 隐式声明报错。
 */
function codegen_emit_import_dep_function_declarations(module: *Module, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  if (module == 0 as *Module || out == 0 as *CodegenOutBuf || ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  let saved_module: *Module = ctx.current_codegen_module;
  let saved_arena: *ASTArena = ctx.current_codegen_arena;
  let saved_dep_index: i32 = ctx.current_codegen_dep_index;
  let saved_prefix_len: i32 = ctx.current_codegen_prefix_len;
  let saved_prefix: u8[64] = [];
  let sp: i32 = 0;
  while (sp < 64) {
    saved_prefix[sp] = ctx.current_codegen_prefix_mirror[sp];
    sp = sp + 1;
  }
  let n_imp: i32 = codegen_module_num_imports(module);
  let imp_i: i32 = 0;
  while (imp_i < n_imp) {
    let dep_path: u8[64] = [];
    let dep_path_len: i32 = codegen_module_import_path_len_at(module, imp_i, &dep_path[0]);
    if (dep_path_len > 0) {
      let seen_before: i32 = 0;
      let prev_i: i32 = 0;
      while (prev_i < imp_i) {
        let prev_path: u8[64] = [];
        let prev_len: i32 = codegen_module_import_path_len_at(module, prev_i, &prev_path[0]);
        if (prev_len == dep_path_len) {
          let eq_prev: bool = true;
          let pk: i32 = 0;
          while (pk < dep_path_len && pk < 64) {
            if (prev_path[pk] != dep_path[pk]) {
              eq_prev = false;
              break;
            }
            pk = pk + 1;
          }
          if (eq_prev) {
            seen_before = 1;
            break;
          }
        }
        prev_i = prev_i + 1;
      }
      if (seen_before == 0) {
        let dep_ix: i32 = codegen_find_dep_index_by_path(ctx, &dep_path[0], dep_path_len);
        let dep_mod: *Module = 0 as *Module;
        let dep_arena: *ASTArena = 0 as *ASTArena;
        let dep_ctx_ix: i32 = dep_ix;
        if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
          dep_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
          dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
        }
        if ((dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena) && dep_path_len > 0) {
          let global_slot: i32 = codegen_find_seeded_global_dep_slot_by_path(&dep_path[0], dep_path_len);
          if (global_slot >= 0) {
            dep_mod = driver_dep_module_buf(global_slot) as *Module;
            dep_arena = driver_dep_arena_buf(global_slot) as *ASTArena;
            dep_ctx_ix = -1;
          }
        }
        if (dep_mod != 0 as *Module && dep_arena != 0 as *ASTArena && dep_mod.num_funcs > 0) {
            let prefix_buf: u8[128] = [];
            let prefix_len: i32 = 0;
            if (codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
              codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
              while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
                prefix_len = prefix_len + 1;
              }
            }
            ctx.current_codegen_module = dep_mod;
            ctx.current_codegen_arena = dep_arena;
            ctx.current_codegen_dep_index = dep_ctx_ix;
            ctx.current_codegen_prefix_len = 0;
            let px: i32 = 0;
            while (px < prefix_len && px < 63) {
              ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
              px = px + 1;
            }
            ctx.current_codegen_prefix_mirror[px] = 0 as u8;
            ctx.current_codegen_prefix_len = px;
            let fi: i32 = 0;
            while (fi < dep_mod.num_funcs) {
              if (emit_func_extern_declaration(dep_arena, out, dep_mod, fi, &prefix_buf[0], prefix_len, ctx) != 0) {
                return -1;
              }
              fi = fi + 1;
            }
        }
      }
    }
    imp_i = imp_i + 1;
  }
  ctx.current_codegen_module = saved_module;
  ctx.current_codegen_arena = saved_arena;
  ctx.current_codegen_dep_index = saved_dep_index;
  ctx.current_codegen_prefix_len = saved_prefix_len;
  sp = 0;
  while (sp < 64) {
    ctx.current_codegen_prefix_mirror[sp] = saved_prefix[sp];
    sp = sp + 1;
  }
  return 0;
}

/** 仅写 C 头（#include <stdint.h>\\n#include <stddef.h>\\n）到 out。拆成独立函数避免 C 代码生成时被重排到 while/return 之后。 */
function codegen_x_ast_emit_header(out: *CodegenOutBuf): i32 {
  let h: u8[64] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10,
    35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  return emit_bytes_64(out, &h[0], 40);
}

/**
 * 将 Module 生成 C 源码写入 out。
 * 先写 #include <stdint.h> 等头，再写各函数定义。
 * ctx 供跨 dep 调用时解析 C 符号前缀。
 * dep_index >= 0 表示当前为第 dep_index 个 dep，用 dep 池 import 路径算 C 前缀；-1 表示主模块。
 * 返回 0 成功，-1 失败。
 */
function codegen_x_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_index: i32): i32 {
  /* 供 CALL 未在 dep 解析时判断是否本模块函数并加当前 C 前缀 */
  if (ctx != 0 as *PipelineDepCtx) {
    ctx.current_codegen_module = module;
    ctx.current_codegen_arena = arena;
    ctx.current_codegen_dep_index = dep_index;
  }
  /* 库模块（dep）时用 dep_index 取路径算 C 前缀，用于函数名加前缀避免与 C 关键字冲突 */
  let prefix_buf: u8[128] = [];
  let prefix_len: i32 = 0;
  let dep_path_prefix: u8[64] = [];
  let dep_path_prefix_len: i32 = 0;
  if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx) {
    dep_path_prefix_len = codegen_dep_import_path_len_at(ctx, dep_index, &dep_path_prefix[0]);
  }
  if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
    /* std.io.core 不加前缀，生成 shux_io_register 等符号，与 prepend 的 #define std_io_core_* 一致。 */
    if (codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0) {
      codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
      while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
        prefix_len = prefix_len + 1;
      }
    }
  }
  /* std.io.core 已在上方保持 prefix_len=0；前缀仍为空时用 dep 池路径经 codegen_import_path_to_c_prefix_into 填满（入口 dep_index<0 时路径空则保持无前缀）。 */
  if (prefix_len == 0 && (dep_index < 0 || dep_path_prefix_len == 0 || codegen_path_is_std_io_core_bytes(&dep_path_prefix[0]) == 0)) {
    prefix_len = 0;
    prefix_buf[0] = 0 as u8;
    if (dep_path_prefix_len > 0) {
      codegen_import_path_to_c_prefix_into(&dep_path_prefix[0], &prefix_buf[0], 128);
      while (prefix_len < 128 && prefix_buf[prefix_len] != 0) {
        prefix_len = prefix_len + 1;
      }
    }
  }
  if (ctx != 0 as *PipelineDepCtx) {
    ctx.current_codegen_prefix_len = 0;
    let px: i32 = 0;
    while (px < prefix_len && px < 63) {
      ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
      px = px + 1;
    }
    ctx.current_codegen_prefix_mirror[px] = 0 as u8;
    ctx.current_codegen_prefix_len = px;
  }
  /* dep 模块 const 也需 emit：dep 模块函数体通过 EXPR_VAR 裸名引用同模块 const，
   * 故 const 定义亦以裸名 emit（与 EXPR_VAR 一致），不加 dep 前缀。
   * 入口模块与 dep 模块均可能含非 const let → 生成 init_globals()；但 dep 模块
   * 入口函数非 main，不会调用其 init_globals（仅入口模块 main 调用），故 dep 模块
   * 若有 let 需后续另行处理（当前 freestanding gate dep 模块均纯 const，无此问题）。 */
  let call_init_globals: i32 = 0;
  if (module.num_top_level_lets > 0) {
    let ti: i32 = 0;
    while (ti < module.num_top_level_lets) {
      if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
        call_init_globals = 1;
        break;
      }
      ti = ti + 1;
    }
  }
  let i: i32 = 0;
  while (i < module.num_funcs) {
    if (i == 0) {
      /* 入口模块且存在 dep 时，print_str 可能由兜底生成 std_io_print_str，需 extern 声明（std.io 中为 extern 不生成定义）。 */
      /* std.io 已由 dep codegen 内联 print_str 等，不再为入口补 extern 以免与定义冲突。 */
      if (codegen_x_ast_emit_header(out) != 0) {
        return -1;
      }
      /* 用户 struct 完整定义须在任意函数/全局使用该类型之前（否则 cc 报不完整类型）。 */
      if (dep_index < 0 && codegen_emit_skipped_dep_type_definitions(ctx, out) != 0) {
        return -1;
      }
      if (codegen_emit_import_dep_function_declarations(module, out, ctx) != 0) {
        return -1;
      }
      if (codegen_emit_module_struct_definitions(module, arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
        return -1;
      }
      /* 顶层 let/const（入口与 dep 模块均 emit）：dep 模块 const 以裸名 emit 供本模块
       * 函数体 EXPR_VAR 裸名引用；入口模块 main 调用 init_globals()，dep 模块不调用。 */
      if (module.num_top_level_lets > 0) {
        let ti: i32 = 0;
        while (ti < module.num_top_level_lets) {
          let is_const: i32 = pipeline_module_top_level_let_is_const(module, ti);
          let name_len: i32 = pipeline_module_top_level_let_name_len(module, ti);
          if (name_len <= 0 || name_len > 63) {
            ti = ti + 1;
            continue;
          }
          let tl_name_buf: u8[64] = [];
          let tni: i32 = 0;
          while (tni < name_len && tni < 64) {
            tl_name_buf[tni] = pipeline_module_top_level_let_name_byte_at(module, ti, tni);
            tni = tni + 1;
          }
          if (is_const != 0) {
            let static_const: u8[15] = [115, 116, 97, 116, 105, 99, 32, 99, 111, 110, 115, 116, 32, 0, 0];
            if (emit_bytes_from_ptr(out, &static_const[0], 13) != 0) {
              return -1;
            }
          } else {
            let static_: u8[9] = [115, 116, 97, 116, 105, 99, 32, 0, 0];
            if (emit_bytes_from_ptr(out, &static_[0], 7) != 0) {
              return -1;
            }
          }
          if (emit_type(arena, out, pipeline_module_top_level_let_type_ref(module, ti), &prefix_buf[0], 0, ctx) != 0) {
            return -1;
          }
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
            return -1;
          }
          if (is_const != 0 && !ast.ref_is_null(pipeline_module_top_level_let_init_ref(module, ti))) {
            let eq: u8[4] = [32, 61, 32, 0];
            if (emit_bytes_4(out, eq, 3) != 0) {
              return -1;
            }
            if (emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) != 0) {
              return -1;
            }
          }
          let sc: u8[3] = [59, 10, 0];
          if (emit_bytes_3(out, sc, 2) != 0) {
            return -1;
          }
          ti = ti + 1;
        }
        let any_let: i32 = 0;
        ti = 0;
        while (ti < module.num_top_level_lets) {
          if (pipeline_module_top_level_let_is_const(module, ti) == 0) {
            any_let = 1;
            break;
          }
          ti = ti + 1;
        }
        if (any_let != 0) {
          /* static void init_globals(void) {\n */
          let init_globals_def: u8[32] = [115, 116, 97, 116, 105, 99, 32, 118, 111, 105, 100, 32, 105, 110, 105, 116, 95, 103, 108, 111, 98, 97, 108, 115, 40, 118, 111, 105, 100, 41, 32, 0];
          /* 31 字节：`static void init_globals(void) `（含闭合 ) 与尾空格），少 2 字节会生成 `void {` 非法 C */
          if (emit_bytes_from_ptr(out, &init_globals_def[0], 31) != 0) {
            return -1;
          }
          let brace3: u8[3] = [123, 10, 0];
          if (emit_bytes_3(out, brace3, 2) != 0) {
            return -1;
          }
          ti = 0;
          while (ti < module.num_top_level_lets) {
            if (pipeline_module_top_level_let_is_const(module, ti) != 0) {
              ti = ti + 1;
              continue;
            }
            if (emit_indent(out, 2) != 0) {
              return -1;
            }
            let nlen: i32 = pipeline_module_top_level_let_name_len(module, ti);
            if (nlen > 0 && nlen <= 63) {
              let tl_init_name: u8[64] = [];
              let tni2: i32 = 0;
              while (tni2 < nlen && tni2 < 64) {
                tl_init_name[tni2] = pipeline_module_top_level_let_name_byte_at(module, ti, tni2);
                tni2 = tni2 + 1;
              }
              if (emit_bytes_from_ptr(out, &tl_init_name[0], nlen) != 0) {
                return -1;
              }
            }
            let eq2: u8[4] = [32, 61, 32, 0];
            if (emit_bytes_4(out, eq2, 3) != 0) {
              return -1;
            }
            if (!ast.ref_is_null(pipeline_module_top_level_let_init_ref(module, ti)) && emit_expr(arena, out, pipeline_module_top_level_let_init_ref(module, ti), ctx) != 0) {
              return -1;
            }
            let sc2: u8[3] = [59, 10, 0];
            if (emit_bytes_3(out, sc2, 2) != 0) {
              return -1;
            }
            ti = ti + 1;
          }
          let close_brace: u8[3] = [125, 10, 0];
          if (emit_bytes_3(out, close_brace, 2) != 0) {
            return -1;
          }
        }
      }
    }
    /* 自举：按名跳过检测勿直接传 module.funcs[i].name 作 *u8（易空）。 */
    let skip_name: u8[64] = [];
    codegen_copy_func_name64_from_module(module, i, &skip_name[0]);
    let skip_nl: i32 = pipeline_module_func_name_len_at(module, i);
    /* is_extern：不生成定义，但发射 extern 原型，与同模块生成的调用站点符号一致（可省手写 *_extern.h）。 */
    if (pipeline_module_func_is_extern_at(module, i) != 0) {
      if (emit_func_extern_declaration(arena, out, module, i, &prefix_buf[0], prefix_len, ctx) != 0) {
        return -1;
      }
      i = i + 1;
      continue;
    }
    /* std.io.driver 的 driver_read_ptr_len/driver_read_ptr 跳过生成；std.io.core 的 shux_io_read_ptr_len/shux_io_read_ptr 由 io.o 提供也跳过；submit_*_batch_buf 按名跳过。
     * -backend asm：无 C preamble 宏桥接到 io.o，须照常发射上述包装函数体，否则 Mach-O 残留 UNDEF（如 _driver_read_ptr/_submit_read）。io.o 仍提供 *_read_fixed 等底层实现符号。 */
    let skip: i32 = 0;
    let asm_backend: i32 = 0;
    if (ctx != 0 as *PipelineDepCtx && ctx.use_asm_backend != 0) {
      asm_backend = 1;
    }
    skip = codegen_should_skip_emit_func_by_name(&skip_name[0], skip_nl);
    if (skip == 0 && prefix_len == 0 && asm_backend == 0) {
      skip = codegen_should_skip_emit_func_core_read_ptr(&skip_name[0], skip_nl);
    }
    if (skip == 0 && prefix_len > 0 && asm_backend == 0) {
      skip = codegen_should_skip_emit_func(0 as *u8, &prefix_buf[0], prefix_len, &skip_name[0], skip_nl);
    }
    if (skip == 0 && dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0 && asm_backend == 0) {
      skip = codegen_should_skip_emit_func(&dep_path_prefix[0], 0 as *u8, 0, &skip_name[0], skip_nl);
    }
    if (skip == 0 && asm_backend == 0) {
      let skip_dep: *u8 = 0 as *u8;
      if (dep_index >= 0 && ctx != 0 as *PipelineDepCtx && dep_path_prefix_len > 0) {
        skip_dep = &dep_path_prefix[0];
      }
      if (skip_dep == 0 as *u8) {
        skip_dep = driver_get_current_dep_path_for_codegen();
      }
      skip = codegen_should_skip_emit_func(skip_dep, 0 as *u8, 0, &skip_name[0], skip_nl);
    }
    if (skip != 0) {
      i = i + 1;
      continue;
    }
    /* 入口函数（main_idx）或单函数时输出 main；多函数时仅 main_idx 对应函数输出 main */
    let is_entry: bool = (i == module.main_func_index) || (module.num_funcs == 1);
    let saved_func_idx: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      saved_func_idx = ctx.current_func_index;
      ctx.current_func_index = i;
    }
    if (emit_func(arena, out, module, i, is_entry, &prefix_buf[0], prefix_len, ctx, call_init_globals) != 0) {
      driver_diagnostic_codegen_emit_func_fail(module, i);
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_func_index = saved_func_idx;
      }
      return -1;
    }
    if (ctx != 0 as *PipelineDepCtx) {
      ctx.current_func_index = saved_func_idx;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * 仅按函数名跳过发射：与 preamble / string.o 冲突的占位符与 string_new 族；逻辑由原 driver_should_skip_emit_func_by_name 迁入 .x。
 */
function codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  let ph11: u8[11] = [112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114];
  let ssp22: u8[22] = [115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 112, 108, 97, 99, 101, 104, 111, 108, 100, 101, 114];
  let sn10: u8[10] = [115, 116, 114, 105, 110, 103, 95, 110, 101, 119];
  let sssn22: u8[22] = [115, 116, 100, 95, 115, 116, 114, 105, 110, 103, 95, 115, 116, 114, 105, 110, 103, 95, 110, 101, 119, 0];
  let asm_seed_mega: u8[25] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
  let asm_to_elf_seed_mega: u8[32] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &ph11[0], 11) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &ssp22[0], 22) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_name_bytes_prefix_eq(name, name_len, &sn10[0], 10) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &sssn22[0], 22) != 0) {
    return 1;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &sssn22[0], 21) != 0) {
    return 1;
  }
  /** bootstrap -E：seed_mega 体过大，X emit_func 失败；SHUX_EMIT_SEED_MEGA=1 时 build_seed_asm_host 仍尝试 emit。 */
  if (pipeline_codegen_emit_seed_mega_enabled() == 0) {
    if (name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, &asm_seed_mega[0], 25) != 0) {
      return 1;
    }
    if (name_len == 32 && codegen_name_bytes_prefix_eq(name, name_len, &asm_to_elf_seed_mega[0], 32) != 0) {
      return 1;
    }
  }
  return 0;
}

/**
 * 判断是否为 submit_*_batch_buf：3 参调用处需补第 4 参 timeout_ms；原 driver_is_submit_batch_buf_call。
 */
function codegen_is_submit_batch_buf_call(name: *u8, name_len: i32): i32 {
  let rd_batch: u8[21] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  let wr_batch: u8[22] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 97, 116, 99, 104, 95, 98, 117, 102];
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len == 21 && codegen_name_bytes_prefix_eq(name, name_len, &rd_batch[0], 21) != 0) {
    return 1;
  }
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &wr_batch[0], 22) != 0) {
    return 1;
  }
  return 0;
}

/**
 * 生成函数定义时是否强制 int32_t：preamble 已由 ptrdiff_t/uint32_t 等覆盖，恒为 0；原 driver_force_param_i32。
 */
function codegen_force_param_i32(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
  /* 保留参数以匹配 emit_func 等调用处；与 runtime.c 一致始终返回 0。 */
  return 0;
}

/**
 * std.io.core 中由 runtime preamble / io 后端提供的 ABI 桥接名：不发射 C 函数体。
 * 跳过 shux_io_read_ptr_len / shux_io_read_ptr（read_ptr_len 允许 name_len>19 仅前缀匹配；原 driver_should_skip_emit_func_core_read_ptr），
 * 以及 shux_io_register、shux_io_register_buffers、shux_io_unregister_buffers、shux_io_wait_readable（与 read_ptr 同策略，标识符按完整长度逐字节比对）。
 */
function codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  let shu_len19: u8[19] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let shu15: u8[15] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* shux_io_register — 15 字节，与 shux_io_read_ptr 同长不同后缀，单独逐字节匹配。 */
  let shu_reg15: u8[15] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114];
  /* shux_io_register_buffers — 23 字节。 */
  let shu_reg_bufs23: u8[23] = [115, 104, 117, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102, 102, 101, 114, 115];
  /* shux_io_unregister_buffers — 25 字节。 */
  let shu_unreg_bufs25: u8[25] = [115, 104, 117, 95, 105, 111, 95, 117, 110, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102, 102, 101, 114, 115];
  /* shux_io_wait_readable — 20 字节。 */
  let shu_wait_rd20: u8[20] = [115, 104, 117, 95, 105, 111, 95, 119, 97, 105, 116, 95, 114, 101, 97, 100, 97, 98, 108, 101];
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len >= 19 && codegen_name_bytes_prefix_eq(name, name_len, &shu_len19[0], 19) != 0) {
    return 1;
  }
  if (name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, &shu15[0], 15) != 0) {
    return 1;
  }
  if (name_len == 15 && codegen_name_bytes_prefix_eq(name, name_len, &shu_reg15[0], 15) != 0) {
    return 1;
  }
  if (name_len == 23 && codegen_name_bytes_prefix_eq(name, name_len, &shu_reg_bufs23[0], 23) != 0) {
    return 1;
  }
  if (name_len == 25 && codegen_name_bytes_prefix_eq(name, name_len, &shu_unreg_bufs25[0], 25) != 0) {
    return 1;
  }
  if (name_len == 20 && codegen_name_bytes_prefix_eq(name, name_len, &shu_wait_rd20[0], 20) != 0) {
    return 1;
  }
  return 0;
}

/**
 * std.io 的 read_fixed_fd/write_fixed_fd 须生成为 std_io_*_impl；prefix 前 7 字节须为 std_io_；与 runtime.c strncmp 长度一致（12/13 字节前缀）；原 driver_std_io_fixed_fd_emit_impl。
 */
function codegen_std_io_fixed_fd_emit_impl(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  let pre7: u8[7] = [115, 116, 100, 95, 105, 111, 95];
  /* read_fixed_fd / write_fixed_fd 全名 13/14 字节；与 runtime.c driver_std_io_fixed_fd_emit_impl 一致。 */
  let rd13: u8[13] = [114, 101, 97, 100, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  let wr14: u8[14] = [119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100, 95, 102, 100];
  if (prefix == 0 as *u8 || name == 0 as *u8 || prefix_len < 7 || name_len <= 0) {
    return 0;
  }
  if (codegen_name_bytes_prefix_eq(prefix, prefix_len, &pre7[0], 7) == 0) {
    return 0;
  }
  if (name_len >= 13 && codegen_name_bytes_prefix_eq(name, name_len, &rd13[0], 13) != 0) {
    return 1;
  }
  if (name_len >= 14 && codegen_name_bytes_prefix_eq(name, name_len, &wr14[0], 14) != 0) {
    return 1;
  }
  return 0;
}
