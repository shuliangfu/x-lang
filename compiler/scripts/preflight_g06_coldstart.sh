#!/usr/bin/env sh
# preflight_g06_coldstart.sh — G-06 冷启动分阶段快验（fail-fast，避免全量 bootstrap 傻等）
#
# 用法（compiler 目录，Linux x86_64 / Docker 内）：
#   ./scripts/preflight_g06_coldstart.sh           # 仅本地/seed 检查（秒级）
#   ./scripts/preflight_g06_coldstart.sh --asm-e   # 额外跑 asm.x -E 烟测（默认 timeout 300s）
#
# 环境：
#   SHUX_E              默认 ./bootstrap_shuxc 或 ./shux-c
#   SHUX_G06_E_TIMEOUT  asm -E 超时秒数，默认 300；0=不跑 --asm-e 烟测

set -e
cd "$(dirname "$0")/.."

ASM_E=0
if [ "${1:-}" = "--asm-e" ]; then
  ASM_E=1
fi

SHUX_E="${SHUX_E:-./bootstrap_shuxc}"
if [ ! -x "$SHUX_E" ] && [ -x ./shux-c ]; then
  SHUX_E=./shux-c
fi

fail() {
  echo "preflight_g06: FAIL: $*" >&2
  exit 1
}

ok() {
  echo "preflight_g06: OK: $*"
}

# --- 阶段 A：seed 清单（秒级，不依赖 shux 可运行）---
REQUIRED_GENS="lexer_gen parser_gen typeck_gen codegen_gen pipeline_gen driver_gen preprocess_gen \
  lsp_io_gen lsp_gen lsp_diag_gen lsp_io_std_heap_gen \
  driver_fmt_gen driver_check_gen driver_test_gen driver_compile_gen driver_build_gen driver_run_gen driver_emit_gen"

for f in $REQUIRED_GENS; do
  seed="seeds/${f}.linux.x86_64.c"
  if [ ! -s "$seed" ]; then
    fail "empty or missing seed: $seed (run create_driver_subcmd_gen_seeds.sh / extract_lsp_gen_seeds.sh)"
  fi
done

if [ ! -x seeds/bootstrap_shuxc.linux.x86_64 ] && [ ! -s seeds/bootstrap_shuxc.linux.x86_64 ]; then
  fail "missing seeds/bootstrap_shuxc.linux.x86_64"
fi
ok "all *_gen seeds non-empty ($(echo $REQUIRED_GENS | wc -w | tr -d ' ') files)"

# lsp_gen 不得与 x_seed_bridge / lsp_state 重复定义
if grep -q '^uint8_t \* std_heap_alloc(size_t' seeds/lsp_gen.linux.x86_64.c 2>/dev/null; then
  fail "lsp_gen seed still defines std_heap_alloc (re-run extract_lsp_gen_seeds.sh)"
fi
if grep -q 'typeck_lsp_main()' seeds/lsp_gen.linux.x86_64.c 2>/dev/null \
  && ! grep -q 'typeck_lsp_main_impl' seeds/lsp_gen.linux.x86_64.c 2>/dev/null; then
  fail "lsp_gen seed exports typeck_lsp_main (should be typeck_lsp_main_impl)"
fi
ok "lsp_gen seed symbol hygiene"

# --- 阶段 B：宿主可执行（秒级）---
if [ ! -x "$SHUX_E" ]; then
  fail "no executable SHUX_E ($SHUX_E); copy seeds/bootstrap_shuxc.linux.x86_64 -> bootstrap_shuxc"
fi
if ! "$SHUX_E" -h >/dev/null 2>&1; then
  fail "$SHUX_E -h failed (wrong arch? need Docker linux/amd64)"
fi
ok "$SHUX_E -h"

# --- 阶段 C：可选 asm.x -E 烟测（分钟级，带 timeout，失败即停）---
if [ "$ASM_E" -eq 0 ]; then
  ok "seed + binary checks passed (--asm-e skipped; use --asm-e for -E smoke)"
  exit 0
fi

TIMEOUT_SEC="${SHUX_G06_E_TIMEOUT:-300}"
OUT_DIR=build_asm/seed_host
mkdir -p "$OUT_DIR"
TMP="$OUT_DIR/preflight_asm_full_gen.c.tmp"
ERR="$OUT_DIR/preflight_asm_full_gen.err"
ASM_LIBROOT="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -L src/pipeline"

ok "asm.x -E smoke (timeout ${TIMEOUT_SEC}s, heartbeat every 15s) ..."

# 长任务心跳：无 stderr 时也能看到仍在运行（避免误以为卡住）
run_asm_e_with_heartbeat() {
  _label="asm.x -E"
  _start=$(date +%s)
  (
    if command -v timeout >/dev/null 2>&1; then
      timeout "$TIMEOUT_SEC" "$SHUX_E" $ASM_LIBROOT -E src/asm/asm.x >"$TMP" 2>"$ERR"
    else
      "$SHUX_E" $ASM_LIBROOT -E src/asm/asm.x >"$TMP" 2>"$ERR"
    fi
  ) &
  _pid=$!
  while kill -0 "$_pid" 2>/dev/null; do
    _now=$(date +%s)
    _elapsed=$((_now - _start))
    _out=0
    [ -f "$TMP" ] && _out=$(wc -c <"$TMP" | tr -d ' ')
    echo "[$(date +%H:%M:%S)] preflight_g06: ${_label} ... ${_elapsed}s elapsed, out=${_out} bytes"
    sleep 15
  done
  wait "$_pid"
  return $?
}

set +e
run_asm_e_with_heartbeat
rc=$?
set -e

if [ "$rc" -eq 124 ]; then
  fail "asm.x -E timeout after ${TIMEOUT_SEC}s (increase SHUX_G06_E_TIMEOUT or fix hang)"
fi
if [ "$rc" -ne 0 ]; then
  echo "preflight_g06: asm.x -E exit=$rc" >&2
  if [ -s "$ERR" ]; then
    echo "--- stderr tail ---" >&2
    tail -30 "$ERR" >&2
  else
    echo "(no stderr; possible crash — try: dmesg | tail)" >&2
  fi
  wc -c "$TMP" 2>/dev/null || true
  fail "asm.x -E failed"
fi
if [ ! -s "$TMP" ]; then
  fail "asm.x -E produced empty output"
fi
ok "asm.x -E smoke ($(wc -c <"$TMP" | tr -d ' ') bytes C)"

echo "preflight_g06: next: SHUX_E=$SHUX_E ./scripts/build_seed_asm_host.sh && make bootstrap-driver-seed"
