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
//     (null/empty gates; Cap residual link_abi_obj_has_undef_sym_impl =
//      UNDEF-cache substring, sibling of needs_undef mmap).
//   wave211 link_abi_obj_exports_marker pure thin orch
//     (null/empty gates; Cap residual link_abi_obj_exports_marker_impl =
//      all-names cache substring; markers are d/s/b, not T/t).
//   wave212 xlang_link_obj_needs_undef_sym pure thin orch
//     (null/empty gates; Cap residual xlang_link_obj_needs_undef_sym_impl = nm/popen + ELF).
//   wave213 xlang_link_obj_has_defined_sym pure thin orch
//     (null/empty gates; Cap residual xlang_link_obj_has_defined_sym_impl =
//      Mach-O/ELF T/t scan or one nm; per-path cache sibling of UNDEF).
// Cap residual: ensure/skip/path Cap inside shell peers; needs_undef_impl /
//   has_undef_impl / exports_marker_impl / has_defined_impl Cap
//   (wave210–213: one-slot UNDEF + T/t + all-names mmap; no per-probe nm).
// PLATFORM: SHARED — no asm co-emit of option/result/debug (Ubuntu hang); link formal .o only.
// Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5
// core_option=6 core_result=7 core_debug=8 core_slice=9 core_builtin=10 std_ffi=11.
// Formal core/*/*.o; g1 rel is core/types/types.o; g9 rel is core/slice/mod.o (API, not glue).
// g9: length.x needs core_slice_len_i32/get_* from mod.x; glue remains core/slice/slice.o.
// g11: pure-asm import METHOD mangle → std_ffi_*; formal std/ffi/ffi.o (mod.x + ffi.x).

/**
 * Cap residual (wave212): exact UNDEF probe body (one-slot cache + in-process scan).
 * Pure orch owns null/empty gates; _impl is always mega.
 * @param user_o *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — exact bare symbol name, no leading underscore (caller rejected null/empty)
 * @return i32 — 1 if user.o has UNDEF for sym, else 0
 * PLATFORM: SHARED orch residual; LINUX ELF / DARWIN Mach-O in-process; nm -u once fallback
 */
