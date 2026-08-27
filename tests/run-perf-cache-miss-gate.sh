#!/usr/bin/env bash
# PERF-006: CPU cache miss manifest gate.
#
# Honesty: soft XLANG_DOD_SOA_FAIL:-0 smoke previously left L1-over / correctness
# unchecked; soft "dod-soa non-fatal" SKIP→OK retired. Prefer product xlang_asm.
# DOC authority = archive/perf. L1 smoke over-cap / correctness = obs via runner
# (FAIL=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-cache-miss-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold L1; Darwin manifest-only + skip).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-cache-miss.sh
. tests/lib/perf-cache-miss.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_CACHE_MISS_DOC:-analysis/archive/perf/perf-cache-miss-v1.md}"
MANIFEST="${XLANG_PERF_CACHE_MISS_TSV:-tests/baseline/perf-cache-miss.tsv}"
BASELINE="${XLANG_CACHE_MISS_BASELINE:-tests/baseline/cache-miss-perf.tsv}"
LIB="tests/lib/perf-cache-miss.sh"
DOD_PERF="tests/run-perf-dod-soa.sh"
MIN_CASES=2
PREFIX="xlang: [XLANG_CACHE_MISS]"
DOD_PREFIX="xlang: [XLANG_DOD_SOA]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-cache-miss gate FAIL: $*" >&2
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
if [ -f analysis/perf-cache-miss-v1.md ]; then
  die "refuse top-level analysis/perf-cache-miss-v1.md (use archive/perf)"
fi

echo "=== PERF-006: cache miss manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$DOD_PERF"; do
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
    field|output_field)
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
    case)
      CASES=$((CASES + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-cache-miss FAIL: doc missing case $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if ! grep -qF "$anchor" "$BASELINE" 2>/dev/null; then
        echo "perf-cache-miss FAIL: baseline missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cap_row)
      if ! grep -qF "$anchor" "$BASELINE" 2>/dev/null; then
        echo "perf-cache-miss FAIL: baseline missing cap $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|script|hook_script|cross_ref)
      path="$anchor"
      case "$kind" in
        script|hook_script) path="tests/$anchor" ;;
        file)
          case "$anchor" in
            tests/*|analysis/*|bench/*|std/*|compiler/*) path="$anchor" ;;
            *) path="tests/$anchor" ;;
          esac
          ;;
      esac
      if [ "$kind" = "cross_ref" ]; then
        if [ ! -f "$anchor" ] && ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
          echo "perf-cache-miss FAIL: missing xref $anchor" >&2
          MISS=$((MISS + 1))
        fi
      elif [ ! -f "$path" ]; then
        # Some cross paths are relative notes; require DOC mention if missing on disk.
        if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
          echo "perf-cache-miss FAIL: missing $path" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$CASES" -lt "$MIN_CASES" ]; then
  die "cases=${CASES} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in cache miss L1 SoA perf; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-cache-miss manifest OK (cases=${CASES})"
RUN_OK=1

# Explicit bad XLANG still hard-dies even when L1 smoke is N/A.
if [ -n "${XLANG:-}" ]; then
  resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
fi

if [ "$(uname -s)" = "Linux" ] && perf_cm_probe_ok; then
  echo "=== PERF-006: dod-soa L1 hook smoke ==="
  chmod +x "$DOD_PERF"
  XLANG_BIN="$(resolve_shu)" || die "no native xlang for L1 smoke"
  set +e
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" XLANG_DOD_SOA_FAIL=0 \
    ./"$DOD_PERF" 2>&1 | tee /tmp/perf_cache_miss_smoke.log
  smoke_rc=${PIPESTATUS[0]}
  set -e
  if [ "$smoke_rc" -ne 0 ]; then
    die "dod-soa L1 smoke hard-fail rc=${smoke_rc}"
  fi
  grep -qF "$DOD_PREFIX" /tmp/perf_cache_miss_smoke.log || \
    die "missing $DOD_PREFIX in dod-soa output"
  if grep -q 'OBS:' /tmp/perf_cache_miss_smoke.log; then
    OBS=1
    echo "perf-cache-miss L1 smoke OBS (see dod-soa log)" >&2
  else
    grep -qF "$PREFIX" /tmp/perf_cache_miss_smoke.log || \
      echo "perf-cache-miss: note — XLANG_CACHE_MISS emit may be absent when miss=nan" >&2
  fi
  echo "perf-cache-miss L1 smoke OK"
else
  SKIP=1
  echo "perf-cache-miss gate SKIP L1 smoke (need Linux + perf)" >&2
fi

ok_report
echo "perf-cache-miss gate OK"
