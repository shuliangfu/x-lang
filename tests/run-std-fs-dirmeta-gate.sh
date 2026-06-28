#!/usr/bin/env bash
# STD-123：std.fs 目录/元数据 API 门禁
#
# 用法：./tests/run-std-fs-dirmeta-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-fs-dirmeta-v1.md"
MANIFEST="tests/baseline/std-fs-dirmeta-manifest.tsv"
MOD_SX="std/fs/mod.sx"
FS_IMPL="std/fs/posix.sx"
LIB="tests/lib/std-fs-dirmeta.sh"
SMOKE_SX="tests/fs/dirmeta_roundtrip.sx"
SMOKE_C="tests/fs/dirmeta_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-fs-dirmeta.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$FS_IMPL" "$SMOKE_SX"; do
  [ -f "$f" ] || { echo "std-fs-dirmeta gate FAIL: missing $f" >&2; exit 1; }
done
[ ! -f std/fs/fs.c ] || { echo "std-fs-dirmeta gate FAIL: fs.c should be deleted (F-03 v2)" >&2; exit 1; }

grep -qF dir_open "$DOC" || exit 1
grep -qF stat "$DOC" || exit 1

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
  grep -qE "function ${anchor}\\(" "$MOD_SX" || exit 1
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || exit 1

sym_miss="$(std_fs_dirmeta_symbols_ok "$MOD_SX" "$FS_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

C_OK=0
SX_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_SX" >/dev/null
  std_fs_dirmeta_run_sx_smoke ./compiler/shux-c "$SMOKE_SX" && SX_OK=1 || exit 1
  C_OK=1
else
  SKIP=1
fi

std_fs_dirmeta_emit_report ok "$C_OK" "$SX_OK" "$SKIP"
echo "std-fs-dirmeta gate OK"
