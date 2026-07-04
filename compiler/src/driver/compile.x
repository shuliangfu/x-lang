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

// compile.x — 完整编译入口 argv 解析与后端分派（从 runtime.c
// driver_run_compiler_full 迁入）
//
// C 侧保留 read_file、invoke_cc、driver_run_asm_backend 等原语；本模块负责
// -o/-L/-backend/-target/-O/-freestanding 解析。

const ast = import("ast");

/** 与 main.x DriverXEmitState 字段布局兼容的编译参数块（sidecar 键为
&state）。 */
struct DriverCompileState {
  path_buf: u8[512];
  path_len: i32;
  out_path_buf: u8[512];
  out_path_len: i32;
  use_asm_backend: i32;
  target_arch: i32;
  /** `-target` 原始字符串（供 asm/ld 使用）。 */
  target_buf: u8[512];
  target_len: i32;
  opt_level_buf: u8[8];
  opt_level_len: i32;
  use_lto: i32;
  /** argv 显式 `-backend asm` 时为 1；勿因顶层 import 降级到 shux-c（其不支持 -backend）。 */
  backend_asm_explicit: i32;
  /** `-freestanding`：Linux x86_64 nostdlib 静态链（crt0_user + runtime_panic + freestanding_io）。 */
  use_freestanding: i32;
  /** parse_argv 内部：是否见过 `-target` 开关（finalize 调 driver_resolve_target_arch）。 */
  parse_saw_target: i32;
  /** `-target-cpu` 原始字符串（native/generic/avx2 等）。 */
  target_cpu_buf: u8[64];
  target_cpu_len: i32;
  /** finalize 后：解析得到的 feature 位掩码（默认 native=宿主机探测）。 */
  target_cpu_features: i32;
  /** `--print-target-cpu` / `-print-target-cpu`：仅打印 feature 后退出。 */
  print_target_cpu: i32;
  /** parse_argv 内部：是否见过 `-target-cpu` 开关。 */
  parse_saw_target_cpu: i32;
}

extern function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32;
/** argv 路径写入 state.path_buf/path_len；EMIT_HEAVY 勿 X while+INDEX 真 emit。 */
extern function driver_compile_argv_copy_path_c(state: *DriverCompileState, arg_buf: *u8, plen: i32): void;
/** 无 -L 时追加默认 lib_root "."；EMIT_HEAVY 下 ensure_default_lib X 体易 ret0 桩。 */
extern function driver_compile_ensure_default_lib_c(key: *u8): void;
/** 重置 DriverCompileState + lib_root sidecar；EMIT_HEAVY 下 *T 形参 field store 易误 emit。 */
extern function driver_compile_parse_argv_init_c(state: *DriverCompileState): void;
/** 向 sidecar 追加 lib_root；EMIT_HEAVY 下 state_key/append 序列与 inject -L 联调须稳定。 */
extern function driver_compile_append_lib_root_c(state: *DriverCompileState, path: *u8, len: i32): void;
/** parse_argv step side-effect C glue（*state field store / get_argv 入 embedded buf 勿 X emit）。 */
extern function driver_compile_argv_apply_minus_o_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32): void;
extern function driver_compile_argv_apply_minus_L_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void;
extern function driver_compile_argv_apply_minus_O_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32): void;
extern function driver_compile_argv_set_use_lto_c(state: *DriverCompileState): void;
/** `-freestanding` 开关：链入 nostdlib crt0/syscall 桩（S4；与 SHUX_FREESTANDING=1 等价）。 */
extern function driver_compile_argv_set_use_freestanding_c(state: *DriverCompileState): void;
/** `-legacy-f32-abi`：等价 SHUX_ABI_F32_XMM=0（legacy f64 widen + cvtsd2ss）。 */
extern function driver_compile_argv_set_legacy_f32_abi_c(): void;
/** `-fsanitize=address`：M-6 debug 边界插桩（release 默认关）。 */
extern function driver_compile_argv_set_sanitize_address_c(): void;
extern function driver_compile_argv_apply_backend_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32, arg_buf: *u8, arg_cap: i32): void;
extern function driver_compile_argv_apply_target_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32): void;
/** `-target-cpu`：下一 argv 写入 target_cpu_buf/target_len/parse_saw_target_cpu。 */
extern function driver_compile_argv_apply_target_cpu_next_c(state: *DriverCompileState, argc: i32, argv: *u8, i: i32): void;
/** `--print-target-cpu`：置 print_target_cpu=1。 */
extern function driver_compile_argv_set_print_target_cpu_c(state: *DriverCompileState): void;
/** `--print-target-cpu` 早退：打印 target_cpu_features 后返回 0（与 impl_c 对齐）。 */
extern function driver_print_target_cpu_features_c(features: i32): i32;
/** finalize：按 target_cpu_buf（空则 native）解析并写 target_cpu_features。 */
extern function driver_compile_resolve_target_cpu_c(state: *DriverCompileState): void;
/** 完整 argv 解析 C mega（standalone 回退）；主链 compile.x init→loop→finalize X emit。 */
extern function driver_compile_parse_argv_impl_c(argc: i32, argv: *u8, state: *DriverCompileState): i32;

