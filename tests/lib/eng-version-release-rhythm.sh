#!/usr/bin/env bash
# eng-version-release-rhythm.sh — ENG-005 共享：VERSION 读取、SemVer 与渠道 tag 解析
#
# 用法（source 后）：
#   eng_version_read_base
#   eng_version_base_valid 0.1.0
#   eng_version_channel_from_tag v0.1.0-beta.1
#   eng_version_vscode_sync_ok

# 读取仓库根 VERSION 文件（单行 MAJOR.MINOR.PATCH）。
eng_version_read_base() {
  local vf="${1:-VERSION}"
  [ -f "$vf" ] || return 1
  tr -d ' \t\r\n' <"$vf" | head -1
}

# 校验 SemVer 基线（无 v 前缀、无预发布后缀）。
eng_version_base_valid() {
  local v="$1"
  [ -n "$v" ] || return 1
  echo "$v" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'
}

# 从 git tag 解析渠道：alpha | beta | stable | unknown。
eng_version_channel_from_tag() {
  local tag="$1"
  [ -n "$tag" ] || { echo unknown; return 1; }
  case "$tag" in
    *-alpha.*) echo alpha ;;
    *-beta.*) echo beta ;;
    v[0-9]*.[0-9]*.[0-9]*) echo stable ;;
    *) echo unknown ;;
  esac
}

# VERSION 与 editors/vscode/package.json 的 version 字段一致则返回 0。
eng_version_vscode_sync_ok() {
  local base vf pkg ver
  vf="${1:-VERSION}"
  pkg="${2:-editors/vscode/package.json}"
  base="$(eng_version_read_base "$vf")" || return 1
  [ -f "$pkg" ] || return 1
  ver=$(grep -E '"version"[[:space:]]*:' "$pkg" | head -1 | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
  [ "$ver" = "$base" ]
}
