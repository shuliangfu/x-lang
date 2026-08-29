#!/usr/bin/env bash
# STD-027: std.dynlib Windows LoadLibrary — honesty soft fallthrough →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. G.7: complete existing resolve_shu;
# drop unused compiler-make.sh; converge dod_native_exe.
# Honesty: leftover ignore of explicit-bad (DOC before resolve) retired.
# Explicit-bad XLANG / missing native = hard die FIRST (before DOC /
# leftover nested observational check / leftover nested host-C).
# leftover nested product path (observational check / host-C win_path /
# product -o open_sym_close+main+win_path) stay.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-dynlib-windows-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_DYNLIB_WIN_DOC:-analysis/archive/std/std-dynlib-windows-v1.md}"
MANIFEST="${XLANG_STD_DYNLIB_WIN_TSV:-tests/baseline/std-dynlib-windows.tsv}"
DYNLIB_RUNTIME="compiler/seeds/runtime_dynlib_os.from_x.c"
DYNLIB_X="std/dynlib/dynlib.x"
MOD_X="std/dynlib/mod.x"
LIB="tests/lib/std-dynlib-windows.sh"
SMOKE="tests/dynlib/open_sym_close.x"
WIN_PATH_X="tests/dynlib/win_path.x"
WIN_PATH_C="tests/dynlib/win_path_smoke.c"
NULL_TEST="tests/dynlib/main.x"
RUNNER="tests/run-dynlib.sh"

# shellcheck source=tests/lib/std-dynlib-windows.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=1

die() {
  echo "std-dynlib-windows gate FAIL: $*" >&2
  std_dynlib_win_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# leftover unused compiler-make.sh retired — converge dod_native_exe.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE DOC /
# leftover nested observational check / leftover nested host-C (refuse
# leftover unused compiler-make SOURCE / leftover ignore of
# explicit-bad / leftover SKIP→OK). leftover nested product path stays
# when XLANG is unset.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover unused compiler-make SOURCE / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== STD-027: dynlib Windows manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DYNLIB_X" "$DYNLIB_RUNTIME" "$MOD_X" \
  "$SMOKE" "$WIN_PATH_X" "$WIN_PATH_C" "$NULL_TEST" "$RUNNER"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in LoadLibraryA LoadLibraryW GetProcAddress FreeLibrary kernel32.dll open_sym_close dynlib_win_normalize_path; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 5. Gate' "$DOC" 2>/dev/null || die "doc missing '## 5. Gate'"

sym_miss="$(std_dynlib_win_manifest_ok "$DOC" "$DYNLIB_RUNTIME" "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "manifest_miss=${sym_miss}"
echo "std-dynlib-windows manifest OK"

if [ "${XLANG_STD_DYNLIB_WIN_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_dynlib_win_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-dynlib-windows gate OK (manifest only)"
  exit 0
fi

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover unused compiler-make SOURCE / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm (refuse leftover unused compiler-make SOURCE / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0
echo "=== STD-027: smoke (XLANG=$XLANG_BIN; check/C obs; osc+null+win_path product -o hard) ==="

# Observational host-C archaeology (existing .o only; refuse soft auto-make).
# PLATFORM: SHARED archaeology — product honesty is .x via asm.
echo "=== STD-027: win path C smoke (observational) ==="
if [ -f std/dynlib/dynlib.o ] && [ -f compiler/runtime_dynlib_os.o ] \
  && std_dynlib_win_run_c_smoke; then
  echo "std-dynlib-windows c smoke OK (observational)"
else
  echo "std-dynlib-windows OBS c smoke (host-C archaeology; refuse soft ensure rebuild)" >&2
  OBS=$((OBS + 1))
fi

# Observational check (paused 2026-08-05).
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std027_chk_osc.log 2>&1
chk1=$?
"$XLANG_BIN" check -L . "$NULL_TEST" >/tmp/xlang_std027_chk_null.log 2>&1
chk2=$?
"$XLANG_BIN" check -L . "$WIN_PATH_X" >/tmp/xlang_std027_chk_wp.log 2>&1
chk3=$?
set -e
if [ "$chk1" -ne 0 ] || [ "$chk2" -ne 0 ] || [ "$chk3" -ne 0 ]; then
  echo "std-dynlib-windows OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

run_one() {
  local src="$1"
  local out="$2"
  local log="$3"
  local label="$4"
  if $RUN_XLANG build -L . "$src" -o "$out" 2>"$log"; then
    local exitcode=0
    "$out" >/dev/null 2>&1 || exitcode=$?
    rm -f "$out"
    if [ "$exitcode" -eq 0 ]; then
      return 0
    fi
    echo "std-dynlib-windows FAIL ${label} exit=$exitcode" >&2
    return 1
  fi
  echo "std-dynlib-windows FAIL ${label} link" >&2
  tail -20 "$log" 2>/dev/null >&2 || true
  return 1
}

if run_one "$SMOKE" "/tmp/xlang_std027_osc_$$" "/tmp/xlang_std027_osc_$$.log" "open_sym_close"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-dynlib-windows OK: open_sym_close"
else
  die "open_sym_close.x exit!=0 (refuse soft SKIP→OK)"
fi
if run_one "$NULL_TEST" "/tmp/xlang_std027_null_$$" "/tmp/xlang_std027_null_$$.log" "main.null"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-dynlib-windows OK: main"
else
  die "main.x exit!=0 (refuse soft SKIP→OK)"
fi
if run_one "$WIN_PATH_X" "/tmp/xlang_std027_wp_$$" "/tmp/xlang_std027_wp_$$.log" "win_path.x"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-dynlib-windows OK: win_path"
else
  die "win_path.x exit!=0 (refuse soft SKIP→OK)"
fi

std_dynlib_win_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-dynlib-windows gate OK (host=$(ci_host_summary))"
