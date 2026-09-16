#!/usr/bin/env bash
# STD-117: std.metrics observability-context gate — honesty soft prefer-c /
# soft SKIP→OK / grep-as-sole-green →硬绿.
#
# Honesty: prefer-c first + soft auto-make + soft SKIP→OK (no native still
# gate OK) + grep-only "X_OK=1 SKIP=1" fake green retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die. Manifest = hard. check residual = obs (paused 2026-08-05). tip product
# -o std_metrics_* / std_trace_* UNDEF = obs (product debt; leave). Report:
# run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-metrics-obs-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_METRICS_OBS_DOC:-analysis/archive/std/std-metrics-obs-v1.md}"
MANIFEST="${XLANG_STD_METRICS_OBS_MANIFEST:-tests/baseline/std-metrics-obs-manifest.tsv}"
VECTORS="${XLANG_STD_METRICS_OBS_VECTORS:-tests/baseline/std-metrics-obs-vectors.tsv}"
MOD_X="std/metrics/mod.x"
LIB="tests/lib/std-metrics-obs.sh"
SMOKE_X="tests/std-metrics/obs_correlation.x"
MIN_APIS=6

# shellcheck source=tests/lib/std-metrics-obs.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-metrics-obs gate FAIL: $*" >&2
  std_metrics_obs_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== STD-117: std.metrics-obs manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
[ ! -f analysis/std-metrics-obs-v1.md ] || die "dual-authority fossil analysis/std-metrics-obs-v1.md (archive live)"

grep -qF obs_ctx_format_log_kv "$DOC" 2>/dev/null || die "doc missing obs_ctx_format_log_kv"
grep -qF 'trace_id=' "$VECTORS" 2>/dev/null || die "vectors missing trace_id="

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_metrics_obs_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"

# Grep anchors stay hard; refuse grep-as-sole-green.
grep -q 'metrics.counter(' "$SMOKE_X" 2>/dev/null || die "obs smoke missing metrics.counter"
echo "std-metrics-obs manifest OK"

if [ "${XLANG_STD_METRICS_OBS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_metrics_obs_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-metrics-obs gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-117: smoke (XLANG=$XLANG_BIN; check=obs; tip product -o UNDEF=obs) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_metrics_obs_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-metrics-obs OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_metrics_obs_$$"
LOG="/tmp/xlang_std_metrics_obs_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  echo "std-metrics-obs OBS tip product -o (ec=$o_ec; std_metrics_*/std_trace_* UNDEF residual)" >&2
  OBS=$((OBS + 1))
else
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  if [ "$exitcode" -ne 0 ]; then
    echo "std-metrics-obs OBS tip run exit=$exitcode" >&2
    OBS=$((OBS + 1))
  else
    RUN_OK=$((RUN_OK + 1))
    echo "std-metrics-obs OK: product -o"
  fi
fi

std_metrics_obs_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-metrics-obs gate OK"
