#!/usr/bin/env bash
# STD-019：std.fmt 多参数 format 门禁
#
# 用法：./tests/run-std-fmt-multi-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_FMT_MULTI_DOC:-analysis/std-fmt-multi-v1.md}"
MANIFEST="${SHUX_STD_FMT_MULTI_TSV:-tests/baseline/std-fmt-multi.tsv}"
FMT_SX="std/fmt/mod.sx"
LIB="tests/lib/std-fmt-multi.sh"
SMOKE="tests/fmt-std/format_multi.sx"
RUNNER="tests/run-fmt-std.sh"

# shellcheck source=tests/lib/std-fmt-multi.sh
. tests/lib/std-fmt-multi.sh

echo "=== STD-019: fmt multi manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$FMT_SX" "$SMOKE" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "std-fmt-multi gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in 'usize, usize' 'i32, i32, i32' fmt_ptr_to_buf; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-fmt-multi gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_fmt_multi_symbols_ok "$FMT_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_fmt_multi_emit_report "fail" 0 0 0
  echo "std-fmt-multi gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-fmt-multi manifest OK"

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
RUN_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-019: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-fmt-multi gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_fmt_multi_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/shux-link-env.sh
  . "$(dirname "$0")/lib/shux-link-env.sh"
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if $RUN_SHUX -L . "$SMOKE" -o /tmp/shux_std_fmt_multi 2>/tmp/shux_std_fmt_multi_build.log; then
    exitcode=0
    /tmp/shux_std_fmt_multi >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "std-fmt-multi gate FAIL: runnable exit=$exitcode" >&2
      std_fmt_multi_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    if grep -qE "library 'zstd' not found|cannot find -lzstd" /tmp/shux_std_fmt_multi_build.log 2>/dev/null; then
      echo "std-fmt-multi gate FAIL: libzstd missing (install zstd or rebuild compress.o without SHUX_USE_ZSTD)" >&2
    else
      echo "std-fmt-multi gate FAIL: link" >&2
    fi
    tail -8 /tmp/shux_std_fmt_multi_build.log 2>/dev/null >&2 || true
    std_fmt_multi_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-fmt-multi gate SKIP typeck (no native shux)" >&2
fi

std_fmt_multi_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-fmt-multi gate OK"
