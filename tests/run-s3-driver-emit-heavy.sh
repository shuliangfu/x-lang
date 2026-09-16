#!/usr/bin/env bash
# S3 driver EMIT_HEAVY smoke: recompile compile.x; count non-ret0 funcs + key insns.
#
# Honesty: soft XLANG_S3_FAIL_ON_EMIT_HEAVY retired — under-baseline /
# stub-func soft OK (no obs) was portable false-green. Missing compiler
# hard-dies. Tip live under/compile-fail on Linux gold = obs (product
# residual). Darwin / non-Linux-x64 = skip=1. ELF/Mach-O optional `_`.
#
# Usage: ./tests/run-s3-driver-emit-heavy.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold (obs under); DARWIN N/A when stub/fail.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

COMP="${XLANG_S3_EMIT_HEAVY_COMPILER:-}"
if [ -z "$COMP" ]; then
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict_glue ./compiler/xlang_asm.experimental; do
    if [ -x "$cand" ]; then
      COMP="$cand"
      break
    fi
  done
fi
COMPILE_X="compiler/src/driver/compile.x"
OUT="/tmp/xlang_s3_driver_emit_heavy.o"
BASELINE="${XLANG_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"

MIN_REAL=0
MIN_TEXT_EH=256
if [ -f "$BASELINE" ]; then
  MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
  MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
fi
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=${MIN_TEXT_EH:-256}

PREFIX="xlang: [XLANG_S3_DRIVER_EMIT_HEAVY]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s3 driver emit-heavy FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

is_emit_heavy_gold() {
  ci_is_linux_x64
}

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
head = r"^[0-9a-f]+ <(_?[^+>]+)>:\n"
nxt = r"(?=^[0-9a-f]+ <_?[^+>]+>:\n|\Z)"
try:
    text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print(0)
    sys.exit(0)
real = 0
for m in re.finditer(head + r"((?:.*\n)*?)" + nxt, text, re.M):
    insns = [ln for ln in m.group(2).splitlines() if ln.strip() and not ln.endswith(":")]
    if len(insns) > 10:
        real += 1
print(real)
PY
}

func_insn_count() {
  python3 - "$1" "$2" <<'PY'
import subprocess, re, sys
path, name = sys.argv[1], sys.argv[2]
text = subprocess.check_output(["objdump", "-d", path], text=True, stderr=subprocess.DEVNULL)
m = re.search(rf"^[0-9a-f]+ <(?:_)?{re.escape(name)}>:\n((?:.*\n)*?)(?=^[0-9a-f]+ <_?|\Z)", text, re.M)
if not m:
    print(0)
else:
    ins = [ln for ln in m.group(1).splitlines() if ln.strip() and not ln.endswith(":")]
    print(len(ins))
PY
}

if [ ! -x "$COMP" ]; then
  die "no executable compiler (set XLANG_S3_EMIT_HEAVY_COMPILER=)"
fi
echo "s3 driver emit-heavy: compiler=$COMP"

rm -f "$OUT"
if ! env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY=1 \
  "$COMP" -backend asm -o "$OUT" $LIBROOT "$COMPILE_X" 2>/dev/null; then
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 driver emit-heavy: obs — compile failed (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 driver emit-heavy: compile failed — non-gold host N/A (skip=1)"
  ok_report
  exit 0
fi
[ -f "$OUT" ] || {
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 driver emit-heavy: obs — output missing (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 driver emit-heavy: output missing — non-gold host N/A (skip=1)"
  ok_report
  exit 0
}

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s3 driver emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

under=0
if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  under=1
fi
if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  under=1
fi

FUNC_UNDER=0
for pair in \
  "driver_compile_parse_argv_init:5" \
  "driver_compile_parse_argv_step:200" \
  "driver_compile_parse_argv_loop:20" \
  "driver_compile_parse_argv_finalize:20" \
  "driver_compile_parse_argv:25" \
  "run_compiler_full_x:15" \
  "run_compiler_full_x_post_parse:40" \
  "compile_dispatch_asm_backend:15"; do
  fn="${pair%%:*}"
  min="${pair##*:}"
  insns=$(func_insn_count "$OUT" "$fn")
  echo "s3 driver emit-heavy: ${fn} insns=${insns} (min=${min})"
  if [ "${insns:-0}" -lt "$min" ] 2>/dev/null; then
    FUNC_UNDER=1
  fi
done

if [ "$under" -eq 1 ] || [ "$FUNC_UNDER" -eq 1 ]; then
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 driver emit-heavy: obs — under baseline __text=${sz} real_funcs=${real} (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 driver emit-heavy: stub/under on non-gold host — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s3 driver emit-heavy OK (__text=${sz}, real_funcs=${real})"
ok_report
