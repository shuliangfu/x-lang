/* seeds/labi_path_pure.from_x.c — G-02f-267/429/L P2 link_abi L0 path pure → R2 full
 * Logic source: src/runtime/labi_path_pure.x
 * Hybrid: SHUX_LABI_PATH_PURE_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14 / wave114–116 / wave146–149）：公共业务符号由 full .x 提供：
 *   labi_suffix_eq2/eq4 + link_abi_ld_argv_entry_is_obj + shux_output_is_elf_o
 *   + shux_output_want_exe + shux_path_has_sep + shux_path_last_sep
 *   + shux_asm_ld_lib_root_ptr_usable (wave114 low-tag)
 *   + shux_asm_ld_lib_root_default (wave115 SHUX_LIB/"." ; Cap residual getenv)
 *   + shux_asm_ld_try_under_lib_roots (wave116 pure join; Cap residual skip+bank)
 *   + link_abi_asm_ld_argv_has_obj (wave146 pure scan; Cap residual realpath)
 *   + link_abi_asm_ld_argv_push_stable (wave147 pure bank+dedup+append; Cap residual bank_push)
 *   + link_abi_asm_ld_push_obj (wave148 pure resolve orch; Cap residual skip/rel/bank/diag)
 *   + link_abi_asm_ld_push_glue_after_std (wave149 pure have_std+ensure orch; Cap residual call_ensure)
 *   + link_abi_asm_ld_push_minimal_runtime_objs (wave150 pure triple push_obj; Cap residual *_o_path)
 *   + shux_asm_ld_append_user_extra_o_files (wave151 pure CLI extra .o append; Cap residual table+access)
 *   + shux_runtime_compiler_o_path_copy (wave160 pure join compiler-dir/leaf; Cap residual resolve)
 *   + shux_repo_root_from_argv0 (wave162 pure strip parent / process.o walk; Cap residual resolve+rel)
 *   + shux_runtime_panic_o_path (wave163 pure cwd/argv0 ladder; Cap residual realpath+getcwd+skip)
 *   + shux_crt0_user_o_path (wave164 pure cwd/argv0 ladder; Cap residual realpath_cap+getcwd)
 *   + shux_freestanding_io_o_path (wave165 pure cwd/argv0 ladder; Cap residual realpath_cap+getcwd)
 *   + shux_std_async_scheduler_o_path (wave166 pure cwd/argv0 ladder; Cap residual realpath_cap+getcwd;
 *     step3 realpath(argv0)+parent+/../std/async)
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
/* Cap residual used by wave146 argv_has_obj cold twin (mega always provides). */
const char *link_abi_realpath_cap(const char *path, char *out);
/* Cap residual used by wave148 push_obj cold twin. */
const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel);
void link_diag_ld_debug_push(const char *rel, const char *stage, const char *path);
/* Cap residual used by wave149 push_glue cold twin (mega always provides). */
int link_abi_call_ensure_argv0(void *ensure_fn, const char *link_argv0);
/* Cap residual used by wave150 push_minimal cold twin (mega always provides). */
/* wave163: panic_o_path is pure in this cold twin (forward decl for push_minimal). */
const char *shux_runtime_asm_io_stubs_o_path(const char *argv0);
const char *shux_runtime_process_argv_o_path(const char *argv0);
const char *shux_runtime_panic_o_path(const char *argv0);
/* Cap residual used by wave151 append_user_extra cold twin (mega always provides). */
int link_abi_user_extra_o_count(void);
const char *link_abi_user_extra_o_at(int i);
int link_abi_path_readable(const char *path);
/* Cap residual used by wave160 compiler_o_path_copy / wave162 repo_root cold twin (mega always provides). */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz);
/* Cap residual used by wave163 panic_o_path cold twin (path_io / libc). */
const char *shux_runtime_o_realpath_if_exists(const char *path, char *resolved);
char *getcwd(char *buf, size_t size);
/* Cap residual used by wave164/165/166 crt0_user / freestanding_io / async_scheduler_o_path
 * cold twin (POSIX realpath; already declared as link_abi_realpath_cap above for wave146). */
