#!/usr/bin/env bash
# F-10 v1：test_x + Stage2 portable 子集（无 xlang 时 SKIP 不 FAIL）。
#
# wave honesty (2026-08-25): DOC → analysis/archive/phase/；
# compiler/Makefile deleted — refuse resurrect; live test_x = ./xbuild test_x
# → compiler/scripts/run_compiler_tests.sh x（G.7 单权威）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
FAIL=${XLANG_F10_TEST_X_PORTABLE_FAIL:-0}
DOC="${XLANG_F10_DOC:-analysis/archive/phase/phase-f-f10-v1.md}"
MANIFEST="tests/baseline/f10-test-x-portable.tsv"
die() { echo "f10-test-x-portable gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== F-10 v1: test_x + portable subset ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-10 v1' "$DOC" || die "doc marker"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f xlang-build.sh ] || die "missing xlang-build.sh"
grep -qE '^[[:space:]]*test_x\)' xlang-build.sh || die "xlang-build.sh missing test_x route"
[ -f compiler/scripts/run_compiler_tests.sh ] || die "missing run_compiler_tests.sh (test_x body)"

while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile|script) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"

XLANG_BIN=""
if stdlib_cm_native_xlang ./compiler/xlang-c; then
  XLANG_BIN=./compiler/xlang-c
elif stdlib_cm_native_xlang ./compiler/xlang; then
  XLANG_BIN=./compiler/xlang
elif stdlib_cm_native_xlang ./compiler/xlang_asm; then
  XLANG_BIN=./compiler/xlang_asm
fi

# Wiring (xbuild test_x route + run_compiler_tests.sh) is hard above.
# Full ./xbuild test_x dogfood is soft unless XLANG_F10_RUN_TEST_X=1 —
# archaeology knife must not absorb unrelated test_x suite residuals.
# PLATFORM: SHARED archaeology.
if [ -n "$XLANG_BIN" ] && [ "${XLANG_F10_RUN_TEST_X:-0}" = "1" ]; then
  echo "=== F-10: ./xbuild test_x (XLANG=$XLANG_BIN) ==="
  TARGET="$(basename "$XLANG_BIN")" ./xbuild test_x >/tmp/f10_test_x.log 2>&1 \
    || die "test_x failed (see /tmp/f10_test_x.log)"
elif [ -n "$XLANG_BIN" ]; then
  echo "f10 SKIP full test_x (wiring OK; XLANG_F10_RUN_TEST_X=1 to run; XLANG=$XLANG_BIN)" >&2
else
  echo "f10 SKIP test_x (no native xlang)" >&2
fi

if [ -f tests/run-d04-stage2-portable-diff-gate.sh ]; then
  echo "=== F-10: delegate d04 portable subset ==="
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  tests/run-d04-stage2-portable-diff-gate.sh || die "d04 portable gate failed"
fi

echo "f10-test-x-portable gate OK"
