#!/usr/bin/env bash
# ENG-004：发布前自动预检（checklist 脚本化）
#
# 默认：manifest 快速 gate（ENG-001/002/003 + 分支锚点 + 可选 tag/干净工作区）
# 全量：SHUX_RELEASE_FULL=1 追加 run-portable-suite.sh
#
# 用法：
#   ./tests/run-eng-release-precheck.sh
#   SHUX_RELEASE_TAG=v0.2.0 ./tests/run-eng-release-precheck.sh
#   SHUX_RELEASE_REQUIRE_CLEAN=1 ./tests/run-eng-release-precheck.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHUX_ENG_RELEASE_MANIFEST:-tests/baseline/eng-branch-release-gate.tsv}"
PREFIX="shux: [SHUX_RELEASE_PRECHECK]"

# shellcheck source=tests/lib/eng-branch-release-gate.sh
. tests/lib/eng-branch-release-gate.sh

echo "${PREFIX} start host=$(uname -s)-$(uname -m 2>/dev/null)" >&2

if [ ! -f "$MANIFEST" ]; then
  echo "${PREFIX} FAIL missing manifest $MANIFEST" >&2
  exit 1
fi

if ! eng_release_ci_branch_ok ".github/workflows/ci.yml"; then
  echo "${PREFIX} FAIL ci.yml missing dev push / main pull_request anchors" >&2
  exit 1
fi
echo "${PREFIX} ci branch anchors OK" >&2

if [ -n "${SHUX_RELEASE_TAG:-}" ]; then
  if ! eng_release_tag_valid "$SHUX_RELEASE_TAG"; then
    echo "${PREFIX} FAIL invalid tag '${SHUX_RELEASE_TAG}' (want vX.Y.Z)" >&2
    exit 1
  fi
  echo "${PREFIX} tag OK ${SHUX_RELEASE_TAG}" >&2
fi

if [ "${SHUX_RELEASE_REQUIRE_CLEAN:-0}" = "1" ]; then
  if ! eng_release_worktree_clean; then
    echo "${PREFIX} FAIL working tree not clean (SHUX_RELEASE_REQUIRE_CLEAN=1)" >&2
    git status --short >&2 || true
    exit 1
  fi
  echo "${PREFIX} worktree clean OK" >&2
fi

FAIL=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in
    release_gate)
      script="tests/$anchor"
      if [ ! -f "$script" ]; then
        echo "${PREFIX} FAIL missing gate $script" >&2
        FAIL=$((FAIL + 1))
        continue
      fi
      chmod +x "$script"
      echo "${PREFIX} running $anchor ..." >&2
      if ! "./$script" >/tmp/shux_release_precheck_"${item_id}".log 2>&1; then
        tail -20 /tmp/shux_release_precheck_"${item_id}".log >&2 || true
        echo "${PREFIX} FAIL gate $anchor" >&2
        FAIL=$((FAIL + 1))
      else
        echo "${PREFIX} gate OK $anchor" >&2
      fi
      ;;
    release_hook)
      if [ "${SHUX_RELEASE_FULL:-0}" != "1" ]; then
        echo "${PREFIX} skip $anchor (set SHUX_RELEASE_FULL=1 for full portable suite)" >&2
        continue
      fi
      script="tests/$anchor"
      if [ ! -f "$script" ]; then
        echo "${PREFIX} FAIL missing hook $script" >&2
        FAIL=$((FAIL + 1))
        continue
      fi
      chmod +x "$script"
      echo "${PREFIX} running full $anchor ..." >&2
      if ! "./$script" >/tmp/shux_release_precheck_full.log 2>&1; then
        tail -30 /tmp/shux_release_precheck_full.log >&2 || true
        echo "${PREFIX} FAIL hook $anchor" >&2
        FAIL=$((FAIL + 1))
      else
        echo "${PREFIX} hook OK $anchor" >&2
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  echo "${PREFIX} FAIL ${FAIL} check(s)" >&2
  exit 1
fi
echo "${PREFIX} all checks passed" >&2
echo "eng-release-precheck OK"
