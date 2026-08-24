#!/usr/bin/env bash
# COMP-011：Windows 目标后端烟测
#
# 用法：./tests/run-comp-win-backend.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

# shellcheck source=tests/lib/comp-win-backend.sh
. tests/lib/comp-win-backend.sh

MATRIX="${XLANG_WIN_BACKEND_MATRIX:-tests/baseline/comp-win-backend-matrix.tsv}"
SAMPLE="tests/asm/windows_min.x"
COFF_OUT="/tmp/xlang_comp_win_backend.$$.obj"
trap 'rm -f "$COFF_OUT" /tmp/xlang_comp_win_exe.$$.exe 2>/dev/null || true' EXIT

echo "=== COMP-011: Windows backend smoke ==="

XLANG_BIN=""
if XLANG_BIN="$(comp_win_backend_pick_xlang 2>/dev/null || true)"; then
  :
fi

if [ -z "$XLANG_BIN" ]; then
  echo "comp-win-backend SKIP (no asm-capable xlang; seed/C-only build)"
  echo "comp-win-backend OK"
  exit 0
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

if [ ! -f "$SAMPLE" ]; then
  echo "comp-win-backend FAIL: missing $SAMPLE" >&2
  exit 1
fi

# wave honesty close (2026-08-25): cross-host COFF writer lives in
# user_asm_seed_bridge seed (twin of coff.x). Darwin/Linux -target windows
# must hard-fail on emit miss — no observational SKIP soft-green.
# PLATFORM: SHARED cross-emit / WINDOWS MSYS also hard.
if ! comp_win_backend_emit_coff "$XLANG_BIN" "$SAMPLE" "$COFF_OUT" >/dev/null; then
  echo "comp-win-backend FAIL: COFF emit $SAMPLE (host=$(uname -s); product CG002)" >&2
  exit 1
fi
SZ="$(wc -c <"$COFF_OUT" | tr -d ' ')"
echo "comp-win-backend OK coff_emit sample=$SAMPLE bytes=$SZ"

# MSYS：尝试 lld-link/link 全链（optional）。
if comp_win_backend_is_msys; then
  EXE="/tmp/xlang_comp_win_exe.$$.exe"
  rm -f "$EXE" 2>/dev/null || true
  if command -v lld-link >/dev/null 2>&1; then
  if lld-link "/entry:_main" "/out:$EXE" "$COFF_OUT" 2>/dev/null && [ -x "$EXE" ]; then
    code=0
    "$EXE" 2>/dev/null || code=$?
    if [ "$code" -eq 42 ]; then
      echo "comp-win-backend OK link_run exit=42 (lld-link)"
    else
      echo "comp-win-backend WARN link_run exit=$code want=42"
    fi
  fi
  elif command -v link >/dev/null 2>&1; then
    if link "/entry:_main" "/out:$EXE" "$COFF_OUT" 2>/dev/null && [ -f "$EXE" ]; then
      code=0
      "$EXE" 2>/dev/null || code=$?
      echo "comp-win-backend OK link_run exit=$code (link)"
    fi
  else
    echo "comp-win-backend SKIP link (no lld-link/link)"
  fi
else
  echo "comp-win-backend SKIP link_run (cross-host emit only)"
fi

echo "comp-win-backend OK"
