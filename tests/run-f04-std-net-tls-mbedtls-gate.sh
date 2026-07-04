#!/usr/bin/env bash
# F-04 v9：std.net mbedTLS TLS 去 C 门禁（tls_mbedtls.x + 无 tls_mbedtls.inc.c）。
#
# 用法：./tests/run-f04-std-net-tls-mbedtls-gate.sh
# 环境：SHUX_F04_NET_TLS_MBEDTLS_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F04_NET_TLS_MBEDTLS_FAIL:-0}
DOC="analysis/phase-f-f04-v9.md"
TLS_X="std/net/tls_mbedtls.x"
TLS_BIO="compiler/src/asm/runtime_tls_mbedtls_bio.c"
NET_C="std/net/net.c"

die() {
  echo "f04-net-tls-mbedtls gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-04 v9: std.net tls_mbedtls remove tls_mbedtls.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v9' "$DOC" || die "doc missing F-04 v9 marker"
[ -f "$TLS_X" ] || die "missing tls_mbedtls.x"
[ -f "$TLS_BIO" ] || die "missing tls_mbedtls_bio.c"
[ ! -f std/net/tls_mbedtls.inc.c ] || die "tls_mbedtls.inc.c should be deleted"
grep -q 'shu_net_tls_mbedtls_marker' "$TLS_X" || die "tls_mbedtls.x missing marker"
grep -q 'net_tls_connect_client_c' "$TLS_X" || die "tls_mbedtls.x missing connect"
grep -q 'net_tls_mbedtls_smoke_c' "$TLS_X" || die "tls_mbedtls.x missing smoke"
grep -q 'shu_mbedtls_ssl_bind_fd_c' "$TLS_BIO" || die "bio.c missing bind"
if grep -q 'tls_mbedtls.inc.c' "$NET_C" 2>/dev/null; then
  die "net.c still references tls_mbedtls.inc.c"
fi
if grep -q 'SHUX_NET_USE_MBEDTLS' "$NET_C" 2>/dev/null; then
  die "net.c still defines SHUX_NET_USE_MBEDTLS include path"
fi
grep -q 'tls_mbedtls.x' compiler/Makefile || die "Makefile missing tls_mbedtls.x build"
grep -q 'std/net/tls_mbedtls.o' compiler/src/runtime_link_abi.c \
  || die "runtime_link_abi missing tls_mbedtls.o link path"

if [ -f tests/run-std-net-tls-gate.sh ]; then
  echo "=== F-04 v9: delegate run-std-net-tls-gate ==="
  chmod +x tests/run-std-net-tls-gate.sh
  if ! tests/run-std-net-tls-gate.sh; then
    die "std-net-tls sub-gate failed"
  fi
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-04 v9: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f04 std.net tls_mbedtls gate OK (F-04 v9)"
