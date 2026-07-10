#!/usr/bin/env bash
# STD-107：std.http server 循环 + client 连接池门禁
#
# 用法：./tests/run-std-http-server-pool-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD107_DOC:-analysis/std-http-server-pool-v1.md}"
MANIFEST="${SHUX_STD107_TSV:-tests/baseline/std-http-server-pool.tsv}"
VECTORS="${SHUX_STD107_VECTORS:-tests/baseline/std-http-server-pool-vectors.tsv}"
MOD_X="std/http/mod.x"
HTTP_C="compiler/seeds/runtime_http_glue.from_x.c"
POOL_INC="compiler/seeds/http/http_server_pool.inc"
LIB="tests/lib/std-http-server-pool.sh"
SMOKE_X="tests/http/server_pool.x"
SMOKE_C="tests/http/server_pool_smoke_ok.c"
MIN_APIS=5

# shellcheck source=tests/lib/std-http-server-pool.sh
. "$LIB"

echo "=== STD-107: http server-pool manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$HTTP_C" "$POOL_INC" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-http-server-pool gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-107 serve_one client_pool_get keep-alive; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-http-server-pool gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'connect_count=1' "$VECTORS" 2>/dev/null; then
  echo "std-http-server-pool gate FAIL: vectors missing pool_reuse gold" >&2
  exit 1
fi

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
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "std-http-server-pool FAIL: doc missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-http-server-pool gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_http_server_pool_symbols_ok "$MOD_X" "$HTTP_C" "$POOL_INC" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_http_server_pool_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-http-server-pool manifest OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_runtime_http_glue_o

C_OK=0
if std_http_server_pool_run_c_smoke "$HTTP_C"; then
  C_OK=1
else
  std_http_server_pool_emit_report "fail" 0 0 0
  exit 1
fi

X_OK=0
SKIP=0
SHUX_BIN=""
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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-107: .x smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-http-server-pool gate FAIL: typeck $SMOKE_X" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_http_server_pool_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_http_server_pool_run_x_smoke "$SHUX_BIN" "$SMOKE_X" "sp"; then
    X_OK=1
  else
    std_http_server_pool_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_http_server_pool_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-http-server-pool gate OK"
