#!/usr/bin/env bash
# F-http v1：std.http 去 C（http.c → http.x + http_glue.c）。
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F_HTTP_V1_FAIL:-0}
DOC="analysis/archive/phase/phase-f-http-v1.md"
MANIFEST="tests/baseline/f-http-v1-closure.tsv"
die() { echo "f-http-v1 gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
echo "=== F-http v1: http.c → http.x + glue ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-http v1' "$DOC" || die "doc marker"
[ -f std/http/http.x ] || die "missing http.x"
[ -f compiler/seeds/runtime_http_glue.from_x.c ] || die "missing glue"
[ ! -f std/http/http_glue.c ] || die "http_glue.c should be deleted (F-ZC)"
[ ! -f std/http/http.c ] || die "http.c should be deleted"
xlang_compiler_make -q runtime_http_glue.o 2>/dev/null || xlang_compiler_make runtime_http_glue.o >/dev/null 2>&1 || die "runtime_http_glue.o build failed"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    absent) [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)" ;;
  esac
done < "$MANIFEST"
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ]; then
  xlang_compiler_make ../std/http/http.o >/dev/null 2>&1 || die "ensure http.o failed (xlang_compiler_make)"
else
  echo "f-http-v1 SKIP http.o build (no xlang-c)" >&2
fi
for sub in run-std-http-gate.sh run-std-http-chunked-gate.sh run-std-http-methods-gate.sh \
  run-std-http-server-pool-gate.sh run-std-http-reqresp-gate.sh run-std-http-https-gate.sh \
  run-std-http-h2-gate.sh run-std-http-context-gate.sh; do
  [ -f "tests/$sub" ] || continue
  chmod +x "tests/$sub"
  tests/"$sub" || die "$sub failed"
done
echo "f-http-v1 gate OK"
