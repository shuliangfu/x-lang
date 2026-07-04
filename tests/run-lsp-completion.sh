#!/usr/bin/env bash
# TOOL-003：LSP textDocument/completion 烟测（C1–C6 六类符号命中）。
#
# 用法：./tests/run-lsp-completion.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/tool-lsp-completion.sh
. tests/lib/tool-lsp-completion.sh

SHUX="${SHUX:-./compiler/shux}"
FIXTURE=tests/lsp/completion_symbols.x
URI="file:///$(pwd)/tests/lsp/completion_symbols.x"

if ! "$SHUX" --help 2>/dev/null | grep -q '\-\-lsp'; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || make -C compiler
  SHUX=./compiler/shux
fi

if command -v python3 >/dev/null 2>&1; then
  DOC_JSON=$(python3 -c "import json; print(json.dumps(open('$FIXTURE').read()))")
else
  echo "run-lsp-completion FAIL: need python3 for JSON escape" >&2
  exit 1
fi

INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":"file:///'"$(pwd)"'","capabilities":{}}}'
DID_OPEN='{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"'"$URI"'","languageId":"su","version":1,"text":'"$DOC_JSON"'}}}'
# 光标在 main 函数体 return 行（0-based line 18）
COMP_REQ='{"jsonrpc":"2.0","id":2,"method":"textDocument/completion","params":{"textDocument":{"uri":"'"$URI"'"},"position":{"line":18,"character":2}}}'
SHUTDOWN='{"jsonrpc":"2.0","id":3,"method":"shutdown"}'
EXIT_NOTIF='{"jsonrpc":"2.0","method":"exit"}'

OUT=$(mktemp)
ERR=$(mktemp)
LSP_IN=$(mktemp)
trap 'rm -f "$OUT" "$ERR" "$LSP_IN"' EXIT

{
  tool_lsp_send_frame "$INIT_REQ"
  tool_lsp_send_frame "$DID_OPEN"
  tool_lsp_send_frame "$COMP_REQ"
  tool_lsp_send_frame "$SHUXXTDOWN"
  tool_lsp_send_frame "$EXIT_NOTIF"
} >"$LSP_IN"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
LSP_EC=0
if command -v timeout >/dev/null 2>&1; then
  timeout 8 "$SHUX" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
else
  "$SHUX" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
fi
if [ "$LSP_EC" -ne 0 ] && [ "$LSP_EC" -ne 124 ]; then
  echo "run-lsp-completion FAIL: shux --lsp exit $LSP_EC" >&2
  [ -s "$ERR" ] && cat "$ERR" >&2
  [ -s "$OUT" ] && cat "$OUT"
  exit 1
fi

if ! grep -q 'completionProvider' "$OUT"; then
  echo "run-lsp-completion FAIL: missing completionProvider in initialize" >&2
  cat "$OUT"
  exit 1
fi
if ! grep -q '"id":2' "$OUT"; then
  echo "run-lsp-completion FAIL: missing completion response id=2" >&2
  cat "$OUT"
  exit 1
fi

HITS=0
for label in add_one Point Kind core.mem function i32; do
  if tool_lsp_completion_has_label "$OUT" "$label"; then
    HITS=$((HITS + 1))
    echo "lsp-completion OK label=$label"
  fi
done
ITEMS=$(tool_lsp_completion_count_items "$OUT")
if [ "$HITS" -lt 6 ]; then
  echo "run-lsp-completion FAIL: hits=${HITS}/6 items=${ITEMS}" >&2
  cat "$OUT"
  exit 1
fi
if [ "${ITEMS:-0}" -lt 10 ]; then
  echo "run-lsp-completion FAIL: items=${ITEMS} < 10" >&2
  cat "$OUT"
  exit 1
fi

echo "tool-lsp-completion report hits=${HITS}/6 items=${ITEMS}"
echo "lsp-completion OK"
