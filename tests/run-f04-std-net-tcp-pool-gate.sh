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
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / nested leftover inventory / leftover observational check;
# refuse leftover ignore of explicit-bad). leftover nested product path
# (inventory / observational check) stay.
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

DOC="${XLANG_F04_NET_TCP_POOL_DOC:-analysis/archive/phase/phase-f-f04-v2.md}"
TCP_POOL="std/net/tcp_pool.x"
NET_MOD="std/net/mod.x"
MANIFEST="tests/baseline/f04-std-net-tcp-pool.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
PREFIX="xlang: [XLANG_F04_NET_TCP_POOL]"

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
  echo "f04-net-tcp-pool gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} check=${CHECK_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
CHECK_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# nested leftover inventory / leftover observational check (refuse
# leftover SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover inventory / observational check).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

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

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
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
