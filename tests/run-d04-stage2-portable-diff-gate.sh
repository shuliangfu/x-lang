#!/usr/bin/env bash
# D-04：Stage1 vs Stage2 portable 子集两代 diff v1（矩阵逐行 outcome 一致）。
#
# 用法：./tests/run-d04-stage2-portable-diff-gate.sh
# 环境：
#   SHUX_D04_FAIL=1        — 失败时硬退出（CI 默认）
#   SHUX_D04_STAGE1/2      — 默认 compiler/shux_asm_stage1 / shux_asm2
#   SHUX_D04_MANIFEST_ONLY — 仅审计 manifest，不跑用例
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D04_FAIL:-0}
DOC="analysis/phase-d-d04-v1.md"
MANIFEST="tests/baseline/d04-stage2-portable-matrix.tsv"
LIB="tests/lib/d04-stage2-portable-diff.sh"
STAGE1="${SHUX_D04_STAGE1:-compiler/shux_asm_stage1}"
STAGE2="${SHUX_D04_STAGE2:-compiler/shux_asm2}"
MIN_CASES=10

die() {
  echo "d04 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

# shellcheck source=tests/lib/d04-stage2-portable-diff.sh
. "$LIB"

echo "=== D-04: Stage2 portable two-gen diff (v1) ==="
for f in "$DOC" "$MANIFEST" "$LIB" tests/run-bootstrap-stage2-dogfood-parser-typeck.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-04 v1' "$DOC" || die "doc missing D-04 v1 marker"

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

if [ "${SHUX_D04_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "d04 stage2-portable-diff gate OK (manifest only)"
  exit 0
fi

# ── Darwin / 无 stage 产物：N/A ──
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "d04 stage2-portable-diff gate: N/A on Darwin (use Docker Linux)"
  echo "d04 stage2-portable-diff gate OK (Darwin N/A — manifest audited)"
  exit 0
fi

if ! d04_stage_binaries_ready; then
  echo "d04 stage2-portable-diff gate: SKIP (no native $STAGE1 / $STAGE2)"
  [ "$FAIL" = "1" ] && die "missing stage binaries under STRICT CI"
  d04_emit_report "skip" 0 0 1
  exit 0
fi

d04_export_link_shux_if_needed

OK=0
BAD=0
echo "=== D-04: stage1 vs stage2 diff (SHUX1=$STAGE1 SHUX2=$STAGE2) ==="
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

d04_emit_report "ok" "$OK" 0 0
echo "d04 stage2-portable-diff gate OK ($OK/$CASE_N cases match)"
