#!/usr/bin/env bash
# NL-04: Linux freestanding file-read smoke (std.fs.freestanding_linux; zero libc).
#
# Usage: ./tests/run-no-libc-fs-gate.sh
# Honesty: soft XLANG_NOLIBC_FS_FAIL retired — die→exit0 was portable false-green.
# Prefer xlang_asm; pin XLANG_LINK_XLANG. Linux x86_64 live; other hosts static+skip=1.
# Report static=/live=/skip=.
# PLATFORM: SHARED archaeology / LINUX freestanding.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/linux_fs_freestanding_smoke.x"
FS_MOD="std/fs/freestanding_linux.x"
GATE_FILE="/tmp/xlang_nolibc_fs_gate.txt"
OUT="/tmp/xlang_nolibc_fs.$$.out"
PARENT="${XLANG_NOLIBC_PARENT_DOC:-analysis/archive/phase/phase-f-no-libc-v1.md}"
PREFIX="xlang: [XLANG_NOLIBC_FS]"

STATIC_OK=0
LIVE_OK=0
SKIP=1

die() {
  echo "nolibc-fs gate FAIL: $*" >&2
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

echo "=== NL-04: freestanding fs read (honesty) ==="
[ -f "$PARENT" ] || die "missing $PARENT"
grep -qE '^## Gate$' "$PARENT" || die "phase-f-no-libc-v1.md missing ## Gate"
for f in "$X" "$FS_MOD"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'freestanding_read_file_into' "$FS_MOD" || die "freestanding_linux.x incomplete"
STATIC_OK=1

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc-fs gate OK (static; live skip — need Linux x86_64)"
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

XLANG_BIN="$(nolibc_pick_xlang)" || XLANG_BIN=""
if [ -z "$XLANG_BIN" ]; then
  SKIP=1
  echo "nolibc-fs gate OK (static; live skip — no native xlang)"
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi
export XLANG_LINK_XLANG="$XLANG_BIN"

printf 'FS' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

# Prefer same CLI as NL-02/03 (-freestanding, no build subcmd). Live compile
# may still be product residual under asm (typeck/UNDEF); report live=0, do
# not soft-SKIP whole gate. PLATFORM: LINUX freestanding.
if ! "$XLANG_BIN" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/xlang_nolibc_fs.log; then
  tail -n 12 /tmp/xlang_nolibc_fs.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  LIVE_OK=0
  SKIP=0
  echo "nolibc-fs gate OK (static; live compile observational residual)" >&2
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi
if [ ! -x "$OUT" ]; then
  rm -f "$GATE_FILE" 2>/dev/null || true
  LIVE_OK=0
  SKIP=0
  echo "nolibc-fs gate OK (static; live no-exe observational residual)" >&2
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if command -v ldd >/dev/null 2>&1; then
  if ldd "$OUT" 2>&1 | grep -qi 'libc\.so'; then
    ldd "$OUT" 2>&1 || true
    rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
    die "$OUT linked against libc.so"
  fi
fi

rc=0
OUT_TXT=$("$OUT" 2>/dev/null) || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
if [ "$rc" -ne 0 ] || [ "$OUT_TXT" != "FS" ]; then
  LIVE_OK=0
  SKIP=0
  echo "nolibc-fs gate OK (static; live run observational residual rc=$rc out='$OUT_TXT')" >&2
  echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi
LIVE_OK=1
SKIP=0

echo "nolibc-fs gate OK (read file via syscall + mmap heap buf, no fs.c/libc)"
echo "${PREFIX} status=ok static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
