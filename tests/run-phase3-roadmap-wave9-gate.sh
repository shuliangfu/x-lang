#!/usr/bin/env bash
# PLAN-009：Phase 3 第九批路线图草稿门禁
#
# 用法：./tests/run-phase3-roadmap-wave9-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_PLAN009_DOC:-analysis/phase3-roadmap-wave9-v1.md}"
MANIFEST="${SHU_PLAN009_TSV:-tests/baseline/phase3-roadmap-wave9.tsv}"
NEXT_MD="NEXT.md"
LIB="tests/lib/phase3-roadmap-wave9.sh"
MIN_TASKS=4
MIN_SEC=5
MIN_DONE=0
DRAFT=0

# shellcheck source=tests/lib/phase3-roadmap-wave9.sh
. "$LIB"

echo "=== PLAN-009: Phase 3 wave9 manifest (draft) ==="
for f in "$DOC" "$MANIFEST" "$NEXT_MD" "$LIB" \
  analysis/phase3-roadmap-wave8-v1.md tests/run-phase3-roadmap-wave8-gate.sh \
  tests/run-boot-028-shu-asm2-ci-matrix-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "phase3-roadmap-wave9 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tasks) MIN_TASKS="$c2" ;;
    min_sections) MIN_SEC="$c2" ;;
    min_done) MIN_DONE="$c2" ;;
    draft) DRAFT="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Phase 3 BOOT-028 COMP-022 STD-070 SHU_PLAN009; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "phase3-roadmap-wave9 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "### 2.20" "$NEXT_MD" 2>/dev/null; then
  echo "phase3-roadmap-wave9 gate FAIL: NEXT.md missing §2.20" >&2
  phase3_roadmap_wave9_emit_report "fail" 0 0 0 "$DRAFT"
  exit 1
fi

sym_miss="$(phase3_roadmap_wave9_check "$MANIFEST" "$NEXT_MD" || true)"
task_n="$(phase3_roadmap_wave9_task_count "$MANIFEST")"
done_n="$(phase3_roadmap_wave9_done_count "$NEXT_MD")"

if [ "${sym_miss:-0}" -gt 0 ]; then
  phase3_roadmap_wave9_emit_report "fail" 0 0 0 "$DRAFT"
  exit 1
fi
if [ "$task_n" -lt "$MIN_TASKS" ]; then
  echo "phase3-roadmap-wave9 gate FAIL: tasks=${task_n} < min ${MIN_TASKS}" >&2
  phase3_roadmap_wave9_emit_report "fail" "$task_n" 0 "$done_n" "$DRAFT"
  exit 1
fi

SEC=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ "$kind" = "section" ] || continue
  if grep -qF "$anchor" "$mod_path" 2>/dev/null; then
    SEC=$((SEC + 1))
  fi
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "phase3-roadmap-wave9 gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  phase3_roadmap_wave9_emit_report "fail" "$task_n" "$SEC" "$done_n" "$DRAFT"
  exit 1
fi

if [ "$done_n" -lt "$MIN_DONE" ]; then
  echo "phase3-roadmap-wave9 gate FAIL: done=${done_n} < min ${MIN_DONE}" >&2
  phase3_roadmap_wave9_emit_report "fail" "$task_n" "$SEC" "$done_n" "$DRAFT"
  exit 1
fi

echo "phase3-roadmap-wave9 manifest OK (tasks=${task_n} sections=${SEC} done=${done_n} draft=${DRAFT})"
phase3_roadmap_wave9_emit_report "ok" "$task_n" "$SEC" "$done_n" "$DRAFT"
echo "phase3-roadmap-wave9 gate OK"
