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
//   wave137 link_abi_generated_c_needs_{zlib,zstd,brotli} pure orch
//     (C-path compress lib string needles; Cap residual contains_substr).
//   wave138 link_abi_generated_c_needs_{core_slice,db_kv,db_arrow} pure orch
//     (C-path core.slice / std.db.kv / std.db.arrow on-demand .o needles).
//   wave139 link_abi_generated_c_provides_{core_mem,std_heap} pure orch
//     (C-path co-emit strong-def markers; skip hard-link mem.o/heap.o).
//   wave141 link_abi_generated_c_needs_{win32,win32_wsa} pure orch
//     (C-path Windows kernel32 / winsock2 string needles; Cap residual contains_substr).
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

/* wave137: generated-C compress lib string needs pure tables + orch.
 * Cap residual: link_abi_generated_c_contains_substr (file IO stays mega).
 * Product: on-demand -lz / -lzstd / -lbrotli* when generated C references these APIs.
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X. */

/**
 * Count of generated-C substr needles for libz C-path on-demand (-lz).
 * @return i32 — 7 needles (Mach-O-ish _compress2/_deflate… + bare compress2/deflateInit/inflateInit)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_zlib_needle_count(): i32 {
  return 7;
}

/**
 * Needle at index for generated-C libz scan.
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_zlib_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "_compress2";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "_deflate";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "_inflate";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "_uncompress";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "compress2";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "deflateInit";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "inflateInit";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for libzstd C-path on-demand (-lzstd).
 * @return i32 — 5 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_zstd_needle_count(): i32 {
  return 5;
}

/**
 * Needle at index for generated-C libzstd scan.
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_zstd_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "ZSTD_compress";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "ZSTD_decompress";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "ZSTD_create";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "ZSTD_free";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "ZSTD_isError";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for libbrotli C-path on-demand (-lbrotli*).
 * @return i32 — 2 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_brotli_needle_count(): i32 {
  return 2;
}

/**
 * Needle at index for generated-C libbrotli scan.
 * @param i i32 — index in [0, 2)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_brotli_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "BrotliEncoder";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "BrotliDecoder";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C needs libz (-lz).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave137): hybrid still had needs_zlib body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_zlib(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_zlib_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_zlib_needle_at(i);
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
 * Whether generated C needs libzstd (-lzstd).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave137): hybrid still had needs_zstd body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_zstd(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_zstd_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_zstd_needle_at(i);
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
 * Whether generated C needs libbrotli (-lbrotli*).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave137): hybrid still had needs_brotli body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_brotli(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_brotli_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_brotli_needle_at(i);
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

/* wave138: generated-C core.slice / std.db.kv / std.db.arrow string needs pure tables + orch.
 * Cap residual: link_abi_generated_c_contains_substr (file IO stays mega).
 * Product: on-demand core/db .o when generated C references these APIs (G-01 pure .x no slice.o;
 *   db.kv / db.arrow still on-demand link std/db/{kv,arrow}/*.o).
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X. */

