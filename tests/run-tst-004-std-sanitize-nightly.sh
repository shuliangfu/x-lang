#!/usr/bin/env bash
# TST-004: std module sanitizer nightly (ASAN heap/channel) — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + prefer-c + soft auto-make retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. No-ASAN = skip= (platform N/A) only when
# invoked standalone; parent gate already classifies non-Linux.
# Usage: ./tests/run-tst-004-std-sanitize-nightly.sh
# Env:
#   XLANG_TST004_FAIL_ON_ERROR=1 — any case fail → exit 1 (default)
# PLATFORM: LINUX ASAN primary — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tst-004-std-sanitize.sh
. tests/lib/tst-004-std-sanitize.sh

MANIFEST="${XLANG_TST004_TSV:-tests/baseline/tst-004-std-sanitize.tsv}"
[ "${XLANG_TST004_FAIL_ON_ERROR:-1}" = "1" ] && FAIL_ON_ERR=1 || FAIL_ON_ERR=0

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tst-004-sanitize-nightly FAIL: $*" >&2
  tst004_sanitize_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== TST-004: std sanitizer nightly (ASAN) ==="

if ! safe_leak_asan_ok; then
  echo "tst-004-sanitize-nightly SKIP: cc missing -fsanitize=address (platform N/A)" >&2
  SKIP=1
  tst004_sanitize_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

FAIL=0
while IFS=$'\t' read -r item_id kind _anchor src needs_o _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    case_*)
      tst004_sanitize_ensure_o "${needs_o:--}"
      if tst004_sanitize_run_case "$XLANG_BIN" "$src" "$item_id"; then
        echo "tst-004-sanitize-nightly OK $item_id"
        RUN_OK=$((RUN_OK + 1))
      else
        echo "tst-004-sanitize-nightly OBS $item_id (ASAN/product residual; refuse soft SKIP→OK)" >&2
        OBS=$((OBS + 1))
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  tst004_sanitize_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  if [ "$FAIL_ON_ERR" -eq 1 ]; then
    exit 1
  fi
else
  tst004_sanitize_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
fi

echo "tst-004-std-sanitize-nightly OK"
