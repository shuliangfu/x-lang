// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-303/304 / P2 runtime rest：-x -E emit 状态槽 + setters + argv 扫描。
// R2 full：.x 吃满 set_path/set_lib/set_n/set_extern + argv_parse；
// 产品 PREFER_X_O 下 rest 业务 T=0（仅 marker；BSS 数据在 rest）。
// Cap-global-bss residual：共享缓冲/指针绑定在 driver_abi 槽 API
// （.x 勿用 **u8 写指针、勿用局部 u8[512] — -E 会丢函数/坏 init_globals）。

export extern "C" function driver_x_emit_path_buf_slot(): *u8;
export extern "C" function driver_x_emit_lib_buf_slot(i: i32): *u8;
export extern "C" function driver_x_emit_scan_ab_slot(): *u8;
export extern "C" function driver_x_emit_scan_nx_slot(): *u8;
export extern "C" function driver_x_emit_clear_c_path(): void;
export extern "C" function driver_x_emit_bind_c_path_to_buf(): void;
export extern "C" function driver_x_emit_bind_lib_root(i: i32): void;
export extern "C" function driver_x_emit_n_lib_roots_slot(): *i32;
export extern "C" function driver_x_emit_want_extern_slot(): *i32;
export extern "C" function driver_get_argv_i(argc: i32, argv: **u8, i: i32, buf: *u8, max: i32): i32;

export function rt_emit_max_lib_roots(): i32 {
  return 16;
}

export function rt_emit_path_cap(): i32 {
  return 512;
}

export function rt_emit_lib_cap(): i32 {
  return 256;
}

export function rt_argv_is_minus_L(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 76) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

export function rt_argv_is_minus_x(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 120) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

export function rt_argv_is_minus_E_tok(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  if (s[0] != 45) {
    return 0;
  }
  if (s[1] != 69) {
    return 0;
  }
  if (s[2] != 0) {
    return 0;
  }
  return 1;
}

export function rt_emit_copy_n(dst: *u8, src: *u8, n: i32): void {
  let ci: i32 = 0;
  if (dst == 0 as *u8) {
    return;
  }
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  while (ci < n) {
    dst[ci as usize] = src[ci as usize];
    ci = ci + 1;
  }
  dst[n as usize] = 0;
}

