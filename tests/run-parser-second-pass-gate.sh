#!/usr/bin/env bash
# build_asm/parser.o 第二遍烟测：ENTRY_MODULE_ONLY + SKIP_TYPECK 须产出非空 __text（ast_pool 截断模块桩化）。
# strict 链仍靠 parser_x.o；本门禁保证 experimental/second pass 不回归空 parser.o。
# 用法：
#   ./tests/run-parser-second-pass-gate.sh
#   SHUX_PARSER_SECOND_PASS_FAIL=1 ./tests/run-parser-second-pass-gate.sh
set -e
cd "$(dirname "$0")/.."

# x_len 须与符号名等长；偏差时 safe_helper 不命中，combined 指标回归无感知。
if [ "${SHUX_PARSER_SAFE_HELPER_LEN_GATE:-1}" = "1" ]; then
  chmod +x tests/run-parser-safe-helper-len-gate.sh 2>/dev/null || true
  ./tests/run-parser-safe-helper-len-gate.sh
fi

# EMIT_HEAVY：符号完整性门禁（替代体积 ratchet；见 BOOT-008）。
if [ "${SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY:-1}" = "1" ]; then
  chmod +x tests/run-parser-thin-glue-symbol-integrity-gate.sh 2>/dev/null || true
  SYM_FAIL=${SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL:-${SHUX_PARSER_SECOND_PASS_FAIL:-0}}
  SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL="$SYM_FAIL" \
    ./tests/run-parser-thin-glue-symbol-integrity-gate.sh
fi

FAIL=${SHUX_PARSER_SECOND_PASS_FAIL:-1}
EMIT_HEAVY=${SHUX_PARSER_SECOND_PASS_EMIT_HEAVY:-0}
WPO_DCE=${SHUX_PARSER_SECOND_PASS_WPO_DCE:-0}
if [ "$EMIT_HEAVY" = "1" ]; then
  # parser.o：slice 委托 + safe_helper 真 emit 回归下限。
  # combined：parser.o + thin_glue（深循环 C glue）；全量 parser_x 链入后 thin_glue 不再含 seed parse_into_buf C（~9KB），故默认 125KB。
  MIN_TEXT="${SHUX_PARSER_SECOND_PASS_MIN_TEXT:-10000}"
  MIN_COMBINED="${SHUX_PARSER_SECOND_PASS_MIN_COMBINED:-125000}"
  # stretch：含 parser_x.o 侧 parse_into_buf C 体积的审计指标（9434B ≈ seed slice 差值；非链接对象）。
  STRETCH_COMBINED="${SHUX_PARSER_SECOND_PASS_STRETCH_COMBINED:-150000}"
  SEED_PARSE_METRIC_BYTES="${SHUX_PARSER_SECOND_PASS_SEED_METRIC_BYTES:-9434}"
else
  MIN_TEXT="${SHUX_PARSER_SECOND_PASS_MIN_TEXT:-16}"
  MIN_COMBINED=0
  STRETCH_COMBINED=0
  SEED_PARSE_METRIC_BYTES=0
fi
EH_SUFFIX=""
[ "$EMIT_HEAVY" = "1" ] && EH_SUFFIX=", EMIT_HEAVY"
[ "$EMIT_HEAVY" = "1" ] && [ "$WPO_DCE" = "1" ] && EH_SUFFIX="${EH_SUFFIX}, WPO_DCE=1"
# 与 build_shux_asm compile_x 一致（须在 compiler/ 目录下执行）。
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-second-pass-gate: N/A on Darwin"
  exit 0
fi

