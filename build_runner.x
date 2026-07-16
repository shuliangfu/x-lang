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

// build_runner.x — build_tool 的入口与编排（G-05：无 build_runtime.c）
//
// 与 build.x + build_runtime_x.x 配合：build.x 提供 build_get_step_* / build_use_asm_only；
// build_runtime_x.x 提供 build_run_step / build_run_asm_build；
// 本文件提供 entry(argc, argv)。Linux 链 crt0_x86_64.o；Darwin 经 build_tool_main.c 薄 main。
// 链接：crt0 + build_runner.o + build_tool.o + build_runtime_x.o + -lc（无 build_runtime.c）。

/** 从 argv 取第 i 个参数到 buf，NUL 结尾；crt0 或 build_tool_main 提供。 */
extern function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32;
/** 执行单步 legacy；由 build_runtime_x.x 提供。 */
extern function build_run_step(step_id: i32, shu_path: *u8): i32;
/** asm 路径；由 build_runtime_x.x 提供。 */
extern function build_run_asm_build(shu_path: *u8): i32;
/** 步骤数量与顺序；由 build.x 生成 build_gen.c 提供。 */
extern function build_get_step_count(): i32;
extern function build_get_step_at(i: i32): i32;
/** 1=默认先试 asm；由 build.x 生成 build_gen.c 提供。 */
extern function build_use_asm_only(): i32;
/** asm 成功后 cp shux_asm → shux；由 build_runtime_x.x 提供。 */
extern function build_copy_shux_asm(): i32;

/** 执行 build.x 配置的 legacy 逐步。返回 0 成功。 */
function build_run_legacy_steps(shu_path: *u8): i32 {
  let n: i32 = build_get_step_count();
  let i: i32 = 0;
  while (i < n) {
    let step_id: i32 = build_get_step_at(i);
    if (step_id < 0) {
      return 1;
    }
    if (build_run_step(step_id, shu_path) != 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** argv[2] 是否与 "asm" 匹配（长度 3）。 */
function build_argv2_is_asm(arg2: *u8, l2: i32): i32 {
  if (l2 == 3 && arg2[0] == 97 && arg2[1] == 115 && arg2[2] == 109) {
    return 1;
  }
  return 0;
}

/** argv[2] 是否与 "legacy" 匹配（长度 6）。 */
function build_argv2_is_legacy(arg2: *u8, l2: i32): i32 {
  if (l2 == 6 && arg2[0] == 108 && arg2[1] == 101 && arg2[2] == 103
    && arg2[3] == 97 && arg2[4] == 99 && arg2[5] == 121) {
    return 1;
  }
  return 0;
}

/** 入口：crt0 / build_tool_main 调用。与 build_runtime.c main() 语义一致（无 C runtime）。 */
function entry(argc: i32, argv: *u8): i32 {
  let shu_buf: u8[256] = [];
  let len: i32 = driver_get_argv_i(argc, argv, 1, shu_buf, 256);
  if (len < 0) {
    shu_buf[0] = 46;
    shu_buf[1] = 47;
    shu_buf[2] = 115;
    shu_buf[3] = 104;
    shu_buf[4] = 117;
    len = 5;
  }
  if (len < 256) {
    shu_buf[len] = 0;
  }
  let arg2: u8[8] = [];
  let l2: i32 = driver_get_argv_i(argc, argv, 2, arg2, 8);
  if (build_argv2_is_asm(arg2, l2) != 0) {
    if (build_run_asm_build(shu_buf) != 0) {
      return 1;
    }
    return 0;
  }
  if (build_argv2_is_legacy(arg2, l2) != 0) {
    if (build_run_legacy_steps(shu_buf) != 0) {
      return 1;
    }
    return 0;
  }
  if (build_use_asm_only() != 0) {
    if (build_run_asm_build(shu_buf) == 0) {
      if (build_copy_shux_asm() != 0) {
        return 1;
      }
      return 0;
    }
  }
  if (build_run_legacy_steps(shu_buf) != 0) {
    return 1;
  }
  return 0;
}
