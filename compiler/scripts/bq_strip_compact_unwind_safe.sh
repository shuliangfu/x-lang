#!/usr/bin/env bash
# Class BQ／BS／BT／BU: strip __compact_unwind on Darwin tip-linked objs.
# Class BS n_sect remap. Ban: parser_asm_thin_glue.o only.
# Class BU: sweep every G05_OBJS Mach-O with CU (via g05_relink_env).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PY=scripts/pabi_strip_macho_compact_unwind.py
# shellcheck disable=SC1091
source scripts/g05_relink_env.sh >/dev/null
for o in ${G05_OBJS:-}; do
  case "$o" in *thin_glue*) echo "ban $o"; continue;; esac
  [[ -f "$o" ]] || continue
  python3 "$PY" "$o" -o "$o" || true
done
