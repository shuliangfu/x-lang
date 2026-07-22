// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-276 / P2 link_abi L7 freestanding pure table + wave117 needs pure orch.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_freestanding_list.from_x.c.
// Hybrid macro SHUX_LABI_FREESTANDING_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: env/io/panic/ensure catalog tables + wave117 heap needle tables +
//   link_abi_generated_c_needs_libc_heap / link_abi_user_o_needs_libc_heap /
//   link_abi_user_o_needs_freestanding_nostdlib_face pure orch +
//   wave136 link_abi_generated_c_needs_{fs,random,time,runtime} pure orch
//     (C-path PRIMARY OS/fs string needles; Cap residual contains_substr).
// Cap residual: ensure/cc/spawn IO; contains_substr + undef_sym probes in mega.
// PLATFORM: SHARED tables / LINUX freestanding face for nostdlib orch.

/** Exported function `labi_fs_env_freestanding`.
 * Memory management helper `labi_fs_env_freestanding`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_env_freestanding(): *u8 {
  let p: *u8 = "SHUX_FREESTANDING";
  return p;
}

/** Exported function `labi_fs_io_sym_count`.
 * Implements `labi_fs_io_sym_count`.
 * @return i32
 */
#[no_mangle]
export function labi_fs_io_sym_count(): i32 {
  return 13;
}

/** Exported function `labi_fs_io_sym_at`.
 * Implements `labi_fs_io_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
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

/** Exported function `labi_fs_panic_sym`.
 * Implements `labi_fs_panic_sym`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_panic_sym(): *u8 {
  let p: *u8 = "shux_panic_";
  return p;
}

/** Exported function `labi_fs_ensure_catalog_count`.
 * Implements `labi_fs_ensure_catalog_count`.
 * @return i32
 */
#[no_mangle]
export function labi_fs_ensure_catalog_count(): i32 {
  return 2;
}

// link_abi L7 freestanding pure table (G.9 English; body is authoritative).
/** Function `labi_fs_ensure_catalog_step_at`.
 * Purpose: implements `labi_fs_ensure_catalog_step_at`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
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

/** Exported function `labi_fs_ensure_out_base`.
 * Implements `labi_fs_ensure_out_base`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
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

/** Exported function `labi_fs_ensure_src_rel`.
 * Implements `labi_fs_ensure_src_rel`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
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

/** Exported function `labi_fs_ensure_stem`.
 * Implements `labi_fs_ensure_stem`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
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

/** Exported function `labi_fs_crt0_out_base`.
 * Implements `labi_fs_crt0_out_base`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_crt0_out_base(): *u8 {
  let p: *u8 = "crt0_user.o";
  return p;
}

/** Exported function `labi_fs_crt0_src_rel`.
 * Implements `labi_fs_crt0_src_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_crt0_src_rel(): *u8 {
  let p: *u8 = "src/asm/crt0_user_x86_64.s";
  return p;
}

/** Exported function `labi_fs_io_out_base`.
 * Implements `labi_fs_io_out_base`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_io_out_base(): *u8 {
  let p: *u8 = "freestanding_io.o";
  return p;
}

/** Exported function `labi_fs_io_src_rel`.
 * Implements `labi_fs_io_src_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_io_src_rel(): *u8 {
  let p: *u8 = "src/asm/freestanding_io_x86_64.s";
  return p;
}

/* Cap residual: file/object probes stay in mega (contains_substr / undef_sym). */
export extern "C" function link_abi_generated_c_contains_substr(c_path: *u8, needle: *u8): i32;
export extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;

/**
 * Count of generated-C substr needles for libc-heap / heap API on-demand.
 * @return i32 — 9 needles (malloc family + heap_*_c + getenv)
 * PLATFORM: SHARED — pure table authority under FREESTANDING_LIST hybrid.
 */
#[no_mangle]
export function labi_fs_heap_c_needle_count(): i32 {
  return 9;
}

