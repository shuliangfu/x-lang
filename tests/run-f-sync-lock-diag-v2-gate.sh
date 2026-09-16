#!/usr/bin/env bash
# F-sync-lock-diag v2: lock-diag logic in sync.x; TLS in runtime_sync_lock_diag_tls.
#
# Usage: ./tests/run-f-sync-lock-diag-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-sync-lock-diag-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-sync lock-diag hard delegate. Soft XLANG_F_SYNC_LOCK_DIAG_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/diag=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-sync-lock-diag; refuse leftover ignore of
# explicit-bad). leftover auto-make of sync.o (`xlang_compiler_make`
# even when the leaf is present — try-heat/g05 raced L2) retired.
# leftover unused compiler-make.sh sourced unused after leftover
# auto-make retired. Missing leaf .o = hard die. leftover nested
# std-sync-lock-diag stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-sync-lock-diag-v2.md"
MANIFEST="tests/baseline/f-sync-lock-diag-v2-closure.tsv"
SYNC_TLS_RUNTIME="compiler/seeds/runtime_sync_lock_diag_tls.from_x.c"
PREFIX="xlang: [XLANG_F_SYNC_LOCK_DIAG_V2]"

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
  echo "f-sync-lock-diag-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} diag=${DIAG_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
DIAG_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-sync-lock-diag (refuse leftover SKIP→OK /
# leftover ignore of explicit-bad / leftover XLANG fallthrough).
# leftover auto-make of sync.o retired; leftover nested
# std-sync-lock-diag stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-sync-lock-diag v2: diag logic → sync.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-sync-lock-diag v2' "$DOC" || die "doc missing F-sync-lock-diag v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/sync/sync.x ] || die "missing std/sync/sync.x"
[ -f "$SYNC_TLS_RUNTIME" ] || die "missing runtime_sync_lock_diag_tls.from_x.c"
[ ! -f std/sync/sync_lock_diag_glue.c ] || die "sync_lock_diag_glue.c should be deleted"
[ ! -f std/sync/sync_lock_diag_tls_glue.c ] || die "tls glue should be deleted from std"

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
grep -q 'sync_lock_diag_before_lock' std/sync/sync.x || die "sync.x missing before_lock"
grep -q 'sync_lock_diag_tls_push_c' "$SYNC_TLS_RUNTIME" || die "runtime tls missing push"
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

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/sync/sync.o ]; then
  die "missing std/sync/sync.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

if [ -f tests/run-std-sync-lock-diag-gate.sh ]; then
  echo "=== F-sync-lock-diag v2: delegate run-std-sync-lock-diag-gate ==="
  chmod +x tests/run-std-sync-lock-diag-gate.sh
  if ! tests/run-std-sync-lock-diag-gate.sh; then
    die "std-sync-lock-diag sub-gate failed"
  fi
  DIAG_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} diag=${DIAG_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-sync-lock-diag-v2 std.sync gate OK (F-sync-lock-diag v2; honesty)"
