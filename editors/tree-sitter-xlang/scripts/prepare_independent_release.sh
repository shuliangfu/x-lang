#!/usr/bin/env bash
# prepare_independent_release.sh — dry-run next step for tree-sitter independent release
# Knife 11.29 · §6 10.6 tools grain after CLOSE 11.28 HOLD; dry-run only (not physical migrate).
#
# Default: inventory + placeholder retarget preview ONLY.
# Physical submodule／subtree push REQUIRES XLANG_TREE_SITTER_REMOTE=<https github url>
# named by the user. Never invent a remote. Never mass-delete bindings.
#
# Usage (repo root or this dir):
#   bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh
#   bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh --check
#   XLANG_TREE_SITTER_REMOTE=https://github.com/OWNER/tree-sitter-xlang \
#     bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh --print-retarget
#
# Exit: 0 = dry-run OK；2 = refused physical step (no remote／banned apply)

set -euo pipefail
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
TS_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$TS_DIR/../.." && pwd)"
cd "$ROOT"

MODE=inventory
APPLY=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --check) MODE=check; shift ;;
    --print-retarget) MODE=retarget; shift ;;
    --apply-submodule)
      echo "prepare_independent_release: REFUSED --apply-submodule without user-named remote flow" >&2
      echo "  set XLANG_TREE_SITTER_REMOTE and re-run after manager批；this script never creates a GitHub repo" >&2
      exit 2
      ;;
    -h|--help)
      sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "=== tree-sitter-xlang independent release prepare (dry-run) ==="
echo "ROOT=$ROOT"
echo "TS_DIR=$TS_DIR"
echo "MODE=$MODE"
echo "XLANG_TREE_SITTER_REMOTE=${XLANG_TREE_SITTER_REMOTE:-<unset>}"
echo

# --- inventory ---
echo "## tracked files under editors/tree-sitter-xlang"
n=$(git ls-files 'editors/tree-sitter-xlang/**' | wc -l | tr -d ' ')
echo "count=$n"
git ls-files 'editors/tree-sitter-xlang/**' | sed 's/^/  /'
echo

echo "## binding / make stubs (gate floor)"
for f in \
  editors/tree-sitter-xlang/Makefile \
  editors/tree-sitter-xlang/bindings/python/tree_sitter_xlang/binding.c \
  editors/tree-sitter-xlang/bindings/node/binding.cc
do
  if [ -f "$f" ]; then echo "  OK  $f"; else echo "  MISSING $f"; exit 1; fi
done
echo

echo "## monorepo cross-refs (must retarget after split)"
# static list from 11.23 LOCATE
refs=(
  "README.md"
  "README_zh-CN.md"
  "NOTICE"
  "LICENSE"
  "CONTRIBUTING.md"
  "xlang.toml"
  "editors/vim/syntax/xlang.vim"
  "editors/HOST_CC_POLICY.md"
  "tests/run-product-path-zero-make-gate.sh"
  "build.x"
)
for f in "${refs[@]}"; do
  if [ -f "$f" ] && grep -nE 'editors/tree-sitter|tree-sitter-xlang' "$f" >/dev/null 2>&1; then
    echo "  REF  $f"
  else
    echo "  skip $f (no path hit or missing)"
  fi
done
echo

echo "## package metadata (current → placeholder after remote named)"
echo "  Cargo.toml repository=$(grep -E '^repository' editors/tree-sitter-xlang/Cargo.toml | head -1)"
echo "  go.mod=$(head -1 editors/tree-sitter-xlang/bindings/go/go.mod)"
if grep -q '"repository"' editors/tree-sitter-xlang/package.json 2>/dev/null; then
  echo "  package.json has repository field"
else
  echo "  package.json repository=<absent> (add when remote named)"
fi
echo

echo "## product-chain protect"
hits=$(grep -nE 'editors/tree-sitter|tree-sitter-xlang' compiler/scripts/g05_*.sh 2>/dev/null | grep -vE ':[0-9]+:[[:space:]]*#' || true)
if [ -n "$hits" ]; then
  echo "  FAIL g05 references tree-sitter:"
  echo "$hits" | head -10
  exit 1
fi
echo "  OK  g05_*.sh 0× tree-sitter"
echo

if [ "$MODE" = "retarget" ] || [ "$MODE" = "check" ]; then
  remote="${XLANG_TREE_SITTER_REMOTE:-}"
  if [ -z "$remote" ]; then
    echo "## retarget preview REFUSED (XLANG_TREE_SITTER_REMOTE unset)"
    echo "  Example after user names remote:"
    echo "    XLANG_TREE_SITTER_REMOTE=https://github.com/OWNER/tree-sitter-xlang \\"
    echo "      bash editors/tree-sitter-xlang/scripts/prepare_independent_release.sh --print-retarget"
    echo "  Proposed edits (placeholders only; not applied):"
    echo "    Cargo.toml repository = \"\$XLANG_TREE_SITTER_REMOTE\""
    echo "    go.mod module = github.com/OWNER/tree-sitter-xlang/bindings/go"
    echo "    package.json repository.url = \"\$XLANG_TREE_SITTER_REMOTE\""
    if [ "$MODE" = "retarget" ]; then exit 2; fi
  else
    echo "## retarget preview for remote=$remote"
    owner_path=$(echo "$remote" | sed -E 's#https://github.com/##; s#\.git$##')
    echo "  Cargo.toml repository = \"$remote\""
    echo "  go.mod module = ${owner_path}/bindings/go"
    echo "  package.json repository = { \"type\": \"git\", \"url\": \"$remote\" }"
    echo "  NEXT physical (NOT run by this script): git subtree split + submodule add $remote"
  fi
fi

echo
echo "=== prepare_independent_release DRY-RUN OK (no physical migrate) ==="
echo "Physical submodule still requires user-named XLANG_TREE_SITTER_REMOTE + manager批."
exit 0
