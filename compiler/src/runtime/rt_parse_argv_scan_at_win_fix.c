/* Win tip-cold fix: pure-asm rt_compile miscompiled `if (i >= argc)` as
 * `if (i >= 0)` (eax=0 from ni=0 reused), so argv scan returns immediately
 * and L2 FAIL_BUILD (silent RC=1, path_len=0). Strong T before
 * runtime_driver_no_c.o (GNU ld first-win). PLATFORM: WINDOWS. */
#include <stdint.h>

typedef struct RtCompileState RtCompileState;

extern int32_t driver_compile_parse_argv_step_c(int32_t argc, uint8_t **argv, RtCompileState *state,
                                                 int32_t i, uint8_t *arg_buf, int32_t cap);

void rt_parse_argv_scan_at(int32_t argc, uint8_t **argv, RtCompileState *state, int32_t i, uint8_t *arg_buf) {
  int32_t ni;
  if (i >= argc) {
    return;
  }
  if (state == 0) {
    return;
  }
  if (arg_buf == 0) {
    return;
  }
  ni = driver_compile_parse_argv_step_c(argc, argv, state, i, arg_buf, 512);
  rt_parse_argv_scan_at(argc, argv, state, ni, arg_buf);
}
