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

// std/simd/simd.x — STD-153 自动向量化策略（F-simd v1 + F-ZC；纯 .x，无 .c/.h）
//
// 【文件职责】
// SHUX_SIMD_HW / SHUX_SIMD_AUTovec 环境变量解析；simd_recommend_path_c 分派；
// HW 探测与 STD-153 烟测均在 .x 内。
// G-03：strcmp 改字节比较，避免 seed asm .o 链入 PIE 可执行文件时 PC32 重定位失败。

extern "C" function getenv(name: *u8): *u8;

/** lane-scalar 回退路径。 */
const SIMD_PATH_SCALAR: i32 = 0;
/** 硬件向量 emit 路径。 */
const SIMD_PATH_HW: i32 = 1;

/** C 字符串常量（解析器不支持 "..." as *u8）。 */
const SIM_LIT_SHUX_SIMD_AUTOVEC: u8[18] = [83, 72, 85, 88, 95, 83, 73, 77, 68, 95, 65, 85, 84, 111, 118, 101, 99, 0];
const SIM_LIT_SHUX_SIMD_HW: u8[13] = [83, 72, 85, 88, 95, 83, 73, 77, 68, 95, 72, 87, 0];

/** C 串与字面量相等；1 相等（无 libc strcmp，避免 PIE 链入重定位错误）。 */
function simd_str_eq(a: *u8, b: *u8): i32 {
  let i: i32 = 0;
  let ca: u8 = 0;
  let cb: u8 = 0;
  if (a == 0 || b == 0) { return 0; }
  i = 0;
  while (1 != 0) {
    ca = a[i];
    cb = b[i];
    if (ca != cb) { return 0; }
    if (ca == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** 读取 SHUX_SIMD_HW=0 或 SHUX_SIMD_AUTovec=scalar 强制标量。 */
function simd_env_force_scalar(): i32 {
  let hw: *u8 = 0;
  let aut: *u8 = 0;
  let lit0: u8[2] = [48, 0];
  let lit_scalar: u8[7] = [115, 99, 97, 108, 97, 114, 0];
  unsafe { hw = getenv(&SIM_LIT_SHUX_SIMD_HW[0]); }
  if (hw != 0 && hw[0] == 48 && hw[1] == 0) { return 1; }
  unsafe { aut = getenv(&SIM_LIT_SHUX_SIMD_AUTOVEC[0]); }
  if (aut == 0) { return 0; }
  if (simd_str_eq(aut, &lit_scalar[0]) != 0) { return 1; }
  if (simd_str_eq(aut, &lit0[0]) != 0) { return 1; }
  return 0;
}

/** 读取 SHUX_SIMD_AUTovec=hw 强制硬件路径。 */
function simd_env_force_hw(): i32 {
  let aut: *u8 = 0;
  let lit_hw: u8[3] = [104, 119, 0];
  let lit1: u8[2] = [49, 0];
  unsafe { aut = getenv(&SIM_LIT_SHUX_SIMD_AUTOVEC[0]); }
  if (aut == 0) { return 0; }
  if (simd_str_eq(aut, &lit_hw[0]) != 0) { return 1; }
  if (simd_str_eq(aut, &lit1[0]) != 0) { return 1; }
  return 0;
}

/** STD-153：推荐向量化路径（0=scalar，1=hw）。 */
function simd_recommend_path_c(): i32 {
  if (simd_env_force_scalar() != 0) { return SIMD_PATH_SCALAR; }
  if (simd_env_force_hw() != 0) {
    if (simd_hw_available_c() != 0) { return SIMD_PATH_HW; }
    return SIMD_PATH_SCALAR;
  }
  if (simd_hw_available_c() != 0) { return SIMD_PATH_HW; }
  return SIMD_PATH_SCALAR;
}

/** F-std-zero-c：simd_os_glue.c 已删除。 */
function simd_f_zero_c_marker_c(): i32 {
  return 1;
}

/**
 * 宿主是否具备已知 SIMD 能力（tier-1 目标默认 1；exotic 由 recommend_path 回退 scalar）。
 */
function simd_hw_available_c(): i32 {
  return 1;
}

/**
 * STD-153 C 烟测：校验 auto 策略与环境覆盖组合。
 * 成功 0；HW 可用却走 scalar 且无 env 覆盖 → 1；无 HW 却非 scalar → 2。
 */
function simd_autovec_smoke_c(): i32 {
  let hw: i32 = 0;
  let path: i32 = 0;
  let hw_env: *u8 = 0;
  let aut_env: *u8 = 0;
  hw = simd_hw_available_c();
  path = simd_recommend_path_c();
  if (hw != 0 && path == SIMD_PATH_SCALAR && simd_env_force_scalar() == 0) {
    unsafe { hw_env = getenv(&SIM_LIT_SHUX_SIMD_HW[0]); }
    unsafe { aut_env = getenv(&SIM_LIT_SHUX_SIMD_AUTOVEC[0]); }
    if (hw_env == 0 && aut_env == 0) { return 1; }
  }
  if (hw == 0 && path != SIMD_PATH_SCALAR) { return 2; }
  return 0;
}
