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
//   wave142 link_abi_generated_c_needs_{core_builtin,core_mem} pure stub0 orch
//     (G-01: always 0 — no hard-link builtin.o / mem.o; was mega-only stub0 body).
//   wave143 shux_generated_c_needs_async_scheduler pure orch
//     (C-path async scheduler string needles ×9; Cap residual contains_substr).
//   wave144 shux_freestanding_user_o_needs_{io,panic} pure orch
//     (user.o UNDEF scan via labi_fs_io_sym_* / labi_fs_panic_sym; Cap residual undef_sym).
//   wave159 shux_link_freestanding_enabled pure orch
//     (peer host_is_linux + pure env name + Cap residual getenv).
//   wave167 shux_ensure_crt0_user_o pure orch
//     (peer freestanding_enabled + path tables + Cap residual resolve/access/cc/stat).
//   wave168 shux_ensure_freestanding_io_o pure orch
//     (peer freestanding_enabled + io path tables + Cap residual resolve/access/cc/stat).
//   wave175 link_abi_generated_c_contains_substr pure orch
//     (pure null gates + Cap residual file malloc/free + Cap residual buf scan).
// Cap residual: undef_sym; getenv; resolve/access/cc/stat for ensure leaves (wave167/168);
//   runtime_read_file_malloc / free / link_abi_buf_contains_substr (wave175).
// PLATFORM: SHARED tables / LINUX freestanding face for nostdlib orch.

