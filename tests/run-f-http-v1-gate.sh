#!/usr/bin/env bash
# F-http v1：std.http 去 C（http.c → http.x + http_glue.c）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F_HTTP_V1_FAIL:-0}
DOC="analysis/phase-f-http-v1.md"
MANIFEST="tests/baseline/f-http-v1-closure.tsv"
die() { echo "f-http-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-http v1: http.c → http.x + glue ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-http v1' "$DOC" || die "doc marker"
[ -f std/http/http.x ] || die "missing http.x"
[ -f compiler/seeds/runtime_http_glue.from_x.c ] || die "missing glue"
[ ! -f std/http/http_glue.c ] || die "http_glue.c should be deleted (F-ZC)"
[ ! -f std/http/http.c ] || die "http.c should be deleted"
grep -q 'runtime_http_glue' compiler/Makefile || die "Makefile missing runtime_http_glue"
make -C compiler -q runtime_http_glue.o 2>/dev/null || make -C compiler runtime_http_glue.o >/dev/null 2>&1 || die "runtime_http_glue.o build failed"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'http.x' compiler/Makefile || die "Makefile missing http.x"
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/http/http.o >/dev/null 2>&1 || die "make http.o failed"
else
  echo "f-http-v1 SKIP http.o build (no shux-c)" >&2
fi
for sub in run-std-http-gate.sh run-std-http-chunked-gate.sh run-std-http-methods-gate.sh \
  run-std-http-server-pool-gate.sh run-std-http-reqresp-gate.sh run-std-http-https-gate.sh \
  run-std-http-h2-gate.sh run-std-http-context-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-http-v1 gate OK"
