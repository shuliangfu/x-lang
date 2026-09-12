#!/bin/bash
# prove_pthin_stretch_audit_eq.sh — 7.2.1 B-minus pilot equivalence driver
#
# 用法：
#   sh scripts/prove_pthin_stretch_audit_eq.sh [file.x ...]
#
# 职责：把 .x 试点(src/asm/pthin_stretch_audit.x)与套件 C 孪生做全量等价性对照：
#   1) ./xlang -E 生成 C → cc → audit_x.o（单符号导出面）
#   2) cc 桥(seeds/parser_asm_lex_step_bridge.from_x.c) → bridge.o
#   3) cc 词法权威 pin(seeds/lexer_gen.linux.x86_64.c) → lexer_pin.o
#   4) cc harness(内嵌 by-value C 参考孪生) → 链接运行
#   5) 语料：内置合成串(每个 token 偏移) + argv 真实 .x 文件(前 4000 token 偏移)
# 判据：返回值一致 + .x 版调用方 lexer 三元组(pos/line/col)不动。
# 诊断工件落 tests/probes/pthin_stretch_audit/，不写 /tmp。
#
# 墙钟分层（2026-09-11 · 目标软刀 L2 总墙钟 ≤10 min）：
#   优先用 scripts/prove_pthin_stretch_audit_eq_mode.sh：
#     daily <substrs>  — 本波差分（~1 min）
#     close            — 全符号 OFF=32 × EQ_JOBS=4（~3–5 min；软刀结案）
#     full             — 全符号 OFF=128 × EQ_JOBS=8（仅升钉/L4）
#   本脚本仍为单进程直跑；旋钮：
#     EQ_MAX_FILE_OFF / EQ_ONLY / EQ_SKIP_SYNTH / EQ_SHARD=i/n / EQ_FILE_STRIDE
# PLATFORM: SHARED — 软刀结案双端 close（非串行 50min full）。
set -eu

cd "$(dirname "$0")/.."

OUT=tests/probes/pthin_stretch_audit
mkdir -p "$OUT"

CC=${CC:-cc}

# 1) .x -> -E -> cc
./xlang -E src/asm/pthin_stretch_audit.x >"$OUT/audit_x_E.c" 2>"$OUT/audit_x_E.err"
$CC -c -I. -Iinclude -Isrc -Isrc/asm -Iseeds/parser_asm -o "$OUT/audit_x.o" "$OUT/audit_x_E.c" 2>"$OUT/audit_x_cc.err" || {
  cat "$OUT/audit_x_cc.err" >&2; exit 1; }

# 2) bridge
$CC -c -I. -Iinclude -Isrc -Iseeds/parser_asm -o "$OUT/bridge.o" \
  seeds/parser_asm_lex_step_bridge.from_x.c 2>"$OUT/bridge_cc.err" || {
  cat "$OUT/bridge_cc.err" >&2; exit 1; }

# 3) lexer authority pin
$CC -c -I. -Iinclude -Isrc -o "$OUT/lexer_pin.o" seeds/lexer_gen.linux.x86_64.c 2>"$OUT/lexer_pin_cc.err" || {
  cat "$OUT/lexer_pin_cc.err" >&2; exit 1; }

# 4) leftover_kind + leftover_namelen + leftover_sourceoff + leftover_kindsrc sibling TUs + harness + link
$CC -c -I. -Iinclude -o "$OUT/leftover_kind.o" \
  scripts/pthin_stretch_audit_eq_leftover_kind.c 2>"$OUT/leftover_kind_cc.err" || {
  cat "$OUT/leftover_kind_cc.err" >&2; exit 1; }
$CC -c -I. -Iinclude -o "$OUT/leftover_namelen.o" \
  scripts/pthin_stretch_audit_eq_leftover_namelen.c 2>"$OUT/leftover_namelen_cc.err" || {
  cat "$OUT/leftover_namelen_cc.err" >&2; exit 1; }
$CC -c -I. -Iinclude -o "$OUT/leftover_sourceoff.o" \
  scripts/pthin_stretch_audit_eq_leftover_sourceoff.c 2>"$OUT/leftover_sourceoff_cc.err" || {
  cat "$OUT/leftover_sourceoff_cc.err" >&2; exit 1; }
$CC -c -I. -Iinclude -o "$OUT/leftover_kindsrc.o" \
  scripts/pthin_stretch_audit_eq_leftover_kindsrc.c 2>"$OUT/leftover_kindsrc_cc.err" || {
  cat "$OUT/leftover_kindsrc_cc.err" >&2; exit 1; }
$CC -I. -Iinclude -o "$OUT/eq_harness" \
  scripts/pthin_stretch_audit_eq_harness.c "$OUT/audit_x.o" "$OUT/bridge.o" "$OUT/lexer_pin.o" \
  "$OUT/leftover_kind.o" "$OUT/leftover_namelen.o" "$OUT/leftover_sourceoff.o" \
  "$OUT/leftover_kindsrc.o" \
  2>"$OUT/harness_cc.err" || { cat "$OUT/harness_cc.err" >&2; exit 1; }

# 5) run（默认真实语料：试点自身 + lite .x + 主入口 .x）
if [ "$#" -eq 0 ]; then
  set -- src/asm/pthin_stretch_audit.x src/asm/pthin_stretch.x src/main.x
fi
"$OUT/eq_harness" "$@"
