// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L8b on_demand early pure tables; G.9 English; body authoritative.
// wave263: late heavy pure (std_task/fk0/fk_gate/provides/link_needs/on_demand shell)
// lives in labi_ondemand_heavy.x (L8c) — full-module -E silent-parse-skip capacity cliff.
// Hybrid: L8b+L8c PREFER_X_O under XLANG_LABI_ONDEMAND_LIST_FROM_X (rest H=0 marker).
//
// R2 full: simple/kv/arrow/time/queue + rel_* pure tables +
//   wave118 labi_od_net_sym_* + link_abi_user_o_needs_std_net pure orch +
//   wave119 labi_od_set_sym_* + link_abi_user_o_needs_std_set pure orch +
//   wave120 labi_od_map_sym_* + link_abi_user_o_needs_std_map pure orch +
//   wave121 labi_od_queue_api_sym_* + link_abi_user_o_needs_std_queue pure orch
//     (product API; separate from contention labi_od_queue_sym_*) +
//   wave122 labi_od_test_sym_* + link_abi_user_o_needs_std_test pure orch +
//   wave123 labi_od_core_mem_sym_* + link_abi_user_o_needs_core_mem pure orch +
//   wave124 labi_od_core_slice_sym_* + link_abi_user_o_needs_core_slice pure orch +
//   wave125 labi_od_page_mmap_sym_* + link_abi_user_o_needs_std_heap_page_mmap pure orch +
//   wave126 labi_od_sys_linux_sym_* + link_abi_user_o_needs_std_sys_linux pure orch +
//   wave127 labi_od_sys_sym_* + link_abi_user_o_needs_std_sys pure orch +
//   wave128 labi_od_heap_api_sym_* + link_abi_user_o_needs_std_heap_api pure orch +
//   wave129 labi_od_heap_user_sym_* + link_abi_user_o_needs_heap_user_syms pure orch +
//   wave130 labi_od_async_scheduler_sym_* + link_abi_user_o_needs_async_scheduler pure orch +
//   wave131 link_abi_obj_needs_{zlib,zstd,brotli} + link_abi_user_o_needs_compress_libs pure orch
//     (marker + UNDEF/prefix tables; Cap residual exports_marker + has_undef_sym) +
//   wave132 labi_user_needs_runtime_{time_os,random_fill,env_os} pure orch
//     (PRIMARY OS bulk gates; null/empty user_o → 1 legacy hard-link) +
//   wave133 labi_user_needs_runtime_process_argv pure orch (9 needles; single-leaf) +
//   wave134 labi_user_needs_std_task pure orch (29 needles; TASK_SPECIAL bulk gate).
//   wave135 labi_std_fk0_user_needs_rel pure orch (16 rel × 106 exact UNDEF; Cap strstr).
//   wave140 labi_od_provides_{core_mem,std_heap}_sym_* + link_abi_user_o_provides_* pure orch
//     (defined-sym tables; Cap residual has_defined_sym; skip hard-link mem.o/heap.o).
//   wave145 link_abi_link_needs_{heap_user_c,std_heap_import} pure orch
//     (aggregate: user_o + ld argv .o scan via pure needs_* + ld_argv_entry_is_obj;
//      Cap residual: none new — reuses pure path_pure is_obj + L8b needs tables).
//   wave190 labi_std_fk_gate_sym_* + labi_std_fk_user_needs pure orch
//     (fk 1–13 plan gates; Cap residual undef_sym; G.7 complete wave135 fk0 sibling).
//   wave197 xlang_asm_ld_append_on_demand_user_objs pure orch
//     (product on_demand shell: pure needs/provides + pure push/path peers;
//      Cap residual ensure/skip/path + freestanding_get + undef_sym).
//   wave210 link_abi_obj_has_undef_sym pure thin orch
//     (null/empty gates; Cap residual link_abi_obj_has_undef_sym_impl = nm/popen).
//   wave211 link_abi_obj_exports_marker pure thin orch
//     (null/empty gates; Cap residual link_abi_obj_exports_marker_impl = nm/popen strstr).
//   wave212 xlang_link_obj_needs_undef_sym pure thin orch
//     (null/empty gates; Cap residual xlang_link_obj_needs_undef_sym_impl = nm/popen + ELF).
//   wave213 xlang_link_obj_has_defined_sym pure thin orch
//     (null/empty gates; Cap residual xlang_link_obj_has_defined_sym_impl = nm/popen T/t).
// Cap residual: ensure/skip/path Cap inside shell peers; needs_undef_impl /
//   has_undef_impl / exports_marker_impl / has_defined_impl Cap
//   (wave210–213 pure own has_undef + exports_marker + needs_undef + has_defined public gates).
// PLATFORM: SHARED — no asm co-emit of option/result/debug (Ubuntu hang); link formal .o only.
// Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5
// core_option=6 core_result=7 core_debug=8 core_slice=9.
// Formal core/*/*.o; g1 rel is core/types/types.o; g9 rel is core/slice/mod.o (API, not glue).
// g9: length.x needs core_slice_len_i32/get_* from mod.x; glue remains core/slice/slice.o.

/**
 * Cap residual (wave212): host nm/popen exact UNDEF probe body (+ LINUX ELF freestanding).
 * Pure orch owns null/empty gates; _impl is always mega (nm -u line parse + optional ELF scan).
 * @param user_o *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — exact bare symbol name, no leading underscore (caller rejected null/empty)
 * @return i32 — 1 if user.o has UNDEF for sym, else 0
 * PLATFORM: SHARED orch residual; LINUX freestanding ELF path inside _impl
 */
export extern "C" function xlang_link_obj_needs_undef_sym_impl(user_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff user.o needs (UNDEF) the given exact symbol; null/empty → 0 without residual.
 * @param user_o *u8 — path to user .o; null/empty rejected at pure gate
 * @param sym *u8 — exact bare symbol name; null/empty rejected at pure gate
 * @return i32 — 1 if UNDEF hit, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual nm/popen (+ ELF on LINUX freestanding).
 * Cap residual: xlang_link_obj_needs_undef_sym_impl (nm -u parse; strip optional U/_).
 * Why (wave212): hybrid still had needs_undef_sym body always mega C (gates+nm+ELF).
 * Used by all L8b pure needs_* orch tables (net/set/map/queue/fk/… on_demand gates).
 * PLATFORM: SHARED orch; residual nm/popen is host (POSIX; Windows hybrid via tools).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function xlang_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym[0] == 0) {
    return 0;
  }
  unsafe {
    return xlang_link_obj_needs_undef_sym_impl(user_o, sym);
  }
  return 0;
}

