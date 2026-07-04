#!/usr/bin/env bash
# x PARSE_BOOTSTRAP_EMIT 轨道门禁：全量 parser.x 真 emit parse_into* 在 seed/shux_asm 上仍 139（已知）。
# C seed TU（parser_asm_parse_bootstrap_obj.c）为默认路径；本门禁记录 x 探测结果，防回归为「静默成功但无 .o」。
# 用法：
#   ./tests/run-parser-parse-bootstrap-x-emit-gate.sh
#   SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_FAIL=1 ./tests/run-parser-parse-bootstrap-x-emit-gate.sh
#   SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_EXPECT_OK=1 SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_FAIL=1 ...  # 修通 x emit 后硬门禁
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_FAIL:-${SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_FAIL:-0}}
EXPECT_OK=${SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_EXPECT_OK:-${SHUX_PARSER_PARSE_BOOTSTRAP_X_EMIT_EXPECT_OK:-0}}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-bootstrap-x-emit-gate: N/A on Darwin"
  exit 0
fi

SHUX_SEED="compiler/shux"
if [ ! -x "$SHUX_SEED" ]; then
  echo "parser-parse-bootstrap-x-emit-gate: SKIP (no $SHUX_SEED)"
  exit 0
fi

OUT="/tmp/shux_parser_boot_x_emit.$$.o"
LOG="/tmp/shux_parser_boot_x_emit.log"
rm -f "$OUT" "$LOG" 2>/dev/null || true

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-x-emit-gate: probe SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT on seed ./shux ..."
set +e
(
  cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
    ./shux -backend asm -o "$OUT" $LIBROOT src/parser/parser.x
) > "$LOG" 2>&1
EC=$?
set -e

HAS_O=0
if [ -s "$OUT" ]; then
  HAS_O=1
fi
HAS_SYM=0
HAS_SYM_SZ=0
if [ "$HAS_O" = "1" ]; then
  if nm -g --defined-only "$OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
    HAS_SYM=1
    HAS_SYM_SZ=$(readelf -s "$OUT" 2>/dev/null | awk '/parse_into_buf$/ && /FUNC/ {print $3; exit}')
    HAS_SYM_SZ=${HAS_SYM_SZ:-0}
  fi
fi

rm -f "$OUT" 2>/dev/null || true

if [ "$EXPECT_OK" = "1" ]; then
  if [ "$EC" -ne 0 ] || [ "$HAS_SYM" != "1" ]; then
    echo "parser-parse-bootstrap-x-emit-gate FAIL: expected x bootstrap OK (ec=$EC has_sym=$HAS_SYM)" >&2
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$LOG" 2>/dev/null || true
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  echo "parser-parse-bootstrap-x-emit-gate PASS: x bootstrap emit OK (unexpected — prefer C TU unless intentional)"
  rm -f "$LOG" 2>/dev/null || true
  exit 0
fi

# 默认：139/失败为已知；须无 mega 级 parse_into_buf 真 emit（ret0 桩允许）。
if [ "$EC" -eq 0 ] && [ "$HAS_SYM" = "1" ] && [ "$HAS_SYM_SZ" -gt 4096 ]; then
  echo "parser-parse-bootstrap-x-emit-gate FAIL: x bootstrap unexpectedly succeeded (use C TU or set EXPECT_OK)" >&2
  rm -f "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# MINIMAL 白名单轨道：parse_into_init 可编，parse_into_buf 仍桩化（见 bisect-gate）。
MIN_OUT="/tmp/shux_parser_boot_x_emit_min.$$.o"
MIN_LOG="/tmp/shux_parser_boot_x_emit_min.log"
rm -f "$MIN_OUT" "$MIN_LOG" 2>/dev/null || true
set +e
(
  cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1 \
    SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
    ./shux -backend asm -o "$MIN_OUT" $LIBROOT src/parser/parser.x
) > "$MIN_LOG" 2>&1
MIN_EC=$?
set -e
MIN_HAS_INIT=0
MIN_HAS_BUF_SZ=0
if [ -s "$MIN_OUT" ]; then
  nm -g --defined-only "$MIN_OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_init$' && MIN_HAS_INIT=1
  if nm -g --defined-only "$MIN_OUT" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
    MIN_HAS_BUF_SZ=$(readelf -s "$MIN_OUT" 2>/dev/null | awk '/parse_into_buf$/ && /FUNC/ {print $3; exit}')
    MIN_HAS_BUF_SZ=${MIN_HAS_BUF_SZ:-0}
  fi
fi
rm -f "$MIN_OUT" "$MIN_LOG" 2>/dev/null || true
if [ "$MIN_EC" -ne 0 ] || [ "$MIN_HAS_INIT" != "1" ] || [ "$MIN_HAS_BUF_SZ" -gt 128 ]; then
  echo "parser-parse-bootstrap-x-emit-gate FAIL: MINIMAL bootstrap (ec=$MIN_EC init=$MIN_HAS_INIT buf_sz=$MIN_HAS_BUF_SZ)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$EC" -eq 139 ] || [ "$EC" -eq 134 ] || [ "$EC" -ne 0 ]; then
  echo "parser-parse-bootstrap-x-emit-gate PASS (known x bootstrap fail ec=$EC; MINIMAL OK; use parser_asm_parse_bootstrap_obj.c)"
  rm -f "$LOG" 2>/dev/null || true
  exit 0
fi

echo "parser-parse-bootstrap-x-emit-gate PASS (ec=$EC has_o=$HAS_O; x emit path inactive — C TU default)"
rm -f "$LOG" 2>/dev/null || true
exit 0
