#!/usr/bin/env bash
# EXC-002: panic/abort vs recoverable-error — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft SKIP→OK
# (no native still gate OK) + prefer-c / bootstrap-link wrap retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# Matrix run+hook hard-fail via TSV; check = obs (paused 2026-08-05).
# Report: run=/obs=/skip=. DOC → analysis/archive/exc/.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-exc-panic-abort-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_EXC_PANIC_ABORT_DOC:-analysis/archive/exc/exc-panic-abort-v1-rfc.md}"
MATRIX="${XLANG_EXC_PANIC_ABORT_TSV:-tests/baseline/exc-panic-abort.tsv}"
SMOKE="tests/exc/recoverable_result.x"
MIN_CASES=7
PREFIX="${XLANG_EXC_PANIC_ABORT_PREFIX:-exc-panic-abort}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "exc-panic-abort gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== EXC-002: panic/abort boundary (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-panic-abort-v1-rfc.md ]; then
  die "top-level DOC resurrected (live = archive/exc/)"
fi
if [ -f analysis/exc-result-error-v1-rfc.md ]; then
  die "companion top-level DOC resurrected (analysis/exc-result-error-v1-rfc.md)"
fi

for f in \
  "$DOC" \
  analysis/archive/exc/exc-result-error-v1-rfc.md \
  "$MATRIX" \
  "$SMOKE" \
  tests/exc/layer_c_recoverable.x \
  tests/exc/runtime_ready.x \
  tests/exc/expect_or_panic_ok.x \
  tests/run-result.sh \
  tests/run-error.sh \
  tests/run-panic.sh; do
  [ -f "$f" ] || [ -e "$f" ] || die "missing $f"
done

for kw in EXC-002 panic abort recoverable Result; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 7. Gate' "$DOC" 2>/dev/null || die "doc missing '## 7. Gate'"

FOUND=0
while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*) continue ;;
    min_*) continue ;;
    docs)
      # TSV docs row: want_ec holds the required DOC section anchor.
      if [ -n "${want_ec:-}" ] && ! grep -qF "$want_ec" "$DOC" 2>/dev/null; then
        die "doc missing section '$want_ec'"
      fi
      continue
      ;;
  esac
  FOUND=$((FOUND + 1))
  case "$policy" in
    run)
      [ -f "tests/exc/${script}" ] || die "missing tests/exc/${script} ($case_id)"
      ;;
    hook)
      [ -f "tests/${script}" ] || die "missing tests/${script} ($case_id)"
      ;;
    *)
      die "bad policy $policy ($case_id)"
      ;;
  esac
done < "$MATRIX"

[ "$FOUND" -ge "$MIN_CASES" ] || die "cases=${FOUND} < min_cases=${MIN_CASES}"
echo "exc-panic-abort manifest OK (cases=${FOUND})"

if [ "${XLANG_EXC_PANIC_ABORT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  ok_report
  echo "exc-panic-abort gate OK (manifest only)"
  exit 0
fi

# Refuse soft auto-make — require existing native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Skip nested make inside hook scripts (refuse soft auto-make chain).
export XLANG_SKIP_SUBSCRIPT_MAKE=1
echo "XLANG=$XLANG_BIN"

echo "=== EXC-002: smoke (check observational; runnable+hook hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -eq 0 ]; then
  echo "exc-panic-abort OK check smoke (observational pass)"
else
  echo "exc-panic-abort OBS check smoke (paused 2026-08-05; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

run_x_case() {
  local script="$1"
  local want_ec="$2"
  local src="tests/exc/${script}"
  local out="/tmp/xlang_exc_panic_abort_${script%.x}_$$"
  local ec=0
  local clog="/tmp/xlang_exc_panic_abort_compile_$$.log"
  if "$XLANG_BIN" -L . "$src" -o "$out" >"$clog" 2>&1; then
    "$out" >/dev/null 2>&1 || ec=$?
    rm -f "$out"
    if [ "$ec" -ne "$want_ec" ]; then
      echo "exc-panic-abort FAIL $script: exit=$ec want=$want_ec" >&2
      return 1
    fi
    return 0
  fi
  echo "exc-panic-abort FAIL compile $script" >&2
  tail -20 "$clog" >&2 || true
  rm -f "$out"
  return 1
}

FAILS=0
while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*|docs|min_*) continue ;;
  esac
  echo "── $case_id: ${notes:-} ──"
  case "$policy" in
    run)
      if run_x_case "$script" "${want_ec:-0}"; then
        RUN_OK=$((RUN_OK + 1))
        echo "exc OK $case_id"
      else
        echo "exc FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      hook="tests/${script}"
      chmod +x "$hook" 2>/dev/null || true
      if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" XLANG_SKIP_SUBSCRIPT_MAKE=1 "$hook"; then
        RUN_OK=$((RUN_OK + 1))
        echo "exc OK $case_id ($script)"
      else
        echo "exc FAIL $case_id ($script)" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
  esac
done < "$MATRIX"

rm -f /tmp/xlang_exc_panic_abort_compile_$$.log

[ "$FAILS" -eq 0 ] || die "${FAILS} case(s)"
[ "$RUN_OK" -ge "$MIN_CASES" ] || die "run=${RUN_OK} < min_cases=${MIN_CASES}"

echo "exc-panic-abort check=obs=${OBS} run=${RUN_OK}"
ok_report
echo "exc-panic-abort gate OK"
