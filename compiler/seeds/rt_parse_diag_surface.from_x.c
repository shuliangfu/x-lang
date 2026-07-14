/* seeds/rt_parse_diag_surface.from_x.c
 * G-02f rt_parse_diag L2 thin surface — isomorphic with src/runtime/rt_parse_diag.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_parse_diag.x) + hybrid rest seed
 *   seeds/rt_parse_diag.from_x.c (-DSHUX_RT_PARSE_DIAG_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: precise parse body (macro→_impl) + marker
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl is U)
 * Regen: ./shux -E ... src/runtime/rt_parse_diag.x | filter DBG + polish externs
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
extern int32_t runtime_report_precise_parse_failure_if_known_impl(uint8_t * input_path, uint8_t * src, size_t src_len);
int32_t runtime_report_precise_parse_failure_if_known(uint8_t * input_path, uint8_t * src, size_t src_len) {
  {
    return runtime_report_precise_parse_failure_if_known_impl(input_path, src, src_len);
  }
  return 0;
}
