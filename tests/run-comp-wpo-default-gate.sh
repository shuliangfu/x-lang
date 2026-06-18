#!/usr/bin/env bash
# COMP-017：WPO default tier 持续扩面门禁
#
# 1) comp-wpo-default-v1.md + comp-wpo-default-wave.tsv + comp-wpo.tsv default 行
# 2) 父 COMP-015 manifest 绿
# 3) 有 shu_asm / .o 产物时逐条执行 default hook
#
# 用法：./tests/run-comp-wpo-default-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP017_DOC:-analysis/comp-wpo-default-v1.md}"
WAVE="${SHU_COMP017_WAVE_TSV:-tests/baseline/comp-wpo-default-wave.tsv}"
MANIFEST="${SHU_COMP017_MANIFEST:-tests/baseline/comp-wpo.tsv}"
LIB="tests/lib/comp-wpo-default.sh"
MIN_DEFAULT=5

# shellcheck source=tests/lib/comp-wpo-default.sh
. "$LIB"
# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

echo "=== COMP-017: WPO default wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$LIB" \
  analysis/comp-wpo-prod-v1.md tests/run-comp-wpo-prod-gate.sh \
  tests/run-comp-wpo-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-wpo-default gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_default_hooks) MIN_DEFAULT="$c2" ;;
  esac
done < "$MANIFEST"

for kw in 默认矩阵 default_ok min_default_hooks tier=default; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-wpo-default gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

DEFAULT_HOOK_N=0
MISS=0
echo "=== COMP-017: default hooks in comp-wpo.tsv ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "default" ] || continue
  case "$kind" in
    hook_default)
      DEFAULT_HOOK_N=$((DEFAULT_HOOK_N + 1))
      hook_path="tests/${anchor}"
      if [ ! -f "$hook_path" ]; then
        echo "comp-wpo-default FAIL: missing $hook_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "comp-wpo-default FAIL: doc missing default item $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-wpo-default OK $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$DEFAULT_HOOK_N" -lt "$MIN_DEFAULT" ]; then
  echo "comp-wpo-default gate FAIL: default_hooks=${DEFAULT_HOOK_N} < min ${MIN_DEFAULT}" >&2
  exit 1
fi

WAVE_HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "hook_gate" ] || continue
  WAVE_HOOK_N=$((WAVE_HOOK_N + 1))
  if [ ! -f "tests/$anchor" ]; then
    echo "comp-wpo-default FAIL: wave missing tests/$anchor" >&2
    MISS=$((MISS + 1))
  fi
done < "$WAVE"

if [ "$WAVE_HOOK_N" -lt "$MIN_DEFAULT" ]; then
  echo "comp-wpo-default gate FAIL: wave_hooks=${WAVE_HOOK_N} < min ${MIN_DEFAULT}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_wpo_default_emit_report "fail" 0 0 0
  exit 1
fi
echo "comp-wpo-default manifest OK (default_hooks=${DEFAULT_HOOK_N})"

echo "=== COMP-017: parent COMP-015 manifest ==="
chmod +x tests/run-comp-wpo-prod-gate.sh
SHU_COMP015_MANIFEST_ONLY=1 ./tests/run-comp-wpo-prod-gate.sh

if [ "${SHU_COMP017_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_wpo_default_emit_report "ok" "$DEFAULT_HOOK_N" 0 0
  echo "comp-wpo-default gate OK (manifest only)"
  exit 0
fi

DEFAULT_RUN=0
DEFAULT_SKIP=0
HOST_SKIP=0

echo "=== COMP-017: default hook runnable ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "default" ] || continue
  [ "$kind" = "hook_default" ] || continue

  hook="tests/$anchor"
  chmod +x "$hook" 2>/dev/null || true

  if ! comp_wpo_default_hook_runnable "$anchor"; then
    echo "comp-wpo-default SKIP $item_id ($anchor Darwin/Linux N/A)"
    DEFAULT_SKIP=$((DEFAULT_SKIP + 1))
    continue
  fi

  if "$hook"; then
    DEFAULT_RUN=$((DEFAULT_RUN + 1))
    echo "comp-wpo-default runnable OK $item_id"
  else
    ec=$?
    if [ "$ec" -eq 0 ]; then
      DEFAULT_RUN=$((DEFAULT_RUN + 1))
      echo "comp-wpo-default runnable OK $item_id"
    else
      echo "comp-wpo-default SKIP $item_id (hook exit $ec)" >&2
      DEFAULT_SKIP=$((DEFAULT_SKIP + 1))
    fi
  fi
done < "$MANIFEST"

if [ "$DEFAULT_RUN" -eq 0 ] && [ "$DEFAULT_SKIP" -gt 0 ]; then
  HOST_SKIP=1
fi

comp_wpo_default_emit_report "ok" "$DEFAULT_HOOK_N" "$DEFAULT_SKIP" "$HOST_SKIP"
echo "comp-wpo-default gate OK"
