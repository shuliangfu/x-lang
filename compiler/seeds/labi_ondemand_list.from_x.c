/* seeds/labi_ondemand_list.from_x.c — G-02f-272 P2 link_abi L8b on_demand list pure
 * Logic source: src/runtime/labi_ondemand_list.x
 * Hybrid: SHUX_LABI_ONDEMAND_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: co-emit / on-demand symbol groups → std rel paths.
 * Probe (nm) + push/ensure stay in mega shux_asm_ld_append_on_demand_user_objs.
 */
#include <stddef.h>

/* Simple groups: any undef sym match → push single rel (no glue). */
enum {
  LABI_OD_SIMPLE_STRING = 0,
  LABI_OD_SIMPLE_CORE_TYPES = 1,
  LABI_OD_SIMPLE_ENCODING = 2,
  LABI_OD_SIMPLE_BASE64 = 3,
  LABI_OD_SIMPLE_CSV = 4,
  LABI_OD_SIMPLE_SCHEMA = 5,
  LABI_OD_SIMPLE_COUNT = 6
};

static const char *const g_od_string_syms[] = {
    "shux_string_copy_c",
    "shux_string_memcmp_c",
    "shux_string_memchr_c",
    "shux_string_memmem_c",
    "shux_string_memrchr_c",
    "std_string_string_new",
    "std_string_string_from_slice",
    "std_string_string_view",
    "std_string_string_len",
};

static const char *const g_od_core_types_syms[] = {
    "core_types_size_of_i32",
    "core_types_placeholder",
};

static const char *const g_od_encoding_syms[] = {
    "encoding_utf8_valid_c",
    "encoding_hex_encode_c",
    "encoding_ascii_is_alpha_c",
    "std_encoding_utf8_valid",
    "std_encoding_utf8_decode_rune",
    "std_encoding_ascii_is_alpha",
};

static const char *const g_od_base64_syms[] = {
    "base64_encode_standard_c",
    "std_base64_encode_standard",
    "std_base64_decode_standard",
    "std_base64_encode_url",
};

static const char *const g_od_csv_syms[] = {
    "std_csv_next_field",
    "std_csv_escape",
    "std_csv_csv_test_quoted_first",
};

static const char *const g_od_schema_syms[] = {
    "schema_create_c",
    "schema_decode_json_c",
    "schema_smoke_c",
};

static const char *const g_od_simple_rels[LABI_OD_SIMPLE_COUNT] = {
    "std/string/string.o",
    "std/base64/base64.o",
    "std/encoding/encoding.o",
    "std/base64/base64.o",
    "std/csv/csv.o",
    "std/schema/schema.o",
};

static const char *const *const g_od_simple_syms[LABI_OD_SIMPLE_COUNT] = {
    g_od_string_syms,
    g_od_core_types_syms,
    g_od_encoding_syms,
    g_od_base64_syms,
    g_od_csv_syms,
    g_od_schema_syms,
};

static const int g_od_simple_sym_n[LABI_OD_SIMPLE_COUNT] = {
    (int)(sizeof g_od_string_syms / sizeof g_od_string_syms[0]),
    (int)(sizeof g_od_core_types_syms / sizeof g_od_core_types_syms[0]),
    (int)(sizeof g_od_encoding_syms / sizeof g_od_encoding_syms[0]),
    (int)(sizeof g_od_base64_syms / sizeof g_od_base64_syms[0]),
    (int)(sizeof g_od_csv_syms / sizeof g_od_csv_syms[0]),
    (int)(sizeof g_od_schema_syms / sizeof g_od_schema_syms[0]),
};

int labi_od_simple_group_count(void) {
  return LABI_OD_SIMPLE_COUNT;
}

int labi_od_simple_group_sym_count(int g) {
  if (g < 0 || g >= LABI_OD_SIMPLE_COUNT)
    return 0;
  return g_od_simple_sym_n[g];
}

const char *labi_od_simple_group_sym_at(int g, int i) {
  if (g < 0 || g >= LABI_OD_SIMPLE_COUNT)
    return NULL;
  if (i < 0 || i >= g_od_simple_sym_n[g])
    return NULL;
  return g_od_simple_syms[g][i];
}

const char *labi_od_simple_group_rel(int g) {
  if (g < 0 || g >= LABI_OD_SIMPLE_COUNT)
    return NULL;
  return g_od_simple_rels[g];
}

/* KV: multi-sym → kv.o + optional glue rel */
static const char *const g_od_kv_syms[] = {
    "db_kv_open_c",
    "db_kv_get_c",
};

int labi_od_kv_sym_count(void) {
  return (int)(sizeof g_od_kv_syms / sizeof g_od_kv_syms[0]);
}

const char *labi_od_kv_sym_at(int i) {
  if (i < 0 || i >= labi_od_kv_sym_count())
    return NULL;
  return g_od_kv_syms[i];
}

const char *labi_od_kv_rel(void) {
  return "std/db/kv/kv.o";
}

const char *labi_od_kv_glue_rel(void) {
  return "compiler/runtime_kv_mmap_glue.o";
}

/* Arrow: multi-sym → arrow.o + glue */
static const char *const g_od_arrow_syms[] = {
    "arrow_column_i32_create_c",
    "arrow_column_adopt_f32_c",
};

int labi_od_arrow_sym_count(void) {
  return (int)(sizeof g_od_arrow_syms / sizeof g_od_arrow_syms[0]);
}

const char *labi_od_arrow_sym_at(int i) {
  if (i < 0 || i >= labi_od_arrow_sym_count())
    return NULL;
  return g_od_arrow_syms[i];
}

const char *labi_od_arrow_rel(void) {
  return "std/db/arrow/arrow.o";
}

const char *labi_od_arrow_glue_rel(void) {
  return "compiler/runtime_arrow_simd_glue.o";
}

/* Time: multi-sym → time_os + time.o */
static const char *const g_od_time_syms[] = {
    "std_time_now_monotonic_ns",
    "std_time_sleep_ms",
    "std_time_timer_start",
    "time_now_monotonic_ns_c",
};

int labi_od_time_sym_count(void) {
  return (int)(sizeof g_od_time_syms / sizeof g_od_time_syms[0]);
}

const char *labi_od_time_sym_at(int i) {
  if (i < 0 || i >= labi_od_time_sym_count())
    return NULL;
  return g_od_time_syms[i];
}

const char *labi_od_time_rel(void) {
  return "std/time/time.o";
}

const char *labi_od_time_os_rel(void) {
  return "compiler/runtime_time_os.o";
}

/* Queue contention: multi-sym → queue_contention + queue.o */
static const char *const g_od_queue_syms[] = {
    "sync_queue_contention_smoke_c",
    "queue_os_run_two_workers_c",
    "queue_contention_worker_push_c",
};

int labi_od_queue_sym_count(void) {
  return (int)(sizeof g_od_queue_syms / sizeof g_od_queue_syms[0]);
}

const char *labi_od_queue_sym_at(int i) {
  if (i < 0 || i >= labi_od_queue_sym_count())
    return NULL;
  return g_od_queue_syms[i];
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
