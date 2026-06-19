#!/usr/bin/env bash
# S3 EMIT_HEAVY 烟测：用 shux_asm 第二遍重编 pipeline.o，统计非 ret0 桩的真机码函数数。
# 依赖：compiler/shux_asm.experimental 或 strict_glue 已重链含最新 ast_pool.c。
# 用法：./tests/run-s3-pipeline-emit-heavy.sh
# 门禁：SHUX_S3_FAIL_ON_EMIT_HEAVY=1 — real_funcs / __text 低于 baseline 时失败
set -e
cd "$(dirname "$0")/.."
COMP="${SHUX_S3_EMIT_HEAVY_COMPILER:-}"
if [ -z "$COMP" ]; then
  for cand in ./compiler/shux_asm.strict_glue ./compiler/shux_asm ./compiler/shux_asm.experimental; do
    if [ -x "$cand" ]; then
      COMP="$cand"
      break
    fi
  done
fi
PIPELINE_SU="compiler/src/pipeline/pipeline.sx"
OUT="/tmp/shux_s3_pipeline_emit_heavy.o"
BASELINE="${SHUX_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"

MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-512}

if [ ! -x "$COMP" ]; then
  echo "s3 emit-heavy: no executable compiler (set SHUX_S3_EMIT_HEAVY_COMPILER=)" >&2
  exit 127
fi
# 与 build_shux_asm rebuild_pipeline_o_second_pass 同 cwd/LIBROOT（根目录 invoke 仅 ~4KiB 薄码）。
case "$COMP" in
  ./*) COMP_ABS="$(cd "$(dirname "$COMP")" && pwd)/$(basename "$COMP")" ;;
  *) COMP_ABS="$COMP" ;;
esac
PIPELINE_SU_REL="src/pipeline/pipeline.sx"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
echo "s3 emit-heavy: compiler=$COMP (from compiler/)"

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
# Mach-O: <_sym>；ELF: <sym>
for m in re.finditer(r"^[0-9a-f]+ <(_?[^>]+)>:\n((?:.*\n)*?)(?=\n[0-9a-f]+ <_?|\Z)", text, re.M):
    body = m.group(2)
    insns = [ln for ln in body.splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

rm -f "$OUT"
if ! ( cd compiler && ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
    "$COMP_ABS" -backend asm -o "$OUT" $LIBROOT "$PIPELINE_SU_REL" ); then
  echo "s3 emit-heavy: compile failed" >&2
  exit 1
fi
[ -f "$OUT" ] || { echo "s3 emit-heavy: output missing"; exit 1; }

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s3 emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHUX_S3_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
    echo "s3 emit-heavy FAIL: real_funcs ${real} < min_real_funcs ${MIN_REAL}" >&2
    echo "s3 emit-heavy hint: ast_pool.c 变更后须重编 pipeline_sx.o + relink shux_asm" >&2
    exit 1
  fi
  if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s3 emit-heavy FAIL: __text ${sz} < min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
fi

echo "s3 emit-heavy OK (__text=${sz}, real_funcs=${real})"
