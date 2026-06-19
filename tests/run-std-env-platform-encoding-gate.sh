#!/usr/bin/env bash
# STD-132：std.env 平台编码 / 环境块边界门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-env-platform-encoding-v1.md"
MANIFEST="tests/baseline/std-env-platform-encoding-manifest.tsv"
MOD_SU="std/env/mod.sx"
ENV_C="std/env/env.c"
LIB="tests/lib/std-env-platform-encoding.sh"
SMOKE_SU="tests/env/platform_encoding.sx"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$ENV_C" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-env-platform-encoding gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-132 "$DOC" || { echo "std-env-platform-encoding gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_env_platform_encoding_symbols_ok "$MOD_SU" "$ENV_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/env/env.o
ENV_O="$(cd compiler && pwd)/../std/env/env.o"
C_OK=0
std_env_platform_encoding_run_c_smoke "$ENV_O" && C_OK=1 || exit 1
SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_env_platform_encoding_run_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi
std_env_platform_encoding_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-env-platform-encoding gate OK"
