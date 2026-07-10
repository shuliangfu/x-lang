/* seeds/rt_run_exec.from_x.c — G-02f-297～299/311 P2 runtime R7 (run/exec gates)
 * Logic source: src/runtime/rt_run_exec.x
 * Hybrid: SHUX_RT_RUN_EXEC_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-297: want_asm_emit_to_file + print_usage
 * f-298: runtime_test_status_to_rc + print_target_cpu_features
 * f-299: exec pure path helpers + driver_exec_compiled (spawn 🔒 在本 seed)
 * f-311: driver_run_test（bash tests/run-all.sh；🔒 system）
 * main_entry / full emit orchestration remain mega rest.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#include <process.h>
#endif

#include "runtime_diag_codes.h"

#include <stdlib.h>

extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code,
                                   const char *detail, const char *fmt, ...);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void shu_target_cpu_print(FILE *out, uint32_t features);
extern int shu_waitpid_retry(pid_t pid, int *status_out);
extern const char *shux_repo_root_from_argv0(const char *argv0);
extern int system(const char *command);

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

/* --- G-02f-299: exec path pure + driver_exec_compiled --- */

/** 从 argv 扫描 `-o` 下一参数；缺省 `"a.out"`（可能指向 argv 槽或静态字面量）。 */
const char *driver_exec_scan_out_path(int argc, char **argv) {
  int i;
  if (!argv || argc < 1)
    return "a.out";
  for (i = 1; i < argc - 1; i++) {
    if (argv[i] && strcmp(argv[i], "-o") == 0 && argv[i + 1] && argv[i + 1][0])
      return argv[i + 1];
  }
  return "a.out";
}

/**
 * 路径是否为不应 exec 的对象/汇编产物（.o/.O/.obj/.s）。
 * 与 shux_output_want_exe 后缀规则对齐。
 */
int driver_exec_path_is_non_exe(const char *exe) {
  size_t n;
  if (!exe)
    return 1;
  n = strlen(exe);
  if (n >= 2 && exe[n - 2] == '.' && (exe[n - 1] == 'o' || exe[n - 1] == 'O'))
    return 1;
  if (n >= 4 && exe[n - 4] == '.' && exe[n - 3] == 'o' && exe[n - 2] == 'b' && exe[n - 1] == 'j')
    return 1;
  if (n >= 2 && exe[n - 2] == '.' && exe[n - 1] == 's')
    return 1;
  return 0;
}

/**
 * cmd_run：编译成功后 exec 产物。spawn/fork 为 🔒 OS 路径，留在本 seed。
 */
int driver_exec_compiled(int argc, uint8_t *argv_opaque) {
  char **argv = (char **)argv_opaque;
  const char *exe;

  if (!argv || argc < 1)
    return 1;
  exe = driver_exec_scan_out_path(argc, argv);
  if (driver_exec_path_is_non_exe(exe))
    return 0;
  {
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    char *av[2];
    intptr_t rc;
    av[0] = (char *)exe;
    av[1] = NULL;
    rc = _spawnvp(_P_WAIT, exe, (const char *const *)av);
    if (rc == -1) {
      runtime_diag_errno_path(NULL, "process error", "spawnvp (driver_exec_compiled)", exe);
      return 1;
    }
    return (int)rc;
#else
    pid_t pid = fork();
    if (pid < 0) {
      runtime_diag_errno_path(NULL, "process error", "fork (driver_exec_compiled)", exe);
      return 1;
    }
    if (pid == 0) {
      char *av[2];
      av[0] = (char *)exe;
      av[1] = NULL;
      execv(exe, av);
      runtime_diag_errno_path(NULL, "process error", "execv (driver_exec_compiled)", exe);
      _exit(127);
    }
    {
      int st = 0;
      if (shu_waitpid_retry(pid, &st) != 0)
        return 1;
      if (WIFEXITED(st))
        return WEXITSTATUS(st);
      return 1;
    }
#endif
  }
}

/** shux test：在仓库根执行 bash 测试脚本。🔒 system。 */
int driver_run_test(int argc, char **argv) {
  const char *root = shux_repo_root_from_argv0(argc > 0 ? argv[0] : NULL);
  const char *rel = "tests/run-all.sh";
  char script[768];
  char cmd[1024];
  if (argc >= 2 && argv[1] && argv[1][0] != '-') {
    rel = argv[1];
  }
  if (rel[0] == '/')
    snprintf(script, sizeof script, "%s", rel);
  else
    snprintf(script, sizeof script, "%s/%s", root, rel);
  snprintf(cmd, sizeof cmd, "cd \"%s\" && bash \"%s\"", root, script);
  diag_reportf(NULL, 0, 0, "info", NULL, "test script: %s", script);
  return runtime_test_status_to_rc(script, system(cmd));
}

int labi_rt_run_exec_slice_marker(void) {
  return 1;
}