/**
 * Cap residual path pure: whether ld argv entry looks like .o/.obj (suffix scan).
 * Used by wave145 aggregate link_needs_* orch when scanning already-pushed objs.
 * @param s *u8 — argv entry path; null/empty → 0
 * @return i32 — 1 if ends with .o or .obj
 * PLATFORM: SHARED — authority labi_path_pure; dual-end prove IDENTICAL
 */
export extern "C" function link_abi_ld_argv_entry_is_obj(s: *u8): i32;

/**
 * Cap residual (wave213): host nm/popen defined (T/t) probe body.
 * Pure orch owns null/empty gates; _impl is always mega (nm line parse; strip optional _).
 * @param o_path *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — exact bare symbol name, no leading underscore (caller rejected null/empty)
 * @return i32 — 1 if nm shows T/t definition for sym, else 0
 * PLATFORM: SHARED residual; host nm/popen (POSIX; Windows hybrid via tools)
 */
export extern "C" function xlang_link_obj_has_defined_sym_impl(o_path: *u8, sym: *u8): i32;

/**
 * Return 1 iff .o defines (T/t) the given exact symbol; null/empty → 0 without residual.
 * @param o_path *u8 — path to .o; null/empty rejected at pure gate
 * @param sym *u8 — exact bare symbol name; null/empty rejected at pure gate
 * @return i32 — 1 if defined hit, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual nm/popen (wave213).
 * Cap residual: xlang_link_obj_has_defined_sym_impl (`nm` + skip addr + T/t + optional _).
 * Why (wave213): hybrid still had has_defined_sym body always mega C (gates+nm).
 * Used by wave140 user_o_provides_* orch and wave170 heap_user ensure stub reject.
 * PLATFORM: SHARED orch; residual nm/popen is host (POSIX; Windows hybrid via tools).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function xlang_link_obj_has_defined_sym(o_path: *u8, sym: *u8): i32 {
  if (o_path == 0 as *u8) {
    return 0;
  }
  if (o_path[0] == 0) {
    return 0;
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym[0] == 0) {
    return 0;
  }
  unsafe {
    return xlang_link_obj_has_defined_sym_impl(o_path, sym);
  }
  return 0;
}

/**
 * Cap residual (wave211): host nm/popen export-marker probe body.
 * Pure orch owns null/empty gates; _impl is always mega (realpath + nm + strstr marker).
 * @param obj_o *u8 — path to .o (caller already rejected null/empty)
 * @param marker *u8 — marker substring (caller already rejected null/empty)
 * @return i32 — 1 if any nm line contains marker
 * PLATFORM: SHARED — always mega C (popen/nm Cap)
 */
export extern "C" function link_abi_obj_exports_marker_impl(obj_o: *u8, marker: *u8): i32;

/**
 * Return 1 iff .o nm output contains marker substring; null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param marker *u8 — marker substring; null/empty rejected at pure gate
 * @return i32 — 1 if any nm line contains marker, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual nm/popen (wave211).
 * Cap residual: link_abi_obj_exports_marker_impl (realpath + `nm` + strstr marker).
 * Why (wave211): hybrid still had exports_marker body always mega C (gates+nm).
 * Used by compress pure orch (zlib/zstd/brotli package markers) and net TLS ensure.
 * PLATFORM: SHARED orch; residual nm/popen is host (POSIX; Windows hybrid via tools).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function link_abi_obj_exports_marker(obj_o: *u8, marker: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  if (marker == 0 as *u8) {
    return 0;
  }
  if (marker[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_obj_exports_marker_impl(obj_o, marker);
  }
  return 0;
}

/**
 * Cap residual (wave210): host nm/popen UNDEF substring probe body.
 * Pure orch owns null/empty gates; _impl is always mega (realpath + nm + " U " + needle).
 * @param obj_o *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — symbol name or prefix needle (caller already rejected null/empty)
 * @return i32 — 1 if any UNDEF line contains needle
 * PLATFORM: SHARED — always mega C (popen/nm Cap); zstd uses prefix needles ZSTD_ / _ZSTD
 */
export extern "C" function link_abi_obj_has_undef_sym_impl(obj_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff .o has an UNDEF line containing sym (host nm); null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param sym *u8 — symbol name or prefix needle; null/empty rejected at pure gate
 * @return i32 — 1 if UNDEF line hits, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual nm/popen (wave210).
 * Cap residual: link_abi_obj_has_undef_sym_impl (realpath + `nm` + " U " + needle).
 * Why (wave210): hybrid still had has_undef_sym body always mega C (gates+nm).
 * Used by compress pure orch (exact lib symbols and zstd prefix needles).
 * PLATFORM: SHARED orch; residual nm/popen is host (POSIX; Windows hybrid via tools).
 * Track-L: #[no_mangle] keeps surface short name matching Cap residual callers.
 */
#[no_mangle]
export function link_abi_obj_has_undef_sym(obj_o: *u8, sym: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_obj_has_undef_sym_impl(obj_o, sym);
  }
  return 0;
}

/* ===== wave197 Cap residual / peer pure for on_demand product shell ===== */
export extern "C" function link_abi_asm_ld_push_obj(primary: *u8, link_argv0: *u8, rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8, argv: **u8, la: *i32, max_la: i32, flag_out: *i32): i32;
export extern "C" function link_abi_asm_ld_argv_push_stable(bank: *u8, argv: **u8, la: *i32, max_la: i32, p: *u8): void;
export extern "C" function xlang_asm_ld_try_under_lib_roots(rel: *u8, lib_roots: **u8, n_lib_roots: i32, bank: *u8): *u8;
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
export extern "C" function xlang_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8;
export extern "C" function xlang_repo_root_from_argv0(argv0: *u8): *u8;
export extern "C" function xlang_ensure_formal_std_make_o(repo_root: *u8, rel_from_repo: *u8, make_target: *u8): i32;
export extern "C" function driver_freestanding_get(): i32;
export extern "C" function xlang_ensure_runtime_thread_glue_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_thread_glue_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_net_udp_batch_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_net_udp_batch_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_net_workers_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_net_workers_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_test_fn_invoke_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_test_fn_invoke_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_heap_user_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_heap_user_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_process_argv_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_process_argv_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_time_os_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_time_os_o_path(argv0: *u8): *u8;
export extern "C" function xlang_ensure_runtime_queue_contention_o(argv0: *u8): i32;
export extern "C" function xlang_runtime_queue_contention_o_path(argv0: *u8): *u8;
export extern "C" function xlang_std_async_scheduler_o_path(argv0: *u8): *u8;
export extern "C" function xlang_runtime_scheduler_glue_o_path(argv0: *u8): *u8;
export extern "C" function xlang_runtime_kv_mmap_glue_o_path(argv0: *u8): *u8;
export extern "C" function xlang_runtime_arrow_simd_glue_o_path(argv0: *u8): *u8;