/** argv[1..] 扫描（C step_c 循环）；impl_c / 非 asm 链回退。 */
extern function driver_compile_parse_argv_scan_c(argc: i32, argv: *u8, state: *DriverCompileState): void;

/** B-02：按 -target triple 同步 #[cfg] 求值上下文（C 实现）。 */
extern function cfg_sync_compile_target_from_state_c(state: *DriverCompileState): void;
extern function driver_emit_lib_root_reset(key: *u8): void;
extern function driver_emit_append_lib_root(key: *u8, path: *u8, len: i32): i32;
extern function driver_emit_lib_root_count(key: *u8): i32;
extern function driver_resolve_target_arch(parsed: i32, saw_target: i32): i32;
extern function driver_source_has_generic_syntax(path: *u8, path_len: i32): i32;
/** C：源码含 += 等复合赋值时返回 1（.x parse 未覆盖，须走 C 后端）。 */
extern function driver_source_has_compound_assign_syntax(path: *u8, path_len: i32): i32;
/** C：源码含顶层 import 时返回 1（seed asm 入口 parse 易 0 func，须走 C
* 后端）。 */
extern function driver_source_has_top_level_import_path(path: *u8, path_len: i32): i32;
extern function driver_asm_output_want_exe(out_path: *u8): i32;
extern function driver_check_only_get(): i32;
extern function driver_bump_stack_limit(): void;
/** C：build_shux_asm 设 SHUX_ASM_ENTRY_MODULE_ONLY=1 时非 0；单模块 -o 仍走 asm 后端。 */
extern function driver_asm_entry_module_only_from_env(): i32;

/** 扫描 argv 是否含 `-h` / `--help`；1 表示应打印用法并 exit 0。 */
extern function driver_compile_argv_is_help_c(argc: i32, argv: *u8): i32;
/** 打印 shux 用法摘要（stdout）。 */
extern function driver_print_usage_c(): void;

/** C mega：完整编译入口（C 栈 state + X parse_argv）；EMIT_HEAVY 改堆分配 + X post_parse。 */
extern function driver_run_compiler_full_x_impl_c(argc: i32, argv: *u8): i32;

/** C：parse 完成后后端分派（非 asm 链回退）；X post_parse 真 emit 后本符号仅 weak/standalone。 */
extern function driver_run_compiler_full_x_post_parse_impl_c(state: *DriverCompileState, argc: i32, argv: *u8): i32;

/** 堆上分配 DriverCompileState（默认字段同 impl_c）；EMIT_HEAVY 勿 X 局部大 struct。 */
extern function driver_compile_state_alloc_c(): *DriverCompileState;

/** 释放 driver_compile_state_alloc_c 所得块。 */
extern function driver_compile_state_free_c(state: *DriverCompileState): void;

/** C mega：asm 后端（读文件、dep、pipeline、.o/ld）；compile.x 经 dispatch 调 impl_c。 */
extern function driver_run_asm_backend_impl_c(
input_path: *u8,
out_path: *u8,
lib_key: *u8,
target: *u8,
argc: i32,
argv: *u8
): i32;

