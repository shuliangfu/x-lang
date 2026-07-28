/* seeds/build_runtime_surface.from_x.c
 * G-02f-83 build_runtime R2 thin+rest surface - isomorphic with src/build_runtime.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/build_runtime.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (5 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest - 5 thin forwards to _impl extern bridges
 * Cap residual: 5 _impl bridges (build_runtime_info_impl/warn_impl + build_patch_pipeline_gen_c_impl/driver_gen_c_impl + build_run_legacy_steps_impl)
 * doc_anchor build_runtime_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: build_/build_patch_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 5 thin+rest functions. seed 全守卫 #ifndef XLANG_BUILD_RUNTIME_FROM_X.
 * Regen: ./xlang-c -E ... build_runtime.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern void build_runtime_info_impl(uint8_t *msg);
extern void build_runtime_warn_impl(uint8_t *msg);
extern int32_t build_patch_pipeline_gen_c_impl(void);
extern int32_t build_patch_driver_gen_c_impl(void);
extern int32_t build_run_legacy_steps_impl(uint8_t *xlang_path);

int32_t build_runtime_x_doc_anchor(void) { return 0; }

/* === 5 thin+rest forwards === */

void build_runtime_info(uint8_t *msg) { build_runtime_info_impl(msg); }

void build_runtime_warn(uint8_t *msg) { build_runtime_warn_impl(msg); }

int32_t build_patch_pipeline_gen_c(void) { return build_patch_pipeline_gen_c_impl(); }

int32_t build_patch_driver_gen_c(void) { return build_patch_driver_gen_c_impl(); }

int32_t build_run_legacy_steps(uint8_t *xlang_path) { return build_run_legacy_steps_impl(xlang_path); }
