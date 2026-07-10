#!/usr/bin/env bash
# F-sync-lock-diag v2：锁诊断逻辑在 sync.x，TLS 在 runtime_sync_lock_diag_tls.inc。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SYNC_LOCK_DIAG_V2_FAIL:-0}
DOC="analysis/phase-f-sync-lock-diag-v2.md"
MANIFEST="tests/baseline/f-sync-lock-diag-v2-closure.tsv"
SYNC_TLS_RUNTIME="compiler/src/asm/runtime_sync_lock_diag_tls.inc"
die() { echo "f-sync-lock-diag-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-sync-lock-diag v2: diag logic → sync.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-sync-lock-diag v2' "$DOC" || die "doc marker"
[ -f "$MANIFEST" ] || die "missing manifest"
[ -f std/sync/sync.x ] || die "missing sync.x"
[ -f "$SYNC_TLS_RUNTIME" ] || die "missing runtime_sync_lock_diag_tls.inc"
[ ! -f std/sync/sync_lock_diag_glue.c ] || die "sync_lock_diag_glue.c should be deleted"
[ ! -f std/sync/sync_lock_diag_tls_glue.c ] || die "tls glue should be deleted from std"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'sync_lock_diag_before_lock' std/sync/sync.x || die "sync.x missing before_lock"
grep -q 'sync_lock_diag_tls_push_c' "$SYNC_TLS_RUNTIME" || die "runtime tls missing push"
grep -q 'runtime_sync_lock_diag_tls' compiler/Makefile || die "Makefile missing runtime tls"
grep -q 'sync_lock_diag_glue.c' compiler/Makefile && die "Makefile still references diag glue"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/sync/sync.o >/dev/null 2>&1 || die "make sync.o failed"
else
  echo "f-sync-lock-diag-v2 SKIP sync.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-sync-lock-diag-gate.sh
tests/run-std-sync-lock-diag-gate.sh || die "lock-diag gate failed"
echo "f-sync-lock-diag-v2 gate OK"
