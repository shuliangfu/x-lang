// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-317/449 / P2 runtime R8-lite: stack-escape gate on large-stack pthread.
// R2 full: .x owns thread_fn + large_stack; FROM_X rest is marker-only (business H=0).
// Cap-fn-ptr: .x cannot take function addresses → dedicated entry
// driver_run_stack_esc_gate_on_large_stack (driver_abi platform layer binds thread_fn).

export extern "C" function pipeline_typeck_x_stack_escape_gate_from_src_c(src: *u8, src_len: i32): i32;

/**
 * Cap-fn-ptr residual: platform layer binds this module's thread_fn then runs on large stack.
 * Params: arg — opaque DriverStackEscGateArgs* as *u8.
 * Returns: void. PLATFORM: SHARED residual in driver_abi.
 */
export extern "C" function driver_run_stack_esc_gate_on_large_stack(arg: *u8): void;

/**
 * Args for the large-stack X stack-escape gate after `shux check` (layout matches seed C).
 * Fields: src / src_len — source buffer; result — out status (-99 = not yet set).
 */
struct DriverStackEscGateArgs {
  src: *u8;
  src_len: i32;
  result: i32;
}

/**
 * pthread entry: WPO-S3 post-scan gate.
 * Params: arg — *DriverStackEscGateArgs as *u8.
 * Returns: always null (pthread start_routine convention).
 * Contracts: null arg → null return without calling typeck; writes a.result.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function driver_stack_esc_gate_thread_fn(arg: *u8): *u8 {
  let a: *DriverStackEscGateArgs = arg as *DriverStackEscGateArgs;
  if (a == 0 as *DriverStackEscGateArgs) {
    return 0 as *u8;
  }
  let r: i32 = 0;
  unsafe {
    r = pipeline_typeck_x_stack_escape_gate_from_src_c(a.src, a.src_len);
  }
  a.result = r;
  return 0 as *u8;
}

/**
 * Run X struct stack-escape gate on a 256MiB-stack pthread (check path; do not parse on main).
 * Params: src / src_len — source buffer for the gate.
 * Returns: gate status from typeck; if result still -99 (pthread create failure etc.),
 * falls back to running the gate on the main thread.
 * Contracts: initial result sentinel is -99; platform residual binds thread_fn.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — large-stack path via driver_abi residual.
 */
#[no_mangle]
export function driver_stack_esc_gate_large_stack(src: *u8, src_len: i32): i32 {
  let args: DriverStackEscGateArgs = DriverStackEscGateArgs {
    src: src,
    src_len: src_len,
    result: -99,
  };
  unsafe {
    driver_run_stack_esc_gate_on_large_stack(&args as *u8);
  }
  if (args.result == -99) {
    let r2: i32 = 0;
    unsafe {
      r2 = pipeline_typeck_x_stack_escape_gate_from_src_c(src, src_len);
    }
    return r2;
  }
  return args.result;
}
