/* seeds/labi_invoke_ld_list.from_x.c — G-02f-275 P2 link_abi L6 invoke_ld list pure
 * Logic source: src/runtime/labi_invoke_ld_list.x
 * Hybrid: SHUX_LABI_INVOKE_LD_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * Pure data: brew -L paths, compress -l* flags, common tail lib flags.
 * spawn/ld/cc IO stays in mega shux_asm_invoke_ld_platform / tail_libs.
 */
#include <stddef.h>

/* ---- macOS Homebrew /usr/local -L paths (order matters) ---- */
static const char *const g_labi_ld_brew_paths[] = {
    "-L/opt/homebrew/lib",
    "-L/usr/local/lib",
};

int labi_ld_brew_lib_path_count(void) {
  return (int)(sizeof g_labi_ld_brew_paths / sizeof g_labi_ld_brew_paths[0]);
}

const char *labi_ld_brew_lib_path_at(int i) {
  int n = labi_ld_brew_lib_path_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_ld_brew_paths[i];
}

/* ---- compress link flags ---- */
const char *labi_ld_flag_lz(void) { return "-lz"; }
const char *labi_ld_flag_lzstd(void) { return "-lzstd"; }
const char *labi_ld_flag_lbrotlienc(void) { return "-lbrotlienc"; }
const char *labi_ld_flag_lbrotlidec(void) { return "-lbrotlidec"; }

/* Indexed compress flag table (audit / unit). */
static const char *const g_labi_ld_compress_flags[] = {
    "-lz",
    "-lzstd",
    "-lbrotlienc",
    "-lbrotlidec",
};

int labi_ld_compress_flag_count(void) {
  return (int)(sizeof g_labi_ld_compress_flags / sizeof g_labi_ld_compress_flags[0]);
}

const char *labi_ld_compress_flag_at(int i) {
  int n = labi_ld_compress_flag_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_ld_compress_flags[i];
}

/* ---- common tail / system link flags ---- */
const char *labi_ld_flag_lm(void) { return "-lm"; }
const char *labi_ld_flag_lsqlite3(void) { return "-lsqlite3"; }
const char *labi_ld_flag_pthread(void) { return "-pthread"; }
const char *labi_ld_flag_lpthread(void) { return "-lpthread"; }
const char *labi_ld_flag_ldl(void) { return "-ldl"; }
const char *labi_ld_flag_lc(void) { return "-lc"; }
const char *labi_ld_flag_lSystem(void) { return "-lSystem"; }
const char *labi_ld_flag_lws2_32(void) { return "-lws2_32"; }
const char *labi_ld_flag_lbcrypt(void) { return "-lbcrypt"; }

/* ---- driver / entry name literals used by platform ld ---- */
const char *labi_ld_driver_clang(void) { return "clang"; }
const char *labi_ld_driver_ld(void) { return "ld"; }
const char *labi_ld_driver_gcc(void) { return "gcc"; }
const char *labi_ld_driver_cc(void) { return "cc"; }
const char *labi_ld_mach_entry_main(void) { return "_main"; }
const char *labi_ld_flag_e(void) { return "-e"; }
const char *labi_ld_flag_o(void) { return "-o"; }

/* Indexed table of common tail flags for smoke/audit (not full policy). */
static const char *const g_labi_ld_common_tail[] = {
    "-lm",
    "-lsqlite3",
    "-pthread",
    "-lpthread",
    "-ldl",
    "-lc",
    "-lSystem",
};

int labi_ld_common_tail_flag_count(void) {
  return (int)(sizeof g_labi_ld_common_tail / sizeof g_labi_ld_common_tail[0]);
}

const char *labi_ld_common_tail_flag_at(int i) {
  int n = labi_ld_common_tail_flag_count();
  if (i < 0 || i >= n)
    return NULL;
  return g_labi_ld_common_tail[i];
}