/** C mega：C 后端（预处理、pipeline 出 C、cc 链接）；compile.x 经 dispatch 调 impl_c。 */
extern function driver_run_emit_c_path_impl_c(
input_path: *u8,
out_path: *u8,
lib_key: *u8,
target: *u8,
opt_level: *u8,
use_lto: i32,
argc: i32,
argv: *u8
): i32;

/**
 * asm 后端薄编排：空参校验 X；mega 委托 driver_run_asm_backend_impl_c（lib_key→lib_roots 在 C）。
 */
function compile_dispatch_asm_backend(
input_path: *u8,
out_path: *u8,
lib_key: *u8,
target: *u8,
argc: i32,
argv: *u8
): i32 {
  if (input_path == 0 as *u8) {
    return 1;
  }
  return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
}

/**
 * C 后端薄编排：空参校验 X；mega 委托 driver_run_emit_c_path_impl_c（含 shux-c  sibling / parsed 路径）。
 */
function compile_dispatch_emit_c_path(
input_path: *u8,
out_path: *u8,
lib_key: *u8,
target: *u8,
opt_level: *u8,
use_lto: i32,
argc: i32,
argv: *u8
): i32 {
  if (input_path == 0 as *u8) {
    return 1;
  }
  return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
}

/** sidecar 键：state 指针。 */
function driver_compile_state_key(state: *DriverCompileState): *u8 {
  return state as *u8;
}

/** 无 -L 时默认库根 "."（与 runtime driver_run_compiler_full 一致）；委托 C 原语。 */
function driver_compile_ensure_default_lib(key: *u8): void {
  driver_compile_ensure_default_lib_c(key);
}

function eq_minus_o(buf: *u8, len: i32): i32 {
  if (len == 2 && buf[0] == 45 && buf[1] == 111) {
    return 1;
  }
  return 0;
}

