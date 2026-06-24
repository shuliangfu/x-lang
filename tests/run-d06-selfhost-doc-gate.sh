#!/usr/bin/env bash
# D-06 v1：SELFHOST / README Stage2 黄金自举文档与复现命令门禁。
#
# 用法：./tests/run-d06-selfhost-doc-gate.sh
# 环境：SHUX_D06_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D06_FAIL:-0}
DOC="analysis/phase-d-d06-v1.md"
MANIFEST="tests/baseline/d06-selfhost-doc.tsv"
SELFHOST="compiler/docs/SELFHOST.md"
README="README.md"
NEXT="NEXT.md"

die() {
  echo "d06 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== D-06: SELFHOST golden self-host doc (v1) ==="
for f in "$DOC" "$MANIFEST" "$SELFHOST" "$README" "$NEXT"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-06 v1' "$DOC" || die "phase doc missing D-06 v1 marker"

# ── SELFHOST.md 必需章节与关键词 ──
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

# Stage2 哈希：须写明 STRICT 默认（D-03）
grep -q 'SHUX_STAGE2_HASH_STRICT' "$SELFHOST" || die "SELFHOST.md missing SHA256 STRICT env"
grep -q 'SHUX_STAGE2_HASH_STRICT=1' "$SELFHOST" || die "SELFHOST.md missing STRICT=1 example"

# ── README 自举状态对齐 ──
grep -q 'Stage2 哈希金标准' "$README" || die "README missing Stage2 hash row"
grep -q 'verify-selfhost-stage2-bstrict' "$README" || die "README missing stage2 bstrict ref"
grep -q 'SELFHOST.md' "$README" || die "README missing SELFHOST link"

# README 须标记 Stage2 哈希已绿（✅ 或「已 SHA256 一致」）
if ! grep -E 'Stage2 哈希金标准.*✅|Stage2 哈希.*SHA256 一致' "$README" >/dev/null 2>&1; then
  die "README Stage2 hash status not marked green"
fi

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

echo "d06 selfhost-doc gate OK (SELFHOST + README golden Stage2 repro documented)"
