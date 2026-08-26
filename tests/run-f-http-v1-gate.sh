#!/usr/bin/env bash
# F-http v1: std.http de-C (http.x + seeds/runtime_http_glue.from_x.c).
#
# Usage: ./tests/run-f-http-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-http-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-009 http + chunked + methods + https hard delegate. Soft XLANG_F_HTTP_V1_FAIL
# retired. Root: soft die→exit0 = portable false-green (static+STD-009 already green).
# Product residuals observational (listed skip): server-pool / reqresp / h2 / context.
# Report static=/ensure=/glue=/http=/chunked=/methods=/https=/pool=/reqresp=/h2=/ctx=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-http-v1.md"
MANIFEST="tests/baseline/f-http-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_HTTP_V1]"

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
  echo "f-http-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} glue=${GLUE_OK:-0} http=${HTTP_OK:-0} chunked=${CHUNKED_OK:-0} methods=${METHODS_OK:-0} https=${HTTPS_OK:-0} pool=${POOL_OK:-0} reqresp=${REQRESP_OK:-0} h2=${H2_OK:-0} ctx=${CTX_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
GLUE_OK=0
HTTP_OK=0
CHUNKED_OK=0
METHODS_OK=0
HTTPS_OK=0
POOL_OK=0
REQRESP_OK=0
H2_OK=0
CTX_OK=0
SKIP=1

echo "=== F-http v1: std.http http.c → http.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-http v1' "$DOC" || die "doc missing F-http v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/http/http.x ] || die "missing http.x"
[ -f compiler/seeds/runtime_http_glue.from_x.c ] || die "missing runtime_http_glue.from_x.c"
[ ! -f std/http/http_glue.c ] || die "http_glue.c should be deleted (F-ZC)"
[ ! -f std/http/http.c ] || die "http.c should be deleted"

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

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make -q runtime_http_glue.o 2>/dev/null \
  || xlang_compiler_make runtime_http_glue.o >/dev/null 2>&1 \
  || die "runtime_http_glue.o build failed"
GLUE_OK=1

xlang_compiler_make ../std/http/http.o >/dev/null 2>&1 \
  || die "ensure http.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-009 family (product signal).
if [ -f tests/run-std-http-gate.sh ]; then
  echo "=== F-http v1: delegate run-std-http-gate ==="
  chmod +x tests/run-std-http-gate.sh
  if ! tests/run-std-http-gate.sh; then
    die "std-http sub-gate failed"
  fi
  HTTP_OK=1
fi

if [ -f tests/run-std-http-chunked-gate.sh ]; then
  echo "=== F-http v1: delegate run-std-http-chunked-gate ==="
  chmod +x tests/run-std-http-chunked-gate.sh
  if ! tests/run-std-http-chunked-gate.sh; then
    die "std-http-chunked sub-gate failed"
  fi
  CHUNKED_OK=1
fi

if [ -f tests/run-std-http-methods-gate.sh ]; then
  echo "=== F-http v1: delegate run-std-http-methods-gate ==="
  chmod +x tests/run-std-http-methods-gate.sh
  if ! tests/run-std-http-methods-gate.sh; then
    die "std-http-methods sub-gate failed"
  fi
  METHODS_OK=1
fi

if [ -f tests/run-std-http-https-gate.sh ]; then
  echo "=== F-http v1: delegate run-std-http-https-gate ==="
  chmod +x tests/run-std-http-https-gate.sh
  if ! tests/run-std-http-https-gate.sh; then
    die "std-http-https sub-gate failed"
  fi
  HTTPS_OK=1
fi

# Product residuals (listed skip 复探红): observational only.
if [ -f tests/run-std-http-server-pool-gate.sh ]; then
  echo "=== F-http v1: std-http-server-pool (observational; product residual) ==="
  chmod +x tests/run-std-http-server-pool-gate.sh
  if tests/run-std-http-server-pool-gate.sh; then
    POOL_OK=1
  else
    echo "f-http-v1 WARN: std-http-server-pool failed (observational)" >&2
    POOL_OK=0
  fi
fi

if [ -f tests/run-std-http-reqresp-gate.sh ]; then
  echo "=== F-http v1: std-http-reqresp (observational; product residual) ==="
  chmod +x tests/run-std-http-reqresp-gate.sh
  if tests/run-std-http-reqresp-gate.sh; then
    REQRESP_OK=1
  else
    echo "f-http-v1 WARN: std-http-reqresp failed (observational)" >&2
    REQRESP_OK=0
  fi
fi

if [ -f tests/run-std-http-h2-gate.sh ]; then
  echo "=== F-http v1: std-http-h2 (observational; product residual) ==="
  chmod +x tests/run-std-http-h2-gate.sh
  if tests/run-std-http-h2-gate.sh; then
    H2_OK=1
  else
    echo "f-http-v1 WARN: std-http-h2 failed (observational)" >&2
    H2_OK=0
  fi
fi

if [ -f tests/run-std-http-context-gate.sh ]; then
  echo "=== F-http v1: std-http-context (observational; product residual) ==="
  chmod +x tests/run-std-http-context-gate.sh
  if tests/run-std-http-context-gate.sh; then
    CTX_OK=1
  else
    echo "f-http-v1 WARN: std-http-context failed (observational)" >&2
    CTX_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} glue=${GLUE_OK} http=${HTTP_OK} chunked=${CHUNKED_OK} methods=${METHODS_OK} https=${HTTPS_OK} pool=${POOL_OK} reqresp=${REQRESP_OK} h2=${H2_OK} ctx=${CTX_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-http-v1 std.http gate OK (F-http v1; honesty)"
