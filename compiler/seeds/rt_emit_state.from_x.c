/* seeds/rt_emit_state.from_x.c — G-02f-303 P2 runtime rest (-E emit state)
 * Logic source: src/runtime/rt_emit_state.x
 * Hybrid: SHUX_RT_EMIT_STATE_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Shared emit state (non-static) for main.x setters + rest driver_run_x_emit_c.
 * Full emit pipeline remains mega rest.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define X_EMIT_MAX_LIB_ROOTS 16

/* 与 seeds/runtime.from_x.c 原 static 同布局；hybrid 时 rest 以 extern 引用。 */
const char *driver_x_emit_c_path;
const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS];
int driver_x_emit_n_lib_roots;
char driver_x_emit_path_buf[512];
char driver_x_emit_lib_bufs[X_EMIT_MAX_LIB_ROOTS][256];
int driver_x_emit_c_want_extern;

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

int labi_rt_emit_state_slice_marker(void) {
  return 1;
}
