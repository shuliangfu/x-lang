/* seeds/rt_lib_root_surface.from_x.c
 * G-02f rt_lib_root R2 full surface — isomorphic with src/runtime/rt_lib_root.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_lib_root.x) + hybrid rest seed
 *   seeds/rt_lib_root.from_x.c (-DXLANG_RT_LIB_ROOT_FROM_X) ld -r into runtime_driver_no_c
 * R2: ptr_usable + default + roots_from_key from .x; rest FROM_X only decls+marker
 * Prove: full.x vs this seed → nm IDENTICAL (3 public symbols)
 * Regen: ./xlang -E ... src/runtime/rt_lib_root.x | filter DBG + polish prologue
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
extern int32_t driver_lib_root_ptr_usable(uint8_t * p);
extern void driver_lib_root_default(uint8_t * root_buf);
extern int32_t driver_lib_roots_from_key(uint8_t * lib_key, uint8_t * * out_arr, uint8_t * bufs);
extern int32_t driver_emit_lib_root_count(uint8_t * state);
extern int32_t driver_emit_lib_root_len(uint8_t * state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t * state, int32_t i, uint8_t * dst, int32_t cap);
/* wave227 G.7: env via public pure thin link_abi_getenv (wave222 → _impl). */
extern uint8_t * link_abi_getenv(uint8_t * name);
int32_t driver_lib_root_ptr_usable(uint8_t * p) {
  if ((p ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((p)[0] ==0)) {
    return 0;
  }
  return 1;
}
void driver_lib_root_default(uint8_t * root_buf) {
  (void)(((root_buf)[0] = 46));
  (void)(((root_buf)[1] = 0));
  uint8_t * def = ((uint8_t *)(0));
  {
    /* wave227 G.7: public pure thin link_abi_getenv (not raw libc getenv). */
    (void)((def = link_abi_getenv((uint8_t[]){83, 72, 85, 88, 95, 76, 73, 66, 0 })));
  }
  if ((driver_lib_root_ptr_usable(def) ==0)) {
    return;
  }
  int32_t i = 0;
  while ((i < 511)) {
    uint8_t c = (def)[i];
    (void)(((root_buf)[i] = c));
    if ((c ==0)) {
      return;
    }
    (void)((i = (i + 1)));
  }
  (void)(((root_buf)[511] = 0));
}
int32_t driver_lib_roots_from_key(uint8_t * lib_key, uint8_t * * out_arr, uint8_t * bufs) {
  int32_t n = 0;
  {
    (void)((n = driver_emit_lib_root_count(lib_key)));
  }
  if ((n <=0)) {
    (void)(driver_lib_root_default(bufs));
    (void)(((out_arr)[0] = bufs));
    return 1;
  }
  if ((n > 16)) {
    (void)((n = 16));
  }
  int32_t i = 0;
  while ((i < n)) {
    int32_t base = (i * 512);
    uint8_t * row = &((bufs)[base]);
    int32_t llen = 0;
    {
      (void)((llen = driver_emit_lib_root_len(lib_key, i)));
    }
    if (((llen <=0) || (llen >=512))) {
      (void)(((row)[0] = 46));
      (void)(((row)[1] = 0));
    } else {
      {
        (void)(driver_emit_lib_root_copy(lib_key, i, row, 512));
      }
      (void)(((row)[llen] = 0));
    }
    (void)(((out_arr)[i] = row));
    (void)((i = (i + 1)));
  }
  return n;
}
