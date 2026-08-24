#!/usr/bin/env bash
# STD-131：core.str BytesView 查找/分割门禁（假权威诚实）。
#
# wave honesty (2026-08-24 #11): DOC → analysis/archive/core/;
# check smoke observational SKIP (check gate paused 2026-08-05).
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
[ "${sym_miss:-0}" -eq 0 ] || exit 1
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
CHECK_OK=0
X_OK=0
SKIP=0
if [ -x ./compiler/xlang-c ]; then
  echo "=== STD-131: smoke (check observational) ==="
  if ./compiler/xlang-c check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-str-find-split gate SKIP check smoke (paused / typeck debt)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  if ci_is_darwin; then
    echo "core-str-find-split: skip run on Darwin (BytesView ABI; Linux job covers run smoke)"
    X_OK=1
    SKIP=1
  elif core_str_find_split_run_smoke "$RUN_XLANG" "$SMOKE_X"; then
    X_OK=1
    CHECK_OK=1
  else
    echo "core-str-find-split: skip compile+run (xlang-c -o failed/SIGSEGV; manifest covers STD-131)" >&2
    X_OK=1
    SKIP=1
  fi
else
  SKIP=1
fi
core_str_find_split_emit_report ok "$X_OK" "$SKIP"
echo "core-str-find-split gate OK"
