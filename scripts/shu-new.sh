#!/usr/bin/env bash
# shu-new.sh — 一命令创建可运行 Shulang 项目（TOOL-006）
#
# 用法：./scripts/shu-new.sh <project-dir>
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
  echo "shu-new FAIL: path already exists: $TARGET" >&2
  exit 1
fi

if [ ! -d "$TEMPLATE" ] || [ ! -f "$TEMPLATE/main.su" ]; then
  echo "shu-new FAIL: missing template $TEMPLATE" >&2
  exit 1
fi

mkdir -p "$TARGET"
cp -R "$TEMPLATE"/. "$TARGET"/
echo "shu-new OK: created $TARGET"
echo "  cd $(basename "$TARGET") && shu run main.su"
