/*
 * DIG s223: host-cc twin for glue_index_assign_addr_cache_hit.
 *
 * Tip-asm of w156_guard_thin.x can emit ELF with Machine=None (EM:0),
 * which ld rejects ("Relocations in generic ELF"). Authority: always
 * return 0 (cache miss) — same as runtime_pipeline_abi_w156_guard_thin.x.
 * PLATFORM: LINUX gold host-cc fallback for g05 selfhost bag.
 */
#include <stdint.h>

/**
 * wave156 INDEX assign-addr cache hit — disabled (always miss).
 * Unused args kept for ABI match with the thin / egg T.
 */
int32_t glue_index_assign_addr_cache_hit(
    uint8_t *arena, uint8_t *ctx, int32_t base_ref, int32_t idx_ref, int32_t esz) {
  (void)arena;
  (void)ctx;
  (void)base_ref;
  (void)idx_ref;
  (void)esz;
  return 0;
}
