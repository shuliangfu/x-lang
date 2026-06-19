#!/usr/bin/env bash
# ENG-004：分支保护与发布门禁 manifest
#
# 1) eng-branch-release-gate-v1.md + manifest + 模板 + lib
# 2) ci.yml 分支触发锚点
# 3) release_gate 脚本存在；烟测 run-eng-release-precheck.sh
#
# 用法：./tests/run-eng-branch-release-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_ENG_RELEASE_DOC:-analysis/eng-branch-release-gate-v1.md}"
MANIFEST="${SHUX_ENG_RELEASE_MANIFEST:-tests/baseline/eng-branch-release-gate.tsv}"
LIB="tests/lib/eng-branch-release-gate.sh"
PRECHECK="tests/run-eng-release-precheck.sh"
CI_YML=".github/workflows/ci.yml"
MIN_GATES=3
MIN_BRANCH=2
PREFIX="shux: [SHUX_RELEASE_PRECHECK]"

# shellcheck source=tests/lib/eng-branch-release-gate.sh
. tests/lib/eng-branch-release-gate.sh

echo "=== ENG-004: branch/release gate manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$PRECHECK" "$CI_YML" \
  tests/templates/eng-release-checklist.txt \
  tests/templates/eng-branch-protection-settings.txt; do
  if [ ! -f "$f" ]; then
    echo "eng-branch-release-gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_release_gates) MIN_GATES="$c2" ;;
    min_branch_rules) MIN_BRANCH="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
GATES=0
BRANCH=0
echo "=== ENG-004: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix) continue ;; esac
  case "$kind" in
    branch_rule)
      BRANCH=$((BRANCH + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-branch-release-gate FAIL: doc missing branch rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-branch-release-gate FAIL: doc missing field '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|template)
      if [ ! -f "$anchor" ]; then
        echo "eng-branch-release-gate FAIL: missing $kind $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-branch-release-gate FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|release_gate|release_hook)
      path="tests/$anchor"
      if [ "$kind" = "script" ] || [ "$kind" = "release_gate" ] || [ "$kind" = "release_hook" ]; then
        if [ ! -f "$path" ]; then
          echo "eng-branch-release-gate FAIL: missing script $path" >&2
          MISS=$((MISS + 1))
        elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
          echo "eng-branch-release-gate FAIL: doc missing script ref $anchor" >&2
          MISS=$((MISS + 1))
        fi
      fi
      case "$kind" in
        release_gate) GATES=$((GATES + 1)) ;;
      esac
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "eng-branch-release-gate FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-branch-release-gate FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$GATES" -lt "$MIN_GATES" ]; then
  echo "eng-branch-release-gate FAIL: release_gates=${GATES} < min ${MIN_GATES}" >&2
  exit 1
fi
if [ "$BRANCH" -lt "$MIN_BRANCH" ]; then
  echo "eng-branch-release-gate FAIL: branch_rules=${BRANCH} < min ${MIN_BRANCH}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "eng-branch-release-gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in branch protection release precheck SHUX_RELEASE_PRECHECK dev main; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "eng-branch-release-gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! eng_release_ci_branch_ok "$CI_YML"; then
  echo "eng-branch-release-gate FAIL: ci.yml branch anchors" >&2
  exit 1
fi
if ! eng_release_tag_valid "v1.0.0"; then
  echo "eng-branch-release-gate FAIL: tag validator broken" >&2
  exit 1
fi
if ! eng_release_tag_valid "v1.0.0-beta.1"; then
  echo "eng-branch-release-gate FAIL: prerelease tag validator broken" >&2
  exit 1
fi
echo "eng-branch-release-gate manifest OK (gates=${GATES})"

echo "=== ENG-004: release precheck smoke ==="
chmod +x "$PRECHECK" tests/lib/eng-branch-release-gate.sh
# 预检会递归调用本 gate；用子 shell 仅跑其它 release_gate 行时易循环。
# 烟测：直接跑 precheck（内含 baseline/quality/cross + branch-release gate）。
if ! ./"$PRECHECK" 2>&1 | tee /tmp/eng_release_precheck_smoke.log; then
  echo "eng-branch-release-gate FAIL: precheck smoke" >&2
  exit 1
fi
grep -qF "$PREFIX" /tmp/eng_release_precheck_smoke.log || {
  echo "eng-branch-release-gate FAIL: missing precheck prefix" >&2
  exit 1
}
grep -q 'eng-release-precheck OK' /tmp/eng_release_precheck_smoke.log || {
  echo "eng-branch-release-gate FAIL: precheck did not OK" >&2
  exit 1
}
echo "eng-branch-release-gate smoke OK"
echo "eng-branch-release-gate gate OK"
