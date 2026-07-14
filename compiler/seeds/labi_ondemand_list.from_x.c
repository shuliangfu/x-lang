/* seeds/labi_ondemand_list.from_x.c — G-02f-272 P2 link_abi L8b on_demand list pure → R2 full
 * Logic source: src/runtime/labi_ondemand_list.x
 * Hybrid: SHUX_LABI_ONDEMAND_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供（simple/kv/arrow/time/queue + rel_*）。
 * Cap residual：nm 探针 + push/ensure 仍在 mega shux_asm_ld_append_on_demand_user_objs。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_ondemand_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

#ifndef SHUX_LABI_ONDEMAND_LIST_FROM_X

/* Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5 */

int labi_od_simple_group_count(void) {
  return 6;
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
  return NULL;
}

const char *labi_od_simple_group_rel(int g) {
  if (g < 0)
    return NULL;
  if (g == 0)
    return "std/string/string.o";
  if (g == 1)
    return "std/base64/base64.o";
  if (g == 2)
    return "std/encoding/encoding.o";
  if (g == 3)
    return "std/base64/base64.o";
  if (g == 4)
    return "std/csv/csv.o";
  if (g == 5)
    return "std/schema/schema.o";
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