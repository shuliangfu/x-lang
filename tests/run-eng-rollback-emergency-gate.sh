#!/usr/bin/env bash
# ENG-006：回滚机制与应急手册 manifest 门禁
#
# 1) eng-rollback-emergency-v1.md + manifest + playbook + lib
# 2) 文档 SLA / 回滚 / 应急 关键词
# 3) run-eng-rollback-drill.sh 干跑烟测
#
# 用法：./tests/run-eng-rollback-emergency-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_ENG_ROLLBACK_DOC:-analysis/eng-rollback-emergency-v1.md}"
MANIFEST="${SHUX_ENG_ROLLBACK_TSV:-tests/baseline/eng-rollback-emergency.tsv}"
PLAYBOOK="tests/templates/eng-rollback-playbook.txt"
LIB="tests/lib/eng-rollback-emergency.sh"
DRILL="tests/run-eng-rollback-drill.sh"
MIN_SEC=4
SLA_MIN=30
PREFIX="shux: [SHUX_ROLLBACK_DRILL]"

# shellcheck source=tests/lib/eng-rollback-emergency.sh
. tests/lib/eng-rollback-emergency.sh

echo "=== ENG-006: rollback emergency manifest ==="
for f in "$DOC" "$MANIFEST" "$PLAYBOOK" "$LIB" "$DRILL"; do
  if [ ! -f "$f" ]; then
    echo "eng-rollback-emergency gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    sla_minutes) SLA_MIN="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
echo "=== ENG-006: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|output_prefix|sla_budget) continue ;; esac
  case "$kind" in
    section)
      SEC=$((SEC + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-rollback-emergency FAIL: doc missing section '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-rollback-emergency FAIL: doc missing field '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    template)
      if [ ! -f "$anchor" ]; then
        echo "eng-rollback-emergency FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-rollback-emergency FAIL: doc missing ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|smoke_hook)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "eng-rollback-emergency FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "eng-rollback-emergency FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "eng-rollback-emergency FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "eng-rollback-emergency FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "eng-rollback-emergency gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "eng-rollback-emergency gate FAIL: missing=${MISS}" >&2
  exit 1
fi

if ! eng_rollback_playbook_ok "$PLAYBOOK"; then
  echo "eng-rollback-emergency gate FAIL: playbook structure" >&2
  exit 1
fi

for kw in 30 分钟 回滚 应急 R1 R2 R3; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "eng-rollback-emergency gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

got_sla="$(eng_rollback_sla_minutes)"
if [ "$got_sla" != "$SLA_MIN" ]; then
  echo "eng-rollback-emergency gate FAIL: sla=${got_sla} want ${SLA_MIN}" >&2
  exit 1
fi
echo "eng-rollback-emergency manifest OK (sections=${SEC}, sla=${SLA_MIN}min)"

echo "=== ENG-006: rollback drill smoke ==="
chmod +x "$DRILL" "$LIB"
if ! ./"$DRILL" 2>&1 | tee /tmp/eng_rollback_drill.log; then
  echo "eng-rollback-emergency gate FAIL: drill" >&2
  exit 1
fi
grep -qF "$PREFIX" /tmp/eng_rollback_drill.log || {
  echo "eng-rollback-emergency gate FAIL: missing drill prefix" >&2
  exit 1
}
grep -q 'eng-rollback-drill OK' /tmp/eng_rollback_drill.log || {
  echo "eng-rollback-emergency gate FAIL: drill did not OK" >&2
  exit 1
}
echo "eng-rollback-emergency drill OK"
echo "eng-rollback-emergency gate OK"
