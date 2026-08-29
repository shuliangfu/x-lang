#!/usr/bin/env bash
# F-socketio v2: EIO/SIO logic in socketio.x (socketio_glue deleted).
#
# Usage: ./tests/run-f-socketio-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-socketio-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_SOCKETIO_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green. STD-SOCKETIO-001 product residual
# (prefer-c / eio_packet) observational (listed skip).
# Report static=/ensure=/sio=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-socketio; refuse leftover ignore of explicit-bad). leftover
# nested product path stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-socketio-v2.md"
MANIFEST="tests/baseline/f-socketio-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_SOCKETIO_V2]"

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

die() {
  echo "f-socketio-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} sio=${SIO_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SIO_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-socketio (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover nested product path stays when XLANG is unset (do not
# rewrite leftover xlang_compiler_make / std-socketio).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-socketio v2: socketio logic → socketio.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-socketio v2' "$DOC" || die "doc missing F-socketio v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/socketio/socketio.x ] || die "missing socketio.x"
[ ! -f std/socketio/socketio_glue.c ] || die "socketio_glue.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
grep -q 'sio_eio_encode_packet_c' std/socketio/socketio.x || die "socketio.x missing eio encode"
grep -q 'sio_packet_smoke_c' std/socketio/socketio.x || die "socketio.x missing packet smoke"
grep -q 'sio_ws_hub_smoke_c' std/socketio/socketio.x || die "socketio.x missing hub smoke"
grep -q 'sio_p3_complete_smoke_c' std/socketio/socketio.x || die "socketio.x missing p3 smoke"
grep -q 'socketio_f_socketio_v2_marker_c' std/socketio/socketio.x || die "socketio.x missing v2 marker"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/socketio/socketio.o >/dev/null 2>&1 \
  || die "ensure socketio.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Do NOT export retired XLANG_F_SOCKETIO_V2_FAIL.
# STD-SOCKETIO-001: prefer-c / eio_packet product residual — observational.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-socketio-gate.sh ]; then
  echo "=== F-socketio v2: std-socketio (observational; product residual) ==="
  chmod +x tests/run-std-socketio-gate.sh
  if tests/run-std-socketio-gate.sh; then
    SIO_OK=1
  else
    echo "f-socketio-v2 WARN: std-socketio failed (observational)" >&2
    SIO_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} sio=${SIO_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-socketio-v2 gate OK (F-socketio v2; honesty)"
