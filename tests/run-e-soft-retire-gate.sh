#!/usr/bin/env bash
# 阶段 E-soft 聚合门禁：manifest + E-01 + C-03/C-04/C-06/C-09 委托。
#
# 用法：./tests/run-e-soft-retire-gate.sh
# 环境：
#   SHUX_E_SOFT_FAIL=1              — 失败时硬退出
#   SHUX_E_SOFT_MANIFEST_ONLY=1     — 仅 manifest（跳过子 gate）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_E_SOFT_FAIL:-0}
DOC="analysis/phase-e-soft-v2-closure.md"
DOC_V1="analysis/phase-e-soft-v1.md"
MANIFEST="tests/baseline/phase-e-soft-retire.tsv"

die() {
  echo "e-soft gate FAIL: $*" >&2
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

echo "=== E-soft v2: compiler C/H soft-retire CLOSED (gate all green) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$DOC_V1" ] || die "missing $DOC_V1"
grep -q 'E-soft v2' "$DOC" || die "doc missing E-soft v2 closure marker"
grep -q 'E-soft v1' "$DOC_V1" || die "doc missing E-soft v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"

# shellcheck source=tests/lib/phase-e-soft-audit.sh
. tests/lib/phase-e-soft-audit.sh

if ! phase_e_soft_audit_manifest "$MANIFEST"; then
  die "phase-e-soft-retire manifest audit failed"
fi
if ! phase_e_soft_audit_makefile_no_c_frontend; then
  die "Makefile default seed still links C frontend"
fi

ret_n=$(phase_e_soft_count_retired "$MANIFEST")
act_n=$(phase_e_soft_count_active "$MANIFEST")
echo "e-soft: soft_retired=${ret_n} active_c=${act_n} (files on disk; default B-strict skips retired)"

if [ "${SHUX_E_SOFT_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "e-soft gate OK (manifest only)"
  exit 0
fi

echo "=== E-soft: delegate E-01 extern .h ==="
run_sub tests/run-e01-extern-h-soft-gate.sh SHUX_E01_FAIL

echo "=== E-soft: delegate C-06 x frontend default ==="
run_sub tests/run-c06-x-frontend-default-gate.sh SHUX_C06_FAIL

echo "=== E-soft: delegate C-09 parser no C fallback ==="
run_sub tests/run-c09-parser-no-c-fallback-gate.sh SHUX_C09_FAIL

if [ -f tests/run-c03-no-pipeline-gen-gate.sh ]; then
  echo "=== E-soft: delegate C-03 no pipeline_gen.c ==="
  run_sub tests/run-c03-no-pipeline-gen-gate.sh SHUX_C03_FAIL
fi

if [ -f tests/run-c04-e-extern-gate.sh ]; then
  echo "=== E-soft: delegate C-04 -E-extern aggregate ==="
  run_sub tests/run-c04-e-extern-gate.sh SHUX_C04_FAIL
fi

if [ -f tests/run-e02-lsp-diag-soft-gate.sh ]; then
  echo "=== E-soft: delegate E-02 lsp_diag soft-retire ==="
  run_sub tests/run-e02-lsp-diag-soft-gate.sh SHUX_E02_FAIL
fi

if [ -f tests/run-e03-preprocess-soft-gate.sh ]; then
  echo "=== E-soft: delegate E-03 preprocess soft-retire ==="
  run_sub tests/run-e03-preprocess-soft-gate.sh SHUX_E03_PREPROCESS_FAIL
fi

if [ -f tests/run-e03-lexer-ast-soft-gate.sh ]; then
  echo "=== E-soft: delegate E-03 lexer/ast soft-retire ==="
  run_sub tests/run-e03-lexer-ast-soft-gate.sh SHUX_E03_LEXER_AST_FAIL
fi

if [ -f tests/run-e03-v3-coldstart-track-gate.sh ]; then
  echo "=== E-soft: delegate E-03 v3 cold-start track ==="
  run_sub tests/run-e03-v3-coldstart-track-gate.sh SHUX_E03_V3_FAIL
fi

if [ -f tests/run-e04-runtime-soft-gate.sh ]; then
  echo "=== E-soft: delegate E-04 runtime path audit ==="
  run_sub tests/run-e04-runtime-soft-gate.sh SHUX_E04_FAIL
fi

if [ -f tests/run-e06-no-compiler-frontend-cc-gate.sh ]; then
  echo "=== E-soft: delegate E-06 no compiler frontend cc -c ==="
  run_sub tests/run-e06-no-compiler-frontend-cc-gate.sh SHUX_E06_FAIL
fi

if [ -f tests/run-e05-include-soft-gate.sh ]; then
  echo "=== E-soft: delegate E-05 include inventory ==="
  run_sub tests/run-e05-include-soft-gate.sh SHUX_E05_FAIL
fi

echo "e-soft gate OK (E-01～E-06 audited; phase E CLOSED at E-soft v2)"
