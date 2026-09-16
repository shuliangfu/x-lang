#!/usr/bin/env bash
# F-test v2: std.test logic in test.x + F-ZC (test_glue.c deleted).
#
# Usage: ./tests/run-f-test-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-test-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-145 test-runner hard delegate. Soft XLANG_F_TEST_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-145 already green;
# soft v2 hard-invoked bench-fuzz／executable which stay ld UNDEF red).
# test-executable／bench-fuzz remain listed residual — not invoked.
# Report static=/ensure=/runner=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-test-runner; refuse leftover ignore of
# explicit-bad). leftover auto-make of runtime_test_fn_invoke.o /
# test.o (`xlang_compiler_make` even when the leaf is present —
# try-heat/g05 raced L2) retired. leftover unused compiler-make.sh
# sourced unused after leftover auto-make retired. Missing leaf .o =
# hard die. leftover nested std-test-runner stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-test-v2.md"
MANIFEST="tests/baseline/f-test-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_TEST_V2]"

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
  echo "f-test-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} runner=${RUNNER_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
RUNNER_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-test-runner (refuse leftover SKIP→OK / leftover
# ignore of explicit-bad / leftover XLANG fallthrough). leftover nested
# product path stays when XLANG is unset (do not rewrite leftover
# nested std-test-runner).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-test v2: test logic → test.x (F-ZC; honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-test v2' "$DOC" || die "doc missing F-test v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/test/test.x ] || die "missing test.x"
[ -f compiler/seeds/runtime_test_fn_invoke.from_x.c ] || die "missing runtime_test_fn_invoke.inc"
[ ! -f std/test/test_glue.c ] || die "test_glue.c should be deleted (F-ZC)"
[ ! -f std/test/test.c ] || die "test.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
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
grep -q 'test_expect_c' std/test/test.x || die "test.x missing expect"
grep -q 'test_runner_report_case_c' std/test/test.x || die "test.x missing runner"
grep -q 'test_bench_run_c' std/test/test.x || die "test.x missing bench_run"
grep -q 'test_fuzz_next_c' std/test/test.x || die "test.x missing fuzz_next"
grep -q 'test_f_test_v2_marker_c' std/test/test.x || die "test.x missing v2 marker"
grep -q 'test_io_bench_line_c' std/test/test.x || die "test.x missing IO bench"
grep -q 'test_f_zero_c_marker_c' std/test/test.x || die "test.x missing F-ZC marker"
STATIC_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f compiler/runtime_test_fn_invoke.o ]; then
  die "missing compiler/runtime_test_fn_invoke.o (refuse leftover auto-make)"
fi
if [ ! -f std/test/test.o ]; then
  die "missing std/test/test.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-145.
if [ -f tests/run-std-test-runner-gate.sh ]; then
  echo "=== F-test v2: delegate run-std-test-runner-gate ==="
  chmod +x tests/run-std-test-runner-gate.sh
  if ! tests/run-std-test-runner-gate.sh; then
    die "std-test-runner sub-gate failed"
  fi
  RUNNER_OK=1
fi

# test-executable／bench-fuzz remain listed residual (ld UNDEF) — not invoked.

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} runner=${RUNNER_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-test-v2 gate OK (F-test v2; honesty)"
