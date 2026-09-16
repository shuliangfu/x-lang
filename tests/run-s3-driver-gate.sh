#!/usr/bin/env bash
# S3 driver gate: compile.x artifacts + build_asm/driver_compile*_emit_heavy floors.
#
# Honesty: soft XLANG_S3_FAIL_ON_REGRESSION / missing-asm soft OK retired.
# Linux x86_64 gold hard-dies missing/under EMIT_HEAVY body + per-func insn
# floors. Darwin thin stub / missing is N/A (skip=1). `xlang check` and
# C-chain driver_compile_x.o are observational (check paused; prefer asm).
# nm accepts optional Mach-O `_`.
#
# Usage: ./tests/run-s3-driver-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: LINUX|UBUNTU x86_64 gold; DARWIN N/A when stub/missing.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. ./tests/lib/ci-host.sh

COMPILE_X="compiler/src/driver/compile.x"
MAIN_X="compiler/src/main.x"
DRIVER_COMPILE_O="compiler/driver_compile_x.o"
DRIVER_ASM_O="compiler/build_asm/driver_compile.o"
DRIVER_ASM_EH_O="compiler/build_asm/driver_compile_emit_heavy.o"
DRIVER_LINK_O="compiler/build_asm/driver_compile_link.o"
SYM_BASELINE="${XLANG_S3_DRIVER_BASELINE:-tests/baseline/s3-driver.tsv}"
EMIT_BASELINE="${XLANG_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
REQ_FULL_X=$(awk -F'\t' '$1=="require_driver_run_compiler_full_x" && $1 !~ /^#/ { print $2; exit }' "$SYM_BASELINE" 2>/dev/null || true)
REQ_FULL_X=${REQ_FULL_X:-1}
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$EMIT_BASELINE")
MIN_TEXT=${MIN_TEXT:-256}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$EMIT_BASELINE")
MIN_REAL=${MIN_REAL:-0}

PREFIX="xlang: [XLANG_S3_DRIVER_GATE]"
RUN_OK=0
OBS=0
SKIP=0
CHECK_OK=0

die() {
  echo "s3 driver gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} check=${CHECK_OK} host=$(ci_host_summary)"
}

is_gold() { ci_is_linux_x64; }

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

func_insn_count_any() {
  local o="$1"
  shift
  local name insns
  for name in "$@"; do
    insns=$(func_insn_count "$o" "$name")
    if [ "${insns:-0}" -gt 0 ] 2>/dev/null; then
      echo "$insns"
      return 0
    fi
  done
  echo 0
}

