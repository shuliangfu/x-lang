#!/usr/bin/env bash
# tool-fmt.sh — TOOL-001 shared helpers (honesty soft→硬绿).
#
# Usage (source):
#   tool_fmt_case_count [manifest_tsv]
#   tool_fmt_rule_count [manifest_tsv]
#   tool_fmt_golden_idempotent XLANG_BIN golden_x
#   tool_fmt_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

# 统计 manifest 中 case 行数。
tool_fmt_case_count() {
  local man="${1:-tests/baseline/tool-fmt-style.tsv}"
  awk -F'\t' '$2=="case" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 统计 manifest 中 rules 行数。
tool_fmt_rule_count() {
  local man="${1:-tests/baseline/tool-fmt-style.tsv}"
  awk -F'\t' '$2=="rules" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 对金样执行 fmt 后 fmt --check 须静默成功（exit 0）。
tool_fmt_golden_idempotent() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-golden}"
  local tmp="/tmp/xlang_tool_fmt_${tag}_$$.x"
  if [ ! -f "$src" ]; then
    echo "tool-fmt FAIL: missing $src" >&2
    return 1
  fi
  cp "$src" "$tmp"
  if ! "$xlang" fmt "$tmp" >/dev/null 2>&1; then
    echo "tool-fmt FAIL: fmt $src" >&2
    rm -f "$tmp"
    return 1
  fi
  local ec=0
  local out
  out=$("$xlang" fmt --check "$tmp" 2>&1) || ec=$?
  rm -f "$tmp"
  if [ "$ec" -ne 0 ]; then
    echo "tool-fmt FAIL: --check after fmt $src ec=$ec out=$out" >&2
    return 1
  fi
  return 0
}

TOOL_FMT_PREFIX="${XLANG_TOOL_FMT_PREFIX:-xlang: [XLANG_TOOL_FMT]}"

# Structured report: run=/obs=/skip= (honesty 2026-08-28).
tool_fmt_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${TOOL_FMT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
