/* Standalone translation unit for the BSS slot prefix of
 * seeds/typeck_cap_residual.from_x.c plus seeds/typeck_allow_legacy.from_x.c.
 *
 * assemble_typeck_gen_from_x.py pastes the whole residual, including the
 * CTFE half, into typeck_gen.c. patch_typeck_gen_lang007.py inserts the
 * allow-legacy helpers from that seed file. A pure-asm compile of typeck.x
 * leaves the slot accessors and typeck_set_allow_legacy_extern_calls
 * undefined. This file is not a second implementation: the bodies stay in
 * those two seeds. TYPECK_CAP_RESIDUAL_SLOTS_ONLY leaves the CTFE half out
 * of this object. seeds/typeck_ctfe_tu.c includes the same residual without
 * that macro. g05 links the CTFE object only when typeck_x.pure_asm matches
 * typeck_x.o. With no stamp, the host-cc paste in typeck_gen.c is still the
 * CTFE definition, and this slot object is the companion on the link.
 *
 * PLATFORM: SHARED — same slot and allow-legacy bodies the host-cc
 * typeck_x.o already contains. The g05 hook that links this object is
 * Linux-only until other hosts leave host-cc typeck_gen.c.
 */
#include <stdint.h>

#define TYPECK_CAP_RESIDUAL_SLOTS_ONLY 1
#include "typeck_cap_residual.from_x.c"
#include "typeck_allow_legacy.from_x.c"
