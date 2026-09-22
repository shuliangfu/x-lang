/* PLATFORM: WINDOWS leftover-PE — ABI-correct asm_wpo_collect_walk.
 * Class AB. Link FIRST (PE first-wins) over wrong-arity stub.
 */
#include <stdint.h>

/* wave777 Class AB: was void(a,b) wrong arity — callers pass 7 args
 * (is_block, a, ref, caller_id, caller_mod, ctx, depth). Win leftover had
 * empty wpo_thin.o (0 bytes) so stub won; PREFER thin -c is HARD BAN / CG002
 * on Win. ABI-safe no-op until PE thin is green. PLATFORM: WINDOWS leftover-PE. */
void asm_wpo_collect_walk(int32_t is_block, void *a, int32_t ref, int32_t caller_id,
                          void *caller_mod, void *ctx, int32_t depth) {
  (void)is_block;
  (void)a;
  (void)ref;
  (void)caller_id;
  (void)caller_mod;
  (void)ctx;
  (void)depth;
}
