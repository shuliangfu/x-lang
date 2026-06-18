#!/usr/bin/env bash
# ENG-005：版本号与发布节奏 manifest 门禁
#
# 1) eng-version-release-rhythm-v1.md + manifest
# 2) VERSION SemVer + VS Code package.json 同步
# 3) alpha/beta/stable 渠道 tag 烟测
#
# 用法：./tests/run-eng-version-release-rhythm-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_ENG_VERSION_DOC:-analysis/eng-version-release-rhythm-v1.md}"
MANIFEST="${SHU_ENG_VERSION_TSV:-tests/baseline/eng-version-release-rhythm.tsv}"
LIB="tests/lib/eng-version-release-rhythm.sh"
VERSION_FILE="VERSION"
VSCODE_PKG="editors/vscode/package.json"
MIN_CHANNELS=3

# shellcheck source=tests/lib/eng-version-release-rhythm.sh
. tests/lib/eng-version-release-rhythm.sh
# shellcheck source=tests/lib/eng-branch-release-gate.sh
. tests/lib/eng-branch-release-gate.sh

echo "=== ENG-005: version release rhythm manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$VERSION_FILE" "$VSCODE_PKG" \
  tests/templates/eng-version-channel-matrix.txt; do
  if [ ! -f "$f" ]; then
    echo "eng-version-release-rhythm gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_channels) MIN_CHANNELS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
CHANNELS=0
echo "=== ENG-005: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      CHANNELS=$((CHANNELS + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: doc missing section '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: doc missing field '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|template)
      if [ ! -f "$anchor" ]; then
        echo "eng-version-release-rhythm FAIL: missing $kind $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "eng-version-release-rhythm FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "eng-version-release-rhythm FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    sample_tag)
      if ! eng_release_tag_valid "$anchor" 2>/dev/null; then
        echo "eng-version-release-rhythm FAIL: invalid sample tag $anchor (ENG-004)" >&2
        MISS=$((MISS + 1))
        continue
      fi
      ch="$(eng_version_channel_from_tag "$anchor")"
      case "$item_id" in
        tag_alpha) [ "$ch" = alpha ] || { echo "eng-version-release-rhythm FAIL: $anchor not alpha" >&2; MISS=$((MISS + 1)); } ;;
        tag_beta) [ "$ch" = beta ] || { echo "eng-version-release-rhythm FAIL: $anchor not beta" >&2; MISS=$((MISS + 1)); } ;;
        tag_stable) [ "$ch" = stable ] || { echo "eng-version-release-rhythm FAIL: $anchor not stable" >&2; MISS=$((MISS + 1)); } ;;
      esac
      ;;
  esac
done < "$MANIFEST"

if [ "$CHANNELS" -lt "$MIN_CHANNELS" ]; then
  echo "eng-version-release-rhythm gate FAIL: channels=${CHANNELS} < min ${MIN_CHANNELS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "eng-version-release-rhythm gate FAIL: missing=${MISS}" >&2
  exit 1
fi

BASE="$(eng_version_read_base "$VERSION_FILE")" || {
  echo "eng-version-release-rhythm gate FAIL: cannot read VERSION" >&2
  exit 1
}
if ! eng_version_base_valid "$BASE"; then
  echo "eng-version-release-rhythm gate FAIL: invalid VERSION '$BASE'" >&2
  exit 1
fi
if ! eng_version_vscode_sync_ok "$VERSION_FILE" "$VSCODE_PKG"; then
  echo "eng-version-release-rhythm gate FAIL: VERSION=$BASE != package.json version" >&2
  exit 1
fi
echo "eng-version-release-rhythm VERSION OK ($BASE, vscode synced)"

for kw in alpha beta stable SemVer 节奏; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "eng-version-release-rhythm gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

echo "eng-version-release-rhythm gate OK"
