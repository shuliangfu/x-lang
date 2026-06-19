#!/usr/bin/env bash
# PERF-006：CPU cache miss 治理 manifest 门禁
#
# 用法：./tests/run-perf-cache-miss-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_CACHE_MISS_DOC:-analysis/perf-cache-miss-v1.md}"
MANIFEST="${SHUX_PERF_CACHE_MISS_TSV:-tests/baseline/perf-cache-miss.tsv}"
BASELINE="${SHUX_CACHE_MISS_BASELINE:-tests/baseline/cache-miss-perf.tsv}"
LIB="tests/lib/perf-cache-miss.sh"
DOD_PERF="tests/run-perf-dod-soa.sh"
MIN_CASES=2
PREFIX="shux: [SHUX_CACHE_MISS]"

# shellcheck source=tests/lib/perf-cache-miss.sh
. tests/lib/perf-cache-miss.sh

echo "=== PERF-006: cache miss manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$DOD_PERF"; do
  if [ ! -f "$f" ]; then
    echo "perf-cache-miss gate FAIL: missing $f" >&2
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
echo "=== PERF-006: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|cap_row)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
        echo "perf-cache-miss FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-cache-miss FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-cache-miss FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'perf-cache-miss.sh' "$DOD_PERF" 2>/dev/null; then
  echo "perf-cache-miss FAIL: $DOD_PERF must source perf-cache-miss.sh" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_cm_report_emit' "$DOD_PERF" 2>/dev/null; then
  echo "perf-cache-miss FAIL: $DOD_PERF must call perf_cm_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  echo "perf-cache-miss gate FAIL: cases=${CASES} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-cache-miss gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in cache miss L1 SoA perf stat; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-cache-miss gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-cache-miss manifest OK (cases=${CASES})"

if [ "$(uname -s)" = "Linux" ] && perf_cm_probe_ok; then
  echo "=== PERF-006: dod-soa L1 hook smoke (advisory) ==="
  chmod +x "$DOD_PERF"
  if SHUX_DOD_SOA_FAIL=0 ./"$DOD_PERF" 2>&1 | tee /tmp/perf_cache_miss_smoke.log | tail -5; then
    grep -qF "$PREFIX" /tmp/perf_cache_miss_smoke.log || {
      echo "perf-cache-miss gate FAIL: missing $PREFIX in dod-soa output" >&2
      exit 1
    }
    echo "perf-cache-miss L1 smoke OK"
  else
    echo "perf-cache-miss gate SKIP L1 smoke (dod-soa non-fatal)" >&2
  fi
else
  echo "perf-cache-miss gate SKIP L1 smoke (need Linux + perf)" >&2
fi

echo "perf-cache-miss gate OK"
