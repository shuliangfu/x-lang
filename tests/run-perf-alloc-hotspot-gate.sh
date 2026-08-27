#!/usr/bin/env bash
# PERF-007: alloc hotspot manifest gate.
#
# Honesty: soft XLANG_ALLOC_HOTSPOT_FAIL:-0 smoke previously left over-cap
# unchecked; soft SKIP→OK / runner-non-fatal soft green retired. Prefer
# product xlang_asm. DOC authority = archive/perf. Strace smoke over-cap =
# obs via runner (FAIL=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-alloc-hotspot-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. tests/lib/perf-alloc-hotspot.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_ALLOC_HOTSPOT_DOC:-analysis/archive/perf/perf-alloc-hotspot-v1.md}"
MANIFEST="${XLANG_PERF_ALLOC_HOTSPOT_TSV:-tests/baseline/perf-alloc-hotspot.tsv}"
BASELINE="${XLANG_ALLOC_HOTSPOT_BASELINE:-tests/baseline/alloc-hotspot-perf.tsv}"
LIB="tests/lib/perf-alloc-hotspot.sh"
RUNNER="tests/run-perf-alloc-hotspot.sh"
STRING_ARENA="tests/run-perf-string-arena.sh"
MIN_CASES=2
PREFIX="xlang: [XLANG_ALLOC_HOTSPOT]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-alloc-hotspot gate FAIL: $*" >&2
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
if [ -f analysis/perf-alloc-hotspot-v1.md ]; then
  die "refuse top-level analysis/perf-alloc-hotspot-v1.md (use archive/perf)"
fi

echo "=== PERF-007: alloc hotspot manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$STRING_ARENA"; do
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
  die "cases=${CASES} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in alloc malloc strace arena hotspot; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-alloc-hotspot manifest OK (cases=${CASES})"

# Strace smoke: prefer asm; missing compiler on Linux = hard; Darwin = skip.
chmod +x "$RUNNER"
if perf_ah_strace_probe_ok; then
  echo "=== PERF-007: alloc hotspot strace smoke ==="
  XLANG_GATE=""
  if ! XLANG_GATE="$(resolve_shu)"; then
    die "no native xlang for strace smoke (refuse soft SKIP→OK)"
  fi
  set +e
  out="$(
    XLANG="$XLANG_GATE" XLANG_ALLOC_HOTSPOT_FAIL=0 ./"$RUNNER" 2>&1
  )"
  rc=$?
  set -e
  printf '%s\n' "$out"
  if [ "$rc" -ne 0 ]; then
    die "alloc-hotspot runner rc=$rc"
  fi
  RUN_OK=1
  if echo "$out" | grep -qE 'obs=[1-9]|OBS:'; then
    OBS=1
  fi
  if echo "$out" | grep -qE 'skip=[1-9]'; then
    SKIP=1
  fi
  if ! echo "$out" | grep -qF "$PREFIX"; then
    die "missing $PREFIX in runner output"
  fi
  echo "perf-alloc-hotspot strace smoke OK"
else
  # Explicit bad XLANG still hard-dies.
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "perf-alloc-hotspot gate SKIP strace smoke (need Linux + strace)" >&2
fi

ok_report
echo "perf-alloc-hotspot gate OK"
