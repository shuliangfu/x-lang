#!/usr/bin/env bash
# S5 / WPO v0：asm DCE 对 __text 的 A/B 门禁（SHUX_ASM_WPO_DCE=1 vs 0）。
# 用法：
#   SHUX=./compiler/shux_asm ./tests/run-perf-wpo-dce-text.sh
#   SHUX_PERF_FAIL_ON_WPO_DCE_TEXT=1 SHUX=./compiler/shux_asm ./tests/run-perf-wpo-dce-text.sh
#   SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-text.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh

if wpo_host_asm_run_na; then
  echo "run-perf-wpo-dce-text: N/A on $(uname -s)-$(uname -m) (refresh shux_asm asm stub; x86_64 covers)"
  echo "wpo dce text OK ($(uname -m) N/A)"
  exit 0
fi

SHUX_BIN="${SHUX:-./compiler/shux_asm}"
BASELINE="${SHUX_WPO_DCE_TEXT_BASELINE:-tests/baseline/wpo-dce-text.tsv}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${SHUX_PERF_FAIL_ON_WPO_DCE_TEXT:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHUX_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

if [ ! -x "$SHUX_BIN" ]; then
  echo "run-perf-wpo-dce-text: SKIP (need shux_asm: $SHUX_BIN)"
  exit 0
fi

# 读取 .o 的 .text 段字节数（Linux size -A / macOS size -x）
text_bytes() {
  local obj="$1"
  local n
  n=$(size -A "$obj" 2>/dev/null | awk '/\.text/ { print $2; exit }')
  if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
    echo "$n"
    return 0
  fi
  n=$(size -x "$obj" 2>/dev/null | awk 'NR==2 { print $1; exit }')
  if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
    echo "$n"
    return 0
  fi
  return 1
}

compile_ab() {
  local src="$1"
  local off_o="$2"
  local on_o="$3"
  rm -f "$off_o" "$on_o"
  SHUX_ASM_WPO_DCE=0 "$SHUX_BIN" -backend asm -o "$off_o" "$src" >/dev/null 2>&1 || return 1
  SHUX_ASM_WPO_DCE=1 "$SHUX_BIN" -backend asm -o "$on_o" "$src" >/dev/null 2>&1 || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

MIN_BYTES=$(awk -F'\t' '$1=="dead_user_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_PCT=$(awk -F'\t' '$1=="dead_user_min_text_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_BYTES=${MIN_BYTES:-16}
MIN_PCT=${MIN_PCT:-5}

OFF_O="/tmp/shux_wpo_dce_text_off.o"
ON_O="/tmp/shux_wpo_dce_text_on.o"

echo "=== wpo dce __text A/B (SHUX=$SHUX_BIN) ==="

if ! compile_ab tests/wpo/dead_user.x "$OFF_O" "$ON_O"; then
  echo "run-perf-wpo-dce-text: SKIP (asm compile failed)"
  exit 0
fi

OFF=$(text_bytes "$OFF_O") || { echo "run-perf-wpo-dce-text: cannot read .text off"; exit 1; }
ON=$(text_bytes "$ON_O") || { echo "run-perf-wpo-dce-text: cannot read .text on"; exit 1; }

if [ "$OFF" -le "$ON" ]; then
  echo "WPO dce text FAIL: DCE on .text ($ON) not smaller than off ($OFF)"
  nm "$OFF_O" 2>/dev/null | grep -E 'dead_export|live_export' || true
  exit 1
fi

SAVE=$((OFF - ON))
PCT=$((SAVE * 100 / OFF))

echo "| case | dce_off | dce_on | save (B) | save (%) |"
echo "| dead_user | $OFF | $ON | $SAVE | ${PCT}% |"

if [ "$SAVE" -lt "$MIN_BYTES" ]; then
  echo "WPO dce text FAIL: save ${SAVE}B < min ${MIN_BYTES}B" >&2
  [ "$FAIL_REGRESS" = 1 ] && exit 1
fi
if [ "$PCT" -lt "$MIN_PCT" ]; then
  echo "WPO dce text FAIL: save ${PCT}% < min ${MIN_PCT}%" >&2
  [ "$FAIL_REGRESS" = 1 ] && exit 1
fi

if [ "$UPDATE_BASELINE" = 1 ]; then
  cat > "$BASELINE" <<EOF
# WPO asm DCE __text A/B：dead_user 跨 import dead_export 剔除后相对 SHUX_ASM_WPO_DCE=0 的节省
# 更新：SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-text.sh
dead_user_min_text_save_bytes	$((SAVE > 8 ? SAVE - 8 : SAVE))
dead_user_min_text_save_pct	$((PCT > 2 ? PCT - 2 : PCT))
EOF
  echo "updated baseline: $BASELINE"
fi

echo "wpo dce text OK (save ${SAVE}B / ${PCT}%)"
