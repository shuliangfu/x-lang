#!/usr/bin/env bash
# COMP-007：增量编译二次编译烟测
#
# 用法：./tests/run-comp-incr-compile.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-incr-compile.sh
. tests/lib/comp-incr-compile.sh

BENCH="${SHUX_INCR_COMPILE_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
PROTOS="${SHUX_INCR_COMPILE_PROTOS:-tests/baseline/comp-incr-compile-prototype.tsv}"
MAX_RATIO="1.0"

SHUX_BIN=""
for cand in ./compiler/shux-c ./compiler/shux ./compiler/shux_asm; do
  if comp_incr_compile_native_shu "$cand"; then
    SHUX_BIN="$cand"
    break
  fi
done

echo "=== COMP-007: incremental compile smoke ==="

# 原型符号检查（不依赖 shux 可执行）。
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
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    max_second_first_ratio) MAX_RATIO="$c2" ;;
  esac
done < "$BENCH"

if [ -z "$SHUX_BIN" ]; then
  echo "comp-incr-compile SKIP bench (no native shux)"
  echo "comp-incr-compile OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

FAILS=0

while IFS=$'\t' read -r bench_id fixture cmd_kind max_r _target _notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*|max_*|target_*) continue ;; esac

  cap="${max_r:-$MAX_RATIO}"
  cap="$(comp_incr_compile_effective_cap "$cap")"
  first_ms=0
  second_ms=0
  FIX="${fixture:-tests/bench/loop_i32.sx}"
  if [ "$cmd_kind" != "make_q" ] && [ ! -f "$FIX" ]; then
    echo "comp-incr-compile SKIP $bench_id (no fixture $FIX)"
    continue
  fi

  case "$cmd_kind" in
    check)
      for run in 1 2; do
        log="$(SHUX_COMPILE_PHASE_TIMING=1 "$SHUX_BIN" check "$FIX" 2>&1)" || true
        ms="$(comp_incr_compile_parse_total_ms "$log")"
        if [ -z "$ms" ]; then
          ms="$(comp_incr_compile_wall_ms "$SHUX_BIN" check "$FIX")"
        fi
        if [ "$run" -eq 1 ]; then first_ms="$ms"; else second_ms="$ms"; fi
      done
      ;;
    -o)
      out="/tmp/shux_incr_compile_${bench_id}.$$"
      for run in 1 2; do
        rm -f "$out" 2>/dev/null || true
        log="$(SHUX_COMPILE_PHASE_TIMING=1 "$SHUX_BIN" "$FIX" -o "$out" 2>&1)" || true
        ms="$(comp_incr_compile_parse_total_ms "$log")"
        if [ -z "$ms" ]; then
          ms="$(comp_incr_compile_wall_ms "$SHUX_BIN" "$FIX" -o "$out")"
        fi
        if [ "$run" -eq 1 ]; then first_ms="$ms"; else second_ms="$ms"; fi
      done
      rm -f "$out" 2>/dev/null || true
      ;;
    timing)
      if ! comp_incr_compile_phase_timing_available "$SHUX_BIN" "$FIX"; then
        echo "comp-incr-compile SKIP $bench_id (phase timing unavailable; seed/C-only shux-c)"
        continue
      fi
      log="$(SHUX_COMPILE_PHASE_TIMING=1 "$SHUX_BIN" check "$FIX" 2>&1)" || true
      if ! printf '%s' "$log" | grep -q 'SHUX_COMPILE_PHASE_TIMING'; then
        echo "comp-incr-compile FAIL: $bench_id no timing line" >&2
        FAILS=$((FAILS + 1))
        continue
      fi
      echo "comp-incr-compile OK $bench_id (timing line present)"
      continue
      ;;
    make_q)
      if make -C compiler -q 2>/dev/null; then
        echo "comp-incr-compile OK $bench_id (make -q)"
      else
        echo "comp-incr-compile FAIL: $bench_id make -q" >&2
        FAILS=$((FAILS + 1))
      fi
      continue
      ;;
    *)
      echo "comp-incr-compile SKIP $bench_id unknown cmd $cmd_kind"
      continue
      ;;
  esac

  ratio="$(comp_incr_compile_ratio "$first_ms" "$second_ms")"
  over="$(awk -v r="$ratio" -v c="$cap" 'BEGIN { print (r+0 > c+0) ? 1 : 0 }')"
  if [ "$over" = "1" ]; then
    echo "comp-incr-compile FAIL: $bench_id ratio=$ratio > max $cap (first=${first_ms}ms second=${second_ms}ms)" >&2
    FAILS=$((FAILS + 1))
  else
    echo "comp-incr-compile: $bench_id ratio=$ratio first_ms=$first_ms second_ms=$second_ms OK"
  fi
done < "$BENCH"

if [ "$FAILS" -gt 0 ]; then
  echo "comp-incr-compile FAIL: ${FAILS} bench(es)" >&2
  exit 1
fi
echo "comp-incr-compile OK"
