#!/usr/bin/env bash
# STD-094/095：std.http ↔ std.context + C 层 connect/recv 超时门禁
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MOD_SU="std/http/mod.sx"
HTTP_C="std/http/http.c"
ERR_SU="std/error/mod.sx"
SMOKE="tests/http/context_get.sx"
SMOKE_TO="tests/http/context_connect_timeout.sx"
SMOKE_C="tests/http/http_timeout_smoke.c"
PREFIX="shux: [SHUX_STD094_HTTP_CTX]"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== STD-094/095: http-context manifest ==="
for f in "$MOD_SU" "$HTTP_C" "$ERR_SU" "$SMOKE" "$SMOKE_TO" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "http-context gate FAIL: missing $f" >&2
    exit 1
  fi
done
for sym in timeout_ms_for_http ctx_check_for_http get_ctx post_ctx head_ctx map_http_c_result request_timeout_ms_for_ctx http_get_timeout_c; do
  case "$sym" in
    http_get_timeout_c|http_timeout_smoke_c)
      if ! grep -qE "(function|int32_t) ${sym}\\(" "$HTTP_C" 2>/dev/null; then
        echo "http-context gate FAIL: missing c api $sym" >&2
        exit 1
      fi
      ;;
    *)
      if ! grep -qE "function ${sym}\\(" "$MOD_SU" 2>/dev/null; then
        echo "http-context gate FAIL: missing api $sym" >&2
        exit 1
      fi
      ;;
  esac
done
for sym in http_timeout_smoke_c; do
  if ! grep -qE "int32_t ${sym}\\(" "$HTTP_C" 2>/dev/null; then
    echo "http-context gate FAIL: missing c smoke $sym" >&2
    exit 1
  fi
done
for sym in http_err_timeout http_err_cancelled; do
  if ! grep -qE "function ${sym}\\(" "$ERR_SU" 2>/dev/null; then
    echo "http-context gate FAIL: missing error $sym" >&2
    exit 1
  fi
done
echo "http-context manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/context/context.o
ensure_std_c_o ../std/time/time.o
ensure_std_c_o ../std/http/http.o

C_OK=0
echo "=== STD-095: C timeout smoke ==="
c_exe="/tmp/shux_std095_http_to_$$"
if cc -Wall -Wextra -o "$c_exe" "$SMOKE_C" std/http/http.o 2>/dev/null; then
  set +e
  "$c_exe" >/dev/null 2>&1
  c_ec=$?
  set -e
  rm -f "$c_exe"
  if [ "$c_ec" -ne 0 ]; then
    echo "http-context gate FAIL: C timeout smoke exit=$c_ec" >&2
    exit 1
  fi
  C_OK=1
else
  echo "http-context gate FAIL: compile $SMOKE_C" >&2
  exit 1
fi

SHUX_BIN=""
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

SU_OK=0
SKIP=0
if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-094/095: smoke (SHUX=$SHUX_BIN) ==="
  for su in "$SMOKE" "$SMOKE_TO"; do
    if ! "$SHUX_BIN" check -L . "$su" >/dev/null 2>&1; then
      echo "http-context gate FAIL: typeck $su" >&2
      "$SHUX_BIN" check -L . "$su" 2>&1 | tail -10 >&2 || true
      exit 1
    fi
    exe="/tmp/shux_std094_http_ctx_$$_${su##*/}"
    if ! "$SHUX_BIN" -L . "$su" -o "$exe" >/dev/null 2>&1; then
      echo "http-context gate FAIL: compile $su" >&2
      exit 1
    fi
    set +e
    "$exe" >/dev/null 2>&1
    ec=$?
    set -e
    rm -f "$exe"
    if [ "$ec" -ne 0 ]; then
      echo "http-context gate FAIL: run $su exit=$ec" >&2
      exit 1
    fi
  done
  SU_OK=1
else
  echo "http-context gate SKIP .sx (no native shux)" >&2
  SKIP=1
fi

echo "${PREFIX} status=ok c=${C_OK} su=${SU_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "std-http-context gate OK"
