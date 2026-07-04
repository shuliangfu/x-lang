#!/usr/bin/env bash
# S3 driver X 门禁：compile.x check + driver_compile_x.o 符号 + build_asm/driver_compile.o __text/insn。
# 用法：./tests/run-s3-driver-gate.sh
# 可选：SHUX_S3_DRIVER_REQUIRE_COMPILE_O=1 — 无 driver_compile_x.o（C 链）时失败
# 可选：SHUX_S3_DRIVER_REQUIRE_ASM_O=1 — 无 build_asm/driver_compile.o 时失败（先 run-s3-driver-sync-build-o.sh）
# 可选：SHUX_S3_FAIL_ON_REGRESSION=1 — build_asm/driver_compile.o 低于 baseline 时失败
# 可选：SHUX_S3_DRIVER_UPDATE_BASELINE=1 — 更新 tests/baseline/s3-driver-o.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler shux-c -q 2>/dev/null || make -C compiler shux-c

SHUX=${SHUX:-./compiler/shux-c}
COMPILE_X="compiler/src/driver/compile.x"
MAIN_X="compiler/src/main.x"
DRIVER_COMPILE_O="compiler/driver_compile_x.o"
DRIVER_ASM_O="compiler/build_asm/driver_compile.o"
DRIVER_ASM_EH_O="compiler/build_asm/driver_compile_emit_heavy.o"
DRIVER_LINK_O="compiler/build_asm/driver_compile_link.o"
SYM_BASELINE="${SHUX_S3_DRIVER_BASELINE:-tests/baseline/s3-driver.tsv}"
EMIT_BASELINE="${SHUX_S3_DRIVER_EMIT_BASELINE:-tests/baseline/s3-driver-o.tsv}"
REQ_FULL_X=$(awk -F'\t' '$1=="require_driver_run_compiler_full_x" && $1 !~ /^#/ { print $2; exit }' "$SYM_BASELINE")
REQ_FULL_X=${REQ_FULL_X:-1}
MIN_TEXT=$(awk -F'\t' '$1=="min_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$EMIT_BASELINE")
MIN_TEXT=${MIN_TEXT:-256}
MIN_REAL=$(awk -F'\t' '$1=="min_real_funcs" && $1 !~ /^#/ { print $2; exit }' "$EMIT_BASELINE")
MIN_REAL=${MIN_REAL:-0}

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
m = re.search(rf"^[0-9a-f]+ <_{re.escape(name)}>:\n((?:.*\n)*?)(?=^[0-9a-f]+ <_|\Z)", text, re.M)
if not m:
    print(0)
else:
    ins = [ln for ln in m.group(1).splitlines() if ln.strip() and not ln.endswith(":")]
    print(len(ins))
PY
}

# asm EMIT_HEAVY 单编 compile.x 与 C-gen driver_compile_x.o 符号名不同；取首个存在的。
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
    if nm "$o" 2>/dev/null | grep -q " T _${sym}$"; then
      return 0
    fi
  done
  return 1
}

check_x_silent() {
  local f="$1"
  local out
  out=$("$SHUX" check "$f" 2>&1) || {
    echo "$out"
    echo "s3 driver gate: check failed on $f"
    exit 1
  }
  if [ -n "$out" ]; then
    echo "s3 driver gate: expected silent check on $f, got: $out"
    exit 1
  fi
}

# ── 1) driver / main .x check ──
check_x_silent "$COMPILE_X"
check_x_silent "$MAIN_X"

compile_o_ok=0
if [ -f "$DRIVER_COMPILE_O" ]; then
  if ! nm_has_def "$DRIVER_COMPILE_O" driver_run_compiler_full_x; then
    echo "s3 driver gate: $DRIVER_COMPILE_O missing symbol driver_run_compiler_full_x" >&2
    exit 1
  fi
  for sym in driver_compile_dispatch_asm_backend driver_compile_dispatch_emit_c_path; do
    if ! nm "$DRIVER_COMPILE_O" 2>/dev/null | grep -q " T _${sym}$"; then
      echo "s3 driver gate: $DRIVER_COMPILE_O missing symbol $sym (regenerate: make -C compiler driver_compile_x.o)" >&2
      exit 1
    fi
  done
  compile_o_ok=1
  if [ "$REQ_FULL_X" = "1" ]; then
    echo "s3 driver gate: driver_run_compiler_full_x + dispatch_* present in $DRIVER_COMPILE_O"
  fi
