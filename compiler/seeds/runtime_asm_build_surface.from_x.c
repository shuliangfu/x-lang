/* seeds/runtime_asm_build_surface.from_x.c
 * G-02f-24 runtime_asm_build R2 thin(extern) surface — isomorphic with src/asm/runtime_asm_build.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o (no rest; seed fully guarded)
 * Prove: full.x vs this surface → nm IDENTICAL (2 #[no_mangle], no doc_anchor)
 * Mode: thin(extern) — .x provides 2 asm_driver_* functions (forwards to driver_abi extern bridges);
 *   seed has #ifndef XLANG_RUNTIME_ASM_BUILD_FROM_X guard (2 skipped when PREFER_X_O)
 * Cap residual: main() — .x cannot express char** argv (Clang forces char** for main's 2nd arg);
 *   main stays in seed, not part of prove (not #[no_mangle] in .x)
 * Note: no doc_anchor function in .x — prove nm compares only #[no_mangle] T symbols.
 * Logic: 2 functions = asm_driver_skip_codegen_dep_0_get (i32 getter) +
 *   asm_driver_set_current_dep_path_for_codegen (void setter). Both forward to driver_abi extern C.
 * Regen: ./xlang-c -E ... runtime_asm_build.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);

int32_t asm_driver_skip_codegen_dep_0_get(void) {
  return driver_skip_codegen_dep_0_get();
}

void asm_driver_set_current_dep_path_for_codegen(uint8_t *path) {
  driver_set_current_dep_path_for_codegen((const char *)path);
}
