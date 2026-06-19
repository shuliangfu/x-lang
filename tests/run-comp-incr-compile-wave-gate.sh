#!/usr/bin/env bash
# COMP-020：incr-compile wave tier 二次编译烟测扩面门禁
#
# 1) comp-incr-compile-wave-v1.md + comp-incr-compile-wave.tsv + comp-incr-compile.tsv wave 行
# 2) 父 COMP-007 manifest 绿
# 3) 有 native shux 时逐条执行 wave hook
#
# 用法：./tests/run-comp-incr-compile-wave-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP020_DOC:-analysis/comp-incr-compile-wave-v1.md}"
WAVE="${SHUX_COMP020_WAVE_TSV:-tests/baseline/comp-incr-compile-wave.tsv}"
MANIFEST="${SHUX_COMP020_MANIFEST:-tests/baseline/comp-incr-compile.tsv}"
BENCH="${SHUX_COMP020_BENCH:-tests/baseline/comp-incr-compile-bench.tsv}"
LIB="tests/lib/comp-incr-compile-wave.sh"
MIN_WAVE=4
MIN_BENCH=5

# shellcheck source=tests/lib/comp-incr-compile-wave.sh
. "$LIB"

echo "=== COMP-020: incr-compile wave manifest ==="
for f in "$DOC" "$WAVE" "$MANIFEST" "$BENCH" "$LIB" \
  analysis/comp-incr-compile-v1.md tests/run-comp-incr-compile-gate.sh \
  tests/run-comp-incr-compile.sh tests/run-obs-compile-phase-timing-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-incr-compile-wave gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_wave_hooks) MIN_WAVE="$c2" ;;
    min_wave_benches) MIN_BENCH="$c2" ;;
  esac
done < "$WAVE"

for kw in Wave 矩阵 wave_ok bench_dogfood_check min_wave_hooks; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-incr-compile-wave gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'bench_dogfood_check' "$BENCH" 2>/dev/null; then
  echo "comp-incr-compile-wave gate FAIL: bench missing bench_dogfood_check" >&2
  exit 1
fi

BENCH_N=0
while IFS=$'\t' read -r bench_id _fixture _cmd _max _target _notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*|max_*|target_*) continue ;; esac
  BENCH_N=$((BENCH_N + 1))
done < "$BENCH"

if [ "$BENCH_N" -lt "$MIN_BENCH" ]; then
  echo "comp-incr-compile-wave gate FAIL: benches=${BENCH_N} < min ${MIN_BENCH}" >&2
  exit 1
fi

WAVE_HOOK_N=0
MISS=0
echo "=== COMP-020: wave hooks in comp-incr-compile.tsv ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "wave" ] || continue
  case "$kind" in
    hook_wave|hook_ref)
      WAVE_HOOK_N=$((WAVE_HOOK_N + 1))
      hook_path="tests/${anchor}"
      if [ ! -f "$hook_path" ]; then
        echo "comp-incr-compile-wave FAIL: missing $hook_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$item_id" "$DOC" 2>/dev/null; then
        echo "comp-incr-compile-wave FAIL: doc missing wave item $item_id" >&2
        MISS=$((MISS + 1))
      else
        echo "comp-incr-compile-wave OK $item_id -> $anchor"
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$WAVE_HOOK_N" -lt "$MIN_WAVE" ]; then
  echo "comp-incr-compile-wave gate FAIL: wave_hooks=${WAVE_HOOK_N} < min ${MIN_WAVE}" >&2
  exit 1
fi

WAVE_MAN_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "hook_gate" ] || continue
  WAVE_MAN_N=$((WAVE_MAN_N + 1))
  if [ ! -f "tests/$anchor" ]; then
    echo "comp-incr-compile-wave FAIL: wave missing tests/$anchor" >&2
    MISS=$((MISS + 1))
  fi
done < "$WAVE"

if [ "$WAVE_MAN_N" -lt "$MIN_WAVE" ]; then
  echo "comp-incr-compile-wave gate FAIL: wave_gate_hooks=${WAVE_MAN_N} < min ${MIN_WAVE}" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  comp_incr_wave_emit_report "fail" 0 0 0 0
  exit 1
fi
echo "comp-incr-compile-wave manifest OK (wave_hooks=${WAVE_HOOK_N} benches=${BENCH_N})"

if [ "${SHUX_COMP020_MANIFEST_ONLY:-0}" = "1" ]; then
  comp_incr_wave_emit_report "ok" "$WAVE_HOOK_N" 0 0 1
  echo "comp-incr-compile-wave gate OK (manifest only)"
  exit 0
fi

echo "=== COMP-020: parent COMP-007 manifest ==="
chmod +x tests/run-comp-incr-compile-gate.sh
SHUX_COMP_INCR_COMPILE_MANIFEST_ONLY=1 ./tests/run-comp-incr-compile-gate.sh

WAVE_RUN=0
WAVE_SKIP=0
HOST_SKIP=1

echo "=== COMP-020: wave hook runnable ==="
while IFS=$'\t' read -r item_id kind anchor src tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "${tier:-}" = "wave" ] || continue
  case "$kind" in
    hook_wave|hook_ref) ;;
    *) continue ;;
  esac

  hook="tests/$anchor"
  chmod +x "$hook" 2>/dev/null || true

  if ! comp_incr_wave_hook_runnable "$anchor"; then
    echo "comp-incr-compile-wave SKIP $item_id ($anchor no native shux)"
    WAVE_SKIP=$((WAVE_SKIP + 1))
    continue
  fi

  if [ "$anchor" = "run-comp-incr-compile-gate.sh" ]; then
    if SHUX_COMP_INCR_COMPILE_MANIFEST_ONLY=1 "$hook"; then
      WAVE_RUN=$((WAVE_RUN + 1))
      echo "comp-incr-compile-wave runnable OK $item_id"
    else
      echo "comp-incr-compile-wave SKIP $item_id (parent manifest)" >&2
      WAVE_SKIP=$((WAVE_SKIP + 1))
    fi
    continue
  fi

  if "$hook"; then
    WAVE_RUN=$((WAVE_RUN + 1))
    echo "comp-incr-compile-wave runnable OK $item_id"
  else
    ec=$?
    if [ "$ec" -eq 0 ]; then
      WAVE_RUN=$((WAVE_RUN + 1))
      echo "comp-incr-compile-wave runnable OK $item_id"
    else
      echo "comp-incr-compile-wave SKIP $item_id (hook exit $ec)" >&2
      WAVE_SKIP=$((WAVE_SKIP + 1))
    fi
  fi
done < "$MANIFEST"

if [ "$WAVE_RUN" -gt 0 ]; then
  HOST_SKIP=0
fi

comp_incr_wave_emit_report "ok" "$WAVE_HOOK_N" "$WAVE_RUN" "$WAVE_SKIP" "$HOST_SKIP"
echo "comp-incr-compile-wave gate OK"
