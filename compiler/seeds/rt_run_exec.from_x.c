/* seeds/rt_run_exec.from_x.c — G-02f-297 P2 runtime R7-lite (run/exec pure gates)
 * Logic source: src/runtime/rt_run_exec.x
 * Hybrid: SHUX_RT_RUN_EXEC_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: pure argv/backend preference + usage print (no spawn/exec body).
 * driver_exec_compiled / main_entry / fmt IO remain mega rest (🔒).
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);

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

int labi_rt_run_exec_slice_marker(void) {
  return 1;
}