function eq_minus_L(buf: *u8, len: i32): i32 {
  if (len == 2 && buf[0] == 45 && buf[1] == 76) {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "-backend"（8 字节）；须 len==8，勿写成 9（与 main.x 一致）。 */
function eq_minus_backend(buf: *u8, len: i32): i32 {
  if (len == 8 && buf[0] == 45 && buf[1] == 98 && buf[2] == 97 && buf[3] == 99 && buf[4] == 107 &&
  buf[5] == 101 && buf[6] == 110 && buf[7] == 100) {
    return 1;
  }
  return 0;
}

function eq_minus_target(buf: *u8, len: i32): i32 {
  if (len < 7) {
    return 0;
  }
  if (buf[0] == 45 && buf[1] == 116 && buf[2] == 97 && buf[3] == 114 && buf[4] == 103 && buf[5] ==
  101 && buf[6] == 116) {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "-target-cpu"（11 字节）。 */
function eq_minus_target_cpu(buf: *u8, len: i32): i32 {
  if (len == 11 && buf[0] == 45 && buf[1] == 116 && buf[2] == 97 && buf[3] == 114 && buf[4] == 103 &&
  buf[5] == 101 && buf[6] == 116 && buf[7] == 45 && buf[8] == 99 && buf[9] == 112 && buf[10] == 117) {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "--print-target-cpu"（18 字节）或 "-print-target-cpu"（17 字节）。 */
function eq_print_target_cpu(buf: *u8, len: i32): i32 {
  if (len == 18 && buf[0] == 45 && buf[1] == 45 && buf[2] == 112 && buf[3] == 114 && buf[4] == 105 &&
  buf[5] == 110 && buf[6] == 116 && buf[7] == 45 && buf[8] == 116 && buf[9] == 97 && buf[10] == 114 &&
  buf[11] == 103 && buf[12] == 101 && buf[13] == 116 && buf[14] == 45 && buf[15] == 99 && buf[16] == 112 &&
  buf[17] == 117) {
    return 1;
  }
  if (len == 17 && buf[0] == 45 && buf[1] == 112 && buf[2] == 114 && buf[3] == 105 && buf[4] == 110 &&
  buf[5] == 116 && buf[6] == 45 && buf[7] == 116 && buf[8] == 97 && buf[9] == 114 && buf[10] == 103 &&
  buf[11] == 101 && buf[12] == 116 && buf[13] == 45 && buf[14] == 99 && buf[15] == 112 && buf[16] == 117) {
    return 1;
  }
  return 0;
}

function eq_minus_O(buf: *u8, len: i32): i32 {
  if (len == 2 && buf[0] == 45 && buf[1] == 79) {
    return 1;
  }
  return 0;
}

function eq_flto(buf: *u8, len: i32): i32 {
  if (len == 5 && buf[0] == 45 && buf[1] == 102 && buf[2] == 108 && buf[3] == 116 && buf[4] == 111)
  {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "-freestanding"（13 字节）。 */
function eq_minus_freestanding(buf: *u8, len: i32): i32 {
  if (len == 13 && buf[0] == 45 && buf[1] == 102 && buf[2] == 114 && buf[3] == 101 && buf[4] == 101 &&
  buf[5] == 115 && buf[6] == 116 && buf[7] == 97 && buf[8] == 110 && buf[9] == 100 && buf[10] == 105 &&
  buf[11] == 110 && buf[12] == 103) {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "-legacy-f32-abi"（15 字节）；x86 SysV legacy f32 CALL widen。 */
function eq_legacy_f32_abi(buf: *u8, len: i32): i32 {
  if (len == 15 && buf[0] == 45 && buf[1] == 108 && buf[2] == 101 && buf[3] == 103 && buf[4] == 97 &&
  buf[5] == 99 && buf[6] == 121 && buf[7] == 45 && buf[8] == 102 && buf[9] == 51 && buf[10] == 50 &&
  buf[11] == 45 && buf[12] == 97 && buf[13] == 98 && buf[14] == 105) {
    return 1;
  }
  return 0;
}

/** 比较 buf 与 "-fsanitize=address"（18 字节）；M-6 debug 边界插桩。 */
function eq_fsanitize_address(buf: *u8, len: i32): i32 {
  if (len == 18 && buf[0] == 45 && buf[1] == 102 && buf[2] == 115 && buf[3] == 97 && buf[4] == 110 &&
  buf[5] == 105 && buf[6] == 116 && buf[7] == 105 && buf[8] == 122 && buf[9] == 101 && buf[10] == 61 &&
  buf[11] == 97 && buf[12] == 100 && buf[13] == 100 && buf[14] == 114 && buf[15] == 101 && buf[16] == 115 &&
  buf[17] == 115) {
    return 1;
  }
  return 0;
}

function eq_asm_word(buf: *u8, len: i32): i32 {
  if (len == 3 && buf[0] == 97 && buf[1] == 115 && buf[2] == 109) {
    return 1;
  }
  return 0;
}

function eq_c_word(buf: *u8, len: i32): i32 {
  if (len == 1 && buf[0] == 99) {
    return 1;
  }
  return 0;
}

/** 是否为 Shux 源文件路径（`.x`；仅 `.x`）。 */
function path_ends_x(buf: *u8, len: i32): i32 {
  if (len >= 3 && buf[len - 3] == 46 && buf[len - 2] == 115) {
    let ext: u8 = buf[len - 1];
    if (ext == 117 || ext == 120) {
      return 1;
    }
  }
  return 0;
}

function target_has_arm(buf: *u8, len: i32): i32 {
  let start: i32 = 0;
  while (start + 5 <= len) {
    if (buf[start] == 97 && buf[start + 1] == 114 && buf[start + 2] == 109 && buf[start + 3] == 54
    &&
    buf[start + 4] == 52) {
      return 1;
    }
    start = start + 1;
  }
  return 0;
}

/**
 * 重置 DriverCompileState 与 lib_root sidecar；委托 C（*T 形参 field 写入勿 X emit）。
 */
function driver_compile_parse_argv_init(state: *DriverCompileState): void {
  driver_compile_parse_argv_init_c(state);
}

/**
 * 处理 argv[i] 一项；side-effect 分支经 C glue（EMIT_HEAVY 勿 X 写 state embedded buf）。
 * 返回下一 argv 下标；len<0 时跳过当前项。
 */
function driver_compile_parse_argv_step(
  argc: i32,
  argv: *u8,
  state: *DriverCompileState,
  i: i32,
  arg_buf: *u8,
  arg_cap: i32
): i32 {
  let len: i32 = driver_get_argv_i(argc, argv, i, arg_buf, arg_cap);
  if (len < 0) {
    return i + 1;
  }
  if (eq_minus_o(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_minus_o_next_c(state, argc, argv, i);
    return i + 2;
  }
  if (eq_minus_L(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_minus_L_next_c(state, argc, argv, i, arg_buf, arg_cap);
    return i + 2;
  }
  if (eq_minus_O(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_minus_O_next_c(state, argc, argv, i);
    return i + 2;
  }
  if (eq_flto(arg_buf, len) != 0) {
    driver_compile_argv_set_use_lto_c(state);
    return i + 1;
  }
  if (eq_minus_freestanding(arg_buf, len) != 0) {
    driver_compile_argv_set_use_freestanding_c(state);
    return i + 1;
  }
  if (eq_legacy_f32_abi(arg_buf, len) != 0) {
    driver_compile_argv_set_legacy_f32_abi_c();
    return i + 1;
  }
  if (eq_fsanitize_address(arg_buf, len) != 0) {
    driver_compile_argv_set_sanitize_address_c();
    return i + 1;
  }
  if (eq_minus_backend(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_backend_next_c(state, argc, argv, i, arg_buf, arg_cap);
    return i + 2;
  }
  if (eq_minus_target(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_target_next_c(state, argc, argv, i);
    return i + 2;
  }
  if (eq_minus_target_cpu(arg_buf, len) != 0 && i + 1 < argc) {
    driver_compile_argv_apply_target_cpu_next_c(state, argc, argv, i);
    return i + 2;
  }
  if (eq_print_target_cpu(arg_buf, len) != 0) {
    driver_compile_argv_set_print_target_cpu_c(state);
    return i + 1;
  }
  if (arg_buf[0] != 45 && path_ends_x(arg_buf, len) != 0) {
    driver_compile_argv_copy_path_c(state, arg_buf, len);
    return i + 1;
  }
  return i + 1;
}

/**
 * argv[1..] 扫描循环；局部仅 arg_buf[512]（勿双 512 数组，EMIT_HEAVY 栈深）。
 */
function driver_compile_parse_argv_loop(argc: i32, argv: *u8, state: *DriverCompileState): i32 {
  let arg_buf: u8[512] = [];
  let i: i32 = 1;
  while (i < argc) {
    i = driver_compile_parse_argv_step(argc, argv, state, i, &arg_buf[0], 512);
  }
  return 0;
}

/** path_len 校验、target_arch 解析、默认 lib_root。 */
function driver_compile_parse_argv_finalize(state: *DriverCompileState): i32 {
  driver_compile_resolve_target_cpu_c(state);
  if (state.print_target_cpu != 0) {
    return 0;
  }
  if (state.path_len <= 0) {
    return 1;
  }
  state.target_arch = driver_resolve_target_arch(state.target_arch, state.parse_saw_target);
  /** B-02：#[cfg] 与 -target triple 联动（cross 编译剪枝）。 */
  cfg_sync_compile_target_from_state_c(state);
  /** finalize 直调 C：ensure_default_lib X 体在 EMIT_HEAVY 第二遍仍可能 ret0 桩。 */
  driver_compile_ensure_default_lib_c(driver_compile_state_key(state));
  return 0;
}

/**
 * 解析完整编译 argv；返回 0 成功，1 无输入 .x。
 * EMIT_HEAVY：init → loop(step+glue) → finalize 全 X 真 emit。
 */
function driver_compile_parse_argv(argc: i32, argv: *u8, state: *DriverCompileState): i32 {
  let one: i32 = 1;
  if (argc < 2) {
    return one;
  }
  driver_compile_parse_argv_init(state);
  driver_compile_parse_argv_loop(argc, argv, state);
  return driver_compile_parse_argv_finalize(state);
}

/**
 * parse 完成后：check-only / 泛型检测 / import 降级 / asm 与 C 后端分派（X 真 emit）。
 */
function run_compiler_full_x_post_parse(state: *DriverCompileState, argc: i32, argv: *u8): i32 {
  let one: i32 = 1;
  let zero: i32 = 0;
  if (state == 0 as *DriverCompileState) {
    return one;
  }
  if (driver_check_only_get() != 0) {
    /** shux-c check 走 C typeck；B-strict shux_asm 由 post_parse_impl_c 保留 asm backend。 */
    state.use_asm_backend = zero;
  }
  let want_generic_check: i32 = zero;
  if (state.out_path_len == zero) {
    want_generic_check = one;
  } else if (driver_asm_output_want_exe(&state.out_path_buf[0]) != 0) {
    want_generic_check = one;
  }
  if (state.use_asm_backend != 0 && want_generic_check != 0) {
    if (driver_source_has_generic_syntax(&state.path_buf[0], state.path_len) != 0) {
      state.use_asm_backend = zero;
    }
    /** 复合赋值（+= 等）已由 lexer.x/parser.x 支持；勿再降级 C 后端。 */
  }
  if (state.use_asm_backend != 0 && state.out_path_len > 0 &&
      driver_asm_output_want_exe(&state.out_path_buf[0]) != 0) {
    /** 同上：exe 输出路径亦保留 asm。 */
  }
  let out_ptr: *u8 = 0 as *u8;
  if (state.out_path_len > 0) {
    out_ptr = &state.out_path_buf[0];
  }
  let target_ptr: *u8 = 0 as *u8;
  if (state.target_len > 0) {
    target_ptr = &state.target_buf[0];
  }
  /** 无 import 的单文件 -o 默认 asm；有 import 允许降级 C（与 post_parse_impl_c 一致）。 */
  if (state.out_path_len > 0 && state.backend_asm_explicit == 0 &&
      driver_source_has_top_level_import_path(&state.path_buf[0], state.path_len) == 0) {
    state.backend_asm_explicit = one;
  }
  if (state.use_asm_backend != 0 && state.backend_asm_explicit == 0 &&
      driver_asm_entry_module_only_from_env() == 0 &&
      driver_source_has_top_level_import_path(&state.path_buf[0], state.path_len) != 0) {
    state.use_asm_backend = zero;
  }
  /** `-freestanding` 须走 asm + nostdlib 链；禁止被 import/泛型等逻辑降级到 C 后端。 */
  if (state.use_freestanding != 0) {
    state.use_asm_backend = one;
    state.backend_asm_explicit = one;
    driver_compile_argv_set_use_freestanding_c(state);
  }
  let lib_key: *u8 = driver_compile_state_key(state);
  if (state.use_asm_backend != 0) {
    return compile_dispatch_asm_backend(&state.path_buf[0], out_ptr, lib_key, target_ptr, argc, argv);
  }
  return compile_dispatch_emit_c_path(
    &state.path_buf[0],
    out_ptr,
    lib_key,
    target_ptr,
    &state.opt_level_buf[0],
    state.use_lto,
    argc,
    argv
  );
}

/**
 * 完整编译入口（.x）：堆上 state + parse_argv + post_parse（EMIT_HEAVY X 真 emit）。
 */
function run_compiler_full_x(argc: i32, argv: *u8): i32 {
  let one: i32 = 1;
  let zero: i32 = 0;
  if (driver_compile_argv_is_help_c(argc, argv) != 0) {
    driver_print_usage_c();
    return zero;
  }
  driver_bump_stack_limit();
  let state: *DriverCompileState = driver_compile_state_alloc_c();
  if (state == 0 as *DriverCompileState) {
    return one;
  }
  if (driver_compile_parse_argv(argc, argv, state) != 0) {
    driver_compile_state_free_c(state);
    return one;
  }
  /** `--print-target-cpu`：勿进入 post_parse（无输入 .x 路径）。 */
  if (state.print_target_cpu != 0) {
    let rcpu: i32 = driver_print_target_cpu_features_c(state.target_cpu_features);
    driver_compile_state_free_c(state);
    return rcpu;
  }
  let r: i32 = run_compiler_full_x_post_parse(state, argc, argv);
  driver_compile_state_free_c(state);
  return r;
}
