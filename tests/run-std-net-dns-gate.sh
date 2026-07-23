#!/usr/bin/env bash
# STD-029：std.net DNS 错误码与 IPv6 门禁
#
# 用法：./tests/run-std-net-dns-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_STD_NET_DNS_DOC:-analysis/std-net-dns-v1.md}"
MANIFEST="${XLANG_STD_NET_DNS_TSV:-tests/baseline/std-net-dns.tsv}"
NET_X="std/net/mod.x"
NET_DNS_X="std/net/dns.x"
LIB="tests/lib/std-net-dns.sh"
RESOLVE_X="tests/net/resolve_dns.x"
MAIN_X="tests/net/main.x"
MIN_APIS=4

# shellcheck source=tests/lib/std-net-dns.sh
. "$LIB"

echo "=== STD-029: net DNS manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$NET_X" "$NET_DNS_X" "$RESOLVE_X" "$MAIN_X" std/net/dns.x std/net/alpn.x; do
  if [ ! -f "$f" ]; then
    echo "std-net-dns gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-029 resolve_ex resolve_ipv6 resolve_err IPv6; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-net-dns gate FAIL: doc missing '$kw'" >&2
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
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$NET_X" 2>/dev/null; then
        echo "std-net-dns gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-net-dns gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-net-dns gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_net_dns_symbols_ok "$NET_X" "$NET_DNS_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_net_dns_emit_report "fail" 0 0 1
  echo "std-net-dns gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-net-dns manifest OK"

stdlib_cm_native_xlang() {
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

RESOLVE_OK=0
MAIN_OK=0
SKIP=1
if XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang-c && echo ./compiler/xlang-c || true)"; then
  :
elif XLANG_BIN="$(stdlib_cm_native_xlang ./compiler/xlang && echo ./compiler/xlang || true)"; then
  :
else
  XLANG_BIN=""
fi

if [ -n "$XLANG_BIN" ]; then
  echo "=== STD-029: typeck + smoke (XLANG=$XLANG_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/net/net.o
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c 2>/dev/null || true
  if ! "$XLANG_BIN" check -L . "$RESOLVE_X" >/dev/null 2>&1; then
    echo "std-net-dns gate FAIL: typeck $RESOLVE_X" >&2
    "$XLANG_BIN" check -L . "$RESOLVE_X" 2>&1 | tail -10 >&2 || true
    std_net_dns_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_net_dns_run_smoke "$XLANG_BIN" "$RESOLVE_X" "resolve_dns"; then
    RESOLVE_OK=1
  else
    std_net_dns_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_net_dns_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_net_dns_emit_report "fail" "$RESOLVE_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-net-dns gate SKIP smoke (no native xlang-c)" >&2
fi

std_net_dns_emit_report "ok" "$RESOLVE_OK" "$MAIN_OK" "$SKIP"
echo "std-net-dns gate OK"