/** Return simple on_demand group count (must match seed labi_ondemand_list.from_x.c). */
#[no_mangle]
export function labi_od_simple_group_count(): i32 {
  return 10;
}

/** Return symbol probe count for simple group g. */
#[no_mangle]
export function labi_od_simple_group_sym_count(g: i32): i32 {
  if (g < 0) {
    return 0;
  }
  if (g == 0) {
    return 9;
  }
  if (g == 1) {
    return 2;
  }
  if (g == 2) {
    return 6;
  }
  if (g == 3) {
    return 4;
  }
  if (g == 4) {
    return 3;
  }
  if (g == 5) {
    return 3;
  }
  if (g == 6) {
    return 4;
  }
  if (g == 7) {
    return 4;
  }
  if (g == 8) {
    return 6;
  }
  // core.slice formal API surface (tests/slice/length.x, subslice_split_chunks.x).
  if (g == 9) {
    return 10;
  }
  return 0;
}

/** Exported function `labi_od_simple_group_sym_at`.
 * Implements `labi_od_simple_group_sym_at`.
 * @param g i32
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_simple_group_sym_at(g: i32, i: i32): *u8 {
  if (g < 0) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  if (g == 0) {
    if (i == 0) {
      let p: *u8 = "xlang_string_copy_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "xlang_string_memcmp_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "xlang_string_memchr_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "xlang_string_memmem_c";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "xlang_string_memrchr_c";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_string_string_new";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_string_string_from_slice";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "std_string_string_view";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "std_string_string_len";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 1) {
    if (i == 0) {
      let p: *u8 = "core_types_size_of_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_types_placeholder";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 2) {
    if (i == 0) {
      let p: *u8 = "encoding_utf8_valid_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "encoding_hex_encode_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "encoding_ascii_is_alpha_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_encoding_utf8_valid";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "std_encoding_utf8_decode_rune";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_encoding_ascii_is_alpha";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 3) {
    if (i == 0) {
      let p: *u8 = "base64_encode_standard_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_base64_encode_standard";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_base64_decode_standard";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_base64_encode_url";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 4) {
    if (i == 0) {
      let p: *u8 = "std_csv_next_field";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_csv_escape";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_csv_csv_test_quoted_first";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 5) {
    if (i == 0) {
      let p: *u8 = "schema_create_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "schema_decode_json_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "schema_smoke_c";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 6) {
    if (i == 0) {
      let p: *u8 = "core_option_some_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_option_unwrap_or_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_option_none_i32";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_option_is_some_i32";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 7) {
    if (i == 0) {
      let p: *u8 = "core_result_ok_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_result_is_ok_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_result_err_i32";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_result_ok";
      return p;
    }
    return 0 as *u8;
  }
  // PLATFORM: SHARED — core.debug formal surface (tests/sort assert_eq_*).
  if (g == 8) {
    if (i == 0) {
      let p: *u8 = "core_debug_assert_eq_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_debug_assert_eq_u32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_debug_assert_eq_u64";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_debug_assert_ne_i32";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "core_debug_assert";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "core_debug_debug_assert";
      return p;
    }
    return 0 as *u8;
  }
  // PLATFORM: SHARED — core.slice formal API (mod.o). Glue from_ptr/subslice in slice.o.
  if (g == 9) {
    if (i == 0) {
      let p: *u8 = "core_slice_len_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_slice_get_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_slice_get_i32_unchecked";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_slice_len_u8";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "core_slice_get_u8";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "core_slice_get_u8_unchecked";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "core_slice_subslice_i32";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "core_slice_subslice_u8";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "core_slice_len_u64";
      return p;
    }
    if (i == 9) {
      let p: *u8 = "core_slice_get_u64";
      return p;
    }
    return 0 as *u8;
  }
  return 0 as *u8;
}

/** Return relative .o path for simple group g (repo-relative). */
#[no_mangle]
export function labi_od_simple_group_rel(g: i32): *u8 {
  if (g < 0) {
    return 0 as *u8;
  }
  if (g == 0) {
    let p: *u8 = "std/string/string.o";
    return p;
  }
  if (g == 1) {
    let p: *u8 = "core/types/types.o";
    return p;
  }
  if (g == 2) {
    let p: *u8 = "std/encoding/encoding.o";
    return p;
  }
  if (g == 3) {
    let p: *u8 = "std/base64/base64.o";
    return p;
  }
  if (g == 4) {
    let p: *u8 = "std/csv/csv.o";
    return p;
  }
  if (g == 5) {
    let p: *u8 = "std/schema/schema.o";
    return p;
  }
  if (g == 6) {
    let p: *u8 = "core/option/option.o";
    return p;
  }
  if (g == 7) {
    let p: *u8 = "core/result/result.o";
    return p;
  }
  if (g == 8) {
    let p: *u8 = "core/debug/debug.o";
    return p;
  }
  if (g == 9) {
    let p: *u8 = "core/slice/mod.o";
    return p;
  }
  return 0 as *u8;
}

/* KV: multi-sym → kv.o + optional glue rel */
#[no_mangle]
export function labi_od_kv_sym_count(): i32 {
  return 2;
}

/** Exported function `labi_od_kv_sym_at`.
 * Implements `labi_od_kv_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "db_kv_open_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "db_kv_get_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_kv_rel`.
 * Implements `labi_od_kv_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_rel(): *u8 {
  let p: *u8 = "std/db/kv/kv.o";
  return p;
}

/** Exported function `labi_od_kv_glue_rel`.
 * Implements `labi_od_kv_glue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_glue_rel(): *u8 {
  let p: *u8 = "compiler/runtime_kv_mmap_glue.o";
  return p;
}

/* Arrow */
#[no_mangle]
export function labi_od_arrow_sym_count(): i32 {
  return 2;
}

