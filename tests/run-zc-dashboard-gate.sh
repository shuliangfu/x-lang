#!/usr/bin/env bash
# ZC-008: zero-copy metrics dashboard — leftover fossil DOC + leftover
# catalog no Honesty →硬绿.
#
# Honesty: leftover top-level `analysis/zc-dashboard-v1.md` as live DOC
# (file already archived to analysis/archive/zc/; gate still hard-required
# the missing top-level path → portable ZC-008 red) + leftover catalog no
# Honesty / missing run=/obs=/skip= report retired. Live =
# analysis/archive/zc/. Refuse top-level resurrect. No XLANG face (manifest
# + nested leftover runner). G.7: do not fork a resolver. Nested leftover
# of leftover `run-zc-dashboard.sh` (do not rewrite that runner; zc3/zc4/zc5
# host-c still leave). Keep `zc-dashboard gate OK`. Runner / missing xref
# stays hard. Explicit XLANG is ignored (no XLANG face).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-zc-dashboard-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/zc-dashboard.sh
. tests/lib/zc-dashboard.sh

DOC="${XLANG_ZC_DASHBOARD_DOC:-analysis/archive/zc/zc-dashboard-v1.md}"
MANIFEST="${XLANG_ZC_DASHBOARD_MANIFEST:-tests/baseline/zc-dashboard-manifest.tsv}"
METRICS="${XLANG_ZC_DASHBOARD_METRICS:-tests/baseline/zc-dashboard-metrics.tsv}"
HISTORY="${XLANG_ZC_DASHBOARD_HISTORY:-tests/baseline/zc-dashboard-history.tsv}"
LIB="tests/lib/zc-dashboard.sh"
RUNNER="tests/run-zc-dashboard.sh"
MIN_METRICS=8
MIN_DAYS=2
PREFIX="${XLANG_ZC_DASHBOARD_GATE_PREFIX:-xlang: [ZC_DASHBOARD]}"
RUN_OK=0
OBS=0
SKIP=0
SMOKE_LOG=""

die() {
  echo "zc-dashboard gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  rm -f "$SMOKE_LOG"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== ZC-008: zero-copy dashboard manifest (archive DOC; no XLANG face) ==="

# Refuse leftover fossil top-level DOC as live path (TST-003 / placeholder pattern).
# PLATFORM: SHARED archaeology — live = archive/zc/.
if [ -f analysis/zc-dashboard-v1.md ]; then
  die "top-level DOC resurrected (live = archive/zc/)"
fi

for f in "$DOC" "$MANIFEST" "$METRICS" "$HISTORY" "$LIB" "$RUNNER"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in dashboard daily runnable report sparkline XLANG_ZC_DASHBOARD; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_metrics) MIN_METRICS="$c2" ;;
    min_history_days) MIN_DAYS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      layer_key="${anchor%%	*}"
      if ! grep -qF "$layer_key" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing layer $layer_key" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script)
      path="$anchor"
      case "$kind" in
        script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "zc-dashboard FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "zc-dashboard FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "zc-dashboard FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

METRIC_N=$(awk -F'\t' '$1 !~ /^#/ && NF >= 2 { n++ } END { print n+0 }' "$METRICS")
if [ "$METRIC_N" -lt "$MIN_METRICS" ]; then
  die "metrics=${METRIC_N} < min ${MIN_METRICS}"
fi

HIST_DAYS=$(zcd_history_days "$HISTORY")
if [ "$HIST_DAYS" -lt "$MIN_DAYS" ]; then
  die "history days=${HIST_DAYS} < min ${MIN_DAYS}"
fi

if ! grep -qF 'zcd_report_emit' "$RUNNER" 2>/dev/null; then
  echo "zc-dashboard FAIL: $RUNNER must call zcd_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "zc-dashboard manifest OK (metrics=${METRIC_N} layers=${LAYER_N} days=${HIST_DAYS})"
RUN_OK=$((RUN_OK + 1))

echo "=== ZC-008: dashboard runnable report ==="
chmod +x "$RUNNER"
SMOKE_LOG="${TMPDIR:-/tmp}/xlang_zc_dashboard_smoke.$$"
if ! "$RUNNER" 2>"$SMOKE_LOG"; then
  cat "$SMOKE_LOG" >&2 || true
  die "runner"
fi
grep -q 'XLANG_ZC_DASHBOARD' "$SMOKE_LOG" || die "missing report prefix"
rm -f "$SMOKE_LOG"
SMOKE_LOG=""
RUN_OK=$((RUN_OK + 1))
echo "zc-dashboard gate OK"
ok_report
