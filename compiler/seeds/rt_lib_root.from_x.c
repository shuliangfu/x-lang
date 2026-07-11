/* seeds/rt_lib_root.from_x.c — G-02f-305 P2 runtime rest (lib root helpers)
 * Logic source: src/runtime/rt_lib_root.x
 * Hybrid: SHUX_RT_LIB_ROOT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: ptr_usable / default(SHUX_LIB) / roots_from_key（emit sidecar 桥）。
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif

extern int32_t driver_emit_lib_root_count(uint8_t *state);
extern int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap);

/* G-02f-432：.x 真迁到 rt_lib_root.x（NULL + 空串检查，flat early-return） */
#ifndef SHUX_RT_LIB_ROOT_FROM_X
/**
 * 判断 lib root 指针可安全解引用（避开 NULL/low tag/getenv 脏值）。
 */
int driver_lib_root_ptr_usable(const char *p) {
  return p && (uintptr_t)p >= 4096u && p[0] != '\0';
}
#else
int driver_lib_root_ptr_usable(const char *p);
#endif

/**
 * 写入默认 lib root：优先 SHUX_LIB（拷贝到 root_buf），否则 "."。
 */
void driver_lib_root_default(char root_buf[512]) {
  const char *def = getenv("SHUX_LIB");
  root_buf[0] = '.';
  root_buf[1] = '\0';
  if (!driver_lib_root_ptr_usable(def))
    return;
  strncpy(root_buf, def, 511);
  root_buf[511] = '\0';
}

/** 从 ast_pool sidecar 键填充 lib_roots 数组；返回根数量。 */
int driver_lib_roots_from_key(uint8_t *lib_key, const char **out_arr, char bufs[X_FULL_MAX_LIB_ROOTS][512]) {
  int n = (int)driver_emit_lib_root_count(lib_key);
  int i;
  if (n <= 0) {
    driver_lib_root_default(bufs[0]);
    out_arr[0] = bufs[0];
    return 1;
  }
  if (n > X_FULL_MAX_LIB_ROOTS)
    n = X_FULL_MAX_LIB_ROOTS;
  for (i = 0; i < n; i++) {
    int32_t llen = driver_emit_lib_root_len(lib_key, i);
    if (llen <= 0 || llen >= 512) {
      bufs[i][0] = '.';
      bufs[i][1] = '\0';
    } else {
      driver_emit_lib_root_copy(lib_key, i, (uint8_t *)bufs[i], 512);
      bufs[i][llen] = '\0';
    }
    out_arr[i] = bufs[i];
  }
  return n;
}

int labi_rt_lib_root_slice_marker(void) {
  return 1;
}
