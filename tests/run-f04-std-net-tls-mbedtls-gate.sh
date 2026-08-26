#!/usr/bin/env bash
# F-04 v9: std.net mbedTLS TLS remove tls_mbedtls.inc.c (tls_mbedtls.x + BIO).
#
# Usage: ./tests/run-f04-std-net-tls-mbedtls-gate.sh
# 2026-08-26: Honesty — hard-fail static archaeology + inventory (no soft
# die→exit0). Soft XLANG_F04_NET_TLS_MBEDTLS_FAIL retired. Prefer asm; pin
# XLANG_LINK_XLANG. Product TLS observational (net-tls residual). Report
# static=/inventory=/tls=/skip=. Gate was portable-false-green (DOC
# top-level; soft FAIL exit0; Makefile fossil greps).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_TLS_MBEDTLS_DOC:-analysis/archive/phase/phase-f-f04-v9.md}"
TLS_X="std/net/tls_mbedtls.x"
TLS_BIO="compiler/seeds/runtime_tls_mbedtls_bio.from_x.c"
ARCH="compiler/scripts/archaeology_host_pick_phony.sh"
LABI="compiler/src/runtime/labi_invoke_ld_list.x"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_NET_TLS_MBEDTLS]"

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
  echo "f04-net-tls-mbedtls gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} tls=${TLS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
TLS_OK=0
SKIP=1

echo "=== F-04 v9: std.net tls_mbedtls remove tls_mbedtls.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v9' "$DOC" || die "doc missing F-04 v9 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v9.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$TLS_X" ] || die "missing tls_mbedtls.x"
[ -f "$TLS_BIO" ] || die "missing runtime_tls_mbedtls_bio.from_x.c"
[ ! -f std/net/tls_mbedtls.inc.c ] || die "tls_mbedtls.inc.c should be deleted"
[ ! -f std/net/tls_mbedtls_bio.c ] || die "tls_mbedtls_bio.c should stay deleted"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'xlang_net_tls_mbedtls_marker' "$TLS_X" || die "tls_mbedtls.x missing marker"
grep -q 'net_tls_connect_client_c' "$TLS_X" || die "tls_mbedtls.x missing connect"
grep -q 'net_tls_mbedtls_smoke_c' "$TLS_X" || die "tls_mbedtls.x missing smoke"
grep -q 'xlang_mbedtls_ssl_bind_fd_c' "$TLS_BIO" || die "bio.c missing bind"
[ -f "$ARCH" ] || die "missing archaeology_host_pick_phony.sh"
grep -q 'tls_mbedtls.x' "$ARCH" || die "archaeology missing tls_mbedtls.x build"
[ -f "$LABI" ] || die "missing labi_invoke_ld_list.x"
grep -q 'std/net/tls_mbedtls.o' "$LABI" || die "labi missing tls_mbedtls.o path"
[ -f "$MK_SEED" ] || die "missing driver_seed_r_lists.mk"
grep -q 'runtime_tls_mbedtls_bio.o' "$MK_SEED" || die "mk missing runtime_tls_mbedtls_bio.o"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v9: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

echo "=== F-04 v9: run-std-net-tls-gate (observational) ==="
set +e
if [ -f tests/run-std-net-tls-gate.sh ]; then
  chmod +x tests/run-std-net-tls-gate.sh
  if tests/run-std-net-tls-gate.sh; then
    TLS_OK=1
  else
    echo "f04-net-tls-mbedtls: std-net-tls observational fail (not soft FAIL)" >&2
    TLS_OK=0
  fi
else
  echo "f04-net-tls-mbedtls: std-net-tls observational skip (missing gate)" >&2
  TLS_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} tls=${TLS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net tls_mbedtls gate OK (F-04 v9; honesty)"
