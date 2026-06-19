#!/usr/bin/env bash
# Shux 硬切：批量 git mv .sx → .sx，以及文件名含 shux 的路径改名。
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== git mv *.sx → *.sx ==="
find . -name '*.sx' -not -path './.git/*' | sort -r | while IFS= read -r f; do
  nx="${f%.sx}.sx"
  if [ -e "$nx" ]; then
    echo "skip exists: $nx" >&2
    continue
  fi
  git mv "$f" "$nx" 2>/dev/null || mv "$f" "$nx"
done

echo "=== rename path segments shux → shux (files/dirs) ==="
# 多轮：先深路径
for _ in 1 2 3 4; do
  find . \( -name '*shux*' -o -name '*shux*' \) -not -path './.git/*' | sort -r | while IFS= read -r p; do
    base="$(basename "$p")"
    dir="$(dirname "$p")"
    newbase="${base//shux/shux}"
    newbase="${newbase//shux/shux}"
    # 修正可能的 shux 双替换：shux_asm 不应变 shux_asm
    newbase="${newbase//shux/shux}"
    if [ "$base" = "$newbase" ]; then
      continue
    fi
    dest="$dir/$newbase"
    if [ -e "$dest" ]; then
      echo "skip dest exists: $dest" >&2
      continue
    fi
    git mv "$p" "$dest" 2>/dev/null || mv "$p" "$dest"
    echo "mv $p -> $dest"
  done
done

echo "rename done"
