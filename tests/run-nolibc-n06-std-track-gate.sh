#!/usr/bin/env bash
# NL-06 v1: freestanding std first-batch track gate.
#
# Usage: ./tests/run-nolibc-n06-std-track-gate.sh
#        XLANG_NOLIBC_N06_MANIFEST_ONLY=1 ./tests/run-nolibc-n06-std-track-gate.sh
# Honesty: soft XLANG_NOLIBC_N06_FAIL retired — die→exit0 was portable false-green.
# Hard-delegate F-01 inventory (soft XLANG_STD_C_INVENTORY_FAIL already retired).
# Report doc=/manifest=/inv=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_N06_DOC:-analysis/archive/phase/phase-f-n06-v1.md}"
MANIFEST="tests/baseline/nolibc-n06-freestanding-replacements.tsv"
STD_C_GATE="tests/run-std-c-inventory-gate.sh"
PREFIX="xlang: [XLANG_NOLIBC_N06]"

DOC_OK=0
MANIFEST_OK=0
INV_OK=0
SKIP=1

die() {
  echo "nolibc-n06 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} inv=${INV_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-06: freestanding std track (honesty) ==="
if [ -f analysis/phase-f-n06-v1.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-06 v1' "$DOC" || die "doc missing NL-06 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n06-v1.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
DOC_OK=1

# shellcheck source=tests/lib/nolibc-n06-std-track.sh
. tests/lib/nolibc-n06-std-track.sh

if ! nolibc_n06_audit_manifest "$MANIFEST"; then
  die "NL-06 freestanding replacements manifest audit failed"
fi
MANIFEST_OK=1

x_n=$(nolibc_n06_count_x_replacements "$MANIFEST")
leg_n=$(nolibc_n06_count_legacy_c "$MANIFEST")
f01_total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' tests/baseline/std-c-inventory.tsv 2>/dev/null)
f01_total=${f01_total:-0}
echo "nolibc-n06: x_replacements=${x_n} legacy_c=${leg_n} (F-01 total=${f01_total})"

if [ "${XLANG_NOLIBC_N06_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-n06 gate OK (manifest only; x=${x_n} legacy=${leg_n})"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} inv=${INV_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ -f "$STD_C_GATE" ]; then
  echo "=== NL-06: delegate run-std-c-inventory-gate (F-01 hard) ==="
  chmod +x "$STD_C_GATE"
  # Do NOT re-export retired soft FAIL knobs.
  if ! "$STD_C_GATE"; then
    die "F-01 std-c-inventory sub-gate failed"
  fi
  INV_OK=1
fi
SKIP=0

echo "nolibc-n06 gate OK (freestanding std track v1)"
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} inv=${INV_OK} skip=${SKIP} host=$(ci_host_summary)"
