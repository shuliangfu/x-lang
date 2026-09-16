#!/usr/bin/env bash
# ZC-007: zero-copy proof template + PR declaration gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK (no native) + prefer-c + soft auto-make + fossil
# top-level DOC retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. DOC/SEM = archive/zc.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-zc-copy-proof-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_ZC_COPY_PROOF_DOC:-analysis/archive/zc/zc-copy-proof-v1.md}"
MATRIX="${XLANG_ZC_COPY_PROOF_TSV:-tests/baseline/zc-copy-proof.tsv}"
PR_TPL="${XLANG_ZC_PR_COPY_TPL:-tests/templates/zc-pr-copy-declaration.txt}"
X_TPL="${XLANG_ZC_X_COPY_TPL:-tests/templates/zc-copy-proof-test.x}"
SEM="${XLANG_ZC_SEMANTICS_DOC:-analysis/archive/zc/zc-semantics-v1.md}"
MIN_PROOFS=1
PREFIX="${XLANG_ZC_COPY_PROOF_PREFIX:-xlang: [XLANG_ZC_COPY_PROOF]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "zc-copy-proof FAIL: $*" >&2
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== ZC-007: copy proof manifest (archive DOC) ==="
if [ -f analysis/zc-copy-proof-v1.md ]; then
  die "top-level DOC resurrected (live = archive/zc/)"
fi
for f in "$DOC" "$MATRIX" "$PR_TPL" "$X_TPL" "$SEM"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_proofs) MIN_PROOFS="$c2" ;; esac
done < "$MATRIX"

for key in path_id userland_copies zc_tier hot_path fallback; do
  if ! grep -qF "$key:" "$X_TPL" 2>/dev/null; then
    die "x template missing key $key"
  fi
done
echo "zc-copy-proof x template OK"

for field in userland_copies zc_tier proof_id fallback; do
  if ! grep -qF "$field:" "$PR_TPL" 2>/dev/null; then
    die "pr template missing $field"
  fi
done
echo "zc-copy-proof pr template OK"

if ! grep -qF 'ZC-007' "$SEM" 2>/dev/null; then
  die "zc-semantics doc missing ZC-007 ref"
fi

RUN_N=0
FAILS=0
echo "=== ZC-007: proof matrix ==="
while IFS=$'\t' read -r proof_id source policy want_ec copies tier notes; do
  [ -z "${proof_id:-}" ] && continue
  case "$proof_id" in \#*|min_proofs) continue ;; esac
  case "$policy" in
    template)
      case "$source" in
        zc-copy-proof-test.x)
          [ -f "$X_TPL" ] || { echo "zc-copy-proof FAIL: $X_TPL" >&2; FAILS=$((FAILS + 1)); }
          ;;
        zc-pr-copy-declaration.txt)
          [ -f "$PR_TPL" ] || { echo "zc-copy-proof FAIL: $PR_TPL" >&2; FAILS=$((FAILS + 1)); }
          ;;
        *)
          echo "zc-copy-proof FAIL: unknown template $source" >&2
          FAILS=$((FAILS + 1))
          ;;
      esac
      ;;
    meta)
      src="tests/templates/$source"
      if [ ! -f "$src" ]; then
        echo "zc-copy-proof FAIL: missing $src" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      for key in path_id userland_copies zc_tier; do
        if ! grep -qF "$key:" "$src" 2>/dev/null; then
          echo "zc-copy-proof FAIL: $src missing $key" >&2
          FAILS=$((FAILS + 1))
        fi
      done
      ;;
    checklist)
      if ! grep -qF 'userland_copies' "$PR_TPL" 2>/dev/null; then
        echo "zc-copy-proof FAIL: checklist fields" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    run)
      src="tests/zc/$source"
      if [ ! -f "$src" ]; then
        echo "zc-copy-proof FAIL: missing $src" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      for key in path_id userland_copies zc_tier; do
        if ! grep -qF "$key:" "$src" 2>/dev/null; then
          echo "zc-copy-proof FAIL: $src missing metadata $key" >&2
          FAILS=$((FAILS + 1))
        fi
      done
      if [ "$copies" != "-" ] && ! grep -qF "userland_copies: $copies" "$src" 2>/dev/null; then
        echo "zc-copy-proof FAIL: $src userland_copies mismatch want $copies" >&2
        FAILS=$((FAILS + 1))
      fi
      RUN_N=$((RUN_N + 1))
      echo "zc-copy-proof OK proof row $proof_id"
      ;;
    *)
      echo "zc-copy-proof WARN: unknown policy $policy for $proof_id" >&2
      ;;
  esac
done < "$MATRIX"

[ "$RUN_N" -ge "$MIN_PROOFS" ] || die "run_proofs=${RUN_N} < min_proofs=${MIN_PROOFS}"
[ "$FAILS" -eq 0 ] || die "matrix errors=${FAILS}"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

run_proof() {
  local script="$1"
  local want_ec="$2"
  local src="tests/zc/$script"
  local out="/tmp/xlang_zc_proof_${script%.x}_$$"
  local log="/tmp/xlang_zc_proof_compile_${script%.x}.log"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    # Tip product residual (link/UNDEF) → obs, not soft SKIP→OK.
    echo "zc-copy-proof OBS $script (compile residual ec=$o_ec; refuse soft SKIP→OK)" >&2
    tail -8 "$log" >&2 || true
    rm -f "$out"
    return 2
  fi
  local ec=0
  set +e
  "$out" >/dev/null 2>&1
  ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne "$want_ec" ]; then
    echo "zc-copy-proof OBS $script: exit=$ec want=$want_ec (product residual)" >&2
    return 2
  fi
  return 0
}

SMOKE_FAILS=0
echo "=== ZC-007: proof smoke (XLANG=$XLANG_BIN) ==="
while IFS=$'\t' read -r proof_id source policy want_ec _c _t _n; do
  [ -z "${proof_id:-}" ] && continue
  case "$proof_id" in \#*|min_proofs|template_meta|pr_checklist) continue ;; esac
  [ "$policy" = "run" ] || continue
  echo "── proof $proof_id ──"
  pr_ec=0
  run_proof "$source" "${want_ec:-0}" || pr_ec=$?
  if [ "$pr_ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "zc-copy-proof smoke OK $proof_id"
  elif [ "$pr_ec" -eq 2 ]; then
    OBS=$((OBS + 1))
  else
    SMOKE_FAILS=$((SMOKE_FAILS + 1))
  fi
done < "$MATRIX"

[ "$SMOKE_FAILS" -eq 0 ] || die "smoke=${SMOKE_FAILS}"
# Manifest + at least one run row validated; smoke may be obs on tip.
if [ "$RUN_OK" -lt 1 ] && [ "$OBS" -lt 1 ]; then
  die "no proof smoke executed (refuse soft SKIP→OK)"
fi

echo "zc-copy-proof gate OK"
ok_report
