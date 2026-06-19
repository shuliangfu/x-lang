#!/usr/bin/env bash
# PLAN-001：Phase 3 路线图定版门禁
#
# 用法：./tests/run-phase3-roadmap-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PLAN001_DOC:-analysis/phase3-roadmap-v1.md}"
MANIFEST="${SHUX_PLAN001_TSV:-tests/baseline/phase3-roadmap.tsv}"
NEXT_MD="NEXT.md"
LIB="tests/lib/phase3-roadmap.sh"
MIN_TASKS=10
MIN_SEC=5

# shellcheck source=tests/lib/phase3-roadmap.sh
. "$LIB"

echo "=== PLAN-001: Phase 3 roadmap manifest ==="
for f in "$DOC" "$MANIFEST" "$NEXT_MD" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "phase3-roadmap gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tasks) MIN_TASKS="$c2" ;;
    min_sections) MIN_SEC="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Phase 3 Option LANG-009 BOOT-020 SHUX_PLAN001; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "phase3-roadmap gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "## 2.12" "$NEXT_MD" 2>/dev/null; then
  echo "phase3-roadmap gate FAIL: NEXT.md missing §2.12" >&2
  phase3_roadmap_emit_report "fail" 0 0
  exit 1
fi

sym_miss="$(phase3_roadmap_check "$MANIFEST" "$NEXT_MD" || true)"
task_n="$(phase3_roadmap_task_count "$MANIFEST")"
if [ "${sym_miss:-0}" -gt 0 ]; then
  phase3_roadmap_emit_report "fail" 0 0
  exit 1
fi
if [ "$task_n" -lt "$MIN_TASKS" ]; then
  echo "phase3-roadmap gate FAIL: tasks=${task_n} < min ${MIN_TASKS}" >&2
  phase3_roadmap_emit_report "fail" "$task_n" 0
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
  echo "phase3-roadmap gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  phase3_roadmap_emit_report "fail" "$task_n" "$SEC"
  exit 1
fi

echo "phase3-roadmap manifest OK (tasks=${task_n} sections=${SEC})"
phase3_roadmap_emit_report "ok" "$task_n" "$SEC"
echo "phase3-roadmap gate OK"
