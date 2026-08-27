#!/usr/bin/env bash
# D-02 v1: Stage1 (xlang_asm_stage1) → Stage2 (xlang_asm2) gate
# (delegates run-stage2-bstrict-gate / verify-selfhost-stage2-bstrict).
#
# Honesty: soft XLANG_D02_FAIL retired — missing compiler/Makefile was
# portable false-green after MG wave941. Live authority =
# verify-selfhost-stage2-bstrict.sh + run-stage2-bstrict-gate.sh +
# bootstrap_verify_bstrict.sh (refuse Makefile resurrect).
#
# Usage: ./tests/run-d02-stage1-to-stage2-gate.sh
# Env:
#   XLANG_D02_MANIFEST_ONLY=1       — static + manifest only
#   XLANG_STAGE2_SKIP_BOOTSTRAP=1   — forwarded to verify (default 1)
# PLATFORM: SHARED archaeology · LINUX live Stage2 · DARWIN static+skip.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if [ -f analysis/phase-d-d02-v1.md ]; then
  echo "d02-stage1-to-stage2-gate gate FAIL: top-level DOC resurrected (live = archive/phase/)" >&2
  exit 1
fi

DOC="analysis/archive/phase/phase-d-d02-v1.md"
MANIFEST="tests/baseline/d02-stage1-to-stage2.tsv"
VERIFY="compiler/verify-selfhost-stage2-bstrict.sh"
VERIFY_BODY="compiler/scripts/verify-selfhost-stage2-bstrict.sh"
STAGE2_GATE="tests/run-stage2-bstrict-gate.sh"
BOOT_VERIFY="compiler/scripts/bootstrap_verify_bstrict.sh"
PREFIX="xlang: [XLANG_D02]"

die() {
  echo "d02 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} static=${STATIC_OK:-0} live=${LIVE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
STATIC_OK=0
LIVE_OK=0
SKIP=1

echo "=== D-02: Stage1 → Stage2 self-host (honesty) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + verify-selfhost-stage2-bstrict)"
fi
for f in "$DOC" "$MANIFEST" "$VERIFY" "$VERIFY_BODY" "$STAGE2_GATE" "$BOOT_VERIFY"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-02 v1' "$DOC" || die "doc missing D-02 v1 marker"
grep -qE '^## Gate$' "$DOC" || die "phase-d-d02-v1.md missing ## Gate honesty section"
DOC_OK=1

grep -q 'xlang_asm_stage1' "$VERIFY_BODY" || die "verify body missing stage1 step"
grep -q 'xlang_asm2' "$VERIFY_BODY" || die "verify body missing stage2 artifact"
grep -q 'verify-selfhost-stage2-bstrict' "$BOOT_VERIFY" || die "bootstrap_verify_bstrict missing stage2 verify"
grep -q 'verify-selfhost-stage2-bstrict' "$STAGE2_GATE" || die "stage2-bstrict-gate missing verify delegate"
STATIC_OK=1

MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in
    gate_ref|cross_ref)
      [ -f "$anchor" ] || { echo "d02 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

if [ "${XLANG_D02_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "d02 stage1-to-stage2 gate OK (manifest only)"
  echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# Darwin: stage2-bstrict-gate is N/A (Linux gold covers full verify).
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=1
  echo "d02 stage1-to-stage2 gate: N/A on Darwin (Linux covers live Stage2; static audited)"
  echo "d02 stage1-to-stage2 gate OK (Darwin N/A — manifest audited)"
  echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} live=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

echo "=== D-02: delegate run-stage2-bstrict-gate ==="
chmod +x "$STAGE2_GATE" "$VERIFY"
export XLANG_STAGE2_SKIP_BOOTSTRAP="${XLANG_STAGE2_SKIP_BOOTSTRAP:-1}"
XLANG_STAGE2_SKIP_BOOTSTRAP="$XLANG_STAGE2_SKIP_BOOTSTRAP" "$STAGE2_GATE" \
  || die "stage2-bstrict sub-gate failed"
LIVE_OK=1
SKIP=0

echo "d02 stage1-to-stage2 gate OK (verify-selfhost-stage2-bstrict)"
echo "${PREFIX} status=ok doc=${DOC_OK} static=${STATIC_OK} live=${LIVE_OK} skip=${SKIP} host=$(ci_host_summary)"
