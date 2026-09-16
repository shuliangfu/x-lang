#!/usr/bin/env bash
# NL-05: freestanding user link policy (runtime block no -lc; bootstrap track-only).
#
# Usage: ./tests/run-no-libc-link-gate.sh
#        XLANG_NOLIBC_LINK_MANIFEST_ONLY=1 ./tests/run-no-libc-link-gate.sh
#        XLANG_NOLIBC_LINK_SKIP_SMOKE=1 ./tests/run-no-libc-link-gate.sh
# Honesty: soft XLANG_NOLIBC_LINK_FAIL retired — die→exit0 was portable false-green.
# Hard-delegate NL-03/04 smokes (no soft FAIL re-export). Refuse Makefile /
# runtime.from_x.c resurrect. Report doc=/audit=/smoke=/skip=.
# PLATFORM: SHARED archaeology / LINUX smoke.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_LINK_DOC:-analysis/archive/phase/phase-f-no-libc-v1.md}"
POLICY="tests/baseline/no-libc-link-policy.tsv"
RT="compiler/seeds/runtime_link_abi.from_x.c"
DRIVER="compiler/src/driver/compile.x"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
PREFIX="xlang: [XLANG_NOLIBC_LINK]"

DOC_OK=0
AUDIT_OK=0
SMOKE_OK=0
SKIP=1

die() {
  echo "nolibc-link gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} audit=${AUDIT_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-05: freestanding link policy (honesty) ==="
if [ -f analysis/phase-f-no-libc-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
if [ -f compiler/seeds/runtime.from_x.c ]; then
  die "seeds/runtime.from_x.c resurrected (hosted -lc track = runtime_link_abi)"
fi

for f in "$DOC" "$POLICY" "$RT" "$DRIVER" "$BUILD_ASM"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'NL-05' "$DOC" || die "phase doc missing NL-05"
grep -qE '^## Gate$' "$DOC" || die "phase-f-no-libc-v1.md missing ## Gate honesty section"
DOC_OK=1

# shellcheck source=tests/lib/no-libc-link-audit.sh
. tests/lib/no-libc-link-audit.sh
if ! nolibc_audit_runtime_freestanding_block "$RT"; then
  die "runtime freestanding block audit failed"
fi
echo "nolibc-link OK: runtime NL-05 block has -nostdlib, no -lc"
AUDIT_OK=1

grep -q 'freestanding' "$DRIVER" || die "driver compile.x missing -freestanding"

TRACK=$(nolibc_track_compiler_lc_mentions)
echo "nolibc-link track: compiler bootstrap files with -lc mentions = $TRACK (expected until F-07; not blocking v1)"

if [ "${XLANG_NOLIBC_LINK_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-link gate OK (manifest + runtime audit)"
  echo "${PREFIX} status=ok doc=${DOC_OK} audit=${AUDIT_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "${XLANG_NOLIBC_LINK_SKIP_SMOKE:-0}" != "1" ]; then
  if [ "$(uname -s 2>/dev/null)" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
    chmod +x tests/run-no-libc-heap-gate.sh tests/run-no-libc-fs-gate.sh
    # Hard-delegate children (they hard-die on static; live may be observational).
    # Do not re-export retired soft FAIL knobs.
    ./tests/run-no-libc-heap-gate.sh || die "heap smoke link failed"
    ./tests/run-no-libc-fs-gate.sh || die "fs smoke link failed"
    # Child exit0 with live=0 still counts as delegated; report smoke=1 when both OK.
    SMOKE_OK=1
    SKIP=0
  else
    SKIP=1
    echo "nolibc-link gate: runtime smokes skip (need Linux x86_64)"
  fi
else
  SKIP=0
  echo "nolibc-link gate: smoke skipped (XLANG_NOLIBC_LINK_SKIP_SMOKE=1)"
fi

echo "nolibc-link gate OK (user freestanding nostdlib; compiler -lc track-only)"
echo "${PREFIX} status=ok doc=${DOC_OK} audit=${AUDIT_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
