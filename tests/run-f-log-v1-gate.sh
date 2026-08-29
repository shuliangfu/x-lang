#!/usr/bin/env bash
# F-log v1: std.log de-C (log.c → log.x + seeds/runtime_log_os.from_x.c).
#
# Usage: ./tests/run-f-log-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-log-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-log multi-sink／rotate-async hard delegate. Soft XLANG_F_LOG_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/multi=/rotate=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested xlang_compiler_make / leftover nested
# std-log-multi-sink / leftover nested std-log-rotate-async; refuse
# leftover ignore of explicit-bad). leftover nested product path stay.
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

DOC="analysis/archive/phase/phase-f-log-v1.md"
MANIFEST="tests/baseline/f-log-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_LOG_V1]"

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
  echo "f-log-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} multi=${MULTI_OK:-0} rotate=${ROTATE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
MULTI_OK=0
ROTATE_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested ensure / leftover nested std-log-multi-sink /
# leftover nested std-log-rotate-async (refuse leftover SKIP→OK /
# leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover nested product path stays when XLANG is unset (do not
# rewrite leftover xlang_compiler_make / std-log-multi-sink /
# std-log-rotate-async).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-log v1: std.log log.c → log.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-log v1' "$DOC" || die "doc missing F-log v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/log/log.x ] || die "missing std/log/log.x"
[ -f compiler/seeds/runtime_log_os.from_x.c ] || die "missing runtime_log_os.from_x.c"
[ ! -f std/log/log_os_glue.c ] || die "log_os_glue.c should be deleted"
[ ! -f std/log/log.c ] || die "log.c should be deleted"

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

xlang_compiler_make ../std/log/log.o >/dev/null 2>&1 \
  || die "ensure log.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-log-multi-sink-gate.sh ]; then
  echo "=== F-log v1: delegate run-std-log-multi-sink-gate ==="
  chmod +x tests/run-std-log-multi-sink-gate.sh
  if ! tests/run-std-log-multi-sink-gate.sh; then
    die "std-log-multi-sink sub-gate failed"
  fi
  MULTI_OK=1
fi

if [ -f tests/run-std-log-rotate-async-gate.sh ]; then
  echo "=== F-log v1: delegate run-std-log-rotate-async-gate ==="
  chmod +x tests/run-std-log-rotate-async-gate.sh
  if ! tests/run-std-log-rotate-async-gate.sh; then
    die "std-log-rotate-async sub-gate failed"
  fi
  ROTATE_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} multi=${MULTI_OK} rotate=${ROTATE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-log-v1 std.log gate OK (F-log v1; honesty)"