text_section_size() {
  local o="$1"
  [ -f "$o" ] || { echo 0; return; }
  local hex
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && { echo 0; return; }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

nm_has_def() {
  local o="$1"
  shift
  local sym
  for sym in "$@"; do
    if nm "$o" 2>/dev/null | grep -qE " T (_)?${sym}\$"; then
      return 0
    fi
  done
  return 1
}

# ── 1) check observational ──
ENV_XLANG="${XLANG:-}"
XLANG=""
for cand in "$ENV_XLANG" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
  [ -n "$cand" ] && [ -x "$cand" ] || continue
  XLANG="$cand"
  break
done
check_one() {
  local f="$1"
  [ -n "$XLANG" ] && [ -x "$XLANG" ] || return 1
  set +e
  local out crc
  out=$("$XLANG" check "$f" 2>&1)
  crc=$?
  set -e
  [ "$crc" -eq 0 ] && [ -z "$out" ]
}
if check_one "$COMPILE_X" && check_one "$MAIN_X"; then
  CHECK_OK=1
else
  OBS=$((OBS + 1))
  echo "s3 driver gate: obs — check not silent (paused gate)"
fi

# C-chain driver_compile_x.o = observational (prefer asm EMIT_HEAVY).
if [ -f "$DRIVER_COMPILE_O" ]; then
  if nm_has_def "$DRIVER_COMPILE_O" driver_run_compiler_full_x; then
    echo "s3 driver gate: driver_compile_x.o has driver_run_compiler_full_x (obs C-chain)"
  else
    OBS=$((OBS + 1))
    echo "s3 driver gate: obs — driver_compile_x.o missing driver_run_compiler_full_x"
  fi
else
  OBS=$((OBS + 1))
  echo "s3 driver gate: obs — no driver_compile_x.o (asm path preferred)"
fi

# ── 2) asm EMIT_HEAVY body ──
DRIVER_GATE_O=""
if [ -f "$DRIVER_ASM_EH_O" ]; then
  DRIVER_GATE_O="$DRIVER_ASM_EH_O"
elif [ -f "$DRIVER_ASM_O" ]; then
  DRIVER_GATE_O="$DRIVER_ASM_O"
fi

if [ -z "$DRIVER_GATE_O" ]; then
  if is_gold; then
    die "missing $DRIVER_ASM_O / $DRIVER_ASM_EH_O (run ./tests/run-s3-driver-sync-build-o.sh)"
  fi
  SKIP=1
  echo "s3 driver gate: missing asm .o — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

asm_sz=$(text_section_size "$DRIVER_GATE_O")
asm_real=$(count_real_asm_funcs "$DRIVER_GATE_O")
wpo_sz=0
[ -f "$DRIVER_ASM_O" ] && wpo_sz=$(text_section_size "$DRIVER_ASM_O")
echo "s3 driver gate: gate_o=$DRIVER_GATE_O __text=${asm_sz} real_funcs=${asm_real} (wpo_o=${DRIVER_ASM_O} __text=${wpo_sz}; min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

if [ "${XLANG_S3_DRIVER_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    echo "# S3 driver compile.x EMIT_HEAVY：build_asm/driver_compile.o baseline"
    echo "# 更新：XLANG_S3_DRIVER_UPDATE_BASELINE=1 ./tests/run-s3-driver-gate.sh"
    printf 'min_text_bytes\t%s\n' "$asm_sz"
    printf 'min_real_funcs\t%s\n' "$asm_real"
    echo "min_text_emit_heavy	5336"
  } >"$EMIT_BASELINE"
  echo "s3 driver gate: updated baseline min_text_bytes=$asm_sz min_real_funcs=$asm_real"
fi

# Thin Darwin stub: dispatch-only ~0x1f0 or empty.
is_stub=0
if [ "${asm_sz:-0}" -lt 1024 ] 2>/dev/null; then
  is_stub=1
fi
if [ "${asm_real:-0}" -lt 4 ] 2>/dev/null && [ "${asm_sz:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  is_stub=1
fi

if [ "$is_stub" -eq 1 ]; then
  if is_gold; then
    die "stub driver .o __text=${asm_sz} real_funcs=${asm_real} (run sync EMIT_HEAVY)"
  fi
  SKIP=1
  echo "s3 driver gate: stub driver .o — non-gold N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${asm_sz:-0}" -eq 0 ] 2>/dev/null; then
  die "empty __text in $DRIVER_GATE_O"
fi

if ! awk -v s="$asm_sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
  if is_gold; then
    die "__text $asm_sz < min_text_bytes $MIN_TEXT"
  fi
  SKIP=1
  echo "s3 driver gate: under min_text on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${asm_real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
  if is_gold; then
    die "real_funcs ${asm_real} < min_real_funcs ${MIN_REAL}"
  fi
  SKIP=1
  echo "s3 driver gate: under min_real on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

# Per-func insn floors (Linux gold hard).
require_insns() {
  local label="$1" min="$2" got="$3"
  echo "s3 driver gate: ${label} insns=${got} (min=${min})"
  if [ "${got:-0}" -lt "$min" ] 2>/dev/null; then
    if is_gold; then
      die "${label} still stub (${got} insns < ${min})"
    fi
    return 1
  fi
  return 0
}

func_under=0
init_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_init")
require_insns "driver_compile_parse_argv_init" 5 "$init_insns" || func_under=1
step_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_step")
require_insns "driver_compile_parse_argv_step" 80 "$step_insns" || func_under=1
loop_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_loop")
require_insns "driver_compile_parse_argv_loop" 20 "$loop_insns" || func_under=1
fin_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_finalize")
require_insns "driver_compile_parse_argv_finalize" 20 "$fin_insns" || func_under=1
argv_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv")
require_insns "driver_compile_parse_argv" 25 "$argv_insns" || func_under=1
full_insns=$(func_insn_count_any "$DRIVER_GATE_O" run_compiler_full_x driver_run_compiler_full_x)
require_insns "run_compiler_full_x*" 15 "$full_insns" || func_under=1
post_insns=$(func_insn_count_any "$DRIVER_GATE_O" run_compiler_full_x_post_parse driver_run_compiler_full_x_post_parse)
require_insns "run_compiler_full_x_post_parse*" 40 "$post_insns" || func_under=1
asm_disp_insns=$(func_insn_count_any "$DRIVER_GATE_O" compile_dispatch_asm_backend driver_compile_dispatch_asm_backend)
require_insns "compile_dispatch_asm_backend*" 15 "$asm_disp_insns" || func_under=1
cpath_insns=$(func_insn_count_any "$DRIVER_GATE_O" compile_dispatch_emit_c_path driver_compile_dispatch_emit_c_path)
require_insns "compile_dispatch_emit_c_path*" 15 "$cpath_insns" || func_under=1

if [ "$func_under" -eq 1 ]; then
  SKIP=1
  echo "s3 driver gate: func under on non-gold — N/A (skip=1)"
  ok_report
  exit 0
fi

if [ -f "$DRIVER_LINK_O" ]; then
  if ! nm "$DRIVER_LINK_O" 2>/dev/null | grep -qE ' T (_)?driver_run_compiler_full_x$'; then
    if is_gold; then
      die "$DRIVER_LINK_O missing driver_run_compiler_full_x (link alias)"
    fi
    OBS=$((OBS + 1))
    echo "s3 driver gate: obs — link.o missing alias"
  else
    echo "s3 driver gate: $DRIVER_LINK_O driver_run_compiler_full_x alias OK"
  fi
elif is_gold; then
  die "missing $DRIVER_LINK_O (sync should ld -r link alias)"
else
  OBS=$((OBS + 1))
  echo "s3 driver gate: obs — no driver_compile_link.o"
fi

RUN_OK=1
echo "s3 driver gate OK (asm __text=${asm_sz}, real_funcs=${asm_real})"
ok_report
