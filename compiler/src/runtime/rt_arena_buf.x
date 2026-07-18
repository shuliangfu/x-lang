// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-309/443 / P2 runtime rest → R2 full：静态 arena/module 缓冲。
// .x 吃满 driver_arena_buf / driver_module_buf（memset + num_types 清零）。
// 产品 PREFER_X_O：full .x + rest 在 FROM_X 下业务 T=0（marker + BSS 数据）。
// Cap-global-bss residual：128MiB/2MiB 数组在 rest seed；槽 API 在 driver_abi
// （.x export let 会变 static，不能跨 TU 导出大数组）。

export extern "C" function driver_arena_static_slot(): *u8;
export extern "C" function driver_module_static_slot(): *u8;
export extern "C" function driver_arena_static_size(): usize;
export extern "C" function driver_module_static_size(): usize;
export extern "C" function pipeline_arena_offset_num_types(): usize;
export extern "C" function memset(p: *u8, c: i32, n: usize): *u8;

/** 清零并返回静态 arena 缓冲（≥ pipeline_sizeof_arena；宿主 128MiB）。 */
#[no_mangle]
export function driver_arena_buf(): *u8 {
  let p: *u8 = 0 as *u8;
  let sz: usize = 0 as usize;
  let off: usize = 0 as usize;
  unsafe {
    p = driver_arena_static_slot();
    sz = driver_arena_static_size();
  }
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    memset(p, 0, sz);
    off = pipeline_arena_offset_num_types();
  }
  // 强制 num_types=0（小端 i32 写 0），避免与 .x 布局不一致时 type_alloc 误判
  if (off + 4 as usize <= sz) {
    p[off] = 0;
    p[off + 1 as usize] = 0;
    p[off + 2 as usize] = 0;
    p[off + 3 as usize] = 0;
  }
  return p;
}

/** 清零并返回静态 module 缓冲（宿主 2MiB）。 */
#[no_mangle]
export function driver_module_buf(): *u8 {
  let p: *u8 = 0 as *u8;
  let sz: usize = 0 as usize;
  unsafe {
    p = driver_module_static_slot();
    sz = driver_module_static_size();
  }
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    memset(p, 0, sz);
  }
  return p;
}
