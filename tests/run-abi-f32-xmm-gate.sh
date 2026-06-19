#!/usr/bin/env bash
# SysV f32 xmm 实/形参 ABI 门禁（默认开启；SHUX_ABI_F32_XMM=0 时 SKIP legacy）。
# 用法：
#   SHUX=./compiler/shux_asm ./tests/run-abi-f32-xmm-gate.sh
#   SHUX_ABI_F32_XMM=0 …  # SKIP
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"

SHUX_BIN="${SHUX:-./compiler/shux_asm}"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"

echo "=== ABI f32 xmm: SysV xmm0–xmm7 + mixed gp/xmm call smoke ==="

if [ "${SHUX_ABI_F32_XMM:-1}" = "0" ]; then
  echo "abi-f32-xmm SKIP (SHUX_ABI_F32_XMM=0 legacy path)"
  exit 0
fi

if ! dod_native_exe "$SHUX_BIN"; then
  echo "abi-f32-xmm SKIP (no native shux/shux_asm)"
  exit 0
fi

# 编译并运行单个 smoke；期望 exit=$3。
abi_f32_xmm_run_smoke() {
  local src="$1"
  local tag="$2"
  local want_rc="$3"
  local obj="/tmp/shux_abi_f32_xmm_${tag}.o"
  local bin="/tmp/shux_abi_f32_xmm_${tag}"
  local rc=0

  rm -f "$obj" "$bin"
  if ! SHUX="$SHUX_BIN" "$SHUX_BIN" "$src" -o "$bin" 2>/dev/null; then
    if ! SHUX="$SHUX_BIN" "$SHUX_BIN" "$src" -o "$obj"; then
      echo "abi-f32-xmm FAIL: compile $src" >&2
      exit 1
    fi
    if [ -f "$CRT0" ] && command -v ld >/dev/null 2>&1; then
      ld -o "$bin" "$obj" "$CRT0" 2>/dev/null || true
    fi
  fi
  if [ ! -x "$bin" ]; then
    echo "abi-f32-xmm FAIL: no runnable binary for $src" >&2
    exit 1
  fi
  "$bin" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -ne "$want_rc" ]; then
    echo "abi-f32-xmm FAIL: $tag expected exit $want_rc, got $rc" >&2
    exit 1
  fi
  echo "abi-f32-xmm: ${tag} exit=${want_rc} OK"
}

abi_f32_xmm_run_smoke "tests/abi/f32_call_xmm_smoke.sx" "pure_f32" 6
abi_f32_xmm_run_smoke "tests/abi/f32_xmm_mixed_call_smoke.sx" "mixed_ptr_f32" 6
abi_f32_xmm_run_smoke "tests/abi/f32_xmm_mixed_field_read_smoke.sx" "mixed_field_read" 6
abi_f32_xmm_run_smoke "tests/abi/f32_tri_field_read_smoke.sx" "tri_field_read" 6

if command -v objdump >/dev/null 2>&1; then
  for tag in mixed_ptr_f32 mixed_field_read; do
    DIS="$(objdump -d "/tmp/shux_abi_f32_xmm_${tag}" 2>/dev/null || true)"
    if echo "$DIS" | grep -qE 'movd.*xmm'; then
      echo "abi-f32-xmm: ${tag} disasm movd xmm present"
    else
      echo "abi-f32-xmm FAIL: ${tag} disasm missing movd xmm" >&2
      exit 1
    fi
    if echo "$DIS" | grep -q 'cvtsd2ss'; then
      echo "abi-f32-xmm FAIL: ${tag} disasm still has cvtsd2ss (legacy widen under SHUX_ABI_F32_XMM=1)" >&2
      exit 1
    fi
  done
fi

# CLI -legacy-f32-abi 须等价 SHUX_ABI_F32_XMM=0（功能仍 exit=6；disasm 含 cvtsd2ss）。
echo "=== ABI f32 xmm: CLI -legacy-f32-abi ==="
CLI_BIN="/tmp/shux_abi_f32_xmm_cli_legacy"
CLI_OBJ="/tmp/shux_abi_f32_xmm_cli_legacy.o"
rm -f "$CLI_BIN" "$CLI_OBJ"
if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -backend asm -L . -legacy-f32-abi tests/abi/f32_call_xmm_smoke.sx -o "$CLI_BIN" 2>/dev/null; then
  if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -backend asm -L . -legacy-f32-abi tests/abi/f32_call_xmm_smoke.sx -o "$CLI_OBJ"; then
    echo "abi-f32-xmm FAIL: compile with -legacy-f32-abi" >&2
    exit 1
  fi
  if [ -f "$CRT0" ] && command -v ld >/dev/null 2>&1; then
    ld -o "$CLI_BIN" "$CLI_OBJ" "$CRT0" 2>/dev/null || true
  fi
fi
if [ ! -x "$CLI_BIN" ]; then
  echo "abi-f32-xmm FAIL: no runnable binary for CLI -legacy-f32-abi" >&2
  exit 1
fi
CLI_RC=0
"$CLI_BIN" >/dev/null 2>&1 || CLI_RC=$?
if [ "$CLI_RC" -ne 6 ]; then
  echo "abi-f32-xmm FAIL: CLI -legacy-f32-abi expected exit 6, got $CLI_RC" >&2
  exit 1
fi
echo "abi-f32-xmm: CLI -legacy-f32-abi exit=6 OK"
if command -v objdump >/dev/null 2>&1; then
  CLI_DIS="$(objdump -d "$CLI_BIN" 2>/dev/null || true)"
  if echo "$CLI_DIS" | grep -q 'cvtsd2ss'; then
    echo "abi-f32-xmm: CLI -legacy-f32-abi disasm cvtsd2ss present"
  else
    echo "abi-f32-xmm FAIL: CLI -legacy-f32-abi disasm missing cvtsd2ss" >&2
    exit 1
  fi
fi

echo "abi-f32-xmm gate OK"
