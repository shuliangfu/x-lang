// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L6 invoke_ld pure tables + orch (G.9 English; body is authoritative).
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_invoke_ld_list.from_x.c.
// Hybrid macro SHUX_LABI_INVOKE_LD_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns brew/compress/tail/driver/entry pure tables + wave152 brew orch
// + wave153 asm compress-libs orch:
//   - labi_ld_brew_lib_path_{count,at} + labi_ld_flag_* / drivers / common_tail
//   - ld_append_brew_lib_paths (wave152; pure table scan; Cap residual host_is_apple)
//   - asm_ld_append_compress_libs (wave153; pure orch; Cap residual needs+ensure+path)
// Cap residual (mega): link_abi_host_is_apple; obj_needs_* Cap (marker/has_undef);
//   ensure/path for zlib glue; spawn/ld/cc IO; invoke_cc_append_compress_ld still mega.
// PLATFORM: SHARED orch / MACOS consumers for brew -L paths.

// Cap residual: compile-time #if __APPLE__ (all arch: aarch64 + x86_64).
// Not the same as shux_host_is_apple_aarch64 (host_lit L2; arm64 only).
export extern "C" function link_abi_host_is_apple(): i32;

// Cap residual / peer pure (ondemand L8b): .o depends on zlib/zstd/brotli.
export extern "C" function link_abi_obj_needs_zlib(obj_o: *u8): i32;
export extern "C" function link_abi_obj_needs_zstd(obj_o: *u8): i32;
export extern "C" function link_abi_obj_needs_brotli(obj_o: *u8): i32;

// Cap residual: ensure zlib macro-wrapper glue .o + resolve its path for ld argv.
export extern "C" function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_compress_zlib_glue_o_path(argv0: *u8): *u8;

/**
 * Homebrew /usr/local -L path table size (fixed catalog).
 * @return i32 — always 2 (homebrew + /usr/local)
 * PLATFORM: SHARED table; consumers gate with host_is_apple.
 */
#[no_mangle]
export function labi_ld_brew_lib_path_count(): i32 {
  return 2;
}

