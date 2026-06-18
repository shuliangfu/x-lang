#!/usr/bin/env bash
# shu-deps-resolve.sh — TOOL-007 包依赖解析原型（本地 manifest，无网络）
#
# 用法：./scripts/shu-deps-resolve.sh <shu.pkg.tsv>
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/lib/tool-pkgmgr.sh
. "$ROOT/tests/lib/tool-pkgmgr.sh"

MANIFEST="${1:-}"
if [ -z "$MANIFEST" ] || [ ! -f "$MANIFEST" ]; then
  echo "shu-deps-resolve FAIL: missing manifest" >&2
  echo "usage: $0 <shu.pkg.tsv>" >&2
  exit 1
fi

MANIFEST_DIR="$(cd "$(dirname "$MANIFEST")" && pwd)"
MANIFEST="$(cd "$(dirname "$MANIFEST")" && pwd)/$(basename "$MANIFEST")"

ROOTS=()
REQUIRES=()
while IFS=$'\t' read -r kind key val _notes; do
  [ -z "${kind:-}" ] && continue
  case "$kind" in \#*) continue ;; esac
  case "$kind" in
    lib_root)
      case "$val" in
        /*) ROOTS+=("$val") ;;
        *) ROOTS+=("$MANIFEST_DIR/$val") ;;
      esac
      ;;
    require) REQUIRES+=("$key") ;;
  esac
done < "$MANIFEST"

if [ "${#ROOTS[@]}" -eq 0 ]; then
  ROOTS+=("$MANIFEST_DIR")
fi

HITS=0
MISS=0
for req in "${REQUIRES[@]}"; do
  found=0
  for lr in "${ROOTS[@]}"; do
    if tool_pkg_resolve_import "$lr" "$req" >/dev/null 2>&1; then
      echo "shu-deps-resolve OK $req -> $(tool_pkg_resolve_import "$lr" "$req")"
      HITS=$((HITS + 1))
      found=1
      break
    fi
  done
  if [ "$found" -eq 0 ]; then
    echo "shu-deps-resolve FAIL: unresolved $req" >&2
    MISS=$((MISS + 1))
  fi
done

if [ "$MISS" -gt 0 ]; then
  exit 1
fi
echo "tool-pkgmgr report requires=${HITS}/${#REQUIRES[@]} roots=${#ROOTS[@]} resolve=OK"
echo "shu-deps-resolve OK"
