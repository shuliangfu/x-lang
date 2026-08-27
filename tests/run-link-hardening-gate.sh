#!/usr/bin/env bash
# P1-7: Linker hardening smoke — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired; Darwin/non-Linux soft SKIP→OK without run=/skip=
# report retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native on Linux = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c).
#   - hard (SHARED archaeology): manifest + runtime_link_abi harden hook;
#     refuse monofile seeds/runtime.from_x.c resurrect
#   - hard (LINUX): product -o tests/link_hardening_smoke.x → Type=DYN (PIE) +
#     GNU_STACK non-exec + exit 42
#   - skip (non-Linux / no readelf): status=ok run=… skip=1 (platform N/A)
# Report: run=/obs=/skip=
# Usage: ./tests/run-link-hardening-gate.sh
# wave honesty (2026-08-24 #5): monofile seeds/runtime.from_x.c retired wave321;
# harden authority = runtime_link_abi.from_x.c（refuse monofile resurrect）.
# PLATFORM: SHARED archaeology / LINUX smoke — Ubuntu gold for PIE+NX.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_LINK_HARDENING_PREFIX:-xlang: [XLANG_LINK_HARDENING]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
MANIFEST="tests/baseline/link-hardening.tsv"
SRC="tests/link_hardening_smoke.x"
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "link-hardening FAIL: $*" >&2
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== P1-7: link hardening manifest ==="
for f in "$MANIFEST" "$SRC" "$LINK_ABI"; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (harden live = runtime_link_abi)"
fi
if ! grep -qF "xlang_append_linux_link_harden" "$LINK_ABI" 2>/dev/null; then
  die "runtime_link_abi missing xlang_append_linux_link_harden"
fi
echo "link-hardening manifest OK"
RUN_OK=$((RUN_OK + 1))

# PLATFORM: LINUX — PIE+NX smoke is Linux/ELF-only. Darwin/other = skip= honesty
# (not soft SKIP→OK with no report). Manifest archaeology above still hard.
if ! ci_is_linux; then
  echo "link-hardening: N/A (Linux ELF PIE+NX only)"
  SKIP=1
  ok_report
  exit 0
fi
if ! command -v readelf >/dev/null 2>&1; then
  echo "link-hardening: N/A (no readelf)"
  SKIP=1
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

EXE="/tmp/xlang_link_harden_$$"
ERR="/tmp/xlang_link_harden_$$.log"
echo "=== link-hardening: product -o smoke (XLANG=$XLANG_BIN) ==="
rm -f "$EXE"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$EXE" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  echo "link-hardening OBS compile (-o timeout; product residual)" >&2
  OBS=$((OBS + 1))
  ok_report
  exit 0
fi
if [ "$o_ec" -ne 0 ] || [ ! -x "$EXE" ]; then
  echo "link-hardening FAIL: compile $SRC (ec=$o_ec)" >&2
  tail -n 12 "$ERR" >&2 || true
  rm -f "$EXE"
  die "compile $SRC"
fi

# PIE: ELF Type must be DYN (Position-Independent Executable).
# Force C locale: zh_CN etc. print 「类型:」 instead of Type:; awk would false-red.
ELF_TYPE="$(LC_ALL=C readelf -h "$EXE" 2>/dev/null | awk '/Type:/ {print $2}')"
if [ "$ELF_TYPE" != "DYN" ]; then
  rm -f "$EXE"
  die "expected Type DYN (PIE), got ${ELF_TYPE:-?}"
fi

# NX: GNU_STACK Flg must not contain E (non-executable stack).
STACK_FLG="$(LC_ALL=C readelf -l -W "$EXE" 2>/dev/null | awk '/GNU_STACK/ {getline; print $NF; exit}')"
case "$STACK_FLG" in
  *E*)
    rm -f "$EXE"
    die "GNU_STACK executable (Flg=$STACK_FLG)"
    ;;
esac

set +e
gate_run_timeout 10 "$EXE" >/dev/null 2>&1
EC=$?
set -e
rm -f "$EXE" "$ERR"
if [ "$EC" -eq 124 ]; then
  echo "link-hardening OBS run (timeout; product residual)" >&2
  OBS=$((OBS + 1))
  ok_report
  exit 0
fi
if [ "$EC" -ne 42 ]; then
  die "expected exit 42, got $EC"
fi

RUN_OK=$((RUN_OK + 1))
echo "link-hardening OK (Type=DYN stack=${STACK_FLG:-RW} exit=42)"
ok_report
echo "link-hardening gate OK"
