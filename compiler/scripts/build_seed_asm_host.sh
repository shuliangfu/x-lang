#!/bin/sh
# build_seed_asm_host.sh -- make build_asm/seed_host/asm_backend_partial.o for
# bootstrap-driver-seed / xlang_x_pipeline ensure ladder / build_xlang_asm.
#
# w1541 (checklist 6.3): the partial is one pure-asm emit of
# src/asm/backend_seed_mega_fallback.x by scripts/build_asm_backend_partial_pure.sh,
# the same builder g05 runs every generation. This script no longer runs
# xlang-c -E asm_seed_full.x, no longer host-cc's asm_full_gen.c or
# seeds/backend_seed_mega_fallback.from_x.c, and no longer copies the partial
# into seeds/asm_backend_partial.<os>.<arch>.o. Failure exits 1; no fallback.
# PLATFORM: SHARED. Usage (compiler dir): ./scripts/build_seed_asm_host.sh
set -e
cd "$(dirname "$0")/.."
if ! bash scripts/build_asm_backend_partial_pure.sh; then
  printf 'build error: build_seed_asm_host: pure asm partial failed (no cc fallback, w1541)\n' >&2
  exit 1
fi
printf 'info: build_seed_asm_host: OK (build_asm/seed_host/asm_backend_partial.o, pure asm)\n' >&2
