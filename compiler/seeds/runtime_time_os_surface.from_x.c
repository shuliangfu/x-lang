/* seeds/runtime_time_os_surface.from_x.c
 * G-02f-19 runtime_time_os R2 full surface — isomorphic with src/asm/runtime_time_os.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_TIME_OS_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (5 public API from .x)
 * Cap residual: 5 OS bridge _impl (clock_gettime/nanosleep/gmtime_r/QPC/Sleep etc.) kept in
 *   seeds/runtime_time_os.from_x.c rest; surface only mirrors .x public API face.
 * Regen: ./xlang-c -E ... runtime_time_os.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

/* === Public API (from .x; mirrored here for prove nm IDENTICAL) === */
extern int64_t time_now_monotonic_ns_c(void);
extern int64_t time_now_wall_ns_c(void);
extern void time_sleep_ns_c(int64_t ns);
extern int32_t time_format_wall_rfc3339_c(uint8_t * buf, int32_t cap);
extern int32_t time_wall_local_offset_min_c(void);

/* === OS bridge _impl (Cap residual; defined in runtime_time_os.from_x.c rest) === */
extern int64_t time_monotonic_ns_impl(void);
extern int64_t time_wall_ns_impl(void);
extern void time_sleep_ns_impl(int64_t ns);
extern int32_t time_format_rfc3339_impl(uint8_t * buf, int32_t cap);
extern int32_t time_local_offset_min_impl(void);

int64_t time_now_monotonic_ns_c(void) {
  return time_monotonic_ns_impl();
}
int64_t time_now_wall_ns_c(void) {
  return time_wall_ns_impl();
}
void time_sleep_ns_c(int64_t ns) {
  if ((ns <=0)) {
    return;
  }
  (void)(time_sleep_ns_impl(ns));
}
int32_t time_format_wall_rfc3339_c(uint8_t * buf, int32_t cap) {
  if (((buf ==0) || (cap <=0))) {
    return -1;
  }
  return time_format_rfc3339_impl(buf, cap);
}
int32_t time_wall_local_offset_min_c(void) {
  return time_local_offset_min_impl();
}
