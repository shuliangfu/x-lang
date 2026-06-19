#!/usr/bin/env bash
# tool-lint.sh — TOOL-002 共享：linter 规则分层与 CI profile 辅助
#
# 用法（source 后）：
#   tool_lint_rule_count [manifest_tsv]
#   tool_lint_case_count [manifest_tsv]
#   tool_lint_profile_rows PROFILE [profile_tsv]
#   tool_lint_ci_fail_on_tier PROFILE rule_id [profile_tsv]

# 统计 manifest 中 rules 行数。
tool_lint_rule_count() {
  local man="${1:-tests/baseline/tool-lint-rules.tsv}"
  awk -F'\t' '$2=="rules" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 统计 manifest 中 case 行数。
tool_lint_case_count() {
  local man="${1:-tests/baseline/tool-lint-rules.tsv}"
  awk -F'\t' '$2=="case" && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 返回 profile 行数（不含注释与 min_ 行）。
tool_lint_profile_rows() {
  local profile="${1:-ci-default}"
  local man="${2:-tests/baseline/tool-lint-ci-profile.tsv}"
  awk -F'\t' -v p="$profile" '$1==p && $1 !~ /^#/ { n++ } END { print n+0 }' "$man"
}

# 查询某规则在 profile 下 ci_fail 是否为 yes（返回 0/1）。
tool_lint_ci_fail_on_tier() {
  local profile="${1:-ci-default}"
  local rule_id="$2"
  local man="${3:-tests/baseline/tool-lint-ci-profile.tsv}"
  awk -F'\t' -v p="$profile" -v r="$rule_id" \
    '$1==p && $2==r && $4=="yes" { found=1 } END { exit (found ? 0 : 1) }' "$man"
}

# 对金样执行 check；期望静默成功。
tool_lint_expect_check_silent() {
  local shux="$1"
  local src="$2"
  local out
  out=$("$shux" check "$src" 2>&1) && ec=0 || ec=$?
  if [ "$ec" -ne 0 ]; then
    echo "tool-lint FAIL: expected silent check on $src ec=$ec out=$out" >&2
    return 1
  fi
  if [ -n "$out" ]; then
    echo "tool-lint FAIL: expected silent check on $src got=$out" >&2
    return 1
  fi
  return 0
}

# 对金样执行 check；期望失败且输出含 error 诊断。
tool_lint_expect_check_error() {
  local shux="$1"
  local src="$2"
  local out
  out=$("$shux" check "$src" 2>&1) && ec=0 || ec=$?
  if [ "$ec" -eq 0 ]; then
    echo "tool-lint FAIL: expected check error on $src" >&2
    return 1
  fi
  if ! echo "$out" | grep -qE ' - error: |typeck error:|check failed'; then
    echo "tool-lint FAIL: missing error diagnostic on $src out=$out" >&2
    return 1
  fi
  return 0
}

# SHUX_PAD_FIELDS=1：期望含 -pad-fields warning 且 exit 0（默认 profile）。
tool_lint_expect_warn_pad() {
  local shux="$1"
  local src="$2"
  local out
  out=$(SHUX_PAD_FIELDS=1 "$shux" check "$src" 2>&1) && ec=0 || ec=$?
  if ! echo "$out" | grep -qE 'warning:.*-pad-fields| - warning: .*-pad-fields'; then
    echo "tool-lint FAIL: missing -pad-fields warning on $src out=$out" >&2
    return 1
  fi
  if [ "$ec" -ne 0 ]; then
    echo "tool-lint FAIL: pad-fields warn should not fail check ec=$ec out=$out" >&2
    return 1
  fi
  return 0
}

# SHUX_HOT_REORDER=1：期望含 -hot-reorder warning 且 exit 0。
tool_lint_expect_warn_reorder() {
  local shux="$1"
  local src="$2"
  local out
  out=$(SHUX_HOT_REORDER=1 "$shux" check "$src" 2>&1) && ec=0 || ec=$?
  if ! echo "$out" | grep -qE 'warning:.*-hot-reorder| - warning: .*-hot-reorder'; then
    echo "tool-lint FAIL: missing -hot-reorder warning on $src out=$out" >&2
    return 1
  fi
  if [ "$ec" -ne 0 ]; then
    echo "tool-lint FAIL: hot-reorder warn should not fail check ec=$ec out=$out" >&2
    return 1
  fi
  return 0
}

# SHUX_UNUSED_HINT=1：期望含 unused binding info 且 exit 0。
tool_lint_expect_info_unused() {
  local shux="$1"
  local src="$2"
  local out
  out=$(SHUX_UNUSED_HINT=1 "$shux" check "$src" 2>&1) && ec=0 || ec=$?
  if ! echo "$out" | grep -qE 'unused binding| - info: unused'; then
    echo "tool-lint FAIL: missing unused hint on $src out=$out" >&2
    return 1
  fi
  if [ "$ec" -ne 0 ]; then
    echo "tool-lint FAIL: unused hint should not fail check ec=$ec out=$out" >&2
    return 1
  fi
  return 0
}