/** Exported function `labi_od_arrow_sym_at`.
 * Implements `labi_od_arrow_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "arrow_column_i32_create_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "arrow_column_adopt_f32_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_arrow_rel`.
 * Implements `labi_od_arrow_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_rel(): *u8 {
  let p: *u8 = "std/db/arrow/arrow.o";
  return p;
}

/** Exported function `labi_od_arrow_glue_rel`.
 * Implements `labi_od_arrow_glue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_glue_rel(): *u8 {
  let p: *u8 = "compiler/runtime_arrow_simd_glue.o";
  return p;
}

/* Time */
#[no_mangle]
export function labi_od_time_sym_count(): i32 {
  return 4;
}

/** Exported function `labi_od_time_sym_at`.
 * Implements `labi_od_time_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_sym_at(i: i32): *u8 {
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
    let p: *u8 = "std_time_timer_start";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "time_now_monotonic_ns_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_time_rel`.
 * Implements `labi_od_time_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_rel(): *u8 {
  let p: *u8 = "std/time/time.o";
  return p;
}

/** Exported function `labi_od_time_os_rel`.
 * Implements `labi_od_time_os_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_os_rel(): *u8 {
  let p: *u8 = "compiler/runtime_time_os.o";
  return p;
}

/* Queue contention */
#[no_mangle]
export function labi_od_queue_sym_count(): i32 {
  return 3;
}

/** Exported function `labi_od_queue_sym_at`.
 * Implements `labi_od_queue_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "sync_queue_contention_smoke_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "queue_os_run_two_workers_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "queue_contention_worker_push_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_queue_rel`.
 * Implements `labi_od_queue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_rel(): *u8 {
  let p: *u8 = "std/queue/queue.o";
  return p;
}

/** Exported function `labi_od_queue_contention_rel`.
 * Implements `labi_od_queue_contention_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_contention_rel(): *u8 {
  let p: *u8 = "compiler/runtime_queue_contention.o";
  return p;
}

/**
 * Count of UNDEF symbols that pull std/net/net.o on product asm on_demand.
 * @return i32 — 17 (std_net_* + net_*_c surface)
 * PLATFORM: SHARED — must match formal net.o export / C glue mangles
 */
#[no_mangle]
export function labi_od_net_sym_count(): i32 {
  return 17;
}

/**
 * Net on_demand UNDEF symbol at index (product probe table for needs_std_net).
 * @param i i32 — index in [0, 17)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_net_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_net_listen";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_net_connect";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_net_udp_bind";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_net_udp_recv_many_buf";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_net_udp_send_many_buf";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_net_addr_to_u32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_net_close_udp";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "net_stream_write_batch_c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "net_tcp_connect_c";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "net_tcp_listen_c";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "net_udp_bind_c";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "net_udp_recv_many_buf_c";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "net_udp_send_many_buf_c";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "net_close_socket_c";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "net_udp_send_c";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "net_dns_resolve_c";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "net_sock_create_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.net / net_*_c (on-demand chain net.o).
 * Pure orch: fixed net UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave118): hybrid still had needs_std_net body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_net(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_net_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_net_sym_at(i);
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
 * Count of UNDEF symbols that pull std/set/set.o on product asm on_demand.
 * @return i32 — 20 (formal overload mangles + legacy std_set_set_i32_*)
 * PLATFORM: SHARED — must match formal set.o export / historical user.o
 */
#[no_mangle]
export function labi_od_set_sym_count(): i32 {
  return 20;
}

/**
 * Set on_demand UNDEF symbol at index (product probe table for needs_std_set).
 * @param i i32 — index in [0, 20)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete existing needs_std_set authority (no second table)
 */
