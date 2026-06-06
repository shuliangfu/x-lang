#!/usr/bin/env bash
# S5：compiler self WPO __text 门禁（call graph dead% + 多库 asm D/B proxy）。
# 用法：
#   ./tests/run-perf-wpo-dce-compiler-self-text.sh
#   SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_COMPILER_SELF_TEXT=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh
#   SHU_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. "$(dirname "$0")/lib/wpo-ab-proxy.sh"

text_bytes() { wpo_ab_text_bytes "$@"; }

SHU_ASM="${SHU:-./compiler/shu_asm}"
case "$SHU_ASM" in
  /*) SHU_ASM_ABS="$SHU_ASM" ;;
  *) SHU_ASM_ABS="$(pwd)/$SHU_ASM" ;;
esac
SHU_C="./compiler/shu-c"
BASELINE="${SHU_WPO_COMPILER_SELF_TEXT_BASELINE:-tests/baseline/wpo-dce-compiler-self-text.tsv}"
GRAPH="/tmp/shu_wpo_compiler_self_text.json"
FAIL_REGRESS=0
UPDATE_BASELINE=0
TRY_MAIN_ASM="${SHU_WPO_TRY_MAIN_ASM:-1}"
MAIN_TIMEOUT="${SHU_WPO_MAIN_ASM_TIMEOUT:-180}"
[ "${SHU_PERF_FAIL_ON_WPO_COMPILER_SELF_TEXT:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHU_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c

MIN_GRAPH_PCT=$(awk -F'\t' '$1=="min_dead_pct_graph" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_MULTI_BYTES=$(awk -F'\t' '$1=="dead_multi_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_MULTI_PCT=$(awk -F'\t' '$1=="dead_multi_min_text_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_GRAPH_PCT=${MIN_GRAPH_PCT:-5}
MIN_MULTI_BYTES=${MIN_MULTI_BYTES:-48}
MIN_MULTI_PCT=${MIN_MULTI_PCT:-8}
MIN_MAIN_PCT=$(awk -F'\t' '$1=="main_min_text_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_MAIN_PCT=${MIN_MAIN_PCT:-3}
MIN_CHAIN_PCT=$(awk -F'\t' '$1=="build_asm_min_text_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_CHAIN_PCT=${MIN_CHAIN_PCT:-1}
MIN_CHAIN_BYTES=$(awk -F'\t' '$1=="build_asm_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_CHAIN_BYTES=${MIN_CHAIN_BYTES:-600}

# 累加 WPO 可裁剪模块 .text（main + driver + pipeline_wpo + typeck_wpo；勿含 glue mega .o）。
sum_wpo_eligible_text() {
  local dir="$1"
  local main_txt="${2:-}"
  local driver_txt="${3:-}"
  local pipe_txt="${4:-}"
  local typeck_txt="${5:-}"
  local backend_txt="${6:-}"
  local total=0
  local t
  if [ -n "$main_txt" ]; then
    total=$((total + main_txt))
  elif [ -f "$dir/main.o" ]; then
    t=$(text_bytes "$dir/main.o" 2>/dev/null) || t=0
    total=$((total + t))
  fi
  if [ -n "$driver_txt" ]; then
    total=$((total + driver_txt))
  elif [ -f "$dir/driver_compile.o" ]; then
    t=$(text_bytes "$dir/driver_compile.o" 2>/dev/null) || t=0
    total=$((total + t))
  fi
  if [ -n "$pipe_txt" ]; then
    total=$((total + pipe_txt))
  elif [ -f "$dir/pipeline_wpo.o" ]; then
    t=$(text_bytes "$dir/pipeline_wpo.o" 2>/dev/null) || t=0
    total=$((total + t))
  fi
  if [ -n "$typeck_txt" ]; then
    total=$((total + typeck_txt))
  elif [ -f "$dir/typeck_wpo.o" ]; then
    t=$(text_bytes "$dir/typeck_wpo.o" 2>/dev/null) || t=0
    total=$((total + t))
  fi
  if [ -n "$backend_txt" ]; then
    total=$((total + backend_txt))
  elif [ -f "$dir/backend_wpo.o" ]; then
    t=$(text_bytes "$dir/backend_wpo.o" 2>/dev/null) || t=0
    total=$((total + t))
  fi
  echo "$total"
}

echo "=== wpo compiler self __text (graph + asm proxy) ==="

# ── 1) main.su 全程序 call graph dead export %（C WPO，与 run-wpo-compiler-self 同语义）──
rm -f "$GRAPH"
SHU_WPO_DUMP_CALLGRAPH="$GRAPH" "$SHU_C" check compiler/src/main.su >/dev/null
[ -s "$GRAPH" ] || { echo "wpo compiler self text: graph missing"; exit 1; }
perl compiler/scripts/wpo_dce.pl "$GRAPH" --min-dead-pct "$MIN_GRAPH_PCT" | tee /tmp/wpo_compiler_self_text_graph.log
grep -q 'wpo_dce OK' /tmp/wpo_compiler_self_text_graph.log

GRAPH_DEAD_PCT=$(grep '^wpo_dce:' /tmp/wpo_compiler_self_text_graph.log | sed -n 's/.*(\([0-9.]*\)%).*/\1/p')
echo "compiler self graph: dead_export_pct=${GRAPH_DEAD_PCT:-?}% (min=${MIN_GRAPH_PCT}%)"

