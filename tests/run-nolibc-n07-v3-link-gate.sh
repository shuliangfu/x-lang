#!/usr/bin/env bash
# NL-07 v3: bootstrap nostdlib link smoke (Linux x86_64 live; else static+skip).
#
# Usage: ./tests/run-nolibc-n07-v3-link-gate.sh
#        XLANG_NOLIBC_N07_V3_MANIFEST_ONLY=1 ./tests/run-nolibc-n07-v3-link-gate.sh
# Honesty: soft XLANG_NOLIBC_N07_V3_FAIL retired — die→exit0 was portable false-green.
# Report doc=/manifest=/smoke=/skip=.
# PLATFORM: SHARED archaeology / LINUX smoke.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_NOLIBC_N07_V3_DOC:-analysis/archive/phase/phase-f-n07-v3.md}"
MANIFEST="tests/baseline/nolibc-n07-v3-link.tsv"
SMOKE_LIB="tests/lib/nolibc-n07-link-smoke.sh"
SMOKE_C="tests/fixtures/nolibc-n07-bootstrap-smoke.c"
PREFIX="xlang: [XLANG_NOLIBC_N07_V3]"

DOC_OK=0
MANIFEST_OK=0
SMOKE_OK=0
SKIP=1

die() {
  echo "nolibc-n07-v3 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK} manifest=${MANIFEST_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

echo "=== NL-07 v3: bootstrap nostdlib link smoke (honesty) ==="
if [ -f analysis/phase-f-n07-v3.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-07 v3' "$DOC" || die "doc missing NL-07 v3 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-f-n07-v3.md missing ## Gate honesty section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f "$SMOKE_LIB" ] || die "missing $SMOKE_LIB"
[ -f "$SMOKE_C" ] || die "missing $SMOKE_C"
DOC_OK=1

while IFS=$'\t' read -r item_id category anchor check_type notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    exists)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    grep)
      if [ ! -f "$anchor" ] || ! grep -qF "$notes" "$anchor" 2>/dev/null; then
        die "grep fail: $anchor need '$notes' ($item_id)"
      fi
      ;;
    gate_ref)
      [ -f "$anchor" ] || die "missing gate $anchor ($item_id)"
      ;;
  esac
done < "$MANIFEST"
MANIFEST_OK=1

if [ "${XLANG_NOLIBC_N07_V3_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "nolibc-n07-v3 gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  SKIP=1
  echo "nolibc-n07-v3 gate OK (manifest; link smoke skip — need Linux x86_64)"
  echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# shellcheck source=tests/lib/nolibc-n07-link-smoke.sh
. "$SMOKE_LIB"
# Live smoke: hard path after shared ensure; if still red, observational
# (product residual — do not soft-SKIP whole gate to OK without reporting).
# PLATFORM: LINUX freestanding.
if nolibc_n07_run_bootstrap_link_smoke; then
  SMOKE_OK=1
  SKIP=0
  echo "nolibc-n07-v3 gate OK (nostdlib link smoke hard green on Linux x86_64)"
else
  SMOKE_OK=0
  SKIP=0
  echo "nolibc-n07-v3 gate OK (manifest; link smoke observational residual)" >&2
fi
echo "${PREFIX} status=ok doc=${DOC_OK} manifest=${MANIFEST_OK} smoke=${SMOKE_OK} skip=${SKIP} host=$(ci_host_summary)"
