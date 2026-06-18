#!/usr/bin/env bash
# STD-038：std.tar 目录遍历与 ustar round-trip 门禁
#
# 用法：./tests/run-std-tar-ustar-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_TAR_USTAR_DOC:-analysis/std-tar-ustar-v1.md}"
MANIFEST="${SHU_STD_TAR_USTAR_TSV:-tests/baseline/std-tar-ustar.tsv}"
TAR_SU="std/tar/mod.su"
TAR_C="std/tar/tar.c"
LIB="tests/lib/std-tar-ustar.sh"
RT_SU="tests/tar/ustar_roundtrip.su"
MAIN_SU="tests/tar/main.su"
MIN_APIS=5

# shellcheck source=tests/lib/std-tar-ustar.sh
. "$LIB"

echo "=== STD-038: tar ustar manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$TAR_SU" "$TAR_C" "$RT_SU" "$MAIN_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-tar-ustar gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-038 ustar next_entry read_entry_data append_entry round-trip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-tar-ustar gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$TAR_SU" 2>/dev/null; then
        echo "std-tar-ustar gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-tar-ustar gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-tar-ustar gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_tar_ustar_symbols_ok "$TAR_SU" "$TAR_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_tar_ustar_emit_report "fail" 0 0 1
  echo "std-tar-ustar gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-tar-ustar manifest OK"

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

RT_OK=0
MAIN_OK=0
SKIP=1
if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-038: typeck + smoke (SHU=$SHU_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$RT_SU" >/dev/null 2>&1; then
    echo "std-tar-ustar gate FAIL: typeck $RT_SU" >&2
    "$SHU_BIN" check -L . "$RT_SU" 2>&1 | tail -10 >&2 || true
    std_tar_ustar_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_tar_ustar_run_smoke "$SHU_BIN" "$RT_SU" "ustar_roundtrip"; then
    RT_OK=1
  else
    std_tar_ustar_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_tar_ustar_run_smoke "$SHU_BIN" "$MAIN_SU" "main"; then
    MAIN_OK=1
  else
    std_tar_ustar_emit_report "fail" "$RT_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-tar-ustar gate SKIP smoke (no native shu-c)" >&2
fi

std_tar_ustar_emit_report "ok" "$RT_OK" "$MAIN_OK" "$SKIP"
echo "std-tar-ustar gate OK"
