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
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
extern function test_expect_c(cond: i32): i32;
extern function test_expect_eq_i32_c(a: i32, b: i32): i32;
extern function test_expect_eq_u32_c(a: u32, b: u32): i32;
extern function test_expect_ne_i32_c(a: i32, b: i32): i32;
extern function test_run_c(fn: usize): i32;
extern function test_bench_run_c(fn: usize, iters: i32): i64;
extern function test_bench_report_c(name: *u8, len: i32, ns: i64): i32;
extern function test_fuzz_seed_c(): u32;
extern function test_fuzz_next_c(state: *u32): u32;
extern function test_fuzz_run_c(fn: usize, iters: i32): i32;
extern function test_bench_run_noop_c(iters: i32): i64;
extern function test_fuzz_run_noop_c(iters: i32): i32;
extern function test_runner_reset_c(): void;
extern function test_runner_report_case_c(name: *u8, len: i32, exit_code: i32): i32;
extern function test_runner_report_skip_c(name: *u8, len: i32): i32;
extern function test_runner_finish_c(): i32;
/** Exported function `assert`.
 * Assertion helper `assert`: panics on failure, returns 0 on success.
 * @param cond i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_c(cond
 * @return void
 */
export function assert(cond: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_c(cond); } return _rc; }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a i32
 * @param b i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_eq_i32_c(a
 * @param b
 * @return void
 */
export function assert_eq(a: i32, b: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_eq_i32_c(a, b); } return _rc; }
/** Exported function `assert_eq`.
 * Assertion helper `assert_eq`: panics on failure, returns 0 on success.
 * @param a u32
 * @param b u32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_eq_u32_c(a
 * @param b
 * @return void
 */
export function assert_eq(a: u32, b: u32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_eq_u32_c(a, b); } return _rc; }
/** Exported function `assert_ne`.
 * Assertion helper `assert_ne`: panics on failure, returns 0 on success.
 * @param a i32
 * @param b i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_ne_i32_c(a
 * @param b
 * @return void
 */
export function assert_ne(a: i32, b: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_expect_ne_i32_c(a, b); } return _rc; }
/** Exported function `expect`.
 * Implements `expect`.
 * @param cond i32): i32 { return assert(cond
 * @return void
 */
export function expect(cond: i32): i32 { return assert(cond); }
/** Exported function `expect_eq_i32`.
 * Implements `expect_eq_i32`.
 * @param a i32
 * @param b i32): i32 { return assert_eq(a
 * @param b
 * @return void
 */
export function expect_eq_i32(a: i32, b: i32): i32 { return assert_eq(a, b); }
/** Exported function `expect_eq_u32`.
 * Implements `expect_eq_u32`.
 * @param a u32
 * @param b u32): i32 { return assert_eq(a
 * @param b
 * @return void
 */
export function expect_eq_u32(a: u32, b: u32): i32 { return assert_eq(a, b); }
/** Exported function `expect_ne_i32`.
 * Implements `expect_ne_i32`.
 * @param a i32
 * @param b i32): i32 { return assert_ne(a
 * @param b
 * @return void
 */
export function expect_ne_i32(a: i32, b: i32): i32 { return assert_ne(a, b); }
/** Exported function `exec`.
 * Implements `exec`.
 * @param fn usize): i32 { let _rc: i32 = 0; unsafe { _rc = test_run_c(fn
 * @return void
 */
export function exec(fn: usize): i32 { let _rc: i32 = 0; unsafe { _rc = test_run_c(fn); } return _rc; }

/** Exported function `bench_run`.
 * Implements `bench_run`.
 * @param fn usize
 * @param iters i32): i64 { let _rc: i64 = 0; unsafe { _rc = test_bench_run_c(fn
 * @param iters
 * @return void
 */
export function bench_run(fn: usize, iters: i32): i64 { let _rc: i64 = 0; unsafe { _rc = test_bench_run_c(fn, iters); } return _rc; }

/** Exported function `bench_report`.
 * Implements `bench_report`.
 * @param name *u8
 * @param len i32
 * @param ns i64
 * @return i32
 */
export function bench_report(name: *u8, len: i32, ns: i64): i32 {
  unsafe { return test_bench_report_c(name, len, ns); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fuzz_seed`.
 * Implements `fuzz_seed`.
 * @param ) u32 { let _rc: u32 = 0; unsafe { _rc = test_fuzz_seed_c(
 * @return void
 */
export function fuzz_seed(): u32 { let _rc: u32 = 0; unsafe { _rc = test_fuzz_seed_c(); } return _rc; }

/** Exported function `fuzz_next`.
 * Implements `fuzz_next`.
 * @param state *u32): u32 { let _rc: u32 = 0; unsafe { _rc = test_fuzz_next_c(state
 * @return void
 */
export function fuzz_next(state: *u32): u32 { let _rc: u32 = 0; unsafe { _rc = test_fuzz_next_c(state); } return _rc; }

/** Exported function `fuzz_run`.
 * Implements `fuzz_run`.
 * @param fn usize
 * @param iters i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_fuzz_run_c(fn
 * @param iters
 * @return void
 */
export function fuzz_run(fn: usize, iters: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_fuzz_run_c(fn, iters); } return _rc; }

/** Exported function `bench_run_noop`.
 * Implements `bench_run_noop`.
 * @param iters i32): i64 { let _rc: i64 = 0; unsafe { _rc = test_bench_run_noop_c(iters
 * @return void
 */
export function bench_run_noop(iters: i32): i64 { let _rc: i64 = 0; unsafe { _rc = test_bench_run_noop_c(iters); } return _rc; }

/** Exported function `fuzz_run_noop`.
 * Implements `fuzz_run_noop`.
 * @param iters i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_fuzz_run_noop_c(iters
 * @return void
 */
export function fuzz_run_noop(iters: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_fuzz_run_noop_c(iters); } return _rc; }

/** Exported function `runner_reset`.
 * Implements `runner_reset`.
 * @param ) void { unsafe { test_runner_reset_c(
 * @return void
 */
export function runner_reset(): void { unsafe { test_runner_reset_c(); } }

/** Exported function `runner_case`.
 * Implements `runner_case`.
 * @param name *u8
 * @param len i32
 * @param exit_code i32
 * @return i32
 */
export function runner_case(name: *u8, len: i32, exit_code: i32): i32 {
  unsafe { return test_runner_report_case_c(name, len, exit_code); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `runner_skip`.
 * Implements `runner_skip`.
 * @param name *u8
 * @param len i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_runner_report_skip_c(name
 * @param len
 * @return void
 */
export function runner_skip(name: *u8, len: i32): i32 { let _rc: i32 = 0; unsafe { _rc = test_runner_report_skip_c(name, len); } return _rc; }

/** Exported function `runner_finish`.
 * Implements `runner_finish`.
 * @param ) i32 { let _rc: i32 = 0; unsafe { _rc = test_runner_finish_c(
 * @return void
 */
export function runner_finish(): i32 { let _rc: i32 = 0; unsafe { _rc = test_runner_finish_c(); } return _rc; }
