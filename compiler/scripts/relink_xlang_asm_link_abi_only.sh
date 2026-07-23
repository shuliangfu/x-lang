#!/bin/sh
# relink_xlang_asm_link_abi_only.sh — 仅刷新 runtime_link_abi / io_stubs 后 B-strict 重链 xlang_asm
#
# 自举约束：须已有 build_asm/*.o 与**真** seed_host/asm_backend_partial.o（勿用 phase1 stub，
# 否则 xlang_asm 缩至 ~2.7MB 且 pipeline -o 失效）。无 partial 时脚本退出 1，保留现有 xlang_asm。
#
# 用法（Linux x86_64 / Docker）：
#   cd compiler && ./scripts/relink_xlang_asm_link_abi_only.sh
#
# 成功后再验：XLANG_LINK_XLANG=./xlang_asm ../tests/run-net.sh（应无需 gcc 回退）

set -e
cd "$(dirname "$0")/.."

PARTIAL="build_asm/seed_host/asm_backend_partial.o"
PRE="xlang_asm.pre_link_abi_relink"

if [ ! -f "$PARTIAL" ]; then
  echo "relink_xlang_asm_link_abi_only: missing $PARTIAL" >&2
  echo "  run build_seed_asm_host or copy real partial; phase1 stub breaks -o (see 自举进度 #57)" >&2
  exit 1
fi

# 拒绝 phase1 stub（~3.6KB）误当 production partial
sz=$(wc -c <"$PARTIAL" | tr -d ' ')
if [ "$sz" -lt 8192 ] 2>/dev/null; then
  echo "relink_xlang_asm_link_abi_only: $PARTIAL too small (${sz}B); likely phase1 stub" >&2
  exit 1
fi

if [ ! -x ./xlang_asm ]; then
  echo "relink_xlang_asm_link_abi_only: need ./xlang_asm" >&2
  exit 1
fi

cp -f ./xlang_asm "$PRE"
echo "relink_xlang_asm_link_abi_only: backup -> $PRE ($(wc -c <"$PRE" | tr -d ' ')B)"

touch seeds/runtime_link_abi.from_x.c seeds/runtime_asm_io_stubs.from_x.c
make -s src/runtime_link_abi.o runtime_asm_io_stubs.o

export XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1
export XLANG_ASM_BSTRICT_RELINK_ONLY=1
export XLANG_ASM_SKIP_STRICT_SMOKE=1
export XLANG_ASM_SKIP_MAIN_O_REBUILD=1
export XLANG_ASM_SKIP_WPO_DOGFOOD=1
export XLANG_ASM_SKIP_ENTRY_SMOKE=1
export XLANG=./xlang_asm

if ! ./scripts/build_xlang_asm.sh; then
  echo "relink_xlang_asm_link_abi_only: relink failed; restore $PRE" >&2
  cp -f "$PRE" ./xlang_asm
  exit 1
fi

new_sz=$(wc -c <./xlang_asm | tr -d ' ')
old_sz=$(wc -c <"$PRE" | tr -d ' ')
# 体积骤降说明链入了 stub backend，回滚
if [ "$new_sz" -lt $((old_sz * 8 / 10)) ] 2>/dev/null; then
  echo "relink_xlang_asm_link_abi_only: xlang_asm shrunk ${old_sz}B -> ${new_sz}B; restore backup" >&2
  cp -f "$PRE" ./xlang_asm
  exit 1
fi

echo "relink_xlang_asm_link_abi_only OK (xlang_asm ${new_sz}B; was ${old_sz}B)"
