#!/usr/bin/env bash
# D-03: Stage1/Stage2 binary SHA256 golden standard v1
# (delegates A-09 run-stage2-hash-gate).
#
# Honesty: soft XLANG_D03_FAIL retired — early Darwin "OOM" soft exit0 skipped
# DOC/manifest entirely (portable false-green). Soft die→exit0 on missing
# DOC/anchors also retired. Live = archive DOC + ## Gate + hash when stage
# binaries exist; honest skip=1 after static when bins absent.
#
# Usage: ./tests/run-d03-stage2-hash-gate.sh
# Env:
#   XLANG_STAGE2_HASH_STRICT=1 — mismatch exits 1 (default 1)
#   XLANG_STAGE2_HASH_SKIP=1   — explicit skip (still requires static audit)
# PLATFORM: SHARED archaeology (SHA256 works on Mach-O + ELF).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if [ -f analysis/phase-d-d03-v1.md ]; then
  echo "d03-stage2-hash-gate gate FAIL: top-level DOC resurrected (live = archive/phase/)" >&2
  exit 1
fi

STRICT=${XLANG_STAGE2_HASH_STRICT:-1}
DOC="analysis/archive/phase/phase-d-d03-v1.md"
MANIFEST="tests/baseline/d03-stage2-hash.tsv"
HASH_GATE="tests/run-stage2-hash-gate.sh"
VERIFY="compiler/verify-selfhost-stage2-bstrict.sh"
VERIFY_BODY="compiler/scripts/verify-selfhost-stage2-bstrict.sh"
STAGE1="${XLANG_D03_STAGE1:-compiler/xlang_asm_stage1}"
STAGE2="${XLANG_D03_STAGE2:-compiler/xlang_asm2}"
PREFIX="xlang: [XLANG_D03]"

die() {
  echo "d03 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} static=${STATIC_OK:-0} hash=${HASH_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
STATIC_OK=0
HASH_OK=0
SKIP=1

echo "=== D-03: Stage2 SHA256 golden standard (honesty) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + verify-selfhost-stage2-bstrict)"
fi
for f in "$DOC" "$MANIFEST" "$HASH_GATE" "$VERIFY" "$VERIFY_BODY" tests/baseline/bootstrap-repro.tsv; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-03 v1' "$DOC" || die "doc missing D-03 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-d-d03-v1.md missing ## Gate honesty section"
DOC_OK=1

grep -q 'Step 4c: Stage2 SHA256' "$VERIFY_BODY" || die "verify body missing Step 4c hash gate"
grep -q 'stage2_hash' tests/baseline/bootstrap-repro.tsv || die "bootstrap-repro missing stage2_hash row"
STATIC_OK=1

MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type _notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in
    gate_ref|cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "d03 manifest missing gate_ref: $anchor ($track_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref anchors missing"

if [ "${XLANG_STAGE2_HASH_SKIP:-0}" = "1" ]; then
  SKIP=1
  echo "d03 stage2-hash gate: SKIP (XLANG_STAGE2_HASH_SKIP=1; static audited)"
  echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} hash=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -f "$STAGE1" ] || [ ! -f "$STAGE2" ]; then
  SKIP=1
  echo "d03 stage2-hash gate: SKIP (no $STAGE1 / $STAGE2; run verify-selfhost-stage2-bstrict first)"
  echo "d03 stage2-hash gate OK (static audited — bins absent)"
  echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} hash=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== D-03: delegate run-stage2-hash-gate (STRICT=$STRICT) ==="
chmod +x "$HASH_GATE"
XLANG_STAGE2_HASH_STRICT="$STRICT" "$HASH_GATE" "$STAGE1" "$STAGE2" || die "hash gate failed"
HASH_OK=1
SKIP=0

echo "d03 stage2-hash gate OK (SHA256 match: $STAGE1 vs $STAGE2)"
echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} hash=${HASH_OK} skip=${SKIP} host=$(ci_host_summary)"
