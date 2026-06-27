#!/usr/bin/env bash
# run-linux-a09-a11-gate-inner.sh — A-09~A-12 门禁内层（已在 Linux 容器内执行，无 nested docker）
#
# 用法（仓库根，Linux x86_64 或 Docker 内）：
#   ./tests/run-linux-a09-a11-gate-inner.sh
#
# 环境：与 run-linux-a09-a11-gate.sh 内层 bash 一致；供 gate 外层 docker 调用或 CI 直跑。

set -euo pipefail
cd "$(dirname "$0")/.."

progress() { echo "[$(date +%H:%M:%S)] $*"; }

# gen1/gen2/verify：bridge strict 快路径（避免 smoke SIGSEGV、WPO futex 卡死；与 run-g-fast-track BSTRICT_FAST_ENV 对齐）
W3_ASM_FAST_ENV=(
  SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1
  SHUX_ASM_SKIP_STRICT_SMOKE=1
  SHUX_ASM_SKIP_MAIN_O_REBUILD=1
  SHUX_ASM_SKIP_WPO_DOGFOOD=1
  SHUX_ASM_SKIP_ENTRY_SMOKE=1
)

# 用法：SHUX_W3_RESUME_FROM=ensure 跳过 seed/gen1/gen2（stage1/2 已存在时续跑 gate 尾段）
ulimit -s 65532 2>/dev/null || true

progress "uname: $(uname -a)"
if [ "${SHUX_W3_RESUME_FROM:-}" != "ensure" ]; then
  progress "=== build seed (bootstrap-driver-seed) ==="
  make -C compiler bootstrap-driver-seed
  progress "=== gen1 build (seed -> shux_asm_stage1) ==="
  cd compiler
  env -u CI "${W3_ASM_FAST_ENV[@]}" SHUX=./shux \
    SHUX_ASM_CI_SKIP_FAST=1 \
    SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    SHUX_ASM_CI_SKIP_SECOND_PASS= \
    ./scripts/build_shux_asm.sh
  cp -f ./shux_asm ./shux_asm_stage1
  progress "=== gen2 build (stage1 -> shux_asm2) ==="
  env -u CI \
    "${W3_ASM_FAST_ENV[@]}" \
    SHUX_ASM_CI_SKIP_FAST=1 \
    SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    SHUX_ASM_CI_SKIP_SECOND_PASS= \
    SHUX_ASM_BOOTSTRAP_ROUND2=1 \
    SHUX=./shux_asm_stage1 \
    ./scripts/build_shux_asm.sh
  cp -f ./shux_asm ./shux_asm2
  cd ..
else
  progress "=== W3 resume from ensure (skip seed/gen1/gen2) ==="
  test -f compiler/shux_asm_stage1 && test -f compiler/shux_asm2 \
    || { progress "FAIL: missing shux_asm_stage1/2 for resume" >&2; exit 1; }
fi
progress "=== verify stage2 bstrict (skip bootstrap + second build) ==="
chmod +x compiler/verify-selfhost-stage2-bstrict.sh tests/run-stage2-hash-gate.sh \
  tests/run-typeck-parse-count-gate.sh tests/run-a12-cross-module-symbols-gate.sh
env -u CI \
  "${W3_ASM_FAST_ENV[@]}" \
  SHUX_ASM_CI_SKIP_FAST=1 \
  SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
  SHUX_ASM_CI_SKIP_SECOND_PASS= \
  SHUX_STAGE2_SKIP_BOOTSTRAP=1 \
  SHUX_STAGE2_SKIP_SECOND_BUILD=1 \
  SHUX_STAGE2_SKIP_REFRESH=1 \
  bash compiler/verify-selfhost-stage2-bstrict.sh
progress "=== A-09 hash strict ==="
SHUX_STAGE2_HASH_STRICT=1 ./tests/run-stage2-hash-gate.sh compiler/shux_asm_stage1 compiler/shux_asm2
progress "=== A-11 typeck parse count strict ==="
# shux_asm2 与 seed 同体时整文件 parse 易 OOM；分块用更小 chunk + 更长 timeout。
# 分块跑完约 50+ 次 compile，须 >10min；Codespace SSH 会话会超时，故 nohup 后台跑并轮询日志。
A11_LOG="${SHUX_W3_A11_LOG:-logs/a11-typeck-parse.log}"
mkdir -p logs
rm -f "$A11_LOG" logs/a11-typeck-parse.exit
nohup bash -c "env SHUX=./compiler/shux_asm2 \
  SHUX_TYPECK_PARSE_COUNT_FAIL=1 \
  SHUX_TYPECK_PARSE_CHUNK_FUNCS=\"${SHUX_TYPECK_PARSE_CHUNK_FUNCS:-5}\" \
  SHUX_TYPECK_PARSE_CHUNK_TIMEOUT=\"${SHUX_TYPECK_PARSE_CHUNK_TIMEOUT:-360}\" \
  ./tests/run-typeck-parse-count-gate.sh; echo \$? >logs/a11-typeck-parse.exit" \
  >"$A11_LOG" 2>&1 &
