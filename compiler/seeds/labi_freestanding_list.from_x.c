/* seeds/labi_freestanding_list.from_x.c — G-02f-276 P2 link_abi L7 freestanding list pure
 * Logic source: src/runtime/labi_freestanding_list.x
 * Hybrid: SHUX_LABI_FREESTANDING_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: freestanding env name, needs_* symbol tables, ensure src/out basenames.
 * ensure/cc/spawn IO stays in mega.
 *
 * G-02f-L：冷启动 / 回退 seed 与 .x 同构（if/else 短字面量，无 static 表），
 * 便于 nm 全局符号 IDENTICAL；产品 PREFER_X_O 优先 .x（W-string-nul）。
 */
#include <stddef.h>

/* ---- env ---- */
const char *labi_fs_env_freestanding(void) {
  return "SHUX_FREESTANDING";
}

/* ---- freestanding_io probe symbols (any undef → needs io) ---- */
int labi_fs_io_sym_count(void) {
  return 13;
}

const char *labi_fs_io_sym_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "shux_sys_write";
  if (i == 1)
    return "shux_sys_read";
  if (i == 2)
    return "shux_sys_close";
  if (i == 3)
    return "shux_sys_exit";
  if (i == 4)
    return "shux_sys_open";
  if (i == 5)
    return "shux_sys_openat";
  if (i == 6)
    return "shux_sys_mmap";
  if (i == 7)
    return "shux_sys_munmap";
  if (i == 8)
    return "shux_sys_socket";
  if (i == 9)
    return "shux_sys_connect";
  if (i == 10)
    return "shux_sys_bind";
  if (i == 11)
    return "shux_sys_listen";
  if (i == 12)
    return "shux_sys_accept";
  return NULL;
}

/* ---- freestanding panic probe ---- */
const char *labi_fs_panic_sym(void) {
  return "shux_panic_";
}

/* ---- ensure catalog: out basename + asm source under compiler dir ---- */
int labi_fs_ensure_catalog_count(void) {
  return 2;
}

int labi_fs_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                   const char **src_rel_out) {
  if (i < 0 || i >= 2)
    return 0;
  if (i == 0) {
    if (stem_out)
      *stem_out = "crt0_user";
    if (out_base_out)
      *out_base_out = "crt0_user.o";
    if (src_rel_out)
      *src_rel_out = "src/asm/crt0_user_x86_64.s";
    return 1;
  }
  if (i == 1) {
    if (stem_out)
      *stem_out = "freestanding_io";
    if (out_base_out)
      *out_base_out = "freestanding_io.o";
    if (src_rel_out)
      *src_rel_out = "src/asm/freestanding_io_x86_64.s";
    return 1;
  }
  return 0;
}

const char *labi_fs_ensure_out_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "crt0_user.o";
  if (i == 1)
    return "freestanding_io.o";
  return NULL;
}

const char *labi_fs_ensure_src_rel(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "src/asm/crt0_user_x86_64.s";
  if (i == 1)
    return "src/asm/freestanding_io_x86_64.s";
  return NULL;
}

const char *labi_fs_ensure_stem(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "crt0_user";
  if (i == 1)
    return "freestanding_io";
  return NULL;
}

/* convenience accessors matching historic names */
const char *labi_fs_crt0_out_base(void) { return "crt0_user.o"; }
const char *labi_fs_crt0_src_rel(void) { return "src/asm/crt0_user_x86_64.s"; }
const char *labi_fs_io_out_base(void) { return "freestanding_io.o"; }
const char *labi_fs_io_src_rel(void) { return "src/asm/freestanding_io_x86_64.s"; }
