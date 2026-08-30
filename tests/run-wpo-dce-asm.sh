#!/usr/bin/env bash
# WPO v0 smoke: asm backend DCE drops dead_export across an import lib.
#
# Honesty: leftover auto-make (`xlang_compiler_make xlang-c` when XLANG
# missing) retired. leftover SKIP compile fail (`-backend asm -o .o`
# fail → exit 0) retired — that was portable false-green. leftover
# ignore of explicit-bad (XLANG=/nonexistent silently auto-made
# xlang-c) retired. leftover unused compiler-make.sh sourced unused
# after leftover auto-make retired. Explicit-bad XLANG / missing native
# = hard die FIRST (before leftover nested host-arch N/A / leftover
# nested Darwin exe N/A). leftover nested product path
# (wpo_host_asm_run_na Windows/Linux aarch64; Darwin exe run N/A; Linux
# exe run if -o succeeds) stay. G.7: complete existing resolve_shu;
# converge dod_native_exe. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

PREFIX="xlang: [XLANG_WPO_DCE_ASM]"
RUN_OK=0
OBS=0
SKIP=1

die() {
  echo "wpo-dce-asm gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# leftover auto-make xlang-c retired — converge dod_native_exe.
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE leftover
# nested host-arch N/A / leftover nested Darwin exe N/A (refuse leftover
# SKIP compile fail / leftover ignore of explicit-bad / leftover
# auto-make). leftover nested product path stays when XLANG is unset.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover ignore of explicit-bad / leftover SKIP compile fail / leftover auto-make)"
fi

echo "=== WPO asm DCE (honesty) ==="

# leftover nested host-arch N/A stay (Windows / Linux aarch64 refresh
# stub). Report skip=1 — not leftover SKIP→OK without a counter.
# PLATFORM: SHARED archaeology — x86_64 / Darwin arm64 cover the smoke.
if wpo_host_asm_run_na; then
  SKIP=1
  echo "WPO asm DCE: N/A on $(uname -s)-$(uname -m) (refresh xlang_asm asm stub; x86_64 covers)"
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  echo "wpo asm dce OK"
  exit 0
fi

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover ignore of explicit-bad / leftover SKIP compile fail / leftover auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover SKIP compile fail / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0

TMP_O="/tmp/xlang_wpo_dead_user_asm.o"
TMP_EXE="/tmp/xlang_wpo_dead_user_asm"

rm -f "$TMP_O" "$TMP_EXE"

# -backend asm -o .o: dead_export must not appear in the symbol table.
# leftover SKIP compile fail retired — present native must compile.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
if ! "$XLANG_BIN" -backend asm -o "$TMP_O" tests/wpo/dead_user.x >/tmp/xlang_wpo_dce_asm_build.log 2>&1; then
  echo "wpo-dce-asm compile log:" >&2
  tail -8 /tmp/xlang_wpo_dce_asm_build.log 2>/dev/null || true
  die "xlang asm compile failed (refuse leftover SKIP compile fail; XLANG=$XLANG_BIN)"
fi

if nm "$TMP_O" 2>/dev/null | grep -q 'dead_export'; then
  nm "$TMP_O" 2>/dev/null | grep -E 'dead_export|live_export|main' || true
  die "dead_export still in .o symbols"
fi
if ! nm "$TMP_O" 2>/dev/null | grep -q 'live_export'; then
  die "missing live_export"
fi
if ! wpo_nm_has_sym "$TMP_O" main; then
  nm "$TMP_O" 2>/dev/null | grep -E 'main|live_export' || true
  die "missing main"
fi
RUN_OK=1

# leftover nested Darwin exe run N/A stay (.o symbol gate already
# covered DCE). Linux exe run stays optional-if-built (leftover nested
# product; do not absorb leftover SKIP of a missing user exe).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
case "$(uname -s 2>/dev/null)" in
  Darwin)
    echo "WPO asm DCE: exe run N/A on Darwin (.o symbol gate OK)"
    OBS=1
    ;;
  *)
    if "$XLANG_BIN" -backend asm -o "$TMP_EXE" tests/wpo/dead_user.x >/dev/null 2>&1 && [ -x "$TMP_EXE" ]; then
      rc=$("$TMP_EXE"; echo $?)
      [ "$rc" = "7" ] || die "dead_user asm exit=$rc want 7"
    else
      OBS=1
    fi
    ;;
esac

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
echo "wpo asm dce OK"
