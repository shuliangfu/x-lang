/* seeds/labi_path_io_surface.from_x.c
 * G-02f labi_path_io R2 full surface — isomorphic with src/runtime/labi_path_io.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_path_io.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (3 public gates + count)
 * Cap residual: nonempty/realpath → mega _impl (stat / realpath)
 * Regen: ./shux -E ... src/runtime/labi_path_io.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t shux_path_is_nonempty_regular_file(uint8_t * path);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * shux_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved);
extern int32_t labi_path_io_count(void);
extern int32_t shux_path_is_nonempty_regular_file_impl(uint8_t * path);
extern uint8_t * shux_runtime_o_realpath_if_exists_impl(uint8_t * path, uint8_t * resolved);
int32_t shux_path_is_nonempty_regular_file(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  {
    return shux_path_is_nonempty_regular_file_impl(path);
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
  if ((shux_path_is_nonempty_regular_file(path) ==0)) {
    return ((uint8_t *)(0));
  }
  return path;
}
uint8_t * shux_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved) {
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
    return shux_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return ((uint8_t *)(0));
}
int32_t labi_path_io_count(void) {
  return 3;
}
