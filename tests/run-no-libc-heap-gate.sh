#!/usr/bin/env bash
# NL-03: Linux freestanding mmap bump heap smoke (zero libc / no heap.c malloc).
#
# Usage: ./tests/run-no-libc-heap-gate.sh
# Honesty: soft XLANG_NOLIBC_HEAP_FAIL retired — die→exit0 was portable false-green.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Linux x86_64 live; other hosts static+skip=1.
# Report static=/live=/skip=.
# PLATFORM: SHARED archaeology / LINUX freestanding.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/linux_heap_mmap_smoke.x"
OUT="/tmp/xlang_nolibc_heap.$$.out"
PAGE_MMAP="std/heap/page_mmap.x"
PARENT="${XLANG_NOLIBC_PARENT_DOC:-analysis/archive/phase/phase-f-no-libc-v1.md}"
PREFIX="xlang: [XLANG_NOLIBC_HEAP]"

STATIC_OK=0
LIVE_OK=0
SKIP=1

die() {
  echo "nolibc-heap gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

nolibc_pick_xlang() {
  local cand abs
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in /*) abs="$XLANG" ;; *) abs="$(pwd)/$XLANG" ;; esac
    if [ -x "$abs" ]; then echo "$abs"; return 0; fi
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if [ -x "$abs" ]; then echo "$abs"; return 0; fi
  done
  return 1
}

echo "=== NL-03: freestanding mmap heap (honesty) ==="
[ -f "$PARENT" ] || die "missing $PARENT"
grep -qE '^## Gate$' "$PARENT" || die "phase-f-no-libc-v1.md missing ## Gate"
[ -f "$X" ] || die "missing $X"
[ -f "$PAGE_MMAP" ] || die "missing $PAGE_MMAP"
grep -q 'page_mmap_heap_init' "$PAGE_MMAP" || die "page_mmap.x missing init"
STATIC_OK=1

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc-heap gate OK (static; live skip — need Linux x86_64)"
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

XLANG_BIN="$(nolibc_pick_xlang)" || XLANG_BIN=""
if [ -z "$XLANG_BIN" ]; then
  SKIP=1
  echo "nolibc-heap gate OK (static; live skip — no native xlang)"
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi
export XLANG_LINK_XLANG="$XLANG_BIN"

rm -f "$OUT" 2>/dev/null || true
if ! "$XLANG_BIN" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/xlang_nolibc_heap.log; then
  tail -n 12 /tmp/xlang_nolibc_heap.log 2>/dev/null || true
  die "compile $X failed"
fi
[ -x "$OUT" ] || die "no executable $OUT"

if command -v ldd >/dev/null 2>&1; then
  if ldd "$OUT" 2>&1 | grep -qi 'libc\.so'; then
    ldd "$OUT" 2>&1 || true
    die "$OUT linked against libc.so"
  fi
fi

rc=0
OUT_TXT=$("$OUT" 2>/dev/null) || rc=$?
rm -f "$OUT" 2>/dev/null || true
if [ "$rc" -ne 0 ]; then
  die "expected exit 0, got $rc"
fi
if [ "$OUT_TXT" != "ABC" ]; then
  die "stdout expected ABC, got '$OUT_TXT'"
fi
LIVE_OK=1
SKIP=0

echo "nolibc-heap gate OK (mmap bump alloc + write, no libc.so)"
echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
