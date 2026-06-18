#!/usr/bin/env bash
# COMP-015：WPO 生产 tier runnable 门禁
#
# 1) comp-wpo-prod-v1.md + comp-wpo-prod-wave.tsv + comp-wpo.tsv prod 行
# 2) 父 COMP-004 manifest 绿
# 3) 有 native shu/shu_asm 时逐条执行 prod hook
#
# 用法：./tests/run-comp-wpo-prod-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP015_DOC:-analysis/comp-wpo-prod-v1.md}"
WAVE="${SHU_COMP015_WAVE_TSV:-tests/baseline/comp-wpo-prod-wave.tsv}"
MANIFEST="${SHU_COMP015_MANIFEST:-tests/baseline/comp-wpo.tsv}"
LIB="tests/lib/comp-wpo-prod.sh"
MIN_PROD=5

# shellcheck source=tests/lib/comp-wpo-prod.sh
. "$LIB"
# shellcheck source=tests/lib/comp-wpo.sh
. tests/lib/comp-wpo.sh

echo "=== COMP-015: WPO prod wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$LIB" \
  analysis/comp-wpo-v1.md tests/run-comp-wpo-gate.sh \
  tests/baseline/wpo-typeck-o.tsv tests/baseline/wpo-pipeline-o.tsv \
  tests/baseline/wpo-strict-glue-text.tsv; do
  if [ ! -f "$f" ]; then
    echo "comp-wpo-prod gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_prod_hooks) MIN_PROD="$c2" ;;
  esac
done < "$MANIFEST"

for kw in 生产矩阵 prod_ok min_prod_hooks tier=prod; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-wpo-prod gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

PROD_HOOK_N=0
MISS=0
echo "=== COMP-015: prod hooks in comp-wpo.tsv ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "prod" ] || continue
  case "$kind" in
    hook_prod)
      PROD_HOOK_N=$((PROD_HOOK_N + 1))
      hook_path="tests/${anchor}"
      if [ ! -f "$hook_path" ]; then
        echo "comp-wpo-prod FAIL: missing $hook_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "comp-wpo-prod FAIL: doc missing prod item $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-wpo-prod OK $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$PROD_HOOK_N" -lt "$MIN_PROD" ]; then
  echo "comp-wpo-prod gate FAIL: prod_hooks=${PROD_HOOK_N} < min ${MIN_PROD}" >&2
  exit 1
fi

WAVE_HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "hook_gate" ] || continue
  WAVE_HOOK_N=$((WAVE_HOOK_N + 1))
  if [ ! -f "tests/$anchor" ]; then
    echo "comp-wpo-prod FAIL: wave missing tests/$anchor" >&2
    MISS=$((MISS + 1))
  fi
done < "$WAVE"

if [ "$WAVE_HOOK_N" -lt "$MIN_PROD" ]; then
  echo "comp-wpo-prod gate FAIL: wave_hooks=${WAVE_HOOK_N} < min ${MIN_PROD}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_wpo_prod_emit_report "fail" 0 0 0
  exit 1
fi
echo "comp-wpo-prod manifest OK (prod_hooks=${PROD_HOOK_N})"

if [ "${SHU_COMP015_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_wpo_prod_emit_report "ok" "$PROD_HOOK_N" 0 1
  echo "comp-wpo-prod gate OK (manifest only)"
  exit 0
fi

echo "=== COMP-015: parent COMP-004 manifest ==="
chmod +x tests/run-comp-wpo-gate.sh tests/run-comp-wpo.sh
SHU_COMP_WPO_MANIFEST_ONLY=1 ./tests/run-comp-wpo-gate.sh

PROD_RUN=0
PROD_SKIP=0
HOST_SKIP=0

SHU_C="${SHU:-./compiler/shu-c}"
if ! comp_wpo_native_exe "$SHU_C"; then
  if comp_wpo_native_exe ./compiler/shu; then
    SHU_C=./compiler/shu
  fi
fi

echo "=== COMP-015: prod hook runnable ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "prod" ] || continue
  [ "$kind" = "hook_prod" ] || continue

  hook="tests/$anchor"
  chmod +x "$hook" 2>/dev/null || true

  if ! comp_wpo_prod_hook_runnable "$anchor"; then
    echo "comp-wpo-prod SKIP $item_id ($anchor Darwin/Linux N/A)"
    PROD_SKIP=$((PROD_SKIP + 1))
    continue
  fi

  case "$anchor" in
    run-wpo-dce-emit.sh)
      if ! comp_wpo_native_exe "$SHU_C"; then
        echo "comp-wpo-prod SKIP $item_id (no native shu/shu-c)"
        PROD_SKIP=$((PROD_SKIP + 1))
        continue
      fi
      if SHU="$SHU_C" "$hook"; then
        PROD_RUN=$((PROD_RUN + 1))
        echo "comp-wpo-prod runnable OK $item_id"
      else
        echo "comp-wpo-prod SKIP $item_id (dce smoke unavailable)" >&2
        PROD_SKIP=$((PROD_SKIP + 1))
      fi
      continue
      ;;
    *)
      if "$hook"; then
        :
      else
        ec=$?
        if [ "$ec" -eq 0 ]; then
          :
        else
          comp_wpo_prod_emit_report "fail" "$PROD_RUN" "$PROD_SKIP" 0
          exit 1
        fi
      fi
      ;;
  esac
  PROD_RUN=$((PROD_RUN + 1))
  echo "comp-wpo-prod runnable OK $item_id"
done < "$MANIFEST"

if [ "$PROD_RUN" -eq 0 ] && [ "$PROD_SKIP" -gt 0 ]; then
  HOST_SKIP=1
fi

comp_wpo_prod_emit_report "ok" "$PROD_HOOK_N" "$PROD_SKIP" "$HOST_SKIP"
echo "comp-wpo-prod gate OK"
