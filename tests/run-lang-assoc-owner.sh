#!/usr/bin/env bash
# LANG-005: associated-call owner binding smoke (positive + negatives) and
# the bound_method quartet regression.
#
# Covers the impl-method owner sidecar: `X.g()` must bind X's own impl
# (cross-impl bleed), an empty impl must not satisfy the receiver, and a
# struct with no impl must not borrow a same-named method. Also pins the
# bound_method quartet expectations (they had no committed runner before).
#
# Honesty: no soft SKIP→OK; a missing native xlang is a hard die (this is
# the live product face). Prefer product xlang_asm; explicit XLANG wins.
#
# Usage: ./tests/run-lang-assoc-owner.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_LANG_ASSOC_OWNER]"
RUN_OK=0
NEG_OK=0

die() {
  echo "lang-assoc-owner FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} neg=${NEG_OK} host=$(ci_host_summary)"
  exit 1
}

resolve_bin() {
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

run_pos() {
  # run_pos <file> <expected-exit> — compile=0 then run must exit expected.
  local f="$1" want="$2" out ec
  out="/tmp/xlang_assoc_owner_$(basename "$f" .x)"
  rm -f "$out"
  "$XLANG_BIN" -o "$out" "$f" >/dev/null 2>&1 || die "$f compile failed (expected 0)"
  ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  [ "$ec" -eq "$want" ] || die "$f run expected $want, got $ec"
  RUN_OK=$((RUN_OK + 1))
}

run_neg() {
  # run_neg <file> — compile must fail cleanly.
  local f="$1" out
  out="/tmp/xlang_assoc_owner_$(basename "$f" .x)"
  rm -f "$out"
  if "$XLANG_BIN" -o "$out" "$f" >/dev/null 2>&1; then
    die "$f compiled (expected reject)"
  fi
  [ ! -f "$out" ] || die "$f rejected but left an artifact"
  NEG_OK=$((NEG_OK + 1))
}

XLANG_BIN="$(resolve_bin)" || die "no native xlang/xlang_asm/xlang-c"

echo "=== LANG-005: assoc owner binding (XLANG=$XLANG_BIN) ==="
run_pos tests/boundary/assoc_owner_cross_impl.x 9
echo "lang-assoc-owner OK cross_impl (run=9)"
run_neg tests/boundary/assoc_owner_empty_impl.x
echo "lang-assoc-owner OK empty_impl reject"
run_neg tests/boundary/assoc_owner_no_impl.x
echo "lang-assoc-owner OK no_impl reject"

# bound_method quartet (previously only exercised by ad-hoc differentials).
run_pos tests/boundary/bound_method.x 7
echo "lang-assoc-owner OK bound_method (run=7)"
run_pos tests/boundary/bound_method_self.x 7
echo "lang-assoc-owner OK bound_method_self (run=7)"
run_neg tests/boundary/bound_method_nobound.x
echo "lang-assoc-owner OK bound_method_nobound reject"
run_neg tests/boundary/bound_method_wrong.x
echo "lang-assoc-owner OK bound_method_wrong reject"

echo "${PREFIX} status=ok run=${RUN_OK} neg=${NEG_OK} host=$(ci_host_summary)"
echo "lang-assoc-owner OK"
