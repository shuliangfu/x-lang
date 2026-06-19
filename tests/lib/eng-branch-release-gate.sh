#!/usr/bin/env bash
# eng-branch-release-gate.sh — ENG-004 共享：tag 校验、ci.yml 分支锚点、manifest 解析
#
# 用法（source 后）：
#   eng_release_prefix
#   eng_release_tag_valid v1.2.3
#   eng_release_ci_branch_ok
#   eng_release_worktree_clean

# 预检 stderr 前缀（与 manifest output_prefix 一致）。
eng_release_prefix() {
  echo "shux: [SHUX_RELEASE_PRECHECK]"
}

# 校验语义化 tag：vX.Y.Z 或 vX.Y.Z-beta.1。
eng_release_tag_valid() {
  local tag="$1"
  [ -n "$tag" ] || return 1
  echo "$tag" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9][a-zA-Z0-9.-]*)?$'
}

# 校验 ci.yml 含 dev push 与 main PR 触发（分支保护 workflow 锚点）。
eng_release_ci_branch_ok() {
  local ci_yml="${1:-.github/workflows/ci.yml}"
  [ -f "$ci_yml" ] || return 1
  grep -qE 'push:' "$ci_yml" || return 1
  grep -qE 'pull_request:' "$ci_yml" || return 1
  grep -q 'dev' "$ci_yml" || return 1
  grep -q 'main' "$ci_yml" || return 1
  return 0
}

# git 工作区是否干净（无 staged/unstaged/untracked 则返回 0）。
eng_release_worktree_clean() {
  git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]
}

# 从 manifest 读取 release_gate 脚本列表（相对 tests/）。
eng_release_manifest_gates() {
  local manifest="$1"
  while IFS=$'\t' read -r item_id kind anchor notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|output_prefix|branch_*|ci_yml|release_checklist|branch_protection_doc|release_precheck|release_gate|lib|precheck_portable|cross_*) continue ;; esac
    case "$kind" in
      release_gate) echo "$anchor" ;;
    esac
  done < "$manifest"
}
