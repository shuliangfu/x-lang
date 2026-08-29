#!/usr/bin/env bash
# F-04 v8: std.net OpenSSL TLS remove tls_openssl.inc.c (tls_openssl.x).
#
# Usage: ./tests/run-f04-std-net-tls-openssl-gate.sh
# 2026-08-26: Honesty — hard-fail static archaeology + inventory (no soft
# die→exit0). Soft XLANG_F04_NET_TLS_OPENSSL_FAIL retired. Prefer asm; pin
# XLANG_LINK_XLANG. Product TLS observational (net-tls residual). Report
# static=/inventory=/tls=/skip=. Gate was portable-false-green (DOC
# top-level; soft FAIL exit0; Makefile fossil greps).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / nested leftover inventory / leftover observational
# run-std-net-tls-gate; refuse leftover ignore of explicit-bad). leftover
# nested product path (inventory / observational net-tls) stay.
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

DOC="${XLANG_F04_NET_TLS_OPENSSL_DOC:-analysis/archive/phase/phase-f-f04-v8.md}"
TLS_X="std/net/tls_openssl.x"
ARCH="compiler/scripts/archaeology_host_pick_phony.sh"
LABI="compiler/src/runtime/labi_invoke_ld_list.x"
LINK_ABI="compiler/seeds/runtime_link_abi.from_x.c"
PREFIX="xlang: [XLANG_F04_NET_TLS_OPENSSL]"

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
  echo "f04-net-tls-openssl gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} tls=${TLS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
TLS_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# nested leftover inventory / leftover observational net-tls (refuse
# leftover SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover inventory / observational run-std-net-tls-gate).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-04 v8: std.net tls_openssl remove tls_openssl.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v8' "$DOC" || die "doc missing F-04 v8 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v8.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$TLS_X" ] || die "missing tls_openssl.x"
[ ! -f std/net/tls_openssl.inc.c ] || die "tls_openssl.inc.c should be deleted"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'xlang_net_tls_openssl_marker' "$TLS_X" || die "tls_openssl.x missing marker"
grep -q 'net_tls_connect_client_c' "$TLS_X" || die "tls_openssl.x missing connect"
grep -q 'net_tls_openssl_smoke_c' "$TLS_X" || die "tls_openssl.x missing smoke"
[ -f "$ARCH" ] || die "missing archaeology_host_pick_phony.sh"
grep -q 'tls_openssl.x' "$ARCH" || die "archaeology missing tls_openssl.x build"
[ -f "$LABI" ] || die "missing labi_invoke_ld_list.x"
grep -q 'std/net/tls_openssl.o' "$LABI" || die "labi missing tls_openssl.o path"
[ -f "$LINK_ABI" ] || die "missing runtime_link_abi.from_x.c"
grep -q 'invoke_cc_append_net_tls_ld' "$LINK_ABI" || die "runtime_link_abi missing tls ld helper"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v8: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

echo "=== F-04 v8: run-std-net-tls-gate (observational) ==="
set +e
if [ -f tests/run-std-net-tls-gate.sh ]; then
  chmod +x tests/run-std-net-tls-gate.sh
  if tests/run-std-net-tls-gate.sh; then
    TLS_OK=1
  else
    echo "f04-net-tls-openssl: std-net-tls observational fail (not soft FAIL)" >&2
    TLS_OK=0
  fi
else
  echo "f04-net-tls-openssl: std-net-tls observational skip (missing gate)" >&2
  TLS_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} tls=${TLS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net tls_openssl gate OK (F-04 v8; honesty)"
