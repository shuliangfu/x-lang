#!/usr/bin/env bash
# LANG-006: CTFE golden hook (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm via lib resolve. Explicit bad XLANG / missing native = hard die.
#
# Usage: ./tests/run-lang-const-eval.sh [case_id]
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
chmod +x tests/lib/lang-const-eval.sh
# shellcheck source=tests/lib/lang-const-eval.sh
. tests/lib/lang-const-eval.sh

if lang_const_eval_main "${1:-}"; then
  echo "lang-const-eval hook OK"
  exit 0
fi
ec=$?
if [ "$ec" -eq 2 ]; then
  echo "lang-const-eval hook FAIL: no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)" >&2
  exit 1
fi
echo "lang-const-eval hook FAIL" >&2
exit 1