COMP_IN="./shux_asm"
if [ -n "${SHUX_PARSER_SECOND_PASS_COMPILER:-}" ]; then
  case "${SHUX_PARSER_SECOND_PASS_COMPILER}" in
    compiler/*) COMP_IN="./${SHUX_PARSER_SECOND_PASS_COMPILER#compiler/}" ;;
    *) COMP_IN="${SHUX_PARSER_SECOND_PASS_COMPILER}" ;;
  esac
fi
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh
COMP_PATH="compiler/$COMP_IN"
[ -x "$COMP_PATH" ] || COMP_PATH="$COMP_IN"
if [ ! -x "$COMP_PATH" ] || ! comp_riscv64_native_shu "$COMP_PATH"; then
  echo "parser-second-pass-gate: SKIP (no native $COMP_IN; seed/C-only build)"
  echo "parser-second-pass-gate OK (SKIP no native shux_asm)"
  exit 0
fi

TMP="/tmp/shux_parser_second_pass_gate.$$.o"
rm -f "$TMP" 2>/dev/null || true

echo "parser-second-pass-gate: compile parser.x (ENTRY_MODULE_ONLY + SKIP_TYPECK${EH_SUFFIX}) with compiler/$COMP_IN ..."
PASS_ENV="env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1"
if [ "$EMIT_HEAVY" = "1" ]; then
  PASS_ENV="$PASS_ENV SHUX_ASM_ENTRY_EMIT_HEAVY=1"
  if [ "$WPO_DCE" = "1" ]; then
    PASS_ENV="$PASS_ENV SHUX_ASM_WPO_DCE=1"
  else
    PASS_ENV="$PASS_ENV SHUX_ASM_WPO_DCE=0"
  fi
fi
if ! (
  cd compiler
  $PASS_ENV \
    "$COMP_IN" -backend asm -o "$TMP" $LIBROOT src/parser/parser.x
) > /tmp/shux_parser_sp_gate.log 2>&1; then
  echo "parser-second-pass-gate FAIL: compile command failed" >&2
  tail -n 12 /tmp/shux_parser_sp_gate.log 2>/dev/null || true
  rm -f "$TMP" /tmp/shux_parser_sp_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if grep -q 'asm_codegen_elf_o failed' /tmp/shux_parser_sp_gate.log 2>/dev/null; then
  echo "parser-second-pass-gate FAIL: asm_codegen_elf_o failed in log" >&2
  tail -n 8 /tmp/shux_parser_sp_gate.log 2>/dev/null || true
  rm -f "$TMP" /tmp/shux_parser_sp_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -s "$TMP" ]; then
  echo "parser-second-pass-gate FAIL: empty output $TMP" >&2
  rm -f "$TMP" /tmp/shux_parser_sp_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
if [ -z "$TEXT_HEX" ]; then
  TEXT_HEX=$(objdump -h "$TMP" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
fi
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)

# EMIT_HEAVY：报告 parser_asm_thin_glue.o __text（experimental 链 C 深循环；不计入门禁 min，仅供进度追踪）。
GLUE_TEXT=0
GLUE_OBJ="compiler/parser_asm_thin_glue.o"
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$GLUE_OBJ" ]; then
  GLUE_HEX=$(objdump -h "$GLUE_OBJ" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  if [ -z "$GLUE_HEX" ]; then
    GLUE_HEX=$(objdump -h "$GLUE_OBJ" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  fi
  GLUE_TEXT=$(perl -e 'print hex(shift)' "$GLUE_HEX" 2>/dev/null || echo 0)
fi
# audit：动态度量 seed parse_into_buf C 体积（thin_glue 含/不含 NO_SEED 差值；bootstrap 侧由 parser_x.o 提供）。
if [ "$EMIT_HEAVY" = "1" ] && [ "${SHUX_PARSER_SECOND_PASS_SEED_METRIC_DYNAMIC:-1}" = "1" ]; then
  SEED_METRIC_TMP="/tmp/shux_parser_seed_metric.$$.o"
  SEED_METRIC_TMP2="/tmp/shux_parser_seed_metric_noseed.$$.o"
  THIN_SRC="compiler/src/asm/parser_asm_thin_c.c"
  if [ -f "$THIN_SRC" ] && command -v cc >/dev/null 2>&1; then
    if cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
      -c -o "$SEED_METRIC_TMP" "$THIN_SRC" 2>/dev/null \
      && cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
        -DPARSER_ASM_THIN_GLUE_NO_SEED_PARSE -c -o "$SEED_METRIC_TMP2" "$THIN_SRC" 2>/dev/null; then
      SH=$(objdump -h "$SEED_METRIC_TMP" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
      SN=$(objdump -h "$SEED_METRIC_TMP2" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
      if [ -n "$SH" ] && [ -n "$SN" ]; then
        SEED_PARSE_METRIC_BYTES=$(perl -e 'print hex(shift)-hex(shift)' "$SH" "$SN" 2>/dev/null || echo "$SEED_PARSE_METRIC_BYTES")
        [ "${SEED_PARSE_METRIC_BYTES:-0}" -lt 0 ] 2>/dev/null && SEED_PARSE_METRIC_BYTES=0
      fi
    fi
  fi
  rm -f "$SEED_METRIC_TMP" "$SEED_METRIC_TMP2" 2>/dev/null || true
fi
COMBINED_TEXT=$((TEXT + GLUE_TEXT))
COMBINED_AUDIT=$((COMBINED_TEXT + SEED_PARSE_METRIC_BYTES))
TEXT_SUFFIX=""
[ "$EMIT_HEAVY" = "1" ] && TEXT_SUFFIX=" (thin_glue=${GLUE_TEXT}B combined=${COMBINED_TEXT}B audit=${COMBINED_AUDIT}B)"

# EMIT_HEAVY：parser.o thin delegate 须 bl→parser_asm_thin_c.c 的 *_glue（undef sym 顶 256；防 c_len 截断）。
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$TMP" ]; then
  NM_BAD=0
  while IFS= read -r sym; do
    [ -n "$sym" ] || continue
    case "$sym" in
      parser_*_glue|\
      parser_asm_*|\
      parser_lex_from_*|\
      parser_lex_copy_from_collect_imports|\
      ast_arena_init|\
      ast_arena_type_get|\
      ast_arena_type_alloc|\
      ast_arena_type_set|\
      ast_arena_expr_alloc|\
      ast_arena_block_alloc|\
      ast_pool_*|\
      pipeline_type_ensure_by_kind_ord|\
      pipeline_module_reset_parse_counters_c|\
      pipeline_module_set_main_func_index|\
      pipeline_module_import_path_copy|\
      pipeline_module_*|\
      pipeline_parser_library_*|\
      pipeline_parser_extern_*|\
      pipeline_parser_set_onefunc_fail_c|\
      pipeline_parser_onefunc_buf_*|\
      pipeline_parser_try_skip_*|\
      pipeline_arena_*|\
      ast_arena_func_alloc|\
      pipeline_onefunc_*|\
      pipeline_parser_set_match_module|\
      pipeline_expr_ref_is_assign_lvalue|\
      compound_assign_token_to_expr_kind_from_glue|\
      parser_slice_from_buf|\
      fs_open_read_c|\
      fs_read_c|\
      fs_posix_read_c|\
      fs_close_c|\
      pipeline_onefunc_num_src_stmt_order|\
      pipeline_onefunc_push_stmt_order|\
      lexer_init|\
      lexer_next_buf|\
      lexer_next_into|\
      ref_is_null)
        ;;
      *)
        echo "parser-second-pass-gate FAIL: unexpected U $sym (delegate c_len trunc?)" >&2
        NM_BAD=1
        ;;
    esac
  done <<EOF
$(nm -u "$TMP" 2>/dev/null | awk '{print $2}' | sort -u)
EOF
  if [ "$NM_BAD" -eq 1 ]; then
    rm -f "$TMP" /tmp/shux_parser_sp_gate.log 2>/dev/null || true
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
fi

rm -f "$TMP" /tmp/shux_parser_sp_gate.log 2>/dev/null || true

GATE_FAIL=0
if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  echo "parser-second-pass-gate FAIL: __text=${TEXT}B < min ${MIN_TEXT}B${TEXT_SUFFIX}" >&2
  GATE_FAIL=1
fi
if [ "$EMIT_HEAVY" = "1" ] && [ "${COMBINED_TEXT:-0}" -lt "$MIN_COMBINED" ] 2>/dev/null; then
  echo "parser-second-pass-gate FAIL: combined=${COMBINED_TEXT}B < min_combined ${MIN_COMBINED}B${TEXT_SUFFIX}" >&2
  GATE_FAIL=1
fi
if [ "$GATE_FAIL" -eq 1 ]; then
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

STRETCH_FAIL=${SHUX_PARSER_SECOND_PASS_STRETCH_FAIL:-0}
if [ "$EMIT_HEAVY" = "1" ] && [ "${STRETCH_COMBINED:-0}" -gt 0 ] 2>/dev/null; then
  if [ "${COMBINED_AUDIT:-0}" -lt "$STRETCH_COMBINED" ] 2>/dev/null; then
    echo "parser-second-pass-gate STRETCH: combined_audit=${COMBINED_AUDIT}B < stretch ${STRETCH_COMBINED}B${TEXT_SUFFIX}" >&2
    [ "$STRETCH_FAIL" = "1" ] && exit 1
  fi
fi

# EMIT_HEAVY：baseline 仅强制 parser.o 下限；combined/audit 为指标追踪，不再 ratchet。
BASELINE_FAIL=${SHUX_PARSER_SECOND_PASS_BASELINE_FAIL:-0}
BASELINE_FILE="${SHUX_PARSER_SECOND_PASS_BASELINE:-tests/baseline/parser-second-pass.tsv}"
if [ "$EMIT_HEAVY" = "1" ] && [ -f "$BASELINE_FILE" ]; then
  BASELINE_MIN_O=$(awk -F'\t' '$1=="min_parser_o_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE_FILE" 2>/dev/null)
  if [ -z "$BASELINE_MIN_O" ]; then
    BASELINE_MIN_O=$(awk -F'\t' '$1=="parser_o_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE_FILE" 2>/dev/null)
  fi
  if [ -n "$BASELINE_MIN_O" ] && [ "${TEXT:-0}" -lt "$BASELINE_MIN_O" ] 2>/dev/null; then
    echo "parser-second-pass-gate BASELINE: parser.o __text=${TEXT}B < min ${BASELINE_MIN_O}B${TEXT_SUFFIX}" >&2
    [ "$BASELINE_FAIL" = "1" ] && exit 1
  fi
fi

if [ "$EMIT_HEAVY" = "1" ]; then
  echo "parser-second-pass-gate OK (__text=${TEXT}B >= ${MIN_TEXT}B, combined=${COMBINED_TEXT}B >= ${MIN_COMBINED}B, audit=${COMBINED_AUDIT}B stretch=${STRETCH_COMBINED}B, EMIT_HEAVY=${EMIT_HEAVY})"
else
  echo "parser-second-pass-gate OK (__text=${TEXT}B >= ${MIN_TEXT}B, EMIT_HEAVY=${EMIT_HEAVY})"
fi
