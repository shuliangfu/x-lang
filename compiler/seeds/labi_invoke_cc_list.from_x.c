/* seeds/labi_invoke_cc_list.from_x.c — G-02f-274/L P2 link_abi L5 invoke_cc list pure → R2 full
 * Logic source: src/runtime/labi_invoke_cc_list.x
 * Hybrid: SHUX_LABI_INVOKE_CC_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供：
 *   labi_linux_harden_flag_{count,at}
 *   labi_invoke_cc_skip_native_env_{count,at} + invoke_cc_skip_native_tuning
 *   labi_icc_rel_* (12) + labi_icc_needs_rel_{count,at}
 * Cap residual：getenv 🔒（libc；.x extern）；fork/exec 仍在 mega shux_invoke_cc_impl。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_invoke_cc_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>
#include <stdlib.h>

#ifndef SHUX_LABI_INVOKE_CC_LIST_FROM_X

int labi_linux_harden_flag_count(void) {
  return 5;
}

const char *labi_linux_harden_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-pie";
  if (i == 1)
    return "-fpie";
  if (i == 2)
    return "-Wl,-z,noexecstack";
  if (i == 3)
    return "-Wl,-z,relro";
  if (i == 4)
    return "-Wl,--allow-multiple-definition";
  return NULL;
}

int labi_invoke_cc_skip_native_env_count(void) {
  return 3;
}

const char *labi_invoke_cc_skip_native_env_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "CI";
  if (i == 1)
    return "SHUX_CI_DOCKER";
  if (i == 2)
    return "SHUX_NO_MARCH_NATIVE";
  return NULL;
}

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

int labi_icc_needs_rel_count(void) {
  return 12;
}

const char *labi_icc_needs_rel_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "core/builtin/builtin.o";
  if (i == 1)
    return "core/builtin/builtin_abi.h";
  if (i == 2)
    return "core/mem/mem.o";
  if (i == 3)
    return "core/slice/slice.o";
  if (i == 4)
    return "std/db/kv/kv.o";
  if (i == 5)
    return "std/db/arrow/arrow.o";
  if (i == 6)
    return "std/csv/csv.o";
  if (i == 7)
    return "std/error/error.o";
  if (i == 8)
    return "std/heap/heap.o";
  if (i == 9)
    return "std/json/json.o";
  if (i == 10)
    return "std/log/log.o";
  if (i == 11)
    return "std/socketio/socketio.o";
  return NULL;
}

#else
int labi_linux_harden_flag_count(void);
const char *labi_linux_harden_flag_at(int i);
int labi_invoke_cc_skip_native_env_count(void);
const char *labi_invoke_cc_skip_native_env_at(int i);
int invoke_cc_skip_native_tuning(void);
const char *labi_icc_rel_core_builtin_o(void);
const char *labi_icc_rel_core_builtin_abi_h(void);
const char *labi_icc_rel_core_mem_o(void);
const char *labi_icc_rel_core_slice_o(void);
const char *labi_icc_rel_db_kv_o(void);
const char *labi_icc_rel_db_arrow_o(void);
const char *labi_icc_rel_csv_o(void);
const char *labi_icc_rel_error_o(void);
const char *labi_icc_rel_heap_o(void);
const char *labi_icc_rel_json_o(void);
const char *labi_icc_rel_log_o(void);
const char *labi_icc_rel_socketio_o(void);
int labi_icc_needs_rel_count(void);
const char *labi_icc_needs_rel_at(int i);
#endif

int labi_invoke_cc_list_slice_marker(void) {
  return 1;
}
