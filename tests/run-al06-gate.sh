#!/usr/bin/env bash
# MEM-C1 AL-06：slice + Allocator 双重逃逸 + AL-04 赋值逃逸 typeck 负例。
set -e
cd "$(dirname "$0")/.."

# Prefer XLANG; fall back to existing binaries — never force cold make (OOM/hang risk).
XLANG_BIN="${XLANG:-}"
if [ -z "$XLANG_BIN" ] || [ ! -x "$XLANG_BIN" ]; then
  for cand in ./compiler/xlang ./compiler/xlang_asm ./compiler/xlang-c; do
    if [ -x "$cand" ]; then
      XLANG_BIN="$cand"
      break
    fi
  done
fi
if [ -z "$XLANG_BIN" ] || [ ! -x "$XLANG_BIN" ]; then
  echo "al06-gate SKIP: no xlang binary (set XLANG=...)" >&2
  exit 0
fi
XLANG="$XLANG_BIN"
echo "al06-gate: XLANG=$XLANG"

# Soft wall-clock per check (seconds)
AL06_TIMEOUT="${XLANG_AL06_TIMEOUT:-30}"

run_check() {
  local src="$1"
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=5 "$AL06_TIMEOUT" "$XLANG" check "$src" 2>&1 || true
  else
    # portable soft timeout via perl
    perl -e "alarm $AL06_TIMEOUT; exec @ARGV" "$XLANG" check "$src" 2>&1 || true
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
