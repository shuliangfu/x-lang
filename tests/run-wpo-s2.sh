#!/usr/bin/env bash
# WPO-S2 烟测：call graph v2 导出全常量实参 call site + wpo_const_spec 断言（NEXT §4.1 WPO-S2）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true
make -C compiler -q 2>/dev/null || make -C compiler

GRAPH="/tmp/shu_wpo_const_spec.json"
rm -f "$GRAPH"

SHU_WPO_DUMP_CALLGRAPH="$GRAPH" ./compiler/shu-c check tests/wpo/const_spec.su >/dev/null
[ -s "$GRAPH" ] || { echo "WPO graph not written"; exit 1; }
grep -q '"version": 2' "$GRAPH" || { echo "WPO graph version != 2"; exit 1; }
grep -q '"call_sites"' "$GRAPH" || { echo "WPO graph missing call_sites"; exit 1; }

# main(id=0) -> scale(id=1) with args [1024, 64]
perl compiler/scripts/wpo_const_spec.pl "$GRAPH" --expect-site 0 1 1024 64 | tee /tmp/wpo_const_spec.log
grep -q 'wpo_const_spec OK' /tmp/wpo_const_spec.log

# WPO-S1 回归：dead_fn 仍可用 v2 JSON
SHU_WPO_DUMP_CALLGRAPH=/tmp/shu_wpo_dead_fn_v2.json ./compiler/shu-c check tests/wpo/dead_fn.su >/dev/null
perl compiler/scripts/wpo_dce.pl /tmp/shu_wpo_dead_fn_v2.json --expect-dead dead_helper

