#!/usr/bin/env bash
# EXC-002: panic/abort vs recoverable-error boundary gate (false-authority honesty).
#
# Usage: ./tests/run-exc-panic-abort-gate.sh
# wave honesty (2026-08-24 #12): DOC → analysis/archive/exc/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); matrix run+hook hard-fail via TSV
# (no soft SKIP→OK when no native). Report check=/run=/skip=.
# Gate was portable-false-red (prefer xlang-c / soft SKIP→OK when no native /
# DOC ## 7. 门禁 without Gate honesty). Ubuntu/Darwin asm smoke already exit0.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_EXC_PANIC_ABORT_DOC:-analysis/archive/exc/exc-panic-abort-v1-rfc.md}"
MATRIX="${XLANG_EXC_PANIC_ABORT_TSV:-tests/baseline/exc-panic-abort.tsv}"
SMOKE="tests/exc/recoverable_result.x"
MIN_CASES=7

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
exc_panic_abort_resolve_shu() {
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

exc_panic_abort_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "exc-panic-abort status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}

echo "=== EXC-002: panic/abort boundary manifest ==="

# Refuse resurrected top-level DOC (live = archive/exc/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/exc-panic-abort-v1-rfc.md ]; then
  echo "exc-panic-abort-gate gate FAIL: top-level DOC resurrected (live = archive/exc/)" >&2
  exit 1
fi

if [ -f analysis/exc-result-error-v1-rfc.md ]; then
  echo "exc-panic-abort-gate gate FAIL: companion top-level DOC resurrected (analysis/exc-result-error-v1-rfc.md)" >&2
  exit 1
fi

for f in \
  "$DOC" \
  analysis/archive/exc/exc-result-error-v1-rfc.md \
  "$MATRIX" \
  "$SMOKE" \
  tests/exc/layer_c_recoverable.x \
  tests/exc/runtime_ready.x \
  tests/exc/expect_or_panic_ok.x \
  tests/run-result.sh \
  tests/run-error.sh \
  tests/run-panic.sh; do
  if [ ! -f "$f" ] && [ ! -e "$f" ]; then
    echo "exc-panic-abort gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in EXC-002 panic abort recoverable Result; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "exc-panic-abort gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 7. Gate' "$DOC" 2>/dev/null; then
  echo "exc-panic-abort gate FAIL: doc missing '## 7. Gate'" >&2
  exit 1
fi

FOUND=0
while IFS=$'\t' read -r case_id script policy want_ec notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*) continue ;;
    min_*) continue ;;
    docs)
      # TSV docs row: want_ec holds the required DOC section anchor.
      if [ -n "${want_ec:-}" ] && ! grep -qF "$want_ec" "$DOC" 2>/dev/null; then
        echo "exc-panic-abort gate FAIL: doc missing section '$want_ec'" >&2
        exit 1
      fi
      continue
      ;;
  esac
  FOUND=$((FOUND + 1))
  case "$policy" in
    run)
      if [ ! -f "tests/exc/${script}" ]; then
        echo "exc-panic-abort gate FAIL: missing tests/exc/${script} ($case_id)" >&2
        exit 1
      fi
      ;;
    hook)
      if [ ! -f "tests/${script}" ]; then
        echo "exc-panic-abort gate FAIL: missing tests/${script} ($case_id)" >&2
        exit 1
      fi
      ;;
    *)
      echo "exc-panic-abort gate FAIL: bad policy $policy ($case_id)" >&2
      exit 1
      ;;
  esac
done < "$MATRIX"

if [ "$FOUND" -lt "$MIN_CASES" ]; then
  echo "exc-panic-abort gate FAIL: cases=${FOUND} < min_cases=${MIN_CASES}" >&2
  exit 1
fi
echo "exc-panic-abort manifest OK (cases=${FOUND})"

if [ "${XLANG_EXC_PANIC_ABORT_MANIFEST_ONLY:-0}" = "1" ]; then
  exc_panic_abort_emit_report "ok" 0 0 1
  echo "exc-panic-abort gate OK (manifest only)"
  exit 0
fi

# Best-effort quiet make (do not soft-SKIP the gate when make is noisy).
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make || true

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(exc_panic_abort_resolve_shu 2>/dev/null)"; then
  echo "=== EXC-002: smoke (XLANG=$XLANG_BIN; check observational; runnable+hook hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "exc-panic-abort gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  # Skip nested make inside hook scripts (gate already best-effort made).
  export XLANG_SKIP_SUBSCRIPT_MAKE=1

  run_x_case() {
    local script="$1"
    local want_ec="$2"
    local src="tests/exc/${script}"
    local out="/tmp/xlang_exc_panic_abort_${script%.x}_$$"
    local ec=0
    if $RUN_XLANG build -L . "$src" -o "$out" >/tmp/xlang_exc_panic_abort_compile_$$.log 2>&1 \
      || "$XLANG_BIN" -L . "$src" -o "$out" >/tmp/xlang_exc_panic_abort_compile_$$.log 2>&1; then
      "$out" >/dev/null 2>&1 || ec=$?
      rm -f "$out"
      if [ "$ec" -ne "$want_ec" ]; then
        echo "exc-panic-abort FAIL $script: exit=$ec want=$want_ec" >&2
        return 1
      fi
      return 0
    fi
    echo "exc-panic-abort FAIL compile $script" >&2
    tail -20 /tmp/xlang_exc_panic_abort_compile_$$.log >&2 || true
    rm -f "$out"
    return 1
  }

  FAILS=0
  while IFS=$'\t' read -r case_id script policy want_ec notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in
      \#*|docs|min_*) continue ;;
    esac
    echo "── $case_id: ${notes:-} ──"
    case "$policy" in
      run)
        if run_x_case "$script" "${want_ec:-0}"; then
          echo "exc OK $case_id"
        else
          echo "exc FAIL $case_id ($script)" >&2
          FAILS=$((FAILS + 1))
        fi
        ;;
      hook)
        hook="tests/${script}"
        chmod +x "$hook" 2>/dev/null || true
        if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" XLANG_SKIP_SUBSCRIPT_MAKE=1 "$hook"; then
          echo "exc OK $case_id ($script)"
        else
          echo "exc FAIL $case_id ($script)" >&2
          FAILS=$((FAILS + 1))
        fi
        ;;
    esac
  done < "$MATRIX"

  rm -f /tmp/xlang_exc_panic_abort_compile_$$.log

  if [ "$FAILS" -gt 0 ]; then
    echo "exc-panic-abort gate FAIL: ${FAILS} case(s)" >&2
    exc_panic_abort_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
  RUN_OK=1
  SKIP=0
else
  echo "exc-panic-abort gate FAIL: no native xlang" >&2
  exc_panic_abort_emit_report "fail" 0 0 0
  exit 2
fi

# check stays observational; hard-green signal is run= (matrix).
echo "exc-panic-abort check_ok=${CHECK_OK} (observational)"
exc_panic_abort_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "exc-panic-abort gate OK"
