/* seeds/rt_emit_state_bss_cold.from_x.c — knife256 / 10.2 cold BSS for
 * rt_emit_state when pure-asm Lxml rename drifts (egg emits 9 commons with
 * hash mismatch vs tip FNV map). Provides the ten named module lets so
 * seed-phase1 links. Function faces stay in pure-asm rt_emit_state.x.
 * PLATFORM: SHARED. Do not use as product path when rename succeeds.
 */
#include <stdint.h>

uint8_t *driver_x_emit_c_path;
int64_t driver_x_emit_lib_roots[16];
int32_t driver_x_emit_n_lib_roots;
uint8_t driver_x_emit_path_buf[512];
uint8_t driver_x_emit_lib_bufs[4096];
int32_t driver_x_emit_c_want_extern;
uint8_t driver_x_emit_scan_ab[512];
uint8_t driver_x_emit_scan_nx[512];
uint8_t driver_x_emit_lib_name_buf[64];
int32_t driver_x_emit_lib_name_len;
