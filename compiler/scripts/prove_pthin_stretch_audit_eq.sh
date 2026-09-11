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
# 墙钟分层（2026-09-11 起强制 · 防每波双端 50min×2）：
#   日常微步 / 软刀迭代（daily）：
#     EQ_ONLY=<本波新增符号逗号子串> EQ_MAX_FILE_OFF=128
#     可选 EQ_SKIP_SYNTH=1（只跑文件语料+null）→ 通常 <2 min
#   整波结案 / 升钉前（full）：
#     不设 EQ_ONLY；EQ_MAX_FILE_OFF=128（或默认）；双端各跑一次
#   旋钮：
#     EQ_MAX_FILE_OFF=N（1..1199）压文件偏移；合成串 + null 守卫默认仍全量
#     EQ_ONLY=a,b,c — 仅跑 name 含任一子串的用例（差分）
#     EQ_SKIP_SYNTH=1 — 跳过合成串电池
# PLATFORM: SHARED（结案须双端 full；日常可双端 daily 或本机 daily + 对端结案 full）。
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

# 4) harness + link
$CC -I. -Iinclude -o "$OUT/eq_harness" \
  scripts/pthin_stretch_audit_eq_harness.c "$OUT/audit_x.o" "$OUT/bridge.o" "$OUT/lexer_pin.o" \
  2>"$OUT/harness_cc.err" || { cat "$OUT/harness_cc.err" >&2; exit 1; }

# 5) run（默认真实语料：试点自身 + lite .x + 主入口 .x）
if [ "$#" -eq 0 ]; then
  set -- src/asm/pthin_stretch_audit.x src/asm/pthin_stretch.x src/main.x
fi
"$OUT/eq_harness" "$@"
