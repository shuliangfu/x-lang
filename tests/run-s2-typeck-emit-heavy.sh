#!/usr/bin/env bash
# S2 EMIT_HEAVY smoke: recompile typeck.x with xlang_asm; count non-ret0 funcs.
#
# Honesty: soft XLANG_S2_FAIL_ON_EMIT_HEAVY retired — under-baseline /
# zero-text soft OK was portable false-green. Linux x86_64 gold hard-dies
# when real_funcs / __text fall under baseline. Darwin / non-Linux-x64 is
# N/A (skip=1) on compile fail or stub/under (EMIT_HEAVY Linux gold).
# nm/objdump accept optional Mach-O leading underscore (ELF has none).
#
# Usage: ./tests/run-s2-typeck-emit-heavy.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/fail.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

COMP="${XLANG_S2_EMIT_HEAVY_COMPILER:-}"
if [ -z "$COMP" ]; then
  # G.7 prefer asm product binary first.
  for cand in ./compiler/xlang_asm ./compiler/xlang_asm.strict_glue ./compiler/xlang_asm.experimental; do
    if [ -x "$cand" ]; then
      COMP="$cand"
      break
    fi
  done
fi
TYPECK_X="compiler/src/typeck/typeck.x"
OUT="/tmp/xlang_s2_typeck_emit_heavy.o"
BASELINE="${XLANG_S2_TYPECK_BASELINE:-tests/baseline/s2-typeck-o.tsv}"
LIBROOT="-L compiler/asm_libroot -L compiler/.. -L compiler/src -L compiler/src/lexer -L compiler/src/ast -L compiler/src/parser -L compiler/src/typeck -L compiler/src/codegen -L compiler/src/preprocess -L compiler/src/pipeline -L compiler/src/lsp -L compiler/src/asm"

MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=${MIN_REAL:-0}
MIN_TEXT_EH=$(awk -F'\t' '$1=="min_text_emit_heavy" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT_EH=${MIN_TEXT_EH:-8192}

PREFIX="xlang: [XLANG_S2_TYPECK_EMIT_HEAVY]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "s2 emit-heavy FAIL: $*" >&2
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

# ELF <sym> / Mach-O <_sym>; ignore <sym+0xN> GNU labels.
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

if [ ! -x "$COMP" ]; then
  die "no executable compiler (tried xlang_asm*; set XLANG_S2_EMIT_HEAVY_COMPILER=)"
fi
echo "s2 emit-heavy: compiler=$COMP"

rm -f "$OUT"
if ! env -u XLANG_ASM_START_FUNC XLANG_ASM_ENTRY_MODULE_ONLY=1 XLANG_ASM_BUILD_SKIP_TYPECK=1 XLANG_ASM_ENTRY_EMIT_HEAVY=1 \
  "$COMP" -backend asm -o "$OUT" $LIBROOT "$TYPECK_X" 2>/dev/null; then
  if is_emit_heavy_gold; then
    die "compile failed"
  fi
  SKIP=1
  echo "s2 emit-heavy: compile failed — non-gold host N/A (skip=1)"
  ok_report
  exit 0
fi
[ -f "$OUT" ] || {
  if is_emit_heavy_gold; then
    die "output missing"
  fi
  SKIP=1
  echo "s2 emit-heavy: output missing — non-gold host N/A (skip=1)"
  ok_report
  exit 0
}

sz=$(text_section_size "$OUT")
real=$(count_real_asm_funcs "$OUT")
echo "s2 emit-heavy: __text=${sz} real_funcs=${real} (min_real=${MIN_REAL}, min_text_emit_heavy=${MIN_TEXT_EH})"

under=0
if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  under=1
fi
if ! awk -v s="$sz" -v m="$MIN_TEXT_EH" 'BEGIN { exit (s > m) ? 0 : 1 }'; then
  under=1
fi

if [ "$under" -eq 1 ]; then
  if is_emit_heavy_gold; then
    if [ "${real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
      die "real_funcs ${real} < min_real_funcs ${MIN_REAL} (relink xlang_asm after typeck/pipeline leave)"
    fi
    die "__text ${sz} <= min_text_emit_heavy ${MIN_TEXT_EH}"
  fi
  SKIP=1
  echo "s2 emit-heavy: stub/under on non-gold host — N/A (skip=1)"
  ok_report
  exit 0
fi

RUN_OK=1
echo "s2 emit-heavy OK (__text=${sz}, real_funcs=${real})"
ok_report
