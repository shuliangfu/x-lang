#!/usr/bin/env bash
# F-04 v13b: std.net UDP batch remove from net.c (udp_batch.x + runtime).
#
# Usage: ./tests/run-f04-std-net-slice-v13b-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f04-std-net-slice-v13b-gate.sh
# 2026-08-26: Honesty — hard-fail static + ensure runtime_net_udp_batch.o
# (no soft die→exit0). Soft XLANG_F04_NET_SLICE_V13B_FAIL retired. Prefer
# asm; pin XLANG_LINK_XLANG. Report static=/v13=/skip=. Gate was
# portable-false-green (DOC top-level; soft FAIL exit0; Makefile fossils).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / nested v13 / xlang_compiler_make; refuse leftover ignore of
# explicit-bad). leftover nested product path (v11 leftover nested
# dns-alpn / xlang_compiler_make) stay.
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

DOC="${XLANG_F04_NET_SLICE_V13B_DOC:-analysis/archive/phase/phase-f-f04-v13b.md}"
NET_RUNTIME="compiler/seeds/runtime_net_udp_batch.from_x.c"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_NET_SLICE_V13B]"

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
  echo "f04-net-slice-v13b gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} v13=${V13_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
V13_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# nested v13 / xlang_compiler_make (refuse leftover SKIP→OK / leftover
# ignore of explicit-bad / leftover XLANG fallthrough). leftover nested
# product path stays when XLANG is unset (do not rewrite leftover nested
# dns-alpn / xlang_compiler_make).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-04 v13b: std.net UDP batch remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v13b' "$DOC" || die "doc missing F-04 v13b marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v13b.md ]; then
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
[ -f std/net/udp_batch.x ] || die "missing udp_batch.x"
[ -f "$NET_RUNTIME" ] || die "missing runtime_net_udp_batch.from_x.c"
[ ! -f std/net/udp_batch_glue.c ] || die "udp_batch_glue.c should be deleted"
grep -q 'net_udp_recv_many_c' std/net/udp_batch.x || die "udp_batch.x missing recv_many"
grep -q 'net_udp_send_many_buf_c' std/net/udp_batch.x || die "udp_batch.x missing send_many_buf"
grep -q 'xlang_net_udp_recvmmsg2_c' "$NET_RUNTIME" || die "runtime missing recvmmsg2"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'runtime_net_udp_batch.o' "$MK_STD" || die "mk missing runtime_net_udp_batch.o"
grep -q 'runtime_net_udp_batch.o' "$MK_SEED" || die "seed mk missing runtime_net_udp_batch.o"
grep -q 'udp_batch.x' "$ENSURE" || die "ensure missing udp_batch.x merge"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

xlang_compiler_make runtime_net_udp_batch.o >/dev/null 2>&1 || die "ensure runtime_net_udp_batch.o failed"

if [ ! -f tests/run-f04-std-net-slice-v13-gate.sh ]; then
  die "missing tests/run-f04-std-net-slice-v13-gate.sh"
fi
echo "=== F-04 v13b: delegate v13 gate (hard) ==="
chmod +x tests/run-f04-std-net-slice-v13-gate.sh
if ! tests/run-f04-std-net-slice-v13-gate.sh; then
  die "v13 sub-gate failed"
fi
V13_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} v13=${V13_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net slice v13b gate OK (F-04 v13b; honesty)"
