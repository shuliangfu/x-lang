/* seeds/labi_ondemand_list.from_x.c — G-02f-272 P2 link_abi L8b on_demand list pure → R2 full
 * Logic source: src/runtime/labi_ondemand_list.x
 * Hybrid: XLANG_LABI_ONDEMAND_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14 / wave118–123）：公共业务符号由 full .x 提供：
 *   simple/kv/arrow/time/queue + rel_* 纯表
 *   + labi_od_net_sym_{count,at} + link_abi_user_o_needs_std_net pure orch
 *   + labi_od_set_sym_{count,at} + link_abi_user_o_needs_std_set pure orch
 *   + labi_od_map_sym_{count,at} + link_abi_user_o_needs_std_map pure orch
 *   + labi_od_queue_api_sym_{count,at} + link_abi_user_o_needs_std_queue pure orch
 *   + labi_od_test_sym_{count,at} + link_abi_user_o_needs_std_test pure orch
 *   + labi_od_core_mem_sym_{count,at} + link_abi_user_o_needs_core_mem pure orch
 *   + labi_od_core_slice_sym_{count,at} + link_abi_user_o_needs_core_slice pure orch
 *   + labi_od_page_mmap_sym_{count,at} + link_abi_user_o_needs_std_heap_page_mmap pure orch
 *   + labi_od_sys_linux_sym_{count,at} + link_abi_user_o_needs_std_sys_linux pure orch
 *   + labi_od_sys_sym_{count,at} + link_abi_user_o_needs_std_sys pure orch
 *   + labi_od_heap_api_sym_{count,at} + link_abi_user_o_needs_std_heap_api pure orch
 *   + labi_od_heap_user_sym_{count,at} + link_abi_user_o_needs_heap_user_syms pure orch
 *   + labi_od_async_scheduler_sym_{count,at} + link_abi_user_o_needs_async_scheduler pure orch
 *   + wave131 compress family: zlib/zstd/brotli marker+undef tables + needs_compress_libs pure orch
 *   + wave132 labi_od_runtime_{time_os,random_fill,env_os}_sym_* + labi_user_needs_runtime_* pure orch
 *   + wave133 labi_od_runtime_process_argv_sym_* + labi_user_needs_runtime_process_argv pure orch
 *   + wave134 labi_od_std_task_sym_* + labi_user_needs_std_task pure orch
 *   + wave135 labi_fk0_rel/sym_* + labi_std_fk0_user_needs_rel pure orch
 *     (PRIMARY OS + TASK_SPECIAL; null/empty user_o → 1)
 *   + wave140 labi_od_provides_{core_mem,std_heap}_sym_* + link_abi_user_o_provides_* pure orch
 *     (defined T/t probes; Cap residual has_defined_sym; skip hard-link mem.o/heap.o)
 *   + wave145 link_abi_link_needs_{heap_user_c,std_heap_import} pure orch
 *     (aggregate user_o + argv .o scan via pure needs_* + ld_argv_entry_is_obj)
 *   + wave190 labi_std_fk_gate_sym_* + labi_std_fk_user_needs pure orch
 *     (fk 1–13 plan gates; Cap residual undef_sym; G.7 complete wave135 fk0 sibling)
 *   + wave197 xlang_asm_ld_append_on_demand_user_objs pure orch
 *     (product on_demand shell; Cap residual ensure/skip/path + freestanding_get + undef_sym)
 * Cap residual：ensure/skip/path Cap inside shell peers；
 *   wave210：has_undef_sym pure thin orch（null/empty）；_impl = UNDEF-cache substring 常驻 mega；
 *   wave211：exports_marker pure thin orch（null/empty）；_impl = all-names cache substring 常驻 mega；
 *   wave212：needs_undef_sym pure thin orch（null/empty）；_impl = UNDEF cache mmap 常驻 mega；
 *   wave213：has_defined_sym pure thin orch（null/empty）；_impl = T/t cache mmap 常驻 mega。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 */
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: L8b standalone ondemand seed → Cap snprintf */
/* G.7: Cap when this TU is cc'd alone (try-labi-prefer L8b); mega include already redirects. */
#undef snprintf
#define snprintf xlang_snprintf
#include "runtime_link_abi.h"

/* Class BE: bodies live in seeds/labi_od_needle_tables.c */
const char *labi_od_simple_group_sym_at(int g, int i);
const char *labi_fk0_sym_at(int k, int i);
const char *labi_std_fk_gate_sym_at(int fk, int i);
/* Class BF: single-index sym_at bodies in labi_od_needle_tables.c */
const char *labi_od_kv_sym_at(int i);
const char *labi_od_arrow_sym_at(int i);
const char *labi_od_net_sym_at(int i);
const char *labi_od_vec_sym_at(int i);
const char *labi_od_set_sym_at(int i);
const char *labi_od_map_sym_at(int i);
const char *labi_od_queue_api_sym_at(int i);
const char *labi_od_test_sym_at(int i);
const char *labi_od_core_mem_sym_at(int i);
const char *labi_od_sys_linux_sym_at(int i);
const char *labi_od_sys_macos_sym_at(int i);
const char *labi_od_heap_api_sym_at(int i);
const char *labi_od_async_scheduler_sym_at(int i);
const char *labi_od_zlib_undef_sym_at(int i);
const char *labi_od_zstd_undef_sym_at(int i);
const char *labi_od_brotli_undef_sym_at(int i);
const char *labi_od_runtime_time_os_sym_at(int i);
const char *labi_od_runtime_random_fill_sym_at(int i);
const char *labi_od_runtime_env_os_sym_at(int i);
const char *labi_od_std_task_sym_at(int i);


/* Cap residual (wave212): UNDEF cache mmap; pure owns null/empty gates. */
int xlang_link_obj_needs_undef_sym_impl(const char *user_o, const char *sym);
/* Cap residual (wave213): T/t cache mmap; pure owns null/empty gates. */
int xlang_link_obj_has_defined_sym_impl(const char *o_path, const char *sym);
/* Cap residual (wave211): all-names cache substring; pure owns null/empty gates. */
int link_abi_obj_exports_marker_impl(const char *obj_o, const char *marker);
/* Cap residual (wave210): UNDEF cache substring; pure owns null/empty gates. */
int link_abi_obj_has_undef_sym_impl(const char *obj_o, const char *sym);
/* wave145 aggregate orch Cap: path pure suffix scan (authority labi_path_pure). */
int link_abi_ld_argv_entry_is_obj(const char *s);

/* Cap residual / peer pure for wave197 on_demand shell cold twin. */
int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, int *flag_out);
/* bank opaque void* ≡ pure labi_path_pure / invoke_ld_list (G.7; L4 cold TU). */
void link_abi_asm_ld_argv_push_stable(void *bank, const char **argv, int *la, int max_la, const char *p);
const char *xlang_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, void *bank);
const char *asm_link_obj_skip_missing(const char *path);
const char *xlang_rel_o_path_from_argv0(const char *argv0, const char *rel);
const char *xlang_repo_root_from_argv0(const char *argv0);
int xlang_ensure_formal_std_make_o(const char *repo_root, const char *rel_from_repo, const char *make_target);
int driver_freestanding_get(void);
int xlang_ensure_runtime_thread_glue_o(const char *argv0);
const char *xlang_runtime_thread_glue_o_path(const char *argv0);
int xlang_ensure_runtime_http_glue_o(const char *argv0);
const char *xlang_runtime_http_glue_o_path(const char *argv0);
int xlang_ensure_runtime_atomic_glue_o(const char *argv0);
const char *xlang_runtime_atomic_glue_o_path(const char *argv0);
int xlang_ensure_runtime_net_udp_batch_o(const char *argv0);
const char *xlang_runtime_net_udp_batch_o_path(const char *argv0);
int xlang_ensure_runtime_net_workers_o(const char *argv0);
const char *xlang_runtime_net_workers_o_path(const char *argv0);
int xlang_ensure_runtime_test_fn_invoke_o(const char *argv0);
const char *xlang_runtime_test_fn_invoke_o_path(const char *argv0);
int xlang_ensure_runtime_heap_user_o(const char *argv0);
const char *xlang_runtime_heap_user_o_path(const char *argv0);
int xlang_ensure_runtime_process_argv_o(const char *argv0);
const char *xlang_runtime_process_argv_o_path(const char *argv0);
int xlang_ensure_runtime_time_os_o(const char *argv0);
const char *xlang_runtime_time_os_o_path(const char *argv0);
int xlang_ensure_runtime_crypto_inc_glue_o(const char *argv0);
const char *xlang_runtime_crypto_inc_glue_o_path(const char *argv0);
int xlang_ensure_runtime_ed25519_ref10_glue_o(const char *argv0);
const char *xlang_runtime_ed25519_ref10_glue_o_path(const char *argv0);
int xlang_ensure_runtime_queue_contention_o(const char *argv0);
const char *xlang_runtime_queue_contention_o_path(const char *argv0);
void labi_std_append_queue_monofile_companions(const char *link_argv0, const char **lib_roots,
    int n_lib_roots, ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la, void *flags);
void labi_std_append_test_monofile_companions(const char *link_argv0, const char **lib_roots,
    int n_lib_roots, ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la);
const char *xlang_std_async_scheduler_o_path(const char *argv0);
const char *xlang_runtime_scheduler_glue_o_path(const char *argv0);
int xlang_ensure_runtime_scheduler_glue_o(const char *argv0);
const char *xlang_runtime_kv_mmap_glue_o_path(const char *argv0);
int xlang_ensure_runtime_kv_mmap_glue_o(const char *argv0);
const char *xlang_runtime_arrow_simd_glue_o_path(const char *argv0);
int xlang_ensure_runtime_arrow_simd_glue_o(const char *argv0);
void link_abi_asm_ld_push_glue_after_std(int have_std, int (*ensure_fn)(const char *), const char *glue_primary,
    const char *link_argv0, const char *glue_rel, const char **lib_roots, int n_lib_roots,
    ShuAsmLdPathBank *bank, const char **argv, int *la, int max_la);

#ifndef XLANG_LABI_ONDEMAND_LIST_FROM_X

/* wave212: needs_undef_sym pure orch cold twin (null/empty gates + Cap residual nm/ELF).
 * PLATFORM: SHARED orch; residual xlang_link_obj_needs_undef_sym_impl always mega. */
int xlang_link_obj_needs_undef_sym(const char *user_o, const char *sym) {
  if (!user_o || !user_o[0] || !sym || !sym[0])
    return 0;
  return xlang_link_obj_needs_undef_sym_impl(user_o, sym);
}

/* wave213: has_defined_sym pure orch cold twin (null/empty gates + Cap residual nm T/t).
 * PLATFORM: SHARED orch; residual xlang_link_obj_has_defined_sym_impl always mega. */
int xlang_link_obj_has_defined_sym(const char *o_path, const char *sym) {
  if (!o_path || !o_path[0] || !sym || !sym[0])
    return 0;
  return xlang_link_obj_has_defined_sym_impl(o_path, sym);
}

/* wave211: exports_marker pure orch cold twin (null/empty gates + Cap residual nm).
 * PLATFORM: SHARED orch; residual link_abi_obj_exports_marker_impl always mega. */
int link_abi_obj_exports_marker(const char *obj_o, const char *marker) {
  if (!obj_o || !obj_o[0] || !marker || !marker[0])
    return 0;
  return link_abi_obj_exports_marker_impl(obj_o, marker);
}

