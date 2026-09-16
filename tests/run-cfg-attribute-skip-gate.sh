#!/usr/bin/env bash
# B-01 v1: #[cfg(...)] semantic prune smoke (parse/typeck + run).
#
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`) retired.
# Soft XLANG_CFG_ATTR_SKIP_FAIL already retired. Prefer xlang_asm; pin
# XLANG_LINK_XLANG. Explicit-bad XLANG / missing native = hard die.
# G.7: complete existing resolve_shu; converge dod_native_exe (drop local
# stdlib_cm_native_xlang duplicate).
#
# Usage: ./tests/run-cfg-attribute-skip-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology (host OS+arch cfg prune).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/lexer/cfg_attribute_skip.x"
OUT="/tmp/xlang_cfg_attr_skip.$$.out"
PREFIX="xlang: [XLANG_B01_CFG_ATTR_SKIP]"
RUN_OK=0
SKIP=1

die() {
  echo "cfg-attribute-skip-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== B-01: #[cfg] attribute prune (honesty) ==="

[ -f "$X" ] || die "missing $X"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi

# Host OS+arch → expected exit (macos=5/linux=7/freebsd=9 + aarch64=11/x86_64=22).
EXPECT=0
ARCH="$(uname -m 2>/dev/null || echo unknown)"
case "$(uname -s):$ARCH" in
  Darwin:arm64|Darwin:aarch64) EXPECT=16 ;;
  Darwin:x86_64) EXPECT=27 ;;
  Linux:x86_64|Linux:amd64) EXPECT=29 ;;
  Linux:aarch64|Linux:arm64) EXPECT=18 ;;
  FreeBSD:amd64|FreeBSD:x86_64) EXPECT=31 ;;
  FreeBSD:arm64|FreeBSD:aarch64) EXPECT=20 ;;
  *)
    SKIP=1
    echo "cfg-attribute-skip-gate OK (unsupported host $(uname -s)/$ARCH)"
    echo "${PREFIX} status=ok run=0 skip=${SKIP} host=$(ci_host_summary)"
    exit 0
    ;;
esac

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

rm -f "$OUT" 2>/dev/null || true
if ! "$XLANG" build -o "$OUT" "$X" 2>/tmp/xlang_cfg_attr_skip.log; then
  tail -n 8 /tmp/xlang_cfg_attr_skip.log 2>/dev/null || true
  die "compile $X"
fi
[ -x "$OUT" ] || die "no executable $OUT"

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true
[ "$rc" -eq "$EXPECT" ] || die "expected exit $EXPECT (host $(uname -s)/$ARCH), got $rc"

RUN_OK=1
SKIP=0
echo "cfg-attribute-skip-gate OK (#[cfg] prune + main returns $EXPECT on $(uname -s)/$ARCH)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
