#!/usr/bin/env bash
# ZC-4 perf：arena concat 链式 bench；仅 Arena64 chunk 分配，无 per-concat heap_alloc。
# 用法：
#   ./tests/run-perf-string-arena.sh
#   SHU=./compiler/shu_asm ./tests/run-perf-string-arena.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. "$(dirname "$0")/lib/perf-alloc-hotspot.sh"

# 与 run-zc4-gate.sh 一致：默认 shu-c；SHU=shu_asm 时仍用 shu-c 链 import std（co-emit 待补）
SHU_BIN="${SHU:-}"
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
if [ -z "$SHU_BIN" ]; then
  SHU_BIN="$(str_arena_pick_shu ./compiler/shu-c ./compiler/shu ./compiler/shu_asm)" || SHU_BIN="./compiler/shu_asm"
else
  case "$SHU_BIN" in /*) ;; *) SHU_BIN="$(pwd)/$SHU_BIN" ;; esac
  if str_arena_native_exe "$SHU_BIN" && echo "$SHU_BIN" | grep -q 'shu_asm' \
    && [ -z "${SHU_ZC4_FORCE_COMPILE_ASM:-}" ]; then
    alt="$(str_arena_pick_shu ./compiler/shu-c ./compiler/shu)" || true
    if [ -n "$alt" ]; then
      echo "string-arena: compile via $(basename "$alt") (shu_asm import std link pending)"
      SHU_BIN="$alt"
    fi
  fi
fi
BENCH_SRC="tests/bench/string_arena_concat.su"
BENCH_EXE="/tmp/shu_string_arena_bench"
EXPECT_N="${SHU_STRING_BENCH_N:-128}"

echo "=== ZC-4 string arena concat bench: ${BENCH_SRC} (expect exit=${EXPECT_N}) ==="

if ! str_arena_native_exe "$SHU_BIN"; then
  echo "string-arena perf SKIP: ${SHU_BIN} not native (rebuild shu_asm on Linux/Mac)"
  exit 0
fi

# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
ensure_std_c_o ../std/string/string.o
ensure_std_c_o ../std/heap/heap.o

rm -f "$BENCH_EXE"

if ! SHU="$SHU_BIN" "$SHU_BIN" -L . "$BENCH_SRC" -o "$BENCH_EXE"; then
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
