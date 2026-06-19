#!/usr/bin/env bash
# STD-152：std.tar 长路径/Pax/目录门禁
#
# 用法：./tests/run-std-tar-extended-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-tar-extended-v1.md"
MANIFEST="tests/baseline/std-tar-extended.tsv"
MOD_SU="std/tar/mod.sx"
TAR_C="std/tar/tar.c"
LIB="tests/lib/std-tar-extended.sh"
SMOKE_SU="tests/tar/long_path_dir.sx"
SMOKE_C="tests/std-tar/extended_ok.c"
MIN_APIS=1

# shellcheck source=tests/lib/std-tar-extended.sh
. "$LIB"

echo "=== STD-152: tar extended manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$TAR_C" "$SMOKE_SU" "$SMOKE_C" std/tar/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-tar-extended gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-152 prefix Pax path_max TAR_TYPE_PAX; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-tar-extended gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "path_max" std/tar/README.md 2>/dev/null; then
  echo "std-tar-extended gate FAIL: README missing path_max" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-tar-extended gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_tar_extended_symbols_ok "$MOD_SU" "$TAR_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_tar_extended_emit_report "fail" 0 0 0
  echo "std-tar-extended gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-tar-extended manifest OK"

C_OK=0
if std_tar_extended_run_c_smoke "$TAR_C"; then
  C_OK=1
else
  std_tar_extended_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
SHUX_BIN=""
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
if stdlib_cm_native_shu ./compiler/shux-c; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  TAR_O="$(cd compiler && pwd)/../std/tar/tar.o"
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-tar-extended gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_tar_extended_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_tar_extended_run_sx_smoke "$SHUX_BIN" "$SMOKE_SU" "$TAR_O"; then
    SU_OK=1
  else
    std_tar_extended_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
  echo "std-tar-extended gate SKIP su smoke (no native shux-c)" >&2
fi

std_tar_extended_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-tar-extended gate OK"
