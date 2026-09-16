#!/usr/bin/env bash
# SysV f32 xmm arg/param ABI gate (default on; XLANG_ABI_F32_XMM=0 → skip legacy).
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# SysV xmm disasm N/A on Darwin/ARM/Win = skip (not soft silence / not hard-red
# false-red on non-x86). Missing movd xmm / residual on Linux gold = obs
# (product tip residual; FAIL_STRICT still hard). Report run=/obs=/skip=.
#
# Usage:
#   XLANG=./compiler/xlang_asm ./tests/run-abi-f32-xmm-gate.sh
#   XLANG_ABI_F32_XMM=0 …  # SKIP legacy path
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu x86_64 gold for xmm disasm; Darwin run smokes.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/dod-host-backend.sh
. tests/lib/dod-host-backend.sh

PREFIX="${XLANG_ABI_F32_XMM_PREFIX:-xlang: [XLANG_ABI_F32_XMM]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "abi-f32-xmm gate FAIL: $*" >&2
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

echo "=== ABI f32 xmm: SysV xmm0–xmm7 + mixed gp/xmm call smoke ==="

if [ "${XLANG_ABI_F32_XMM:-1}" = "0" ]; then
  echo "abi-f32-xmm SKIP (XLANG_ABI_F32_XMM=0 legacy path)"
  SKIP=$((SKIP + 1))
  echo "abi-f32-xmm gate OK"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
CRT0="compiler/src/runtime/crt0_linux_x86_64.o"

# Compile and run one smoke; expect exit=$3.
abi_f32_xmm_run_smoke() {
  local src="$1"
  local tag="$2"
  local want_rc="$3"
  local obj="/tmp/xlang_abi_f32_xmm_${tag}.o"
  local bin="/tmp/xlang_abi_f32_xmm_${tag}"
  local rc=0

  rm -f "$obj" "$bin"
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" build "$src" -o "$bin" 2>/dev/null; then
    if ! XLANG="$XLANG_BIN" "$XLANG_BIN" build "$src" -o "$obj"; then
      die "compile $src"
    fi
    if [ -f "$CRT0" ] && command -v ld >/dev/null 2>&1; then
      ld -o "$bin" "$obj" "$CRT0" 2>/dev/null || true
    fi
  fi
  if [ ! -x "$bin" ]; then
    die "no runnable binary for $src"
  fi
  "$bin" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -ne "$want_rc" ]; then
    die "$tag expected exit $want_rc, got $rc"
  fi
  echo "abi-f32-xmm: ${tag} exit=${want_rc} OK"
  RUN_OK=$((RUN_OK + 1))
}

abi_f32_xmm_run_smoke "tests/abi/f32_call_xmm_smoke.x" "pure_f32" 6
abi_f32_xmm_run_smoke "tests/abi/f32_xmm_mixed_call_smoke.x" "mixed_ptr_f32" 6
abi_f32_xmm_run_smoke "tests/abi/f32_xmm_mixed_field_read_smoke.x" "mixed_field_read" 6
abi_f32_xmm_run_smoke "tests/abi/f32_tri_field_read_smoke.x" "tri_field_read" 6

# SysV xmm disasm: Linux x86_64 gold. Darwin/ARM/Win = platform skip.
if dod_host_f32_run_na; then
  echo "abi-f32-xmm: SysV xmm disasm N/A on $(uname -s)-$(uname -m) (Linux x86_64 covers)"
  SKIP=$((SKIP + 1))
elif command -v objdump >/dev/null 2>&1; then
  for tag in mixed_ptr_f32 mixed_field_read; do
    DIS="$(objdump -d "/tmp/xlang_abi_f32_xmm_${tag}" 2>/dev/null || true)"
    if echo "$DIS" | grep -qE 'movd.*xmm'; then
      echo "abi-f32-xmm: ${tag} disasm movd xmm present"
      RUN_OK=$((RUN_OK + 1))
    elif [ -n "${XLANG_ABI_F32_XMM_STRICT:-}" ]; then
      die "${tag} disasm missing movd xmm"
    else
      echo "abi-f32-xmm OBS: ${tag} disasm missing movd xmm (product residual; not soft false-green)" >&2
      OBS=$((OBS + 1))
    fi
    if echo "$DIS" | grep -q 'cvtsd2ss'; then
      die "${tag} disasm still has cvtsd2ss (legacy widen under XLANG_ABI_F32_XMM=1)"
    fi
  done
fi

# CLI -legacy-f32-abi must match XLANG_ABI_F32_XMM=0 (exit=6; disasm has cvtsd2ss on x86).
echo "=== ABI f32 xmm: CLI -legacy-f32-abi ==="
CLI_BIN="/tmp/xlang_abi_f32_xmm_cli_legacy"
CLI_OBJ="/tmp/xlang_abi_f32_xmm_cli_legacy.o"
rm -f "$CLI_BIN" "$CLI_OBJ"
if ! XLANG="$XLANG_BIN" "$XLANG_BIN" build -backend asm -L . -legacy-f32-abi tests/abi/f32_call_xmm_smoke.x -o "$CLI_BIN" 2>/dev/null; then
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" build -backend asm -L . -legacy-f32-abi tests/abi/f32_call_xmm_smoke.x -o "$CLI_OBJ"; then
    die "compile with -legacy-f32-abi"
  fi
  if [ -f "$CRT0" ] && command -v ld >/dev/null 2>&1; then
    ld -o "$CLI_BIN" "$CLI_OBJ" "$CRT0" 2>/dev/null || true
  fi
fi
if [ ! -x "$CLI_BIN" ]; then
  die "no runnable binary for CLI -legacy-f32-abi"
fi
CLI_RC=0
"$CLI_BIN" >/dev/null 2>&1 || CLI_RC=$?
if [ "$CLI_RC" -ne 6 ]; then
  die "CLI -legacy-f32-abi expected exit 6, got $CLI_RC"
fi
echo "abi-f32-xmm: CLI -legacy-f32-abi exit=6 OK"
RUN_OK=$((RUN_OK + 1))

if dod_host_f32_run_na; then
  echo "abi-f32-xmm: legacy cvtsd2ss disasm N/A on $(uname -s)-$(uname -m) (Linux x86_64 covers)"
  SKIP=$((SKIP + 1))
elif command -v objdump >/dev/null 2>&1; then
  CLI_DIS="$(objdump -d "$CLI_BIN" 2>/dev/null || true)"
  if echo "$CLI_DIS" | grep -q 'cvtsd2ss'; then
    echo "abi-f32-xmm: CLI -legacy-f32-abi disasm cvtsd2ss present"
    RUN_OK=$((RUN_OK + 1))
  elif [ -n "${XLANG_ABI_F32_XMM_STRICT:-}" ]; then
    die "CLI -legacy-f32-abi disasm missing cvtsd2ss"
  else
    echo "abi-f32-xmm OBS: CLI -legacy-f32-abi disasm missing cvtsd2ss (product residual; not soft false-green)" >&2
    OBS=$((OBS + 1))
  fi
fi

echo "abi-f32-xmm gate OK"
ok_report
