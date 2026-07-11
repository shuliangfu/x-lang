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

// emit.x — -x -E 与单文件 C/asm 烟测 emit 路径（从 main.x 迁出以瘦身 entry）
// 符号前缀 driver_：run_x_emit_x → driver_run_x_emit_x，dispatch_x_emit_to_c →
// driver_dispatch_x_emit_to_c

// 勿 import ast/codegen/sys：-E 生成 driver_emit_gen.c 时内联类型定义避免递归加载。

/** 内联类型定义（原 import("ast") 提供；字段布局须与 ast_PipelineDepCtx 一致）。 */
allow(padding) struct PipelineDepCtx {
  ndep: i32;
  entry_dir_buf: u8[512];
  entry_dir_len: i32;
  num_lib_roots: i32;
  path_buf: u8[512];
  loaded_buf: u8[4194304];
  loaded_len: isize;
  preprocess_buf: u8[4194304];
  preprocess_len: i32;
  use_asm_backend: i32;
  target_arch: i32;
  target_cpu_features: i32;
  use_macho_o: i32;
  use_coff_o: i32;
  current_block_ref: i32;
  typeck_loop_depth: i32;
  current_func_index: i32;
  skip_codegen_dep_0: i32;
  entry_already_parsed: i32;
  current_func_single_empty_param_index: i32;
  current_func_empty_param_count: i32;
  current_emit_empty_var_next_index: i32;
  emit_expr_as_callee: i32;
  current_codegen_module: *u8;
  current_codegen_arena: *u8;
  current_codegen_dep_index: i32;
  current_codegen_prefix_mirror: u8[64];
  current_codegen_prefix_len: i32;
  asm_entry_module_only: i32;
  entry_module_import_path_mirror: u8[64];
  entry_module_import_path_len: i32;
  typeck_scope_region_len: i32;
  typeck_scope_region_label: u8[64];
}

/** 内联类型定义（原 import("codegen") 提供）。 */
allow(padding) struct CodegenOutBuf {
  data: u8[9437184];
  len: i32;
}

/** std.sys 模块函数（原 sys.read_file_into）；-E 符号名 std_sys_read_file_into。 */
extern function std_sys_read_file_into(path: *u8, buf: *u8, cap: i32): i32;

/** POSIX 读写原语（链 ../std/fs/fs.o）；勿 import("std.fs")，-E-extern 不会内联 fs_read
* 符号名。 */
extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function fs_posix_close_c(fd: i32): i32;
/** preprocess.x 导出名带模块前缀。 */
extern function preprocess_x_buf(source_buf: *u8, source_len: isize, out_buf: *u8,
out_cap: i32): i32;
/** pipeline_glue / ast_pool：堆缓冲生命周期（emit 栈上 ctx 须显式 ensure/free）。
*/
extern function pipeline_dep_ctx_ensure_source_buffers(ctx: *PipelineDepCtx): i32;
extern function pipeline_dep_ctx_free_source_buffers(ctx: *PipelineDepCtx): void;
extern function pipeline_dep_ctx_loaded_buf_ptr(ctx: *PipelineDepCtx): *u8;
extern function pipeline_dep_ctx_preprocess_buf_ptr(ctx: *PipelineDepCtx): *u8;
extern function pipeline_dep_ctx_set_loaded_len(ctx: *PipelineDepCtx, n: isize): void;

/**
* 与 main.x 中 DriverXEmitState 布局一致（字段顺序/类型勿改）。
* main 负责 argv 解析填本 struct；本模块负责 emit 执行。
*/
struct DriverXEmitState {
  path_buf: u8[512];
  path_len: i32;
  emit_extern_imports: i32;
  use_asm_backend: i32;
  target_arch: i32;
  out_path_buf: u8[512];
  out_path_len: i32;
}

/** sidecar 键：DriverXEmitState 指针转 *u8，供 C lib_root 池 API 使用。 */
function emit_state_key(state: *DriverXEmitState): *u8 {
  return state as *u8;
}