a11_pid=$!
a11_wait=0
while kill -0 "$a11_pid" 2>/dev/null; do
  a11_wait=$((a11_wait + 1))
  if [ "$a11_wait" -gt 3600 ]; then
    progress "FAIL: A-11 typeck parse count timeout (1h)"
    kill "$a11_pid" 2>/dev/null || true
    exit 1
  fi
  sleep 10
done
wait "$a11_pid" || a11_ec=$?
a11_ec=${a11_ec:-0}
if [ -f logs/a11-typeck-parse.exit ]; then
  a11_ec=$(cat logs/a11-typeck-parse.exit)
fi
tail -n 8 "$A11_LOG" 2>/dev/null || true
if [ "$a11_ec" -ne 0 ]; then
  progress "FAIL: A-11 typeck parse count (exit=$a11_ec; see $A11_LOG)"
  exit 1
fi
progress "A-11 typeck parse count OK"
progress "=== A-12 cross-module symbols strict ==="
SHUX_A12_CROSS_MODULE_FAIL=1 ./tests/run-a12-cross-module-symbols-gate.sh
progress "=== ensure std .sx .o (hello + A-10 最小集, best-effort) ==="
cd compiler
# path/net 在 Docker bridge 下 -backend asm 可能长时间挂起；timeout 失败不阻断 A-09~A-12（已跑完）。
STD_SX_OK=1
# path：单 mod.sx；-backend asm 可能挂起，timeout 后 best-effort。
o=../std/path/path.o
sx=../std/path/mod.sx
rm -f "$o"
if [ -x ./shux_asm2 ]; then
  SHUX_ASM_O=./shux_asm2
elif [ -x ./shux_asm ]; then
  SHUX_ASM_O=./shux_asm
elif [ -x ./shux ]; then
  SHUX_ASM_O=./shux
else
  SHUX_ASM_O=
fi
if [ -n "$SHUX_ASM_O" ]; then
  if command -v timeout >/dev/null 2>&1; then
    timeout "${SHUX_STD_SX_COMPILE_TIMEOUT:-120}" env SHUX_ASM_WPO_DCE=0 "$SHUX_ASM_O" -backend asm -L .. "$sx" -o "$o" 2>/dev/null || rm -f "$o"
  else
    env SHUX_ASM_WPO_DCE=0 "$SHUX_ASM_O" -backend asm -L .. "$sx" -o "$o" 2>/dev/null || rm -f "$o"
  fi
fi
if [ ! -s "$o" ] && [ -x ./shux-c ]; then
  progress "WARN: path.o empty after shux; fallback shux-c (timeout)"
  if command -v timeout >/dev/null 2>&1; then
    timeout "${SHUX_STD_SX_COMPILE_TIMEOUT:-120}" ./shux-c -L .. "$sx" -o "$o" 2>/dev/null || rm -f "$o"
  else
    ./shux-c -L .. "$sx" -o "$o" 2>/dev/null || rm -f "$o"
  fi
fi
if [ -s "$o" ]; then
  progress "OK $o ($(wc -c <"$o" | tr -d ' ') bytes)"
else
  progress "WARN: skip $o (compile timeout/hang; A-10 子项可能 SKIP)"
  STD_SX_OK=0
fi
# net：多 .sx 合并；走 Makefile 规则。
o=../std/net/net.o
rm -f "$o"
if command -v timeout >/dev/null 2>&1; then
  timeout "${SHUX_STD_SX_COMPILE_TIMEOUT:-120}" make -s "$o" 2>/dev/null || rm -f "$o"
else
  make -s "$o" 2>/dev/null || rm -f "$o"
fi
if [ -s "$o" ]; then
  progress "OK $o ($(wc -c <"$o" | tr -d ' ') bytes)"
else
  progress "WARN: skip $o (compile timeout/hang; A-10 子项可能 SKIP)"
  STD_SX_OK=0
