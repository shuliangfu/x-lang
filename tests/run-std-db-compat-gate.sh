#!/usr/bin/env bash
# STD-120：import std.db 兼容层门禁
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-db-compat-v1.md"
MANIFEST="tests/baseline/std-db-compat-manifest.tsv"
VECTORS="tests/baseline/std-db-compat-vectors.tsv"
MOD_SU="std/db/mod.sx"
SQLITE_SU="std/sqlite/mod.sx"
LIB="tests/lib/std-db-compat.sh"
SMOKE_SU="tests/std-db/compat_smoke.sx"
MIN_APIS=5

# shellcheck source=tests/lib/std-db-compat.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SQLITE_SU" "$SMOKE_SU" std/db/README.md; do
  [ -f "$f" ] || { echo "std-db-compat gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF std.sqlite "$DOC" || exit 1
grep -qF db_is_deprecated "$VECTORS" || exit 1
grep -qF db_open_c "$MOD_SU" || exit 1

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_SU" || exit 1
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || exit 1

sym_miss="$(std_db_compat_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/sqlite/sqlite.o

SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_db_compat_run_sx_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_db_compat_emit_report ok "$SU_OK" "$SKIP"
echo "std-db-compat gate OK"