/** 将 emit lib_root 池灌入 PipelineDepCtx（-backend c 烟测路径）。 */
function emit_copy_lib_roots_to_ctx(state: *DriverXEmitState, ctx: *PipelineDepCtx): void {
  let k: i32 = 0;
  let n: i32 = ew_lib_root_count(emit_state_key(state));
  let tmp: u8[256] = [];
  while (k < n) {
    let llen: i32 = ew_lib_root_len(emit_state_key(state), k);
    if (llen > 0) {
      ew_lib_root_copy(emit_state_key(state), k, &tmp[0], 256);
      ew_append_lib_root(ctx, &tmp[0], llen);
    }
    k = k + 1;
  }
}

/**
* -x -E emit 路径用 PipelineDepCtx 零基线（8 字段字面量 + 显式填 backend/index
* 等）。
*/
function pipeline_dep_ctx_for_emit(use_asm: i32, target: i32): PipelineDepCtx {
  let ctx: PipelineDepCtx = PipelineDepCtx {
    ndep: 0,
    entry_dir_buf: [],
    entry_dir_len: 0,
    num_lib_roots: 0
  };
  ctx.use_asm_backend = use_asm;
  ctx.target_arch = target;
  ctx.current_func_index = -1;
  ctx.current_func_single_empty_param_index = -1;
  return ctx;
}

