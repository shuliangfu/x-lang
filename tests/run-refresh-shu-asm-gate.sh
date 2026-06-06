#!/usr/bin/env bash
# parser/typeck/codegen/ast .su 变更后：migrate-su gen 门禁 + relink shu_asm + 烟测 import/hex + M-3 region typeck（SU 路径）。
# 用法：./tests/run-refresh-shu-asm-gate.sh
# 环境：SHU_FORCE_REFRESH_ASM_GATE=1 强制重编 parser/lexer/typeck/codegen .o（忽略 mtime）。
set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s)" != "Linux" ]; then
  echo "refresh shu asm gate SKIP (non-Linux; mixed ELF/Mach-O 本地勿 relink)"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler OPT=1

chmod +x tests/run-migrate-su-gen-gate.sh
SHU_FORCE_REFRESH_ASM_GATE="${SHU_FORCE_REFRESH_ASM_GATE:-0}" ./tests/run-migrate-su-gen-gate.sh

# 不覆盖 release shu；仅 cp shu -> shu_asm 供 asm struct mk 门禁对齐
SHU_BSTRICT_NO_REPLACE=1 make -C compiler refresh-shu-asm-gate

echo "refresh shu asm gate: verify shu import std.async + 0x const ..."
out_import=$(./compiler/shu -L . -E tests/parser/import_std_async.su 2>&1) || {
  echo "refresh shu asm gate FAIL: shu -E import_std_async.su" >&2
  exit 1
}
echo "$out_import" | grep -q 'shu_async_queue_reset' || {
  echo "refresh shu asm gate FAIL: missing shu_async_queue_reset from std.async" >&2
  exit 1
}

echo "refresh shu asm gate: 0x const typeck (SU path via relinked shu) ..."
./compiler/shu check -L . tests/parser/const_hex.su 2>&1 || {
  echo "refresh shu asm gate FAIL: shu check const_hex.su" >&2
  exit 1
}

echo "refresh shu asm gate: 0x const C emit (shu-c) ..."
out_hex=$(./compiler/shu-c -L . -E tests/parser/const_hex.su 2>&1) || {
  echo "refresh shu asm gate FAIL: shu-c -E const_hex.su" >&2
  exit 1
}
echo "$out_hex" | grep -q '1095980800' || {
  echo "refresh shu asm gate FAIL: expected MAGIC 1095980800 (0x41535700)" >&2
  exit 1
}

echo "refresh shu asm gate: M-3 region typeck (SU path via relinked shu) ..."
SHU=./compiler/shu ./tests/run-typeck-region.sh | tee /tmp/refresh_asm_region.log
grep -q 'region typeck OK' /tmp/refresh_asm_region.log

echo "refresh shu asm gate: M-4 linear typeck (SU path via relinked shu) ..."
SHU=./compiler/shu ./tests/run-typeck-linear.sh | tee /tmp/refresh_asm_linear.log
grep -q 'linear typeck OK' /tmp/refresh_asm_linear.log || {
  echo "refresh shu asm gate FAIL: SU path linear typeck" >&2
  exit 1
}

echo "refresh shu asm gate OK"
