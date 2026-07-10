#!/usr/bin/env bash
# F-09 v1：全仓库手写 C 清零审计门禁（std/core + compiler/src 跟踪模式）。
#
# 用法：./tests/run-no-handwritten-c-gate.sh
# 环境：
#   SHUX_NO_HANDWRITTEN_C_FAIL=1       — 失败时硬退出
#   SHUX_NO_HANDWRITTEN_C_UPDATE=1     — 刷新 tests/baseline/no-handwritten-c-whitelist.tsv
#   SHUX_NO_HANDWRITTEN_C_STRICT=1     — 终局零 C 模式（当前必 FAIL，供 CI 预留）
#   SHUX_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 — 仅 manifest + 存量对比，跳过子 gate
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NO_HANDWRITTEN_C_FAIL:-0}
UPDATE=${SHUX_NO_HANDWRITTEN_C_UPDATE:-0}
STRICT=${SHUX_NO_HANDWRITTEN_C_STRICT:-0}
MANIFEST_ONLY=${SHUX_NO_HANDWRITTEN_C_MANIFEST_ONLY:-0}
DOC="analysis/phase-f-f09-v1.md"
BASELINE="${SHUX_NO_HANDWRITTEN_C_TSV:-tests/baseline/no-handwritten-c-whitelist.tsv}"

# shellcheck source=tests/lib/no-handwritten-c-audit.sh
. tests/lib/no-handwritten-c-audit.sh

die() {
  echo "no-handwritten-c gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

run_sub() {
  local script="$1"
  local env_var="$2"
  chmod +x "$script"
  if ! env "${env_var}=${FAIL}" "$script"; then
    die "sub-gate failed: $script"
  fi
}

echo "=== F-09 v1: no-handwritten-C audit (track mode) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-09 v1' "$DOC" || die "doc missing F-09 v1 marker"

if [ "$UPDATE" = "1" ]; then
  nhc_write_snapshot_tsv "$BASELINE"
  total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
  echo "no-handwritten-c gate: updated $BASELINE (total=${total})"
  exit 0
fi

if [ ! -f "$BASELINE" ]; then
  nhc_write_snapshot_tsv "$BASELINE"
  total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
  echo "no-handwritten-c gate: created baseline $BASELINE (total=${total})"
  exit 0
fi

export NHC_AUDIT_STRICT="$STRICT"
if ! nhc_audit_whitelist "$BASELINE"; then
  die "whitelist audit failed"
fi

if [ "$MANIFEST_ONLY" = "1" ]; then
  echo "no-handwritten-c gate OK (manifest only)"
  exit 0
fi

echo "=== F-09 v1: delegate run-std-c-inventory-gate ==="
run_sub tests/run-std-c-inventory-gate.sh SHUX_STD_C_INVENTORY_FAIL

if [ -f tests/run-f04-std-crypto-closure-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f04-std-crypto-closure-gate (manifest track) ==="
  chmod +x tests/run-f04-std-crypto-closure-gate.sh
  if ! SHUX_F04_CRYPTO_CLOSURE_FAIL="$FAIL" \
    SHUX_F04_CRYPTO_V16_FAIL=0 SHUX_F04_CRYPTO_V17_FAIL=0 \
    SHUX_F04_CRYPTO_V18_FAIL=0 SHUX_F04_CRYPTO_V19_FAIL=0 \
    tests/run-f04-std-crypto-closure-gate.sh; then
    die "f04 crypto closure sub-gate failed"
  fi
fi

if [ -f tests/run-f05-std-db-closure-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f05-std-db-closure-gate ==="
  run_sub tests/run-f05-std-db-closure-gate.sh SHUX_F05_DB_CLOSURE_FAIL
fi

if [ -f tests/run-f-path-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-path-v1-gate (manifest track) ==="
  chmod +x tests/run-f-path-v1-gate.sh
  if ! SHUX_F_PATH_V1_FAIL="$FAIL" tests/run-f-path-v1-gate.sh; then
    die "f-path-v1 sub-gate failed"
  fi
fi

echo "=== F-09 / G-02f: delegate run-g02f-src-no-inc-gate (src .inc=0) ==="
./tests/run-g02f-src-no-inc-gate.sh

if [ -f tests/run-f-uuid-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-uuid-v1-gate (manifest track) ==="
  chmod +x tests/run-f-uuid-v1-gate.sh
  if ! SHUX_F_UUID_V1_FAIL="$FAIL" tests/run-f-uuid-v1-gate.sh; then
    die "f-uuid-v1 sub-gate failed"
  fi
fi

if [ -f tests/run-f-sort-v1-gate.sh ]; then
  echo "=== F-09 v1: delegate run-f-sort-v1-gate (manifest track) ==="
  chmod +x tests/run-f-sort-v1-gate.sh
  if ! SHUX_F_SORT_V1_FAIL="$FAIL" tests/run-f-sort-v1-gate.sh; then
    die "f-sort-v1 sub-gate failed"
  fi
fi

if [ -f tests/run-e-soft-retire-gate.sh ]; then
  echo "=== F-09 v1: delegate run-e-soft-retire-gate (compiler C track) ==="
  chmod +x tests/run-e-soft-retire-gate.sh
  if ! SHUX_E_SOFT_FAIL="$FAIL" SHUX_E_SOFT_MANIFEST_ONLY=1 tests/run-e-soft-retire-gate.sh; then
    die "e-soft manifest sub-gate failed"
  fi
fi

echo "no-handwritten-c gate OK (F-09 v1 track; run SHUX_NO_HANDWRITTEN_C_STRICT=1 for zero-C终局)"
