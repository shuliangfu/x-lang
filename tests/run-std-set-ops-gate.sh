#!/usr/bin/env bash
# STD-129：std.set Set_i32 union/intersect/difference 门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-set-ops-v1.md"
MANIFEST="tests/baseline/std-set-ops-manifest.tsv"
MOD_SU="std/set/mod.sx"
LIB="tests/lib/std-set-ops.sh"
SMOKE_SU="tests/set/ops.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-set-ops gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-129 "$DOC" || { echo "std-set-ops gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_set_ops_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_set_ops_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_set_ops_emit_report ok "$SU_OK" "$SKIP"
echo "std-set-ops gate OK"
