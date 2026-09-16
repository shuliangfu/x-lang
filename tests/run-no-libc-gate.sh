#!/usr/bin/env bash
# F-no-libc aggregate: NL-01 prep + NL-06/07 track + NL-02～05 Linux runtime.
#
# Usage: ./tests/run-no-libc-gate.sh
#        XLANG_NOLIBC_MANIFEST_ONLY=1 ./tests/run-no-libc-gate.sh
# Honesty: soft XLANG_NOLIBC_FAIL (+ child FAIL knobs) retired — die→exit0 was
# portable false-green after MG (e.g. n07-v2 missing Makefile). Children are
# hard-delegated; prefer asm via child pickers. Report n01=/n06=/n07=/rt=/skip=.
# PLATFORM: SHARED archaeology / LINUX freestanding.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

N01_GATE="tests/run-nolibc-n01-preparation-gate.sh"
FREESTANDING_HELLO="tests/run-freestanding-hello.sh"
PARENT="${XLANG_NOLIBC_PARENT_DOC:-analysis/archive/phase/phase-f-no-libc-v1.md}"
PREFIX="xlang: [XLANG_NOLIBC]"

N01_OK=0
N06_OK=0
N07_OK=0
RT_OK=0
SKIP=1

die() {
  echo "nolibc gate FAIL: $*" >&2
  echo "${PREFIX} status=fail n01=${N01_OK} n06=${N06_OK} n07=${N07_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

run_sub() {
  local script="$1"
  chmod +x "$script"
  if ! "$script"; then
    die "sub-gate failed: $script"
  fi
}

echo "=== F-no-libc: aggregate gate (honesty) ==="
if [ -f analysis/phase-f-no-libc-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f "$PARENT" ] || die "missing $PARENT"
grep -qE '^## Gate$' "$PARENT" || die "phase-f-no-libc-v1.md missing ## Gate honesty section"

echo "=== NL-01: delegate run-nolibc-n01-preparation-gate ==="
chmod +x "$N01_GATE" tests/lib/nolibc-n01-manifest.sh tests/lib/no-libc-link-audit.sh
# Hard-delegate; do not re-export retired soft FAIL knobs.
./tests/run-nolibc-n01-preparation-gate.sh || die "NL-01 preparation failed"
N01_OK=1

if [ "${XLANG_NOLIBC_MANIFEST_ONLY:-0}" = "1" ] || [ "${XLANG_NOLIBC_N01_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc gate OK (NL-01 manifest only)"
  echo "${PREFIX} status=ok n01=${N01_OK} n06=${N06_OK} n07=${N07_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== NL-06: delegate run-nolibc-n06-std-track-gate ==="
chmod +x tests/run-nolibc-n06-std-track-gate.sh tests/lib/nolibc-n06-std-track.sh
run_sub tests/run-nolibc-n06-std-track-gate.sh
N06_OK=1

echo "=== NL-07: delegate run-nolibc-n07-bootstrap-prep-gate ==="
chmod +x tests/run-nolibc-n07-bootstrap-prep-gate.sh tests/lib/nolibc-n07-bootstrap-audit.sh
run_sub tests/run-nolibc-n07-bootstrap-prep-gate.sh

echo "=== NL-07 v2: delegate run-nolibc-n07-v2-prep-gate ==="
chmod +x tests/run-nolibc-n07-v2-prep-gate.sh
run_sub tests/run-nolibc-n07-v2-prep-gate.sh

echo "=== NL-07 v3: delegate run-nolibc-n07-v3-link-gate ==="
chmod +x tests/run-nolibc-n07-v3-link-gate.sh tests/lib/nolibc-n07-link-smoke.sh
run_sub tests/run-nolibc-n07-v3-link-gate.sh

echo "=== NL-07 v4: delegate run-nolibc-n07-v4-build-gate ==="
chmod +x tests/run-nolibc-n07-v4-build-gate.sh
run_sub tests/run-nolibc-n07-v4-build-gate.sh

echo "=== NL-07 v5: delegate run-nolibc-n07-v5-gate ==="
chmod +x tests/run-nolibc-n07-v5-gate.sh
run_sub tests/run-nolibc-n07-v5-gate.sh
N07_OK=1

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc gate OK (NL-01 + NL-06 + NL-07 track; rt skip — need Linux x86_64)"
  echo "${PREFIX} status=ok n01=${N01_OK} n06=${N06_OK} n07=${N07_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# Prefer asm for freestanding runtime smokes.
# PLATFORM: SHARED archaeology / LINUX freestanding.
if [ -z "${XLANG:-}" ]; then
  if [ -x ./compiler/xlang_asm ]; then
    export XLANG=./compiler/xlang_asm
  elif [ -x ./compiler/xlang ]; then
    export XLANG=./compiler/xlang
  fi
fi
if [ -n "${XLANG:-}" ]; then
  export XLANG_LINK_XLANG="$XLANG"
fi

echo "=== S4: delegate run-freestanding-hello ==="
chmod +x "$FREESTANDING_HELLO"
if ! "$FREESTANDING_HELLO"; then
  die "freestanding hello sub-gate failed"
fi

if [ -x tests/run-std-sys-gate.sh ]; then
  echo "=== BOOT-029: delegate run-std-sys-gate (hard) ==="
  chmod +x tests/run-std-sys-gate.sh
  # Hard-delegate; do not re-export soft FAIL knobs.
  tests/run-std-sys-gate.sh || die "std-sys sub-gate failed"
fi

echo "=== NL-02: delegate run-no-libc-socket-gate ==="
run_sub tests/run-no-libc-socket-gate.sh

echo "=== NL-03: delegate run-no-libc-heap-gate ==="
run_sub tests/run-no-libc-heap-gate.sh

echo "=== NL-04: delegate run-no-libc-fs-gate ==="
run_sub tests/run-no-libc-fs-gate.sh

echo "=== NL-05: delegate run-no-libc-link-gate (runtime audit; smokes skipped) ==="
XLANG_NOLIBC_LINK_SKIP_SMOKE=1 run_sub tests/run-no-libc-link-gate.sh
RT_OK=1
SKIP=0

echo "nolibc gate OK (NL-01～NL-07 user freestanding; bootstrap nostdlib v2+v3 track)"
echo "${PREFIX} status=ok n01=${N01_OK} n06=${N06_OK} n07=${N07_OK} rt=${RT_OK} skip=${SKIP} host=$(ci_host_summary)"
