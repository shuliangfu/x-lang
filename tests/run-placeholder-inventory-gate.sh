#!/usr/bin/env bash
# STD-168: placeholder() inventory freeze — leftover fossil DOC + leftover
# catalog no Honesty →硬绿.
#
# Honesty: leftover top-level `analysis/placeholder-inventory-v1.md` as
# live DOC (file already archived to analysis/archive/other-tickets/;
# gate still hard-required the missing top-level path → portable STD-168
# red) + leftover catalog no Honesty / missing run=/obs=/skip= report
# retired. Live = analysis/archive/other-tickets/. Refuse top-level
# resurrect. No XLANG face (grep inventory). G.7: do not fork a resolver;
# complete existing placeholder_emit_report. Nested leftover of leftover
# run-comprehensive-check-gate.sh (bundle host; do not rewrite that host).
# Keep `placeholder-inventory gate OK`. Count > max_count stays hard.
# Explicit XLANG is ignored (no XLANG face).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-placeholder-inventory-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/placeholder-inventory.sh
. tests/lib/placeholder-inventory.sh

DOC="${XLANG_PLACEHOLDER_INV_DOC:-analysis/archive/other-tickets/placeholder-inventory-v1.md}"
MANIFEST="${XLANG_PLACEHOLDER_INV_MANIFEST:-tests/baseline/placeholder-inventory.tsv}"
LIB="tests/lib/placeholder-inventory.sh"
MAX_COUNT=40
CNT=0
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "placeholder-inventory gate FAIL: $*" >&2
  placeholder_emit_report "fail" "$CNT" "$MAX_COUNT" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

echo "=== STD-168: placeholder inventory (archive DOC; no XLANG face) ==="

# Refuse leftover fossil top-level DOC as live path (TST-003 pattern).
# PLATFORM: SHARED archaeology — live = archive/other-tickets/.
if [ -f analysis/placeholder-inventory-v1.md ]; then
  die "top-level DOC resurrected (live = archive/other-tickets/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in max_count) MAX_COUNT="$c2" ;; esac
done < "$MANIFEST"

CNT="$(placeholder_count_repo)"
if [ "$CNT" -gt "$MAX_COUNT" ]; then
  die "count=$CNT > max=$MAX_COUNT"
fi

if ! grep -qF 'tests/stdlib-import/main.x' "$DOC" 2>/dev/null; then
  die "doc missing smoke ref"
fi

RUN_OK=1
placeholder_emit_report "ok" "$CNT" "$MAX_COUNT" "$RUN_OK" "$OBS" "$SKIP"
echo "placeholder-inventory gate OK (count=$CNT max=$MAX_COUNT)"
