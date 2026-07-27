/* seeds/runtime_dynlib_os_surface.from_x.c
 * G-02f-124 runtime_dynlib_os R2 full surface — isomorphic with src/asm/runtime_dynlib_os.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_DYNLIB_OS_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (7 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 6 OS bridge _impl (LoadLibraryW/dlopen/dlsym/dlclose/dlerror/FormatMessage etc.)
 *   kept in seeds/runtime_dynlib_os.from_x.c rest; surface only mirrors .x public API face.
 * Regen: ./xlang-c -E ... runtime_dynlib_os.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>

/* === OS bridge _impl (Cap residual; defined in runtime_dynlib_os.from_x.c rest) === */
extern uint8_t * dynlib_win_load_library_w_utf8_impl(uint8_t * path);
extern int32_t dynlib_os_copy_last_error_impl(uint8_t * buf, int32_t cap);
extern uint8_t * dynlib_os_open_impl(uint8_t * path);
extern uint8_t * dynlib_os_sym_impl(uint8_t * lib, uint8_t * name);
extern void dynlib_os_close_impl(uint8_t * lib);
extern int32_t dynlib_os_win_path_smoke_impl(void);

/* === Public API (from .x; mirrored here for prove nm IDENTICAL) === */
/* 1 doc_anchor (export function, no ast_ prefix in xlang-c codegen) */
int32_t runtime_dynlib_os_x_doc_anchor(void) { return 0; }

/* 7 #[no_mangle] public API wrappers */
int32_t dynlib_win_normalize_path(uint8_t * out, int32_t out_cap, uint8_t * path) {
  int32_t i;
  if (out == 0) return 0;
  if (out_cap < 2) return 0;
  if (path == 0) return 0;
  i = 0;
  while (path[i] != 0) {
    uint8_t c;
    if (i + 1 >= out_cap) break;
    c = path[i];
    if (c == 47) c = 92;
    out[i] = c;
    i = i + 1;
  }
  out[i] = 0;
  return i;
}
uint8_t * dynlib_win_load_library_w_utf8(uint8_t * path) {
  return dynlib_win_load_library_w_utf8_impl(path);
}
int32_t dynlib_os_copy_last_error_c(uint8_t * out, int32_t cap) {
  return dynlib_os_copy_last_error_impl(out, cap);
}
uint8_t * dynlib_os_open_c(uint8_t * path) {
  return dynlib_os_open_impl(path);
}
uint8_t * dynlib_os_sym_c(uint8_t * lib, uint8_t * name) {
  return dynlib_os_sym_impl(lib, name);
}
void dynlib_os_close_c(uint8_t * lib) {
  dynlib_os_close_impl(lib);
}
int32_t dynlib_os_win_path_smoke_c(void) {
  return dynlib_os_win_path_smoke_impl();
}
