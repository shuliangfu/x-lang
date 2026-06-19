#!/usr/bin/env bash
# PERF-007：内存分配热点治理 manifest 门禁
#
# 用法：./tests/run-perf-alloc-hotspot-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_ALLOC_HOTSPOT_DOC:-analysis/perf-alloc-hotspot-v1.md}"
MANIFEST="${SHUX_PERF_ALLOC_HOTSPOT_TSV:-tests/baseline/perf-alloc-hotspot.tsv}"
BASELINE="${SHUX_ALLOC_HOTSPOT_BASELINE:-tests/baseline/alloc-hotspot-perf.tsv}"
LIB="tests/lib/perf-alloc-hotspot.sh"
RUNNER="tests/run-perf-alloc-hotspot.sh"
STRING_ARENA="tests/run-perf-string-arena.sh"
MIN_CASES=2
PREFIX="shux: [SHUX_ALLOC_HOTSPOT]"

# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. tests/lib/perf-alloc-hotspot.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source tests/lib/dod-native-exe.sh

echo "=== PERF-007: alloc hotspot manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$STRING_ARENA"; do
  if [ ! -f "$f" ]; then
    echo "perf-alloc-hotspot gate FAIL: missing $f" >&2
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
echo "=== PERF-007: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-alloc-hotspot FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-alloc-hotspot FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|cap_row)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-alloc-hotspot FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
        echo "perf-alloc-hotspot FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-alloc-hotspot FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-alloc-hotspot FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-alloc-hotspot FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-alloc-hotspot FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'perf-alloc-hotspot.sh' "$STRING_ARENA" 2>/dev/null; then
  echo "perf-alloc-hotspot FAIL: $STRING_ARENA must source perf-alloc-hotspot.sh" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_ah_report_emit' "$STRING_ARENA" 2>/dev/null; then
  echo "perf-alloc-hotspot FAIL: $STRING_ARENA must call perf_ah_report_emit" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_ah_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-alloc-hotspot FAIL: $RUNNER must call perf_ah_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  echo "perf-alloc-hotspot gate FAIL: cases=${CASES} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-alloc-hotspot gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in alloc malloc strace arena hotspot; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-alloc-hotspot gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-alloc-hotspot manifest OK (cases=${CASES})"

if perf_ah_strace_probe_ok; then
  echo "=== PERF-007: alloc hotspot strace smoke (advisory) ==="
  chmod +x "$RUNNER"
  if SHUX_ALLOC_HOTSPOT_FAIL=0 ./"$RUNNER" 2>&1 | tee /tmp/perf_alloc_hotspot_smoke.log | tail -8; then
    if grep -qF "$PREFIX" /tmp/perf_alloc_hotspot_smoke.log; then
      echo "perf-alloc-hotspot strace smoke OK"
    else
      if grep -q 'alloc-hotspot perf SKIP' /tmp/perf_alloc_hotspot_smoke.log; then
        echo "perf-alloc-hotspot gate SKIP strace smoke (runner skipped)" >&2
      else
        echo "perf-alloc-hotspot gate FAIL: missing $PREFIX in runner output" >&2
        exit 1
      fi
    fi
  else
    echo "perf-alloc-hotspot gate SKIP strace smoke (runner non-fatal)" >&2
  fi
else
  echo "perf-alloc-hotspot gate SKIP strace smoke (need Linux + strace + native shux)" >&2
fi

echo "perf-alloc-hotspot gate OK"
