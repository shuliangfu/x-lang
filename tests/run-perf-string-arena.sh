#!/usr/bin/env bash
# ZC-4 perf：arena concat 链式 bench；仅 Arena64 chunk 分配，无 per-concat heap_alloc。
# 用法：
#   ./tests/run-perf-string-arena.sh
#   SHUX=./compiler/shux_asm ./tests/run-perf-string-arena.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. "$(dirname "$0")/lib/perf-alloc-hotspot.sh"

# 与 run-zc4-gate.sh 一致：默认 shux-c；SHUX=shux_asm 时仍用 shux-c 链 import std（co-emit 待补）
SHUX_BIN="${SHUX:-}"
str_arena_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
str_arena_pick_shu() {
  local cand abs
  for cand in "$@"; do
    [ -n "$cand" ] || continue
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if str_arena_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}
if [ -z "$SHUX_BIN" ]; then
  SHUX_BIN="$(str_arena_pick_shu ./compiler/shux-c ./compiler/shux ./compiler/shux_asm)" || SHUX_BIN="./compiler/shux_asm"
else
  case "$SHUX_BIN" in /*) ;; *) SHUX_BIN="$(pwd)/$SHUX_BIN" ;; esac
  if str_arena_native_exe "$SHUX_BIN" && echo "$SHUX_BIN" | grep -q 'shux_asm' \
    && [ -z "${SHUX_ZC4_FORCE_COMPILE_ASM:-}" ]; then
    alt="$(str_arena_pick_shu ./compiler/shux-c ./compiler/shux)" || true
    if [ -n "$alt" ]; then
      echo "string-arena: compile via $(basename "$alt") (shux_asm import std link pending)"
      SHUX_BIN="$alt"
    fi
  fi
fi
BENCH_SRC="tests/bench/string_arena_concat.x"
BENCH_EXE="/tmp/shux_string_arena_bench"
EXPECT_N="${SHUX_STRING_BENCH_N:-128}"

echo "=== ZC-4 string arena concat bench: ${BENCH_SRC} (expect exit=${EXPECT_N}) ==="

if ! str_arena_native_exe "$SHUX_BIN"; then
  echo "string-arena perf SKIP: ${SHUX_BIN} not native (rebuild shux_asm on Linux/Mac)"
  exit 0
fi

# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/string/string.o
# F-03 v2：heap 已纯 .x，不再 ensure heap.o

rm -f "$BENCH_EXE"

if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -L . "$BENCH_SRC" -o "$BENCH_EXE"; then
  echo "string-arena perf FAIL: compile $BENCH_SRC" >&2
  exit 1
fi

RC=0
"$BENCH_EXE" >/dev/null 2>&1 || RC=$?
echo "string_arena_concat exit=${RC} (expect ${EXPECT_N})"
if [ "$RC" != "$EXPECT_N" ]; then
  echo "string-arena perf FAIL: correctness" >&2
  exit 1
fi

# Linux 可选：strace 确认无 malloc（仅 arena init 的 posix_memalign）+ PERF-007 emit
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
      echo "string-arena perf WARN: strace heap alloc exceeds cap (malloc=${perf_ah_malloc} calloc=${perf_ah_calloc} realloc=${perf_ah_realloc})" >&2
    fi
  fi
fi

echo "string-arena perf OK"
