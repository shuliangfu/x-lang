#!/usr/bin/env bash
# A-12：B-strict shux_asm strict link 跨模块符号门禁（arch_* / backend 导出无 U）。
# 用法：./tests/run-a12-cross-module-symbols-gate.sh
# 环境：SHUX_A12_CROSS_MODULE_FAIL=1 存在 baseline 外 undefined 时硬失败
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_A12_CROSS_MODULE_FAIL:-0}
COMPILER="${SHUX_A12_COMPILER:-compiler/shux_asm}"
BASELINE="${SHUX_A12_UNDEFINED_TSV:-tests/baseline/a12-cross-module-undefined.tsv}"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "a12-cross-module-symbols-gate: N/A on Darwin (Linux x86_64/arm64 covers strict link)"
  exit 0
fi

if [ ! -x "$COMPILER" ]; then
  echo "a12-cross-module-symbols-gate: SKIP (no $COMPILER)"
  exit 0
fi

# 跨模块 backend/arch 符号：须已定义，不得为 nm U。
PATTERNS='arch_(arm64|x86_64|riscv64)|backend_asm_codegen|platform_elf'
UNDEF=$(nm "$COMPILER" 2>/dev/null | awk '/ U / { print $3 }' | grep -E "$PATTERNS" | LC_ALL=C sort -u || true)
UNDEF_COUNT=$(printf '%s\n' "$UNDEF" | sed '/^$/d' | wc -l | tr -d ' ')

echo "a12-cross-module-symbols-gate: $COMPILER arch/backend undefined count=${UNDEF_COUNT}"

if [ "${UNDEF_COUNT:-0}" -eq 0 ]; then
  echo "a12-cross-module-symbols-gate OK (no arch_/backend_asm undefined in $COMPILER)"
  exit 0
fi

echo "a12-cross-module-symbols-gate: undefined symbols (first 12):" >&2
printf '%s\n' "$UNDEF" | head -12 >&2

# baseline 允许已知过渡态；默认 track-only，CI 可 SHUX_A12_CROSS_MODULE_FAIL=1 收紧。
if [ -f "$BASELINE" ]; then
  ALLOWED=$(awk -F'\t' '$1=="allowed_undefined" && $2 !~ /^#/ { print $2 }' "$BASELINE" | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u)
  NEW=""
  while IFS= read -r sym; do
    [ -z "$sym" ] && continue
    if ! printf '%s\n' "$ALLOWED" | grep -qxF "$sym"; then
      NEW="${NEW} ${sym}"
    fi
  done <<EOF
$UNDEF
EOF
  if [ -z "$(echo "$NEW" | tr -d ' ')" ]; then
    echo "a12-cross-module-symbols-gate OK (${UNDEF_COUNT} undefined; all in baseline allowlist)"
    exit 0
  fi
  echo "a12-cross-module-symbols-gate FAIL: new undefined beyond baseline:${NEW}" >&2
else
  echo "a12-cross-module-symbols-gate WARN: ${UNDEF_COUNT} undefined (no baseline; create $BASELINE)" >&2
fi

[ "$FAIL" = "1" ] && exit 1
exit 0
