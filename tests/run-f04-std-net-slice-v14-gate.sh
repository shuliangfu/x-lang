#!/usr/bin/env bash
# F-04 v14: std.net accept workers remove from net.c; net.c deleted.
#
# Usage: ./tests/run-f04-std-net-slice-v14-gate.sh
# 2026-08-26: Honesty — hard-fail static + ensure runtime_net_workers.o
# (no soft die→exit0). Soft XLANG_F04_NET_SLICE_V14_FAIL retired. Prefer
# asm; pin XLANG_LINK_XLANG. Report static=/v13b=/skip=. Gate was
# portable-false-green (DOC top-level; soft FAIL exit0; Makefile fossils).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_F04_NET_SLICE_V14_DOC:-analysis/archive/phase/phase-f-f04-v14.md}"
NET_RUNTIME="compiler/seeds/runtime_net_workers.from_x.c"
ENSURE="compiler/scripts/ensure_host_cc_seed_o.sh"
MK_STD="compiler/mk/std_and_panic_objs.mk"
MK_SEED="compiler/mk/driver_seed_r_lists.mk"
PREFIX="xlang: [XLANG_F04_NET_SLICE_V14]"

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
  echo "f04-net-slice-v14 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} v13b=${V13B_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
V13B_OK=0
SKIP=1

echo "=== F-04 v14: std.net workers remove from net.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-04 v14' "$DOC" || die "doc missing F-04 v14 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f04-v14.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$ENSURE" ] || die "missing ensure_host_cc_seed_o.sh"
[ -f "$MK_STD" ] || die "missing std_and_panic_objs.mk"
[ -f "$MK_SEED" ] || die "missing driver_seed_r_lists.mk"
[ ! -f std/net/net.c ] || die "std/net/net.c should be deleted"
[ -f std/net/workers.x ] || die "missing workers.x"
[ -f "$NET_RUNTIME" ] || die "missing runtime_net_workers.from_x.c"
[ ! -f std/net/workers_glue.c ] || die "workers_glue.c should be deleted"
grep -q 'net_run_accept_workers_c' std/net/workers.x || die "workers.x missing API"
grep -q 'xlang_net_worker_accept_entry_ptr_c' std/net/workers.x || die "workers.x missing entry_ptr extern"
grep -q 'xlang_net_worker_accept_entry_ptr_c' "$NET_RUNTIME" || die "runtime missing entry ptr"
grep -q '../std/net/net.o' "$MK_STD" || die "mk missing net.o"
grep -q 'runtime_net_workers.o' "$MK_STD" || die "mk missing runtime_net_workers.o"
grep -q 'runtime_net_workers.o' "$MK_SEED" || die "seed mk missing runtime_net_workers.o"
grep -q 'workers.x' "$ENSURE" || die "ensure missing workers.x merge"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

xlang_compiler_make runtime_net_workers.o >/dev/null 2>&1 || die "ensure runtime_net_workers.o failed"

if [ ! -f tests/run-f04-std-net-slice-v13b-gate.sh ]; then
  die "missing tests/run-f04-std-net-slice-v13b-gate.sh"
fi
echo "=== F-04 v14: delegate v13b gate (hard) ==="
chmod +x tests/run-f04-std-net-slice-v13b-gate.sh
if ! tests/run-f04-std-net-slice-v13b-gate.sh; then
  die "v13b sub-gate failed"
fi
V13B_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} v13b=${V13B_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f04 std.net slice v14 gate OK (F-04 v14; honesty)"
