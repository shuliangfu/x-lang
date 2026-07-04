#!/usr/bin/env bash
# F-socketio v1：std.socketio 去 C（socketio.c → socketio.x；胶层 v2 已删，见 run-f-socketio-v2-gate.sh）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SOCKETIO_V1_FAIL:-0}
DOC="analysis/phase-f-socketio-v1.md"
MANIFEST="tests/baseline/f-socketio-v1-closure.tsv"
die() { echo "f-socketio-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-socketio v1: socketio.c → socketio.x (glue superseded by v2) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-socketio v1' "$DOC" || die "doc marker"
[ -f std/socketio/socketio.x ] || die "missing socketio.x"
[ ! -f std/socketio/socketio.c ] || die "socketio.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'socketio.x' compiler/Makefile || die "Makefile missing socketio.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/socketio/socketio.o >/dev/null 2>&1 || die "make socketio.o failed"
else
  echo "f-socketio-v1 SKIP socketio.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-socketio-gate.sh
tests/run-std-socketio-gate.sh || die "run-std-socketio-gate failed"
echo "f-socketio-v1 gate OK"
