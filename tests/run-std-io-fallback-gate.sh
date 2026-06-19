#!/usr/bin/env bash
# STD-026：std.io 非 Linux io_uring 回退统一文档门禁
#
# 用法：./tests/run-std-io-fallback-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_IO_FALLBACK_DOC:-analysis/std-io-fallback-v1.md}"
MANIFEST="${SHUX_STD_IO_FALLBACK_TSV:-tests/baseline/std-io-fallback.tsv}"
IO_C="std/io/io.c"
MOD_SU="std/io/mod.sx"
README="std/io/README.md"
LIB="tests/lib/std-io-fallback.sh"
SMOKE="tests/io/fallback_matrix.sx"
RUNNER="tests/run-io.sh"

# shellcheck source=tests/lib/std-io-fallback.sh
. tests/lib/std-io-fallback.sh

echo "=== STD-026: std.io fallback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$IO_C" "$MOD_SU" "$README" "$SMOKE" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-io-fallback gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in macOS Windows io_uring kqueue IOCP read_batch_fd; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-io-fallback gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

split="$(std_io_fallback_manifest_ok "$DOC" "$README" "$IO_C" "$MOD_SU" "$MANIFEST" || true)"
matrix_miss="${split%% *}"
code_miss="${split#* }"
if [ "${matrix_miss:-0}" -gt 0 ] || [ "${code_miss:-0}" -gt 0 ]; then
  std_io_fallback_emit_report "fail" 0 0 0 0 0
  echo "std-io-fallback gate FAIL: matrix_miss=${matrix_miss} code_miss=${code_miss}" >&2
  exit 1
fi
echo "std-io-fallback manifest OK"

stdlib_cm_native_shu() {
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
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-026: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-io-fallback gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_io_fallback_emit_report "fail" 1 1 1 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-io-fallback gate SKIP typeck (no native shux)" >&2
fi

std_io_fallback_emit_report "ok" 1 1 1 "$CHECK_OK" "$SKIP"
echo "std-io-fallback gate OK"
