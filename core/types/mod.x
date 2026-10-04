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

// note
// note
// placeholder

/** `placeholder`: see signature for params/returns; contracts in body. */
export function placeholder(): i32 { return 0; }

// size_of_i32
/** `size_of_i32`: see signature for params/returns; contracts in body. */
export function size_of_i32(): i32 { return 4; }
/** `size_of_bool`: see signature for params/returns; contracts in body. */
export function size_of_bool(): i32 { return 1; }
/** `size_of_u8`: see signature for params/returns; contracts in body. */
export function size_of_u8(): i32 { return 1; }
/** `size_of_i16`: see signature for params/returns; contracts in body. */
export function size_of_i16(): i32 { return 2; }
/** `size_of_u16`: see signature for params/returns; contracts in body. */
export function size_of_u16(): i32 { return 2; }
/** `size_of_u32`: see signature for params/returns; contracts in body. */
export function size_of_u32(): i32 { return 4; }
/** `size_of_u64`: see signature for params/returns; contracts in body. */
export function size_of_u64(): i32 { return 8; }
/** `size_of_i64`: see signature for params/returns; contracts in body. */
export function size_of_i64(): i32 { return 8; }
/** `size_of_usize`: see signature for params/returns; contracts in body. */
export function size_of_usize(): i32 { return 8; }
/** `size_of_isize`: see signature for params/returns; contracts in body. */
export function size_of_isize(): i32 { return 8; }
/** `size_of_f32`: see signature for params/returns; contracts in body. */
export function size_of_f32(): i32 { return 4; }
/** `size_of_f64`: see signature for params/returns; contracts in body. */
export function size_of_f64(): i32 { return 8; }

// size_of_pointer
/** `size_of_pointer`: see signature for params/returns; contracts in body. */
export function size_of_pointer(): i32 { return 8; }
/** `align_of_pointer`: see signature for params/returns; contracts in body. */
export function align_of_pointer(): i32 { return 8; }

// align_of_i32
/** `align_of_i32`: see signature for params/returns; contracts in body. */
export function align_of_i32(): i32 { return 4; }
/** `align_of_bool`: see signature for params/returns; contracts in body. */
export function align_of_bool(): i32 { return 1; }
/** `align_of_u8`: see signature for params/returns; contracts in body. */
export function align_of_u8(): i32 { return 1; }
/** `align_of_i16`: see signature for params/returns; contracts in body. */
export function align_of_i16(): i32 { return 2; }
/** `align_of_u16`: see signature for params/returns; contracts in body. */
export function align_of_u16(): i32 { return 2; }
/** `align_of_u32`: see signature for params/returns; contracts in body. */
export function align_of_u32(): i32 { return 4; }
/** `align_of_u64`: see signature for params/returns; contracts in body. */
export function align_of_u64(): i32 { return 8; }
/** `align_of_i64`: see signature for params/returns; contracts in body. */
export function align_of_i64(): i32 { return 8; }
/** `align_of_usize`: see signature for params/returns; contracts in body. */
export function align_of_usize(): i32 { return 8; }
/** `align_of_isize`: see signature for params/returns; contracts in body. */
export function align_of_isize(): i32 { return 8; }
/** `align_of_f32`: see signature for params/returns; contracts in body. */
export function align_of_f32(): i32 { return 4; }
/** `align_of_f64`: see signature for params/returns; contracts in body. */
export function align_of_f64(): i32 { return 8; }

/**
 * Generic byte-size query.
 * The compiler folds size_of<T>() to that type's size before this body runs.
 * Unfolded, the body returns 0.
 * @return i32 — 0 when the call is not folded
 * PLATFORM: SHARED
 */
export function size_of<T>(): i32 { return 0; }

/**
 * Generic alignment query.
 * The compiler folds align_of<T>() to that type's alignment before this body runs.
 * Unfolded, the body returns 0.
 * @return i32 — 0 when the call is not folded
 * PLATFORM: SHARED
 */
export function align_of<T>(): i32 { return 0; }

/**
 * Concrete function after the generic queries.
 * The installed product does not asm-emit a generic that ends the file.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
export function types_layout_anchor(): i32 { return 0; }