export extern "C" function xlang_link_obj_needs_undef_sym_impl(user_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff user.o needs (UNDEF) the given exact symbol; null/empty → 0 without residual.
 * @param user_o *u8 — path to user .o; null/empty rejected at pure gate
 * @param sym *u8 — exact bare symbol name; null/empty rejected at pure gate
 * @return i32 — 1 if UNDEF hit, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual UNDEF cache lookup.
 * Cap residual: xlang_link_obj_needs_undef_sym_impl (Mach-O/ELF scan or one nm -u;
 * strip optional U/_). Per-path cache: on_demand walks hundreds of probes against
 * the same user.o — do not popen nm per symbol (P2 Darwin -o).
 * Why (wave212): hybrid still had needs_undef_sym body always mega C (gates+nm+ELF).
 * Used by all L8b pure needs_* orch tables (net/set/map/queue/fk/… on_demand gates).
 * PLATFORM: SHARED orch; residual scan/nm is host (POSIX; Windows hybrid via tools).
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
 * Cap residual (wave213): exact defined (T/t) probe body (one-slot cache + in-process scan).
 * Pure orch owns null/empty gates; _impl is always mega.
 * @param o_path *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — exact bare symbol name, no leading underscore (caller rejected null/empty)
 * @return i32 — 1 if the object defines sym as text (T/t), else 0
 * PLATFORM: SHARED residual; LINUX ELF / DARWIN Mach-O in-process; nm once fallback
 */
export extern "C" function xlang_link_obj_has_defined_sym_impl(o_path: *u8, sym: *u8): i32;

/**
 * Return 1 iff .o defines (T/t) the given exact symbol; null/empty → 0 without residual.
 * @param o_path *u8 — path to .o; null/empty rejected at pure gate
 * @param sym *u8 — exact bare symbol name; null/empty rejected at pure gate
 * @return i32 — 1 if defined hit, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual T/t cache lookup.
 * Cap residual: xlang_link_obj_has_defined_sym_impl (Mach-O/ELF T/t scan or one nm;
 * strip optional _). Per-path cache shares the UNDEF mmap: on_demand also probes
 * defined-sym tables against the same user.o — do not popen nm per symbol
 * (P2 Darwin -o sibling). Compress substring probes share this mmap too.
 * Why (wave213): hybrid still had has_defined_sym body always mega C (gates+nm).
 * Used by wave140 user_o_provides_* orch and wave170 heap_user ensure stub reject.
 * PLATFORM: SHARED orch; residual scan/nm is host (POSIX; Windows hybrid via tools).
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
 * Cap residual (wave211): export-marker substring probe body (all-names cache).
 * Pure orch owns null/empty gates; _impl is always mega.
 * @param obj_o *u8 — path to .o (caller already rejected null/empty)
 * @param marker *u8 — marker substring (caller already rejected null/empty)
 * @return i32 — 1 if any symbol name contains marker
 * PLATFORM: SHARED residual; LINUX ELF / DARWIN Mach-O in-process; nm once fallback
 */
export extern "C" function link_abi_obj_exports_marker_impl(obj_o: *u8, marker: *u8): i32;

/**
 * Return 1 iff .o exports a symbol whose name contains marker; null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param marker *u8 — marker substring; null/empty rejected at pure gate
 * @return i32 — 1 if any symbol name contains marker, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual all-names lookup.
 * Cap residual: link_abi_obj_exports_marker_impl (Mach-O/ELF all-names scan or one nm;
 * strstr on stripped names; Darwin reconstructs one leading '_'). Markers live in
 * data (d/s/b), not T/t — do not reuse the defined blob. Per-path cache shares the
 * UNDEF mmap (P2 Darwin -o compress sibling; hello still spawned 11 full-nm after
 * UNDEF + T/t caches).
 * Why (wave211): hybrid still had exports_marker body always mega C (gates+nm).
 * Used by compress pure orch (zlib/zstd/brotli package markers) and net TLS ensure.
 * PLATFORM: SHARED orch; residual scan/nm is host (POSIX; Windows hybrid via tools).
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
 * Cap residual (wave210): UNDEF substring probe body (one-slot cache).
 * Pure orch owns null/empty gates; _impl is always mega.
 * @param obj_o *u8 — path to .o (caller already rejected null/empty)
 * @param sym *u8 — symbol name or prefix needle (caller already rejected null/empty)
 * @return i32 — 1 if any UNDEF name contains needle
 * PLATFORM: SHARED residual; LINUX ELF / DARWIN Mach-O in-process; nm once fallback
 */
export extern "C" function link_abi_obj_has_undef_sym_impl(obj_o: *u8, sym: *u8): i32;

/**
 * Return 1 iff .o has an UNDEF name containing sym; null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param sym *u8 — symbol name or prefix needle; null/empty rejected at pure gate
 * @return i32 — 1 if UNDEF substring hits, else 0
 * Pure orch: ≡ mega null/empty gates before Cap residual UNDEF-cache substring.
 * Cap residual: link_abi_obj_has_undef_sym_impl (Mach-O/ELF UNDEF scan or one nm;
 * strstr on stripped names; Darwin reconstructs one leading '_' so `_ZSTD` /
 * `_compress2` still hit). Per-path cache shares the needs_undef mmap
 * (P2 Darwin -o compress sibling; 8 of hello's 11 leftover full-nm).
 * Why (wave210): hybrid still had has_undef_sym body always mega C (gates+nm).
 * Used by compress pure orch (exact lib symbols and zstd prefix needles).
 * PLATFORM: SHARED orch; residual scan/nm is host (POSIX; Windows hybrid via tools).
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

/**
 * Return simple on_demand group count (must match seed labi_ondemand_list.from_x.c).
 * Groups: 0 string · 1 types · 2 encoding · 3 base64 · 4 csv · 5 schema ·
 * 6 option · 7 result · 8 debug · 9 slice · 10 builtin · 11 ffi.
 * @return i32 — 26 (was 25; +g25 core.cmp formal faces, CORE-005 direct import)
 * PLATFORM: SHARED — pure-asm product UNDEF gates for formal core/std .o
 */
#[no_mangle]
export function labi_od_simple_group_count(): i32 {
  return 26;
}

/**
 * Return symbol probe count for simple group g.
 * @param g i32 — group index in [0, labi_od_simple_group_count())
 * @return i32 — exact UNDEF needle count for that group; 0 if out of range
 * PLATFORM: SHARED — must match formal export surface for each rel .o
 */
#[no_mangle]
export function labi_od_simple_group_sym_count(g: i32): i32 {
  if (g < 0) {
    return 0;
  }
  if (g == 0) {
    return 13;
  }
  if (g == 1) {
    /* PLATFORM: SHARED — full core/types/types.o export surface (CORE-013 i16/u16). */
    return 27;
  }
  if (g == 2) {
    return 6;
  }
  if (g == 3) {
    return 4;
  }
  if (g == 4) {
    return 5;
  }
  if (g == 5) {
    return 3;
  }
  if (g == 6) {
    return 4;
  }
  // PLATFORM: SHARED — core.result short API (is_ok/is_err/unwrap_or/err/ok) + *_i32 aliases.
  // Was 4 (ok_i32/is_ok_i32/err_i32/ok): sole is_err/unwrap_or/err never opened gate → BLD001.
  // G.7: prefer suffix-free overloads; keep *_i32 needles for legacy callers.
  if (g == 7) {
    return 10;
  }
  if (g == 8) {
    return 6;
  }
  /* PLATFORM: SHARED — full core/slice/mod.o export surface (CORE-004; was 13). */
  if (g == 9) {
    return 28;
  }
  // PLATFORM: SHARED — core.builtin formal (tests/builtin/main.x pure-asm UNDEF residual).
  // G-01: C-path still never hard-links builtin.o (bitops → __builtin_*); pure-asm emits
  // external core_builtin_* and needs formal core/builtin/builtin.o via this group.
  if (g == 10) {
    return 14;
  }
  // PLATFORM: SHARED — std.ffi formal (tests/ffi/main.x pure-asm UNDEF residual).
  // Pure-asm import METHOD → std_ffi_*; also probe leaf ffi_*_c faces from ffi.x.
  if (g == 11) {
    return 8;
  }
  // PLATFORM: SHARED — std.test formal (tests/stdtest pure-asm residual).
  // need_test special path can miss when monofile dual lags; simple-group is
  // the same authority path as g10/g11 (ensure formal + push).
  if (g == 12) {
    return 5;
  }
  // PLATFORM: SHARED — core.assert formal (run-debug core-assert residual).
  // Distinct from g8 core.debug (core_debug_*); pure-asm mangles core.assert → core_assert_*.
  if (g == 13) {
    return 6;
  }
  // PLATFORM: SHARED — std.fmt formal (run-fmt / run-fmt-std residual).
  // Not on default OP_STD plan; simple-group is sole pure-asm push path.
  // Count 8→9: cookbook fmt_template_i32 sole UNDEF std_fmt_format_template.
  if (g == 14) {
    return 9;
  }
  // PLATFORM: SHARED — std.compress formal facade (run-compress residual).
  // Product path previously retired compress.o for C co-emit; pure-asm needs formal T.
  // Count 6→14: cookbook compress_stream_br_zs unique UNDEF stream/format/mode.
  // Count 14→24 (9.2.2): submodule zlib/gzip unique UNDEFs + Linux co-emit
  // bare compress_*_c (exact matcher; facade std_compress_gzip_compress does
  // not fire for std_compress_zlib_deflate / std_compress_gzip_gzip_compress).
  if (g == 15) {
    /* PLATFORM: SHARED — 28: +4 stream needles the co-emitted std.compress
   * module leaves U (glue in std/compress/*.o; run-compress BLD001 root). */
  return 28;
  }
  // PLATFORM: SHARED — std.io.driver formal (run-io-driver residual).
  if (g == 16) {
    return 4;
  }
  // PLATFORM: SHARED — std.debug formal (run-debug std-debug residual).
  if (g == 17) {
    return 3;
  }
  // PLATFORM: SHARED — std.simd formal (run-perf-simd + STD-SIMD-INTRINSIC).
  // VECTOR mid faces: shuffle/select/splat + add/sub/mul/hsum/dot/fma/madd
  // + scalar placeholder/hw_available/recommend_path/SIMD_PATH_* (s2/autovec)
  // + select_lane i32/f32 (product helper; sole-call UNDEF without these needles).
  if (g == 18) {
    return 23;
  }
  // PLATFORM: SHARED — std.io context-timeout formal (run-std-io-context residual).
  // timeout_from_ctx / read_ctx / write_ctx (mod.x; monofile skip std.io emit).
  if (g == 19) {
    return 3;
  }
  /*
   * wave957: std.unicode formal product probe (run-unicode residual).
   * Before wave957: .x source had no unicode simple_group; C seed had k==17
   * but PREFER path used .x → unicode symbols never probed → BLD001 UNDEF.
   * Added as g==20 to avoid disrupting existing g0-g19 assignments.
   * PLATFORM: SHARED.
   */
  if (g == 20) {
    return 8;
  }
  /*
   * PLATFORM: SHARED — core.str formal (cookbook core_str_index unique UNDEF).
   * Matcher is exact; bytes_view itself is often inlined (STRUCT_LIT return) so
   * index_of / index_of_byte / starts_with are the fire points. Count 12 = full
   * export surface in core/str/mod.x (G.7 complete one table; no second group).
   */
  if (g == 21) {
    return 12;
  }
  /*
   * PLATFORM: SHARED — core.iterator formal (cookbook iter_slice_sum unique UNDEF).
   * Matcher is exact; no prior group. Count 10 = full export surface in
   * core/iterator/mod.x (G.7 complete one table; no second group).
   */
  if (g == 22) {
    return 10;
  }
  /*
   * PLATFORM: SHARED — std.bytes formal (tests/std-bytes/arena_external unique UNDEF).
   * Matcher is exact; no prior group. Count 29 = full export surface in
   * std/bytes/mod.x (G.7 complete one table; no second group). Unique fire
   * points: from_external / is_owned / recommend_bytes_alloc_arena / extend /
   * length / deinit.
   */
  if (g == 23) {
    return 29;
  }
  /*
   * PLATFORM: SHARED — core.fmt formal (CORE-010/011 direct import("core.fmt")).
   * Matcher exact; widths/f64_special unique fire: usize/isize/ptr + f64*_to_buf.
   * Count 12 = CORE-010/011 fire points + common *_to_buf exports (G.7 one table).
   */
  if (g == 24) {
    return 12;
  }
  /*
   * PLATFORM: SHARED — core.cmp formal (CORE-005 direct import("core.cmp")).
   * Matcher exact; Ordering smoke unique fire: cmp_i32/u8/ptr + is_lt/eq/gt + then/reverse.
   * Count 12 = full core/cmp/mod.x export surface (G.7 one table).
   */
  if (g == 25) {
    return 12;
  }
  return 0;
}

/* Class BE: labi_od_simple_group_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_simple_group_sym_at(g: i32, i: i32): *u8;

/**
 * Return relative .o path for simple group g (repo-relative).
 * @param g i32 — group index in [0, labi_od_simple_group_count())
 * @return *u8 — static path string, or null if out of range
 * PLATFORM: SHARED — ensure via xlang_ensure_formal_std_make_o before push
 */
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
  // PLATFORM: SHARED — core.builtin formal product .o (G-01 pure-asm only; C stays __builtin_*).
  if (g == 10) {
    let p: *u8 = "core/builtin/builtin.o";
    return p;
  }
  // PLATFORM: SHARED — std.ffi formal product .o (pure-asm run-ffi residual).
  if (g == 11) {
    let p: *u8 = "std/ffi/ffi.o";
    return p;
  }
  // PLATFORM: SHARED — std.test formal product .o (pure-asm run-stdtest residual).
  if (g == 12) {
    let p: *u8 = "std/test/test.o";
    return p;
  }
  // PLATFORM: SHARED — core.assert formal product .o (run-debug core-assert residual).
  if (g == 13) {
    let p: *u8 = "core/assert/assert.o";
    return p;
  }
  // PLATFORM: SHARED — std.fmt formal product .o (run-fmt residual).
  if (g == 14) {
    let p: *u8 = "std/fmt/fmt.o";
    return p;
  }
  // PLATFORM: SHARED — std.compress formal product .o (run-compress residual).
  if (g == 15) {
    let p: *u8 = "std/compress/compress.o";
    return p;
  }
  // PLATFORM: SHARED — std.io.driver formal product .o (run-io-driver residual).
  if (g == 16) {
    let p: *u8 = "std/io/driver.o";
    return p;
  }
  // PLATFORM: SHARED — std.debug formal product .o (run-debug residual).
  if (g == 17) {
    let p: *u8 = "std/debug/debug.o";
    return p;
  }
  // PLATFORM: SHARED — std.simd formal product .o (run-perf-simd residual).
  if (g == 18) {
    let p: *u8 = "std/simd/simd.o";
    return p;
  }
  // PLATFORM: SHARED — std.io context-timeout formal product .o (STD-091 residual).
  if (g == 19) {
    let p: *u8 = "std/io/io.o";
    return p;
  }
  // wave957: std.unicode formal product .o (run-unicode residual).
  if (g == 20) {
    let p: *u8 = "std/unicode/unicode.o";
    return p;
  }
  // PLATFORM: SHARED — core.str formal product .o (cookbook core_str_index).
  if (g == 21) {
    let p: *u8 = "core/str/mod.o";
    return p;
  }
  // PLATFORM: SHARED — core.iterator formal product .o (cookbook iter_slice_sum).
  if (g == 22) {
    let p: *u8 = "core/iterator/mod.o";
    return p;
  }
  // PLATFORM: SHARED — std.bytes formal product .o (tests/std-bytes/arena_external).
  if (g == 23) {
    let p: *u8 = "std/bytes/bytes.o";
    return p;
  }
  // PLATFORM: SHARED — core.fmt formal product .o (CORE-010/011 direct import).
  if (g == 24) {
    let p: *u8 = "core/fmt/mod.o";
    return p;
  }
  // PLATFORM: SHARED — core.cmp formal product .o (CORE-005 direct import).
  if (g == 25) {
    let p: *u8 = "core/cmp/mod.o";
    return p;
  }
  return 0 as *u8;
}

