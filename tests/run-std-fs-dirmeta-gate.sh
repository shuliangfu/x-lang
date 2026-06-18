#!/usr/bin/env bash
# STD-123：std.fs 目录/元数据 API 门禁
#
# 用法：./tests/run-std-fs-dirmeta-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-fs-dirmeta-v1.md"
MANIFEST="tests/baseline/std-fs-dirmeta-manifest.tsv"
MOD_SU="std/fs/mod.su"
FS_C="std/fs/fs.c"
LIB="tests/lib/std-fs-dirmeta.sh"
SMOKE_SU="tests/fs/dirmeta_roundtrip.su"
SMOKE_C="tests/fs/dirmeta_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-fs-dirmeta.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$FS_C" "$SMOKE_SU" "$SMOKE_C"; do
  [ -f "$f" ] || { echo "std-fs-dirmeta gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF fs_dir_open "$DOC" || exit 1
grep -qF fs_stat "$DOC" || exit 1

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

sym_miss="$(std_fs_dirmeta_symbols_ok "$MOD_SU" "$FS_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/fs/fs.o
FS_O="$(cd compiler && pwd)/../std/fs/fs.o"

C_OK=0
std_fs_dirmeta_run_c_smoke "$FS_O" && C_OK=1 || exit 1

SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_fs_dirmeta_run_su_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_fs_dirmeta_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-fs-dirmeta gate OK"
