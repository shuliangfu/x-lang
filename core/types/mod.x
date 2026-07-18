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

// core.types — 基础类型 size_of/align_of（自举前实现）
// 当前：上述类型 + 指针（size_of_pointer/align_of_pointer，64 位为 8）；i16/u16 待语言与编译器支持后再补，泛型 size_of(T)/align_of(T) 待内建。
// 高性能：所有函数为常量/纯函数，可被编译器内联；无隐式分配与间接调用。

export function placeholder(): i32 { return 0; }

// 基础类型大小（字节），供自举前使用；与变量类型与类型系统设计一致。
export function size_of_i32(): i32 { return 4; }
export function size_of_bool(): i32 { return 1; }
export function size_of_u8(): i32 { return 1; }
export function size_of_i16(): i32 { return 2; }
export function size_of_u16(): i32 { return 2; }
export function size_of_u32(): i32 { return 4; }
export function size_of_u64(): i32 { return 8; }
export function size_of_i64(): i32 { return 8; }
export function size_of_usize(): i32 { return 8; }
export function size_of_isize(): i32 { return 8; }
export function size_of_f32(): i32 { return 4; }
export function size_of_f64(): i32 { return 8; }

// 指针：*T 在 64 位环境下为 8 字节；与 typeck/codegen 一致。
export function size_of_pointer(): i32 { return 8; }
export function align_of_pointer(): i32 { return 8; }

// 基础类型对齐（字节），与 size_of_* 对称；64 位环境下常见布局。
export function align_of_i32(): i32 { return 4; }
export function align_of_bool(): i32 { return 1; }
export function align_of_u8(): i32 { return 1; }
export function align_of_i16(): i32 { return 2; }
export function align_of_u16(): i32 { return 2; }
export function align_of_u32(): i32 { return 4; }
export function align_of_u64(): i32 { return 8; }
export function align_of_i64(): i32 { return 8; }
export function align_of_usize(): i32 { return 8; }
export function align_of_isize(): i32 { return 8; }
export function align_of_f32(): i32 { return 4; }
export function align_of_f64(): i32 { return 8; }

/**
 * 泛型 compile-time 布局查询：typeck/codegen 折叠为常量（CORE-001）。
 * 占位 return 0；单态化调用 `size_of<T>()` / `align_of<T>()` 由编译器替换为实际字节数。
 */
export function size_of<T>(): i32 { return 0; }
export function align_of<T>(): i32 { return 0; }
