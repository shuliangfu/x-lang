#!/usr/bin/env bash
# B-32：审计 bootstrap 是否仍 cc -c 编译 std/*.c。
# v1 track 全量；已迁移模块（io/fs/heap/compress）硬禁见 run-f07-no-cc-std-migrated-gate.sh。
#
# 用法：./tests/run-b32-no-cc-std-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-32: track cc -c std (migrated hard-ban → F-07 v1) ==="
MANIFEST="tests/baseline/b32-cc-std-track.tsv"
mkdir -p tests/baseline
: > "$MANIFEST"
echo -e "file\tpattern\tnotes" >> "$MANIFEST"
found=0
while IFS= read -r f; do
  if grep -qE 'cc .*-c.*std/' "$f" 2>/dev/null || grep -qE 'gcc .*-c.*std/' "$f" 2>/dev/null; then
    echo -e "${f}\tcc -c std/\ttrack" >> "$MANIFEST"
    found=$((found + 1))
  fi
done < <(find compiler tests -name 'Makefile' -o -name '*.sh' 2>/dev/null | head -200)
echo "b32 track: $found Makefile/sh hits (see $MANIFEST)"
echo "b32 no-cc-std track gate OK"
