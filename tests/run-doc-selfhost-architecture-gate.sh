#!/usr/bin/env bash
# DOC-002：自举架构全景图 manifest 门禁
#
# 1) doc-selfhost-architecture-v1.md 存在且含必需章节
# 2) 交叉引用文件存在
# 3) 关联 BOOT 文档存在
#
# 用法：./tests/run-doc-selfhost-architecture-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_DOC_SELFHOST_ARCH:-analysis/doc-selfhost-architecture-v1.md}"
MANIFEST="${SHUX_DOC_SELFHOST_MANIFEST:-tests/baseline/doc-selfhost-architecture.tsv}"
MIN_SEC=8

echo "=== DOC-002: selfhost architecture manifest ==="
for f in \
  "$DOC" \
  "$MANIFEST" \
  compiler/docs/SELFHOST.md \
  NEXT.md; do
  if [ ! -f "$f" ]; then
    echo "doc-selfhost-architecture gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_sections) MIN_SEC="$c2" ;; esac
done < "$MANIFEST"

MISS=0
FOUND=0
echo "=== DOC-002: required sections ==="
while IFS=$'\t' read -r sec_id anchor notes; do
  [ -z "${sec_id:-}" ] && continue
  case "$sec_id" in \#*|min_*) continue ;; esac
  if [ "$sec_id" = "cross_ref_selfhost" ]; then
    if [ ! -f "$anchor" ]; then
      echo "doc-selfhost-architecture FAIL: missing cross-ref $anchor" >&2
      MISS=$((MISS + 1))
    else
      echo "doc-selfhost-architecture OK cross-ref $anchor"
    fi
    continue
  fi
  if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
    echo "doc-selfhost-architecture FAIL: missing anchor '$anchor' ($sec_id)" >&2
    MISS=$((MISS + 1))
  else
    FOUND=$((FOUND + 1))
    echo "doc-selfhost-architecture OK section $sec_id"
  fi
done < "$MANIFEST"

if [ "$FOUND" -lt "$MIN_SEC" ]; then
  echo "doc-selfhost-architecture gate FAIL: sections=${FOUND} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "doc-selfhost-architecture gate FAIL: missing=${MISS}" >&2
  exit 1
fi

# 全景图须引用 SELFHOST
if ! grep -q 'SELFHOST.md' "$DOC"; then
  echo "doc-selfhost-architecture gate FAIL: doc missing SELFHOST.md reference" >&2
  exit 1
fi

# 关联 BOOT 分析文档
for boot_doc in \
  analysis/boot-stage-diag-v1.md \
  analysis/boot-repro-v1.md \
  analysis/boot-crossplatform-v1.md; do
  if [ ! -f "$boot_doc" ]; then
    echo "doc-selfhost-architecture gate FAIL: missing $boot_doc" >&2
    exit 1
  fi
done
echo "doc-selfhost-architecture BOOT cross-refs OK"

echo "doc-selfhost-architecture gate OK"
