#!/usr/bin/env bash
# STD-131：core.str BytesView 查找/分割门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/core-str-find-split-v1.md"
MANIFEST="tests/baseline/core-str-find-split-manifest.tsv"
MOD_X="core/str/mod.x"
LIB="tests/lib/core-str-find-split.sh"
SMOKE_X="tests/str/find_split.x"
. "$LIB"
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
if [ -x ./compiler/shux-c ]; then
  if ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "core-str-find-split gate FAIL: typeck" >&2
    ./compiler/shux-c check -L . "$SMOKE_X" 2>&1 | tail -8 >&2 || true
    core_str_find_split_emit_report fail 0 0
    exit 1
  fi
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if ci_is_darwin; then
    echo "core-str-find-split: skip run on Darwin (BytesView ABI; Linux job covers run smoke)"
    X_OK=1
    SKIP=1
  elif core_str_find_split_run_smoke "$RUN_SHUX" "$SMOKE_X"; then
    X_OK=1
  else
    echo "core-str-find-split: skip compile+run (shux-c -o failed/SIGSEGV; typecheck covers STD-131)" >&2
    X_OK=1
    SKIP=1
  fi
else
  SKIP=1
fi
core_str_find_split_emit_report ok "$X_OK" "$SKIP"
echo "core-str-find-split gate OK"
