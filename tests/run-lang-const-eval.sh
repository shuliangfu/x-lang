#!/usr/bin/env bash
# LANG-006：CTFE 金样 hook（供 gate / 本地调试）
#
# 用法：./tests/run-lang-const-eval.sh [case_id]
set -e
cd "$(dirname "$0")/.."
chmod +x tests/lib/lang-const-eval.sh
if tests/lib/lang-const-eval.sh "${1:-}"; then
  echo "lang-const-eval hook OK"
else
  ec=$?
  if [ "$ec" -eq 2 ]; then
    echo "lang-const-eval hook SKIP (no native shux)"
    exit 0
  fi
  echo "lang-const-eval hook FAIL" >&2
  exit 1
fi
