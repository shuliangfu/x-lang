#!/usr/bin/env bash
# TYPE-003：借用规则冲突 / 误报烟测
#
# 用法：./tests/run-type-borrow-conflict.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_TYPE_BORROW_CASES:-tests/baseline/type-borrow-conflict-cases.tsv}"

# shellcheck source=tests/lib/type-borrow-conflict.sh
. tests/lib/type-borrow-conflict.sh
# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if type_borrow_native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ] || ! type_borrow_native_shu "$SHU_BIN"; then
  echo "type-borrow-conflict SKIP (no native shu, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "type-borrow-conflict OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== TYPE-003: borrow conflict smoke (SHU=$SHU_BIN) ==="
FAILS=0
while IFS=$'\t' read -r case_id file policy substr want_line notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  src=$(type_borrow_case_path "$file") || {
    echo "type-borrow-conflict FAIL: missing case file $file" >&2
    FAILS=$((FAILS + 1))
    continue
  }
  case "$policy" in
    pos)
      if "$SHU_BIN" check "$src" >/dev/null 2>&1; then
        echo "type-borrow-conflict OK $case_id (pos)"
      else
        err=$("$SHU_BIN" check "$src" 2>&1) || true
        echo "type-borrow-conflict FAIL: false positive $case_id ($notes)" >&2
        echo "$err" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    neg)
      err=$("$SHU_BIN" check "$src" 2>&1) || true
      if [ -z "$substr" ] || [ "$substr" = "-" ]; then
        echo "type-borrow-conflict FAIL: neg case $case_id missing expect_substr" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      if ! echo "$err" | grep -qF "$substr"; then
        echo "type-borrow-conflict FAIL: $case_id missing '$substr'" >&2
        echo "$err" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      if [ -n "$want_line" ] && [ "$want_line" != "-" ]; then
        if ! lang_lifetime_diag_expect_at_line "$err" "$substr" "$want_line"; then
          FAILS=$((FAILS + 1))
          continue
        fi
      fi
      echo "type-borrow-conflict OK $case_id (neg: $substr)"
      ;;
    *)
      echo "type-borrow-conflict WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "type-borrow-conflict FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "type-borrow-conflict OK"
