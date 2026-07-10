/* seeds/rt_run_exec.from_x.c — G-02f-297/298 P2 runtime R7-lite (run/exec pure gates)
 * Logic source: src/runtime/rt_run_exec.x
 * Hybrid: SHUX_RT_RUN_EXEC_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-297: want_asm_emit_to_file + print_usage
 * f-298: runtime_test_status_to_rc + print_target_cpu_features
 * driver_exec_compiled / main_entry / fmt IO remain mega rest (🔒).
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#include "runtime_diag_codes.h"

extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void shu_target_cpu_print(FILE *out, uint32_t features);

/**
 * 是否与 driver_run_compiler_full 默认一致：默认可走 asm 后端；
 * 仅当 argv 含 `-backend c` 时为 0。
 */
int driver_want_asm_emit_to_file(int argc, char **argv) {
  int want_asm = 1;
  char cur[512];
  char nx[512];
  int i;
  if (!argv || argc < 2)
    return 0;
  for (i = 1; i < argc; i++) {
    if (driver_get_argv_i(argc, argv, i, cur, (int)sizeof cur) < 0)
      continue;
    if (strcmp(cur, "-backend") != 0)
      continue;
    if (i + 1 >= argc)
      break;
    if (driver_get_argv_i(argc, argv, i + 1, nx, (int)sizeof nx) < 0) {
      i++;
      continue;
    }
    if (strcmp(nx, "c") == 0)
      want_asm = 0;
    if (strcmp(nx, "asm") == 0)
      want_asm = 1;
    i++;
  }
  return want_asm ? 1 : 0;
}

/**
 * 打印 shux 用法摘要（fd 1）。
 * B-strict / -nostartfiles 上用 write(1)，避免 stdout 未初始化。
 */
void driver_print_usage_c(void) {
  static const char usage[] =
      "Shux (shux) compiler\n"
      "\n"
      "Usage:\n"
      "  shux [options] file.x          compile and run\n"
      "  shux build [file.x] [-o exe]   compile (default a.out)\n"
      "  shux run file.x                compile and run\n"
      "  shux check [paths...]           parse + typeck only\n"
      "  shux fmt [--check] [paths...]   format .x sources\n"
      "  shux explain <CODE>             explain a diagnostic code\n"
      "  shux test [script.sh]           run test script\n"
      "\n"
      "Common options:\n"
      "  -backend asm|c    backend (default asm)\n"
      "  -O <0|1|2|3|s>    optimization (default 2)\n"
      "  -o <path>         output binary or .o\n"
      "  -L <dir>          library search path\n"
      "  -target <triple>  target (e.g. aarch64-linux-gnu)\n"
      "  -target-cpu <cpu> native|generic|avx2|...\n"
      "  --print-target-cpu  print host CPU features and exit\n"
      "  --explain <CODE>   print diagnostic code explanation and exit\n"
      "  -freestanding     nostdlib static link (Linux x86_64 ELF)\n"
      "  -legacy-f32-abi   legacy SysV f32 CALL (f64 widen; default xmm ABI)\n"
      "  -E                emit C (debug)\n"
      "  -flto              link-time optimization (C backend)\n"
      "  -h, --help         show this help\n"
      "\n"
      "Environment:\n"
      "  SHUX_ABI_F32_XMM=0  same as -legacy-f32-abi (x86_64 SysV)\n"
      "  SHUX_OPT          default -O level if omitted\n"
      "\n"
      "Release default: shux_asm -backend asm -O2 (f32 xmm ABI on unless legacy).\n"
      "See compiler/docs/F32_XMM_ABI.md for f32 ABI and deprecation timeline.\n";
  (void)write(STDOUT_FILENO, usage, sizeof(usage) - 1u);
}

/* --- G-02f-298 --- */

/** wait/system 状态 → 进程 rc；失败路径写诊断（diag 仍 extern）。 */
int runtime_test_status_to_rc(const char *script, int st) {
  if (st == -1) {
    runtime_diag_errno_path(script, "process error", "system(shux test)", script);
    return 1;
  }
  if (WIFEXITED(st))
    return WEXITSTATUS(st) != 0 ? 1 : 0;
  if (WIFSIGNALED(st)) {
    diag_reportf_with_code(script, 0, 0, "process error", SHUX_DIAG_CODE_PROCESS_PRC001, NULL,
                           "test script terminated by signal %d: '%s'", WTERMSIG(st), script ? script : "?");
    return 1;
  }
  diag_reportf_with_code(script, 0, 0, "process error", SHUX_DIAG_CODE_PROCESS_PRC001, NULL,
                         "test script terminated abnormally: '%s'", script ? script : "?");
  return 1;
}

/** X run_compiler_full_x：`--print-target-cpu` 早退打印 feature。 */
int32_t driver_print_target_cpu_features_c(int32_t features) {
  shu_target_cpu_print(stdout, (uint32_t)features);
  return 0;
}

int labi_rt_run_exec_slice_marker(void) {
  return 1;
}
