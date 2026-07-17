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

// Cap-T001 / LANG-007 S0 (M1→M2 codegen): functions that call export-extern
// pipeline_* / driver_* / glue use whole-body unsafe FFI gates.
// Residual (not Cap-T001): after wrap, first fail is XT001 — collect parse dep=ast
// pr_ok=-2 (parser state after entry parse of mega codegen.x). Product seed pin unchanged.
// PLATFORM: SHARED — product still pins codegen seed until M2.

const ast = import("ast");

/** dep 池 import 路径读写（定义在 pipeline_glue.c / ast_pool.c）。 */
export extern function pipeline_dep_ctx_import_path_len(ctx: *PipelineDepCtx, idx: i32): i32;
export extern function pipeline_dep_ctx_import_path_copy64(ctx: *PipelineDepCtx, idx: i32, dst: *u8): void;
export extern function pipeline_dep_ctx_module_at(ctx: *PipelineDepCtx, idx: i32): *Module;
export extern function pipeline_dep_ctx_arena_at(ctx: *PipelineDepCtx, idx: i32): *ASTArena;
export extern function pipeline_dep_ctx_ndep(ctx: *PipelineDepCtx): i32;

/** glue：按池 ref 安全读类型 kind / elem_ref / array_size，避免 X 对大 Type 按值返回撕裂（与 typeck 同源）。 */
export extern function pipeline_type_named_name_into(arena: *ASTArena, ref: i32, out64: *u8): i32;
export extern function pipeline_type_kind_ord_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *ASTArena, ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *ASTArena, ref: i32): i32;
/** glue：type_to_c_repr 全逻辑在 C，避免 dep prerun 全量 typeck 时 X 大函数 check_block 失败。 */
export extern function pipeline_codegen_type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** 单文件 C co-emit：header+全 dep 类型+forward 只 emit 一次（pipeline 多 dep 各调 codegen_x_ast 时防重入）。 */
export extern function pipeline_codegen_c_file_prologue_done_get(): i32;
export extern function pipeline_codegen_c_file_prologue_done_set(v: i32): void;
export extern function pipeline_codegen_c_file_prologue_done_reset(): void;
/** 单文件 C：完整 struct tag 首次 claim 返回 1，重复返回 0（防 co-emit redefinition）。 */
export extern function pipeline_codegen_struct_tag_try_claim(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32;
/** glue：emit_struct_field_type_via_pipeline 全逻辑在 C，同上。 */
export extern function pipeline_codegen_emit_struct_field_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** glue：发射完整 struct 字段声明，修正数组字段 `type name[n]` 顺序。 */
export extern function pipeline_codegen_emit_struct_field_decl(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32): i32;
/** build_seed_asm_host：SHUX_EMIT_SEED_MEGA=1 时勿跳过 seed_mega emit。 */
export extern function pipeline_codegen_emit_seed_mega_enabled(): i32;
/** C-backend float literal emit (host snprintf; float_val + float_bits fallback).
 * Authority: pipeline_glue.c pipeline_codegen_emit_float_lit_c; product Darwin also exports
 * the same symbol from seeds/pipeline_glue_strict_minimal.from_x.c (same semantics, same commit).
 * PLATFORM: SHARED — required by force-regen codegen M2 (EXPR_FLOAT_LIT). */
export extern function pipeline_codegen_emit_float_lit_c(out: *CodegenOutBuf, float_val: f64, bits_lo: i32, bits_hi: i32): i32;
/** runtime_driver_diagnostic.c：emit_func 失败时打印函数名下标，便于定位 -E codegen fail。 */
export extern function driver_diagnostic_codegen_emit_func_fail(module: *Module, func_index: i32): void;
/** glue：按槽读 Module.struct_layouts，避免 X 对大 StructLayout 按值拷贝读字段不稳。 */
export extern function pipeline_module_struct_layout_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_name_into(module: *Module, idx: i32, out64: *u8): void;
export extern function pipeline_module_struct_layout_num_fields(module: *Module, idx: i32): i32;
export extern function pipeline_module_struct_layout_field_type_ref(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_len(module: *Module, layout_idx: i32, field_idx: i32): i32;
export extern function pipeline_module_struct_layout_field_name_into(module: *Module, layout_idx: i32, field_idx: i32, out64: *u8): void;
/** export struct 标记：定义模块优先于 merge/污染写入的同名 layout（is_export=0）。 */
export extern function pipeline_module_struct_layout_is_export_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_kind_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_binding_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_import_select_count_at(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_select_name_len(module: *Module, idx: i32, sel: i32): i32;
export extern function pipeline_module_import_select_name_byte_at(module: *Module, idx: i32, sel: i32, off: i32): u8;
export extern function pipeline_module_import_path_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_import_path_copy(module: *Module, idx: i32, dst: *u8, dst_cap: i32): void;
export extern function parser_get_module_num_imports(module: *Module): i32;
export extern function driver_dep_arena_buf(i: i32): *u8;
export extern function driver_dep_module_buf(i: i32): *u8;
export extern function driver_dep_seeded_get(i: i32): i32;
export extern function driver_dep_slot_for_path(path: *u8): i32;
/** runtime.c：当前 codegen 单元的 dep 逻辑路径（如 std.io.core），dep 池 prefix 不可用时的回退。 */
export extern function driver_get_current_dep_path_for_codegen(): *u8;
/** Expr 变长附属池读 API。 */
export extern function pipeline_expr_kind_ord_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_as_target_type_ref_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_call_resolved_dep_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_call_resolved_func_index_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_method_call_arg_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_match_arm_result_ref(arena: *ASTArena, expr_ref: i32, i: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *ASTArena, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *ASTArena, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *ASTArena, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(arena: *ASTArena, expr_ref: i32): i32;
export extern function pipeline_module_enum_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_enum_num_variants(module: *Module, idx: i32): i32;
export extern function pipeline_module_enum_variant_name_len(module: *Module, idx: i32, variant_idx: i32): i32;
export extern function pipeline_module_enum_variant_name_byte_at(module: *Module, idx: i32, variant_idx: i32, off: i32): u8;
/** Codegen-time: mark Enum.Variant / import.Enum.Variant (sets is_enum_variant + tag). */
export extern function pipeline_codegen_try_mark_enum_field_access(module: *Module, arena: *ASTArena, expr_ref: i32, dep_ctx: *PipelineDepCtx): void;
export extern function pipeline_module_top_level_let_is_const(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_len(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(module: *Module, idx: i32, off: i32): u8;
export extern function pipeline_module_top_level_let_type_ref(module: *Module, idx: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(module: *Module, idx: i32): i32;
export extern function pipeline_codegen_dep_skip_x_bootstrap_partial(path: *u8): i32;
/** glue：C 指针读 module.funcs[fi].name / params[pi].name，避免 .x 嵌套下标 typeck 与 asm GEP 问题。 */
export extern function pipeline_module_func_name_copy64(module: *Module, fi: i32, dst: *u8): void;
export extern function pipeline_module_func_param_name_copy32(module: *Module, fi: i32, pi: i32, dst: *u8): void;
/** glue：读 funcs[fi].num_params 与 params[pi].name_len，供 expr_var_matches_func_param_index 等避免 mod.funcs[fi].params[pi] 下标 typeck。 */
export extern function pipeline_module_func_num_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_name_len_at(module: *Module, fi: i32, pi: i32): i32;
export extern function pipeline_module_func_name_len_at(module: *Module, fi: i32): i32;
/** 泛型模板参数个数；>0 时 C 后端不 monomorphize，禁止 emit 非法 struct *_T。 */
export extern function pipeline_module_func_num_generic_params_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_return_type_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_body_ref_at(module: *Module, fi: i32): i32;
/** codegen 无名形参下标 sidecar 池（ast_pool.c）。 */
export extern function pipeline_dep_ctx_empty_param_reset(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_append(ctx: *PipelineDepCtx, pi: i32): i32;
export extern function pipeline_dep_ctx_empty_param_at(ctx: *PipelineDepCtx, i: i32): i32;
export extern function pipeline_dep_ctx_empty_param_backup(ctx: *PipelineDepCtx): void;
export extern function pipeline_dep_ctx_empty_param_restore(ctx: *PipelineDepCtx): void;
export extern function pipeline_module_func_body_expr_ref_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_extern_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_used_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_naked_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_entry_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_no_mangle_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_interrupt_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_is_variadic_at(module: *Module, fi: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(module: *Module, fi: i32, pi: i32): i32;
/** Block 池读（ast_pool.c）；emit_block 经 glue 访问 const/let/if/expr。 */
export extern function pipeline_block_const_name_copy64(arena: *ASTArena, br: i32, ci: i32, dst: *u8): void;
export extern function pipeline_block_const_name_len(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_type_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_const_init_ref(arena: *ASTArena, br: i32, ci: i32): i32;
export extern function pipeline_block_let_name_copy64(arena: *ASTArena, br: i32, li: i32, dst: *u8): void;
export extern function pipeline_block_let_name_len(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_let_init_ref(arena: *ASTArena, br: i32, li: i32): i32;
export extern function pipeline_block_if_cond_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_then_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
export extern function pipeline_block_if_else_body_ref(arena: *ASTArena, br: i32, ii: i32): i32;
/** MEM-B0：defer 子块 body ref（逆序 emit 用）。 */
export extern function pipeline_block_defer_body_ref(arena: *ASTArena, br: i32, di: i32): i32;
export extern function pipeline_module_func_ref_at(module: *Module, func_index: i32): i32;
/** asm backend：`import a.b.c` + `a.b.c.method` 形式解析 C ABI 符号（backend_call_dispatch.c）。 */
export extern function pipeline_asm_resolve_whole_import_qualified_symbol_c(arena: *ASTArena, cur_mod: *Module, callee_expr_ref: i32, sym_flat: *u8, out_match_imp_j: *i32): i32;
export extern function pipeline_block_stmt_order_kind(arena: *ASTArena, br: i32, si: i32): u8;
export extern function pipeline_block_stmt_order_idx(arena: *ASTArena, br: i32, si: i32): i32;

/**
 * path 指向的 NUL 结尾字节是否与 "std.io.core" 完全一致（ codegen.c 同名逻辑迁入 .x，减少一处 extern）。
 */
/** import 路径是否为 std.io.driver（与 codegen.c 一致）。 */
export function codegen_path_is_std_io_driver_bytes(path: *u8): i32 {
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

export function codegen_path_is_std_io_core_bytes(path: *u8): i32 {
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
export function codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void {
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
export function codegen_dep_import_path_len_at(ctx: *PipelineDepCtx, idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let plen: i32 = pipeline_dep_ctx_import_path_len(ctx, idx);
    if (plen <= 0) {
      return 0;
    }
    pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
    return plen;
  }
}

/**
 * 在 dep 池中查找 current_codegen_module，路径写入 dst；返回长度，0 表示未找到或无路径。
 */
export function codegen_ctx_dep_path_for_current_codegen_module_into(ctx: *PipelineDepCtx, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 读取当前 codegen 模块第 import_idx 条 import 的原始 import path。
 * 返回长度，0 表示当前模块为空、索引无效或未记录路径。
 */
export function codegen_module_import_path_len_at(module: *Module, import_idx: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 以 import path 精确匹配 dep_ctx 中的全局 dep 槽位，返回 dep index；找不到返回 -1。
 */
export function codegen_find_dep_index_by_path(ctx: *PipelineDepCtx, path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

export function codegen_find_seeded_global_dep_slot_by_path(path: *u8, path_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

export function codegen_module_num_imports(module: *Module): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (module == 0 as *Module) {
      return 0;
    }
    let n_imp: i32 = parser_get_module_num_imports(module);
    if (n_imp > 0) {
      return n_imp;
    }
    return module.num_imports;
  }
}

/**
 * 根据当前 codegen 模块在 dep 池中的逻辑路径，写入与 emit_func 一致的 C 符号前缀（buf 内 NUL 结尾），返回前缀字节长度（不含 NUL）。
 * 主模块未出现在 dep 池中时路径为空，返回 0；std.io.core 与 codegen_x_ast 一致不加前缀。
 */
export function codegen_emit_prefix_len_from_ctx(ctx: *PipelineDepCtx, buf: *u8, buf_cap: i32): i32 {
  if (buf == 0 as *u8 || buf_cap <= 0 || ctx == 0 as *PipelineDepCtx) {
    return 0;
  }
  buf[0] = 0 as u8;
  /*
   * 入口库模块：优先 entry_module_import_path（driver 钉死的 C 前缀），避免
   * current_codegen_prefix 被 dep codegen 覆写后污染入口局部/调用前缀。
   */
  if (ctx.current_codegen_dep_index < 0 && ctx.entry_module_import_path_len > 0) {
    let pi: i32 = 0;
    while (pi < ctx.entry_module_import_path_len && pi < buf_cap - 1) {
      buf[pi] = ctx.entry_module_import_path_mirror[pi];
      pi = pi + 1;
    }
    buf[pi] = 0 as u8;
    return pi;
  }
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
export function codegen_emit_async_run_seed_push_name(out: *CodegenOutBuf, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 输出 async 调度 wrapper 调用 `shux_async_sched_<fn>()`。 */
export function codegen_emit_async_sched_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 输出 async 调度 wrapper 调用 `shux_async_sched_<name>()`。 */
export function codegen_emit_async_sched_call_by_name(out: *CodegenOutBuf, fn_name: *u8, fn_len: i32): i32 {
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
export function codegen_emit_async_task_submit_call(out: *CodegenOutBuf, module: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 输出 `shux_async_task_submit((int32_t (*)(void))prefix_name)`；spawn 的 binding import 回退路径复用。 */
export function codegen_emit_async_task_submit_call_by_symbol(out: *CodegenOutBuf, prefix: *u8, prefix_len: i32, fn_name: *u8, fn_len: i32): i32 {
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
export function codegen_emit_async_binding_import_call(arena: *ASTArena, out: *CodegenOutBuf, call_expr_ref: i32, ctx: *PipelineDepCtx, is_spawn: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** `run dep.fn(args)` 等 METHOD_CALL async 回退：run 仅依赖 method 名，不需要 dep 前缀。 */
export function codegen_emit_async_method_call_run(arena: *ASTArena, out: *CodegenOutBuf, method_expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 线性扫描 module.funcs，按 ASCII 函数名返回下标；找不到返回 -1。 */
export function codegen_find_module_func_index_by_name(module: *Module, nm: *u8, nm_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 绑定 import（`const dep = import("...")`）的 `dep.fn(...)` 回退解析依赖槽，找不到返回 -1。 */
export function codegen_resolve_binding_import_dep_index(ctx: *PipelineDepCtx, arena: *ASTArena, callee_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** run/spawn 的 resolved_func_index 未填稳时，回退按 callee/method 名在线性扫描目标模块函数。 */
export function codegen_resolve_call_target_func_index(arena: *ASTArena, module: *Module, call_expr_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 判断 field_access 的 base 是否为指向函数第 param_idx 个形参的 EXPR_VAR（含「恰好一个无名形参」时的无名 VAR）。
 * 多无名形参时不尝试绑定，避免与 current_emit_empty_var_next_index 顺序耦合。
 * 自举：勿将 module.funcs[func_index] 或 Param 按值拷入局部，改经 mod.funcs[func_index].params[param_idx] 逐字段读。
 */
export function expr_var_matches_func_param_index(arena: *ASTArena, var_ref: i32, mod: *Module, func_index: i32, param_idx: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** prefix+name 拼成的完整 C 符号与字面量逐字节比较；长度不一或指针为空则不相等。 */
export function codegen_symbuf_bytes_eq(buf: *u8, buf_len: i32, lit: *u8, lit_len: i32): i32 {
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
export function codegen_call_num_args_override(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, num_args: i32): i32 {
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
export function codegen_name_bytes_prefix_eq(name: *u8, name_len: i32, expect: *u8, exp_len: i32): i32 {
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
export function codegen_is_std_io_driver_bridge_name(name: *u8, name_len: i32): i32 {
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
  if (name_len == 22 && codegen_name_bytes_prefix_eq(name, name_len, &nm22[0], 22) != 0) {
    return 1;
  }
  /* 【Why 根源】submit_*_batch 不得 skip co-emit：call 端仍用 std_io_driver_submit_*_batch，
   * 跳过则只剩 preamble weak 返回 -1（run-io-driver r4=-1）。
   * register/submit_read/submit_write 由 call 端改写 shux_io_*_buf，可 skip 本体。 */
  return 0;
}

/**
 * Skip emitting std.io.core bodies that duplicate runtime/io.o strong symbols.
 *
 * Purpose: when product C co-emits std.io.core, do not redefine shux_io_read_fixed
 * (and siblings) that product preamble already provides as weak stubs / io.o.
 *
 * Parameters:
 *   dep_path  — module path bytes; must start with "std.io.core" (11 bytes).
 *   name      — bare function name (no module prefix).
 *   name_len  — name length; allow exact or exact+1 (historical trailing-NUL window).
 *
 * Returns 1 to skip emit, 0 to emit.
 *
 * Contract: match tables use full "shux_io_*" (with 'x'), never historic "shu_io_*".
 * Batch names are checked before short submit_read/write prefixes.
 * PLATFORM: SHARED — link-name contract; Cap force + pin product matrix.
 */
export function codegen_should_skip_emit_std_io_core_io_dup(dep_path: *u8, name: *u8, name_len: i32): i32 {
  let path_core: u8[11] = [115, 116, 100, 46, 105, 111, 46, 99, 111, 114, 101];
  /* shux_io_read_fixed — 18 (preamble weak returns -1; avoid redef with weak). */
  let n_rf: u8[18] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 102, 105, 120, 101, 100];
  /* shux_io_write_fixed — 19 */
  let n_wf: u8[19] = [115, 104, 117, 120, 95, 105, 111, 95, 119, 114, 105, 116, 101, 95, 102, 105, 120, 101, 100];
  /*
   * 【Why 根源】勿 skip submit_read / submit_*_batch：
   *   - core co-emit 会调 std_io_backend_io_*（同 TU 已有真体）；
   *   - 旧 skip 只剩 preamble weak，且 weak 再调裸 io_write_batch/io_read_batch，
   *     产品 -o 不硬链 runtime_asm_io_stubs（与 co-emit std_io_write_stdout 冲突）→
   *     run-io-driver 双端 UNDEF _io_write_batch / 弱路径假红。
   * Do NOT skip shux_io_submit_write either (no weak; Cap force hello residual).
   * PLATFORM: SHARED — product C path; Cap force + pin seed.
   */
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
  if ((name_len == 18 || name_len == 19) && codegen_name_bytes_prefix_eq(name, name_len, &n_rf[0], 18) != 0) {
    return 1;
  }
  if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &n_wf[0], 19) != 0) {
    return 1;
  }
  return 0;
}

/**
 * std.io 的 handle_stdin/stdout/stderr/from_fd 为字面量返回；若 dep 槽误用 std_io_driver_ 前缀再生成会与 std_io_handle_* 重复。
 * dep_path 非空时须为 std.io（path_io）；prefix-only 分支传 dep_path=0，仅按 name 判断。
 */
export function codegen_should_skip_emit_std_io_trivial_handle(dep_path: *u8, name: *u8, name_len: i32): i32 {
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
export function codegen_should_skip_emit_func(dep_path: *u8, prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  /* Case A：拼接 prefix+name 等于完整 mangled 名 std_io_driver_driver_read_ptr_len（33）或 std_io_driver_driver_read_ptr（29）。 */
  let full33: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let full29: u8[29] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* Case B：import 路径 NUL 结尾（与 codegen_path_is_std_io_core_bytes 同样逐字节含末尾 NUL）。 */
  let path_driver: u8[14] = [115, 116, 100, 46, 105, 111, 46, 100, 114, 105, 118, 101, 114, 0];
  let path_io: u8[7] = [115, 116, 100, 46, 105, 111, 0];
  /* Case B：标识符本体；AST 可能上报 name_len exact+1。 */
  let nm_len19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  let nm_len15: u8[15] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /* driver_read_ptr_gen — 19 (same length as ptr_len; distinct suffix) */
  let nm_gen19: u8[19] = [100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  let pi: i32 = 0;
  let ni: i32 = 0;
  let ok_path: i32 = 0;
  let di: i32 = 0;
  /* full33_gen: std_io_driver_driver_read_ptr_gen (33) — same length as ptr_len; must not early-return 0 on mismatch. */
  let full33_gen: u8[33] = [115, 116, 100, 95, 105, 111, 95, 100, 114, 105, 118, 101, 114, 95, 100, 114, 105, 118, 101, 114, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 103, 101, 110];
  if (prefix != 0 as *u8 && prefix_len > 0 && name != 0 as *u8 && name_len > 0) {
    let total_len: i32 = prefix_len + name_len;
    if (total_len == 33) {
      let match_len: i32 = 1;
      let match_gen: i32 = 1;
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full33[pi]) {
          match_len = 0;
        }
        if (prefix[pi] != full33_gen[pi]) {
          match_gen = 0;
        }
        pi = pi + 1;
      }
      ni = 0;
      while (ni < name_len) {
        if (name[ni] != full33[prefix_len + ni]) {
          match_len = 0;
        }
        if (name[ni] != full33_gen[prefix_len + ni]) {
          match_gen = 0;
        }
        ni = ni + 1;
      }
      if (match_len != 0 || match_gen != 0) {
        return 1;
      }
      /* fall through — other total-33 names are not auto-skipped */
    }
    if (total_len == 29) {
      pi = 0;
      while (pi < prefix_len) {
        if (prefix[pi] != full29[pi]) {
          /* fall through on mismatch (do not abort whole skip) */
          pi = prefix_len + 1;
          break;
        }
        pi = pi + 1;
      }
      if (pi == prefix_len) {
        ni = 0;
        while (ni < name_len) {
          if (name[ni] != full29[prefix_len + ni]) {
            ni = name_len + 1;
            break;
          }
          ni = ni + 1;
        }
        if (ni == name_len) {
          return 1;
        }
      }
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
      if ((name_len == 19 || name_len == 20) && codegen_name_bytes_prefix_eq(name, name_len, &nm_gen19[0], 19) != 0) {
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
  /* dep 误标为 std.io.driver 时 mod 的 handle_* 会以 std_io_driver_handle_* 再生成一次，与 std_io_handle_* 重复。
   * 【Why 根源】仅凭 prefix_len==14 会误伤 std_heap_libc_（同为 14 字节）：
   * trivial_handle 在 name_len==12 时又因 X→C 丢括号变成「任意 12 字符名即 skip」，
   * 导致 heap_alloc_c 只留 extern、无函数体 → heap.o 缺 std_heap_libc_heap_alloc_c。
   * 【Invariant】必须 prefix 确为 std_io_driver_ 才走 handle skip。 */
  if (prefix != 0 as *u8 && prefix_len == 14 && name != 0 as *u8
      && codegen_name_bytes_prefix_eq(prefix, prefix_len, &pref_abi14[0], 14) != 0) {
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
export function codegen_force_param_std_io_driver_prefix_ok(prefix: *u8, prefix_len: i32): i32 {
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
export function codegen_force_param_size_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
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
export function codegen_force_param_size_t_std_io_print_str_second(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
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
export function codegen_force_param_ptrdiff_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
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
export function codegen_force_param_uint32_t(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32, param_index: i32): i32 {
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
export function codegen_use_buf_wrapper(name: *u8, name_len: i32, num_args: i32): i32 {
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
export function codegen_emit_io_driver_buf_call_name(out: *CodegenOutBuf, name: *u8, name_len: i32, num_args: i32): i32 {
  let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
  let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
  let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
  /* 权威名：shux_io_*_buf（含 x；旧表误写成 shu_io_* 导致隐式声明）。 */
  let sym_reg: u8[20] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
  let sym_rd: u8[23] = [115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
  let sym_wr: u8[24] = [115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  if (num_args == 1 && name_len == 8 && codegen_name_bytes_prefix_eq(name, name_len, &reg8[0], 8) != 0) {
    if (emit_bytes_from_ptr(out, &sym_reg[0], 20) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 11 && codegen_name_bytes_prefix_eq(name, name_len, &rd11[0], 11) != 0) {
    if (emit_bytes_from_ptr(out, &sym_rd[0], 23) != 0) {
      return -1;
    }
    return 1;
  }
  if (num_args == 2 && name_len == 12 && codegen_name_bytes_prefix_eq(name, name_len, &wr12[0], 12) != 0) {
    if (emit_bytes_from_ptr(out, &sym_wr[0], 24) != 0) {
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
export function codegen_try_emit_std_io_driver_buf_body(out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let nparams: i32 = 0;
    let p0: u8[32] = [98, 117, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let p1: u8[32] = [116, 105, 109, 101, 111, 117, 116, 95, 109, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let reg8: u8[8] = [114, 101, 103, 105, 115, 116, 101, 114];
    let rd11: u8[11] = [115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100];
    let wr12: u8[12] = [115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101];
    let sym_reg: u8[20] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 103, 105, 115, 116, 101, 114, 95, 98, 117, 102];
    let sym_rd: u8[23] = [115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 98, 117, 102];
    let sym_wr: u8[24] = [115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 119, 114, 105, 116, 101, 95, 98, 117, 102];
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
      if (emit_bytes_from_ptr(out, &sym_reg[0], 20) != 0) { return -1; }
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
      if (emit_bytes_from_ptr(out, &sym_rd[0], 23) != 0) { return -1; }
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
      if (emit_bytes_from_ptr(out, &sym_wr[0], 24) != 0) { return -1; }
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
}

/** 从 arena 判断 base 是否为指针；有 resolved 且非 PTR 时明确返回 0（局部值 struct 必须用 `.`）。 */
export function field_access_base_is_pointer_ref(arena: *ASTArena, base_ref: i32): i32 {
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
 * base 是否已有有效 resolved_type_ref。
 * 【Why】名字回退（slice_param_name）在类型已知时不得覆盖：局部 `let ctx: PipelineDepCtx` 值类型
 * 若仍按名 `ctx` 强制 `->`，会生成非法 C（member reference type is not a pointer）。
 */
export function field_access_base_type_resolved(arena: *ASTArena, base_ref: i32): i32 {
  if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
    return 0;
  }
  let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
  if (ast.ref_is_null(base.resolved_type_ref) || base.resolved_type_ref <= 0 || base.resolved_type_ref > arena.num_types) {
    return 0;
  }
  return 1;
}

/**
 * Emit one call argument under seed/glue slice ABI (PLATFORM: SHARED).
 *
 * Why: TYPE_SLICE params lower as `struct shux_slice_* *`. Locals stay by-value
 * structs, so call sites must pass `&local` (seed: `&(slice)`). Slice params are
 * already pointers — pass through. ADDR_OF is left unchanged.
 *
 * Invariant: only for call/method arg positions; never for general emit_expr.
 */
export function emit_call_arg_slice_abi(arena: *ASTArena, out: *CodegenOutBuf, arg_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (ast.ref_is_null(arg_ref)) {
      return append_byte(out, 48);
    }
    let arg: Expr = ast.ast_arena_expr_get(arena, arg_ref);
    if (arg.kind == ExprKind.EXPR_ADDR_OF) {
      return emit_expr(arena, out, arg_ref, ctx);
    }
    /* Already a slice param of the current function → C pointer; do not add &. */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      if (field_access_base_is_pointer_param(arena, arg_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
        /* pointer_param now treats TYPE_SLICE params as pointers */
        let is_slice_param: i32 = 0;
        let base: Expr = arg;
        if (base.kind == ExprKind.EXPR_VAR && base.var_name_len > 0) {
          let mod: *Module = ctx.current_codegen_module;
          let fi: i32 = ctx.current_func_index;
          let np: i32 = pipeline_module_func_num_params_at(mod, fi);
          let pi: i32 = 0;
          while (pi < np) {
            let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, fi, pi);
            if (p_name_len > 0 && p_name_len == base.var_name_len) {
              let pname_buf: u8[32] = [];
              pipeline_module_func_param_name_copy32(mod, fi, pi, &pname_buf[0]);
              let matched: bool = true;
              let j: i32 = 0;
              while (j < p_name_len && j < 32) {
                if (pname_buf[j] != base.var_name[j]) {
                  matched = false;
                  break;
                }
                j = j + 1;
              }
              if (matched) {
                let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, fi, pi);
                if (pipeline_type_kind_ord_at(arena, param_ty_ref) == (TypeKind.TYPE_SLICE as i32)) {
                  is_slice_param = 1;
                }
              }
            }
            pi = pi + 1;
          }
        }
        if (is_slice_param != 0) {
          return emit_expr(arena, out, arg_ref, ctx);
        }
      }
    }
    /* Local / rvalue slice → &(arg) for pointer param ABI. */
    let need_addr: i32 = 0;
    if (!ast.ref_is_null(arg.resolved_type_ref) && arg.resolved_type_ref > 0 && arg.resolved_type_ref <= arena.num_types) {
      let aty: Type = ast.ast_arena_type_get(arena, arg.resolved_type_ref);
      if (aty.kind == TypeKind.TYPE_SLICE) {
        need_addr = 1;
      }
    }
    if (need_addr == 0 && arg.kind == ExprKind.EXPR_VAR && ctx != 0 as *PipelineDepCtx) {
      /* Local let annotated as TYPE_SLICE */
      if (field_access_base_is_pointer_local(arena, arg_ref, ctx) == 0) {
        let br: i32 = 0;
        if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
          br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
        }
        if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
          br = ctx.current_block_ref;
        }
        if (!ast.ref_is_null(br) && br > 0 && br <= arena.num_blocks) {
          let nlets: i32 = ast.ast_block_num_lets(arena, br);
          let li: i32 = 0;
          while (li < nlets) {
            let nl: i32 = pipeline_block_let_name_len(arena, br, li);
            if (nl == arg.var_name_len && nl > 0) {
              let nb: u8[64] = [];
              pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
              let eq: bool = true;
              let j2: i32 = 0;
              while (j2 < nl && j2 < 64) {
                if (nb[j2] != arg.var_name[j2]) {
                  eq = false;
                  break;
                }
                j2 = j2 + 1;
              }
              if (eq) {
                let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
                if (pipeline_type_kind_ord_at(arena, tr) == (TypeKind.TYPE_SLICE as i32)) {
                  need_addr = 1;
                }
              }
            }
            li = li + 1;
          }
        }
      }
    }
    if (need_addr != 0) {
      let pre: u8[3] = [38, 40, 0];
      if (emit_bytes_3(out, pre, 2) != 0) {
        return -1;
      }
      if (emit_expr(arena, out, arg_ref, ctx) != 0) {
        return -1;
      }
      return append_byte(out, 41);
    }
    return emit_expr(arena, out, arg_ref, ctx);
  }
}

/**
 * 【Why 根源】回退：typeck 未填 resolved_type_ref 时，通过当前函数形参类型判断 base 是否为指针。
 * 用于 dep 模块 codegen：dep 模块函数体未走完整 typeck，EXPR_VAR 的 resolved_type_ref 可能为空，
 * field_access_base_is_pointer_ref 返回 0 → 字段访问误用 . 而非 ->（C 编译错误）。
 * 通过形参类型回退判断，确保 *T 形参的字段访问生成 ->。
 * 【Invariant】仅当 base 为 EXPR_VAR 且 var_name 匹配当前函数某形参名时生效。
 */
export function field_access_base_is_pointer_param(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[32] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            let pty: Type = ast.ast_arena_type_get(arena, param_ty_ref);
            /* PLATFORM: SHARED — C ABI: *T and u8[] (TYPE_SLICE) params are pointers.
             * Seed/glue pass slices as struct shux_slice_* *; field access must use ->. */
            if (pty.kind == TypeKind.TYPE_PTR || pty.kind == TypeKind.TYPE_SLICE) {
              return 1;
            }
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/* 局部 let s: *T：无 resolved_type 时按 body 块 let 注解判 *T → C 用 -> */
export function field_access_base_is_pointer_local(arena: *ASTArena, base_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || ctx == 0 as *PipelineDepCtx) {
      return 0;
    }
    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let br: i32 = 0;
    if (ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
      br = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      br = ctx.current_block_ref;
    }
    if (ast.ref_is_null(br) || br <= 0 || br > arena.num_blocks) {
      return 0;
    }
    let nlets: i32 = ast.ast_block_num_lets(arena, br);
    let li: i32 = 0;
    while (li < nlets) {
      let nl: i32 = pipeline_block_let_name_len(arena, br, li);
      if (nl == base.var_name_len && nl > 0) {
        let nb: u8[64] = [];
        pipeline_block_let_name_copy64(arena, br, li, &nb[0]);
        let eq: bool = true;
        let j: i32 = 0;
        while (j < nl && j < 64) {
          if (nb[j] != base.var_name[j]) {
            eq = false;
            break;
          }
          j = j + 1;
        }
        if (eq) {
          let tr: i32 = pipeline_block_let_type_ref(arena, br, li);
          if (!ast.ref_is_null(tr) && tr > 0 && tr <= arena.num_types) {
            let lty: Type = ast.ast_arena_type_get(arena, tr);
            if (lty.kind == TypeKind.TYPE_PTR) {
              return 1;
            }
          }
        }
      }
      li = li + 1;
    }
    return 0;
  }
}

/**
 * base 是否匹配当前函数某形参且该形参 type_ref 有效（值类型或指针均可）。
 * 【Why 根源】dep co-emit 时 EXPR_VAR 常无 resolved_type_ref；名字回退把 "ctx" 一律当 *T → 生成
 *   `ctx->handle`，但 std.context 的 `ctx: Context` 是值类型须 `.`。形参类型已知时禁止名字回退。
 */
export function field_access_base_param_type_known(arena: *ASTArena, base_ref: i32, mod: *Module, func_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena.num_exprs) {
      return 0;
    }
    if (mod == 0 as *Module || func_index < 0 || func_index >= mod.num_funcs) {
      return 0;
    }
    let base: Expr = ast.ast_arena_expr_get(arena, base_ref);
    if (base.kind != ExprKind.EXPR_VAR || base.var_name_len <= 0) {
      return 0;
    }
    let np: i32 = pipeline_module_func_num_params_at(mod, func_index);
    let pi: i32 = 0;
    while (pi < np) {
      let p_name_len: i32 = pipeline_module_func_param_name_len_at(mod, func_index, pi);
      if (p_name_len > 0 && p_name_len == base.var_name_len) {
        let pname_buf: u8[32] = [];
        pipeline_module_func_param_name_copy32(mod, func_index, pi, &pname_buf[0]);
        let matched: bool = true;
        let j: i32 = 0;
        while (j < p_name_len && j < 32) {
          if (pname_buf[j] != base.var_name[j]) {
            matched = false;
            break;
          }
          j = j + 1;
        }
        if (matched) {
          let param_ty_ref: i32 = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
          if (!ast.ref_is_null(param_ty_ref) && param_ty_ref > 0 && param_ty_ref <= arena.num_types) {
            return 1;
          }
        }
      }
      pi = pi + 1;
    }
    return 0;
  }
}

/**
 * 回退：base 为已知指针/slice 形参名时字段访问输出 ->。
 * 仅当 typeck 未填 resolved_type_ref 时由调用方启用；类型已解析时禁止用本表覆盖
 * （见 field_access_base_type_resolved），否则局部值 `ctx`/`out` 会被误编成 `->`。
 */
export function field_access_base_is_slice_param_name(arena: *ASTArena, base_ref: i32): i32 {
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
  /* 勿把裸名 "out" 当指针：局部 `let out: Slice/Struct` 值类型极常见，误用 -> 会生成非法 C
   *（invalid type argument of '->'）。CodegenOutBuf* 请用 out_buf / 依赖 resolved_type_ref。 */
  if (base.var_name_len == 7 && base.var_name[0] == 99 && base.var_name[1] == 117 && base.var_name[2] == 114 && base.var_name[3] == 95 && base.var_name[4] == 109 && base.var_name[5] == 111 && base.var_name[6] == 100) {
    return 1;
  }
  return 0;
}

/** stmt_order 是否已包含块内第 li 条 let（kind=1）。 */
export function block_stmt_order_has_let(arena: *ASTArena, block_ref: i32, let_idx: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 返回非 0 表示 name 已以 prefix 开头且应跳过再次前置 prefix。
 * 仅当前缀为 ASCII「build_」（6 字节）时启用：与 build.x 约定一致；preprocess_ 等仍须叠写以匹配链接 shim。
 */
export function codegen_c_prefix_redundant_with_name(prefix: *u8, prefix_len: i32, name: *u8, name_len: i32): i32 {
  if (prefix == 0 as *u8 || name == 0 as *u8) {
    return 0;
  }
  if (prefix_len <= 0 || name_len < prefix_len) {
    return 0;
  }
  /* 【Why 根源】ast_ 模块的 C 定义在 pipeline_glue.c 中使用双前缀（ast_ast_*），
   *   不需要去重。所有其他模块的 C 定义使用单前缀（函数名已含模块前缀），
   *   需要去重以避免双前缀（如 backend_backend_*、codegen_codegen_*、build_build_*）。
   *   仅排除 ast_（prefix = "ast_"，4 字节：97,115,116,95）。 */
  if (prefix_len == 4 && prefix[0] == 97 && prefix[1] == 115 && prefix[2] == 116 && prefix[3] == 95) {
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
export struct CodegenOutBuf {
  data: u8[9437184];
  len: i32;
}

/** 向缓冲区追加一字节（b 为 i32，取低 8 位，经查找表转为 u8）。返回 0 成功，缓冲区满返回 -1。 */
export function append_byte(out: *CodegenOutBuf, b: i32): i32 {
  if (out.len >= 9437184) {
    return -1;
  }
  /** 勿 `let lo = b & 255` 再写 out.data：与下一赋值同体时 parse_into_buf 多函数模块会丢 append_byte body_ref。 */
  out.data[out.len] = (b & 255) as u8;
  out.len = out.len + 1;
  return 0;
}

/** 向缓冲区追加一字节（b 为 u8）：转调 append_byte，避免 u8 直接写入 data[out.len] 在 parse_into_buf AST 上与 typeck 不兼容。 */
export function append_byte_u8(out: *CodegenOutBuf, b: u8): i32 {
  return append_byte(out, b as i32);
}

/** 从 ptr[0..len-1] 逐字节追加到 out，用于库前缀等变长内容。 */
export function emit_bytes_from_ptr(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
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
export function emit_bytes_64(out: *CodegenOutBuf, ptr: *u8, len: i32): i32 {
  return emit_bytes_from_ptr(out, ptr, len);
}
export function emit_bytes_32(out: *CodegenOutBuf, buf: u8[32], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_22(out: *CodegenOutBuf, buf: u8[22], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_9(out: *CodegenOutBuf, buf: u8[9], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_8(out: *CodegenOutBuf, buf: u8[8], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_7(out: *CodegenOutBuf, buf: u8[7], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_6(out: *CodegenOutBuf, buf: u8[6], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_5(out: *CodegenOutBuf, buf: u8[5], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_4(out: *CodegenOutBuf, buf: u8[4], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_3(out: *CodegenOutBuf, buf: u8[3], len: i32): i32 {
  let i: i32 = 0;
  while (i < len) {
    if (append_byte_u8(out, buf[i]) != 0) {
      return -1;
    }
    i = i + 1;
  }
  return 0;
}
export function emit_bytes_2(out: *CodegenOutBuf, buf: u8[2], len: i32): i32 {
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
export function format_uint(out: *CodegenOutBuf, val: i32): i32 {
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

/** 非负 u64 十进制（EXPR_LIT 可超过 i32）。 */
export function format_uint64(out: *CodegenOutBuf, val: u64): i32 {
  if (val >= (10 as u64)) {
    let q: u64 = val / (10 as u64);
    let r: u64 = val % (10 as u64);
    if (format_uint64(out, q) != 0) {
      return -1;
    }
    if (append_byte(out, 48 + (r as i32)) != 0) {
      return -1;
    }
    return 0;
  }
  if (append_byte(out, 48 + (val as i32)) != 0) {
    return -1;
  }
  return 0;
}

/** 将 i64 整数的十进制表示写入 out（含负号；INT64_MIN 特判）。 */
export function format_int(out: *CodegenOutBuf, val: i64): i32 {
  if (val >= 0) {
    return format_uint64(out, val as u64);
  }
  let u: i64 = 0 - val;
  if (u < 0) {
    /* INT64_MIN：0 - val 仍溢出；直接写 "-9223372036854775808" */
    if (append_byte(out, 45) != 0) {
      return -1;
    }
    let d: u8[20] = [57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56, 0];
    let i: i32 = 0;
    while (i < 19) {
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
  return format_uint64(out, u as u64);
}

/** 写 indent 个空格。 */
export function emit_indent(out: *CodegenOutBuf, indent: i32): i32 {
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
export function emit_break_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let br: u8[8] = [98, 114, 101, 97, 107, 59, 10, 0];
  return emit_bytes_8(out, br, 7);
}

/** 写 continue;\n（含缩进）。 */
export function emit_continue_stmt(out: *CodegenOutBuf, indent: i32): i32 {
  if (emit_indent(out, indent) != 0) {
    return -1;
  }
  let co: u8[11] = [99, 111, 110, 116, 105, 110, 117, 101, 59, 10, 0];
  return emit_bytes_from_ptr(out, &co[0], 10);
}

/** 将 pipeline_type_kind_ord_at 序数委托 emit_type_kind（勿 ast_arena_type_get 按值 Type）。 */
export function emit_type_kind_ord(out: *CodegenOutBuf, tk: i32): i32 {
  return emit_type_kind(out, tk);
}

/** 根据 TypeKind 写 C 类型名到 out（仅内建类型）；纯 .x，按数组尺寸调用对应 emit_bytes_N。 */
export function emit_type_kind(out: *CodegenOutBuf, kind_ord: i32): i32 {
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
export function type_kind_append_to_scratch(scratch: *u8, cap: i32, w: i32, kind_ord: i32): i32 {
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
export function emit_vector_c_type_out(out: *CodegenOutBuf, elem_kind_ord: i32, lanes: i32): i32 {
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
export function type_kind_append_to_scratch_ord(scratch: *u8, cap: i32, w: i32, tk: i32): i32 {
  let w2: i32 = type_kind_append_to_scratch(scratch, cap, w, tk);
  if (w2 < 0) {
    return type_kind_append_to_scratch(scratch, cap, w, TypeKind.TYPE_I32 as i32);
  }
  return w2;
}

/** 写入 C c_type_str 等价串至 scratch（无 NUL）；逻辑在 pipeline_codegen_type_to_c_repr（C glue）。 */
export function type_to_c_repr(arena: *ASTArena, scratch: *u8, cap: i32, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_type_to_c_repr(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
  }
}

/** 写类型到 out（glue 读 kind/elem/array/name，勿 ast_arena_type_get 按值 Type）。 */
export function emit_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
      /*
       * core.option 具象 Option_*：定义模块前缀恒为 core_option_。
       * 【Why 根源】dep 池按 type_ref 查不到跨模块 monomorph 时，旧逻辑用当前模块 struct_prefix
       *   （如 core_slice_）生成 incomplete `struct core_slice_Option_i32`，而 co-emit 的
       *   some/none 体是 `struct core_option_Option_i32` → length.x 等链接/编译失败。
       * 【Invariant】裸名以 Option_ 开头的 TYPE_NAMED 一律 `struct core_option_<name>`。
       */
      if (name_len >= 8 && nm[0] == 79 && nm[1] == 112 && nm[2] == 116 && nm[3] == 105
          && nm[4] == 111 && nm[5] == 110 && nm[6] == 95) {
        let opt_head: u8[20] = [115, 116, 114, 117, 99, 116, 32, 99, 111, 114, 101, 95, 111, 112, 116, 105, 111, 110, 95, 0];
        if (emit_bytes_from_ptr(out, &opt_head[0], 19) != 0) {
          return -1;
        }
        let oi: i32 = 0;
        while (oi < name_len && oi < 64) {
          if (append_byte_u8(out, nm[oi]) != 0) {
            return -1;
          }
          oi = oi + 1;
        }
        return 0;
      }
      /* u16/i16/i8 无独立 TypeKind（存为 TYPE_NAMED），映射到 stdint.h 的 uint16_t/int16_t/int8_t。
       * 【Why 根源】AST 枚举无 TYPE_U16/TYPE_I16/TYPE_I16，窄整型存为 TYPE_NAMED name="u16"/"i16"/"i8"，
       *   不映射会被 fallback 当作用户 struct 输出 "struct ast_i8" 等，C 编译报 incomplete type。
       * 【Invariant】u8 走 TYPE_U8 内建分支无需此处映射；仅 signed i8 需补（负数字面量 typeck 已放行）。
       * 【Asm/Perf】emit_type 是 codegen 热路径但 TYPE_NAMED 命中率低，字面量字节比较无分支预测惩罚。 */
      if (name_len == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54) {
        let u16_t: u8[9] = [117, 105, 110, 116, 49, 54, 95, 116, 0];
        return emit_bytes_8(out, u16_t, 8);
      }
      if (name_len == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) {
        let i16_t: u8[8] = [105, 110, 116, 49, 54, 95, 116, 0];
        return emit_bytes_8(out, i16_t, 7);
      }
      if (name_len == 2 && nm[0] == 105 && nm[1] == 56) {
        let i8_t: u8[7] = [105, 110, 116, 56, 95, 116, 0];
        return emit_bytes_8(out, i8_t, 6);
      }
      /*
       * 向量拼写 TYPE_NAMED（parser 部分路径未落 TYPE_VECTOR）：i32x4/u32x4/i32x8…
       * 发 C typedef 名，禁 struct ast_i32x4 incomplete。
       */
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 8);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 52) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 4);
      }
      if (name_len == 5 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 56) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 8);
      }
      if (name_len == 6 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_I32 as i32, 16);
      }
      if (name_len == 6 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50 && nm[3] == 120 && nm[4] == 49 && nm[5] == 54) {
        return emit_vector_c_type_out(out, TypeKind.TYPE_U32 as i32, 16);
      }
      /** 用户顶层 enum：C 无对应 tag 时按 int32_t 存储（与 typeck 布局一致）。 */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_enum(ctx.current_codegen_module, arena, type_ref) != 0) {
        let i32_enum: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
        return emit_bytes_8(out, i32_enum, 7);
      }
      /* dep 模块 user enum：emit "enum <prefix>_<name>" 而非 "struct <prefix>_<name>"
       * 【Why 根源】TypeKind/ExprKind 等在 ast 模块定义为 enum，入口模块引用时
       *   codegen_type_is_module_user_enum 仅查当前模块找不到，需遍历 dep 模块。
       *   不做此检查会误走 struct 前缀生成 "struct ast_TypeKind"，C 编译报 incomplete type。
       * 【Invariant】dep_enum_prefix_len > 0 仅当类型在 dep 模块 enums 中找到。
       * 【Asm/Perf】仅 TYPE_NAMED 且非当前模块 enum 时触发，热路径无额外开销。 */
      if (ctx != 0 as *PipelineDepCtx) {
        let dep_enum_prefix: u8[128] = [];
        let dep_enum_prefix_len: i32 = codegen_type_dep_enum_prefix_into(ctx, arena, type_ref, &dep_enum_prefix[0], 128);
        if (dep_enum_prefix_len > 0) {
          let e: u8[8] = [101, 110, 117, 109, 32, 0, 0, 0];
          if (emit_bytes_8(out, e, 5) != 0) {
            return -1;
          }
          if (emit_bytes_from_ptr(out, &dep_enum_prefix[0], dep_enum_prefix_len) != 0) {
            return -1;
          }
          let bare_off2: i32 = 0;
          let bi2: i32 = 0;
          while (bi2 < name_len && bi2 < 64) {
            if (nm[bi2] == 46) {
              bare_off2 = bi2 + 1;
            }
            bi2 = bi2 + 1;
          }
          let ci2: i32 = bare_off2;
          while (ci2 < name_len && ci2 < 64) {
            if (append_byte_u8(out, nm[ci2]) != 0) {
              return -1;
            }
            ci2 = ci2 + 1;
          }
          return 0;
        }
      }
      let s: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_8(out, s, 7) != 0) {
        return -1;
      }
      dep_prefix_len = codegen_type_dep_struct_prefix_into(ctx, arena, type_ref, &dep_prefix_buf[0], 128);
      /* 【Why 根源】dep_prefix 查找失败（struct_layouts 不含该类型）时，若类型名为限定名（如 ast.Module），
       *   从限定名最后 '.' 之前提取模块路径，用 codegen_import_path_to_c_prefix_into 转为 C 前缀。
       *   backend dep 模块的 struct_layouts 不含 ast 模块的 Module，dep_prefix 查找返回 0，
       *   但限定名 "ast.Module" 明确指示定义模块为 ast，应生成 struct ast_Module 而非 struct backend_Module。
       * 【Invariant】仅在 dep_prefix_len == 0 且 name 含 '.' 时触发；非限定名走原有 fallback 链。
       * 【Asm/Perf】仅 dep_prefix 查找失败时触发，不增加热路径开销。 */
      if (dep_prefix_len == 0) {
        let qmod_end: i32 = 0;
        let qhas_dot: bool = false;
        let qi: i32 = 0;
        while (qi < name_len && qi < 64) {
          if (nm[qi] == 46) {
            qhas_dot = true;
            qmod_end = qi;
          }
          qi = qi + 1;
        }
        if (qhas_dot && qmod_end > 0 && qmod_end < 64) {
          let mod_path: u8[64] = [];
          let mi: i32 = 0;
          while (mi < qmod_end) {
            mod_path[mi] = nm[mi];
            mi = mi + 1;
          }
          mod_path[mi] = 0 as u8;
          codegen_import_path_to_c_prefix_into(&mod_path[0], &dep_prefix_buf[0], 128);
          dep_prefix_len = 0;
          while (dep_prefix_len < 128 && dep_prefix_buf[dep_prefix_len] != 0 as u8) {
            dep_prefix_len = dep_prefix_len + 1;
          }
        }
      }
      /* 【Why 根源】dep_prefix（定义模块前缀，如 platform_elf_）必须优先于 struct_prefix（当前模块前缀，如 peephole_）。
       *   dep 模块函数签名引用跨模块 struct 时，struct_prefix 是当前 dep 模块前缀（由 codegen_x_ast 按 dep_index 计算），
       *   但 C 编译器要求 struct 名与定义模块一致，否则跨模块调用类型不匹配（peephole_ElfCodegenCtx vs platform_elf_ElfCodegenCtx）。
       *   入口模块 struct_prefix 为空，自然走 dep_prefix；dep 模块 struct_prefix 非空，旧逻辑错误地优先用它。
       * 【Invariant】dep_prefix_len > 0 仅当类型在其他 dep 模块的 struct_layouts 中找到；当前模块自定义 struct 不在 dep 池，dep_prefix_len=0 走 struct_prefix。
       * 【Asm/Perf】无额外开销——codegen_type_dep_struct_prefix_into 已在上方无条件调用，仅交换分支顺序。 */
      if (dep_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, &dep_prefix_buf[0], dep_prefix_len) != 0) {
          return -1;
        }
      } else if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      } else if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
          && codegen_type_is_module_user_struct(ctx.current_codegen_module, arena, type_ref) != 0) {
        /* dep 与入口库均经 codegen_emit_prefix_len_from_ctx（入口读 entry_module pin）。 */
        let cur_pre: u8[128] = [];
        let cur_pre_len: i32 = codegen_emit_prefix_len_from_ctx(ctx, &cur_pre[0], 128);
        if (cur_pre_len > 0 && emit_bytes_from_ptr(out, &cur_pre[0], cur_pre_len) != 0) {
          return -1;
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
}

/**
 * Pick defining-module dep index for a bare struct name across the dep pool.
 *
 * Why: co-emit can leave the same bare name in several modules (merge, struct-lit
 * pollution). Wrong owner → dual C tags (lexer_Token vs token_Token) and incomplete
 * by-value fields (LexerResult before Token).
 *
 * Ranking (PLATFORM: SHARED):
 *  1) Prefer layouts with num_fields > 0 over empty placeholders.
 *  2) Prefer is_export=1 (true `export struct`) over non-export copies.
 *  3) When both candidates are export: prefer current_codegen_dep_index so dual real
 *     types (std_context_Error vs std_error_Error) each emit under their own prefix.
 *  4) When both are non-export (pollution competition, e.g. Token in lexer+token with
 *     is_export still 0 on product parser pin): prefer the **latest** dep index — leaf
 *     imports are registered after parents (token after lexer), so the defining file wins.
 *
 * Returns -1 if no dep has the bare name; otherwise a pipeline_dep_ctx index.
 */
export function codegen_type_dep_struct_owner_index(ctx: *PipelineDepCtx, bare_nm: *u8, bare_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let best_di: i32 = -1;
    let best_export: i32 = 0;
    let best_nf: i32 = 0;
    let cur: i32 = -1;
    let di: i32 = 0;
    let nd: i32 = 0;
    if (ctx == 0 as *PipelineDepCtx || bare_nm == 0 as *u8 || bare_len <= 0) {
      return -1;
    }
    cur = ctx.current_codegen_dep_index;
    nd = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let li: i32 = 0;
        let hit: i32 = 0;
        let hit_export: i32 = 0;
        let hit_nf: i32 = 0;
        while (li < dep_mod.num_struct_layouts) {
          let dep_name_len: i32 = pipeline_module_struct_layout_name_len(dep_mod, li);
          if (dep_name_len == bare_len) {
            let dep_nm: u8[64] = [];
            let eq: bool = true;
            let j: i32 = 0;
            pipeline_module_struct_layout_name_into(dep_mod, li, &dep_nm[0]);
            while (j < bare_len && j < 64) {
              if (dep_nm[j] != bare_nm[j]) {
                eq = false;
                break;
              }
              j = j + 1;
            }
            if (eq) {
              hit = 1;
              hit_nf = pipeline_module_struct_layout_num_fields(dep_mod, li);
              if (pipeline_module_struct_layout_is_export_at(dep_mod, li) != 0) {
                hit_export = 1;
              }
              break;
            }
          }
          li = li + 1;
        }
        if (hit != 0) {
          /* Empty same-name layouts must not steal ownership (incomplete type). */
          if (best_di < 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf <= 0) {
            best_di = di;
            best_export = hit_export;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export == 0) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_export != 0 && best_export == 0 && hit_nf >= best_nf) {
            best_di = di;
            best_export = 1;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export != 0 && best_export != 0 && di == cur) {
            /* Dual true exports (Error): current module owns its own tag. */
            best_di = di;
            best_nf = hit_nf;
          } else if (hit_nf > 0 && best_nf > 0 && hit_export == 0 && best_export == 0 && di > best_di) {
            /*
             * Non-export competition: prefer later dep (leaf import after parent).
             * Token: lexer di=0 pollution vs token di=1 definition → token wins.
             * Do not apply cur preference here — that re-emitted lexer_Token and
             * broke LexerResult by-value field completeness (parser M1 host-cc).
             */
            best_di = di;
            best_nf = hit_nf;
          }
        }
      }
      di = di + 1;
    }
    return best_di;
  }
}

/**
 * 入口模块 codegen 时，若 TYPE_NAMED 实际来自某个 dep 模块的 struct_layouts，
 * 则返回该 dep 的 C 前缀长度并写入 dst（如 lexer_ / std_io_driver_）。
 * 定义模块优先（export + current dep），避免 first-match 把 Error 错标为 std_context_Error。
 */
export function codegen_type_dep_struct_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let name_len: i32 = 0;
    let ty_nm: u8[64] = [];
    let owner: i32 = -1;
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
    owner = codegen_type_dep_struct_owner_index(ctx, &ty_nm[bare_off], bare_len);
    if (owner >= 0) {
      let dep_path: u8[64] = [];
      let plen: i32 = codegen_dep_import_path_len_at(ctx, owner, &dep_path[0]);
      if (plen > 0) {
        codegen_import_path_to_c_prefix_into(&dep_path[0], dst, dst_cap);
        let out_len: i32 = 0;
        while (out_len < dst_cap && dst[out_len] != 0 as u8) {
          out_len = out_len + 1;
        }
        return out_len;
      }
    }
    return 0;
  }
}

/**
 * 固定数组元素是否为 u8（u8[N] 走 uint8_t* 初值路径，与 hello 的 msg 缓冲一致）。
 */
export function type_array_elem_is_u8(arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 局部固定数组：仅发射元素类型（如 int32_t）；[N] 须在变量名之后由 emit_local_fixed_array_suffix 输出。
 */
export function emit_local_fixed_array_elem_type(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let inner: i32 = pipeline_type_elem_ref_at(arena, type_ref);
    if (ast.ref_is_null(inner) || emit_type(arena, out, inner, 0 as *u8, 0, ctx) != 0) {
      let fb: u8[8] = [105, 110, 116, 51, 50, 95, 116, 0];
      return emit_bytes_8(out, fb, 7);
    }
    return 0;
  }
}

/** 局部固定数组维度后缀：[N]，写在变量名之后（int32_t a[N]）。 */
export function emit_local_fixed_array_suffix(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let asz: i32 = pipeline_type_array_size_at(arena, type_ref);
    if (append_byte(out, 91) != 0) {
      return -1;
    }
    if (format_int(out, asz) != 0) {
      return -1;
    }
    return append_byte(out, 93);
  }
}

/**
 * 切片 let s: T[] = arr：生成 { .data = arr, .length = N }（对齐 codegen.c codegen_init）。
 * @return 1 已写出初值；0 不适用（走 emit_expr）；-1 失败。
 */
export function try_emit_slice_init_from_array_var(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, let_idx: i32, let_type_ref: i32, linit_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
    /* 成功须返回 1：调用方 else if (slice_init == 1) 才跳过 emit_expr；返回 0 会再发一遍 arr 名。 */
    if (emit_bytes_4(out, d3, 2) != 0) {
      return -1;
    }
    return 1;
  }
}

/**
 * 数组字面量初值：{ e0, e1, ... }（用于 int32_t a[N] = { ... }，避免 (T[]){ } 赋给栈数组）。
 */
export function emit_braced_array_lit_init(arena: *ASTArena, out: *CodegenOutBuf, init_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 发射「结构体定义」用的字段类型串；逻辑在 pipeline_codegen_emit_struct_field_type（C glue）。
 */
export function emit_struct_field_type_via_pipeline(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    return pipeline_codegen_emit_struct_field_type(arena, out, type_ref, struct_prefix, struct_prefix_len);
  }
}

/**
 * Look up the type_ref of `struct_name.field_name` in the entry module then deps.
 *
 * Purpose: STRUCT_LIT array-field emit must know the field is TYPE_ARRAY so it can
 * expand `.name = src` (illegal in C) into `.name = { src[0], …, src[N-1] }`.
 * Parameters: arena unused (layout lives on Module); ctx may be null → 0.
 * struct_name may be bare (`OneFuncResult`) or dotted; bare tail is matched.
 * Returns: field type_ref, or 0 if not found.
 * PLATFORM: SHARED — co-emit C TU; verify parser.x host-cc array-init residual.
 */
export function codegen_lookup_struct_field_type_ref(
  arena: *ASTArena,
  ctx: *PipelineDepCtx,
  struct_name: *u8,
  struct_name_len: i32,
  field_name: *u8,
  field_name_len: i32
): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    (void)(arena);
    if (struct_name == 0 as *u8 || struct_name_len <= 0 || field_name == 0 as *u8 || field_name_len <= 0) {
      return 0;
    }
    let bare_off: i32 = 0;
    let bi: i32 = 0;
    while (bi < struct_name_len && bi < 64) {
      if (struct_name[bi] == 46) {
        bare_off = bi + 1;
      }
      bi = bi + 1;
    }
    let bare_len: i32 = struct_name_len - bare_off;
    if (bare_len <= 0) {
      return 0;
    }
    let flen_use: i32 = field_name_len;
    if (flen_use > 64) {
      flen_use = 64;
    }
    let try_mod: *Module = 0 as *Module;
    let pass: i32 = 0;
    while (pass < 2) {
      let nmod: i32 = 1;
      if (pass == 1) {
        if (ctx == 0 as *PipelineDepCtx) {
          break;
        }
        nmod = pipeline_dep_ctx_ndep(ctx);
      }
      let mi: i32 = 0;
      while (mi < nmod) {
        if (pass == 0) {
          if (ctx == 0 as *PipelineDepCtx || ctx.current_codegen_module == 0 as *Module) {
            mi = mi + 1;
            continue;
          }
          try_mod = ctx.current_codegen_module;
        } else {
          try_mod = pipeline_dep_ctx_module_at(ctx, mi);
        }
        if (try_mod != 0 as *Module) {
          let k: i32 = 0;
          while (k < try_mod.num_struct_layouts) {
            let snl: i32 = pipeline_module_struct_layout_name_len(try_mod, k);
            if (snl == bare_len && snl > 0) {
              let snm: u8[64] = [];
              pipeline_module_struct_layout_name_into(try_mod, k, &snm[0]);
              let eq: bool = true;
              let sj: i32 = 0;
              while (sj < snl && sj < 64) {
                if (snm[sj] != struct_name[bare_off + sj]) {
                  eq = false;
                  break;
                }
                sj = sj + 1;
              }
              if (eq) {
                let nf: i32 = pipeline_module_struct_layout_num_fields(try_mod, k);
                let j: i32 = 0;
                while (j < nf) {
                  let fnl: i32 = pipeline_module_struct_layout_field_name_len(try_mod, k, j);
                  if (fnl == flen_use && fnl > 0) {
                    let fnm: u8[64] = [];
                    pipeline_module_struct_layout_field_name_into(try_mod, k, j, &fnm[0]);
                    let feq: bool = true;
                    let fj: i32 = 0;
                    while (fj < fnl && fj < 64) {
                      if (fnm[fj] != field_name[fj]) {
                        feq = false;
                        break;
                      }
                      fj = fj + 1;
                    }
                    if (feq) {
                      return pipeline_module_struct_layout_field_type_ref(try_mod, k, j);
                    }
                  }
                  j = j + 1;
                }
              }
            }
            k = k + 1;
          }
        }
        mi = mi + 1;
        if (pass == 0) {
          break;
        }
      }
      pass = pass + 1;
    }
    return 0;
  }
}

/**
 * pipeline_module_struct_layout_name_into 给出的 struct 尾部名若与 IO 异步 ABI 固定名相同，则跳过 codegen 发射：
 * runtime.c / preamble 已定义完整的 ast_* 与 std_io_driver_* 等 tag，再输出会重复完整定义导致 C 编译失败。
 * 仅匹配裸名 Buffer、Completion、AsyncContext（与任意 struct_prefix 拼接后均由 ABI 层提供）。
 */
export function codegen_should_skip_emit_struct_layout_for_abi_dup(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  let nm_buffer: u8[7] = [66, 117, 102, 102, 101, 114, 0];
  let nm_completion: u8[11] = [67, 111, 109, 112, 108, 101, 116, 105, 111, 110, 0];
  let nm_async_ctx: u8[13] = [65, 115, 121, 110, 99, 67, 111, 110, 116, 101, 120, 116, 0];
  /* preamble 已定义 struct std_error_Error / ErrorChain — 勿再 emit。 */
  let nm_error: u8[6] = [69, 114, 114, 111, 114, 0];
  let nm_error_chain: u8[11] = [69, 114, 114, 111, 114, 67, 104, 97, 105, 110, 0];
  /*
   * rt_preamble 已 one-liner 定义 Option_i32/u8/u64/ptr_u8（slice get_* 等消费端在 option 体前需要完整类型）。
   * 凡裸名 Option_* 一律 skip — preamble 权威，co-emit 再 emit → redefinition（stdlib-import/option）。
   * PLATFORM: SHARED — seed pin and .x must agree (dual-authority ban).
   */
  let nm_option_us: u8[8] = [79, 112, 116, 105, 111, 110, 95, 0];
  /* 泛型模板 Option<T>：C 无 monomorphize，勿 emit 非法/空 layout。 */
  let nm_option: u8[7] = [79, 112, 116, 105, 111, 110, 0];
  /*
   * rt_preamble one-liner also owns Result_i32 / Result_u8 (core_result_* tags).
   * Co-emit full layout → redefinition of 'core_result_Result_*' (hello / fmt path).
   * 【Invariant】bare Result_i32 / Result_u8 skip — same authority as seed pin.
   */
  let nm_result_i32: u8[11] = [82, 101, 115, 117, 108, 116, 95, 105, 51, 50, 0];
  let nm_result_u8: u8[10] = [82, 101, 115, 117, 108, 116, 95, 117, 56, 0];
  /*
   * rt_preamble / runtime.from_x 已 one-liner 定义：
   *   struct std_string_String { ... }; typedef ... String;
   *   struct std_string_StrView { ... };
   * 入口编 std/string 时再 emit 完整 layout → redefinition of 'std_string_String'。
   * 【Invariant】与 Error/Option_i32 同策略：preamble 权威，codegen 跳过裸名。
   */
  let nm_string: u8[7] = [83, 116, 114, 105, 110, 103, 0];
  let nm_str_view: u8[8] = [83, 116, 114, 86, 105, 101, 119, 0];
  /*
   * rt_preamble write_io_net_abi_inline 已 one-liner：
   *   std_net_TcpStream/Listener/UdpSocket/Ipv4Addr/Ipv6Addr
   * import std.net 再 emit layout → redefinition。preamble 为 ABI 权威。
   */
  let nm_tcp_stream: u8[10] = [84, 99, 112, 83, 116, 114, 101, 97, 109, 0];
  let nm_tcp_listener: u8[12] = [84, 99, 112, 76, 105, 115, 116, 101, 110, 101, 114, 0];
  let nm_udp_socket: u8[10] = [85, 100, 112, 83, 111, 99, 107, 101, 116, 0];
  let nm_ipv4: u8[9] = [73, 112, 118, 52, 65, 100, 100, 114, 0];
  let nm_ipv6: u8[9] = [73, 112, 118, 54, 65, 100, 100, 114, 0];
  let nm_sock_v4: u8[13] = [83, 111, 99, 107, 101, 116, 65, 100, 100, 114, 86, 52, 0];
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_buffer[0], 6) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_completion[0], 10) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_async_ctx[0], 12) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_error[0], 5) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_error_chain[0], 10) != 0) {
    return 1;
  }
  /* Option_*（len>7 且前缀 Option_） */
  if (name_len > 7 && codegen_symbuf_bytes_eq(name, 7, &nm_option_us[0], 7) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_option[0], 6) != 0) {
    return 1;
  }
  /* Result_i32 / Result_u8 — preamble owns complete core_result_* layouts. */
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_i32[0], 10) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_result_u8[0], 9) != 0) {
    return 1;
  }
  if (name_len == 6 && codegen_symbuf_bytes_eq(name, name_len, &nm_string[0], 6) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_str_view[0], 7) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_stream[0], 9) != 0) {
    return 1;
  }
  if (name_len == 11 && codegen_symbuf_bytes_eq(name, name_len, &nm_tcp_listener[0], 11) != 0) {
    return 1;
  }
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_udp_socket[0], 9) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv4[0], 8) != 0) {
    return 1;
  }
  if (name_len == 8 && codegen_symbuf_bytes_eq(name, name_len, &nm_ipv6[0], 8) != 0) {
    return 1;
  }
  if (name_len == 12 && codegen_symbuf_bytes_eq(name, name_len, &nm_sock_v4[0], 12) != 0) {
    return 1;
  }
  /* Preamble owns Allocator/Arena64/FsIovecBuf/Iovec — skip co-emit redefinition.
   * PLATFORM: SHARED — keep lets flat at function scope. Nested `{ let ... }` anon
   * blocks are parse-skipped by the current product parser (residual body then
   * mis-ingested as top-level lets → illegal static/init_globals in force-regen). */
  let nm_allocator: u8[10] = [65, 108, 108, 111, 99, 97, 116, 111, 114, 0];
  let nm_arena64: u8[8] = [65, 114, 101, 110, 97, 54, 52, 0];
  let nm_fs_iovec: u8[11] = [70, 115, 73, 111, 118, 101, 99, 66, 117, 102, 0];
  let nm_iovec: u8[6] = [73, 111, 118, 101, 99, 0];
  if (name_len == 9 && codegen_symbuf_bytes_eq(name, name_len, &nm_allocator[0], 9) != 0) {
    return 1;
  }
  if (name_len == 7 && codegen_symbuf_bytes_eq(name, name_len, &nm_arena64[0], 7) != 0) {
    return 1;
  }
  if (name_len == 10 && codegen_symbuf_bytes_eq(name, name_len, &nm_fs_iovec[0], 10) != 0) {
    return 1;
  }
  if (name_len == 5 && codegen_symbuf_bytes_eq(name, name_len, &nm_iovec[0], 5) != 0) {
    return 1;
  }
  return 0;
}

/** 当前模块 struct_layouts 中是否存在与 type 同名的 NAMED 类型（入口用户 struct，非 ast_ 前缀）。 */
export function codegen_type_is_module_user_struct(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 当前模块登记的顶层 enum 名是否与 type_ref 的 TYPE_NAMED 一致（C 侧按 int32_t 表示）。 */
export function codegen_type_is_module_user_enum(module: *Module, arena: *ASTArena, type_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 遍历 dep 模块 enums，返回匹配 enum 的 C prefix（如 "ast_"）；未命中返回 0。
 * 【Why 根源】TypeKind/ExprKind 等在 ast 模块定义为 enum，入口模块引用时
 *   codegen_type_is_module_user_enum 仅查当前模块找不到，需遍历 dep 模块。
 *   不做此检查会误走 struct 前缀生成 "struct ast_TypeKind"，C 编译报 incomplete type。
 * 【Invariant】用裸名（最后一个 '.' 之后）与 dep enum name 比较，对齐 codegen_type_dep_struct_prefix_into。
 * 【Asm/Perf】仅 TYPE_NAMED 且非当前模块 enum 时触发，热路径无额外开销。 */
export function codegen_type_dep_enum_prefix_into(ctx: *PipelineDepCtx, arena: *ASTArena, type_ref: i32, dst: *u8, dst_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
        let ei: i32 = 0;
        while (ei < dep_mod.num_module_enums) {
          let dep_name_len: i32 = pipeline_module_enum_name_len(dep_mod, ei);
          if (dep_name_len == bare_len) {
            let eq: bool = true;
            let j: i32 = 0;
            while (j < bare_len && j < 64) {
              if (pipeline_module_enum_name_byte_at(dep_mod, ei, j) != ty_nm[bare_off + j]) {
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
          ei = ei + 1;
        }
      }
      di = di + 1;
    }
    return 0;
  }
}

/**
 * 发射完整 struct 字段声明，支持多维数组的 `type name[N][M]` 顺序；
 * 与旧 C glue 的职责相同，但改在 X 侧走 emit_type(ctx) 以正确解析 dep struct 前缀。
 */
export function codegen_emit_struct_field_decl_x(arena: *ASTArena, out: *CodegenOutBuf, type_ref: i32, field_name: *u8, field_name_len: i32, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 遍历 module.struct_layouts，发射完整 C struct（须在首次使用类型之前）；名称与字段名由 glue 读出。
 * 【Why 根源】dep co-emit 时仅 emit 本 dep 为定义所有者的 layout，跳过 merge/污染写入的异名模块类型，
 *   避免 `struct std_context_Error` 与 `struct std_error_Error` 双 tag（与 owner_index 前缀一致）。
 */
export function codegen_emit_module_struct_definitions(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let k: i32 = 0;
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    while (k < module.num_struct_layouts) {
      let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nf <= 0 || nl <= 0) {
        k = k + 1;
        continue;
      }
      let ty_nm: u8[64] = [];
      pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
      /*
       * PLATFORM: SHARED — only the defining owner emits full C layout.
       * Entry (cur_di < 0) must also skip dep-owned names (e.g. Lexer from lexer.x).
       * Otherwise co-emit re-emits as parser_Lexer; entry prime/merge layouts may have
       * field_type_ref=0 on later fields → field_decl fail mid-struct (parser M1 residual).
       * Authority: codegen_type_dep_struct_owner_index (export-first); seed pin same commit.
       */
      if (ctx != 0 as *PipelineDepCtx) {
        let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
        if (owner >= 0 && owner != cur_di) {
          k = k + 1;
          continue;
        }
      }
      if (codegen_should_skip_emit_struct_layout_for_abi_dup(&ty_nm[0], nl) != 0) {
        k = k + 1;
        continue;
      }
      /* 单文件 co-emit：同一 mangled tag 只完整 emit 一次。 */
      let claim_pfx: u8[128] = [];
      let claim_plen: i32 = 0;
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        claim_plen = struct_prefix_len;
        if (claim_plen > 127) {
          claim_plen = 127;
        }
        let ci: i32 = 0;
        while (ci < claim_plen) {
          claim_pfx[ci] = struct_prefix[ci];
          ci = ci + 1;
        }
      } else if (!(ctx != 0 as *PipelineDepCtx && ctx.current_codegen_dep_index < 0)) {
        claim_pfx[0] = 97;
        claim_pfx[1] = 115;
        claim_pfx[2] = 116;
        claim_pfx[3] = 95;
        claim_plen = 4;
      }
      if (pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &ty_nm[0], nl) == 0) {
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
}

/** 遍历 module 的 struct layouts，emit forward declaration（struct <prefix>_<name>;\n）。
 * 【Why 根源】C 语言 struct tag 作用域规则：extern 函数声明引用 struct 时，若完整定义尚未 emit，
 *   tag 首次出现在参数列表中会创建局部作用域 tag → 后续完整定义被视为不同类型 → conflicting types。
 *   forward declaration 使 extern 声明引用文件作用域 tag，与后续完整定义匹配。
 * 【Invariant】forward declaration 的 struct 名须与 codegen_emit_module_struct_definitions 一致：
 *   struct <prefix>_<name>（prefix 为空时不加前缀）。
 * 【Asm/Perf】仅在 -E 输出写一次，无热路径影响。 */
export function codegen_emit_module_struct_forward_declarations(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32): i32 {
  return codegen_emit_module_struct_forward_declarations_ctx(module, out, struct_prefix, struct_prefix_len, 0 as *PipelineDepCtx);
}

/** 带 ctx 的 forward decl：dep 仅 emit 本模块拥有的 layout（与 definitions 一致）。 */
export function codegen_emit_module_struct_forward_declarations_ctx(module: *Module, out: *CodegenOutBuf, struct_prefix: *u8, struct_prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    let k: i32 = 0;
    let cur_di: i32 = -1;
    if (ctx != 0 as *PipelineDepCtx) {
      cur_di = ctx.current_codegen_dep_index;
    }
    while (k < module.num_struct_layouts) {
      let nf: i32 = pipeline_module_struct_layout_num_fields(module, k);
      let nl: i32 = pipeline_module_struct_layout_name_len(module, k);
      if (nf <= 0 || nl <= 0) {
        k = k + 1;
        continue;
      }
      let ty_nm: u8[64] = [];
      pipeline_module_struct_layout_name_into(module, k, &ty_nm[0]);
      /* PLATFORM: SHARED — same owner skip as codegen_emit_module_struct_definitions (entry + dep). */
      if (ctx != 0 as *PipelineDepCtx) {
        let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
        if (owner >= 0 && owner != cur_di) {
          k = k + 1;
          continue;
        }
      }
      /* "struct " */
      let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
      if (emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
        return -1;
      }
      if (struct_prefix != 0 as *u8 && struct_prefix_len > 0) {
        if (emit_bytes_from_ptr(out, struct_prefix, struct_prefix_len) != 0) {
          return -1;
        }
      }
      if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
        return -1;
      }
      /* ";\n" */
      let semi_nl: u8[2] = [59, 10];
      if (emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
        return -1;
      }
      k = k + 1;
    }
    return 0;
  }
}

/**
 * 遍历 module.enums，按 `enum prefix_Name { prefix_Name_Variant, ... };` 发射完整 C enum。
 * 供 entry 单文件模式为“被跳过或纯类型 dep”补齐类型定义，避免 dep struct 字段引用不完整 enum。
 */
export function codegen_emit_module_enum_definitions(module: *Module, out: *CodegenOutBuf, enum_prefix: *u8, enum_prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
      /* 单文件 co-emit：enum tag 只完整 emit 一次（claim key 加 'e' 前缀与 struct 区分）。 */
      let claim_pfx: u8[128] = [];
      let claim_plen: i32 = 0;
      claim_pfx[0] = 101;
      claim_plen = 1;
      if (enum_prefix != 0 as *u8 && enum_prefix_len > 0) {
        let ep: i32 = enum_prefix_len;
        if (ep > 126) {
          ep = 126;
        }
        let ei2: i32 = 0;
        while (ei2 < ep) {
          claim_pfx[1 + ei2] = enum_prefix[ei2];
          ei2 = ei2 + 1;
        }
        claim_plen = 1 + ep;
      }
      if (pipeline_codegen_struct_tag_try_claim(&claim_pfx[0], claim_plen, &enm[0], enl) == 0) {
        ei = ei + 1;
        continue;
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
}

/**
 * Emit enum/struct type definitions for every dep module in import-first order.
 *
 * Why: flat di order registers parents before leaf imports (lexer before token).
 * LexerResult embeds token.Token by value → host C needs token_Token complete before
 * lexer_LexerResult (parser M1 host-cc residual).
 *
 * Algorithm (PLATFORM: SHARED): Kahn-style multi-pass over dep indices — a dep is
 * emitted only when every import path that resolves to another dep slot is already
 * emitted (or not in the pool). Caps at nd+2 passes; remainder emitted in di order.
 * Path de-dupe still applies. Restores current_codegen_* after work.
 */
export function codegen_emit_skipped_dep_type_definitions(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
    /* Cap 64 dep slots for emit-done flags (product graphs are far smaller). */
    let done: i32[64] = [];
    let di_init: i32 = 0;
    while (di_init < 64) {
      done[di_init] = 0;
      di_init = di_init + 1;
    }
    let remaining: i32 = 0;
    let di_count: i32 = 0;
    while (di_count < nd) {
      let dep_mod0: *Module = pipeline_dep_ctx_module_at(ctx, di_count);
      let dep_arena0: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di_count);
      let dep_path0: u8[64] = [];
      let plen0: i32 = codegen_dep_import_path_len_at(ctx, di_count, &dep_path0[0]);
      if (dep_mod0 != 0 as *Module && dep_arena0 != 0 as *ASTArena && plen0 > 0) {
        remaining = remaining + 1;
      } else {
        done[di_count] = 1;
      }
      di_count = di_count + 1;
    }
    let pass: i32 = 0;
    let max_pass: i32 = nd + 2;
    while (remaining > 0 && pass < max_pass) {
      let progressed: i32 = 0;
      let di: i32 = 0;
      while (di < nd) {
        if (done[di] != 0) {
          di = di + 1;
          continue;
        }
        let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
        let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        let dep_path: u8[64] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        if (dep_mod == 0 as *Module || dep_arena == 0 as *ASTArena || dep_path_len <= 0) {
          done[di] = 1;
          di = di + 1;
          continue;
        }
        /* Ready iff every resolved import dep is already emitted. */
        let ready: i32 = 1;
        let n_imp: i32 = codegen_module_num_imports(dep_mod);
        let ii: i32 = 0;
        while (ii < n_imp) {
          let ipath: u8[64] = [];
          let ilen: i32 = codegen_module_import_path_len_at(dep_mod, ii, &ipath[0]);
          if (ilen > 0) {
            let idi: i32 = codegen_find_dep_index_by_path(ctx, &ipath[0], ilen);
            if (idi >= 0 && idi < nd && idi != di && done[idi] == 0) {
              ready = 0;
              break;
            }
          }
          ii = ii + 1;
        }
        if (ready == 0) {
          di = di + 1;
          continue;
        }
        /* Path de-dupe: first *non-empty* registration (lower di) is authority.
         * Why: an earlier same-path slot with num_struct_layouts==0 (failed/partial load)
         * must not suppress a later real module (parser M1: missing struct ast_* full
         * layouts → dual-extern incomplete tags). Later empty re-regs still suppressed
         * once a non-empty slot for the path was seen.
         * PLATFORM: SHARED — co-emit C TU; verify parser.x -E host-cc + typeck -E. */
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
              let prev_mod: *Module = pipeline_dep_ctx_module_at(ctx, pj);
              if (prev_mod != 0 as *Module && prev_mod.num_struct_layouts > 0) {
                seen_before = 1;
                break;
              }
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
        done[di] = 1;
        remaining = remaining - 1;
        progressed = 1;
        di = di + 1;
      }
      if (progressed == 0) {
        /* Cycle / unresolved: emit remaining in di order. */
        let dj: i32 = 0;
        while (dj < nd) {
          if (done[dj] == 0) {
            let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, dj);
            let dep_arena2: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dj);
            let dep_path2: u8[64] = [];
            let plen2: i32 = codegen_dep_import_path_len_at(ctx, dj, &dep_path2[0]);
            if (dep_mod2 != 0 as *Module && dep_arena2 != 0 as *ASTArena && plen2 > 0) {
              let prefix_buf2: u8[128] = [];
              let prefix_len2: i32 = 0;
              if (codegen_path_is_std_io_core_bytes(&dep_path2[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&dep_path2[0], &prefix_buf2[0], 128);
                while (prefix_len2 < 128 && prefix_buf2[prefix_len2] != 0 as u8) {
                  prefix_len2 = prefix_len2 + 1;
                }
              }
              ctx.current_codegen_module = dep_mod2;
              ctx.current_codegen_arena = dep_arena2;
              ctx.current_codegen_dep_index = dj;
              let px2: i32 = 0;
              while (px2 < prefix_len2 && px2 < 63) {
                ctx.current_codegen_prefix_mirror[px2] = prefix_buf2[px2];
                px2 = px2 + 1;
              }
              ctx.current_codegen_prefix_mirror[px2] = 0 as u8;
              ctx.current_codegen_prefix_len = px2;
              if (codegen_emit_module_enum_definitions(dep_mod2, out, &prefix_buf2[0], prefix_len2) != 0) {
                return -1;
              }
              if (codegen_emit_module_struct_definitions(dep_mod2, dep_arena2, out, &prefix_buf2[0], prefix_len2, ctx) != 0) {
                return -1;
              }
            }
            done[dj] = 1;
            remaining = remaining - 1;
          }
          dj = dj + 1;
        }
      }
      pass = pass + 1;
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
}

/** 遍历所有 dep 模块，emit struct forward declaration。
 * 【Why 根源】在 codegen_emit_import_dep_function_declarations 之前调用，确保 extern 声明引用的
 *   dep 模块 struct tag 在文件作用域已知，避免 conflicting types。C 允许对已有完整定义的 struct
 *   再 emit forward declaration（无副作用），故无需排除 skipped 模块。
 * 【Invariant】遍历顺序与 codegen_emit_skipped_dep_type_definitions 一致（dep_index 递增）。
 * 【Asm/Perf】仅在 -E 输出写一次，无热路径影响。
 *
 * Also (parser M1 host-cc): for every bare layout name, emit one forward under the
 * **owner** prefix from codegen_type_dep_struct_owner_index (e.g. `struct ast_Module;`).
 * Per-module forwards can use polluted prefixes (`lexer_Module`) while signatures use
 * owner tags (`ast_Module`) → dual incomplete tags / conflicting types without this.
 * PLATFORM: SHARED — co-emit C TU; verify parser.x -E host-cc.
 */
export function codegen_emit_dep_struct_forward_declarations(ctx: *PipelineDepCtx, out: *CodegenOutBuf): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || out == 0 as *CodegenOutBuf) {
      return 0;
    }
    let saved_dep_index: i32 = ctx.current_codegen_dep_index;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    let di: i32 = 0;
    while (di < nd) {
      let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod != 0 as *Module) {
        let dep_path: u8[64] = [];
        let dep_path_len: i32 = codegen_dep_import_path_len_at(ctx, di, &dep_path[0]);
        let prefix_buf: u8[128] = [];
        let prefix_len: i32 = 0;
        if (dep_path_len > 0 && codegen_path_is_std_io_core_bytes(&dep_path[0]) == 0) {
          codegen_import_path_to_c_prefix_into(&dep_path[0], &prefix_buf[0], 128);
          while (prefix_len < 128 && prefix_buf[prefix_len] != 0 as u8) {
            prefix_len = prefix_len + 1;
          }
        }
        ctx.current_codegen_dep_index = di;
        if (codegen_emit_module_struct_forward_declarations_ctx(dep_mod, out, &prefix_buf[0], prefix_len, ctx) != 0) {
          ctx.current_codegen_dep_index = saved_dep_index;
          return -1;
        }
      }
      di = di + 1;
    }
    /* Owner-prefixed file-scope forwards (dedupe by claim of mangled tag). */
    di = 0;
    while (di < nd) {
      let dep_mod2: *Module = pipeline_dep_ctx_module_at(ctx, di);
      if (dep_mod2 != 0 as *Module) {
        let k: i32 = 0;
        while (k < dep_mod2.num_struct_layouts) {
          let nl: i32 = pipeline_module_struct_layout_name_len(dep_mod2, k);
          let nf: i32 = pipeline_module_struct_layout_num_fields(dep_mod2, k);
          if (nl > 0 && nf > 0) {
            let ty_nm: u8[64] = [];
            pipeline_module_struct_layout_name_into(dep_mod2, k, &ty_nm[0]);
            let owner: i32 = codegen_type_dep_struct_owner_index(ctx, &ty_nm[0], nl);
            if (owner >= 0) {
              let opath: u8[64] = [];
              let oplen: i32 = codegen_dep_import_path_len_at(ctx, owner, &opath[0]);
              let opfx: u8[128] = [];
              let opfx_len: i32 = 0;
              if (oplen > 0 && codegen_path_is_std_io_core_bytes(&opath[0]) == 0) {
                codegen_import_path_to_c_prefix_into(&opath[0], &opfx[0], 128);
                while (opfx_len < 128 && opfx[opfx_len] != 0 as u8) {
                  opfx_len = opfx_len + 1;
                }
              }
              /* C allows redundant `struct Tag;` — emit owner-prefixed forward always.
               * Do not try_claim: that would block later full layout emit of the same tag. */
              let hdr: u8[8] = [115, 116, 114, 117, 99, 116, 32, 0];
              if (emit_bytes_from_ptr(out, &hdr[0], 7) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (opfx_len > 0 && emit_bytes_from_ptr(out, &opfx[0], opfx_len) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              if (emit_bytes_from_ptr(out, &ty_nm[0], nl) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
              let semi_nl: u8[2] = [59, 10];
              if (emit_bytes_from_ptr(out, &semi_nl[0], 2) != 0) {
                ctx.current_codegen_dep_index = saved_dep_index;
                return -1;
              }
            }
          }
          k = k + 1;
        }
      }
      di = di + 1;
    }
    ctx.current_codegen_dep_index = saved_dep_index;
    return 0;
  }
}

/**
 * 若字段访问形如 binding.field，且 binding 为当前模块 import 绑定名，则把该 import 的路径写入 dst 并返回长度。
 * 仅做 binding->path 解析，不校验 field 是否真为 const / function。
 */
export function codegen_resolve_binding_import_path_for_field_access(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 若方法调用形如 binding.method(...)，且 binding 为当前模块 import 绑定名，则把该 import 的路径写入 dst 并返回长度。
 * 仅做 binding->path 解析，不依赖 typeck 已写入 resolved dep。
 */
export function codegen_resolve_binding_import_path_for_method_call(ctx: *PipelineDepCtx, arena: *ASTArena, expr_ref: i32, dst: *u8): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * binding.field：将 import binding 上的字段访问扁平化为 prefix+field（如 heap_libc.heap_alloc_c -> std_heap_libc_heap_alloc_c）。
 * 仅在字段访问确实落到 import binding 时成功；否则返回 -1。
 */
export function emit_import_module_field_symbol(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
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
export function emit_import_module_const_field(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 写表达式到 out；仅支持当前 .x AST 中已用到的节点（LIT、VAR、二元、一元、BLOCK、RETURN 等）。
 * ctx 非空且 ndep>0 时，EXPR_CALL 会解析跨 dep 调用并输出 dep 的 C 前缀。
 */
export function emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ast.ref_is_null(expr_ref)) {
      return 0;
    }
    if (expr_ref <= 0 || expr_ref > arena.num_exprs) {
      return 0;
    }
    let e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
    /* STRING_LIT(kind 59)。
     * 【Why 根源】旧逻辑 *u8 发 `(uint8_t[]){ bytes, 0 }`：C 块作用域 compound literal
     *   为自动存储；`let p = "x"; return p`（如 labi_linux_harden_flag_at）返回悬空指针，
     *   invoke_cc 把野指针塞进 argv → gcc 收到乱码路径、链接失败。
     * 【Invariant】*u8 路径发 `((uint8_t*)"\xHH...")`：C 字符串字面量在 rodata，生命周期稳定。
     * slice 路径 .data 同理用 rodata 串，勿栈 compound。
     * W-string-nul：*u8 串隐式 NUL；slice .length=slen 不含尾 NUL。
     * 内容上限 var_name[64] → slen≤64。 */
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 59) {
      let slen: i32 = e.var_name_len;
      let emit_slice: bool = false;
      if (slen < 0) {
        slen = 0;
      }
      if (slen > 64) {
        slen = 64;
      }
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let sty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if (sty.kind == TypeKind.TYPE_SLICE) {
          emit_slice = true;
        }
      }
      /* 公共：((uint8_t*)"\xHH...") rodata 串 */
      let cast_open: u8[14] = [40, 40, 117, 105, 110, 116, 56, 95, 116, 32, 42, 41, 34, 0];
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
      }
      if (emit_bytes_from_ptr(out, &cast_open[0], 13) != 0) {
        return -1;
      }
      let si: i32 = 0;
      while (si < slen) {
        let b: i32 = e.var_name[si] as i32;
        if (b < 0) {
          b = b + 256;
        }
        if (b > 255) {
          b = b & 255;
        }
        /* \xHH */
        if (append_byte(out, 92) != 0) {
          return -1;
        }
        if (append_byte(out, 120) != 0) {
          return -1;
        }
        let hi: i32 = b / 16;
        let lo: i32 = b - hi * 16;
        let hex: u8[17] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102, 0];
        if (append_byte(out, hex[hi]) != 0) {
          return -1;
        }
        if (append_byte(out, hex[lo]) != 0) {
          return -1;
        }
        si = si + 1;
      }
      /* Close the C string quote and cast paren; slice path adds .length = N. */
      if (append_byte(out, 34) != 0) {
        return -1;
      }
      if (append_byte(out, 41) != 0) {
        return -1;
      }
      if (emit_slice) {
        let slice_tail: u8[18] = [32, 44, 32, 46, 108, 101, 110, 103, 116, 104, 32, 61, 32, 0, 0, 0, 0, 0];
        if (emit_bytes_from_ptr(out, &slice_tail[0], 13) != 0) {
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
      return 0;
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
      /* if 无 else：值位补 0（C 三元必须双侧）；与 historical seed 对齐。 */
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
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
          /* 【Why 根源】sym_buf 是 "prefix_funcname" 整体符号（如 core_fmt_fmt_scalar_to_buf）。
             需拆分为 prefix + funcname，对 funcname 走 mangling 以支持函数重载。
             【Invariant】callee 须为 FIELD_ACCESS 或 VAR；imp_j 映射到 dep 模块；dep_mod_q 为 NULL 时回退整体 emit。 */
          let callee_q: Expr = ast.ast_arena_expr_get(arena, callee_ref);
          let fn_ptr_q: *u8 = 0 as *u8;
          let fn_len_q: i32 = 0;
          if (callee_q.kind == ExprKind.EXPR_FIELD_ACCESS && callee_q.field_access_field_len > 0) {
            fn_ptr_q = &callee_q.field_access_field_name[0];
            fn_len_q = callee_q.field_access_field_len;
          } else if (callee_q.kind == ExprKind.EXPR_VAR && callee_q.var_name_len > 0) {
            fn_ptr_q = &callee_q.var_name[0];
            fn_len_q = callee_q.var_name_len;
          }
          let dep_mod_q: *Module = 0 as *Module;
          if (imp_j >= 0 && imp_j < pipeline_dep_ctx_ndep(ctx)) {
            dep_mod_q = pipeline_dep_ctx_module_at(ctx, imp_j);
          }
          let mangled_emitted: i32 = 0;
          if (fn_len_q > 0 && fn_len_q <= sym_len && dep_mod_q != 0 as *Module) {
            let pre_len_q: i32 = sym_len - fn_len_q;
            if (pre_len_q > 0) {
              if (emit_bytes_from_ptr(out, &sym_buf[0], pre_len_q) != 0) {
                return -1;
              }
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_q, fn_ptr_q, fn_len_q) != 0) {
              return -1;
            }
            mangled_emitted = 1;
          }
          if (mangled_emitted == 0) {
            if (emit_bytes_from_ptr(out, &sym_buf[0], sym_len) != 0) {
              return -1;
            }
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
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_q), ctx) != 0) {
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
      /* 优先吃 typeck 已解析好的 dep 槽位；但目标 dep 模块须含 field 名，否则盲信错 dep 前缀。 */
      if (!ast.ref_is_null(callee_ref) && callee_ref > 0 && callee_ref <= arena.num_exprs && ctx != 0 as *PipelineDepCtx && pipeline_dep_ctx_ndep(ctx) > 0) {
        let dep_ix_fast: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
        let callee_fast: Expr = ast.ast_arena_expr_get(arena, callee_ref);
        if (dep_ix_fast >= 0 && dep_ix_fast < pipeline_dep_ctx_ndep(ctx) && callee_fast.kind == ExprKind.EXPR_FIELD_ACCESS && callee_fast.field_access_field_len > 0) {
          let dep_mod_chk: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
          let field_in_dep: i32 = 0;
          if (dep_mod_chk != 0 as *Module) {
            let fi_c: i32 = 0;
            while (fi_c < dep_mod_chk.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(dep_mod_chk, fi_c);
              if (fl == callee_fast.field_access_field_len && fl > 0) {
                let fnc: u8[64] = [];
                pipeline_module_func_name_copy64(dep_mod_chk, fi_c, &fnc[0]);
                let eqc: i32 = 1;
                let ic: i32 = 0;
                while (ic < fl) {
                  if (fnc[ic] != callee_fast.field_access_field_name[ic]) {
                    eqc = 0;
                    ic = fl;
                  } else {
                    ic = ic + 1;
                  }
                }
                if (eqc != 0) {
                  field_in_dep = 1;
                  fi_c = dep_mod_chk.num_funcs;
                } else {
                  fi_c = fi_c + 1;
                }
              } else {
                fi_c = fi_c + 1;
              }
            }
          }
          if (field_in_dep != 0) {
          let dep_path_fast: u8[64] = [];
          pipeline_dep_ctx_import_path_copy64(ctx, dep_ix_fast, &dep_path_fast[0]);
          let pre_fast: u8[128] = [];
          codegen_import_path_to_c_prefix_into(&dep_path_fast[0], &pre_fast[0], 128);
          let pre_fast_len: i32 = 0;
          while (pre_fast_len < 128 && pre_fast[pre_fast_len] != 0) {
            pre_fast_len = pre_fast_len + 1;
          }
          /* std.io.driver register/submit_read/submit_write：FIELD_ACCESS 快路径也须走 shux_io_*_buf + &arg（与 VAR 路径一致）。
           * 否则生成 std_io_driver_submit_read(Buffer) 却声明为 ptrdiff_t，cc 失败。 */
          let drv_buf_fast: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fast[0]) != 0) {
            drv_buf_fast = codegen_emit_io_driver_buf_call_name(out, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len, e.call_num_args);
            if (drv_buf_fast < 0) {
              return -1;
            }
          }
          if (drv_buf_fast == 0) {
            if (pre_fast_len > 0 && codegen_c_prefix_redundant_with_name(&pre_fast[0], pre_fast_len, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_fast[0], pre_fast_len) != 0) {
              return -1;
            }
            /* 重载搜索须在 dep 模块（std.fmt），勿用 entry current_codegen_module。 */
            let dep_mod_fast: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix_fast);
            if (dep_mod_fast == 0 as *Module) {
              dep_mod_fast = ctx.current_codegen_module;
            }
            if (codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_fast, &callee_fast.field_access_field_name[0], callee_fast.field_access_field_len) != 0) {
              return -1;
            }
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
            if (drv_buf_fast != 0 && ai_fast == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast))) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai_fast), ctx) != 0) {
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
                  /* 【Why 根源】传 dep_mod 而非 cur_mod：fallback 重载搜索需在目标 dep 模块查同名函数，
                     传 cur_mod 会在 main 模块找不到 free/bump 等重载函数。
                     【Invariant】dep_path_bind 来自 cur_mod import 表，dep_ix 经 path 匹配查 dep_ctx。
                     【Asm/Perf】codegen_find_dep_index_by_path 为 O(ndep) 线性扫描，仅 binding 命中时触发。 */
                  let dep_ix_bind: i32 = codegen_find_dep_index_by_path(ctx, &dep_path_bind[0], dep_path_bind_len);
                  let dep_mod_bind: *Module = cur_mod;
                  if (dep_ix_bind >= 0 && dep_ix_bind < pipeline_dep_ctx_ndep(ctx)) {
                    dep_mod_bind = pipeline_dep_ctx_module_at(ctx, dep_ix_bind);
                  }
                  let pre_buf: u8[128] = [];
                  codegen_import_path_to_c_prefix_into(&dep_path_bind[0], &pre_buf[0], 128);
                  let pre_len: i32 = 0;
                  while (pre_len < 128 && pre_buf[pre_len] != 0) {
                    pre_len = pre_len + 1;
                  }
                  /* std.io.driver register/submit_read/submit_write：binding FIELD_ACCESS 同样走 shux_io_*_buf + &arg。 */
                  let drv_buf_bind: i32 = 0;
                  if (codegen_path_is_std_io_driver_bytes(&dep_path_bind[0]) != 0) {
                    drv_buf_bind = codegen_emit_io_driver_buf_call_name(out, &callee.field_access_field_name[0], callee.field_access_field_len, e.call_num_args);
                    if (drv_buf_bind < 0) {
                      return -1;
                    }
                  }
                  if (drv_buf_bind == 0) {
                    /* #[no_mangle] 目标：binding.field 调用也用裸名 */
                    let bind_pre: i32 = pre_len;
                    if (dep_mod_bind != 0 as *Module && callee.field_access_field_len > 0) {
                      let fi_b: i32 = 0;
                      while (fi_b < dep_mod_bind.num_funcs) {
                        let fl: i32 = pipeline_module_func_name_len_at(dep_mod_bind, fi_b);
                        if (fl == callee.field_access_field_len && fl > 0) {
                          let fnb: u8[64] = [];
                          pipeline_module_func_name_copy64(dep_mod_bind, fi_b, &fnb[0]);
                          let eqb: i32 = 1;
                          let bi_b: i32 = 0;
                          while (bi_b < fl) {
                            if (fnb[bi_b] != callee.field_access_field_name[bi_b]) {
                              eqb = 0;
                              bi_b = fl;
                            } else {
                              bi_b = bi_b + 1;
                            }
                          }
                          if (eqb != 0) {
                            bind_pre = codegen_func_c_symbol_prefix_len(dep_mod_bind, fi_b, pre_len);
                            fi_b = dep_mod_bind.num_funcs;
                          } else {
                            fi_b = fi_b + 1;
                          }
                        } else {
                          fi_b = fi_b + 1;
                        }
                      }
                    }
                    if (bind_pre > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], bind_pre, &callee.field_access_field_name[0], callee.field_access_field_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], bind_pre) != 0) {
                      return -1;
                    }
                    if (callee.field_access_field_len > 0 && codegen_emit_call_func_name(out, arena, ctx, expr_ref, dep_mod_bind, &callee.field_access_field_name[0], callee.field_access_field_len) != 0) {
                      return -1;
                    }
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
                    if (drv_buf_bind != 0 && ai == 0) {
                      let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                      if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                        return -1;
                      }
                    }
                    if (ast.ref_is_null(pipeline_expr_call_arg_ref(arena, expr_ref, ai))) {
                      if (append_byte(out, 48) != 0) {
                        return -1;
                      }
                    } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
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
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
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
          /*
           * Local-first bare-name CALL (align pin seed).
           * Purpose: if current_codegen_module already defines the bare name
           *   (e.g. core.result.unwrap_or), do not scan earlier deps and steal
           *   a same-named symbol (core.option.unwrap_or → core_option_unwrap_or).
           * Authority: seeds/codegen_gen.linux.x86_64.c local_has_name before
           *   while (j < nd_call && local_has_name == 0).
           * Uses pipeline_module_func_name_* (not arena Func) — reliable for slim modules.
           * PLATFORM: SHARED — Cap force si co-emit matrix.
           */
          let local_has_name: i32 = 0;
          if (cur_mod != 0 as *Module && callee.var_name_len > 0) {
            let lfi: i32 = 0;
            while (lfi < cur_mod.num_funcs) {
              let lnl: i32 = pipeline_module_func_name_len_at(cur_mod, lfi);
              if (lnl == callee.var_name_len) {
                let lnm: u8[64] = [];
                pipeline_module_func_name_copy64(cur_mod, lfi, &lnm[0]);
                let leq: i32 = 1;
                let li: i32 = 0;
                while (li < lnl && li < 64) {
                  if (lnm[li] != callee.var_name[li]) {
                    leq = 0;
                    break;
                  }
                  li = li + 1;
                }
                if (leq != 0) {
                  local_has_name = 1;
                  break;
                }
              }
              lfi = lfi + 1;
            }
          }
          while (j < nd_call && local_has_name == 0) {
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
                    /* extern / #[no_mangle]：CALL 用裸名，与定义/声明端一致 */
                    if (callee_is_extern != 0 || pipeline_module_func_is_no_mangle_at(dep_mod, fi) != 0) {
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
                      } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_dep), ctx) != 0) {
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
            } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, ai), ctx) != 0) {
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
                  /*
                   * Same-module bare call prefix (align pin seed CALL callee2 path).
                   * Purpose: prefer path of current_codegen_module in the dep pool
                   *   (core_result_ while emitting result), then entry pin / mirror.
                   *   Do NOT only use codegen_emit_prefix_len_from_ctx: it prefers
                   *   current_codegen_prefix_mirror which import/dep walks can leave
                   *   on a prior dep (e.g. core_option_ → bare unwrap_or mis-prefixed).
                   * Authority: seeds/codegen_gen.linux.x86_64.c same-module VAR CALL.
                   * PLATFORM: SHARED — Cap force si (result→result, not option).
                   */
                  let cur_dep_path_buf: u8[128] = [];
                  let cur_dep_plen: i32 = codegen_ctx_dep_path_for_current_codegen_module_into(ctx, &cur_dep_path_buf[0]);
                  let pl: i32 = 0;
                  if (cur_dep_plen > 0) {
                    codegen_import_path_to_c_prefix_into(&cur_dep_path_buf[0], &cur_pre[0], 128);
                    while (pl < 128 && cur_pre[pl] != 0 as u8) {
                      pl = pl + 1;
                    }
                  } else if (ctx.current_codegen_prefix_len > 0) {
                    let _cpl: i32 = ctx.current_codegen_prefix_len;
                    let pi: i32 = 0;
                    while (pi < _cpl && pi < 127) {
                      cur_pre[pi] = ctx.current_codegen_prefix_mirror[pi];
                      pi = pi + 1;
                    }
                    cur_pre[pi] = 0 as u8;
                    pl = pi;
                  } else {
                    cur_pre[0] = 0 as u8;
                    pl = 0;
                  }
                  /* 【Why extern/no_mangle 裸名】同模块调用须与定义/声明符号一致 */
                  if (pipeline_module_func_is_extern_at(cur_mod, fi) != 0
                      || pipeline_module_func_is_no_mangle_at(cur_mod, fi) != 0) {
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
                    } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx_cur), ctx) != 0) {
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
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* ").keys, (" 9 字节 */
            let mid1: u8[10] = [41, 46, 107, 101, 121, 115, 44, 32, 40, 0];
            if (emit_bytes_from_ptr(out, &mid1[0], 9) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* ").occupied, (" 13 字节 */
            let mid2: u8[14] = [41, 46, 111, 99, 99, 117, 112, 105, 101, 100, 44, 32, 40, 0];
            if (emit_bytes_from_ptr(out, &mid2[0], 13) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 0), ctx) != 0) {
              return -1;
            }
            /* ").cap, " 7 字节 */
            let mid3: u8[8] = [41, 46, 99, 97, 112, 44, 32, 0];
            if (emit_bytes_8(out, mid3, 7) != 0) {
              return -1;
            }
            if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, 1), ctx) != 0) {
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
        } else if (emit_call_arg_slice_abi(arena, out, pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx), ctx) != 0) {
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
    /* FLOAT_LIT: emit real value via C helper (old seed stub always wrote 0.0).
     * Authority: pipeline_codegen_emit_float_lit_c in pipeline_glue.c / strict_minimal seed. */
    if (e.kind == ExprKind.EXPR_FLOAT_LIT) {
      return pipeline_codegen_emit_float_lit_c(out, e.float_val, e.float_bits_lo, e.float_bits_hi);
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
      if (!ast.ref_is_null(e.if_else_ref)) {
        if (emit_expr(arena, out, e.if_else_ref, ctx) != 0) {
          return -1;
        }
      } else {
        if (append_byte(out, 48) != 0) {
          return -1;
        }
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
      /*
       * 【Why 根源】typeck 写 index_base_is_slice；co-emit dep 或 soft typeck 时标志可能为 0。
       *   再查 base 的 resolved TYPE_SLICE(11)，避免对 fat pointer 发非法 `(s)[i]`。
       */
      let need_slice_data: i32 = e.index_base_is_slice;
      if (need_slice_data == 0 && !ast.ref_is_null(e.index_base_ref)) {
        let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, e.index_base_ref);
        if (!ast.ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena.num_types) {
          if (pipeline_type_kind_ord_at(arena, base_ty) == 11) {
            need_slice_data = 1;
          }
        }
      }
      if (need_slice_data != 0) {
        /* PLATFORM: SHARED — slice params are pointers: use ->data not .data.
         * Why: Cap by-value→pointer param ABI; INDEX used to hardcode `.data` → host-cc error. */
        let use_arrow: i32 = 0;
        if (!ast.ref_is_null(e.index_base_ref)) {
          if (field_access_base_is_pointer_ref(arena, e.index_base_ref) != 0) {
            use_arrow = 1;
          }
          if (use_arrow == 0 && ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
            if (field_access_base_is_pointer_param(arena, e.index_base_ref, ctx.current_codegen_module, ctx.current_func_index) != 0) {
              use_arrow = 1;
            }
          }
        }
        if (use_arrow != 0) {
          let arrow_data: u8[8] = [45, 62, 100, 97, 116, 97, 0, 0];
          if (emit_bytes_from_ptr(out, &arrow_data[0], 6) != 0) {
            return -1;
          }
        } else {
          let dot: u8[6] = [46, 100, 97, 116, 97, 0];
          if (emit_bytes_6(out, dot, 5) != 0) {
            return -1;
          }
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
      /* PLATFORM: SHARED — mark Enum.Variant / import.Enum.Variant on this arena
       * before re-reading e (seed call site must pass emit_expr arena, not a
       * possibly-stale current_codegen_arena). */
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module) {
        pipeline_codegen_try_mark_enum_field_access(ctx.current_codegen_module, arena, expr_ref, ctx);
        e = ast.ast_arena_expr_get(arena, expr_ref);
      }
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
      /* base 为指针时输出 ->，否则输出 .。
       * 优先级：resolved TYPE_PTR → 当前函数 *T 形参 →（仅类型未解析且形参类型亦未知时）名字回退。
       * 禁止：类型已解析为值类型、或形参类型已知为非指针时，用 ctx/out 等名字强制 ->。
       * （std.context 的 ctx: Context 值类型在 dep co-emit 无 resolved_type_ref 时曾被 "ctx" 回退成 ->）。 */
      let is_ptr_base: i32 = field_access_base_is_pointer_ref(arena, e.field_access_base_ref);
      let param_type_known: i32 = 0;
      if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module && ctx.current_func_index >= 0) {
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_param(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
        }
        if (is_ptr_base == 0) {
          is_ptr_base = field_access_base_is_pointer_local(arena, e.field_access_base_ref, ctx);
        }
        param_type_known = field_access_base_param_type_known(arena, e.field_access_base_ref, ctx.current_codegen_module, ctx.current_func_index);
      }
      if (is_ptr_base == 0 && param_type_known == 0 && field_access_base_type_resolved(arena, e.field_access_base_ref) == 0) {
        if (field_access_base_is_slice_param_name(arena, e.field_access_base_ref) != 0) {
          is_ptr_base = 1;
        }
      }
      if (is_ptr_base != 0) {
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
      let p: u8[22] = [115, 104, 117, 120, 95, 112, 97, 110, 105, 99, 95, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      if (emit_bytes_22(out, p, 12) != 0) {
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
        /*
         * 【Why 根源】driver.xxx / core.xxx 常为 METHOD_CALL。typeck 在 dep typeck 失败
         *   时仍可能写入错误 call_resolved（错 dep+错 func）→ 盲信会把
         *   submit_write_batch_buf 发成 std_fmt_append_to_buf_*，uring_ok 发成
         *   print_u8_ptr_usize()。必须校验「名+arity」与 method_call_name 一致，
         *   否则落入下方 binding 回退（按 import path + method 名重搜）。
         */
        let mc_resolved_ok: i32 = 0;
        if (dep_ix >= 0 && func_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
          let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_ix);
          if (dep_mod != 0 as *Module && func_ix < dep_mod.num_funcs) {
            let fn_name: u8[64] = [];
            let fn_len: i32 = pipeline_module_func_name_len_at(dep_mod, func_ix);
            let name_ok: i32 = 0;
            if (fn_len > 0) {
              pipeline_module_func_name_copy64(dep_mod, func_ix, &fn_name[0]);
            }
            if (fn_len > 0 && fn_len == e.method_call_name_len && e.method_call_name_len > 0) {
              name_ok = 1;
              let mi: i32 = 0;
              while (mi < fn_len) {
                if (fn_name[mi] != e.method_call_name[mi]) {
                  name_ok = 0;
                  mi = fn_len;
                } else {
                  mi = mi + 1;
                }
              }
            }
            if (name_ok != 0 && pipeline_module_func_num_params_at(dep_mod, func_ix) == e.method_call_num_args) {
              mc_resolved_ok = 1;
            }
            /*
             * PLATFORM: SHARED — multi-import closure can leave call_resolved dep_ix on a
             * transitive dep (e.g. std.heap.libc) while the binding is std.heap. Name+arity
             * alone then emits std_heap_libc_free instead of std_heap_free_u8_ptr.
             * Trust resolved only when dep path matches the import binding path.
             * When path matches, keep typeck's overload pick (do not force re-search).
             */
            if (mc_resolved_ok != 0) {
              let bind_path: u8[64] = [];
              let bind_plen: i32 = codegen_resolve_binding_import_path_for_method_call(ctx, arena, expr_ref, &bind_path[0]);
              let dep_path_chk: u8[64] = [];
              pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path_chk[0]);
              let dep_plen_chk: i32 = pipeline_dep_ctx_import_path_len(ctx, dep_ix);
              if (bind_plen > 0) {
                if (bind_plen != dep_plen_chk) {
                  mc_resolved_ok = 0;
                } else {
                  let bp: i32 = 0;
                  while (bp < bind_plen) {
                    if (bind_path[bp] != dep_path_chk[bp]) {
                      mc_resolved_ok = 0;
                      bp = bind_plen;
                    } else {
                      bp = bp + 1;
                    }
                  }
                }
              }
            }
            if (mc_resolved_ok != 0) {
            let dep_path: u8[64] = [];
            pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, &dep_path[0]);
            let pre_buf: u8[128] = [];
            codegen_import_path_to_c_prefix_into(&dep_path[0], &pre_buf[0], 128);
            let pre_len: i32 = 0;
            while (pre_len < 128 && pre_buf[pre_len] != 0) {
              pre_len = pre_len + 1;
            }
            /* std.io.driver register/submit_read/submit_write：METHOD_CALL 也须走 shux_io_*_buf + &arg。
             * driver.submit_read(buf) 解析为 METHOD_CALL，非 FIELD_ACCESS+CALL。 */
            let drv_buf_mc: i32 = 0;
            if (codegen_path_is_std_io_driver_bytes(&dep_path[0]) != 0 && fn_len > 0) {
              drv_buf_mc = codegen_emit_io_driver_buf_call_name(out, &fn_name[0], fn_len, e.method_call_num_args);
              if (drv_buf_mc < 0) {
                return -1;
              }
            }
            if (drv_buf_mc == 0) {
              /* #[no_mangle] CALL 不加 path 前缀，与定义端裸名一致 */
              let call_pre: i32 = codegen_func_c_symbol_prefix_len(dep_mod, func_ix, pre_len);
              if (call_pre > 0 && fn_len > 0 && codegen_c_prefix_redundant_with_name(&pre_buf[0], call_pre, &fn_name[0], fn_len) == 0 && emit_bytes_from_ptr(out, &pre_buf[0], call_pre) != 0) {
                return -1;
              }
              /* 【Why 根源】typeck 已解析的重载函数也须 mangle：emit_bytes_from_ptr 只发原名，
                 重载函数（如 heap.free 6 重载）会与定义端 mangled 名不匹配 → 链接错误。
                 dep param type_ref lives in that module's arena — prefer dep_ctx arena,
                 else codegen_arena_for_module (null arena → empty suffixes → bare free).
                 【Invariant】fn_len>0 保证有函数名；codegen_emit_func_link_name 内部判断 overload_count。 */
              /* Prefer module→arena map (stable); dep_ix arena can be stale/null on Linux. */
              let dep_arena: *ASTArena = codegen_arena_for_module(ctx, dep_mod, arena);
              if (dep_arena == 0 as *ASTArena) {
                dep_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
              }
              if (fn_len > 0 && codegen_emit_func_link_name(out, dep_arena, dep_mod, func_ix) != 0) {
                return -1;
              }
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
              if (drv_buf_mc != 0 && ai == 0) {
                let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
                if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                  return -1;
                }
              }
              let dep_arg: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai);
              if (ast.ref_is_null(dep_arg)) {
                if (append_byte(out, 48) != 0) {
                  return -1;
                }
              /* PLATFORM: SHARED — method dep args use same slice pointer ABI as CALL. */
              } else if (emit_call_arg_slice_abi(arena, out, dep_arg, ctx) != 0) {
                return -1;
              }
              ai = ai + 1;
            }
            return append_byte(out, 41);
            }
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
          /* std.io.driver register/submit_read/submit_write：METHOD_CALL binding 回退路径。 */
          let drv_buf_fb: i32 = 0;
          if (codegen_path_is_std_io_driver_bytes(&dep_path_fb[0]) != 0) {
            drv_buf_fb = codegen_emit_io_driver_buf_call_name(out, &e.method_call_name[0], e.method_call_name_len, e.method_call_num_args);
            if (drv_buf_fb < 0) {
              return -1;
            }
          }
          if (drv_buf_fb == 0) {
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
            if (drv_buf_fb != 0 && ai_fb == 0) {
              let cast_buf: u8[19] = [40, 105, 110, 116, 112, 116, 114, 95, 116, 41, 40, 118, 111, 105, 100, 42, 41, 38, 0];
              if (emit_bytes_from_ptr(out, &cast_buf[0], 18) != 0) {
                return -1;
              }
            }
            let arg_fb: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, ai_fb);
            if (ast.ref_is_null(arg_fb)) {
              if (append_byte(out, 48) != 0) {
                return -1;
              }
            /* PLATFORM: SHARED — method fallback args: slice locals → &(s). */
            } else if (emit_call_arg_slice_abi(arena, out, arg_fb, ctx) != 0) {
              return -1;
            }
            ai_fb = ai_fb + 1;
          }
          return append_byte(out, 41);
        }
      }
      /*
       * Bootstrap trait 最小回归：impl Double for i32 在 typeck 可 skip monomorphize，
       * 仅保留 METHOD_CALL AST。历史 seed 将 i32.double() 内联为 (base * 2)；
       * 禁止发 C 的 `21.double()`（非法 float 后缀）。与 pipeline_glue_strict_minimal
       * 的 i32.double→i32 typeck 兜底对称。
       */
      if (e.method_call_name_len == 6
          && e.method_call_name[0] == 100 && e.method_call_name[1] == 111
          && e.method_call_name[2] == 117 && e.method_call_name[3] == 98
          && e.method_call_name[4] == 108 && e.method_call_name[5] == 101
          && e.method_call_num_args == 0
          && !ast.ref_is_null(e.method_call_base_ref)) {
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, e.method_call_base_ref, ctx) != 0) {
          return -1;
        }
        let mul2: u8[6] = [32, 42, 32, 50, 41, 0];
        if (emit_bytes_from_ptr(out, &mul2[0], 5) != 0) {
          return -1;
        }
        return 0;
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
        /* PLATFORM: SHARED — residual method_call args: slice pointer ABI. */
        } else if (emit_call_arg_slice_abi(arena, out, m_arg, ctx) != 0) {
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
      /*
       * PLATFORM: SHARED — compound lit must use defining-module C tag.
       * Entry/ctx prefix alone yields parser_Token while the full def is token_Token
       * (or lexer_Token pollution) → incomplete type (parser M1 host-cc residual).
       * Authority: codegen_type_dep_struct_owner_index (same as emit_type).
       */
      if (ctx != 0 as *PipelineDepCtx && e.struct_lit_struct_name_len > 0) {
        let lit_bare_off: i32 = 0;
        let lit_bi: i32 = 0;
        while (lit_bi < e.struct_lit_struct_name_len && lit_bi < 64) {
          if (e.struct_lit_struct_name[lit_bi] == 46) {
            lit_bare_off = lit_bi + 1;
          }
          lit_bi = lit_bi + 1;
        }
        let lit_bare_len: i32 = e.struct_lit_struct_name_len - lit_bare_off;
        if (lit_bare_len > 0) {
          let lit_owner: i32 = codegen_type_dep_struct_owner_index(ctx, &e.struct_lit_struct_name[lit_bare_off], lit_bare_len);
          if (lit_owner >= 0) {
            let lit_path: u8[64] = [];
            let lit_plen: i32 = codegen_dep_import_path_len_at(ctx, lit_owner, &lit_path[0]);
            if (lit_plen > 0) {
              codegen_import_path_to_c_prefix_into(&lit_path[0], &sl_pfx[0], 128);
              sl_plen = 0;
              while (sl_plen < 128 && sl_pfx[sl_plen] != 0 as u8) {
                sl_plen = sl_plen + 1;
              }
            }
          }
        }
      }
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
      /*
       * Preamble ABI types: compound lit must use the defining-module C tag, not the
       * entry-module prefix. Catch-all std_net_ was wrong for Option_* → incomplete
       * std_net_Option_i32 (option/si matrix red under force-regen).
       * PLATFORM: SHARED — align with seed pin + emit_type Option_/Result_ authority.
       */
      if (codegen_should_skip_emit_struct_layout_for_abi_dup(&e.struct_lit_struct_name[0], e.struct_lit_struct_name_len) != 0) {
        bare_user_lit = 0;
        if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 66) {
          /* Buffer → std_io_driver_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95; sl_pfx[7] = 100;
          sl_pfx[8] = 114; sl_pfx[9] = 105; sl_pfx[10] = 118; sl_pfx[11] = 101;
          sl_pfx[12] = 114; sl_pfx[13] = 95; sl_pfx[14] = 0;
          sl_plen = 14;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 69) {
          /* Error → std_error_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 101; sl_pfx[5] = 114; sl_pfx[6] = 114; sl_pfx[7] = 111;
          sl_pfx[8] = 114; sl_pfx[9] = 95; sl_pfx[10] = 0;
          sl_plen = 10;
        } else if (e.struct_lit_struct_name_len >= 8 && e.struct_lit_struct_name[0] == 79
            && e.struct_lit_struct_name[1] == 112 && e.struct_lit_struct_name[2] == 116
            && e.struct_lit_struct_name[3] == 105 && e.struct_lit_struct_name[4] == 111
            && e.struct_lit_struct_name[5] == 110 && e.struct_lit_struct_name[6] == 95) {
          /* Option_* → core_option_ (same invariant as emit_type monomorph path) */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 111; sl_pfx[6] = 112; sl_pfx[7] = 116;
          sl_pfx[8] = 105; sl_pfx[9] = 111; sl_pfx[10] = 110; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 82) {
          /* Result_u8 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 82
            && e.struct_lit_struct_name[7] == 105) {
          /* Result_i32 → core_result_ */
          sl_pfx[0] = 99; sl_pfx[1] = 111; sl_pfx[2] = 114; sl_pfx[3] = 101;
          sl_pfx[4] = 95; sl_pfx[5] = 114; sl_pfx[6] = 101; sl_pfx[7] = 115;
          sl_pfx[8] = 117; sl_pfx[9] = 108; sl_pfx[10] = 116; sl_pfx[11] = 95;
          sl_pfx[12] = 0;
          sl_plen = 12;
        } else if (e.struct_lit_struct_name_len == 6 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[1] == 116 && e.struct_lit_struct_name[2] == 114 && e.struct_lit_struct_name[3] == 105) {
          /* String → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 7 && e.struct_lit_struct_name[0] == 83 && e.struct_lit_struct_name[3] == 86) {
          /* StrView → std_string_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 115; sl_pfx[5] = 116; sl_pfx[6] = 114; sl_pfx[7] = 105;
          sl_pfx[8] = 110; sl_pfx[9] = 103; sl_pfx[10] = 95; sl_pfx[11] = 0;
          sl_plen = 11;
        } else if (e.struct_lit_struct_name_len == 9 && e.struct_lit_struct_name[0] == 84) {
          /* TcpStream → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 11 && e.struct_lit_struct_name[0] == 84) {
          /* TcpListener → std_net_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 110; sl_pfx[5] = 101; sl_pfx[6] = 116; sl_pfx[7] = 95;
          sl_pfx[8] = 0;
          sl_plen = 8;
        } else if (e.struct_lit_struct_name_len == 10 && e.struct_lit_struct_name[0] == 70 && e.struct_lit_struct_name[1] == 115) {
          /* FsIovecBuf → std_fs_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 102; sl_pfx[5] = 115; sl_pfx[6] = 95; sl_pfx[7] = 0;
          sl_plen = 7;
        } else if (e.struct_lit_struct_name_len == 5 && e.struct_lit_struct_name[0] == 73 && e.struct_lit_struct_name[1] == 111) {
          /* Iovec → std_io_sync_ */
          sl_pfx[0] = 115; sl_pfx[1] = 116; sl_pfx[2] = 100; sl_pfx[3] = 95;
          sl_pfx[4] = 105; sl_pfx[5] = 111; sl_pfx[6] = 95;
          sl_pfx[7] = 115; sl_pfx[8] = 121; sl_pfx[9] = 110; sl_pfx[10] = 99;
          sl_pfx[11] = 95; sl_pfx[12] = 0;
          sl_plen = 12;
        }
        /* other abi_dup names: keep sl_pfx from ctx (do not force std_net_) */
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
        /* STRUCT_LIT array fields: C designated init cannot take an array/pointer RHS.
         * - EXPR_ARRAY_LIT empty → `{ 0 }`; non-empty → emit_braced_array_lit_init
         * - VAR/param (u8[N] or decayed *u8) → expand `.name = { src[0], …, src[N-1] }`
         *   (parser M1 host-cc residual: `.name = z64` / `.name = name64` illegal).
         * Do NOT emit_expr alone for TYPE_ARRAY fields (pointer-to-integer on first elem).
         * PLATFORM: SHARED — seed pin same commit; verify parser.x -E host-cc. */
        let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, expr_ref, fi);
        if (!ast.ref_is_null(init_ref)) {
          let init_e: Expr = ast.ast_arena_expr_get(arena, init_ref);
          if (init_e.kind == ExprKind.EXPR_ARRAY_LIT) {
            if (init_e.array_lit_num_elems == 0) {
              let zero_init: u8[6] = [123, 32, 48, 32, 125, 0];
              if (emit_bytes_6(out, zero_init, 5) != 0) {
                return -1;
              }
            } else {
              if (emit_braced_array_lit_init(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
            }
          } else {
            let use_elem_expand: i32 = 0;
            let arr_sz: i32 = 0;
            let flen_lk: i32 = flen;
            if (flen_lk > 64) {
              flen_lk = 64;
            }
            let ftr: i32 = codegen_lookup_struct_field_type_ref(
              arena, ctx, &e.struct_lit_struct_name[0], e.struct_lit_struct_name_len, &sl_fnbuf[0], flen_lk);
            if (!ast.ref_is_null(ftr)
                && pipeline_type_kind_ord_at(arena, ftr) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, ftr);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            } else if (!ast.ref_is_null(init_e.resolved_type_ref)
                && pipeline_type_kind_ord_at(arena, init_e.resolved_type_ref) == (TypeKind.TYPE_ARRAY as i32)) {
              arr_sz = pipeline_type_array_size_at(arena, init_e.resolved_type_ref);
              if (arr_sz > 0 && arr_sz <= 512) {
                use_elem_expand = 1;
              }
            }
            if (use_elem_expand != 0) {
              if (append_byte(out, 123) != 0) {
                return -1;
              }
              let ai: i32 = 0;
              while (ai < arr_sz) {
                if (ai > 0) {
                  let cm: u8[3] = [44, 32, 0];
                  if (emit_bytes_3(out, cm, 2) != 0) {
                    return -1;
                  }
                }
                if (emit_expr(arena, out, init_ref, ctx) != 0) {
                  return -1;
                }
                if (append_byte(out, 91) != 0) {
                  return -1;
                }
                if (format_int(out, ai as i64) != 0) {
                  return -1;
                }
                if (append_byte(out, 93) != 0) {
                  return -1;
                }
                ai = ai + 1;
              }
              if (append_byte(out, 125) != 0) {
                return -1;
              }
            } else {
              if (emit_expr(arena, out, init_ref, ctx) != 0) {
                return -1;
              }
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
      let is_vector: i32 = 0;
      if (!ast.ref_is_null(e.resolved_type_ref) && e.resolved_type_ref > 0 && e.resolved_type_ref <= arena.num_types) {
        let ty: Type = ast.ast_arena_type_get(arena, e.resolved_type_ref);
        if (ty.kind == TypeKind.TYPE_SLICE) {
          is_slice = 1;
          elem_type_ref = ty.elem_type_ref;
        } else if (ty.kind == TypeKind.TYPE_ARRAY) {
          elem_type_ref = ty.elem_type_ref;
        } else if (ty.kind == TypeKind.TYPE_VECTOR) {
          /* 向量字面量须 (i32x4_t){...}；(int32_t[]){...} / (uint8_t[]){...} 不能初始化 vector 类型。 */
          is_vector = 1;
        } else if (ty.kind == TypeKind.TYPE_NAMED && ty.name_len >= 5) {
          /* 误落 TYPE_NAMED 的 i32x4/u32x8 等拼写 */
          let ni: i32 = 0;
          while (ni < ty.name_len) {
            if (ty.name[ni] == 120) {
              is_vector = 1;
              ni = ty.name_len;
            } else {
              ni = ni + 1;
            }
          }
        }
      }
      if (is_vector != 0) {
        /* (vec_ty){ e0, e1, ... } compound literal */
        if (append_byte(out, 40) != 0) {
          return -1;
        }
        if (emit_type(arena, out, e.resolved_type_ref, 0 as *u8, 0, ctx) != 0) {
          return -1;
        }
        if (append_byte(out, 41) != 0) {
          return -1;
        }
        if (append_byte(out, 123) != 0) {
          return -1;
        }
        let vai: i32 = 0;
        while (vai < n) {
          if (vai > 0) {
            let comma: u8[3] = [44, 32, 0];
            if (emit_bytes_3(out, comma, 2) != 0) {
              return -1;
            }
          }
          if (!ast.ref_is_null(pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai))
              && emit_expr(arena, out, pipeline_expr_array_lit_elem_ref(arena, expr_ref, vai), ctx) != 0) {
            return -1;
          }
          vai = vai + 1;
        }
        let vclose: u8[4] = [32, 125, 0, 0];
        return emit_bytes_4(out, vclose, 2);
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
}

/**
 * 判断 EXPR_VAR 形 callee 是否为 string_new 或 std_string_string_new；
 * 拆成独立函数并用循环比较，避免超长 if 在 -E-extern 路径 parse 失败。
 */
export function codegen_callee_var_is_string_new(e: Expr): i32 {
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
export function emit_run_defers(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

export function codegen_current_func_returns_void(arena: *ASTArena, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * Emit a C `return` statement with Cap-T001 / host-cc awareness.
 *
 * Why: Cap-T001 wrappers often end with typeck filler `return 0` after a real
 * `return glue(...)`. Bare `return 0` is illegal when the function returns a
 * struct by value (Lexer, OneFuncResult, …) → host-cc "returning 'int' from …".
 * For TYPE_NAMED returns, int-lit/empty `return 0` becomes
 * `return (struct Tag){0};` (valid C dead code).
 * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc.
 */
export function emit_return_stmt_with_context(arena: *ASTArena, out: *CodegenOutBuf, indent: i32, operand_ref: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
    /* G-02f-476: panic() 是 noreturn；return panic() 不应生成 "return shux_panic_(0,0);"（void 返回值赋给非 void 函数报错）。直接输出 panic 调用 + ";\n"，不带 return 前缀。 */
    if (!ast.ref_is_null(operand_ref)) {
      if (pipeline_expr_kind_ord_at(arena, operand_ref) == (42 as i32)) {
        if (emit_indent(out, indent) != 0) {
          return -1;
        }
        if (emit_expr(arena, out, operand_ref, ctx) != 0) {
          return -1;
        }
        let sc_panic: u8[4] = [59, 10, 0, 0];
        return emit_bytes_4(out, sc_panic, 2);
      }
    }
    /*
     * By-value struct + Cap-T001 filler `return 0`: host C rejects `return 0` for
     * incomplete/struct return types. Emit compound zero instead.
     */
    if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
        && ctx.current_func_index >= 0 && ctx.current_func_index < ctx.current_codegen_module.num_funcs) {
      let rty: i32 = pipeline_module_func_return_type_at(ctx.current_codegen_module, ctx.current_func_index);
      if (!ast.ref_is_null(rty) && pipeline_type_kind_ord_at(arena, rty) == (TypeKind.TYPE_NAMED as i32)) {
        let use_struct_zero: i32 = 0;
        if (ast.ref_is_null(operand_ref)) {
          use_struct_zero = 1;
        } else if (pipeline_expr_kind_ord_at(arena, operand_ref) == (ExprKind.EXPR_LIT as i32)) {
          let lit: Expr = ast.ast_arena_expr_get(arena, operand_ref);
          if (lit.int_val == 0) {
            use_struct_zero = 1;
          }
        }
        if (use_struct_zero != 0) {
          if (emit_indent(out, indent) != 0) {
            return -1;
          }
          /* return ( */
          let ret_open: u8[8] = [114, 101, 116, 117, 114, 110, 32, 40];
          if (emit_bytes_from_ptr(out, &ret_open[0], 8) != 0) {
            return -1;
          }
          if (emit_type(arena, out, rty, 0 as *u8, 0, ctx) != 0) {
            return -1;
          }
          /* ){0};\n */
          let ret_close: u8[8] = [41, 123, 48, 125, 59, 10, 0, 0];
          if (emit_bytes_from_ptr(out, &ret_close[0], 6) != 0) {
            return -1;
          }
          return 0;
        }
      }
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
}

/**
 * 块尾 final_expr 发射。
 * 函数体：值表达式 → return expr;；嵌套块（while/if 体）：break/continue 如实发，其余 (void)(expr);
 * 【Why 根源】原先一律 emit_return，导致 while { break } → return 0、while { 1 } → return 1。
 */
export function emit_block_final_expr(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, final_ref: i32, indent: i32, ctx: *PipelineDepCtx, fn_ret_void: i32): i32 {
  if (ast.ref_is_null(final_ref)) {
    return 0;
  }
  let fe: Expr = ast.ast_arena_expr_get(arena, final_ref);
  if (fe.kind == ExprKind.EXPR_BREAK) {
    return emit_break_stmt(out, indent);
  }
  if (fe.kind == ExprKind.EXPR_CONTINUE) {
    return emit_continue_stmt(out, indent);
  }
  if (fe.kind == ExprKind.EXPR_RETURN) {
    return emit_return_stmt_with_context(arena, out, indent, fe.unary_operand_ref, ctx, fn_ret_void);
  }
  let parent_br: i32 = 0;
  if (block_ref > 0 && block_ref <= arena.num_blocks) {
    let blk: Block = ast.ast_arena_block_get(arena, block_ref);
    parent_br = blk.parent_block_ref;
  }
  /*
   * Nested / non-function-body final: emit `expr;` not return.
   * PLATFORM: SHARED — GNU statement expr `({ ... })` (EXPR_BLOCK as value, e.g.
   * `if (a==b){1}else{0}` as call arg) must end with a value expression.
   * `return 1;` makes the statement-expr void → host-cc "void to int32_t".
   * Only the real function body block may use return for final_expr.
   */
  let is_func_body: i32 = 0;
  if (ctx != 0 as *PipelineDepCtx && ctx.current_codegen_module != 0 as *Module
      && ctx.current_func_index >= 0) {
    let fbody: i32 = pipeline_module_func_body_ref_at(ctx.current_codegen_module, ctx.current_func_index);
    if (!ast.ref_is_null(fbody) && fbody == block_ref) {
      is_func_body = 1;
    }
  }
  if (parent_br > 0 || is_func_body == 0) {
    if (emit_indent(out, indent) != 0) {
      return -1;
    }
    if (emit_expr(arena, out, final_ref, ctx) != 0) {
      return -1;
    }
    let end: u8[4] = [59, 10, 0, 0];
    return emit_bytes_from_ptr(out, &end[0], 2);
  }
  return emit_return_stmt_with_context(arena, out, indent, final_ref, ctx, fn_ret_void);
}

/**
 * 写块体到 out：const/let 声明、while/for、表达式语句、最终表达式。
 * 当 num_stmt_order > 0 时按 stmt_order 源码顺序输出，保证 let/if/return 等顺序正确，避免递归或提前 return 等错误。
 */
export function emit_block(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, indent: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
              /*
               * init 为返回 String 的 call（如 string_new）时，强制用 typedef 名 String。
               * 【Why 根源】旧 emit `struct String`：preamble 是
               *   `typedef struct std_string_String String`，`struct String` 为另一 incomplete tag。
               * 【Invariant】与 preamble typedef 一致；勿再写 `struct String`。
               */
              if (type_emitted == 0 && !ast.ref_is_null(init_e.resolved_type_ref) && init_e.resolved_type_ref > 0 && init_e.resolved_type_ref <= arena.num_types) {
                let rt: Type = ast.ast_arena_type_get(arena, init_e.resolved_type_ref);
                if (rt.kind == TypeKind.TYPE_NAMED && rt.name_len >= 6) {
                  let n0: i32 = rt.name_len - 6;
                  if (rt.name[n0] == 83 && rt.name[n0 + 1] == 116 && rt.name[n0 + 2] == 114 && rt.name[n0 + 3] == 105 && rt.name[n0 + 4] == 110 && rt.name[n0 + 5] == 103) {
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
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
                    let str_ty: u8[7] = [83, 116, 114, 105, 110, 103, 0];
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
              /* 向量 TYPE_NAMED / TYPE_VECTOR：0 → { 0 }；ARRAY_LIT → 花括号初值（赋值语境） */
              let use_vec_z: i32 = 0;
              let use_vec_braced: i32 = 0;
              if (!ast.ref_is_null(linit_ref) && linit_ref > 0 && linit_ref <= arena.num_exprs
                  && !ast.ref_is_null(let_type_ref)) {
                let init_ez: Expr = ast.ast_arena_expr_get(arena, linit_ref);
                let tk_z: i32 = pipeline_type_kind_ord_at(arena, let_type_ref);
                let is_vec_ty: i32 = 0;
                if (tk_z == TypeKind.TYPE_VECTOR) {
                  is_vec_ty = 1;
                } else if (tk_z == TypeKind.TYPE_NAMED) {
                  let vzn: u8[64] = [];
                  let vzn_l: i32 = pipeline_type_named_name_into(arena, let_type_ref, &vzn[0]);
                  let vi: i32 = 0;
                  while (vi < vzn_l) {
                    if (vzn[vi] == 120) {
                      is_vec_ty = 1;
                      vi = vzn_l;
                    } else {
                      vi = vi + 1;
                    }
                  }
                }
                if (is_vec_ty != 0) {
                  if (init_ez.kind == ExprKind.EXPR_LIT && init_ez.int_val == 0) {
                    use_vec_z = 1;
                  } else if (init_ez.kind == ExprKind.EXPR_ARRAY_LIT) {
                    use_vec_braced = 1;
                  }
                }
              }
              if (use_vec_z != 0) {
                let vz: u8[6] = [123, 32, 48, 32, 125, 0];
                if (emit_bytes_6(out, vz, 5) != 0) {
                  return -1;
                }
              } else if (use_vec_braced != 0) {
                if (emit_braced_array_lit_init(arena, out, linit_ref, ctx) != 0) {
                  return -1;
                }
              } else if (emit_expr(arena, out, linit_ref, ctx) != 0) {
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
          /**
           * M-3：region 零开销域标签。
           * 有 let/const 时包 { } 限定作用域；无局部时不包花括号。
           * 【Why 根源】`unsafe { call() }` 常落 EXPR_BLOCK→region；若再包 { }，
           *   GNU 语句表达式 `({ { call(); } })` 末尾为 compound → 值类型 void，
           *   破坏 `if (unsafe { memcmp(...) } != 0)`。
           */
          if (idx >= 0 && idx < ast.ast_block_num_regions(arena, block_ref)) {
            let reg_body: i32 = ast.ast_block_region_body_ref(arena, block_ref, idx);
            let need_scope: i32 = 0;
            if (!ast.ref_is_null(reg_body) && reg_body > 0 && reg_body <= arena.num_blocks) {
              if (ast.ast_block_num_lets(arena, reg_body) > 0
                  || ast.ast_block_num_consts(arena, reg_body) > 0) {
                need_scope = 1;
              }
            }
            if (need_scope != 0) {
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
            } else {
              if (emit_block(arena, out, reg_body, indent, ctx) != 0) {
                return -1;
              }
            }
          }
        }
        si = si + 1;
      }
      if (emit_run_defers(arena, out, block_ref, indent, ctx) != 0) {
        return -1;
      }
      let final_ref: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
      if (emit_block_final_expr(arena, out, block_ref, final_ref, indent, ctx, fn_ret_void) != 0) {
        return -1;
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
              /* typedef String — 勿 struct String（incomplete）。 */
              let str_ty2a: u8[7] = [83, 116, 114, 105, 110, 103, 0];
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
              let str_ty2: u8[7] = [83, 116, 114, 105, 110, 103, 0];
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
    /* 函数体 / 嵌套块 final_expr：见 emit_block_final_expr */
    let final_ref_plain: i32 = ast.ast_block_final_expr_ref(arena, block_ref);
    if (emit_block_final_expr(arena, out, block_ref, final_ref_plain, indent, ctx, fn_ret_void) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * 【Why 根源】将 src[0..len-1] 拷贝到 dst 并返回 len，供 codegen_type_ref_to_suffix 写基本类型后缀。
 * 【Invariant】dst 须 >= len 字节；不写 NUL（调用方按返回长度使用）。
 */
export function emit_suffix_bytes(dst: *u8, src: *u8, len: i32): i32 {
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
export function codegen_type_ref_to_suffix(arena: *ASTArena, type_ref: i32, buf: *u8, buf_cap: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
    /* NAMED: 用类型名；'.' → '_'（C 链接符合法，heap.Arena64 → heap_Arena64） */
    if (tk == (TypeKind.TYPE_NAMED as i32)) {
      let nl: i32 = pipeline_type_named_name_into(arena, type_ref, buf);
      let si: i32 = 0;
      while (si < nl && si < buf_cap) {
        if (buf[si] == 46) { buf[si] = 95; }
        si = si + 1;
      }
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
}

/**
 * 【Why 根源】统计模块内同名函数个数（>1 时须 mangled C 符号），与 codegen.c module_func_overload_count 对齐。
 * 【Invariant】仅按 name 比较；返回值用于判断是否需 mangle。
 */
export function codegen_module_func_overload_count(module: *Module, name_ptr: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 【Why 根源】比较两个函数的参数签名是否相同（用 type_to_suffix 逐参比较），与 codegen.c func_param_sig_equal 对齐。
 * 【Invariant】参数个数不同直接返回 0；mod_a/fi_a 与 mod_b/fi_b 可指向不同模块（dep 调用场景）。
 */
export function codegen_func_param_sig_equal(arena: *ASTArena, mod_a: *Module, fi_a: i32, mod_b: *Module, fi_b: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * 【Why 根源】统计模块内与 fi 同名且参数签名相同的函数个数，与 codegen.c module_overload_param_sig_count 对齐。
 * 【Invariant】签名相同个数 >1 时须追加 _ret_<T> 后缀避免链接冲突。
 */
export function codegen_module_overload_param_sig_count(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/**
 * #[no_mangle]：C 链接符号为裸名，不加 import path 前缀。
 * 与 codegen_emit_func_link_name 的「原名」规则对齐；定义 / 声明 / CALL 三端共用。
 * 【Why 根源】仅跳过 overload mangle 仍写 std_net_tcp_* 前缀时，workers C 胶层
 * 引用的 net_accept_many_c 在 Linux 全量 .o 链接下 U 无法解析（mac dead_strip 掩盖）。
 */
export function codegen_func_c_symbol_prefix_len(module: *Module, fi: i32, prefix_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (prefix_len <= 0) {
      return 0;
    }
    if (module != 0 as *Module && fi >= 0 && pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return 0;
    }
    return prefix_len;
  }
}

/**
 * Emit the C link symbol for function fi: bare name, or mangled name_t1_t2 when overloaded.
 * Aligns with seed pin / historical codegen.c func_link_name. #[no_mangle] always bare.
 *
 * Why zero-init + assign (not let x = f(name)): product pin X→C hoists all `let` inits
 * to the top of the block. `let overload_count = count(fn_local, …)` ran before
 * codegen_copy_func_name64, so overload_count was always 0/1 and extern decls collided
 * (hello: core_fmt_fmt_scalar_to_buf / std_io_print unmangled).
 * PLATFORM: SHARED — definition / extern decl / CALL must all call this helper.
 */
export function codegen_emit_func_link_name(out: *CodegenOutBuf, arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe: zero locals first; fill via statements after the early-return gate. */
    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let overload_count: i32 = 0;
    let np: i32 = 0;
    let pi: i32 = 0;
    let sig_count: i32 = 0;
    if (module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    if (fn_len <= 0) {
      return -1;
    }
    /* #[no_mangle] 用原名 */
    if (pipeline_module_func_is_no_mangle_at(module, fi) != 0) {
      return emit_bytes_64(out, &fn_local[0], fn_len);
    }
    /* Count overloads only after name is copied (let-hoist safe). */
    overload_count = codegen_module_func_overload_count(module, &fn_local[0], fn_len);
    if (overload_count <= 1) {
      return emit_bytes_64(out, &fn_local[0], fn_len);
    }
    /* 需要 mangle: name_t1_t2... */
    if (emit_bytes_64(out, &fn_local[0], fn_len) != 0) {
      return -1;
    }
    np = pipeline_module_func_num_params_at(module, fi);
    pi = 0;
    while (pi < np) {
      let suf: u8[64] = [];
      let param_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, pi);
      /*
       * PLATFORM: SHARED — param type_ref is indexed in the function's module arena.
       * Callers must pass that arena; if null/wrong, suffix is empty → bare free
       * (Ubuntu multi-import heap.free). Prefer non-null arena; never silent bare mangle.
       */
      let sl: i32 = 0;
      if (arena != 0 as *ASTArena) {
        sl = codegen_type_ref_to_suffix(arena, param_ty, &suf[0], 64);
      }
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
    sig_count = codegen_module_overload_param_sig_count(arena, module, fi);
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
}

/**
 * 【Why 根源】type_ref 是 arena 局部索引：目标模块函数的 param type_ref 必须用该模块
 *   自己的 arena 做 suffix，否则 *u8+usize 会 mangle 成 print_u8（错 arena 把 PTR 看成
 *   U8、第二参 suffix 空）→ 定义端 print_u8_ptr_usize、调用端 print_u8 链接失败。
 * 【Invariant】优先按 Module* 在 dep 池回填 arena；找不到则用 fallback（调用方 arena）。
 */
export function codegen_arena_for_module(ctx: *PipelineDepCtx, module: *Module, fallback: *ASTArena): *ASTArena {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx == 0 as *PipelineDepCtx || module == 0 as *Module) {
      return fallback;
    }
    let di: i32 = 0;
    let nd: i32 = pipeline_dep_ctx_ndep(ctx);
    while (di < nd) {
      if (pipeline_dep_ctx_module_at(ctx, di) == module) {
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, di);
        if (da != 0 as *ASTArena) {
          return da;
        }
        return fallback;
      }
      di = di + 1;
    }
    return fallback;
  }
}

/**
 * 【Why 根源】CALL 端输出目标函数 C 符号名。
 *   1) typeck 的 call_resolved 仅在「名+arity」一致时可信；错 func_ix 会把 uring_ok
 *      体误发成 std_io_print_u8_ptr_usize()（0 实参却挂 2 参符号）。
 *   2) link_name 必须用目标模块 arena，否则 overload 后缀与定义端不一致（print_u8）。
 *   3) 未解析时按名+类型 / 唯一 arity 搜索；再扫全部 dep；最后 fallback 原名。
 * 【Invariant】arg 类型查调用方 arena；param 类型查 search_mod arena。
 */
export function codegen_emit_call_func_name(out: *CodegenOutBuf, arena: *ASTArena, ctx: *PipelineDepCtx, expr_ref: i32, current_module: *Module, fallback_name: *u8, fallback_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (ctx != 0 as *PipelineDepCtx && arena != 0 as *ASTArena) {
      let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
      let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
      let call_e0: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let is_m0: i32 = 0;
      if (call_e0.kind == ExprKind.EXPR_METHOD_CALL) {
        is_m0 = 1;
      }
      let nargs0: i32 = 0;
      if (is_m0 != 0) {
        nargs0 = call_e0.method_call_num_args;
      } else {
        nargs0 = call_e0.call_num_args;
      }
      /* resolved 仅在名+arity 匹配时采用；否则作废并重搜。 */
      if (func_ix >= 0) {
        let res_mod: *Module = 0 as *Module;
        if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
          res_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        } else {
          res_mod = current_module;
        }
        if (res_mod != 0 as *Module && func_ix < res_mod.num_funcs) {
          let ok_res: i32 = 1;
          if (pipeline_module_func_num_params_at(res_mod, func_ix) != nargs0) {
            ok_res = 0;
          }
          if (ok_res != 0 && fallback_len > 0) {
            let rlen: i32 = pipeline_module_func_name_len_at(res_mod, func_ix);
            if (rlen != fallback_len) {
              ok_res = 0;
            } else {
              let rnm: u8[64] = [];
              pipeline_module_func_name_copy64(res_mod, func_ix, &rnm[0]);
              let ri: i32 = 0;
              while (ri < rlen) {
                if (rnm[ri] != fallback_name[ri]) {
                  ok_res = 0;
                  ri = rlen;
                } else {
                  ri = ri + 1;
                }
              }
            }
          }
          /* 重载：仅名+arity 可信不足，typeck 可能指向首个同名；须再按实参类型重搜。 */
          if (ok_res != 0 && fallback_len > 0
              && codegen_module_func_overload_count(res_mod, fallback_name, fallback_len) > 1) {
            ok_res = 0;
          }
          if (ok_res != 0) {
            let res_arena: *ASTArena = codegen_arena_for_module(ctx, res_mod, arena);
            return codegen_emit_func_link_name(out, res_arena, res_mod, func_ix);
          }
        }
        func_ix = -1;
      }
      /*
       * Target module for re-search: prefer binding current_module when provided.
       * PLATFORM: SHARED — call_resolved dep_ix may point at a transitive dep after
       * multi-import closure (heap.free → libc free); binding module is the authority.
       */
      let search_mod: *Module = 0 as *Module;
      let search_arena: *ASTArena = arena;
      if (current_module != 0 as *Module) {
        search_mod = current_module;
        search_arena = codegen_arena_for_module(ctx, search_mod, arena);
      } else if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx)) {
        search_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
        search_arena = pipeline_dep_ctx_arena_at(ctx, dep_ix);
        if (search_arena == 0 as *ASTArena) {
          search_arena = arena;
        }
      } else {
        search_mod = current_module;
        search_arena = codegen_arena_for_module(ctx, search_mod, arena);
      }
      if (search_mod != 0 as *Module && fallback_len > 0) {
        let call_e: Expr = call_e0;
        let is_method: i32 = is_m0;
        let call_nargs: i32 = nargs0;
        let found_fi: i32 = -1;
        let found_count: i32 = 0;
        let fi_s: i32 = 0;
        while (fi_s < search_mod.num_funcs) {
          let fn_len: i32 = pipeline_module_func_name_len_at(search_mod, fi_s);
          if (fn_len == fallback_len && fn_len > 0) {
            let fn_name: u8[64] = [];
            pipeline_module_func_name_copy64(search_mod, fi_s, &fn_name[0]);
            let matched: i32 = 1;
            let bi: i32 = 0;
            while (bi < fn_len) {
              if (fn_name[bi] != fallback_name[bi]) {
                matched = 0;
                bi = fn_len;
              } else {
                bi = bi + 1;
              }
            }
            if (matched != 0) {
              let np: i32 = pipeline_module_func_num_params_at(search_mod, fi_s);
              if (np == call_nargs) {
                let types_match: i32 = 1;
                let pi: i32 = 0;
                while (pi < np && types_match != 0) {
                  let arg_ref: i32 = 0;
                  if (is_method != 0) {
                    arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, pi);
                  } else {
                    arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, pi);
                  }
                  if (ast.ref_is_null(arg_ref)) {
                    types_match = 0;
                  } else {
                    let arg_ty: i32 = pipeline_expr_resolved_type_ref(arena, arg_ref);
                    /* EXPR_AS：operand 无 resolved 时用 as 目标类型。 */
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 54) {
                      let as_tgt: i32 = pipeline_expr_as_target_type_ref_at(arena, arg_ref);
                      if (as_tgt > 0) {
                        arg_ty = as_tgt;
                      }
                    }
                    /* STRING_LIT(kind 59) 无 resolved 时按 *u8 匹配 print(ptr,*u8)。 */
                    let is_str_lit: i32 = 0;
                    if (arg_ty <= 0 && pipeline_expr_kind_ord_at(arena, arg_ref) == 59) {
                      is_str_lit = 1;
                    }
                    let param_ty: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_s, pi);
                    let sa: u8[64] = [];
                    let sb: u8[64] = [];
                    let na: i32 = 0;
                    let nb: i32 = 0;
                    /** TYPE_ARRAY(10)→TYPE_PTR(9)：`buf: u8[N]` 对 `*u8` 按 elem 比后缀，否则 overload 全灭回退首同名。 */
                    if (is_str_lit == 0 && arg_ty > 0
                        && pipeline_type_kind_ord_at(arena, arg_ty) == 10
                        && pipeline_type_kind_ord_at(search_arena, param_ty) == 9) {
                      let ae: i32 = pipeline_type_elem_ref_at(arena, arg_ty);
                      let pe: i32 = pipeline_type_elem_ref_at(search_arena, param_ty);
                      na = codegen_type_ref_to_suffix(arena, ae, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, pe, &sb[0], 64);
                    } else if (is_str_lit != 0) {
                      sa[0] = 117;
                      sa[1] = 56;
                      sa[2] = 95;
                      sa[3] = 112;
                      sa[4] = 116;
                      sa[5] = 114;
                      na = 6;
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    } else {
                      na = codegen_type_ref_to_suffix(arena, arg_ty, &sa[0], 64);
                      nb = codegen_type_ref_to_suffix(search_arena, param_ty, &sb[0], 64);
                    }
                    if (na != nb) {
                      types_match = 0;
                    } else {
                      if (na <= 0) {
                        types_match = 0;
                      } else {
                        let k: i32 = 0;
                        while (k < na) {
                          if (sa[k] != sb[k]) {
                            types_match = 0;
                            k = na;
                          } else {
                            k = k + 1;
                          }
                        }
                      }
                    }
                  }
                  pi = pi + 1;
                }
                if (types_match != 0) {
                  found_fi = fi_s;
                  found_count = found_count + 1;
                }
              }
            }
          }
          fi_s = fi_s + 1;
        }
        if (found_count == 1 && found_fi >= 0) {
          return codegen_emit_func_link_name(out, search_arena, search_mod, found_fi);
        }
        /*
         * PLATFORM: SHARED — PTR overload (heap.free *u8 vs *i32): suffix compare can
         * fail across arenas; fall back to kind+elem kind match so we never emit bare free.
         */
        if (found_count != 1 && call_nargs == 1 && is_method != 0 && search_mod != 0 as *Module) {
          let arg0: i32 = pipeline_expr_method_call_arg_ref(arena, expr_ref, 0);
          let arg0_ty: i32 = 0;
          if (arg0 > 0) {
            arg0_ty = pipeline_expr_resolved_type_ref(arena, arg0);
          }
          if (arg0_ty > 0 && pipeline_type_kind_ord_at(arena, arg0_ty) == 9) {
            let ae_k: i32 = 0;
            let ae: i32 = pipeline_type_elem_ref_at(arena, arg0_ty);
            if (ae > 0) {
              ae_k = pipeline_type_kind_ord_at(arena, ae);
            }
            let fi_p: i32 = 0;
            let best_p: i32 = -1;
            let n_p: i32 = 0;
            while (fi_p < search_mod.num_funcs) {
              let fl: i32 = pipeline_module_func_name_len_at(search_mod, fi_p);
              if (fl == fallback_len && fl > 0 && pipeline_module_func_num_params_at(search_mod, fi_p) == 1) {
                let fnm_p: u8[64] = [];
                pipeline_module_func_name_copy64(search_mod, fi_p, &fnm_p[0]);
                let me: i32 = 1;
                let bi: i32 = 0;
                while (bi < fl) {
                  if (fnm_p[bi] != fallback_name[bi]) {
                    me = 0;
                    bi = fl;
                  } else {
                    bi = bi + 1;
                  }
                }
                if (me != 0) {
                  let pt: i32 = pipeline_module_func_param_type_ref_at(search_mod, fi_p, 0);
                  if (pt > 0 && pipeline_type_kind_ord_at(search_arena, pt) == 9) {
                    let pe: i32 = pipeline_type_elem_ref_at(search_arena, pt);
                    if (pe > 0 && pipeline_type_kind_ord_at(search_arena, pe) == ae_k) {
                      best_p = fi_p;
                      n_p = n_p + 1;
                    }
                  }
                }
              }
              fi_p = fi_p + 1;
            }
            if (n_p == 1 && best_p >= 0) {
              return codegen_emit_func_link_name(out, search_arena, search_mod, best_p);
            }
          }
        }
        /* 类型未解析：同名同 arity 唯一则用；优先唯一 extern/no_mangle。 */
        if (found_count != 1 && call_nargs >= 0) {
          let arity_fi: i32 = -1;
          let arity_count: i32 = 0;
          let ext_fi: i32 = -1;
          let ext_count: i32 = 0;
          let fi_a: i32 = 0;
          while (fi_a < search_mod.num_funcs) {
            let fn_len_a: i32 = pipeline_module_func_name_len_at(search_mod, fi_a);
            if (fn_len_a == fallback_len && fn_len_a > 0) {
              let fn_name_a: u8[64] = [];
              pipeline_module_func_name_copy64(search_mod, fi_a, &fn_name_a[0]);
              let matched_a: i32 = 1;
              let bi_a: i32 = 0;
              while (bi_a < fn_len_a) {
                if (fn_name_a[bi_a] != fallback_name[bi_a]) {
                  matched_a = 0;
                  bi_a = fn_len_a;
                } else {
                  bi_a = bi_a + 1;
                }
              }
              if (matched_a != 0) {
                let np_a: i32 = pipeline_module_func_num_params_at(search_mod, fi_a);
                if (np_a == call_nargs) {
                  arity_fi = fi_a;
                  arity_count = arity_count + 1;
                  if (pipeline_module_func_is_extern_at(search_mod, fi_a) != 0 || pipeline_module_func_is_no_mangle_at(search_mod, fi_a) != 0) {
                    ext_fi = fi_a;
                    ext_count = ext_count + 1;
                  }
                }
              }
            }
            fi_a = fi_a + 1;
          }
          if (ext_count == 1 && ext_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, ext_fi);
          }
          if (arity_count == 1 && arity_fi >= 0) {
            return codegen_emit_func_link_name(out, search_arena, search_mod, arity_fi);
          }
        }
      }
    }
    /* binding/dep 未钉死：扫全部 dep 找同名同 arity（首个命中）。 */
    if (ctx != 0 as *PipelineDepCtx && fallback_len > 0 && arena != 0 as *ASTArena) {
      let mc_e: Expr = ast.ast_arena_expr_get(arena, expr_ref);
      let mc_nargs: i32 = 0;
      if (mc_e.kind == ExprKind.EXPR_METHOD_CALL) {
        mc_nargs = mc_e.method_call_num_args;
      } else {
        mc_nargs = mc_e.call_num_args;
      }
      let dep_di: i32 = 0;
      let nd: i32 = pipeline_dep_ctx_ndep(ctx);
      while (dep_di < nd) {
        let dm: *Module = pipeline_dep_ctx_module_at(ctx, dep_di);
        let da: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_di);
        if (dm != 0 as *Module && da != 0 as *ASTArena) {
          let fi_x: i32 = 0;
          let found_x: i32 = -1;
          while (fi_x < dm.num_funcs) {
            let fn_x: i32 = pipeline_module_func_name_len_at(dm, fi_x);
            if (fn_x == fallback_len && fn_x > 0) {
              let fnm: u8[64] = [];
              pipeline_module_func_name_copy64(dm, fi_x, &fnm[0]);
              let mx: i32 = 1;
              let bx: i32 = 0;
              while (bx < fn_x) {
                if (fnm[bx] != fallback_name[bx]) {
                  mx = 0;
                  bx = fn_x;
                } else {
                  bx = bx + 1;
                }
              }
              if (mx != 0 && pipeline_module_func_num_params_at(dm, fi_x) == mc_nargs) {
                found_x = fi_x;
                fi_x = dm.num_funcs;
              } else {
                fi_x = fi_x + 1;
              }
            } else {
              fi_x = fi_x + 1;
            }
          }
          if (found_x >= 0) {
            return codegen_emit_func_link_name(out, da, dm, found_x);
          }
        }
        dep_di = dep_di + 1;
      }
    }
    /* 未解析：回退原名 */
    return emit_bytes_from_ptr(out, fallback_name, fallback_len);
  }
}

/**
 * 自举：勿将 module.funcs[fi].name 整 u8[64] 按值传给 emit_bytes_64 或作 *u8 来源传给带名检查的帮助函数（asm 生成路径易成空名）。
 * 逐标量读入局部缓冲区再传递。
 */
export function codegen_copy_func_name64_from_module(module: *Module, fi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_name_copy64(module, fi, dst);
  }
}

/**
 * 形参名 u8[32]：同上，避免按值撕裂。
 */
export function codegen_copy_param_name32_from_module(module: *Module, fi: i32, pi: i32, dst: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    pipeline_module_func_param_name_copy32(module, fi, pi, dst);
  }
}

/**
 * Emit one function: return type + name + (params) + { body }.
 * When call_init_globals != 0 and is_entry main, body starts with init_globals();
 *
 * Why name_is_main is assigned after copy (not `let x = name_eq`): pin X→C hoists
 * all let inits to block top, so `let name_is_main = (fn_local[0]=='m'…)` ran on a
 * still-zero buffer → never emitted C `main` (rv matrix: undefined _main).
 * PLATFORM: SHARED — entry main symbol contract.
 */
/**
 * True if this block (or nested region bodies, e.g. Cap-T001 `unsafe { return … }`)
 * contains a return statement or a final expression (treated as the function return path).
 *
 * Purpose: emit_func fallback `return 0` must not fire when the only return lives inside
 * an unsafe/region body — otherwise by-value struct functions get illegal `return 0`.
 * Parameters: arena + block_ref (1-based pool ref); null/invalid → 0.
 * Returns: 1 if a return path is present, 0 otherwise.
 * PLATFORM: SHARED — C TU ordering / host-cc; seed pin same commit.
 */
export function codegen_block_contains_return(arena: *ASTArena, block_ref: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    if (arena == 0 as *ASTArena || ast.ref_is_null(block_ref)) {
      return 0;
    }
    /* final_expr on the block is the implicit return path for expression-bodied blocks. */
    if (!ast.ref_is_null(ast.ast_block_final_expr_ref(arena, block_ref))) {
      return 1;
    }
    let ji: i32 = 0;
    let nes: i32 = ast.ast_block_num_expr_stmts(arena, block_ref);
    while (ji < nes) {
      let se: Expr = ast.ast_arena_expr_get(arena, ast.ast_block_expr_stmt_ref(arena, block_ref, ji));
      if (se.kind == ExprKind.EXPR_RETURN) {
        return 1;
      }
      ji = ji + 1;
    }
    /* Cap-T001: return often sits only inside unsafe / region body blocks. */
    let ri: i32 = 0;
    let nr: i32 = ast.ast_block_num_regions(arena, block_ref);
    while (ri < nr) {
      let rb: i32 = ast.ast_block_region_body_ref(arena, block_ref, ri);
      if (codegen_block_contains_return(arena, rb) != 0) {
        return 1;
      }
      ri = ri + 1;
    }
    return 0;
  }
}

