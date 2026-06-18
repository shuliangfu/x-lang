#!/usr/bin/env bash
# PERF-010：冷启动 / 首编译 manifest 门禁
#
# 用法：./tests/run-perf-coldstart-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_PERF_COLDSTART_DOC:-analysis/perf-coldstart-v1.md}"
MANIFEST="${SHU_PERF_COLDSTART_MANIFEST:-tests/baseline/perf-coldstart.tsv}"
CAP="${SHU_PERF_COLDSTART_CAP:-tests/baseline/coldstart-perf.tsv}"
MIN_LAYERS=6
MIN_METRICS=5

# shellcheck source=tests/lib/perf-coldstart.sh
. tests/lib/perf-coldstart.sh

echo "=== PERF-010: coldstart manifest ==="
for f in "$DOC" "$MANIFEST" "$CAP" \
  tests/lib/perf-coldstart.sh tests/run-perf-coldstart.sh \
  examples/hello.su tests/freestanding/return42/main.su \
  tests/freestanding/hello/main.su tests/baseline/compile-dogfood.tsv \
  tests/baseline/perf-baseline-registry.tsv tests/run-ci-full-suite.sh; do
  if [ ! -f "$f" ]; then
    echo "perf-coldstart gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_metrics) MIN_METRICS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
METRIC_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ -n "$src" ] && [ ! -f "$src" ]; then
        echo "perf-coldstart FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    metric)
      METRIC_N=$((METRIC_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing metric $anchor" >&2
        MISS=$((MISS + 1))
      fi
      cap="$(perf_coldstart_cap "$anchor" 2>/dev/null || true)"
      if [ -z "$cap" ]; then
        echo "perf-coldstart FAIL: cap missing $anchor in $CAP" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "perf-coldstart FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "perf-coldstart FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

CAP_N="$(perf_coldstart_metric_count)"
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "perf-coldstart gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$METRIC_N" -lt "$MIN_METRICS" ] || [ "$CAP_N" -lt "$MIN_METRICS" ]; then
  echo "perf-coldstart gate FAIL: metrics manifest=${METRIC_N} cap=${CAP_N} min=${MIN_METRICS}" >&2
  exit 1
fi

for kw in coldstart compile startup runnable report median; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-coldstart gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! grep -qF 'coldstart-perf' tests/baseline/perf-baseline-registry.tsv 2>/dev/null; then
  echo "perf-coldstart gate FAIL: registry missing coldstart-perf" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "perf-coldstart gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "perf-coldstart manifest OK (layers=${LAYER_N} metrics=${METRIC_N})"

# 烟测：少量 runs、不硬失败回归（portable）；无 native shu 时 SKIP。
chmod +x tests/run-perf-coldstart.sh
SHU_GATE=""
for cand in ./compiler/shu ./compiler/shu-c; do
  if perf_coldstart_native_shu "$cand"; then
    SHU_GATE="$cand"
    break
  fi
done
if [ -n "$SHU_GATE" ]; then
  SHU="$SHU_GATE" SHU_COLDSTART_RUNS="${SHU_COLDSTART_GATE_RUNS:-3}" \
    SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=0 \
    ./tests/run-perf-coldstart.sh
else
  echo "perf-coldstart SKIP smoke (no native shu on $(uname -s)/$(uname -m 2>/dev/null))"
fi

echo "perf-coldstart gate OK"
