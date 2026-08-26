#!/usr/bin/env bash
# F-12: README + SELFHOST full-selfhost wording unified (D+E+F; Stage2 ≠ end).
#
# Usage: ./tests/run-f12-selfhost-doc-unified-gate.sh
# 2026-08-26: Honesty — hard-fail archive DOC + bilingual README needles +
# d06 (no soft die→exit0; no soft d06 FAIL pass-through). Soft
# XLANG_F12_SELFHOST_DOC_UNIFIED_FAIL retired. Report
# doc=/selfhost=/readme=/d06=/skip=. Gate was portable-false-green (soft
# FAIL exit0 + soft d06 exit0 while archive DOC already green; README EN
# rewrite dropped fossil "Stage2 哈希金标准" needle into d06 soft FAIL).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F12_DOC:-analysis/archive/phase/phase-f-f12-v1.md}"
MANIFEST="tests/baseline/f12-selfhost-doc-unified.tsv"
PREFIX="xlang: [XLANG_F12_DOC]"

die() {
  echo "f12-selfhost-doc-unified gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} selfhost=${SELFHOST_OK:-0} readme=${README_OK:-0} d06=${D06_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
SELFHOST_OK=0
README_OK=0
D06_OK=0
SKIP=1

echo "=== F-12: selfhost doc unified D+E+F (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-12 v1' "$DOC" || die "doc missing F-12 v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f12-v1.md ]; then
  die "top-level F-12 DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile|script) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
DOC_OK=1

for kw in 'D+E+F' '完全自举' '黄金自举' '阶段 D'; do
  grep -qF "$kw" compiler/docs/SELFHOST.md || die "SELFHOST missing '$kw'"
done
SELFHOST_OK=1

# Bilingual roots: README.md (EN) + README_zh-CN.md (ZH). Accept either.
grep -qF 'SELFHOST.md' README.md || die "README missing SELFHOST link"
grep -qE 'Stage2|语义自举' README.md || grep -qE 'Stage2|语义自举' README_zh-CN.md \
  || die "README missing Stage2/语义自举"
grep -qE '阶段 F|Phase F' README.md || grep -qE '阶段 F|Phase F' README_zh-CN.md \
  || die "README missing 阶段 F / Phase F"
grep -qF 'D+E+F' README.md || grep -qF 'D+E+F' README_zh-CN.md \
  || die "README missing D+E+F"
README_OK=1

if grep -q 'Xlang 完全自举验证' compiler/verify-selfhost.sh 2>/dev/null; then
  die "verify-selfhost.sh still claims 完全自举 in title"
fi
if grep -qE '^echo " Xlang 完全自举' compiler/verify-selfhost-stage2.sh 2>/dev/null; then
  die "verify-selfhost-stage2.sh banner still claims bare 完全自举"
fi
if grep -q '✓ 完全自举验证通过' compiler/verify-selfhost-stage2.sh 2>/dev/null; then
  die "verify-selfhost-stage2.sh success message still claims 完全自举"
fi

chmod +x tests/run-d06-selfhost-doc-gate.sh
# Hard-delegate; soft XLANG_D06_FAIL retired (honesty same wave).
# PLATFORM: SHARED archaeology.
if ! tests/run-d06-selfhost-doc-gate.sh; then
  die "d06 doc gate failed"
fi
D06_OK=1
SKIP=0

echo "f12-selfhost-doc-unified gate OK"
echo "${PREFIX} status=ok doc=${DOC_OK} selfhost=${SELFHOST_OK} readme=${README_OK} d06=${D06_OK} skip=${SKIP} host=$(ci_host_summary)"
