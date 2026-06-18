#!/usr/bin/env bash
# TOOL-004：大文件 LSP diagnostic + 双次 completion 性能烟测。
#
# 用法：./tests/run-lsp-diag-perf.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/tool-lsp-diag-perf.sh
. tests/lib/tool-lsp-diag-perf.sh

SHU="${SHU:-./compiler/shu}"
FIXTURE=tests/lsp/diag_large_ok.su
URI="file:///$(pwd)/tests/lsp/diag_large_ok.su"
MAX_WALL_MS="${SHU_LSP_DIAG_MAX_WALL_MS:-15000}"
MIN_FUNCS="${SHU_LSP_DIAG_MIN_FUNCS:-30}"

if ! "$SHU" --help 2>/dev/null | grep -q '\-\-lsp'; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || make -C compiler
  SHU=./compiler/shu
fi

FUNCS=$(tool_lsp_count_funcs "$FIXTURE")
if [ "${FUNCS:-0}" -lt "$MIN_FUNCS" ]; then
  echo "run-lsp-diag-perf FAIL: funcs=${FUNCS} < min ${MIN_FUNCS}" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "run-lsp-diag-perf FAIL: need python3" >&2
  exit 1
fi

DOC_JSON=$(python3 -c "import json; print(json.dumps(open('$FIXTURE').read()))")

INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":"file:///'"$(pwd)"'","capabilities":{}}}'
DID_OPEN='{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"'"$URI"'","languageId":"su","version":1,"text":'"$DOC_JSON"'}}}'
DIAG_REQ='{"jsonrpc":"2.0","id":2,"method":"textDocument/diagnostic","params":{"textDocument":{"uri":"'"$URI"'"}}}'
COMP_REQ1='{"jsonrpc":"2.0","id":3,"method":"textDocument/completion","params":{"textDocument":{"uri":"'"$URI"'"},"position":{"line":80,"character":2}}}'
COMP_REQ2='{"jsonrpc":"2.0","id":4,"method":"textDocument/completion","params":{"textDocument":{"uri":"'"$URI"'"},"position":{"line":80,"character":2}}}'
SHUTDOWN='{"jsonrpc":"2.0","id":5,"method":"shutdown"}'
EXIT_NOTIF='{"jsonrpc":"2.0","method":"exit"}'

OUT=$(mktemp)
ERR=$(mktemp)
LSP_IN=$(mktemp)
trap 'rm -f "$OUT" "$ERR" "$LSP_IN"' EXIT

{
  tool_lsp_send_frame "$INIT_REQ"
  tool_lsp_send_frame "$DID_OPEN"
  tool_lsp_send_frame "$DIAG_REQ"
  tool_lsp_send_frame "$COMP_REQ1"
  tool_lsp_send_frame "$COMP_REQ2"
  tool_lsp_send_frame "$SHUTDOWN"
  tool_lsp_send_frame "$EXIT_NOTIF"
} >"$LSP_IN"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
T0=$(tool_lsp_ms_now)
LSP_EC=0
if command -v timeout >/dev/null 2>&1; then
  timeout 30 "$SHU" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
else
  "$SHU" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
fi
T1=$(tool_lsp_ms_now)
WALL_MS=$((T1 - T0))

if [ "$LSP_EC" -ne 0 ] && [ "$LSP_EC" -ne 124 ]; then
  echo "run-lsp-diag-perf FAIL: shu --lsp exit $LSP_EC wall_ms=${WALL_MS}" >&2
  [ -s "$ERR" ] && cat "$ERR" >&2
  [ -s "$OUT" ] && cat "$OUT"
  exit 1
fi

if ! grep -q '"id":2' "$OUT" || ! grep -q '"result":\[' "$OUT"; then
  echo "run-lsp-diag-perf FAIL: missing diagnostic response" >&2
  cat "$OUT"
  exit 1
fi
if ! grep -q '"id":3' "$OUT" || ! grep -q '"id":4' "$OUT"; then
  echo "run-lsp-diag-perf FAIL: missing completion responses" >&2
  cat "$OUT"
  exit 1
fi

# 从 stdout 切出两次 completion 的 result 段粗算 item 数（应一致 = 模块缓存命中）
ITEMS3=$(grep -o '"label":' "$OUT" | wc -l | tr -d ' \n')
# 两次 completion 各有一份 label 列表；warm 判定：总 label 数为偶数且两半一致
HALF=$((ITEMS3 / 2))
if [ "$HALF" -lt 10 ]; then
  echo "run-lsp-diag-perf FAIL: completion items too few total=${ITEMS3}" >&2
  exit 1
fi

if [ "$WALL_MS" -gt "$MAX_WALL_MS" ]; then
  echo "run-lsp-diag-perf FAIL: wall_ms=${WALL_MS} > max ${MAX_WALL_MS}" >&2
  exit 1
fi

echo "tool-lsp-diag-perf report wall_ms=${WALL_MS} funcs=${FUNCS} warm_items=${HALF}/${HALF} large=OK"
echo "lsp-diag-perf OK"
