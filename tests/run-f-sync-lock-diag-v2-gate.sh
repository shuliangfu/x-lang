#!/usr/bin/env bash
# F-sync-lock-diag v2: lock-diag logic in sync.x; TLS in runtime_sync_lock_diag_tls.
#
# Usage: ./tests/run-f-sync-lock-diag-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-sync-lock-diag-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-sync lock-diag hard delegate. Soft XLANG_F_SYNC_LOCK_DIAG_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/diag=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-sync-lock-diag-v2.md"
MANIFEST="tests/baseline/f-sync-lock-diag-v2-closure.tsv"
SYNC_TLS_RUNTIME="compiler/seeds/runtime_sync_lock_diag_tls.from_x.c"
PREFIX="xlang: [XLANG_F_SYNC_LOCK_DIAG_V2]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
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

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/sync/sync.o >/dev/null 2>&1 \
  || die "ensure sync.o failed (xlang_compiler_make; prefer asm)"
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
