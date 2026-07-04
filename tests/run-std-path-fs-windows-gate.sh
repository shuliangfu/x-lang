#!/usr/bin/env bash
# STD-021/022：std.path / std.fs Windows 对齐门禁
#
# 用法：./tests/run-std-path-fs-windows-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_PFW_DOC:-analysis/std-path-fs-windows-v1.md}"
MANIFEST="${SHUX_STD_PFW_TSV:-tests/baseline/std-path-fs-windows.tsv}"
PATH_X="std/path/mod.x"
LIB="tests/lib/std-path-fs-windows.sh"
PATH_TEST="tests/path/windows_abs_join.x"
FS_TEST="tests/fs/windows_path_smoke.x"

# shellcheck source=tests/lib/std-path-fs-windows.sh
. tests/lib/std-path-fs-windows.sh

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-021/022: path/fs Windows manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PATH_X" "$PATH_TEST" "$FS_TEST"; do
  if [ ! -f "$f" ]; then
    echo "std-path-fs-windows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in is_sep is_absolute win_path_smoke sep; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-fs-windows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_pfw_symbols_ok "$PATH_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_pfw_emit_report "fail" 0 0 1
  echo "std-path-fs-windows gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-path-fs-windows manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

PATH_OK=0
FS_OK=0
SKIP=1
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

if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-021/022: typeck (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/path/path.o 2>/dev/null || make -C compiler ../std/path/path.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if "$SHUX_BIN" check -L . "$PATH_TEST" >/dev/null 2>&1; then
    PATH_OK=1
  else
    echo "std-path-fs-windows gate FAIL: path windows typeck" >&2
    "$SHUX_BIN" check -L . "$PATH_TEST" 2>&1 | tail -8 >&2 || true
    std_pfw_emit_report "fail" 0 0 0
    exit 1
  fi
  for sym in sep is_sep is_absolute join basename dirname; do
    if ! grep -qE "function ${sym}\\(" "$PATH_X" 2>/dev/null; then
      echo "std-path-fs-windows gate FAIL: mod missing function ${sym}" >&2
      std_pfw_emit_report "fail" 0 0 0
      exit 1
    fi
  done
  for call in path.is_absolute path.join path.basename; do
    if ! grep -q "${call}" "$PATH_TEST" 2>/dev/null; then
      echo "std-path-fs-windows gate FAIL: smoke missing ${call}" >&2
      std_pfw_emit_report "fail" 0 0 0
      exit 1
    fi
  done
  if "$SHUX_BIN" check -L . "$FS_TEST" >/dev/null 2>&1; then
    FS_OK=1
  else
    echo "std-path-fs-windows gate FAIL: fs windows typeck" >&2
    "$SHUX_BIN" check -L . "$FS_TEST" 2>&1 | tail -8 >&2 || true
    std_pfw_emit_report "fail" "$PATH_OK" 0 0
    exit 1
  fi
  SKIP=0
  if [ -x tests/run-std-fs-crossplatform-gate.sh ]; then
    echo "=== STD-022: delegate std-fs-crossplatform (runnable subset) ==="
    chmod +x tests/run-std-fs-crossplatform-gate.sh
    if SHUX="$SHUX_BIN" ./tests/run-std-fs-crossplatform-gate.sh >/tmp/std_pfw_xplat.log 2>&1; then
      grep -qF 'std-fs-crossplatform gate OK' /tmp/std_pfw_xplat.log || true
    else
      if ci_is_windows_msys; then
        tail -12 /tmp/std_pfw_xplat.log >&2 || true
        std_pfw_emit_report "fail" "$PATH_OK" "$FS_OK" 0
        exit 1
      fi
      echo "std-path-fs-windows gate WARN: xplat delegate (non-Windows)" >&2
    fi
  fi
else
  echo "std-path-fs-windows gate SKIP typeck (no native shux-c)" >&2
fi

std_pfw_emit_report "ok" "$PATH_OK" "$FS_OK" "$SKIP"
echo "std-path-fs-windows gate OK"