/* wave210: has_undef_sym pure orch cold twin (null/empty gates + Cap residual nm).
 * PLATFORM: SHARED orch; residual link_abi_obj_has_undef_sym_impl always mega. */
int link_abi_obj_has_undef_sym(const char *obj_o, const char *sym) {
  if (!obj_o || !obj_o[0] || !sym || !sym[0])
    return 0;
  return link_abi_obj_has_undef_sym_impl(obj_o, sym);
}

/* Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5
 * core_option=6 core_result=7 core_debug=8 core_slice=9 core_builtin=10 std_ffi=11.
 * PLATFORM: SHARED — g1 rel is core/types/types.o (was wrongly base64.o).
 * types/option/result/debug/slice/builtin formal .o via formal_mod + ensure; no asm co-emit hang.
 * g9 rel is core/slice/mod.o (API); glue from_ptr/subslice remains core/slice/slice.o.
 * g10 core.builtin: pure-asm emits core_builtin_* (C-path G-01 still __builtin_*).
 * g11 std.ffi: pure-asm emits std_ffi_*; formal std/ffi/ffi.o (mod.x + ffi.x). */

int labi_od_simple_group_count(void) {
  /* PLATFORM: SHARED — ≡ pure labi_ondemand_list.x (g0..g23).
   * G.7: seed cold twin must match pure table; L4 product often falls back to
   * this host-cc seed when pure prefer times out. Was return 13 with g12=simd
   * (pure g12=test / g18=simd) → run-compress UNDEF after L4 wipe.
   * g21: core.str formal (cookbook core_str_index unique UNDEF).
   * g22: core.iterator formal (cookbook iter_slice_sum unique UNDEF).
   * g23: std.bytes formal (tests/std-bytes/arena_external unique UNDEF).
   * g24: core.fmt formal (CORE-010/011 direct import).
   * g25: core.cmp formal (CORE-005 direct import Ordering/cmp_*). */
  return 26;
}

int labi_od_simple_group_sym_count(int g) {
  if (g < 0)
    return 0;
  if (g == 0)
    return 13; /* std.string — +concat_arena/view_get/length_StrView cookbook unique UNDEF */
  /* PLATFORM: SHARED — full core/types/types.o export surface (CORE-013 i16/u16). */
  if (g == 1)
    return 27;
  if (g == 2)
    return 6;
  if (g == 3)
    return 4;
  if (g == 4)
    return 5;
  if (g == 5)
    return 3;
  if (g == 6)
    return 4;
  /* PLATFORM: SHARED — core.result short API + *_i32 aliases (mirror list.x; was 4). */
  if (g == 7)
    return 10;
  if (g == 8)
    return 6;
  /* PLATFORM: SHARED — full core/slice/mod.o export surface (CORE-004). */
  if (g == 9)
    return 28;
  if (g == 10)
    return 14;
  if (g == 11)
    return 8;
  if (g == 12)
    return 5; /* std.test */
  if (g == 13)
    return 6; /* core.assert */
  if (g == 14)
    return 9; /* std.fmt — +format_template cookbook sole UNDEF */
  /* PLATFORM: SHARED — twin of labi_ondemand_list.x g==15. Needles i==24..27
   * (stream_state_bytes ×3 + brotli_stream_init_decompress_) already live
   * below; count 24 never walked them → Ubuntu run-compress UNDEF when L8c
   * prefer fails and this seed is the first-wins L8b winner (L8b 24 vs 28). */
  if (g == 15)
    return 28; /* std.compress — +4 stream needles (24→28; i==24..27) */
  if (g == 16)
    return 4; /* std.io.driver */
  if (g == 17)
    return 3; /* std.debug */
  if (g == 18)
    return 23; /* std.simd VECTOR mid + binop/dot/fma + scalar faces + select_lane */
  if (g == 19)
    return 3; /* std.io ctx-timeout STD-091 */
  /* wave957: std.unicode formal (run-unicode residual). */
  if (g == 20)
    return 8;
  /* PLATFORM: SHARED — core.str formal (cookbook core_str_index unique UNDEF).
   * Matcher exact; bytes_view often inlined so index_of* / starts_with fire.
   * Count 12 = full core/str/mod.x export surface. G.7 one table. */
  if (g == 21)
    return 12;
  /* PLATFORM: SHARED — core.iterator formal (cookbook iter_slice_sum unique UNDEF).
   * Matcher exact; no prior group. Count 10 = full core/iterator/mod.x export
   * surface. G.7 one table. */
  if (g == 22)
    return 10;
  /* PLATFORM: SHARED — std.bytes formal (tests/std-bytes/arena_external unique UNDEF).
   * Matcher exact; no prior group. Count 29 = full std/bytes/mod.x export
   * surface. G.7 one table. */
  if (g == 23)
    return 29;
  /* PLATFORM: SHARED — core.fmt formal (CORE-010/011). Count 12. G.7 one table. */
  if (g == 24)
    return 12;
  /* PLATFORM: SHARED — core.cmp formal (CORE-005). Count 12. G.7 one table. */
  if (g == 25)
    return 12;
  return 0;
}

/* Class BE: labi_od_simple_group_sym_at → seeds/labi_od_needle_tables.c (always linked). */


const char *labi_od_simple_group_rel(int g) {
  if (g < 0)
    return NULL;
  if (g == 0)
    return "std/string/string.o";
  if (g == 1)
    return "core/types/types.o";
  if (g == 2)
    return "std/encoding/encoding.o";
  if (g == 3)
    return "std/base64/base64.o";
  if (g == 4)
    return "std/csv/csv.o";
  if (g == 5)
    return "std/schema/schema.o";
  if (g == 6)
    return "core/option/option.o";
  if (g == 7)
    return "core/result/result.o";
  if (g == 8)
    return "core/debug/debug.o";
  if (g == 9)
    return "core/slice/mod.o";
  if (g == 10)
    return "core/builtin/builtin.o";
  if (g == 11)
    return "std/ffi/ffi.o";
  if (g == 12)
    return "std/test/test.o";
  if (g == 13)
    return "core/assert/assert.o";
  if (g == 14)
    return "std/fmt/fmt.o";
  if (g == 15)
    return "std/compress/compress.o";
  if (g == 16)
    return "std/io/driver.o";
  if (g == 17)
    return "std/debug/debug.o";
  if (g == 18)
    return "std/simd/simd.o";
  if (g == 19)
    return "std/io/io.o";
  /* wave957: std.unicode formal product .o (run-unicode residual). */
  if (g == 20)
    return "std/unicode/unicode.o";
  /* PLATFORM: SHARED — core.str formal product .o (cookbook core_str_index). */
  if (g == 21)
    return "core/str/mod.o";
  /* PLATFORM: SHARED — core.iterator formal product .o (cookbook iter_slice_sum). */
  if (g == 22)
    return "core/iterator/mod.o";
  /* PLATFORM: SHARED — std.bytes formal product .o (tests/std-bytes/arena_external). */
  if (g == 23)
    return "std/bytes/bytes.o";
  /* PLATFORM: SHARED — core.fmt formal product .o (CORE-010/011). */
  if (g == 24)
    return "core/fmt/mod.o";
  /* PLATFORM: SHARED — core.cmp formal product .o (CORE-005). */
  if (g == 25)
    return "core/cmp/mod.o";
  return NULL;
}

/* KV: multi-sym → kv.o + optional glue rel.
 * PLATFORM: SHARED — cookbook db_kv_arrow unique-first (mmap_available /
 * open / close / append_ts / get / wal_flush / compact / sst_level_count),
 * then remaining unique std.db.kv export faces, then legacy C ABI.
 * Matcher is exact; C ABI names never fire import METHOD std_db_kv_*. */
int labi_od_kv_sym_count(void) {
  return 14;
}

/* Class BF: labi_od_kv_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_kv_sym_at(int i);

const char *labi_od_kv_rel(void) {
  return "std/db/kv/kv.o";
}

const char *labi_od_kv_glue_rel(void) {
  return "compiler/runtime_kv_mmap_glue.o";
}

/* Arrow.
 * PLATFORM: SHARED — cookbook db_kv_arrow unique-first (adopt_f32_ptr_i32_i32 /
 * sum / dot / free_ArrowColumn), then remaining unique std.db.arrow export
 * faces, then legacy C ABI. Matcher is exact. */
int labi_od_arrow_sym_count(void) {
  return 29;
}

/* Class BF: labi_od_arrow_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_arrow_sym_at(int i);

const char *labi_od_arrow_rel(void) {
  return "std/db/arrow/arrow.o";
}

const char *labi_od_arrow_glue_rel(void) {
  return "compiler/runtime_arrow_simd_glue.o";
}

/* PLATFORM: SHARED — cookbook async_mod_import / drain_idle / scheduler_reset /
 * net_fs_async_smoke unique-first.
 * Distinct from labi_od_async_scheduler_sym_* (C ABI ×35 for scheduler.o
 * skip-missing; never unique import METHOD std_async_*). Matcher is exact.
 * Produce path is formal_mod c_face std/async/async.o (not host-cc of mod.x). */
int labi_od_async_sym_count(void) {
  return 4;
}

const char *labi_od_async_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_async_placeholder";
  if (i == 1)
    return "std_async_drain_idle";
  /* import("std.async").scheduler_reset → mangled unique METHOD. */
  if (i == 2)
    return "std_async_scheduler_reset";
  /* import("std.async").net_fs_async_smoke → mangled unique METHOD. */
  if (i == 3)
    return "std_async_net_fs_async_smoke";
  return NULL;
}

const char *labi_od_async_rel(void) {
  return "std/async/async.o";
}

/* Time */
int labi_od_time_sym_count(void) {
  return 4;
}

const char *labi_od_time_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_time_now_monotonic_ns";
  if (i == 1)
    return "std_time_sleep_ms";
  if (i == 2)
    return "std_time_timer_start";
  if (i == 3)
    return "time_now_monotonic_ns_c";
  return NULL;
}

const char *labi_od_time_rel(void) {
  return "std/time/time.o";
}

const char *labi_od_time_os_rel(void) {
  return "compiler/runtime_time_os.o";
}

/* Queue contention */
int labi_od_queue_sym_count(void) {
  return 3;
}

const char *labi_od_queue_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "sync_queue_contention_smoke_c";
  if (i == 1)
    return "queue_os_run_two_workers_c";
  if (i == 2)
    return "queue_contention_worker_push_c";
  return NULL;
}

const char *labi_od_queue_rel(void) {
  return "std/queue/queue.o";
}

const char *labi_od_queue_contention_rel(void) {
  return "compiler/runtime_queue_contention.o";
}

/* wave118: net UNDEF table + needs_std_net pure orch. PLATFORM: SHARED.
 * Count 34: +new/smoke/acquire/release unique tcp_pool wrappers + net_resolve_ipv4/ipv6_ex_c (9.1.7). */
int labi_od_net_sym_count(void) { return 34; }
/* Class BF: labi_od_net_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_net_sym_at(int i);

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_net(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_net_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_net_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/*
 * wave956: std.thread on_demand probe table + needs_std_thread pure orch.
 * Before wave956: asm on_demand only pushed thread.o inside need_net block;
 * user programs importing only std.thread never got thread.o. Twin of
 * labi_od_net_sym_* / link_abi_user_o_needs_std_net. PLATFORM: SHARED.
 */
