/* seeds/labi_invoke_cc_list_surface.from_x.c
 * G-02f labi_invoke_cc_list R2 full surface — isomorphic with cold seed string tables.
 *
 * 【Why 根源】旧 surface 由 .x STRING_LIT 生成 `(uint8_t[]){...}; return p`：
 *   C 块作用域 compound literal 为自动存储，return 后悬空。
 *   labi_linux_harden_flag_at 被 invoke_cc 写入 argv → gcc 收到乱码路径。
 * 【Invariant】全部返回 C 字符串字面量（rodata），与 labi_invoke_cc_list.from_x.c 冷路径一致。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>

int32_t labi_linux_harden_flag_count(void) {
  return 5;
}

uint8_t *labi_linux_harden_flag_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"-pie";
  if (i == 1)
    return (uint8_t *)"-fpie";
  if (i == 2)
    return (uint8_t *)"-Wl,-z,noexecstack";
  if (i == 3)
    return (uint8_t *)"-Wl,-z,relro";
  if (i == 4)
    return (uint8_t *)"-Wl,--allow-multiple-definition";
  return NULL;
}

int32_t labi_invoke_cc_skip_native_env_count(void) {
  return 3;
}

uint8_t *labi_invoke_cc_skip_native_env_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"CI";
  if (i == 1)
    return (uint8_t *)"SHUX_CI_DOCKER";
  if (i == 2)
    return (uint8_t *)"SHUX_NO_MARCH_NATIVE";
  return NULL;
}

int32_t invoke_cc_skip_native_tuning(void) {
  int32_t n = labi_invoke_cc_skip_native_env_count();
  int32_t i;
  for (i = 0; i < n; i++) {
    uint8_t *name = labi_invoke_cc_skip_native_env_at(i);
    if (name && name[0] && getenv((const char *)name) != NULL)
      return 1;
  }
  return 0;
}

uint8_t *labi_icc_rel_core_builtin_o(void) {
  return (uint8_t *)"core/builtin/builtin.o";
}
uint8_t *labi_icc_rel_core_builtin_abi_h(void) {
  return (uint8_t *)"core/builtin/builtin_abi.h";
}
uint8_t *labi_icc_rel_core_mem_o(void) {
  return (uint8_t *)"core/mem/mem.o";
}
uint8_t *labi_icc_rel_core_slice_o(void) {
  return (uint8_t *)"core/slice/slice.o";
}
uint8_t *labi_icc_rel_db_kv_o(void) {
  return (uint8_t *)"std/db/kv/kv.o";
}
uint8_t *labi_icc_rel_db_arrow_o(void) {
  return (uint8_t *)"std/db/arrow/arrow.o";
}
uint8_t *labi_icc_rel_csv_o(void) {
  return (uint8_t *)"std/csv/csv.o";
}
uint8_t *labi_icc_rel_error_o(void) {
  return (uint8_t *)"std/error/error.o";
}
uint8_t *labi_icc_rel_heap_o(void) {
  return (uint8_t *)"std/heap/heap.o";
}
uint8_t *labi_icc_rel_json_o(void) {
  return (uint8_t *)"std/json/json.o";
}
uint8_t *labi_icc_rel_log_o(void) {
  return (uint8_t *)"std/log/log.o";
}
uint8_t *labi_icc_rel_socketio_o(void) {
  return (uint8_t *)"std/socketio/socketio.o";
}

int32_t labi_icc_needs_rel_count(void) {
  return 12;
}

uint8_t *labi_icc_needs_rel_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"core/builtin/builtin.o";
  if (i == 1)
    return (uint8_t *)"core/builtin/builtin_abi.h";
  if (i == 2)
    return (uint8_t *)"core/mem/mem.o";
  if (i == 3)
    return (uint8_t *)"core/slice/slice.o";
  if (i == 4)
    return (uint8_t *)"std/db/kv/kv.o";
  if (i == 5)
    return (uint8_t *)"std/db/arrow/arrow.o";
  if (i == 6)
    return (uint8_t *)"std/csv/csv.o";
  if (i == 7)
    return (uint8_t *)"std/error/error.o";
  if (i == 8)
    return (uint8_t *)"std/heap/heap.o";
  if (i == 9)
    return (uint8_t *)"std/json/json.o";
  if (i == 10)
    return (uint8_t *)"std/log/log.o";
  if (i == 11)
    return (uint8_t *)"std/socketio/socketio.o";
  return NULL;
}
