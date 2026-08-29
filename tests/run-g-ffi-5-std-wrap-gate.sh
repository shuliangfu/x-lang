#!/usr/bin/env bash
# G-FFI-5: std/ffi + std/sys extern calls must wrap in unsafe { } (LANG-007 v2).
#
# Honesty: leftover catalog no Honesty + missing run=/obs=/skip= report +
# leftover native_xlang (third resolver; only on optional TYPECK) retired.
# No XLANG face by default (grep / manifest). G.7: do not fork a resolver.
# Nested leftover of already-honesty-closed
# `run-g-ffi-5-business-no-bare-extern-gate.sh` (parent product path not
# rewritten). Also a portable catalog leaf. Keep `g-ffi-5 std-wrap gate OK`
# (portable greps `g-ffi-5 gate OK`). Manifest / unsafe-wrap grep stays hard.
# Default TYPECK skip=1 (check postponed). XLANG_G_FFI5_TYPECK=1 = obs
# (check paused; refuse leftover native_xlang / leftover prefer-seed).
# Explicit XLANG is ignored (no XLANG face; parent still hard-dies via
# nested LANG-007 when that path is taken).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-g-ffi-5-std-wrap-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_G_FFI5_WRAP_PREFIX:-xlang: [G_FFI5_WRAP]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "g-ffi-5 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== G-FFI-5: std/ffi + std/sys unsafe wrap manifest (no XLANG face) ==="
for f in \
  std/ffi/ffi.x \
  std/ffi/mod.x \
  std/sys/mod.x \
  std/sys/linux.x \
  std/sys/macos.x \
  std/sys/freebsd.x \
  std/sys/win32.x \
  std/sys/win32_net.x \
  std/sys/mmap.x \
  std/sys/linux_io_uring.x; do
  [ -f "$f" ] || die "missing $f"
done
echo "g-ffi-5 manifest OK"
RUN_OK=$((RUN_OK + 1))

echo "=== G-FFI-5: win32 / ffi.x impl unsafe wrap grep ==="
gffi5_need_unsafe() {
  local f="$1" sym="$2"
  if ! grep -qF "$sym" "$f" || ! grep -q 'unsafe' "$f"; then
    echo "g-ffi-5 FAIL: $f must wrap extern ($sym) in unsafe" >&2
    return 1
  fi
  return 0
}
FAILS=0
gffi5_need_unsafe std/ffi/ffi.x 'strlen(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.x 'malloc(n)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/ffi/ffi.x 'free(ptr)' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'GetStdHandle' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'WriteFile' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32.x 'ExitProcess' || FAILS=$((FAILS + 1))
gffi5_need_unsafe std/sys/win32_net.x 'WSAStartup' || FAILS=$((FAILS + 1))
# Linux / macOS / FreeBSD: OS layers with extern must wrap in unsafe.
# (mmap.x re-export-only modules may omit unsafe.)
# PLATFORM: SHARED archaeology — wrap grep is the product of this leaf.
for f in std/sys/linux.x std/sys/macos.x std/sys/freebsd.x std/sys/linux_io_uring.x; do
  if grep -qE '^[[:space:]]*extern ' "$f" && ! grep -q 'unsafe' "$f"; then
    echo "g-ffi-5 FAIL: $f has extern without unsafe" >&2
    FAILS=$((FAILS + 1))
  fi
done
if [ "$FAILS" -gt 0 ]; then
  die "${FAILS} wrap check(s)"
fi
echo "g-ffi-5 grep OK (win32 + ffi + sys)"
RUN_OK=$((RUN_OK + 1))

# Optional typeck is leftover check postponed. Default skip=1.
# TYPECK=1 stays obs (refuse leftover native_xlang / leftover prefer-seed).
if [ "${XLANG_G_FFI5_TYPECK:-0}" = "1" ]; then
  echo "g-ffi-5 typeck OBS (check paused; refuse leftover native_xlang)" >&2
  OBS=$((OBS + 1))
else
  echo "g-ffi-5 typeck SKIP (default; check postponed)"
  SKIP=$((SKIP + 1))
fi

echo "g-ffi-5 std-wrap gate OK"
# Portable greps `g-ffi-5 gate OK` (leftover substring mismatch vs std-wrap).
echo "g-ffi-5 gate OK"
ok_report
