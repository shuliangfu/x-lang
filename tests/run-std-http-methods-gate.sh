#!/usr/bin/env bash
# STD-032：std.http POST/HEAD 与状态行解析门禁
#
# 用法：./tests/run-std-http-methods-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HTTP_METHODS_DOC:-analysis/std-http-methods-v1.md}"
MANIFEST="${SHUX_STD_HTTP_METHODS_TSV:-tests/baseline/std-http-methods.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
LIB="tests/lib/std-http-methods.sh"
METHODS_X="tests/http/methods_status.x"
MIN_APIS=3

# shellcheck source=tests/lib/std-http-methods.sh
. "$LIB"

echo "=== STD-032: http methods manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$HTTP_C" "$METHODS_X"; do
  if [ ! -f "$f" ]; then
    echo "std-http-methods gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in POST HEAD PUT DELETE PATCH OPTIONS parse_status_line Method client_request; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-methods gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-http-methods gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-http-methods gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-methods gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_methods_symbols_ok "$MOD_X" "$HTTP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_methods_emit_report "fail" 0 1
  echo "std-http-methods gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-http-methods manifest OK"

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

METHODS_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-032: typeck + smoke (SHUX=$SHUX_BIN) ==="
  if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
    export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/http/http.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$METHODS_X" >/dev/null 2>&1; then
    echo "std-http-methods gate FAIL: typeck $METHODS_X" >&2
    "$SHUX_BIN" check -L . "$METHODS_X" 2>&1 | tail -10 >&2 || true
    std_http_methods_emit_report "fail" 0 0
    exit 1
  fi
  if std_http_methods_run_smoke "$SHUX_BIN" "$METHODS_X" "methods_status"; then
    METHODS_OK=1
  else
    std_http_methods_emit_report "fail" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-http-methods gate SKIP smoke (no native shux-c)" >&2
fi

std_http_methods_emit_report "ok" "$METHODS_OK" "$SKIP"
echo "std-http-methods gate OK"
