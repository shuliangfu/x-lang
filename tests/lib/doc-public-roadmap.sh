#!/usr/bin/env bash
# doc-public-roadmap.sh — DOC-005 共享：季度版本校验与报告
#
# 用法（source 后）：
#   doc_roadmap_prefix
#   doc_roadmap_quarter_from_manifest MANIFEST_TSV
#   doc_roadmap_quarter_ok DOC QUARTER
#   doc_roadmap_emit_report status quarter sections cross_refs

DOC_ROADMAP_PREFIX="${SHU_DOC_ROADMAP_PREFIX:-shu: [SHU_DOC_ROADMAP]}"

# 报告行固定前缀。
doc_roadmap_prefix() {
  echo "$DOC_ROADMAP_PREFIX"
}

# 从 manifest 读取 quarter_anchor 行（默认 2026-Q2）。
doc_roadmap_quarter_from_manifest() {
  local manifest="${1:-tests/baseline/doc-public-roadmap.tsv}"
  local q="2026-Q2"
  while IFS=$'\t' read -r c1 c2 _rest; do
    c1="${c1#\# }"
    case "$c1" in
      quarter_anchor) q="$c2" ;;
    esac
  done < "$manifest"
  echo "$q"
}

# 文档须含当季版本字符串（如 2026-Q2）。
doc_roadmap_quarter_ok() {
  local doc="$1"
  local quarter="$2"
  [ -n "$doc" ] && [ -f "$doc" ] || return 1
  [ -n "$quarter" ] || return 1
  grep -qF "$quarter" "$doc" 2>/dev/null
}

# 输出结构化季度路线图报告行。
doc_roadmap_emit_report() {
  local status="$1"
  local quarter="$2"
  local sections="$3"
  local cross_refs="$4"
  echo "${DOC_ROADMAP_PREFIX} status=${status} quarter=${quarter} sections=${sections} cross_refs=${cross_refs}"
}
