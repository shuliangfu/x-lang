#!/usr/bin/env bash
# D-04: Stage1 vs Stage2 portable subset two-gen diff v1
# (matrix row outcomes must match).
#
# Honesty: soft XLANG_D04_FAIL retired — early Darwin "OOM" soft exit0 skipped
# DOC/matrix entirely (portable false-green). Soft die→exit0 on missing DOC
# also retired. Live portable diff remains Linux gold; Darwin = static +
# honest skip=1 after matrix audit.
#
# Usage: ./tests/run-d04-stage2-portable-diff-gate.sh
# Env:
#   XLANG_D04_STAGE1/2      — default compiler/xlang_asm_stage1 / xlang_asm2
#   XLANG_D04_MANIFEST_ONLY — static + matrix only
# PLATFORM: SHARED archaeology · LINUX live portable · DARWIN static+skip.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if [ -f analysis/phase-d-d04-v1.md ]; then
  echo "d04-stage2-portable-diff-gate gate FAIL: top-level DOC resurrected (live = archive/phase/)" >&2
  exit 1
fi

DOC="analysis/archive/phase/phase-d-d04-v1.md"
MANIFEST="tests/baseline/d04-stage2-portable-matrix.tsv"
LIB="tests/lib/d04-stage2-portable-diff.sh"
STAGE1="${XLANG_D04_STAGE1:-compiler/xlang_asm_stage1}"
STAGE2="${XLANG_D04_STAGE2:-compiler/xlang_asm2}"
MIN_CASES=10
PREFIX="xlang: [XLANG_D04]"

die() {
  echo "d04 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} matrix=${MATRIX_OK:-0} cases_ok=${OK:-0} cases_fail=${BAD:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# shellcheck source=tests/lib/d04-stage2-portable-diff.sh
. "$LIB"

DOC_OK=0
MATRIX_OK=0
OK=0
BAD=0
SKIP=1

echo "=== D-04: Stage2 portable two-gen diff (honesty) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + verify-selfhost-stage2-bstrict)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" tests/run-bootstrap-stage2-dogfood-parser-typeck.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-04 v1' "$DOC" || die "doc missing D-04 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-d-d04-v1.md missing ## Gate honesty section"
DOC_OK=1

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_cases) MIN_CASES="$c2" ;; esac
done < "$MANIFEST"

CASE_N=0
MISS=0
echo "=== D-04: matrix smoke files ==="
while IFS=$'\t' read -r case_id category src mode expected_exit _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  CASE_N=$((CASE_N + 1))
  if [ ! -f "$src" ]; then
    echo "d04 FAIL: missing src $src ($case_id)" >&2
    MISS=$((MISS + 1))
  fi
  case "$mode" in
    check|link_run) ;;
    *)
      echo "d04 FAIL: bad mode $mode ($case_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MANIFEST"
[ "$CASE_N" -ge "$MIN_CASES" ] || die "matrix cases $CASE_N < $MIN_CASES"
[ "$MISS" -eq 0 ] || die "$MISS matrix rows invalid"
MATRIX_OK=1

if [ "${XLANG_D04_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "d04 stage2-portable-diff gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} matrix=${MATRIX_OK} cases_ok=0 cases_fail=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# Darwin / non-Linux: static audited; live portable remains Linux gold.
if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  SKIP=1
  echo "d04 stage2-portable-diff gate: N/A on $(uname -s) (Linux covers live portable; matrix audited)"
  echo "d04 stage2-portable-diff gate OK (non-Linux N/A — matrix audited)"
  echo "${PREFIX} status=ok doc=${DOC_OK} matrix=${MATRIX_OK} cases_ok=0 cases_fail=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if ! d04_stage_binaries_ready; then
  SKIP=1
  echo "d04 stage2-portable-diff gate: SKIP (no native $STAGE1 / $STAGE2; static audited)"
  echo "d04 stage2-portable-diff gate OK (static audited — bins absent)"
  d04_emit_report "ok" 0 0 1
  echo "${PREFIX} status=ok doc=${DOC_OK} matrix=${MATRIX_OK} cases_ok=0 cases_fail=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

d04_export_link_xlang_if_needed

echo "=== D-04: stage1 vs stage2 diff (XLANG1=$STAGE1 XLANG2=$STAGE2) ==="
while IFS=$'\t' read -r case_id category src mode expected_exit _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac

  o1="" o2=""
  case "$mode" in
    check)
      o1=$(d04_outcome_check "$STAGE1" "$src")
      o2=$(d04_outcome_check "$STAGE2" "$src")
      ;;
    link_run)
      o1=$(d04_outcome_link_run "$STAGE1" "$src" "$expected_exit" "${case_id}_s1")
      o2=$(d04_outcome_link_run "$STAGE2" "$src" "$expected_exit" "${case_id}_s2")
      ;;
  esac

  if [ "$o1" = "$o2" ]; then
    OK=$((OK + 1))
    echo "d04 OK $case_id ($category) $mode: $o1"
  else
    BAD=$((BAD + 1))
    echo "d04 MISMATCH $case_id ($src): stage1=$o1 stage2=$o2" >&2
  fi
done < "$MANIFEST"

if [ "$BAD" -gt 0 ]; then
  d04_emit_report "fail" "$OK" "$BAD" 0
  die "$BAD case(s) differ between stage1 and stage2"
fi

SKIP=0
d04_emit_report "ok" "$OK" 0 0
echo "d04 stage2-portable-diff gate OK ($OK/$CASE_N cases match)"
echo "${PREFIX} status=ok doc=${DOC_OK} matrix=${MATRIX_OK} cases_ok=${OK} cases_fail=0 skip=${SKIP} host=$(ci_host_summary)"
