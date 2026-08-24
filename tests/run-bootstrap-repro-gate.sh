#!/usr/bin/env bash
# BOOT-003：自举最小复现 manifest 门禁
#
# wave309 honesty: DOC archived under analysis/archive/boot/.
# PLATFORM: SHARED archaeology.
#
# 验证文档、矩阵、hook 脚本存在；可选 list 烟测。
# 用法：./tests/run-bootstrap-repro-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_BOOT_REPRO_DOC:-analysis/archive/boot/boot-repro-v1.md}"
MATRIX="${XLANG_BOOTSTRAP_REPRO_TSV:-tests/baseline/bootstrap-repro.tsv}"

echo "=== BOOT-003: bootstrap repro manifest ==="
for f in \
  "$DOC" \
  "$MATRIX" \
  tests/run-bootstrap-repro.sh \
  tests/run-bootstrap-repro-build.sh; do
  if [ ! -f "$f" ]; then
    echo "bootstrap-repro gate FAIL: missing $f" >&2
    exit 1
  fi
done

# 矩阵中每个 hook 须存在。
MISSING=0
while IFS=$'\t' read -r case_id stage hook platform notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  if [ ! -f "tests/${hook}" ]; then
    echo "bootstrap-repro gate FAIL: missing tests/${hook} (case $case_id)" >&2
    MISSING=$((MISSING + 1))
  fi
done < "$MATRIX"
if [ "$MISSING" -gt 0 ]; then
  exit 1
fi
echo "bootstrap-repro manifest OK (${MISSING} missing hooks checked)"

chmod +x tests/run-bootstrap-repro.sh tests/run-bootstrap-repro-build.sh
if ! ./tests/run-bootstrap-repro.sh list | grep -q 'verify_semantic'; then
  echo "bootstrap-repro gate FAIL: list output invalid" >&2
  exit 1
fi
echo "bootstrap-repro list OK"

# 默认不跑完整 repro（耗时）；显式开启时跑 verify_semantic 或指定 case。
if [ -n "${XLANG_BOOTSTRAP_REPRO_GATE_RUN:-}" ]; then
  echo "=== BOOT-003: smoke repro (${XLANG_BOOTSTRAP_REPRO_GATE_RUN}) ==="
  ./tests/run-bootstrap-repro.sh "${XLANG_BOOTSTRAP_REPRO_GATE_RUN}"
fi

echo "bootstrap-repro gate OK"
