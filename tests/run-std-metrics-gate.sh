#!/usr/bin/env bash
# STD-078：std.metrics 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_METRICS_DOC:-analysis/std-metrics-v1.md}"
MANIFEST="${SHU_STD_METRICS_MANIFEST:-tests/baseline/std-metrics-manifest.tsv}"
VECTORS="${SHU_STD_METRICS_VECTORS:-tests/baseline/std-metrics-vectors.tsv}"
MOD_SU="std/metrics/mod.su"
LIB="tests/lib/std-metrics.sh"
SMOKE_SU="tests/std-metrics/roundtrip.su"
MIN_APIS=10

# shellcheck source=tests/lib/std-metrics.sh
. "$LIB"

echo "=== STD-078: std.metrics manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU" std/metrics/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-metrics gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-078 Counter Gauge Histogram export_prometheus label; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-metrics gate FAIL: doc missing '$kw'" >&2
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
    echo "std-metrics gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-metrics gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_metrics_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_metrics_emit_report "fail" 0 0
  exit 1
fi
echo "std-metrics manifest OK"

SU_OK=0
SKIP=0
SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-078: .su smoke (SHU=$SHU_BIN) ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-metrics gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_metrics_emit_report "fail" 0 0
    exit 1
  fi
  if std_metrics_run_smoke "$SHU_BIN" "$SMOKE_SU" "roundtrip"; then SU_OK=1; else
    std_metrics_emit_report "fail" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_metrics_emit_report "ok" "$SU_OK" "$SKIP"
echo "std-metrics gate OK"
