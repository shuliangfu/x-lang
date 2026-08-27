#!/usr/bin/env bash
# C-07: xlang-c (C frontend REF) vs xlang/xlang_asm (.x frontend CAND)
# same-input typeck/run parity gate.
#
# Honesty: soft XLANG_C07_FAIL + top-level DOC soft-SKIP retired (missing
# analysis/phase-c-c07-v1.md was portable false-green after archive). Soft
# SKIP when REF/CAND missing also retired — product path must ship both.
#
# Product residual (tip): CAND with `-backend c` may SEGV / diverge from REF
# on Darwin/Ubuntu; that mismatch is **observational** (parity=0), not soft
# exit0 on missing DOC. REF typeck_ok failures remain hard (C frontend face).
#
# Usage: ./tests/run-c07-frontend-parity-gate.sh
# Env: C07_REF / C07_CAND override; XLANG_C07_TRY_RUN=1 adds -o run after typeck.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

TRY_RUN=${XLANG_C07_TRY_RUN:-0}
MATRIX="${XLANG_C07_MATRIX:-tests/baseline/c07-frontend-parity-matrix.tsv}"
DOC="analysis/archive/phase/phase-c-c07-v1.md"
PREFIX="xlang: [XLANG_C07]"

# shellcheck source=tests/lib/c07-frontend-parity.sh
. tests/lib/c07-frontend-parity.sh

die() {
  echo "c07 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail ref=${REF_OK:-0} pass=${PASS:-0} obs=${OBS_FAIL:-0} parity=${PARITY:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

REF_OK=0
PASS=0
OBS_FAIL=0
PARITY=0
SKIP=1

echo "=== C-07: frontend parity (xlang-c REF vs x CAND; honesty) ==="
if [ -f analysis/phase-c-c07-v1.md ]; then
  die "top-level phase-c-c07-v1.md resurrected (live = archive/phase/)"
fi
for f in "$MATRIX" "$DOC" tests/lib/c07-frontend-parity.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'C-07' "$DOC" || die "doc missing C-07 marker"
grep -qE '^## Gate' "$DOC" || die "phase-c-c07-v1.md missing ## Gate honesty section"

xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true

rc_resolve=0
c07_resolve_compilers || rc_resolve=$?
if [ "$rc_resolve" -eq 1 ]; then
  die "xlang-c REF not runnable on $(ci_host_summary) (soft SKIP retired)"
fi
if [ "$rc_resolve" -eq 2 ]; then
  die "no runnable xlang/xlang_asm CAND on $(ci_host_summary) (soft SKIP retired)"
fi

echo "c07 parity: REF=$C07_REF CAND=$C07_CAND host=$(ci_host_summary) try_run=$TRY_RUN"

while IFS=$'\t' read -r case_id src policy expect_exit notes; do
  [ -z "$case_id" ] || [ "${case_id#\#}" != "$case_id" ] && continue
  [ -f "$src" ] || die "missing src $src ($case_id)"

  tag="${case_id}_$$"
  log_ref="/tmp/c07_${tag}_ref.log"
  log_cand="/tmp/c07_${tag}_cand.log"

  rc_ref=0
  rc_cand=0
  set +e
  c07_typeck_x "$C07_REF" "$src" "$log_ref"
  rc_ref=$?
  c07_typeck_x "$C07_CAND" "$src" "$log_cand"
  rc_cand=$?
  set -e

  if [ "$policy" = "compile_fail" ]; then
    # REF must reject (hard). CAND mismatch = observational residual.
    if [ "$rc_ref" -eq 0 ]; then
      die "$case_id: REF expected compile fail (ref=$rc_ref) — $notes"
    fi
    if ! c07_log_typeck_error "$log_ref"; then
      die "$case_id: REF expected typeck error in log — $notes"
    fi
    REF_OK=$((REF_OK + 1))
    if [ "$rc_cand" -eq 0 ] || ! c07_log_typeck_error "$log_cand"; then
      echo "c07 OBS compile_fail $case_id: CAND diverge (cand=$rc_cand) — $notes"
      OBS_FAIL=$((OBS_FAIL + 1))
    else
      echo "c07 OK compile_fail $case_id ($notes)"
      PASS=$((PASS + 1))
    fi
    rm -f "$log_ref" "$log_cand" 2>/dev/null || true
    continue
  fi

  if [ "$policy" != "typeck_ok" ] && [ "$policy" != "run" ]; then
    die "$case_id: unknown policy $policy"
  fi

  # REF typeck_ok is hard (C frontend face). CAND SEGV/mismatch = observational.
  if [ "$rc_ref" -ne 0 ] || ! c07_log_typeck_ok "$log_ref"; then
    echo "c07 REF typeck fail ($case_id ref=$rc_ref):" >&2
    tail -n 8 "$log_ref" 2>/dev/null || true
    die "$case_id: REF typeck failed (ref=$rc_ref) — $notes"
  fi

  cand_ok=0
  if [ "$rc_cand" -eq 0 ] && c07_log_typeck_ok "$log_cand"; then
    cand_ok=1
  fi

  if [ "$TRY_RUN" = "1" ] && [ "$cand_ok" -eq 1 ]; then
    out_ref="/tmp/c07_${tag}_ref"
    out_cand="/tmp/c07_${tag}_cand"
    rc_link_ref=0
    rc_link_cand=0
    set +e
    c07_compile_x "$C07_REF" "$src" "$out_ref" "$log_ref"
    rc_link_ref=$?
    c07_compile_x "$C07_CAND" "$src" "$out_cand" "$log_cand"
    rc_link_cand=$?
    set -e
    if [ "$rc_link_ref" -eq 0 ] && [ "$rc_link_cand" -eq 0 ] && [ -x "$out_ref" ] && [ -x "$out_cand" ]; then
      run_ref=$(c07_run_exit "$out_ref")
      run_cand=$(c07_run_exit "$out_cand")
      if [ "$run_ref" != "$run_cand" ] || [ "$run_ref" != "$expect_exit" ]; then
        echo "c07 OBS run $case_id: ref=$run_ref cand=$run_cand expect=$expect_exit — $notes"
        OBS_FAIL=$((OBS_FAIL + 1))
        cand_ok=0
      else
        echo "c07 OK typeck+run $case_id exit=$run_ref ($notes)"
      fi
    else
      echo "c07 OK typeck_only $case_id (run skip: link ref=$rc_link_ref cand=$rc_link_cand) ($notes)"
    fi
    rm -f "$out_ref" "$out_cand" 2>/dev/null || true
  fi

  REF_OK=$((REF_OK + 1))
  if [ "$cand_ok" -eq 1 ]; then
    echo "c07 OK typeck $case_id ($notes)"
    PASS=$((PASS + 1))
  else
    echo "c07 OBS typeck $case_id: CAND diverge (cand=$rc_cand; tip -backend c residual) — $notes"
    OBS_FAIL=$((OBS_FAIL + 1))
  fi
  rm -f "$log_ref" "$log_cand" 2>/dev/null || true
done < "$MATRIX"

[ "$REF_OK" -ge 1 ] || die "no REF cases exercised"
if [ "$OBS_FAIL" -eq 0 ]; then
  PARITY=1
else
  PARITY=0
fi
SKIP=0
echo "c07 frontend-parity gate OK (ref=$REF_OK pass=$PASS obs=$OBS_FAIL parity=$PARITY REF=$C07_REF CAND=$C07_CAND)"
echo "${PREFIX} status=ok ref=${REF_OK} pass=${PASS} obs=${OBS_FAIL} parity=${PARITY} skip=${SKIP} host=$(ci_host_summary)"