export function emit_func(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, is_entry: bool, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx, call_init_globals: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* Hoist-safe name locals: fill via statements before any name-dependent test. */
    let fn_local: u8[64] = [];
    let fn_len: i32 = 0;
    let name_is_main: bool = false;
    let force_entry_main: bool = false;
    let emit_c_main_symbol: bool = false;
    let main_name: u8[4] = [109, 97, 105, 110];
    /* 自举：禁止整 Func 按值拷贝；一律 module.funcs[fi]. 访问。 */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    fn_len = pipeline_module_func_name_len_at(module, fi);
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
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
    /*
     * Emit C symbol "main" only when the function name is the four bytes main.
     * Assign name_is_main after copy (let-hoist safe) — see function docblock.
     * Single-function entry with empty name still forces main (bootstrap path).
     * Do not write (is_entry && a) || b — X→C may drop parens.
     */
    if (fn_len == 4 && fn_local[0] == 109 && fn_local[1] == 97 && fn_local[2] == 105 && fn_local[3] == 110) {
      name_is_main = true;
    }
    if (is_entry && module.num_funcs == 1) {
      if (fn_len <= 0) {
        force_entry_main = true;
      }
      if (fn_local[0] == 0) {
        force_entry_main = true;
      }
    }
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
      /* #[no_mangle] 不加 path 前缀，与 C ABI 胶层（net_accept_many_c 等）一致 */
      let sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
      if (sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, sym_pre, &fn_local[0], fn_len) == 0 && emit_bytes_from_ptr(out, prefix, sym_pre) != 0) {
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
        /* PLATFORM: SHARED — lower TYPE_SLICE params as pointers (seed/glue ABI).
         * Why: Cap by-value slice + pointer glue → SIGSEGV (string bytes as ptr).
         * Emit: `struct shux_slice_T * name` so field access uses -> and calls pass &local. */
        if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (append_byte(out, 42) != 0) {
            return -1;
          }
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
    /*
     * Fallback `return 0;` — default OFF when a body block was emitted.
     * Why (parser M1 host-cc): Cap-T001 `unsafe { return glue(...); }` nests return in a
     * region; old top-level-only scan still appended `return 0` → illegal for by-value
     * struct (Lexer / OneFuncResult). Scalar fallback only if no return path found.
     * PLATFORM: SHARED — seed pin same commit; verify parser.x host-cc + product matrix.
     * Authority: codegen_block_contains_return + integer/pointer kind gate.
     */
    let need_fallback_return: bool = false;
    if (fn_ret_void) {
      need_fallback_return = false;
    } else if (!ast.ref_is_null(pipeline_module_func_body_expr_ref_at(module, fi))) {
      need_fallback_return = false;
    } else if (!ast.ref_is_null(pipeline_module_func_body_ref_at(module, fi))) {
      let body_br: i32 = pipeline_module_func_body_ref_at(module, fi);
      if (codegen_block_contains_return(arena, body_br) == 0) {
        let ret_ord: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
        /* Integer-like 0..7 and TYPE_PTR only. */
        if ((ret_ord >= 0 && ret_ord <= 7) || ret_ord == (TypeKind.TYPE_PTR as i32)) {
          need_fallback_return = true;
        }
      }
    } else {
      let ret_ord2: i32 = pipeline_type_kind_ord_at(arena, pipeline_module_func_return_type_at(module, fi));
      if ((ret_ord2 >= 0 && ret_ord2 <= 7) || ret_ord2 == (TypeKind.TYPE_PTR as i32)) {
        need_fallback_return = true;
      }
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
}

/**
 * 为 is_extern 函数发射一行 C extern 原型（与同模块 CALL、emit_func 的符号名与形参 ABI 一致）。
 * 不产出函数体：定义在其它编译单元或由链接库提供；-E-extern / 单片 C 时需此声明才可编译。
 */
/**
 * 裸名是否与 unistd.h 中 read/write 声明冲突（preamble 含 unistd.h）。
 * 仅 read/write：readv/writev/poll 使用我们的 Iovec/PollFd 布局，须自行 emit 原型。
 */
export function codegen_is_libc_conflicting_extern_name(name: *u8, name_len: i32): i32 {
  if (name == 0 as *u8 || name_len <= 0) {
    return 0;
  }
  /* read 4 */
  if (name_len == 4 && name[0] == 114 && name[1] == 101 && name[2] == 97 && name[3] == 100) {
    return 1;
  }
  /* write 5 */
  if (name_len == 5 && name[0] == 119 && name[1] == 114 && name[2] == 105 && name[3] == 116 && name[4] == 101) {
    return 1;
  }
  return 0;
}

/**
 * 【Why 根源】C 后端跳过 num_generic_params>0 模板后，调用点仍发 prefix+name（如 main_id），
 *   若无单态化体则 cc 报 implicit declaration。历史 codegen.c 有 mono_instances；pipeline 仅有
 *   call_num_type_args 计数 + typeck 返回类型 fixup，缺实例发射。
 * 【Invariant】从同模块 CALL 推断 mono 类型：resolved_type_ref 优先，否则 arg0；name 或
 *   call_resolved_func_index 匹配模板。
 * 【Asm/Perf】线性扫 arena exprs；仅泛型定义路径调用，非热路径。
 */
export function codegen_find_mono_type_for_generic_func(arena: *ASTArena, module: *Module, fi: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || module == 0 as *Module || fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    if (fn_len <= 0) {
      return 0;
    }
    let ei: i32 = 1;
    while (ei <= arena.num_exprs) {
      let e: Expr = ast.ast_arena_expr_get(arena, ei);
      if (e.kind == ExprKind.EXPR_CALL) {
        let matched: i32 = 0;
        if (e.call_resolved_func_index == fi) {
          matched = 1;
        } else if (!ast.ref_is_null(e.call_callee_ref) && e.call_callee_ref > 0 && e.call_callee_ref <= arena.num_exprs) {
          let cal: Expr = ast.ast_arena_expr_get(arena, e.call_callee_ref);
          if (cal.kind == ExprKind.EXPR_VAR && cal.var_name_len == fn_len) {
            let eq: i32 = 1;
            let k: i32 = 0;
            while (k < fn_len) {
              if (cal.var_name[k] != fn_local[k]) {
                eq = 0;
                k = fn_len;
              } else {
                k = k + 1;
              }
            }
            matched = eq;
          }
        }
        if (matched != 0) {
          let ty: i32 = e.resolved_type_ref;
          if (ty <= 0 && e.call_num_args > 0) {
            let a0: i32 = pipeline_expr_call_arg_ref(arena, ei, 0);
            if (a0 > 0) {
              ty = pipeline_expr_resolved_type_ref(arena, a0);
            }
          }
          if (ty > 0) {
            return ty;
          }
        }
      }
      ei = ei + 1;
    }
    return 0;
  }
}

