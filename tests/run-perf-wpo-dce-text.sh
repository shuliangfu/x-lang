#!/usr/bin/env bash
# S5 / WPO v0: asm DCE __text A/B gate (XLANG_ASM_WPO_DCE=1 vs 0).
#
# Honesty: soft XLANG_PERF_FAIL_ON_WPO_DCE_TEXT:-0 under-min still printed
# FAIL then OK / exit 0 was portable false-green. Missing xlang_asm soft
# SKIP→OK retired. Compile failure with a present compiler is hard die
# (refuse soft SKIP→OK). Under-min save = obs (perf residual;
# FAIL_ON_WPO_DCE_TEXT=1 still hard). Host N/A (MINGW / Linux aarch64 stub)
# = skip=1. Prefer product xlang_asm. Report run=/obs=/skip=.
#
# Usage:
#   XLANG=./compiler/xlang_asm ./tests/run-perf-wpo-dce-text.sh
#   XLANG_PERF_FAIL_ON_WPO_DCE_TEXT=1 XLANG=./compiler/xlang_asm ./tests/run-perf-wpo-dce-text.sh
#   XLANG_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-text.sh
# PLATFORM: SHARED archaeology (Linux x86_64 / Darwin cover; Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="xlang: [XLANG_PERF_WPO_DCE_TEXT]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "run-perf-wpo-dce-text FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

if wpo_host_asm_run_na; then
  SKIP=1
  echo "run-perf-wpo-dce-text: N/A on $(uname -s)-$(uname -m) (refresh xlang_asm asm stub; x86_64 covers)"
  echo "wpo dce text OK ($(uname -m) N/A)"
  echo "${PREFIX} status=ok run=0 obs=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

XLANG_BIN="${XLANG:-./compiler/xlang_asm}"
BASELINE="${XLANG_WPO_DCE_TEXT_BASELINE:-tests/baseline/wpo-dce-text.tsv}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${XLANG_PERF_FAIL_ON_WPO_DCE_TEXT:-0}" = "1" ] && FAIL_REGRESS=1
[ "${XLANG_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

if [ ! -x "$XLANG_BIN" ]; then
  die "need xlang_asm at $XLANG_BIN (refuse soft SKIP→OK)"
fi

# Read .o .text bytes (Linux size -A / macOS size -x).
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
  XLANG_ASM_WPO_DCE=0 "$XLANG_BIN" -backend asm -o "$off_o" "$src" >/dev/null 2>&1 || return 1
  XLANG_ASM_WPO_DCE=1 "$XLANG_BIN" -backend asm -o "$on_o" "$src" >/dev/null 2>&1 || return 1
  [ -s "$off_o" ] && [ -s "$on_o" ]
}

MIN_BYTES=$(awk -F'\t' '$1=="dead_user_min_text_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_PCT=$(awk -F'\t' '$1=="dead_user_min_text_save_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_BYTES=${MIN_BYTES:-16}
MIN_PCT=${MIN_PCT:-5}

OFF_O="/tmp/xlang_wpo_dce_text_off.o"
ON_O="/tmp/xlang_wpo_dce_text_on.o"

echo "=== wpo dce __text A/B (XLANG=$XLANG_BIN) ==="

if ! compile_ab tests/wpo/dead_user.x "$OFF_O" "$ON_O"; then
  die "asm compile failed for tests/wpo/dead_user.x (refuse soft SKIP→OK)"
fi
RUN_OK=1

OFF=$(text_bytes "$OFF_O") || die "cannot read .text off"
ON=$(text_bytes "$ON_O") || die "cannot read .text on"

if [ "$OFF" -le "$ON" ]; then
  echo "WPO dce text FAIL: DCE on .text ($ON) not smaller than off ($OFF)" >&2
  nm "$OFF_O" 2>/dev/null | grep -E 'dead_export|live_export' || true
  die "DCE on .text ($ON) not smaller than off ($OFF)"
fi

SAVE=$((OFF - ON))
PCT=$((SAVE * 100 / OFF))

echo "| case | dce_off | dce_on | save (B) | save (%) |"
echo "| dead_user | $OFF | $ON | $SAVE | ${PCT}% |"

if [ "$SAVE" -lt "$MIN_BYTES" ]; then
  echo "WPO dce text OBS: save ${SAVE}B < min ${MIN_BYTES}B (perf residual)" >&2
  OBS=1
  if [ "$FAIL_REGRESS" = 1 ]; then
    die "save ${SAVE}B < min ${MIN_BYTES}B (XLANG_PERF_FAIL_ON_WPO_DCE_TEXT=1)"
  fi
fi
if [ "$PCT" -lt "$MIN_PCT" ]; then
  echo "WPO dce text OBS: save ${PCT}% < min ${MIN_PCT}% (perf residual)" >&2
  OBS=1
  if [ "$FAIL_REGRESS" = 1 ]; then
    die "save ${PCT}% < min ${MIN_PCT}% (XLANG_PERF_FAIL_ON_WPO_DCE_TEXT=1)"
  fi
fi

if [ "$UPDATE_BASELINE" = 1 ]; then
  cat > "$BASELINE" <<EOF
# WPO asm DCE __text A/B：dead_user 跨 import dead_export 剔除后相对 XLANG_ASM_WPO_DCE=0 的节省
# 更新：XLANG_PERF_UPDATE_BASELINE=1 ./tests/run-perf-wpo-dce-text.sh
dead_user_min_text_save_bytes	$((SAVE > 8 ? SAVE - 8 : SAVE))
dead_user_min_text_save_pct	$((PCT > 2 ? PCT - 2 : PCT))
EOF
  echo "updated baseline: $BASELINE"
fi

echo "wpo dce text OK (save ${SAVE}B / ${PCT}%; obs=${OBS})"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} save=${SAVE} pct=${PCT} host=$(ci_host_summary)"
