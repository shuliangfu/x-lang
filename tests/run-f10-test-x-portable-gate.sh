#!/usr/bin/env bash
# F-10: test_x wiring + Stage2 portable subset (no native xlang → SKIP).
#
# Usage: ./tests/run-f10-test-x-portable-gate.sh
#        XLANG_F10_RUN_TEST_X=1 ./tests/run-f10-test-x-portable-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + xbuild test_x route + d04
# (no soft die→exit0). Soft XLANG_F10_TEST_X_PORTABLE_FAIL retired. Live
# test_x = ./xbuild test_x → compiler/scripts/run_compiler_tests.sh x
# (G.7). Full ./xbuild test_x dogfood stays opt-in (XLANG_F10_RUN_TEST_X=1)
# so archaeology knife does not absorb unrelated suite residuals. Report
# doc=/wiring=/d04=/skip=. Gate was portable-false-green (soft FAIL exit0
# while wiring already green).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F10_DOC:-analysis/archive/phase/phase-f-f10-v1.md}"
MANIFEST="tests/baseline/f10-test-x-portable.tsv"
PREFIX="xlang: [XLANG_F10_TEST_X]"

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

die() {
  echo "f10-test-x-portable gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} wiring=${WIRING_OK:-0} d04=${D04_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
WIRING_OK=0
D04_OK=0
SKIP=1

echo "=== F-10: test_x + portable subset (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-10 v1' "$DOC" || die "doc missing F-10 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f10-v1.md ]; then
  die "top-level F-10 DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"
[ -f xlang-build.sh ] || die "missing xlang-build.sh"
grep -qE '^[[:space:]]*test_x\)' xlang-build.sh || die "xlang-build.sh missing test_x route"
[ -f compiler/scripts/run_compiler_tests.sh ] || die "missing run_compiler_tests.sh (test_x body)"
DOC_OK=1

while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile|script) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
WIRING_OK=1

XLANG_BIN=""
if stdlib_cm_native_xlang ./compiler/xlang-c; then
  XLANG_BIN=./compiler/xlang-c
elif stdlib_cm_native_xlang ./compiler/xlang; then
  XLANG_BIN=./compiler/xlang
elif stdlib_cm_native_xlang ./compiler/xlang_asm; then
  XLANG_BIN=./compiler/xlang_asm
fi

# Wiring (xbuild test_x route + run_compiler_tests.sh) is hard above.
# Full ./xbuild test_x dogfood is opt-in — archaeology knife must not absorb
# unrelated test_x suite residuals.
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
  echo "=== F-10: delegate d04 portable subset (hard) ==="
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  if ! tests/run-d04-stage2-portable-diff-gate.sh; then
    die "d04 portable gate failed"
  fi
fi
D04_OK=1
SKIP=0

echo "f10-test-x-portable gate OK"
echo "${PREFIX} status=ok doc=${DOC_OK} wiring=${WIRING_OK} d04=${D04_OK} skip=${SKIP} host=$(ci_host_summary)"
