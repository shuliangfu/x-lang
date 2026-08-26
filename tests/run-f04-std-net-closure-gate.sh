#!/usr/bin/env bash
# F-04 v15: std.net hosted-path closure (v1～v14 aggregate + manifest).
#
# Usage: ./tests/run-f04-std-net-closure-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-closure-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + child gates + inventory
# (no soft die→exit0; no soft child FAIL pass-through). Soft
# XLANG_F04_NET_CLOSURE_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Report v14=/dns=/tcp_pool=/tls_stub=/ws=/static=/inventory=/skip=.
# Gate was portable-false-green (DOC top-level after archive; soft FAIL
# exit0 + soft child FAIL pass-through; Makefile content greps / TSV
# makefile_net_o after Makefile deleted). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_CLOSURE_DOC:-analysis/archive/phase/phase-f-f04-v15.md}"
MANIFEST="tests/baseline/f04-std-net-closure.tsv"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_NET_CLOSURE]"

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
  echo "f04-net-closure gate FAIL: $*" >&2
  echo "${PREFIX} status=fail v14=${V14_OK:-0} dns=${DNS_OK:-0} tcp_pool=${TCP_POOL_OK:-0} tls_stub=${TLS_STUB_OK:-0} ws=${WS_OK:-0} static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

V14_OK=0
DNS_OK=0
TCP_POOL_OK=0
TLS_STUB_OK=0
WS_OK=0
STATIC_OK=0
INVENTORY_OK=0
SKIP=1

echo "=== F-04 v15: std.net hosted path closure (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-04 v15' "$DOC" || die "doc missing F-04 v15 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v15.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$MK_SEED" ] || die "missing driver_seed_r_lists.mk"
[ ! -f std/net/net.c ] || die "std/net/net.c must stay deleted"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'runtime_net_workers.o' "$MK_STD" || die "mk missing runtime_net_workers.o"
grep -q 'runtime_net_udp_batch.o' "$MK_STD" || die "mk missing runtime_net_udp_batch.o"
grep -q 'runtime_net_workers.o' "$MK_SEED" || die "seed mk missing runtime_net_workers.o"
grep -q 'workers.x' "$ENSURE" || die "ensure missing workers.x"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    file|doc|gate|script|manifest)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f04-net-closure manifest OK"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

xlang_compiler_make ../std/net/net.o >/dev/null 2>&1 || die "ensure net.o failed (xlang_compiler_make)"

# Hard-delegate children. Do NOT export retired XLANG_F04_NET_*_FAIL envs.
# PLATFORM: SHARED archaeology.
run_child() {
  local g="$1"
  local flag_var="$2"
  [ -f "$g" ] || die "missing $g"
  echo "=== F-04 v15: delegate $(basename "$g") (hard) ==="
  chmod +x "$g"
  if ! "$g"; then
    die "$(basename "$g") sub-gate failed"
  fi
  eval "$flag_var=1"
}

# v14 cascade covers dns-alpn through workers (v10～v14).
run_child tests/run-f04-std-net-slice-v14-gate.sh V14_OK
# Explicit leaf gates also covered by closure TSV / historical delegates.
run_child tests/run-f04-std-net-dns-alpn-gate.sh DNS_OK
run_child tests/run-f04-std-net-tcp-pool-gate.sh TCP_POOL_OK
run_child tests/run-f04-std-net-tls-stub-gate.sh TLS_STUB_OK
run_child tests/run-f04-std-net-ws-gate.sh WS_OK

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-04 v15: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1
SKIP=0

echo "${PREFIX} status=ok v14=${V14_OK} dns=${DNS_OK} tcp_pool=${TCP_POOL_OK} tls_stub=${TLS_STUB_OK} ws=${WS_OK} static=${STATIC_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net closure gate OK (F-04 v15; honesty)"