#[no_mangle]
export function labi_od_set_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_set_new_i32_retSet_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_set_new_i32_retSet_u64";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_set_with_capacity_Set_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_set_insert_Set_i32_ptr_i32";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_set_insert_Set_u64_ptr_u64";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_set_contains_key_Set_i32_i32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_set_contains_key_Set_u64_u64";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_set_remove_Set_i32_ptr_i32";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_set_remove_Set_u64_ptr_u64";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_set_len_Set_i32";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_set_len_Set_u64";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_set_deinit_Set_i32_ptr";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "std_set_deinit_Set_u64_ptr";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "std_set_str_new";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "std_set_str_insert";
    return p;
  }
  /* Legacy / alternate mangles: old user.o still pulls set.o. */
  if (i == 15) {
    let p: *u8 = "std_set_set_i32_insert";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "std_set_set_i32_contains";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "std_set_set_i32_remove";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "std_set_set_i32_len";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "std_set_set_i32_deinit";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.set API (on-demand chain set.o + heap/hash deps).
 * Pure orch: fixed set UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave119): hybrid still had needs_std_set body always mega C with hard-coded strings.
 * Stale names alone never appear as U on product asm → set.o never pushed → BLD001 (Ubuntu).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_set(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_set_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_set_sym_at(i);
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
 * Count of UNDEF symbols that pull std/map/map.o on product asm on_demand.
 * @return i32 — 9 (empty_size smoke + Map_i32_i32 surface + str map)
 * PLATFORM: SHARED — must match formal map.o export mangles
 */
#[no_mangle]
export function labi_od_map_sym_count(): i32 {
  return 9;
}

/**
 * Map on_demand UNDEF symbol at index (product probe table for needs_std_map).
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete existing needs_std_map authority (no second table)
 */
#[no_mangle]
export function labi_od_map_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_map_empty_size";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_map_new_Map_i32_i32";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_map_with_capacity_Map_i32_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_map_insert_Map_i32_i32_ptr_i32_i32";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_map_get_Map_i32_i32_i32";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_map_find_Map_i32_i32_i32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_map_deinit_Map_i32_i32_ptr";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_map_str_new";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_map_str_insert";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.map API (on-demand chain map.o + heap companions).
 * Pure orch: fixed map UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave120): hybrid still had needs_std_map body always mega C with hard-coded strings.
 * Complete authority was empty_size + full Map_i32/str surface; keep single table+orch in L8b.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_map(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_map_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_map_sym_at(i);
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
 * Count of product std.queue UNDEF symbols (tests/queue surface; not contention).
 * Complements labi_od_queue_sym_* (contention smoke only).
 * @return i32 — 12
 * PLATFORM: SHARED — must match formal queue.o export mangles
 */
#[no_mangle]
export function labi_od_queue_api_sym_count(): i32 {
  return 12;
}

/**
 * Product queue on_demand UNDEF symbol at index (needs_std_queue probe table).
 * @param i i32 — index in [0, 12)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete product needs_std_queue authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_queue_api_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_queue_new_retQueue_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_queue_new_retQueue_u8";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_queue_push_back_Queue_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_queue_push_back_Queue_u8_ptr_u8";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_queue_push_front";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_queue_pop_front_Queue_i32_ptr";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_queue_pop_back";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_queue_get";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_queue_len_Queue_i32";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_queue_is_empty_Queue_i32";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_queue_deinit_Queue_i32_ptr";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_queue_with_capacity";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references product std.queue API (on-demand chain queue.o).
 * Pure orch: fixed product queue UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * Contention path stays labi_od_queue_sym_* + labi_od_user_needs_any_sym_table in mega.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave121): hybrid still had needs_std_queue body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; do not merge with contention table (different objs).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_queue(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_queue_api_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_queue_api_sym_at(i);
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
 * Count of std.test on_demand UNDEF probes (product test.o gate).
 * Prefix-style entries (test_runner_ etc.) rely on Cap residual strstr
 * fallback inside xlang_link_obj_needs_undef_sym (exact + substring).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal test.o / runner export prefixes
 */
#[no_mangle]
export function labi_od_test_sym_count(): i32 {
  return 7;
}

/**
 * Product test on_demand UNDEF symbol or prefix at index (needs_std_test probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol/prefix, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_test authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_test_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "test_call_i32_void_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "test_runner_";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "test_expect_";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "test_bench_";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "test_f_test_";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "test_io_";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "test_fuzz_";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.test API (on-demand chain test.o).
 * Pure orch: fixed test UNDEF/prefix table; Cap residual xlang_link_obj_needs_undef_sym.
 * Avoids unconditional test.o on hello-class minimal links (ld duplicate risk).
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave122): hybrid still had needs_std_test body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; prefixes intentionally retained (strstr Cap).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_test(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_test_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_test_sym_at(i);
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
 * Count of core.mem on_demand UNDEF probes (product core/mem/mem.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal core/mem export surface
 */
#[no_mangle]
export function labi_od_core_mem_sym_count(): i32 {
  return 7;
}

/**
 * Product core.mem on_demand UNDEF symbol at index (needs_core_mem probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_core_mem authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_core_mem_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core_mem_align_up";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core_mem_align_down";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core_mem_mem_copy";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core_mem_mem_set";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "core_mem_mem_zero";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "core_mem_mem_move";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "core_mem_mem_compare";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references core.mem API (on-demand chain core/mem/mem.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave123): hybrid still had needs_core_mem body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_core_mem(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_core_mem_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_core_mem_sym_at(i);
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
 * Count of core.slice on_demand UNDEF probes (product core/slice glue gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 6
 * PLATFORM: SHARED — must match formal core/slice export surface used by needs_core_slice
 */
#[no_mangle]
export function labi_od_core_slice_sym_count(): i32 {
  return 6;
}

/**
 * Product core.slice on_demand UNDEF symbol at index (needs_core_slice probe table).
 * @param i i32 — index in [0, 6)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_core_slice authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_core_slice_sym_at(i: i32): *u8 {
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
 * Whether user .o references core.slice glue API (on-demand chain core/slice/slice.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave124): hybrid still had needs_core_slice body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_core_slice(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_core_slice_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_core_slice_sym_at(i);
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
 * Count of std.heap.page_mmap on_demand UNDEF probes (product page_mmap.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 5
 * PLATFORM: SHARED — must match formal std/heap/page_mmap export surface
 */
#[no_mangle]
export function labi_od_page_mmap_sym_count(): i32 {
  return 5;
}

/**
 * Product std.heap.page_mmap on_demand UNDEF symbol at index (needs_std_heap_page_mmap probe table).
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_heap_page_mmap authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_page_mmap_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_available";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_init";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_alloc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_deinit";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_free";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.heap.page_mmap API (on-demand chain std/heap/page_mmap.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * Freestanding mmap bump heap gate; transitive linux.o + core_mem.o covered by later on_demand.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave125): hybrid still had needs_std_heap_page_mmap body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_heap_page_mmap(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_page_mmap_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_page_mmap_sym_at(i);
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
 * Count of std.sys.linux on_demand UNDEF probes (product linux.o freestanding gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal std/sys/linux export surface
 */
#[no_mangle]
export function labi_od_sys_linux_sym_count(): i32 {
  return 7;
}

/**
 * Product std.sys.linux on_demand UNDEF symbol at index (needs_std_sys_linux probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_sys_linux authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_sys_linux_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_sys_linux_linux_syscall_invoke_available";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_sys_linux_linux_anonymous_mmap";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_sys_linux_linux_syscall_munmap";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_sys_linux_linux_syscall_read";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_sys_linux_linux_syscall_write";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_sys_linux_linux_syscall_close";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_sys_linux_linux_syscall_exit";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.sys.linux API (on-demand chain std/sys/linux.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * F-no-libc freestanding Linux syscall thin wrappers (mmap/read/write/close/exit).
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave126): hybrid still had needs_std_sys_linux body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys_linux(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_sys_linux_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_sys_linux_sym_at(i);
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
 * Count of std.sys facade on_demand UNDEF probes (product sys.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 8
 * PLATFORM: SHARED — must match formal std/sys export surface
 */
#[no_mangle]
export function labi_od_sys_sym_count(): i32 {
  return 8;
}

/**
 * Product std.sys on_demand UNDEF symbol at index (needs_std_sys probe table).
 * @param i i32 — index in [0, 8)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_sys authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_sys_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_sys_write_stdout";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_sys_write_stderr";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_sys_write";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_sys_read";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_sys_close";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_sys_exit";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_sys_freestanding_write_available";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_sys_linux_syscall_table_available";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.sys facade API (on-demand chain std/sys/sys.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * F-no-libc: write_stdout/read/close/exit + freestanding availability probes.
 * On Linux, sys.o may transitively pull linux.o via cfg target_os.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave127): hybrid still had needs_std_sys body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_sys_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_sys_sym_at(i);
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
 * Count of std.heap formal API on_demand UNDEF probes (product heap.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 25
 * PLATFORM: SHARED — must match formal std/heap export surface (incl. Allocator/libc family)
 */
#[no_mangle]
export function labi_od_heap_api_sym_count(): i32 {
  return 25;
}

/**
 * Product std.heap on_demand UNDEF symbol at index (needs_std_heap_api probe table).
 * @param i i32 — index in [0, 25)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_heap_api authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_heap_api_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_heap_alloc_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_heap_alloc_u8";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_free_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_heap_free_u8";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_heap_alloc_size_zero";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_heap_alloc_usize";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_heap_free_u8_ptr";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_heap_default_alloc";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_heap_kind_arena";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_heap_alloc_Allocator_usize";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_heap_realloc_Allocator_u8_ptr_usize";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_heap_free_Allocator_u8_ptr";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "std_heap_arena64_alloc";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "std_heap_libc_heap_arena64_alloc_c";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "std_heap_libc_heap_alloc_c";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "std_heap_libc_heap_free_c";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "std_heap_libc_heap_alloc_aligned_c";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "std_heap_libc_heap_alloc_i32_c";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "std_heap_libc_heap_alloc_u8_c";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "std_heap_libc_heap_alloc_u64_c";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "std_heap_libc_heap_free_i32_c";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "std_heap_libc_heap_free_u8_c";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "std_heap_libc_heap_free_u64_c";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "std_heap_map_find";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "std_heap_libc_heap_copy_u8_at_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.heap formal API (on-demand chain std/heap/heap.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * Covers typed alloc/free, Allocator/default/kind, arena64, and libc heap surface
 * used by formal set/map/queue/vec .o after import_alias C stubs were removed.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave128): hybrid still had needs_std_heap_api body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_heap_api(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_heap_api_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_heap_api_sym_at(i);
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
 * Count of runtime_heap_user on_demand UNDEF probes (compiler/runtime_heap_user.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * Product complete set (G.7): seed authority includes with_arena init/deinit
 * (not the incomplete 4-sym residual formerly left in mega runtime_link_abi.x).
 * @return i32 — 7
 * PLATFORM: SHARED — must match heap_user export surface used by with_arena asm emit
 */
#[no_mangle]
export function labi_od_heap_user_sym_count(): i32 {
  return 7;
}

/**
 * Product runtime_heap_user on_demand UNDEF symbol at index (needs_heap_user_syms probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_heap_user_syms authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_heap_user_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "heap_alloc_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "heap_free_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "heap_realloc_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "heap_arena64_alloc_c";
    return p;
  }
  // with_arena asm emit (pipeline_glue) — complete product probes (G.7).
  if (i == 4) {
    let p: *u8 = "heap_arena_init_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "heap_arena64_deinit_c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "heap_arena64_init_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references runtime_heap_user symbols (on-demand chain runtime_heap_user.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * Covers heap_alloc/free/realloc, arena64_alloc, and with_arena init/deinit surface.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave129): hybrid still had needs_heap_user_syms body always mega C with hard-coded strings;
 *   and residual mega runtime_link_abi.x table was incomplete (4 of 7 product symbols).
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_heap_user_syms(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_heap_user_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_heap_user_sym_at(i);
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
 * Count of std.async.scheduler on_demand UNDEF probes (std/async/scheduler.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * Product complete set (G.7): seed authority coop/cps/frame/run/task/worker/io + seed I/O complete surface.
 * @return i32 — 35
 * PLATFORM: SHARED — must match async scheduler + async IO export surface used by product on_demand
 */
#[no_mangle]
export function labi_od_async_scheduler_sym_count(): i32 {
  return 35;
}

/**
 * Product async scheduler on_demand UNDEF symbol at index (needs_async_scheduler probe table).
 * @param i i32 — index in [0, 35)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_async_scheduler authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_async_scheduler_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "xlang_async_coop_pingpong";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "xlang_async_coop_pingpong_jmp";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "xlang_async_cps_suspend";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "xlang_async_asm_frame_phase_by_id";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "xlang_async_asm_frame_store_from_ptr";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "xlang_async_asm_frame_load_to_ptr";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "xlang_async_asm_frame_reset_by_id";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "xlang_async_cps_suspend_io";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "xlang_async_run_i32";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "xlang_async_task_submit";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "xlang_async_task_submit_to";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "xlang_async_scheduler_drain";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "xlang_async_worker_drain";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "xlang_async_worker_count";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "xlang_async_worker_pending";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "xlang_async_queue_reset";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "xlang_async_scheduler_pending";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "xlang_async_io_wake_all";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "xlang_async_io_waiters_pending";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "xlang_async_io_completions_ready";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "xlang_async_run_seed_set_i32";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "xlang_async_run_seed_reset";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "xlang_async_run_seed_push_i32";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "xlang_async_run_seed_push_u32";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "xlang_async_run_seed_push_i64";
    return p;
  }
  if (i == 25) {
    let p: *u8 = "xlang_async_run_seed_valid";
    return p;
  }
  if (i == 26) {
    let p: *u8 = "xlang_async_run_seed_take_i32";
    return p;
  }
  if (i == 27) {
    let p: *u8 = "xlang_async_run_seed_take_u32";
    return p;
  }
  if (i == 28) {
    let p: *u8 = "xlang_async_run_seed_take_i64";
    return p;
  }
  if (i == 29) {
    let p: *u8 = "xlang_io_submit_read_async";
    return p;
  }
  if (i == 30) {
    let p: *u8 = "xlang_io_complete_read_async";
    return p;
  }
  if (i == 31) {
    let p: *u8 = "xlang_io_complete_read_async_slot";
    return p;
  }
  if (i == 32) {
    let p: *u8 = "xlang_io_submit_write_async";
    return p;
  }
  if (i == 33) {
    let p: *u8 = "xlang_io_complete_write_async";
    return p;
  }
  if (i == 34) {
    let p: *u8 = "xlang_io_complete_write_async_slot";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references async scheduler / async IO symbols (on-demand chain scheduler.o + glue).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * Covers coop/cps/frame/run/task/worker/io waiters and async read/write complete surface.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave130): hybrid still had needs_async_scheduler body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_async_scheduler(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_async_scheduler_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_async_scheduler_sym_at(i);
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
 * Count of zlib UNDEF needles for link_abi_obj_needs_zlib (exact libz symbols).
 * Product complete set (G.7): seed authority _compress2/_deflate/_inflate/_uncompress.
 * @return i32 — 4
 * PLATFORM: SHARED — must match zlib C API surface used by product compress gate
 */
#[no_mangle]
export function labi_od_zlib_undef_sym_count(): i32 {
  return 4;
}

/**
 * zlib UNDEF needle at index (needs_zlib probe table; exact symbols).
 * @param i i32 — index in [0, 4)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete zlib undef authority
 */
#[no_mangle]
export function labi_od_zlib_undef_sym_at(i: i32): *u8 {
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
  return 0 as *u8;
}

/**
 * xlang_compress_zlib_marker export name for package marker gate.
 * @return *u8 — static C string "xlang_compress_zlib_marker"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_compress_zlib_marker(): *u8 {
  let p: *u8 = "xlang_compress_zlib_marker";
  return p;
}

/**
 * Count of zstd UNDEF/prefix needles for link_abi_obj_needs_zstd.
 * Product complete set (G.7): seed authority prefix needles ZSTD_ and _ZSTD
 * (Cap residual has_undef_sym does substring match on UNDEF lines).
 * @return i32 — 2
 * PLATFORM: SHARED — must match zstd C API surface used by product compress gate
 */
#[no_mangle]
export function labi_od_zstd_undef_sym_count(): i32 {
  return 2;
}

/**
 * zstd UNDEF/prefix needle at index (needs_zstd probe table).
 * @param i i32 — index in [0, 2)
 * @return *u8 — static C string needle, or null if out of range
 * PLATFORM: SHARED — G.7 complete zstd undef/prefix authority
 */
#[no_mangle]
export function labi_od_zstd_undef_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "ZSTD_";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "_ZSTD";
    return p;
  }
  return 0 as *u8;
}

