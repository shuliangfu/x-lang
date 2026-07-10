/* seeds/rt_dispatch_thin.from_x.c — G-02f-312 P2 runtime rest (dispatch thin gates)
 * Logic source: src/runtime/rt_dispatch_thin.x
 * Hybrid: SHUX_RT_DISPATCH_THIN_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope:
 *  - driver_run_asm_backend_c / driver_run_emit_c_path_c 兼容旧名薄门闩
 *  - driver_run_compiler_full 入口选择
 *  - driver_try_compile_via_shu_c_sibling（fork/exec 同目录 shux-c）🔒
 * impl_c / parsed 巨石仍 mega rest。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#include <process.h>
#endif

extern int driver_argv0_basename_is(const char *argv0, const char *base);
extern int32_t driver_run_asm_backend_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                             int32_t argc, uint8_t *argv);
extern int32_t driver_run_emit_c_path_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                             uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv);
extern int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t *argv);

/** 兼容旧符号名；新路径 compile.x 经 compile_dispatch_* 调 impl_c。 */
int32_t driver_run_asm_backend_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target, int32_t argc,
                                 uint8_t *argv) {
  return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
}

/** 兼容旧符号名；新路径 compile.x 经 compile_dispatch_* 调 impl_c。 */
int32_t driver_run_emit_c_path_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key, uint8_t *target,
                                 uint8_t *opt_level, int32_t use_lto, int32_t argc, uint8_t *argv) {
  return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
}

/**
 * 完整编译入口：B-strict / product 走 impl_c。
 */
int driver_run_compiler_full(int argc, char **argv) {
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
  return (int)driver_run_compiler_full_x_impl_c((int32_t)argc, (uint8_t *)argv);
#else
  extern int32_t driver_run_compiler_full_x(int32_t argc, uint8_t *argv);
  return (int)driver_run_compiler_full_x((int32_t)argc, (uint8_t *)argv);
#endif
}

/**
 * 含 import 时 seed X codegen 易重复符号；若同目录有 shux-c 则委托其完成 -o 链接。
 * 返回 ≥0 为子进程 exit；-1 表示未委托（继续本进程路径）。
 * 🔒 fork/exec/_spawnvp。
 */
int driver_try_compile_via_shu_c_sibling(int argc, char **argv) {
  char shu_c[512];
  const char *self;
  const char *slash;
  if (argc < 2 || !argv || !argv[0])
    return -1;
  /* 已在 shux-c 内：勿 fork 自身。 */
  if (driver_argv0_basename_is(argv[0], "shux-c"))
    return -1;
  self = argv[0];
  slash = strrchr(self, '/');
#if defined(_WIN32)
  {
    const char *bs = strrchr(self, '\\');
    if (bs && (!slash || bs > slash))
      slash = bs;
  }
#endif
  if (slash) {
    size_t dir_len = (size_t)(slash - self);
    if (dir_len >= sizeof(shu_c) - 8)
      return -1;
    memcpy(shu_c, self, dir_len);
    shu_c[dir_len] = '\0';
    strcat(shu_c, "/shux-c");
  } else {
    strcpy(shu_c, "shux-c");
  }
  if (access(shu_c, X_OK) != 0)
    return -1;
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
  {
    argv[0] = shu_c;
    intptr_t rc = _spawnvp(_P_WAIT, shu_c, (const char *const *)argv);
    if (rc == -1)
      return -1;
    return (int)rc;
  }
#else
  {
    pid_t pid = fork();
    if (pid < 0)
      return -1;
    if (pid == 0) {
      argv[0] = shu_c;
      execvp(shu_c, argv);
      _exit(127);
    }
    {
      int st = 0;
      if (waitpid(pid, &st, 0) < 0)
        return -1;
      if (WIFEXITED(st))
        return WEXITSTATUS(st);
      return 1;
    }
  }
#endif
}

int labi_rt_dispatch_thin_slice_marker(void) {
  return 1;
}
