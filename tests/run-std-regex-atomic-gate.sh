#!/usr/bin/env bash
# STD-124：std.regex 原子分组 `(?>...)` 门禁
#
# 用法：./tests/run-std-regex-atomic-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-regex-atomic-v1.md"
MANIFEST="tests/baseline/std-regex-atomic-manifest.tsv"
MIN_INC="std/regex/regex_min.inc.c"
REGEX_C="std/regex/regex.c"
LIB="tests/lib/std-regex-atomic.sh"
SMOKE_SU="tests/regex/atomic_match.sx"

# shellcheck source=tests/lib/std-regex-atomic.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$LIB" "$MIN_INC" "$REGEX_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-regex-atomic gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF STD-124 "$DOC" || exit 1
grep -qF atomic_nest "$MIN_INC" || exit 1

sym_miss="$(std_regex_atomic_symbols_ok "$MIN_INC" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/regex/regex.o
REGEX_O="$(cd compiler && pwd)/../std/regex/regex.o"

C_OK=0
std_regex_atomic_run_c_smoke "$REGEX_O" && C_OK=1 || exit 1

SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_regex_atomic_run_sx_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_regex_atomic_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-regex-atomic gate OK"
