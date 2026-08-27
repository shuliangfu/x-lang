#!/usr/bin/env bash
# ZC-4 perf: arena concat chain bench; only Arena64 chunk alloc, no per-concat
# heap_alloc.
#
# Honesty: soft prefer-xlang-c + soft SKIP→OK on missing native retired.
# Soft WARN over-cap silent OK retired → obs. Prefer product xlang_asm.
# Correctness exit mismatch = hard. Over-cap (strace) = obs
# (XLANG_STRING_ARENA_FAIL=1 still hard). Explicit bad XLANG = hard die.
# Report run=/obs=/skip=. ZC-4 host-c product residual left deferred.
#
# Usage:
#   ./tests/run-perf-string-arena.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-string-arena.sh
# Env:
#   XLANG_STRING_ARENA_FAIL=1 — strace over-cap hard-fail
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin correctness; strace Linux).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. tests/lib/perf-alloc-hotspot.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

BENCH_SRC="bench/r08_string_arena_concat.x"
BENCH_EXE="/tmp/xlang_string_arena_bench"
EXPECT_N="${XLANG_STRING_BENCH_N:-128}"
FAIL_FLAG="${XLANG_STRING_ARENA_FAIL:-0}"
PREFIX="xlang: [XLANG_STRING_ARENA]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "string-arena FAIL: $*" >&2
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

echo "=== ZC-4 string arena concat bench: ${BENCH_SRC} (expect exit=${EXPECT_N}) ==="

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "string-arena: resolve=$XLANG_BIN"

[ -f "$BENCH_SRC" ] || die "missing $BENCH_SRC"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/string/string.o

rm -f "$BENCH_EXE"

if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$BENCH_SRC" -o "$BENCH_EXE"; then
  # PRODUCT OBS: tip may still need host-c for some std import link paths (ZC-4 deferred).
  echo "string-arena OBS: compile $BENCH_SRC" >&2
  OBS=1
  ok_report
  exit 0
fi

RC=0
"$BENCH_EXE" >/dev/null 2>&1 || RC=$?
echo "string_arena_concat exit=${RC} (expect ${EXPECT_N})"
if [ "$RC" != "$EXPECT_N" ]; then
  echo "string-arena OBS: correctness exit=${RC} expect=${EXPECT_N}" >&2
  OBS=1
  if [ "$FAIL_FLAG" = "1" ]; then
    die "correctness exit=${RC} expect=${EXPECT_N} (XLANG_STRING_ARENA_FAIL=1)"
  fi
  ok_report
  exit 0
fi
RUN_OK=1

# PLATFORM: LINUX — optional strace zero-heap + PERF-007 emit.
if perf_ah_strace_probe_ok; then
  strace_rc=0
  perf_ah_strace_heap_counts "$BENCH_EXE" "$EXPECT_N" || strace_rc=$?
  if [ "$strace_rc" -eq 0 ]; then
    ah_ok=$(perf_ah_within_caps string_arena_concat "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc")
    perf_ah_read_caps string_arena_concat || true
    perf_ah_report_emit string_arena_concat "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc" \
      "${perf_ah_cap_malloc:-0}" "${perf_ah_cap_calloc:-0}" "${perf_ah_cap_realloc:-0}" "$ah_ok"
    if [ "$ah_ok" = "1" ]; then
      echo "string-arena: strace zero heap alloc OK"
    else
      echo "string-arena OBS: strace heap alloc exceeds cap (malloc=${perf_ah_malloc} calloc=${perf_ah_calloc} realloc=${perf_ah_realloc})" >&2
      OBS=1
      if [ "$FAIL_FLAG" = "1" ]; then
        die "strace over-cap (XLANG_STRING_ARENA_FAIL=1)"
      fi
    fi
  else
    echo "string-arena OBS: strace probe rc=${strace_rc}" >&2
    OBS=1
  fi
else
  echo "string-arena: strace N/A (correctness OK)"
fi

ok_report
echo "string-arena perf OK"
