#!/usr/bin/env sh
# gen_g06_phase1_backend_stub.sh -- kept for callers (bootstrap_driver_seed.sh).
#
# w1541 (checklist 6.3): there is no phase1 weak-stub partial any more and no
# seeds/asm_backend_partial.<os>.<arch>.o. The partial is always the real one,
# one pure-asm emit of src/asm/backend_seed_mega_fallback.x by
# scripts/build_asm_backend_partial_pure.sh. No host cc of generated stubs.
# PLATFORM: SHARED. Usage (compiler dir): ./scripts/gen_g06_phase1_backend_stub.sh
set -e
cd "$(dirname "$0")/.."
exec bash scripts/build_asm_backend_partial_pure.sh