/* KV: multi-sym → kv.o + optional glue rel.
 * PLATFORM: SHARED — cookbook db_kv_arrow unique-first, then remaining unique
 * std.db.kv export faces, then legacy C ABI. Twin of L8b seed. */
#[no_mangle]
export function labi_od_kv_sym_count(): i32 {
  return 14;
}

/* Class BF: labi_od_kv_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_kv_sym_at(i: i32): *u8;

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

/* Arrow.
 * PLATFORM: SHARED — cookbook db_kv_arrow unique-first, then remaining unique
 * std.db.arrow export faces, then legacy C ABI. Twin of L8b seed. */
#[no_mangle]
export function labi_od_arrow_sym_count(): i32 {
  return 29;
}

/* Class BF: labi_od_arrow_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_arrow_sym_at(i: i32): *u8;

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

/* PLATFORM: SHARED — cookbook async_mod_import / drain_idle / scheduler_reset /
 * net_fs_async_smoke unique-first.
 * Distinct from labi_od_async_scheduler_sym_* (C ABI ×35 for scheduler.o
 * skip-missing; never unique import METHOD std_async_*). Twin of L8b seed.
 * Produce path is formal_mod c_face std/async/async.o. */
#[no_mangle]
export function labi_od_async_sym_count(): i32 {
  return 4;
}

