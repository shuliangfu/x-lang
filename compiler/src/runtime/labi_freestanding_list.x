// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-276 / P2 link_abi L7 freestanding pure table + wave117 needs pure orch.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_freestanding_list.from_x.c.
// Hybrid macro XLANG_LABI_FREESTANDING_LIST_FROM_X (FROM_X rest business H=0, marker only).
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
//   wave143 xlang_generated_c_needs_async_scheduler pure orch
//     (C-path async scheduler string needles ×9; Cap residual contains_substr).
//   wave144 xlang_freestanding_user_o_needs_{io,panic} pure orch
//     (user.o UNDEF scan via labi_fs_io_sym_* / labi_fs_panic_sym; Cap residual undef_sym).
//   wave159 xlang_link_freestanding_enabled pure orch
//     (peer host_is_linux + pure env name + Cap residual getenv).
//   wave167 xlang_ensure_crt0_user_o pure orch
//     (peer freestanding_enabled + path tables + Cap residual resolve/access/cc/stat).
//   wave168 xlang_ensure_freestanding_io_o pure orch
//     (peer freestanding_enabled + io path tables + Cap residual resolve/access/cc/stat).
//   wave175 link_abi_generated_c_contains_substr pure orch
//     (pure null gates + Cap residual file malloc/free + Cap residual buf scan).
//   wave176 link_abi_generated_c_contains_substr_use_line pure orch
//     (pure null gates + Cap residual file malloc/free + Cap residual buf use_line scan).
//   wave177 link_abi_generated_c_contains_any_substr_use_line pure orch
//     (pure thin loop over needles[i] → pure contains_substr_use_line).
//   wave178 link_abi_generated_c_contains_any_substr pure orch
//     (pure thin loop over needles[i] → pure contains_substr; raw multi-needle).
// Cap residual: undef_sym; link_abi_getenv (wave223 G.7; not raw getenv); resolve/access/cc/stat
//   for ensure leaves (wave167/168); runtime_read_file_malloc / free /
//   link_abi_buf_contains_substr (wave175); link_abi_buf_contains_substr_use_line (wave176).
// PLATFORM: SHARED tables / LINUX freestanding face for nostdlib orch.

