#!/usr/bin/env bash
# A-09 / A-14：Stage2 二进制 SHA256 金标准门禁
#
# 比对两代 bootstrap 编译器（stage1 vs stage2）的可执行文件哈希。
# 与 verify-selfhost-stage2-bstrict.sh 行为 parity 正交：行为一致 ≠ 二进制一致。
#
# 用法（仓库根）：
#   ./tests/run-stage2-hash-gate.sh compiler/shux_asm_stage1 compiler/shux_asm2
#   SHUX_STAGE2_HASH_STRICT=1 ./tests/run-stage2-hash-gate.sh   # 默认路径见下
#
# 环境：
#   SHUX_STAGE2_HASH_SKIP=1      — 完全跳过（非 Linux / 本地调试）
#   SHUX_STAGE2_HASH_STRICT=1    — 哈希不等时 exit 1（CI 在哈希稳定后开启）
#   默认（STRICT 未设）：不等时 WARN 但 exit 0（track-only，待 A-09 全绿后改 STRICT）

set -e
cd "$(dirname "$0")/.."

STAGE1="${1:-compiler/shux_asm_stage1}"
STAGE2="${2:-compiler/shux_asm2}"

if [ "${SHUX_STAGE2_HASH_SKIP:-0}" = "1" ]; then
  echo "stage2-hash-gate: SKIP (SHUX_STAGE2_HASH_SKIP=1)"
  exit 0
fi

if [ ! -f "$STAGE1" ] || [ ! -f "$STAGE2" ]; then
  echo "stage2-hash-gate FAIL: missing binary (stage1=$STAGE1 stage2=$STAGE2)" >&2
  exit 1
fi

# 计算文件 SHA256（Linux sha256sum / macOS shasum 兼容）。
stage2_hash_file() {
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    echo "stage2-hash-gate FAIL: no sha256sum or shasum" >&2
    exit 1
  fi
}

H1="$(stage2_hash_file "$STAGE1")"
H2="$(stage2_hash_file "$STAGE2")"
SZ1="$(wc -c <"$STAGE1" | tr -d ' ')"
SZ2="$(wc -c <"$STAGE2" | tr -d ' ')"

echo "stage2-hash-gate: stage1 $STAGE1"
echo "  sha256=$H1  bytes=$SZ1"
echo "stage2-hash-gate: stage2 $STAGE2"
echo "  sha256=$H2  bytes=$SZ2"

if [ "$H1" = "$H2" ]; then
  echo "stage2-hash-gate OK (SHA256 match — 黄金自举金标准)"
  exit 0
fi

echo "stage2-hash-gate: MISMATCH (stage1 != stage2 SHA256)" >&2
if [ "${SHUX_STAGE2_HASH_STRICT:-0}" = "1" ]; then
  echo "stage2-hash-gate FAIL (SHUX_STAGE2_HASH_STRICT=1)" >&2
  exit 1
fi

echo "stage2-hash-gate WARN (track-only; set SHUX_STAGE2_HASH_STRICT=1 to hard-fail)"
exit 0
