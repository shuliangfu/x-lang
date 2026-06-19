#!/usr/bin/env bash
# parser/typeck/codegen/ast .sx 变更后：migrate-sx gen 门禁 + relink shux_asm + 烟测 import/hex + M-3 region typeck（SU 路径）。
# 用法：./tests/run-refresh-shux-asm-gate.sh
# 环境：SHUX_FORCE_REFRESH_ASM_GATE=1 强制重编 parser/lexer/typeck/codegen .o（忽略 mtime）。
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ] && [ -z "${CI:-}" ]; then
  echo "refresh shux asm gate SKIP (local non-Linux only; CI always runs single-platform relink)"
  exit 0
fi
if [ "$(uname -s)" != "Linux" ] && [ -n "${CI:-}" ]; then
  echo "refresh shux asm gate: CI non-Linux — Mach-O/PE single-platform relink"
fi

make -C compiler -q 2>/dev/null || make -C compiler OPT=1

chmod +x tests/run-migrate-sx-gen-gate.sh
SHUX_FORCE_REFRESH_ASM_GATE="${SHUX_FORCE_REFRESH_ASM_GATE:-0}" ./tests/run-migrate-sx-gen-gate.sh

# 不覆盖 release shux；仅 cp shux -> shux_asm 供 asm struct mk 门禁对齐
SHUX_BSTRICT_NO_REPLACE=1 make -C compiler refresh-shux-asm-gate

echo "refresh shux asm gate: verify shux import std.async + 0x const ..."
out_import=$(./compiler/shux -L . -E tests/parser/import_std_async.sx 2>&1) || {
  echo "refresh shux asm gate FAIL: shux -E import_std_async.sx" >&2
  exit 1
}
echo "$out_import" | grep -q 'shux_async_queue_reset' || {
  echo "refresh shux asm gate FAIL: missing shux_async_queue_reset from std.async" >&2
  exit 1
}

echo "refresh shux asm gate: 0x const typeck (SU path via relinked shux) ..."
./compiler/shux check -L . tests/parser/const_hex.sx 2>&1 || {
  echo "refresh shux asm gate FAIL: shux check const_hex.sx" >&2
  exit 1
}

echo "refresh shux asm gate: 0x const C emit (shux-c) ..."
out_hex=$(./compiler/shux-c -L . -E tests/parser/const_hex.sx 2>&1) || {
  echo "refresh shux asm gate FAIL: shux-c -E const_hex.sx" >&2
  exit 1
}
echo "$out_hex" | grep -q '1095980800' || {
  echo "refresh shux asm gate FAIL: expected MAGIC 1095980800 (0x41535700)" >&2
  exit 1
}

echo "refresh shux asm gate: M-3 region typeck (SU path via relinked shux) ..."
SHUX=./compiler/shux ./tests/run-typeck-region.sh | tee /tmp/refresh_asm_region.log
grep -q 'region typeck OK' /tmp/refresh_asm_region.log

echo "refresh shux asm gate: M-4 linear typeck (SU path via relinked shux) ..."
SHUX=./compiler/shux ./tests/run-typeck-linear.sh | tee /tmp/refresh_asm_linear.log
grep -q 'linear typeck OK' /tmp/refresh_asm_linear.log || {
  echo "refresh shux asm gate FAIL: SU path linear typeck" >&2
  exit 1
}

echo "refresh shux asm gate OK"