// wave223 G.7: env lookup authority = public pure thin link_abi_getenv (labi_diag_pure L1).
// Cap residual host getenv stays mega as link_abi_getenv_impl (XLANG_FREESTANDING gate).
export extern "C" function link_abi_getenv(name: *u8): *u8;
// Cap residual (wave175/176 contains_substr pure orch): host whole-file malloc + free + buf scan.
// Nested pure byte-scan / line-filter loops over large files historically truncated later
// export bodies in this module (codegen); keep scan Cap residual, pure owns gates/orch.
export extern "C" function runtime_read_file_malloc(path: *u8, out_len: *usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function link_abi_buf_contains_substr(data: *u8, data_len: usize, needle: *u8): i32;
export extern "C" function link_abi_buf_contains_substr_use_line(data: *u8, data_len: usize, needle: *u8): i32;
// Peer pure (labi_host_lit L thin → Cap residual _impl #if __linux__).
export extern "C" function xlang_host_is_linux(): i32;
// Cap residual (wave167/168 ensure pure orch): resolve / access / cc / skip-stat.
export extern "C" function xlang_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
export extern "C" function link_abi_path_readable(path: *u8): i32;
export extern "C" function xlang_cc_compile_sync(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32;
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
// Peer pure path ladder (labi_path_pure L0; wave164/165).
export extern "C" function xlang_crt0_user_o_path(argv0: *u8): *u8;
export extern "C" function xlang_freestanding_io_o_path(argv0: *u8): *u8;
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
  let p: *u8 = "XLANG_FREESTANDING";
  return p;
}

/** Exported function `labi_fs_io_sym_count`.
 * Implements `labi_fs_io_sym_count`.
 * @return i32
 */
#[no_mangle]
export function labi_fs_io_sym_count(): i32 {
  return 16;
}

/** Exported function `labi_fs_io_sym_at`.
 * Implements `labi_fs_io_sym_at`.
 * @param i i32
 * @return *u8
 */
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_io_sym_at(i: i32): *u8;


/** Exported function `labi_fs_panic_sym`.
 * Implements `labi_fs_panic_sym`.
 * @return *u8
 */
#[no_mangle]
export function labi_fs_panic_sym(): *u8 {
  let p: *u8 = "xlang_panic_";
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
export extern "C" function xlang_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff generated C at c_path contains needle as a raw byte substring.
 * Pure orch: null/empty gates + Cap residual file load + Cap residual buf scan + free.
 * Cap residual: runtime_read_file_malloc / free / link_abi_buf_contains_substr.
 * @param c_path *u8 — NUL-terminated path to generated .c; null/empty → 0
 * @param needle *u8 — NUL-terminated needle; null/empty → 0 (≡ mega single-needle wrap)
 * @return i32 — 1 if needle occurs anywhere in file bytes, else 0
 * Why (wave175): hybrid still had contains_substr body always mega C (any_substr + file view).
 * Not the same as link_abi_generated_c_contains_substr_use_line (line-filter pure orch wave176).
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
 * Return 1 iff generated C at c_path contains needle on a real use line
 * (not bare extern / #define / comment / struct|typedef name / placeholder / weak attr).
 * Pure orch: null/empty gates + Cap residual file load + Cap residual line-filter scan + free.
 * Cap residual: runtime_read_file_malloc / free / link_abi_buf_contains_substr_use_line.
 * @param c_path *u8 — NUL-terminated path to generated .c; null/empty → 0
 * @param needle *u8 — NUL-terminated needle; null/empty → 0
 * @return i32 — 1 if a non-skipped line contains needle, else 0
 * Why (wave176): hybrid still had use_line body always mega C (file view + line filter).
 * Line-filter scan stays Cap residual (wave175 codegen lesson: pure deep while over large
 * buffers truncates later exports in this module). G.7 single authority orch.
 * PLATFORM: SHARED — hybrid L7 pure; mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_contains_substr_use_line(c_path: *u8, needle: *u8): i32 {
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
    hit = link_abi_buf_contains_substr_use_line(data, raw_len, needle);
  }
  unsafe {
    free(data);
  }
  return hit;
}

/**
 * Return 1 iff generated C at c_path contains any needle on a real use line.
 * Pure thin orch: null/empty gates + loop needles[i] via pure contains_substr_use_line.
 * Each hit reuses the single-needle pure authority (file load + Cap residual line filter).
 * @param c_path *u8 — NUL-terminated path to generated .c; null → 0
 * @param needles **u8 — C char** table of NUL needles; null → 0
 * @param n_needles i32 — table length; <=0 → 0
 * @return i32 — 1 if any nonempty needle hits a non-skipped use line, else 0
 * Why (wave177): hybrid still had any_substr_use_line body always mega C (thin loop
 * over pure use_line). Product callers: net_api / crypto_api on-demand scans.
 * Note: null-check needles via cast to *u8 (do not write needles == 0 as **u8).
 * G.7 single authority orch; no second use_line scan. PLATFORM: SHARED — hybrid L7 pure;
 * mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_contains_any_substr_use_line(
  c_path: *u8, needles: **u8, n_needles: i32
): i32 {
  // Guard c_path / needles null; empty path still fails inside pure use_line.
  if (c_path == 0 as *u8) {
    return 0;
  }
  if ((needles as *u8) == 0 as *u8) {
    return 0;
  }
  if (n_needles <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n_needles) {
    let needle: *u8 = needles[i];
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = link_abi_generated_c_contains_substr_use_line(c_path, needle);
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
 * Return 1 iff generated C at c_path contains any needle as raw bytes
 * (no line filter — whole-file memcmp via pure contains_substr).
 * Pure thin orch: null gates + loop needles[i] via pure contains_substr.
 * Each hit reuses the single-needle pure authority (file load + Cap residual buf scan).
 * @param c_path *u8 — NUL-terminated path to generated .c; null → 0
 * @param needles **u8 — C char** table of NUL needles; null → 0
 * @param n_needles i32 — table length; <=0 → 0
 * @return i32 — 1 if any nonempty needle hits the file view, else 0
 * Why (wave178): hybrid still had any_substr body always mega C (file-view multi-needle
 * memcmp). No product callers post-wave175 (on-demand uses use_line / single contains_substr);
 * migrate for G.7 residual closure + family symmetry with any_substr_use_line.
 * Empty needles skipped (0), aligned with pure contains_substr — not mega empty→1 quirk.
 * Note: null-check needles via cast to *u8 (do not write needles == 0 as **u8).
 * G.7 single authority orch; no second raw scan. PLATFORM: SHARED — hybrid L7 pure;
 * mega cold twin under #ifndef FREESTANDING_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_generated_c_contains_any_substr(
  c_path: *u8, needles: **u8, n_needles: i32
): i32 {
  // Guard c_path / needles null; empty path still fails inside pure contains_substr.
  if (c_path == 0 as *u8) {
    return 0;
  }
  if ((needles as *u8) == 0 as *u8) {
    return 0;
  }
  if (n_needles <= 0) {
    return 0;
  }
  let i: i32 = 0;
  while (i < n_needles) {
    let needle: *u8 = needles[i];
    if (needle != 0 as *u8) {
      if (needle[0] != 0) {
        let hit: i32 = link_abi_generated_c_contains_substr(c_path, needle);
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_heap_c_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_heap_o_sym_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_memcpy_face_sym_at(i: i32): *u8;


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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_heap_c_needle_at(i);
    }
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
 * Pure orch: fixed undef-symbol table; Cap residual xlang_link_obj_needs_undef_sym.
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let sym: *u8 = 0 as *u8;
    unsafe {
      sym = labi_fs_heap_o_sym_at(i);
    }
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = xlang_link_obj_needs_undef_sym(user_o, sym);
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let sym: *u8 = 0 as *u8;
    unsafe {
      sym = labi_fs_memcpy_face_sym_at(i);
    }
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = xlang_link_obj_needs_undef_sym(user_o, sym);
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_fs_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_random_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_time_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_runtime_needle_at(i: i32): *u8;


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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_fs_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_random_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_time_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_runtime_needle_at(i);
    }
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_zlib_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_zstd_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_brotli_needle_at(i: i32): *u8;


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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_zlib_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_zstd_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_brotli_needle_at(i);
    }
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_core_slice_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_db_kv_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_db_arrow_needle_at(i: i32): *u8;


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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_core_slice_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_db_kv_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_db_arrow_needle_at(i);
    }
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
 * Count of generated-C substr needles for Win32 kernel32 / xlang win32 helpers.
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_win32_needle_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_win32_wsa_needle_at(i: i32): *u8;


/**
 * Whether generated C needs Win32 kernel32 / xlang win32 helpers.
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_win32_needle_at(i);
    }
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
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_win32_wsa_needle_at(i);
    }
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_fs_gen_async_scheduler_needle_at(i: i32): *u8;


/**
 * Whether generated C needs async_scheduler.o (C frontend on-demand link).
 * Pure orch: fixed needle table ×9; Cap residual contains_substr.
 * @param c_path *u8 — path to generated .c; null/empty → 0
 * @return i32 — 1 if any needle hits, else 0
 * Why (wave143): hybrid still had needs_async_scheduler body always mega C with hard-coded strings.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_generated_c_needs_async_scheduler(c_path: *u8): i32 {
  if (c_path == 0 as *u8) {
    return 0;
  }
  if (c_path[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_gen_async_scheduler_needle_count();
  let i: i32 = 0;
  while (i < n) {
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let needle: *u8 = 0 as *u8;
    unsafe {
      needle = labi_fs_gen_async_scheduler_needle_at(i);
    }
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
 * still UNDEFs xlang_sys_* or xlang_panic_. Tables already pure (labi_fs_io_sym_* /
 * labi_fs_panic_sym); this wave moves the orch bodies out of always-mega C.
 * Cap residual: xlang_link_obj_needs_undef_sym (nm/pipe stays mega).
 * PLATFORM: SHARED orch / LINUX freestanding consumers. */

/**
 * Whether freestanding user .o needs freestanding_io.o (UNDEF xlang_sys_*).
 * Pure orch: fixed UNDEF table ×13 via labi_fs_io_sym_*; Cap residual undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any io-face UNDEF hits, else 0
 * Why (wave144): hybrid still had needs_io body always mega C over pure table.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_freestanding_user_o_needs_io(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_fs_io_sym_count();
  let i: i32 = 0;
  while (i < n) {
    // PLATFORM: SHARED — extern symbol-table FFI must run inside unsafe.
    let sym: *u8 = 0 as *u8;
    unsafe {
      sym = labi_fs_io_sym_at(i);
    }
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = xlang_link_obj_needs_undef_sym(user_o, sym);
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
 * Whether freestanding user .o needs panic runtime (UNDEF xlang_panic_).
 * Pure orch: single panic needle via labi_fs_panic_sym; Cap residual undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if panic UNDEF hits, else 0
 * Why (wave144): hybrid still had needs_panic body always mega C over pure table.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_freestanding_user_o_needs_panic(user_o: *u8): i32 {
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
    hit = xlang_link_obj_needs_undef_sym(user_o, s);
  }
  if (hit != 0) {
    return 1;
  }
  return 0;
}

/**
 * Whether freestanding (nostdlib Linux ELF) link mode is active for this driver.
 * Pure orch: peer xlang_host_is_linux + pure labi_fs_env_freestanding name + Cap residual getenv.
 * Rules (≡ historical mega): non-Linux → 0; driver_freestanding != 0 → 1; else read
 * XLANG_FREESTANDING env — null / empty / leading '0' → 0; any other non-empty → 1.
 * @param driver_freestanding i32 — CLI/driver freestanding flag (0 = off, nonzero = force on)
 * @return i32 — 1 if freestanding path should run, else 0
 * Why (wave159): hybrid still had freestanding_enabled body always mega C over pure env name.
 * Cap residual: link_abi_getenv (wave223 G.7; host getenv_impl mega). PLATFORM: SHARED orch / LINUX freestanding consumers.
 */
#[no_mangle]
export function xlang_link_freestanding_enabled(driver_freestanding: i32): i32 {
  // Non-Linux hosts never take freestanding product path (peer host_lit pure → _impl Cap).
  let is_linux: i32 = 0;
  unsafe {
    is_linux = xlang_host_is_linux();
  }
  if (is_linux == 0) {
    return 0;
  }
  // Driver flag forces freestanding when already on Linux.
  if (driver_freestanding != 0) {
    return 1;
  }
  // Cap residual: read XLANG_FREESTANDING via pure env name table.
  // wave223 G.7: public pure thin link_abi_getenv (not raw libc getenv).
  let name: *u8 = labi_fs_env_freestanding();
  let e: *u8 = 0 as *u8;
  unsafe {
    e = link_abi_getenv(name);
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
 * Cap residual: xlang_resolve_compiler_dir (PLATFORM #if body); link_abi_path_readable (access R_OK);
 *   xlang_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat).
 * Why (wave167): hybrid still had always-mega C body for freestanding crt0 ensure path ladder
 *   (tables already pure; only orch+join stayed mega over access/cc Cap).
 * Sibling wave168: xlang_ensure_freestanding_io_o pure (same Cap residual set; io tables/path).
 * PLATFORM: SHARED orch / LINUX freestanding consumers — hybrid L7 pure; mega cold twin under
 *   #ifndef FREESTANDING_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_ensure_crt0_user_o(argv0: *u8, driver_freestanding: i32): i32 {
  // Pure tables for out leaf / asm source rel / stem (diag).
  let out_base: *u8 = labi_fs_crt0_out_base();
  let src_rel: *u8 = labi_fs_crt0_src_rel();
  let stem: *u8 = labi_fs_ensure_stem(0);
  // Peer pure freestanding gate (wave159): no-op when freestanding inactive.
  if (xlang_link_freestanding_enabled(driver_freestanding) == 0) {
    return 0;
  }
  // Cap residual: skip if product path already has crt0_user.o (stat via path pure peer).
  let o_path: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    o_path = xlang_crt0_user_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have != 0 as *u8) {
    return 0;
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = xlang_resolve_compiler_dir(argv0, &comp[0], 4096);
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
    crc = xlang_cc_compile_sync(&src_s[0], &out_o[0], 0 as *u8, 0 as *u8, 0 as *u8, 1);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status(leaf_o, crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    o_path = xlang_crt0_user_o_path(argv0);
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
 * Cap residual: xlang_resolve_compiler_dir (PLATFORM #if body); link_abi_path_readable (access R_OK);
 *   xlang_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat).
 * Why (wave168): hybrid still had always-mega C body for freestanding_io ensure path ladder
 *   (tables already pure wave276; o_path pure wave165; only orch+join stayed mega over access/cc Cap).
 * Peer wave167: xlang_ensure_crt0_user_o (same Cap residual set; crt0 tables/path).
 * PLATFORM: SHARED orch / LINUX freestanding consumers — hybrid L7 pure; mega cold twin under
 *   #ifndef FREESTANDING_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function xlang_ensure_freestanding_io_o(argv0: *u8, driver_freestanding: i32): i32 {
  // Pure tables for out leaf / asm source rel / stem (diag); stem index 1 = freestanding_io.
  let out_base: *u8 = labi_fs_io_out_base();
  let src_rel: *u8 = labi_fs_io_src_rel();
  let stem: *u8 = labi_fs_ensure_stem(1);
  // Peer pure freestanding gate (wave159): no-op when freestanding inactive.
  if (xlang_link_freestanding_enabled(driver_freestanding) == 0) {
    return 0;
  }
  // Cap residual: skip if product path already has freestanding_io.o (stat via path pure peer).
  let o_path: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    o_path = xlang_freestanding_io_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have != 0 as *u8) {
    return 0;
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = xlang_resolve_compiler_dir(argv0, &comp[0], 4096);
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
    crc = xlang_cc_compile_sync(&src_s[0], &out_o[0], 0 as *u8, 0 as *u8, 0 as *u8, 1);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status(leaf_o, crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    o_path = xlang_freestanding_io_o_path(argv0);
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

// ---------------------------------------------------------------------------
// w1542 (7.1): Windows user-program link spawns bare MinGW `ld`, never `gcc`.
// The default user path must not execve a host C compiler (host-cc=0 goal;
// 8.3 zero-cc). gcc used to be the link driver only to supply crt objects,
// -L search dirs and the libgcc/mingw runtime -l tail. We now derive those
// from where ld.exe sits on PATH: root = <ld dir>/.., crt2.o under
// <root>/lib or <root>/<triple>/lib, crtbegin/crtend under
// <root>/lib/gcc/<triple>/<ver> (scanned; highest version wins). No gcc
// version or machine path is hard-coded. Missing pieces → BLD001 and the
// link fails; there is no fallback to gcc.
// Buffer contract: caller passes `bufs` holding labi_win_ld_slot_count()
// slots of `cap` bytes each (durable for the spawn; seed keeps it static).
// PLATFORM: WINDOWS | MINGW consumer (seed use_coff_o branch); pure bytes
// elsewhere (never called on Darwin/Linux).
// ---------------------------------------------------------------------------

export extern "C" function xlang_fmt_opendir(name: *u8): *u8;
export extern "C" function xlang_fmt_closedir(dirp: *u8): i32;
export extern "C" function xlang_fmt_readdir_name(dirp: *u8): *u8;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/**
 * Number of path slots labi_win_ld_prepare fills (caller sizes bufs = count * cap).
 * @return i32 — slot count (12)
 */
#[no_mangle]
export function labi_win_ld_slot_count(): i32 {
  return 12;
}

/**
 * Address of slot i inside the caller slot bank.
 * @param bufs *u8 — slot bank base
 * @param cap i32 — bytes per slot
 * @param i i32 — slot index
 * @return *u8 — slot start
 */
#[no_mangle]
export function labi_win_ld_slot(bufs: *u8, cap: i32, i: i32): *u8 {
  let off: i32 = i * cap;
  return &bufs[off as usize];
}

/**
 * Append src at dst[pos..]; keeps NUL. Returns new pos or -1 on overflow/null dst.
 * @param dst *u8 — destination buffer
 * @param cap i32 — capacity in bytes
 * @param pos i32 — write index
 * @param src *u8 — C string (null = empty)
 * @return i32 — new pos, or -1
 */
#[no_mangle]
export function labi_win_ld_cat(dst: *u8, cap: i32, pos: i32, src: *u8): i32 {
  if (dst == 0 as *u8) {
    return 0 - 1;
  }
  if (pos < 0) {
    return 0 - 1;
  }
  if (pos >= cap) {
    return 0 - 1;
  }
  let i: i32 = 0;
  if (src == 0 as *u8) {
    dst[pos as usize] = 0;
    return pos;
  }
  while (1 == 1) {
    let c: u8 = src[i as usize];
    if (c == 0) {
      break;
    }
    if (pos + 1 >= cap) {
      dst[pos as usize] = 0;
      return 0 - 1;
    }
    dst[pos as usize] = c;
    pos = pos + 1;
    i = i + 1;
  }
  dst[pos as usize] = 0;
  return pos;
}

/**
 * dst = a + b + c (any may be null). Returns 1 ok, 0 overflow.
 * @param dst *u8 — destination
 * @param cap i32 — capacity
 * @param a *u8 — first piece
 * @param b *u8 — second piece
 * @param c *u8 — third piece
 * @return i32 — 1 ok, 0 overflow
 */
#[no_mangle]
export function labi_win_ld_join3(dst: *u8, cap: i32, a: *u8, b: *u8, c: *u8): i32 {
  let p: i32 = 0;
  dst[0] = 0;
  p = labi_win_ld_cat(dst, cap, p, a);
  if (p < 0) {
    return 0;
  }
  p = labi_win_ld_cat(dst, cap, p, b);
  if (p < 0) {
    return 0;
  }
  p = labi_win_ld_cat(dst, cap, p, c);
  if (p < 0) {
    return 0;
  }
  return 1;
}

/**
 * Compare dotted version strings numerically ("16.2.0" > "9.5.0").
 * @param a *u8 — version a
 * @param b *u8 — version b
 * @return i32 — >0 when a newer, <0 when b newer, 0 equal
 */
#[no_mangle]
export function labi_win_ld_ver_cmp(a: *u8, b: *u8): i32 {
  let ia: i32 = 0;
  let ib: i32 = 0;
  let rounds: i32 = 0;
  while (rounds < 8) {
    let na: i32 = 0;
    let nb: i32 = 0;
    while (1 == 1) {
      let ca: u8 = a[ia as usize];
      if (ca < 48 || ca > 57) {
        break;
      }
      na = na * 10 + ((ca as i32) - 48);
      ia = ia + 1;
    }
    while (1 == 1) {
      let cb: u8 = b[ib as usize];
      if (cb < 48 || cb > 57) {
        break;
      }
      nb = nb * 10 + ((cb as i32) - 48);
      ib = ib + 1;
    }
    if (na != nb) {
      return na - nb;
    }
    let ea: u8 = a[ia as usize];
    let eb: u8 = b[ib as usize];
    if (ea != 46 || eb != 46) {
      return 0;
    }
    ia = ia + 1;
    ib = ib + 1;
    rounds = rounds + 1;
  }
  return 0;
}

/**
 * Find ld.exe on PATH (';' separated). On hit: ld_out = "<dir>/ld.exe",
 * root_out = "<dir>/..". Entries may end with '\' or '/'.
 * @param ld_out *u8 — full ld path out
 * @param root_out *u8 — toolchain root out
 * @param cap i32 — capacity of each out buffer
 * @return i32 — 1 found, 0 not found
 */
#[no_mangle]
export function labi_win_ld_find_on_path(ld_out: *u8, root_out: *u8, cap: i32): i32 {
  let path: *u8 = 0 as *u8;
  unsafe {
    path = link_abi_getenv("PATH");
  }
  if (path == 0 as *u8) {
    return 0;
  }
  let dir: u8[1024] = [];
  let i: i32 = 0;
  let guard: i32 = 0;
  while (guard < 65536) {
    guard = guard + 1;
    // Copy one entry into dir.
    let n: i32 = 0;
    while (1 == 1) {
      let c: u8 = path[i as usize];
      if (c == 0 || c == 59) {
        break;
      }
      if (n < 1000) {
        dir[n as usize] = c;
        n = n + 1;
      }
      i = i + 1;
    }
    // Trim a trailing separator.
    if (n > 0) {
      let last: u8 = dir[(n - 1) as usize];
      if (last == 92 || last == 47) {
        n = n - 1;
      }
    }
    dir[n as usize] = 0;
    if (n > 0) {
      if (labi_win_ld_join3(ld_out, cap, &dir[0], "/ld.exe", 0 as *u8) != 0) {
        let ok: i32 = 0;
        unsafe {
          ok = link_abi_path_readable(ld_out);
        }
        if (ok != 0) {
          if (labi_win_ld_join3(root_out, cap, &dir[0], "/..", 0 as *u8) != 0) {
            return 1;
          }
        }
      }
    }
    if (path[i as usize] == 0) {
      break;
    }
    i = i + 1;
  }
  ld_out[0] = 0;
  root_out[0] = 0;
  return 0;
}

/**
 * Scan <root>/lib/gcc/<triple>/<ver>/crtbegin.o; keep highest <ver>.
 * Writes gcc_dir_out = "<root>/lib/gcc/<triple>/<ver>" and triple_out.
 * @param root *u8 — toolchain root
 * @param gcc_dir_out *u8 — out
 * @param triple_out *u8 — out
 * @param cap i32 — capacity of each out and scratch
 * @param scratch *u8 — scratch buffer (cap bytes)
 * @return i32 — 1 found, 0 none
 */
#[no_mangle]
export function labi_win_ld_find_gcc_dir(root: *u8, gcc_dir_out: *u8, triple_out: *u8, cap: i32, scratch: *u8): i32 {
  let base: u8[1024] = [];
  let tdir: u8[1024] = [];
  let tname: u8[256] = [];
  let best_ver: u8[256] = [];
  let found: i32 = 0;
  gcc_dir_out[0] = 0;
  triple_out[0] = 0;
  best_ver[0] = 0;
  if (labi_win_ld_join3(&base[0], 1024, root, "/lib/gcc", 0 as *u8) == 0) {
    return 0;
  }
  let d1: *u8 = 0 as *u8;
  unsafe {
    d1 = xlang_fmt_opendir(&base[0]);
  }
  if (d1 == 0 as *u8) {
    return 0;
  }
  let g1: i32 = 0;
  while (g1 < 256) {
    g1 = g1 + 1;
    let n1: *u8 = 0 as *u8;
    unsafe {
      n1 = xlang_fmt_readdir_name(d1);
    }
    if (n1 == 0 as *u8) {
      break;
    }
    if (n1[0] == 46) {
      continue;
    }
    tname[0] = 0;
    if (labi_win_ld_cat(&tname[0], 256, 0, n1) < 0) {
      continue;
    }
    if (labi_win_ld_join3(&tdir[0], 1024, &base[0], "/", &tname[0]) == 0) {
      continue;
    }
    let d2: *u8 = 0 as *u8;
    unsafe {
      d2 = xlang_fmt_opendir(&tdir[0]);
    }
    if (d2 == 0 as *u8) {
      continue;
    }
    let g2: i32 = 0;
    while (g2 < 256) {
      g2 = g2 + 1;
      let n2: *u8 = 0 as *u8;
      unsafe {
        n2 = xlang_fmt_readdir_name(d2);
      }
      if (n2 == 0 as *u8) {
        break;
      }
      if (n2[0] < 48 || n2[0] > 57) {
        continue;
      }
      let p: i32 = 0;
      scratch[0] = 0;
      p = labi_win_ld_cat(scratch, cap, p, &tdir[0]);
      p = labi_win_ld_cat(scratch, cap, p, "/");
      p = labi_win_ld_cat(scratch, cap, p, n2);
      p = labi_win_ld_cat(scratch, cap, p, "/crtbegin.o");
      if (p < 0) {
        continue;
      }
      let ok: i32 = 0;
      unsafe {
        ok = link_abi_path_readable(scratch);
      }
      if (ok == 0) {
        continue;
      }
      let better: i32 = 1;
      if (found != 0) {
        if (labi_win_ld_ver_cmp(n2, &best_ver[0]) <= 0) {
          better = 0;
        }
      }
      if (better != 0) {
        best_ver[0] = 0;
        if (labi_win_ld_cat(&best_ver[0], 256, 0, n2) >= 0) {
          if (labi_win_ld_join3(gcc_dir_out, cap, &tdir[0], "/", &best_ver[0]) != 0) {
            triple_out[0] = 0;
            labi_win_ld_cat(triple_out, cap, 0, &tname[0]);
            found = 1;
          }
        }
      }
    }
    unsafe {
      xlang_fmt_closedir(d2);
    }
  }
  unsafe {
    xlang_fmt_closedir(d1);
  }
  return found;
}

/**
 * Report a Windows link setup failure (BLD001) with a clear reason.
 * @param what *u8 — what is missing
 * @param where_s *u8 — searched location (nullable)
 * @return void
 */
#[no_mangle]
export function labi_win_ld_report(what: *u8, where_s: *u8): void {
  let msg: u8[1400] = [];
  let p: i32 = 0;
  msg[0] = 0;
  p = labi_win_ld_cat(&msg[0], 1400, p, "windows link: ");
  p = labi_win_ld_cat(&msg[0], 1400, p, what);
  if (where_s != 0 as *u8) {
    p = labi_win_ld_cat(&msg[0], 1400, p, " (looked in ");
    p = labi_win_ld_cat(&msg[0], 1400, p, where_s);
    p = labi_win_ld_cat(&msg[0], 1400, p, ")");
  }
  p = labi_win_ld_cat(&msg[0], 1400, p, "; need MinGW binutils ld with its crt/libgcc tree; gcc is not used as the link driver");
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, "build error", "BLD001", &msg[0], 0 as *u8);
  }
}

/**
 * Fill the Windows ld slot bank. Slots:
 *   0 ld.exe path  1 root  2 crt2.o  3 crtbegin.o  4 crtend.o
 *   5 -L<gcc ver dir>  6 -L<root>/lib/gcc  7 -L<root>/<triple>/lib (may be empty)
 *   8 -L<root>/lib  9 -L<root>  10 triple  11 scratch
 * @param bufs *u8 — slot bank (labi_win_ld_slot_count() * cap bytes)
 * @param cap i32 — bytes per slot (>= 512)
 * @return i32 — 0 ok; -1 ld missing; -2 crtbegin/crtend missing; -3 crt2 missing; -4 overflow
 */
#[no_mangle]
export function labi_win_ld_prepare(bufs: *u8, cap: i32): i32 {
  let s0: *u8 = labi_win_ld_slot(bufs, cap, 0);
  let s1: *u8 = labi_win_ld_slot(bufs, cap, 1);
  let s2: *u8 = labi_win_ld_slot(bufs, cap, 2);
  let s3: *u8 = labi_win_ld_slot(bufs, cap, 3);
  let s4: *u8 = labi_win_ld_slot(bufs, cap, 4);
  let s5: *u8 = labi_win_ld_slot(bufs, cap, 5);
  let s6: *u8 = labi_win_ld_slot(bufs, cap, 6);
  let s7: *u8 = labi_win_ld_slot(bufs, cap, 7);
  let s8: *u8 = labi_win_ld_slot(bufs, cap, 8);
  let s9: *u8 = labi_win_ld_slot(bufs, cap, 9);
  let s10: *u8 = labi_win_ld_slot(bufs, cap, 10);
  let s11: *u8 = labi_win_ld_slot(bufs, cap, 11);
  let gdir: u8[1024] = [];
  let k: i32 = 0;
  while (k < 12) {
    let sk: *u8 = labi_win_ld_slot(bufs, cap, k);
    sk[0] = 0;
    k = k + 1;
  }
  if (labi_win_ld_find_on_path(s0, s1, cap) == 0) {
    labi_win_ld_report("ld.exe not found", "PATH");
    return 0 - 1;
  }
  if (labi_win_ld_find_gcc_dir(s1, &gdir[0], s10, cap, s11) == 0) {
    labi_win_ld_join3(s11, cap, s1, "/lib/gcc/<triple>/<version>", 0 as *u8);
    labi_win_ld_report("crtbegin.o not found", s11);
    return 0 - 2;
  }
  if (labi_win_ld_join3(s3, cap, &gdir[0], "/crtbegin.o", 0 as *u8) == 0) {
    return 0 - 4;
  }
  if (labi_win_ld_join3(s4, cap, &gdir[0], "/crtend.o", 0 as *u8) == 0) {
    return 0 - 4;
  }
  let ce: i32 = 0;
  unsafe {
    ce = link_abi_path_readable(s4);
  }
  if (ce == 0) {
    labi_win_ld_report("crtend.o not found", s4);
    return 0 - 2;
  }
  // crt2.o: <root>/lib first (w64devkit, msys2), then <root>/<triple>/lib.
  let have_crt2: i32 = 0;
  if (labi_win_ld_join3(s2, cap, s1, "/lib/crt2.o", 0 as *u8) != 0) {
    unsafe {
      have_crt2 = link_abi_path_readable(s2);
    }
  }
  // <root>/<triple>/lib search dir (kept when it exists; crt2 fallback).
  if (labi_win_ld_join3(s11, cap, s1, "/", s10) != 0) {
    let p7: i32 = 0;
    p7 = labi_win_ld_cat(s11, cap, 0, s1);
    p7 = labi_win_ld_cat(s11, cap, p7, "/");
    p7 = labi_win_ld_cat(s11, cap, p7, s10);
    p7 = labi_win_ld_cat(s11, cap, p7, "/lib/crt2.o");
    if (p7 > 0) {
      let t7: i32 = 0;
      unsafe {
        t7 = link_abi_path_readable(s11);
      }
      if (t7 != 0) {
        let q: i32 = 0;
        q = labi_win_ld_cat(s7, cap, 0, "-L");
        q = labi_win_ld_cat(s7, cap, q, s1);
        q = labi_win_ld_cat(s7, cap, q, "/");
        q = labi_win_ld_cat(s7, cap, q, s10);
        q = labi_win_ld_cat(s7, cap, q, "/lib");
        if (q < 0) {
          s7[0] = 0;
        }
        if (have_crt2 == 0) {
          s2[0] = 0;
          if (labi_win_ld_cat(s2, cap, 0, s11) >= 0) {
            have_crt2 = 1;
          }
        }
      }
    }
  }
  if (have_crt2 == 0) {
    labi_win_ld_join3(s11, cap, s1, "/lib", 0 as *u8);
    labi_win_ld_report("crt2.o not found", s11);
    return 0 - 3;
  }
  if (labi_win_ld_join3(s5, cap, "-L", &gdir[0], 0 as *u8) == 0) {
    return 0 - 4;
  }
  if (labi_win_ld_join3(s6, cap, "-L", s1, "/lib/gcc") == 0) {
    return 0 - 4;
  }
  if (labi_win_ld_join3(s8, cap, "-L", s1, "/lib") == 0) {
    return 0 - 4;
  }
  if (labi_win_ld_join3(s9, cap, "-L", s1, 0 as *u8) == 0) {
    return 0 - 4;
  }
  return 0;
}

/**
 * Push one argv entry when room remains (keeps one slot for NULL).
 * @param argv **u8 — argv table
 * @param la *i32 — in/out count
 * @param max_la i32 — capacity
 * @param s *u8 — entry (null/empty skipped)
 * @return void
 */
#[no_mangle]
export function labi_win_ld_push(argv: **u8, la: *i32, max_la: i32, s: *u8): void {
  if (s == 0 as *u8) {
    return;
  }
  if (s[0] == 0) {
    return;
  }
  let cur: i32 = la[0];
  if (cur < max_la - 1) {
    argv[cur] = s;
    la[0] = cur + 1;
  }
}

/**
 * Head of the ld argv (after argv[0]): PE target, crt start objects, -L dirs.
 * ≡ gcc driver: -m i386pep -Bdynamic crt2.o crtbegin.o -L<ver> -L<lib/gcc> -L<lib> -L<root>.
 * @param bufs *u8 — slot bank filled by labi_win_ld_prepare
 * @param cap i32 — bytes per slot
 * @param argv **u8 — argv table
 * @param la *i32 — in/out count
 * @param max_la i32 — capacity
 * @return void
 */
#[no_mangle]
export function labi_win_ld_append_head(bufs: *u8, cap: i32, argv: **u8, la: *i32, max_la: i32): void {
  labi_win_ld_push(argv, la, max_la, "-m");
  labi_win_ld_push(argv, la, max_la, "i386pep");
  labi_win_ld_push(argv, la, max_la, "-Bdynamic");
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 2));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 3));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 5));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 6));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 7));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 8));
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 9));
}

