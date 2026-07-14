/* seeds/labi_ensure_list.from_x.c — G-02f-273 P2 link_abi L4 ensure list pure
 * Logic source: src/runtime/labi_ensure_list.x
 * Hybrid: SHUX_LABI_ENSURE_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure catalog: runtime ensure targets (stem / out.o / seed / flags / hint).
 * spawn/cc IO stays in mega link_abi_ensure_from_catalog.
 *
 * Track L：冷启动 / 回退 seed 与 .x 同构（if/else 短字面量，无 static 表；
 * step_at 经 accessor 聚合，与 .x 一致），便于 nm 全局符号 IDENTICAL；
 * 产品 PREFER_X_O 优先 .x（W-string-nul）。
 */
#include <stddef.h>

/* flags: 0=NONE, 1=PIE (-fPIE), 2=SQLITE (-DSHUX_DB_USE_SQLITE3) */

int labi_ensure_catalog_count(void) {
  return 26;
}

const char *labi_ensure_catalog_stem(int i) {
  if (i < 0)
    return NULL;

  if (i == 0)
    return "runtime_asm_io_stubs";
  if (i == 1)
    return "runtime_process_argv";
  if (i == 2)
    return "runtime_process_os_glue";
  if (i == 3)
    return "runtime_random_fill";
  if (i == 4)
    return "runtime_compress_zlib_glue";
  if (i == 5)
    return "runtime_time_os";
  if (i == 6)
    return "runtime_queue_contention";
  if (i == 7)
    return "runtime_dynlib_os";
  if (i == 8)
    return "runtime_env_os";
  if (i == 9)
    return "runtime_backtrace_platform";
  if (i == 10)
    return "runtime_log_os";
  if (i == 11)
    return "runtime_math_libm";
  if (i == 12)
    return "runtime_atomic_glue";
  if (i == 13)
    return "runtime_channel_glue";
  if (i == 14)
    return "runtime_net_udp_batch";
  if (i == 15)
    return "runtime_net_workers";
  if (i == 16)
    return "runtime_sync_os";
  if (i == 17)
    return "runtime_sync_lock_diag_tls";
  if (i == 18)
    return "runtime_thread_glue";
  if (i == 19)
    return "runtime_scheduler_glue";
  if (i == 20)
    return "runtime_http_glue";
  if (i == 21)
    return "runtime_kv_mmap_glue";
  if (i == 22)
    return "runtime_arrow_simd_glue";
  if (i == 23)
    return "runtime_sqlite_glue";
  if (i == 24)
    return "runtime_crypto_inc_glue";
  if (i == 25)
    return "runtime_ed25519_ref10_glue";
  return NULL;
}

const char *labi_ensure_catalog_out_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "runtime_asm_io_stubs.o";
  if (i == 1)
    return "runtime_process_argv.o";
  if (i == 2)
    return "runtime_process_os_glue.o";
  if (i == 3)
    return "runtime_random_fill.o";
  if (i == 4)
    return "runtime_compress_zlib_glue.o";
  if (i == 5)
    return "runtime_time_os.o";
  if (i == 6)
    return "runtime_queue_contention.o";
  if (i == 7)
    return "runtime_dynlib_os.o";
  if (i == 8)
    return "runtime_env_os.o";
  if (i == 9)
    return "runtime_backtrace_platform.o";
  if (i == 10)
    return "runtime_log_os.o";
  if (i == 11)
    return "runtime_math_libm.o";
  if (i == 12)
    return "runtime_atomic_glue.o";
  if (i == 13)
    return "runtime_channel_glue.o";
  if (i == 14)
    return "runtime_net_udp_batch.o";
  if (i == 15)
    return "runtime_net_workers.o";
  if (i == 16)
    return "runtime_sync_os.o";
  if (i == 17)
    return "runtime_sync_lock_diag_tls.o";
  if (i == 18)
    return "runtime_thread_glue.o";
  if (i == 19)
    return "runtime_scheduler_glue.o";
  if (i == 20)
    return "runtime_http_glue.o";
  if (i == 21)
    return "runtime_kv_mmap_glue.o";
  if (i == 22)
    return "runtime_arrow_simd_glue.o";
  if (i == 23)
    return "runtime_sqlite_glue.o";
  if (i == 24)
    return "runtime_crypto_inc_glue.o";
  if (i == 25)
    return "runtime_ed25519_ref10_glue.o";
  return NULL;
}

const char *labi_ensure_catalog_seed_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "runtime_asm_io_stubs.from_x.c";
  if (i == 1)
    return "runtime_process_argv.from_x.c";
  if (i == 2)
    return "runtime_process_os_glue.from_x.c";
  if (i == 3)
    return "runtime_random_fill.from_x.c";
  if (i == 4)
    return "runtime_compress_zlib_glue.from_x.c";
  if (i == 5)
    return "runtime_time_os.from_x.c";
  if (i == 6)
    return "runtime_queue_contention.from_x.c";
  if (i == 7)
    return "runtime_dynlib_os.from_x.c";
  if (i == 8)
    return "runtime_env_os.from_x.c";
  if (i == 9)
    return "runtime_backtrace_platform.from_x.c";
  if (i == 10)
    return "runtime_log_os.from_x.c";
  if (i == 11)
    return "runtime_math_libm.from_x.c";
  if (i == 12)
    return "runtime_atomic_glue.from_x.c";
  if (i == 13)
    return "runtime_channel_glue.from_x.c";
  if (i == 14)
    return "runtime_net_udp_batch.from_x.c";
  if (i == 15)
    return "runtime_net_workers.from_x.c";
  if (i == 16)
    return "runtime_sync_os.from_x.c";
  if (i == 17)
    return "runtime_sync_lock_diag_tls.from_x.c";
  if (i == 18)
    return "runtime_thread_glue.from_x.c";
  if (i == 19)
    return "runtime_scheduler_glue.from_x.c";
  if (i == 20)
    return "runtime_http_glue.from_x.c";
  if (i == 21)
    return "runtime_kv_mmap_glue.from_x.c";
  if (i == 22)
    return "runtime_arrow_simd_glue.from_x.c";
  if (i == 23)
    return "runtime_sqlite_glue.from_x.c";
  if (i == 24)
    return "runtime_crypto_inc_glue.from_x.c";
  if (i == 25)
    return "runtime_ed25519_ref10_glue.from_x.c";
  return NULL;
}

int labi_ensure_catalog_flags(int i) {
  if (i < 0)
    return 0;
  if (i == 0)
    return 1;
  if (i == 23)
    return 2;
  if (i >= 26)
    return 0;
  return 0;
}

int labi_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                const char **seed_base_out, int *flags_out,
                                const char **hint_out) {
  const char *s;
  if (i < 0 || i >= 26)
    return 0;
  s = labi_ensure_catalog_stem(i);
  if (!s)
    return 0;
  if (stem_out)
    *stem_out = s;
  if (out_base_out)
    *out_base_out = labi_ensure_catalog_out_base(i);
  if (seed_base_out)
    *seed_base_out = labi_ensure_catalog_seed_base(i);
  if (flags_out)
    *flags_out = labi_ensure_catalog_flags(i);
  if (hint_out) {
    if (i == 0)
      *hint_out = "try: make -C compiler runtime_asm_io_stubs.o";
    else if (i == 1)
      *hint_out = "try: make -C compiler runtime_process_argv.o";
    else
      *hint_out = NULL;
  }
  return 1;
}
