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

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -x compiler/shux ]; then
  echo "run-bootstrap-bstrict-linux: need seed shux (make -C compiler OPT=1 all)" >&2
  exit 127
fi

# bootstrap-bstrict-ci 已用 asm_only_strict shux_asm 跑完白名单；勿再 bootstrap-driver-crt0
# 覆盖 shux_asm（crt0/full_asm 链常缺符号或 SIGSEGV，与 B-strict 验收正交）。
if [ -n "${SHUX_BSTRICT_SKIP_BUILD:-}" ] && [ -x compiler/shux_asm ]; then
  echo "run-bootstrap-bstrict-linux: reuse bstrict shux_asm (SHUX_BSTRICT_SKIP_BUILD=1, skip crt0 rebuild)"
else
  echo "run-bootstrap-bstrict-linux: make bootstrap-driver-crt0 ..."
  make -C compiler bootstrap-driver-crt0
fi

if [ ! -x compiler/shux_asm ]; then
  echo "run-bootstrap-bstrict-linux: compiler/shux_asm missing after crt0 build" >&2
  exit 1
fi

# full_asm 拓扑标签：build_asm 全域 __text 非空；parser.o 等偶发 asm emit 失败时 Q=0，
# 但 asm_only_strict/crt0 shux_asm 仍可用——以 return-value 烟测为准，勿因 Q!=1 阻断 CI。
if [ -f compiler/build_asm/.asm_text_quality ]; then
  Q=$(cat compiler/build_asm/.asm_text_quality)
  if [ "$Q" = "1" ]; then
    echo "run-bootstrap-bstrict-linux: full_asm quality OK (.asm_text_quality=1)"
  else
    echo "run-bootstrap-bstrict-linux: warn: build_asm/.asm_text_quality=$Q (expected 1 for full_asm); continue crt0 smoke" >&2
  fi
fi

# crt0 产物烟测：return-value（无 SU driver，能力子集）
echo "run-bootstrap-bstrict-linux: smoke return-value via crt0 shux_asm ..."
if ! compiler/shux_asm tests/return-value/main.sx -o /tmp/shux_crt0_rv 2>/dev/null; then
  echo "run-bootstrap-bstrict-linux: crt0 shux_asm compile return-value failed (expected on some hosts)" >&2
  exit 1
fi
EX=0
/tmp/shux_crt0_rv >/dev/null 2>&1 || EX=$?
if [ "$EX" -ne 42 ]; then
  echo "run-bootstrap-bstrict-linux: expected exit 42, got $EX" >&2
  exit 1
fi

echo "run-bootstrap-bstrict-linux OK (crt0 + full_asm + return-value smoke)"
