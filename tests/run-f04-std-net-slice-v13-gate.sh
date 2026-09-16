#!/usr/bin/env bash
# F-04 v13: std.net IPv4 TCP core remove from net.c (tcp.x).
#
# Usage: ./tests/run-f04-std-net-slice-v13-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-slice-v13-gate.sh
# 2026-08-26: Honesty — hard-fail static (no soft die→exit0). Soft
# XLANG_F04_NET_SLICE_V13_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Report static=/v12=/skip=. Gate was portable-false-green (DOC top-level;
# soft FAIL exit0; Makefile fossils).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / nested v12; refuse leftover ignore of explicit-bad). leftover
# nested product path (v11 leftover nested dns-alpn) stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. G.7: complete existing resolve_shu;
# drop unused compiler-make.sh; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F04_NET_SLICE_V13_DOC:-analysis/archive/phase/phase-f-f04-v13.md}"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_SLICE_V13]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f04-net-slice-v13 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} v12=${V12_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
V12_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# nested v12 (refuse leftover SKIP→OK / leftover ignore of explicit-bad /
# leftover XLANG fallthrough). leftover nested product path stays when
# XLANG is unset (do not rewrite leftover nested dns-alpn).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-04 v13: std.net TCP core remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v13' "$DOC" || die "doc missing F-04 v13 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v13.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
[ -f std/net/tcp.x ] || die "missing tcp.x"
grep -q 'net_tcp_connect_c' std/net/tcp.x || die "tcp.x missing connect"
grep -q 'net_tcp_listen_c' std/net/tcp.x || die "tcp.x missing listen"
grep -q 'net_accept_c' std/net/tcp.x || die "tcp.x missing accept"
grep -q 'net_accept_many_c' std/net/tcp.x || die "tcp.x missing accept_many"
grep -q 'net_connect_many_c' std/net/tcp.x || die "tcp.x missing connect_many"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'tcp.x' "$ENSURE" || die "ensure missing tcp.x merge"
if [ -f std/net/workers.x ]; then
  grep -q 'net_run_accept_workers_c' std/net/workers.x || die "workers.x missing run_accept_workers"
fi
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-f04-std-net-slice-v12-gate.sh ]; then
  die "missing tests/run-f04-std-net-slice-v12-gate.sh"
fi
echo "=== F-04 v13: delegate v12 gate (hard) ==="
chmod +x tests/run-f04-std-net-slice-v12-gate.sh
if ! tests/run-f04-std-net-slice-v12-gate.sh; then
  die "v12 sub-gate failed"
fi
V12_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} v12=${V12_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net slice v13 gate OK (F-04 v13; honesty)"
