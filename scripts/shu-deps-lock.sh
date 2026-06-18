#!/usr/bin/env bash
# shu-deps-lock.sh — TOOL-008 由 shu.pkg.tsv 生成 shu.pkg.lock.tsv
#
# 用法：./scripts/shu-deps-lock.sh <shu.pkg.tsv> [out.lock.tsv]
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=tests/lib/tool-deps-lock.sh
. "$ROOT/tests/lib/tool-deps-lock.sh"

MANIFEST="${1:-}"
OUT="${2:-}"
if [ -z "$MANIFEST" ] || [ ! -f "$MANIFEST" ]; then
  echo "shu-deps-lock FAIL: missing manifest" >&2
  exit 1
fi
if [ -z "$OUT" ]; then
  OUT="$(dirname "$MANIFEST")/shu.pkg.lock.tsv"
fi

tool_deps_read_manifest "$MANIFEST"
TMP="$(mktemp)"
{
  echo "# shu.pkg.lock v1 — generated from $(basename "$MANIFEST")"
  echo "# lock_version	1"
  echo "meta	lock_version	1	-	-"
  echo "meta	name	${PKG_NAME:-app}	-	-"
  for lr in "${ROOTS[@]}"; do
  rel_lr="$(tool_deps_relpath_from_repo "$lr" "$ROOT")"
  echo "lib_root	.	${rel_lr}	-	-"
  done
  for req in "${REQUIRES[@]}"; do
    abs="$(tool_deps_resolve_abs "$req")" || {
      echo "shu-deps-lock FAIL: unresolved $req" >&2
      rm -f "$TMP"
      exit 1
    }
    relp="$(tool_deps_relpath_from_repo "$abs" "$ROOT")"
    dig="$(tool_deps_sha256_file "$abs")"
    echo "locked	${req}	bundled	${relp}	${dig}"
  done
} >"$TMP"
mv "$TMP" "$OUT"
echo "shu-deps-lock OK: wrote $OUT"
echo "tool-deps-lock report locked=${#REQUIRES[@]}/${#REQUIRES[@]} gen=OK"
