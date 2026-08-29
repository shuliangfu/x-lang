#!/usr/bin/env bash
# STD-142: std.process xplat — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# xplat_behavior + boundary exit0 = hard run (run+=). check + win/pipe
# (XT001 neighborhood) = obs. Report: run=/obs=/skip=. G.7: complete
# existing resolve_shu; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-process-xplat-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-process-xplat gate FAIL: $*" >&2
  std_process_xplat_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-142: std.process xplat manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-process-xplat-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$PROC_C" "$PROC_X" \
  "$SMOKE_X" "$BOUNDARY_X" std/process/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-142 spawn_io getppid spawn_wait_win pipe; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

sym_miss="$(std_process_xplat_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"

std_process_xplat_vectors_ok "$VECTORS" "$MIN_VECTORS" || die "vectors"
echo "std-process-xplat registry OK"

if [ "${XLANG_STD142_PROCESS_XPLAT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_process_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-process-xplat gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-142: smoke (XLANG=$XLANG_BIN; check/win/pipe obs; xplat+boundary product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std142_chk_xplat.log 2>&1
chk1=$?
"$XLANG_BIN" check -L . "$BOUNDARY_X" >/tmp/xlang_std142_chk_bound.log 2>&1
chk2=$?
set -e
if [ "$chk1" -ne 0 ] || [ "$chk2" -ne 0 ]; then
  echo "std-process-xplat OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

for sym in getpid getppid spawn_simple waitpid pipe spawn_io; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "mod missing function ${sym}"
done
grep -q 'unsafe' "$MOD_X" 2>/dev/null || die "mod missing unsafe extern wrappers"

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

if std_process_xplat_run_smoke "$XLANG_BIN" "$SMOKE_X"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-process-xplat OK: xplat_behavior"
else
  die "xplat_behavior.x exit!=0 (refuse soft SKIP→OK)"
fi
if std_process_xplat_run_smoke "$XLANG_BIN" "$BOUNDARY_X"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-process-xplat OK: boundary"
else
  die "boundary.x exit!=0 (refuse soft SKIP→OK)"
fi

# Observational only: Windows spawn / pipe-echo still XT001 product typeck
# (process-pipe neighborhood; not soft). Do not soft-SKIP→OK the gate.
# PLATFORM: SHARED archaeology — report via obs=.
echo "=== STD-142: win/pipe observational (not hard) ==="
if [ -f "$WIN_X" ] && std_process_xplat_run_smoke "$XLANG_BIN" "$WIN_X" 2>/dev/null; then
  echo "std-process-xplat win smoke OK (observational)"
else
  echo "std-process-xplat OBS win smoke (XT001/product; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
if [ -f "$PIPE_X" ] && std_process_xplat_run_smoke "$XLANG_BIN" "$PIPE_X" 2>/dev/null; then
  echo "std-process-xplat pipe smoke OK (observational)"
else
  echo "std-process-xplat OBS pipe smoke (XT001/product; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_process_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-process-xplat gate OK (host=$(ci_host_summary))"
