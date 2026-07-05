#!/usr/bin/env bash
# C-06：Makefile 默认 bootstrap/relink 仅链 *_sx.o 前端，不链 C parser/typeck/codegen.o。
#
# 用法：./tests/run-c06-sx-frontend-default-gate.sh
# 环境：SHUX_C06_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_C06_FAIL:-0}
MF="compiler/Makefile"
DOC="analysis/phase-c-c06-v1.md"

echo "=== C-06: sx frontend default (no C parser.o in DRIVER_SEED_OBJS) ==="
for f in "$MF" "$DOC"; do
  [ -f "$f" ] || { echo "c06 gate FAIL: missing $f" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
done

grep -q 'C-06 v1' "$MF" || { echo "c06 gate FAIL: Makefile missing C-06 marker" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
grep -q 'DRIVER_SEED_SX_FRONTEND_OBJS' "$MF" || { echo "c06 gate FAIL: missing DRIVER_SEED_SX_FRONTEND_OBJS" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
grep -q 'runtime_driver_no_c.o' "$MF" || { echo "c06 gate FAIL: missing runtime_driver_no_c default" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
grep -q 'SHUX_LEGACY_C_FRONTEND' "$MF" || { echo "c06 gate FAIL: missing legacy escape hatch" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
grep -q 'ast_sx.o:' "$MF" || { echo "c06 gate FAIL: missing ast_sx.o alias" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

# DRIVER_SEED_OBJS 定义行不得直接含 C parser/typeck/codegen .o（须在 LEGACY 变量内）。
if sed -n '/^DRIVER_SEED_OBJS =/,/^$/p' "$MF" | grep -qE 'src/parser/parser\.o|src/typeck/typeck\.o|src/codegen/codegen\.o'; then
  echo "c06 gate FAIL: DRIVER_SEED_OBJS still embeds C frontend .o" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

grep -q 'DRIVER_SEED_LINK_FLAGS' "$MF" || { echo "c06 gate FAIL: missing DRIVER_SEED_LINK_FLAGS" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }
grep -q 'codegen_pipeline_stubs.o' "$MF" || { echo "c06 gate FAIL: missing codegen_pipeline_stubs for no-C path" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

echo "c06 sx-frontend-default gate OK"