extern function driver_emit_lib_root_count(state: *u8): i32;
extern function driver_emit_lib_root_len(state: *u8, i: i32): i32;
extern function driver_emit_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void;
extern function driver_fs_open_read_path(path: *u8, path_len: i32): i32;
extern function driver_fs_open_write(path: *u8, path_len: i32): i32;
extern function driver_arena_buf(): *u8;
extern function driver_module_buf(): *u8;
extern function driver_pipeline_fail_code(rc: i32, path: *u8): void;
extern function driver_print_x_smoke_summary(module: *u8, codegen_len: usize): void;
extern function pipeline_run_x_pipeline_impl(module_buf: *u8, arena_buf: *u8, source: *u8,
source_len: usize, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32;
extern function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32;
extern function driver_run_x_emit_c_set_lib(i: i32, buf: *u8, len: i32): i32;
extern function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32;
extern function driver_run_x_emit_c_set_emit_extern(v: i32): i32;
extern function driver_run_x_emit_c(): i32;
/** pipeline_glue：向 PipelineDepCtx 追加 -L 库根。 */
extern function ast_pipeline_ctx_append_lib_root(ctx: *PipelineDepCtx, path: *u8, len: i32): i32;

/**
* -E unsafe wrappers：typeck 要求 extern 调用须在 unsafe 块内。
* helper 内 unsafe 块仅含单条 extern 调用 + return，无 let+if 组合，
* 避免 shux -E 丢弃函数体。
*/
function ew_std_sys_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  unsafe { return std_sys_read_file_into(path, buf, cap); }
  return 0;
}
function ew_fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return fs_posix_write_c(fd, buf, count); }
  return 0 as isize;
}
function ew_fs_posix_close_c(fd: i32): i32 {
  unsafe { return fs_posix_close_c(fd); }
  return 0;
}
function ew_preprocess_x_buf(source_buf: *u8, source_len: isize, out_buf: *u8, out_cap: i32): i32 {
  unsafe { return preprocess_x_buf(source_buf, source_len, out_buf, out_cap); }
  return 0;
}
function ew_ensure_source_buffers(ctx: *PipelineDepCtx): i32 {
  unsafe { return pipeline_dep_ctx_ensure_source_buffers(ctx); }
  return 0;
}
function ew_free_source_buffers(ctx: *PipelineDepCtx): void {
  unsafe { pipeline_dep_ctx_free_source_buffers(ctx); }
}
function ew_loaded_buf_ptr(ctx: *PipelineDepCtx): *u8 {
  unsafe { return pipeline_dep_ctx_loaded_buf_ptr(ctx); }
  return 0 as *u8;
}
function ew_preprocess_buf_ptr(ctx: *PipelineDepCtx): *u8 {
  unsafe { return pipeline_dep_ctx_preprocess_buf_ptr(ctx); }
  return 0 as *u8;
}
function ew_set_loaded_len(ctx: *PipelineDepCtx, n: isize): void {
  unsafe { pipeline_dep_ctx_set_loaded_len(ctx, n); }
}
function ew_lib_root_count(state: *u8): i32 {
  unsafe { return driver_emit_lib_root_count(state); }
  return 0;
}
function ew_lib_root_len(state: *u8, i: i32): i32 {
  unsafe { return driver_emit_lib_root_len(state, i); }
  return 0;
}
function ew_lib_root_copy(state: *u8, i: i32, dst: *u8, cap: i32): void {
  unsafe { driver_emit_lib_root_copy(state, i, dst, cap); }
}
function ew_fs_open_write(path: *u8, path_len: i32): i32 {
  unsafe { return driver_fs_open_write(path, path_len); }
  return 0;
}
function ew_arena_buf(): *u8 {
  unsafe { return driver_arena_buf(); }
  return 0 as *u8;
}
function ew_module_buf(): *u8 {
  unsafe { return driver_module_buf(); }
  return 0 as *u8;
}
function ew_pipeline_fail_code(rc: i32, path: *u8): void {
  unsafe { driver_pipeline_fail_code(rc, path); }
}
function ew_print_x_smoke_summary(module: *u8, codegen_len: usize): void {
  unsafe { driver_print_x_smoke_summary(module, codegen_len); }
}
function ew_run_x_pipeline_impl(module_buf: *u8, arena_buf: *u8, source: *u8,
source_len: usize, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  unsafe { return pipeline_run_x_pipeline_impl(module_buf, arena_buf, source, source_len, out, ctx); }
  return 0;
}
function ew_set_path(path: *u8, path_len: i32): i32 {
  unsafe { return driver_run_x_emit_c_set_path(path, path_len); }
  return 0;
}
function ew_set_lib(i: i32, buf: *u8, len: i32): i32 {
  unsafe { return driver_run_x_emit_c_set_lib(i, buf, len); }
  return 0;
}
function ew_set_n_lib_roots(n: i32): i32 {
  unsafe { return driver_run_x_emit_c_set_n_lib_roots(n); }
  return 0;
}
function ew_set_emit_extern(v: i32): i32 {
  unsafe { return driver_run_x_emit_c_set_emit_extern(v); }
  return 0;
}
function ew_run_x_emit_c(): i32 {
  unsafe { return driver_run_x_emit_c(); }
  return 0;
}
function ew_append_lib_root(ctx: *PipelineDepCtx, path: *u8, len: i32): i32 {
  unsafe { return ast_pipeline_ctx_append_lib_root(ctx, path, len); }
  return 0;
}

