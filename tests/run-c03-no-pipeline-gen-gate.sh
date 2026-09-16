#!/usr/bin/env bash
# C-03 v1：B-strict / crt0 链不得 cc -c pipeline_gen.c（Linux/macOS；Windows track-only）。
#
# 用法：./tests/run-c03-no-pipeline-gen-gate.sh
# 环境：
# 2026-08-26: soft XLANG_C03_FAIL retired (die always hard).
#   XLANG_C03_BUILD_LOG=/path     — 可选，审计已有 bstrict 构建日志
#
# wave honesty (2026-08-24 #5): DOC → analysis/archive/phase/；
# Makefile deleted MG wave941 — live audit = bootstrap_driver_crt0.sh +
# build_xlang_asm.sh（refuse resurrect）。
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_C03_DOC:-analysis/archive/phase/phase-c-c03-v1.md}"
DOC_V2="${XLANG_C03_DOC_V2:-analysis/archive/phase/phase-c-c03-v2.md}"
MANIFEST="tests/baseline/c03-no-pipeline-gen.tsv"
BUILD_ASM="compiler/scripts/build_xlang_asm.sh"
CRT0_SH="compiler/scripts/bootstrap_driver_crt0.sh"
LOG="${XLANG_C03_BUILD_LOG:-/tmp/build_bstrict.log}"
PAT='(^|[[:space:]])cc -c (\.\./)?pipeline_gen\.c([[:space:]]|$)'

die() {
  echo "c03 gate FAIL: $*" >&2
  exit 1
}

echo "=== C-03 v2: Windows B-strict track (optional) ==="
[ -f "$DOC_V2" ] && grep -q 'C-03 v2' "$DOC_V2" || echo "c03 note: phase-c-c03-v2.md optional"

echo "=== C-03: no cc -c pipeline_gen.c (B-strict v1) ==="
for f in "$DOC" "$MANIFEST" "$BUILD_ASM" "$CRT0_SH" tests/run-bootstrap-bstrict-ci.sh; do
  [ -f "$f" ] || die "missing $f"
done
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild + bootstrap scripts)"
fi
grep -q 'C-03 v1' "$DOC" || die "doc missing C-03 v1 marker"

grep -q 'pipeline_gen' "$BUILD_ASM" || die "build_xlang_asm.sh missing pipeline_gen references"
grep -q 'cc -c pipeline_gen.c' "$CRT0_SH" || die "bootstrap_driver_crt0.sh missing pipeline_gen audit"
grep -q 'must not cc -c pipeline_gen' "$CRT0_SH" || die "bootstrap_driver_crt0.sh missing reject message"

# manifest gate_ref
MISS=0
while IFS=$'\t' read -r track_id _layer anchor check_type _notes; do
  [ -z "${track_id:-}" ] && continue
  case "$track_id" in \#*) continue ;; esac
  case "$check_type" in gate_ref)
    case "$anchor" in
      compiler/Makefile) continue ;; # retired
      analysis/phase-c-c03-*) continue ;; # archived; gate pins DOC
    esac
    [ -f "$anchor" ] || { echo "c03 manifest missing: $anchor" >&2; MISS=$((MISS + 1)); }
    ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest gate_ref missing"

if [ -f "$LOG" ]; then
  if grep -qE "$PAT" "$LOG" 2>/dev/null; then
    die "build log $LOG contains cc -c pipeline_gen.c"
  fi
  echo "c03 OK: audited build log $LOG (no pipeline_gen cc -c)"
else
  echo "c03 note: no build log at $LOG (run bootstrap-driver-bstrict first for full audit)"
fi

echo "c03 no-pipeline-gen gate OK (archive DOC + crt0 script audit; Makefile retired)"