/**
 * xlang_compress_zstd_marker export name for package marker gate.
 * @return *u8 — static C string "xlang_compress_zstd_marker"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_compress_zstd_marker(): *u8 {
  let p: *u8 = "xlang_compress_zstd_marker";
  return p;
}

/**
 * Count of brotli UNDEF needles for link_abi_obj_needs_brotli (exact libbrotli symbols).
 * Product complete set (G.7): seed authority BrotliEncoderCompress + BrotliDecoderDecompress.
 * @return i32 — 2
 * PLATFORM: SHARED — must match brotli C API surface used by product compress gate
 */
#[no_mangle]
export function labi_od_brotli_undef_sym_count(): i32 {
  return 2;
}

/**
 * brotli UNDEF needle at index (needs_brotli probe table; exact symbols).
 * @param i i32 — index in [0, 2)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete brotli undef authority
 */
#[no_mangle]
export function labi_od_brotli_undef_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "BrotliEncoderCompress";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "BrotliDecoderDecompress";
    return p;
  }
  return 0 as *u8;
}

/**
 * xlang_compress_brotli_marker export name for package marker gate.
 * @return *u8 — static C string "xlang_compress_brotli_marker"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_compress_brotli_marker(): *u8 {
  let p: *u8 = "xlang_compress_brotli_marker";
  return p;
}

/**
 * Whether .o depends on libz (package marker or zlib UNDEF symbols).
 * Pure orch: marker Cap residual + fixed exact UNDEF table + Cap residual has_undef_sym.
 * @param obj_o *u8 — path to any .o (user or compress); null/empty → 0
 * @return i32 — 1 if marker or any zlib UNDEF hits, else 0
 * Why (wave131): hybrid still had needs_zlib body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; Cap residual marker/has_undef stay mega.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_obj_needs_zlib(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  let marker: *u8 = labi_od_compress_zlib_marker();
  if (marker != 0 as *u8) {
    if (marker[0] != 0) {
      let mhit: i32 = 0;
      unsafe {
        mhit = link_abi_obj_exports_marker(obj_o, marker);
      }
      if (mhit != 0) {
        return 1;
      }
    }
  }
  let n: i32 = labi_od_zlib_undef_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_zlib_undef_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_obj_has_undef_sym(obj_o, sym);
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
 * Whether .o depends on libzstd (package marker or zstd UNDEF/prefix needles).
 * Pure orch: marker Cap residual + fixed prefix-needle table + Cap residual has_undef_sym.
 * Prefix needles ZSTD_ / _ZSTD match product seed authority (substring on UNDEF lines).
 * @param obj_o *u8 — path to any .o; null/empty → 0
 * @return i32 — 1 if marker or any zstd needle hits, else 0
 * Why (wave131): hybrid still had needs_zstd body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_obj_needs_zstd(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  let marker: *u8 = labi_od_compress_zstd_marker();
  if (marker != 0 as *u8) {
    if (marker[0] != 0) {
      let mhit: i32 = 0;
      unsafe {
        mhit = link_abi_obj_exports_marker(obj_o, marker);
      }
      if (mhit != 0) {
        return 1;
      }
    }
  }
  let n: i32 = labi_od_zstd_undef_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_zstd_undef_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_obj_has_undef_sym(obj_o, sym);
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
 * Whether .o depends on libbrotli (package marker or brotli UNDEF symbols).
 * Pure orch: marker Cap residual + fixed exact UNDEF table + Cap residual has_undef_sym.
 * @param obj_o *u8 — path to any .o; null/empty → 0
 * @return i32 — 1 if marker or any brotli UNDEF hits, else 0
 * Why (wave131): hybrid still had needs_brotli body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_obj_needs_brotli(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  let marker: *u8 = labi_od_compress_brotli_marker();
  if (marker != 0 as *u8) {
    if (marker[0] != 0) {
      let mhit: i32 = 0;
      unsafe {
        mhit = link_abi_obj_exports_marker(obj_o, marker);
      }
      if (mhit != 0) {
        return 1;
      }
    }
  }
  let n: i32 = labi_od_brotli_undef_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_brotli_undef_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_obj_has_undef_sym(obj_o, sym);
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
 * Whether user .o references any compress library (zlib/zstd/brotli).
 * Pure orch: OR of three leaf pure orchs (G.7 single product compress gate).
 * @param user_o *u8 — path to user .o; null/empty → 0 via leaf null guards
 * @return i32 — 1 if any leaf needs hits, else 0
 * Why (wave131): hybrid still had needs_compress_libs body always mega C chaining hard-coded leaves.
 * Keep single product orch in L8b; leaf pure + Cap residual marker/has_undef.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_compress_libs(user_o: *u8): i32 {
  if (link_abi_obj_needs_zlib(user_o) != 0) {
    return 1;
  }
  if (link_abi_obj_needs_zstd(user_o) != 0) {
    return 1;
  }
  if (link_abi_obj_needs_brotli(user_o) != 0) {
    return 1;
  }
  return 0;
}

/* wave132–133: bulk PRIMARY OS pure tables + orch.
 * wave132: time_os / random_fill / env_os.
 * wave133: process_argv (9 needles; single-leaf to stay under module codegen capacity).
 * Semantics: null/empty user_o → 1 (legacy hard-link for old call sites without user_o).
 * std_task stays mega until capacity raise or L8b split.
 * Cap residual: xlang_link_obj_needs_undef_sym. PLATFORM: SHARED. */

