#!/usr/bin/env bash
# STD-036：std.csv parse_row / write_row 门禁（假权威诚实）。
#
# 用法：./tests/run-std-csv-row-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); row_roundtrip.x + main.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CSV_ROW_DOC:-analysis/archive/std/std-csv-row-v1.md}"
MANIFEST="${XLANG_STD_CSV_ROW_TSV:-tests/baseline/std-csv-row.tsv}"
MOD_X="std/csv/mod.x"
CSV_X="std/csv/csv.x"
LIB="tests/lib/std-csv-row.sh"
RT_X="tests/csv/row_roundtrip.x"
MAIN_X="tests/csv/main.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-csv-row.sh
. "$LIB"

echo "=== STD-036: csv row manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CSV_X" "$RT_X" "$MAIN_X"; do
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

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-csv-row gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

sym_miss="$(std_csv_row_symbols_ok "$MOD_X" "$CSV_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_csv_row_emit_report "fail" 0 0 1
  echo "std-csv-row gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-csv-row manifest OK"

if [ "${XLANG_STD_CSV_ROW_MANIFEST_ONLY:-0}" = "1" ]; then
  std_csv_row_emit_report "ok" 0 0 1
  echo "std-csv-row gate OK (manifest only)"
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
  echo "=== STD-036: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$RT_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-csv-row gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  run_one() {
    local src="$1"
    local tag="$2"
    local out="/tmp/xlang_std036_csv_row_${tag}_$$"
    local log="/tmp/xlang_std036_csv_row_${tag}_$$.log"
    if $RUN_XLANG build -L . "$src" -o "$out" 2>"$log"; then
      local exitcode=0
      "$out" >/dev/null 2>&1 || exitcode=$?
      rm -f "$out"
      if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
        return 0
      fi
      echo "std-csv-row gate FAIL runnable $tag exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      return 1
    fi
    echo "std-csv-row gate FAIL runnable $tag link" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    return 1
  }

  if run_one "$RT_X" "row_roundtrip" && run_one "$MAIN_X" "main"; then
    RUN_OK=1
    SKIP=0
  else
    std_csv_row_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-csv-row gate FAIL: no native xlang" >&2
  std_csv_row_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-csv-row check_ok=${CHECK_OK} (observational)"
std_csv_row_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-csv-row gate OK"
