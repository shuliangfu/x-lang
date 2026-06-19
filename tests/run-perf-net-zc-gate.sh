#!/usr/bin/env bash
# PERF-009：网络零拷贝 CPU/byte manifest 门禁
#
# 用法：./tests/run-perf-net-zc-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_NET_ZC_DOC:-analysis/perf-net-zc-v1.md}"
MANIFEST="${SHUX_PERF_NET_ZC_TSV:-tests/baseline/perf-net-zc.tsv}"
BASELINE="${SHUX_NET_ZC_BASELINE:-tests/baseline/net-zc-perf.tsv}"
LIB="tests/lib/perf-net-zc.sh"
RUNNER="tests/run-perf-net-zc.sh"
NET_PERF="tests/run-perf-net.sh"
ZC1="tests/run-zc1-gate.sh"
MIN_CASES=3
PREFIX="shux: [SHUX_NET_ZC]"

# shellcheck source=tests/lib/perf-net-zc.sh
. tests/lib/perf-net-zc.sh

echo "=== PERF-009: net zero-copy manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$NET_PERF" "$ZC1"; do
  if [ ! -f "$f" ]; then
    echo "perf-net-zc gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASES=0
echo "=== PERF-009: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-net-zc FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-net-zc FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|cap_row)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-net-zc FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
        echo "perf-net-zc FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-net-zc FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-net-zc FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-net-zc FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-net-zc FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'perf-net-zc.sh' "$NET_PERF" 2>/dev/null; then
  echo "perf-net-zc FAIL: $NET_PERF must source perf-net-zc.sh" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_nz_report_emit' "$NET_PERF" 2>/dev/null; then
  echo "perf-net-zc FAIL: $NET_PERF must call perf_nz_report_emit" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_nz_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-net-zc FAIL: $RUNNER must call perf_nz_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  echo "perf-net-zc gate FAIL: cases=${CASES} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-net-zc gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in cycles zero copy provided net echo; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-net-zc gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-net-zc manifest OK (cases=${CASES})"

if perf_nz_probe_ok; then
  echo "=== PERF-009: net zc perf smoke (advisory) ==="
  chmod +x "$RUNNER"
  if SHUX_NET_ZC_FAIL=0 ./"$RUNNER" 2>&1 | tee /tmp/perf_net_zc_smoke.log | tail -10; then
    if grep -qF "$PREFIX" /tmp/perf_net_zc_smoke.log; then
      echo "perf-net-zc perf smoke OK"
    elif grep -q 'net-zc perf SKIP' /tmp/perf_net_zc_smoke.log; then
      echo "perf-net-zc gate SKIP perf smoke (runner skipped)" >&2
    else
      echo "perf-net-zc gate FAIL: missing $PREFIX in runner output" >&2
      exit 1
    fi
  else
    echo "perf-net-zc gate SKIP perf smoke (runner non-fatal)" >&2
  fi
else
  echo "perf-net-zc gate SKIP perf smoke (need Linux + perf)" >&2
fi

echo "perf-net-zc gate OK"