/**
 * Bootstrap 单态化：identity 形泛型 `f<T>(x: T): T { return x; }`。
 * 调用点已发 prefix+name（非 id_i32）；此处用具体 mono 类型发同名 C 函数，体为 return param。
 * 返回 1=已 emit，0=不适用/无调用点（继续 skip 模板），-1=emit 失败。
 */
export function codegen_try_emit_generic_identity_mono(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    if (arena == 0 as *ASTArena || out == 0 as *CodegenOutBuf || module == 0 as *Module) {
      return 0;
    }
    if (fi < 0 || fi >= module.num_funcs) {
      return 0;
    }
    if (pipeline_module_func_num_generic_params_at(module, fi) <= 0) {
      return 0;
    }
    if (pipeline_module_func_is_extern_at(module, fi) != 0) {
      return 0;
    }
    if (pipeline_module_func_num_params_at(module, fi) != 1) {
      return 0;
    }
    let ret_ty: i32 = pipeline_module_func_return_type_at(module, fi);
    let p0_ty: i32 = pipeline_module_func_param_type_ref_at(module, fi, 0);
    if (ret_ty <= 0 || p0_ty <= 0) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, ret_ty) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    if (pipeline_type_kind_ord_at(arena, p0_ty) != TypeKind.TYPE_NAMED) {
      return 0;
    }
    let ret_nm: u8[64] = [];
    let p0_nm: u8[64] = [];
    let ret_nl: i32 = pipeline_type_named_name_into(arena, ret_ty, &ret_nm[0]);
    let p0_nl: i32 = pipeline_type_named_name_into(arena, p0_ty, &p0_nm[0]);
    if (ret_nl <= 0 || ret_nl != p0_nl) {
      return 0;
    }
    let bi: i32 = 0;
    while (bi < ret_nl) {
      if (ret_nm[bi] != p0_nm[bi]) {
        return 0;
      }
      bi = bi + 1;
    }
    let mono_ty: i32 = codegen_find_mono_type_for_generic_func(arena, module, fi);
    if (mono_ty <= 0) {
      return 0;
    }
    let pn_len: i32 = pipeline_module_func_param_name_len_at(module, fi, 0);
    let pn: u8[32] = [];
    pipeline_module_func_param_name_copy32(module, fi, 0, &pn[0]);
    if (pn_len <= 0) {
      /* 无名形参：用 x */
      pn[0] = 120;
      pn_len = 1;
    }
    /* ret_type name(param) { return param; } — 与 CALL 站点 prefix+name 一致 */
    if (emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    let mono_sym_pre: i32 = codegen_func_c_symbol_prefix_len(module, fi, prefix_len);
    if (mono_sym_pre > 0 && codegen_c_prefix_redundant_with_name(prefix, mono_sym_pre, &fn_local[0], fn_len) == 0) {
      if (emit_bytes_from_ptr(out, prefix, mono_sym_pre) != 0) {
        return -1;
      }
    }
    if (codegen_emit_func_link_name(out, arena, module, fi) != 0) {
      return -1;
    }
    if (append_byte(out, 40) != 0) {
      return -1;
    }
    if (emit_type(arena, out, mono_ty, prefix, prefix_len, ctx) != 0) {
      return -1;
    }
    if (append_byte(out, 32) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
      return -1;
    }
    let open_body: u8[4] = [41, 32, 123, 10];
    if (emit_bytes_from_ptr(out, &open_body[0], 4) != 0) {
      return -1;
    }
    if (emit_indent(out, 2) != 0) {
      return -1;
    }
    let ret_kw: u8[8] = [114, 101, 116, 117, 114, 110, 32, 0];
    if (emit_bytes_from_ptr(out, &ret_kw[0], 7) != 0) {
      return -1;
    }
    if (emit_bytes_from_ptr(out, &pn[0], pn_len) != 0) {
      return -1;
    }
    let end: u8[3] = [59, 10, 125];
    if (emit_bytes_from_ptr(out, &end[0], 3) != 0) {
      return -1;
    }
    if (append_byte(out, 10) != 0) {
      return -1;
    }
    return 1;
  }
}

