/*
 * Host-gcc first-wins twin of xlang_invoke_ld_for_exe_impl.
 *
 * DIG s257 Soft Cap (PLATFORM: WINDOWS host-cc; SHARED remap contract):
 * After s256 Soft Cap mkstemp fills g_driver_asm_tmp_path_kept, tip still
 * passes the mutable tmp slot (cleared by work_reset) as o_path into
 * xlang_asm_invoke_ld_platform. tipU platform only rejects NULL, not "".
 * Result: append_std sees empty user_o → freestanding/std flood (unicode
 * multi-def / BCrypt / U WinMain) while the real 147B user .o is ignored.
 *
 * Seed win_ld coff branch already remaps empty → kept; tip pure/tipU path
 * does not. Soft Cap remap at invoke_ld_for_exe_impl entry (G.7: complete
 * existing kept contract; do not add a second probe).
 */
#include <stdint.h>
#include <string.h>

#ifndef PATH_MAX
#define PATH_MAX 260
#endif

extern char *driver_asm_tmp_path_kept(void);
extern const char *xlang_asm_ld_effective_link_argv0(const char *link_argv0, char *syn, int syn_cap);
extern int driver_freestanding_get(void);
extern int xlang_asm_ld_prepare_for_exe_link(const char *link_eff, const char *o_path, int freestanding, int use_macho_o, int use_coff_o);
extern int xlang_asm_invoke_ld_platform(const char *o_path, const char *exe_path, const char *target, int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots, int driver_freestanding);

/**
 * Prefer durable mkstemp kept path when the mutable o_path/slot is empty,
 * then prepare + invoke platform ld (seed invoke_ld_for_exe_impl shape).
 *
 * @param o_path temp user .o (may be empty after work_reset)
 * @param exe_path output exe path
 * @param target triple / target string (may be null)
 * @param use_macho_o Mach-O object path gate
 * @param use_coff_o COFF object path gate
 * @param link_argv0 compiler argv0 for path resolve
 * @param lib_roots -L roots
 * @param n_lib_roots count of lib_roots
 * @return 0 on success; -1 on prepare/link failure
 */
int xlang_invoke_ld_for_exe_impl(const char *o_path, const char *exe_path, const char *target,
    int use_macho_o, int use_coff_o, const char *link_argv0, const char **lib_roots, int n_lib_roots) {
  char link_argv_syn[PATH_MAX];
  const char *link_eff;
  int freestanding;

  /* DIG s257: empty slot → kept (seed win_ld coff parity). */
  if (!o_path || !o_path[0]) {
    char *kept = driver_asm_tmp_path_kept();
    if (kept && kept[0]) {
      o_path = kept;
    }
  }

  link_eff = xlang_asm_ld_effective_link_argv0(link_argv0, link_argv_syn, (int)sizeof link_argv_syn);
  if (!link_eff) {
    return -1;
  }
  freestanding = driver_freestanding_get();
  if (xlang_asm_ld_prepare_for_exe_link(link_eff, o_path, freestanding, use_macho_o, use_coff_o) != 0) {
    return -1;
  }
  return xlang_asm_invoke_ld_platform(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots,
      freestanding);
}
