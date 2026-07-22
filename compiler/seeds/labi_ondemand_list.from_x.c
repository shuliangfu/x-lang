/* seeds/labi_ondemand_list.from_x.c — G-02f-272 P2 link_abi L8b on_demand list pure → R2 full
 * Logic source: src/runtime/labi_ondemand_list.x
 * Hybrid: SHUX_LABI_ONDEMAND_LIST_FROM_X + ld -r into runtime_link_abi.o
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
 * Cap residual：nm 探针 + push/ensure 仍在 mega shux_asm_ld_append_on_demand_user_objs；
 *   undef_sym / exports_marker / has_undef_sym / has_defined_sym 探针仍 mega（pure orch Cap）。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_ondemand_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>
#include <string.h>

/* Cap residual (mega always): nm UNDEF probe used by pure needs orch. */
int shux_link_obj_needs_undef_sym(const char *user_o, const char *sym);
/* Cap residual (mega always): nm defined T/t probe used by pure provides orch. */
int shux_link_obj_has_defined_sym(const char *o_path, const char *sym);
/* Cap residual (mega always): compress package marker + UNDEF/prefix probes. */
int link_abi_obj_exports_marker(const char *obj_o, const char *marker);
int link_abi_obj_has_undef_sym(const char *obj_o, const char *sym);
/* wave145 aggregate orch Cap: path pure suffix scan (authority labi_path_pure). */
int link_abi_ld_argv_entry_is_obj(const char *s);

#ifndef SHUX_LABI_ONDEMAND_LIST_FROM_X

/* Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5
 * core_option=6 core_result=7 core_debug=8 core_slice=9.
 * PLATFORM: SHARED — g1 rel is core/types/types.o (was wrongly base64.o).
 * types/option/result/debug/slice formal .o via Makefile + ensure; no asm co-emit hang.
 * g9 rel is core/slice/mod.o (API); glue from_ptr/subslice remains core/slice/slice.o. */

int labi_od_simple_group_count(void) {
  return 10;
}

int labi_od_simple_group_sym_count(int g) {
  if (g < 0)
    return 0;
  if (g == 0)
    return 9;
  if (g == 1)
    return 2;
  if (g == 2)
    return 6;
  if (g == 3)
    return 4;
  if (g == 4)
    return 3;
  if (g == 5)
    return 3;
  if (g == 6)
    return 4;
  if (g == 7)
    return 4;
  if (g == 8)
    return 6;
  if (g == 9)
    return 10;
  return 0;
}

const char *labi_od_simple_group_sym_at(int g, int i) {
  if (g < 0)
    return NULL;
  if (i < 0)
    return NULL;
  if (g == 0) {
    if (i == 0)
      return "shux_string_copy_c";
    if (i == 1)
      return "shux_string_memcmp_c";
    if (i == 2)
      return "shux_string_memchr_c";
    if (i == 3)
      return "shux_string_memmem_c";
    if (i == 4)
      return "shux_string_memrchr_c";
    if (i == 5)
      return "std_string_string_new";
    if (i == 6)
      return "std_string_string_from_slice";
    if (i == 7)
      return "std_string_string_view";
    if (i == 8)
      return "std_string_string_len";
    return NULL;
  }
  if (g == 1) {
    if (i == 0)
      return "core_types_size_of_i32";
    if (i == 1)
      return "core_types_placeholder";
    return NULL;
  }
  if (g == 2) {
    if (i == 0)
      return "encoding_utf8_valid_c";
    if (i == 1)
      return "encoding_hex_encode_c";
    if (i == 2)
      return "encoding_ascii_is_alpha_c";
    if (i == 3)
      return "std_encoding_utf8_valid";
    if (i == 4)
      return "std_encoding_utf8_decode_rune";
    if (i == 5)
      return "std_encoding_ascii_is_alpha";
    return NULL;
  }
  if (g == 3) {
    if (i == 0)
      return "base64_encode_standard_c";
    if (i == 1)
      return "std_base64_encode_standard";
    if (i == 2)
      return "std_base64_decode_standard";
    if (i == 3)
      return "std_base64_encode_url";
    return NULL;
  }
  if (g == 4) {
    if (i == 0)
      return "std_csv_next_field";
    if (i == 1)
      return "std_csv_escape";
    if (i == 2)
      return "std_csv_csv_test_quoted_first";
    return NULL;
  }
  if (g == 5) {
    if (i == 0)
      return "schema_create_c";
    if (i == 1)
      return "schema_decode_json_c";
    if (i == 2)
      return "schema_smoke_c";
    return NULL;
  }
  if (g == 6) {
    if (i == 0)
      return "core_option_some_i32";
    if (i == 1)
      return "core_option_unwrap_or_i32";
    if (i == 2)
      return "core_option_none_i32";
    if (i == 3)
      return "core_option_is_some_i32";
    return NULL;
  }
  if (g == 7) {
    if (i == 0)
      return "core_result_ok_i32";
    if (i == 1)
      return "core_result_is_ok_i32";
    if (i == 2)
      return "core_result_err_i32";
    if (i == 3)
      return "core_result_ok";
    return NULL;
  }
  /* PLATFORM: SHARED — core.debug formal surface (tests/sort assert_eq_*). */
  if (g == 8) {
    if (i == 0)
      return "core_debug_assert_eq_i32";
    if (i == 1)
      return "core_debug_assert_eq_u32";
    if (i == 2)
      return "core_debug_assert_eq_u64";
    if (i == 3)
      return "core_debug_assert_ne_i32";
    if (i == 4)
      return "core_debug_assert";
    if (i == 5)
      return "core_debug_debug_assert";
    return NULL;
  }
  /* PLATFORM: SHARED — core.slice formal API (tests/slice/length.x BLD001 residual). */
  if (g == 9) {
    if (i == 0)
      return "core_slice_len_i32";
    if (i == 1)
      return "core_slice_get_i32";
    if (i == 2)
      return "core_slice_get_i32_unchecked";
    if (i == 3)
      return "core_slice_len_u8";
    if (i == 4)
      return "core_slice_get_u8";
    if (i == 5)
      return "core_slice_get_u8_unchecked";
    if (i == 6)
      return "core_slice_subslice_i32";
    if (i == 7)
      return "core_slice_subslice_u8";
    if (i == 8)
      return "core_slice_len_u64";
    if (i == 9)
      return "core_slice_get_u64";
    return NULL;
  }
  return NULL;
}

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
  return NULL;
}

