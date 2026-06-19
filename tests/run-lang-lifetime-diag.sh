#!/usr/bin/env bash
# LANG-008：生命周期错误行号定位烟测
#
# 用法：./tests/run-lang-lifetime-diag.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_LANG_LIFETIME_DIAG_CASES:-tests/baseline/lang-lifetime-diag-cases.tsv}"

# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if lang_lifetime_diag_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! lang_lifetime_diag_native_shu "$SHUX_BIN"; then
  echo "lang-lifetime-diag SKIP (no native shux, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "lang-lifetime-diag OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== LANG-008: lifetime diagnostic line smoke (SHUX=$SHUX_BIN) ==="
FAILS=0
while IFS=$'\t' read -r case_id file substr want_line notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  src="tests/typeck/slice_lifetime/${file}"
  if [ ! -f "$src" ]; then
    echo "lang-lifetime-diag FAIL: missing $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  err=$("$SHUX_BIN" check "$src" 2>&1) || true
  if lang_lifetime_diag_expect_at_line "$err" "$substr" "$want_line"; then
    echo "lang-lifetime-diag OK $case_id at ${want_line} ($notes)"
  else
    FAILS=$((FAILS + 1))
  fi
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "lang-lifetime-diag FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "lang-lifetime-diag OK"
