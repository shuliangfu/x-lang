/* seeds/rt_emit_state.from_x.c — Cap-global-bss + lib-name + entry prefix.
 * driver_run_x_emit_c_set_path, driver_run_x_emit_c_set_lib,
 * driver_run_x_emit_c_set_n_lib_roots, driver_run_x_emit_c_set_emit_extern,
 * and driver_argv_parse_x_emit_c are defined only in
 * src/runtime/rt_emit_state.x. Their C bodies were deleted in w845.
 * Do not reintroduce a #ifndef twin. This file remains because the shared
 * path, library, and scan buffers are not an .x export (export let becomes
 * static), and because xlang_driver_x_emit_set_lib_name,
 * xlang_driver_x_emit_lib_name_into, and
 * xlang_pipeline_pctx_set_entry_lib_prefix have no .x body.
 * Slot accessors live in runtime_driver_abi.
 * PLATFORM: SHARED — product links pure-asm .x + this object. No full-seed
 * fallback: a seed-only cc no longer defines the five setters.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
/* struct ast_PipelineDepCtx layout authority (ctx prefix setter below). */
#include "runtime_pipeline_abi.h"

#define X_EMIT_MAX_LIB_ROOTS 16

/* Same layout as the old static block in seeds/runtime.from_x.c.
 * Cap-global-bss residual: these arrays and the shared pointers must be
 * non-static so other TUs can take their address. An .x export let lowers
 * to static and cannot replace this block. driver_abi slot functions
 * extern these symbols.
 * PLATFORM: SHARED.
 */
const char *driver_x_emit_c_path;
const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS];
int driver_x_emit_n_lib_roots;
char driver_x_emit_path_buf[512];
char driver_x_emit_lib_bufs[X_EMIT_MAX_LIB_ROOTS][256];
int driver_x_emit_c_want_extern;
/* argv 扫描 scratch（Cap residual 槽经 driver_abi 暴露给 .x） */
char driver_x_emit_scan_ab[512];
char driver_x_emit_scan_nx[512];

/* 7.4.4 v3: dual-set the codegen ctx entry prefix (name + '_') on BOTH
 * current_codegen_prefix and entry_module_import_path mirrors — the .x twin
 * of the C-side writer in rt_run_compiler_parsed (trailing underscore
 * shape). Lives here (not pabi) because the rt-slice lane reliably
 * rebuilds this TU (pabi inject-only does not take new rest bodies, and
 * HOST_CC_SEED_FORCE hybrid is forbidden on Darwin per 392d44cb6).
 * Null ctx / empty / over-long name is a no-op. PLATFORM: SHARED. */
void xlang_pipeline_pctx_set_entry_lib_prefix(struct ast_PipelineDepCtx *ctx, const void *name, int32_t name_len) {
  int32_t k;
  if (!ctx || !name || name_len <= 0 || name_len >= 63)
    return;
  for (k = 0; k < name_len; k++) {
    ctx->current_codegen_prefix_mirror[k] = ((const uint8_t *)name)[k];
    ctx->entry_module_import_path_mirror[k] = ((const uint8_t *)name)[k];
  }
  ctx->current_codegen_prefix_mirror[name_len] = '_';
  ctx->current_codegen_prefix_mirror[name_len + 1] = 0;
  ctx->entry_module_import_path_mirror[name_len] = '_';
  ctx->entry_module_import_path_mirror[name_len + 1] = 0;
  ctx->current_codegen_prefix_len = name_len + 1;
  ctx->entry_module_import_path_len = name_len + 1;
}

/* 7.4.4 v3: opt-in -lib-name for the X-pipeline -E/-o emit lane. parse_x
 * (main.x) stores it via the setter; driver_run_x_emit_c (rt_run_x_emit.x,
 * the hot -x -E lane per main_entry dispatch) reads it and seeds the ctx
 * entry prefix via xlang_pipeline_pctx_set_entry_lib_prefix. Empty/absent =
 * bare emission (today's default; "-lib-name \"\"" stays a tolerated no-op
 * for the xlang_compile_std_module probe). Always-seed: no .x twin.
 * PLATFORM: SHARED. */
char driver_x_emit_lib_name_buf[64];
int driver_x_emit_lib_name_len;

void xlang_driver_x_emit_set_lib_name(const uint8_t *buf, int32_t len) {
  driver_x_emit_lib_name_len = 0;
  driver_x_emit_lib_name_buf[0] = '\0';
  if (!buf || len <= 0 || len >= (int)sizeof(driver_x_emit_lib_name_buf))
    return;
  memcpy(driver_x_emit_lib_name_buf, buf, (size_t)len);
  driver_x_emit_lib_name_buf[len] = '\0';
  driver_x_emit_lib_name_len = len;
}

int32_t xlang_driver_x_emit_lib_name_into(uint8_t *out, int32_t cap) {
  int32_t n = driver_x_emit_lib_name_len;
  if (!out || cap <= 0)
    return 0;
  if (n <= 0) {
    out[0] = '\0';
    return 0;
  }
  if (n > cap - 1)
    n = cap - 1;
  memcpy(out, driver_x_emit_lib_name_buf, (size_t)n);
  out[n] = '\0';
  return n;
}

int labi_rt_emit_state_slice_marker(void) {
  return 1;
}
