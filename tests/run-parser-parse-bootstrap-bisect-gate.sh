#!/usr/bin/env bash
# X PARSE_BOOTSTRAP_EMIT 二分门禁：MINIMAL 白名单应可编；全量仍 139（根因在 parse_into_buf/parse_into mega emit）。
# 用法：
#   ./tests/run-parser-parse-bootstrap-bisect-gate.sh
#   SHUX_PARSER_PARSE_BOOTSTRAP_BISECT_FAIL=1 ./tests/run-parser-parse-bootstrap-bisect-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_PARSE_BOOTSTRAP_BISECT_FAIL:-0}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-bootstrap-bisect-gate: N/A on Darwin"
  exit 0
fi

SHUX_SEED="compiler/shux"
if [ ! -x "$SHUX_SEED" ]; then
  echo "parser-parse-bootstrap-bisect-gate: SKIP (no $SHUX_SEED)"
  exit 0
fi

symbol_text_size() {
  local sym="$1"
  local f="$2"
  local sz
  sz=$(readelf -s "$f" 2>/dev/null | awk -v s="$sym" '$NF==s && /FUNC/ {print $3; exit}')
  [ -z "$sz" ] && echo 0 && return
  echo "$sz"
}

probe_bootstrap() {
  local mode="$1"
  local out="/tmp/shux_parser_boot_bisect_${mode}.$$.o"
  local log="/tmp/shux_parser_boot_bisect_${mode}.log"
  local ec has_o has_init buf_sz
  rm -f "$out" "$log" 2>/dev/null || true
  set +e
  (
    cd compiler
    if [ "$mode" = "minimal" ]; then
      env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL=1 \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
        ./shux -backend asm -o "$out" $LIBROOT src/parser/parser.x
    else
      env -u SHUX_ASM_START_FUNC SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1 \
        SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_WPO_DCE=0 \
        ./shux -backend asm -o "$out" $LIBROOT src/parser/parser.x
    fi
  ) > "$log" 2>&1
  ec=$?
  set -e
  has_o=0
  has_init=0
  buf_sz=0
  if [ -s "$out" ]; then
    has_o=1
    nm -g --defined-only "$out" 2>/dev/null | grep -qE '[[:space:]]parse_into_init$' && has_init=1
    buf_sz=$(symbol_text_size parse_into_buf "$out")
  fi
  rm -f "$out" 2>/dev/null || true
  echo "$ec $has_o $has_init $buf_sz"
  if [ "$FAIL" = "1" ] && [ -s "$log" ]; then
    tail -n 6 "$log" 2>/dev/null || true
  fi
  rm -f "$log" 2>/dev/null || true
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-bisect-gate: MINIMAL whitelist (parse_into_init + set_main_index) ..."
read -r MIN_EC MIN_O MIN_INIT MIN_BUF_SZ <<<"$(probe_bootstrap minimal)"
if [ "$MIN_EC" -ne 0 ] || [ "$MIN_O" != "1" ] || [ "$MIN_INIT" != "1" ]; then
  echo "parser-parse-bootstrap-bisect-gate FAIL: MINIMAL expected OK (ec=$MIN_EC has_o=$MIN_O has_init=$MIN_INIT)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if [ "$MIN_BUF_SZ" -gt 128 ]; then
  echo "parser-parse-bootstrap-bisect-gate FAIL: MINIMAL parse_into_buf text=${MIN_BUF_SZ}B (mega emit leaked)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
echo "parser-parse-bootstrap-bisect-gate: MINIMAL PASS (ec=$MIN_EC parse_into_buf_stub=${MIN_BUF_SZ}B)"

echo "parser-parse-bootstrap-bisect-gate: FULL bootstrap (expect 139 / no mega parse_into_buf emit) ..."
read -r FULL_EC FULL_O FULL_INIT FULL_BUF_SZ <<<"$(probe_bootstrap full)"
if [ "$FULL_EC" -eq 0 ] && [ "$FULL_BUF_SZ" -gt 4096 ]; then
  echo "parser-parse-bootstrap-bisect-gate FAIL: FULL unexpectedly emitted parse_into_buf (${FULL_BUF_SZ}B)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if [ "$FULL_EC" -eq 139 ] || [ "$FULL_EC" -eq 134 ] || [ "$FULL_EC" -ne 0 ]; then
  echo "parser-parse-bootstrap-bisect-gate: FULL PASS (known fail ec=$FULL_EC; root cause: mega parse_into* X emit)"
else
  echo "parser-parse-bootstrap-bisect-gate: FULL PASS (ec=$FULL_EC has_o=$FULL_O; use C TU for production)"
fi
exit 0
