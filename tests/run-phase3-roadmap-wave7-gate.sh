#!/usr/bin/env bash
# PLAN-007：Phase 3 第七批路线图定版门禁
#
# 用法：./tests/run-phase3-roadmap-wave7-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PLAN007_DOC:-analysis/phase3-roadmap-wave7-v1.md}"
MANIFEST="${SHUX_PLAN007_TSV:-tests/baseline/phase3-roadmap-wave7.tsv}"
NEXT_MD="NEXT.md"
LIB="tests/lib/phase3-roadmap-wave7.sh"
MIN_TASKS=4
MIN_SEC=5
MIN_DONE=4

# shellcheck source=tests/lib/phase3-roadmap-wave7.sh
. "$LIB"

echo "=== PLAN-007: Phase 3 wave7 manifest ==="
for f in "$DOC" "$MANIFEST" "$NEXT_MD" "$LIB" \
  analysis/phase3-roadmap-wave6-v1.md tests/run-phase3-roadmap-wave6-gate.sh \
  tests/run-boot-026-parser-c4-bootstrap-gate.sh \
  tests/run-comp-incr-compile-wave-gate.sh \
  tests/run-std-sqlite-row-col-text-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "phase3-roadmap-wave7 gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tasks) MIN_TASKS="$c2" ;;
    min_sections) MIN_SEC="$c2" ;;
    min_done) MIN_DONE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Phase 3 BOOT-026 COMP-020 STD-068 SHUX_PLAN007; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "phase3-roadmap-wave7 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "### 2.18" "$NEXT_MD" 2>/dev/null; then
  echo "phase3-roadmap-wave7 gate FAIL: NEXT.md missing §2.18" >&2
  phase3_roadmap_wave7_emit_report "fail" 0 0 0
  exit 1
fi

sym_miss="$(phase3_roadmap_wave7_check "$MANIFEST" "$NEXT_MD" || true)"
task_n="$(phase3_roadmap_wave7_task_count "$MANIFEST")"
done_n="$(phase3_roadmap_wave7_done_count "$NEXT_MD")"

if [ "${sym_miss:-0}" -gt 0 ]; then
  phase3_roadmap_wave7_emit_report "fail" 0 0 0
  exit 1
fi
if [ "$task_n" -lt "$MIN_TASKS" ]; then
  echo "phase3-roadmap-wave7 gate FAIL: tasks=${task_n} < min ${MIN_TASKS}" >&2
  phase3_roadmap_wave7_emit_report "fail" "$task_n" 0 "$done_n"
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
  echo "phase3-roadmap-wave7 gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  phase3_roadmap_wave7_emit_report "fail" "$task_n" "$SEC" "$done_n"
  exit 1
fi

if [ "$done_n" -lt "$MIN_DONE" ]; then
  echo "phase3-roadmap-wave7 gate FAIL: done=${done_n} < min ${MIN_DONE} (§2.18 须全 ✅)" >&2
  phase3_roadmap_wave7_emit_report "fail" "$task_n" "$SEC" "$done_n"
  exit 1
fi

echo "phase3-roadmap-wave7 manifest OK (tasks=${task_n} sections=${SEC} done=${done_n})"
phase3_roadmap_wave7_emit_report "ok" "$task_n" "$SEC" "$done_n"
echo "phase3-roadmap-wave7 gate OK"
