/* seeds/rt_compile.from_x.c — G-02f-291/292 P2 runtime R6 compile pure helpers
 * Logic source: src/runtime/rt_compile.x
 * Hybrid: SHUX_RT_COMPILE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-291: deps_std_core + emit_asm path pure
 * f-292: argv state field helpers (copy_path / freestanding / help)
 * Full driver_compile_* phase/IO remains in runtime mega rest.
 */
#if !defined(_POSIX_C_SOURCE)
#define _POSIX_C_SOURCE 200809L
#endif
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* Layout matches seeds/runtime.from_x.c DriverCompileStateSU (fields used here). */
typedef struct DriverCompileStateSU {
  uint8_t path_buf[512];
  int32_t path_len;
  uint8_t out_path_buf[512];
  int32_t out_path_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  uint8_t target_buf[512];
  int32_t target_len;
  uint8_t opt_level_buf[8];
  int32_t opt_level_len;
  int32_t use_lto;
  int32_t backend_asm_explicit;
  int32_t use_freestanding;
  int32_t parse_saw_target;
  uint8_t target_cpu_buf[64];
  int32_t target_cpu_len;
  int32_t target_cpu_features;
  int32_t print_target_cpu;
  int32_t parse_saw_target_cpu;
} DriverCompileStateSU;

extern void driver_freestanding_set(int on);
extern void cfg_set_freestanding(int on);
extern void driver_sanitize_address_set(int on);
extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);

/**
 * dep 列表是否全为 std./core. 闭包（符号由预编 .o / preamble 提供，勿 dep_prerun 全量 typeck）。
 * tests/multi-file 的 import("foo") 等用户 dep 返回 0，仍走 typeck_only。
 */
int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps) {
  int k;
  if (!dep_paths || n_deps <= 0)
    return 0;
  for (k = 0; k < n_deps; k++) {
    const char *p = dep_paths[k];
    if (!p || p[0] == '\0')
      return 0;
    if (strncmp(p, "std.", 4) == 0 || strncmp(p, "core.", 5) == 0)
      continue;
    return 0;
  }
  return 1;
}

/**
 * `-E src/asm/asm.x` 的 compiler-internal 闭包仅需 parse 填 import/签名槽；
 * 对 `ast` 等大模块做 dep_prerun typeck 会显著拖慢甚至卡住 seed host 构建。
 */
int driver_x_emit_asm_dep_parse_only_ok(const char *input_path, const char *dep_path) {
  if (!input_path || !dep_path)
    return 0;
  if (strstr(input_path, "src/asm/asm.x") == NULL && strstr(input_path, "/asm/asm.x") == NULL)
    return 0;
  if (strcmp(dep_path, "ast") == 0 || strcmp(dep_path, "codegen") == 0 || strcmp(dep_path, "backend") == 0 ||
      strcmp(dep_path, "peephole") == 0)
    return 1;
  if (strncmp(dep_path, "asm.", 4) == 0 || strncmp(dep_path, "arch.", 5) == 0 ||
      strncmp(dep_path, "platform.", 9) == 0)
    return 1;
  return 0;
}

int driver_x_emit_asm_direct_import_only(const char *input_path) {
  if (!input_path)
    return 0;
  if (strstr(input_path, "src/asm/asm.x") != NULL || strstr(input_path, "/asm/asm.x") != NULL)
    return 1;
  if (strstr(input_path, "src/asm/asm_seed_full.x") != NULL ||
      strstr(input_path, "/asm/asm_seed_full.x") != NULL)
    return 1;
  return 0;
}

int driver_x_emit_asm_dep_parse_skip_typeck_ok(const char *input_path, const char *dep_path) {
  if (!driver_x_emit_asm_direct_import_only(input_path) || !dep_path)
    return 0;
  return strcmp(dep_path, "backend") == 0;
}

/* --- G-02f-292: argv state field helpers --- */

void driver_compile_argv_copy_path_c(DriverCompileStateSU *state, uint8_t *arg_buf, int32_t plen) {
  int32_t k;
  int32_t n;
  if (!state || !arg_buf || plen <= 0)
    return;
  n = plen;
  if (n > 511)
    n = 511;
  for (k = 0; k < n; k++)
    state->path_buf[k] = arg_buf[k];
  state->path_len = n;
}

/** `-freestanding`：置 use_freestanding 并同步 driver_freestanding_set（S4 nostdlib 链）。 */
void driver_compile_argv_set_use_freestanding_c(DriverCompileStateSU *state) {
  if (!state)
    return;
  state->use_freestanding = 1;
  driver_freestanding_set(1);
  cfg_set_freestanding(1);
}

/** `-legacy-f32-abi`：等价 SHUX_ABI_F32_XMM=0。 */
void driver_compile_argv_set_legacy_f32_abi_c(void) {
  setenv("SHUX_ABI_F32_XMM", "0", 1);
}

/** `-fsanitize=address`：M-6 debug 边界插桩。 */
void driver_compile_argv_set_sanitize_address_c(void) {
  driver_sanitize_address_set(1);
}

/**
 * 扫描 argv 是否含 `-h` 或 `--help`。
 * 返回 1 表示应打印用法并 exit 0。
 */
int32_t driver_compile_argv_is_help_c(int32_t argc, uint8_t *argv_opaque) {
  char **argv = (char **)argv_opaque;
  char buf[16];
  int len;
  int i;

  if (argc < 2 || !argv)
    return 0;
  for (i = 1; i < argc; i++) {
    len = driver_get_argv_i(argc, argv, i, buf, (int)sizeof(buf));
    if (len == 2 && buf[0] == '-' && buf[1] == 'h')
      return 1;
    if (len == 6 && !memcmp(buf, "--help", 6))
      return 1;
  }
  return 0;
}

int labi_rt_compile_slice_marker(void) {
  return 1;
}