/* KV: multi-sym → kv.o + optional glue rel */
int labi_od_kv_sym_count(void) {
  return 2;
}

const char *labi_od_kv_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "db_kv_open_c";
  if (i == 1)
    return "db_kv_get_c";
  return NULL;
}

const char *labi_od_kv_rel(void) {
  return "std/db/kv/kv.o";
}

const char *labi_od_kv_glue_rel(void) {
  return "compiler/runtime_kv_mmap_glue.o";
}

/* Arrow */
int labi_od_arrow_sym_count(void) {
  return 2;
}

const char *labi_od_arrow_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "arrow_column_i32_create_c";
  if (i == 1)
    return "arrow_column_adopt_f32_c";
  return NULL;
}

const char *labi_od_arrow_rel(void) {
  return "std/db/arrow/arrow.o";
}

const char *labi_od_arrow_glue_rel(void) {
  return "compiler/runtime_arrow_simd_glue.o";
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

/* wave118: net UNDEF table + needs_std_net pure orch. PLATFORM: SHARED. */
int labi_od_net_sym_count(void) { return 17; }
const char *labi_od_net_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_net_listen";
  if (i == 1)
    return "std_net_connect";
  if (i == 2)
    return "std_net_udp_bind";
  if (i == 3)
    return "std_net_udp_recv_many_buf";
  if (i == 4)
    return "std_net_udp_send_many_buf";
  if (i == 5)
    return "std_net_addr_to_u32";
  if (i == 6)
    return "std_net_close_udp";
  if (i == 7)
    return "net_stream_write_batch_c";
  if (i == 8)
    return "net_tcp_connect_c";
  if (i == 9)
    return "net_tcp_listen_c";
  if (i == 10)
    return "net_udp_bind_c";
  if (i == 11)
    return "net_udp_recv_many_buf_c";
  if (i == 12)
    return "net_udp_send_many_buf_c";
  if (i == 13)
    return "net_close_socket_c";
  if (i == 14)
    return "net_udp_send_c";
  if (i == 15)
    return "net_dns_resolve_c";
  if (i == 16)
    return "net_sock_create_c";
  return NULL;
}

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_net(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_net_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_net_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave119: set UNDEF table + needs_std_set pure orch. PLATFORM: SHARED. */
int labi_od_set_sym_count(void) { return 20; }
const char *labi_od_set_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_set_new_i32_retSet_i32";
  if (i == 1)
    return "std_set_new_i32_retSet_u64";
  if (i == 2)
    return "std_set_with_capacity_Set_i32_ptr_i32";
  if (i == 3)
    return "std_set_insert_Set_i32_ptr_i32";
  if (i == 4)
    return "std_set_insert_Set_u64_ptr_u64";
  if (i == 5)
    return "std_set_contains_key_Set_i32_i32";
  if (i == 6)
    return "std_set_contains_key_Set_u64_u64";
  if (i == 7)
    return "std_set_remove_Set_i32_ptr_i32";
  if (i == 8)
    return "std_set_remove_Set_u64_ptr_u64";
  if (i == 9)
    return "std_set_len_Set_i32";
  if (i == 10)
    return "std_set_len_Set_u64";
  if (i == 11)
    return "std_set_deinit_Set_i32_ptr";
  if (i == 12)
    return "std_set_deinit_Set_u64_ptr";
  if (i == 13)
    return "std_set_str_new";
  if (i == 14)
    return "std_set_str_insert";
  /* Legacy / alternate mangles. */
  if (i == 15)
    return "std_set_set_i32_insert";
  if (i == 16)
    return "std_set_set_i32_contains";
  if (i == 17)
    return "std_set_set_i32_remove";
  if (i == 18)
    return "std_set_set_i32_len";
  if (i == 19)
    return "std_set_set_i32_deinit";
  return NULL;
}

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_set(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_set_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_set_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave120: map UNDEF table + needs_std_map pure orch. PLATFORM: SHARED. */
int labi_od_map_sym_count(void) { return 9; }
const char *labi_od_map_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_map_empty_size";
  if (i == 1)
    return "std_map_new_Map_i32_i32";
  if (i == 2)
    return "std_map_with_capacity_Map_i32_i32_ptr_i32";
  if (i == 3)
    return "std_map_insert_Map_i32_i32_ptr_i32_i32";
  if (i == 4)
    return "std_map_get_Map_i32_i32_i32";
  if (i == 5)
    return "std_map_find_Map_i32_i32_i32";
  if (i == 6)
    return "std_map_deinit_Map_i32_i32_ptr";
  if (i == 7)
    return "std_map_str_new";
  if (i == 8)
    return "std_map_str_insert";
  return NULL;
}

