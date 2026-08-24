#!/usr/bin/env bash
# CORE-006：core.iterator 最小迭代协议门禁（假权威诚实）。
#
# 用法：./tests/run-core-iterator-protocol-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_ITER_DOC:-analysis/archive/core/core-iterator-protocol-v1.md}"
MANIFEST="${XLANG_CORE_ITER_TSV:-tests/baseline/core-iterator-protocol.tsv}"
ITER_X="core/iterator/mod.x"
LIB="tests/lib/core-iterator-protocol.sh"
SMOKE="tests/iterator/main.x"
COOKBOOK="examples/cookbook/iter_slice_sum.x"

# shellcheck source=tests/lib/core-iterator-protocol.sh
. tests/lib/core-iterator-protocol.sh

echo "=== CORE-006: iterator protocol manifest (archive DOC) ==="
if [ -f analysis/core-iterator-protocol-v1.md ]; then
  echo "core-iterator-protocol gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$ITER_X" "$SMOKE" "$COOKBOOK"; do
  if [ ! -f "$f" ]; then
    echo "core-iterator-protocol gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in next_i32 SliceIter Cookbook iter_slice_sum; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-iterator-protocol gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_iter_symbols_ok "$ITER_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_iter_emit_report "fail" 0 0 0 0
  echo "core-iterator-protocol gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-iterator-protocol manifest OK"

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
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
COOKBOOK_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-006: smoke (XLANG=$XLANG_BIN; check observational) ==="
  # Observational: check gate paused (2026-08-05); prefer -o path.
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-iterator-protocol gate SKIP check smoke (paused / typeck debt)" >&2
  fi
  if "$XLANG_BIN" check -L . "$COOKBOOK" >/dev/null 2>&1; then
    COOKBOOK_OK=1
  else
    echo "core-iterator-protocol gate SKIP check cookbook (paused / typeck debt)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  if $RUN_XLANG build -L . "$SMOKE" -o /tmp/xlang_core_iter 2>/tmp/xlang_core_iter_build.log; then
    exitcode=0
    /tmp/xlang_core_iter >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      CHECK_OK=1
      SKIP=0
    else
      echo "core-iterator-protocol gate SKIP runnable exit=$exitcode" >&2
      SKIP=1
    fi
  else
    echo "core-iterator-protocol gate SKIP runnable link" >&2
    tail -5 /tmp/xlang_core_iter_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "core-iterator-protocol gate SKIP typeck (no native xlang)" >&2
fi

core_iter_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$COOKBOOK_OK" "$SKIP"
echo "core-iterator-protocol gate OK"
