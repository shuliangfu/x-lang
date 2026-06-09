#!/usr/bin/env bash
# DOD-S1 门禁：struct soa + [N]SoAStruct 列主序 arr[i].field smoke。
# 用法：
#   ./tests/run-dod-s1-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-dod-s1-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/dod-host-backend.sh
source "$(dirname "$0")/lib/dod-host-backend.sh"

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
esac

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu_asm ./compiler/shu; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if dod_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

echo "=== DOD-S1: struct soa + #[soa] + arr[i].field smoke ==="

SMOKE_SRC="tests/dod/soa_smoke.su"
ATTR_SRC="tests/dod/soa_attr_smoke.su"
F32_SRC="tests/dod/f32_soa_sum_smoke.su"
F32_AOS_LIT_SRC="tests/dod/f32_aos_lit_assign_smoke.su"
SMOKE_O="/tmp/shu_dod_s1_smoke.o"
ATTR_O="/tmp/shu_dod_s1_attr.o"
F32_O="/tmp/shu_dod_s1_f32_sum.o"
F32_AOS_LIT_O="/tmp/shu_dod_s1_f32_aos_lit.o"
SMOKE_BIN="/tmp/shu_dod_s1_smoke"
F32_BIN="/tmp/shu_dod_s1_f32_sum"
F32_AOS_LIT_BIN="/tmp/shu_dod_s1_f32_aos_lit"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
rm -f "$SMOKE_O" "$ATTR_O" "$F32_O" "$F32_AOS_LIT_O" "$SMOKE_BIN" "$F32_BIN" "$F32_AOS_LIT_BIN"

if [ -z "$SHU_ABS" ] || ! dod_native_exe "$SHU_ABS"; then
  echo "dod-s1 gate SKIP (no native shu/shu_asm; rebuild on Linux for run test)"
  exit 0
fi

DOD_EXE_SHU="$(dod_host_exe_shu "$SHU_ABS")"
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*)
    echo "dod-s1: Darwin -o link via shu-c (seed asm/import path; x86_64 covers asm disasm)"
    ;;
  Linux-aarch64|Linux-arm64)
    echo "dod-s1: Linux ARM64 -o link via shu-c (refresh shu_asm lite)"
    ;;
esac

if ! SHU="$SHU_ABS" "$SHU_ABS" "$SMOKE_SRC" -o "$SMOKE_O"; then
  echo "dod-s1 FAIL: compile $SMOKE_SRC" >&2
  exit 1
fi

if ! SHU="$SHU_ABS" "$SHU_ABS" "$ATTR_SRC" -o "$ATTR_O"; then
  echo "dod-s1 FAIL: compile $ATTR_SRC" >&2
  exit 1
fi

# f32：Darwin / Linux ARM64 上 shu_asm 默认 asm ELF 不可用；-backend c f32 仍 WIP，仅跳过 .o 烟测。
if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
  echo "dod-s1: skip f32 .o compile (asm f32 ELF N/A on $(uname -s)-$(uname -m); f32 exe run N/A below)"
else
  if ! SHU="$SHU_ABS" "$SHU_ABS" "$F32_SRC" -o "$F32_O"; then
    echo "dod-s1 FAIL: compile $F32_SRC" >&2
    exit 1
  fi

  if ! SHU="$SHU_ABS" "$SHU_ABS" "$F32_AOS_LIT_SRC" -o "$F32_AOS_LIT_O"; then
    echo "dod-s1 FAIL: compile $F32_AOS_LIT_SRC" >&2
    exit 1
  fi
fi

if [ ! -f "$SMOKE_O" ] || [ ! -f "$ATTR_O" ]; then
  echo "dod-s1 FAIL: missing object file" >&2
  exit 1
fi
if [ -z "$DOD_F32_BACKEND_ARGS" ]; then
  if [ ! -f "$F32_O" ] || [ ! -f "$F32_AOS_LIT_O" ]; then
    echo "dod-s1 FAIL: missing object file" >&2
    exit 1
  fi
fi

# 链接并运行：Darwin/ARM64 lite 用 shu-c；Linux x86_64 用 shu_asm -backend asm。
if SHU="$SHU_ABS" "$DOD_EXE_SHU" $DOD_GATE_BACKEND_ARGS "$SMOKE_SRC" -o "$SMOKE_BIN" 2>/dev/null && [ -x "$SMOKE_BIN" ]; then
  RC="$("$SMOKE_BIN" 2>/dev/null; echo $?)"
  RC="${RC##*$'\n'}"
  if [ "$RC" = "8" ]; then
    echo "dod-s1: soa_smoke exit=8 OK"
  else
    echo "dod-s1 FAIL: soa_smoke expected exit 8, got ${RC:-?}" >&2
    exit 1
  fi
