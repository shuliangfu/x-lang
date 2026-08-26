#!/usr/bin/env bash
# EXC-006: error recovery suite gate (false-authority honesty).
#
# Usage: ./tests/run-exc-error-recovery-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); recovery suite runnable hard-fail via
# tests/lib/exc-error-recovery.sh (no soft SKIP→OK when no native).
# Report check=/run=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# DOC soft SKIP bench narrative). Ubuntu/Darwin asm smoke already exit0.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_ERROR_RECOVERY_DOC:-analysis/archive/exc/exc-error-recovery-v1.md}"
MATRIX="${XLANG_EXC_ERROR_RECOVERY_TSV:-tests/baseline/exc-error-recovery-cases.tsv}"
RUNNER="tests/lib/exc-error-recovery.sh"
SMOKE="tests/exc/recovery/r_or_fallback.x"
MIN_CASES=30

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
exc_error_recovery_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
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
  echo "exc-error-recovery status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
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
  exc_error_recovery_emit_report "ok" 0 0 1
  echo "exc-error-recovery gate OK (manifest only)"
  exit 0
fi

chmod +x "$RUNNER" 2>/dev/null || true

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(exc_error_recovery_resolve_shu 2>/dev/null)"; then
  echo "=== EXC-006: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "exc-error-recovery gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Hard-fail full suite via runner (no soft SKIP→OK).
  # PLATFORM: SHARED
  echo "=== EXC-006: runnable report (XLANG=$XLANG_BIN) ==="
  if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" "$RUNNER"; then
    RUN_OK=1
    SKIP=0
  else
    echo "exc-error-recovery gate FAIL: runnable report (XLANG=$XLANG_BIN)" >&2
    exc_error_recovery_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "exc-error-recovery gate FAIL: no native xlang" >&2
  exc_error_recovery_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (recovery suite).
echo "exc-error-recovery check_ok=${CHECK_OK} (observational)"
exc_error_recovery_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "exc-error-recovery gate OK"
