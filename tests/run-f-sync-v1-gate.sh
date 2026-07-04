#!/usr/bin/env bash
# F-sync v1：std.sync 去 C（sync.x + runtime_sync_os.c + runtime_sync_lock_diag_tls.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SYNC_V1_FAIL:-0}
DOC="analysis/phase-f-sync-v1.md"
MANIFEST="tests/baseline/f-sync-v1-closure.tsv"
die() { echo "f-sync-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-sync v1: sync.c → sync.x ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-sync v1' "$DOC" || die "doc marker"
[ -f std/sync/sync.x ] || die "missing sync.x"
[ -f compiler/src/asm/runtime_sync_os.c ] || die "missing runtime_sync_os.c"
[ -f compiler/src/asm/runtime_sync_lock_diag_tls.c ] || die "missing runtime_sync_lock_diag_tls.c"
[ ! -f std/sync/sync_os_glue.c ] || die "sync_os_glue.c should be deleted"
[ ! -f std/sync/sync_lock_diag_tls_glue.c ] || die "sync_lock_diag_tls_glue.c should be deleted"
[ ! -f std/sync/sync.c ] || die "sync.c should be deleted"
[ ! -f std/sync/sync_lock_diag_glue.c ] || die "sync_lock_diag_glue.c should be deleted (v2)"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'runtime_sync_os' compiler/Makefile || die "Makefile missing runtime_sync_os"
make -C compiler -q runtime_sync_os.o runtime_sync_lock_diag_tls.o 2>/dev/null || \
  make -C compiler runtime_sync_os.o runtime_sync_lock_diag_tls.o >/dev/null 2>&1 || die "runtime sync build failed"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/sync/sync.o >/dev/null 2>&1 || die "make sync.o failed"
else
  echo "f-sync-v1 SKIP sync.o build (no shux-c)" >&2
fi
for sub in run-std-sync-lock-diag-gate.sh run-std-sync-rwlock-condvar-gate.sh run-f-sync-lock-diag-v2-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-sync-v1 gate OK"
