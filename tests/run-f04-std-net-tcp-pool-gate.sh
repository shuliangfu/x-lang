#!/usr/bin/env bash
# F-04 v2: std.net tcp_pool remove tcp_pool.inc.c (tcp_pool.x).
#
# Usage: ./tests/run-f04-std-net-tcp-pool-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-tcp-pool-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory (no soft die→exit0).
# Soft XLANG_F04_NET_TCP_POOL_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# xlang check observational (check gate paused). Report
# static=/inventory=/check=/skip=. Gate was portable-false-green (DOC
# top-level after archive; soft FAIL exit0; Makefile fossils).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_TCP_POOL_DOC:-analysis/archive/phase/phase-f-f04-v2.md}"
TCP_POOL="std/net/tcp_pool.x"
NET_MOD="std/net/mod.x"
MANIFEST="tests/baseline/f04-std-net-tcp-pool.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_TCP_POOL]"

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
  echo "f04-net-tcp-pool gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} check=${CHECK_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CHECK_OK=0
SKIP=1

echo "=== F-04 v2: std.net tcp_pool remove tcp_pool.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v2' "$DOC" || die "doc missing F-04 v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v2.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$TCP_POOL" ] || die "missing tcp_pool.x"
[ ! -f std/net/tcp_pool.inc.c ] || die "tcp_pool.inc.c should be deleted"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q 'net_tcp_pool_create_c' "$TCP_POOL" || die "tcp_pool missing create"
grep -q 'net_tcp_pool_smoke_c' "$TCP_POOL" || die "tcp_pool missing smoke"
grep -q 'import("std.net.tcp_pool")' "$NET_MOD" || die "mod.x missing tcp_pool import"
if grep -q 'extern function net_tcp_pool_create_c' "$NET_MOD" 2>/dev/null; then
  die "mod.x still extern net_tcp_pool_create_c"
fi
grep -q 'tcp_pool_new' "$NET_MOD" || die "mod.x missing tcp_pool_new"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'tcp_pool' "$ENSURE" || die "ensure missing tcp_pool merge"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$TCP_POOL"
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
echo "f04-net-tcp-pool manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v2: delegate run-std-c-inventory-gate (F-01; hard) ==="
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

# check gate paused — observational only.
# PLATFORM: SHARED archaeology.
echo "=== F-04 v2: typecheck tcp_pool_smoke.x (observational) ==="
set +e
if [ -f tests/net/tcp_pool_smoke.x ]; then
  if "$XLANG_BIN" check -L . tests/net/tcp_pool_smoke.x >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "f04-net-tcp-pool: check observational fail (not soft FAIL)" >&2
    CHECK_OK=0
  fi
else
  echo "f04-net-tcp-pool: check observational skip (no smoke.x)" >&2
  CHECK_OK=0
fi
set -e
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} check=${CHECK_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net tcp_pool gate OK (F-04 v2; honesty)"
