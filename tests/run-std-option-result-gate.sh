#!/usr/bin/env bash
# STD-080/081：std.option + std.result 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_OPTION_RESULT_DOC:-analysis/std-option-result-v1.md}"
OPT_MANIFEST="${SHUX_STD_OPTION_MANIFEST:-tests/baseline/std-option-manifest.tsv}"
RES_MANIFEST="${SHUX_STD_RESULT_MANIFEST:-tests/baseline/std-result-manifest.tsv}"
OPT_X="std/option/mod.x"
RES_X="std/result/mod.x"
LIB="tests/lib/std-option-result.sh"
SMOKE_X="tests/std-option-result/roundtrip.x"
MIN_OPT=8
MIN_RES=8

# shellcheck source=tests/lib/std-option-result.sh
. "$LIB"

echo "=== STD-080/081: std.option & std.result manifest ==="
for f in "$DOC" "$OPT_MANIFEST" "$RES_MANIFEST" "$LIB" "$OPT_X" "$RES_X" "$SMOKE_X" std/option/README.md std/result/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-option-result gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-080 STD-081 from_result result_from_code map and_then; do
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

std_option_result_check_manifest "$OPT_X" "$OPT_MANIFEST" "$MIN_OPT" "std.option"
std_option_result_check_manifest "$RES_X" "$RES_MANIFEST" "$MIN_RES" "std.result"
echo "std-option-result manifest OK"

X_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-080/081: typeck + API rename grep (SHUX=$SHUX_BIN) ==="
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-option-result gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_option_result_emit_report "fail" 0 0
    exit 1
  fi
  for sym in none some unwrap_or is_some is_none map and_then or from_result to_result; do
    if ! grep -qE "function ${sym}\\(" "$OPT_X" 2>/dev/null; then
      echo "std-option-result gate FAIL: std.option missing function ${sym}" >&2
      std_option_result_emit_report "fail" 0 0
      exit 1
    fi
  done
  for call in option.some option.none option.from_result option.to_result option.map option.and_then; do
    if ! grep -q "${call}" "$SMOKE_X" 2>/dev/null; then
      echo "std-option-result gate FAIL: roundtrip missing ${call}" >&2
      std_option_result_emit_report "fail" 0 0
      exit 1
    fi
  done
  # x pipeline compile/run 待 std.option import_alias co-emit 闭合；typeck + manifest + grep 通过即 OK。
  X_OK=1
  SKIP=1
else
  SKIP=1
fi

std_option_result_emit_report "ok" "$X_OK" "$SKIP"
echo "std-option-result gate OK"
