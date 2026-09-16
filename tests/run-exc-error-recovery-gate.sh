#!/usr/bin/env bash
# EXC-006: error recovery suite gate (false-authority honesty).
#
# Usage: ./tests/run-exc-error-recovery-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`) retired.
# Leftover bootstrap-link wrap retired (product path is `"$XLANG_BIN" -L . -o`
# in the recovery runner; refuse `$RUN_XLANG` remap). Prefer xlang_asm; pin
# XLANG_LINK_XLANG. Explicit-bad XLANG / missing native = hard die. check
# observational (paused 2026-08-05); recovery suite runnable hard-fail via
# tests/lib/exc-error-recovery.sh. Report run=/obs=/skip= (keep check= extra).
# G.7: complete existing exc_error_recovery_resolve_shu; converge
# dod_native_exe; drop unused compiler-make.sh. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_EXC_ERROR_RECOVERY_DOC:-analysis/archive/exc/exc-error-recovery-v1.md}"
MATRIX="${XLANG_EXC_ERROR_RECOVERY_TSV:-tests/baseline/exc-error-recovery-cases.tsv}"
RUNNER="tests/lib/exc-error-recovery.sh"
SMOKE="tests/exc/recovery/r_or_fallback.x"
MIN_CASES=30

# G.7: complete existing exc_error_recovery_resolve_shu. Explicit XLANG
# that is missing or non-native returns 1 (caller hard-dies). Unset XLANG
# prefers asm. Native check converges on dod_native_exe.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
exc_error_recovery_resolve_shu() {
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

exc_error_recovery_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  local obs="${5:-0}"
  echo "exc-error-recovery status=${status} check=${check_ok} run=${run_ok} obs=${obs} skip=${skip}"
}

echo "=== EXC-006: error recovery manifest ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-error-recovery-v1.md ]; then
  echo "exc-error-recovery-gate gate FAIL: top-level DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" "$RUNNER" "$SMOKE" tests/exc/recovery; do
  if [ ! -e "$f" ]; then
    echo "exc-error-recovery gate FAIL: missing $f" >&2
    exit 1
  fi
done

# RFC must contain gate keywords + honesty Gate section.
for kw in runnable report R1-unwrap-or R6-suite; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "exc-error-recovery gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "exc-error-recovery gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_cases) MIN_CASES="${c2# }" ;;
  esac
done < "$MATRIX"

MISS=0
FOUND=0
echo "=== EXC-006: matrix walk ==="
while IFS=$'\t' read -r case_id script policy want_ec category notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*) continue ;;
    min_cases|min_items) continue ;;
    docs)
      section="${want_ec:-}"
      if [ -n "$section" ] && ! grep -qF "$section" "$DOC" 2>/dev/null; then
        echo "exc-error-recovery FAIL: doc missing section '$section' (${notes:-})" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case_*)
      FOUND=$((FOUND + 1))
      case "$policy" in
        run|observe)
          src="tests/exc/${script}"
          if [ ! -f "$src" ]; then
            echo "exc-error-recovery FAIL: missing $src ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        run_path)
          if [ ! -f "$script" ]; then
            echo "exc-error-recovery FAIL: missing $script ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        hook)
          hook="tests/${script}"
          if [ ! -f "$hook" ]; then
            echo "exc-error-recovery FAIL: missing hook $hook ($case_id)" >&2
            MISS=$((MISS + 1))
          fi
          ;;
        *)
          echo "exc-error-recovery FAIL: bad policy $policy ($case_id)" >&2
          MISS=$((MISS + 1))
          ;;
      esac
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_CASES" ]; then
  echo "exc-error-recovery gate FAIL: cases=${FOUND} < min_cases=${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "exc-error-recovery gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "exc-error-recovery manifest OK (cases=${FOUND})"

if [ "${XLANG_EXC_ERROR_RECOVERY_MANIFEST_ONLY:-0}" = "1" ]; then
  exc_error_recovery_emit_report "ok" 0 0 1 0
  echo "exc-error-recovery gate OK (manifest only)"
  exit 0
fi

chmod +x "$RUNNER" 2>/dev/null || true

CHECK_OK=0
RUN_OK=0
OBS=0
SKIP=1

if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(exc_error_recovery_resolve_shu)"; then
    echo "exc-error-recovery gate FAIL: explicit XLANG not native (refuse leftover XLANG fallthrough)" >&2
    exc_error_recovery_emit_report "fail" 0 0 0 0
    exit 1
  fi
elif ! XLANG_BIN="$(exc_error_recovery_resolve_shu)"; then
  echo "exc-error-recovery gate FAIL: no native xlang" >&2
  exc_error_recovery_emit_report "fail" 0 0 0 0
  exit 1
fi

echo "=== EXC-006: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "exc-error-recovery gate SKIP check smoke (paused 2026-08-05)" >&2
fi

# Pin product link to resolved compiler (prefer asm).
# Refuse leftover bootstrap-link wrap / leftover `$RUN_XLANG` remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Hard-fail full suite via runner (no soft SKIP→OK / leftover wrap).
# PLATFORM: SHARED
echo "=== EXC-006: runnable report (XLANG=$XLANG_BIN) ==="
if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$RUNNER"; then
  RUN_OK=1
  SKIP=0
else
  echo "exc-error-recovery gate FAIL: runnable report (XLANG=$XLANG_BIN)" >&2
  if [ "$CHECK_OK" -eq 0 ]; then OBS=1; fi
  exc_error_recovery_emit_report "fail" "$CHECK_OK" 0 0 "$OBS"
  exit 1
fi

# check stays observational; hard-green signal is run= (recovery suite).
if [ "$CHECK_OK" -eq 0 ]; then OBS=1; fi
echo "exc-error-recovery check_ok=${CHECK_OK} (observational)"
exc_error_recovery_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP" "$OBS"
echo "exc-error-recovery gate OK"