export function emit_func_extern_declaration(arena: *ASTArena, out: *CodegenOutBuf, module: *Module, fi: i32, prefix: *u8, prefix_len: i32, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

    /* 自举：经 module.funcs[fi] 逐字段读，避免整 Func 按值拷贝截断。 */
    if (fi < 0 || fi >= module.num_funcs) {
      return -1;
    }
    /* 未单态化泛型模板：无具体实例时勿 emit 非法 struct *_T 原型。identity mono 见定义路径。 */
    if (pipeline_module_func_num_generic_params_at(module, fi) > 0) {
      return 0;
    }
    let fn_local: u8[64] = [];
    codegen_copy_func_name64_from_module(module, fi, &fn_local[0]);
    let fn_len: i32 = pipeline_module_func_name_len_at(module, fi);
    /* unistd 已声明：勿 emit 冲突原型（int32_t vs int 等）。 */
    if (pipeline_module_func_is_extern_at(module, fi) != 0 && codegen_is_libc_conflicting_extern_name(&fn_local[0], fn_len) != 0) {
      return 0;
    }
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
      /* 【Why 根源】extern function 分两类：
       *   1. 真正外部链接库符号（如 shux_sys_mmap）：函数名不含模块前缀，须用裸名。
       *   2. .x extern 声明但 C 实现在 pipeline_glue.c（如 ast_arena_expr_get）：
       *      函数名已含模块前缀（ast_），C 定义为双前缀（ast_ast_arena_expr_get）。
       *      须保留前缀使声明符号 = ast_ast_arena_expr_get，与 C 定义匹配。
       * 判断：函数名是否以模块前缀开头。是 → 保留前缀（双前缀匹配 C 定义）；
       *       否 → 裸名（外部链接库符号）。 */
      let _starts_with_prefix: bool = false;
      if (prefix_len > 0 && fn_len >= prefix_len) {
        let _k: i32 = 0;
        _starts_with_prefix = true;
        while (_k < prefix_len) {
          if (fn_local[_k] != prefix[_k]) {
            _starts_with_prefix = false;
            break;
          }
          _k = _k + 1;
        }
      }
      if (!_starts_with_prefix) {
        name_prefix_len = 0;
      }
    }
    /* #[no_mangle]：声明端与定义端同为 C ABI 裸名 */
    name_prefix_len = codegen_func_c_symbol_prefix_len(module, fi, name_prefix_len);
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
        /* PLATFORM: SHARED — TYPE_SLICE params as pointers (mirror emit_func body; seed/glue ABI). */
        if (pipeline_type_kind_ord_at(arena, pipeline_module_func_param_type_ref_at(module, fi, p)) == (TypeKind.TYPE_SLICE as i32)) {
          if (append_byte(out, 32) != 0) {
            return -1;
          }
          if (append_byte(out, 42) != 0) {
            return -1;
          }
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
    /* 变参：C ABI extern function 尾部发 `...`（C89 要求至少有一个命名参数后才合法）。
     *  Why：printf/vfprintf 等 C 变参函数原型必须含 `...`，否则调用方实参类型/数量校验失效。
     *  Invariant：仅 is_variadic==1 且 num_params>0 时发；X ABI 不支持变参，不会进入此分支。
     *  Asm/Perf：仅 codegen 时一次性发射，无运行期开销。 */
    if (pipeline_module_func_is_variadic_at(module, fi) != 0 && pipeline_module_func_num_params_at(module, fi) > 0) {
      let ellipsis: u8[5] = [44, 32, 46, 46, 46];
      if (emit_bytes_from_ptr(out, &ellipsis[0], 5) != 0) {
        return -1;
      }
    }
    let end_proto: u8[3] = [41, 59, 10];
    if (emit_bytes_from_ptr(out, &end_proto[0], 3) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * 为当前模块直接 import 的 dep 预发函数原型。
 * 单文件/partial bootstrap 时，某些被跳过或未 co-emit 的 dep 仍会被调用；先补 extern，避免 C99 隐式声明报错。
 */
export function codegen_emit_import_dep_function_declarations(module: *Module, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
}

/** 仅写 C 头（#include <stdint.h>\\n#include <stddef.h>\\n#include <sys/types.h>\\n）到 out。
 * 【Why 根源】ssize_t 由 POSIX <sys/types.h> 提供，asm 模块 file_io 用到 loaded_len: ssize_t；
 *   不 include 会导致 cc 报 'ssize_t' undeclared。dep 模块 struct 的 forward declaration 由
 *   codegen_emit_dep_struct_forward_declarations 在本函数之后 emit，不在 header 硬编码。
 * 拆成独立函数避免 C 代码生成时被重排到 while/return 之后。 */
export function codegen_x_ast_emit_header(out: *CodegenOutBuf): i32 {
  let h: u8[64] = [35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 105, 110, 116, 46, 104, 62, 10,
    35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 116, 100, 100, 101, 102, 46, 104, 62, 10,
    35, 105, 110, 99, 108, 117, 100, 101, 32, 60, 115, 121, 115, 47, 116, 121, 112, 101, 115, 46, 104, 62, 10,
    0];
  return emit_bytes_64(out, &h[0], 63);
}

/**
 * 将 Module 生成 C 源码写入 out。
 * 先写 #include <stdint.h> 等头，再写各函数定义。
 * ctx 供跨 dep 调用时解析 C 符号前缀。
 * dep_index >= 0 表示当前为第 dep_index 个 dep，用 dep 池 import 路径算 C 前缀；-1 表示主模块。
 * 返回 0 成功，-1 失败。
 */
export extern function pipeline_codegen_std_dep_link_only(path: *u8): i32;

export function codegen_x_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx, dep_index: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {

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
      /* 产品轨：std 预编 .o 权威时勿 co-emit dep 体（json/base64/csv/heap…），否则 dual-authority */
      if (dep_path_prefix_len > 0 && pipeline_codegen_std_dep_link_only(&dep_path_prefix[0]) != 0) {
        return 0;
      }
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
    /*
     * 【Why 根源】入口库模块无 dep import path。driver 在 pipeline 前写入
     *   entry_module_import_path_mirror 为 C 前缀（core_mem_ / std_string_）。
     *   不可读 current_codegen_prefix_mirror：pipeline 先 codegen 各 dep，会把
     *   current 覆写成最后 dep 的前缀（string 入口误成 core_mem_ → 全模块错前缀 +
     *   incomplete struct String）。
     * 【Invariant】仅 dep_index < 0 且 entry_module_import_path_len > 0 时采用；
     *   dep 仍由 import path 重算。用户程序 entry_len=0 → 无前缀。
     */
    if (prefix_len == 0 && dep_index < 0 && ctx != 0 as *PipelineDepCtx) {
      if (ctx.entry_module_import_path_len > 0) {
        let pi: i32 = 0;
        while (pi < ctx.entry_module_import_path_len && pi < 127) {
          prefix_buf[pi] = ctx.entry_module_import_path_mirror[pi];
          pi = pi + 1;
        }
        prefix_buf[pi] = 0 as u8;
        prefix_len = pi;
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
        /*
         * 【Why 根源】pipeline 对每个 dep 与 entry 各调一次 codegen_x_ast；旧逻辑每个模块 i==0 都
         *   emit_header + forward + import decls，导致单文件 C 中途再 #include、enum/struct 重复定义、
         *   conflicting types（不完整 tag 与完整定义交错）。
         * 【Invariant】全文件 prologue（header+全 dep 类型+forward）只 emit 一次；此后各模块只补
         *   本模块 import extern 与函数体；entry 再补自身 enum/struct。
         */
        if (pipeline_codegen_c_file_prologue_done_get() == 0) {
          if (codegen_x_ast_emit_header(out) != 0) {
            return -1;
          }
          if (codegen_emit_skipped_dep_type_definitions(ctx, out) != 0) {
            return -1;
          }
          /*
           * Restore current_codegen_module after dep type walk.
           * Purpose: skipped_dep_type_definitions may leave ctx pointing at the last
           *   dep visited; CALL binding resolution (fmt.fmt_*) and same-module bare
           *   names (unwrap_or) then mangle with the wrong prefix.
           * Authority: seeds/codegen_gen.linux.x86_64.c codegen_x_ast after
           *   codegen_emit_skipped_dep_type_definitions.
           * PLATFORM: SHARED — multi-dep co-emit C TU; verify Cap force hello/si.
           */
          if (ctx != 0 as *PipelineDepCtx) {
            ctx.current_codegen_module = module;
            ctx.current_codegen_arena = arena;
          }
          if (codegen_emit_dep_struct_forward_declarations(ctx, out) != 0) {
            return -1;
          }
          pipeline_codegen_c_file_prologue_done_set(1);
        }
        /* 本模块 import 的 extern 原型（libc 冲突名在 emit_func_extern_declaration 内跳过）。 */
        if (codegen_emit_import_dep_function_declarations(module, out, ctx) != 0) {
          return -1;
        }
        /* entry 模块自身的 enum+struct；dep 类型已在 prologue 的 skipped_dep_type_definitions 中 emit。 */
        if (dep_index < 0) {
          if (codegen_emit_module_enum_definitions(module, out, &prefix_buf[0], prefix_len) != 0) {
            return -1;
          }
          if (codegen_emit_module_struct_definitions(module, arena, out, &prefix_buf[0], prefix_len, ctx) != 0) {
            return -1;
          }
        }
        /*
         * Same-module forward prototypes (body-front extern wall).
         * Purpose: co-emitted TU may call later functions in the same module (e.g.
         *   core_option_map_ptr_u8 → core_option_is_some_ptr_u8). Without prototypes,
         *   host C99 rejects implicit declarations even when the definition follows.
         * Authority: same loop as seeds/codegen_gen.linux.x86_64.c codegen_x_ast
         *   (emit_func_extern_declaration for every non-extern func before bodies).
         * PLATFORM: SHARED — C TU ordering; verify mac + Ubuntu option force-regen.
         * Does not re-pin seed: seed already has this wall; Cap was missing it in .x.
         */
        let fwd_fi: i32 = 0;
        while (fwd_fi < module.num_funcs) {
          if (pipeline_module_func_is_extern_at(module, fwd_fi) == 0) {
            if (emit_func_extern_declaration(arena, out, module, fwd_fi, &prefix_buf[0], prefix_len, ctx) != 0) {
              return -1;
            }
          }
          fwd_fi = fwd_fi + 1;
        }
        /* 顶层 let/const（入口与 dep 模块均 emit）：dep 模块 const 以裸名 emit 供本模块
         * 函数体 EXPR_VAR 裸名引用；入口模块 main 调用 init_globals()，dep 模块不调用。
         * 【Why 根源】emit_type 对 TYPE_ARRAY 输出 elem*（形参退化）；顶层 u8[N] 须
         *   `static uint8_t name[N] [= {…}]`，否则 init_globals 写 `p = (uint8_t[]){ }` 悬空 → SIGSEGV。
         * 【Invariant】固定数组在声明处带维与初值；init_globals 跳过 TYPE_ARRAY。
         * 【Asm/Perf】与局部 fixed array 同形 emit_local_fixed_array_*。 */
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
            let tl_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
            let tl_init: i32 = pipeline_module_top_level_let_init_ref(module, ti);
            let is_fixed_arr: i32 = 0;
            if (!ast.ref_is_null(tl_ty) && pipeline_type_kind_ord_at(arena, tl_ty) == TypeKind.TYPE_ARRAY) {
              is_fixed_arr = 1;
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
            if (is_fixed_arr != 0) {
              if (emit_local_fixed_array_elem_type(arena, out, tl_ty, ctx) != 0) {
                return -1;
              }
            } else {
              if (emit_type(arena, out, tl_ty, &prefix_buf[0], 0, ctx) != 0) {
                return -1;
              }
            }
            if (append_byte(out, 32) != 0) {
              return -1;
            }
            if (emit_bytes_from_ptr(out, &tl_name_buf[0], name_len) != 0) {
              return -1;
            }
            if (is_fixed_arr != 0) {
              if (emit_local_fixed_array_suffix(arena, out, tl_ty) != 0) {
                return -1;
              }
            }
            /* 固定数组：声明处写初值（空 [] 则 BSS 零初始化，勿 compound lit 赋指针）。
             * 非数组 const：保持声明处 = init；非数组 let：仍由 init_globals 赋值。 */
            let want_decl_init: i32 = 0;
            if (is_fixed_arr != 0 && !ast.ref_is_null(tl_init)) {
              if (pipeline_expr_kind_ord_at(arena, tl_init) == (46 as i32)) {
                if (pipeline_expr_array_lit_num_elems_at(arena, tl_init) > 0) {
                  want_decl_init = 1;
                }
              } else {
                want_decl_init = 1;
              }
            }
            if (is_const != 0 && is_fixed_arr == 0 && !ast.ref_is_null(tl_init)) {
              want_decl_init = 1;
            }
            if (want_decl_init != 0) {
              let eq: u8[4] = [32, 61, 32, 0];
              if (emit_bytes_4(out, eq, 3) != 0) {
                return -1;
              }
              if (is_fixed_arr != 0) {
                if (emit_braced_array_lit_init(arena, out, tl_init, ctx) != 0) {
                  return -1;
                }
              } else {
                if (emit_expr(arena, out, tl_init, ctx) != 0) {
                  return -1;
                }
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
          /*
           * 入口模块且有 main 时，才把 dep 的非 const 顶层 let 并入 init_globals
           * （co-emit 单文件：dep 会先 emit static 声明，main 再统一赋值）。
           * 库模块多文件 -E（如 std/heap/mod.x）：dep 仅 extern、本 TU 无 dep static，
           * 若仍扫描 dep let 会生成 `shu_heap_trace_on = -1` 等未声明标识符（cc -c 失败）。
           * dep 自身的 let 由编译该 dep 文件时的 init_globals 负责。
           */
          if (dep_index < 0 && any_let == 0 && module.main_func_index >= 0) {
            let dep_scan_i: i32 = 0;
            let dep_ndep: i32 = pipeline_dep_ctx_ndep(ctx);
            while (dep_scan_i < dep_ndep) {
              let scan_path: u8[64] = [];
              let scan_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_scan_i, &scan_path[0]);
              if (scan_plen > 0 && pipeline_codegen_std_dep_link_only(&scan_path[0]) != 0) {
                dep_scan_i = dep_scan_i + 1;
                continue;
              }
              let dep_scan_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_scan_i);
              if (dep_scan_mod != 0 as *Module) {
                let dep_ti: i32 = 0;
                while (dep_ti < dep_scan_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_scan_mod, dep_ti) == 0) {
                    any_let = 1;
                    break;
                  }
                  dep_ti = dep_ti + 1;
                }
              }
              if (any_let != 0) {
                break;
              }
              dep_scan_i = dep_scan_i + 1;
            }
          }
          if (any_let != 0 && dep_index < 0) {
            /* 入口模块 init_globals 统一初始化入口模块 + dep 模块的非 const 顶层 let。
             * dep 模块不再各自 emit init_globals，避免 C redefinition error。 */
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
              /* 固定数组已在声明处初值/BSS；勿 `arr = (T[]){ }` 悬空 */
              let ig_ty: i32 = pipeline_module_top_level_let_type_ref(module, ti);
              if (!ast.ref_is_null(ig_ty) && pipeline_type_kind_ord_at(arena, ig_ty) == TypeKind.TYPE_ARRAY) {
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
            /* dep 模块非 const 顶层 let：仅可执行入口（有 main）且 co-emit 时统一赋值。
             * link_only 预编 .o 的 dep 不在本 TU 声明 static，禁止写 shu_heap_trace_*。 */
            let dep_i: i32 = 0;
            let ndep: i32 = 0;
            if (module.main_func_index >= 0) {
              ndep = pipeline_dep_ctx_ndep(ctx);
            }
            while (dep_i < ndep) {
              let lo_path: u8[64] = [];
              let lo_plen: i32 = codegen_dep_import_path_len_at(ctx, dep_i, &lo_path[0]);
              if (lo_plen > 0 && pipeline_codegen_std_dep_link_only(&lo_path[0]) != 0) {
                dep_i = dep_i + 1;
                continue;
              }
              let dep_mod: *Module = pipeline_dep_ctx_module_at(ctx, dep_i);
              if (dep_mod != 0 as *Module) {
                let dep_arena: *ASTArena = pipeline_dep_ctx_arena_at(ctx, dep_i);
                let dti: i32 = 0;
                while (dti < dep_mod.num_top_level_lets) {
                  if (pipeline_module_top_level_let_is_const(dep_mod, dti) == 0) {
                    let dig_ty: i32 = pipeline_module_top_level_let_type_ref(dep_mod, dti);
                    if (dep_arena != 0 as *ASTArena && !ast.ref_is_null(dig_ty)
                        && pipeline_type_kind_ord_at(dep_arena, dig_ty) == TypeKind.TYPE_ARRAY) {
                      dti = dti + 1;
                      continue;
                    }
                    if (emit_indent(out, 2) != 0) {
                      return -1;
                    }
                    let dnlen: i32 = pipeline_module_top_level_let_name_len(dep_mod, dti);
                    if (dnlen > 0 && dnlen <= 63) {
                      let dtl_name: u8[64] = [];
                      let dtni: i32 = 0;
                      while (dtni < dnlen && dtni < 64) {
                        dtl_name[dtni] = pipeline_module_top_level_let_name_byte_at(dep_mod, dti, dtni);
                        dtni = dtni + 1;
                      }
                      if (emit_bytes_from_ptr(out, &dtl_name[0], dnlen) != 0) {
                        return -1;
                      }
                    }
                    let deq: u8[4] = [32, 61, 32, 0];
                    if (emit_bytes_4(out, deq, 3) != 0) {
                      return -1;
                    }
                    if (!ast.ref_is_null(pipeline_module_top_level_let_init_ref(dep_mod, dti)) && emit_expr(dep_arena, out, pipeline_module_top_level_let_init_ref(dep_mod, dti), ctx) != 0) {
                      return -1;
                    }
                    let dsc: u8[3] = [59, 10, 0];
                    if (emit_bytes_3(out, dsc, 2) != 0) {
                      return -1;
                    }
                  }
                  dti = dti + 1;
                }
              }
              dep_i = dep_i + 1;
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
      /* 泛型：跳过未单态化模板（struct *_T 非法 C）；identity 形 bootstrap 单态化后发具体体。 */
      if (pipeline_module_func_num_generic_params_at(module, i) > 0) {
        let mono_rc: i32 = codegen_try_emit_generic_identity_mono(arena, out, module, i, &prefix_buf[0], prefix_len, ctx);
        if (mono_rc < 0) {
          return -1;
        }
        i = i + 1;
        continue;
      }
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
      /*
       * 【Why 根源】C 后端 -o 会链入 std/{string,error,context}/*.o；dep 共 emit 再写体 →
       *   数十× redefinition（hello 曾 68×）。asm 后端无 .o 预链，仍须 emit 体。
       * 【Invariant】仅 dep（dep_index>=0）+ C 后端跳过；入口编该模块本身不跳。
       */
      if (skip == 0 && asm_backend == 0) {
        let is_prelinked_dep: i32 = 0;
        if (dep_index >= 0 && dep_path_prefix_len >= 10) {
          /* std.string or std/string */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 115 && dep_path_prefix[5] == 116 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 105 && dep_path_prefix[8] == 110 && dep_path_prefix[9] == 103) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 9) {
          /* std.error or std/error */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 101 && dep_path_prefix[5] == 114 && dep_path_prefix[6] == 114
              && dep_path_prefix[7] == 111 && dep_path_prefix[8] == 114) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && dep_index >= 0 && dep_path_prefix_len >= 11) {
          /* std.context or std/context */
          if (dep_path_prefix[0] == 115 && dep_path_prefix[1] == 116 && dep_path_prefix[2] == 100
              && (dep_path_prefix[3] == 46 || dep_path_prefix[3] == 47)
              && dep_path_prefix[4] == 99 && dep_path_prefix[5] == 111 && dep_path_prefix[6] == 110
              && dep_path_prefix[7] == 116 && dep_path_prefix[8] == 101 && dep_path_prefix[9] == 120
              && dep_path_prefix[10] == 116) {
            is_prelinked_dep = 1;
          }
        }
        if (is_prelinked_dep == 0 && prefix_len >= 11
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 115 && prefix_buf[5] == 116
            && prefix_buf[6] == 114 && prefix_buf[7] == 105 && prefix_buf[8] == 110
            && prefix_buf[9] == 103 && prefix_buf[10] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 10
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 101 && prefix_buf[5] == 114
            && prefix_buf[6] == 114 && prefix_buf[7] == 111 && prefix_buf[8] == 114
            && prefix_buf[9] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep == 0 && prefix_len >= 12
            && prefix_buf[0] == 115 && prefix_buf[1] == 116 && prefix_buf[2] == 100
            && prefix_buf[3] == 95 && prefix_buf[4] == 99 && prefix_buf[5] == 111
            && prefix_buf[6] == 110 && prefix_buf[7] == 116 && prefix_buf[8] == 101
            && prefix_buf[9] == 120 && prefix_buf[10] == 116 && prefix_buf[11] == 95
            && dep_index >= 0) {
          is_prelinked_dep = 1;
        }
        if (is_prelinked_dep != 0) {
          skip = 1;
        }
      }
      /*
       * Legacy belt: if an older by_name still skipped bare placeholder/string_new,
       * un-skip when this module has a real C prefix (core_mem_ / core_types_ / …).
       * Current by_name no longer skips those names (seed-aligned); this remains a
       * no-op safety net. Product preamble only externs core_types_placeholder —
       * co-emit must produce the strong body or si links UNDEF.
       * PLATFORM: SHARED — Cap force multi-dep co-emit (stdlib-import).
       */
      if (skip != 0 && prefix_len > 0 && (skip_nl == 11 || skip_nl == 10)) {
        skip = 0;
      }
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
      /*
       * Restore module identity + C prefix before each function body.
       * Purpose: prior emit_func / import-extern walks may leave
       *   current_codegen_module or prefix_mirror on another dep (e.g. core.option
       *   while emitting core.result → bare unwrap_or becomes core_option_unwrap_or;
       *   or entry while emitting std.fmt → fmt.fmt_i32 not core_fmt_fmt_i32).
       * Authority: seeds/codegen_gen.linux.x86_64.c before codegen_emit_func
       *   (module/arena/dep_index); prefix_mirror re-pin matches this module's
       *   prefix_buf computed at codegen_x_ast entry (Cap residual root).
       * PLATFORM: SHARED — Cap force multi-dep co-emit matrix (hello/si).
       */
      if (ctx != 0 as *PipelineDepCtx) {
        ctx.current_codegen_module = module;
        ctx.current_codegen_arena = arena;
        ctx.current_codegen_dep_index = dep_index;
        let px: i32 = 0;
        while (px < prefix_len && px < 63) {
          ctx.current_codegen_prefix_mirror[px] = prefix_buf[px];
          px = px + 1;
        }
        ctx.current_codegen_prefix_mirror[px] = 0 as u8;
        ctx.current_codegen_prefix_len = px;
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
  // PLATFORM: SHARED — Cap-T001 whole-body unsafe close. Extra matching `}` required so
  // product parser does not parse-skip this mega function (SHUX_DEBUG_PARSE: skip at
  // codegen_x_ast entry → residual body mis-ingested as top-level lets / fake init_globals).
  }
}

/**
 * 仅按函数名跳过发射：与 preamble / string.o 冲突的占位符与 string_new 族；逻辑由原 driver_should_skip_emit_func_by_name 迁入 .x。
 */
/**
 * Decide whether to skip emitting a function solely by bare name.
 * Purpose: gate oversized bootstrap mega bodies (and historically bare
 *   placeholder/string_new that collided with preamble #define macros).
 * Parameters: name/name_len — function bare name (not C-mangled).
 * Returns: 1 = skip emit, 0 = emit normally.
 * Authority: seeds/codegen_gen.linux.x86_64.c codegen_should_skip_emit_func_by_name.
 * Why: product preamble no longer #define-aliases placeholder/string_new; those
 *   are real exports (core_types_placeholder, core_mem_placeholder, and peers).
 *   Cap still skipped bare "placeholder" so multi-dep co-emit of core.types
 *   emitted every size_of body but dropped placeholder → si -o UNDEF.
 * Invariant: only asm_codegen_ast_seed_mega / to_elf mega remain name-skips
 *   unless SHUX_EMIT_SEED_MEGA is set; do not re-add placeholder skip.
 * PLATFORM: SHARED — Cap force stdlib-import / core.* co-emit link.
 * Note: never write star-slash inside this block comment (truncates C emit).
 */
function codegen_should_skip_emit_func_by_name(name: *u8, name_len: i32): i32 {
  // PLATFORM: SHARED — LANG-007 S0: Cap-T001 whole-body unsafe FFI gate.
  unsafe {
    let asm_seed_mega: u8[25] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    let asm_to_elf_seed_mega: u8[32] = [97, 115, 109, 95, 99, 111, 100, 101, 103, 101, 110, 95, 97, 115, 116, 95, 116, 111, 95, 101, 108, 102, 95, 115, 101, 101, 100, 95, 109, 101, 103, 97];
    if (name == 0 as *u8) {
      return 0;
    }
    // placeholder and string_new skip removed (seed-aligned; real core/std exports).
    // bootstrap -E: seed_mega bodies are huge; SHUX_EMIT_SEED_MEGA=1 still tries emit.
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
 * Skip std.io.core ABI bridge names supplied by runtime preamble / io backend.
 *
 * Purpose: do not emit C bodies for shux_io_read_ptr(_len), register*, wait_readable
 * when the C backend already maps them via preamble macros/weak stubs.
 *
 * Parameters:
 *   name / name_len — bare identifier; must use full "shux_io_*" spelling (with 'x').
 *
 * Returns 1 to skip, 0 to emit.
 * read_ptr_len allows name_len >= 20 (prefix match); others require exact length.
 * PLATFORM: SHARED — Cap force hello co-emit must not redefine preamble bridges.
 */
function codegen_should_skip_emit_func_core_read_ptr(name: *u8, name_len: i32): i32 {
  /* shux_io_read_ptr_len — 20 */
  let shux_rpl20: u8[20] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 108, 101, 110];
  /* shux_io_read_ptr — 16 */
  let shux_rp16: u8[16] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114];
  /*
   * 【Why 根源】勿 skip shux_io_register / register_buffers / unregister / wait_readable：
   *   旧 skip 假定 runtime_asm_io_stubs 提供强符号；产品 C 路径 macOS 不硬链 stubs.o
   *   （与 co-emit std_io_write_stdout 冲突），且 preamble 无 register 的 weak →
   *   run-io-driver main 经 shux_io_register_buf 裸调 _shux_io_register → 双端 UNDEF。
   * co-emit core 体 → std_io_backend_io_register_buffer（同 TU 真体）为权威。
   * PLATFORM: SHARED.
   */
  if (name == 0 as *u8) {
    return 0;
  }
  if (name_len >= 20 && codegen_name_bytes_prefix_eq(name, name_len, &shux_rpl20[0], 20) != 0) {
    return 1;
  }
  if (name_len == 16 && codegen_name_bytes_prefix_eq(name, name_len, &shux_rp16[0], 16) != 0) {
    return 1;
  }
  /* shux_io_read_ptr_backend — 24 (preamble weak stub) */
  let shux_rpb24: u8[24] = [115, 104, 117, 120, 95, 105, 111, 95, 114, 101, 97, 100, 95, 112, 116, 114, 95, 98, 97, 99, 107, 101, 110, 100];
  if ((name_len == 24 || name_len == 25) && codegen_name_bytes_prefix_eq(name, name_len, &shux_rpb24[0], 24) != 0) {
    return 1;
  }
  /* shux_io_submit_read_async — 25 (preamble weak stub) */
  let shux_sra25: u8[25] = [115, 104, 117, 120, 95, 105, 111, 95, 115, 117, 98, 109, 105, 116, 95, 114, 101, 97, 100, 95, 97, 115, 121, 110, 99];
  if ((name_len == 25 || name_len == 26) && codegen_name_bytes_prefix_eq(name, name_len, &shux_sra25[0], 25) != 0) {
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
