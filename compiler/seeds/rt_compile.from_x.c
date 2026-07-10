/* seeds/rt_compile.from_x.c — G-02f-291 P2 runtime R6-lite (compile pure deps)
 * Logic source: src/runtime/rt_compile.x
 * Hybrid: SHUX_RT_COMPILE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: pure string/path helpers used by compile/emit orchestration.
 * Full driver_compile_* phase/IO remains in runtime mega rest.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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

int labi_rt_compile_slice_marker(void) {
  return 1;
}
