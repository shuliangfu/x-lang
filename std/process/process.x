// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// std/process/process.x — argc/argv 薄封装（F-process v1；替代 process.c 中 args 段）
//
// 【文件职责】process_args_count_c / process_arg_c；全局 shux_process_argc/argv 在 compiler/runtime_process_argv.o。
// OS syscall（getenv/spawn 等）见 compiler/src/asm/runtime_process_os_glue.c。

/** 胶层：读取 codegen 写入的 argc。 */
extern function process_shux_argc_get(): i32;

/** 胶层：读取 argv[i]；越界返回 0。 */
extern function process_shux_argv_get(i: i32): *u8;

/** 热路径：返回命令行参数个数（含 argv[0]）。 */
export function process_args_count_c(): i32 { let _rc: i32 = 0; unsafe { _rc = process_shux_argc_get(); } return _rc; }

/** 热路径：返回第 i 个参数 C 字符串；越界或未初始化返回 0。 */
export function process_arg_c(i: i32): *u8 { let _rc: *u8 = 0; unsafe { _rc = process_shux_argv_get(i); } return _rc; }
