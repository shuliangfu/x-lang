/* seeds/labi_invoke_cc_list.from_x.c — G-02f-274 P2 link_abi L5 invoke_cc list pure
 * Logic source: src/runtime/labi_invoke_cc_list.x
 * Hybrid: SHUX_LABI_INVOKE_CC_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: linux harden flags, skip-native env names, invoke_cc rel paths.
 * fork/exec/spawn IO stays in mega shux_invoke_cc_impl.
 */
#include <stddef.h>
#include <stdlib.h>

/* ---- Linux release link harden argv tokens (order matters) ---- */
static const char *const g_labi_linux_harden_flags[] = {
    "-pie",
    "-fpie",
    "-Wl,-z,noexecstack",
    "-Wl,-z,relro",
    "-Wl,--allow-multiple-definition",
};

int labi_linux_harden_flag_count(void) {
  return (int)(sizeof g_labi_linux_harden_flags / sizeof g_labi_linux_harden_flags[0]);
}

const char *labi_linux_harden_flag_at(int i) {
  int n = labi_linux_harden_flag_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_linux_harden_flags[i];
}

/* ---- env names that force skip -march=native / -flto ---- */
static const char *const g_labi_skip_native_envs[] = {
    "CI",
    "SHUX_CI_DOCKER",
    "SHUX_NO_MARCH_NATIVE",
};

int labi_invoke_cc_skip_native_env_count(void) {
  return (int)(sizeof g_labi_skip_native_envs / sizeof g_labi_skip_native_envs[0]);
}

const char *labi_invoke_cc_skip_native_env_at(int i) {
  int n = labi_invoke_cc_skip_native_env_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_skip_native_envs[i];
}

/* getenv 🔒 — still pure policy table; used by invoke_cc / hybrid product path. */
int invoke_cc_skip_native_tuning(void) {
  int n = labi_invoke_cc_skip_native_env_count();
  int i;
  for (i = 0; i < n; i++) {
    const char *name = labi_invoke_cc_skip_native_env_at(i);
    if (name && name[0] && getenv(name) != NULL)
      return 1;
  }
  return 0;
}

/* ---- include_root-relative paths used by invoke_cc needs_* branches ---- */
const char *labi_icc_rel_core_builtin_o(void) { return "core/builtin/builtin.o"; }
const char *labi_icc_rel_core_builtin_abi_h(void) { return "core/builtin/builtin_abi.h"; }
const char *labi_icc_rel_core_mem_o(void) { return "core/mem/mem.o"; }
const char *labi_icc_rel_core_slice_o(void) { return "core/slice/slice.o"; }
const char *labi_icc_rel_db_kv_o(void) { return "std/db/kv/kv.o"; }
const char *labi_icc_rel_db_arrow_o(void) { return "std/db/arrow/arrow.o"; }
const char *labi_icc_rel_csv_o(void) { return "std/csv/csv.o"; }
const char *labi_icc_rel_error_o(void) { return "std/error/error.o"; }
const char *labi_icc_rel_heap_o(void) { return "std/heap/heap.o"; }
const char *labi_icc_rel_json_o(void) { return "std/json/json.o"; }
const char *labi_icc_rel_log_o(void) { return "std/log/log.o"; }
const char *labi_icc_rel_socketio_o(void) { return "std/socketio/socketio.o"; }

/* Indexed table for audit / unit (same 12 rels). */
static const char *const g_labi_icc_needs_rels[] = {
    "core/builtin/builtin.o",
    "core/builtin/builtin_abi.h",
    "core/mem/mem.o",
    "core/slice/slice.o",
    "std/db/kv/kv.o",
    "std/db/arrow/arrow.o",
    "std/csv/csv.o",
    "std/error/error.o",
    "std/heap/heap.o",
    "std/json/json.o",
    "std/log/log.o",
    "std/socketio/socketio.o",
};

int labi_icc_needs_rel_count(void) {
  return (int)(sizeof g_labi_icc_needs_rels / sizeof g_labi_icc_needs_rels[0]);
}

const char *labi_icc_needs_rel_at(int i) {
  int n = labi_icc_needs_rel_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_icc_needs_rels[i];
}
