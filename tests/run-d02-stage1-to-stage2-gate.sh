#!/usr/bin/env bash
# D-02 v1：Stage1（shux_asm_stage1）→ Stage2（shux_asm2）门禁（委托 run-stage2-bstrict-gate）。
#
# 用法：./tests/run-d02-stage1-to-stage2-gate.sh
# 环境：
#   SHUX_D02_FAIL=1              — 失败时硬退出
#   SHUX_D02_MANIFEST_ONLY=1     — 仅 manifest
#   SHUX_STAGE2_SKIP_BOOTSTRAP=1 — 传给 verify（默认 1）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_D02_FAIL:-0}
DOC="analysis/phase-d-d02-v1.md"
MANIFEST="tests/baseline/d02-stage1-to-stage2.tsv"
VERIFY="compiler/verify-selfhost-stage2-bstrict.sh"
STAGE2_GATE="tests/run-stage2-bstrict-gate.sh"

die() {
  echo "d02 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== D-02: Stage1 → Stage2 self-host (v1) ==="
for f in "$DOC" "$MANIFEST" "$VERIFY" "$STAGE2_GATE" compiler/Makefile; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'D-02 v1' "$DOC" || die "doc missing D-02 v1 marker"
grep -q 'bootstrap-verify-stage2-bstrict' compiler/Makefile || die "Makefile missing bootstrap-verify-stage2-bstrict"
grep -q 'shux_asm_stage1' "$VERIFY" || die "verify missing stage1 step"
grep -q 'shux_asm2' "$VERIFY" || die "verify missing stage2 artifact"

MISS=0
while IFS=$'\t' read -r item_id _layer anchor check_type _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "d02 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

if [ "${SHUX_D02_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "d02 stage1-to-stage2 gate OK (manifest only)"
  exit 0
fi

# Darwin：与 run-stage2-bstrict-gate 一致 N/A
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "d02 stage1-to-stage2 gate: N/A on Darwin (use Docker run-linux-a09-a11-gate.sh)"
  echo "d02 stage1-to-stage2 gate OK (Darwin N/A — manifest audited)"
  exit 0
fi

echo "=== D-02: delegate run-stage2-bstrict-gate ==="
chmod +x "$STAGE2_GATE" "$VERIFY"
export SHUX_STAGE2_SKIP_BOOTSTRAP="${SHUX_STAGE2_SKIP_BOOTSTRAP:-1}"
if [ "$FAIL" = "1" ]; then
  SHUX_STAGE2_SKIP_BOOTSTRAP="$SHUX_STAGE2_SKIP_BOOTSTRAP" "$STAGE2_GATE" || die "stage2-bstrict sub-gate failed"
else
  "$STAGE2_GATE" || die "stage2-bstrict sub-gate failed"
fi

echo "d02 stage1-to-stage2 gate OK (verify-selfhost-stage2-bstrict)"