/* Pure orch: table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_map(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_map_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_map_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave121: product queue UNDEF table + needs_std_queue pure orch.
 * PLATFORM: SHARED — separate from contention labi_od_queue_sym_* (3 smoke/os symbols). */
int labi_od_queue_api_sym_count(void) { return 12; }
const char *labi_od_queue_api_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_queue_new_retQueue_i32";
  if (i == 1)
    return "std_queue_new_retQueue_u8";
  if (i == 2)
    return "std_queue_push_back_Queue_i32_ptr_i32";
  if (i == 3)
    return "std_queue_push_back_Queue_u8_ptr_u8";
  if (i == 4)
    return "std_queue_push_front";
  if (i == 5)
    return "std_queue_pop_front_Queue_i32_ptr";
  if (i == 6)
    return "std_queue_pop_back";
  if (i == 7)
    return "std_queue_get";
  if (i == 8)
    return "std_queue_len_Queue_i32";
  if (i == 9)
    return "std_queue_is_empty_Queue_i32";
  if (i == 10)
    return "std_queue_deinit_Queue_i32_ptr";
  if (i == 11)
    return "std_queue_with_capacity";
  return NULL;
}

/* Pure orch: product table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_queue(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_queue_api_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_queue_api_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave122: product test UNDEF/prefix table + needs_std_test pure orch.
 * PLATFORM: SHARED — prefixes (test_runner_ etc.) use Cap residual strstr in undef_sym. */
int labi_od_test_sym_count(void) { return 7; }
const char *labi_od_test_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "test_call_i32_void_c";
  if (i == 1)
    return "test_runner_";
  if (i == 2)
    return "test_expect_";
  if (i == 3)
    return "test_bench_";
  if (i == 4)
    return "test_f_test_";
  if (i == 5)
    return "test_io_";
  if (i == 6)
    return "test_fuzz_";
  return NULL;
}

/* Pure orch: test table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_test(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_test_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_test_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave123: product core.mem exact UNDEF table + needs_core_mem pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_core_mem_sym_count(void) { return 7; }
const char *labi_od_core_mem_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "core_mem_align_up";
  if (i == 1)
    return "core_mem_align_down";
  if (i == 2)
    return "core_mem_mem_copy";
  if (i == 3)
    return "core_mem_mem_set";
  if (i == 4)
    return "core_mem_mem_zero";
  if (i == 5)
    return "core_mem_mem_move";
  if (i == 6)
    return "core_mem_mem_compare";
  return NULL;
}

/* Pure orch: core_mem table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_core_mem(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_core_mem_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_core_mem_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave124: product core.slice exact UNDEF table + needs_core_slice pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_core_slice_sym_count(void) { return 6; }
const char *labi_od_core_slice_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "core_slice_i32_from_ptr_c";
  if (i == 1)
    return "core_subslice_i32_c";
  if (i == 2)
    return "core_slice_u8_from_ptr_c";
  if (i == 3)
    return "core_subslice_u8_c";
  if (i == 4)
    return "core_slice_u64_from_ptr_c";
  if (i == 5)
    return "core_subslice_u64_c";
  return NULL;
}

/* Pure orch: core_slice table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_core_slice(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_core_slice_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_core_slice_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
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
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave126: product std.sys.linux exact UNDEF table + needs_std_sys_linux pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_sys_linux_sym_count(void) { return 7; }
const char *labi_od_sys_linux_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_sys_linux_linux_syscall_invoke_available";
  if (i == 1)
    return "std_sys_linux_linux_anonymous_mmap";
  if (i == 2)
    return "std_sys_linux_linux_syscall_munmap";
  if (i == 3)
    return "std_sys_linux_linux_syscall_read";
  if (i == 4)
    return "std_sys_linux_linux_syscall_write";
  if (i == 5)
    return "std_sys_linux_linux_syscall_close";
  if (i == 6)
    return "std_sys_linux_linux_syscall_exit";
  return NULL;
}

/* Pure orch: sys_linux table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_sys_linux(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_sys_linux_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_sys_linux_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave127: product std.sys facade exact UNDEF table + needs_std_sys pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_sys_sym_count(void) { return 8; }
const char *labi_od_sys_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_sys_write_stdout";
  if (i == 1)
    return "std_sys_write_stderr";
  if (i == 2)
    return "std_sys_write";
  if (i == 3)
    return "std_sys_read";
  if (i == 4)
    return "std_sys_close";
  if (i == 5)
    return "std_sys_exit";
  if (i == 6)
    return "std_sys_freestanding_write_available";
  if (i == 7)
    return "std_sys_linux_syscall_table_available";
  return NULL;
}

/* Pure orch: sys table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_sys(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_sys_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_sys_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave128: product std.heap formal API exact UNDEF table + needs_std_heap_api pure orch.
 * PLATFORM: SHARED — exact symbols only (no prefix/strstr probes). */
