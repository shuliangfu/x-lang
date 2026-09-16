#!/usr/bin/env bash
# SAFE-005: leak night runner (Linux ASAN/LSAN) — honesty soft→硬绿.
#
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native on Linux+ASAN = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Non-Linux / no ASAN = skip= (platform N/A).
# Usage: ./tests/run-safe-leak-nightly.sh
# Env:
#   XLANG_LEAK_PROBE=1 — also run leak_probe.c
#   XLANG_LEAK_FAIL_ON_LEAK=1 — any leak → exit 1 (CI default)
# PLATFORM: LINUX ASAN primary; Darwin/Windows skip.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/safe-leak.sh
. tests/lib/safe-leak.sh

MANIFEST="${XLANG_LEAK_MANIFEST:-tests/baseline/safe-leak-nightly.tsv}"
[ "${XLANG_LEAK_FAIL_ON_LEAK:-1}" = "1" ] && FAIL_ON_LEAK=1 || FAIL_ON_LEAK=0
[ "${XLANG_LEAK_PROBE:-0}" = "1" ] && RUN_PROBE=1 || RUN_PROBE=0

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "safe-leak-nightly FAIL: $*" >&2
  safe_leak_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== SAFE-005: leak nightly (ASAN) ==="

# PLATFORM: LINUX — night path; non-Linux = skip (not soft silence of missing native).
if [ "$(uname -s)" != "Linux" ]; then
  echo "safe-leak-nightly SKIP: non-Linux host (platform N/A)"
  SKIP=$((SKIP + 1))
  safe_leak_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  exit 0
fi

if ! safe_leak_asan_ok; then
  echo "safe-leak-nightly SKIP: cc missing -fsanitize=address" >&2
  SKIP=$((SKIP + 1))
  safe_leak_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

FAIL=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    case_*)
      if safe_leak_run_x "$XLANG_BIN" "$src" "$item_id"; then
        echo "safe-leak-nightly OK $item_id"
        RUN_OK=$((RUN_OK + 1))
      else
        FAIL=$((FAIL + 1))
        OBS=$((OBS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$RUN_PROBE" -eq 1 ]; then
  set +e
  safe_leak_run_probe
  prc=$?
  set -e
  if [ "$prc" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
  elif [ "$prc" -eq 2 ]; then
    SKIP=$((SKIP + 1))
  else
    FAIL=$((FAIL + 1))
    OBS=$((OBS + 1))
  fi
fi

if [ "$FAIL" -gt 0 ] && [ "$FAIL_ON_LEAK" -eq 1 ]; then
  safe_leak_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
fi

safe_leak_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "safe-leak-nightly OK"
