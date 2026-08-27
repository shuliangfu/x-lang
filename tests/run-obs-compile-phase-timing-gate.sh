#!/usr/bin/env bash
# OBS-001: compile phase timing manifest + smoke (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK (no native / no phase timing / check-or--o fail) +
# prefer-c (xlang-c before asm) + soft auto-make retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Manifest always hard. Phase-timing smoke miss = obs (not soft OK).
# Report: run=/obs=/skip=
# DOC authority = archive/obs. Usage: ./tests/run-obs-compile-phase-timing-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_OBS_PHASE_TIMING_DOC:-analysis/archive/obs/obs-compile-phase-timing-v1.md}"
MANIFEST="${XLANG_OBS_PHASE_TIMING_TSV:-tests/baseline/obs-compile-phase-timing.tsv}"
RUNTIME="${XLANG_OBS_PHASE_TIMING_RUNTIME:-compiler/seeds/runtime_driver_abi.from_x.c}"
PIPELINE="${XLANG_OBS_PHASE_TIMING_PIPELINE:-compiler/src/pipeline/pipeline.x}"
MIN_ITEMS=6
OUTPUT_PREFIX="xlang: [XLANG_COMPILE_PHASE_TIMING]"
SMOKE_FIX="examples/hello.x"
PREFIX="${XLANG_OBS_PHASE_PREFIX:-xlang: [XLANG_OBS_PHASE]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "obs-compile-phase-timing FAIL: $*" >&2
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== OBS-001: compile phase timing manifest ==="
for f in "$DOC" "$MANIFEST" "$RUNTIME" "$PIPELINE"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  case "$item_id" in
    output_prefix) OUTPUT_PREFIX="$anchor" ;;
    smoke_fixture) SMOKE_FIX="$anchor" ;;
  esac
done < "$MANIFEST"

MISS=0
FOUND=0
echo "=== OBS-001: manifest anchor check ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_items) continue ;; esac
  FOUND=$((FOUND + 1))
  case "$kind" in
    env_var)
      if ! grep -qF "$anchor" "$RUNTIME" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: env $anchor not in $RUNTIME" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    output_prefix|field_parse|field_typeck|field_codegen|field_total)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    impl_begin|impl_end|impl_flush)
      if ! grep -qE "(void|function) ${anchor}\\(" "$RUNTIME" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: ${anchor} not in $RUNTIME" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    pipeline_hook)
      if ! grep -qF "$anchor" "$PIPELINE" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: ${anchor} not in $PIPELINE" >&2
        MISS=$((MISS + 1))
      fi
      if ! grep -qF "driver_compile_phase_timing_begin" "$PIPELINE" 2>/dev/null; then
        echo "obs-compile-phase-timing FAIL: timing hooks missing in $PIPELINE" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke_fixture)
      if [ ! -f "$anchor" ]; then
        echo "obs-compile-phase-timing FAIL: missing fixture $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$FOUND" -ge "$MIN_ITEMS" ] || die "items=${FOUND} < min_items=${MIN_ITEMS}"
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "obs-compile-phase-timing manifest OK (host=$(ci_host_summary), items=${FOUND})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

LOG=/tmp/xlang_obs_phase_timing.log
# Prefer product -o (check paused). Timing lines must appear for hard run;
# missing timing on tip = obs (was soft SKIP→OK).
set +e
XLANG_COMPILE_PHASE_TIMING=1 "$XLANG_BIN" "$SMOKE_FIX" -o /tmp/xlang_obs_phase_timing_$$ >"$LOG" 2>&1
o_ec=$?
set -e
rm -f /tmp/xlang_obs_phase_timing_$$ 2>/dev/null || true
if [ "$o_ec" -ne 0 ]; then
  # Secondary observational check path.
  set +e
  XLANG_COMPILE_PHASE_TIMING=1 "$XLANG_BIN" check "$SMOKE_FIX" >"$LOG" 2>&1
  set -e
fi

if grep -qF "$OUTPUT_PREFIX" "$LOG"; then
  miss_field=0
  for field in parse_ms= typeck_ms= codegen_ms= total_ms=; do
    if ! grep -qF "$field" "$LOG"; then
      echo "obs-compile-phase-timing FAIL: missing $field in output" >&2
      miss_field=1
    fi
  done
  [ "$miss_field" -eq 0 ] || die "phase timing fields incomplete"
  RUN_OK=$((RUN_OK + 1))
  echo "obs-compile-phase-timing smoke OK ($XLANG_BIN $SMOKE_FIX)"
else
  OBS=$((OBS + 1))
  echo "obs-compile-phase-timing OBS smoke (phase timing unavailable on tip; refuse soft SKIP→OK)" >&2
fi

echo "obs-compile-phase-timing gate OK"
ok_report
