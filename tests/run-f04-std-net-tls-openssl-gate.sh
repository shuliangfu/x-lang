#!/usr/bin/env bash
# F-04 v8：std.net OpenSSL TLS 去 C 门禁（tls_openssl.x + 无 tls_openssl.inc.c）。
#
# 用法：./tests/run-f04-std-net-tls-openssl-gate.sh
# 环境：SHUX_F04_NET_TLS_OPENSSL_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_TLS_OPENSSL_FAIL:-0}
DOC="analysis/phase-f-f04-v8.md"
TLS_X="std/net/tls_openssl.x"
NET_C="std/net/net.c"

die() {
  echo "f04-net-tls-openssl gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v8: std.net tls_openssl remove tls_openssl.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v8' "$DOC" || die "doc missing F-04 v8 marker"
[ -f "$TLS_X" ] || die "missing tls_openssl.x"
[ ! -f std/net/tls_openssl.inc.c ] || die "tls_openssl.inc.c should be deleted"
grep -q 'shu_net_tls_openssl_marker' "$TLS_X" || die "tls_openssl.x missing marker"
grep -q 'net_tls_connect_client_c' "$TLS_X" || die "tls_openssl.x missing connect"
grep -q 'net_tls_openssl_smoke_c' "$TLS_X" || die "tls_openssl.x missing smoke"
if grep -q 'tls_openssl.inc.c' "$NET_C" 2>/dev/null; then
  die "net.c still references tls_openssl.inc.c"
fi
if grep -q 'SHUX_NET_USE_OPENSSL' "$NET_C" 2>/dev/null; then
  die "net.c still defines SHUX_NET_USE_OPENSSL include path"
fi
grep -q 'tls_openssl.x' compiler/Makefile || die "Makefile missing tls_openssl.x build"
grep -q 'invoke_cc_append_net_tls_ld.*repo_root' compiler/seeds/runtime_link_abi.from_x.c \
  || die "runtime_link_abi missing tls_openssl.o link path"

if [ -f tests/run-std-net-tls-gate.sh ]; then
  echo "=== F-04 v8: delegate run-std-net-tls-gate ==="
  chmod +x tests/run-std-net-tls-gate.sh
  if ! tests/run-std-net-tls-gate.sh; then
    die "std-net-tls sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v8: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.net tls_openssl gate OK (F-04 v8)"
