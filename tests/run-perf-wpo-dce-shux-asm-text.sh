#!/usr/bin/env bash
# S5：shux_asm 全二进制 .text dogfood（实测 + wpo-eligible 模块代理反推 WPO-off 体积）。
# 全链 -3% 须多模块 WPO；本脚本先实锤 main+driver 对二进制的可度量节省。
# 用法：
#   ./tests/run-perf-wpo-dce-shux-asm-text.sh
#   SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_SHUX_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shux-asm-text.sh
#   SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-shux-asm-text.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. "$(dirname "$0")/lib/wpo-ab-proxy.sh"

# 与 gate 脚本一致：ELF/Mach-O 通用 .text 读取。
text_bytes() { wpo_ab_text_bytes "$@"; }

SHUX_ASM="${SHUX:-./compiler/shux_asm}"
case "$SHUX_ASM" in
  /*) SHUX_ASM_ABS="$SHUX_ASM" ;;
  *) SHUX_ASM_ABS="$(pwd)/$SHUX_ASM" ;;
esac
BASELINE="${SHUX_WPO_SHUX_ASM_TEXT_BASELINE:-tests/baseline/wpo-dce-shux-asm-text.tsv}"
MAIN_TIMEOUT="${SHUX_WPO_MAIN_ASM_TIMEOUT:-180}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${SHUX_PERF_FAIL_ON_WPO_SHUX_ASM_TEXT:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHUX_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

MIN_ELIGIBLE_BYTES=$(awk -F'\t' '$1=="min_wpo_eligible_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_ELIGIBLE_BYTES=${MIN_ELIGIBLE_BYTES:-600}
MIN_BINARY_PCT=$(awk -F'\t' '$1=="min_binary_proxy_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_BINARY_PCT=${MIN_BINARY_PCT:-0.3}
# stretch -3%：全链 strict bstrict 后手动/专用 job 启用（CI-fast 仅 ~0.8% proxy）
if [ "${SHUX_WPO_STRETCH_3PCT:-0}" = "1" ]; then
  MIN_BINARY_PCT=3.0
  MIN_BINARY_BYTES=12000
  MIN_ELIGIBLE_BYTES=12000
fi
MIN_BINARY_BYTES=$(awk -F'\t' '$1=="min_binary_proxy_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_BINARY_BYTES=${MIN_BINARY_BYTES:-600}

echo "=== wpo shux_asm binary __text (measured + wpo-eligible proxy) ==="

# Darwin gen_driver：ENTRY_ONLY/EMIT_HEAVY A/B 常 inconclusive（eligible save=0），Linux 覆盖 perf 门禁。
if [ "$(uname -s 2>/dev/null)" = Darwin ]; then
  echo "wpo shux_asm text: N/A on Darwin (gen_driver A/B inconclusive; Linux x86_64/ARM64 covers)"
  echo "wpo shux_asm text OK (Darwin N/A)"
  exit 0
fi

if [ ! -x "$SHUX_ASM_ABS" ]; then
  echo "wpo shux_asm text: SKIP (no shux_asm: $SHUX_ASM_ABS)"
  exit 0
fi

TEXT_ON=$(text_bytes "$SHUX_ASM_ABS") || {
  echo "wpo shux_asm text FAIL: cannot read .text from $SHUX_ASM_ABS" >&2
  exit 1
}
echo "shux_asm binary: .text=${TEXT_ON}B ($SHUX_ASM_ABS)"

BUILD_ASM="compiler/build_asm"
BASELINE_PROXY="tests/baseline/wpo-dce-compiler-self-text.tsv"
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

main_fast=$(wpo_ab_try_main_fast "$BUILD_ASM/main.o" "$BASELINE_PROXY" 768) || main_fast=""
if [ -n "$main_fast" ]; then
  MOFF="${main_fast%% *}"
  MON="${main_fast#* }"
  echo "wpo shux_asm text: main A/B fast-path (__text=${MON}B proxy off=${MOFF}B)"
fi
drv_fast=$(wpo_ab_try_driver_fast "$BUILD_ASM/driver_compile.o" "$BASELINE_PROXY" 768) || drv_fast=""
if [ -n "$drv_fast" ]; then
  DOFF="${drv_fast%% *}"
  DON="${drv_fast#* }"
  echo "wpo shux_asm text: driver A/B fast-path (__text=${DON}B proxy off=${DOFF}B)"
fi
pipe_tree="$BUILD_ASM/pipeline_wpo.o"
[ -f "$pipe_tree" ] || pipe_tree="$BUILD_ASM/pipeline.o"
pipe_fast=$(wpo_ab_try_pipeline_fast "$pipe_tree" "$BASELINE_PROXY" 2048) || pipe_fast=""
if [ -n "$pipe_fast" ]; then
  POFF="${pipe_fast%% *}"
  PON="${pipe_fast#* }"
  echo "wpo shux_asm text: pipeline A/B fast-path ($pipe_tree __text=${PON}B proxy off=${POFF}B)"
fi
tck_tree="$BUILD_ASM/typeck_wpo.o"
[ -f "$tck_tree" ] || tck_tree="$BUILD_ASM/typeck.o"
tck_fast=$(wpo_ab_try_typeck_fast "$tck_tree" "$BASELINE_PROXY" 2048) || tck_fast=""
if [ -n "$tck_fast" ]; then
  TOFF="${tck_fast%% *}"
  TON="${tck_fast#* }"
  echo "wpo shux_asm text: typeck A/B fast-path ($tck_tree __text=${TON}B proxy off=${TOFF}B)"
fi
be_tree="$BUILD_ASM/backend_wpo.o"
[ -f "$be_tree" ] || be_tree="$BUILD_ASM/backend.o"
be_fast=$(wpo_ab_try_backend_fast "$be_tree" "$BASELINE_PROXY" 512) || be_fast=""
if [ -n "$be_fast" ]; then
  BOFF="${be_fast%% *}"
  BON="${be_fast#* }"
  echo "wpo shux_asm text: backend A/B fast-path ($be_tree __text=${BON}B proxy off=${BOFF}B)"
fi

MAIN_OFF="/tmp/shux_wpo_shux_asm_main_off.o"
MAIN_ON="/tmp/shux_wpo_shux_asm_main_on.o"
DRIVER_OFF="/tmp/shux_wpo_shux_asm_driver_off.o"
DRIVER_ON="/tmp/shux_wpo_shux_asm_driver_on.o"
PIPE_OFF="/tmp/shux_wpo_shux_asm_pipe_off.o"
PIPE_ON="/tmp/shux_wpo_shux_asm_pipe_on.o"
TCK_OFF="/tmp/shux_wpo_shux_asm_tck_off.o"
TCK_ON="/tmp/shux_wpo_shux_asm_tck_on.o"
BE_OFF="/tmp/shux_wpo_shux_asm_be_off.o"
BE_ON="/tmp/shux_wpo_shux_asm_be_on.o"

compile_main_ab() {
  rm -f "$MAIN_OFF" "$MAIN_ON"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=0 SHUX_ASM_WPO_DCE=0 \
      "$SHUX_ASM_ABS" -backend asm -o "$MAIN_OFF" src/main.sx >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=0 SHUX_ASM_WPO_DCE=1 \
      "$SHUX_ASM_ABS" -backend asm -o "$MAIN_ON" src/main.sx >/dev/null 2>&1 ) || return 1
  [ -s "$MAIN_OFF" ] && [ -s "$MAIN_ON" ]
}

compile_driver_ab() {
  rm -f "$DRIVER_OFF" "$DRIVER_ON"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      "$SHUX_ASM_ABS" -backend asm -o "$DRIVER_OFF" src/driver/compile.sx >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=1 \
      "$SHUX_ASM_ABS" -backend asm -o "$DRIVER_ON" src/driver/compile.sx >/dev/null 2>&1 ) || return 1
  [ -s "$DRIVER_OFF" ] && [ -s "$DRIVER_ON" ]
}

compile_pipeline_ab() {
  rm -f "$PIPE_OFF" "$PIPE_ON"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      "$SHUX_ASM_ABS" -backend asm -o "$PIPE_OFF" src/pipeline/pipeline.sx >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=1 \
      "$SHUX_ASM_ABS" -backend asm -o "$PIPE_ON" src/pipeline/pipeline.sx >/dev/null 2>&1 ) || return 1
  [ -s "$PIPE_OFF" ] && [ -s "$PIPE_ON" ]
}

compile_typeck_ab() {
  rm -f "$TCK_OFF" "$TCK_ON"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      "$SHUX_ASM_ABS" -backend asm -o "$TCK_OFF" src/typeck/typeck.sx >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=1 \
      "$SHUX_ASM_ABS" -backend asm -o "$TCK_ON" src/typeck/typeck.sx >/dev/null 2>&1 ) || return 1
  [ -s "$TCK_OFF" ] && [ -s "$TCK_ON" ]
}

compile_backend_ab() {
  rm -f "$BE_OFF" "$BE_ON"
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      "$SHUX_ASM_ABS" -backend asm -o "$BE_OFF" src/asm/backend.sx >/dev/null 2>&1 ) || return 1
  ( cd compiler && \
    timeout "$MAIN_TIMEOUT" env SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=1 \
      "$SHUX_ASM_ABS" -backend asm -o "$BE_ON" src/asm/backend.sx >/dev/null 2>&1 ) || return 1
  [ -s "$BE_OFF" ] && [ -s "$BE_ON" ]
}

if [ "$MOFF" -eq 0 ] || [ "$MON" -eq 0 ]; then
  if compile_main_ab; then
    MOFF=$(text_bytes "$MAIN_OFF") || MOFF=0
    MON=$(text_bytes "$MAIN_ON") || MON=0
  fi
fi
if [ "$DOFF" -eq 0 ] || [ "$DON" -eq 0 ]; then
  if compile_driver_ab; then
    DOFF=$(text_bytes "$DRIVER_OFF") || DOFF=0
    DON=$(text_bytes "$DRIVER_ON") || DON=0
  fi
fi
if [ "$POFF" -eq 0 ] || [ "$PON" -eq 0 ]; then
  if compile_pipeline_ab; then
    POFF=$(text_bytes "$PIPE_OFF") || POFF=0
    PON=$(text_bytes "$PIPE_ON") || PON=0
  fi
fi
if [ "$TOFF" -eq 0 ] || [ "$TON" -eq 0 ]; then
  if compile_typeck_ab; then
    TOFF=$(text_bytes "$TCK_OFF") || TOFF=0
    TON=$(text_bytes "$TCK_ON") || TON=0
  fi
fi
if [ "$BOFF" -eq 0 ] || [ "$BON" -eq 0 ]; then
  if compile_backend_ab; then
    BOFF=$(text_bytes "$BE_OFF") || BOFF=0
    BON=$(text_bytes "$BE_ON") || BON=0
  fi
fi

ELIGIBLE_OFF=$((MOFF + DOFF + POFF + TOFF + BOFF))
ELIGIBLE_ON=$((MON + DON + PON + TON + BON))
ELIGIBLE_SAVE=0
if [ "$ELIGIBLE_OFF" -gt "$ELIGIBLE_ON" ] && [ "$ELIGIBLE_OFF" -gt 0 ]; then
  ELIGIBLE_SAVE=$((ELIGIBLE_OFF - ELIGIBLE_ON))
fi

# 代理：若 build_asm 使用 WPO 压缩 .o，则 WPO-off 二进制 .text ≈ 当前 + eligible_save。
TEXT_OFF_PROXY=$((TEXT_ON + ELIGIBLE_SAVE))
BINARY_SAVE=$ELIGIBLE_SAVE
BINARY_PCT=0
if [ "$TEXT_OFF_PROXY" -gt "$TEXT_ON" ] && [ "$TEXT_OFF_PROXY" -gt 0 ]; then
  BINARY_PCT=$(awk -v s="$BINARY_SAVE" -v o="$TEXT_OFF_PROXY" 'BEGIN { printf "%.2f", s * 100 / o }')
fi

echo "| metric | dce_on (now) | dce_off (proxy) | save (B) | save (%) |"
echo "| shux_asm .text | $TEXT_ON | $TEXT_OFF_PROXY | $BINARY_SAVE | ${BINARY_PCT}% |"
echo "| wpo-eligible TU | $ELIGIBLE_ON | $ELIGIBLE_OFF | $ELIGIBLE_SAVE | — |"
echo "| main.sx TU | $MON | $MOFF | $((MOFF - MON)) | — |"
echo "| driver/compile.sx TU | $DON | $DOFF | $((DOFF - DON)) | — |"
echo "| pipeline/pipeline.sx TU | $PON | $POFF | $((POFF - PON)) | — |"
echo "| typeck/typeck.sx TU | $TON | $TOFF | $((TOFF - TON)) | — |"
echo "| asm/backend.sx TU | $BON | $BOFF | $((BOFF - BON)) | — |"

fail=0
if [ "$ELIGIBLE_SAVE" -lt "$MIN_ELIGIBLE_BYTES" ]; then
  echo "WPO shux_asm text FAIL: wpo-eligible save ${ELIGIBLE_SAVE}B < min ${MIN_ELIGIBLE_BYTES}B" >&2
  fail=1
fi
if [ "$BINARY_SAVE" -lt "$MIN_BINARY_BYTES" ]; then
  echo "WPO shux_asm text FAIL: binary proxy save ${BINARY_SAVE}B < min ${MIN_BINARY_BYTES}B" >&2
  fail=1
fi
if awk -v p="$BINARY_PCT" -v m="$MIN_BINARY_PCT" 'BEGIN { exit (p + 0 >= m + 0) ? 0 : 1 }'; then
  :
else
  echo "WPO shux_asm text FAIL: binary proxy save ${BINARY_PCT}% < min ${MIN_BINARY_PCT}%" >&2
  fail=1
fi
if [ "$fail" -eq 1 ] && [ "$FAIL_REGRESS" = "1" ]; then
  exit 1
fi

if [ "$UPDATE_BASELINE" = "1" ] && [ "$ELIGIBLE_SAVE" -gt 0 ]; then
  cat > "$BASELINE" <<EOF
# shux_asm 全二进制 .text dogfood：wpo-eligible(main+driver+pipeline) 代理反推 WPO-off
# 更新：SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-shux-asm-text.sh
min_wpo_eligible_save_bytes	$((ELIGIBLE_SAVE > 64 ? ELIGIBLE_SAVE - 64 : ELIGIBLE_SAVE))
min_binary_proxy_save_bytes	$((BINARY_SAVE > 64 ? BINARY_SAVE - 64 : BINARY_SAVE))
min_binary_proxy_save_pct	$(awk -v p="$BINARY_PCT" 'BEGIN { v=p-0.1; if (v<0.1) v=0.1; printf "%.2f", v }')
EOF
  echo "updated baseline: $BASELINE"
fi

echo "wpo shux_asm text OK (binary .text=${TEXT_ON}B; eligible save=${ELIGIBLE_SAVE}B; proxy save=${BINARY_SAVE}B/${BINARY_PCT}%)"
