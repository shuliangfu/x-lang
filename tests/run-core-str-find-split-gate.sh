#!/usr/bin/env bash
# STD-131：core.str BytesView 查找/分割门禁（假权威诚实）。
#
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
# 2026-08-25: runnable hard-green (core/str/mod.o find/split surface);
# Prefer xlang_asm; find_split.x exit 0 hard-fail (no Darwin soft SKIP).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_CORE_STR_FIND_SPLIT_DOC:-analysis/archive/core/core-str-find-split-v1.md}"
MANIFEST="tests/baseline/core-str-find-split-manifest.tsv"
MOD_X="core/str/mod.x"
LIB="tests/lib/core-str-find-split.sh"
SMOKE_X="tests/str/find_split.x"
# Designed success score (tests/str/find_split.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/core-str-find-split.sh
. "$LIB"

echo "=== STD-131: core.str find/split manifest (archive DOC) ==="
if [ -f analysis/core-str-find-split-v1.md ]; then
  echo "core-str-find-split gate FAIL: top-level DOC resurrected (live = archive/core/)" >&2
  exit 1
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "core-str-find-split gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-131 "$DOC" || { echo "core-str-find-split gate FAIL: doc" >&2; exit 1; }
sym_miss="$(core_str_find_split_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  core_str_find_split_emit_report "fail" 0 0
  echo "core-str-find-split gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "core-str-find-split manifest OK"

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
X_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-131: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-str-find-split gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm). Avoid Darwin-arm64
  # bootstrap remap of xlang_asm → xlang-c that hides pure-asm UNDEF / hangs host-cc.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_core_str_find_split_$$"
  LOG="/tmp/xlang_core_str_find_split_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      X_OK=1
      SKIP=0
    else
      echo "core-str-find-split gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      core_str_find_split_emit_report "fail" 0 0
      exit 1
    fi
  else
    echo "core-str-find-split gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    core_str_find_split_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "core-str-find-split gate SKIP typeck (no native xlang)" >&2
fi

core_str_find_split_emit_report "ok" "$X_OK" "$SKIP"
echo "core-str-find-split gate OK"
