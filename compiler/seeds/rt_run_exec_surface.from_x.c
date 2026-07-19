/* seeds/rt_run_exec_surface.from_x.c — polished -E of src/runtime/rt_run_exec.x
 * R2 full：8 公共符号；Cap residual driver_print_usage_write / driver_exec_compiled_body in driver_abi
 * 勿手写第二套语义；由 shux -E 产物抛光。
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t rt_exec_suffix2_non_exe(uint8_t * exe, size_t n);
extern int32_t rt_exec_suffix4_non_exe(uint8_t * exe, size_t n);
extern int32_t rt_exec_check_non_exe(uint8_t * exe, size_t n);
extern uint8_t * rt_exec_a_out(void);
extern int32_t rt_exec_wifexited(int32_t st);
extern int32_t rt_exec_wexitstatus(int32_t st);
extern int32_t rt_exec_wifsignaled(int32_t st);
extern int32_t rt_exec_append(uint8_t * dst, int32_t cap, uint8_t * src);
extern int32_t rt_exec_append_byte(uint8_t * dst, int32_t cap, uint8_t b);
extern int32_t driver_want_asm_emit_to_file(int32_t argc, uint8_t * * argv);
extern void driver_print_usage_c(void);
extern int32_t runtime_test_status_to_rc(uint8_t * script, int32_t st);
extern int32_t driver_print_target_cpu_features_c(int32_t features);
extern uint8_t * driver_exec_scan_out_path(int32_t argc, uint8_t * * argv);
extern int32_t driver_exec_path_is_non_exe(uint8_t * exe);
extern int32_t driver_exec_compiled(int32_t argc, uint8_t * argv_opaque);
extern int32_t driver_run_test(int32_t argc, uint8_t * * argv);
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * * argv, int32_t i, uint8_t * buf, int32_t max);
extern void runtime_diag_errno_path(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * path);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void shu_target_cpu_print(uint8_t * out, uint32_t features);
extern uint8_t * shux_repo_root_from_argv0(uint8_t * argv0);
extern uint8_t * driver_stdio_stdout(void);
extern void driver_print_usage_write(void);
extern int32_t driver_exec_compiled_body(int32_t argc, uint8_t * argv_opaque);
int32_t rt_exec_suffix2_non_exe(uint8_t * exe, size_t n) {
  if ((n < ((size_t)(2)))) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(2)))] !=46)) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(1)))] ==111)) {
    return 1;
  }
  if (((exe)[(n - ((size_t)(1)))] ==79)) {
    return 1;
  }
  if (((exe)[(n - ((size_t)(1)))] ==115)) {
    return 1;
  }
  return 0;
}
int32_t rt_exec_suffix4_non_exe(uint8_t * exe, size_t n) {
  if ((n < ((size_t)(4)))) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(4)))] !=46)) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(3)))] !=111)) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(2)))] !=98)) {
    return 0;
  }
  if (((exe)[(n - ((size_t)(1)))] !=106)) {
    return 0;
  }
  return 1;
}
int32_t rt_exec_check_non_exe(uint8_t * exe, size_t n) {
  if ((rt_exec_suffix2_non_exe(exe, n) ==1)) {
    return 1;
  }
  if ((rt_exec_suffix4_non_exe(exe, n) ==1)) {
    return 1;
  }
  return 0;
}
uint8_t * rt_exec_a_out(void) {
  uint8_t * p = ((uint8_t *)(0));
  {
    (void)((p = malloc(((size_t)(8)))));
  }
  if ((p ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  (void)(((p)[0] = 97));
  (void)(((p)[1] = 46));
  (void)(((p)[2] = 111));
  (void)(((p)[3] = 117));
  (void)(((p)[4] = 116));
  (void)(((p)[5] = 0));
  return p;
}
int32_t rt_exec_wifexited(int32_t st) {
  if (((st & 127) ==0)) {
    return 1;
  }
  return 0;
}
int32_t rt_exec_wexitstatus(int32_t st) {
  return ((st >>8) & 255);
}
int32_t rt_exec_wifsignaled(int32_t st) {
  int32_t t = (st & 127);
  if ((t ==0)) {
    return 0;
  }
  if ((t ==127)) {
    return 0;
  }
  return 1;
}
int32_t rt_exec_append(uint8_t * dst, int32_t cap, uint8_t * src) {
  int32_t n = 0;
  int32_t i = 0;
  uint8_t c = 0;
  if ((dst ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((cap <=0)) {
    return 0;
  }
  if ((src ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((n < cap)) {
    if (((dst)[n] ==0)) {
      break;
    }
    (void)((n = (n + 1)));
  }
  while (((n + 1) < cap)) {
    (void)((c = (src)[i]));
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[n] = c));
    (void)((n = (n + 1)));
    (void)((i = (i + 1)));
  }
  if ((n < cap)) {
    (void)(((dst)[n] = 0));
  } else {
    (void)(((dst)[(cap - 1)] = 0));
  }
  return n;
}
int32_t rt_exec_append_byte(uint8_t * dst, int32_t cap, uint8_t b) {
  int32_t n = 0;
  if ((dst ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((cap <=1)) {
    return 0;
  }
  while ((n < cap)) {
    if (((dst)[n] ==0)) {
      break;
    }
    (void)((n = (n + 1)));
  }
  if (((n + 1) >=cap)) {
    (void)(((dst)[(cap - 1)] = 0));
    return n;
  }
  (void)(((dst)[n] = b));
  (void)((n = (n + 1)));
  (void)(((dst)[n] = 0));
  return n;
}
int32_t driver_want_asm_emit_to_file(int32_t argc, uint8_t * * argv) {
  int32_t want_asm = 1;
  int32_t i = 1;
  uint8_t * cur = ((uint8_t *)(0));
  uint8_t * nx = ((uint8_t *)(0));
  int32_t rc = 0;
  if ((((uint8_t *)(argv)) ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((argc < 2)) {
    return 0;
  }
  {
    (void)((cur = malloc(((size_t)(512)))));
    (void)((nx = malloc(((size_t)(512)))));
  }
  if ((cur ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((nx ==((uint8_t *)(0)))) {
    {
      (void)(free(cur));
    }
    return 0;
  }
  while ((i < argc)) {
    {
      (void)((rc = driver_get_argv_i(argc, argv, i, cur, 512)));
    }
    if ((rc < 0)) {
      (void)((i = (i + 1)));
    } else {
      {
        if ((strcmp(cur, ((uint8_t *)((uint8_t[]){45, 98, 97, 99, 107, 101, 110, 100, 0 }))) ==0)) {
          if (((i + 1) < argc)) {
            (void)((rc = driver_get_argv_i(argc, argv, (i + 1), nx, 512)));
            if ((rc >=0)) {
              if ((strcmp(nx, ((uint8_t *)((uint8_t[]){99, 0 }))) ==0)) {
                (void)((want_asm = 0));
              }
              if ((strcmp(nx, ((uint8_t *)((uint8_t[]){97, 115, 109, 0 }))) ==0)) {
                (void)((want_asm = 1));
              }
            }
            (void)((i = (i + 1)));
          }
        }
      }
      (void)((i = (i + 1)));
    }
  }
  {
    (void)(free(cur));
    (void)(free(nx));
  }
  if ((want_asm !=0)) {
    return 1;
  }
  return 0;
}
void driver_print_usage_c(void) {
  {
    (void)(driver_print_usage_write());
  }
  (void)(0);
  return;
}
int32_t runtime_test_status_to_rc(uint8_t * script, int32_t st) {
  if ((st ==(0 - 1))) {
    {
      (void)(runtime_diag_errno_path(script, ((uint8_t *)((uint8_t[]){112, 114, 111, 99, 101, 115, 115, 32, 101, 114, 114, 111, 114, 0 })), ((uint8_t *)((uint8_t[]){115, 121, 115, 116, 101, 109, 40, 115, 104, 117, 120, 32, 116, 101, 115, 116, 41, 0 })), script));
    }
    return 1;
  }
  if ((rt_exec_wifexited(st) !=0)) {
    if ((rt_exec_wexitstatus(st) !=0)) {
      return 1;
    }
    return 0;
  }
  if ((rt_exec_wifsignaled(st) !=0)) {
    {
      (void)(diag_report_with_code(script, 0, 0, ((uint8_t *)((uint8_t[]){112, 114, 111, 99, 101, 115, 115, 32, 101, 114, 114, 111, 114, 0 })), ((uint8_t *)((uint8_t[]){80, 82, 67, 48, 48, 49, 0 })), ((uint8_t *)((uint8_t[]){116, 101, 115, 116, 32, 115, 99, 114, 105, 112, 116, 32, 116, 101, 114, 109, 105, 110, 97, 116, 101, 100, 32, 98, 121, 32, 115, 105, 103, 110, 97, 108, 0 })), ((uint8_t *)(0))));
    }
    return 1;
  }
  {
    (void)(diag_report_with_code(script, 0, 0, ((uint8_t *)((uint8_t[]){112, 114, 111, 99, 101, 115, 115, 32, 101, 114, 114, 111, 114, 0 })), ((uint8_t *)((uint8_t[]){80, 82, 67, 48, 48, 49, 0 })), ((uint8_t *)((uint8_t[]){116, 101, 115, 116, 32, 115, 99, 114, 105, 112, 116, 32, 116, 101, 114, 109, 105, 110, 97, 116, 101, 100, 32, 97, 98, 110, 111, 114, 109, 97, 108, 108, 121, 0 })), ((uint8_t *)(0))));
  }
  return 1;
}
int32_t driver_print_target_cpu_features_c(int32_t features) {
  uint8_t * out = ((uint8_t *)(0));
  {
    (void)((out = driver_stdio_stdout()));
    (void)(shu_target_cpu_print(out, ((uint32_t)(features))));
  }
  return 0;
}
uint8_t * driver_exec_scan_out_path(int32_t argc, uint8_t * * argv) {
  int32_t i = 1;
  uint8_t * p = ((uint8_t *)(0));
  uint8_t * q = ((uint8_t *)(0));
  if ((((uint8_t *)(argv)) ==((uint8_t *)(0)))) {
    return rt_exec_a_out();
  }
  if ((argc < 1)) {
    return rt_exec_a_out();
  }
  while ((i < (argc - 1))) {
    (void)((p = (argv)[i]));
    if ((p !=((uint8_t *)(0)))) {
      {
        if ((strcmp(p, ((uint8_t *)((uint8_t[]){45, 111, 0 }))) ==0)) {
          (void)((q = (argv)[(i + 1)]));
          if ((q !=((uint8_t *)(0)))) {
            if (((q)[0] !=0)) {
              return q;
            }
          }
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return rt_exec_a_out();
}
int32_t driver_exec_path_is_non_exe(uint8_t * exe) {
  if ((exe ==((uint8_t *)(0)))) {
    return 1;
  }
  {
    size_t n = strlen(exe);
    return rt_exec_check_non_exe(exe, n);
  }
  return 0;
}
int32_t driver_exec_compiled(int32_t argc, uint8_t * argv_opaque) {
  if ((argv_opaque ==((uint8_t *)(0)))) {
    return 1;
  }
  if ((argc < 1)) {
    return 1;
  }
  {
    return driver_exec_compiled_body(argc, argv_opaque);
  }
  return 1;
}
int32_t driver_run_test(int32_t argc, uint8_t * * argv) {
  uint8_t * root = ((uint8_t *)(0));
  uint8_t * rel = ((uint8_t *)(0));
  uint8_t * script = ((uint8_t *)(0));
  uint8_t * cmd = ((uint8_t *)(0));
  uint8_t * a0 = ((uint8_t *)(0));
  int32_t st = 0;
  if ((((uint8_t *)(argv)) !=((uint8_t *)(0)))) {
    if ((argc > 0)) {
      (void)((a0 = (argv)[0]));
    }
  }
  {
    (void)((root = shux_repo_root_from_argv0(a0)));
  }
  (void)((rel = ((uint8_t *)((uint8_t[]){116, 101, 115, 116, 115, 47, 114, 117, 110, 45, 97, 108, 108, 46, 115, 104, 0 }))));
  if ((argc >=2)) {
    if ((((uint8_t *)(argv)) !=((uint8_t *)(0)))) {
      if (((argv)[1] !=((uint8_t *)(0)))) {
        if ((((argv)[1])[0] !=45)) {
          (void)((rel = (argv)[1]));
        }
      }
    }
  }
  {
    (void)((script = malloc(((size_t)(768)))));
    (void)((cmd = malloc(((size_t)(1024)))));
  }
  if ((script ==((uint8_t *)(0)))) {
    return 1;
  }
  if ((cmd ==((uint8_t *)(0)))) {
    {
      (void)(free(script));
    }
    return 1;
  }
  (void)(((script)[0] = 0));
  (void)(((cmd)[0] = 0));
  if (((rel)[0] ==47)) {
    (void)(rt_exec_append(script, 768, rel));
  } else {
    (void)(rt_exec_append(script, 768, root));
    (void)(rt_exec_append(script, 768, ((uint8_t *)((uint8_t[]){47, 0 }))));
    (void)(rt_exec_append(script, 768, rel));
  }
  (void)(rt_exec_append(cmd, 1024, ((uint8_t *)((uint8_t[]){99, 100, 32, 0 }))));
  (void)(rt_exec_append_byte(cmd, 1024, 34));
  (void)(rt_exec_append(cmd, 1024, root));
  (void)(rt_exec_append_byte(cmd, 1024, 34));
  (void)(rt_exec_append(cmd, 1024, ((uint8_t *)((uint8_t[]){32, 38, 38, 32, 98, 97, 115, 104, 32, 0 }))));
  (void)(rt_exec_append_byte(cmd, 1024, 34));
  (void)(rt_exec_append(cmd, 1024, script));
  (void)(rt_exec_append_byte(cmd, 1024, 34));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, ((uint8_t *)((uint8_t[]){105, 110, 102, 111, 0 })), ((uint8_t *)((uint8_t[]){73, 48, 48, 48, 0 })), ((uint8_t *)((uint8_t[]){116, 101, 115, 116, 32, 115, 99, 114, 105, 112, 116, 0 })), script));
    (void)((st = system(cmd)));
  }
  (void)((st = runtime_test_status_to_rc(script, st)));
  {
    (void)(free(script));
    (void)(free(cmd));
  }
  return st;
}
