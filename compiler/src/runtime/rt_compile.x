// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-291/292 / P2 runtime R6 compile pure helpers。
// 产品实现：seeds/rt_compile.from_x.c；hybrid 宏 SHUX_RT_COMPILE_FROM_X。
//
// f-291：deps_std_core + emit_asm path pure
// f-292：argv state — copy_path / freestanding / help
// 主编排/IO 仍 mega。

extern "C" function strncmp(a: *u8, b: *u8, n: usize): i32;
extern "C" function strcmp(a: *u8, b: *u8): i32;
extern "C" function strstr(hay: *u8, needle: *u8): *u8;

/** dep 列表是否全为 std./core. 闭包（逻辑锚点；完整实现见 seed）。 */
#[no_mangle]
function driver_deps_are_std_core_closure_only(dep_paths: **u8, n_deps: i32): i32 {
  let k: i32 = 0;
  if (dep_paths == 0 as **u8 || n_deps <= 0) {
    return 0;
  }
  while (k < n_deps) {
    unsafe {
      let p: *u8 = dep_paths[k as usize];
      if (p == 0 as *u8) {
        return 0;
      }
      if (p[0] == 0) {
        return 0;
      }
      if (strncmp(p, "std." as *u8, 4 as usize) == 0) {
        k = k + 1;
      } else {
        if (strncmp(p, "core." as *u8, 5 as usize) == 0) {
          k = k + 1;
        } else {
          return 0;
        }
      }
    }
  }
  return 1;
}
