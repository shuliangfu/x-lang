#!/usr/bin/env bash
# STD-089：std.task 门禁（F-task v2：纯 task.sx）
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_TASK_DOC:-analysis/std-task-v1.md}"
MANIFEST="${SHUX_STD_TASK_MANIFEST:-tests/baseline/std-task-manifest.tsv}"
MOD_SX="std/task/mod.sx"
TASK_SX="std/task/task.sx"
LIB="tests/lib/std-task.sh"
SMOKE_SX="tests/std-task/group_smoke.sx"
SMOKE_C="tests/std-task/task_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-task.sh
. "$LIB"

echo "=== STD-089: std.task manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$TASK_SX" "$SMOKE_SX" "$SMOKE_C" std/task/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-task gate FAIL: missing $f" >&2
    exit 1
  fi
done
if [ -f std/task/task_async_glue.c ]; then
  echo "std-task gate FAIL: task_async_glue.c should be deleted (F-task v2)" >&2
  exit 1
fi

for kw in STD-089 task_group_spawn task_group_check_leak supervise_retry join_set; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-task gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_SX" 2>/dev/null; then
    echo "std-task gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-task gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_task_symbols_ok "$MOD_SX" "$TASK_SX" "" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_task_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-task manifest OK"

C_OK=0
SX_OK=0
SKIP=0

echo "=== STD-089: task c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/task/task.o 2>/dev/null \
    && ensure_std_c_o ../std/async/scheduler.o 2>/dev/null \
    && ensure_std_c_o ../std/context/context.o 2>/dev/null \
    && ensure_std_c_o ../std/time/time.o 2>/dev/null \
    && std_task_run_c_smoke "$TASK_SX"; then
    C_OK=1
  else
    echo "std-task gate SKIP c smoke (no full task.o)" >&2
  fi
else
  echo "std-task gate SKIP c smoke (no shux-c)" >&2
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-089: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-task gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_task_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_task_run_smoke "$SHUX_BIN" "$SMOKE_SX" "group"; then SX_OK=1; else
    std_task_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_task_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-task gate OK"