int labi_od_heap_api_sym_count(void) { return 25; }
const char *labi_od_heap_api_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_heap_alloc_i32";
  if (i == 1)
    return "std_heap_alloc_u8";
  if (i == 2)
    return "std_heap_free_i32";
  if (i == 3)
    return "std_heap_free_u8";
  if (i == 4)
    return "std_heap_alloc_size_zero";
  if (i == 5)
    return "std_heap_alloc_usize";
  if (i == 6)
    return "std_heap_free_u8_ptr";
  if (i == 7)
    return "std_heap_default_alloc";
  if (i == 8)
    return "std_heap_kind_arena";
  if (i == 9)
    return "std_heap_alloc_Allocator_usize";
  if (i == 10)
    return "std_heap_realloc_Allocator_u8_ptr_usize";
  if (i == 11)
    return "std_heap_free_Allocator_u8_ptr";
  if (i == 12)
    return "std_heap_arena64_alloc";
  if (i == 13)
    return "std_heap_libc_heap_arena64_alloc_c";
  if (i == 14)
    return "std_heap_libc_heap_alloc_c";
  if (i == 15)
    return "std_heap_libc_heap_free_c";
  if (i == 16)
    return "std_heap_libc_heap_alloc_aligned_c";
  if (i == 17)
    return "std_heap_libc_heap_alloc_i32_c";
  if (i == 18)
    return "std_heap_libc_heap_alloc_u8_c";
  if (i == 19)
    return "std_heap_libc_heap_alloc_u64_c";
  if (i == 20)
    return "std_heap_libc_heap_free_i32_c";
  if (i == 21)
    return "std_heap_libc_heap_free_u8_c";
  if (i == 22)
    return "std_heap_libc_heap_free_u64_c";
  if (i == 23)
    return "std_heap_map_find";
  if (i == 24)
    return "std_heap_libc_heap_copy_u8_at_c";
  return NULL;
}

/* Pure orch: heap_api table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_std_heap_api(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_heap_api_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_heap_api_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave129: product runtime_heap_user exact UNDEF table + needs_heap_user_syms pure orch.
 * PLATFORM: SHARED — exact symbols only; product complete includes with_arena init/deinit. */
int labi_od_heap_user_sym_count(void) { return 7; }
const char *labi_od_heap_user_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "heap_alloc_c";
  if (i == 1)
    return "heap_free_c";
  if (i == 2)
    return "heap_realloc_c";
  if (i == 3)
    return "heap_arena64_alloc_c";
  if (i == 4)
    return "heap_arena_init_c";
  if (i == 5)
    return "heap_arena64_deinit_c";
  if (i == 6)
    return "heap_arena64_init_c";
  return NULL;
}

/* Pure orch: heap_user table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_heap_user_syms(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_heap_user_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_heap_user_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave130: product async scheduler exact UNDEF table + needs_async_scheduler pure orch.
 * PLATFORM: SHARED — exact symbols only; product complete coop/cps/frame/run/task/worker/io. */
int labi_od_async_scheduler_sym_count(void) { return 35; }
const char *labi_od_async_scheduler_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "shux_async_coop_pingpong";
  if (i == 1)
    return "shux_async_coop_pingpong_jmp";
  if (i == 2)
    return "shux_async_cps_suspend";
  if (i == 3)
    return "shux_async_asm_frame_phase_by_id";
  if (i == 4)
    return "shux_async_asm_frame_store_from_ptr";
  if (i == 5)
    return "shux_async_asm_frame_load_to_ptr";
  if (i == 6)
    return "shux_async_asm_frame_reset_by_id";
  if (i == 7)
    return "shux_async_cps_suspend_io";
  if (i == 8)
    return "shux_async_run_i32";
  if (i == 9)
    return "shux_async_task_submit";
  if (i == 10)
    return "shux_async_task_submit_to";
  if (i == 11)
    return "shux_async_scheduler_drain";
  if (i == 12)
    return "shux_async_worker_drain";
  if (i == 13)
    return "shux_async_worker_count";
  if (i == 14)
    return "shux_async_worker_pending";
  if (i == 15)
    return "shux_async_queue_reset";
  if (i == 16)
    return "shux_async_scheduler_pending";
  if (i == 17)
    return "shux_async_io_wake_all";
  if (i == 18)
    return "shux_async_io_waiters_pending";
  if (i == 19)
    return "shux_async_io_completions_ready";
  if (i == 20)
    return "shux_async_run_seed_set_i32";
  if (i == 21)
    return "shux_async_run_seed_reset";
  if (i == 22)
    return "shux_async_run_seed_push_i32";
  if (i == 23)
    return "shux_async_run_seed_push_u32";
  if (i == 24)
    return "shux_async_run_seed_push_i64";
  if (i == 25)
    return "shux_async_run_seed_valid";
  if (i == 26)
    return "shux_async_run_seed_take_i32";
  if (i == 27)
    return "shux_async_run_seed_take_u32";
  if (i == 28)
    return "shux_async_run_seed_take_i64";
  if (i == 29)
    return "shux_io_submit_read_async";
  if (i == 30)
    return "shux_io_complete_read_async";
  if (i == 31)
    return "shux_io_complete_read_async_slot";
  if (i == 32)
    return "shux_io_submit_write_async";
  if (i == 33)
    return "shux_io_complete_write_async";
  if (i == 34)
    return "shux_io_complete_write_async_slot";
  return NULL;
}

/* Pure orch: async_scheduler table + Cap residual undef_sym. PLATFORM: SHARED. */
int link_abi_user_o_needs_async_scheduler(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 0;
  n = labi_od_async_scheduler_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_async_scheduler_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave131: product compress family marker + UNDEF/prefix tables + pure orch.
 * PLATFORM: SHARED — Cap residual exports_marker + has_undef_sym (popen/nm). */
int labi_od_zlib_undef_sym_count(void) { return 4; }
const char *labi_od_zlib_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "_compress2";
  if (i == 1)
    return "_deflate";
  if (i == 2)
    return "_inflate";
  if (i == 3)
    return "_uncompress";
  return NULL;
}
const char *labi_od_compress_zlib_marker(void) { return "shu_compress_zlib_marker"; }

