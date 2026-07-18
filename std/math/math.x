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

// std/math/math.x — 数学常量（F-math v1；signum/special_smoke 在 runtime_math_libm.c）
//
// 【文件职责】PI/E/Tau 纯 .x 常量；libm 与烟测见 runtime_math_libm.c。

/** 圆周率 π。 */
export function math_pi_c(): f64 {
  return 3.14159265358979323846 as f64;
}

/** 自然常数 e。 */
export function math_e_c(): f64 {
  return 2.7182818284590452354 as f64;
}

/** 2π。 */
export function math_tau_c(): f64 {
  return math_pi_c() * 2.0;
}
