#!/usr/bin/env bash
# B-31: freestanding_io_x86_64.s thin .s registration + Linux freestanding hello.
#
# Honesty: soft XLANG_B31_FAIL retired — Linux freestanding hello failure was
# portable false-green (soft die→exit0). Missing ASM/DOC/hello script is hard
# die. Linux x86_64 freestanding hello is hard green. Non-Linux stays N/A
# (static .s + DOC only; smoke skip=1).
#
# Usage: ./tests/run-b31-freestanding-io-gate.sh
# Report: run=/skip=
# PLATFORM: SHARED archaeology; LINUX|UBUNTU freestanding smoke gold.
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when
# archived; live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

ASM="compiler/src/asm/freestanding_io_x86_64.s"
DOC="${XLANG_B_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"
HELLO="tests/run-freestanding-hello.sh"
PREFIX="xlang: [XLANG_B31]"
RUN_OK=0
SKIP=1

die() {
  echo "b31 freestanding-io-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== B-31: freestanding_io .s baseline ==="
for f in "$ASM" "$HELLO" "$DOC"; do
  [ -f "$f" ] || die "missing $f"
done
# Refuse top-level DOC / Makefile resurrect (MG archaeology).
# PLATFORM: SHARED — archive DOC is the gate authority.
[ ! -f analysis/phase-b-completion-v1.md ] || die "refuse top-level DOC resurrect analysis/phase-b-completion-v1.md"
[ ! -f compiler/Makefile ] || die "refuse compiler/Makefile resurrect (MG)"
grep -qE '^## Gate' "$DOC" || die "DOC missing ## Gate: $DOC"
grep -q 'xlang_sys_write' "$ASM" || die ".s missing xlang_sys_write"
grep -q 'xlang_sys_read' "$ASM" || die ".s missing xlang_sys_read"
SKIP=0

OS="$(uname -s 2>/dev/null || echo unknown)"
ARCH="$(uname -m 2>/dev/null || echo unknown)"
# PLATFORM: LINUX|UBUNTU — freestanding crt0 / io .s smoke is x86_64 Linux gold.
# PLATFORM: MACOS|DARWIN / other — static registration only; smoke N/A.
if [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
  chmod +x "$HELLO"
  if ! "$HELLO"; then
    die "freestanding hello smoke failed"
  fi
  RUN_OK=1
  echo "b31 freestanding-io-gate OK (Linux smoke run=1)"
else
  SKIP=1
  echo "b31 freestanding-io-gate OK (static .s+DOC; smoke N/A on ${OS}/${ARCH})"
fi

echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