int labi_od_zstd_undef_sym_count(void) { return 2; }
const char *labi_od_zstd_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "ZSTD_";
  if (i == 1)
    return "_ZSTD";
  return NULL;
}
const char *labi_od_compress_zstd_marker(void) { return "shu_compress_zstd_marker"; }

int labi_od_brotli_undef_sym_count(void) { return 2; }
const char *labi_od_brotli_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "BrotliEncoderCompress";
  if (i == 1)
    return "BrotliDecoderDecompress";
  return NULL;
}
const char *labi_od_compress_brotli_marker(void) { return "shu_compress_brotli_marker"; }

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
const char *labi_od_runtime_time_os_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "time_now_monotonic_ns_c";
  if (i == 1)
    return "time_now_wall_ns_c";
  if (i == 2)
    return "time_sleep_ns_c";
  if (i == 3)
    return "time_format_wall_rfc3339_c";
  if (i == 4)
    return "time_wall_local_offset_min_c";
  if (i == 5)
    return "std_time_now_monotonic_ns";
  if (i == 6)
    return "std_time_now_wall_ns";
  if (i == 7)
    return "std_time_sleep_ms";
  if (i == 8)
    return "std_time_timer_start";
  if (i == 9)
    return "std_time_duration_ns";
  return NULL;
}
int labi_user_needs_runtime_time_os(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_time_os_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_time_os_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

int labi_od_runtime_random_fill_sym_count(void) { return 12; }
const char *labi_od_runtime_random_fill_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "random_fill_bytes_c";
  if (i == 1)
    return "std_random_fill_bytes";
  if (i == 2)
    return "std_random_fill";
  if (i == 3)
    return "std_random_next";
  if (i == 4)
    return "std_random_range_u32_u32";
  if (i == 5)
    return "std_random_gen";
  if (i == 6)
    return "std_random_flip";
  if (i == 7)
    return "std_random_rng_smoke";
  if (i == 8)
    return "std_random_seed";
  if (i == 9)
    return "random_u32_c";
  if (i == 10)
    return "random_u64_c";
  if (i == 11)
    return "random_rng_smoke_c";
  return NULL;
}
int labi_user_needs_runtime_random_fill(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_random_fill_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_random_fill_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

int labi_od_runtime_env_os_sym_count(void) { return 19; }
const char *labi_od_runtime_env_os_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "env_getenv_c";
  if (i == 1)
    return "env_getenv_exists_c";
  if (i == 2)
    return "env_getenv_z_c";
  if (i == 3)
    return "env_getenv_ptr_c";
  if (i == 4)
    return "env_setenv_c";
  if (i == 5)
    return "env_unsetenv_c";
  if (i == 6)
    return "env_temp_dir_c";
  if (i == 7)
    return "env_iter_count_c";
  if (i == 8)
    return "env_iter_at_c";
  if (i == 9)
    return "std_env_getenv";
  if (i == 10)
    return "std_env_getenv_exists";
  if (i == 11)
    return "std_env_getenv_z";
  if (i == 12)
    return "std_env_getenv_ptr";
  if (i == 13)
    return "std_env_setenv";
  if (i == 14)
    return "std_env_unsetenv";
  if (i == 15)
    return "std_env_temp_dir";
  if (i == 16)
    return "std_env_iter";
  if (i == 17)
    return "std_env_iter_count";
  if (i == 18)
    return "std_env_args_iter";
  return NULL;
}
int labi_user_needs_runtime_env_os(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_runtime_env_os_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_runtime_env_os_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave133: process_argv pure table + orch (9 needles). */
int labi_od_runtime_process_argv_sym_count(void) { return 9; }
const char *labi_od_runtime_process_argv_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "process_shux_argc_get";
  if (i == 1)
    return "process_shux_argv_get";
  if (i == 2)
    return "process_arg_c";
  if (i == 3)
    return "process_args_count_c";
  if (i == 4)
    return "std_process_args";
  if (i == 5)
    return "std_process_arg";
  if (i == 6)
    return "std_process_argc";
  if (i == 7)
    return "std_process_argv";
  if (i == 8)
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
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave134: std_task pure table + orch (29 needles; TASK_SPECIAL). */
int labi_od_std_task_sym_count(void) { return 29; }
const char *labi_od_std_task_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "std_task_new";
  if (i == 1)
    return "std_task_free";
  if (i == 2)
    return "std_task_bind";
  if (i == 3)
    return "std_task_spawn";
  if (i == 4)
    return "std_task_join";
  if (i == 5)
    return "std_task_pending";
  if (i == 6)
    return "std_task_check_leak";
  if (i == 7)
    return "std_task_cancel";
  if (i == 8)
    return "std_task_total";
  if (i == 9)
    return "std_task_set_new";
  if (i == 10)
    return "std_task_set_free";
  if (i == 11)
    return "std_task_set_spawn";
  if (i == 12)
    return "std_task_set_join";
  if (i == 13)
    return "std_task_set_check_leak";
  if (i == 14)
    return "std_task_echo";
  if (i == 15)
    return "std_task_echo_ptr";
  if (i == 16)
    return "std_task_retry";
  if (i == 17)
    return "std_task_err_ok";
  if (i == 18)
    return "task_group_create_c";
  if (i == 19)
    return "task_group_spawn_c";
  if (i == 20)
    return "task_group_join_c";
  if (i == 21)
    return "task_group_free_c";
  if (i == 22)
    return "join_set_create_c";
  if (i == 23)
    return "join_set_spawn_c";
  if (i == 24)
    return "join_set_join_c";
  if (i == 25)
    return "task_smoke_c";
  if (i == 26)
    return "task_supervise_retry_c";
  if (i == 27)
    return "task_echo_fn_c";
  if (i == 28)
    return "task_echo_fn_ptr_c";
  return NULL;
}
int labi_user_needs_std_task(const char *user_o) {
  int n;
  int i;
  if (!user_o || !user_o[0])
    return 1;
  n = labi_od_std_task_sym_count();
  for (i = 0; i < n; i++) {
    const char *sym = labi_od_std_task_sym_at(i);
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}


/* wave135: labi_std_fk0_user_needs_rel pure cold twin (tables + orch). */
int labi_fk0_rel_count(void) {
  return 16;
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
    return 3;
  if (k == 4)
    return 2;
  if (k == 5)
    return 2;
  if (k == 6)
    return 4;
  if (k == 7)
    return 7;
  if (k == 8)
    return 4;
  if (k == 9)
    return 4;
  if (k == 10)
    return 10;
  if (k == 11)
    return 9;
  if (k == 12)
    return 10;
  if (k == 13)
    return 12;
  if (k == 14)
    return 15;
  if (k == 15)
    return 9;
  return 0;
}

const char *labi_fk0_sym_at(int k, int i) {
  if (i < 0)
    return NULL;

  if (k == 0) {
    if (i == 0)
      return "std_string_string_empty";
    if (i == 1)
      return "std_string_new";
    if (i == 2)
      return "std_string_len_String";
    if (i == 3)
      return "std_string_len_StrView";
    if (i == 4)
      return "std_string_is_empty_String";
    if (i == 5)
      return "std_string_is_empty_StrView";
    if (i == 6)
      return "std_string_view";
    if (i == 7)
      return "std_string_string_from_slice";
    if (i == 8)
      return "std_string_string_eq";
    if (i == 9)
      return "shux_string_memcmp_c";
    if (i == 10)
      return "shux_string_memmem_c";
    return NULL;
  }
  if (k == 1) {
    if (i == 0)
      return "std_encoding_utf8_valid";
    if (i == 1)
      return "std_encoding_ascii_is_alpha";
    return NULL;
  }
  if (k == 2) {
    if (i == 0)
      return "std_base64_encode_standard";
    if (i == 1)
      return "std_base64_decode_standard";
    return NULL;
  }
  if (k == 3) {
    if (i == 0)
      return "std_http_get";
    if (i == 1)
      return "std_http_request";
    if (i == 2)
      return "std_http_client_new";
    return NULL;
  }
  if (k == 4) {
    if (i == 0)
      return "std_json_parse";
    if (i == 1)
      return "std_json_stringify";
    return NULL;
  }
  if (k == 5) {
    if (i == 0)
      return "std_csv_next_field";
    if (i == 1)
      return "std_csv_parse_line";
    return NULL;
  }
  if (k == 6) {
    if (i == 0)
      return "std_path_join";
    if (i == 1)
      return "std_path_dirname";
    if (i == 2)
      return "std_path_empty_len";
    if (i == 3)
      return "std_path_basename";
    return NULL;
  }
  if (k == 7) {
    if (i == 0)
      return "std_hash_sip_hash";
    if (i == 1)
      return "std_hash_fnv1a";
    if (i == 2)
      return "std_hash_start";
    if (i == 3)
      return "std_hash_bytes";
    if (i == 4)
      return "std_hash_finish";
    if (i == 5)
      return "std_hash_free";
    if (i == 6)
      return "std_hash_write_u8_ptr_u32";
    return NULL;
  }
  if (k == 8) {
    if (i == 0)
      return "std_error_http_err_timeout";
    if (i == 1)
      return "std_error_ok";
    if (i == 2)
      return "std_error_io_err_timeout";
    if (i == 3)
      return "std_error_io_err_cancelled";
    return NULL;
  }
  if (k == 9) {
    if (i == 0)
      return "std_context_background";
    if (i == 1)
      return "std_context_deadline_ns";
    if (i == 2)
      return "std_context_is_cancelled";
    if (i == 3)
      return "std_context_remaining_ns";
    return NULL;
  }
  if (k == 10) {
    if (i == 0)
      return "std_vec_new_retVec_u8";
    if (i == 1)
      return "std_vec_new_retVec_i32";
    if (i == 2)
      return "std_vec_push_Vec_u8_ptr_u8";
    if (i == 3)
      return "std_vec_push_Vec_i32_ptr_i32";
    if (i == 4)
      return "std_vec_len_Vec_u8";
    if (i == 5)
      return "std_vec_len_Vec_i32";
    if (i == 6)
      return "std_vec_len_empty";
    if (i == 7)
      return "std_vec_vec_len_empty";
    if (i == 8)
      return "std_vec_new";
    if (i == 9)
      return "std_vec_push";
    return NULL;
  }
  if (k == 11) {
    if (i == 0)
      return "std_sort_sort_i32_ptr_i32";
    if (i == 1)
      return "std_sort_sort_u8_ptr_i32";
    if (i == 2)
      return "std_sort_stable_i32_ptr_i32";
    if (i == 3)
      return "std_sort_stable_u8_ptr_i32";
    if (i == 4)
      return "std_sort_stable_by_key";
    if (i == 5)
      return "std_sort_cmp";
    if (i == 6)
      return "std_sort_cmp_asc_fn";
    if (i == 7)
      return "std_sort_cmp_desc_fn";
    if (i == 8)
      return "std_sort_cmp_key_fn";
    return NULL;
  }
  if (k == 12) {
    if (i == 0)
      return "std_env_getenv";
    if (i == 1)
      return "std_env_getenv_exists";
    if (i == 2)
      return "std_env_getenv_z";
    if (i == 3)
      return "std_env_getenv_ptr";
    if (i == 4)
      return "std_env_setenv";
    if (i == 5)
      return "std_env_unsetenv";
    if (i == 6)
      return "std_env_temp_dir";
    if (i == 7)
      return "std_env_iter";
    if (i == 8)
      return "std_env_iter_count";
    if (i == 9)
      return "std_env_args_iter";
    return NULL;
  }
  if (k == 13) {
    if (i == 0)
      return "std_random_next";
    if (i == 1)
      return "std_random_fill_bytes";
    if (i == 2)
      return "std_random_fill";
    if (i == 3)
      return "std_random_range_u32_u32";
    if (i == 4)
      return "std_random_flip";
    if (i == 5)
      return "std_random_gen";
    if (i == 6)
      return "std_random_rng_smoke";
    if (i == 7)
      return "std_random_seed";
    if (i == 8)
      return "random_u32_c";
    if (i == 9)
      return "random_u64_c";
    if (i == 10)
      return "random_rng_smoke_c";
    if (i == 11)
      return "random_fill_bytes_c";
    return NULL;
  }
  if (k == 14) {
    if (i == 0)
      return "std_time_now_monotonic_ns";
    if (i == 1)
      return "std_time_now_monotonic_ms";
    if (i == 2)
      return "std_time_now_wall_ns";
    if (i == 3)
      return "std_time_sleep_ms";
    if (i == 4)
      return "std_time_sleep_ns";
    if (i == 5)
      return "std_time_duration_ns";
    if (i == 6)
      return "std_time_timer_start";
    if (i == 7)
      return "std_time_start";
    if (i == 8)
      return "std_time_elapsed_ns";
    if (i == 9)
      return "std_time_format_wall_rfc3339";
    if (i == 10)
      return "std_time_wall_local_offset_min";
    if (i == 11)
      return "std_time_format_timezone_smoke";
    if (i == 12)
      return "time_now_monotonic_ns_c";
    if (i == 13)
      return "time_sleep_ns_c";
    if (i == 14)
      return "time_now_wall_ns_c";
    return NULL;
  }
  if (k == 15) {
    if (i == 0)
      return "std_fs_invalid";
    if (i == 1)
      return "std_fs_open";
    if (i == 2)
      return "std_fs_create";
    if (i == 3)
      return "std_fs_close";
    if (i == 4)
      return "std_fs_read";
    if (i == 5)
      return "std_fs_write";
    if (i == 6)
      return "std_fs_chunk_size";
    if (i == 7)
      return "std_fs_mmap_ro";
    if (i == 8)
      return "std_fs_last_error";
    return NULL;
  }
  return NULL;
}

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
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave190: labi_std_fk_user_needs pure cold twin (fk 1–13 gate tables + orch).
 * Cap residual: shux_link_obj_needs_undef_sym. PLATFORM: SHARED. */
int labi_std_fk_gate_sym_count(int fk) {
  if (fk == 1) return 4;
  if (fk == 2) return 4;
  if (fk == 3) return 5;
  if (fk == 4) return 3;
  if (fk == 5) return 5;
  if (fk == 6) return 5;
  if (fk == 7) return 4;
  if (fk == 8) return 2;
  if (fk == 9) return 29;
  if (fk == 10) return 3;
  if (fk == 11) return 2;
  if (fk == 12) return 4;
  if (fk == 13) return 4;
  return 0;
}

const char *labi_std_fk_gate_sym_at(int fk, int i) {
  if (i < 0) return NULL;
  if (fk == 1) {
    if (i == 0) return "process_shux_argv_get";
    if (i == 1) return "process_arg_c";
    if (i == 2) return "std_process_exit";
    if (i == 3) return "std_process_args";
    return NULL;
  }
  if (fk == 2) {
    if (i == 0) return "std_thread_spawn";
    if (i == 1) return "std_thread_join";
    if (i == 2) return "thread_create_c";
    if (i == 3) return "thread_join_c";
    return NULL;
  }
  if (fk == 3) {
    if (i == 0) return "std_sync_lock";
    if (i == 1) return "std_sync_new_mutex";
    if (i == 2) return "std_sync_try_lock";
    if (i == 3) return "std_sync_wait";
    if (i == 4) return "sync_mutex_lock_c";
    return NULL;
  }
  if (fk == 4) {
    if (i == 0) return "std_crypto_mem_eq";
    if (i == 1) return "crypto_mem_eq_c";
    if (i == 2) return "std_crypto_sha256";
    return NULL;
  }
  if (fk == 5) {
    if (i == 0) return "std_log_log";
    if (i == 1) return "std_log_level_info";
    if (i == 2) return "std_log_set_min_level";
    if (i == 3) return "log_write_c";
    if (i == 4) return "std_log_structured_kv";
    return NULL;
  }
  if (fk == 6) {
    if (i == 0) return "std_atomic_store_i32_ptr_i32";
    if (i == 1) return "std_atomic_load_i32_ptr";
    if (i == 2) return "std_atomic_fetch_add_i32_ptr_i32";
    if (i == 3) return "std_atomic_store_i64_ptr_i64";
    if (i == 4) return "atomic_store_i32_c";
    return NULL;
  }
  if (fk == 7) {
    if (i == 0) return "std_channel_send";
    if (i == 1) return "std_channel_recv";
    if (i == 2) return "channel_send";
    if (i == 3) return "channel_recv";
    return NULL;
  }
  if (fk == 8) {
    if (i == 0) return "std_backtrace_capture";
    if (i == 1) return "backtrace_capture";
    return NULL;
  }
  if (fk == 9) {
    if (i == 0) return "std_math_sin";
    if (i == 1) return "std_math_cos";
    if (i == 2) return "std_math_tan";
    if (i == 3) return "std_math_pi";
    if (i == 4) return "std_math_e";
    if (i == 5) return "std_math_tau";
    if (i == 6) return "std_math_floor";
    if (i == 7) return "std_math_ceil";
    if (i == 8) return "std_math_trunc";
    if (i == 9) return "std_math_round";
    if (i == 10) return "std_math_sqrt";
    if (i == 11) return "std_math_cbrt";
    if (i == 12) return "std_math_pow";
    if (i == 13) return "std_math_exp";
    if (i == 14) return "std_math_log";
    if (i == 15) return "std_math_abs";
    if (i == 16) return "std_math_signum";
    if (i == 17) return "std_math_min";
    if (i == 18) return "std_math_max";
    if (i == 19) return "std_math_asin";
    if (i == 20) return "std_math_acos";
    if (i == 21) return "std_math_atan";
    if (i == 22) return "std_math_atan2";
    if (i == 23) return "math_sin";
    if (i == 24) return "math_cos";
    if (i == 25) return "math_sin_c";
    if (i == 26) return "math_cos_c";
    if (i == 27) return "math_floor_c";
    if (i == 28) return "math_pi_c";
    return NULL;
  }
  if (fk == 10) {
    if (i == 0) return "std_db_sqlite";
    if (i == 1) return "sqlite3_open";
    if (i == 2) return "db_sqlite_open";
    return NULL;
  }
  if (fk == 11) {
    if (i == 0) return "std_elf_parse";
    if (i == 1) return "elf_parse";
    return NULL;
  }
  if (fk == 12) {
    if (i == 0) return "std_dynlib_open";
    if (i == 1) return "std_dynlib_sym";
    if (i == 2) return "dynlib_open_c";
    if (i == 3) return "dynlib_open";
    return NULL;
  }
  if (fk == 13) {
    if (i == 0) return "std_http_get";
    if (i == 1) return "std_http_request";
    if (i == 2) return "std_http_client_new";
    if (i == 3) return "std_http_request_timeout_ms_for_ctx";
    return NULL;
  }
  return NULL;
}

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
    if (sym && sym[0] && shux_link_obj_needs_undef_sym(user_o, sym) != 0)
      return 1;
  }
  return 0;
}