int labi_od_thread_sym_count(void) { return 4; }
const char *labi_od_thread_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_thread_create";
  if (i == 1)
    return "std_thread_join";
  if (i == 2)
    return "std_thread_start";
  if (i == 3)
    return "std_thread_stats";
  return NULL;
}

int link_abi_user_o_needs_std_thread(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_thread_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_thread_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/*
 * wave958: std.vec on_demand probe table + needs_std_vec pure orch.
 * Twin of labi_od_thread_sym_* / link_abi_user_o_needs_std_thread.
 * PLATFORM: SHARED.
 */
int labi_od_vec_sym_count(void) { return 44; }
/* Class BF: labi_od_vec_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_vec_sym_at(int i);

int link_abi_user_o_needs_std_vec(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_vec_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_vec_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/*
 * wave958: std.http on_demand probe table + needs_std_http pure orch.
 * Twin of labi_od_thread_sym_* / link_abi_user_o_needs_std_thread.
 * PLATFORM: SHARED.
 */
int labi_od_http_sym_count(void) { return 5; }
const char *labi_od_http_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_http_parse_status_line";
  if (i == 1)
    return "std_http_decode_chunked_body";
  if (i == 2)
    return "std_http_has_chunked_encoding";
  if (i == 3)
    return "std_http_has_keep_alive";
  if (i == 4)
    return "std_http_headers_body_offset";
  return NULL;
}

