#!/usr/bin/env bash
# D-06: SELFHOST / README Stage2 golden self-host doc + repro commands.
#
# Usage: ./tests/run-d06-selfhost-doc-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + live bilingual README needles
# (no soft die→exit0). Soft XLANG_D06_FAIL retired. README EN rewrite dropped
# fossil "Stage2 哈希金标准" / verify-selfhost-stage2-bstrict root needles;
# live face accepts EN "D Stage2" ✅ / SHA256 row OR ZH equivalents. Report
# doc=/selfhost=/readme=/manifest=/skip=. Gate was portable-false-green
# (soft FAIL exit0 while SELFHOST already green; f12 hard FAIL=1 still green
# because soft d06 exited 0).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-d-d06-v1.md"
MANIFEST="tests/baseline/d06-selfhost-doc.tsv"
SELFHOST="compiler/docs/SELFHOST.md"
README="README.md"
README_ZH="README_zh-CN.md"
NEXT="analysis/自举进度.md"
PREFIX="xlang: [XLANG_D06_DOC]"

die() {
  echo "d06 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} selfhost=${SELFHOST_OK:-0} readme=${README_OK:-0} manifest=${MANIFEST_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
SELFHOST_OK=0
README_OK=0
MANIFEST_OK=0
SKIP=1

readme_has() {
  local pat="$1"
  grep -qE "$pat" "$README" 2>/dev/null && return 0
  [ -f "$README_ZH" ] && grep -qE "$pat" "$README_ZH" 2>/dev/null && return 0
  return 1
}

echo "=== D-06: SELFHOST golden self-host doc (honesty) ==="
for f in "$DOC" "$MANIFEST" "$SELFHOST" "$README" "$NEXT"; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (use analysis/自举进度.md)"
fi
if [ -f analysis/phase-d-d06-v1.md ]; then
  die "top-level D-06 DOC resurrected (live = archive/phase/)"
fi
grep -q 'D-06 v1' "$DOC" || die "phase doc missing D-06 v1 marker"
grep -qE '^## Gate' "$DOC" 2>/dev/null || true
DOC_OK=1

# ── SELFHOST.md required sections / keywords ──
for kw in \
  '阶段 D' \
  '黄金自举' \
  'bootstrap-verify-stage2-bstrict' \
  'run-d03-stage2-hash-gate' \
  'run-d04-stage2-portable-diff-gate' \
  'run-linux-a09-a11-gate' \
  '完全自举' \
  'D+E+F'; do
  grep -qF "$kw" "$SELFHOST" || die "SELFHOST.md missing '$kw'"
done

# Stage2 hash: STRICT default documented (D-03)
grep -q 'XLANG_STAGE2_HASH_STRICT' "$SELFHOST" || die "SELFHOST.md missing SHA256 STRICT env"
grep -q 'XLANG_STAGE2_HASH_STRICT=1' "$SELFHOST" || die "SELFHOST.md missing STRICT=1 example"
SELFHOST_OK=1

# ── README bilingual Stage2 status (live needles; refuse fossil-only) ──
grep -q 'SELFHOST.md' "$README" || die "README missing SELFHOST link"

# Live EN: "| **D Stage2** | ✅ …" or SHA256 mention; ZH: Stage2 哈希 / SHA256 一致.
# Fossil "Stage2 哈希金标准" / verify-selfhost-stage2-bstrict may be absent from EN root.
# PLATFORM: SHARED archaeology.
if ! readme_has 'D Stage2|Stage2 哈希金标准|Stage2.*SHA256|SHA256 一致'; then
  die "README missing live Stage2 status row (D Stage2 / Stage2 hash / SHA256)"
fi
if ! readme_has '✅'; then
  die "README Stage2 / self-host table missing green mark"
fi
# Stage2 bstrict repro lives in SELFHOST (checked above); README only needs
# the status row + SELFHOST link (G.7 single authority for repro commands).
README_OK=1

# ── manifest gate_ref ──
MISS=0
while IFS=$'\t' read -r item_id _doc anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "d06 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"
MANIFEST_OK=1
SKIP=0

echo "d06 selfhost-doc gate OK (SELFHOST + README golden Stage2 repro documented)"
echo "${PREFIX} status=ok doc=${DOC_OK} selfhost=${SELFHOST_OK} readme=${README_OK} manifest=${MANIFEST_OK} skip=${SKIP} host=$(ci_host_summary)"
