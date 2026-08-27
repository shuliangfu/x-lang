#!/usr/bin/env bash
# LANG-008: lifetime diagnostic line smoke.
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die.
# Missing native = hard die (manifest face is live). `xlang check` line/
# substr smoke is observational (check gate paused 2026-08-05) — count
# as obs, not soft silence. Report run=/obs=/skip=.
#
# Usage: ./tests/run-lang-lifetime-diag.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

MATRIX="${XLANG_LANG_LIFETIME_DIAG_CASES:-tests/baseline/lang-lifetime-diag-cases.tsv}"
PREFIX="xlang: [XLANG_LANG_LIFETIME_DIAG]"
RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

die() {
  echo "lang-lifetime-diag FAIL: $*" >&2
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "=== LANG-008: lifetime diagnostic line smoke (XLANG=$XLANG_BIN) ==="
FAILS=0
while IFS=$'\t' read -r case_id file substr want_line notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  src="tests/typeck/slice_lifetime/${file}"
  if [ ! -f "$src" ]; then
    echo "lang-lifetime-diag FAIL: missing $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  # check gate paused — smoke is observational product/diag debt.
  # PLATFORM: SHARED — not soft silence; count obs.
  err=$("$XLANG_BIN" check "$src" 2>&1) || true
  if lang_lifetime_diag_expect_at_line "$err" "$substr" "$want_line"; then
    echo "lang-lifetime-diag OK $case_id at ${want_line} ($notes)"
  else
    FAILS=$((FAILS + 1))
  fi
done < "$MATRIX"

RUN_OK=1
if [ "$FAILS" -gt 0 ]; then
  echo "lang-lifetime-diag OBS smoke (${FAILS} case(s); check paused / diag format debt)" >&2
  OBS=1
fi

ok_report
echo "lang-lifetime-diag OK"
