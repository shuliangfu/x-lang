#!/usr/bin/env bash
# C-03 v1：B-strict / crt0 链不得 cc -c pipeline_gen.c（Linux/macOS；Windows track-only）。
#
# 用法：./tests/run-c03-no-pipeline-gen-gate.sh
# 环境：
#   SHUX_C03_FAIL=1              — 失败时硬退出
#   SHUX_C03_BUILD_LOG=/path     — 可选，审计已有 bstrict 构建日志
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C03_FAIL:-0}
DOC="analysis/phase-c-c03-v1.md"
MANIFEST="tests/baseline/c03-no-pipeline-gen.tsv"
MF="compiler/Makefile"
BUILD_ASM="compiler/scripts/build_shux_asm.sh"
LOG="${SHUX_C03_BUILD_LOG:-/tmp/build_bstrict.log}"
PAT='(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'

die() {
  echo "c03 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== C-03 v2: Windows B-strict track (optional) ==="
[ -f analysis/phase-c-c03-v2.md ] && grep -q 'C-03 v2' analysis/phase-c-c03-v2.md || echo "c03 note: phase-c-c03-v2.md optional"

echo "=== C-03: no cc -c pipeline_gen.c (B-strict v1) ==="
for f in "$DOC" "$MANIFEST" "$MF" "$BUILD_ASM" tests/run-bootstrap-bstrict-ci.sh; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'C-03 v1' "$DOC" || die "doc missing C-03 v1 marker"

grep -q 'bootstrap-driver-bstrict' "$MF" || die "Makefile missing bootstrap-driver-bstrict"
grep -q 'SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1' "$MF" || die "Makefile bstrict missing SKIP_GEN"
grep -q 'cc -c pipeline_gen.c' "$MF" || die "Makefile crt0 missing pipeline_gen audit"
grep -q 'pipeline_gen' "$BUILD_ASM" || die "build_shux_asm.sh missing pipeline_gen references"

# manifest gate_ref
MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type _notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    [ -f "$anchor" ] || { echo "c03 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

# 可选：审计已有 bstrict 构建日志
if [ -f "$LOG" ]; then
  if grep -qE "$PAT" "$LOG" 2>/dev/null; then
    die "build log $LOG contains cc -c pipeline_gen.c"
  fi
  echo "c03 OK: audited build log $LOG (no pipeline_gen cc -c)"
else
  echo "c03 note: no build log at $LOG (run bootstrap-driver-bstrict first for full audit)"
fi

echo "c03 no-pipeline-gen gate OK (Linux/macOS B-strict; Windows SHUX_WIN_BSTRICT=1 see run-bootstrap-bstrict-windows-gate)"
