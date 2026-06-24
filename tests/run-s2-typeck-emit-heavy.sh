#!/usr/bin/env bash
# S2 EMIT_HEAVY 烟测：用 shux_asm 第二遍重编 typeck.o，统计非 ret0 桩的真机码函数数。
# 依赖：compiler/shux_asm 已重链含最新 ast_pool.c（make bootstrap-driver-bstrict）。
# 用法：./tests/run-s2-typeck-emit-heavy.sh
# 门禁：SHUX_S2_FAIL_ON_EMIT_HEAVY=1 — real_funcs < baseline min_real_funcs 或 __text < min_text_emit_heavy 时失败
set -e
cd "$(dirname "$0")/.."
COMP="${SHUX_S2_EMIT_HEAVY_COMPILER:-}"
if [ -z "$COMP" ]; then
  # strict 重链 shux_asm 可用；优先 experimental bootstrap（全 SX 链），再 strict_glue / shux_asm。
  for cand in ./compiler/shux_asm.experimental ./compiler/shux_asm ./compiler/shux_asm.strict_glue; do
    if [ -x "$cand" ]; then
      COMP="$cand"
      break
    fi
  done
fi
TYPECK_SX="compiler/src/typeck/typeck.sx"
OUT="/tmp/shux_s2_typeck_emit_heavy.o"
BASELINE="${SHUX_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"

MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-8192}

if [ ! -x "$COMP" ]; then
  echo "s2 emit-heavy: no executable compiler (tried shux_asm.experimental / shux_asm; set SHUX_S2_EMIT_HEAVY_COMPILER=)" >&2
  exit 127
fi
echo "s2 emit-heavy: compiler=$COMP"

text_section_size() {
  local o="$1"
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

count_real_asm_funcs() {
  python3 - "$1" <<'PY'
import subprocess, re, sys
path = sys.argv[1]
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(r"^[0-9a-f]+ <(_[^>]+)>:\n((?:.*\n)*?)(?=\n[0-9a-f]+ <_|\Z)", text, re.M):
    body = m.group(2)
    insns = [ln for ln in body.splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

rm -f "$OUT"
if ! env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 \
  "$COMP" -backend asm -o "$OUT" $LIBROOT "$TYPECK_SX" 2>/dev/null; then
  echo "s2 emit-heavy: compile failed" >&2
  exit 1
fi
[ -f "$OUT" ] || { echo "s2 emit-heavy: output missing"; exit 1; }

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s2 emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHUX_S2_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
    echo "s2 emit-heavy FAIL: real_funcs ${real} < min_real_funcs ${MIN_REAL}" >&2
    echo "s2 emit-heavy hint: ast_pool.c 变更后须 make bootstrap-driver-bstrict 重链 shux_asm" >&2
    exit 1
  fi
  if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s > m) ? 0 : 1 }'; then
    echo "s2 emit-heavy FAIL: __text ${sz} <= min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
fi

echo "s2 emit-heavy OK (__text=${sz}, real_funcs=${real})"
