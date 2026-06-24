#!/usr/bin/env bash
# STD-125：std.compress Brotli 可选后端门禁
#
# 用法：./tests/run-std-compress-brotli-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-compress-brotli-v1.md"
MANIFEST="tests/baseline/std-compress-brotli-manifest.tsv"
MOD_SX="std/compress/mod.sx"
COMPRESS_C="std/compress/brotli/brotli_lib.sx"
LIB="tests/lib/std-compress-brotli.sh"
SMOKE_SX="tests/std-compress/brotli_roundtrip.sx"
SMOKE_C="tests/std-compress/brotli_smoke_ok.c"
MIN_APIS=4

# shellcheck source=tests/lib/std-compress-brotli.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$COMPRESS_C" "$SMOKE_SX"; do
  [ -f "$f" ] || { echo "std-compress-brotli gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF compress-o-brotli "$DOC" || exit 1
grep -qF brotli_available "$DOC" || exit 1

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

sym_miss="$(std_compress_brotli_symbols_ok "$MOD_SX" "$COMPRESS_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

BROTLI_OK=0
SKIP=1
C_EC=2

if std_compress_brotli_try_build; then
  # F-04 v6+：C smoke 依赖 compress.o 已废弃；无符号时返回 2（SKIP）
  COMPRESS_O=""
  if [ -f std/compress/compress.o ]; then
    COMPRESS_O="std/compress/compress.o"
  fi
  set +e
  std_compress_brotli_run_c_smoke "$COMPRESS_O"
  C_EC=$?
  set -e
  if [ "$C_EC" -eq 0 ]; then
    BROTLI_OK=1
    SKIP=0
    if [ -x ./compiler/shux-c ]; then
      make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
      ./compiler/shux-c check -L . "$SMOKE_SX" >/dev/null
      std_compress_brotli_run_sx_smoke ./compiler/shux-c "$SMOKE_SX" || exit 1
    fi
  elif [ "$C_EC" -eq 2 ]; then
    echo "std-compress-brotli gate SKIP runtime (no brotli link libs)" >&2
  else
    echo "std-compress-brotli gate FAIL: C smoke" >&2
    exit 1
  fi
else
  echo "std-compress-brotli gate SKIP build (no brotli dev headers)" >&2
fi

std_compress_brotli_emit_report ok "$BROTLI_OK" "$SKIP"
echo "std-compress-brotli gate OK"
