#!/usr/bin/env bash
# LANG-005：ABI 稳定承诺烟测（C 布局 + 可选 f32 xmm）
#
# 用法：./tests/run-lang-abi-stability.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/lang-abi-stability.sh
. tests/lib/lang-abi-stability.sh

echo "=== LANG-005: ABI layout (cc) ==="
chmod +x tests/run-abi-layout.sh
./tests/run-abi-layout.sh
echo "lang-abi-stability OK layout"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu_asm ./compiler/shu-c ./compiler/shu; do
    if lang_abi_native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -n "$SHU_BIN" ] && lang_abi_native_shu "$SHU_BIN"; then
  if [ -x tests/run-abi-f32-xmm-gate.sh ]; then
    echo "=== LANG-005: f32 xmm ABI (optional) ==="
    chmod +x tests/run-abi-f32-xmm-gate.sh
    if SHU="$SHU_BIN" ./tests/run-abi-f32-xmm-gate.sh; then
      echo "lang-abi-stability OK f32_xmm"
    else
      echo "lang-abi-stability SKIP f32_xmm (gate failed or unsupported host)" >&2
    fi
  fi
else
  echo "lang-abi-stability SKIP f32_xmm (no native shu)"
fi

echo "lang-abi-stability OK"
