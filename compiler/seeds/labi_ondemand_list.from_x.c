/* seeds/labi_ondemand_list.from_x.c — G-02f-272 P2 link_abi L8b on_demand list pure → R2 full
 * Logic source: src/runtime/labi_ondemand_list.x
 * Hybrid: SHUX_LABI_ONDEMAND_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14 / wave118–122）：公共业务符号由 full .x 提供：
 *   simple/kv/arrow/time/queue + rel_* 纯表
 *   + labi_od_net_sym_{count,at} + link_abi_user_o_needs_std_net pure orch
 *   + labi_od_set_sym_{count,at} + link_abi_user_o_needs_std_set pure orch
 *   + labi_od_map_sym_{count,at} + link_abi_user_o_needs_std_map pure orch
 *   + labi_od_queue_api_sym_{count,at} + link_abi_user_o_needs_std_queue pure orch
 *   + labi_od_test_sym_{count,at} + link_abi_user_o_needs_std_test pure orch
 * Cap residual：nm 探针 + push/ensure 仍在 mega shux_asm_ld_append_on_demand_user_objs；
 *   undef_sym 探针仍 mega（pure needs orch Cap）。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_ondemand_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

/* Cap residual (mega always): nm UNDEF probe used by pure needs orch. */
int shux_link_obj_needs_undef_sym(const char *user_o, const char *sym);

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