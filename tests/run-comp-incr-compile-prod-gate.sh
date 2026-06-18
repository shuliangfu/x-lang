#!/usr/bin/env bash
# COMP-021：incr-compile prod tier 生产烟测门禁
#
# 1) comp-incr-compile-prod-v1.md + comp-incr-compile-prod-wave.tsv + comp-incr-compile.tsv prod 行
# 2) 父 COMP-020 manifest 绿
# 3) 有 native shu 时逐条执行 prod hook
#
# 用法：./tests/run-comp-incr-compile-prod-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP021_DOC:-analysis/comp-incr-compile-prod-v1.md}"
WAVE="${SHU_COMP021_WAVE_TSV:-tests/baseline/comp-incr-compile-prod-wave.tsv}"
MANIFEST="${SHU_COMP021_MANIFEST:-tests/baseline/comp-incr-compile.tsv}"
BENCH="${SHU_COMP021_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
LIB="tests/lib/comp-incr-compile-prod.sh"
MIN_PROD=4

# shellcheck source=tests/lib/comp-incr-compile-prod.sh
. "$LIB"

echo "=== COMP-021: incr-compile prod manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$BENCH" "$LIB" \
  analysis/comp-incr-compile-wave-v1.md tests/run-comp-incr-compile-wave-gate.sh \
  tests/run-comp-incr-compile-gate.sh tests/run-comp-incr-compile.sh \
  tests/run-obs-compile-phase-timing-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-incr-compile-prod gate FAIL: missing $f" >&2
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
    echo "comp-incr-compile-prod gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

PROD_HOOK_N=0
MISS=0
echo "=== COMP-021: prod hooks in comp-incr-compile.tsv ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "prod" ] || continue
  case "$kind" in
    hook_prod|hook_ref)
      PROD_HOOK_N=$((PROD_HOOK_N + 1))
      hook_path="tests/${anchor}"
      if [ ! -f "$hook_path" ]; then
        echo "comp-incr-compile-prod FAIL: missing $hook_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile-prod FAIL: doc missing prod item $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-incr-compile-prod OK $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$PROD_HOOK_N" -lt "$MIN_PROD" ]; then
  echo "comp-incr-compile-prod gate FAIL: prod_hooks=${PROD_HOOK_N} < min ${MIN_PROD}" >&2
  exit 1
fi

WAVE_HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "hook_gate" ] || continue
  WAVE_HOOK_N=$((WAVE_HOOK_N + 1))
  if [ ! -f "tests/$anchor" ]; then
    echo "comp-incr-compile-prod FAIL: prod wave missing tests/$anchor" >&2
    MISS=$((MISS + 1))
  fi
done < "$WAVE"

if [ "$WAVE_HOOK_N" -lt "$MIN_PROD" ]; then
  echo "comp-incr-compile-prod gate FAIL: prod_gate_hooks=${WAVE_HOOK_N} < min ${MIN_PROD}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_incr_prod_emit_report "fail" 0 0 0 0
  exit 1
fi
echo "comp-incr-compile-prod manifest OK (prod_hooks=${PROD_HOOK_N})"

echo "=== COMP-021: parent COMP-020 manifest ==="
chmod +x tests/run-comp-incr-compile-wave-gate.sh
SHU_COMP020_MANIFEST_ONLY=1 ./tests/run-comp-incr-compile-wave-gate.sh

if [ "${SHU_COMP021_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_incr_prod_emit_report "ok" "$PROD_HOOK_N" 0 0 1
  echo "comp-incr-compile-prod gate OK (manifest only)"
  exit 0
fi

PROD_RUN=0
PROD_SKIP=0
HOST_SKIP=1

echo "=== COMP-021: prod hook runnable ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "prod" ] || continue
  case "$kind" in
    hook_prod|hook_ref) ;;
    *) continue ;;
  esac

  hook="tests/$anchor"
  chmod +x "$hook" 2>/dev/null || true

  if ! comp_incr_prod_hook_runnable "$anchor"; then
    echo "comp-incr-compile-prod SKIP $item_id ($anchor no native shu)"
    PROD_SKIP=$((PROD_SKIP + 1))
    continue
  fi

  if [ "$anchor" = "run-comp-incr-compile-gate.sh" ]; then
    if SHU_COMP_INCR_COMPILE_MANIFEST_ONLY=1 "$hook"; then
      PROD_RUN=$((PROD_RUN + 1))
      echo "comp-incr-compile-prod runnable OK $item_id"
    else
      echo "comp-incr-compile-prod SKIP $item_id (parent manifest)" >&2
      PROD_SKIP=$((PROD_SKIP + 1))
    fi
    continue
  fi

  if [ "$anchor" = "run-comp-incr-compile-wave-gate.sh" ]; then
    if SHU_COMP020_MANIFEST_ONLY=1 "$hook"; then
      PROD_RUN=$((PROD_RUN + 1))
      echo "comp-incr-compile-prod runnable OK $item_id"
    else
      echo "comp-incr-compile-prod SKIP $item_id (wave parent)" >&2
      PROD_SKIP=$((PROD_SKIP + 1))
    fi
    continue
  fi

  if "$hook"; then
    PROD_RUN=$((PROD_RUN + 1))
    echo "comp-incr-compile-prod runnable OK $item_id"
  else
    ec=$?
    if [ "$ec" -eq 0 ]; then
      PROD_RUN=$((PROD_RUN + 1))
      echo "comp-incr-compile-prod runnable OK $item_id"
    else
      echo "comp-incr-compile-prod SKIP $item_id (hook exit $ec)" >&2
      PROD_SKIP=$((PROD_SKIP + 1))
    fi
  fi
done < "$MANIFEST"

if [ "$PROD_RUN" -gt 0 ]; then
  HOST_SKIP=0
fi

comp_incr_prod_emit_report "ok" "$PROD_HOOK_N" "$PROD_RUN" "$PROD_SKIP" "$HOST_SKIP"
echo "comp-incr-compile-prod gate OK"
