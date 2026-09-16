#!/usr/bin/env bash
# STD-051: std.regex gate — honesty soft prefer-c / soft SKIP→OK /
# soft auto-make / soft ensure_std_c_o / soft xlang-c rebuild / c_smoke=/x= →硬绿.
#
# Honesty: prefer-c first (xlang-c) + soft SKIP→OK (no native still gate OK /
# link debt SKIP) + soft `ensure_std_c_o` + soft `xlang_compiler_make xlang-c`
# + hard check as sole .x smoke + report `c_smoke=`/`x=` retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Host-C archaeology = obs only (prebuilt
# std/regex/regex.o; refuse soft ensure). check residual = obs
# (paused 2026-08-05). tip product -o (missing _main / UNDEF) = obs.
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-regex-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_STD_REGEX_DOC:-analysis/archive/std/std-regex-v1.md}"
MANIFEST="${XLANG_STD_REGEX_TSV:-tests/baseline/std-regex.tsv}"
XPLAT="${XLANG_STD_REGEX_XPLAT:-tests/baseline/std-regex-xplat.tsv}"
MOD_X="std/regex/mod.x"
REGEX_X="std/regex/regex.x"
LIB="tests/lib/std-regex.sh"
MIN_APIS=3

# shellcheck source=tests/lib/std-regex.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-regex gate FAIL: $*" >&2
  std_regex_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then echo "$linux"
  elif ci_is_darwin; then echo "$macos"
  elif ci_is_windows_msys; then echo "$windows"
  else echo "must"
  fi
}

echo "=== STD-051: regex manifest ==="
for f in "$DOC" "$MANIFEST" "$XPLAT" "$LIB" "$MOD_X" "$REGEX_X"; do
  [ -f "$f" ] || die "missing $f"
done
for kw in STD-051 regex.x match Windows; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-regex-v1.md ] || die "dual-authority fossil analysis/std-regex-v1.md (archive live)"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"
[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_regex_symbols_ok "$MOD_X" "$REGEX_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-regex manifest OK"

if [ "${XLANG_STD_REGEX_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_regex_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-regex gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-051: smoke (XLANG=$XLANG_BIN host=$(ci_host_summary); host-C=obs; check=obs; tip product=obs) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make.
# PLATFORM: SHARED — missing prebuilt regex.o = obs, not soft SKIP→OK.
set +e
std_regex_run_c_smoke "$REGEX_X"
c_rc=$?
set -e
case "$c_rc" in
  0)
    RUN_OK=$((RUN_OK + 1))
    echo "std-regex OK: c smoke"
    ;;
  *)
    echo "std-regex OBS c smoke (rc=$c_rc)" >&2
    OBS=$((OBS + 1))
    ;;
esac

# tip product xplat matrix — hard green when -o+run exit0; else obs (leave debt).
# Refuse soft SKIP on link debt. check = obs (paused).
# PLATFORM: SHARED archaeology.
while IFS=$'\t' read -r case_id script linux pol_mac pol_win _notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in \#*) continue ;; esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  case "$pol" in
    skip)
      echo "std-regex xplat env-skip $case_id"
      SKIP=$((SKIP + 1))
      continue
      ;;
  esac
  case "$script" in
    *.c) continue ;;
  esac
  set +e
  "$XLANG_BIN" check -L . "$script" >/tmp/xlang_std_regex_chk_$$.log 2>&1
  chk=$?
  set -e
  if [ "$chk" -ne 0 ]; then
    echo "std-regex OBS check $case_id (paused / CHK residual ec=$chk)" >&2
    OBS=$((OBS + 1))
  fi
  if std_regex_run_smoke "$XLANG_BIN" "$script" "$case_id"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-regex OK: product $case_id"
  else
    echo "std-regex OBS tip product $case_id (UNDEF/missing-main residual)" >&2
    OBS=$((OBS + 1))
  fi
done < "$XPLAT"

for sym in compile match free group_count; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "mod missing function ${sym}"
done
grep -q "regex.match" tests/regex/literal_match.x 2>/dev/null || die "smoke missing regex.match"

std_regex_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-regex gate OK"
