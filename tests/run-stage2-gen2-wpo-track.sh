#!/usr/bin/env bash
# track-only：Stage2 gen2 增量 WPO 试链（typeck/backend TRY env）。
# 用法：./tests/run-stage2-gen2-wpo-track.sh
set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "stage2-gen2-wpo-track: N/A on Darwin"
  exit 0
fi

if [ ! -x compiler/shux_asm ]; then
  echo "stage2-gen2-wpo-track: SKIP (no shux_asm)"
  exit 0
fi

chmod +x compiler/scripts/build_shux_asm.sh
cp -f compiler/shux_asm compiler/shux_asm_stage1
SMK="tests/boundary/struct_mk_let_inline.x"

run_case() {
  local label="$1"
  local extra="$2"
  cp -f compiler/shux_asm_stage1 compiler/shux_asm_stage1_copy
  (
    cd compiler
    cp -f shux_asm_stage1_copy shux_asm_stage1
    eval "$extra SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 SHUX=./shux_asm_stage1 ./scripts/build_shux_asm.sh" > /tmp/st2_wpo_"$label".log 2>&1
    ./shux_asm "../$SMK" -o "/tmp/st2_wpo_${label}.out" 2>/dev/null
  ) && rc=0 || rc=$?
  echo "stage2-gen2-wpo-track: $label struct_mk_rc=$rc"
  return 0
}

echo "=== stage2 gen2 WPO track (round2 topology) ==="
run_case "default" ""
run_case "try_typeck" "SHUX_ASM_ROUND2_TRY_TYPECK_WPO=1"

echo "stage2-gen2-wpo-track OK (track-only logged)"
