#!/usr/bin/env bash
# STD-132：std.env 平台编码 / 环境块边界门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-env-platform-encoding-v1.md"
MANIFEST="tests/baseline/std-env-platform-encoding-manifest.tsv"
MOD_X="std/env/mod.x"
ENV_IMPL="std/env/env.x"
ENV_GLUE="compiler/src/asm/runtime_env_os.inc"
LIB="tests/lib/std-env-platform-encoding.sh"
SMOKE_X="tests/env/platform_encoding.x"
. "$LIB"
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-env-platform-encoding gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-132 "$DOC" || { echo "std-env-platform-encoding gate FAIL: doc" >&2; exit 1; }
sym_miss="$(std_env_platform_encoding_symbols_ok "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1
C_OK=0
SKIP=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/env/env.o >/dev/null 2>&1 || true
  ENV_O="$(cd compiler && pwd)/../std/env/env.o"
  if [ -f "$ENV_O" ] && std_env_platform_encoding_run_c_smoke "$ENV_O"; then
    C_OK=1
  else
    echo "std-env-platform-encoding gate SKIP c smoke (no full env.o)" >&2
    SKIP=1
  fi
else
  echo "std-env-platform-encoding gate SKIP c smoke (no shux-c)" >&2
  SKIP=1
fi
X_OK=0
if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_env_platform_encoding_run_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
  SKIP=0
else
  [ "$SKIP" = "1" ] || SKIP=1
fi
std_env_platform_encoding_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-env-platform-encoding gate OK"
