#!/usr/bin/env bash
# LANG-001: edition / feature gate smoke.
#
# Honesty: soft SKIP→OK when no native xlang (bare "gate OK") + prefer
# xlang-c before xlang_asm retired. Prefer product xlang_asm. Explicit
# bad XLANG = hard die. Missing native = hard die (edition/feature hooks
# are the live face). Report run=/edition=/feature=/skip=.
#
# Usage: ./tests/run-lang-feature-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

PREFIX="xlang: [XLANG_LANG_FEATURE]"
RUN_OK=0
EDITION_OK=0
FEATURE_OK=0
SKIP=0

die() {
  echo "lang-feature-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} edition=${EDITION_OK} feature=${FEATURE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} edition=${EDITION_OK} feature=${FEATURE_OK} skip=${SKIP} host=$(ci_host_summary)"
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
chmod +x scripts/xlang-lang-edition.sh

ED_STABLE=tests/lang-feature/edition_stable.x
FEAT=tests/lang-feature/feature_match.x
EXE="/tmp/xlang_lang_feat_$$"

run_expect() {
  local label="$1"
  shift
  "$@" -o "$EXE" 2>&1
  local ec=0
  "$EXE" >/dev/null 2>&1 || ec=$?
  rm -f "$EXE"
  echo "$ec"
}

# edition: default stable 0
ec=$(run_expect edition_stable ./scripts/xlang-lang-edition.sh 2024 "$ED_STABLE")
[ "$ec" -eq 0 ] || die "edition stable want 0 got $ec"

# edition: no 2025 flag also 0
ec=$(run_expect edition_default "$XLANG_BIN" "$ED_STABLE")
[ "$ec" -eq 0 ] || die "edition default want 0 got $ec"

# edition: 2025 experimental 99
ec=$(run_expect edition_2025 ./scripts/xlang-lang-edition.sh 2025 "$ED_STABLE")
[ "$ec" -eq 99 ] || die "edition 2025 want 99 got $ec"
EDITION_OK=1

# feature: off 0
ec=$(run_expect feature_off "$XLANG_BIN" "$FEAT")
[ "$ec" -eq 0 ] || die "feature off want 0 got $ec"

# feature: on 42
ec=$(run_expect feature_on ./scripts/xlang-lang-edition.sh feature MATCH_STMT "$FEAT")
[ "$ec" -eq 42 ] || die "feature on want 42 got $ec"
FEATURE_OK=1
RUN_OK=1

echo "lang-feature-gate report edition=OK feature=OK host=$(ci_host_summary)"
ok_report
echo "lang-feature-gate OK"
