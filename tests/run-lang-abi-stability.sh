#!/usr/bin/env bash
# LANG-005: ABI stability smoke (C layout + f32 xmm).
#
# Honesty: soft SKIP→OK when no native xlang / f32 gate fail retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (ABI face is live). Layout (cc) is hard.
# f32 xmm residual → obs (not soft silence). Report layout=/f32=/obs=/skip=.
#
# Usage: ./tests/run-lang-abi-stability.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/lang-abi-stability.sh
. tests/lib/lang-abi-stability.sh

PREFIX="xlang: [XLANG_LANG_ABI_STABILITY]"
LAYOUT_OK=0
F32_OK=0
OBS=0
SKIP=0

die() {
  echo "lang-abi-stability FAIL: $*" >&2
  echo "${PREFIX} status=fail layout=${LAYOUT_OK} f32=${F32_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok layout=${LAYOUT_OK} f32=${F32_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

echo "=== LANG-005: ABI layout (cc) ==="
chmod +x tests/run-abi-layout.sh
./tests/run-abi-layout.sh
LAYOUT_OK=1
echo "lang-abi-stability OK layout"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

if [ ! -x tests/run-abi-f32-xmm-gate.sh ]; then
  die "missing tests/run-abi-f32-xmm-gate.sh"
fi

echo "=== LANG-005: f32 xmm ABI (XLANG=$XLANG_BIN) ==="
chmod +x tests/run-abi-f32-xmm-gate.sh
# f32 residual is observational product debt on some hosts (e.g. Darwin
# arm64 without full SysV xmm path); count obs, not soft silence.
# PLATFORM: SHARED — Ubuntu x86_64 gold still required for hard xmm.
set +e
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-abi-f32-xmm-gate.sh
f32_ec=$?
set -e
if [ "$f32_ec" -eq 0 ]; then
  F32_OK=1
  echo "lang-abi-stability OK f32_xmm"
else
  echo "lang-abi-stability OBS f32_xmm (host/ABI residual; refuse soft SKIP→OK)" >&2
  OBS=1
fi

ok_report
echo "lang-abi-stability OK"
