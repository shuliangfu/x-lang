#!/usr/bin/env bash
# F-socketio v2：std.socketio 逻辑下沉（EIO/SIO → socketio.x；删除 socketio_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_SOCKETIO_V2_FAIL:-0}
DOC="analysis/phase-f-socketio-v2.md"
MANIFEST="tests/baseline/f-socketio-v2-closure.tsv"
die() { echo "f-socketio-v2 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-socketio v2: socketio logic → socketio.x (pure) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-socketio v2' "$DOC" || die "doc marker"
[ -f std/socketio/socketio.x ] || die "missing socketio.x"
[ ! -f std/socketio/socketio_glue.c ] || die "socketio_glue.c should be deleted"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'sio_eio_encode_packet_c' std/socketio/socketio.x || die "socketio.x missing eio encode"
grep -q 'sio_packet_smoke_c' std/socketio/socketio.x || die "socketio.x missing packet smoke"
grep -q 'sio_ws_hub_smoke_c' std/socketio/socketio.x || die "socketio.x missing hub smoke"
grep -q 'sio_p3_complete_smoke_c' std/socketio/socketio.x || die "socketio.x missing p3 smoke"
grep -q 'socketio_f_socketio_v2_marker_c' std/socketio/socketio.x || die "socketio.x missing v2 marker"
grep -q 'socketio.x' compiler/Makefile || die "Makefile missing socketio.x"
grep -q 'socketio_glue.c' compiler/Makefile && die "Makefile still references socketio_glue.c"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/socketio/socketio.o >/dev/null 2>&1 || die "make socketio.o failed"
else
  echo "f-socketio-v2 SKIP socketio.o build (no shux-c)" >&2
fi
chmod +x tests/run-std-socketio-gate.sh
tests/run-std-socketio-gate.sh || die "run-std-socketio-gate failed"
echo "f-socketio-v2 gate OK"
