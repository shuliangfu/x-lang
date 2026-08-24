#!/usr/bin/env bash
# PLAN-008：Phase 3 第八批路线图定版门禁
#
# 用法：./tests/run-phase3-roadmap-wave8-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# Makefile → xbuild (refuse resurrect); live roadmap = analysis/自举进度.md.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_PLAN008_DOC:-analysis/archive/other-tickets/phase3-roadmap-wave8-v1.md}"
MANIFEST="${XLANG_PLAN008_TSV:-tests/baseline/phase3-roadmap-wave8.tsv}"
ROADMAP="${XLANG_LIVE_ROADMAP:-analysis/自举进度.md}"
# Historical NEXT.md task/§ authority now lives in archived DOC (refuse resurrect).
TASK_DOC="$DOC"
LIB="tests/lib/phase3-roadmap-wave8.sh"
MIN_TASKS=4
MIN_SEC=5
MIN_DONE=4

# shellcheck source=tests/lib/phase3-roadmap-wave8.sh
. "$LIB"

echo "=== PLAN-008: Phase 3 wave8 manifest ==="
for f in "$DOC" "$MANIFEST" "$ROADMAP" "$LIB" \
  analysis/archive/other-tickets/phase3-roadmap-wave7-v1.md tests/run-phase3-roadmap-wave7-gate.sh \
  tests/run-boot-027-xlang-asm2-cross-gate.sh \
  tests/run-comp-incr-compile-prod-gate.sh \
  tests/run-std-sqlite-row-col-blob-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "phase3-roadmap-wave8 gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f NEXT.md ]; then
  echo "$(basename "$0" .sh | sed "s/^run-//;s/-gate$//") gate FAIL: NEXT.md resurrected (use analysis/自举进度.md)" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_tasks) MIN_TASKS="$c2" ;;
    min_sections) MIN_SEC="$c2" ;;
    min_done) MIN_DONE="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Phase 3 BOOT-027 COMP-021 STD-069 XLANG_PLAN008; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "phase3-roadmap-wave8 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "§2.19" "$TASK_DOC" 2>/dev/null; then
  echo "phase3-roadmap-wave8 gate FAIL: DOC missing §2.19" >&2
  phase3_roadmap_wave8_emit_report "fail" 0 0 0
  exit 1
fi

sym_miss="$(phase3_roadmap_wave8_check "$MANIFEST" "$TASK_DOC" || true)"
task_n="$(phase3_roadmap_wave8_task_count "$MANIFEST")"
done_n="$(phase3_roadmap_wave8_done_count "$TASK_DOC")"

if [ "${sym_miss:-0}" -gt 0 ]; then
  phase3_roadmap_wave8_emit_report "fail" 0 0 0
  exit 1
fi
if [ "$task_n" -lt "$MIN_TASKS" ]; then
  echo "phase3-roadmap-wave8 gate FAIL: tasks=${task_n} < min ${MIN_TASKS}" >&2
  phase3_roadmap_wave8_emit_report "fail" "$task_n" 0 "$done_n"
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
  echo "phase3-roadmap-wave8 gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  phase3_roadmap_wave8_emit_report "fail" "$task_n" "$SEC" "$done_n"
  exit 1
fi

if [ "$done_n" -lt "$MIN_DONE" ]; then
  echo "phase3-roadmap-wave8 gate FAIL: done=${done_n} < min ${MIN_DONE} (§2.19 须全 ✅)" >&2
  phase3_roadmap_wave8_emit_report "fail" "$task_n" "$SEC" "$done_n"
  exit 1
fi

echo "phase3-roadmap-wave8 manifest OK (tasks=${task_n} sections=${SEC} done=${done_n})"
phase3_roadmap_wave8_emit_report "ok" "$task_n" "$SEC" "$done_n"
echo "phase3-roadmap-wave8 gate OK"
