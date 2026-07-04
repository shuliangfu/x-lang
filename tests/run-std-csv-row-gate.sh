#!/usr/bin/env bash
# STD-036：std.csv parse_row / write_row 门禁（F-csv v1：csv.x）
#
# 用法：./tests/run-std-csv-row-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CSV_ROW_DOC:-analysis/std-csv-row-v1.md}"
MANIFEST="${SHUX_STD_CSV_ROW_TSV:-tests/baseline/std-csv-row.tsv}"
CSV_X="std/csv/mod.x"
CSV_X="std/csv/csv.x"
LIB="tests/lib/std-csv-row.sh"
RT_X="tests/csv/row_roundtrip.x"
MAIN_X="tests/csv/main.x"

# shellcheck source=tests/lib/std-csv-row.sh
. "$LIB"

echo "=== STD-036: csv row manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$CSV_X" "$CSV_X" "$RT_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-csv-row gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in parse_row write_row RFC 4180 row_roundtrip; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-csv-row gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_csv_row_symbols_ok "$CSV_X" "$CSV_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_csv_row_emit_report "fail" 0 0 1
  echo "std-csv-row gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-csv-row manifest OK"

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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-036: typeck + smoke (SHUX=$SHUX_BIN) ==="
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/csv/csv.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$RT_X" >/dev/null 2>&1; then
    echo "std-csv-row gate FAIL: typeck $RT_X" >&2
    "$SHUX_BIN" check -L . "$RT_X" 2>&1 | tail -10 >&2 || true
    std_csv_row_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_csv_row_run_smoke "$SHUX_BIN" "$RT_X" "row_roundtrip"; then
    RT_OK=1
  else
    std_csv_row_emit_report "fail" 0 0 0
    exit 1
  fi
  if std_csv_row_run_smoke "$SHUX_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_csv_row_emit_report "fail" "$RT_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-csv-row gate SKIP smoke (no native shux-c)" >&2
fi

std_csv_row_emit_report "ok" "$RT_OK" "$MAIN_OK" "$SKIP"
echo "std-csv-row gate OK"
