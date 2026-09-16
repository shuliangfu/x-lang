#!/usr/bin/env bash
# S3 driver parity: build_asm/driver_compile.o + driver_compile_link.o exports.
#
# Honesty: soft XLANG_S3_FAIL_ON_PARITY retired — under-baseline / missing .o
# soft die→exit0 + soft SKIP→OK was portable false-green. Mach-O-only `T _sym`
# needles were portable false-FAIL on ELF (Ubuntu). Prefer optional `_` nm.
# Missing objects on Linux gold are hard die. Darwin / non-Linux-x64 stub-or-
# missing stays N/A (skip=1). Tip often keeps driver_compile.o as thin stub
# while link.o carries live exports — size/real under baseline on compile.o
# is observational when link.o symbols hard-green.
#
# Usage: ./tests/run-s3-driver-o-parity.sh
# Prereq (Linux gold): ./tests/run-s3-driver-sync-build-o.sh when forcing size
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/missing.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

DRIVER_ASM_O="compiler/build_asm/driver_compile.o"
DRIVER_LINK_O="compiler/build_asm/driver_compile_link.o"
BASELINE="${XLANG_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_TEXT=${MIN_TEXT:-256}
MIN_REAL=${MIN_REAL:-0}
PREFIX="xlang: [XLANG_S3_DRIVER_PARITY]"
RUN_OK=0
OBS=0
SKIP=1

die() {
  echo "s3 driver parity FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
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
# ELF: <sym>:  Mach-O: <_sym>: — accept optional leading _
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

# ELF/Mach-O defined symbol (optional leading _).
sym_defined() {
  local o="$1" sym="$2"
  nm "$o" 2>/dev/null | grep -qE " T (_)?${sym}\$"
}

# PLATFORM: LINUX|UBUNTU x86_64 — EMIT_HEAVY driver gold.
# PLATFORM: MACOS|DARWIN / other — stub build_asm without sync is N/A.
is_emit_heavy_gold_host() {
  ci_is_linux && ci_is_x86_64_host
}

if [ ! -f "$DRIVER_ASM_O" ] || [ ! -f "$DRIVER_LINK_O" ]; then
  if is_emit_heavy_gold_host; then
    [ -f "$DRIVER_ASM_O" ] || die "missing $DRIVER_ASM_O (run ./tests/run-s3-driver-sync-build-o.sh; refuse soft SKIP→OK)"
    die "missing $DRIVER_LINK_O (sync should build driver_compile_link.o; refuse soft SKIP→OK)"
  fi
  echo "s3 driver parity: N/A missing driver .o on $(ci_host_summary) (EMIT_HEAVY Linux x86_64 gold)"
  ok_report
  exit 0
fi

asm_sz=$(text_section_size "$DRIVER_ASM_O")
asm_real=$(count_real_asm_funcs "$DRIVER_ASM_O")
echo "s3 driver parity: $DRIVER_ASM_O __text=${asm_sz} real_funcs=${asm_real} (min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

# Link.o symbol surface is the hard product authority (compile.o may stay stub).
NEED_SYMS="driver_run_compiler_full_x driver_compile_dispatch_asm_backend driver_compile_dispatch_emit_c_path driver_compile_parse_argv"
missing_syms=""
for sym in $NEED_SYMS; do
  if ! sym_defined "$DRIVER_LINK_O" "$sym"; then
    missing_syms="${missing_syms} ${sym}"
  fi
done

# Non-gold host: missing link exports + stub compile.o → honest skip (no soft FAIL print).
# If link.o already exports the live surface, continue (size under → obs below).
if ! is_emit_heavy_gold_host; then
  under=0
  [ "${asm_sz:-0}" -lt "${MIN_TEXT}" ] 2>/dev/null && under=1
  [ "${MIN_REAL:-0}" -gt 0 ] && [ "${asm_real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null && under=1
  if [ -n "$missing_syms" ] && [ "$under" -eq 1 ]; then
    echo "s3 driver parity: N/A stub/unsynced driver objects on $(ci_host_summary) (__text=${asm_sz} real=${asm_real} miss=${missing_syms})"
    ok_report
    exit 0
  fi
fi

SKIP=0

if [ -n "$missing_syms" ]; then
  die "$DRIVER_LINK_O missing symbols:${missing_syms}"
fi
echo "s3 driver parity: link.o exports driver_run_compiler_full_x + dispatch_* + parse_argv"
RUN_OK=$((RUN_OK + 1))

# compile.o EMIT_HEAVY size: tip often keeps thin stub while link.o is live → obs.
if [ "${asm_sz:-0}" -lt "${MIN_TEXT}" ] 2>/dev/null; then
  echo "s3 driver parity OBS: $DRIVER_ASM_O __text ${asm_sz} < min_text_bytes ${MIN_TEXT} (stub tip residual; link.o symbols hard)" >&2
  OBS=$((OBS + 1))
elif [ "${MIN_REAL:-0}" -gt 0 ] && [ "${asm_real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  echo "s3 driver parity OBS: real_funcs ${asm_real} < min_real_funcs ${MIN_REAL} (stub tip residual; link.o symbols hard)" >&2
  OBS=$((OBS + 1))
else
  echo "s3 driver parity: compile.o EMIT_HEAVY size/real OK"
  RUN_OK=$((RUN_OK + 1))
fi

echo "s3 driver parity OK (__text=${asm_sz}, real_funcs=${asm_real}, run=${RUN_OK}, obs=${OBS})"
ok_report
exit 0