/**
 * Tail of the ld argv: MinGW runtime -l group (≡ gcc libgcc spec) then crtend.o.
 * @param bufs *u8 — slot bank filled by labi_win_ld_prepare
 * @param cap i32 — bytes per slot
 * @param argv **u8 — argv table
 * @param la *i32 — in/out count
 * @param max_la i32 — capacity
 * @return void
 */
#[no_mangle]
export function labi_win_ld_append_tail(bufs: *u8, cap: i32, argv: **u8, la: *i32, max_la: i32): void {
  labi_win_ld_push(argv, la, max_la, "-lmingw32");
  labi_win_ld_push(argv, la, max_la, "-lgcc");
  labi_win_ld_push(argv, la, max_la, "-lmingwex");
  labi_win_ld_push(argv, la, max_la, "-lmsvcrt");
  labi_win_ld_push(argv, la, max_la, "-lkernel32");
  labi_win_ld_push(argv, la, max_la, "-lpthread");
  labi_win_ld_push(argv, la, max_la, "-ladvapi32");
  labi_win_ld_push(argv, la, max_la, "-lshell32");
  labi_win_ld_push(argv, la, max_la, "-luser32");
  labi_win_ld_push(argv, la, max_la, "-lkernel32");
  labi_win_ld_push(argv, la, max_la, "-lmingw32");
  labi_win_ld_push(argv, la, max_la, "-lgcc");
  labi_win_ld_push(argv, la, max_la, "-lmingwex");
  labi_win_ld_push(argv, la, max_la, "-lmsvcrt");
  labi_win_ld_push(argv, la, max_la, "-lkernel32");
  labi_win_ld_push(argv, la, max_la, labi_win_ld_slot(bufs, cap, 4));
}
