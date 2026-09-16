#!/usr/bin/env bash
# PERF-004: compile dogfood no-regression gate (fixed compile/check vs baseline).
#
# Honesty: soft SKIP→OK when no native XLANG + soft prefer-xlang-c-only
# retired. Prefer product xlang_asm. Timing over-cap is observational via
# the runner when FAIL_REG=0 (FAIL_REG=1 still hard). Missing compiler
# with FAIL_REG=1 = hard die. Report run=/obs=/skip=.
#
# wave309 honesty: DOC archived under analysis/archive/perf/.
# PLATFORM: SHARED archaeology.
#
# Checks:
#   1) manifest: compile-dogfood.tsv + 8 source paths + DOC ## Gate
#   2) Xlang median ≤ tests/baseline/compile-dogfood.tsv
#      (default XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1)
#
# Usage: ./tests/run-perf-compile-dogfood-gate.sh
# Smoke (no hard timing fail): XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=0 ./tests/run-perf-compile-dogfood-gate.sh
# CI: run-ci-full-suite.sh on native Linux x86_64 (hard fail)
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_COMPILE_DOGFOOD_DOC:-analysis/archive/perf/perf-compile-dogfood-v1.md}"
BASELINE="${XLANG_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
FAIL_REG="${XLANG_PERF_FAIL_ON_COMPILE_REGRESSION:-1}"
PREFIX="xlang: [XLANG_PERF_COMPILE_DOGFOOD]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-compile-dogfood gate FAIL: $*" >&2
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

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-compile-dogfood-v1.md ]; then
  die "refuse top-level analysis/perf-compile-dogfood-v1.md (use archive/perf)"
fi

# wave309 honesty: bench micro cases renamed (r01_/m03_/r10_/a01_);
# baseline case_id keys unchanged in compile-dogfood.tsv.
compile_dogfood_case_src() {
  case "$1" in
    loop_i32) echo bench/r01_loop_i32.x ;;
    mem_copy) echo bench/m03_mem_copy.x ;;
    struct_param) echo bench/r10_struct_param.x ;;
    call_boundary) echo bench/a01_call_boundary.x ;;
    perf_main) echo tests/perf-baseline/main.x ;;
    check_backend) echo compiler/src/asm/backend.x ;;
    check_parser) echo compiler/src/parser/parser.x ;;
    check_typeck) echo compiler/src/typeck/typeck.x ;;
    *) return 1 ;;
  esac
}

COMPILE_DOGFOOD_CASES="loop_i32 mem_copy struct_param call_boundary perf_main check_backend check_parser check_typeck"

echo "=== PERF-004: compile dogfood manifest ==="
if [ ! -f "$BASELINE" ]; then
  die "missing $BASELINE"
fi
if [ ! -f "$DOC" ]; then
  die "missing $DOC"
fi
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

missing=0
for case_id in $COMPILE_DOGFOOD_CASES; do
  src=$(compile_dogfood_case_src "$case_id") || true
  if [ -z "$src" ] || [ ! -f "$src" ]; then
    echo "perf-compile-dogfood gate FAIL: missing source for $case_id" >&2
    missing=$((missing + 1))
    continue
  fi
  if ! awk -F'\t' -v c="$case_id" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
    echo "perf-compile-dogfood gate FAIL: baseline missing case $case_id" >&2
    missing=$((missing + 1))
  fi
done
[ "$missing" -eq 0 ] || die "manifest incomplete ($missing)"
echo "compile-dogfood manifest OK (8 cases)"
RUN_OK=1

# PLATFORM: LINUX — compile-dogfood hard bench gold is native Linux.
# Darwin/Docker call this gate with FAIL_REG=0 (BOOT-012 / ci-full-suite);
# do not run multi-minute -o benches here — ok_pattern accepts SKIP bench.
if [ "$FAIL_REG" != "1" ]; then
  case "$(uname -s 2>/dev/null)" in
    Linux)
      ;;
    *)
      SKIP=1
      echo "perf-compile-dogfood gate SKIP bench (FAIL_REG=0 non-Linux; gold=Linux)" >&2
      ok_report
      exit 0
      ;;
  esac
fi

XLANG_BIN="$(resolve_shu)" || true
if [ -z "${XLANG_BIN:-}" ]; then
  if [ "$FAIL_REG" = "1" ]; then
    die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "perf-compile-dogfood gate SKIP bench (no native xlang; FAIL_REG=0)" >&2
  ok_report
  exit 0
fi

echo "=== PERF-004: compile dogfood vs baseline (XLANG=$XLANG_BIN FAIL_REG=$FAIL_REG) ==="
chmod +x tests/run-perf-compile-dogfood.sh
# Capture runner status line; propagate hard fail.
set +e
OUT=$(
  XLANG="$XLANG_BIN" \
    XLANG_PERF_FAIL_ON_COMPILE_REGRESSION="$FAIL_REG" \
    ./tests/run-perf-compile-dogfood.sh 2>&1
)
RC=$?
set -e
printf '%s\n' "$OUT"
# Prefer runner's run=/obs= if present.
if echo "$OUT" | grep -q 'status='; then
  RLINE=$(echo "$OUT" | grep 'status=' | tail -1)
  echo "gate saw: $RLINE"
  # Extract obs= from runner when present.
  R_OBS=$(echo "$RLINE" | sed -n 's/.*obs=\([0-9]*\).*/\1/p')
  R_RUN=$(echo "$RLINE" | sed -n 's/.*run=\([0-9]*\).*/\1/p')
  [ -n "$R_OBS" ] && OBS="$R_OBS"
  [ -n "$R_RUN" ] && RUN_OK="$R_RUN"
fi
if [ "$RC" -ne 0 ]; then
  die "runner exit $RC"
fi

echo "perf-compile-dogfood gate OK"
ok_report
