#!/usr/bin/env bash
# S3 driver EMIT_HEAVY 烟测：用 shux_asm 第二遍重编 compile.sx，统计非 ret0 桩的真机码函数数。
# 依赖：compiler/shux_asm.experimental 或 strict_glue 已重链含最新 ast_pool.c。
# 用法：./tests/run-s3-driver-emit-heavy.sh
# 门禁：SHUX_S3_FAIL_ON_EMIT_HEAVY=1 — real_funcs / __text 低于 baseline 时失败
set -e
cd "$(dirname "$0")/.."
COMP="${SHUX_S3_EMIT_HEAVY_COMPILER:-}"
if [ -z "$COMP" ]; then
  for cand in ./compiler/shux_asm.strict_glue ./compiler/shux_asm.experimental ./compiler/shux_asm; do
    if [ -x "$cand" ]; then
      COMP="$cand"
      break
    fi
  done
fi
COMPILE_SX="compiler/src/driver/compile.sx"
OUT="/tmp/shux_s3_driver_emit_heavy.o"
BASELINE="${SHUX_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"

MIN_REAL=0
MIN_TEXT_EH=256
if [ -f "$BASELINE" ]; then
  MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
  MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
fi
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=${MIN_TEXT_EH:-256}

if [ ! -x "$COMP" ]; then
  echo "s3 driver emit-heavy: no executable compiler (set SHUX_S3_EMIT_HEAVY_COMPILER=)" >&2
  exit 127
fi
echo "s3 driver emit-heavy: compiler=$COMP"

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
  "$COMP" -backend asm -o "$OUT" $LIBROOT "$COMPILE_SX" 2>/dev/null; then
  echo "s3 driver emit-heavy: compile failed" >&2
  exit 1
fi
[ -f "$OUT" ] || { echo "s3 driver emit-heavy: output missing"; exit 1; }

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s3 driver emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

if [ "${SHUX_S3_FAIL_ON_EMIT_HEAVY:-0}" = "1" ]; then
  if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
    echo "s3 driver emit-heavy FAIL: real_funcs ${real} < min_real_funcs ${MIN_REAL}" >&2
    echo "s3 driver emit-heavy hint: ast_pool.c 变更后须 relink shux_asm" >&2
    exit 1
  fi
  if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
    echo "s3 driver emit-heavy FAIL: __text ${sz} < min_text_emit_heavy ${MIN_TEXT_EH}" >&2
    exit 1
  fi
  func_insn_count() {
    python3 - "$1" "$2" <<'PY'
import subprocess, re, sys
path, name = sys.argv[1], sys.argv[2]
text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
m = re.search(rf"^[0-9a-f]+ <_{re.escape(name)}>:\n((?:.*\n)*?)(?=^[0-9a-f]+ <_|\Z)", text, re.M)
if not m:
    print(0)
else:
    ins = [ln for ln in m.group(1).splitlines() if ln.strip() and not ln.endswith(":")]
    print(len(ins))
PY
  }
  for pair in \
    "driver_compile_parse_argv_init:5" \
    "driver_compile_parse_argv_step:200" \
    "driver_compile_parse_argv_loop:20" \
    "driver_compile_parse_argv_finalize:20" \
    "driver_compile_parse_argv:25" \
    "run_compiler_full_sx:15" \
    "run_compiler_full_sx_post_parse:40" \
    "compile_dispatch_asm_backend:15"; do
    fn="${pair%%:*}"
    min="${pair##*:}"
    insns=$(func_insn_count "$OUT" "$fn")
    echo "s3 driver emit-heavy: ${fn} insns=${insns} (min=${min})"
    if [ "${insns:-0}" -lt "$min" ] 2>/dev/null; then
      echo "s3 driver emit-heavy FAIL: ${fn} still stub (${insns} insns)" >&2
      exit 1
    fi
  done
fi

echo "s3 driver emit-heavy OK (__text=${sz}, real_funcs=${real})"
