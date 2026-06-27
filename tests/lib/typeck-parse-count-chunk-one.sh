#!/usr/bin/env bash
# typeck-parse-count-chunk-one.sh — 单块 typeck.sx parse 指标（独立进程，避免父 shell 连跑 ~90 次后异常）
#
# 用法（仓库根）：
#   ./tests/lib/typeck-parse-count-chunk-one.sh <compiler> <chunk.sx> <out.o> [log]
#
# 成功：stdout 打印 num_defined（已扣 stub main）；失败返回 1。

set -euo pipefail
cd "$(dirname "$0")/../.."

COMP="${1:?compiler}"
CHUNK_SX="${2:?chunk.sx}"
OUT_O="${3:?out.o}"
LOG="${4:-/tmp/shux_typeck_chunk_one.$$.log}"
LIBROOT="${SHUX_TYPECK_PARSE_CHUNK_LIBROOT:--L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm}"

COMP="$(cd "$(dirname "$COMP")" && pwd)/$(basename "$COMP")"
CHUNK_SX="$(cd "$(dirname "$CHUNK_SX")" && pwd)/$(basename "$CHUNK_SX")"

if [ ! -x "$COMP" ] || [ ! -f "$CHUNK_SX" ]; then
  echo "typeck-parse-count-chunk-one: missing compiler or chunk" >&2
  exit 1
fi

# shux 在非 TTY stdout（>file）下 parse 可能挂起；tee|cat Drain。pipefail 下 SIGTERM→143 勿让 set -e 提前退出。
# shellcheck disable=SC2086
set +e
( cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 \
    SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_PARSE_METRIC_ONLY=1 SHUX_DEBUG_PIPE=1 \
    "$COMP" -backend asm -o "$OUT_O" $LIBROOT "$CHUNK_SX"
) 2>&1 | tee "$LOG" | cat >/dev/null
pipe_ec=${PIPESTATUS[0]:-1}
set -e

ndef=$(sed -n 's/.*num_defined=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
if [ -n "$ndef" ]; then
  echo "$((ndef - 1))"
  exit 0
fi
nf=$(sed -n 's/.*after_entry_parse num_funcs=\([0-9][0-9]*\).*/\1/p' "$LOG" | tail -1)
if [ -n "$nf" ]; then
  echo "$((nf - 1))"
  exit 0
fi
echo "typeck-parse-count-chunk-one: no parse metric (pipe_ec=${pipe_ec}; see $LOG)" >&2
tail -n 8 "$LOG" >&2 || true
exit 1
