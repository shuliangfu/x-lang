#!/usr/bin/env bash
# PERF-005: perf flamegraph Top-N hotspot report gate.
#
# Honesty: soft SKIP→OK when no perf / no native xlang (bare exit 0)
# retired. Prefer product xlang_asm. Explicit bad XLANG = hard die.
# DOC authority = archive/perf (refuse top-level resurrect). Fossil
# bench/loop_i32.x + top-level cross-refs remapped. No-perf host =
# skip=1 (honest N/A). Partial Top-N rows = obs via runner. Report
# run=/obs=/skip=.
#
# Usage: ./tests/run-perf-flamegraph-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin skip=1 no perf).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-flamegraph.sh
. tests/lib/perf-flamegraph.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_FLAMEGRAPH_DOC:-analysis/archive/perf/perf-flamegraph-v1.md}"
MANIFEST="${XLANG_PERF_FLAMEGRAPH_TSV:-tests/baseline/perf-flamegraph.tsv}"
LIB="tests/lib/perf-flamegraph.sh"
RUNNER="tests/run-perf-flamegraph.sh"
MIN_TOPN=20
MIN_CASES=2
SMOKE_CASE="loop_i32_compile"
PREFIX="xlang: [XLANG_PERF_FLAMEGRAPH]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-flamegraph gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-flamegraph-v1.md ]; then
  die "refuse top-level analysis/perf-flamegraph-v1.md (use archive/perf)"
fi

echo "=== PERF-005: flamegraph manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$RUNNER"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
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
  die "profile_cases=${CASES} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
for kw in perf record Top20 flamegraph XLANG_PERF_FLAMEGRAPH; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-flamegraph manifest OK (cases=${CASES}, min_top_n=${MIN_TOPN})"
RUN_OK=1

# Explicit bad XLANG still hard-dies even when perf smoke is N/A.
if [ -n "${XLANG:-}" ]; then
  resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
fi

if ! perf_fg_probe_ok; then
  SKIP=1
  echo "perf-flamegraph gate SKIP smoke (perf unavailable; host=$(ci_host_summary); skip=1)" >&2
  echo "perf-flamegraph gate OK"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"

echo "=== PERF-005: smoke profile ($SMOKE_CASE) ==="
chmod +x "$RUNNER"
OUT="/tmp/xlang-perf-flamegraph-gate-$$"
set +e
out="$(
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    XLANG_PERF_FLAMEGRAPH_CASE="$SMOKE_CASE" \
    XLANG_PERF_FLAMEGRAPH_OUT_DIR="$OUT" \
    XLANG_PERF_FLAMEGRAPH_TOPN="$MIN_TOPN" \
    ./"$RUNNER" 2>&1
)"
rc=$?
set -e
printf '%s\n' "$out"
echo "$out" | tee /tmp/perf_flamegraph_smoke.log >/dev/null
if [ "$rc" -ne 0 ]; then
  die "runner rc=$rc"
fi
if ! echo "$out" | grep -q "perf-flamegraph OK"; then
  die "runner did not OK"
fi
if ! echo "$out" | grep -qF "${PREFIX} case=${SMOKE_CASE} top${MIN_TOPN}_done"; then
  die "missing top${MIN_TOPN}_done line"
fi
TSV="${OUT}/${SMOKE_CASE}-top${MIN_TOPN}.tsv"
if [ ! -f "$TSV" ]; then
  die "missing $TSV"
fi
ROWS=$(wc -l <"$TSV" | tr -d ' ')
if [ "$ROWS" -lt "$MIN_TOPN" ]; then
  # Partial Top-N = product/tooling obs (not silent OK).
  OBS=1
  echo "perf-flamegraph OBS: rows=${ROWS} < min_top_n=${MIN_TOPN}" >&2
fi
if echo "$out" | grep -qE 'OBS:|warn=rows_lt_topn|obs=[1-9]'; then
  OBS=1
fi
echo "perf-flamegraph smoke OK (case=${SMOKE_CASE} rows=${ROWS})"
echo "perf-flamegraph gate OK"
ok_report
exit 0