/* Pure peer defined earlier in this cold twin (wave116); declared for clarity. */
const char *shux_asm_ld_try_under_lib_roots(const char *rel, const char **lib_roots, int n_lib_roots, void *bank);
int32_t link_abi_asm_ld_argv_has_obj(const char **argv, int la, const char *path);
void link_abi_asm_ld_argv_push_stable(void *bank, const char **argv, int *la, int max_la, const char *p);
int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
    const char **lib_roots, int n_lib_roots, void *bank, const char **argv, int *la, int max_la,
    int *flag_out);

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
/* wave146: argv has_obj pure orch (cold twin ≡ .x; Cap residual realpath_cap). */
int32_t link_abi_asm_ld_argv_has_obj(const char **argv, int la, const char *path) {
  int k;
  char abs_new[4096];
  char abs_exist[4096];
  const char *use_new;
  const char *rn;
  if (!argv || la <= 0 || !path || !path[0])
    return 0;
  use_new = path;
  rn = link_abi_realpath_cap(path, abs_new);
  if (rn)
    use_new = rn;
  for (k = 0; k < la; k++) {
    const char *exist = argv[k];
    const char *re;
    if (!exist || !exist[0])
      continue;
    if (strcmp(exist, path) == 0 || strcmp(exist, use_new) == 0)
      return 1;
    re = link_abi_realpath_cap(exist, abs_exist);
    if (re && strcmp(re, use_new) == 0)
      return 1;
  }
  return 0;
}

/* wave147: argv push_stable pure orch (cold twin ≡ .x; Cap residual bank_push). */
void link_abi_asm_ld_argv_push_stable(void *bank, const char **argv, int *la, int max_la,
    const char *p) {
  const char *use_p;
  int cur;
  if (!p || !p[0] || !la)
    return;
  cur = *la;
  if (cur >= max_la - 1)
    return;
  use_p = p;
  if (bank) {
    const char *bp = shux_asm_ld_bank_push(bank, p);
    if (bp)
      use_p = bp;
  }
  if (link_abi_asm_ld_argv_has_obj(argv, cur, use_p))
    return;
  if (!argv)
    return;
  argv[cur] = use_p;
  *la = cur + 1;
}

/* wave148: push_obj pure orch (cold twin ≡ .x; Cap residual skip/rel/bank/diag). */
int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
    const char **lib_roots, int n_lib_roots, void *bank, const char **argv, int *la, int max_la,
    int *flag_out) {
  const char *p = NULL;
  int debug_runtime_obj = 0;
  int before;
  if (!la || *la >= max_la - 1)
    return 0;
  if (rel && (strcmp(rel, "compiler/runtime_asm_io_stubs.o") == 0
          || strcmp(rel, "compiler/runtime_process_argv.o") == 0))
    debug_runtime_obj = 1;
  if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
    link_diag_ld_debug_push(rel, "primary", primary ? primary : "(null)");
  if (primary && primary[0])
    p = asm_link_obj_skip_missing(primary);
  if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
    link_diag_ld_debug_push(rel, "after-primary", p ? p : "(null)");
  if (!p && rel && rel[0])
    p = asm_link_obj_skip_missing(shux_rel_o_path_from_argv0(link_argv0, rel));
  if (!p && bank && rel && rel[0])
    p = shux_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank);
  if (!p)
    return 0;
  if (bank) {
    const char *bp = shux_asm_ld_bank_push(bank, p);
    if (bp)
      p = bp;
    else
      return 0;
  }
  if (debug_runtime_obj && getenv("SHUX_DEBUG_LD"))
    link_diag_ld_debug_push(rel, "final", p ? p : "(null)");
  /* Single-authority append: wave147 push_stable bank=null after hard bank. */
  before = *la;
  link_abi_asm_ld_argv_push_stable(NULL, argv, la, max_la, p);
  if (*la <= before)
    return 0;
  if (flag_out)
    *flag_out = 1;
  return 1;
}

/* wave149: push_glue_after_std pure orch (cold twin ≡ .x; Cap residual call_ensure). */
void link_abi_asm_ld_push_glue_after_std(int have_std, int (*ensure_fn)(const char *argv0),
    const char *glue_primary, const char *link_argv0, const char *glue_rel,
    const char **lib_roots, int n_lib_roots, void *bank, const char **argv, int *la, int max_la) {
  if (!have_std)
    return;
  if (ensure_fn) {
    if (link_abi_call_ensure_argv0((void *)ensure_fn, link_argv0) != 0)
      return;
  }
  (void)link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots,
      bank, argv, la, max_la, NULL);
}

