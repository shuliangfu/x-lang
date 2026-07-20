/* seeds/rt_asm_stub_surface.from_x.c
 * G-02f rt_asm_stub R2 full surface — isomorphic with src/runtime/rt_asm_stub.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_asm_stub.x) + rest seed marker under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (2 public: want_exe + asm_codegen_ast)
 * Cap residual: driver_asm_stub_gas_line_* + out_append_cstr in driver_abi
 * Regen: ./shux -E ... src/runtime/rt_asm_stub.x | filter DBG + polish prologue
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
extern int32_t driver_asm_output_want_exe(uint8_t * path);
extern int32_t asm_codegen_ast(uint8_t * module, uint8_t * arena, uint8_t * out);
extern int32_t shux_output_want_exe(uint8_t * path);
extern uint8_t * driver_asm_stub_gas_line_at(int32_t i);
extern int32_t driver_asm_stub_gas_line_count(void);
extern int32_t driver_asm_stub_out_append_cstr(uint8_t * out, uint8_t * s);
int32_t driver_asm_output_want_exe(uint8_t * path) {
  {
    return shux_output_want_exe(path);
  }
  return 0;
}
int32_t asm_codegen_ast(uint8_t * module, uint8_t * arena, uint8_t * out) {
  int32_t n = 0;
  int32_t i = 0;
  if ((out ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((module ==((uint8_t *)(0)))) {
  }
  if ((arena ==((uint8_t *)(0)))) {
  }
  {
    (void)((n = driver_asm_stub_gas_line_count()));
  }
  while ((i < n)) {
    uint8_t * line = ((uint8_t *)(0));
    int32_t rc = 0;
    {
      (void)((line = driver_asm_stub_gas_line_at(i)));
      (void)((rc = driver_asm_stub_out_append_cstr(out, line)));
    }
    if ((rc !=0)) {
      return (0 - 1);
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