/** Exported function `labi_ld_brew_lib_path_at`.
 * Implements `labi_ld_brew_lib_path_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_brew_lib_path_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-L/opt/homebrew/lib";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-L/usr/local/lib";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ld_flag_lz`.
 * Implements `labi_ld_flag_lz`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lz(): *u8 {
  let p: *u8 = "-lz";
  return p;
}

/** Exported function `labi_ld_flag_lzstd`.
 * Implements `labi_ld_flag_lzstd`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lzstd(): *u8 {
  let p: *u8 = "-lzstd";
  return p;
}

/** Exported function `labi_ld_flag_lbrotlienc`.
 * Implements `labi_ld_flag_lbrotlienc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbrotlienc(): *u8 {
  let p: *u8 = "-lbrotlienc";
  return p;
}

/** Exported function `labi_ld_flag_lbrotlidec`.
 * Implements `labi_ld_flag_lbrotlidec`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbrotlidec(): *u8 {
  let p: *u8 = "-lbrotlidec";
  return p;
}

/** Exported function `labi_ld_compress_flag_count`.
 * Implements `labi_ld_compress_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_ld_compress_flag_count(): i32 {
  return 4;
}

/** Exported function `labi_ld_compress_flag_at`.
 * Implements `labi_ld_compress_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_compress_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lz";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lzstd";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-lbrotlienc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lbrotlidec";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ld_flag_lm`.
 * Implements `labi_ld_flag_lm`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lm(): *u8 {
  let p: *u8 = "-lm";
  return p;
}

/** Exported function `labi_ld_flag_lsqlite3`.
 * Implements `labi_ld_flag_lsqlite3`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lsqlite3(): *u8 {
  let p: *u8 = "-lsqlite3";
  return p;
}

/** Exported function `labi_ld_flag_pthread`.
 * Read path helper `labi_ld_flag_pthread`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_pthread(): *u8 {
  let p: *u8 = "-pthread";
  return p;
}

/** Exported function `labi_ld_flag_lpthread`.
 * Read path helper `labi_ld_flag_lpthread`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lpthread(): *u8 {
  let p: *u8 = "-lpthread";
  return p;
}

/** Exported function `labi_ld_flag_ldl`.
 * Implements `labi_ld_flag_ldl`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_ldl(): *u8 {
  let p: *u8 = "-ldl";
  return p;
}

/** Exported function `labi_ld_flag_lc`.
 * Implements `labi_ld_flag_lc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lc(): *u8 {
  let p: *u8 = "-lc";
  return p;
}

/** Exported function `labi_ld_flag_lSystem`.
 * Implements `labi_ld_flag_lSystem`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lSystem(): *u8 {
  let p: *u8 = "-lSystem";
  return p;
}

/** Exported function `labi_ld_flag_lws2_32`.
 * Implements `labi_ld_flag_lws2_32`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lws2_32(): *u8 {
  let p: *u8 = "-lws2_32";
  return p;
}

/** Exported function `labi_ld_flag_lbcrypt`.
 * Implements `labi_ld_flag_lbcrypt`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbcrypt(): *u8 {
  let p: *u8 = "-lbcrypt";
  return p;
}

/** Exported function `labi_ld_driver_clang`.
 * Implements `labi_ld_driver_clang`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_clang(): *u8 {
  let p: *u8 = "clang";
  return p;
}

/** Exported function `labi_ld_driver_ld`.
 * Implements `labi_ld_driver_ld`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_ld(): *u8 {
  let p: *u8 = "ld";
  return p;
}

/** Exported function `labi_ld_driver_gcc`.
 * Implements `labi_ld_driver_gcc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_gcc(): *u8 {
  let p: *u8 = "gcc";
  return p;
}

/** Exported function `labi_ld_driver_cc`.
 * Implements `labi_ld_driver_cc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_cc(): *u8 {
  let p: *u8 = "cc";
  return p;
}

/** Exported function `labi_ld_mach_entry_main`.
 * Implements `labi_ld_mach_entry_main`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_mach_entry_main(): *u8 {
  let p: *u8 = "_main";
  return p;
}

/** Exported function `labi_ld_flag_e`.
 * Implements `labi_ld_flag_e`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_e(): *u8 {
  let p: *u8 = "-e";
  return p;
}

/** Exported function `labi_ld_flag_o`.
 * Implements `labi_ld_flag_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_o(): *u8 {
  let p: *u8 = "-o";
  return p;
}

/** Exported function `labi_ld_common_tail_flag_count`.
 * Implements `labi_ld_common_tail_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_ld_common_tail_flag_count(): i32 {
  return 7;
}

/** Exported function `labi_ld_common_tail_flag_at`.
 * Implements `labi_ld_common_tail_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_common_tail_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lm";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lsqlite3";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-pthread";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lpthread";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "-ldl";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "-lc";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "-lSystem";
    return p;
  }
  return 0 as *u8;
}

/**
 * Append Homebrew /usr/local -L paths onto an ld/cc argv (Apple hosts only).
 * Enables -lz / -lzstd / -lbrotli* resolution under brew prefixes without hardcoding
 * at each compress-lib append site.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; need *la < max_la - 1 (room for NUL terminator)
 * @return void — no-op on non-Apple; skips null/empty table entries; stops when capacity full
 * Pure orch: Cap residual link_abi_host_is_apple + pure brew table count/at + append loop.
 * Cap residual: link_abi_host_is_apple (#if __APPLE__; all arch — not aarch64-only host_lit).
 * Why (wave152): hybrid still had always-mega C body for brew -L append (#if APPLE loop).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch / MACOS consumers (Linux/Windows host_is_apple → 0 no-op).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function ld_append_brew_lib_paths(argv: **u8, la: *i32, max_la: i32): void {
  // Cap residual: only Apple hosts append -L brew paths (≡ mega #if defined(__APPLE__)).
  let apple: i32 = 0;
  unsafe {
    apple = link_abi_host_is_apple();
  }
  if (apple == 0) {
    return;
  }
  // Guard argv null via *u8 cast (wave147/151: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let n: i32 = labi_ld_brew_lib_path_count();
  let k: i32 = 0;
  while (k < n) {
    // Capacity guard: leave one slot for argv NULL terminator (≡ mega max_la - 1).
    let cur: i32 = la[0];
    if (cur >= max_la - 1) {
      break;
    }
    let p: *u8 = labi_ld_brew_lib_path_at(k);
    k = k + 1;
    if (p == 0 as *u8) {
      continue;
    }
    if (p[0] == 0) {
      continue;
    }
    // Store table pointer (static string lifetime; no copy).
    argv[cur] = p;
    la[0] = cur + 1;
  }
}

/**
 * ASM ld: append -lz / -lzstd / -lbrotli* (and zlib glue .o) when compress_o or user_o needs them.
 * Gates each format via Cap residual / peer pure link_abi_obj_needs_*; brew -L via pure peer
 * ld_append_brew_lib_paths; flag strings via pure labi_ld_flag_*; zlib glue via Cap residual
 * ensure + path then direct argv append (asm path does not use invoke_cc_argv_push_existing).
 * @param compress_o *u8 — path to std/compress .o (nullable/empty → ignored by needs_*)
 * @param user_o *u8 — path to user main .o (nullable/empty → ignored by needs_*)
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; leave one slot for NULL terminator (max_la - 1)
 * @return void — appends only when a needs_* hits and capacity remains
 * Pure orch: needs_* Cap/peer + brew pure + flag pure + ensure/path Cap residual.
 * Cap residual: shux_ensure_runtime_compress_zlib_glue_o + shux_runtime_compress_zlib_glue_o_path;
 *   needs_* Cap (marker/has_undef) live under ondemand hybrid pure.
 * Why (wave153): hybrid still had always-mega C body for asm compress -l* append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Sibling invoke_cc_append_compress_ld remains mega (uses invoke_cc_argv_push_existing for glue).
 * PLATFORM: SHARED — verify mac + Ubuntu compress neighborhood + prove IDENTICAL.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function asm_ld_append_compress_libs(compress_o: *u8, user_o: *u8, argv: **u8, la: *i32, max_la: i32): void {
  // Guard argv null via *u8 cast (wave147/151/152: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let need_z: i32 = 0;
  let need_zs: i32 = 0;
  let need_br: i32 = 0;
  unsafe {
    need_z = link_abi_obj_needs_zlib(compress_o);
    if (need_z == 0) {
      need_z = link_abi_obj_needs_zlib(user_o);
    }
    need_zs = link_abi_obj_needs_zstd(compress_o);
    if (need_zs == 0) {
      need_zs = link_abi_obj_needs_zstd(user_o);
    }
    need_br = link_abi_obj_needs_brotli(compress_o);
    if (need_br == 0) {
      need_br = link_abi_obj_needs_brotli(user_o);
    }
  }
  if (need_z != 0) {
    // brew -L then -lz; ensure zlib macro-wrapper glue .o and append its path.
    ld_append_brew_lib_paths(argv, la, max_la);
    let cur: i32 = la[0];
    if (cur < max_la - 1) {
      let fl: *u8 = labi_ld_flag_lz();
      argv[cur] = fl;
      la[0] = cur + 1;
    }
    // Cap residual: build/ensure glue then resolve path (argv0 null ≡ mega NULL).
    unsafe {
      let _e: i32 = shux_ensure_runtime_compress_zlib_glue_o(0 as *u8);
    }
    let glue: *u8 = 0 as *u8;
    unsafe {
      glue = shux_runtime_compress_zlib_glue_o_path(0 as *u8);
    }
    if (glue != 0 as *u8) {
      if (glue[0] != 0) {
        let cur2: i32 = la[0];
        if (cur2 < max_la - 1) {
          argv[cur2] = glue;
          la[0] = cur2 + 1;
        }
      }
    }
  }
  if (need_zs != 0) {
    ld_append_brew_lib_paths(argv, la, max_la);
    let curz: i32 = la[0];
    if (curz < max_la - 1) {
      let flz: *u8 = labi_ld_flag_lzstd();
      argv[curz] = flz;
      la[0] = curz + 1;
    }
  }
  if (need_br != 0) {
    ld_append_brew_lib_paths(argv, la, max_la);
    let curb: i32 = la[0];
    if (curb < max_la - 1) {
      let fle: *u8 = labi_ld_flag_lbrotlienc();
      argv[curb] = fle;
      la[0] = curb + 1;
    }
    let curb2: i32 = la[0];
    if (curb2 < max_la - 1) {
      let fld: *u8 = labi_ld_flag_lbrotlidec();
      argv[curb2] = fld;
      la[0] = curb2 + 1;
    }
  }
}
