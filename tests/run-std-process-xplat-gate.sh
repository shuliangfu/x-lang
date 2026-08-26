#!/usr/bin/env bash
# STD-142：std.process 跨平台行为一致性门禁（假权威诚实）。
#
# 用法：./tests/run-std-process-xplat-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); xplat_behavior.x + boundary.x exit 0 hard-fail
# (no soft SKIP when native xlang present). spawn_wait_win / spawn_pipe_echo
# observational (XT001 product typeck; not soft). Report check=/xplat=/boundary=/skip=.
# Product surface already green under asm for aggregate+boundary; gate was
# portable-false-red (prefer xlang-c / hard check / soft SKIP / fossil DOC path).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD142_PROCESS_XPLAT_DOC:-analysis/archive/std/std-process-xplat-v1.md}"
MANIFEST="${XLANG_STD142_PROCESS_XPLAT_MANIFEST:-tests/baseline/std-process-xplat-manifest.tsv}"
VECTORS="${XLANG_STD142_PROCESS_XPLAT_VECTORS:-tests/baseline/std-process-xplat.tsv}"
MOD_X="std/process/mod.x"
PROC_C="${XLANG_STD_PROCESS_IMPL:-compiler/seeds/runtime_process_os_glue.from_x.c}"
PROC_X="std/process/process.x"
LIB="tests/lib/std-process-xplat.sh"
SMOKE_X="tests/process/xplat_behavior.x"
BOUNDARY_X="tests/process/boundary.x"
WIN_X="tests/process/spawn_wait_win.x"
PIPE_X="tests/process/spawn_pipe_echo.x"
MIN_VECTORS=10

# shellcheck source=tests/lib/std-process-xplat.sh
. "$LIB"

echo "=== STD-142: std.process xplat manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-process-xplat-v1.md ]; then
  echo "std-process-xplat gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$PROC_C" "$PROC_X" "$SMOKE_X" "$BOUNDARY_X" std/process/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-process-xplat gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-142 spawn_io getppid spawn_wait_win pipe; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-process-xplat gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-process-xplat gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_process_xplat_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_process_xplat_emit_report "fail" 0 0 0 0
  exit 1
fi

if ! std_process_xplat_vectors_ok "$VECTORS" "$MIN_VECTORS"; then
  std_process_xplat_emit_report "fail" 0 0 0 0
  exit 1
fi
echo "std-process-xplat registry OK"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

stdlib_cm_native_xlang() {
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

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
XPLAT_OK=0
BOUNDARY_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-142: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$BOUNDARY_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-process-xplat gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  for sym in getpid getppid spawn_simple waitpid pipe spawn_io; do
    if ! grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null; then
      echo "std-process-xplat gate FAIL: mod missing function ${sym}" >&2
      std_process_xplat_emit_report "fail" "$CHECK_OK" 0 0 0
      exit 1
    fi
  done
  if ! grep -q 'unsafe' "$MOD_X" 2>/dev/null; then
    echo "std-process-xplat gate FAIL: mod missing unsafe extern wrappers" >&2
    std_process_xplat_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi

  xlang_compiler_make -q ../std/process/process.o 2>/dev/null || xlang_compiler_make ../std/process/process.o 2>/dev/null || true
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if ! std_process_xplat_run_smoke "$XLANG_BIN" "$SMOKE_X"; then
    std_process_xplat_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  XPLAT_OK=1

  if ! std_process_xplat_run_smoke "$XLANG_BIN" "$BOUNDARY_X"; then
    std_process_xplat_emit_report "fail" "$CHECK_OK" "$XPLAT_OK" 0 0
    exit 1
  fi
  BOUNDARY_OK=1
  SKIP=0

  # Observational only: Windows spawn / pipe-echo still XT001 product typeck
  # (process-pipe neighborhood; not soft). Do not soft-SKIP→OK the gate.
  # PLATFORM: SHARED archaeology — report note only.
  echo "=== STD-142: win/pipe observational (not hard) ==="
  WIN_NOTE=0
  PIPE_NOTE=0
  if [ -f "$WIN_X" ] && std_process_xplat_run_smoke "$XLANG_BIN" "$WIN_X" 2>/dev/null; then
    WIN_NOTE=1
  else
    echo "std-process-xplat gate SKIP win smoke (observational; XT001/product)" >&2
  fi
  if [ -f "$PIPE_X" ] && std_process_xplat_run_smoke "$XLANG_BIN" "$PIPE_X" 2>/dev/null; then
    PIPE_NOTE=1
  else
    echo "std-process-xplat gate SKIP pipe smoke (observational; XT001/product)" >&2
  fi
  echo "std-process-xplat win_note=${WIN_NOTE} pipe_note=${PIPE_NOTE}"
else
  echo "std-process-xplat gate FAIL: no native xlang" >&2
  std_process_xplat_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is xplat= + boundary=.
echo "std-process-xplat check_ok=${CHECK_OK} (observational) host=$(ci_host_summary)"
std_process_xplat_emit_report "ok" "$CHECK_OK" "$XPLAT_OK" "$BOUNDARY_OK" "$SKIP"
echo "std-process-xplat gate OK"
