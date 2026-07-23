#!/usr/bin/env bash
# Xlang 迁移验收汇总 — 对应 重构分析文档.md §12。
# 用法（仓库根）：./tools/verify-xlang-migration.sh
# 可选：VERIFY_XLANG_SKIP_RUN_ALL=1 跳过 run-all（仅 gate + stage2）

set -e
cd "$(dirname "$0")/.."

fail=0
note() { echo "verify-xlang-migration: $*"; }
bad() { note "FAIL: $*"; fail=1; }

note "── §12.1 legacy gate ──"
./tests/run-no-legacy-xlang-gate.sh || bad "legacy gate"

note "── §12.2 .su 文件计数 ──"
su_n=$(find . -name '*.su' -not -path './.git/*' 2>/dev/null | wc -l | tr -d ' ')
if [ "$su_n" != "0" ]; then
  bad "found $su_n .su files"
fi

note "── §12.3 xlang CLI ──"
if [ ! -x ./compiler/xlang ]; then
  bad "compiler/xlang missing (run make -C compiler bootstrap-driver-seed)"
else
  ./compiler/xlang --help 2>&1 | head -3
  ./compiler/xlang --help 2>&1 | grep -q '\.x' || bad "xlang --help missing .x"
fi

note "── §12.4 stage2 selfhost ──"
./compiler/verify-selfhost-stage2.sh || bad "stage2 verify"

if [ "${VERIFY_XLANG_SKIP_RUN_ALL:-0}" != "1" ]; then
  note "── §12.5 run-all (C chain) ──"
  RUN_ALL_USE_C=1 ./tests/run-all.sh || bad "run-all C chain"
fi

if [ "$fail" -ne 0 ]; then
  echo "verify-xlang-migration: FAILED" >&2
  exit 1
fi
note "OK (§12 core checks passed)"
exit 0
