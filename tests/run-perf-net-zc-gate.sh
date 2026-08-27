#!/usr/bin/env bash
# PERF-009: net zero-copy manifest gate.
#
# Honesty: soft XLANG_NET_ZC_FAIL:-0 smoke previously left over-cap /
# zc≥ref unchecked; soft SKIP→OK / runner-non-fatal soft green retired.
# Prefer product xlang_asm. DOC authority = archive/perf. Perf smoke
# over-cap = obs via runner (FAIL=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-net-zc-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-net-zc.sh
. tests/lib/perf-net-zc.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_PERF_NET_ZC_DOC:-analysis/archive/perf/perf-net-zc-v1.md}"
MANIFEST="${XLANG_PERF_NET_ZC_TSV:-tests/baseline/perf-net-zc.tsv}"
BASELINE="${XLANG_NET_ZC_BASELINE:-tests/baseline/net-zc-perf.tsv}"
LIB="tests/lib/perf-net-zc.sh"
RUNNER="tests/run-perf-net-zc.sh"
NET_PERF="tests/run-perf-net.sh"
ZC1="tests/run-zc1-gate.sh"
MIN_CASES=3
PREFIX="xlang: [XLANG_NET_ZC]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-net-zc gate FAIL: $*" >&2
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
if [ -f analysis/perf-net-zc-v1.md ]; then
  die "refuse top-level analysis/perf-net-zc-v1.md (use archive/perf)"
fi

echo "=== PERF-009: net zero-copy manifest ==="
for f in "$DOC" "$MANIFEST" "$BASELINE" "$LIB" "$RUNNER" "$NET_PERF" "$ZC1"; do
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

if ! grep -qF 'perf_nz_report_emit' "$RUNNER" 2>/dev/null; then
  echo "perf-net-zc FAIL: $RUNNER must call perf_nz_report_emit" >&2
  MISS=$((MISS + 1))
fi
if ! grep -qF 'perf-net-zc.sh' "$NET_PERF" 2>/dev/null; then
  echo "perf-net-zc FAIL: $NET_PERF must source perf-net-zc.sh" >&2
  MISS=$((MISS + 1))
fi

if [ "$CASES" -lt "$MIN_CASES" ]; then
  die "cases=${CASES} < min ${MIN_CASES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi

for kw in cycles zero copy provided net echo; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
echo "perf-net-zc manifest OK (cases=${CASES})"

# Perf smoke: prefer asm; missing compiler on Linux = hard; Darwin = skip.
chmod +x "$RUNNER"
if perf_nz_probe_ok; then
  echo "=== PERF-009: net zc perf smoke ==="
  XLANG_GATE=""
  if ! XLANG_GATE="$(resolve_shu)"; then
    die "no native xlang for perf smoke (refuse soft SKIP→OK)"
  fi
  set +e
  out="$(
    XLANG="$XLANG_GATE" XLANG_NET_ZC_FAIL=0 ./"$RUNNER" 2>&1
  )"
  rc=$?
  set -e
  printf '%s\n' "$out"
  if [ "$rc" -ne 0 ]; then
    die "net-zc runner rc=$rc"
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
  echo "perf-net-zc perf smoke OK"
else
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "perf-net-zc gate SKIP perf smoke (need Linux + perf)" >&2
fi

ok_report
echo "perf-net-zc gate OK"
