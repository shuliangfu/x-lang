/* seeds/labi_path_pure.from_x.c — G-02f-267/429/L P2 link_abi L0 path pure → R2 full
 * Logic source: src/runtime/labi_path_pure.x
 * Hybrid: SHUX_LABI_PATH_PURE_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14 / wave114–116）：公共业务符号由 full .x 提供：
 *   labi_suffix_eq2/eq4 + link_abi_ld_argv_entry_is_obj + shux_output_is_elf_o
 *   + shux_output_want_exe + shux_path_has_sep + shux_path_last_sep
 *   + shux_asm_ld_lib_root_ptr_usable (wave114 low-tag)
 *   + shux_asm_ld_lib_root_default (wave115 SHUX_LIB/"." ; Cap residual getenv)
 *   + shux_asm_ld_try_under_lib_roots (wave116 pure join; Cap residual skip+bank)
 *   + count
 * Cap residual（mega rest 冷路径）：Windows #if '\\' 分隔符；产品 PREFER 走 .x POSIX。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_path_pure_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>

/* Cap residual used by wave116 cold twin (product hybrid: path_io + gates). */
const char *asm_link_obj_skip_missing(const char *path);
const char *shux_asm_ld_bank_push(void *b, const char *path);

#ifndef SHUX_LABI_PATH_PURE_FROM_X

int32_t labi_suffix_eq2(uint8_t *s, int32_t n, uint8_t a0, uint8_t a1) {
  if (n < 2) {
    return 0;
  }
  if (s[n - 2] != a0) {
    return 0;
  }
  if (s[n - 1] != a1) {
    return 0;
  }
  return 1;
}

int32_t labi_suffix_eq4(uint8_t *s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3) {
  if (n < 4) {
    return 0;
  }
  if (s[n - 4] != a0) {
    return 0;
  }
  if (s[n - 3] != a1) {
    return 0;
  }
  if (s[n - 2] != a2) {
    return 0;
  }
  if (s[n - 1] != a3) {
    return 0;
  }
  return 1;
}

int32_t link_abi_ld_argv_entry_is_obj(uint8_t *s) {
  int32_t n = 0;
  if (s == ((uint8_t *)(0))) {
    return 0;
  }
  if (s[0] == 0) {
    return 0;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  if (labi_suffix_eq2(s, n, 46, 111) != 0) {
    return 1;
  }
  if (labi_suffix_eq4(s, n, 46, 111, 98, 106) != 0) {
    return 1;
  }
  return 0;
}

int32_t shux_output_is_elf_o(uint8_t *path) {
  int32_t n = 0;
  if (path == ((uint8_t *)(0))) {
    return 0;
  }
  while (path[n] != 0) {
    n = n + 1;
  }
  if (labi_suffix_eq2(path, n, 46, 111) != 0) {
    return 1;
  }
  if (labi_suffix_eq2(path, n, 46, 79) != 0) {
    return 1;
  }
  if (labi_suffix_eq4(path, n, 46, 111, 98, 106) != 0) {
    return 1;
  }
  return 0;
}

int32_t shux_output_want_exe(uint8_t *path) {
  int32_t n = 0;
  if (path == ((uint8_t *)(0))) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  while (path[n] != 0) {
    n = n + 1;
  }
  if (labi_suffix_eq2(path, n, 46, 111) != 0) {
    return 0;
  }
  if (labi_suffix_eq2(path, n, 46, 79) != 0) {
    return 0;
  }
  if (labi_suffix_eq2(path, n, 46, 115) != 0) {
    return 0;
  }
  if (labi_suffix_eq4(path, n, 46, 111, 98, 106) != 0) {
    return 0;
  }
  return 1;
}

int32_t shux_path_has_sep(uint8_t *s) {
  if (s == ((uint8_t *)(0))) {
    return 0;
  }
  int32_t i = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

uint8_t *shux_path_last_sep(uint8_t *s) {
  if (s == ((uint8_t *)(0))) {
    return ((uint8_t *)(0));
  }
  int32_t last = 0;
  int32_t found = 0;
  int32_t i = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      last = i;
      found = 1;
    }
    i = i + 1;
  }
  if (found == 0) {
    return ((uint8_t *)(0));
  }
  size_t base = ((size_t)(s));
  return ((uint8_t *)((base + ((size_t)(last)))));
}

/* wave114 cold twin: lib-root pointer usable (null / low-tag / empty). */
int32_t shux_asm_ld_lib_root_ptr_usable(uint8_t *p) {
  if (p == ((uint8_t *)(0))) {
    return 0;
  }
  if (((size_t)(p)) < ((size_t)(4096))) {
    return 0;
  }
  if (p[0] == 0) {
    return 0;
  }
  return 1;
}

/* wave115 cold twin: default lib-root (SHUX_LIB or "."). Cap residual: getenv. */
void shux_asm_ld_lib_root_default(uint8_t *root_buf) {
  const char *def;
  root_buf[0] = (uint8_t)'.';
  root_buf[1] = 0;
  def = getenv("SHUX_LIB");
  if (shux_asm_ld_lib_root_ptr_usable((uint8_t *)def) == 0) {
    return;
  }
  strncpy((char *)root_buf, def, 511);
  root_buf[511] = 0;
}

/* wave116 cold twin: try rel under each lib root (pure join; Cap skip+bank). */
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, void *bank) {
  int i;
  char tmp[4096];
  size_t rel_n;
  if (!rel || (uintptr_t)rel < 4096u)
    return NULL;
  if (!rel[0] || !bank || !lib_roots || (uintptr_t)lib_roots < 4096u || n_lib_roots <= 0)
    return NULL;
  rel_n = strlen(rel);
  for (i = 0; i < n_lib_roots && i < 24; i++) {
    size_t rn;
    size_t j;
    const char *root = lib_roots[i];
    if (!root || (uintptr_t)root < 4096u)
      continue;
    if (!root[0])
      continue;
    rn = strlen(root);
    while (rn > 1 && root[rn - 1] == '/')
      rn--;
    if (rn + 2 + rel_n >= sizeof(tmp))
      continue;
    if (rn > 0) {
      for (j = 0; j < rn; j++)
        tmp[j] = root[j];
      tmp[rn] = '/';
      for (j = 0; j <= rel_n; j++)
        tmp[rn + 1 + j] = rel[j];
    } else {
      for (j = 0; j <= rel_n; j++)
        tmp[j] = rel[j];
    }
    if (!asm_link_obj_skip_missing(tmp))
      continue;
    return shux_asm_ld_bank_push(bank, tmp);
  }
  return NULL;
}

/* Pure audit: number of L0 path-pure public gates in this slice. */
int32_t labi_path_pure_count(void) {
  return 10;
}

#else
int32_t labi_suffix_eq2(uint8_t *s, int32_t n, uint8_t a0, uint8_t a1);
int32_t labi_suffix_eq4(uint8_t *s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3);
int32_t link_abi_ld_argv_entry_is_obj(uint8_t *s);
int32_t shux_output_is_elf_o(uint8_t *path);
int32_t shux_output_want_exe(uint8_t *path);
int32_t shux_path_has_sep(uint8_t *s);
uint8_t *shux_path_last_sep(uint8_t *s);
int32_t shux_asm_ld_lib_root_ptr_usable(uint8_t *p);
void shux_asm_ld_lib_root_default(uint8_t *root_buf);
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, void *bank);
int32_t labi_path_pure_count(void);
#endif

int labi_path_pure_slice_marker(void) {
  return 1;
}
