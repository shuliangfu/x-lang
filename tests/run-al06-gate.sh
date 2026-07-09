#!/usr/bin/env bash
# MEM-C1 AL-06：slice + Allocator 双重逃逸 + AL-04 赋值逃逸 typeck 负例。
set -e
cd "$(dirname "$0")/.."

# Prefer SHUX; fall back to existing binaries — never force cold make (OOM/hang risk).
SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ] || [ ! -x "$SHUX_BIN" ]; then
  for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux-c; do
    if [ -x "$cand" ]; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi
if [ -z "$SHUX_BIN" ] || [ ! -x "$SHUX_BIN" ]; then
  echo "al06-gate SKIP: no shux binary (set SHUX=...)" >&2
  exit 0
fi
SHUX="$SHUX_BIN"
echo "al06-gate: SHUX=$SHUX"

# Soft wall-clock per check (seconds)
AL06_TIMEOUT="${SHUX_AL06_TIMEOUT:-30}"

run_check() {
  local src="$1"
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=5 "$AL06_TIMEOUT" "$SHUX" check "$src" 2>&1 || true
  else
    # portable soft timeout via perl
    perl -e "alarm $AL06_TIMEOUT; exec @ARGV" "$SHUX" check "$src" 2>&1 || true
  fi
}

check_neg() {
  local src="$1"
  local msg="$2"
  local out
  out="$(run_check "$src")"
  if ! echo "$out" | grep -qF "$msg"; then
    echo "al06-gate FAIL: $src expected '$msg'" >&2
    echo "$out" >&2
    exit 1
  fi
  echo "al06-gate OK $src -> $msg"
}

check_neg tests/typeck/allocator_assign_escape.x "allocator region escape"
check_neg tests/typeck/dual_escape_with_arena_region.x "slice region escape"
echo "al06-gate OK (AL-04 assign + AL-06 dual escape)"
