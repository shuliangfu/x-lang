#!/usr/bin/env bash
# parser/lexer/typeck/codegen/ast .su → gen.c → .o 跨平台门禁（仅 shu-c 生成 + cc 编译，勿 relink shu_asm）。
# Mac/Linux 均可跑；refresh gate 前置快速失败。
# 用法：./tests/run-migrate-su-gen-gate.sh
# 环境：SHU_FORCE_MIGRATE_SU_GEN=1 强制重编（忽略 mtime）。
set -e
cd "$(dirname "$0")/.."

if [ ! -x ./compiler/shu-c ]; then
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
fi

# M-3：ast/typeck/codegen 变更须与 parser 一并重编
SU_SRC=(
  compiler/src/parser/parser.su
  compiler/src/lexer/lexer.su
  compiler/src/typeck/typeck.su
  compiler/src/codegen/codegen.su
  compiler/src/ast/ast.su
)
SU_OBJ=(
  compiler/parser_su.o
  compiler/lexer_su.o
  compiler/typeck_su.o
  compiler/codegen_su.o
  compiler/ast_gen2.c
)

need_rebuild=0
if [ "${SHU_FORCE_MIGRATE_SU_GEN:-0}" = "1" ] || [ "${SHU_FORCE_REFRESH_ASM_GATE:-0}" = "1" ]; then
  need_rebuild=1
else
  for f in "${SU_SRC[@]}"; do
    for o in "${SU_OBJ[@]}"; do
      if [ ! -f "$o" ] || [ "$f" -nt "$o" ]; then
        need_rebuild=1
        break 2
      fi
    done
  done
fi

if [ "$need_rebuild" = "1" ]; then
  echo "migrate su gen gate: rebuild parser/lexer/typeck/codegen su objs ..."
  rm -f compiler/parser_gen.c compiler/parser_su.o \
    compiler/lexer_gen.c compiler/lexer_su.o \
    compiler/typeck_gen.c compiler/typeck_su.o \
    compiler/codegen_gen.c compiler/codegen_su.o \
    compiler/ast_gen2.c
  make -C compiler parser_su.o lexer_su.o typeck_su.o codegen_su.o
fi

# M-3 region 相关符号须出现在 gen 产物（防 SU 路径静默退化）
grep -q 'pipeline_block_append_region' compiler/parser_gen.c || {
  echo "migrate su gen gate FAIL: parser_gen.c missing pipeline_block_append_region" >&2
  exit 1
}
grep -q 'region_label' compiler/parser_gen.c || {
  echo "migrate su gen gate FAIL: parser_gen.c missing region_label (slice domain)" >&2
  exit 1
}
grep -q 'pipeline_typeck_check_block_one_region_c' compiler/typeck_gen.c || {
  echo "migrate su gen gate FAIL: typeck_gen.c missing block region typeck glue" >&2
  exit 1
}
grep -q 'pipeline_typeck_check_call_slice_region_c' compiler/typeck_gen.c || {
  echo "migrate su gen gate FAIL: typeck_gen.c missing call slice region glue" >&2
  exit 1
}
grep -q 'parser_copy_module_import_path64' compiler/parser_gen.c || {
  echo "migrate su gen gate FAIL: parser_gen thin gen incomplete" >&2
  exit 1
}

grep -q 'pipeline_typeck_linear_use_var_c' compiler/typeck_gen.c || {
  echo "migrate su gen gate FAIL: typeck_gen.c missing linear move glue" >&2
  exit 1
}
grep -q 'TYPE_LINEAR' compiler/parser_gen.c || {
  echo "migrate su gen gate FAIL: parser_gen.c missing TYPE_LINEAR" >&2
  exit 1
}
grep -q 'TYPE_LINEAR' compiler/codegen_gen.c || {
  echo "migrate su gen gate FAIL: codegen_gen.c missing TYPE_LINEAR unwrap" >&2
  exit 1
}
grep -q 'pipeline_typeck_reject_addr_of_linear_c' compiler/typeck_gen.c || {
  echo "migrate su gen gate FAIL: typeck_gen.c missing reject addr_of linear glue" >&2
  exit 1
}
grep -q 'pipeline_typeck_is_read_ptr_slice_callee_c' compiler/typeck_gen.c || {
  echo "migrate su gen gate FAIL: typeck_gen.c missing read_ptr slice region glue" >&2
  exit 1
}
grep -q 'field_access_base_is_slice_param_name' compiler/codegen_gen.c || {
  echo "migrate su gen gate FAIL: codegen_gen.c missing slice param field access (local . vs param ->)" >&2
  exit 1
}

echo "migrate su gen gate OK"
