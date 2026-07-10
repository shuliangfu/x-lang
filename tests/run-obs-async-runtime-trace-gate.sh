#!/usr/bin/env bash
# OBS-002：async/runtime trace 采样 manifest + 烟测门禁
#
# 1) obs-async-runtime-trace-v1.md + manifest
# 2) scheduler.c 符号与 env 锚点
# 3) async_runtime_trace_smoke.c：SHUX_ASYNC_RUNTIME_TRACE=1 须输出 summary + rank
#
# 用法：./tests/run-obs-async-runtime-trace-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_OBS_ASYNC_TRACE_DOC:-analysis/obs-async-runtime-trace-v1.md}"
MANIFEST="${SHUX_OBS_ASYNC_TRACE_TSV:-tests/baseline/obs-async-runtime-trace.tsv}"
SCHED="${SHUX_OBS_ASYNC_TRACE_SCHED:-compiler/seeds/runtime_scheduler_glue.from_x.c}"
SMOKE_SRC="${SHUX_OBS_ASYNC_TRACE_SMOKE:-tests/bench/async_runtime_trace_smoke.c}"
SCHED_O="std/async/scheduler.o"
MIN_ITEMS=8
MIN_TOPN=5
PREFIX="shux: [SHUX_ASYNC_RUNTIME_TRACE]"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

echo "=== OBS-002: async runtime trace manifest ==="
for f in "$DOC" "$MANIFEST" "$SCHED" "$SMOKE_SRC"; do
  if [ ! -f "$f" ]; then
    echo "obs-async-runtime-trace gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_items) MIN_ITEMS="$c2" ;;
    min_topn) MIN_TOPN="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
FOUND=0
echo "=== OBS-002: manifest anchor check ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    env_var|env_topn|env_sample|env_slow_us)
      if ! grep -qF "$anchor" "$SCHED" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: env $anchor not in $SCHED" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    output_prefix|field_summary|field_rank)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    impl_flush|impl_push)
      if ! grep -qE "(void|static void) ${anchor}\\(" "$SCHED" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: ${anchor} not in $SCHED" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    event_kind)
      if ! grep -qF "\"$anchor\"" "$SCHED" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: event kind $anchor not in $SCHED" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "obs-async-runtime-trace FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: doc missing file ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    object)
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "obs-async-runtime-trace FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-async-runtime-trace FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FOUND" -lt "$MIN_ITEMS" ]; then
  echo "obs-async-runtime-trace gate FAIL: items=${FOUND} < min ${MIN_ITEMS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "obs-async-runtime-trace gate FAIL: missing=${MISS}" >&2
  exit 1
fi
for kw in SHUX_ASYNC_RUNTIME_TRACE 长尾 drain_idle poll_completions; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "obs-async-runtime-trace gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "obs-async-runtime-trace manifest OK (items=${FOUND})"

echo "=== OBS-002: smoke harness ==="
make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o
if [ ! -f "$SCHED_O" ]; then
  echo "obs-async-runtime-trace gate FAIL: missing $SCHED_O" >&2
  exit 1
fi
SMOKE_BIN="/tmp/shux_obs_async_trace_smoke_$$"
cc -std=gnu11 -Wall -Wextra -o "$SMOKE_BIN" "$SMOKE_SRC" "$SCHED_O" 2>/tmp/obs_async_trace_build.log || {
  cat /tmp/obs_async_trace_build.log >&2
  echo "obs-async-runtime-trace gate FAIL: smoke compile" >&2
  rm -f "$SMOKE_BIN"
  exit 1
}
SHUX_ASYNC_RUNTIME_TRACE=1 \
  SHUX_ASYNC_RUNTIME_TRACE_TOPN="$MIN_TOPN" \
  "$SMOKE_BIN" 2>/tmp/obs_async_trace_run.log || {
  cat /tmp/obs_async_trace_run.log >&2
  echo "obs-async-runtime-trace gate FAIL: smoke run" >&2
  rm -f "$SMOKE_BIN"
  exit 1
}
rm -f "$SMOKE_BIN"

grep -qF "$PREFIX" /tmp/obs_async_trace_run.log || {
  echo "obs-async-runtime-trace gate FAIL: missing trace prefix" >&2
  exit 1
}
grep -qF 'summary events=' /tmp/obs_async_trace_run.log || {
  echo "obs-async-runtime-trace gate FAIL: missing summary line" >&2
  exit 1
}
grep -qE 'rank=[1-9]' /tmp/obs_async_trace_run.log || {
  echo "obs-async-runtime-trace gate FAIL: missing rank line" >&2
  exit 1
}
RANKS=$(grep -cE 'rank=[0-9]+ kind=' /tmp/obs_async_trace_run.log || true)
if [ "$RANKS" -lt 1 ]; then
  echo "obs-async-runtime-trace gate FAIL: rank lines=${RANKS}" >&2
  exit 1
fi
echo "obs-async-runtime-trace smoke OK (rank_lines=${RANKS})"
echo "obs-async-runtime-trace gate OK"
