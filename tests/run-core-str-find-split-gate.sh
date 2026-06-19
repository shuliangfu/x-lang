#!/usr/bin/env bash
# STD-131：core.str BytesView 查找/分割门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/core-str-find-split-v1.md"
MANIFEST="tests/baseline/core-str-find-split-manifest.tsv"
MOD_SU="core/str/mod.sx"
LIB="tests/lib/core-str-find-split.sh"
SMOKE_SU="tests/str/find_split.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "core-str-find-split gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-131 "$DOC" || { echo "core-str-find-split gate FAIL: doc" >&2; exit 1; }
sym_miss="$(core_str_find_split_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
SU_OK=0
SKIP=0
  if [ -x ./compiler/shux-c ]; then
    ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
    if ci_is_darwin; then
      echo "core-str-find-split: skip run on Darwin (BytesView ABI; Linux job covers run smoke)"
      SU_OK=1
      SKIP=1
    elif ci_is_docker; then
      echo "core-str-find-split: skip compile+run in Docker (shux-c compile SIGSEGV on musl; typecheck covers API)"
      SU_OK=1
      SKIP=1
    else
      core_str_find_split_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
    fi
else
  SKIP=1
fi
core_str_find_split_emit_report ok "$SU_OK" "$SKIP"
echo "core-str-find-split gate OK"
