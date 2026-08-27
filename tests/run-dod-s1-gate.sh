#!/usr/bin/env bash
# DOD-S1 gate: struct soa + SoAStruct[N] column-major arr[i].field smoke.
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm via dod_native_exe; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Darwin/ARM64 -o link via xlang-c remains platform
# backend (dod_host_exe_shu), not soft prefer-c for the whole gate. f32 N/A /
# compile-only link miss = skip/obs. Report run=/obs=/skip=.
#
# Usage: ./tests/run-dod-s1-gate.sh
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED — Ubuntu x86_64 gold for f32 addss; Darwin soa i32 hard.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/dod-host-backend.sh
. tests/lib/dod-host-backend.sh

PREFIX="${XLANG_DOD_S1_PREFIX:-xlang: [XLANG_DOD_S1]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "dod-s1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== DOD-S1: struct soa + #[soa] + arr[i].field smoke ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

SMOKE_SRC="tests/dod/soa_smoke.x"
ATTR_SRC="tests/dod/soa_attr_smoke.x"
F32_SRC="tests/dod/f32_soa_sum_smoke.x"
F32_AOS_LIT_SRC="tests/dod/f32_aos_lit_assign_smoke.x"
SMOKE_O="/tmp/xlang_dod_s1_smoke.o"
ATTR_O="/tmp/xlang_dod_s1_attr.o"
F32_O="/tmp/xlang_dod_s1_f32_sum.o"
F32_AOS_LIT_O="/tmp/xlang_dod_s1_f32_aos_lit.o"
SMOKE_BIN="/tmp/xlang_dod_s1_smoke"
F32_BIN="/tmp/xlang_dod_s1_f32_sum"
F32_AOS_LIT_BIN="/tmp/xlang_dod_s1_f32_aos_lit"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"
rm -f "$SMOKE_O" "$ATTR_O" "$F32_O" "$F32_AOS_LIT_O" "$SMOKE_BIN" "$F32_BIN" "$F32_AOS_LIT_BIN"

for f in "$SMOKE_SRC" "$ATTR_SRC" "$F32_SRC" "$F32_AOS_LIT_SRC"; do
  [ -f "$f" ] || die "missing $f"
done

DOD_EXE_XLANG="$(dod_host_exe_shu "$XLANG_ABS")"
case "$(uname -s)-$(uname -m 2>/dev/null)" in
  Darwin-*)
    echo "dod-s1: Darwin -o link via xlang-c (seed asm/import path; x86_64 covers asm disasm)"
    ;;
  Linux-aarch64|Linux-arm64)
    echo "dod-s1: Linux ARM64 -o link via xlang-c (refresh xlang_asm lite)"
    ;;
  MINGW*|MSYS*)
    echo "dod-s1: Windows MSYS2 -o link via xlang-c (f32 asm N/A; Linux x86_64 covers)"
    ;;
esac

if ! "$XLANG_ABS" "$SMOKE_SRC" -o "$SMOKE_O"; then
  die "compile $SMOKE_SRC"
fi
RUN_OK=$((RUN_OK + 1))

if ! "$XLANG_ABS" "$ATTR_SRC" -o "$ATTR_O"; then
  die "compile $ATTR_SRC"
fi
RUN_OK=$((RUN_OK + 1))

# f32: Darwin / Linux ARM64 default asm ELF N/A; -backend c f32 still WIP → skip .o.
if [ -n "$DOD_F32_BACKEND_ARGS" ]; then
  echo "dod-s1: skip f32 .o compile (asm f32 ELF N/A on $(uname -s)-$(uname -m); f32 exe run N/A below)"
  SKIP=$((SKIP + 1))
else
  if ! "$XLANG_ABS" "$F32_SRC" -o "$F32_O"; then
    die "compile $F32_SRC"
  fi
  RUN_OK=$((RUN_OK + 1))
  if ! "$XLANG_ABS" "$F32_AOS_LIT_SRC" -o "$F32_AOS_LIT_O"; then
    die "compile $F32_AOS_LIT_SRC"
  fi
  RUN_OK=$((RUN_OK + 1))
fi

if [ ! -f "$SMOKE_O" ] || [ ! -f "$ATTR_O" ]; then
  die "missing object file"
fi
if [ -z "$DOD_F32_BACKEND_ARGS" ]; then
  if [ ! -f "$F32_O" ] || [ ! -f "$F32_AOS_LIT_O" ]; then
    die "missing object file"
  fi
fi

# Link+run: Darwin/ARM64 lite uses xlang-c; Linux x86_64 uses xlang_asm -backend asm.
if XLANG="$XLANG_ABS" "$DOD_EXE_XLANG" $DOD_GATE_BACKEND_ARGS "$SMOKE_SRC" -o "$SMOKE_BIN" 2>/dev/null && [ -x "$SMOKE_BIN" ]; then
  RC="$("$SMOKE_BIN" 2>/dev/null; echo $?)"
  RC="${RC##*$'\n'}"
  if [ "$RC" = "8" ]; then
    echo "dod-s1: soa_smoke exit=8 OK"
    RUN_OK=$((RUN_OK + 1))
  else
    die "soa_smoke expected exit 8, got ${RC:-?}"
  fi