/**
* 在 .x 内执行单文件 emit：读 state.path_buf、预处理、pipeline、写 stdout 或 -o
* 路径。
* 仅无 import 单文件时正确（deps 为 0）；多文件须走 dispatch_x_emit_to_c。
*/
function run_x_emit_x(state: *DriverXEmitState): i32 {
  if (state.path_len >= 0 && state.path_len < 511) {
    state.path_buf[state.path_len] = 0 as u8;
  }
  let ctx: PipelineDepCtx = pipeline_dep_ctx_for_emit(state.use_asm_backend, state.target_arch);
  if (ew_ensure_source_buffers(&ctx) != 0) {
    return 1;
  }
  let cap_i: i32 = 4194304;
  let n: i32 = ew_std_sys_read_file_into(&state.path_buf[0], ew_loaded_buf_ptr(&ctx), cap_i);
  if (n < 0) {
    ew_free_source_buffers(&ctx);
    return 1;
  }
  ew_set_loaded_len(&ctx, n as isize);
  let out_len: i32 = ew_preprocess_x_buf(ew_loaded_buf_ptr(&ctx), n,
  ew_preprocess_buf_ptr(&ctx), 4194304);
  if (out_len < 0) {
    ew_free_source_buffers(&ctx);
    return 1;
  }
  ctx.preprocess_len = out_len;
  let arena_buf: *u8 = ew_arena_buf();
  let module_buf: *u8 = ew_module_buf();
  let last_slash: i32 = -1;
  let k: i32 = 0;
  while (k < state.path_len && k < 512) {
    if (state.path_buf[k] == 47) {
      last_slash = k;
    }
    k = k + 1;
  }
  if (last_slash >= 0) {
    k = 0;
    while (k < last_slash && k < 511) {
      ctx.entry_dir_buf[k] = state.path_buf[k];
      k = k + 1;
    }
    ctx.entry_dir_buf[k] = 0;
    ctx.entry_dir_len = k;
  } else {
    ctx.entry_dir_buf[0] = 46;
    ctx.entry_dir_buf[1] = 0;
    ctx.entry_dir_len = 1;
  }
  ctx.num_lib_roots = 0;
  emit_copy_lib_roots_to_ctx(state, &ctx);
  let out: CodegenOutBuf = CodegenOutBuf { data: [], len: 0 };
  let source_len: usize = out_len as usize;
  let rc: i32 = ew_run_x_pipeline_impl(module_buf, arena_buf,
  ew_preprocess_buf_ptr(&ctx), source_len, &out, &ctx);
  if (rc != 0) {
    ew_pipeline_fail_code(rc, &ctx.path_buf[0]);
    ew_free_source_buffers(&ctx);
    return 1;
  }
  let len: i32 = out.len;
  if (state.out_path_len == 0) {
    ew_print_x_smoke_summary(module_buf, len as usize);
  }
  if (state.out_path_len > 0) {
    let wfd: i32 = ew_fs_open_write(state.out_path_buf, state.out_path_len);
    if (wfd < 0) {
      ew_free_source_buffers(&ctx);
      return 1;
    }
    if (len > 262144) {
      let written: isize = ew_fs_posix_write_c(wfd, &out.data[0], 262144);
      ew_fs_posix_close_c(wfd);
      if (written < 0 || (written as i32) != 262144) {
        ew_free_source_buffers(&ctx);
        return 1;
      }
    } else {
      let written: isize = ew_fs_posix_write_c(wfd, &out.data[0], len as usize);
      ew_fs_posix_close_c(wfd);
      if (written < 0 || (written as i32) != len) {
        ew_free_source_buffers(&ctx);
        return 1;
      }
    }
  } else {
    if (len > 262144) {
      let written: isize = ew_fs_posix_write_c(1, &out.data[0], 262144);
      if (written < 0 || (written as i32) != 262144) {
        ew_free_source_buffers(&ctx);
        return 1;
      }
    } else {
      let written: isize = ew_fs_posix_write_c(1, &out.data[0], len as usize);
      if (written < 0 || (written as i32) != len) {
        ew_free_source_buffers(&ctx);
        return 1;
      }
    }
  }
  ew_free_source_buffers(&ctx);
  return 0;
}

/**
* -x -E 多文件：将 path 与 -L 库根灌入 C 侧，再调 driver_run_x_emit_c（deps+main
* 完整路径）。
*/
function dispatch_x_emit_to_c(state: *DriverXEmitState): i32 {
  ew_set_emit_extern(state.emit_extern_imports);
  ew_set_path(state.path_buf, state.path_len);
  let k: i32 = 0;
  let n_roots: i32 = ew_lib_root_count(emit_state_key(state));
  let lib_tmp: u8[256] = [];
  while (k < n_roots) {
    let llen: i32 = ew_lib_root_len(emit_state_key(state), k);
    ew_lib_root_copy(emit_state_key(state), k, &lib_tmp[0], 256);
    ew_set_lib(k, &lib_tmp[0], llen);
    k = k + 1;
  }
  ew_set_n_lib_roots(n_roots);
  return ew_run_x_emit_c();
}