/** path 灌入 emit 槽。 */
#[no_mangle]
export function driver_run_x_emit_c_set_path(path: *u8, path_len: i32): i32 {
  let set_pbuf: *u8 = 0 as *u8;
  let set_cap: i32 = 0;
  unsafe {
    driver_x_emit_clear_c_path();
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  set_cap = rt_emit_path_cap();
  if (path_len >= set_cap) {
    return 0;
  }
  unsafe {
    set_pbuf = driver_x_emit_path_buf_slot();
  }
  if (set_pbuf == 0 as *u8) {
    return 0;
  }
  rt_emit_copy_n(set_pbuf, path, path_len);
  unsafe {
    driver_x_emit_bind_c_path_to_buf();
  }
  return 0;
}

/** 第 i 个 -L 根灌入 lib 槽。 */
#[no_mangle]
export function driver_run_x_emit_c_set_lib(i: i32, buf: *u8, len: i32): i32 {
  let set_lbuf: *u8 = 0 as *u8;
  let set_maxr: i32 = 0;
  let set_lcap: i32 = 0;
  set_maxr = rt_emit_max_lib_roots();
  set_lcap = rt_emit_lib_cap();
  if (i < 0) {
    return 0;
  }
  if (i >= set_maxr) {
    return 0;
  }
  if (buf == 0 as *u8) {
    return 0;
  }
  if (len < 0) {
    return 0;
  }
  if (len >= set_lcap) {
    return 0;
  }
  unsafe {
    set_lbuf = driver_x_emit_lib_buf_slot(i);
  }
  if (set_lbuf == 0 as *u8) {
    return 0;
  }
  rt_emit_copy_n(set_lbuf, buf, len);
  unsafe {
    driver_x_emit_bind_lib_root(i);
  }
  return 0;
}

/** 设置 -L 根个数。 */
#[no_mangle]
export function driver_run_x_emit_c_set_n_lib_roots(n: i32): i32 {
  let n_slot: *i32 = 0 as *i32;
  let n_maxr: i32 = 0;
  let n_v: i32 = 0;
  n_maxr = rt_emit_max_lib_roots();
  if (n >= 0) {
    if (n <= n_maxr) {
      n_v = n;
    }
  }
  unsafe {
    n_slot = driver_x_emit_n_lib_roots_slot();
  }
  if (n_slot != 0 as *i32) {
    n_slot[0] = n_v;
  }
  return 0;
}

/** 设置 want_extern（-E-extern）。 */
#[no_mangle]
export function driver_run_x_emit_c_set_emit_extern(v: i32): i32 {
  let w_slot: *i32 = 0 as *i32;
  let w_out: i32 = 0;
  if (v != 0) {
    w_out = 1;
  }
  unsafe {
    w_slot = driver_x_emit_want_extern_slot();
  }
  if (w_slot != 0 as *i32) {
    w_slot[0] = w_out;
  }
  return 0;
}

/**
 * 从 argv[i..] 扫描 -L / -x -E <path>（尾递归）。
 * 命中 -x -E 后写 path 槽并返回 1。
 */
export function rt_scan_x_emit_argv(argc: i32, argv: **u8, i: i32): i32 {
  let sc_ab: *u8 = 0 as *u8;
  let sc_nx: *u8 = 0 as *u8;
  let sc_ln: i32 = 0;
  let sc_k: i32 = 0;
  let sc_nslot: *i32 = 0 as *i32;
  let sc_pbuf: *u8 = 0 as *u8;
  let sc_lbuf: *u8 = 0 as *u8;
  let sc_maxr: i32 = 0;
  if (i >= argc) {
    return 0;
  }
  unsafe {
    sc_ab = driver_x_emit_scan_ab_slot();
  }
  if (sc_ab == 0 as *u8) {
    return 0;
  }
  unsafe {
    sc_ln = driver_get_argv_i(argc, argv, i, sc_ab, 512);
  }
  if (sc_ln < 0) {
    return rt_scan_x_emit_argv(argc, argv, i + 1);
  }
  if (rt_argv_is_minus_L(sc_ab) != 0) {
    if (i + 1 >= argc) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_nslot = driver_x_emit_n_lib_roots_slot();
    }
    sc_k = 0;
    if (sc_nslot != 0 as *i32) {
      sc_k = sc_nslot[0];
    }
    sc_maxr = rt_emit_max_lib_roots();
    if (sc_k < sc_maxr) {
      unsafe {
        sc_lbuf = driver_x_emit_lib_buf_slot(sc_k);
      }
      if (sc_lbuf != 0 as *u8) {
        unsafe {
          sc_ln = driver_get_argv_i(argc, argv, i + 1, sc_lbuf, 256);
        }
        if (sc_ln < 0) {
          return 0;
        }
        unsafe {
          driver_x_emit_bind_lib_root(sc_k);
        }
        if (sc_nslot != 0 as *i32) {
          sc_nslot[0] = sc_k + 1;
        }
      }
    }
    return rt_scan_x_emit_argv(argc, argv, i + 2);
  }
  if (rt_argv_is_minus_x(sc_ab) != 0) {
    if (i + 2 >= argc) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_nx = driver_x_emit_scan_nx_slot();
    }
    if (sc_nx == 0 as *u8) {
      return 0;
    }
    unsafe {
      sc_ln = driver_get_argv_i(argc, argv, i + 1, sc_nx, 512);
    }
    if (sc_ln < 0) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    if (rt_argv_is_minus_E_tok(sc_nx) == 0) {
      return rt_scan_x_emit_argv(argc, argv, i + 1);
    }
    unsafe {
      sc_pbuf = driver_x_emit_path_buf_slot();
    }
    if (sc_pbuf == 0 as *u8) {
      return 0;
    }
    unsafe {
      sc_ln = driver_get_argv_i(argc, argv, i + 2, sc_pbuf, 512);
    }
    if (sc_ln < 0) {
      return 0;
    }
    unsafe {
      driver_x_emit_bind_c_path_to_buf();
    }
    return 1;
  }
  return rt_scan_x_emit_argv(argc, argv, i + 1);
}

/**
 * 扫描 argv：若存在 -x -E <path> 则记下 path 及此前 -L，返回 1，否则 0。
 * 注意：勿写 argv == 0 as **u8（-E 会整函数丢符号）。
 */
#[no_mangle]
export function driver_argv_parse_x_emit_c(argc: i32, argv: **u8): i32 {
  let pr_nslot: *i32 = 0 as *i32;
  unsafe {
    driver_x_emit_clear_c_path();
    pr_nslot = driver_x_emit_n_lib_roots_slot();
  }
  if (pr_nslot != 0 as *i32) {
    pr_nslot[0] = 0;
  }
  if (argc < 4) {
    return 0;
  }
  return rt_scan_x_emit_argv(argc, argv, 1);
}
