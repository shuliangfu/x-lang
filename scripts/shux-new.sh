#!/usr/bin/env bash
# shux-new.sh — 一命令创建可运行 Shux 项目（TOOL-006）
#
# 用法：./scripts/shux-new.sh <project-dir>
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/tests/templates/project-hello"
DEST="${1:-}"

if [ -z "$DEST" ]; then
  echo "usage: $0 <project-dir>" >&2
  exit 1
fi

case "$DEST" in
  /*) TARGET="$DEST" ;;
  *) TARGET="$(pwd)/$DEST" ;;
esac

if [ -e "$TARGET" ]; then
  echo "shux-new FAIL: path already exists: $TARGET" >&2
  exit 1
fi

if [ ! -d "$TEMPLATE" ] || [ ! -f "$TEMPLATE/main.x" ]; then
  echo "shux-new FAIL: missing template $TEMPLATE" >&2
  exit 1
fi

mkdir -p "$TARGET"
cp -R "$TEMPLATE"/. "$TARGET"/
echo "shux-new OK: created $TARGET"
echo "  cd $(basename "$TARGET") && shux run main.x"
