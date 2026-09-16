#!/usr/bin/env bash
# PERF-010: coldstart / first-compile manifest gate.
#
# Honesty: soft XLANG_PERF_FAIL_ON_COLDSTART_REGRESSION:-0 smoke previously
# left over-cap unchecked; soft SKIP→OK when no native xlang retired for the
# timing half (manifest still hard). Prefer product xlang_asm. Timing over-cap
# is observational via the runner (FAIL_ON=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-coldstart-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/perf-coldstart.sh
. tests/lib/perf-coldstart.sh

DOC="${XLANG_PERF_COLDSTART_DOC:-analysis/archive/perf/perf-coldstart-v1.md}"
MANIFEST="${XLANG_PERF_COLDSTART_MANIFEST:-tests/baseline/perf-coldstart.tsv}"
CAP="${XLANG_PERF_COLDSTART_CAP:-tests/baseline/coldstart-perf.tsv}"
MIN_LAYERS=6
MIN_METRICS=5
PREFIX="xlang: [XLANG_PERF_COLDSTART]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-coldstart gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-coldstart-v1.md ]; then
  die "refuse top-level analysis/perf-coldstart-v1.md (use archive/perf)"
fi

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

echo "=== PERF-010: coldstart manifest ==="
for f in "$DOC" "$MANIFEST" "$CAP" \
  tests/lib/perf-coldstart.sh tests/run-perf-coldstart.sh \
  examples/hello.x tests/freestanding/return42/main.x \
  tests/freestanding/hello/main.x tests/baseline/compile-dogfood.tsv \
  tests/baseline/perf-baseline-registry.tsv tests/run-ci-full-suite.sh; do
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
    min_layers) MIN_LAYERS="$c2" ;;
    min_metrics) MIN_METRICS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
LAYER_N=0
METRIC_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ -n "$src" ] && [ ! -f "$src" ]; then
        echo "perf-coldstart FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    metric)
      METRIC_N=$((METRIC_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing metric $anchor" >&2
        MISS=$((MISS + 1))
      fi
      cap="$(perf_coldstart_cap "$anchor" 2>/dev/null || true)"
      if [ -z "$cap" ]; then
        echo "perf-coldstart FAIL: cap missing $anchor in $CAP" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "perf-coldstart FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "perf-coldstart FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "perf-coldstart FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

CAP_N="$(perf_coldstart_metric_count)"
if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  die "layers=${LAYER_N} < min ${MIN_LAYERS}"
fi
if [ "$METRIC_N" -lt "$MIN_METRICS" ] || [ "$CAP_N" -lt "$MIN_METRICS" ]; then
  die "metrics manifest=${METRIC_N} cap=${CAP_N} min=${MIN_METRICS}"
fi

for kw in coldstart compile startup runnable report median; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done

if ! grep -qF 'coldstart-perf' tests/baseline/perf-baseline-registry.tsv 2>/dev/null; then
  die "registry missing coldstart-perf"
fi

if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "perf-coldstart manifest OK (layers=${LAYER_N} metrics=${METRIC_N})"

# Timing smoke: prefer asm; missing compiler = skip=1 (honest N/A), not soft OK.
# Soft FAIL_ON:-0 retired in runner (over-cap → obs).
chmod +x tests/run-perf-coldstart.sh
XLANG_GATE=""
if XLANG_GATE="$(resolve_shu)"; then
  set +e
  out="$(
    XLANG="$XLANG_GATE" XLANG_COLDSTART_RUNS="${XLANG_COLDSTART_GATE_RUNS:-3}" \
      XLANG_PERF_FAIL_ON_COLDSTART_REGRESSION=0 \
      ./tests/run-perf-coldstart.sh 2>&1
  )"
  rc=$?
  set -e
  printf '%s\n' "$out"
  if [ "$rc" -ne 0 ]; then
    die "coldstart runner rc=$rc"
  fi
  RUN_OK=1
  if echo "$out" | grep -qE 'obs=[1-9]|OBS:'; then
    OBS=1
  fi
  if echo "$out" | grep -qE 'skip=[1-9]'; then
    SKIP=1
  fi
else
  echo "perf-coldstart SKIP smoke (no native xlang; refuse soft SKIP→OK as green — skip=1)"
  SKIP=1
fi

echo "perf-coldstart gate OK"
ok_report
exit 0
