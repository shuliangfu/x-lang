/* Source-faithful driver_* flag-slot accessors twin
 * (runtime_driver_abi_thin.x / pabi_check_diag_emitted_flag_one.x).
 *
 * s212 DIG: same tipU class as s211 skip_codegen — huge-frame get compares
 * the slot POINTER (never *p) so get always returns 1; set stores v into
 * the stack local that holds the pointer. Covers the remaining family that
 * dig PE still first-wins from broken thin (skip_typeck / freestanding /
 * skip_codegen_dep_0 / sanitize_address / fmt_check_only /
 * large_stack_thread). check_only (s133/s134) and skip_codegen (s211)
 * already have dedicated twins.
 *
 * docs-only .x, do not idx8.
 * PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>

extern int32_t *driver_x_pipeline_skip_typeck_flag_slot(void);
extern int32_t *driver_freestanding_flag_slot(void);
extern int32_t *driver_skip_codegen_dep_0_flag_slot(void);
extern int32_t *driver_sanitize_address_flag_slot(void);
extern int32_t *driver_fmt_check_only_flag_slot(void);
extern int32_t *driver_large_stack_thread_flag_slot(void);
extern uint8_t *link_abi_getenv(const char *name);

static int32_t flag_nonzero(int32_t *p) {
  if (p == 0) return 0;
  if (p[0] != 0) return 1;
  return 0;
}

static void flag_store(int32_t *p, int32_t v) {
  if (p == 0) return;
  p[0] = v;
}

int32_t driver_x_pipeline_skip_typeck_get(void) {
  return flag_nonzero(driver_x_pipeline_skip_typeck_flag_slot());
}

void driver_x_pipeline_skip_typeck_set(int32_t v) {
  flag_store(driver_x_pipeline_skip_typeck_flag_slot(), v);
}

int32_t driver_freestanding_get(void) {
  return flag_nonzero(driver_freestanding_flag_slot());
}

void driver_freestanding_set(int32_t v) {
  flag_store(driver_freestanding_flag_slot(), v);
}

int32_t driver_skip_codegen_dep_0_get(void) {
  return flag_nonzero(driver_skip_codegen_dep_0_flag_slot());
}

void driver_skip_codegen_dep_0_set(int32_t v) {
  flag_store(driver_skip_codegen_dep_0_flag_slot(), v);
}

void driver_sanitize_address_set(int32_t v) {
  flag_store(driver_sanitize_address_flag_slot(), v);
}

/* Mirrors pabi_check_diag_emitted_flag_one.x: BSS flag, else getenv. */
int32_t driver_sanitize_address_get(void) {
  uint8_t *e;
  if (flag_nonzero(driver_sanitize_address_flag_slot()) != 0) return 1;
  e = link_abi_getenv("XLANG_SANITIZE_ADDRESS");
  if (e == 0) return 0;
  if (e[0] == 0) return 0;
  if (e[0] == 48) return 0; /* '0' */
  return 1;
}

int32_t driver_fmt_check_only_get(void) {
  return flag_nonzero(driver_fmt_check_only_flag_slot());
}

void driver_fmt_check_only_set(int32_t v) {
  flag_store(driver_fmt_check_only_flag_slot(), v);
}

int32_t driver_is_large_stack_thread(void) {
  return flag_nonzero(driver_large_stack_thread_flag_slot());
}

void driver_large_stack_thread_mark(int32_t on) {
  flag_store(driver_large_stack_thread_flag_slot(), on);
}
