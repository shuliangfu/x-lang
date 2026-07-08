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

// std.test — 测试断言与 runner（对标 Zig std.testing、Rust test）
// STD-054：bench_run / bench_report / fuzz_seed / fuzz_next / fuzz_run 占位 API。
// STD-145：统一 runner（runner_reset / runner_case / runner_skip / runner_finish）。
//
// 【文件职责】assert、assert_eq、assert_ne 返回
// 0=通过/1=失败；run 执行测试函数。
// 【依赖】core；F-test v2 逻辑在 test.x（F-ZC 纯 .x；fn-ptr 在 runtime_test_fn_invoke.o）。
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
/** 断言 cond 为真；返回 0 通过，1 失败。 */
function assert(cond: i32): i32 { unsafe { return test_expect_c(cond); } }
/** 断言 a == b（i32）；返回 0 通过，1 失败。 */
function assert_eq(a: i32, b: i32): i32 { unsafe { return test_expect_eq_i32_c(a, b); } }
/** 断言 a == b（u32）；返回 0 通过，1 失败。 */
function assert_eq(a: u32, b: u32): i32 { unsafe { return test_expect_eq_u32_c(a, b); } }
/** 断言 a != b（i32）；返回 0 通过，1 失败。 */
function assert_ne(a: i32, b: i32): i32 { unsafe { return test_expect_ne_i32_c(a, b); } }
/** expect 风格别名：与 assert 语义一致，供测试调用。 */
function expect(cond: i32): i32 { return assert(cond); }
function expect_eq_i32(a: i32, b: i32): i32 { return assert_eq(a, b); }
function expect_eq_u32(a: u32, b: u32): i32 { return assert_eq(a, b); }
function expect_ne_i32(a: i32, b: i32): i32 { return assert_ne(a, b); }
/** 执行测试函数 fn（无参返回 i32）；返回 fn 的返回值（0=通过）。 */
function exec(fn: usize): i32 { unsafe { return test_run_c(fn); } }

/** 调用无参 fn 共 iters 次，返回纳秒耗时。 */
function bench_run(fn: usize, iters: i32): i64 { unsafe { return test_bench_run_c(fn, iters); } }

/** 写 bench 报告到 stderr：shux: [SHUX_BENCH] name=… ns=… */
function bench_report(name: *u8, len: i32, ns: i64): i32 {
  unsafe { return test_bench_report_c(name, len, ns); }
}

/** 读取 SHUX_FUZZ_SEED 或默认种子。 */
function fuzz_seed(): u32 { unsafe { return test_fuzz_seed_c(); } }

/** LCG 单步；state 为 in/out 种子指针。 */
function fuzz_next(state: *u32): u32 { unsafe { return test_fuzz_next_c(state); } }

/** 每轮推进 PRNG 后调用 fn；全部返回 0 则 0。 */
function fuzz_run(fn: usize, iters: i32): i32 { unsafe { return test_fuzz_run_c(fn, iters); } }

/** STD-143：对 C 内置 noop 跑 bench，无需函数指针。 */
function bench_run_noop(iters: i32): i64 { unsafe { return test_bench_run_noop_c(iters); } }

/** STD-143：对 C 内置 noop 跑 fuzz runner。 */
function fuzz_run_noop(iters: i32): i32 { unsafe { return test_fuzz_run_noop_c(iters); } }

/** 重置 runner 计数（STD-145）。 */
function runner_reset(): void { unsafe { test_runner_reset_c(); } }

/** 报告单条用例；exit_code=0 为 pass。 */
function runner_case(name: *u8, len: i32, exit_code: i32): i32 {
  unsafe { return test_runner_report_case_c(name, len, exit_code); }
}

/** 报告 skip 用例。 */
function runner_skip(name: *u8, len: i32): i32 { unsafe { return test_runner_report_skip_c(name, len); } }

/** 输出汇总行；返回 fail 数。 */
function runner_finish(): i32 { unsafe { return test_runner_finish_c(); } }
