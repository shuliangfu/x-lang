#!/usr/bin/env bash
# STD-088：std.trace 门禁（F-trace v2：纯 trace.x）
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_TRACE_DOC:-analysis/std-trace-v1.md}"
MANIFEST="${SHUX_STD_TRACE_MANIFEST:-tests/baseline/std-trace-manifest.tsv}"
MOD_X="std/trace/mod.x"
TRACE_X="std/trace/trace.x"
LIB="tests/lib/std-trace.sh"
SMOKE_X="tests/std-trace/nested_smoke.x"
SMOKE_C="tests/std-trace/trace_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-trace.sh
. "$LIB"

echo "=== STD-088: std.trace manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TRACE_X" "$SMOKE_X" "$SMOKE_C" std/trace/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-trace gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-088 span_start_child attach_to_context export_text trace_id; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-trace gate FAIL: doc missing '$kw'" >&2
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
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-trace gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-trace gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_trace_symbols_ok "$MOD_X" "$TRACE_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_trace_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-trace manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-088: trace c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/trace/trace.o 2>/dev/null && std_trace_run_c_smoke "$TRACE_X"; then
    C_OK=1
  else
    echo "std-trace gate SKIP c smoke (no full trace.o)" >&2
  fi
else
  echo "std-trace gate SKIP c smoke (no shux-c)" >&2
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-088: .x smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-trace gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_trace_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_trace_run_smoke "$SHUX_BIN" "$SMOKE_X" "nested"; then X_OK=1; else
    std_trace_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_trace_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-trace gate OK"