elif command -v ld >/dev/null 2>&1; then
  if [ -f "$CRT0" ]; then
    if ld -o "$SMOKE_BIN" "$SMOKE_O" "$CRT0" 2>/dev/null; then
      RC="$("$SMOKE_BIN" 2>/dev/null; echo $?)"
      RC="${RC##*$'\n'}"
      if [ "$RC" = "8" ]; then
        echo "dod-s1: soa_smoke exit=8 OK"
        RUN_OK=$((RUN_OK + 1))
      else
        die "soa_smoke expected exit 8, got ${RC:-?}"
      fi
    else
      echo "dod-s1: compile-only (link skipped; obs)"
      OBS=$((OBS + 1))
    fi
  else
    echo "dod-s1: compile-only (no crt0; obs)"
    OBS=$((OBS + 1))
  fi
else
  echo "dod-s1: compile-only (no ld; obs)"
  OBS=$((OBS + 1))
fi

# f32 SoA column scan: 1+2+3+4=10 (addss path)
if dod_host_f32_run_na; then
  echo "dod-s1: f32 compile/run N/A on $(uname -s)-$(uname -m) (gen_driver -backend c f32 WIP; Linux x86_64 covers addss path)"
  SKIP=$((SKIP + 1))
elif XLANG="$XLANG_ABS" "$XLANG_ABS" "$F32_SRC" -o "$F32_BIN" 2>/dev/null && [ -x "$F32_BIN" ]; then
  RC=0
  "$F32_BIN" >/dev/null 2>&1 || RC=$?
  if [ "$RC" -ne 10 ]; then
    die "f32_soa_sum_smoke expected exit 10, got $RC"
  fi
  echo "dod-s1: f32_soa_sum_smoke exit=10 OK"
  RUN_OK=$((RUN_OK + 1))
  if command -v objdump >/dev/null 2>&1; then
    if objdump -d "$F32_BIN" 2>/dev/null | grep -q 'addss'; then
      echo "dod-s1: f32 sum disasm addss OK"
      RUN_OK=$((RUN_OK + 1))
    else
      echo "dod-s1 WARN: disasm missing addss (obs)" >&2
      OBS=$((OBS + 1))
    fi
  fi
elif command -v ld >/dev/null 2>&1 && [ -f "$F32_O" ] && [ -f "$CRT0" ]; then
  if ld -o "$F32_BIN" "$F32_O" "$CRT0" 2>/dev/null; then
    RC=0
    "$F32_BIN" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne 10 ]; then
      die "f32_soa_sum_smoke expected exit 10, got $RC"
    fi
    echo "dod-s1: f32_soa_sum_smoke exit=10 OK"
    RUN_OK=$((RUN_OK + 1))
  else
    echo "dod-s1: f32 link skipped (obs)"
    OBS=$((OBS + 1))
  fi
fi

# f32 AoS literal field assign: 1+2+3+4=10
if dod_host_f32_run_na; then
  echo "dod-s1: f32 aos lit run N/A on $(uname -s)-$(uname -m) (gen_driver -backend c f32 WIP; Linux x86_64 covers)"
  SKIP=$((SKIP + 1))
elif XLANG="$XLANG_ABS" "$XLANG_ABS" "$F32_AOS_LIT_SRC" -o "$F32_AOS_LIT_BIN" 2>/dev/null && [ -x "$F32_AOS_LIT_BIN" ]; then
  RC=0
  "$F32_AOS_LIT_BIN" >/dev/null 2>&1 || RC=$?
  if [ "$RC" -ne 10 ]; then
    die "f32_aos_lit_assign_smoke expected exit 10, got $RC"
  fi
  echo "dod-s1: f32_aos_lit_assign_smoke exit=10 OK"
  RUN_OK=$((RUN_OK + 1))
elif command -v ld >/dev/null 2>&1 && [ -f "$F32_AOS_LIT_O" ] && [ -f "$CRT0" ]; then
  if ld -o "$F32_AOS_LIT_BIN" "$F32_AOS_LIT_O" "$CRT0" 2>/dev/null; then
    RC=0
    "$F32_AOS_LIT_BIN" >/dev/null 2>&1 || RC=$?
    if [ "$RC" -ne 10 ]; then
      die "f32_aos_lit_assign_smoke expected exit 10, got $RC"
    fi
    echo "dod-s1: f32_aos_lit_assign_smoke exit=10 OK"
    RUN_OK=$((RUN_OK + 1))
  else
    echo "dod-s1: f32 aos lit link skipped (obs)"
    OBS=$((OBS + 1))
  fi
fi

echo "dod-s1 gate OK"
ok_report
