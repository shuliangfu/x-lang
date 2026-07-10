#!/usr/bin/env bash
# OBS-003：统一结构化日志 manifest + 烟测门禁
#
# 1) obs-structured-log-v1.md + manifest
# 2) log.c / mod.x 符号；registry bracket 组件可 grep
# 3) obs_structured_log_smoke.c 输出合法结构化行
#
# 用法：./tests/run-obs-structured-log-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_OBS_STRUCT_LOG_DOC:-analysis/obs-structured-log-v1.md}"
MANIFEST="${SHUX_OBS_STRUCT_LOG_TSV:-tests/baseline/obs-structured-log.tsv}"
LOG_X="std/log/log.x"
LOG_RUNTIME="compiler/seeds/runtime_log_os.from_x.c"
LOG_X="std/log/mod.x"
SMOKE="tests/bench/obs_structured_log_smoke.c"
LOG_O="std/log/log.o"
MIN_COMP=6

# shellcheck source=tests/lib/obs-structured-log.sh
. tests/lib/obs-structured-log.sh

echo "=== OBS-003: structured log manifest ==="
for f in "$DOC" "$MANIFEST" "$LOG_X" "$LOG_RUNTIME" "$LOG_X" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "obs-structured-log gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_components) MIN_COMP="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
COMP=0
echo "=== OBS-003: manifest anchors ==="
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|line_prefix) continue ;; esac
  case "$kind" in
    section|field)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    runtime_fn)
      if ! grep -qF "$anchor" "$LOG_X" 2>/dev/null && ! grep -qF "$anchor" "$LOG_RUNTIME" 2>/dev/null; then
        echo "obs-structured-log FAIL: ${anchor} not in log.x/runtime_log_os.inc" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    su_fn)
      if ! grep -qF "$anchor" "$LOG_X" 2>/dev/null; then
        echo "obs-structured-log FAIL: ${anchor} not in $LOG_X" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    bracket_component)
      COMP=$((COMP + 1))
      if ! grep -rqF "shux: [$anchor]" . \
        --include='*.c' --include='*.sh' --include='*.x' 2>/dev/null; then
        echo "obs-structured-log FAIL: bracket component $anchor not found in tree" >&2
        MISS=$((MISS + 1))
      else
        echo "obs-structured-log OK bracket $anchor"
      fi
      ;;
    struct_component)
      COMP=$((COMP + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing struct component $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "obs-structured-log FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "obs-structured-log FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "obs-structured-log FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$COMP" -lt "$MIN_COMP" ]; then
  echo "obs-structured-log gate FAIL: components=${COMP} < min ${MIN_COMP}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "obs-structured-log gate FAIL: missing=${MISS}" >&2
  exit 1
fi

for kw in key=value 机器聚合 level=info component=; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "obs-structured-log gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
echo "obs-structured-log manifest OK (components=${COMP})"

echo "=== OBS-003: structured log smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/log/log.o runtime_log_os.o -q 2>/dev/null || make -C compiler ../std/log/log.o runtime_log_os.o
else
  echo "obs-structured-log gate SKIP smoke (no shux-c)" >&2
  echo "obs-structured-log gate OK"
  exit 0
fi
if [ ! -f "$LOG_O" ]; then
  echo "obs-structured-log gate FAIL: missing $LOG_O" >&2
  exit 1
fi
SMOKE_BIN="/tmp/shux_obs_struct_log_smoke_$$"
cc -std=gnu11 -Wall -Wextra -o "$SMOKE_BIN" "$SMOKE" "$LOG_O" compiler/runtime_log_os.o 2>/tmp/obs_struct_log_build.log || {
  cat /tmp/obs_struct_log_build.log >&2
  echo "obs-structured-log gate FAIL: smoke compile" >&2
  rm -f "$SMOKE_BIN"
  exit 1
}
"$SMOKE_BIN" 2>/tmp/obs_struct_log_run.log || {
  cat /tmp/obs_struct_log_run.log >&2
  echo "obs-structured-log gate FAIL: smoke run" >&2
  rm -f "$SMOKE_BIN"
  exit 1
}
rm -f "$SMOKE_BIN"
LINE=$(head -1 /tmp/obs_struct_log_run.log)
if ! obs_struct_log_line_valid "$LINE"; then
  echo "obs-structured-log gate FAIL: invalid structured line: $LINE" >&2
  exit 1
fi
grep -qF 'component=obs_smoke' /tmp/obs_struct_log_run.log || {
  echo "obs-structured-log gate FAIL: missing component=obs_smoke" >&2
  exit 1
}
echo "obs-structured-log smoke OK"
echo "obs-structured-log gate OK"