/* wave150: push_minimal_runtime_objs pure orch (cold twin ≡ .x; Cap residual *_o_path). */
void link_abi_asm_ld_push_minimal_runtime_objs(const char *link_argv0, const char **lib_roots,
    int n_lib_roots, void *bank, const char **argv, int *la, int max_la) {
  const char *io_p = shux_runtime_asm_io_stubs_o_path(link_argv0);
  const char *proc_p = shux_runtime_process_argv_o_path(link_argv0);
  const char *panic_p = shux_runtime_panic_o_path(link_argv0);
  (void)link_abi_asm_ld_push_obj(io_p, link_argv0, "compiler/runtime_asm_io_stubs.o",
      lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
  (void)link_abi_asm_ld_push_obj(proc_p, link_argv0, "compiler/runtime_process_argv.o",
      lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
  (void)link_abi_asm_ld_push_obj(panic_p, link_argv0, "compiler/runtime_panic.o",
      lib_roots, n_lib_roots, bank, argv, la, max_la, NULL);
}

/* wave151: append_user_extra_o_files pure orch (cold twin ≡ .x; Cap residual table+access). */
void shux_asm_ld_append_user_extra_o_files(const char **argv, int *la, int max_la) {
  int n;
  int ui;
  if (!argv || !la)
    return;
  n = link_abi_user_extra_o_count();
  for (ui = 0; ui < n; ui++) {
    const char *p;
    if (*la >= max_la - 1)
      break;
    p = link_abi_user_extra_o_at(ui);
    if (!p || !p[0])
      continue;
    if (!link_abi_path_readable(p))
      continue;
    argv[(*la)++] = p;
  }
}

/* wave160: compiler_o_path_copy pure orch (cold twin ≡ .x; Cap residual resolve). */
int shux_runtime_compiler_o_path_copy(const char *argv0, const char *leaf, char *out, size_t out_sz) {
  char comp_dir[4096];
  int dn;
  int ln;
  int i;
  int k;
  size_t need;
  if (!out || out_sz == 0 || !leaf || !leaf[0])
    return -1;
  out[0] = '\0';
  if (shu_resolve_compiler_dir(argv0, comp_dir, sizeof comp_dir) != 0)
    return -1;
  dn = 0;
  while (comp_dir[dn] != 0)
    dn = dn + 1;
  ln = 0;
  while (leaf[ln] != 0)
    ln = ln + 1;
  need = (size_t)dn + 1u + (size_t)ln;
  if (need >= out_sz) {
    out[0] = '\0';
    return -1;
  }
  for (i = 0; i < dn; i++)
    out[i] = comp_dir[i];
  out[dn] = '/';
  for (k = 0; k <= ln; k++)
    out[dn + 1 + k] = leaf[k];
  return 0;
}

/* wave162: repo_root pure orch (cold twin ≡ .x; Cap residual resolve + rel_o_path). */
static char g_labi_repo_root_buf[512];

const char *shux_repo_root_from_argv0(const char *argv0) {
  char comp[4096];
  int n;
  int i;
  int pn;
  int j;
  int k;
  char *last;
  const char *proc_o;
  g_labi_repo_root_buf[0] = '\0';
  if (shu_resolve_compiler_dir(argv0, comp, sizeof comp) == 0 && comp[0]) {
    n = 0;
    while (comp[n] != 0)
      n = n + 1;
    if (n < 512) {
      for (i = 0; i <= n; i++)
        g_labi_repo_root_buf[i] = comp[i];
      last = (char *)shux_path_last_sep((uint8_t *)g_labi_repo_root_buf);
      if (last && last != g_labi_repo_root_buf) {
        *last = '\0';
        return g_labi_repo_root_buf;
      }
      g_labi_repo_root_buf[0] = '\0';
    }
  }
  proc_o = shux_rel_o_path_from_argv0(argv0, "std/process/process.o");
  if (!proc_o || !proc_o[0])
    return g_labi_repo_root_buf;
  pn = 0;
  while (proc_o[pn] != 0)
    pn = pn + 1;
  if (pn >= 512)
    return g_labi_repo_root_buf;
  for (j = 0; j <= pn; j++)
    g_labi_repo_root_buf[j] = proc_o[j];
  for (k = 0; k < 3; k++) {
    last = (char *)shux_path_last_sep((uint8_t *)g_labi_repo_root_buf);
    if (!last || last == g_labi_repo_root_buf)
      break;
    *last = '\0';
  }
  return g_labi_repo_root_buf;
}

/* wave163: panic_o_path pure orch (cold twin ≡ .x; Cap residual realpath+getcwd+skip). */
static char g_labi_panic_o_path_buf[512];
static char g_labi_panic_o_path_resolved[4096];

const char *shux_runtime_panic_o_path(const char *argv0) {
  const char *hit;
  char cwd[512];
  int i;
  int last_sep_i;
  int n;
  int j;
  int k;
  const char *sm;
  g_labi_panic_o_path_buf[0] = '\0';
  g_labi_panic_o_path_resolved[0] = '\0';
  hit = shux_runtime_o_realpath_if_exists("runtime_panic.o", g_labi_panic_o_path_resolved);
  if (hit)
    return hit;
  hit = shux_runtime_o_realpath_if_exists("compiler/runtime_panic.o", g_labi_panic_o_path_resolved);
  if (hit)
    return hit;
  if (getcwd(cwd, 488) != NULL) {
    int L = 0;
    while (cwd[L] != 0)
      L = L + 1;
    if (L + 24 < 512) {
      const char *suf = "/compiler/runtime_panic.o";
      int si = 0;
      while (si <= 24) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      hit = shux_runtime_o_realpath_if_exists(cwd, g_labi_panic_o_path_resolved);
      if (hit)
        return hit;
    }
  }
  if (argv0 && argv0[0]) {
    i = 0;
    last_sep_i = -1;
    while (argv0[i] != 0) {
      if ((uint8_t)argv0[i] == 47)
        last_sep_i = i;
      i = i + 1;
    }
    n = 0;
    if (last_sep_i >= 0) {
      if (last_sep_i >= 512 - 20)
        return g_labi_panic_o_path_buf;
      for (j = 0; j < last_sep_i; j++)
        g_labi_panic_o_path_buf[j] = argv0[j];
      g_labi_panic_o_path_buf[last_sep_i] = '\0';
      n = last_sep_i;
    } else {
      g_labi_panic_o_path_buf[0] = '.';
      g_labi_panic_o_path_buf[1] = '\0';
      n = 1;
    }
    if (n + 18 < 512) {
      const char *leaf = "/runtime_panic.o";
      k = 0;
      while (leaf[k] != 0) {
        g_labi_panic_o_path_buf[n + k] = leaf[k];
        k = k + 1;
      }
      g_labi_panic_o_path_buf[n + k] = '\0';
      hit = shux_runtime_o_realpath_if_exists(g_labi_panic_o_path_buf, g_labi_panic_o_path_resolved);
      if (hit)
        return hit;
      sm = asm_link_obj_skip_missing(g_labi_panic_o_path_buf);
      if (sm)
        return g_labi_panic_o_path_buf;
    }
  }
  return g_labi_panic_o_path_buf;
}

/* wave164: crt0_user_o_path pure orch (cold twin ≡ .x; Cap residual realpath_cap+getcwd). */
static char g_labi_crt0_user_o_path_buf[512];
static char g_labi_crt0_user_o_path_resolved[4096];

const char *shux_crt0_user_o_path(const char *argv0) {
  const char *hit;
  char cwd[512];
  int i;
  int last_sep_i;
  int n;
  int j;
  int k;
  g_labi_crt0_user_o_path_buf[0] = '\0';
  g_labi_crt0_user_o_path_resolved[0] = '\0';
  hit = link_abi_realpath_cap("compiler/crt0_user.o", g_labi_crt0_user_o_path_resolved);
  if (hit)
    return hit;
  if (getcwd(cwd, 490) != NULL) {
    int L = 0;
    while (cwd[L] != 0)
      L = L + 1;
    if (L + 21 < 512) {
      const char *suf = "/compiler/crt0_user.o";
      int si = 0;
      while (si <= 21) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      hit = link_abi_realpath_cap(cwd, g_labi_crt0_user_o_path_resolved);
      if (hit)
        return hit;
    }
  }
  if (argv0 && argv0[0]) {
    i = 0;
    last_sep_i = -1;
    while (argv0[i] != 0) {
      if ((uint8_t)argv0[i] == 47)
        last_sep_i = i;
      i = i + 1;
    }
    n = 0;
    if (last_sep_i >= 0) {
      if (last_sep_i >= 512 - 16)
        return g_labi_crt0_user_o_path_buf;
      for (j = 0; j < last_sep_i; j++)
        g_labi_crt0_user_o_path_buf[j] = argv0[j];
      g_labi_crt0_user_o_path_buf[last_sep_i] = '\0';
      n = last_sep_i;
    } else {
      g_labi_crt0_user_o_path_buf[0] = '.';
      g_labi_crt0_user_o_path_buf[1] = '\0';
      n = 1;
    }
    if (n + 14 < 512) {
      const char *leaf = "/crt0_user.o";
      k = 0;
      while (leaf[k] != 0) {
        g_labi_crt0_user_o_path_buf[n + k] = leaf[k];
        k = k + 1;
      }
      g_labi_crt0_user_o_path_buf[n + k] = '\0';
      hit = link_abi_realpath_cap(g_labi_crt0_user_o_path_buf, g_labi_crt0_user_o_path_resolved);
      if (hit)
        return hit;
      return g_labi_crt0_user_o_path_buf;
    }
  }
  return g_labi_crt0_user_o_path_buf;
}

/* wave165: freestanding_io_o_path pure orch (cold twin ≡ .x; Cap residual realpath_cap+getcwd). */
static char g_labi_freestanding_io_o_path_buf[512];
static char g_labi_freestanding_io_o_path_resolved[4096];

const char *shux_freestanding_io_o_path(const char *argv0) {
  const char *hit;
  char cwd[512];
  int i;
  int last_sep_i;
  int n;
  int j;
  int k;
  g_labi_freestanding_io_o_path_buf[0] = '\0';
  g_labi_freestanding_io_o_path_resolved[0] = '\0';
  hit = link_abi_realpath_cap("compiler/freestanding_io.o", g_labi_freestanding_io_o_path_resolved);
  if (hit)
    return hit;
  if (getcwd(cwd, 484) != NULL) {
    int L = 0;
    while (cwd[L] != 0)
      L = L + 1;
    if (L + 27 < 512) {
      const char *suf = "/compiler/freestanding_io.o";
      int si = 0;
      while (si <= 27) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      hit = link_abi_realpath_cap(cwd, g_labi_freestanding_io_o_path_resolved);
      if (hit)
        return hit;
    }
  }
  if (argv0 && argv0[0]) {
    i = 0;
    last_sep_i = -1;
    while (argv0[i] != 0) {
      if ((uint8_t)argv0[i] == 47)
        last_sep_i = i;
      i = i + 1;
    }
    n = 0;
    if (last_sep_i >= 0) {
      if (last_sep_i >= 512 - 20)
        return g_labi_freestanding_io_o_path_buf;
      for (j = 0; j < last_sep_i; j++)
        g_labi_freestanding_io_o_path_buf[j] = argv0[j];
      g_labi_freestanding_io_o_path_buf[last_sep_i] = '\0';
      n = last_sep_i;
    } else {
      g_labi_freestanding_io_o_path_buf[0] = '.';
      g_labi_freestanding_io_o_path_buf[1] = '\0';
      n = 1;
    }
    if (n + 18 < 512) {
      const char *leaf = "/freestanding_io.o";
      k = 0;
      while (leaf[k] != 0) {
        g_labi_freestanding_io_o_path_buf[n + k] = leaf[k];
        k = k + 1;
      }
      g_labi_freestanding_io_o_path_buf[n + k] = '\0';
      hit = link_abi_realpath_cap(g_labi_freestanding_io_o_path_buf, g_labi_freestanding_io_o_path_resolved);
      if (hit)
        return hit;
      return g_labi_freestanding_io_o_path_buf;
    }
  }
  return g_labi_freestanding_io_o_path_buf;
}

/* wave166: async_scheduler_o_path pure orch (cold twin ≡ .x; Cap residual realpath_cap+getcwd).
 * Step3: realpath(argv0) then parent + /../std/async/scheduler.o (≠ freestanding leaf join). */
static char g_labi_async_scheduler_o_path_buf[4096];
static char g_labi_async_scheduler_o_path_resolved[4096];

const char *shux_std_async_scheduler_o_path(const char *argv0) {
  const char *hit;
  const char *rp;
  char cwd[512];
  int i;
  int last_sep_i;
  int n;
  int k;
  g_labi_async_scheduler_o_path_buf[0] = '\0';
  g_labi_async_scheduler_o_path_resolved[0] = '\0';
  hit = link_abi_realpath_cap("std/async/scheduler.o", g_labi_async_scheduler_o_path_resolved);
  if (hit)
    return hit;
  if (getcwd(cwd, 486) != NULL) {
    int L = 0;
    while (cwd[L] != 0)
      L = L + 1;
    if (L + 26 <= 512) {
      const char *suf = "/std/async/scheduler.o";
      int si = 0;
      while (si <= 22) {
        cwd[L + si] = suf[si];
        si = si + 1;
      }
      hit = link_abi_realpath_cap(cwd, g_labi_async_scheduler_o_path_resolved);
      if (hit)
        return hit;
    }
  }
  if (argv0 && argv0[0]) {
    rp = link_abi_realpath_cap(argv0, g_labi_async_scheduler_o_path_buf);
    if (rp) {
      i = 0;
      last_sep_i = -1;
      while (g_labi_async_scheduler_o_path_buf[i] != 0) {
        if ((uint8_t)g_labi_async_scheduler_o_path_buf[i] == 47)
          last_sep_i = i;
        i = i + 1;
      }
      if (last_sep_i >= 0) {
        if (last_sep_i + 26 < 4096) {
          g_labi_async_scheduler_o_path_buf[last_sep_i] = '\0';
          n = last_sep_i;
          {
            const char *leaf = "/../std/async/scheduler.o";
            k = 0;
            while (leaf[k] != 0) {
              g_labi_async_scheduler_o_path_buf[n + k] = leaf[k];
              k = k + 1;
            }
            g_labi_async_scheduler_o_path_buf[n + k] = '\0';
          }
          hit = link_abi_realpath_cap(g_labi_async_scheduler_o_path_buf, g_labi_async_scheduler_o_path_resolved);
          if (hit)
            return hit;
        }
      }
    }
  }
  return g_labi_async_scheduler_o_path_buf;
}

int32_t labi_path_pure_count(void) {
  return 22;
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
int32_t link_abi_asm_ld_argv_has_obj(const char **argv, int la, const char *path);
void link_abi_asm_ld_argv_push_stable(void *bank, const char **argv, int *la, int max_la, const char *p);
int link_abi_asm_ld_push_obj(const char *primary, const char *link_argv0, const char *rel,
    const char **lib_roots, int n_lib_roots, void *bank, const char **argv, int *la, int max_la,
    int *flag_out);
void link_abi_asm_ld_push_glue_after_std(int have_std, int (*ensure_fn)(const char *argv0),
    const char *glue_primary, const char *link_argv0, const char *glue_rel,
    const char **lib_roots, int n_lib_roots, void *bank, const char **argv, int *la, int max_la);
void link_abi_asm_ld_push_minimal_runtime_objs(const char *link_argv0, const char **lib_roots,
    int n_lib_roots, void *bank, const char **argv, int *la, int max_la);
void shux_asm_ld_append_user_extra_o_files(const char **argv, int *la, int max_la);
int shux_runtime_compiler_o_path_copy(const char *argv0, const char *leaf, char *out, size_t out_sz);
const char *shux_repo_root_from_argv0(const char *argv0);
const char *shux_runtime_panic_o_path(const char *argv0);
const char *shux_crt0_user_o_path(const char *argv0);
const char *shux_freestanding_io_o_path(const char *argv0);
const char *shux_std_async_scheduler_o_path(const char *argv0);
int32_t labi_path_pure_count(void);
#endif

int labi_path_pure_slice_marker(void) {
  return 1;
}
