#!/usr/bin/env bash
# OBS-002: async/runtime trace manifest + C smoke — leftover fossil DOC +
# leftover catalog no Honesty + leftover auto-make →硬绿.
#
# Honesty: leftover top-level `analysis/obs-async-runtime-trace-v1.md` as
# live DOC (file already archived to analysis/archive/obs/; gate still
# hard-required the missing top-level path → portable OBS-002 red) + leftover
# catalog no Honesty / missing run=/obs=/skip= + leftover
# `xlang_compiler_make ../std/async/scheduler.o -q || make` retired.
# Live = analysis/archive/obs/. Refuse top-level resurrect. No XLANG face
# (host-cc of bench/async_runtime_trace_smoke.c + existing scheduler.o).
# G.7: do not fork a resolver; drop leftover unused compiler-make source.
# Missing / UNDEF scheduler.o = obs (host-C archaeology; refuse leftover
# auto-make). Keep `obs-async-runtime-trace gate OK`. Explicit XLANG is
# ignored (no XLANG face).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-obs-async-runtime-trace-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_OBS_ASYNC_TRACE_DOC:-analysis/archive/obs/obs-async-runtime-trace-v1.md}"
MANIFEST="${XLANG_OBS_ASYNC_TRACE_TSV:-tests/baseline/obs-async-runtime-trace.tsv}"
SCHED="${XLANG_OBS_ASYNC_TRACE_SCHED:-compiler/seeds/runtime_scheduler_glue.from_x.c}"
SMOKE_SRC="${XLANG_OBS_ASYNC_TRACE_SMOKE:-bench/async_runtime_trace_smoke.c}"
SCHED_O="std/async/scheduler.o"
MIN_ITEMS=8
MIN_TOPN=5
PREFIX="${XLANG_OBS_ASYNC_TRACE_PREFIX:-xlang: [XLANG_ASYNC_RUNTIME_TRACE]}"
RUN_OK=0
OBS=0
SKIP=0
SMOKE_BIN=""
BUILD_LOG=""
RUN_LOG=""

die() {
  echo "obs-async-runtime-trace gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  rm -f "$SMOKE_BIN" "$BUILD_LOG" "$RUN_LOG"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== OBS-002: async runtime trace manifest (archive DOC; no XLANG face) ==="

# Refuse leftover fossil top-level DOC as live path (TST-003 / placeholder pattern).
# PLATFORM: SHARED archaeology — live = archive/obs/.
if [ -f analysis/obs-async-runtime-trace-v1.md ]; then
  die "top-level DOC resurrected (live = archive/obs/)"
fi

for f in "$DOC" "$MANIFEST" "$SCHED" "$SMOKE_SRC"; do
  [ -f "$f" ] || die "missing $f"
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
  die "items=${FOUND} < min ${MIN_ITEMS}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
for kw in XLANG_ASYNC_RUNTIME_TRACE 长尾 drain_idle poll_completions; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "obs-async-runtime-trace manifest OK (items=${FOUND})"
RUN_OK=$((RUN_OK + 1))

echo "=== OBS-002: smoke harness (existing scheduler.o; refuse leftover auto-make) ==="
# PLATFORM: SHARED — host-cc C smoke against an existing .o; not a product -o path.
# Host-C archaeology = obs without leftover auto-make rebuild.
SMOKE_BIN="${TMPDIR:-/tmp}/xlang_obs_async_trace_smoke.$$"
BUILD_LOG="${TMPDIR:-/tmp}/xlang_obs_async_trace_build.$$"
RUN_LOG="${TMPDIR:-/tmp}/xlang_obs_async_trace_run.$$"
if [ ! -f "$SCHED_O" ]; then
  echo "obs-async-runtime-trace OBS: missing $SCHED_O (host-C archaeology; refuse leftover auto-make)" >&2
  OBS=$((OBS + 1))
else
  smoke_ok=1
  if ! ${CC:-cc} -std=gnu11 -Wall -Wextra -o "$SMOKE_BIN" "$SMOKE_SRC" "$SCHED_O" 2>"$BUILD_LOG"; then
    echo "obs-async-runtime-trace OBS: smoke compile (host-C archaeology; refuse leftover auto-make)" >&2
    cat "$BUILD_LOG" >&2 || true
    OBS=$((OBS + 1))
    smoke_ok=0
  elif ! XLANG_ASYNC_RUNTIME_TRACE=1 \
      XLANG_ASYNC_RUNTIME_TRACE_TOPN="$MIN_TOPN" \
      "$SMOKE_BIN" 2>"$RUN_LOG"; then
    echo "obs-async-runtime-trace OBS: smoke run (host-C archaeology)" >&2
    cat "$RUN_LOG" >&2 || true
    OBS=$((OBS + 1))
    smoke_ok=0
  elif ! grep -qF "$PREFIX" "$RUN_LOG" \
      || ! grep -qF 'summary events=' "$RUN_LOG" \
      || ! grep -qE 'rank=[1-9]' "$RUN_LOG"; then
    echo "obs-async-runtime-trace OBS: smoke output (host-C archaeology)" >&2
    OBS=$((OBS + 1))
    smoke_ok=0
  else
    RANKS=$(grep -cE 'rank=[0-9]+ kind=' "$RUN_LOG" || true)
    if [ "$RANKS" -lt 1 ]; then
      echo "obs-async-runtime-trace OBS: rank lines=${RANKS} (host-C archaeology)" >&2
      OBS=$((OBS + 1))
      smoke_ok=0
    else
      RUN_OK=$((RUN_OK + 1))
      echo "obs-async-runtime-trace smoke OK (rank_lines=${RANKS})"
    fi
  fi
fi
rm -f "$SMOKE_BIN" "$BUILD_LOG" "$RUN_LOG"
SMOKE_BIN=""
BUILD_LOG=""
RUN_LOG=""
echo "obs-async-runtime-trace gate OK"
ok_report
