#!/usr/bin/env bash
# F-04 v11: std.net addr/ipv6/io_batch remove from net.c.
#
# Usage: ./tests/run-f04-std-net-slice-v11-gate.sh
# 2026-08-26: Honesty — hard-fail static (no soft die→exit0). Soft
# XLANG_F04_NET_SLICE_V11_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# File needles = addr.x / ipv6.x / io_batch.x (fossil net_addr.x fixed).
# Report static=/dns_alpn=/skip=. Gate was portable-false-green (DOC
# top-level; soft FAIL exit0; Makefile fossils; wrong net_addr.x path
# hidden by soft die). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_SLICE_V11_DOC:-analysis/archive/phase/phase-f-f04-v11.md}"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_SLICE_V11]"

resolve_shu() {
  local cand abs
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
  echo "f04-net-slice-v11 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} dns_alpn=${DNS_ALPN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
DNS_ALPN_OK=0
SKIP=1

echo "=== F-04 v11: std.net addr/ipv6/io_batch remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v11' "$DOC" || die "doc missing F-04 v11 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v11.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
# Live file names (not fossil net_addr.x / net_ipv6.x / net_io_batch.x).
for x in addr ipv6 io_batch; do
  [ -f "std/net/${x}.x" ] || die "missing ${x}.x"
done
grep -q 'net_tcp_local_addr_c' std/net/addr.x || die "addr.x missing local"
grep -q 'net_tcp_connect_ipv6_c' std/net/ipv6.x || die "ipv6.x missing connect"
grep -q 'net_stream_read_batch_provided_c' std/net/io_batch.x || die "io_batch.x missing provided"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'io_batch.x' "$ENSURE" || die "ensure missing io_batch.x merge"
grep -q 'addr.x' "$ENSURE" || die "ensure missing addr.x merge"
grep -q 'ipv6.x' "$ENSURE" || die "ensure missing ipv6.x merge"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-f04-std-net-dns-alpn-gate.sh ]; then
  die "missing tests/run-f04-std-net-dns-alpn-gate.sh"
fi
echo "=== F-04 v11: delegate f04 dns/alpn gate (hard) ==="
chmod +x tests/run-f04-std-net-dns-alpn-gate.sh
# Do not export retired XLANG_F04_NET_DNS_ALPN_FAIL.
if ! tests/run-f04-std-net-dns-alpn-gate.sh; then
  die "dns/alpn sub-gate failed"
fi
DNS_ALPN_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} dns_alpn=${DNS_ALPN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net slice v11 gate OK (F-04 v11; honesty)"
