#!/usr/bin/env bash
# LSP 测试：启动 shux --lsp，发送 initialize / didOpen / diagnostics / textDocument/formatting / shutdown / exit，校验 stdout 含预期 JSON-RPC 响应。
# 依赖：带 LSP 的 shux（make -C compiler bootstrap-driver-seed）。

set -e
cd "$(dirname "$0")/.."
SHUX="${SHUX:-./compiler/shux}"

# 构建带 LSP 的 shux（若尚未构建或无 --lsp 则先 bootstrap-driver-seed）
if ! "$SHUX" --help 2>/dev/null | grep -q '\-\-lsp'; then
  make -C compiler bootstrap-driver-seed
  SHUX=./compiler/shux
fi

# 发送一条 LSP 消息：Content-Length: N\r\n\r\n<body>
# 注意：wc -c 在 BSD/macOS 会输出前导空格，需去掉，否则 LSP 解析 Content-Length 时会在空格处停止得到 0
send_lsp() {
  local body="$1"
  local len
  len=$(printf '%s' "$body" | wc -c | tr -d ' \n')
  printf 'Content-Length: %d\r\n\r\n%s' "$len" "$body"
}

# 用 Python 做 JSON 转义（若不可用则用内联写死的短文档）
if command -v python3 >/dev/null 2>&1; then
  DOC_JSON=$(python3 -c "import json; print(json.dumps(open('tests/lsp/main.x').read()))")
  DEF_DOC_JSON=$(python3 -c "import json; print(json.dumps(open('tests/lsp/def_call.x').read()))")
else
  DOC_JSON='"function main(): i32 { return 0; }"'
  DEF_DOC_JSON='"function helper(): i32 { return 1; } function main(): i32 { return helper(); }"'
fi

INIT_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
DID_OPEN='{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///tests/lsp/main.x","languageId":"su","version":1,"text":'"$DOC_JSON"'}}}'
DID_OPEN_DEF='{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///tests/lsp/def_call.x","languageId":"su","version":1,"text":'"$DEF_DOC_JSON"'}}}'
DIAG_REQ='{"jsonrpc":"2.0","id":2,"method":"textDocument/diagnostics","params":{"textDocument":{"uri":"file:///tests/lsp/main.x"}}}'
FMT_REQ='{"jsonrpc":"2.0","id":4,"method":"textDocument/formatting","params":{"textDocument":{"uri":"file:///tests/lsp/main.x"},"options":{"tabSize":2,"insertSpaces":true,"maxLineLength":100}}}'
DEF_REQ='{"jsonrpc":"2.0","id":5,"method":"textDocument/definition","params":{"textDocument":{"uri":"file:///tests/lsp/def_call.x"},"position":{"line":6,"character":9}}}'
SHUTDOWN='{"jsonrpc":"2.0","id":3,"method":"shutdown"}'
EXIT_NOTIF='{"jsonrpc":"2.0","method":"exit"}'

OUT=$(mktemp)
ERR=$(mktemp)
LSP_IN=$(mktemp)
trap "rm -f $OUT $ERR $LSP_IN" EXIT

# 先写入临时文件再重定向 stdin，避免管道在子 shell 退出后关闭导致 LSP 只读到第一条消息即 EOF
{
  send_lsp "$INIT_REQ"
  send_lsp "$DID_OPEN"
  send_lsp "$DIAG_REQ"
  send_lsp "$FMT_REQ"
  send_lsp "$DID_OPEN_DEF"
  send_lsp "$DEF_REQ"
  send_lsp "$SHUTDOWN"
  send_lsp "$EXIT_NOTIF"
} >"$LSP_IN"
# 调试 stdin 每次 read 的请求/返回字节数：LSP_READ_DEBUG=1 时 LSP 的 stderr 会打 io_read 日志
# timeout 为 GNU coreutils，macOS 默认无；无 timeout 时直接运行，避免 exit 127
# Alpine 等默认栈约 8MB，LSP parse/typeck 易 SIGSEGV(139)；与 build_shux_asm 一致抬高 soft limit。
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
LSP_EC=0
if command -v timeout >/dev/null 2>&1; then
  LSP_READ_DEBUG="${LSP_READ_DEBUG:-}" timeout 5 "$SHUX" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
else
  LSP_READ_DEBUG="${LSP_READ_DEBUG:-}" "$SHUX" --lsp <"$LSP_IN" 2>"$ERR" >"$OUT" || LSP_EC=$?
fi
# 124 = timeout 且已有部分响应时可接受；0 为正常；其余为失败
if [ "$LSP_EC" -ne 0 ] && [ "$LSP_EC" -ne 124 ]; then
  echo "LSP test FAIL: shux --lsp exit $LSP_EC" >&2
  [ -s "$ERR" ] && cat "$ERR" >&2
  [ -s "$OUT" ] && cat "$OUT"
  exit 1
fi
if [ -n "${LSP_READ_DEBUG:-}" ]; then
  echo "LSP stderr (LSP_READ_DEBUG):" >&2
  cat "$ERR" >&2
fi

# 至少应收到 initialize 与 shutdown 的响应；stdout 为多条 Content-Length+\r\n\r\n+body
if ! grep -q '"jsonrpc"' "$OUT"; then
  echo "LSP test FAIL: no jsonrpc in output"
  cat "$OUT"
  exit 1
fi
if ! grep -q '"result"' "$OUT"; then
  echo "LSP test FAIL: no result in output"
  cat "$OUT"
  exit 1
fi
if ! grep -qE 'capabilities|serverInfo|"name":"shux"' "$OUT"; then
  echo "LSP test FAIL: initialize response missing capabilities"
  [ -s "$ERR" ] && cat "$ERR" >&2
  [ -s "$OUT" ] && cat "$OUT"
  exit 1
fi
# diagnostics 的 result 应为数组（[] 或 [{...}]）
if ! grep -q '"result":\[' "$OUT"; then
  echo "LSP test FAIL: diagnostics result not an array"
  cat "$OUT"
  exit 1
fi
# capabilities 应包含 documentFormattingProvider
if ! grep -q 'documentFormattingProvider' "$OUT"; then
  echo "LSP test FAIL: capabilities missing documentFormattingProvider"
  cat "$OUT"
  exit 1
fi
# formatting 的 result 应为 TextEdit 数组，且含 newText
if ! grep -q '"newText":' "$OUT"; then
  echo "LSP test FAIL: formatting response missing newText"
  cat "$OUT"
  exit 1
fi
# definition 烟测：helper() 调用应解析到 def_call.x 内 helper 定义（非 null）
if ! grep -q '"id":5' "$OUT" || ! grep -q '"line":0' "$OUT"; then
  echo "LSP test FAIL: definition response missing expected helper location"
  cat "$OUT"
  exit 1
fi

echo "LSP test OK"
