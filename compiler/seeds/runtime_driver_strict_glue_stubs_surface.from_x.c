/* seeds/runtime_driver_strict_glue_stubs_surface.from_x.c
 * G-02f-89 runtime_driver_strict_glue_stubs R2 mixed surface - isomorphic with src/runtime_driver_strict_glue_stubs.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_driver_strict_glue_stubs.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (12 #[no_mangle])
 * Mode: mixed - 4 thin+rest forwards + 8 DIRECT via typeck_*_slot extern bridges
 * Cap residual: 10 extern bridges (driver_skip_codegen_dep_0_get + driver_set_current_dep_path_for_codegen
 *   + driver_diagnostic_pipe_marker + typeck_layout_metrics_sz_slot + typeck_layout_metrics_al_slot
 *   + typeck_layout_metrics_sz_slot_depth + typeck_layout_metrics_al_slot_depth
 *   + typeck_call_resolve_dep_idx_slot + typeck_call_resolve_func_idx_slot + append_text_to_codegen_buf_impl)
 * No doc_anchor (runtime_driver_strict_glue_stubs.x has none).
 * Note: asm_/typeck_/append_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 12 functions = 4 thin+rest + 8 DIRECT.
 * Regen: ./xlang-c -E ... runtime_driver_strict_glue_stubs.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern int32_t *typeck_layout_metrics_sz_slot(void);
extern int32_t *typeck_layout_metrics_al_slot(void);
extern int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth);
extern int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth);
extern int32_t *typeck_call_resolve_dep_idx_slot(void);
extern int32_t *typeck_call_resolve_func_idx_slot(void);
extern int32_t append_text_to_codegen_buf_impl(uint8_t *out, uint8_t *text);

/* === 3 thin+rest forwards to driver_* === */

int32_t asm_driver_skip_codegen_dep_0_get(void) {
  return driver_skip_codegen_dep_0_get();
}

void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
  driver_set_current_dep_path_for_codegen(path);
}

void typeck_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

/* === 8 DIRECT via typeck_*_slot extern bridges === */

void typeck_i32_ptr_store(int32_t *p, int32_t v) {
  if (p == 0) { return; }
  p[0] = v;
}

int32_t typeck_i32_ptr_read(int32_t *p) {
  if (p == 0) { return 0; }
  return p[0];
}

void typeck_layout_metrics_init_slot(void) {
  int32_t *sz = typeck_layout_metrics_sz_slot();
  int32_t *al = typeck_layout_metrics_al_slot();
  sz[0] = 0;
  al[0] = 1;
}

void typeck_layout_metrics_init_depth(int32_t depth) {
  int32_t *sz = typeck_layout_metrics_sz_slot_depth(depth);
  int32_t *al = typeck_layout_metrics_al_slot_depth(depth);
  sz[0] = 0;
  al[0] = 1;
}

int32_t typeck_layout_metrics_al_read_depth(int32_t depth) {
  int32_t *p = typeck_layout_metrics_al_slot_depth(depth);
  return p[0];
}

int32_t typeck_layout_metrics_sz_read_depth(int32_t depth) {
  int32_t *p = typeck_layout_metrics_sz_slot_depth(depth);
  return p[0];
}

int32_t typeck_call_resolve_dep_idx_peek(void) {
  int32_t *p = typeck_call_resolve_dep_idx_slot();
  return p[0];
}

int32_t typeck_call_resolve_func_idx_peek(void) {
  int32_t *p = typeck_call_resolve_func_idx_slot();
  return p[0];
}

/* === 1 thin+rest forward to append_text_to_codegen_buf_impl === */

int32_t append_text_to_codegen_buf(uint8_t *out, uint8_t *text) {
  return append_text_to_codegen_buf_impl(out, text);
}
