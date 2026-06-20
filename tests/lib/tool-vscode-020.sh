#!/usr/bin/env bash
# tool-vscode-020.sh — TOOL-009 VS Code 0.2 共享辅助
#
# 用法（source 后）：
#   tool_vscode_020_grammar_json_ok path
#   tool_vscode_020_grammar_has_rule grammar anchor
#   tool_vscode_020_version_sync_ok
#   tool_vscode_020_has_node
#   tool_vscode_020_emit_report status grammar_ok vsix_ok skip

TOOL_VSCODE_PREFIX="${SHUX_TOOL009_PREFIX:-shux: [SHUX_TOOL009_VSCODE_020]}"
VSCODE_DIR="${SHUX_VSCODE_DIR:-editors/vscode}"
GRAMMAR="${VSCODE_DIR}/grammars/sx.tmLanguage.json"
PKG="${VSCODE_DIR}/package.json"
VERSION_FILE="${SHUX_VERSION_FILE:-VERSION}"
EXPECTED_VER="${SHUX_TOOL009_VERSION:-0.2.0}"

# 校验 TextMate grammar JSON 可解析。
tool_vscode_020_grammar_json_ok() {
  local path="${1:-$GRAMMAR}"
  python3 -m json.tool "$path" >/dev/null 2>&1
}

# grammar 文件须包含锚点字符串（rule 定义存在）。
tool_vscode_020_grammar_has_rule() {
  local grammar="${1:-$GRAMMAR}"
  local anchor="$2"
  [ -n "$anchor" ] && [ -f "$grammar" ] || return 1
  grep -qF "$anchor" "$grammar" 2>/dev/null
}

# VERSION 与 package.json version 与期望 0.2.0 一致。
tool_vscode_020_version_sync_ok() {
  local base pkg ver
  [ -f "$VERSION_FILE" ] || return 1
  base=$(tr -d ' \t\r\n' <"$VERSION_FILE" | head -1)
  [ "$base" = "$EXPECTED_VER" ] || return 1
  [ -f "$PKG" ] || return 1
  ver=$(grep -E '"version"[[:space:]]*:' "$PKG" | head -1 | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
  [ "$ver" = "$EXPECTED_VER" ]
}

# 本机是否有 node + npm 可执行 vsix 打包。
tool_vscode_020_has_node() {
  command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1
}

# 输出结构化报告行。
tool_vscode_020_emit_report() {
  local status="$1"
  local grammar_ok="$2"
  local vsix_ok="$3"
  local skip="$4"
  echo "${TOOL_VSCODE_PREFIX} status=${status} grammar_ok=${grammar_ok} vsix_ok=${vsix_ok} skip=${skip}"
}