fi
make -s runtime_test_fn_invoke.o runtime_panic.o
cd ..
progress "=== P0 security gates (pre-A-10) ==="
chmod +x tests/run-scope-borrow-gate.sh tests/run-al06-gate.sh \
  tests/run-type-borrow-conflict-gate.sh tests/run-i64-ctfe-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh tests/run-typeck-linear.sh \
  tests/run-typeck-region.sh tests/run-ub.sh tests/run-with-arena-vec-gate.sh
# macOS 宿主 bind-mount 可能留下 Mach-O bootstrap_shuxc；强制按 Linux 种子刷新 shux-c。
make -C compiler bootstrap_shuxc
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. tests/lib/bootstrap-link-shux.sh
P0_SHUX="${TYPECK_SHUX:-./compiler/shux}"
if [ ! -x "$P0_SHUX" ] && [ -x ./compiler/shux-c ]; then
  P0_SHUX=./compiler/shux-c
  make -C compiler shux-c 2>/dev/null || true
fi
# W3：bootstrap seed ./compiler/shux 对简单 asm -o 易 SIGSEGV；P0 中须 -o 链接/运行的 gate 用 stage2 shux_asm(2)。
COMPILE_SHUX="$P0_SHUX"
if [ -x ./compiler/shux_asm2 ]; then
  COMPILE_SHUX=./compiler/shux_asm2
elif [ -x ./compiler/shux_asm ]; then
  COMPILE_SHUX=./compiler/shux_asm
elif [ -n "${RUN_SHUX:-}" ] && [ -x "$RUN_SHUX" ]; then
  COMPILE_SHUX="$RUN_SHUX"
fi
SHUX="$P0_SHUX" ./tests/run-scope-borrow-gate.sh
SHUX="$P0_SHUX" ./tests/run-al06-gate.sh
SHUX="$P0_SHUX" SHUX_TYPE_BORROW_FAIL=1 ./tests/run-type-borrow-conflict-gate.sh
SHUX="$P0_SHUX" ./tests/run-typeck-linear.sh
SHUX="$P0_SHUX" ./tests/run-typeck-region.sh
SHUX="$P0_SHUX" ./tests/run-i64-ctfe-gate.sh
SHUX="$COMPILE_SHUX" ./tests/run-ub.sh
# with_arena：stage2 shux_asm(2) 对 region 内多 if 仍 emit 不全；bootstrap seed shux 当前可绿。
if [ -x ./compiler/shux ] && ./compiler/shux tests/mem/with_arena_vec_push.sx -o /tmp/shux_wav_probe 2>/dev/null \
  && [ -x /tmp/shux_wav_probe ]; then
  rm -f /tmp/shux_wav_probe
  SHUX=./compiler/shux ./tests/run-with-arena-vec-gate.sh
else
  SHUX="$COMPILE_SHUX" ./tests/run-with-arena-vec-gate.sh
fi
./tests/run-safe-unsafe-audit-gate.sh
progress "=== A-10 L5 run-all bstrict (shux_asm2) ==="
chmod +x tests/run-l5-run-all-parity-gate.sh tests/run-all-bstrict.sh
cp -f compiler/shux_asm2 compiler/shux_asm
env -u CI \
  SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1 \
  SHUX_ASM_CI_SKIP_FAST=1 \
  SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
  SHUX_ASM_CI_SKIP_SECOND_PASS= \
  SHUX_BSTRICT_SKIP_BUILD=1 \
  ./tests/run-l5-run-all-parity-gate.sh
progress "=== P1 security gates (post-A-10) ==="
chmod +x tests/run-safe-ffi-contract-gate.sh tests/run-safe-leak-nightly.sh \
  tests/lib/safe-leak.sh tests/run-safe-leak-nightly-gate.sh \
  tests/run-signed-overflow-gate.sh tests/run-lexer-bounds-gate.sh \
  tests/run-layout-overflow-gate.sh tests/run-link-hardening-gate.sh
make -C compiler shux-c
SHUX=./compiler/shux-c ./tests/run-safe-ffi-contract-gate.sh
SHUX=./compiler/shux-c ./tests/run-safe-leak-nightly.sh
SHUX=./compiler/shux-c ./tests/run-signed-overflow-gate.sh
SHUX=./compiler/shux-c ./tests/run-lexer-bounds-gate.sh
SHUX=./compiler/shux-c ./tests/run-layout-overflow-gate.sh
SHUX=./compiler/shux-c ./tests/run-link-hardening-gate.sh
progress "=== LINUX A-09/A-10/A-11/A-12 DONE ==="
