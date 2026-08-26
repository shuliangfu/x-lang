#!/usr/bin/env bash
# F-04 v1: std.net TLS stub remove tls_stub.inc.c (tls_stub.x).
#
# Usage: ./tests/run-f04-std-net-tls-stub-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-tls-stub-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory (no soft die→exit0).
# Soft XLANG_F04_NET_TLS_STUB_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Product run-std-net-tls-gate observational (net-tls residual). Report
# static=/inventory=/tls=/skip=. Gate was portable-false-green (DOC still
# pointed at top-level analysis/phase-f-f04-v1.md after archive; soft FAIL
# printed then exit0; Makefile fossil greps after Makefile deleted).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_TLS_STUB_DOC:-analysis/archive/phase/phase-f-f04-v1.md}"
TLS_STUB="std/net/tls_stub.x"
NET_MOD="std/net/mod.x"
MANIFEST="tests/baseline/f04-std-net-tls-stub.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_TLS_STUB]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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
  echo "f04-net-tls-stub gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} tls=${TLS_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
TLS_OK=0
SKIP=1

echo "=== F-04 v1: std.net tls_stub remove tls_stub.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v1' "$DOC" || die "doc missing F-04 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$TLS_STUB" ] || die "missing tls_stub.x"
[ ! -f std/net/tls_stub.inc.c ] || die "tls_stub.inc.c should be deleted"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'net_tls_is_available_c' "$TLS_STUB" || die "tls_stub missing net_tls_is_available_c"
grep -q 'net_tls_last_error_c' "$TLS_STUB" || die "tls_stub missing net_tls_last_error_c"
grep -q 'import("std.net.tls_stub")' "$NET_MOD" || die "mod.x missing tls_stub import"
if grep -q 'extern function net_tls_is_available_c' "$NET_MOD" 2>/dev/null; then
  die "mod.x still extern net_tls_is_available_c"
fi
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'tls_stub' "$ENSURE" || die "ensure missing tls_stub merge"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$TLS_STUB"
      case "$mod_path" in
        std/net/mod.x) target="$NET_MOD" ;;
      esac
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-net-tls-stub manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v1: delegate run-std-c-inventory-gate (F-01; hard) ==="
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

# Product TLS dogfood is observational (tip: net-tls still skip / residual).
# PLATFORM: SHARED archaeology — static+inventory already hard.
echo "=== F-04 v1: run-std-net-tls-gate (observational) ==="
set +e
if [ -f tests/run-std-net-tls-gate.sh ]; then
  chmod +x tests/run-std-net-tls-gate.sh
  if tests/run-std-net-tls-gate.sh; then
    TLS_OK=1
  else
    echo "f04-net-tls-stub: std-net-tls observational fail (not soft FAIL)" >&2
    TLS_OK=0
  fi
else
  echo "f04-net-tls-stub: std-net-tls observational skip (missing gate)" >&2
  TLS_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} tls=${TLS_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net tls stub gate OK (F-04 v1; honesty)"
