#!/usr/bin/env bash
# ENG-006：回滚应急干跑演练（不 checkout、不 push、不改 baseline）
#
# 校验 playbook + 烟测 hook 存在，打印 SLA 分阶段与最近 tag 列表。
#
# 用法：
#   ./tests/run-eng-rollback-drill.sh
#   SHUX_ROLLBACK_TARGET_TAG=v0.1.0-beta.1 ./tests/run-eng-rollback-drill.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHUX_ENG_ROLLBACK_TSV:-tests/baseline/eng-rollback-emergency.tsv}"
PLAYBOOK="${SHUX_ENG_ROLLBACK_PLAYBOOK:-tests/templates/eng-rollback-playbook.txt}"

# shellcheck source=tests/lib/eng-rollback-emergency.sh
. tests/lib/eng-rollback-emergency.sh
# shellcheck source=tests/lib/eng-branch-release-gate.sh
. tests/lib/eng-branch-release-gate.sh

PREFIX="$(eng_rollback_prefix)"
SLA="$(eng_rollback_sla_minutes)"

echo "${PREFIX} start sla_minutes=${SLA} mode=dry_run" >&2

if [ ! -f "$MANIFEST" ]; then
  echo "${PREFIX} FAIL missing manifest $MANIFEST" >&2
  exit 1
fi
if ! eng_rollback_playbook_ok "$PLAYBOOK"; then
  echo "${PREFIX} FAIL playbook missing R1/R2/R3 or smoke section" >&2
  exit 1
fi
echo "${PREFIX} playbook OK" >&2

echo "${PREFIX} sla T0-T5 triage (5min)" >&2
echo "${PREFIX} sla T5-T15 rollback action (10min)" >&2
echo "${PREFIX} sla T15-T25 smoke hooks (10min)" >&2
echo "${PREFIX} sla T25-T30 incident close (5min)" >&2

FAIL=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$kind" in
    smoke_hook)
      if ! eng_rollback_smoke_hook_ok "$anchor"; then
        echo "${PREFIX} FAIL missing smoke hook tests/$anchor" >&2
        FAIL=$((FAIL + 1))
      else
        echo "${PREFIX} hook OK $anchor" >&2
      fi
      ;;
  esac
done < "$MANIFEST"

if [ -n "${SHUX_ROLLBACK_TARGET_TAG:-}" ]; then
  if ! eng_release_tag_valid "$SHUX_ROLLBACK_TARGET_TAG"; then
    echo "${PREFIX} WARN target tag format suspicious: ${SHUX_ROLLBACK_TARGET_TAG}" >&2
  fi
  echo "${PREFIX} target_tag=${SHUX_ROLLBACK_TARGET_TAG} (dry_run only)" >&2
fi

TAGS="$(eng_rollback_list_recent_tags 5)"
if [ -n "$TAGS" ]; then
  echo "${PREFIX} recent_tags:" >&2
  echo "$TAGS" | while IFS= read -r t; do
    [ -n "$t" ] && echo "${PREFIX}   $t" >&2
  done
else
  echo "${PREFIX} recent_tags: (none yet — use git tag after first release)" >&2
fi

if [ "$FAIL" -gt 0 ]; then
  echo "${PREFIX} FAIL ${FAIL} hook(s)" >&2
  exit 1
fi
echo "${PREFIX} dry_run complete (no git/worktree changes)" >&2
echo "eng-rollback-drill OK"
