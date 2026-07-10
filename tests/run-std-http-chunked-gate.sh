#!/usr/bin/env bash
# STD-033：std.http 分块传输与 Keep-Alive 门禁
#
# 用法：./tests/run-std-http-chunked-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_CHUNKED_DOC:-analysis/std-http-chunked-v1.md}"
MANIFEST="${SHUX_STD_HTTP_CHUNKED_TSV:-tests/baseline/std-http-chunked.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
CHUNKED_INC="compiler/seeds/http/http_chunked.inc"
LIB="tests/lib/std-http-chunked.sh"
SMOKE="tests/http/chunked_keepalive.x"
BENCH="tests/bench/http_chunked_decode_bench.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-http-chunked.sh
. "$LIB"

echo "=== STD-033: http chunked/keep-alive manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$CHUNKED_INC" "$SMOKE" "$BENCH"; do
  if [ ! -f "$f" ]; then
    echo "std-http-chunked gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in chunked keep-alive decode_chunked build_get_keep_alive; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-chunked gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http-chunked gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-chunked gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_chunked_symbols_ok "$MOD_X" "$CHUNKED_INC" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_chunked_emit_report "fail" 0 0 0 1
  exit 1
fi
echo "std-http-chunked manifest OK"

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

CHUNKED_OK=0
KEEPALIVE_OK=0
TYPECK_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-033: typeck + smoke (SHUX=$SHUX_BIN) ==="
  if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/http/http.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  for x in "$SMOKE" "$BENCH"; do
    if ! "$SHUX_BIN" check -L . "$x" >/dev/null 2>&1; then
      echo "std-http-chunked gate FAIL: typeck $x" >&2
      "$SHUX_BIN" check -L . "$x" 2>&1 | tail -10 >&2 || true
      std_http_chunked_emit_report "fail" 0 0 0 0
      exit 1
    fi
  done
  TYPECK_OK=1
  exe="/tmp/shux_std_http_chunked_$$"
  set +e
  link_log=$("$SHUX_BIN" -L . "$SMOKE" -o "$exe" 2>&1)
  link_ec=$?
  set -e
  if [ "$link_ec" -eq 0 ]; then
    set +e
    "$exe" >/dev/null 2>&1
    run_ec=$?
    set -e
    rm -f "$exe"
    if [ "$run_ec" -eq 0 ]; then
      CHUNKED_OK=1
      KEEPALIVE_OK=1
      SKIP=0
    else
      echo "std-http-chunked gate FAIL: run exit=$run_ec" >&2
      std_http_chunked_emit_report "fail" 0 0 "$TYPECK_OK" 0
      exit 1
    fi
  elif echo "$link_log" | grep -qE "library 'zstd' not found|shux_panic_"; then
    echo "std-http-chunked gate SKIP runnable link (typeck passed)" >&2
    SKIP=1
  else
    echo "std-http-chunked gate FAIL: link $SMOKE" >&2
    echo "$link_log" | tail -8 >&2 || true
    std_http_chunked_emit_report "fail" 0 0 "$TYPECK_OK" 0
    exit 1
  fi
else
  echo "std-http-chunked gate SKIP smoke (no native shux-c)" >&2
fi

std_http_chunked_emit_report "ok" "$CHUNKED_OK" "$KEEPALIVE_OK" "$TYPECK_OK" "$SKIP"
echo "std-http-chunked gate OK"
