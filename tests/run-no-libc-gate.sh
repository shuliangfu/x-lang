#!/usr/bin/env bash
# F-no-libc 聚合门禁：NL-01 准备 + NL-02～07 子 gate（Linux x86_64 硬验收）。
#
# 用法：./tests/run-no-libc-gate.sh
# 环境：
#   SHUX_NOLIBC_FAIL=1                  — 失败时硬退出
#   SHUX_NOLIBC_MANIFEST_ONLY=1         — 仅 NL-01 manifest（同 N01_MANIFEST_ONLY）
#   SHUX_NOLIBC_N01_MANIFEST_ONLY=1     — 仅 NL-01
#   SHUX=./compiler/shux                — freestanding 编译器
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_FAIL:-0}
N01_GATE="tests/run-nolibc-n01-preparation-gate.sh"
FREESTANDING_HELLO="tests/run-freestanding-hello.sh"

die() {
  echo "nolibc gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

run_sub() {
  local script="$1"
  local env_var="$2"
  chmod +x "$script"
  if ! env "${env_var}=${FAIL}" "$script"; then
    die "sub-gate failed: $script"
  fi
}

echo "=== F-no-libc: aggregate gate (NL-01～NL-07) ==="

# ── NL-01：准备层（manifest + 基础设施）──
echo "=== NL-01: delegate run-nolibc-n01-preparation-gate ==="
chmod +x "$N01_GATE" tests/lib/nolibc-n01-manifest.sh tests/lib/no-libc-link-audit.sh
SHUX_NOLIBC_N01_FAIL="$FAIL" ./tests/run-nolibc-n01-preparation-gate.sh || die "NL-01 preparation failed"

if [ "${SHUX_NOLIBC_MANIFEST_ONLY:-0}" = "1" ] || [ "${SHUX_NOLIBC_N01_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc gate OK (NL-01 manifest only)"
  exit 0
fi

# ── NL-06：freestanding std track（任意平台 manifest + F-01）──
echo "=== NL-06: delegate run-nolibc-n06-std-track-gate (freestanding std track) ==="
chmod +x tests/run-nolibc-n06-std-track-gate.sh tests/lib/nolibc-n06-std-track.sh
run_sub tests/run-nolibc-n06-std-track-gate.sh SHUX_NOLIBC_N06_FAIL

# ── NL-07：编译器 bootstrap 去 libc 准备（任意平台 manifest + lc track）──
echo "=== NL-07: delegate run-nolibc-n07-bootstrap-prep-gate (bootstrap no-libc prep) ==="
chmod +x tests/run-nolibc-n07-bootstrap-prep-gate.sh tests/lib/nolibc-n07-bootstrap-audit.sh
run_sub tests/run-nolibc-n07-bootstrap-prep-gate.sh SHUX_NOLIBC_N07_FAIL

# ── NL-07 v2：bootstrap nostdlib 首试 prep（任意平台 manifest + 桩编译）──
echo "=== NL-07 v2: delegate run-nolibc-n07-v2-prep-gate ==="
chmod +x tests/run-nolibc-n07-v2-prep-gate.sh
run_sub tests/run-nolibc-n07-v2-prep-gate.sh SHUX_NOLIBC_N07_V2_FAIL

# ── NL-07 v3：bootstrap nostdlib 链入烟测（Linux x86_64 硬绿；其它 SKIP）──
echo "=== NL-07 v3: delegate run-nolibc-n07-v3-link-gate ==="
chmod +x tests/run-nolibc-n07-v3-link-gate.sh tests/lib/nolibc-n07-link-smoke.sh
run_sub tests/run-nolibc-n07-v3-link-gate.sh SHUX_NOLIBC_N07_V3_FAIL

# ── NL-07 v4：bootstrap nostdlib 全链试跑（track；TRY_BUILD=1 硬试跑）──
echo "=== NL-07 v4: delegate run-nolibc-n07-v4-build-gate ==="
chmod +x tests/run-nolibc-n07-v4-build-gate.sh
run_sub tests/run-nolibc-n07-v4-build-gate.sh SHUX_NOLIBC_N07_V4_FAIL

# ── NL-07 v5：Linux x86_64 bootstrap 默认 nostdlib 硬绿（manifest + TRY_BUILD）──
echo "=== NL-07 v5: delegate run-nolibc-n07-v5-gate ==="
chmod +x tests/run-nolibc-n07-v5-gate.sh
run_sub tests/run-nolibc-n07-v5-gate.sh SHUX_NOLIBC_N07_V5_FAIL

# ── Linux x86_64：NL-02～05 运行时烟测 ──
if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc gate OK (NL-01 + NL-06 + NL-07 track; SKIP NL-02～05 runtime — need Linux x86_64)"
  exit 0
fi

export SHUX="${SHUX:-./compiler/shux}"
if [ ! -x "$SHUX" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi

echo "=== S4: delegate run-freestanding-hello ==="
chmod +x "$FREESTANDING_HELLO"
if ! "$FREESTANDING_HELLO"; then
  die "freestanding hello sub-gate failed"
fi

if [ -x tests/run-std-sys-gate.sh ]; then
  echo "=== BOOT-029: delegate run-std-sys-gate ==="
  run_sub tests/run-std-sys-gate.sh SHUX_STD_SYS_FAIL
fi

echo "=== NL-02: delegate run-no-libc-socket-gate ==="
run_sub tests/run-no-libc-socket-gate.sh SHUX_NOLIBC_SOCKET_FAIL

echo "=== NL-03: delegate run-no-libc-heap-gate ==="
run_sub tests/run-no-libc-heap-gate.sh SHUX_NOLIBC_HEAP_FAIL

echo "=== NL-04: delegate run-no-libc-fs-gate ==="
run_sub tests/run-no-libc-fs-gate.sh SHUX_NOLIBC_FS_FAIL

echo "=== NL-05: delegate run-no-libc-link-gate (runtime audit; smokes skipped) ==="
SHUX_NOLIBC_LINK_SKIP_SMOKE=1 run_sub tests/run-no-libc-link-gate.sh SHUX_NOLIBC_LINK_FAIL

echo "nolibc gate OK (NL-01～NL-07 user freestanding; bootstrap nostdlib v2+v3 track)"
