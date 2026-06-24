#!/usr/bin/env bash
# STD-080/081：std.option + std.result 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_OPTION_RESULT_DOC:-analysis/std-option-result-v1.md}"
OPT_MANIFEST="${SHUX_STD_OPTION_MANIFEST:-tests/baseline/std-option-manifest.tsv}"
RES_MANIFEST="${SHUX_STD_RESULT_MANIFEST:-tests/baseline/std-result-manifest.tsv}"
OPT_SX="std/option/mod.sx"
RES_SX="std/result/mod.sx"
LIB="tests/lib/std-option-result.sh"
SMOKE_SX="tests/std-option-result/roundtrip.sx"
MIN_OPT=8
MIN_RES=8

# shellcheck source=tests/lib/std-option-result.sh
. "$LIB"

echo "=== STD-080/081: std.option & std.result manifest ==="
for f in "$DOC" "$OPT_MANIFEST" "$RES_MANIFEST" "$LIB" "$OPT_SX" "$RES_SX" "$SMOKE_SX" std/option/README.md std/result/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-option-result gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-080 STD-081 option_from_result result_from_error_code map_i32 and_then; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-option-result gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_OPT="$c2" ;; esac
done < "$OPT_MANIFEST"
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_RES="$c2" ;; esac
done < "$RES_MANIFEST"

std_option_result_check_manifest "$OPT_SX" "$OPT_MANIFEST" "$MIN_OPT" "std.option"
std_option_result_check_manifest "$RES_SX" "$RES_MANIFEST" "$MIN_RES" "std.result"
echo "std-option-result manifest OK"

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-080/081: .sx smoke (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-option-result gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_option_result_emit_report "fail" 0 0
    exit 1
  fi
  if std_option_result_run_smoke "$SHUX_BIN" "$SMOKE_SX" "roundtrip"; then SX_OK=1; else
    std_option_result_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_option_result_emit_report "ok" "$SX_OK" "$SKIP"
echo "std-option-result gate OK"
