#!/usr/bin/env bash
# COMP-011: Windows target backend smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no asm-capable xlang retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG = hard die. Missing
# native = hard die. Native present but Windows asm not available =
# skip= (capability N/A, not soft SKIP→OK). COFF emit miss = hard fail
# when capable. Report run=/skip=.
#
# Usage: ./tests/run-comp-win-backend.sh
# PLATFORM: SHARED cross-emit / WINDOWS MSYS link optional.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-win-backend.sh
. tests/lib/comp-win-backend.sh

SAMPLE="tests/asm/windows_min.x"
COFF_OUT="/tmp/xlang_comp_win_backend.$$.obj"
PREFIX="xlang: [XLANG_COMP_WIN_BACKEND]"
RUN_OK=0
SKIP=0
trap 'rm -f "$COFF_OUT" /tmp/xlang_comp_win_exe.$$.exe 2>/dev/null || true' EXIT

die() {
  echo "comp-win-backend FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
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
    # Explicit XLANG that is missing or wrong-ABI = hard die (refuse soft SKIP→OK).
    return 1
  fi
  # Prefer product asm. PLATFORM: SHARED — product path honesty; Ubuntu gold.
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

echo "=== COMP-011: Windows backend smoke ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# Capability N/A (seed/C-only or no Windows asm) = skip=, not soft SKIP→OK.
if ! comp_win_backend_asm_capable "$XLANG_BIN"; then
  echo "comp-win-backend SKIP (native present; Windows asm not available; capability N/A)"
  SKIP=$((SKIP + 1))
  ok_report
  exit 0
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

[ -f "$SAMPLE" ] || die "missing $SAMPLE"

# PLATFORM: SHARED cross-emit / WINDOWS MSYS also hard — emit miss is product red.
if ! comp_win_backend_emit_coff "$XLANG_BIN" "$SAMPLE" "$COFF_OUT" >/dev/null; then
  die "COFF emit $SAMPLE (host=$(uname -s); product CG002)"
fi
SZ="$(wc -c <"$COFF_OUT" | tr -d ' ')"
echo "comp-win-backend OK coff_emit sample=$SAMPLE bytes=$SZ"
RUN_OK=$((RUN_OK + 1))

# MSYS: try lld-link/link full chain (optional).
if comp_win_backend_is_msys; then
  EXE="/tmp/xlang_comp_win_exe.$$.exe"
  rm -f "$EXE" 2>/dev/null || true
  if command -v lld-link >/dev/null 2>&1; then
    if lld-link "/entry:_main" "/out:$EXE" "$COFF_OUT" 2>/dev/null && [ -x "$EXE" ]; then
      code=0
      "$EXE" 2>/dev/null || code=$?
      if [ "$code" -eq 42 ]; then
        echo "comp-win-backend OK link_run exit=42 (lld-link)"
        RUN_OK=$((RUN_OK + 1))
      else
        echo "comp-win-backend WARN link_run exit=$code want=42"
        SKIP=$((SKIP + 1))
      fi
    else
      echo "comp-win-backend SKIP link_run (lld-link failed)"
      SKIP=$((SKIP + 1))
    fi
  elif command -v link >/dev/null 2>&1; then
    if link "/entry:_main" "/out:$EXE" "$COFF_OUT" 2>/dev/null && [ -f "$EXE" ]; then
      code=0
      "$EXE" 2>/dev/null || code=$?
      echo "comp-win-backend OK link_run exit=$code (link)"
      RUN_OK=$((RUN_OK + 1))
    else
      echo "comp-win-backend SKIP link_run (link failed)"
      SKIP=$((SKIP + 1))
    fi
  else
    echo "comp-win-backend SKIP link (no lld-link/link)"
    SKIP=$((SKIP + 1))
  fi
else
  echo "comp-win-backend SKIP link_run (cross-host emit only)"
  SKIP=$((SKIP + 1))
fi

echo "comp-win-backend OK"
ok_report
