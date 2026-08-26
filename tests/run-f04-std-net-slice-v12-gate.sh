#!/usr/bin/env bash
# F-04 v12: std.net sock/udp basic remove from net.c.
#
# Usage: ./tests/run-f04-std-net-slice-v12-gate.sh
# 2026-08-26: Honesty — hard-fail static (no soft die→exit0). Soft
# XLANG_F04_NET_SLICE_V12_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Report static=/v11=/skip=. Gate was portable-false-green (DOC top-level;
# soft FAIL exit0; Makefile fossils). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_SLICE_V12_DOC:-analysis/archive/phase/phase-f-f04-v12.md}"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_SLICE_V12]"

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
  echo "f04-net-slice-v12 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} v11=${V11_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
V11_OK=0
SKIP=1

echo "=== F-04 v12: std.net sock/udp basic remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v12' "$DOC" || die "doc missing F-04 v12 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v12.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
[ -f std/net/sock.x ] || die "missing sock.x"
[ -f std/net/udp.x ] || die "missing udp.x"
grep -q 'net_close_socket_c' std/net/sock.x || die "sock.x missing close"
grep -q 'net_set_blocking_c' std/net/sock.x || die "sock.x missing set_blocking"
grep -q 'net_udp_bind_c' std/net/udp.x || die "udp.x missing bind"
grep -q 'net_udp_recv_from_c' std/net/udp.x || die "udp.x missing recv_from"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'sock.x' "$ENSURE" || die "ensure missing sock.x merge"
grep -q 'udp.x' "$ENSURE" || die "ensure missing udp.x merge"
if [ -f std/net/udp_batch.x ]; then
  grep -q 'net_udp_recv_from_c' std/net/udp_batch.x || die "udp_batch.x should use net_udp_recv_from_c"
fi
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-f04-std-net-slice-v11-gate.sh ]; then
  die "missing tests/run-f04-std-net-slice-v11-gate.sh"
fi
echo "=== F-04 v12: delegate v11 gate (hard) ==="
chmod +x tests/run-f04-std-net-slice-v11-gate.sh
if ! tests/run-f04-std-net-slice-v11-gate.sh; then
  die "v11 sub-gate failed"
fi
V11_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} v11=${V11_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net slice v12 gate OK (F-04 v12; honesty)"
