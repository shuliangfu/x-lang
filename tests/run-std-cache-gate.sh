#!/usr/bin/env bash
# STD-087：std.cache 门禁
#
# 用法：./tests/run-std-cache-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_CACHE_DOC:-analysis/std-cache-v1.md}"
MANIFEST="${SHU_STD_CACHE_MANIFEST:-tests/baseline/std-cache-manifest.tsv}"
MOD_SU="std/cache/mod.su"
CACHE_C="std/cache/cache.c"
LIB="tests/lib/std-cache.sh"
SMOKE_SU="tests/std-cache/lru_pool_smoke.su"
SMOKE_C="tests/std-cache/cache_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-cache.sh
. "$LIB"

echo "=== STD-087: std.cache manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$CACHE_C" "$SMOKE_SU" "$SMOKE_C" std/cache/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-cache gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-087 lru_put pool_acquire pool_mark_unhealthy lru_stats; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-cache gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-cache gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-cache gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_cache_symbols_ok "$MOD_SU" "$CACHE_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_cache_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-cache manifest OK"

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-087: cache c smoke ==="
make -C compiler ../std/cache/cache.o ../std/time/time.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shu_cache_smoke \
  "$SMOKE_C" std/cache/cache.o std/time/time.o 2>/dev/null; then
  if /tmp/shu_cache_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shu_cache_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_cache_emit_report "fail" 0 0 0
  echo "std-cache gate FAIL: c smoke" >&2
  exit 1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-087: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-cache gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_cache_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_cache_run_smoke "$SHU_BIN" "$SMOKE_SU" "lru"; then SU_OK=1; else
    std_cache_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-cache gate SKIP .su smoke (no shu)" >&2
  SKIP=1
fi

std_cache_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-cache gate OK"
