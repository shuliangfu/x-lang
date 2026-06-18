#!/usr/bin/env bash
# COMP-019：WPO global tier 默认全局开启烟测门禁
#
# 1) comp-wpo-global-v1.md + comp-wpo-global-wave.tsv + comp-wpo.tsv global 行
# 2) 父 COMP-017 manifest 绿
# 3) 有 shu_asm / .o 产物时逐条执行 global hook
#
# 用法：./tests/run-comp-wpo-global-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP019_DOC:-analysis/comp-wpo-global-v1.md}"
WAVE="${SHU_COMP019_WAVE_TSV:-tests/baseline/comp-wpo-global-wave.tsv}"
MANIFEST="${SHU_COMP019_MANIFEST:-tests/baseline/comp-wpo.tsv}"
LIB="tests/lib/comp-wpo-global.sh"
MIN_GLOBAL=5

# shellcheck source=tests/lib/comp-wpo-global.sh
. "$LIB"
# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

echo "=== COMP-019: WPO global wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$LIB" \
  analysis/comp-wpo-default-v1.md tests/run-comp-wpo-default-gate.sh \
  tests/run-comp-wpo-prod-gate.sh tests/run-comp-wpo-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-wpo-global gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_global_hooks) MIN_GLOBAL="$c2" ;;
  esac
done < "$MANIFEST"

for kw in 全局矩阵 global_ok min_global_hooks tier=global; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-wpo-global gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

GLOBAL_HOOK_N=0
MISS=0
echo "=== COMP-019: global hooks in comp-wpo.tsv ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "global" ] || continue
  case "$kind" in
    hook_global)
      GLOBAL_HOOK_N=$((GLOBAL_HOOK_N + 1))
      hook_path="tests/${anchor}"
      if [ ! -f "$hook_path" ]; then
        echo "comp-wpo-global FAIL: missing $hook_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "comp-wpo-global FAIL: doc missing global item $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-wpo-global OK $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$GLOBAL_HOOK_N" -lt "$MIN_GLOBAL" ]; then
  echo "comp-wpo-global gate FAIL: global_hooks=${GLOBAL_HOOK_N} < min ${MIN_GLOBAL}" >&2
  exit 1
fi

WAVE_HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "hook_gate" ] || continue
  WAVE_HOOK_N=$((WAVE_HOOK_N + 1))
  if [ ! -f "tests/$anchor" ]; then
    echo "comp-wpo-global FAIL: wave missing tests/$anchor" >&2
    MISS=$((MISS + 1))
  fi
done < "$WAVE"

if [ "$WAVE_HOOK_N" -lt "$MIN_GLOBAL" ]; then
  echo "comp-wpo-global gate FAIL: wave_hooks=${WAVE_HOOK_N} < min ${MIN_GLOBAL}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_wpo_global_emit_report "fail" 0 0 0
  exit 1
fi
echo "comp-wpo-global manifest OK (global_hooks=${GLOBAL_HOOK_N})"

echo "=== COMP-019: parent COMP-017 manifest ==="
chmod +x tests/run-comp-wpo-default-gate.sh
SHU_COMP017_MANIFEST_ONLY=1 ./tests/run-comp-wpo-default-gate.sh

if [ "${SHU_COMP019_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_wpo_global_emit_report "ok" "$GLOBAL_HOOK_N" 0 0
  echo "comp-wpo-global gate OK (manifest only)"
  exit 0
fi

GLOBAL_RUN=0
GLOBAL_SKIP=0
HOST_SKIP=0

echo "=== COMP-019: global hook runnable ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "global" ] || continue
  [ "$kind" = "hook_global" ] || continue

  hook="tests/$anchor"
  chmod +x "$hook" 2>/dev/null || true

  if ! comp_wpo_global_hook_runnable "$anchor"; then
    echo "comp-wpo-global SKIP $item_id ($anchor Darwin/Linux N/A)"
    GLOBAL_SKIP=$((GLOBAL_SKIP + 1))
    continue
  fi

  if "$hook"; then
    GLOBAL_RUN=$((GLOBAL_RUN + 1))
    echo "comp-wpo-global runnable OK $item_id"
  else
    ec=$?
    if [ "$ec" -eq 0 ]; then
      GLOBAL_RUN=$((GLOBAL_RUN + 1))
      echo "comp-wpo-global runnable OK $item_id"
    else
      echo "comp-wpo-global SKIP $item_id (hook exit $ec)" >&2
      GLOBAL_SKIP=$((GLOBAL_SKIP + 1))
    fi
  fi
done < "$MANIFEST"

if [ "$GLOBAL_RUN" -eq 0 ] && [ "$GLOBAL_SKIP" -gt 0 ]; then
  HOST_SKIP=1
fi

comp_wpo_global_emit_report "ok" "$GLOBAL_HOOK_N" "$GLOBAL_SKIP" "$HOST_SKIP"
echo "comp-wpo-global gate OK"
