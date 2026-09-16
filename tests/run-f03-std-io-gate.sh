#!/usr/bin/env bash
# F-03 v2/v3：std.io 去 C 门禁（backend.x + 无 io.c/io.o）。
#
# 用法：./tests/run-f03-std-io-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f03-std-io-gate.sh
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; static + inventory +
# run-io hard-fail (no soft die→exit0; no soft SKIP→OK when no native;
# no prefer-c). Report inventory=/run=/skip=. Gate was portable-false-green
# (prefer xlang-c / soft FAIL exit0 / SKIP runtime still OK while asm run-io
# already green).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# inventory / nested run-io; refuse leftover ignore of explicit-bad).
# leftover nested product path (inventory / run-io) stay. G.7: complete
# existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F03_IO_DOC:-analysis/archive/phase/phase-f-f03-v2-io.md}"
BACKEND="std/io/backend.x"
CORE="std/io/core.x"
PREFIX="xlang: [XLANG_F03_IO]"

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
  echo "f03-io gate FAIL: $*" >&2
  echo "${PREFIX} status=fail inventory=${INVENTORY_OK:-0} run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

INVENTORY_OK=0
RUN_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE inventory /
# nested run-io (refuse leftover SKIP→OK / leftover ignore of explicit-bad
# / leftover XLANG fallthrough). leftover nested product path stays when
# XLANG is unset (do not rewrite leftover inventory / run-io).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-03 v2/v3: std.io remove io.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-03 v2/v3' "$DOC" || die "doc missing F-03 v2/v3 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ ! -f std/io/io.c ] || die "io.c should be deleted"
[ -f std/io/sync.x ] || die "missing sync.x"
[ -f std/io/win32.x ] || die "missing win32.x"
[ -f std/io/read_ptr.x ] || die "missing read_ptr.x"
[ -f std/io/stubs.x ] || die "missing stubs.x"
[ -f "$BACKEND" ] || die "missing backend.x"
grep -q 'function io_read(' "$BACKEND" || die "io_backend missing io_read"
grep -q 'import("std.io.backend")' "$CORE" || die "core.x missing backend import"
if grep -q 'extern function io_read' "$CORE" 2>/dev/null; then
  die "core.x still extern io_read"
fi
if grep -q 'link_abi_asm_ld_push_obj.*std/io/io.o' compiler/seeds/runtime_link_abi.from_x.c 2>/dev/null; then
  die "runtime_link_abi.inc still pushes std/io/io.o"
fi
grep -q 'xlang_io_uring_is_available_c' std/io/stubs.x || die "io_stubs missing uring probe"
echo "f03-io manifest OK"

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-03 v2/v3: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  # Hard-fail inventory regressions (total > baseline). total < baseline stays OK.
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi

echo "=== F-03 v2/v3: run-io (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Avoid subscript make rebuilding prefer-c side path during dogfood.
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-io.sh ]; then
  die "missing tests/run-io.sh"
fi
chmod +x tests/run-io.sh
if ! tests/run-io.sh; then
  die "run-io sub-gate failed"
fi
RUN_OK=1
SKIP=0

echo "${PREFIX} status=ok inventory=${INVENTORY_OK} run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f03-io gate OK (F-03 v2/v3; io.c removed; honesty)"