# WPO-S2 asm：常量实参 call fold（须 shu_asm；Linux ARM64 lite refresh stub 记 N/A）
if [ -x ./compiler/shu_asm ] && ! wpo_host_asm_run_na; then
  if wpo_s2_darwin_skip_exe_run; then
    echo "wpo-s2: Darwin asm uses -o .o disasm (user exe ld __TEXT N/A)"
  fi

  OUT=$(wpo_s2_asm_out_path /tmp/shu_wpo_const_spec_fold)
  if ! ./compiler/shu_asm tests/wpo/const_spec_fold.su -o "$OUT" 2>/tmp/wpo_s2_fold_build.log; then
    echo "wpo-s2 asm FAIL: const_spec_fold compile failed"
    tail -8 /tmp/wpo_s2_fold_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EX=0
    "$OUT" >/dev/null 2>&1 || EX=$?
    if [ "$EX" -ne 0 ]; then
      echo "wpo-s2 asm FAIL: const_spec_fold expected exit 0, got $EX"
      exit 1
    fi
  fi
  MAIN_ASM=$(wpo_main_asm "$OUT" || true)
  if [ -z "$MAIN_ASM" ]; then
    echo "wpo-s2 asm FAIL: cannot disassemble _main ($OUT); need otool or objdump"
    exit 1
  fi
  if wpo_main_calls_pat "$OUT" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
    echo "wpo-s2 asm FAIL: _main still calls _scale (expected WPO const fold inline)"
    echo "$MAIN_ASM" | grep -E 'scale|bl|call' || true
    exit 1
  fi
  echo "wpo-s2 asm fold OK (_main no bl _scale, exit 0)"

  # WPO-S2 monomorphize：SHU_WPO_MONO=1 生成 scale__wpo_1024_64 thunk，_main bl 单态符号
  OUT_MONO=$(wpo_s2_asm_out_path /tmp/shu_wpo_const_spec_mono)
  if ! SHU_WPO_MONO=1 ./compiler/shu_asm tests/wpo/const_spec_fold.su -o "$OUT_MONO" 2>/tmp/wpo_s2_mono_build.log; then
    echo "wpo-s2 asm FAIL: const_spec_fold mono compile failed"
    tail -8 /tmp/wpo_s2_mono_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXM=0
    "$OUT_MONO" >/dev/null 2>&1 || EXM=$?
    if [ "$EXM" -ne 0 ]; then
      echo "wpo-s2 asm FAIL: const_spec_fold mono expected exit 0, got $EXM"
      exit 1
    fi
  fi
  if ! nm "$OUT_MONO" 2>/dev/null | grep -q 'scale__wpo_1024_64'; then
    echo "wpo-s2 asm FAIL: missing mono symbol scale__wpo_1024_64"
    nm "$OUT_MONO" 2>/dev/null | grep wpo || true
    exit 1
  fi
  MAIN_MONO=$(wpo_main_asm "$OUT_MONO" || true)
  if [ -z "$MAIN_MONO" ]; then
    echo "wpo-s2 asm FAIL: cannot disassemble _main ($OUT_MONO)"
    exit 1
  fi
  if ! wpo_main_calls_pat "$OUT_MONO" 'scale__wpo_1024_64'; then
    # Darwin .o：otool 的 bl 常为 PC-relative 无符号；nm 已确认 mono 符号即可。
    if wpo_s2_darwin_skip_exe_run && nm "$OUT_MONO" 2>/dev/null | grep -q 'scale__wpo_1024_64'; then
      echo "wpo-s2 asm mono OK (Darwin .o: nm scale__wpo_1024_64; bl sym N/A in disasm)"
    else
      echo "wpo-s2 asm FAIL: _main expected bl scale__wpo_1024_64"
      echo "$MAIN_MONO" | grep -E 'bl|call|scale' || true
      exit 1
    fi
  else
    if wpo_main_calls_pat "$OUT_MONO" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
      echo "wpo-s2 asm FAIL: _main should not bl generic _scale in mono mode"
      exit 1
    fi
    echo "wpo-s2 asm mono OK (scale__wpo_1024_64 thunk + _main bl mono sym)"
  fi

  # WPO-S2 vec 特化：lane0(vec_add4([const],[const])) fold
  OUT_VEC=$(wpo_s2_asm_out_path /tmp/shu_wpo_vec_const_spec_fold)
  if ! ./compiler/shu_asm tests/wpo/vec_const_spec_fold.su -o "$OUT_VEC" 2>/tmp/wpo_s2_vec_build.log; then
    echo "wpo-s2 asm FAIL: vec_const_spec_fold compile failed"
    tail -8 /tmp/wpo_s2_vec_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXV=0
    "$OUT_VEC" >/dev/null 2>&1 || EXV=$?
    if [ "$EXV" -ne 0 ]; then
      echo "wpo-s2 asm FAIL: vec_const_spec_fold expected exit 0, got $EXV"
      exit 1
    fi
  fi
  MAIN_VEC=$(wpo_main_asm "$OUT_VEC" || true)
  if [ -z "$MAIN_VEC" ]; then
    echo "wpo-s2 asm FAIL: cannot disassemble _main ($OUT_VEC)"
    exit 1
  fi
  if wpo_main_calls_pat "$OUT_VEC" 'vec_add4|lane0'; then
    echo "wpo-s2 asm FAIL: _main still bl vec_add4/lane0 (expected WPO vec const fold)"
    echo "$MAIN_VEC" | grep -E 'bl|call|vec_add4|lane0' || true
    exit 1
  fi
  echo "wpo-s2 asm vec fold OK (_main no bl vec_add4/lane0, exit 0)"

  # WPO-S2 vec mono：SHU_WPO_MONO=1 → lane0__wpo_1_2_3_4_10_20_30_40 thunk
  OUT_VEC_MONO=$(wpo_s2_asm_out_path /tmp/shu_wpo_vec_const_spec_mono)
  if ! SHU_WPO_MONO=1 ./compiler/shu_asm tests/wpo/vec_const_spec_mono.su -o "$OUT_VEC_MONO" 2>/tmp/wpo_s2_vec_mono_build.log; then
    echo "wpo-s2 asm FAIL: vec_const_spec_mono compile failed"
    tail -8 /tmp/wpo_s2_vec_mono_build.log 2>/dev/null || true
    exit 1
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXVM=0
    "$OUT_VEC_MONO" >/dev/null 2>&1 || EXVM=$?
    if [ "$EXVM" -ne 0 ]; then
      echo "wpo-s2 asm FAIL: vec_const_spec_mono expected exit 0, got $EXVM"
      exit 1
    fi
  fi
  if ! nm "$OUT_VEC_MONO" 2>/dev/null | grep -q 'lane0__wpo_1_2_3_4_10_20_30_40'; then
    echo "wpo-s2 asm FAIL: missing vec mono symbol lane0__wpo_1_2_3_4_10_20_30_40"
    nm "$OUT_VEC_MONO" 2>/dev/null | grep wpo || true
    exit 1
  fi
  MAIN_VEC_MONO=$(wpo_main_asm "$OUT_VEC_MONO" || true)
  if [ -z "$MAIN_VEC_MONO" ]; then
    echo "wpo-s2 asm FAIL: cannot disassemble _main ($OUT_VEC_MONO)"
    exit 1
  fi
  if ! wpo_main_calls_pat "$OUT_VEC_MONO" 'lane0__wpo_1_2_3_4_10_20_30_40'; then
    if wpo_s2_darwin_skip_exe_run && nm "$OUT_VEC_MONO" 2>/dev/null | grep -q 'lane0__wpo_1_2_3_4_10_20_30_40'; then
      echo "wpo-s2 asm vec mono OK (Darwin .o: nm lane0__wpo_*; bl sym N/A in disasm)"
    else
      echo "wpo-s2 asm FAIL: _main expected bl lane0__wpo_1_2_3_4_10_20_30_40"
      echo "$MAIN_VEC_MONO" | grep -E 'bl|call|lane0' || true
      exit 1
    fi
  elif wpo_main_calls_pat "$OUT_VEC_MONO" 'lane0([^_a-zA-Z0-9]|$)|vec_add4'; then
    echo "wpo-s2 asm FAIL: _main should not bl generic lane0/vec_add4 in vec mono mode"
    exit 1
  else
    echo "wpo-s2 asm vec mono OK (lane0__wpo_* thunk + _main bl mono sym)"
  fi
elif wpo_host_asm_run_na; then
  echo "wpo-s2: asm fold/mono N/A on $(uname -s)-$(uname -m) (refresh shu_asm asm stub; x86_64 covers)"
fi

echo "wpo-s2 smoke OK"
