#!/usr/bin/env bash
# TOOL-009：VS Code 扩展 vsix 打包烟测
#
# 顺序：npm install → compile → vsce package
# 用法：./tests/run-tool-vscode-pack.sh
set -e
cd "$(dirname "$0")/.."

VSCODE_DIR="editors/vscode"
EXPECTED_VER="${SHU_TOOL009_VERSION:-0.2.0}"
VSIX="${VSCODE_DIR}/vscode-shulang-${EXPECTED_VER}.vsix"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "run-tool-vscode-pack SKIP (no node/npm)"
  exit 0
fi

if [ ! -d "$VSCODE_DIR" ]; then
  echo "run-tool-vscode-pack FAIL: missing $VSCODE_DIR" >&2
  exit 1
fi

cd "$VSCODE_DIR"
# 依赖安装（首次或 lock 变更）
if [ ! -d node_modules ]; then
  npm install --no-fund --no-audit
fi
npm run compile
# vsce 打包；允许无 git 仓库元数据
npx --yes @vscode/vsce package --allow-missing-repository --out "vscode-shulang-${EXPECTED_VER}.vsix"

if [ ! -f "vscode-shulang-${EXPECTED_VER}.vsix" ]; then
  echo "run-tool-vscode-pack FAIL: vsix not created" >&2
  exit 1
fi
echo "run-tool-vscode-pack OK ($VSIX)"
