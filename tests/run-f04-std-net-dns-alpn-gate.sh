#!/usr/bin/env bash
# F-04 v10: std.net DNS/ALPN remove from net.c (dns.x + alpn.x).
#
# Usage: ./tests/run-f04-std-net-dns-alpn-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-dns-alpn-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV (no soft die→exit0). Soft
# XLANG_F04_NET_DNS_ALPN_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# STD-029 hard-delegated. Report static=/dns=/skip=. Gate was
# portable-false-green (DOC top-level; soft FAIL exit0; Makefile fossils).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested STD-029; refuse leftover ignore of
# explicit-bad). leftover nested product path (STD-029
# run-std-net-dns-gate) stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_DNS_ALPN_DOC:-analysis/archive/phase/phase-f-f04-v10.md}"
ALPN_X="std/net/alpn.x"
DNS_X="std/net/dns.x"
MANIFEST="tests/baseline/f04-std-net-dns-alpn.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_DNS_ALPN]"

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
  echo "f04-net-dns-alpn gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} dns=${DNS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
DNS_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested STD-029 (refuse leftover SKIP→OK / leftover ignore of
# explicit-bad / leftover XLANG fallthrough). leftover nested product
# path stays when XLANG is unset (do not rewrite leftover STD-029
# run-std-net-dns-gate).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-04 v10: std.net DNS/ALPN remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v10' "$DOC" || die "doc missing F-04 v10 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v10.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$ALPN_X" ] || die "missing alpn.x"
[ -f "$DNS_X" ] || die "missing dns.x"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'net_tls_alpn_h2_http1_wire_c' "$ALPN_X" || die "alpn.x missing alpn wire"
grep -q 'net_resolve_ipv4_ex_c' "$DNS_X" || die "dns.x missing resolve_ex"
grep -q 'net_resolve_ipv6_ex_c' "$DNS_X" || die "dns.x missing resolve_ipv6"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'alpn.x' "$ENSURE" || die "ensure missing alpn.x merge"
grep -q 'dns.x' "$ENSURE" || die "ensure missing dns.x merge"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      [ -f "$mod_path" ] || die "missing $mod_path"
      grep -qF "$anchor" "$mod_path" || die "manifest missing '$anchor' in $mod_path"
      ;;
    file)
      [ -f "$anchor" ] || die "missing file $anchor"
      ;;
    absent)
      # net.c deleted — absent symbols stay absent.
      if [ -f std/net/net.c ] && grep -qF "$anchor" std/net/net.c 2>/dev/null; then
        die "net.c still contains absent symbol $anchor"
      fi
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-net-dns-alpn manifest OK"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-std-net-dns-gate.sh ]; then
  die "missing tests/run-std-net-dns-gate.sh"
fi
echo "=== F-04 v10: delegate run-std-net-dns-gate (STD-029; hard) ==="
chmod +x tests/run-std-net-dns-gate.sh
# Do not re-export retired soft FAIL envs; STD-029 already hard-honesty.
if ! tests/run-std-net-dns-gate.sh; then
  die "std-net-dns sub-gate failed"
fi
DNS_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} dns=${DNS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net dns/alpn gate OK (F-04 v10; honesty)"
