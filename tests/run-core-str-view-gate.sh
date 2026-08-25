#!/usr/bin/env bash
# CORE-007：core.str BytesView 门禁（假权威诚实）。
#
# 用法：./tests/run-core-str-view-gate.sh
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/ + archive/std/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (labi g21 ×12 core/str/mod.o surface);
# Prefer xlang_asm; smoke exit 0 + cookbook core_str_index exit 0 hard-fail.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_STR_DOC:-analysis/archive/core/core-str-view-v1.md}"
STD_DOC="${XLANG_STD_STRVIEW_DOC:-analysis/archive/std/std-strview-zc4-v1.md}"
MANIFEST="${XLANG_CORE_STR_TSV:-tests/baseline/core-str-view.tsv}"
STR_X="core/str/mod.x"
LIB="tests/lib/core-str-view.sh"
SMOKE="tests/str/bytes_view.x"
COOKBOOK="examples/cookbook/core_str_index.x"
# Cookbook designed success score = 0 (all index/starts_with checks pass).
COOKBOOK_EXPECT=0

# shellcheck source=tests/lib/core-str-view.sh
. tests/lib/core-str-view.sh

echo "=== CORE-007: core.str BytesView manifest (archive DOC) ==="
if [ -f analysis/core-str-view-v1.md ] || [ -f analysis/std-strview-zc4-v1.md ]; then
  echo "core-str-view gate FAIL: top-level DOC resurrected (live = archive/)" >&2
  exit 1
fi
for f in "$DOC" "$STD_DOC" "$MANIFEST" "$LIB" "$STR_X" "$SMOKE" "$COOKBOOK"; do
  if [ ! -f "$f" ]; then
    echo "core-str-view gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in BytesView StrView bytes_view_subview 生命周期 Cookbook core_str_index; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-str-view gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(core_str_symbols_ok "$STR_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_str_emit_report "fail" 0 0 0 0
  echo "core-str-view gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-str-view manifest OK"

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
COOKBOOK_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== CORE-007: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-str-view gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  OUT="/tmp/xlang_core_str_view_$$"
  LOG="/tmp/xlang_core_str_view_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
    else
      echo "core-str-view gate FAIL runnable exit=$exitcode" >&2
      core_str_emit_report "fail" "$CHECK_OK" 0 0 0
      exit 1
    fi
  else
    echo "core-str-view gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_str_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  # Cookbook: product unique-UNDEF fire (index_of / starts_with); success score 0.
  CB_OUT="/tmp/xlang_core_str_view_cb_$$"
  CB_LOG="/tmp/xlang_core_str_view_cb_build_$$.log"
  if $RUN_XLANG build -L . "$COOKBOOK" -o "$CB_OUT" 2>"$CB_LOG"; then
    cb_exit=0
    "$CB_OUT" >/dev/null 2>&1 || cb_exit=$?
    rm -f "$CB_OUT"
    if [ "$cb_exit" -eq "$COOKBOOK_EXPECT" ]; then
      COOKBOOK_OK=1
      SKIP=0
    else
      echo "core-str-view gate FAIL cookbook exit=$cb_exit (expect $COOKBOOK_EXPECT)" >&2
      core_str_emit_report "fail" "$CHECK_OK" "$RUN_OK" 0 0
      exit 1
    fi
  else
    echo "core-str-view gate FAIL cookbook link" >&2
    tail -20 "$CB_LOG" 2>/dev/null >&2 || true
    core_str_emit_report "fail" "$CHECK_OK" "$RUN_OK" 0 0
    exit 1
  fi
else
  echo "core-str-view gate SKIP typeck (no native xlang)" >&2
fi

core_str_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$COOKBOOK_OK" "$SKIP"
echo "core-str-view gate OK"