/**
 * Count of runtime time_os UNDEF needles for labi_user_needs_runtime_time_os.
 * Product complete (G.7): time_*_c OS glue + std_time_* formal API.
 * @return i32 — 10
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_time_os_sym_count(): i32 {
  return 10;
}

/**
 * runtime time_os UNDEF needle at index (exact symbols only).
 * @param i i32 — index in [0, 10)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_time_os_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "time_now_monotonic_ns_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "time_now_wall_ns_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "time_sleep_ns_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "time_format_wall_rfc3339_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "time_wall_local_offset_min_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_time_now_monotonic_ns";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_time_now_wall_ns";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_time_sleep_ms";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_time_timer_start";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_time_duration_ns";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o needs runtime time_os companion (PRIMARY_TIME_OS bulk gate).
 * Pure orch: fixed exact UNDEF table; Cap residual undef_sym.
 * null/empty user_o → 1 (legacy hard-link when call site has no user_o).
 * @param user_o *u8 — path to user .o
 * @return i32 — 1 if gate open (push/ensure time_os), else 0
 * Why (wave132): hybrid still had labi_user_needs_runtime_time_os body always mega C.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function labi_user_needs_runtime_time_os(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 1;
  }
  if (user_o[0] == 0) {
    return 1;
  }
  let n: i32 = labi_od_runtime_time_os_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_runtime_time_os_sym_at(i);
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
 * Count of runtime random_fill UNDEF needles for labi_user_needs_runtime_random_fill.
 * Product complete (G.7): random_*_c OS glue + std_random_* formal API.
 * @return i32 — 12
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_random_fill_sym_count(): i32 {
  return 12;
}

/**
 * runtime random_fill UNDEF needle at index (exact symbols only).
 * @param i i32 — index in [0, 12)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_random_fill_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "random_fill_bytes_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_random_fill_bytes";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_random_fill";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_random_next";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_random_range_u32_u32";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_random_gen";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_random_flip";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_random_rng_smoke";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_random_seed";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "random_u32_c";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "random_u64_c";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "random_rng_smoke_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o needs runtime random_fill companion (PRIMARY_RANDOM_FILL bulk gate).
 * Pure orch: fixed exact UNDEF table; Cap residual undef_sym.
 * null/empty user_o → 1 (legacy hard-link).
 * @param user_o *u8 — path to user .o
 * @return i32 — 1 if gate open, else 0
 * Why (wave132): hybrid still had labi_user_needs_runtime_random_fill body always mega C.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_user_needs_runtime_random_fill(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 1;
  }
  if (user_o[0] == 0) {
    return 1;
  }
  let n: i32 = labi_od_runtime_random_fill_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_runtime_random_fill_sym_at(i);
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
 * Count of runtime env_os UNDEF needles for labi_user_needs_runtime_env_os.
 * Product complete (G.7): env_*_c OS glue + std_env_* formal API (incl args_iter).
 * @return i32 — 19
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_env_os_sym_count(): i32 {
  return 19;
}

/**
 * runtime env_os UNDEF needle at index (exact symbols only).
 * @param i i32 — index in [0, 19)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_env_os_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "env_getenv_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "env_getenv_exists_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "env_getenv_z_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "env_getenv_ptr_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "env_setenv_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "env_unsetenv_c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "env_temp_dir_c";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "env_iter_count_c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "env_iter_at_c";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_env_getenv";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_env_getenv_exists";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_env_getenv_z";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "std_env_getenv_ptr";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "std_env_setenv";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "std_env_unsetenv";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "std_env_temp_dir";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "std_env_iter";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "std_env_iter_count";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "std_env_args_iter";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o needs runtime env_os companion (PRIMARY_ENV_OS bulk gate).
 * Pure orch: fixed exact UNDEF table; Cap residual undef_sym.
 * null/empty user_o → 1 (legacy hard-link).
 * @param user_o *u8 — path to user .o
 * @return i32 — 1 if gate open, else 0
 * Why (wave132): hybrid still had labi_user_needs_runtime_env_os body always mega C.
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_user_needs_runtime_env_os(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 1;
  }
  if (user_o[0] == 0) {
    return 1;
  }
  let n: i32 = labi_od_runtime_env_os_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_runtime_env_os_sym_at(i);
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
 * Count of runtime process_argv UNDEF needles for labi_user_needs_runtime_process_argv.
 * Product complete (G.7): process_*_c + process_xlang_* + std_process_* + std_env_args_iter.
 * @return i32 — 9
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_process_argv_sym_count(): i32 {
  return 9;
}

/**
 * runtime process_argv UNDEF needle at index (exact symbols only).
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_process_argv_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "process_xlang_argc_get";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "process_xlang_argv_get";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "process_arg_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "process_args_count_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_process_args";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_process_arg";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_process_argc";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_process_argv";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_env_args_iter";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o needs runtime process_argv companion (PRIMARY process argv bulk gate).
 * Pure orch: fixed exact UNDEF table; Cap residual undef_sym.
 * null/empty user_o → 1 (legacy hard-link when call site has no user_o).
 * @param user_o *u8 — path to user .o
 * @return i32 — 1 if gate open (push/ensure process_argv path), else 0
 * Why (wave133): hybrid still had labi_user_needs_runtime_process_argv body always mega C;
 * single-leaf migrate after wave132 capacity clip blocked process_argv+std_task together.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function labi_user_needs_runtime_process_argv(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 1;
  }
  if (user_o[0] == 0) {
    return 1;
  }
  let n: i32 = labi_od_runtime_process_argv_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_runtime_process_argv_sym_at(i);
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
