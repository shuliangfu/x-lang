// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-317/449 / P2 runtime R8-lite：栈逃逸 gate 大栈 pthread。
// R2 full：.x 吃满 thread_fn + large_stack；FROM_X rest 仅 marker（业务 H=0）。
// Cap-fn-ptr：.x 无法取函数地址 → 专用入口 driver_run_stack_esc_gate_on_large_stack
// （driver_abi 平台层绑定 thread_fn，与既有 pthread 体同层）。

export extern "C" function pipeline_typeck_x_stack_escape_gate_from_src_c(src: *u8, src_len: i32): i32;
/** Cap-fn-ptr residual：平台层绑定本模块 thread_fn 后进大栈。 */
export extern "C" function driver_run_stack_esc_gate_on_large_stack(arg: *u8): void;

/** shux check 后 X 栈逃逸 gate 大栈线程参数（与 seed C 布局一致）。 */
struct DriverStackEscGateArgs {
  src: *u8;
  src_len: i32;
  result: i32;
}

/** pthread 入口：WPO-S3 post-scan gate。 */
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
 * 在 256MiB 栈 pthread 上跑 X struct 栈逃逸 gate（check 路径；勿在主线程 parse）。
 * result 仍为 -99 时回落主线程直跑（pthread 创建失败等）。
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
