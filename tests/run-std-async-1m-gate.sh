#!/usr/bin/env bash
# STD-004：async 1M task 压测门禁（无崩溃 + 计数正确 exit 0）
#
# 读取 tests/baseline/std-async-1m.tsv，按平台 must/skip 跑 1M ping-pong。
# 用法：./tests/run-std-async-1m-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

MATRIX="${SHU_STD_ASYNC_1M_TSV:-tests/baseline/std-async-1m.tsv}"

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
}

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

async_is_linux_x64_asm() {
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Linux-x86_64|Linux-amd64) return 0 ;;
  esac
  return 1
}

if [ ! -f "$MATRIX" ]; then
  echo "std-async-1m gate FAIL: missing $MATRIX" >&2
  exit 1
fi

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "std-async-1m gate SKIP (no native shu; host=$(ci_host_summary))" >&2
  exit 0
fi

# 编译 bench：Linux x86_64 可用 asm；其它平台 shu-c/-backend c。
async_compile_bench() {
  local su="$1"
  local out="$2"
  rm -f "$out"
  if async_is_linux_x64_asm && [[ "$su" == *sched* ]]; then
    if ! "$SHU_BIN" -L . "$su" -backend asm -o "$out" >/tmp/async_1m_compile.log 2>&1; then
      cat /tmp/async_1m_compile.log >&2
      return 1
    fi
    return 0
  fi
  if async_is_linux_x64_asm; then
    "$SHU_BIN" -L . "$su" -o "$out"
  elif [ -x ./compiler/shu-c ]; then
    ./compiler/shu-c -L . "$su" -o "$out"
  elif [ -x ./compiler/shu ]; then
    ./compiler/shu -L . "$su" -backend c -o "$out"
  else
    "$SHU_BIN" -L . "$su" -o "$out"
  fi
}

echo "=== STD-004: async 1M stress ($(ci_host_summary) SHU=$SHU_BIN) ==="

FAILS=0
while IFS=$'\t' read -r case_id script linux pol_mac pol_win want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  if [ "$pol" = "skip" ]; then
    echo "async 1M SKIP $case_id ($notes)"
    continue
  fi
  src="tests/bench/${script}"
  if [ ! -f "$src" ]; then
    echo "async 1M FAIL $case_id: missing $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  out="/tmp/shu_async_1m_${case_id}"
  echo "── case $case_id: $src ──"
  if ! async_compile_bench "$src" "$out"; then
    echo "async 1M FAIL $case_id: compile" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "${want_ec:-0}" ]; then
    echo "async 1M FAIL $case_id: exit=$ec want=${want_ec:-0}" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "async 1M OK $case_id (exit=$ec)"
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  echo "std-async-1m gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "std-async-1m gate OK"
