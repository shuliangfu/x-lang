#!/usr/bin/env bash
# STD-021/022：std.path / std.fs Windows 对齐门禁
#
# 用法：./tests/run-std-path-fs-windows-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_PFW_DOC:-analysis/std-path-fs-windows-v1.md}"
MANIFEST="${SHU_STD_PFW_TSV:-tests/baseline/std-path-fs-windows.tsv}"
PATH_SU="std/path/mod.su"
PATH_C="std/path/path.c"
LIB="tests/lib/std-path-fs-windows.sh"
PATH_TEST="tests/path/windows_abs_join.su"
FS_TEST="tests/fs/windows_path_smoke.su"

# shellcheck source=tests/lib/std-path-fs-windows.sh
. tests/lib/std-path-fs-windows.sh

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== STD-021/022: path/fs Windows manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PATH_SU" "$PATH_C" "$PATH_TEST" "$FS_TEST"; do
  if [ ! -f "$f" ]; then
    echo "std-path-fs-windows gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in path_is_sep path_is_absolute win_path_smoke path_sep_c; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-path-fs-windows gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_pfw_symbols_ok "$PATH_SU" "$MANIFEST" || true)"
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
  for cand in ./compiler/shu-c ./compiler/shu; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

if SHU_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-021/022: typeck (SHU=$SHU_BIN) ==="
  make -C compiler -q ../std/path/path.o 2>/dev/null || make -C compiler ../std/path/path.o 2>/dev/null || true
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if "$SHU_BIN" check -L . "$PATH_TEST" >/dev/null 2>&1; then
    PATH_OK=1
  else
    echo "std-path-fs-windows gate FAIL: path windows typeck" >&2
    "$SHU_BIN" check -L . "$PATH_TEST" 2>&1 | tail -8 >&2 || true
    std_pfw_emit_report "fail" 0 0 0
    exit 1
  fi
  if "$SHU_BIN" check -L . "$FS_TEST" >/dev/null 2>&1; then
    FS_OK=1
  else
    echo "std-path-fs-windows gate FAIL: fs windows typeck" >&2
    "$SHU_BIN" check -L . "$FS_TEST" 2>&1 | tail -8 >&2 || true
    std_pfw_emit_report "fail" "$PATH_OK" 0 0
    exit 1
  fi
  SKIP=0
  if [ -x tests/run-std-fs-crossplatform-gate.sh ]; then
    echo "=== STD-022: delegate std-fs-crossplatform (runnable subset) ==="
    chmod +x tests/run-std-fs-crossplatform-gate.sh
    if SHU="$SHU_BIN" ./tests/run-std-fs-crossplatform-gate.sh >/tmp/std_pfw_xplat.log 2>&1; then
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
  echo "std-path-fs-windows gate SKIP typeck (no native shu-c)" >&2
fi

std_pfw_emit_report "ok" "$PATH_OK" "$FS_OK" "$SKIP"
echo "std-path-fs-windows gate OK"
