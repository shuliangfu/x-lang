#!/usr/bin/env bash
# STD-145: std.test runner — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary /
# prefer-c) + soft auto-make + check=/run=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product
# runner_smoke.x -o exit0 + report lines = hard run (run+=). check = obs.
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-test-runner-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD145_DOC:-analysis/archive/std/std-test-runner-v1.md}"
MANIFEST="${XLANG_STD145_TSV:-tests/baseline/std-test-runner-manifest.tsv}"
MOD_X="std/test/mod.x"
TEST_X="std/test/test.x"
LIB="tests/lib/std-test-runner.sh"
SMOKE_X="tests/std-test/runner_smoke.x"
SMOKE_EXPECT=0
MIN_APIS=4

# shellcheck source=tests/lib/std-test-runner.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-test-runner gate FAIL: $*" >&2
  std_test_runner_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-145: std.test runner manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-test-runner-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TEST_X" "$SMOKE_X" std/test/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-145 runner_case runner_finish XLANG_TEST_SUMMARY; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"
grep -qF "runner_reset" std/test/README.md 2>/dev/null || die "README missing runner_reset"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_test_runner_symbols_ok "$MOD_X" "$TEST_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-test-runner registry OK"

if [ "${XLANG_STD145_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_test_runner_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-test-runner gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-145: smoke (XLANG=$XLANG_BIN; check obs; runner_smoke product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std145_chk.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-test-runner OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED — std/test is SHARED report surface.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

OUT="/tmp/xlang_std145_runner_$$"
LOG="/tmp/xlang_std145_runner_build_$$.log"
ERR="/tmp/xlang_std145_runner_err_$$.log"
if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
  exitcode=0
  "$OUT" >/dev/null 2>"$ERR" || exitcode=$?
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || {
    cat "$ERR" >&2 || true
    die "runner_smoke.x exit=$exitcode (expect $SMOKE_EXPECT; refuse soft SKIP→OK)"
  }
  grep -qF 'xlang: [XLANG_TEST] name=case_ok status=pass' "$ERR" 2>/dev/null || {
    cat "$ERR" >&2 || true
    die "missing pass line (refuse soft SKIP→OK)"
  }
  grep -qF 'xlang: [XLANG_TEST_SUMMARY] total=2 pass=1 fail=0 skip=1' "$ERR" 2>/dev/null || {
    cat "$ERR" >&2 || true
    die "missing summary (refuse soft SKIP→OK)"
  }
  RUN_OK=$((RUN_OK + 1))
  echo "std-test-runner OK: runner_smoke"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "runner_smoke.x link (refuse soft SKIP→OK)"
fi

std_test_runner_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-test-runner gate OK (host=$(ci_host_summary))"
