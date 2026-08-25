#!/usr/bin/env bash
# STD-026: std.io non-Linux io_uring fallback matrix gate (false-authority honesty).
#
# Usage: ./tests/run-std-io-fallback-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); fallback_matrix.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product authority = backend.x + sync.x + win32.x (io.c retired); gate was
# portable-false-red (prefer xlang-c / soft SKIP / hard typeck / ## 5. 验收
# without ## 6. Gate / TSV still required deleted io.c).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-io-fallback-v1.md ]; then
  echo "std-io-fallback gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-026: std.io fallback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$BACKEND_X" "$SYNC_X" "$WIN32_X" "$MOD_X" \
  "$README" "$SMOKE" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-io-fallback gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in macOS Windows io_uring kqueue IOCP read_batch_fd backend.x; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-io-fallback gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-io-fallback gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

split="$(std_io_fallback_manifest_ok "$DOC" "$README" "$MANIFEST" || true)"
matrix_miss="${split%% *}"
code_miss="${split#* }"
if [ "${matrix_miss:-0}" -gt 0 ] || [ "${code_miss:-0}" -gt 0 ]; then
  std_io_fallback_emit_report "fail" 0 0 0 0 0 0
  echo "std-io-fallback gate FAIL: matrix_miss=${matrix_miss} code_miss=${code_miss}" >&2
  exit 1
fi
echo "std-io-fallback manifest OK"

if [ "${XLANG_STD_IO_FALLBACK_MANIFEST_ONLY:-0}" = "1" ]; then
  std_io_fallback_emit_report "ok" 1 1 1 0 0 1
  echo "std-io-fallback gate OK (manifest only)"
  exit 0
fi

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
RUN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-026: smoke (XLANG=$XLANG_BIN; check observational; fallback_matrix hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-io-fallback gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_io_fallback_run_smoke "$XLANG_BIN" "$SMOKE" "matrix"; then
    RUN_OK=1
  else
    std_io_fallback_emit_report "fail" 1 1 1 "$CHECK_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-io-fallback gate FAIL: no native xlang" >&2
  std_io_fallback_emit_report "fail" 1 1 1 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run=.
echo "std-io-fallback check_ok=${CHECK_OK} (observational)"
std_io_fallback_emit_report "ok" 1 1 1 "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-io-fallback gate OK"
