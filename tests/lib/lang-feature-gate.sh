#!/usr/bin/env bash
# lang-feature-gate.sh — LANG-001 共享辅助

# 统计 manifest gates 行数。
lang_feature_gate_count() {
  local man="${1:-tests/baseline/lang-feature-gate.tsv}"
  awk -F'\t' '$2=="gates" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}