/**
 * Exact UNDEF needle at index i for std.async leftover unique on-demand (user .o).
 * @param i i32 — 0..count-1; unique-first cookbook names only
 * @return *u8 — NUL-terminated symbol; null if i out of range
 * PLATFORM: SHARED — matcher is exact; import METHOD is std_async_*.
 */
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_async_sym_at(i: i32): *u8;


/**
 * Rel path of the formal_mod c_face vehicle for leftover unique std.async names.
 * @return *u8 — "std/async/async.o"
 * PLATFORM: SHARED — distinct from scheduler.o / future.o std_x auto-soft.
 */
#[no_mangle]
export function labi_od_async_rel(): *u8 {
  let p: *u8 = "std/async/async.o";
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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_time_sym_at(i: i32): *u8;


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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_queue_sym_at(i: i32): *u8;


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
 * @return i32 — 34 (std_net_* + net_*_c surface + wave956 std_net_resolve_*
 *                + std_net_close_stream/connect_blocking/write_batch/tcp_pool_*
 *                + unique close_listener + Cap 9.1.7 net_resolve_ipv4/ipv6_ex_c)
 * PLATFORM: SHARED — must match formal net.o export / C glue mangles
 */
#[no_mangle]
export function labi_od_net_sym_count(): i32 {
  return 34;
}

/* Class BF: labi_od_net_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_net_sym_at(i: i32): *u8;

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
 * Count of UNDEF symbols that pull std/thread/thread.o on product asm on_demand.
 * @return i32 — 4 (wave956: std_thread_create / join / start / stats)
 * PLATFORM: SHARED — must match formal thread.o export / C glue mangles
 */
#[no_mangle]
export function labi_od_thread_sym_count(): i32 {
  return 4;
}

/**
 * Thread on_demand UNDEF symbol at index (product probe table for needs_std_thread).
 * @param i i32 — index in [0, 4)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 single thread probe table (no second path)
 */
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_thread_sym_at(i: i32): *u8;


/**
 * Whether user .o references std.thread / std_thread_* (on-demand chain thread.o).
 * Pure orch: fixed thread UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave956): before this, asm on_demand only pushed thread.o inside
 * need_net block; user programs importing only std.thread never got
 * thread.o. Twin of link_abi_user_o_needs_std_net. PLATFORM: SHARED.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_thread(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_thread_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_thread_sym_at(i);
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

/*
 * wave958: std.vec on_demand probe table. Before wave958: no vec probe table
 * existed; user programs using Vec<u16/i32/u8/u64/f64> hit BLD001 UNDEF
 * because needs_std_vec never fired. Probe covers common ops (push/get/
 * length/deinit/from_slice/capacity/clear) plus pop/extend (exact UNDEF;
 * matcher is exact — push/from_slice_u8 do not cover pop, Vec_u64/f64
 * extend, sole from_slice_u64/f64, sole push_u64/f64, sole
 * length/get/deinit u64/f64, or sole vec3f SOA/AOS push/deinit/
 * reserve/sum). G.7: single vec probe authority.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_od_vec_sym_count(): i32 {
  return 44;
}

/* Class BF: labi_od_vec_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_vec_sym_at(i: i32): *u8;

/**
 * Whether user .o references std.vec API (on-demand chain std/vec/vec.o).
 * Pure orch: fixed vec UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * PLATFORM: SHARED — G.7 single vec probe authority.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_vec(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_vec_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_vec_sym_at(i);
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
 * Return relative .o path for std.vec (repo-relative).
 * @return *u8 — static "std/vec/vec.o"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_rel_vec(): *u8 {
  let p: *u8 = "std/vec/vec.o";
  return p;
}

/*
 * wave958: std.http on_demand probe table. Before wave958: no http probe
 * table existed; user programs using http.parse_status_line / decode_chunked
 * / has_chunked_encoding / has_keep_alive / headers_body_offset hit BLD001
 * UNDEF. All 5 symbols are in std/http/http.o. G.7: single http probe
 * authority. PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_od_http_sym_count(): i32 {
  return 5;
}

/**
 * Http on_demand UNDEF symbol at index (product probe table for needs_std_http).
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_http authority (no second table)
 */
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_http_sym_at(i: i32): *u8;


/**
 * Whether user .o references std.http API (on-demand chain std/http/http.o).
 * Pure orch: fixed http UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * PLATFORM: SHARED — G.7 single http probe authority.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_http(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_http_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_http_sym_at(i);
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
 * Return relative .o path for std.http (repo-relative).
 * @return *u8 — static "std/http/http.o"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_rel_http(): *u8 {
  let p: *u8 = "std/http/http.o";
  return p;
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

/* Class BF: labi_od_set_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_set_sym_at(i: i32): *u8;

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
 * @return i32 — 15 (empty_size smoke + Map_i32_i32 surface + str map + wave957 Map_u64_i32 surface)
 * PLATFORM: SHARED — must match formal map.o export mangles
 */
#[no_mangle]
export function labi_od_map_sym_count(): i32 {
  return 15;
}

/* Class BF: labi_od_map_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_map_sym_at(i: i32): *u8;

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

/* Class BF: labi_od_queue_api_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_queue_api_sym_at(i: i32): *u8;

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
 * Matcher is exact `xlang_undef_cache_has` (rest==len). Prefix rows never fire.
 * @return i32 — 28
 * PLATFORM: SHARED — leftover L8b is the live table; keep seed/.x/.surface twins
 */
#[no_mangle]
export function labi_od_test_sym_count(): i32 {
  // PLATFORM: SHARED — 7 historical prefix/bare + 5 std_test_* + 16 mod.x inner *_c.
  return 28;
}

/* Class BF: labi_od_test_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_test_sym_at(i: i32): *u8;

/**
 * Whether user .o references std.test API (on-demand chain test.o).
 * Pure orch: fixed test UNDEF table; Cap residual xlang_link_obj_needs_undef_sym
 * (exact cache; prefixes in the table never fire).
 * Avoids unconditional test.o on hello-class minimal links (ld duplicate risk).
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave122): hybrid still had needs_std_test body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b. Live needles = inner test_*_c (product -o
 * co-emits std_test_* wrappers as T).
 * PLATFORM: SHARED — hybrid L8b leftover is live; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
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
 * @return i32 — 31 (was 7; +volatile/fence + align_of_* + mem_swap/placeholder/is_alignment)
 * PLATFORM: SHARED — must match formal core/mem/mod.x export surface (CORE-017)
 */
#[no_mangle]
export function labi_od_core_mem_sym_count(): i32 {
  /* PLATFORM: SHARED — full core/mem/mem.o export surface (CORE-017 volatile/fence). */
  return 31;
}

/* Class BF: labi_od_core_mem_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_core_mem_sym_at(i: i32): *u8;

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
  return 9;
}

/* Class BG: labi_od_core_slice_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_core_slice_sym_at(i: i32): *u8;

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
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_page_mmap_sym_at(i: i32): *u8;


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
 * Count of sys_linux on_demand UNDEF probes (product formal .o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 34
 * PLATFORM: SHARED — must match formal std/sys/linux export surface (nested leaf sys_linux)
 */
#[no_mangle]
export function labi_od_sys_linux_sym_count(): i32 {
  // 38 since 2026-09-09: +4 xlang_sys_* FFI externs the co-emitted
  // std.sys.linux module leaves U (glue = std/sys/linux.o +
  // compiler/src/asm/freestanding_io_x86_64.o; run-process BLD001 root).
  return 38;
}

/* Class BF: labi_od_sys_linux_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_sys_linux_sym_at(i: i32): *u8;

/**
 * Whether user .o references std.sys.linux API (on-demand chain std/sys/linux.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
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
 * Count of sys_macos on_demand UNDEF probes (product formal .o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 13
 * PLATFORM: SHARED — must match formal std/sys/macos export surface (nested leaf sys_macos)
 */
#[no_mangle]
export function labi_od_sys_macos_sym_count(): i32 {
  return 13;
}

/* Class BF: labi_od_sys_macos_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_sys_macos_sym_at(i: i32): *u8;

/**
 * Whether user .o references std.sys.macos API (on-demand chain std/sys/macos.o).
 * Pure orch: fixed exact UNDEF table; Cap residual xlang_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * PLATFORM: SHARED — Darwin cfg import / macos_write_*; LINUX no-op unless needles fire.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys_macos(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_sys_macos_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_sys_macos_sym_at(i);
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

/* Class BG: labi_od_sys_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_sys_sym_at(i: i32): *u8;

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
 * @return i32 — 32
 * PLATFORM: SHARED — must match formal std/heap export surface (incl. Allocator/libc family)
 */
#[no_mangle]
export function labi_od_heap_api_sym_count(): i32 {
  return 32;
}

/* Class BF: labi_od_heap_api_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_heap_api_sym_at(i: i32): *u8;

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

/* Class BG: labi_od_heap_user_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_heap_user_sym_at(i: i32): *u8;

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

/* Class BF: labi_od_async_scheduler_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_async_scheduler_sym_at(i: i32): *u8;

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
 * Product complete set (G.7): one-shot compress2/uncompress plus gzip Init2
 * and Darwin/ELF gzip product mangles.
 * @return i32 — 22
 * PLATFORM: SHARED — Darwin gzip-only import must pull glue/-lz.
 * 16..19: facade names (`std_compress_gzip_compress`) so `xlang build`
 * user.o UNDEF fires needs_zlib while asm ld passes compress_o=NULL.
 * 20..21: stream facade (`std_compress_compress_init`) so cookbook
 * compress_stream_br_zs fires -lz (c_face dispatch U gzip stream T).
 */
#[no_mangle]
export function labi_od_zlib_undef_sym_count(): i32 {
  return 22;
}

/* Class BF: labi_od_zlib_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_zlib_undef_sym_at(i: i32): *u8;

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
 * (Cap residual has_undef_sym does substring match on UNDEF lines) plus
 * facade / submodule mangles so `xlang build` user.o fires needs_zstd while
 * asm ld passes compress_o=NULL.
 * @return i32 — 12
 * PLATFORM: SHARED — must match zstd C API surface used by product compress gate
 */
#[no_mangle]
export function labi_od_zstd_undef_sym_count(): i32 {
  return 12;
}

/* Class BF: labi_od_zstd_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_zstd_undef_sym_at(i: i32): *u8;

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
 * Product complete set (G.7): seed authority BrotliEncoderCompress + BrotliDecoderDecompress
 * plus facade / submodule mangles so `xlang build` user.o fires needs_brotli while
 * asm ld passes compress_o=NULL.
 * @return i32 — 12
 * PLATFORM: SHARED — must match brotli C API surface used by product compress gate
 */
#[no_mangle]
export function labi_od_brotli_undef_sym_count(): i32 {
  return 12;
}

/* Class BF: labi_od_brotli_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_brotli_undef_sym_at(i: i32): *u8;

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

/* Class BF: labi_od_runtime_time_os_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_runtime_time_os_sym_at(i: i32): *u8;

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

/* Class BF: labi_od_runtime_random_fill_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_runtime_random_fill_sym_at(i: i32): *u8;

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

/* Class BF: labi_od_runtime_env_os_sym_at → seeds/labi_od_needle_tables.c (always linked). */
export extern function labi_od_runtime_env_os_sym_at(i: i32): *u8;

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
 * G.7: process_argv only for bare argv glue + env args_iter (not product std_process_*).
 * Product import METHOD std_process_* opens std/process/process.o via fk==1 (OP_STD).
 * Pushing process_argv for std_process_* dual-linked with process.o (multidef args_c).
 * @return i32 — 5
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_runtime_process_argv_sym_count(): i32 {
  return 5;
}

/**
 * runtime process_argv UNDEF needle at index (exact symbols only).
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — exact match (Darwin nm -u has no type letter U)
 */
/* Class BJ: body in seeds/labi_od_needle_tables.c */
export extern function labi_od_runtime_process_argv_sym_at(i: i32): *u8;


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
