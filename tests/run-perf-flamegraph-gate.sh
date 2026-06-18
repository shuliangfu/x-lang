#!/usr/bin/env bash
# PERF-005：perf flamegraph Top-N 热点报告门禁
#
# 1) analysis/perf-flamegraph-v1.md + perf-flamegraph.tsv manifest
# 2) tests/lib/perf-flamegraph.sh + run-perf-flamegraph.sh 存在
# 3) Linux + perf + native shu：烟测 check_typeck 须输出 ≥ min_top_n 行
#
# 用法：./tests/run-perf-flamegraph-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_PERF_FLAMEGRAPH_DOC:-analysis/perf-flamegraph-v1.md}"
MANIFEST="${SHU_PERF_FLAMEGRAPH_TSV:-tests/baseline/perf-flamegraph.tsv}"
LIB="tests/lib/perf-flamegraph.sh"
RUNNER="tests/run-perf-flamegraph.sh"
MIN_TOPN=20
MIN_CASES=2
SMOKE_CASE="check_typeck"
PREFIX="shu: [SHU_PERF_FLAMEGRAPH]"

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-flamegraph.sh
. tests/lib/perf-flamegraph.sh

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== PERF-005: flamegraph manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    echo "perf-flamegraph gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_top_n) MIN_TOPN="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CASES=0
echo "=== PERF-005: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    case_id)
      SMOKE_CASE="$anchor"
      ;;
    profile_case)
      CASES=$((CASES + 1))
      if ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "perf-flamegraph FAIL: doc missing case $item_id" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-flamegraph FAIL: doc missing field '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "perf-flamegraph FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-flamegraph FAIL: doc missing script ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "perf-flamegraph FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-flamegraph FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASES" -lt "$MIN_CASES" ]; then
  echo "perf-flamegraph gate FAIL: profile_cases=${CASES} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-flamegraph gate FAIL: missing=${MISS}" >&2
  exit 1
fi
for kw in perf record Top20 flamegraph SHU_PERF_FLAMEGRAPH; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "perf-flamegraph gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "perf-flamegraph manifest OK (cases=${CASES}, min_top_n=${MIN_TOPN})"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if ! perf_fg_probe_ok || [ -z "$SHU_BIN" ]; then
  echo "perf-flamegraph gate SKIP hooks (perf or native shu unavailable; host=$(ci_host_summary))" >&2
  echo "perf-flamegraph gate OK"
  exit 0
fi

echo "=== PERF-005: smoke profile ($SMOKE_CASE) ==="
chmod +x "$RUNNER"
OUT="/tmp/shu-perf-flamegraph-gate-$$"
SHU="$SHU_BIN" \
  SHU_PERF_FLAMEGRAPH_CASE="$SMOKE_CASE" \
  SHU_PERF_FLAMEGRAPH_OUT_DIR="$OUT" \
  SHU_PERF_FLAMEGRAPH_TOPN="$MIN_TOPN" \
  ./"$RUNNER" 2>&1 | tee /tmp/perf_flamegraph_smoke.log

grep -q "perf-flamegraph OK" /tmp/perf_flamegraph_smoke.log || {
  echo "perf-flamegraph gate FAIL: runner did not OK" >&2
  exit 1
}
grep -qF "${PREFIX} case=${SMOKE_CASE} top${MIN_TOPN}_done" /tmp/perf_flamegraph_smoke.log || {
  echo "perf-flamegraph gate FAIL: missing top${MIN_TOPN}_done line" >&2
  exit 1
}
TSV="${OUT}/${SMOKE_CASE}-top${MIN_TOPN}.tsv"
if [ ! -f "$TSV" ]; then
  echo "perf-flamegraph gate FAIL: missing $TSV" >&2
  exit 1
fi
ROWS=$(wc -l <"$TSV" | tr -d ' ')
if [ "$ROWS" -lt "$MIN_TOPN" ]; then
  echo "perf-flamegraph gate FAIL: rows=${ROWS} < min_top_n=${MIN_TOPN}" >&2
  exit 1
fi
echo "perf-flamegraph smoke OK (case=${SMOKE_CASE} rows=${ROWS})"
echo "perf-flamegraph gate OK"
