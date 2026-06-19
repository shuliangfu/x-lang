#!/usr/bin/env bash
# PERF-008：syscall 批处理优化 manifest 门禁
#
# 用法：./tests/run-perf-syscall-batch-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_SYSCALL_BATCH_DOC:-analysis/perf-syscall-batch-v1.md}"
MANIFEST="${SHUX_PERF_SYSCALL_BATCH_TSV:-tests/baseline/perf-syscall-batch.tsv}"
BASELINE="${SHUX_SYSCALL_BATCH_BASELINE:-tests/baseline/syscall-batch-perf.tsv}"
LIB="tests/lib/perf-syscall-batch.sh"
RUNNER="tests/run-perf-syscall-batch.sh"
ZC5="tests/run-zc5-gate.sh"
MIN_CASES=4
PREFIX="shux: [SHUX_SYSCALL_BATCH]"

# shellcheck source=tests/lib/perf-syscall-batch.sh
. tests/lib/perf-syscall-batch.sh

echo "=== PERF-008: syscall batch manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$ZC5"; do
  if [ ! -f "$f" ]; then
    echo "perf-syscall-batch gate FAIL: missing $f" >&2
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
echo "=== PERF-008: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing field $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case|cap_row)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! awk -F'\t' -v c="$anchor" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$BASELINE"; then
        echo "perf-syscall-batch FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "perf-syscall-batch FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-syscall-batch FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-syscall-batch FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! grep -qF 'perf-syscall-batch.sh' "$ZC5" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $ZC5 must source perf-syscall-batch.sh" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_sb_report_emit' "$ZC5" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $ZC5 must call perf_sb_report_emit" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf_sb_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-syscall-batch FAIL: $RUNNER must call perf_sb_report_emit" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  echo "perf-syscall-batch gate FAIL: cases=${CASES} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-syscall-batch gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in syscall batch readv splice strace; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-syscall-batch gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-syscall-batch manifest OK (cases=${CASES})"

if perf_sb_strace_probe_ok; then
  echo "=== PERF-008: syscall batch strace smoke (advisory) ==="
  chmod +x "$RUNNER"
  if SHUX_SYSCALL_BATCH_FAIL=0 ./"$RUNNER" 2>&1 | tee /tmp/perf_syscall_batch_smoke.log | tail -10; then
    if grep -qF "$PREFIX" /tmp/perf_syscall_batch_smoke.log; then
      echo "perf-syscall-batch strace smoke OK"
    elif grep -q 'syscall-batch perf SKIP' /tmp/perf_syscall_batch_smoke.log; then
      echo "perf-syscall-batch gate SKIP strace smoke (runner skipped)" >&2
    else
      echo "perf-syscall-batch gate FAIL: missing $PREFIX in runner output" >&2
      exit 1
    fi
  else
    echo "perf-syscall-batch gate SKIP strace smoke (runner non-fatal)" >&2
  fi
else
  echo "perf-syscall-batch gate SKIP strace smoke (need Linux + strace)" >&2
fi

echo "perf-syscall-batch gate OK"
