#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_JSON="${SCRIPT_DIR}/package.json"

usage() {
  cat <<'EOF'
用法：
  ./install-local-extension.sh [选项]

默认行为：
  1. 安装 npm 依赖（若 node_modules 不存在）
  2. 编译扩展
  3. 打包 VSIX
  4. 用本机可用的编辑器 CLI 本地安装（默认覆盖安装）

选项：
  --editor <name>     指定编辑器 CLI：auto / trae-cn / code / code-insiders / cursor / codium
  --skip-install      只编译并打包，不执行本地安装
  --skip-package      跳过打包，直接安装已有 VSIX
  --skip-compile      跳过 compile
  --no-force          安装时不加 --force
  --help              显示帮助

示例：
  ./install-local-extension.sh
  ./install-local-extension.sh --editor trae-cn
  ./install-local-extension.sh --skip-install
EOF
}

need_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "FAIL: missing command: $cmd" >&2
    exit 1
  fi
}

pkg_version() {
  sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PKG_JSON" | head -1
}

detect_editor_cli() {
  local preferred="${1:-auto}"
  local candidates=()

  if [ "$preferred" != "auto" ]; then
    candidates=("$preferred")
  else
    candidates=(trae-cn code cursor codium code-insiders)
  fi

  local cli
  for cli in "${candidates[@]}"; do
    if command -v "$cli" >/dev/null 2>&1; then
      printf '%s\n' "$cli"
      return 0
    fi
  done
  return 1
}

EDITOR_CLI="auto"
SKIP_INSTALL=0
SKIP_PACKAGE=0
SKIP_COMPILE=0
FORCE_INSTALL=1

while [ $# -gt 0 ]; do
  case "$1" in
    --editor)
      EDITOR_CLI="${2:-}"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=1
      shift
      ;;
    --skip-package)
      SKIP_PACKAGE=1
      shift
      ;;
    --skip-compile)
      SKIP_COMPILE=1
      shift
      ;;
    --no-force)
      FORCE_INSTALL=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "FAIL: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$PKG_JSON" ]; then
  echo "FAIL: missing ${PKG_JSON}" >&2
  exit 1
fi

VERSION="$(pkg_version)"
if [ -z "$VERSION" ]; then
  echo "FAIL: cannot read version from ${PKG_JSON}" >&2
  exit 1
fi

VSIX="vscode-xlang-${VERSION}.vsix"
VSIX_PATH="${SCRIPT_DIR}/${VSIX}"

echo "== Xlang VSCode local install =="
echo "dir: ${SCRIPT_DIR}"
echo "version: ${VERSION}"

cd "$SCRIPT_DIR"

need_cmd node
need_cmd npm

if [ ! -d node_modules ]; then
  echo "== npm install =="
  npm install --no-fund --no-audit
fi

if [ "$SKIP_COMPILE" -eq 0 ]; then
  echo "== npm run compile =="
  npm run compile
fi

if [ "$SKIP_PACKAGE" -eq 0 ]; then
  echo "== package vsix =="
  npx --yes @vscode/vsce package --allow-missing-repository --out "$VSIX"
fi

if [ ! -f "$VSIX_PATH" ]; then
  echo "FAIL: missing VSIX: ${VSIX_PATH}" >&2
  exit 1
fi

echo "vsix: ${VSIX_PATH}"

if [ "$SKIP_INSTALL" -eq 1 ]; then
  echo "skip install: done"
  exit 0
fi

if ! CLI="$(detect_editor_cli "$EDITOR_CLI")"; then
  echo "FAIL: no editor CLI found. Tried: ${EDITOR_CLI}" >&2
  echo "You can install manually from VSIX: ${VSIX_PATH}" >&2
  exit 1
fi

echo "== install extension =="
echo "editor cli: ${CLI}"

INSTALL_ARGS=(--install-extension "$VSIX_PATH")
if [ "$FORCE_INSTALL" -eq 1 ]; then
  INSTALL_ARGS+=(--force)
fi

"$CLI" "${INSTALL_ARGS[@]}"

cat <<EOF
OK: extension installed via ${CLI}
Next step:
  1. Reload window in your editor
  2. Open a .x file
  3. Check "Xlang" output channel if LSP still does not respond
EOF
