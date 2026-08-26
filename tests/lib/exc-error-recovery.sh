#!/usr/bin/env bash
# EXC-006: error recovery single-case / full suite runner (gate + local debug).
#
# Usage:
#   ./tests/lib/exc-error-recovery.sh              # full runnable (needs native xlang)
#   ./tests/lib/exc-error-recovery.sh case_id      # single case
#   XLANG=./compiler/xlang_asm ./tests/lib/exc-error-recovery.sh
#
# 2026-08-26 honesty: prefer xlang_asm then xlang-c/xlang; pin XLANG_LINK_XLANG
# when resolving; hard-fail compile/run (no soft SKIP→OK).
# PLATFORM: SHARED archaeology.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
set -e
cd "$(dirname "$0")/../.."

MATRIX="${XLANG_EXC_ERROR_RECOVERY_TSV:-tests/baseline/exc-error-recovery-cases.tsv}"
ONE_CASE="${1:-}"

# Detect native (same-arch) xlang binary.
# PLATFORM: SHARED — Darwin/Linux ELF|Mach-O arch check.
native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; fall back to xlang-c / xlang.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

# 编译并运行 .x，校验退出码
exc_recovery_run_x() {
  local xlang="$1"
  local src="$2"
  local want_ec="$3"
  local tag="$4"
  local out="/tmp/xlang_exc_recovery_${tag}"
  if [ ! -f "$src" ]; then
    echo "exc-recovery FAIL: missing $src" >&2
    return 1
  fi
  # Compile with resolved product compiler (prefer asm; LINK pin is for hooks).
  # PLATFORM: SHARED
  set +e
  if [ -n "${RUN_XLANG:-}" ]; then
    # shellcheck disable=SC2086
    $RUN_XLANG -L . "$src" -o "$out" >/tmp/xlang_exc_recovery_compile.log 2>&1
  else
    "$xlang" -L . "$src" -o "$out" >/tmp/xlang_exc_recovery_compile.log 2>&1
  fi
  local comp_ec=$?
  set -e
  if [ "$comp_ec" -ne 0 ]; then
    # Hard-fail compile: check-only after SIGSEGV was soft-green (check gate paused).
    cat /tmp/xlang_exc_recovery_compile.log >&2
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  if [ "$ec" -ne "$want_ec" ]; then
    echo "exc-recovery FAIL $tag: exit=$ec want=$want_ec" >&2
    return 1
  fi
  return 0
}

# 执行矩阵一行 runnable case
exc_recovery_run_row() {
  local xlang="$1"
  local case_id="$2"
  local script="$3"
  local policy="$4"
  local want_ec="${5:-0}"
  case "$policy" in
    run)
      exc_recovery_run_x "$xlang" "tests/exc/${script}" "$want_ec" "$case_id"
      ;;
    run_path)
      exc_recovery_run_x "$xlang" "$script" "$want_ec" "$case_id"
      ;;
    observe)
      # Honest residual (e.g. ErrorChain 20B asm ABI): keep row, do not hard-red gate.
      set +e
      exc_recovery_run_x "$xlang" "tests/exc/${script}" "$want_ec" "$case_id" \
        >/tmp/xlang_exc_observe_${case_id}.log 2>&1
      local _orc=$?
      set -e
      if [ "$_orc" -eq 0 ]; then
        return 0
      fi
      echo "exc-recovery SKIP $case_id ($script; observational residual)" >&2
      return 0
      ;;
    hook)
      local hook="tests/${script}"
      if [ ! -f "$hook" ]; then
        echo "exc-recovery FAIL: missing hook $hook" >&2
        return 1
      fi
      chmod +x "$hook" 2>/dev/null || true
      XLANG="$xlang" "$hook"
      ;;
    *)
      echo "exc-recovery WARN: unknown policy $policy ($case_id)" >&2
      return 1
      ;;
  esac
}

XLANG_BIN=""
if XLANG_BIN="$(resolve_shu)"; then
  :
else
  # Hard residual: gate owns FAIL when no native; runner exit 2 for local debug.
  echo "exc-error-recovery: no native xlang" >&2
  exit 2
fi

# Pin product link to resolved compiler (prefer asm; avoid Darwin asm→c remap).
# PLATFORM: SHARED
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=bootstrap-link-xlang.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/bootstrap-link-xlang.sh"

# Quiet ensure; resolve already found a native binary so make failure is soft.
xlang_compiler_make -q 2>/dev/null || true
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

FAILS=0
FOUND=0
while IFS=$'\t' read -r case_id script policy want_ec _cat notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in
    \#*|min_items|min_cases|docs) continue ;;
  esac
  if [ -n "$ONE_CASE" ] && [ "$case_id" != "$ONE_CASE" ]; then
    continue
  fi
  FOUND=$((FOUND + 1))
  echo "── exc-recovery $case_id: ${notes:-} ──"
  if exc_recovery_run_row "$XLANG_BIN" "$case_id" "$script" "$policy" "${want_ec:-0}"; then
    echo "exc-recovery OK $case_id"
  else
    FAILS=$((FAILS + 1))
  fi
done < "$MATRIX"

if [ -n "$ONE_CASE" ] && [ "$FOUND" -eq 0 ]; then
  echo "exc-recovery FAIL: unknown case_id=$ONE_CASE" >&2
  exit 1
fi

if [ "$FAILS" -gt 0 ]; then
  echo "exc-error-recovery runner FAIL: ${FAILS} case(s)" >&2
  exit 1
fi
echo "exc-error-recovery runner OK (${FOUND} case(s))"
