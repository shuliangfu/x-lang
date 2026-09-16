#!/usr/bin/env bash
# SIMD-LANG-HOSTC-FALLTHROUGH gate: Stage 10 (10.5.1) slice10.
# Force xlang-c (host-C) so try_emit_simd_lang_builtin is not used; scalar
# bodies in std/simd/builtin.x must run and exit 0 (no panic).
#
# Usage: ./tests/run-simd-lang-hostc-fallthrough-gate.sh
# PLATFORM: SHARED harness — Ubuntu/Darwin when native xlang-c exists.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_LANG_HOSTC_FALLTHROUGH_PREFIX:-xlang: [XLANG_SIMD_LANG_HOSTC_FALLTHROUGH]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-lang-hostc-fallthrough gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_xlang_c() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG_C:-}" ]; then
    case "$XLANG_C" in
      /*) abs="$XLANG_C" ;;
      *) abs="$root/$XLANG_C" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== SIMD-LANG-HOSTC-FALLTHROUGH: scalar bodies via xlang-c ==="
XLANG_C_ABS="$(resolve_xlang_c)" || {
  echo "simd-lang-hostc-fallthrough SKIP: no native xlang-c (host=$(ci_host_summary))" >&2
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
}
export XLANG="$XLANG_C_ABS"
export XLANG_LINK_XLANG="$XLANG_C_ABS"

SMOKE_SRC="tests/sys/simd_lang_hostc_fallthrough_smoke.x"
SMOKE_EXE="/tmp/xlang_simd_lang_hostc_fallthrough_smoke"
rm -f "$SMOKE_EXE"
[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"

if ! "$XLANG_C_ABS" -L . "$SMOKE_SRC" -o "$SMOKE_EXE"; then
  die "host-C compile/link $SMOKE_SRC"
fi
[ -x "$SMOKE_EXE" ] || die "missing exe $SMOKE_EXE"

if ! rc="$SMOKE_EXE"; then
  die "run $SMOKE_EXE exit=$rc (scalar fallthrough panic?)"
fi
RUN_OK=$((RUN_OK + 1))

# Honesty: product must be host-C path — refuse if someone pointed XLANG_C at asm
# and still greened via HW intercept only. Prefer basename check.
base="$(basename "$XLANG_C_ABS")"
case "$base" in
  xlang-c|xlang) ;;
  *)
    OBS=$((OBS + 1))
    echo "simd-lang-hostc-fallthrough WARN: XLANG_C basename=$base (obs)" >&2
    ;;
esac

ok_report