/**
 * Count of generated-C substr needles for core.slice C-path scan (G-01 no slice.o chain).
 * @return i32 — 6 needles (i32/u8/u64 from_ptr + subslice)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_core_slice_needle_count(): i32 {
  return 6;
}

/**
 * Needle at index for generated-C core.slice scan.
 * @param i i32 — index in [0, 6)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_core_slice_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core_slice_i32_from_ptr_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core_subslice_i32_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core_slice_u8_from_ptr_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core_subslice_u8_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "core_slice_u64_from_ptr_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "core_subslice_u64_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for std.db.kv C-path on-demand (kv.o).
 * @return i32 — 7 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_db_kv_needle_count(): i32 {
  return 7;
}

/**
 * Needle at index for generated-C std.db.kv scan.
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_db_kv_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "db_kv_open_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "db_kv_put_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "db_kv_get_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "db_kv_append_ts_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "db_kv_wal_flush_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "db_kv_compact_c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "db_kv_sst_level_count_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for std.db.arrow C-path on-demand (arrow.o).
 * @return i32 — 3 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_db_arrow_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for generated-C std.db.arrow scan.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_db_arrow_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "arrow_column_";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "arrow_batch_";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "arrow_smoke_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C references core.slice C helpers (scan only; G-01 no slice.o).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave138): hybrid still had needs_core_slice body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_core_slice(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_core_slice_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_core_slice_needle_at(i);
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
 * Whether generated C needs std.db.kv (.o on-demand).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave138): hybrid still had needs_db_kv body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_db_kv(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_db_kv_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_db_kv_needle_at(i);
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
 * Whether generated C needs std.db.arrow (.o on-demand).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave138): hybrid still had needs_db_arrow body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_db_arrow(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_db_arrow_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_db_arrow_needle_at(i);
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
 * Count of generated-C substr needles for co-emit core.mem strong definitions.
 * Used to skip hard-linking core/mem/mem.o when the user TU already defines mem.
 * @return i32 — 3 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_provides_core_mem_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for co-emit core.mem definition scan.
 * Invariant: match definition lines (body brace / typed prototype), not bare extern.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_provides_core_mem_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "void core_mem_mem_copy(";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "int32_t core_mem_placeholder(void) {";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "int32_t core_mem_align_of_i32(void) {";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for co-emit std.heap strong definitions.
 * Used to skip hard-linking heap.o when the user TU already defines libc heap API.
 * @return i32 — 3 needles
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_provides_std_heap_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for co-emit std.heap definition scan.
 * Invariant: definition lines carry body brace; extern lines prefix "extern " and miss.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_provides_std_heap_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "uint8_t * std_heap_libc_heap_alloc_c(size_t size) {";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "void std_heap_libc_heap_free_c(uint8_t * ptr) {";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_libc_heap_alloc_c(size_t size) {";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C already co-emits core.mem strong definitions.
 * Pure orch: fixed definition-line needles; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any definition needle hits, else 0
 * Why (wave139): hybrid still had provides_core_mem body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_provides_core_mem(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_provides_core_mem_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_provides_core_mem_needle_at(i);
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
 * Whether generated C already co-emits std.heap strong definitions.
 * Pure orch: fixed definition-line needles; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any definition needle hits, else 0
 * Why (wave139): hybrid still had provides_std_heap body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_provides_std_heap(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_provides_std_heap_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_provides_std_heap_needle_at(i);
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

/* wave141: generated-C Windows kernel32 / winsock2 string needs pure tables + orch.
 * Cap residual: link_abi_generated_c_contains_substr (file IO stays mega).
 * Product: on-demand win32 stubs / -lws2_32 when generated C references these APIs.
 * PLATFORM: SHARED tables — WINDOWS link surface (needles); hybrid L7 pure; mega cold twin. */

/**
 * Count of generated-C substr needles for Win32 kernel32 / shux win32 helpers.
 * @return i32 — 9 needles (GetStdHandle… + win32_* helpers)
 * PLATFORM: SHARED (table) / WINDOWS (link consumers)
 */
#[no_mangle]
export function labi_fs_gen_win32_needle_count(): i32 {
  return 9;
}

/**
 * Needle at index for generated-C Win32 scan.
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_win32_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "GetStdHandle";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "WriteFile";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "CreateFileA";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "ReadFile";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "CloseHandle";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "ExitProcess";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "win32_write";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "win32_read_file_into";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "win32_exit_process";
    return p;
  }
  return 0 as *u8;
}

/**
 * Count of generated-C substr needles for Win32 WSA / winsock2.
 * @return i32 — 3 needles
 * PLATFORM: SHARED (table) / WINDOWS (link -lws2_32)
 */
#[no_mangle]
export function labi_fs_gen_win32_wsa_needle_count(): i32 {
  return 3;
}

/**
 * Needle at index for generated-C Win32 WSA scan.
 * @param i i32 — index in [0, 3)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_win32_wsa_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "WSAStartup";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "WSACleanup";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "win32_net_available";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C needs Win32 kernel32 / shux win32 helpers.
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave141): hybrid still had needs_win32 body always mega C with hard-coded strings.
 * PLATFORM: SHARED orch / WINDOWS consumers
 */
#[no_mangle]
export function link_abi_generated_c_needs_win32(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_win32_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_win32_needle_at(i);
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
 * Whether generated C needs Winsock2 (-lws2_32).
 * Pure orch: fixed needle table; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave141): hybrid still had needs_win32_wsa body always mega C with hard-coded strings.
 * PLATFORM: SHARED orch / WINDOWS consumers
 */
#[no_mangle]
export function link_abi_generated_c_needs_win32_wsa(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_win32_wsa_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_win32_wsa_needle_at(i);
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
