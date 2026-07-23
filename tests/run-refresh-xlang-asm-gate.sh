#!/usr/bin/env bash
# parser/typeck/codegen/ast .x 变更后：migrate-x gen 门禁 + relink xlang_asm + 烟测 import/hex + M-3 region typeck（X 路径）。
# 用法：./tests/run-refresh-xlang-asm-gate.sh
# 环境：XLANG_FORCE_REFRESH_ASM_GATE=1 强制重编 parser/lexer/typeck/codegen .o（忽略 mtime）。
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ] && [ -z "${CI:-}" ]; then
  echo "refresh xlang asm gate SKIP (local non-Linux only; CI always runs single-platform relink)"
  exit 0
fi
if [ "$(uname -s)" != "Linux" ] && [ -n "${CI:-}" ]; then
  echo "refresh xlang asm gate: CI non-Linux — Mach-O/PE single-platform relink"
fi

make -C compiler -q 2>/dev/null || make -C compiler OPT=1

chmod +x tests/run-migrate-x-gen-gate.sh
XLANG_FORCE_REFRESH_ASM_GATE="${XLANG_FORCE_REFRESH_ASM_GATE:-0}" ./tests/run-migrate-x-gen-gate.sh

# 不覆盖 release xlang；仅 cp xlang -> xlang_asm 供 asm struct mk 门禁对齐
XLANG_BSTRICT_NO_REPLACE=1 make -C compiler refresh-xlang-asm-gate

echo "refresh xlang asm gate: verify xlang import std.async + 0x const ..."
out_import=$(./compiler/xlang build -L . -E tests/parser/import_std_async.x 2>&1) || {
  echo "refresh xlang asm gate FAIL: xlang -E import_std_async.x" >&2
  exit 1
}
echo "$out_import" | grep -q 'xlang_async_queue_reset' || {
  echo "refresh xlang asm gate FAIL: missing xlang_async_queue_reset from std.async" >&2
  exit 1
}

echo "refresh xlang asm gate: 0x const typeck (X path via relinked xlang) ..."
./compiler/xlang check -L . tests/parser/const_hex.x 2>&1 || {
  echo "refresh xlang asm gate FAIL: xlang check const_hex.x" >&2
  exit 1
}

echo "refresh xlang asm gate: 0x const C emit (xlang-c) ..."
out_hex=$(./compiler/xlang-c -L . -E tests/parser/const_hex.x 2>&1) || {
  echo "refresh xlang asm gate FAIL: xlang-c -E const_hex.x" >&2
  exit 1
}
echo "$out_hex" | grep -q '1095980800' || {
  echo "refresh xlang asm gate FAIL: expected MAGIC 1095980800 (0x41535700)" >&2
  exit 1
}

echo "refresh xlang asm gate: M-3 region typeck (X path via relinked xlang) ..."
XLANG=./compiler/xlang ./tests/run-typeck-region.sh | tee /tmp/refresh_asm_region.log
grep -q 'region typeck OK' /tmp/refresh_asm_region.log

echo "refresh xlang asm gate: M-4 linear typeck (X path via relinked xlang) ..."
XLANG=./compiler/xlang ./tests/run-typeck-linear.sh | tee /tmp/refresh_asm_linear.log
grep -q 'linear typeck OK' /tmp/refresh_asm_linear.log || {
  echo "refresh xlang asm gate FAIL: X path linear typeck" >&2
  exit 1
}

echo "refresh xlang asm gate OK"
