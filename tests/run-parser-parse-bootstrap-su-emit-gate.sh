#!/usr/bin/env bash
# SU PARSE_BOOTSTRAP_EMIT 轨道门禁：全量 parser.su 真 emit parse_into* 在 seed/shu_asm 上仍 139（已知）。
# C seed TU（parser_asm_parse_bootstrap_obj.c）为默认路径；本门禁记录 SU 探测结果，防回归为「静默成功但无 .o」。
# 用法：
#   ./tests/run-parser-parse-bootstrap-su-emit-gate.sh
#   SHU_PARSER_PARSE_BOOTSTRAP_SU_EMIT_FAIL=1 ./tests/run-parser-parse-bootstrap-su-emit-gate.sh
#   SHU_PARSER_PARSE_BOOTSTRAP_SU_EMIT_EXPECT_OK=1 SHU_PARSER_PARSE_BOOTSTRAP_SU_EMIT_FAIL=1 ...  # 修通 SU 后硬门禁
set -e
cd "$(dirname "$0")/.."

FAIL=${SHU_PARSER_PARSE_BOOTSTRAP_SU_EMIT_FAIL:-0}
EXPECT_OK=${SHU_PARSER_PARSE_BOOTSTRAP_SU_EMIT_EXPECT_OK:-0}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-bootstrap-su-emit-gate: N/A on Darwin"
  exit 0
fi

SHU_SEED="compiler/shu"
if [ ! -x "$SHU_SEED" ]; then
  echo "parser-parse-bootstrap-su-emit-gate: SKIP (no $SHU_SEED)"
  exit 0
fi

OUT="/tmp/shu_parser_boot_su_emit.$$.o"
LOG="/tmp/shu_parser_boot_su_emit.log"
rm -f "$OUT" "$LOG" 2>/dev/null || true

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-su-emit-gate: probe SHU_ASM_PARSER_PARSE_BOOTSTRAP_EMIT on seed ./shu ..."
set +e
(
  cd compiler
  env -u SHU_ASM_START_FUNC SHU_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_WPO_DCE=0 \
    ./shu -backend asm -o "$OUT" $LIBROOT src/parser/parser.su
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
    echo "parser-parse-bootstrap-su-emit-gate FAIL: expected SU bootstrap OK (ec=$EC has_sym=$HAS_SYM)" >&2
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$LOG" 2>/dev/null || true
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  echo "parser-parse-bootstrap-su-emit-gate PASS: SU bootstrap emit OK (unexpected — prefer C TU unless intentional)"
  rm -f "$LOG" 2>/dev/null || true
  exit 0
fi

# 默认：139/失败为已知；须无 mega 级 parse_into_buf 真 emit（ret0 桩允许）。
if [ "$EC" -eq 0 ] && [ "$HAS_SYM" = "1" ] && [ "$HAS_SYM_SZ" -gt 4096 ]; then
  echo "parser-parse-bootstrap-su-emit-gate FAIL: SU bootstrap unexpectedly succeeded (use C TU or set EXPECT_OK)" >&2
  rm -f "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# MINIMAL 白名单轨道：parse_into_init 可编，parse_into_buf 仍桩化（见 bisect-gate）。
MIN_OUT="/tmp/shu_parser_boot_su_emit_min.$$.o"
MIN_LOG="/tmp/shu_parser_boot_su_emit_min.log"
rm -f "$MIN_OUT" "$MIN_LOG" 2>/dev/null || true
set +e
(
  cd compiler
  env -u SHU_ASM_START_FUNC SHU_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
    SHU_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1 \
    SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_WPO_DCE=0 \
    ./shu -backend asm -o "$MIN_OUT" $LIBROOT src/parser/parser.su
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
  echo "parser-parse-bootstrap-su-emit-gate FAIL: MINIMAL bootstrap (ec=$MIN_EC init=$MIN_HAS_INIT buf_sz=$MIN_HAS_BUF_SZ)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$EC" -eq 139 ] || [ "$EC" -eq 134 ] || [ "$EC" -ne 0 ]; then
  echo "parser-parse-bootstrap-su-emit-gate PASS (known SU bootstrap fail ec=$EC; MINIMAL OK; use parser_asm_parse_bootstrap_obj.c)"
  rm -f "$LOG" 2>/dev/null || true
  exit 0
fi

echo "parser-parse-bootstrap-su-emit-gate PASS (ec=$EC has_o=$HAS_O; SU path inactive — C TU default)"
rm -f "$LOG" 2>/dev/null || true
exit 0
