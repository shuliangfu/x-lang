#!/usr/bin/env bash
# typeck_wpo opt-in 链入后 struct_mk 须通过。
# 自举 typeck.o（>8KiB）时链整颗 typeck.o（勿链 wpo partial — 会带入 WPO 内联 check_block 局部符号）；
# 未自举时链 typeck_wpo layout helpers + typeck.o partial。
# 用法：./tests/run-typeck-wpo-optin-smoke.sh
# 前置：compiler/shux_asm 已 bootstrap。
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "typeck-wpo-optin: N/A on Darwin"
  exit 0
fi

if [ ! -x compiler/shux_asm ]; then
  echo "typeck-wpo-optin: SKIP (no shux_asm)"
  exit 0
fi

chmod +x compiler/scripts/build_shux_asm.sh
SMK="tests/boundary/struct_mk_let_inline.sx"

# 二次 build 触发 typeck_wpo opt-in 链（与 gen1 二次 build 同路径）。
(
  cd compiler
  rm -f build_asm/typeck_strict_link_partial.o build_asm/typeck_strict_link_export.txt \
    build_asm/typeck_wpo_helpers_partial.o build_asm/typeck_wpo_helpers_export.txt
  SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=./shux ./scripts/build_shux_asm.sh > /tmp/typeck_wpo_smoke.log 2>&1
)

if ! grep -qE 'typeck_wpo_helpers|whole typeck.o \(selfhosted|seed typeck.o' /tmp/typeck_wpo_smoke.log; then
  echo "typeck-wpo-optin FAIL: log missing typeck_wpo opt-in link path" >&2
  exit 1
fi

if ! grep -q 'STRICT_LINK_BUILD_ASM_TYPECK_WPO=1' /tmp/typeck_wpo_smoke.log; then
  echo "typeck-wpo-optin FAIL: log missing STRICT_LINK_BUILD_ASM_TYPECK_WPO=1" >&2
  exit 1
fi

RC=0
compiler/shux_asm "$SMK" -o /tmp/typeck_wpo_smki 2>/dev/null || RC=$?
if [ "$RC" -ne 0 ]; then
  echo "typeck-wpo-optin FAIL: struct_mk compile rc=$RC" >&2
  exit 1
fi
/tmp/typeck_wpo_smki >/dev/null 2>&1 || RC=$?
if [ "$RC" -ne 10 ]; then
  echo "typeck-wpo-optin FAIL: struct_mk run rc=$RC (expected 10)" >&2
  exit 1
fi

if nm compiler/shux_asm 2>/dev/null | grep -qE ' T check_block$'; then
  cb_src=$(nm compiler/shux_asm 2>/dev/null | grep ' T check_block$' | awk '{print $1}')
  echo "typeck-wpo-optin OK (struct_mk 10; check_block T @ $cb_src from typeck.o partial)"
else
  echo "typeck-wpo-optin OK (struct_mk 10)"
fi
