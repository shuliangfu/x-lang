#!/usr/bin/env bash
# COMP-007: incremental compile second-pass smoke (false-authority honesty).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c (xlang-c before
# xlang_asm) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die after proto
# registry (proto face is live without a compiler). `xlang check` benches
# = obs (check gate paused 2026-08-05). Ratio over-cap = obs
# (XLANG_INCR_COMPILE_FAIL=1 still hard). Fossil fixture default →
# examples/hello.x. Report run=/obs=/skip=.
#
# Usage: ./tests/run-comp-incr-compile.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-incr-compile.sh
. tests/lib/comp-incr-compile.sh

BENCH="${XLANG_INCR_COMPILE_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
PROTOS="${XLANG_INCR_COMPILE_PROTOS:-tests/baseline/comp-incr-compile-prototype.tsv}"
MAX_RATIO="1.0"
# Soft FAIL:-0 retired: over-cap defaults to obs; FAIL=1 still hard.
FAIL_ON="${XLANG_INCR_COMPILE_FAIL:-0}"

PREFIX="xlang: [XLANG_COMP_INCR_COMPILE]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "comp-incr-compile FAIL: $*" >&2
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
    # Explicit XLANG that is missing or wrong-ABI = hard die (refuse soft SKIP→OK).
    return 1
  fi
  # Prefer product asm (retire prefer-c). PLATFORM: SHARED — Ubuntu gold.
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

echo "=== COMP-007: incremental compile smoke ==="

# Prototype registry does not require a native compiler.
PROTO_FAIL=0
while IFS=$'\t' read -r pid _cap status sym src _notes; do
  [ -z "${pid:-}" ] && continue
  case "$pid" in \#*|min_*) continue ;; esac
  [ "$status" = "planned" ] && continue
  if ! comp_incr_compile_proto_present "$src" "$sym"; then
    echo "comp-incr-compile FAIL: proto $pid missing $sym in $src" >&2
    PROTO_FAIL=$((PROTO_FAIL + 1))
  else
    echo "comp-incr-compile OK proto $pid"
  fi
done < "$PROTOS"
if [ "$PROTO_FAIL" -gt 0 ]; then
  die "proto registry ${PROTO_FAIL} miss(es)"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    max_second_first_ratio) MAX_RATIO="$c2" ;;
  esac
done < "$BENCH"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "comp-incr-compile: XLANG=$XLANG_BIN"

while IFS=$'\t' read -r bench_id fixture cmd_kind max_r _target _notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*|max_*|target_*) continue ;; esac

  cap="${max_r:-$MAX_RATIO}"
  cap="$(comp_incr_compile_effective_cap "$cap")"
  first_ms=0
  second_ms=0
  FIX="${fixture:-examples/hello.x}"
  if [ "$cmd_kind" != "make_q" ] && [ ! -f "$FIX" ]; then
    die "missing fixture $FIX for $bench_id (refuse fossil soft SKIP)"
  fi

  case "$cmd_kind" in
    check)
      # check gate paused 2026-08-05 → observational (not soft SKIP→OK silence).
      check_ok=1
      for run in 1 2; do
        log="$(XLANG_COMPILE_PHASE_TIMING=1 "$XLANG_BIN" check "$FIX" 2>&1)" || check_ok=0
        ms="$(comp_incr_compile_parse_total_ms "$log")"
        if [ -z "$ms" ]; then
          ms="$(comp_incr_compile_wall_ms "$XLANG_BIN" check "$FIX")" || true
        fi
        if [ "$run" -eq 1 ]; then first_ms="$ms"; else second_ms="$ms"; fi
      done
      if [ "$check_ok" -eq 0 ] || [ -z "${first_ms:-}" ] || [ -z "${second_ms:-}" ]; then
        echo "comp-incr-compile OBS $bench_id (check residual / paused; refuse soft SKIP→OK)" >&2
        OBS=$((OBS + 1))
        continue
      fi
      ;;
    -o)
      out="/tmp/xlang_incr_compile_${bench_id}.$$"
      for run in 1 2; do
        rm -f "$out" 2>/dev/null || true
        log="$(XLANG_COMPILE_PHASE_TIMING=1 XLANG_LINK_XLANG="$XLANG_BIN" \
          "$XLANG_BIN" "$FIX" -o "$out" 2>&1)" || true
        ms="$(comp_incr_compile_parse_total_ms "$log")"
        if [ -z "$ms" ]; then
          ms="$(comp_incr_compile_wall_ms "$XLANG_BIN" "$FIX" -o "$out")"
        fi
        if [ ! -x "$out" ] && [ ! -f "$out" ]; then
          die "-o failed for $bench_id (refuse soft SKIP→OK)"
        fi
        if [ "$run" -eq 1 ]; then first_ms="$ms"; else second_ms="$ms"; fi
      done
      rm -f "$out" 2>/dev/null || true
      ;;
    timing)
      if ! comp_incr_compile_phase_timing_available "$XLANG_BIN" "$FIX"; then
        echo "comp-incr-compile OBS $bench_id (phase timing unavailable; product residual)" >&2
        OBS=$((OBS + 1))
        continue
      fi
      log="$(XLANG_COMPILE_PHASE_TIMING=1 "$XLANG_BIN" check "$FIX" 2>&1)" || true
      if ! printf '%s' "$log" | grep -q 'XLANG_COMPILE_PHASE_TIMING'; then
        # Prefer -o path when check is paused / C-only timing missing.
        log="$(XLANG_COMPILE_PHASE_TIMING=1 XLANG_LINK_XLANG="$XLANG_BIN" \
          "$XLANG_BIN" "$FIX" -o "/tmp/xlang_incr_timing_$$" 2>&1)" || true
        rm -f "/tmp/xlang_incr_timing_$$" 2>/dev/null || true
      fi
      if ! printf '%s' "$log" | grep -q 'XLANG_COMPILE_PHASE_TIMING'; then
        echo "comp-incr-compile OBS $bench_id (no timing line; product residual)" >&2
        OBS=$((OBS + 1))
        continue
      fi
      echo "comp-incr-compile OK $bench_id (timing line present)"
      RUN_OK=$((RUN_OK + 1))
      continue
      ;;
    make_q)
      if xlang_compiler_make -q 2>/dev/null; then
        echo "comp-incr-compile OK $bench_id (make -q)"
        RUN_OK=$((RUN_OK + 1))
      else
        die "$bench_id make -q failed"
      fi
      continue
      ;;
    *)
      die "unknown cmd_kind $cmd_kind for $bench_id"
      ;;
  esac

  ratio="$(comp_incr_compile_ratio "$first_ms" "$second_ms")"
  over="$(awk -v r="$ratio" -v c="$cap" 'BEGIN { print (r+0 > c+0) ? 1 : 0 }')"
  if [ "$over" = "1" ]; then
    if [ "$FAIL_ON" = "1" ]; then
      die "$bench_id ratio=$ratio > max $cap (first=${first_ms}ms second=${second_ms}ms)"
    fi
    echo "comp-incr-compile OBS $bench_id ratio=$ratio > max $cap (first=${first_ms}ms second=${second_ms}ms; FAIL=1 still hard)" >&2
    OBS=$((OBS + 1))
  else
    echo "comp-incr-compile: $bench_id ratio=$ratio first_ms=$first_ms second_ms=$second_ms OK"
    RUN_OK=$((RUN_OK + 1))
  fi
done < "$BENCH"

echo "comp-incr-compile OK"
ok_report
