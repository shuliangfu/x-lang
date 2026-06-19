#!/usr/bin/env bash
# STD-117：std.metrics 观测上下文关联门禁
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-metrics-obs-v1.md"
MANIFEST="tests/baseline/std-metrics-obs-manifest.tsv"
VECTORS="tests/baseline/std-metrics-obs-vectors.tsv"
MOD_SU="std/metrics/mod.sx"
LIB="tests/lib/std-metrics-obs.sh"
SMOKE_SU="tests/std-metrics/obs_correlation.sx"
MIN_APIS=6

# shellcheck source=tests/lib/std-metrics-obs.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  [ -f "$f" ] || { echo "std-metrics-obs gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF obs_ctx_format_log_kv "$DOC" || exit 1
grep -qF trace_id= "$VECTORS" || exit 1

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

sym_miss="$(std_metrics_obs_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

SU_OK=0
SKIP=0
if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_SU" >/dev/null
  std_metrics_obs_run_sx_smoke ./compiler/shux-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_metrics_obs_emit_report ok "$SU_OK" "$SKIP"
echo "std-metrics-obs gate OK"