// Cap residual (wave159): host getenv for SHUX_FREESTANDING env gate.
export extern "C" function getenv(name: *u8): *u8;
// Cap residual (wave175 contains_substr pure orch): host whole-file malloc + free + buf scan.
// Nested pure byte-scan loops over large files historically truncated later export bodies
// in this module (codegen); keep scan Cap residual, pure owns gates/orch.
export extern "C" function runtime_read_file_malloc(path: *u8, out_len: *usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function link_abi_buf_contains_substr(data: *u8, data_len: usize, needle: *u8): i32;
// Peer pure (labi_host_lit L thin → Cap residual _impl #if __linux__).
export extern "C" function shux_host_is_linux(): i32;
// Cap residual (wave167/168 ensure pure orch): resolve / access / cc / skip-stat.
export extern "C" function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
export extern "C" function link_abi_path_readable(path: *u8): i32;
export extern "C" function shux_cc_compile_sync(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32;
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
// Peer pure path ladder (labi_path_pure L0; wave164/165).
export extern "C" function shux_crt0_user_o_path(argv0: *u8): *u8;
export extern "C" function shux_freestanding_io_o_path(argv0: *u8): *u8;
// Peer pure diags (labi_diag_pure L1).
export extern "C" function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void;
export extern "C" function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void;
export extern "C" function link_diag_runtime_obj_build_status(obj_name: *u8, status: i32): void;
export extern "C" function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void;

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

/* Cap residual: object UNDEF probe stays mega (nm/popen). */
export extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff generated C at c_path contains needle as a raw byte substring.
 * Pure orch: null/empty gates + Cap residual file load + Cap residual buf scan + free.
 * Cap residual: runtime_read_file_malloc / free / link_abi_buf_contains_substr.
 * @param c_path *u8 — NUL-terminated path to generated .c; null/empty → 0
 * @param needle *u8 — NUL-terminated needle; null/empty → 0 (≡ mega single-needle wrap)
 * @return i32 — 1 if needle occurs anywhere in file bytes, else 0
 * Why (wave175): hybrid still had contains_substr body always mega C (any_substr + file view).
 * Not the same as link_abi_generated_c_contains_substr_use_line (line filter Cap residual).
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_contains_substr(c_path: *u8, needle: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  if (needle == 0 as *u8) {
    return 0;
  }
  if (needle[0] == 0) {
    return 0;
  }
  let raw_len: usize = 0 as usize;
  let data: *u8 = 0 as *u8;
  unsafe {
    data = runtime_read_file_malloc(c_path, &raw_len);
  }
  if (data == 0 as *u8) {
    return 0;
  }
  let hit: i32 = 0;
  unsafe {
    hit = link_abi_buf_contains_substr(data, raw_len, needle);
  }
  unsafe {
    free(data);
  }
  return hit;
}

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
 * PLATFORM: LINUX freestanding face (table SHARED; ensure_crt0 pure wave167; io ensure still mega)
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

/* wave142: generated-C core.builtin / core.mem needs pure stub0 orch.
 * G-01 product: bitops are __builtin_* inline; mem is pure .x — never hard-link
 * core/builtin/builtin.o or core/mem/mem.o from C-path scan.
 * No needle tables (always 0). Closes soft residual «hybrid still always mega stub0».
 * PLATFORM: SHARED — call-site ABI kept; body pure under L7. */

/**
 * Whether generated C needs core.builtin.o (G-01: always 0).
 * Bitops emit as host __builtin_*; no hard-link of core/builtin/builtin.o.
 * @param c_path *u8 — unused; kept for call-site ABI (generated_c needs_* family)
 * @return i32 — always 0
 * Why (wave142): hybrid still had needs_core_builtin body always mega C stub0.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_core_builtin(c_path: *u8): i32 {
  return 0;
}

/**
 * Whether generated C needs core/mem.o (G-01: always 0).
 * core.mem is pure .x on product path; no hard-link of core/mem/mem.o from C scan.
 * @param c_path *u8 — unused; kept for call-site ABI (generated_c needs_* family)
 * @return i32 — always 0
 * Why (wave142): hybrid still had needs_core_mem body always mega C stub0.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function link_abi_generated_c_needs_core_mem(c_path: *u8): i32 {
  return 0;
}

/* wave143: generated-C std.async scheduler string needs pure table + orch.
 * Product: C frontend invoke_cc on-demand links async_scheduler.o when generated
 * C references scheduler entry points (run_i32 / cps_suspend / task_submit / …).
 * Cap residual: link_abi_generated_c_contains_substr (file IO stays mega).
 * Distinct from wave130 user.o UNDEF table (link_abi_user_o_needs_async_scheduler).
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin. */

/**
 * Count of generated-C substr needles for std.async scheduler on-demand link.
 * @return i32 — 9 needles (run_i32 … bind_context_c)
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_async_scheduler_needle_count(): i32 {
  return 9;
}

/**
 * Needle at index for generated-C async scheduler scan.
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_fs_gen_async_scheduler_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "shux_async_run_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "shux_async_cps_suspend";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "shux_async_task_submit";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "shux_async_run_seed_";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "shux_async_coop_pingpong_jmp";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "shux_async_coop_pingpong";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "shux_async_run_drain_until_idle";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "shux_async_queue_reset";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "shux_async_bind_context_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether generated C needs async_scheduler.o (C frontend on-demand link).
 * Pure orch: fixed needle table ×9; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave143): hybrid still had needs_async_scheduler body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function shux_generated_c_needs_async_scheduler(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_async_scheduler_needle_count();
  let i: i32 = 0;
  while (i < n) {
    let needle: *u8 = labi_fs_gen_async_scheduler_needle_at(i);
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

/* wave144: freestanding user.o needs_io / needs_panic pure orch.
 * Product: freestanding link path pushes freestanding_io.o / panic.o when user.o
 * still UNDEFs shux_sys_* or shux_panic_. Tables already pure (labi_fs_io_sym_* /
 * labi_fs_panic_sym); this wave moves the orch bodies out of always-mega C.
 * Cap residual: shux_link_obj_needs_undef_sym (nm/pipe stays mega).
 * PLATFORM: SHARED orch / LINUX freestanding consumers. */

/**
 * Whether freestanding user .o needs freestanding_io.o (UNDEF shux_sys_*).
 * Pure orch: fixed UNDEF table ×13 via labi_fs_io_sym_*; Cap residual undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any io-face UNDEF hits, else 0
 * Why (wave144): hybrid still had needs_io body always mega C over pure table.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function shux_freestanding_user_o_needs_io(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_io_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_fs_io_sym_at(i);
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
 * Whether freestanding user .o needs panic runtime (UNDEF shux_panic_).
 * Pure orch: single panic needle via labi_fs_panic_sym; Cap residual undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if panic UNDEF hits, else 0
 * Why (wave144): hybrid still had needs_panic body always mega C over pure table.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function shux_freestanding_user_o_needs_panic(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let s: *u8 = labi_fs_panic_sym();
  if (s == 0 as *u8) {
    return 0;
  }
  if (s[0] == 0) {
    return 0;
  }
  let hit: i32 = 0;
  unsafe {
    hit = shux_link_obj_needs_undef_sym(user_o, s);
  }
  if (hit != 0) {
    return 1;
  }
  return 0;
}

/**
 * Whether freestanding (nostdlib Linux ELF) link mode is active for this driver.
 * Pure orch: peer shux_host_is_linux + pure labi_fs_env_freestanding name + Cap residual getenv.
 * Rules (≡ historical mega): non-Linux → 0; driver_freestanding != 0 → 1; else read
 * SHUX_FREESTANDING env — null / empty / leading '0' → 0; any other non-empty → 1.
 * @param driver_freestanding i32 — CLI/driver freestanding flag (0 = off, nonzero = force on)
 * @return i32 — 1 if freestanding path should run, else 0
 * Why (wave159): hybrid still had freestanding_enabled body always mega C over pure env name.
 * Cap residual: getenv only. PLATFORM: SHARED orch / LINUX freestanding consumers.
 */
#[no_mangle]
export function shux_link_freestanding_enabled(driver_freestanding: i32): i32 {
  // Non-Linux hosts never take freestanding product path (peer host_lit pure → _impl Cap).
  let is_linux: i32 = 0;
  unsafe {
    is_linux = shux_host_is_linux();
  }
  if (is_linux == 0) {
    return 0;
  }
  // Driver flag forces freestanding when already on Linux.
  if (driver_freestanding != 0) {
    return 1;
  }
  // Cap residual: read SHUX_FREESTANDING via pure env name table.
  let name: *u8 = labi_fs_env_freestanding();
  let e: *u8 = 0 as *u8;
  unsafe {
    e = getenv(name);
  }
  if (e == 0 as *u8) {
    return 0;
  }
  if (e[0] == 0) {
    return 0;
  }
  // Leading ASCII '0' (48) disables freestanding; any other first byte enables.
  if (e[0] == 48) {
    return 0;
  }
  return 1;
}

/**
 * Ensure freestanding crt0_user.o exists next to the product host (compile from asm if missing).
 * Only runs when freestanding link mode is active; otherwise no-op success (return 0).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @param driver_freestanding i32 — CLI/driver freestanding flag (passed to freestanding_enabled)
 * @return i32 — 0 success / no-op; -1 on resolve/source/cc/missing failure (diag already written)
 * Pure orch: peer freestanding_enabled + pure table out_base/src_rel/stem + pure byte join
 *   (no snprintf Cap) after Cap residual resolve; Cap residual path_readable + cc_compile_sync
 *   + skip_missing (stat) + path pure crt0 ladder + peer diags.
 * Cap residual: shu_resolve_compiler_dir (PLATFORM #if body); link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat).
 * Why (wave167): hybrid still had always-mega C body for freestanding crt0 ensure path ladder
 *   (tables already pure; only orch+join stayed mega over access/cc Cap).
 * Sibling wave168: shux_ensure_freestanding_io_o pure (same Cap residual set; io tables/path).
 * PLATFORM: SHARED orch / LINUX freestanding consumers — hybrid L7 pure; mega cold twin under
 *   #ifndef FREESTANDING_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_crt0_user_o(argv0: *u8, driver_freestanding: i32): i32 {
  // Pure tables for out leaf / asm source rel / stem (diag).
  let out_base: *u8 = labi_fs_crt0_out_base();
  let src_rel: *u8 = labi_fs_crt0_src_rel();
  let stem: *u8 = labi_fs_ensure_stem(0);
  // Peer pure freestanding gate (wave159): no-op when freestanding inactive.
  if (shux_link_freestanding_enabled(driver_freestanding) == 0) {
    return 0;
  }
  // Cap residual: skip if product path already has crt0_user.o (stat via path pure peer).
  let o_path: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_crt0_user_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have != 0 as *u8) {
    return 0;
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc != 0) {
    // Match mega: diag with out_base (fallback leaf name if table null).
    let name: *u8 = out_base;
    if (name == 0 as *u8) {
      name = "crt0_user.o";
    }
    unsafe {
      link_diag_runtime_obj_resolve_fail(name, 0 as *u8);
    }
    return -1;
  }
  // Fallback leaf names ≡ mega ternary defaults.
  let leaf_o: *u8 = out_base;
  if (leaf_o == 0 as *u8) {
    leaf_o = "crt0_user.o";
  }
  let leaf_s: *u8 = src_rel;
  if (leaf_s == 0 as *u8) {
    leaf_s = "src/asm/crt0_user_x86_64.s";
  }
  // Pure strlen(comp) once for both joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + leaf_o + NUL (no snprintf Cap).
  let ln_o: i32 = 0;
  while (leaf_o[ln_o] != 0) {
    ln_o = ln_o + 1;
  }
  // snprintf overflow → silent -1 (≡ mega size_t >= sizeof).
  if (dn + 1 + ln_o >= 4096) {
    return -1;
  }
  let out_o: u8[4096] = [];
  let i: i32 = 0;
  while (i < dn) {
    out_o[i] = comp[i];
    i = i + 1;
  }
  out_o[dn] = 47;
  let k: i32 = 0;
  while (k <= ln_o) {
    out_o[dn + 1 + k] = leaf_o[k];
    k = k + 1;
  }
  // Pure join src_s = comp + '/' + leaf_s + NUL.
  let ln_s: i32 = 0;
  while (leaf_s[ln_s] != 0) {
    ln_s = ln_s + 1;
  }
  if (dn + 1 + ln_s >= 4096) {
    return -1;
  }
  let src_s: u8[4096] = [];
  i = 0;
  while (i < dn) {
    src_s[i] = comp[i];
    i = i + 1;
  }
  src_s[dn] = 47;
  k = 0;
  while (k <= ln_s) {
    src_s[dn + 1 + k] = leaf_s[k];
    k = k + 1;
  }
  // Cap residual: access(src, R_OK) via path_readable (wave151 Cap).
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_s[0]);
  }
  if (readable == 0) {
    let st: *u8 = stem;
    if (st == 0 as *u8) {
      st = "crt0_user";
    }
    unsafe {
      link_diag_runtime_source_missing(st, &src_s[0]);
    }
    return -1;
  }
  // Cap residual: cc -c asm source → out_o (from_asm_s=1; no -I paths for .s).
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync(&src_s[0], &out_o[0], 0 as *u8, 0 as *u8, 0 as *u8, 1);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status(leaf_o, crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    o_path = shux_crt0_user_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing(leaf_o, &out_o[0]);
    }
    return -1;
  }
  return 0;
}

/**
 * Ensure freestanding freestanding_io.o exists next to the product host (compile from asm if missing).
 * Only runs when freestanding link mode is active; otherwise no-op success (return 0).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @param driver_freestanding i32 — CLI/driver freestanding flag (passed to freestanding_enabled)
 * @return i32 — 0 success / no-op; -1 on resolve/source/cc/missing failure (diag already written)
 * Pure orch: peer freestanding_enabled + pure table out_base/src_rel/stem(1) + pure byte join
 *   (no snprintf Cap) after Cap residual resolve; Cap residual path_readable + cc_compile_sync
 *   + skip_missing (stat) + path pure freestanding_io ladder + peer diags.
 * Cap residual: shu_resolve_compiler_dir (PLATFORM #if body); link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat).
 * Why (wave168): hybrid still had always-mega C body for freestanding_io ensure path ladder
 *   (tables already pure wave276; o_path pure wave165; only orch+join stayed mega over access/cc Cap).
 * Peer wave167: shux_ensure_crt0_user_o (same Cap residual set; crt0 tables/path).
 * PLATFORM: SHARED orch / LINUX freestanding consumers — hybrid L7 pure; mega cold twin under
 *   #ifndef FREESTANDING_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_freestanding_io_o(argv0: *u8, driver_freestanding: i32): i32 {
  // Pure tables for out leaf / asm source rel / stem (diag); stem index 1 = freestanding_io.
  let out_base: *u8 = labi_fs_io_out_base();
  let src_rel: *u8 = labi_fs_io_src_rel();
  let stem: *u8 = labi_fs_ensure_stem(1);
  // Peer pure freestanding gate (wave159): no-op when freestanding inactive.
  if (shux_link_freestanding_enabled(driver_freestanding) == 0) {
    return 0;
  }
  // Cap residual: skip if product path already has freestanding_io.o (stat via path pure peer).
  let o_path: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_freestanding_io_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have != 0 as *u8) {
    return 0;
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc != 0) {
    // Match mega: diag with out_base (fallback leaf name if table null).
    let name: *u8 = out_base;
    if (name == 0 as *u8) {
      name = "freestanding_io.o";
    }
    unsafe {
      link_diag_runtime_obj_resolve_fail(name, 0 as *u8);
    }
    return -1;
  }
  // Fallback leaf names ≡ mega ternary defaults.
  let leaf_o: *u8 = out_base;
  if (leaf_o == 0 as *u8) {
    leaf_o = "freestanding_io.o";
  }
  let leaf_s: *u8 = src_rel;
  if (leaf_s == 0 as *u8) {
    leaf_s = "src/asm/freestanding_io_x86_64.s";
  }
  // Pure strlen(comp) once for both joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + leaf_o + NUL (no snprintf Cap).
  let ln_o: i32 = 0;
  while (leaf_o[ln_o] != 0) {
    ln_o = ln_o + 1;
  }
  // snprintf overflow → silent -1 (≡ mega size_t >= sizeof).
  if (dn + 1 + ln_o >= 4096) {
    return -1;
  }
  let out_o: u8[4096] = [];
  let i: i32 = 0;
  while (i < dn) {
    out_o[i] = comp[i];
    i = i + 1;
  }
  out_o[dn] = 47;
  let k: i32 = 0;
  while (k <= ln_o) {
    out_o[dn + 1 + k] = leaf_o[k];
    k = k + 1;
  }
  // Pure join src_s = comp + '/' + leaf_s + NUL.
  let ln_s: i32 = 0;
  while (leaf_s[ln_s] != 0) {
    ln_s = ln_s + 1;
  }
  if (dn + 1 + ln_s >= 4096) {
    return -1;
  }
  let src_s: u8[4096] = [];
  i = 0;
  while (i < dn) {
    src_s[i] = comp[i];
    i = i + 1;
  }
  src_s[dn] = 47;
  k = 0;
  while (k <= ln_s) {
    src_s[dn + 1 + k] = leaf_s[k];
    k = k + 1;
  }
  // Cap residual: access(src, R_OK) via path_readable (wave151 Cap).
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_s[0]);
  }
  if (readable == 0) {
    let st: *u8 = stem;
    if (st == 0 as *u8) {
      st = "freestanding_io";
    }
    unsafe {
      link_diag_runtime_source_missing(st, &src_s[0]);
    }
    return -1;
  }
  // Cap residual: cc -c asm source → out_o (from_asm_s=1; no -I paths for .s).
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync(&src_s[0], &out_o[0], 0 as *u8, 0 as *u8, 0 as *u8, 1);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status(leaf_o, crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    o_path = shux_freestanding_io_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing(leaf_o, &out_o[0]);
    }
    return -1;
  }
  return 0;
}
