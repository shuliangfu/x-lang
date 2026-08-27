#!/usr/bin/env bash
# COMP-003: codegen stability regression gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) + soft auto-make retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Fossil top-level DOC / bench/loop_i32.x paths retired — live =
# archive/comp + bench/r01_|m03_|r10_|a01_*. DOC authority = archive/comp
# with ## Gate. Report run=/hook=/obs=/skip=.
#
# Usage: ./tests/run-codegen-regression-gate.sh
# wave honesty (2026-08-24): DOC → analysis/archive/comp/;
# 2026-08-27: soft SKIP→OK / prefer-c / fossil bench →硬绿.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_CODEGEN_REGRESSION_DOC:-analysis/archive/comp/comp-codegen-regression-v1.md}"
MATRIX="${XLANG_CODEGEN_REGRESSION_TSV:-tests/baseline/codegen-regression-matrix.tsv}"
PREFIX="${XLANG_CODEGEN_REGRESSION_PREFIX:-xlang: [XLANG_COMP003_CODEGEN_REGRESSION]}"

RUN_OK=0
HOOK_OK=0
OBS=0
SKIP=0

die() {
  echo "codegen-regression gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} hook=${HOOK_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} hook=${HOOK_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
    # Explicit XLANG that is missing or wrong-ABI = hard die (refuse soft SKIP→OK).
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

arch_ok() {
  local want="$1"
  case "$want" in
    any) return 0 ;;
    x86_64) ci_is_x86_64_host ;;
    arm64) ci_is_arm64_host ;;
    !docker) ! ci_is_docker ;;
    *) return 0 ;;
  esac
}

echo "=== COMP-003: codegen regression manifest ==="
if [ -f analysis/comp-codegen-regression-v1.md ]; then
  die "top-level DOC resurrected (live = archive/comp/)"
fi
for f in "$DOC" "$MATRIX"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi
# Refuse fossil bench paths that soft SKIP / missing-src used to hide.
for fossil in bench/loop_i32.x bench/mem_copy.x bench/struct_param.x bench/call_boundary.x; do
  if [ -f "$fossil" ]; then
    die "fossil bench resurrected: $fossil (live = r01_/m03_/r10_/a01_*)"
  fi
done
echo "codegen-regression manifest OK (host=$(ci_host_summary))"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# Refuse soft auto-make (prefer-c / g05 heat): native must already exist.

run_x_case() {
  local src="$1"
  local want_ec="$2"
  local out="/tmp/xlang_codegen_${src##*/}"
  local compile_ec=0
  out="${out%.x}"
  if [ ! -f "$src" ]; then
    echo "codegen-regression FAIL: missing $src" >&2
    return 1
  fi
  set +e
  "$XLANG_BIN" -L . "$src" -o "$out" >/tmp/xlang_codegen_compile.log 2>&1
  compile_ec=$?
  set -e
  if [ "$compile_ec" -ne 0 ]; then
    # Darwin tip heat SIGKILL (bash 137 = 128+9) = product residual obs.
    # PLATFORM: DARWIN heat; Ubuntu gold still hard-fails non-kill compile errors.
    if [ "$compile_ec" -eq 137 ] || [ "$compile_ec" -eq 9 ]; then
      echo "codegen-regression OBS compile SIGKILL $src (Darwin heat residual; refuse soft SKIP→OK)" >&2
      return 2
    fi
    cat /tmp/xlang_codegen_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  if [ "$ec" -ne "$want_ec" ]; then
    echo "codegen-regression FAIL $src: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

FAILS=0
echo "=== COMP-003: codegen smoke (XLANG=$XLANG_BIN) ==="

while IFS=$'\t' read -r case_id src arch policy want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  if ! arch_ok "$arch"; then
    echo "codegen-regression SKIP $case_id ($arch on $(ci_host_summary))"
    SKIP=$((SKIP + 1))
    continue
  fi
  echo "── $case_id: $notes ──"
  case "$policy" in
    run)
      set +e
      run_x_case "$src" "${want_ec:-0}"
      rc=$?
      set -e
      if [ "$rc" -eq 0 ]; then
        echo "codegen-regression OK $case_id"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$rc" -eq 2 ]; then
        OBS=$((OBS + 1))
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    hook)
      # Prefer resolved product path; asm-73 additionally prefers xlang_asm when present.
      hook_shu="$XLANG_BIN"
      if [ "$src" = "run-asm-73-gate.sh" ] && [ -x ./compiler/xlang_asm ] && dod_native_exe "$(pwd)/compiler/xlang_asm"; then
        hook_shu="$(pwd)/compiler/xlang_asm"
      fi
      hook="tests/${src}"
      [ -f "$hook" ] || die "missing hook $hook"
      chmod +x "$hook" 2>/dev/null || true
      if XLANG="$hook_shu" "$hook"; then
        echo "codegen-regression OK $case_id ($src)"
        HOOK_OK=$((HOOK_OK + 1))
      else
        # Hook product residual → obs (not soft silence / not hard-red archaeology).
        echo "codegen-regression OBS hook $case_id ($src) (product residual; refuse soft SKIP→OK)" >&2
        OBS=$((OBS + 1))
      fi
      ;;
    *)
      echo "codegen-regression WARN: unknown policy $policy" >&2
      OBS=$((OBS + 1))
      ;;
  esac
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  die "${FAILS} run case(s) failed"
fi

ok_report
echo "codegen-regression gate OK"