/* wave140: user.o provides_core_mem/std_heap defined-sym tables + pure orch.
 * Cap residual: shux_link_obj_has_defined_sym (popen/nm). PLATFORM: SHARED. */
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
    if (sym && sym[0] && shux_link_obj_has_defined_sym(user_o, sym) != 0)
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
    if (sym && sym[0] && shux_link_obj_has_defined_sym(user_o, sym) != 0)
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
const char *labi_od_rel_thread(void) { return "std/thread/thread.o"; }
const char *labi_od_rel_heap(void) { return "std/heap/heap.o"; }
const char *labi_od_rel_set(void) { return "std/set/set.o"; }
const char *labi_od_rel_map(void) { return "std/map/map.o"; }
const char *labi_od_rel_async_scheduler(void) { return "std/async/scheduler.o"; }
const char *labi_od_rel_core_mem(void) { return "core/mem/mem.o"; }
const char *labi_od_rel_sys_linux(void) { return "std/sys/linux.o"; }
const char *labi_od_rel_page_mmap(void) { return "std/heap/page_mmap.o"; }
const char *labi_od_rel_sys(void) { return "std/sys/sys.o"; }
const char *labi_od_rel_core_slice(void) { return "core/slice/slice.o"; }
const char *labi_od_rel_test(void) { return "std/test/test.o"; }
const char *labi_od_rel_heap_user(void) { return "compiler/runtime_heap_user.o"; }
const char *labi_od_rel_scheduler_glue(void) { return "compiler/runtime_scheduler_glue.o"; }
const char *labi_od_rel_thread_glue(void) { return "compiler/runtime_thread_glue.o"; }
const char *labi_od_rel_net_udp_batch(void) { return "compiler/runtime_net_udp_batch.o"; }
const char *labi_od_rel_net_workers(void) { return "compiler/runtime_net_workers.o"; }
const char *labi_od_rel_test_fn_invoke(void) { return "compiler/runtime_test_fn_invoke.o"; }

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
const char *labi_od_rel_heap(void);
const char *labi_od_rel_set(void);
const char *labi_od_rel_map(void);
const char *labi_od_rel_async_scheduler(void);
const char *labi_od_rel_core_mem(void);
const char *labi_od_rel_sys_linux(void);
const char *labi_od_rel_page_mmap(void);
const char *labi_od_rel_sys(void);
const char *labi_od_rel_core_slice(void);
const char *labi_od_rel_test(void);
const char *labi_od_rel_heap_user(void);
const char *labi_od_rel_scheduler_glue(void);
const char *labi_od_rel_thread_glue(void);
const char *labi_od_rel_net_udp_batch(void);
const char *labi_od_rel_net_workers(void);
const char *labi_od_rel_test_fn_invoke(void);
#endif

int labi_ondemand_list_slice_marker(void) {
  return 1;
}