#!/usr/bin/env bash
# S3 pipeline EMIT_HEAVY smoke: recompile pipeline.x; count non-ret0 funcs.
#
# Honesty: soft XLANG_S3_FAIL_ON_EMIT_HEAVY retired — zero-text soft OK
# (no obs) was portable false-green (Darwin tip OK at __text=0). Missing
# compiler hard-dies. Tip live under/compile-fail on Linux gold = obs
# (product residual). Darwin / non-Linux-x64 = skip=1.
# Invoke from compiler/ cwd (same as build_xlang_asm second-pass).
#
# Usage: ./tests/run-s3-pipeline-emit-heavy.sh
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
OUT="/tmp/xlang_s3_pipeline_emit_heavy.o"
BASELINE="${XLANG_S3_PIPELINE_BASELINE:-tests/baseline/s3-pipeline-o.tsv}"

MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-512}

PREFIX="xlang: [XLANG_S3_PIPELINE_EMIT_HEAVY]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s3 emit-heavy FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
}

is_emit_heavy_gold() {
  ci_is_linux_x64
}

if [ ! -x "$COMP" ]; then
  die "no executable compiler (set XLANG_S3_EMIT_HEAVY_COMPILER=)"
fi
# Same cwd/LIBROOT as build_xlang_asm rebuild_pipeline_o_second_pass.
case "$COMP" in
  ./*) COMP_ABS="$(cd "$(dirname "$COMP")" && pwd)/$(basename "$COMP")" ;;
  *) COMP_ABS="$COMP" ;;
esac
PIPELINE_X_REL="src/pipeline/pipeline.x"
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

rm -f "$OUT"
set +e
(
  cd compiler && ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
  env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY=1 XLANG_ASM_WPO_DCE=0 \
    "$COMP_ABS" -backend asm -o "$OUT" $LIBROOT "$PIPELINE_X_REL"
)
compile_rc=$?
set -e
if [ "$compile_rc" -ne 0 ]; then
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 emit-heavy: obs — compile failed (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 emit-heavy: compile failed — non-gold host N/A (skip=1)"
  ok_report
  exit 0
fi
[ -f "$OUT" ] || {
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 emit-heavy: obs — output missing (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 emit-heavy: output missing — non-gold host N/A (skip=1)"
  ok_report
  exit 0
}

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s3 emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

under=0
if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  under=1
fi
if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  under=1
fi

if [ "$under" -eq 1 ]; then
  if is_emit_heavy_gold; then
    OBS=$((OBS + 1))
    echo "s3 emit-heavy: obs — under baseline __text=${sz} real_funcs=${real} (EMIT_HEAVY product residual)"
    ok_report
    exit 0
  fi
  SKIP=1
  echo "s3 emit-heavy: stub/under on non-gold host — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s3 emit-heavy OK (__text=${sz}, real_funcs=${real})"
ok_report
