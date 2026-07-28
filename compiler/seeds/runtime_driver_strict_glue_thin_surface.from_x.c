/* seeds/runtime_driver_strict_glue_thin_surface.from_x.c
 * G-02f runtime_driver_strict_glue_thin R2 mixed surface - isomorphic with src/runtime_driver_strict_glue_thin.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/runtime_driver_strict_glue_thin.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (11 symbols)
 * Mode: mixed - 8 DIRECT compute + 3 thin+rest forwards to driver_*
 * Cap residual: 9 extern bridges (3 driver_* + 6 typeck_*_slot / slot_depth)
 * doc_anchor: none (no doc_anchor defined in .x).
 * Logic: 11 functions = 8 DIRECT compute (typeck_i32_ptr_store,
 *   typeck_i32_ptr_read, typeck_layout_metrics_init_slot,
 *   typeck_layout_metrics_init_depth, typeck_layout_metrics_al_read_depth,
 *   typeck_layout_metrics_sz_read_depth, typeck_call_resolve_dep_idx_peek,
 *   typeck_call_resolve_func_idx_peek)
 *   + 3 thin+rest forwards (asm_driver_skip_codegen_dep_0_get,
 *      asm_driver_set_current_dep_path_for_codegen,
 *      typeck_driver_diagnostic_pipe_marker).
 * Regen: xlang_asm -E src/runtime_driver_strict_glue_thin.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
/* Cap residual: 9 extern bridges (thin+rest forwards target these; defined in rest C). */
extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern int32_t * typeck_layout_metrics_sz_slot(void);
extern int32_t * typeck_layout_metrics_al_slot(void);
extern int32_t * typeck_layout_metrics_sz_slot_depth(int32_t depth);
extern int32_t * typeck_layout_metrics_al_slot_depth(int32_t depth);
extern int32_t * typeck_call_resolve_dep_idx_slot(void);
extern int32_t * typeck_call_resolve_func_idx_slot(void);
int32_t asm_driver_skip_codegen_dep_0_get(void) {
  {
    int32_t r = driver_skip_codegen_dep_0_get();
    return r;
  }
  return 0;
}
void asm_driver_set_current_dep_path_for_codegen(uint8_t * path) {
  (void)(driver_set_current_dep_path_for_codegen(path));
}
void typeck_driver_diagnostic_pipe_marker(int32_t id) {
  (void)(driver_diagnostic_pipe_marker(id));
}
void typeck_i32_ptr_store(int32_t * p, int32_t v) {
  if ((p ==0)) {
    return;
  }
  (void)(((p)[0] = v));
}
int32_t typeck_i32_ptr_read(int32_t * p) {
  if ((p ==0)) {
    return 0;
  }
  {
    int32_t r = (p)[0];
    return r;
  }
  return 0;
}
void typeck_layout_metrics_init_slot(void) {
  {
    int32_t * sz = typeck_layout_metrics_sz_slot();
    int32_t * al = typeck_layout_metrics_al_slot();
    (void)(((sz)[0] = 0));
    (void)(((al)[0] = 1));
  }
}
void typeck_layout_metrics_init_depth(int32_t depth) {
  {
    int32_t * sz = typeck_layout_metrics_sz_slot_depth(depth);
    int32_t * al = typeck_layout_metrics_al_slot_depth(depth);
    (void)(((sz)[0] = 0));
    (void)(((al)[0] = 1));
  }
}
int32_t typeck_layout_metrics_al_read_depth(int32_t depth) {
  {
    int32_t * p = typeck_layout_metrics_al_slot_depth(depth);
    int32_t r = (p)[0];
    return r;
  }
  return 0;
}
int32_t typeck_layout_metrics_sz_read_depth(int32_t depth) {
  {
    int32_t * p = typeck_layout_metrics_sz_slot_depth(depth);
    int32_t r = (p)[0];
    return r;
  }
  return 0;
}
int32_t typeck_call_resolve_dep_idx_peek(void) {
  {
    int32_t * p = typeck_call_resolve_dep_idx_slot();
    int32_t r = (p)[0];
    return r;
  }
  return 0;
}
int32_t typeck_call_resolve_func_idx_peek(void) {
  {
    int32_t * p = typeck_call_resolve_func_idx_slot();
    int32_t r = (p)[0];
    return r;
  }
  return 0;
}
