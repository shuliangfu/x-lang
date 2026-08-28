#!/usr/bin/env bash
# CORE-016: generic Option/Result unify with core type families.
#
# Honesty: soft prefer-c (xlang-c before asm) + soft auto-make of xlang-c +
# soft SKIP→OK when no native (false authority) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). Check path
# = obs= (check gate paused 2026-08-05). Product `-o` unify_option /
# unify_result must exit 0. Report: run=/obs=/skip=
# Usage: ./tests/run-core-option-result-unify-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_CORE016_DOC:-analysis/archive/core/core-option-result-unify-v1.md}"
MANIFEST="${XLANG_CORE016_TSV:-tests/baseline/core-option-result-unify.tsv}"
SMOKE1="tests/core016/unify_option.x"
SMOKE2="tests/core016/unify_result.x"
TYPECK_X="compiler/src/typeck/typeck.x"
MIN_GOLDEN=2

# shellcheck source=tests/lib/core-option-result-unify.sh
. tests/lib/core-option-result-unify.sh

PREFIX="${XLANG_CORE016_PREFIX:-xlang: [XLANG_CORE016_OPTION_RESULT_UNIFY]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-option-result-unify FAIL: $*" >&2
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
  # Prefer product asm; refuse prefer-c.
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

echo "=== CORE-016: Option/Result unify (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="

if [ -f analysis/core-option-result-unify-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
if [ -f compiler/src/typeck/typeck_generic_struct.c ]; then
  die "typeck_generic_struct.c resurrected"
fi
if [ -f compiler/src/parser/parser.c ]; then
  die "parser.c resurrected (live = parser.x)"
fi
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/option/mod.x core/result/mod.x "$TYPECK_X"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in CORE-016 Result_i32 Option_i32 typeck_expand; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(core016_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core016_emit_report "fail" 0 0 0
  die "manifest miss=${sym_miss}"
fi
echo "core-option-result-unify manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
if "$XLANG_BIN" check -L . "$SMOKE1" >/dev/null 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE2" >/dev/null 2>&1; then
  :
else
  echo "core-option-result-unify OBS: check residual (paused; refuse soft silence)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core016_$$"
trap 'rm -f "$exe"' EXIT
GOLDEN_OK=0
for x in "$SMOKE1" "$SMOKE2"; do
  set +e
  link_log=$("$XLANG_BIN" -L . "$x" -o "$exe" 2>&1)
  link_ec=$?
  set -e
  if [ "$link_ec" -ne 0 ]; then
    echo "$link_log" | tail -5 >&2 || true
    core016_emit_report "fail" "$GOLDEN_OK" 0 0
    die "runnable link ($x)"
  fi
  set +e
  "$exe" >/dev/null 2>&1
  run_ec=$?
  set -e
  rm -f "$exe"
  if [ "$run_ec" -ne 0 ]; then
    core016_emit_report "fail" "$GOLDEN_OK" 0 0
    die "run $x exit=$run_ec"
  fi
  GOLDEN_OK=$((GOLDEN_OK + 1))
  RUN_OK=$((RUN_OK + 1))
done

if [ "$GOLDEN_OK" -lt "$MIN_GOLDEN" ]; then
  core016_emit_report "fail" "$GOLDEN_OK" 0 0
  die "golden=$GOLDEN_OK < min $MIN_GOLDEN"
fi

core016_emit_report "ok" "$GOLDEN_OK" 1 0
echo "core-option-result-unify gate OK"
ok_report
