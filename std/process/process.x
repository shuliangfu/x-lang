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

// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
extern function process_shux_argc_get(): i32;

/* See implementation. */
extern function process_shux_argv_get(i: i32): *u8;

/** Exported function `process_args_count_c`.
 * Implements `process_args_count_c`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = process_shux_argc_get(
 * @return void
 */
export function process_args_count_c(): i32 { let _rc: i32 = 0; unsafe { _rc = process_shux_argc_get(); } return _rc; }

/** Exported function `process_arg_c`.
 * Implements `process_arg_c`.
 * @param i i32): *u8 { let _rc: *u8 = 0; unsafe { _rc = process_shux_argv_get(i
 * @return void
 */
export function process_arg_c(i: i32): *u8 { let _rc: *u8 = 0; unsafe { _rc = process_shux_argv_get(i); } return _rc; }
