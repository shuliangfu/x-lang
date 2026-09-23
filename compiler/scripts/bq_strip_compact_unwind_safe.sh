#!/usr/bin/env bash
# Class BQ: strip __compact_unwind on Darwin tip objs proven link-safe.
# Ban: thin_glue / call_dispatch / enc_dispatch / diag.o (n_sect／LOH).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PY=scripts/pabi_strip_macho_compact_unwind.py
for o in \
  src/seed_link_compat.o \
  src/runtime_driver_diagnostic.o \
  src/asm/backend_try_inline_dispatch.o
do
  if [[ -f "$o" ]]; then
    python3 "$PY" "$o" -o "$o"
  else
    echo "skip missing $o" >&2
  fi
done
