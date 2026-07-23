#!/usr/bin/env bash
# xlang-deps-verify.sh — TOOL-008 校验锁文件与磁盘内容一致（可重复构建）
#
# 用法：./scripts/xlang-deps-verify.sh <xlang.pkg.tsv> <xlang.pkg.lock.tsv>
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/lib/tool-deps-lock.sh
. "$ROOT/tests/lib/tool-deps-lock.sh"

MANIFEST="${1:-}"
LOCK="${2:-}"
if [ -z "$MANIFEST" ] || [ ! -f "$MANIFEST" ]; then
  echo "xlang-deps-verify FAIL: missing manifest" >&2
  exit 1
fi
if [ -z "$LOCK" ] || [ ! -f "$LOCK" ]; then
  echo "xlang-deps-verify FAIL: missing lock" >&2
  exit 1
fi

tool_deps_read_manifest "$MANIFEST"

LOCKED_N=0
OK=0
FAIL=0
while IFS=$'\t' read -r kind pkg tier relp dig _rest; do
  [ -z "${kind:-}" ] && continue
  case "$kind" in \#*) continue ;; esac
  [ "$kind" != "locked" ] && continue
  LOCKED_N=$((LOCKED_N + 1))
  abs="$ROOT/$relp"
  if [ ! -f "$abs" ]; then
    echo "xlang-deps-verify FAIL: missing $abs ($pkg)" >&2
    FAIL=$((FAIL + 1))
    continue
  fi
  got="$(tool_deps_sha256_file "$abs")"
  if [ "$got" != "$dig" ]; then
    echo "xlang-deps-verify FAIL: hash mismatch $pkg want=$dig got=$got" >&2
    FAIL=$((FAIL + 1))
    continue
  fi
  echo "xlang-deps-verify OK $pkg $relp"
  OK=$((OK + 1))
done < "$LOCK"

REQ_N="${#REQUIRES[@]}"
if [ "$OK" -ne "$REQ_N" ] || [ "$LOCKED_N" -lt "$REQ_N" ]; then
  echo "xlang-deps-verify FAIL: locked=${LOCKED_N} ok=${OK} requires=${REQ_N}" >&2
  exit 1
fi
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
echo "tool-deps-lock report locked=${OK}/${REQ_N} verify=OK reproducible=OK"
echo "xlang-deps-verify OK"
