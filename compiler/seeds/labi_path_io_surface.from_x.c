/* seeds/labi_path_io_surface.from_x.c
 * G-02f labi_path_io R2 full surface — isomorphic with src/runtime/labi_path_io.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_path_io.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (6 public gates + count; wave221 path_executable)
 * Cap residual: nonempty/realpath_if/path_readable/realpath_cap/path_executable → mega _impl
 *   (stat / realpath+skip / access R_OK / POSIX realpath|Windows null / access X_OK)
 * Regen: ./xlang -E ... src/runtime/labi_path_io.x | filter DBG + polish prologue
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
extern int32_t xlang_path_is_nonempty_regular_file(uint8_t * path);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved);
extern int32_t link_abi_path_readable(uint8_t * path);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
extern int32_t link_abi_path_executable(uint8_t * path);
extern int32_t labi_path_io_count(void);
extern int32_t xlang_path_is_nonempty_regular_file_impl(uint8_t * path);
extern uint8_t * xlang_runtime_o_realpath_if_exists_impl(uint8_t * path, uint8_t * resolved);
extern int32_t link_abi_path_readable_impl(uint8_t * path);
extern uint8_t * link_abi_realpath_cap_impl(uint8_t * path, uint8_t * out);
extern int32_t link_abi_path_executable_impl(uint8_t * path);
int32_t xlang_path_is_nonempty_regular_file(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  {
    return xlang_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}
uint8_t * asm_link_obj_skip_missing(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  if ((xlang_path_is_nonempty_regular_file(path) ==0)) {
    return ((uint8_t *)(0));
  }
  return path;
}
uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved) {
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  if ((resolved ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    return xlang_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return ((uint8_t *)(0));
}
/* wave209: link_abi_path_readable pure orch (surface pin ≡ .x). */
int32_t link_abi_path_readable(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  {
    return link_abi_path_readable_impl(path);
  }
  return 0;
}
/* wave218: link_abi_realpath_cap pure orch (surface pin ≡ .x). */
uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out) {
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  if ((out ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  {
    return link_abi_realpath_cap_impl(path, out);
  }
  return ((uint8_t *)(0));
}
/* wave221: link_abi_path_executable pure orch (surface pin ≡ .x). */
int32_t link_abi_path_executable(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  {
    return link_abi_path_executable_impl(path);
  }
  return 0;
}
int32_t labi_path_io_count(void) {
  return 6;
}
