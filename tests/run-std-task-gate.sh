#!/usr/bin/env bash
# STD-089：std.task 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_TASK_DOC:-analysis/std-task-v1.md}"
MANIFEST="${SHUX_STD_TASK_MANIFEST:-tests/baseline/std-task-manifest.tsv}"
MOD_SU="std/task/mod.sx"
TASK_C="std/task/task.c"
LIB="tests/lib/std-task.sh"
SMOKE_SU="tests/std-task/group_smoke.sx"
SMOKE_C="tests/std-task/task_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-task.sh
. "$LIB"

echo "=== STD-089: std.task manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$TASK_C" "$SMOKE_SU" "$SMOKE_C" std/task/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-task gate FAIL: missing $f" >&2
    exit 1
  fi
done

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
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-task gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-task gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_task_symbols_ok "$MOD_SU" "$TASK_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_task_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-task manifest OK"

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-089: task c smoke ==="
make -C compiler ../std/task/task.o ../std/async/scheduler.o ../std/context/context.o ../std/time/time.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shux_task_smoke \
  "$SMOKE_C" std/task/task.o std/async/scheduler.o std/context/context.o std/time/time.o 2>/dev/null; then
  if /tmp/shux_task_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shux_task_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_task_emit_report "fail" 0 0 0
  echo "std-task gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-089: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-task gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_task_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_task_run_smoke "$SHUX_BIN" "$SMOKE_SU" "group"; then SU_OK=1; else
    std_task_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_task_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-task gate OK"
