/* seeds/labi_ensure_list.from_x.c — G-02f-273 P2 link_abi L4 ensure list pure
 * Logic source: src/runtime/labi_ensure_list.x
 * Hybrid: SHUX_LABI_ENSURE_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure catalog: runtime ensure targets (stem / out.o / seed / flags).
 * spawn/cc IO stays in mega link_abi_ensure_from_catalog.
 */
#include <stddef.h>

/* flags for catalog entries */
enum {
  LABI_ENS_FLAG_NONE = 0,
  LABI_ENS_FLAG_PIE = 1,    /* -fPIE via shux_cc_compile_sync_ex */
  LABI_ENS_FLAG_SQLITE = 2  /* -DSHUX_DB_USE_SQLITE3 */
};

/* Catalog ids — keep in sync with mega thin wrappers. */
enum {
  LABI_ENS_ASM_IO_STUBS = 0,
  LABI_ENS_PROCESS_ARGV,
  LABI_ENS_PROCESS_OS_GLUE,
  LABI_ENS_RANDOM_FILL,
  LABI_ENS_COMPRESS_ZLIB_GLUE,
  LABI_ENS_TIME_OS,
  LABI_ENS_QUEUE_CONTENTION,
  LABI_ENS_DYNLIB_OS,
  LABI_ENS_ENV_OS,
  LABI_ENS_BACKTRACE_PLATFORM,
  LABI_ENS_LOG_OS,
  LABI_ENS_MATH_LIBM,
  LABI_ENS_ATOMIC_GLUE,
  LABI_ENS_CHANNEL_GLUE,
  LABI_ENS_NET_UDP_BATCH,
  LABI_ENS_NET_WORKERS,
  LABI_ENS_SYNC_OS,
  LABI_ENS_SYNC_LOCK_DIAG_TLS,
  LABI_ENS_THREAD_GLUE,
  LABI_ENS_SCHEDULER_GLUE,
  LABI_ENS_HTTP_GLUE,
  LABI_ENS_KV_MMAP_GLUE,
  LABI_ENS_ARROW_SIMD_GLUE,
  LABI_ENS_SQLITE_GLUE,
  LABI_ENS_CRYPTO_INC_GLUE,
  LABI_ENS_ED25519_REF10_GLUE,
  LABI_ENS_COUNT
};

typedef struct LabiEnsureEntry {
  const char *stem;       /* diag stem without .o (e.g. runtime_time_os) */
  const char *out_base;   /* runtime_time_os.o */
  const char *seed_base;  /* runtime_time_os.from_x.c under seeds/ */
  int flags;
  const char *resolve_hint; /* optional; empty => NULL to diag */
} LabiEnsureEntry;

static const LabiEnsureEntry g_labi_ens[] = {
    {"runtime_asm_io_stubs", "runtime_asm_io_stubs.o", "runtime_asm_io_stubs.from_x.c",
     LABI_ENS_FLAG_PIE, "try: make -C compiler runtime_asm_io_stubs.o"},
    {"runtime_process_argv", "runtime_process_argv.o", "runtime_process_argv.from_x.c",
     LABI_ENS_FLAG_NONE, "try: make -C compiler runtime_process_argv.o"},
    {"runtime_process_os_glue", "runtime_process_os_glue.o", "runtime_process_os_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_random_fill", "runtime_random_fill.o", "runtime_random_fill.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_compress_zlib_glue", "runtime_compress_zlib_glue.o", "runtime_compress_zlib_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_time_os", "runtime_time_os.o", "runtime_time_os.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_queue_contention", "runtime_queue_contention.o", "runtime_queue_contention.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_dynlib_os", "runtime_dynlib_os.o", "runtime_dynlib_os.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_env_os", "runtime_env_os.o", "runtime_env_os.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_backtrace_platform", "runtime_backtrace_platform.o", "runtime_backtrace_platform.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_log_os", "runtime_log_os.o", "runtime_log_os.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_math_libm", "runtime_math_libm.o", "runtime_math_libm.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_atomic_glue", "runtime_atomic_glue.o", "runtime_atomic_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_channel_glue", "runtime_channel_glue.o", "runtime_channel_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_net_udp_batch", "runtime_net_udp_batch.o", "runtime_net_udp_batch.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_net_workers", "runtime_net_workers.o", "runtime_net_workers.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_sync_os", "runtime_sync_os.o", "runtime_sync_os.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_sync_lock_diag_tls", "runtime_sync_lock_diag_tls.o", "runtime_sync_lock_diag_tls.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_thread_glue", "runtime_thread_glue.o", "runtime_thread_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_scheduler_glue", "runtime_scheduler_glue.o", "runtime_scheduler_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_http_glue", "runtime_http_glue.o", "runtime_http_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_kv_mmap_glue", "runtime_kv_mmap_glue.o", "runtime_kv_mmap_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_arrow_simd_glue", "runtime_arrow_simd_glue.o", "runtime_arrow_simd_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_sqlite_glue", "runtime_sqlite_glue.o", "runtime_sqlite_glue.from_x.c",
     LABI_ENS_FLAG_SQLITE, ""},
    {"runtime_crypto_inc_glue", "runtime_crypto_inc_glue.o", "runtime_crypto_inc_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
    {"runtime_ed25519_ref10_glue", "runtime_ed25519_ref10_glue.o", "runtime_ed25519_ref10_glue.from_x.c",
     LABI_ENS_FLAG_NONE, ""},
};

int labi_ensure_catalog_count(void) {
  return LABI_ENS_COUNT;
}

int labi_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                const char **seed_base_out, int *flags_out,
                                const char **hint_out) {
  if (i < 0 || i >= LABI_ENS_COUNT)
    return 0;
  if (stem_out)
    *stem_out = g_labi_ens[i].stem;
  if (out_base_out)
    *out_base_out = g_labi_ens[i].out_base;
  if (seed_base_out)
    *seed_base_out = g_labi_ens[i].seed_base;
  if (flags_out)
    *flags_out = g_labi_ens[i].flags;
  if (hint_out) {
    const char *h = g_labi_ens[i].resolve_hint;
    *hint_out = (h && h[0]) ? h : NULL;
  }
  return 1;
}

const char *labi_ensure_catalog_stem(int i) {
  if (i < 0 || i >= LABI_ENS_COUNT)
    return NULL;
  return g_labi_ens[i].stem;
}

const char *labi_ensure_catalog_out_base(int i) {
  if (i < 0 || i >= LABI_ENS_COUNT)
    return NULL;
  return g_labi_ens[i].out_base;
}

const char *labi_ensure_catalog_seed_base(int i) {
  if (i < 0 || i >= LABI_ENS_COUNT)
    return NULL;
  return g_labi_ens[i].seed_base;
}

int labi_ensure_catalog_flags(int i) {
  if (i < 0 || i >= LABI_ENS_COUNT)
    return 0;
  return g_labi_ens[i].flags;
}