elif [ "${SHUX_S3_DRIVER_REQUIRE_COMPILE_O:-0}" = "1" ]; then
  echo "s3 driver gate: missing $DRIVER_COMPILE_O (make -C compiler driver_compile_x.o)" >&2
  exit 1
fi

asm_o_ok=0
asm_sz=0
asm_real=0
# S3 insn / min_text 门禁针对 EMIT_HEAVY 全量体；WPO 压缩 driver_compile.o 仅 dogfood。
DRIVER_GATE_O="$DRIVER_ASM_O"
if [ -f "$DRIVER_ASM_EH_O" ]; then
  DRIVER_GATE_O="$DRIVER_ASM_EH_O"
fi
if [ -f "$DRIVER_ASM_O" ] || [ -f "$DRIVER_ASM_EH_O" ]; then
  asm_sz=$(text_section_size "$DRIVER_GATE_O")
  asm_real=$(count_real_asm_funcs "$DRIVER_GATE_O")
  wpo_sz=0
  if [ -f "$DRIVER_ASM_O" ]; then
    wpo_sz=$(text_section_size "$DRIVER_ASM_O")
  fi
  echo "s3 driver gate: gate_o=$DRIVER_GATE_O __text=${asm_sz} real_funcs=${asm_real} (wpo_o=${DRIVER_ASM_O} __text=${wpo_sz}; min_text=${MIN_TEXT}, min_real=${MIN_REAL})"

  if [ "${SHUX_S3_DRIVER_UPDATE_BASELINE:-0}" = "1" ]; then
    {
      echo "# S3 driver compile.x EMIT_HEAVY：build_asm/driver_compile.o baseline"
      echo "# 更新：SHUX_S3_DRIVER_UPDATE_BASELINE=1 ./tests/run-s3-driver-gate.sh"
      printf 'min_text_bytes\t%s\n' "$asm_sz"
      printf 'min_real_funcs\t%s\n' "$asm_real"
      echo "min_text_emit_heavy	5336"
    } >"$EMIT_BASELINE"
    echo "s3 driver gate: updated baseline min_text_bytes=$asm_sz min_real_funcs=$asm_real"
  fi

  if [ "${asm_sz:-0}" -eq 0 ] 2>/dev/null; then
    echo "s3 driver gate FAIL: empty __text in $DRIVER_ASM_O" >&2
    exit 1
  fi

  if [ "${SHUX_S3_FAIL_ON_REGRESSION:-0}" = "1" ] || [ "${SHUX_S3_DRIVER_REQUIRE_ASM_O:-0}" = "1" ]; then
    if ! awk -v s="$asm_sz" -v m="$MIN_TEXT" 'BEGIN { exit (s >= m) ? 0 : 1 }'; then
      echo "s3 driver gate FAIL: __text $asm_sz < min_text_bytes $MIN_TEXT" >&2
      exit 1
    fi
    if [ "${MIN_REAL:-0}" -gt 0 ] && [ "${asm_real:-0}" -lt "${MIN_REAL}" ] 2>/dev/null; then
      echo "s3 driver gate FAIL: real_funcs ${asm_real} < min_real_funcs ${MIN_REAL}" >&2
      exit 1
    fi
  fi

  if [ "${SHUX_S3_FAIL_ON_REGRESSION:-0}" = "1" ]; then
    init_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_init")
    echo "s3 driver gate: driver_compile_parse_argv_init insns=${init_insns} (min=5; thin→init_c)"
    if [ "${init_insns:-0}" -lt 5 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: driver_compile_parse_argv_init still stub (${init_insns} insns)" >&2
      exit 1
    fi

    step_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_step")
    echo "s3 driver gate: driver_compile_parse_argv_step insns=${step_insns} (min=80)"
    if [ "${step_insns:-0}" -lt 80 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: driver_compile_parse_argv_step still stub (${step_insns} insns)" >&2
      exit 1
    fi

    loop_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_loop")
    echo "s3 driver gate: driver_compile_parse_argv_loop insns=${loop_insns} (min=20)"
    if [ "${loop_insns:-0}" -lt 20 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: driver_compile_parse_argv_loop still stub (${loop_insns} insns)" >&2
      exit 1
    fi

    fin_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv_finalize")
    echo "s3 driver gate: driver_compile_parse_argv_finalize insns=${fin_insns} (min=20)"
    if [ "${fin_insns:-0}" -lt 20 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: driver_compile_parse_argv_finalize still stub (${fin_insns} insns)" >&2
      exit 1
    fi

    argv_insns=$(func_insn_count "$DRIVER_GATE_O" "driver_compile_parse_argv")
    echo "s3 driver gate: driver_compile_parse_argv insns=${argv_insns} (min=25; X init+loop+finalize)"
    if [ "${argv_insns:-0}" -lt 25 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: driver_compile_parse_argv still stub (${argv_insns} insns)" >&2
      exit 1
    fi

    full_insns=$(func_insn_count_any "$DRIVER_GATE_O" run_compiler_full_x driver_run_compiler_full_x)
    echo "s3 driver gate: run_compiler_full_x* insns=${full_insns} (min=15; X heap state + post_parse)"
    if [ "${full_insns:-0}" -lt 15 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: run_compiler_full_x still stub (${full_insns} insns)" >&2
      exit 1
    fi

    post_insns=$(func_insn_count_any "$DRIVER_GATE_O" run_compiler_full_x_post_parse driver_run_compiler_full_x_post_parse)
    echo "s3 driver gate: run_compiler_full_x_post_parse* insns=${post_insns} (min=40; X dispatch)"
    if [ "${post_insns:-0}" -lt 40 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: run_compiler_full_x_post_parse still stub (${post_insns} insns)" >&2
      exit 1
    fi

    asm_disp_insns=$(func_insn_count_any "$DRIVER_GATE_O" compile_dispatch_asm_backend driver_compile_dispatch_asm_backend)
    echo "s3 driver gate: compile_dispatch_asm_backend* insns=${asm_disp_insns} (min=15)"
    if [ "${asm_disp_insns:-0}" -lt 15 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: compile_dispatch_asm_backend still stub (${asm_disp_insns} insns)" >&2
      exit 1
    fi

    cpath_insns=$(func_insn_count_any "$DRIVER_GATE_O" compile_dispatch_emit_c_path driver_compile_dispatch_emit_c_path)
    echo "s3 driver gate: compile_dispatch_emit_c_path* insns=${cpath_insns} (min=15)"
    if [ "${cpath_insns:-0}" -lt 15 ] 2>/dev/null; then
      echo "s3 driver gate FAIL: compile_dispatch_emit_c_path still stub (${cpath_insns} insns)" >&2
      exit 1
    fi
  fi

  asm_o_ok=1
elif [ "${SHUX_S3_DRIVER_REQUIRE_ASM_O:-0}" = "1" ] || [ "${SHUX_S3_FAIL_ON_REGRESSION:-0}" = "1" ]; then
  echo "s3 driver gate: missing $DRIVER_ASM_O / $DRIVER_ASM_EH_O (run ./tests/run-s3-driver-sync-build-o.sh)" >&2
  exit 1
fi

if [ -f "$DRIVER_LINK_O" ]; then
  if ! nm "$DRIVER_LINK_O" 2>/dev/null | grep -q ' T _driver_run_compiler_full_x$'; then
    echo "s3 driver gate: $DRIVER_LINK_O missing driver_run_compiler_full_x (link alias)" >&2
    exit 1
  fi
  echo "s3 driver gate: $DRIVER_LINK_O driver_run_compiler_full_x alias OK"
elif [ "${SHUX_S3_FAIL_ON_REGRESSION:-0}" = "1" ] && [ "$asm_o_ok" -eq 1 ]; then
  echo "s3 driver gate: missing $DRIVER_LINK_O (sync should ld -r link alias)" >&2
  exit 1
fi

if [ "$compile_o_ok" -eq 0 ] && [ "$asm_o_ok" -eq 0 ]; then
  echo "s3 driver gate OK (check only; no driver .o artifacts)"
  exit 0
fi

if [ "$asm_o_ok" -eq 1 ]; then
  echo "s3 driver gate OK (compile.x check; asm __text=${asm_sz}, real_funcs=${asm_real})"
else
  echo "s3 driver gate OK (compile.x + driver_compile_x.o symbols)"
fi
