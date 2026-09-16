#!/usr/bin/env bash
# F-03 aggregate: std.heap + std.fs + std.io core C-removal gate.
#
# Usage: ./tests/run-f03-std-core-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f03-std-core-gate.sh
# 2026-08-26: Honesty — hard-fail static + four child gates + inventory
# (no soft die→exit0; no soft PRODUCT_FAIL; no export of retired
# XLANG_F03_{HEAP_OPS,HEAP_LIBC,FS,IO}_FAIL). Soft XLANG_F03_CORE_FAIL /
# XLANG_F03_PRODUCT_FAIL retired. Report
# heap_ops=/heap_libc=/fs=/io=/inventory=/skip=. Children already
# prefer-asm + LINK pin. Gate was portable-false-green (soft FAIL exit0
# + soft child WARN while children already green under honesty).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# children / inventory; refuse leftover ignore of explicit-bad as parent
# fallthrough exporting asm). leftover nested children product paths stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F03_DOC:-analysis/archive/phase/phase-f-f03-closure.md}"
MANIFEST="tests/baseline/f03-std-core.tsv"
PREFIX="xlang: [XLANG_F03_CORE]"

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
  echo "f03-core gate FAIL: $*" >&2
  echo "${PREFIX} status=fail heap_ops=${HEAP_OPS_OK:-0} heap_libc=${HEAP_LIBC_OK:-0} fs=${FS_OK:-0} io=${IO_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

HEAP_OPS_OK=0
HEAP_LIBC_OK=0
FS_OK=0
IO_OK=0
INVENTORY_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE children /
# inventory (refuse leftover SKIP→OK / leftover ignore of explicit-bad /
# leftover XLANG fallthrough as parent exporting asm). leftover nested
# children product paths stay when XLANG is unset.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-03 core: heap + fs + io remove *.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03' "$DOC" || die "doc missing F-03 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/heap/heap.c ] || die "heap.c should be deleted"
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted"
[ ! -f std/io/io.c ] || die "io.c should be deleted"

if [ -f "$MANIFEST" ]; then
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
    esac
    case "$kind" in
      absent)
        [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
        ;;
      script)
        [ -f "$anchor" ] || die "manifest missing script: $anchor"
        ;;
      symbol)
        target="$mod_path"
        [ -n "$target" ] || die "manifest symbol missing mod_path for $item_id"
        [ -f "$target" ] || die "manifest target missing: $target"
        grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
        ;;
    esac
  done < "$MANIFEST"
fi
echo "f03-core manifest OK"

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
# Pin product link for child dogfood (children re-resolve; keep env honest).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

# Hard-delegate children. Do NOT export retired XLANG_F03_*_FAIL envs —
# each child is already honesty-hard (prefer-asm + inventory + smoke).
# PLATFORM: SHARED archaeology.
run_child() {
  local g="$1"
  local flag_var="$2"
  [ -f "$g" ] || die "missing $g"
  echo "=== F-03 core: delegate $(basename "$g") (hard) ==="
  chmod +x "$g"
  if ! "$g"; then
    die "$(basename "$g") sub-gate failed"
  fi
  eval "$flag_var=1"
}

run_child tests/run-f03-std-heap-ops-gate.sh HEAP_OPS_OK
run_child tests/run-f03-std-heap-libc-gate.sh HEAP_LIBC_OK
run_child tests/run-f03-std-fs-gate.sh FS_OK
run_child tests/run-f03-std-io-gate.sh IO_OK

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 core: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  # Hard-fail inventory regressions (total > baseline). total < baseline stays OK.
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi
SKIP=0

echo "${PREFIX} status=ok heap_ops=${HEAP_OPS_OK} heap_libc=${HEAP_LIBC_OK} fs=${FS_OK} io=${IO_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f03-core gate OK (F-03 aggregate; heap/fs/io .c removed; honesty)"