int link_abi_user_o_needs_std_http(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_http_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_http_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave119: set UNDEF table + needs_std_set pure orch. PLATFORM: SHARED. */
int labi_od_set_sym_count(void) { return 20; }
/* Class BF: labi_od_set_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_set_sym_at(int i);

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_set(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_set_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_set_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave120: map UNDEF table + needs_std_map pure orch. PLATFORM: SHARED. */
int labi_od_map_sym_count(void) { return 15; }
/* Class BF: labi_od_map_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_map_sym_at(int i);

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_map(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_map_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_map_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave121: product queue UNDEF table + needs_std_queue pure orch.
 * PLATFORM: SHARED — separate from contention labi_od_queue_sym_* (3 smoke/os symbols). */
int labi_od_queue_api_sym_count(void) { return 12; }
/* Class BF: labi_od_queue_api_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_queue_api_sym_at(int i);

/* Pure orch: product table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_queue(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_queue_api_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_queue_api_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave122: product test UNDEF table + needs_std_test pure orch.
 * PLATFORM: SHARED — matcher is exact xlang_undef_cache_has (rest==len).
 * Prefixes (test_expect_ etc.) never fire. Product asm -o co-emits std_test_*
 * wrappers as T, so inner test_*_c are the live UNDEF needles (≡ json/channel/heap
 * leftover exact-needle class). Count 28 = 7 historical prefix/bare + 5 std_test_*
 * faces + 16 mod.x inner *_c. G.7 complete existing table (no second list). */
int labi_od_test_sym_count(void) { return 28; }
/* Class BF: labi_od_test_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_test_sym_at(int i);

/* Pure orch: test table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_test(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_test_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_test_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave123 + CORE-017: product core.mem exact UNDEF table + needs_core_mem pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes).
 * Was 7 (align/mem_* only): sole volatile/fence UNDEF never opened mem.o → BLD001.
 * Count 31 = full core/mem/mod.x export surface (G.7 one table; seed twin of .x). */
int labi_od_core_mem_sym_count(void) { return 31; }
/* Class BF: labi_od_core_mem_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_core_mem_sym_at(int i);

/* Pure orch: core_mem table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_core_mem(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_core_mem_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_core_mem_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave124: product core.slice exact UNDEF table + needs_core_slice pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_core_slice_sym_count(void) { return 9; }
/* Class BG: labi_od_core_slice_sym_at → needle tables */
const char *labi_od_core_slice_sym_at(int i);

/* Pure orch: core_slice table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_core_slice(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_core_slice_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_core_slice_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave125: product std.heap.page_mmap exact UNDEF table + needs_std_heap_page_mmap pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_page_mmap_sym_count(void) { return 5; }
const char *labi_od_page_mmap_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_heap_page_mmap_page_mmap_heap_available";
  if (i == 1)
    return "std_heap_page_mmap_page_mmap_heap_init";
  if (i == 2)
    return "std_heap_page_mmap_page_mmap_heap_alloc";
  if (i == 3)
    return "std_heap_page_mmap_page_mmap_heap_deinit";
  if (i == 4)
    return "std_heap_page_mmap_page_mmap_heap_free";
  return NULL;
}

/* Pure orch: page_mmap table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_heap_page_mmap(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_page_mmap_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_page_mmap_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* product sys_linux exact UNDEF table + needs pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
/* 38 since 2026-09-09: +4 xlang_sys_* FFI externs the co-emitted
 * std.sys.linux module leaves U (glue = std/sys/linux.o +
 * compiler/src/asm/freestanding_io_x86_64.o; hosted user programs
 * importing std.process died BLD001 — run-process FAIL root).
 * Mirrors the .x twin. */
int labi_od_sys_linux_sym_count(void) { return 38; }
/* Class BF: labi_od_sys_linux_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_sys_linux_sym_at(int i);

int link_abi_user_o_needs_std_sys_linux(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_sys_linux_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_sys_linux_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* product sys_macos exact UNDEF table + needs pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_sys_macos_sym_count(void) { return 13; }
/* Class BF: labi_od_sys_macos_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_sys_macos_sym_at(int i);

int link_abi_user_o_needs_std_sys_macos(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_sys_macos_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_sys_macos_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave127: product std.sys facade exact UNDEF table + needs_std_sys pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_sys_sym_count(void) { return 8; }
/* Class BG: labi_od_sys_sym_at → needle tables */
const char *labi_od_sys_sym_at(int i);

/* Pure orch: sys table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_sys(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_sys_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_sys_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave128: product std.heap formal API exact UNDEF table + needs_std_heap_api pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_heap_api_sym_count(void) { return 32; }
/* Class BF: labi_od_heap_api_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_heap_api_sym_at(int i);

/* Pure orch: heap_api table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_heap_api(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_heap_api_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_heap_api_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave129: product runtime_heap_user exact UNDEF table + needs_heap_user_syms pure orch.
 * PLATFORM: SHARED — exact symbols only; product complete includes with_arena init/deinit. */
int labi_od_heap_user_sym_count(void) { return 7; }
/* Class BG: labi_od_heap_user_sym_at → needle tables */
const char *labi_od_heap_user_sym_at(int i);

/* Pure orch: heap_user table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_heap_user_syms(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_heap_user_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_heap_user_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave130: product async scheduler exact UNDEF table + needs_async_scheduler pure orch.
 * PLATFORM: SHARED — exact symbols only; product complete coop/cps/frame/run/task/worker/io. */
int labi_od_async_scheduler_sym_count(void) { return 35; }
/* Class BF: labi_od_async_scheduler_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_async_scheduler_sym_at(int i);

/* Pure orch: async_scheduler table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_async_scheduler(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_async_scheduler_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_async_scheduler_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave131: product compress family marker + UNDEF/prefix tables + pure orch.
 * PLATFORM: SHARED — Cap residual exports_marker + has_undef_sym (popen/nm). */
int labi_od_zlib_undef_sym_count(void) { return 22; }
/* Class BF: labi_od_zlib_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_zlib_undef_sym_at(int i);
const char *labi_od_compress_zlib_marker(void) { return "xlang_compress_zlib_marker"; }

int labi_od_zstd_undef_sym_count(void) { return 12; }
/* Class BF: labi_od_zstd_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_zstd_undef_sym_at(int i);
const char *labi_od_compress_zstd_marker(void) { return "xlang_compress_zstd_marker"; }

int labi_od_brotli_undef_sym_count(void) { return 12; }
/* Class BF: labi_od_brotli_undef_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_brotli_undef_sym_at(int i);
const char *labi_od_compress_brotli_marker(void) { return "xlang_compress_brotli_marker"; }

/* Pure orch: zlib marker + exact UNDEF table + Cap residual. PLATFORM: SHARED. */
int link_abi_obj_needs_zlib(const char *obj_o) {
  int n;
  int i;
  const char *marker;
  if (!obj_o || !obj_o[0])
    return 0;
  marker = labi_od_compress_zlib_marker();
  if (marker && marker[0] && link_abi_obj_exports_marker(obj_o, marker) != 0)
    return 1;
  n = labi_od_zlib_undef_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_zlib_undef_sym_at(i);
    if (sym && sym[0] && link_abi_obj_has_undef_sym(obj_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* Pure orch: zstd marker + prefix needles + Cap residual. PLATFORM: SHARED. */
int link_abi_obj_needs_zstd(const char *obj_o) {
  int n;
  int i;
  const char *marker;
  if (!obj_o || !obj_o[0])
    return 0;
  marker = labi_od_compress_zstd_marker();
  if (marker && marker[0] && link_abi_obj_exports_marker(obj_o, marker) != 0)
    return 1;
  n = labi_od_zstd_undef_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_zstd_undef_sym_at(i);
    if (sym && sym[0] && link_abi_obj_has_undef_sym(obj_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* Pure orch: brotli marker + exact UNDEF table + Cap residual. PLATFORM: SHARED. */
int link_abi_obj_needs_brotli(const char *obj_o) {
  int n;
  int i;
  const char *marker;
  if (!obj_o || !obj_o[0])
    return 0;
  marker = labi_od_compress_brotli_marker();
  if (marker && marker[0] && link_abi_obj_exports_marker(obj_o, marker) != 0)
    return 1;
  n = labi_od_brotli_undef_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_brotli_undef_sym_at(i);
    if (sym && sym[0] && link_abi_obj_has_undef_sym(obj_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* Pure orch: OR of three compress leaves. PLATFORM: SHARED. */
int link_abi_user_o_needs_compress_libs(const char *user_o) {
  if (link_abi_obj_needs_zlib(user_o) != 0)
    return 1;
  if (link_abi_obj_needs_zstd(user_o) != 0)
    return 1;
  if (link_abi_obj_needs_brotli(user_o) != 0)
    return 1;
  return 0;
}

/* wave132–134: bulk PRIMARY OS + TASK_SPECIAL pure tables + orch.
 * PLATFORM: SHARED — exact symbols only; null/empty user_o → 1 legacy hard-link.
 * wave133: process_argv pure; wave134: std_task pure (single-leaf after capacity clip). */
int labi_od_runtime_time_os_sym_count(void) { return 10; }
/* Class BF: labi_od_runtime_time_os_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_runtime_time_os_sym_at(int i);
int labi_user_needs_runtime_time_os(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_time_os_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_time_os_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

int labi_od_runtime_random_fill_sym_count(void) { return 12; }
/* Class BF: labi_od_runtime_random_fill_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_runtime_random_fill_sym_at(int i);
int labi_user_needs_runtime_random_fill(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_random_fill_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_random_fill_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

int labi_od_runtime_env_os_sym_count(void) { return 19; }
/* Class BF: labi_od_runtime_env_os_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_runtime_env_os_sym_at(int i);
int labi_user_needs_runtime_env_os(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_env_os_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_env_os_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave133: process_argv pure table + orch (5 needles).
 * PLATFORM: SHARED — product std_process_* is fk==1 → process.o (not process_argv).
 * Twin of labi_ondemand_list.x (G.7 seed/.x same commit). */
int labi_od_runtime_process_argv_sym_count(void) { return 5; }
const char *labi_od_runtime_process_argv_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "process_xlang_argc_get";
  if (i == 1)
    return "process_xlang_argv_get";
  if (i == 2)
    return "process_arg_c";
  if (i == 3)
    return "process_args_count_c";
  if (i == 4)
    return "std_env_args_iter";
  return NULL;
}
int labi_user_needs_runtime_process_argv(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_process_argv_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_process_argv_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave134: std_task pure table + orch (29 needles; TASK_SPECIAL). */
int labi_od_std_task_sym_count(void) { return 29; }
/* Class BF: labi_od_std_task_sym_at → seeds/labi_od_needle_tables.c (always linked). */
const char *labi_od_std_task_sym_at(int i);
int labi_user_needs_std_task(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_std_task_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_std_task_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}


/* wave135: labi_std_fk0_user_needs_rel pure cold twin (tables + orch).
 * PLATFORM: SHARED — must mirror labi_ondemand_heavy.x (G.7 single authority).
 * Product/cold both hit this TU when PREFER_X_O falls back or FROM_X off.
 * Was return 16 (fs last): ac064cc62/2d8b92871 pure+surface added tar/unicode/
 * runtime but cold twin lagged → Ubuntu product labi_fk0_rel_count still 0x10
 * → never open std/tar/tar.o gate → run-tar UNDEF std_tar_{read,write}_header
 * even when formal tar.o has T surface (soft first-red @bbb6646d0). */
int labi_fk0_rel_count(void) {
  /* PLATFORM: SHARED — was 25; +option +result (=heavy return 27). */
  return 27;
}
const char *labi_fk0_rel_at(int k) {

  if (k == 0)
    return "std/string/string.o";
  if (k == 1)
    return "std/encoding/encoding.o";
  if (k == 2)
    return "std/base64/base64.o";
  if (k == 3)
    return "std/http/http.o";
  if (k == 4)
    return "std/json/json.o";
  if (k == 5)
    return "std/csv/csv.o";
  if (k == 6)
    return "std/path/path.o";
  if (k == 7)
    return "std/hash/hash.o";
  if (k == 8)
    return "std/error/error.o";
  if (k == 9)
    return "std/context/context.o";
  if (k == 10)
    return "std/vec/vec.o";
  if (k == 11)
    return "std/sort/sort.o";
  if (k == 12)
    return "std/env/env.o";
  if (k == 13)
    return "std/random/random.o";
  if (k == 14)
    return "std/time/time.o";
  if (k == 15)
    return "std/fs/fs.o";
  /* PLATFORM: SHARED — mirror heavy k16–18 (pure-asm soft residual class). */
  if (k == 16)
    return "std/tar/tar.o";
  if (k == 17)
    return "std/unicode/unicode.o";
  if (k == 18)
    return "std/runtime/runtime.o";
  /* PLATFORM: SHARED — mirror heavy k19 (cookbook cli_subcommand). */
  if (k == 19)
    return "std/cli/cli.o";
  /* PLATFORM: SHARED — mirror heavy k20 (cookbook datetime_iana). */
  if (k == 20)
    return "std/datetime/datetime.o";
  /* PLATFORM: SHARED — mirror heavy k21 (STD-086 std_config_*). */
  if (k == 21)
    return "std/config/config.o";
  /* PLATFORM: SHARED — mirror heavy k22 (STD-087 std_cache_*). */
  if (k == 22)
    return "std/cache/cache.o";
  /* PLATFORM: SHARED — mirror heavy k23 (STD-076 std_url_*). */
  if (k == 23)
    return "std/url/url.o";
  /* PLATFORM: SHARED — mirror heavy k24 (STD-079 std_security_*). */
  if (k == 24)
    return "std/security/security.o";
  /* PLATFORM: SHARED — mirror heavy k25 (STD-080 std_option_*). */
  if (k == 25)
    return "std/option/option.o";
  /* PLATFORM: SHARED — mirror heavy k26 (STD-081 std_result_*). */
  if (k == 26)
    return "std/result/result.o";
  return NULL;
}

int labi_fk0_sym_count(int k) {

  if (k == 0)
    return 11;
  if (k == 1)
    return 2;
  if (k == 2)
    return 2;
  if (k == 3)
    return 4;
  /* PLATFORM: SHARED — json.o fk0 gate (mirror labi_ondemand_heavy.x).
   * std_json_parse* needles miss after asm co-emit of wrappers (T in user.o);
   * sole UNDEF is json_parse_*_c. Parse/skip family including bare *_c. */
  if (k == 4)
    return 12;
  if (k == 5)
    return 4;
  /* PLATFORM: SHARED — path.o fk0 complete (mirror labi_ondemand_heavy.x).
   * Was: join/dirname/empty_len/basename only. Sole sep/clean/extension UNDEF
   * never opened gate (run-path extension_stem_abs_clean). */
  if (k == 6)
    return 12;
  if (k == 7)
    return 11;
  /* PLATFORM: SHARED — error.o fk0 complete (mirror heavy.x; was 4).
   * EXC soft SKIP: sole code_invalid/io_err_generic/chain_* never opened gate.
   * G.7: every public std_error_* export ×57. */
  if (k == 8)
    return 57;
  if (k == 9)
    return 4;
  if (k == 10)
    return 42;
  if (k == 11)
    return 9;
  if (k == 12)
    /* PLATFORM: SHARED — +args_iter_*_c (mirror heavy; env_iter leftover UNDEF). */
    return 13;
  if (k == 13)
    return 12;
  if (k == 14)
    return 15;
  /* PLATFORM: SHARED — fs fk0 complete (mirror heavy.x): +readv_buf/writev_buf +stat +dir_{open,read,close}. */
  if (k == 15)
    return 15;
  /* PLATFORM: SHARED — tar/unicode/runtime formal public surface (mirror heavy). */
  if (k == 16)
    return 7;
  if (k == 17)
    return 6;
  if (k == 18)
    return 5;
  /* PLATFORM: SHARED — cli formal public surface (mirror heavy). */
  if (k == 19)
    return 10;
  /* PLATFORM: SHARED — datetime formal public surface (mirror heavy). */
  if (k == 20)
    return 27;
  /* PLATFORM: SHARED — config formal public surface (mirror heavy). */
  if (k == 21)
    return 31;
  /* PLATFORM: SHARED — cache formal public surface (mirror heavy). */
  if (k == 22)
    return 20;
  /* PLATFORM: SHARED — url formal public surface (mirror heavy). */
  if (k == 23)
    return 10;
  /* PLATFORM: SHARED — security formal public surface (mirror heavy). */
  if (k == 24)
    return 16;
  /* PLATFORM: SHARED — option formal public surface (mirror heavy). */
  if (k == 25)
    return 11;
  /* PLATFORM: SHARED — result formal public surface (mirror heavy). */
  if (k == 26)
    return 11;
  return 0;
}

/* Class BE: labi_fk0_sym_at → seeds/labi_od_needle_tables.c (always linked). */


int labi_std_fk0_user_needs_rel(const char *user_o, const char *rel) {
  int nk;
  int k;
  int kind;
  int n;
  int i;
  if (!rel || !rel[0])
    return 0;
  if (!user_o || !user_o[0])
    return 1;
  nk = labi_fk0_rel_count();
  kind = -1;
  for (k = 0; k < nk; k++) {
    const char *needle = labi_fk0_rel_at(k);
    if (needle && needle[0] && strstr(rel, needle) != NULL) {
      kind = k;
      break;
    }
  }
  if (kind < 0)
    return 0;
  n = labi_fk0_sym_count(kind);
  for (i = 0; i < n; i++) {
    const char *sym = labi_fk0_sym_at(kind, i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave190: labi_std_fk_user_needs pure cold twin (fk 1–13 gate tables + orch).
 * Cap residual: xlang_link_obj_needs_undef_sym. PLATFORM: SHARED. */
int labi_std_fk_gate_sym_count(int fk) {
  /* PLATFORM: SHARED — process product face complete (pure-asm std_process_*). */
  if (fk == 1) return 28;
  if (fk == 2) return 16; /* pool/name/affinity + create/join — twin labi_ondemand_heavy.x */
  if (fk == 3) return 5;
  if (fk == 4) return 3;
  if (fk == 5) return 5;
  /* PLATFORM: SHARED — std/atomic complete surface (10.4.1 widen i16/u16/i64/u64 support). */
  if (fk == 6) return 32;
  /* PLATFORM: SHARED — twin labi_ondemand_heavy.x fk7=19.
   * Live Ubuntu L8b was count=4 (std_channel_send/recv + channel_send/recv);
   * asm -o co-emits std_channel_* as T; sole UNDEF channel_i32_free_c
   * (run-channel). Exact matcher; G.7 complete i32 wrapper faces. */
  if (fk == 7) return 19;
  if (fk == 8) return 2;
  /* PLATFORM: SHARED — runtime_math_libm freestanding face gate completion
   * (9.2.4 Fix F). Was 29 needles; the 31 freestanding C-ABI faces
   * (math_acos_c .. math_special_near) were absent, so a user TU whose only
   * UNDEFs are e.g. math_fmin_c/math_fmax_c never opened the fk9 gate and
   * the std/math/math.o plan leaf stayed closed -> UNDEF at ld.
   * Twin of labi_ondemand_heavy.x labi_std_fk_gate_sym_count (fk9 = 60). */
  if (fk == 9) return 60;
  /* PLATFORM: SHARED — cookbook sqlite_available unique UNDEF (is_available).
   * Was 3 needles; matcher exact so prefix std_db_sqlite never fires.
   * Twin of labi_ondemand_heavy.x. 29 unique import faces + legacy 3 + db_open_c. */
  if (fk == 10) return 33;
  if (fk == 11) return 2;
  if (fk == 12) return 4;
  if (fk == 13) return 5;
  return 0;
}

/* Class BE: labi_std_fk_gate_sym_at → seeds/labi_od_needle_tables.c (always linked). */


int labi_std_fk_user_needs(const char *user_o, int fk) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_std_fk_gate_sym_count(fk);
  if (n <= 0)
    return 1;
  for (i = 0; i < n; i++) {
    const char *sym = labi_std_fk_gate_sym_at(fk, i);
    if (sym && sym[0] && xlang_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave140: user.o provides_core_mem/std_heap defined-sym tables + pure orch.
 * Cap residual: xlang_link_obj_has_defined_sym (popen/nm). PLATFORM: SHARED. */
int labi_od_provides_core_mem_sym_count(void) { return 2; }
const char *labi_od_provides_core_mem_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "core_mem_mem_copy";
  if (i == 1)
    return "core_mem_placeholder";
  return NULL;
}

int link_abi_user_o_provides_core_mem(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_provides_core_mem_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_provides_core_mem_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_has_defined_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

int labi_od_provides_std_heap_sym_count(void) { return 2; }
const char *labi_od_provides_std_heap_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_heap_libc_heap_alloc_c";
  if (i == 1)
    return "std_heap_alloc_usize";
  return NULL;
}

int link_abi_user_o_provides_std_heap(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_provides_std_heap_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_provides_std_heap_sym_at(i);
    if (sym && sym[0] && xlang_link_obj_has_defined_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave145: aggregate link_needs_heap_user_c / std_heap_import pure orch.
 * user_o probe + argv .o scan; Cap residual: none new (reuses needs_* + is_obj).
 * PLATFORM: SHARED. */
int link_abi_link_needs_heap_user_c(const char *user_o, const char **argv, int la) {
  int i;
  if (user_o && user_o[0] && link_abi_user_o_needs_heap_user_syms(user_o))
    return 1;
  if (!argv || la <= 0)
    return 0;
  for (i = 0; i < la && argv[i]; i++) {
    if (!link_abi_ld_argv_entry_is_obj(argv[i]))
      continue;
    if (link_abi_user_o_needs_heap_user_syms(argv[i]))
      return 1;
  }
  return 0;
}

int link_abi_link_needs_std_heap_import(const char *user_o, const char **argv, int la) {
  int i;
  if (user_o && user_o[0] && link_abi_user_o_needs_std_heap_api(user_o))
    return 1;
  if (!argv || la <= 0)
    return 0;
  for (i = 0; i < la && argv[i]; i++) {
    if (!link_abi_ld_argv_entry_is_obj(argv[i]))
      continue;
    if (link_abi_user_o_needs_std_heap_api(argv[i]))
      return 1;
  }
  return 0;
}

/* Pure rel constants for needs_* driven branches (early on_demand). */
const char *labi_od_rel_net(void) { return "std/net/net.o"; }
/* PLATFORM: SHARED — net.o transitive U std_error_* / std_context_*; ≡ pure .x. */
const char *labi_od_rel_error(void) { return "std/error/error.o"; }
const char *labi_od_rel_context(void) { return "std/context/context.o"; }
const char *labi_od_rel_atomic_glue(void) { return "compiler/runtime_atomic_glue.o"; }
const char *labi_od_rel_thread(void) { return "std/thread/thread.o"; }
/* wave958: std.vec / std.http on_demand rel constants. PLATFORM: SHARED. */
const char *labi_od_rel_vec(void) { return "std/vec/vec.o"; }
const char *labi_od_rel_http(void) { return "std/http/http.o"; }
const char *labi_od_rel_heap(void) { return "std/heap/heap.o"; }
const char *labi_od_rel_set(void) { return "std/set/set.o"; }
const char *labi_od_rel_map(void) { return "std/map/map.o"; }
const char *labi_od_rel_async_scheduler(void) { return "std/async/scheduler.o"; }
const char *labi_od_rel_core_mem(void) { return "core/mem/mem.o"; }
const char *labi_od_rel_sys_linux(void) { return "std/sys/linux.o"; }
const char *labi_od_rel_sys_macos(void) { return "std/sys/macos.o"; }
const char *labi_od_rel_page_mmap(void) { return "std/heap/page_mmap.o"; }
const char *labi_od_rel_sys(void) { return "std/sys/sys.o"; }
const char *labi_od_rel_core_slice(void) { return "core/slice/slice.o"; }
const char *labi_od_rel_test(void) { return "std/test/test.o"; }
const char *labi_od_rel_heap_user(void) { return "compiler/runtime_heap_user.o"; }
const char *labi_od_rel_scheduler_glue(void) { return "compiler/runtime_scheduler_glue.o"; }
const char *labi_od_rel_thread_glue(void) { return "compiler/runtime_thread_glue.o"; }
/* wave958: http glue companion .o path for std.http on_demand ensure. */
const char *labi_od_rel_http_glue(void) { return "compiler/runtime_http_glue.o"; }
const char *labi_od_rel_net_udp_batch(void) { return "compiler/runtime_net_udp_batch.o"; }
const char *labi_od_rel_net_workers(void) { return "compiler/runtime_net_workers.o"; }
const char *labi_od_rel_test_fn_invoke(void) { return "compiler/runtime_test_fn_invoke.o"; }

/* wave197: on_demand product shell cold twin (≡ mega pre-wave197 / pure .x). */
/* local helper: any of pure-table syms undefined in user_o (nm). */
static int labi_od_user_needs_any_sym_table(const char *user_o, int n, const char *(*sym_at)(int)) {
    int i;
    if (!user_o || !user_o[0] || n <= 0 || !sym_at)
        return 0;
    for (i = 0; i < n; i++) {
        const char *s = sym_at(i);
        if (s && s[0] && xlang_link_obj_needs_undef_sym(user_o, s))
            return 1;
    }
    return 0;
}

static int labi_od_user_needs_simple_group(const char *user_o, int g) {
    int n = labi_od_simple_group_sym_count(g);
    int i;
    if (!user_o || !user_o[0] || n <= 0)
        return 0;
    for (i = 0; i < n; i++) {
        const char *s = labi_od_simple_group_sym_at(g, i);
        if (s && s[0] && xlang_link_obj_needs_undef_sym(user_o, s))
            return 1;
    }
    return 0;
}

/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
/* G-02f-272：on_demand 列表纯表 + 本函数 IO 解释 */
void xlang_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags) {
#if defined(__linux__) || defined(__APPLE__)
    const char *p;
    int sg;
    if (!user_o || !user_o[0] || !la || *la >= max_la - 1)
        return;
    if (link_abi_user_o_needs_std_net(user_o)) {
        int have_net = 0;
        /* PLATFORM: SHARED — L4 wipe deletes net.o; push_obj skip-missing is
         * not enough (≡ need_sys). Cookbook net_listen_bind UNDEF std_net_listen
         * / close_listener while needles already fire. Produce path is existing
         * net_merge via compiler-make try-heat (not formal_mod). G.7: complete
         * existing need_net path with ensure; do not add a second simple-group
         * or convert net_merge into formal_mod. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)xlang_ensure_formal_std_make_o(include_root, "std/net/net.o",
                                                    "../std/net/net.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_net(), lib_roots, n_lib_roots, bank, argv, la, max_la, &have_net);
        if (have_net) {
            if (flags)
                flags->have_net = 1;
            /* PLATFORM: SHARED — net.o U error/context; user needles miss. ≡ C need_context.
             * G.7 companions: error formal + context formal + atomic_glue + time_os. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0]) {
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/error/error.o",
                                                        "../std/error/error.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/context/context.o",
                                                        "../std/context/context.o");
                }
                link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_error(), lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_context(), lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_atomic_glue_o,
                    xlang_runtime_atomic_glue_o_path(link_argv0), link_argv0,
                    labi_od_rel_atomic_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
                link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_time_os_o,
                    xlang_runtime_time_os_o_path(link_argv0), link_argv0,
                    labi_od_time_os_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            /* workers.x / net_run_accept_workers_c U thread_create_c (thread_glue).
             * PLATFORM: SHARED — L4 wipe deletes thread.o; skip-missing never
             * pushes glue. Darwin -dead_strip hid unused workers T; Ubuntu gold
             * exposes UNDEF. G.7 complete existing need_net thread companion
             * with formal ensure (≡ error/context); do not add a second table. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/thread/thread.o",
                                                        "../std/thread/thread.o");
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_thread(), lib_roots, n_lib_roots, bank, argv, la, max_la,
                flags ? &flags->have_thread : NULL);
            if (flags && flags->have_thread) {
                link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_thread_glue_o,
                    xlang_runtime_thread_glue_o_path(link_argv0), link_argv0,
                    labi_od_rel_thread_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
            link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_net_udp_batch_o,
                xlang_runtime_net_udp_batch_o_path(link_argv0), link_argv0,
                labi_od_rel_net_udp_batch(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_net_workers_o,
                xlang_runtime_net_workers_o_path(link_argv0), link_argv0,
                labi_od_rel_net_workers(), lib_roots, n_lib_roots, bank, argv, la, max_la);
        }
    }
    /*
     * wave956: standalone std.thread on_demand (independent of need_net).
     * Before wave956: thread.o + thread_glue.o were only pushed inside the
     * need_net block above; user programs importing only std.thread (no
     * std.net) never triggered thread.o ensure → BLD001 UNDEF std_thread_*.
     * Probe: link_abi_user_o_needs_std_thread scans labi_od_thread_sym_*
     * (std_thread_create / join / start / stats). When hit, push thread.o
     * then ensure + push thread_glue.o (same as the net-embedded thread
     * path). Skip if need_net already pushed thread.o (flags->have_thread).
     * PLATFORM: SHARED. G.7: single thread ensure path (table + this block).
     */
    if (link_abi_user_o_needs_std_thread(user_o)) {
        int already_th = (flags && flags->have_thread);
        if (!already_th) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_thread(), lib_roots, n_lib_roots,
                                     bank, argv, la, max_la, flags ? &flags->have_thread : NULL);
            if (flags && flags->have_thread) {
                link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_thread_glue_o,
                    xlang_runtime_thread_glue_o_path(link_argv0), link_argv0,
                    labi_od_rel_thread_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
            }
        }
    }
    /*
     * wave958: standalone std.vec on_demand. PLATFORM: SHARED.
     * Probe: link_abi_user_o_needs_std_vec scans labi_od_vec_sym_*.
     * When hit, ensure std/vec/vec.o then push it onto the link line.
     * G.7: single vec ensure path (table + this block).
     */
    if (link_abi_user_o_needs_std_vec(user_o)) {
        const char *root_vec = xlang_repo_root_from_argv0(link_argv0);
        if (root_vec && root_vec[0])
            xlang_ensure_formal_std_make_o(root_vec, "std/vec/vec.o", "../std/vec/vec.o");
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_vec(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /*
     * wave958: standalone std.http on_demand. PLATFORM: SHARED.
     * Probe: link_abi_user_o_needs_std_http scans labi_od_http_sym_*.
     * When hit, ensure std/http/http.o then push it onto the link line.
     * G.7: single http ensure path (table + this block).
     */
    if (link_abi_user_o_needs_std_http(user_o)) {
        const char *root_http = xlang_repo_root_from_argv0(link_argv0);
        if (root_http && root_http[0])
            xlang_ensure_formal_std_make_o(root_http, "std/http/http.o", "../std/http/http.o");
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_http(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /*
         * wave958: http.o has UNDEF _http_*_c symbols defined in
         * compiler/runtime_http_glue.o. Ensure + push glue companion.
         * PLATFORM: SHARED.
         */
        link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_http_glue_o,
            xlang_runtime_http_glue_o_path(link_argv0), link_argv0,
            labi_od_rel_http_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    if (link_abi_link_needs_std_heap_import(user_o, argv, la ? *la : 0)) {
        /* L4 wipe deletes heap.o; push_obj skip-missing is not enough. Ensure
         * first (≡ set/map). PLATFORM: SHARED — Darwin hard UNDEF if absent. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0]) {
                (void)xlang_ensure_formal_std_make_o(include_root, "std/heap/heap.o",
                                                    "../std/heap/heap.o");
                (void)xlang_ensure_formal_std_make_o(include_root, "core/mem/mem.o",
                                                    "../core/mem/mem.o");
            }
        }
        /* heap.o → core.mem: skip mem.o when user already T-defines core.mem. */
        if (!link_abi_user_o_provides_core_mem(user_o)) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        /*
         * Always push heap.o when needs_std_heap_api fired.
         * Product asm -o co-emits libc/alloc wrappers as T (provides_std_heap
         * hits std_heap_libc_heap_alloc_c) while still U std_heap_mem_set
         * (core_mem_mem_zero call). Two-probe provides is too coarse and
         * swallowed the mem_set needle. Product ld uses
         * --allow-multiple-definition (first-wins user T).
         * G.7: complete this single heap push. PLATFORM: SHARED.
         */
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /*
     * PLATFORM: SHARED — set/map product asm: formal .o + heap/core_mem/(hash for set).
     * Align companions with C invoke_cc need_set/need_map (G.7 complete, no second path).
     * L4 wipe: ensure formal .o via Makefile before push.
     */
    if (link_abi_user_o_needs_std_set(user_o)) {
        const char *include_root = xlang_repo_root_from_argv0(link_argv0);
        if (include_root && include_root[0]) {
            (void)xlang_ensure_formal_std_make_o(include_root, "std/set/set.o", "../std/set/set.o");
            (void)xlang_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
            (void)xlang_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
            (void)xlang_ensure_formal_std_make_o(include_root, "std/hash/hash.o", "../std/hash/hash.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_set(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /* set.o → U std_hash_bytes; fk0 hash gate is user-only and misses set.o. */
        link_abi_asm_ld_push_obj(NULL, link_argv0, "std/hash/hash.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_std_map(user_o)) {
        const char *include_root = xlang_repo_root_from_argv0(link_argv0);
        if (include_root && include_root[0]) {
            (void)xlang_ensure_formal_std_make_o(include_root, "std/map/map.o", "../std/map/map.o");
            (void)xlang_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
            (void)xlang_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_map(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /* map.o U: typed libc heap + map_find; user may only U empty_size. */
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    if (link_abi_user_o_needs_async_scheduler(user_o)) {
        p = asm_link_obj_skip_missing(xlang_std_async_scheduler_o_path(link_argv0));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_rel_async_scheduler(), lib_roots, n_lib_roots, bank);
        if (p && *la < max_la - 1)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p && *la < max_la - 1) {
            const char *rsg = asm_link_obj_skip_missing(xlang_runtime_scheduler_glue_o_path(link_argv0));
            if (!rsg && bank)
                rsg = xlang_asm_ld_try_under_lib_roots(labi_od_rel_scheduler_glue(), lib_roots, n_lib_roots, bank);
            if (rsg)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, rsg);
        }
    }
    if (link_abi_user_o_needs_core_mem(user_o)) {
        p = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, labi_od_rel_core_mem()));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
    }
    /*
     * F-no-libc NL-03：freestanding mmap bump 堆按需链入。
     * 【Why 根源】page_mmap.x 固定 import std.sys.linux + core.mem，故链 page_mmap.o 须同时
     * 链 linux.o + core_mem.o；sys.o 传递依赖 linux.o。--gc-sections 移除未引用的 hosted 函数。
     * 【Invariant】顺序：linux.o → core_mem.o → page_mmap.o / sys.o（被依赖者先入链）。
     *
     * G-03 freestanding co-emit 守卫：freestanding 模式下 dep 模块经 co-emit 已 emit 到 user.o
     * （#[cfg(not(freestanding))] 剪枝 hosted 函数，仅留 syscall 桩/const）。预编译 std/sys/linux.o
     * 等是 hosted 编译产物（含 linux_mmap_rw → libc open/lseek/ftruncate），链入会泄漏 undefined
     * 引用；且 consts（syscall_nr_write）与 co-emit 重复定义。故 freestanding 模式跳过整块，
     * 完全依赖 co-emit 提供的 freestanding-safe 子集。
     */
    if (!driver_freestanding_get()) {
        int need_page_mmap = link_abi_user_o_needs_std_heap_page_mmap(user_o);
        int need_sys_linux = link_abi_user_o_needs_std_sys_linux(user_o);
        int need_sys_macos = link_abi_user_o_needs_std_sys_macos(user_o);
        int need_sys = link_abi_user_o_needs_std_sys(user_o);
        int ai;
        /*
         * PLATFORM: SHARED / LINUX gold — formal heap.o carries U page_mmap_* even when
         * user.o only has std_string_* / std_heap_* API UNDEFs. Scan already-pushed argv
         * (heap.o from on_demand above) so string/wa chain gets page_mmap.o.
         * G.7: extend existing page_mmap probe authority (no second path).
         */
        if (argv && la) {
            for (ai = 0; ai < *la && argv[ai]; ai++) {
                if (!link_abi_ld_argv_entry_is_obj(argv[ai]))
                    continue;
                if (link_abi_user_o_needs_std_heap_page_mmap(argv[ai]))
                    need_page_mmap = 1;
                if (link_abi_user_o_needs_std_sys_linux(argv[ai]))
                    need_sys_linux = 1;
                if (link_abi_user_o_needs_std_sys_macos(argv[ai]))
                    need_sys_macos = 1;
                if (link_abi_user_o_needs_std_sys(argv[ai]))
                    need_sys = 1;
            }
        }
        if (need_sys_linux || need_page_mmap || need_sys) {
            /* PLATFORM: SHARED — L4 wipe deletes linux.o; nested leaf sys_linux
             * is authority for std_sys_linux_linux_*. Twin of need_sys ensure. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/sys/linux.o",
                                                        "../std/sys/linux.o");
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_sys_linux(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        /* PLATFORM: LINUX|x86_64 — linux.o only calls xlang_sys_*; the raw
         * syscall stubs live in compiler/src/asm/freestanding_io_x86_64.o.
         * Hosted user links that co-emit std.sys.linux need it pushed too
         * (run-process BLD001 root). Mirrors the .x twin. */
        (void)link_abi_asm_ld_push_obj(NULL, link_argv0, "compiler/src/asm/freestanding_io_x86_64.o",
                                       lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_sys_macos) {
            /* PLATFORM: SHARED — Darwin cfg import macos_write_*; ensure+push. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/sys/macos.o",
                                                        "../std/sys/macos.o");
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_sys_macos(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_page_mmap || need_sys) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_page_mmap) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_page_mmap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_sys) {
            /* PLATFORM: SHARED — L4 wipe deletes sys.o; push_obj skip-missing is
             * not enough (≡ heap/vec/http). Cookbook sys_write_stdout UNDEF
             * std_sys_write_stdout while needles already fire. G.7: complete
             * existing need_sys path with formal ensure; do not add a second
             * simple-group table. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/sys/sys.o",
                                                        "../std/sys/sys.o");
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_sys(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    if (link_abi_user_o_needs_core_slice(user_o)) {
        /* PLATFORM: SHARED — L4 wipe deletes core/slice/slice.o; the silent
         * skip-missing below then leaves core_subslice_*_c UNDEF
         * (subslice_split_chunks BLD001). Mirror the sys.o ensure. Mirrors
         * the .x twin. */
        {
            const char *root_cs = xlang_repo_root_from_argv0(link_argv0);
            if (root_cs && root_cs[0] != '\0')
                (void)xlang_ensure_formal_std_make_o(root_cs, "core/slice/slice.o",
                                                     "../core/slice/slice.o");
        }
        p = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, labi_od_rel_core_slice()));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_rel_core_slice(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        /*
         * wave957: X-facing core_slice u64 symbols (chunks_len / split_at /
         * subslice) are in core/slice/mod.o (API), not slice.o (glue). Push
         * mod.o too when needs_core_slice fires. G.7: complete the single
         * core_slice ensure path. PLATFORM: SHARED.
         */
        {
            const char *csmod_rel = "core/slice/mod.o";
            const char *p_csmod = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, csmod_rel));
            if (!p_csmod && bank)
                p_csmod = xlang_asm_ld_try_under_lib_roots(csmod_rel, lib_roots, n_lib_roots, bank);
            if (p_csmod)
                link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_csmod);
        }
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_kv_sym_count(), labi_od_kv_sym_at)) {
        /* PLATFORM: SHARED — L4 wipe deletes kv.o; push skip-missing is not
         * enough (≡ need_sys / need_net). Produce path is formal_mod
         * mod.x+kv.x (was std_x auto-soft kv.x only → T db_kv_*). G.7 complete
         * existing kv table with formal ensure + glue ensure. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)xlang_ensure_formal_std_make_o(include_root, "std/db/kv/kv.o",
                                                    "../std/db/kv/kv.o");
        }
        p = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, labi_od_kv_rel()));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_kv_rel(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p)
            link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_kv_mmap_glue_o,
                xlang_runtime_kv_mmap_glue_o_path(link_argv0), link_argv0,
                labi_od_kv_glue_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_arrow_sym_count(), labi_od_arrow_sym_at)) {
        /* PLATFORM: SHARED — L4 wipe deletes arrow.o; skip-missing never
         * ensure (≡ kv). Produce path is formal_mod mod.x+arrow.x.
         * arrow.o U arrow_column_f32_*_c (simd glue) and simd_hw_available_c
         * (simd c_face C ABI). Darwin -dead_strip hid unused simd T; Ubuntu
         * gold exposes UNDEF. G.7 complete existing arrow table. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0]) {
                (void)xlang_ensure_formal_std_make_o(include_root, "std/db/arrow/arrow.o",
                                                    "../std/db/arrow/arrow.o");
                (void)xlang_ensure_formal_std_make_o(include_root, "std/simd/simd.o",
                                                    "../std/simd/simd.o");
            }
        }
        p = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, labi_od_arrow_rel()));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_arrow_rel(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/simd/simd.o", lib_roots, n_lib_roots,
                                     bank, argv, la, max_la, NULL);
            link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_arrow_simd_glue_o,
                xlang_runtime_arrow_simd_glue_o_path(link_argv0), link_argv0,
                labi_od_arrow_glue_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la);
        }
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_async_sym_count(), labi_od_async_sym_at)) {
        /* PLATFORM: SHARED — leftover unique UNDEF std_async_placeholder /
         * std_async_drain_idle / std_async_scheduler_reset /
         * std_async_net_fs_async_smoke. No async.o existed; scheduler C ABI
         * table never fires unique import METHOD. Produce path is formal_mod
         * c_face. drain_idle / scheduler_reset / net_fs U xlang_async_* →
         * scheduler glue ensure (async_net_fs #include). G.7 complete unique
         * table; do not dump unique names into labi_od_async_scheduler_sym_*. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)xlang_ensure_formal_std_make_o(include_root, "std/async/async.o",
                                                    "../std/async/async.o");
        }
        p = asm_link_obj_skip_missing(xlang_rel_o_path_from_argv0(link_argv0, labi_od_async_rel()));
        if (!p && bank)
            p = xlang_asm_ld_try_under_lib_roots(labi_od_async_rel(), lib_roots, n_lib_roots, bank);
        if (p)
            link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p);
        if (p)
            link_abi_asm_ld_push_glue_after_std(1, xlang_ensure_runtime_scheduler_glue_o,
                xlang_runtime_scheduler_glue_o_path(link_argv0), link_argv0,
                labi_od_rel_scheduler_glue(), lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    if (link_abi_user_o_needs_std_test(user_o)) {
        /* PLATFORM: SHARED — Darwin -backend asm run-stdtest. Cold L4 leaves L8c
         * unused, so this full L8b seed is the on_demand body. Do not gate
         * companions on have_test (g12 may already have test.o). G.7 ≡ queue:
         * always push test.o then labi_std_append_test_monofile_companions. */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)xlang_ensure_formal_std_make_o(include_root, "std/test/test.o",
                                                    "../std/test/test.o");
        }
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_test(), lib_roots, n_lib_roots,
                                 bank, argv, la, max_la, NULL);
        labi_std_append_test_monofile_companions(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la);
    }
    /*
     * PLATFORM: LINUX freestanding / SHARED gate —
     * runtime_heap_user.o wraps libc malloc/free/realloc. Under -freestanding
     * (-nostdlib) that yields U malloc. Zero-libc product heap is page_mmap
     * (co-emit or formal); never push heap_user on freestanding links.
     * G.7: complete existing heap_user on_demand authority (no second path).
     */
    if (!driver_freestanding_get() && link_abi_link_needs_heap_user_c(user_o, argv, la ? *la : 0)) {
        if (xlang_ensure_runtime_heap_user_o(link_argv0) != 0)
            return;
        link_abi_asm_ld_push_obj(xlang_runtime_heap_user_o_path(link_argv0), link_argv0, labi_od_rel_heap_user(),
                                 lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        if (flags)
            flags->have_libc_heap = 1;
    }
    /* Simple multi-sym groups → single rel (pure table). Formal ensure for core/*.o. */
    {
        int pushed_core_formal = 0;
        for (sg = 0; sg < labi_od_simple_group_count(); sg++) {
            const char *rel = labi_od_simple_group_rel(sg);
            if (!rel || !rel[0])
                continue;
            if (!labi_od_user_needs_simple_group(user_o, sg))
                continue;
            /* PLATFORM: SHARED — L4 wipe drops gitignored formal std/core .o.
             * G.7: ensure by rel for every simple-group hit (≡ pure heavy generic
             * ensure). Covers g12..g19 (test/assert/fmt/compress/driver/debug/simd/io)
             * and legacy core/* + encoding. Do not leave seed-only subset. */
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                char make_tgt[PATH_MAX];
                if (include_root && include_root[0] &&
                    (size_t)snprintf(make_tgt, sizeof make_tgt, "../%s", rel) < sizeof make_tgt)
                    (void)xlang_ensure_formal_std_make_o(include_root, rel, make_tgt);
                if (strstr(rel, "core/"))
                    pushed_core_formal = 1;
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            /* PLATFORM: SHARED — 9.2.2: facade compress.o is c_face stub (return -1).
             * Real zlib/gzip live in submodule formal .o (mod+libz). Companion ≡
             * encoding.o → string/base64. Glue provides deflateInit2/inflateInit2. */
            if (strstr(rel, "std/compress/compress.o")) {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0]) {
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/compress/zlib/zlib.o",
                                                        "../std/compress/zlib/zlib.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/compress/gzip/gzip.o",
                                                        "../std/compress/gzip/gzip.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/compress/zstd/zstd.o",
                                                        "../std/compress/zstd/zstd.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/compress/brotli/brotli.o",
                                                        "../std/compress/brotli/brotli.o");
                }
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/compress/zlib/zlib.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/compress/gzip/gzip.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/compress/zstd/zstd.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/compress/brotli/brotli.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                /* Glue + -lz stay in asm_ld_append_compress_libs (needs_zlib).
                 * Do not push runtime_compress_zlib_glue.o here (duplicate T). */
                /* PLATFORM: LINUX|x86_64 — zstd/brotli lib.x are extern C FFI;
                 * raw ld has no -l face. Push system .so when present. macOS
                 * brew .dylib is a separate card. Must stay in this compress.o
                 * companion (was mistakenly nested under core/slice/mod.o). */
                link_abi_asm_ld_push_obj(NULL, link_argv0, "/usr/lib/x86_64-linux-gnu/libzstd.so",
                                         lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "/usr/lib/x86_64-linux-gnu/libbrotlienc.so",
                                         lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "/usr/lib/x86_64-linux-gnu/libbrotlidec.so",
                                         lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            }
            /* PLATFORM: SHARED — g12 std/test/test.o monofile C dual (≡ need_test). */
            if (strstr(rel, "std/test/test.o"))
                labi_std_append_test_monofile_companions(link_argv0, lib_roots, n_lib_roots,
                                                       bank, argv, la, max_la);
            /* PLATFORM: SHARED — encoding.o U std_base64_* + std_string_string_* helpers.
             * User.o only U encoding_*; g0/g3 alone miss. Companion ≡ g9 slice glue. */
            if (strstr(rel, "std/encoding/encoding.o")) {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0]) {
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/string/string.o",
                                                        "../std/string/string.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/base64/base64.o",
                                                        "../std/base64/base64.o");
                }
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/string/string.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/base64/base64.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
            }
            /* PLATFORM: SHARED — bytes.o U heap.alloc/realloc/copy/free (mod.x grow/extend).
             * User.o for roundtrip only U std_bytes_* so heap_api needles miss.
             * Companion ≡ encoding.o → string/base64. Also co-push string.o for as_view.
             */
            if (strstr(rel, "std/bytes/bytes.o")) {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0]) {
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/heap/heap.o",
                                                        "../std/heap/heap.o");
                    (void)xlang_ensure_formal_std_make_o(include_root, "std/string/string.o",
                                                        "../std/string/string.o");
                }
                link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
                link_abi_asm_ld_push_obj(NULL, link_argv0, "std/string/string.o", lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
            }
            /* PLATFORM: SHARED — formal mod.o U from_ptr/subslice → always co-push glue slice.o.
             * User.o for length.x has no U core_slice_*_from_ptr_c, so needs_core_slice alone misses glue. */
            if (strstr(rel, "core/slice/mod.o")) {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                if (include_root && include_root[0])
                    (void)xlang_ensure_formal_std_make_o(include_root, "core/slice/slice.o",
                                                        "../core/slice/slice.o");
                link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_slice(), lib_roots, n_lib_roots,
                                         bank, argv, la, max_la, NULL);
            }
        }
        /*
         * Formal core/*.o from xlang_compile_std_module carry preamble weak process_arg*_c
         * → U process_xlang_*. Same complement as sync/atomic: push process_argv (not process.o).
         * PLATFORM: SHARED — Ubuntu asm si residual after ELF UNDEF scan.
         */
        if (pushed_core_formal) {
            (void)xlang_ensure_runtime_process_argv_o(link_argv0);
            link_abi_asm_ld_push_obj(xlang_runtime_process_argv_o_path(link_argv0), link_argv0,
                "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — string/heap/vec/mem formal .o carry preamble weak process_arg*_c
     * → U process_xlang_*. fk0 string push does not set have_math/sync flags, so the std_objs
     * process_argv complement never fired (Ubuntu string_asm residual).
     * G.7: complete existing process_argv complement by scanning argv after on_demand.
     */
    if (argv && la) {
        int need_pav = 0;
        int ai;
        int have_process_o = 0;
        for (ai = 0; ai < *la && argv[ai]; ai++) {
            const char *e = argv[ai];
            if (!link_abi_ld_argv_entry_is_obj(e))
                continue;
            if (strstr(e, "process.o") && !strstr(e, "process_argv"))
                have_process_o = 1;
            if (xlang_link_obj_needs_undef_sym(e, "process_xlang_argc_get")
                || xlang_link_obj_needs_undef_sym(e, "process_xlang_argv_get"))
                need_pav = 1;
        }
        if (need_pav && !have_process_o) {
            (void)xlang_ensure_runtime_process_argv_o(link_argv0);
            link_abi_asm_ld_push_obj(xlang_runtime_process_argv_o_path(link_argv0), link_argv0,
                "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — std/cache/cache.o (fk0) U time_now_monotonic_ns_c after
     * push; user.o only has std_cache_* so time-table / need_time_os never fire.
     * G.7: mirror process_argv complement — scan argv objs for the C face UNDEF,
     * then ensure + push runtime_time_os.o (STD-087 lru_pool_smoke).
     */
    if (argv && la) {
        int need_tos = 0;
        int have_tos = 0;
        int ti;
        for (ti = 0; ti < *la && argv[ti]; ti++) {
            const char *e = argv[ti];
            if (!link_abi_ld_argv_entry_is_obj(e))
                continue;
            if (strstr(e, "runtime_time_os.o"))
                have_tos = 1;
            if (xlang_link_obj_needs_undef_sym(e, "time_now_monotonic_ns_c"))
                need_tos = 1;
        }
        if (need_tos && !have_tos) {
            if (xlang_ensure_runtime_time_os_o(link_argv0) == 0)
                link_abi_asm_ld_push_obj(xlang_runtime_time_os_o_path(link_argv0), link_argv0,
                    labi_od_time_os_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — std/security/security.o (fk0) U std_crypto_mem_eq /
     * crypto_hmac_sha256_c / std_random_fill_bytes after push; user.o only has
     * std_security_* so fk4 crypto / random gates never fire. G.7: mirror
     * process_argv / time_os complement (STD-079 roundtrip).
     */
    if (argv && la) {
        int need_crypto = 0;
        int need_hmac = 0;
        int need_rand = 0;
        int have_crypto = 0;
        int have_hmac = 0;
        int have_rand = 0;
        int ci;
        for (ci = 0; ci < *la && argv[ci]; ci++) {
            const char *e = argv[ci];
            if (!link_abi_ld_argv_entry_is_obj(e))
                continue;
            if (strstr(e, "std/crypto/crypto.o"))
                have_crypto = 1;
            if (strstr(e, "runtime_crypto_inc_glue.o"))
                have_hmac = 1;
            if (strstr(e, "std/random/random.o"))
                have_rand = 1;
            if (xlang_link_obj_needs_undef_sym(e, "std_crypto_mem_eq")
                || xlang_link_obj_needs_undef_sym(e, "crypto_mem_eq_c"))
                need_crypto = 1;
            if (xlang_link_obj_needs_undef_sym(e, "crypto_hmac_sha256_c"))
                need_hmac = 1;
            if (xlang_link_obj_needs_undef_sym(e, "std_random_fill_bytes"))
                need_rand = 1;
        }
        if (need_crypto && !have_crypto) {
            const char *root_c = xlang_repo_root_from_argv0(link_argv0);
            if (root_c && root_c[0])
                (void)xlang_ensure_formal_std_make_o(root_c, "std/crypto/crypto.o",
                                                    "../std/crypto/crypto.o");
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/crypto/crypto.o",
                lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_hmac && !have_hmac) {
            /* CRYPTO_PAIR: ed25519_ref10 (sha512) + crypto_inc (hmac_sha256_c). */
            (void)xlang_ensure_runtime_ed25519_ref10_glue_o(link_argv0);
            link_abi_asm_ld_push_obj(xlang_runtime_ed25519_ref10_glue_o_path(link_argv0),
                link_argv0, "compiler/runtime_ed25519_ref10_glue.o",
                lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            (void)xlang_ensure_runtime_crypto_inc_glue_o(link_argv0);
            link_abi_asm_ld_push_obj(xlang_runtime_crypto_inc_glue_o_path(link_argv0),
                link_argv0, "compiler/runtime_crypto_inc_glue.o",
                lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        if (need_rand && !have_rand) {
            const char *root_r = xlang_repo_root_from_argv0(link_argv0);
            if (root_r && root_r[0])
                (void)xlang_ensure_formal_std_make_o(root_r, "std/random/random.o",
                                                    "../std/random/random.o");
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/random/random.o",
                lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    /*
     * PLATFORM: SHARED — std/result/result.o (fk0) U std_error_ok after push;
     * user.o may only have std_result_* so fk0 k8 error gate never fires.
     * G.7: mirror security→crypto (STD-080/081 roundtrip).
     */
    if (argv && la) {
        int need_err = 0;
        int have_err = 0;
        int ei;
        for (ei = 0; ei < *la && argv[ei]; ei++) {
            const char *e = argv[ei];
            if (!link_abi_ld_argv_entry_is_obj(e))
                continue;
            if (strstr(e, "std/error/error.o"))
                have_err = 1;
            if (xlang_link_obj_needs_undef_sym(e, "std_error_ok"))
                need_err = 1;
        }
        if (need_err && !have_err) {
            const char *root_e = xlang_repo_root_from_argv0(link_argv0);
            if (root_e && root_e[0])
                (void)xlang_ensure_formal_std_make_o(root_e, "std/error/error.o",
                                                    "../std/error/error.o");
            link_abi_asm_ld_push_obj(NULL, link_argv0, "std/error/error.o",
                lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
    }
    if (labi_od_user_needs_any_sym_table(user_o, labi_od_time_sym_count(), labi_od_time_sym_at)) {
        /* PLATFORM: SHARED — L4 wipe drops formal time.o; push_obj skip_missing alone
         * leaves U std_time_*. G.7: ensure formal before push (same as plan STD block). */
        {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0])
                (void)xlang_ensure_formal_std_make_o(include_root, "std/time/time.o",
                                                    "../std/time/time.o");
        }
        if (xlang_ensure_runtime_time_os_o(link_argv0) == 0)
            link_abi_asm_ld_push_obj(xlang_runtime_time_os_o_path(link_argv0), link_argv0,
                                     labi_od_time_os_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_time_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
    }
    /*
     * PLATFORM: SHARED — product queue (std_queue_*) + monofile companions.
     * G.7: single helper labi_std_append_queue_monofile_companions.
     */
    {
        int need_q_product = link_abi_user_o_needs_std_queue(user_o);
        int need_q_contention = labi_od_user_needs_any_sym_table(user_o, labi_od_queue_sym_count(), labi_od_queue_sym_at);
        if (need_q_product || need_q_contention) {
            const char *include_root = xlang_repo_root_from_argv0(link_argv0);
            if (include_root && include_root[0]) {
                (void)xlang_ensure_formal_std_make_o(include_root, "std/queue/queue.o", "../std/queue/queue.o");
                (void)xlang_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
                (void)xlang_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_queue_rel(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_heap(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            link_abi_asm_ld_push_obj(NULL, link_argv0, labi_od_rel_core_mem(), lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
            labi_std_append_queue_monofile_companions(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la, flags);
        }
    }
#else
    /* PLATFORM: WINDOWS — product -o previously no-op'd on_demand (linux/apple
     * only). Entry-only asm then left core_option_* UNDEF despite formal
     * core/option/option.o on disk. Push simple-group formals (option/result/…)
     * for any UNDEF hit; skip-missing keeps hello clean. */
    {
        int sg;
        if (!user_o || !user_o[0] || !la || *la >= max_la - 1)
            return;
        for (sg = 0; sg < labi_od_simple_group_count(); sg++) {
            const char *rel = labi_od_simple_group_rel(sg);
            if (!rel || !rel[0])
                continue;
            if (!labi_od_user_needs_simple_group(user_o, sg))
                continue;
            {
                const char *include_root = xlang_repo_root_from_argv0(link_argv0);
                char make_tgt[512];
                if (include_root && include_root[0] &&
                    (size_t)snprintf(make_tgt, sizeof make_tgt, "../%s", rel) < sizeof make_tgt)
                    (void)xlang_ensure_formal_std_make_o(include_root, rel, make_tgt);
            }
            link_abi_asm_ld_push_obj(NULL, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
        }
        /* option.o expect_* → xlang_panic_; core/debug often supplies it. */
        if (labi_od_user_needs_simple_group(user_o, 6)) {
            link_abi_asm_ld_push_obj(NULL, link_argv0, "core/debug/debug.o", lib_roots, n_lib_roots,
                                     bank, argv, la, max_la, NULL);
        }
    }
#endif
}

#else
int labi_od_simple_group_count(void);
int labi_od_simple_group_sym_count(int g);
const char *labi_od_simple_group_sym_at(int g, int i);
const char *labi_od_simple_group_rel(int g);
int labi_od_kv_sym_count(void);
const char *labi_od_kv_sym_at(int i);
const char *labi_od_kv_rel(void);
const char *labi_od_kv_glue_rel(void);
int labi_od_arrow_sym_count(void);
const char *labi_od_arrow_sym_at(int i);
const char *labi_od_arrow_rel(void);
const char *labi_od_arrow_glue_rel(void);
int labi_od_async_sym_count(void);
const char *labi_od_async_sym_at(int i);
const char *labi_od_async_rel(void);
int labi_od_time_sym_count(void);
const char *labi_od_time_sym_at(int i);
const char *labi_od_time_rel(void);
const char *labi_od_time_os_rel(void);
int labi_od_queue_sym_count(void);
const char *labi_od_queue_sym_at(int i);
const char *labi_od_queue_rel(void);
const char *labi_od_queue_contention_rel(void);
int labi_od_net_sym_count(void);
const char *labi_od_net_sym_at(int i);
int link_abi_user_o_needs_std_net(const char *user_o);
int labi_od_set_sym_count(void);
const char *labi_od_set_sym_at(int i);
int link_abi_user_o_needs_std_set(const char *user_o);
int labi_od_map_sym_count(void);
const char *labi_od_map_sym_at(int i);
int link_abi_user_o_needs_std_map(const char *user_o);
int labi_od_queue_api_sym_count(void);
const char *labi_od_queue_api_sym_at(int i);
int link_abi_user_o_needs_std_queue(const char *user_o);
int labi_od_test_sym_count(void);
const char *labi_od_test_sym_at(int i);
int link_abi_user_o_needs_std_test(const char *user_o);
int labi_od_core_mem_sym_count(void);
const char *labi_od_core_mem_sym_at(int i);
int link_abi_user_o_needs_core_mem(const char *user_o);
int labi_od_core_slice_sym_count(void);
const char *labi_od_core_slice_sym_at(int i);
int link_abi_user_o_needs_core_slice(const char *user_o);
int labi_od_page_mmap_sym_count(void);
const char *labi_od_page_mmap_sym_at(int i);
int link_abi_user_o_needs_std_heap_page_mmap(const char *user_o);
int labi_od_sys_linux_sym_count(void);
const char *labi_od_sys_linux_sym_at(int i);
int link_abi_user_o_needs_std_sys_linux(const char *user_o);
int labi_od_sys_macos_sym_count(void);
const char *labi_od_sys_macos_sym_at(int i);
int link_abi_user_o_needs_std_sys_macos(const char *user_o);
int labi_od_sys_sym_count(void);
const char *labi_od_sys_sym_at(int i);
int link_abi_user_o_needs_std_sys(const char *user_o);
int labi_od_heap_api_sym_count(void);
const char *labi_od_heap_api_sym_at(int i);
int link_abi_user_o_needs_std_heap_api(const char *user_o);
int labi_od_heap_user_sym_count(void);
const char *labi_od_heap_user_sym_at(int i);
int link_abi_user_o_needs_heap_user_syms(const char *user_o);
int labi_od_async_scheduler_sym_count(void);
const char *labi_od_async_scheduler_sym_at(int i);
int link_abi_user_o_needs_async_scheduler(const char *user_o);
int labi_od_zlib_undef_sym_count(void);
const char *labi_od_zlib_undef_sym_at(int i);
const char *labi_od_compress_zlib_marker(void);
int labi_od_zstd_undef_sym_count(void);
const char *labi_od_zstd_undef_sym_at(int i);
const char *labi_od_compress_zstd_marker(void);
int labi_od_brotli_undef_sym_count(void);
const char *labi_od_brotli_undef_sym_at(int i);
const char *labi_od_compress_brotli_marker(void);
int link_abi_obj_needs_zlib(const char *obj_o);
int link_abi_obj_needs_zstd(const char *obj_o);
int link_abi_obj_needs_brotli(const char *obj_o);
int link_abi_user_o_needs_compress_libs(const char *user_o);
int labi_od_runtime_time_os_sym_count(void);
const char *labi_od_runtime_time_os_sym_at(int i);
int labi_user_needs_runtime_time_os(const char *user_o);
int labi_od_runtime_random_fill_sym_count(void);
const char *labi_od_runtime_random_fill_sym_at(int i);
int labi_user_needs_runtime_random_fill(const char *user_o);
int labi_od_runtime_env_os_sym_count(void);
const char *labi_od_runtime_env_os_sym_at(int i);
int labi_user_needs_runtime_env_os(const char *user_o);
int labi_od_runtime_process_argv_sym_count(void);
const char *labi_od_runtime_process_argv_sym_at(int i);
int labi_user_needs_runtime_process_argv(const char *user_o);
int labi_od_std_task_sym_count(void);
const char *labi_od_std_task_sym_at(int i);
int labi_user_needs_std_task(const char *user_o);
int labi_fk0_rel_count(void);
const char *labi_fk0_rel_at(int k);
int labi_fk0_sym_count(int k);
const char *labi_fk0_sym_at(int k, int i);
int labi_std_fk0_user_needs_rel(const char *user_o, const char *rel);
int labi_std_fk_gate_sym_count(int fk);
const char *labi_std_fk_gate_sym_at(int fk, int i);
int labi_std_fk_user_needs(const char *user_o, int fk);
int labi_od_provides_core_mem_sym_count(void);
const char *labi_od_provides_core_mem_sym_at(int i);
int link_abi_user_o_provides_core_mem(const char *user_o);
int labi_od_provides_std_heap_sym_count(void);
const char *labi_od_provides_std_heap_sym_at(int i);
int link_abi_user_o_provides_std_heap(const char *user_o);
int link_abi_link_needs_heap_user_c(const char *user_o, const char **argv, int la);
int link_abi_link_needs_std_heap_import(const char *user_o, const char **argv, int la);
const char *labi_od_rel_net(void);
const char *labi_od_rel_thread(void);
const char *labi_od_rel_vec(void);
const char *labi_od_rel_http(void);
const char *labi_od_rel_heap(void);
const char *labi_od_rel_set(void);
const char *labi_od_rel_map(void);
const char *labi_od_rel_async_scheduler(void);
const char *labi_od_rel_core_mem(void);
const char *labi_od_rel_sys_linux(void);
const char *labi_od_rel_sys_macos(void);
const char *labi_od_rel_page_mmap(void);
const char *labi_od_rel_sys(void);
const char *labi_od_rel_core_slice(void);
const char *labi_od_rel_test(void);
const char *labi_od_rel_heap_user(void);
const char *labi_od_rel_scheduler_glue(void);
const char *labi_od_rel_thread_glue(void);
const char *labi_od_rel_http_glue(void);
const char *labi_od_rel_net_udp_batch(void);
const char *labi_od_rel_net_workers(void);
const char *labi_od_rel_test_fn_invoke(void);
/* wave197: product on_demand shell pure orch (L8b). */
void xlang_asm_ld_append_on_demand_user_objs(const char *link_argv0, const char *user_o,
    const char **lib_roots, int n_lib_roots, ShuAsmLdPathBank *bank,
    const char **argv, int *la, int max_la, ShuAsmLdStdLinkFlags *flags);
#endif

int labi_ondemand_list_slice_marker(void) {
  return 1;
}

#if !defined(XLANG_LABI_NEEDLE_TABLES_EXTERNAL) && !defined(XLANG_LABI_NEEDLE_TABLES_PROVIDED)
#define XLANG_LABI_NEEDLE_TABLES_PROVIDED
/* Class BE/BG: cold mega / layer-seed embeds needle tables. Prefer merge
 * passes -DXLANG_LABI_NEEDLE_TABLES_EXTERNAL and links labi_od_needle_tables.o. */
#include "seeds/labi_od_needle_tables.c"
#endif
