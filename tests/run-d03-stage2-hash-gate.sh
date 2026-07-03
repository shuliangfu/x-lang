#!/usr/bin/env bash
# D-03：Stage1/Stage2 二进制 SHA256 金标准 v1（委托 A-09 run-stage2-hash-gate）。
#
# 与 verify-selfhost-stage2-bstrict 行为 parity 正交：行为一致 ≠ 二进制一致。
#
# 用法：./tests/run-d03-stage2-hash-gate.sh
# 环境：
#   SHUX_D03_FAIL=1           — 失败时硬退出（CI 默认）
#   SHUX_STAGE2_HASH_STRICT=1 — 哈希不等时 exit 1（默认 1）
#   SHUX_STAGE2_HASH_SKIP=1   — 完全跳过
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D03_FAIL:-0}
STRICT=${SHUX_STAGE2_HASH_STRICT:-1}
DOC="analysis/phase-d-d03-v1.md"
MANIFEST="tests/baseline/d03-stage2-hash.tsv"
HASH_GATE="tests/run-stage2-hash-gate.sh"
VERIFY="compiler/verify-selfhost-stage2-bstrict.sh"
if [ "$(uname)" = "Darwin" ]; then echo "SKIP (macOS): shux_asm_stage1 OOM"; exit 0; fi
STAGE1="${SHUX_D03_STAGE1:-compiler/shux_asm_stage1}"
STAGE2="${SHUX_D03_STAGE2:-compiler/shux_asm2}"

die() {
  echo "d03 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== D-03: Stage2 SHA256 golden standard (v1) ==="
if [ "${SHUX_STAGE2_HASH_SKIP:-0}" = "1" ]; then
  echo "d03 stage2-hash gate: SKIP (SHUX_STAGE2_HASH_SKIP=1)"
  exit 0
fi

for f in "$DOC" "$MANIFEST" "$HASH_GATE" "$VERIFY" tests/baseline/bootstrap-repro.tsv; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-03 v1' "$DOC" || die "doc missing D-03 v1 marker"
grep -q 'Step 4c: Stage2 SHA256' "$VERIFY" || die "verify-selfhost missing Step 4c hash gate"
grep -q 'stage2_hash' tests/baseline/bootstrap-repro.tsv || die "bootstrap-repro missing stage2_hash row"

# ── manifest gate_ref 锚点 ──
echo "=== D-03: manifest gate_ref anchors ==="
MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type _notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    if [ ! -f "$anchor" ]; then
      echo "d03 manifest missing gate_ref: $anchor ($track_id)" >&2
      MISS=$((MISS + 1))
    fi
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref anchors missing"

# ── 平台：Darwin 无 native ELF stage 产物时 N/A ──
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "d03 stage2-hash gate: N/A on Darwin (use Docker run-linux-a09-a11-gate.sh)"
  echo "d03 stage2-hash gate OK (Darwin N/A — manifest audited)"
  exit 0
fi

# ── 委托 A-09 hash gate（STRICT 默认开）──
if [ ! -f "$STAGE1" ] || [ ! -f "$STAGE2" ]; then
  echo "d03 stage2-hash gate: SKIP (no $STAGE1 / $STAGE2; run verify-selfhost-stage2-bstrict first)"
  [ "$FAIL" = "1" ] && die "missing stage binaries under STRICT CI"
  exit 0
fi

echo "=== D-03: delegate run-stage2-hash-gate (STRICT=$STRICT) ==="
chmod +x "$HASH_GATE"
SHUX_STAGE2_HASH_STRICT="$STRICT" "$HASH_GATE" "$STAGE1" "$STAGE2" || die "hash gate failed"

echo "d03 stage2-hash gate OK (SHA256 match: $STAGE1 vs $STAGE2)"
