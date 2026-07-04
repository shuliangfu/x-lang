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

// std.simd — SIMD-S2：标准向量类型 Vec4f / Vec8i（映射 f32x4 / i32x8 语义）
// STD-047：vec4f_shuffle / vec8i_select lane-scalar 实装；STD-061：shuffle/select 生产级 perf bench 锚点。
//
// 【文件职责】
//   - Vec4f：4×f32（128-bit，NEON / SSE / AVX 低半）
//   - Vec8i：8×i32（256-bit，AVX2；arm64 为 lane-scalar 路径直至 SVE）
// 编译器将 Vec4f/Vec8i 识别为 TYPE_VECTOR 栈槽（16B / 32B，16B 对齐）。
// 【依赖】语言 TYPE_VECTOR；SIMD-S1 target_cpu_features 供后续 intrinsic 分派。
//
// 底层拼写：f32x4 / i32x8 与 Vec4f / Vec8i 等价（parser + asm 后端）。

extern function simd_hw_available_c(): i32;
extern function simd_recommend_path_c(): i32;

/** lane-scalar 回退路径常量（与 simd.c SIMD_PATH_SCALAR 一致）。 */
function SIMD_PATH_SCALAR(): i32 { return 0; }
/** 硬件向量 emit 路径常量（与 simd.c SIMD_PATH_HW 一致）。 */
function SIMD_PATH_HW(): i32 { return 1; }

/** 宿主是否具备已知 SIMD 能力（1/0）。 */
function hw_available(): i32 {
  unsafe { return simd_hw_available_c(); }
}

/** STD-153：推荐向量化路径（0=scalar，1=hw）。 */
function recommend_path(): i32 {
  unsafe { return simd_recommend_path_c(); }
}

/** Vec8i 逐 lane 加法（当前 lane-scalar emit；SIMD-S3 起可矢量化）。 */
function add(a: Vec8i, b: Vec8i): Vec8i {
  return a + b;
}

/** Vec8i 逐 lane 减法（SIMD-S3 binop 内联：psubd/vpsubd）。 */
function sub(a: Vec8i, b: Vec8i): Vec8i {
  return a - b;
}

/** Vec8i 逐 lane 乘法（SIMD-S3 binop 内联：pmulld/vpmulld）。 */
function mul(a: Vec8i, b: Vec8i): Vec8i {
  return a * b;
}

/** Vec8i 广播单值到 8 lane。 */
function splat(x: i32): Vec8i {
  let v: Vec8i = [x, x, x, x, x, x, x, x];
  return v;
}

/** Vec4f 逐 lane 加法。 */
function add(a: Vec4f, b: Vec4f): Vec4f {
  return a + b;
}

/** Vec4f 逐 lane 减法（SIMD-S3 binop 内联：mulps/subps）。 */
function sub(a: Vec4f, b: Vec4f): Vec4f {
  return a - b;
}

/** Vec4f 逐 lane 乘法（SIMD-S3 binop 内联：mulps）。 */
function mul(a: Vec4f, b: Vec4f): Vec4f {
  return a * b;
}

/** Vec4f 四 lane 水平求和（dot 归约 epilogue）。 */
function hsum(v: Vec4f): f32 {
  return v[0] + v[1] + v[2] + v[3];
}

/** Vec4f 点积：sum(a[i]*b[i])。 */
function dot(a: Vec4f, b: Vec4f): f32 {
  return hsum(mul(a, b));
}

/**
 * Vec4f 融合乘加（FMA）：逐 lane 计算 a + b * c。
 * x86 emit vfmadd231ps（FMA3）或 mulps+addps；无 HW 时 lane-scalar 回退。
 */
function fma(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  let r: Vec4f = [
    a[0] + b[0] * c[0],
    a[1] + b[1] * c[1],
    a[2] + b[2] * c[2],
    a[3] + b[3] * c[3]
  ];
  return r;
}

/** Vec4f multiply-add 别名（同 fma）。 */
function madd(a: Vec4f, b: Vec4f, c: Vec4f): Vec4f {
  return fma(a, b, c);
}

/** Vec4f 广播单值到 4 lane。 */
function splat(x: f32): Vec4f {
  let v: Vec4f = [x, x, x, x];
  return v;
}

/**
 * Vec4f comptime shuffle（SIMD-S4）：mask 为编译期 i32[4]，lane 索引 0..3。
 * lane-scalar 回退：v[mask[i]]；编译器可内联为 pshufd。
 */
function shuffle(v: Vec4f, mask: i32[4]): Vec4f {
  let r: Vec4f = [v[mask[0]], v[mask[1]], v[mask[2]], v[mask[3]]];
  return r;
}

/**
 * Vec8i comptime shuffle（SIMD-S4）：mask 为编译期 i32[8]。
 * lane-scalar 回退：v[mask[i]]。
 */
function shuffle(v: Vec8i, mask: i32[8]): Vec8i {
  let r: Vec8i = [
    v[mask[0]], v[mask[1]], v[mask[2]], v[mask[3]],
    v[mask[4]], v[mask[5]], v[mask[6]], v[mask[7]]
  ];
  return r;
}

/** 单 lane select：mask lane 非 0 取 a，否则 b。 */
function select_lane(mask_lane: i32, a_lane: i32, b_lane: i32): i32 {
  if (mask_lane != 0) { return a_lane; }
  return b_lane;
}

/**
 * Vec8i 向量 select（SIMD-S4）：mask lane 非 0 取 a，否则 b。
 */
function select(mask: Vec8i, a: Vec8i, b: Vec8i): Vec8i {
  let r: Vec8i = [
    select_lane(mask[0], a[0], b[0]),
    select_lane(mask[1], a[1], b[1]),
    select_lane(mask[2], a[2], b[2]),
    select_lane(mask[3], a[3], b[3]),
    select_lane(mask[4], a[4], b[4]),
    select_lane(mask[5], a[5], b[5]),
    select_lane(mask[6], a[6], b[6]),
    select_lane(mask[7], a[7], b[7])
  ];
  return r;
}

/** 单 lane f32 select：mask 非 0 取 a。 */
function select_lane(mask_lane: f32, a_lane: f32, b_lane: f32): f32 {
  if (mask_lane != 0.0) { return a_lane; }
  return b_lane;
}

/**
 * Vec4f 向量 select（SIMD-S4）：mask lane 非 0 取 a，否则 b。
 */
function select(mask: Vec4f, a: Vec4f, b: Vec4f): Vec4f {
  let r: Vec4f = [
    select_lane(mask[0], a[0], b[0]),
    select_lane(mask[1], a[1], b[1]),
    select_lane(mask[2], a[2], b[2]),
    select_lane(mask[3], a[3], b[3])
  ];
  return r;
}

/** 占位：模块加载 smoke（import("std.simd") 链）。 */
function placeholder(): i32 {
  return 0;
}