/**
 * Needle at index for generated-C heap scan.
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_heap_c_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "malloc";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "calloc";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "realloc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "posix_memalign";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "heap_alloc_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "heap_free_c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "heap_realloc_c";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "heap_alloc_zeroed_c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "getenv";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of user .o undef symbols for libc-heap face.
 * @return i32 — 6 symbols (malloc family + free + getenv)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_heap_o_sym_count(): i32 {
  return 6;
}

/**
 * Undef symbol at index for user .o heap scan.
 * @param i i32 — index in [0, 6)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_heap_o_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "malloc";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "calloc";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "realloc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "free";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "posix_memalign";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "getenv";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of extra mem* symbols for freestanding nostdlib face (beyond heap).
 * @return i32 — 3 (memcpy, memcmp, memset)
 * PLATFORM: SHARED / LINUX freestanding face
 */
#[no_mangle]
export function labi_fs_memcpy_face_sym_count(): i32 {
  return 3;
}

/**
 * Extra mem* symbol at index for freestanding nostdlib face.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_memcpy_face_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "memcpy";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "memcmp";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "memset";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C needs libc heap / heap API (on-demand -lc or stubs).
 * Pure orch: scan fixed needle table via Cap residual contains_substr (file IO).
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave117): hybrid still had needs_libc_heap body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_needs_libc_heap(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_heap_c_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_heap_c_needle_at(i);
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr(c_path, needle);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Whether user .o still needs libc heap symbols (UNDEF probe).
 * Pure orch: fixed undef-symbol table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_libc_heap(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_heap_o_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_fs_heap_o_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Whether freestanding nostdlib face is required (heap + memcpy/memcmp/memset UNDEF).
 * Pure orch: reuse pure needs_libc_heap + mem* table; Cap residual undef only.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if zero-libc face needed, else 0
 * PLATFORM: LINUX freestanding face (table SHARED; ensure path still mega)
 */
#[no_mangle]
export function link_abi_user_o_needs_freestanding_nostdlib_face(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  if (link_abi_user_o_needs_libc_heap(user_o) != 0) {
    return 1;
  }
  let n: i32 = labi_fs_memcpy_face_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_fs_memcpy_face_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/* wave136: generated-C string needs pure tables + orch (C-path PRIMARY OS/fs).
 * Cap residual: link_abi_generated_c_contains_substr (file IO stays mega).
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X. */

/**
 * Count of generated-C substr needles for std.fs C-path on-demand.
 * @return i32 — 5 needles (fs_open_read_c / last_error / close / read / write)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_fs_needle_count(): i32 {
  return 5;
}

/**
 * Needle at index for generated-C std.fs scan.
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_fs_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "fs_open_read_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "fs_last_error_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "fs_close_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "fs_read_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "fs_write_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for std.random C-path on-demand.
 * @return i32 — 3 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_random_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for generated-C std.random scan.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_random_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "random_rng_smoke_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "random_fill_bytes_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "random_u64_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for std.time C-path on-demand.
 * @return i32 — 10 needles (std_time_* API + time_*_c OS face)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_time_needle_count(): i32 {
  return 10;
}

/**
 * Needle at index for generated-C std.time scan.
 * @param i i32 — index in [0, 10)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_time_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_time_now_monotonic_ns";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_time_sleep_ms";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_time_duration_ns";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_time_now_wall_ns";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_time_format_timezone_smoke";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "time_now_monotonic_ns_c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "time_sleep_ms_c";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "time_duration_ns_c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "time_now_wall_ns_c";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "time_format_timezone_smoke_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for std.runtime C-path on-demand.
 * @return i32 — 3 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_runtime_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for generated-C std.runtime scan.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_runtime_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "runtime_crash_evidence_collect_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "runtime_panic";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "runtime_abort";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C needs std.fs C symbols (C-path -lc / fs face).
 * Pure orch: scan fixed needle table via Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave136): hybrid still had needs_fs body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_needs_fs(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_fs_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_fs_needle_at(i);
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr(c_path, needle);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Whether generated C needs std.random C symbols.
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave136): hybrid still had needs_random body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_random(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_random_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_random_needle_at(i);
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr(c_path, needle);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Whether generated C needs std.time C symbols (time.o + runtime_time_os.o).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave136): hybrid still had needs_time body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_time(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_time_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_time_needle_at(i);
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr(c_path, needle);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Whether generated C needs std.runtime C symbols (runtime.o).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave136): hybrid still had needs_runtime body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_runtime(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_runtime_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_runtime_needle_at(i);
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr(c_path, needle);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}
