// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
//
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
// labi_fs_env_freestanding: see function docblock below.

#[no_mangle]
/** Exported function `labi_fs_env_freestanding`.
 * Memory management helper `labi_fs_env_freestanding`.
 * @return *u8
 */
export function labi_fs_env_freestanding(): *u8 {
  let p: *u8 = "SHUX_FREESTANDING";
  return p;
}

#[no_mangle]
/** Exported function `labi_fs_io_sym_count`.
 * Implements `labi_fs_io_sym_count`.
 * @return i32
 */
export function labi_fs_io_sym_count(): i32 {
  return 13;
}

#[no_mangle]
/** Exported function `labi_fs_io_sym_at`.
 * Implements `labi_fs_io_sym_at`.
 * @param i i32
 * @return *u8
 */
export function labi_fs_io_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "shux_sys_write";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "shux_sys_read";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "shux_sys_close";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "shux_sys_exit";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "shux_sys_open";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "shux_sys_openat";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "shux_sys_mmap";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "shux_sys_munmap";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "shux_sys_socket";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "shux_sys_connect";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "shux_sys_bind";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "shux_sys_listen";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "shux_sys_accept";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `labi_fs_panic_sym`.
 * Implements `labi_fs_panic_sym`.
 * @return *u8
 */
export function labi_fs_panic_sym(): *u8 {
  let p: *u8 = "shux_panic_";
  return p;
}

#[no_mangle]
/** Exported function `labi_fs_ensure_catalog_count`.
 * Implements `labi_fs_ensure_catalog_count`.
 * @return i32
 */
export function labi_fs_ensure_catalog_count(): i32 {
  return 2;
}

// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
#[no_mangle]
/** Function `labi_fs_ensure_catalog_step_at`.
 * Purpose: implements `labi_fs_ensure_catalog_step_at`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function labi_fs_ensure_catalog_step_at(
  i: i32, stem_out: *usize, out_base_out: *usize, src_rel_out: *usize
): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 2) {
    return 0;
  }
  if (i == 0) {
    if (stem_out != 0 as *usize) {
      let p: *u8 = "crt0_user";
      stem_out[0] = p as usize;
    }
    if (out_base_out != 0 as *usize) {
      let p: *u8 = "crt0_user.o";
      out_base_out[0] = p as usize;
    }
    if (src_rel_out != 0 as *usize) {
      let p: *u8 = "src/asm/crt0_user_x86_64.s";
      src_rel_out[0] = p as usize;
    }
    return 1;
  }
  if (i == 1) {
    if (stem_out != 0 as *usize) {
      let p: *u8 = "freestanding_io";
      stem_out[0] = p as usize;
    }
    if (out_base_out != 0 as *usize) {
      let p: *u8 = "freestanding_io.o";
      out_base_out[0] = p as usize;
    }
    if (src_rel_out != 0 as *usize) {
      let p: *u8 = "src/asm/freestanding_io_x86_64.s";
      src_rel_out[0] = p as usize;
    }
    return 1;
  }
  return 0;
}

#[no_mangle]
/** Exported function `labi_fs_ensure_out_base`.
 * Implements `labi_fs_ensure_out_base`.
 * @param i i32
 * @return *u8
 */
export function labi_fs_ensure_out_base(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "crt0_user.o";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "freestanding_io.o";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `labi_fs_ensure_src_rel`.
 * Implements `labi_fs_ensure_src_rel`.
 * @param i i32
 * @return *u8
 */
export function labi_fs_ensure_src_rel(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "src/asm/crt0_user_x86_64.s";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "src/asm/freestanding_io_x86_64.s";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `labi_fs_ensure_stem`.
 * Implements `labi_fs_ensure_stem`.
 * @param i i32
 * @return *u8
 */
export function labi_fs_ensure_stem(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "crt0_user";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "freestanding_io";
    return p;
  }
  return 0 as *u8;
}

#[no_mangle]
/** Exported function `labi_fs_crt0_out_base`.
 * Implements `labi_fs_crt0_out_base`.
 * @return *u8
 */
export function labi_fs_crt0_out_base(): *u8 {
  let p: *u8 = "crt0_user.o";
  return p;
}

#[no_mangle]
/** Exported function `labi_fs_crt0_src_rel`.
 * Implements `labi_fs_crt0_src_rel`.
 * @return *u8
 */
export function labi_fs_crt0_src_rel(): *u8 {
  let p: *u8 = "src/asm/crt0_user_x86_64.s";
  return p;
}

#[no_mangle]
/** Exported function `labi_fs_io_out_base`.
 * Implements `labi_fs_io_out_base`.
 * @return *u8
 */
export function labi_fs_io_out_base(): *u8 {
  let p: *u8 = "freestanding_io.o";
  return p;
}

#[no_mangle]
/** Exported function `labi_fs_io_src_rel`.
 * Implements `labi_fs_io_src_rel`.
 * @return *u8
 */
export function labi_fs_io_src_rel(): *u8 {
  let p: *u8 = "src/asm/freestanding_io_x86_64.s";
  return p;
}