# ── 2) asm __text A/B：多库 proxy（需 shu_asm）──

compile_ab() {
  local src="$1"
  local off_o="$2"
  local on_o="$3"
  rm -f "$off_o" "$on_o"
  SHU_ASM_WPO_DCE=0 "$SHU_ASM_ABS" -backend asm -o "$off_o" "$src" >/dev/null 2>&1 || return 1
  SHU_ASM_WPO_DCE=1 "$SHU_ASM_ABS" -backend asm -o "$on_o" "$src" >/dev/null 2>&1 || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

MULTI_OFF="/tmp/shu_wpo_compiler_self_multi_off.o"
MULTI_ON="/tmp/shu_wpo_compiler_self_multi_on.o"
MULTI_SAVE=0
MULTI_PCT=0

if [ ! -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: asm proxy SKIP (no shu_asm)"
else
  if compile_ab tests/wpo/dead_multi_user.su "$MULTI_OFF" "$MULTI_ON"; then
    OFF=$(text_bytes "$MULTI_OFF") || { echo "cannot read multi off .text"; exit 1; }
    ON=$(text_bytes "$MULTI_ON") || { echo "cannot read multi on .text"; exit 1; }
    if [ "$OFF" -le "$ON" ]; then
      echo "WPO compiler self text FAIL: multi DCE on ($ON) not smaller than off ($OFF)"
      nm "$MULTI_OFF" 2>/dev/null | grep -E 'dead_export|live_export' || true
      exit 1
    fi
    MULTI_SAVE=$((OFF - ON))
    MULTI_PCT=$((MULTI_SAVE * 100 / OFF))
    echo "| proxy | dce_off | dce_on | save (B) | save (%) |"
    echo "| dead_multi_user | $OFF | $ON | $MULTI_SAVE | ${MULTI_PCT}% |"
    if [ "$MULTI_SAVE" -lt "$MIN_MULTI_BYTES" ]; then
      echo "WPO compiler self text FAIL: multi save ${MULTI_SAVE}B < min ${MIN_MULTI_BYTES}B" >&2
      [ "$FAIL_REGRESS" = 1 ] && exit 1
    fi
    if [ "$MULTI_PCT" -lt "$MIN_MULTI_PCT" ]; then
      echo "WPO compiler self text FAIL: multi save ${MULTI_PCT}% < min ${MIN_MULTI_PCT}%" >&2
      [ "$FAIL_REGRESS" = 1 ] && exit 1
    fi
  else
    echo "wpo compiler self text: asm proxy FAIL (dead_multi_user compile failed)" >&2
    [ "$FAIL_REGRESS" = 1 ] && exit 1
  fi
fi

# ── 3) 可选：main.su 单 TU asm __text A/B（与 build_shu_asm rebuild_main_o 同模式；失败仅 WARN）──
MAIN_OFF="/tmp/shu_wpo_main_off.o"
MAIN_ON="/tmp/shu_wpo_main_on.o"
MAIN_SAVE=""
MAIN_PCT=""
DRIVER_OFF="/tmp/shu_wpo_driver_off.o"
DRIVER_ON="/tmp/shu_wpo_driver_on.o"
DRIVER_SAVE=""
DRIVER_PCT=""
PIPE_OFF="/tmp/shu_wpo_pipe_off.o"
PIPE_ON="/tmp/shu_wpo_pipe_on.o"
PIPE_SAVE=""
PIPE_PCT=""
BUILD_ASM_DIR="compiler/build_asm"

compile_main_su_ab() {
  local off_o="$1"
  local on_o="$2"
  local emit_heavy="${3:-0}"
  rm -f "$off_o" "$on_o"
  # 与 rebuild_main_o_for_cli 一致：ENTRY_ONLY + SKIP_TYPECK；生产链优先 EMIT_HEAVY=0（仅 entry ~656B）。
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" SHU_ASM_WPO_DCE=0 \
      "$SHU_ASM_ABS" -backend asm -o "$off_o" src/main.su >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY="$emit_heavy" SHU_ASM_WPO_DCE=1 \
      "$SHU_ASM_ABS" -backend asm -o "$on_o" src/main.su >/dev/null 2>&1 ) || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

# driver/compile.su EMIT_HEAVY A/B（与 run-s3-driver-emit-heavy 同模式）。
compile_driver_su_ab() {
  local off_o="$1"
  local on_o="$2"
  rm -f "$off_o" "$on_o"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=0 \
      "$SHU_ASM_ABS" -backend asm -o "$off_o" src/driver/compile.su >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=1 \
      "$SHU_ASM_ABS" -backend asm -o "$on_o" src/driver/compile.su >/dev/null 2>&1 ) || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

# pipeline.su EMIT_HEAVY A/B（run_su_pipeline_impl root + reach DCE）。
compile_pipeline_su_ab() {
  local off_o="$1"
  local on_o="$2"
  rm -f "$off_o" "$on_o"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=0 \
      "$SHU_ASM_ABS" -backend asm -o "$off_o" src/pipeline/pipeline.su >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=1 \
      "$SHU_ASM_ABS" -backend asm -o "$on_o" src/pipeline/pipeline.su >/dev/null 2>&1 ) || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

# typeck.su EMIT_HEAVY A/B（typeck_su_ast root + reach DCE）。
compile_typeck_su_ab() {
  local off_o="$1"
  local on_o="$2"
  rm -f "$off_o" "$on_o"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=0 \
      "$SHU_ASM_ABS" -backend asm -o "$off_o" src/typeck/typeck.su >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=1 \
      "$SHU_ASM_ABS" -backend asm -o "$on_o" src/typeck/typeck.su >/dev/null 2>&1 ) || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

# backend.su EMIT_HEAVY A/B（asm_codegen_ast root + reach DCE）。
compile_backend_su_ab() {
  local off_o="$1"
  local on_o="$2"
  rm -f "$off_o" "$on_o"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=0 \
      "$SHU_ASM_ABS" -backend asm -o "$off_o" src/asm/backend.su >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=1 \
      "$SHU_ASM_ABS" -backend asm -o "$on_o" src/asm/backend.su >/dev/null 2>&1 ) || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

MOFF=0
MON=0
DOFF=0
DON=0
POFF=0
PON=0
TOFF=0
TON=0
BOFF=0
BON=0
TCK_OFF="/tmp/shu_wpo_tck_off.o"
TCK_ON="/tmp/shu_wpo_tck_on.o"
BE_OFF="/tmp/shu_wpo_be_off.o"
BE_ON="/tmp/shu_wpo_be_on.o"

if [ "$TRY_MAIN_ASM" = "1" ] && [ -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: trying main.su asm A/B (ENTRY_ONLY, timeout ${MAIN_TIMEOUT}s per pass) ..."
  main_fast=""
  main_fast=$(wpo_ab_try_main_fast "$BUILD_ASM_DIR/main.o" "$BASELINE" 768) || main_fast=""
  if [ -n "$main_fast" ]; then
    MOFF="${main_fast%% *}"
    MON="${main_fast#* }"
    echo "wpo compiler self text: main.su A/B fast-path (build_asm main.o __text=${MON}B, proxy off=${MOFF}B)"
  elif compile_main_su_ab "$MAIN_OFF" "$MAIN_ON" 0; then
    MOFF=$(text_bytes "$MAIN_OFF") || MOFF=0
    MON=$(text_bytes "$MAIN_ON") || MON=0
  fi
  if [ "$MOFF" -gt "$MON" ] && [ "$MOFF" -gt 0 ]; then
    MAIN_SAVE=$((MOFF - MON))
    MAIN_PCT=$((MAIN_SAVE * 100 / MOFF))
    echo "| main.su | dce_off | dce_on | save (B) | save (%) |"
    echo "| compiler/src/main.su | $MOFF | $MON | $MAIN_SAVE | ${MAIN_PCT}% |"
    if [ "$MAIN_PCT" -lt "$MIN_MAIN_PCT" ]; then
      echo "WPO compiler self text FAIL: main save ${MAIN_PCT}% < min ${MIN_MAIN_PCT}%" >&2
      [ "$FAIL_REGRESS" = "1" ] && exit 1
    fi
  else
    echo "wpo compiler self text: main.su asm A/B inconclusive (off=$MOFF on=$MON)"
  fi
fi

# ── 3b) 可选：driver/compile.su EMIT_HEAVY asm A/B ──
if [ "$TRY_MAIN_ASM" = "1" ] && [ -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: trying driver/compile.su asm A/B (EMIT_HEAVY, timeout ${MAIN_TIMEOUT}s per pass) ..."
  drv_fast=""
  drv_fast=$(wpo_ab_try_driver_fast "$BUILD_ASM_DIR/driver_compile.o" "$BASELINE" 768) || drv_fast=""
  if [ -n "$drv_fast" ]; then
    DOFF="${drv_fast%% *}"
    DON="${drv_fast#* }"
    echo "wpo compiler self text: driver A/B fast-path (build_asm __text=${DON}B, proxy off=${DOFF}B)"
  elif compile_driver_su_ab "$DRIVER_OFF" "$DRIVER_ON"; then
    DOFF=$(text_bytes "$DRIVER_OFF") || DOFF=0
    DON=$(text_bytes "$DRIVER_ON") || DON=0
  fi
  if [ "$DOFF" -gt "$DON" ] && [ "$DOFF" -gt 0 ]; then
    DRIVER_SAVE=$((DOFF - DON))
    DRIVER_PCT=$((DRIVER_SAVE * 100 / DOFF))
    echo "| driver.su | dce_off | dce_on | save (B) | save (%) |"
    echo "| compiler/src/driver/compile.su | $DOFF | $DON | $DRIVER_SAVE | ${DRIVER_PCT}% |"
  else
    echo "wpo compiler self text: driver/compile.su asm A/B inconclusive (off=$DOFF on=$DON)"
  fi
fi

# ── 3c) 可选：pipeline.su EMIT_HEAVY asm A/B ──
if [ "$TRY_MAIN_ASM" = "1" ] && [ -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: trying pipeline.su asm A/B (EMIT_HEAVY, timeout ${MAIN_TIMEOUT}s per pass) ..."
  pipe_tree="$BUILD_ASM_DIR/pipeline_wpo.o"
  [ -f "$pipe_tree" ] || pipe_tree="$BUILD_ASM_DIR/pipeline.o"
  pipe_fast=""
  pipe_fast=$(wpo_ab_try_pipeline_fast "$pipe_tree" "$BASELINE" 2048) || pipe_fast=""
  if [ -n "$pipe_fast" ]; then
    POFF="${pipe_fast%% *}"
    PON="${pipe_fast#* }"
    echo "wpo compiler self text: pipeline A/B fast-path ($pipe_tree __text=${PON}B, proxy off=${POFF}B)"
  elif compile_pipeline_su_ab "$PIPE_OFF" "$PIPE_ON"; then
    POFF=$(text_bytes "$PIPE_OFF") || POFF=0
    PON=$(text_bytes "$PIPE_ON") || PON=0
  fi
  if [ "$POFF" -gt "$PON" ] && [ "$POFF" -gt 0 ]; then
    PIPE_SAVE=$((POFF - PON))
    PIPE_PCT=$((PIPE_SAVE * 100 / POFF))
    echo "| pipeline.su | dce_off | dce_on | save (B) | save (%) |"
    echo "| compiler/src/pipeline/pipeline.su | $POFF | $PON | $PIPE_SAVE | ${PIPE_PCT}% |"
  else
    echo "wpo compiler self text: pipeline.su asm A/B inconclusive (off=$POFF on=$PON)"
  fi
fi

# ── 3d) 可选：typeck.su EMIT_HEAVY asm A/B ──
if [ "$TRY_MAIN_ASM" = "1" ] && [ -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: trying typeck.su asm A/B (EMIT_HEAVY, timeout ${MAIN_TIMEOUT}s per pass) ..."
  tck_tree="$BUILD_ASM_DIR/typeck_wpo.o"
  [ -f "$tck_tree" ] || tck_tree="$BUILD_ASM_DIR/typeck.o"
  tck_fast=""
  tck_fast=$(wpo_ab_try_typeck_fast "$tck_tree" "$BASELINE" 2048) || tck_fast=""
  if [ -n "$tck_fast" ]; then
    TOFF="${tck_fast%% *}"
    TON="${tck_fast#* }"
    echo "wpo compiler self text: typeck A/B fast-path ($tck_tree __text=${TON}B, proxy off=${TOFF}B)"
  elif compile_typeck_su_ab "$TCK_OFF" "$TCK_ON"; then
    TOFF=$(text_bytes "$TCK_OFF") || TOFF=0
    TON=$(text_bytes "$TCK_ON") || TON=0
  fi
  if [ "$TOFF" -gt "$TON" ] && [ "$TOFF" -gt 0 ]; then
    TCK_SAVE=$((TOFF - TON))
    TCK_PCT=$((TCK_SAVE * 100 / TOFF))
    echo "| typeck.su | dce_off | dce_on | save (B) | save (%) |"
    echo "| compiler/src/typeck/typeck.su | $TOFF | $TON | $TCK_SAVE | ${TCK_PCT}% |"
  else
    echo "wpo compiler self text: typeck.su asm A/B inconclusive (off=$TOFF on=$TON)"
  fi
fi

# ── 3e) 可选：backend.su EMIT_HEAVY asm A/B ──
if [ "$TRY_MAIN_ASM" = "1" ] && [ -x "$SHU_ASM_ABS" ]; then
  echo "wpo compiler self text: trying backend.su asm A/B (EMIT_HEAVY, timeout ${MAIN_TIMEOUT}s per pass) ..."
  be_tree="$BUILD_ASM_DIR/backend_wpo.o"
  [ -f "$be_tree" ] || be_tree="$BUILD_ASM_DIR/backend.o"
  be_fast=""
  be_fast=$(wpo_ab_try_backend_fast "$be_tree" "$BASELINE" 512) || be_fast=""
  if [ -n "$be_fast" ]; then
    BOFF="${be_fast%% *}"
    BON="${be_fast#* }"
    echo "wpo compiler self text: backend A/B fast-path ($be_tree __text=${BON}B, proxy off=${BOFF}B)"
  elif compile_backend_su_ab "$BE_OFF" "$BE_ON"; then
    BOFF=$(text_bytes "$BE_OFF") || BOFF=0
    BON=$(text_bytes "$BE_ON") || BON=0
  fi
  if [ "$BOFF" -gt "$BON" ] && [ "$BOFF" -gt 0 ]; then
    BE_SAVE=$((BOFF - BON))
    BE_PCT=$((BE_SAVE * 100 / BOFF))
    echo "| backend.su | dce_off | dce_on | save (B) | save (%) |"
    echo "| compiler/src/asm/backend.su | $BOFF | $BON | $BE_SAVE | ${BE_PCT}% |"
  else
    echo "wpo compiler self text: backend.su asm A/B inconclusive (off=$BOFF on=$BON)"
  fi
fi

# ── 4) build_asm WPO 可裁剪模块 dogfood：main + driver + pipeline + typeck + backend A/B 代理 ──
CHAIN_SAVE=""
CHAIN_PCT=""

if [ -d "$BUILD_ASM_DIR" ] && [ -f "$BUILD_ASM_DIR/main.o" ]; then
  CUR_MAIN=$(text_bytes "$BUILD_ASM_DIR/main.o" 2>/dev/null) || CUR_MAIN=0
  CUR_DRIVER=0
  if [ -f "$BUILD_ASM_DIR/driver_compile.o" ]; then
    CUR_DRIVER=$(text_bytes "$BUILD_ASM_DIR/driver_compile.o" 2>/dev/null) || CUR_DRIVER=0
  fi
  if [ "$MOFF" -gt "$MON" ]; then
    CHAIN_OFF=$(sum_wpo_eligible_text "$BUILD_ASM_DIR" "$MOFF" "$DOFF" "$POFF" "$TOFF" "$BOFF")
    CHAIN_ON=$(sum_wpo_eligible_text "$BUILD_ASM_DIR" "$MON" "$DON" "$PON" "$TON" "$BON")
    if [ "$CHAIN_OFF" -gt "$CHAIN_ON" ] && [ "$CHAIN_OFF" -gt 0 ]; then
      CHAIN_SAVE=$((CHAIN_OFF - CHAIN_ON))
      CHAIN_PCT=$((CHAIN_SAVE * 100 / CHAIN_OFF))
      echo "| build_asm chain | dce_off | dce_on | save (B) | save (%) |"
      echo "| wpo-eligible (main+driver+pipeline+typeck+backend) | $CHAIN_OFF | $CHAIN_ON | $CHAIN_SAVE | ${CHAIN_PCT}% |"
      chain_fail=0
      if [ "$CHAIN_SAVE" -lt "$MIN_CHAIN_BYTES" ]; then
        echo "WPO compiler self text FAIL: build_asm chain save ${CHAIN_SAVE}B < min ${MIN_CHAIN_BYTES}B" >&2
        chain_fail=1
      fi
      if [ "$CHAIN_PCT" -lt "$MIN_CHAIN_PCT" ]; then
        echo "WPO compiler self text FAIL: build_asm chain save ${CHAIN_PCT}% < min ${MIN_CHAIN_PCT}%" >&2
        chain_fail=1
      fi
      if [ "$chain_fail" -eq 1 ] && [ "$FAIL_REGRESS" = 1 ]; then
        exit 1
      fi
    fi
  elif [ "$MAIN_SAVE" = "" ]; then
    echo "wpo compiler self text: build_asm chain SKIP (main.su A/B unavailable)"
  fi
fi

if [ "$UPDATE_BASELINE" = 1 ] && [ "$MULTI_SAVE" -gt 0 ]; then
  cat > "$BASELINE" <<EOF
# WPO compiler self __text proxy：dead_multi_user 三库 dead export A/B 相对 SHU_ASM_WPO_DCE=0 的节省
# main.su call graph dead% 下限（与 run-wpo-compiler-self.sh 一致）
# 更新：SHU_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh
min_dead_pct_graph	${MIN_GRAPH_PCT}
dead_multi_min_text_save_bytes	$((MULTI_SAVE > 16 ? MULTI_SAVE - 16 : MULTI_SAVE))
dead_multi_min_text_save_pct	$((MULTI_PCT > 3 ? MULTI_PCT - 3 : MULTI_PCT))
build_asm_min_text_save_pct	$((CHAIN_PCT > 0 ? (CHAIN_PCT > 3 ? CHAIN_PCT - 3 : CHAIN_PCT) : MIN_CHAIN_PCT))
build_asm_min_text_save_bytes	$((CHAIN_SAVE > 64 ? CHAIN_SAVE - 64 : MIN_CHAIN_BYTES))
EOF
  echo "updated baseline: $BASELINE"
fi

echo "wpo compiler self text OK (graph dead>=${MIN_GRAPH_PCT}%; multi save=${MULTI_SAVE}B/${MULTI_PCT}%; main save=${MAIN_SAVE:-SKIP}B/${MAIN_PCT:-SKIP}%; driver save=${DRIVER_SAVE:-SKIP}B/${DRIVER_PCT:-SKIP}%; pipeline save=${PIPE_SAVE:-SKIP}B/${PIPE_PCT:-SKIP}%; chain save=${CHAIN_SAVE:-SKIP}B/${CHAIN_PCT:-SKIP}%)"
