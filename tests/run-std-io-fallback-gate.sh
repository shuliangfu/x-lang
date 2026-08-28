#!/usr/bin/env bash
# STD-026: std.io non-Linux io_uring fallback — honesty leftover wrap →硬绿.
#
# Honesty: leftover bootstrap-link wrap + fossil `$RUN_XLANG build` in
# std_io_fallback_run_smoke retired (product path is `"$xlang" -L . -o`).
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse leftover wrap / fossil RUN_XLANG build /
# soft SKIP→OK / soft auto-make / prefer-c). Product fallback_matrix.x -o
# exit0 = hard run (run=1). check = obs. Report: run=/obs=/skip=.
# G.7: complete existing run_smoke; drop unused compiler-make.sh.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-io-fallback-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_IO_FALLBACK_DOC:-analysis/archive/std/std-io-fallback-v1.md}"
MANIFEST="${XLANG_STD_IO_FALLBACK_TSV:-tests/baseline/std-io-fallback.tsv}"
BACKEND_X="std/io/backend.x"
SYNC_X="std/io/sync.x"
WIN32_X="std/io/win32.x"
MOD_X="std/io/mod.x"
README="std/io/README.md"
LIB="tests/lib/std-io-fallback.sh"
SMOKE="tests/io/fallback_matrix.x"
RUNNER="tests/run-io.sh"

# shellcheck source=tests/lib/std-io-fallback.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-io-fallback gate FAIL: $*" >&2
  std_io_fallback_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-io-fallback-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-026: std.io fallback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$BACKEND_X" "$SYNC_X" "$WIN32_X" "$MOD_X" \
  "$README" "$SMOKE" "$RUNNER"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in macOS Windows io_uring kqueue IOCP read_batch_fd backend.x; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

split="$(std_io_fallback_manifest_ok "$DOC" "$README" "$MANIFEST" || true)"
matrix_miss="${split%% *}"
code_miss="${split#* }"
[ "${matrix_miss:-0}" -eq 0 ] && [ "${code_miss:-0}" -eq 0 ] || \
  die "matrix_miss=${matrix_miss} code_miss=${code_miss}"
echo "std-io-fallback manifest OK"

if [ "${XLANG_STD_IO_FALLBACK_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_io_fallback_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-io-fallback gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-026: smoke (XLANG=$XLANG_BIN; check obs; fallback_matrix product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_io_fallback_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-io-fallback OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap / fossil `$RUN_XLANG build` (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
if std_io_fallback_run_smoke "$XLANG_BIN" "$SMOKE" "matrix"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-io-fallback OK: fallback_matrix"
else
  die "fallback_matrix.x exit!=0 (refuse soft SKIP→OK)"
fi

std_io_fallback_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-io-fallback gate OK"
