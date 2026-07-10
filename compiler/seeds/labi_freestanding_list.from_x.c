/* seeds/labi_freestanding_list.from_x.c — G-02f-276 P2 link_abi L7 freestanding list pure
 * Logic source: src/runtime/labi_freestanding_list.x
 * Hybrid: SHUX_LABI_FREESTANDING_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: freestanding env name, needs_* symbol tables, ensure src/out basenames.
 * ensure/cc/spawn IO stays in mega.
 */
#include <stddef.h>

/* ---- env ---- */
const char *labi_fs_env_freestanding(void) {
  return "SHUX_FREESTANDING";
}

/* ---- freestanding_io probe symbols (any undef → needs io) ---- */
static const char *const g_labi_fs_io_syms[] = {
    "shux_sys_write",
    "shux_sys_read",
    "shux_sys_close",
    "shux_sys_exit",
    "shux_sys_open",
    "shux_sys_openat",
    "shux_sys_mmap",
    "shux_sys_munmap",
    "shux_sys_socket",
    "shux_sys_connect",
    "shux_sys_bind",
    "shux_sys_listen",
    "shux_sys_accept",
};

int labi_fs_io_sym_count(void) {
  return (int)(sizeof g_labi_fs_io_syms / sizeof g_labi_fs_io_syms[0]);
}

const char *labi_fs_io_sym_at(int i) {
  int n = labi_fs_io_sym_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_fs_io_syms[i];
}

/* ---- freestanding panic probe ---- */
const char *labi_fs_panic_sym(void) {
  return "shux_panic_";
}

/* ---- ensure catalog: out basename + asm source under compiler dir ---- */
enum {
  LABI_FS_ENS_CRT0 = 0,
  LABI_FS_ENS_IO = 1,
  LABI_FS_ENS_COUNT = 2
};

typedef struct LabiFsEnsureEntry {
  const char *stem;      /* diag stem */
  const char *out_base;  /* crt0_user.o */
  const char *src_rel;   /* src/asm/....s under compiler dir */
} LabiFsEnsureEntry;

static const LabiFsEnsureEntry g_labi_fs_ens[] = {
    {"crt0_user", "crt0_user.o", "src/asm/crt0_user_x86_64.s"},
    {"freestanding_io", "freestanding_io.o", "src/asm/freestanding_io_x86_64.s"},
};

int labi_fs_ensure_catalog_count(void) {
  return LABI_FS_ENS_COUNT;
}

int labi_fs_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                   const char **src_rel_out) {
  if (i < 0 || i >= LABI_FS_ENS_COUNT)
    return 0;
  if (stem_out)
    *stem_out = g_labi_fs_ens[i].stem;
  if (out_base_out)
    *out_base_out = g_labi_fs_ens[i].out_base;
  if (src_rel_out)
    *src_rel_out = g_labi_fs_ens[i].src_rel;
  return 1;
}

const char *labi_fs_ensure_out_base(int i) {
  if (i < 0 || i >= LABI_FS_ENS_COUNT)
    return NULL;
  return g_labi_fs_ens[i].out_base;
}

const char *labi_fs_ensure_src_rel(int i) {
  if (i < 0 || i >= LABI_FS_ENS_COUNT)
    return NULL;
  return g_labi_fs_ens[i].src_rel;
}

const char *labi_fs_ensure_stem(int i) {
  if (i < 0 || i >= LABI_FS_ENS_COUNT)
    return NULL;
  return g_labi_fs_ens[i].stem;
}

/* convenience accessors matching historic names */
const char *labi_fs_crt0_out_base(void) { return "crt0_user.o"; }
const char *labi_fs_crt0_src_rel(void) { return "src/asm/crt0_user_x86_64.s"; }
const char *labi_fs_io_out_base(void) { return "freestanding_io.o"; }
const char *labi_fs_io_src_rel(void) { return "src/asm/freestanding_io_x86_64.s"; }
