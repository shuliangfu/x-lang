#!/usr/bin/env bash
# M4：Linux 上验收 crt0 + full_asm（B-partial），与 Darwin 上 asm_only_strict（B-strict）分轨。
# 用法（仓库根）：./tests/run-bootstrap-bstrict-linux.sh
# 非 Linux 宿主：打印 skip 并 exit 0（macOS CI 不跑本脚本）。

set -e
cd "$(dirname "$0")/.."

if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "run-bootstrap-bstrict-linux: skip (host is not Linux; crt0 仅 glibc Linux x86_64)"
  exit 0
fi

if [ -f /etc/alpine-release ]; then
  echo "run-bootstrap-bstrict-linux: Alpine musl — crt0 + full_asm（与 glibc Linux 同路径）"
fi

ulimit -s 16384 2>/dev/null || true

if [ ! -x compiler/shu ]; then
  echo "run-bootstrap-bstrict-linux: need seed shu (make -C compiler OPT=1 all)" >&2
  exit 127
fi

echo "run-bootstrap-bstrict-linux: make bootstrap-driver-crt0 ..."
make -C compiler bootstrap-driver-crt0

if [ ! -x compiler/shu_asm ]; then
  echo "run-bootstrap-bstrict-linux: compiler/shu_asm missing after crt0 build" >&2
  exit 1
fi

# full_asm 拓扑标签：build_asm 全域 __text 非空
if [ -f compiler/build_asm/.asm_text_quality ]; then
  Q=$(cat compiler/build_asm/.asm_text_quality)
  if [ "$Q" != "1" ]; then
    echo "run-bootstrap-bstrict-linux: build_asm/.asm_text_quality=$Q (expected 1 for full_asm)" >&2
    exit 1
  fi
  echo "run-bootstrap-bstrict-linux: full_asm quality OK (.asm_text_quality=1)"
fi

# crt0 产物烟测：return-value（无 SU driver，能力子集）
echo "run-bootstrap-bstrict-linux: smoke return-value via crt0 shu_asm ..."
if ! compiler/shu_asm tests/return-value/main.su -o /tmp/shu_crt0_rv 2>/dev/null; then
  echo "run-bootstrap-bstrict-linux: crt0 shu_asm compile return-value failed (expected on some hosts)" >&2
  exit 1
fi
EX=0
/tmp/shu_crt0_rv >/dev/null 2>&1 || EX=$?
if [ "$EX" -ne 42 ]; then
  echo "run-bootstrap-bstrict-linux: expected exit 42, got $EX" >&2
  exit 1
fi

echo "run-bootstrap-bstrict-linux OK (crt0 + full_asm + return-value smoke)"
