/* seeds/rt_emit_state.from_x.c — G-02f-303/304 P2 runtime rest (-E emit state)
 * Logic source: src/runtime/rt_emit_state.x
 * Hybrid: SHUX_RT_EMIT_STATE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-303: shared emit state + setters
 * f-304: driver_argv_parse_x_emit_c（扫 -L / -x -E 灌入状态槽）
 * Full emit pipeline remains mega rest.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define X_EMIT_MAX_LIB_ROOTS 16

extern int driver_get_argv_i(int argc, char **argv, int i, char *buf, int max);

/* 与 seeds/runtime.from_x.c 原 static 同布局；hybrid 时 rest 以 extern 引用。 */
const char *driver_x_emit_c_path;
const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS];
int driver_x_emit_n_lib_roots;
char driver_x_emit_path_buf[512];
char driver_x_emit_lib_bufs[X_EMIT_MAX_LIB_ROOTS][256];
int driver_x_emit_c_want_extern;

/* G-02f-455：thin+rest PREFER_X_O
 *   thin .x provides 1 #[no_mangle] wrapper (calls *_impl in rest).
 *   rest seed C (compiled with -DSHUX_RT_EMIT_STATE_FROM_X):
 *     - driver_run_x_emit_c_set_path renamed to *_impl via macro.
 *   Other functions stay in rest:
 *     - driver_argv_parse_x_emit_c uses char **argv (signature mismatch with .x *u8).
 *     - set_lib / set_n_lib_roots / set_emit_extern / labi_marker have no .x counterpart. */
#ifdef SHUX_RT_EMIT_STATE_FROM_X
#define driver_run_x_emit_c_set_path    driver_run_x_emit_c_set_path_impl
#endif

int driver_run_x_emit_c_set_path(const uint8_t *path, int path_len) {
  driver_x_emit_c_path = NULL;
  if (!path || path_len <= 0 || path_len >= (int)sizeof(driver_x_emit_path_buf))
    return 0;
  memcpy(driver_x_emit_path_buf, path, (size_t)path_len);
  driver_x_emit_path_buf[path_len] = '\0';
  driver_x_emit_c_path = driver_x_emit_path_buf;
  return 0;
}

int driver_run_x_emit_c_set_lib(int i, const uint8_t *buf, int len) {
  if (i < 0 || i >= X_EMIT_MAX_LIB_ROOTS || !buf || len < 0 || len >= 256)
    return 0;
  memcpy(driver_x_emit_lib_bufs[i], buf, (size_t)len);
  driver_x_emit_lib_bufs[i][len] = '\0';
  driver_x_emit_lib_roots[i] = driver_x_emit_lib_bufs[i];
  return 0;
}

int driver_run_x_emit_c_set_n_lib_roots(int n) {
  driver_x_emit_n_lib_roots = (n >= 0 && n <= X_EMIT_MAX_LIB_ROOTS) ? n : 0;
  return 0;
}

int driver_run_x_emit_c_set_emit_extern(int v) {
  driver_x_emit_c_want_extern = v ? 1 : 0;
  return 0;
}

/**
 * 扫描 argv：若存在 -x -E <path> 则记下 path 及此前出现的 -L path，返回 1，否则返回 0。
 */
int driver_argv_parse_x_emit_c(int argc, char **argv) {
  char ab[512];
  char nx[512];
  driver_x_emit_c_path = NULL;
  driver_x_emit_n_lib_roots = 0;
  if (argc < 4 || !argv)
    return 0;
  for (int i = 1; i < argc; i++) {
    if (driver_get_argv_i(argc, argv, i, ab, (int)sizeof ab) < 0)
      continue;
    if (strcmp(ab, "-L") == 0 && i + 1 < argc) {
      int k = driver_x_emit_n_lib_roots;
      if (k < X_EMIT_MAX_LIB_ROOTS) {
        int ln = driver_get_argv_i(argc, argv, i + 1, driver_x_emit_lib_bufs[k], 256);
        if (ln < 0)
          return 0;
        driver_x_emit_lib_roots[k] = driver_x_emit_lib_bufs[k];
        driver_x_emit_n_lib_roots++;
      }
      i++;
      continue;
    }
    if (strcmp(ab, "-x") == 0 && i + 2 < argc) {
      if (driver_get_argv_i(argc, argv, i + 1, nx, (int)sizeof nx) < 0 || strcmp(nx, "-E") != 0)
        continue;
      if (driver_get_argv_i(argc, argv, i + 2, driver_x_emit_path_buf, (int)sizeof driver_x_emit_path_buf) < 0)
        return 0;
      driver_x_emit_c_path = driver_x_emit_path_buf;
      return 1;
    }
  }
  return 0;
}

int labi_rt_emit_state_slice_marker(void) {
  return 1;
}