elif command -v ld >/dev/null 2>&1; then
  if [ -f "$CRT0" ]; then
    if ld -o "$SMOKE_BIN" "$SMOKE_O" "$CRT0" 2>/dev/null; then
      RC="$("$SMOKE_BIN" 2>/dev/null; echo $?)"
      RC="${RC##*$'\n'}"
      if [ "$RC" = "8" ]; then
        echo "dod-s1: soa_smoke exit=8 OK"
      else
        echo "dod-s1 FAIL: soa_smoke expected exit 8, got ${RC:-?}" >&2
        exit 1
      fi
    else
      echo "dod-s1: compile-only OK (link skipped)"
    fi
  else
    echo "dod-s1: compile-only OK (no crt0)"
  fi
else
  echo "dod-s1: compile-only OK (no ld)"
fi

# f32 SoA 列扫描：1+2+3+4=10（addss 路径）
if dod_host_f32_run_na; then
  echo "dod-s1: f32 compile/run N/A on $(uname -s)-$(uname -m) (gen_driver -backend c f32 WIP; Linux x86_64 covers addss path)"
elif SHU="$SHU_ABS" "$SHU_ABS" "$F32_SRC" -o "$F32_BIN" 2>/dev/null && [ -x "$F32_BIN" ]; then
  RC=0
  "$F32_BIN" >/dev/null 2>&1 || RC=$?
  if [ "$RC" -ne 10 ]; then
    echo "dod-s1 FAIL: f32_soa_sum_smoke expected exit 10, got $RC" >&2
    exit 1
  fi
  echo "dod-s1: f32_soa_sum_smoke exit=10 OK"
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d "$F32_BIN" 2>/dev/null | grep -q 'addss'; then
      echo "dod-s1: f32 sum disasm addss OK"
    else
      echo "dod-s1 WARN: disasm missing addss (non-fatal)" >&2
    fi
  fi
elif command -v ld >/dev/null 2>&1 && [ -f "$F32_O" ] && [ -f "$CRT0" ]; then
  if ld -o "$F32_BIN" "$F32_O" "$CRT0" 2>/dev/null; then
    RC=0
    "$F32_BIN" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne 10 ]; then
      echo "dod-s1 FAIL: f32_soa_sum_smoke expected exit 10, got $RC" >&2
      exit 1
    fi
    echo "dod-s1: f32_soa_sum_smoke exit=10 OK"
  fi
fi

# f32 AoS 字面量 field assign：1+2+3+4=10（字面量写 + addss 读累加）
if dod_host_f32_run_na; then
  echo "dod-s1: f32 aos lit run N/A on $(uname -s)-$(uname -m) (gen_driver -backend c f32 WIP; Linux x86_64 covers)"
elif SHU="$SHU_ABS" "$SHU_ABS" "$F32_AOS_LIT_SRC" -o "$F32_AOS_LIT_BIN" 2>/dev/null && [ -x "$F32_AOS_LIT_BIN" ]; then
  RC=0
  "$F32_AOS_LIT_BIN" >/dev/null 2>&1 || RC=$?
  if [ "$RC" -ne 10 ]; then
    echo "dod-s1 FAIL: f32_aos_lit_assign_smoke expected exit 10, got $RC" >&2
    exit 1
  fi
  echo "dod-s1: f32_aos_lit_assign_smoke exit=10 OK"
elif command -v ld >/dev/null 2>&1 && [ -f "$F32_AOS_LIT_O" ] && [ -f "$CRT0" ]; then
  if ld -o "$F32_AOS_LIT_BIN" "$F32_AOS_LIT_O" "$CRT0" 2>/dev/null; then
    RC=0
    "$F32_AOS_LIT_BIN" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne 10 ]; then
      echo "dod-s1 FAIL: f32_aos_lit_assign_smoke expected exit 10, got $RC" >&2
      exit 1
    fi
    echo "dod-s1: f32_aos_lit_assign_smoke exit=10 OK"
  fi
fi

echo "dod-s1 gate OK"
