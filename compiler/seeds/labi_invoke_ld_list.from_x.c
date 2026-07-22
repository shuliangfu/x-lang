/* seeds/labi_invoke_ld_list.from_x.c — G-02f-275 P2 link_abi L6 invoke_ld list pure → R2 full
 * Logic source: src/runtime/labi_invoke_ld_list.x
 * Hybrid: SHUX_LABI_INVOKE_LD_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full：公共业务符号由 full .x 提供：
 *   labi_ld_brew_lib_path_{count,at}
 *   labi_ld_compress_flag_{count,at} + labi_ld_flag_lz/zstd/brotli*
 *   labi_ld_flag_lm/sqlite3/pthread/ldl/lc/lSystem/lws2_32/lbcrypt
 *   labi_ld_driver_{clang,ld,gcc,cc} + labi_ld_mach_entry_main + labi_ld_flag_{e,o}
 *   labi_ld_common_tail_flag_{count,at}
 *   ld_append_brew_lib_paths (wave152 pure orch; Cap residual link_abi_host_is_apple)
 * Cap residual：link_abi_host_is_apple (#if __APPLE__) in mega; spawn/ld/cc IO mega.
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_invoke_ld_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

/* Cap residual always provided by mega (compile-time #if); cold twin calls it. */
int link_abi_host_is_apple(void);

#ifndef SHUX_LABI_INVOKE_LD_LIST_FROM_X

int labi_ld_brew_lib_path_count(void) {
  return 2;
}

const char *labi_ld_brew_lib_path_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-L/opt/homebrew/lib";
  if (i == 1)
    return "-L/usr/local/lib";
  return NULL;
}

const char *labi_ld_flag_lz(void) { return "-lz"; }
const char *labi_ld_flag_lzstd(void) { return "-lzstd"; }
const char *labi_ld_flag_lbrotlienc(void) { return "-lbrotlienc"; }
const char *labi_ld_flag_lbrotlidec(void) { return "-lbrotlidec"; }

int labi_ld_compress_flag_count(void) {
  return 4;
}

const char *labi_ld_compress_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-lz";
  if (i == 1)
    return "-lzstd";
  if (i == 2)
    return "-lbrotlienc";
  if (i == 3)
    return "-lbrotlidec";
  return NULL;
}

const char *labi_ld_flag_lm(void) { return "-lm"; }
const char *labi_ld_flag_lsqlite3(void) { return "-lsqlite3"; }
const char *labi_ld_flag_pthread(void) { return "-pthread"; }
const char *labi_ld_flag_lpthread(void) { return "-lpthread"; }
const char *labi_ld_flag_ldl(void) { return "-ldl"; }
const char *labi_ld_flag_lc(void) { return "-lc"; }
const char *labi_ld_flag_lSystem(void) { return "-lSystem"; }
const char *labi_ld_flag_lws2_32(void) { return "-lws2_32"; }
const char *labi_ld_flag_lbcrypt(void) { return "-lbcrypt"; }

const char *labi_ld_driver_clang(void) { return "clang"; }
const char *labi_ld_driver_ld(void) { return "ld"; }
const char *labi_ld_driver_gcc(void) { return "gcc"; }
const char *labi_ld_driver_cc(void) { return "cc"; }
const char *labi_ld_mach_entry_main(void) { return "_main"; }
const char *labi_ld_flag_e(void) { return "-e"; }
const char *labi_ld_flag_o(void) { return "-o"; }

int labi_ld_common_tail_flag_count(void) {
  return 7;
}

const char *labi_ld_common_tail_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-lm";
  if (i == 1)
    return "-lsqlite3";
  if (i == 2)
    return "-pthread";
  if (i == 3)
    return "-lpthread";
  if (i == 4)
    return "-ldl";
  if (i == 5)
    return "-lc";
  if (i == 6)
    return "-lSystem";
  return NULL;
}

/* wave152: ld_append_brew_lib_paths pure orch (cold twin ≡ .x; Cap residual host_is_apple). */
void ld_append_brew_lib_paths(const char **argv, int *la, int max_la) {
  int n;
  int k;
  if (!link_abi_host_is_apple())
    return;
  if (!argv || !la)
    return;
  n = labi_ld_brew_lib_path_count();
  for (k = 0; k < n; k++) {
    const char *p;
    if (*la >= max_la - 1)
      break;
    p = labi_ld_brew_lib_path_at(k);
    if (!p || !p[0])
      continue;
    argv[(*la)++] = p;
  }
}

#else
int labi_ld_brew_lib_path_count(void);
const char *labi_ld_brew_lib_path_at(int i);
const char *labi_ld_flag_lz(void);
const char *labi_ld_flag_lzstd(void);
const char *labi_ld_flag_lbrotlienc(void);
const char *labi_ld_flag_lbrotlidec(void);
int labi_ld_compress_flag_count(void);
const char *labi_ld_compress_flag_at(int i);
const char *labi_ld_flag_lm(void);
const char *labi_ld_flag_lsqlite3(void);
const char *labi_ld_flag_pthread(void);
const char *labi_ld_flag_lpthread(void);
const char *labi_ld_flag_ldl(void);
const char *labi_ld_flag_lc(void);
const char *labi_ld_flag_lSystem(void);
const char *labi_ld_flag_lws2_32(void);
const char *labi_ld_flag_lbcrypt(void);
const char *labi_ld_driver_clang(void);
const char *labi_ld_driver_ld(void);
const char *labi_ld_driver_gcc(void);
const char *labi_ld_driver_cc(void);
const char *labi_ld_mach_entry_main(void);
const char *labi_ld_flag_e(void);
const char *labi_ld_flag_o(void);
int labi_ld_common_tail_flag_count(void);
const char *labi_ld_common_tail_flag_at(int i);
void ld_append_brew_lib_paths(const char **argv, int *la, int max_la);
#endif

int labi_invoke_ld_list_slice_marker(void) {
  return 1;
}