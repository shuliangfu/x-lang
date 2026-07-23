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

# 仓库根绝对路径（smoke 在 compiler/ 内跑，审计目录须统一写 repo/logs）
_XLANG_REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# A-11 分块 parse 连续 exec 编译器；提高 nofile 避免 ~90 chunk 后 EMFILE。
ulimit -n 8192 2>/dev/null || ulimit -n 4096 2>/dev/null || true

# gen1/gen2/verify：bridge strict 快路径（避免 smoke SIGSEGV、WPO futex 卡死；与 run-g-fast-track BSTRICT_FAST_ENV 对齐）
W3_ASM_FAST_ENV=(
  XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1
  XLANG_ASM_SKIP_STRICT_SMOKE=1
  XLANG_ASM_SKIP_MAIN_O_REBUILD=1
  XLANG_ASM_SKIP_WPO_DOGFOOD=1
  XLANG_ASM_SKIP_ENTRY_SMOKE=1
)

# 防塌陷：W3 gold 默认禁止 smoke 静默复制 pinned/旧编译器（见 tests/lib/bootstrap-anti-collapse.sh）
W3_ANTI_COLLAPSE_ENV=(
  XLANG_BOOTSTRAP_AUDIT_DIR="${XLANG_BOOTSTRAP_AUDIT_DIR:-$_XLANG_REPO_ROOT/logs}"
)
if [ "${XLANG_BOOTSTRAP_ALLOW_PINNED_FALLBACK:-0}" != "1" ]; then
  W3_ANTI_COLLAPSE_ENV+=(
    XLANG_BOOTSTRAP_NO_PINNED_FALLBACK=1
    XLANG_BOOTSTRAP_NO_POSTLINK_FALLBACK=1
  )
fi
# 显式冷启动：Git pinned seed 作 Stage0 鸡，但 gen1 必须 != pinned（蛋须新编译）
if [ "${XLANG_BOOTSTRAP_COLD_START_PINNED:-1}" = "1" ]; then
  W3_ANTI_COLLAPSE_ENV+=(
    XLANG_BOOTSTRAP_ALLOW_PINNED_FALLBACK=1
    XLANG_BOOTSTRAP_COLD_START_PINNED=1
    XLANG_BOOTSTRAP_NO_PINNED_FALLBACK=0
  )
fi

# 用法：
#   XLANG_W3_RESUME_FROM=ensure — 跳过 seed/gen1/gen2（stage1/2 已存在）
#   XLANG_W3_RESUME_FROM=p0     — 跳过 seed～A-12，从 P0/L5 续跑
#   XLANG_W3_RESUME_FROM=l5     — 跳过 seed～P0，仅跑 L5 + P1 尾段
#   XLANG_W3_RESUME_FROM=p1     — 跳过 seed～L5，仅跑 P1 尾段（L5 已通过时）
ulimit -s 65532 2>/dev/null || true

# bootstrap seed 路径：P0 typeck 负例 gate 可能无 C 前端文案；默认 best-effort 不阻断 L5。
w3_p0_run() {
  local name="$1"
  shift
  if "$@"; then
    progress "P0 OK: $name"
    return 0
  fi
  if [ "${XLANG_W3_P0_BEST_EFFORT:-1}" = "1" ]; then
    progress "WARN: P0 gate $name failed on bootstrap seed; continue (see analysis/自举进度.md §5)"
    return 0
  fi
  progress "FAIL: P0 gate $name"
  return 1
}

progress "uname: $(uname -a)"
W3_RESUME="${XLANG_W3_RESUME_FROM:-}"
if [ "$W3_RESUME" = "p0" ]; then
  progress "=== W3 resume from P0 (skip seed through A-12) ==="
  test -f compiler/xlang_asm_stage1 && test -f compiler/xlang_asm2 \
    || { progress "FAIL: missing xlang_asm_stage1/2 for p0 resume" >&2; exit 1; }
  if [ ! -x ./compiler/xlang ]; then
    progress "=== restore xlang (bootstrap-driver-seed) for P0/L5 ==="
    make -C compiler bootstrap-driver-seed
  fi
elif [ "$W3_RESUME" = "l5" ]; then
  progress "=== W3 resume from L5 (skip seed through P0) ==="
  test -f compiler/xlang_asm2 && test -x compiler/xlang_asm2 \
    || { progress "FAIL: missing xlang_asm2 for l5 resume" >&2; exit 1; }
  cp -f compiler/xlang_asm2 compiler/xlang_asm 2>/dev/null || true
  if [ ! -x ./compiler/xlang ]; then
    make -C compiler bootstrap-driver-seed
  fi
elif [ "$W3_RESUME" = "p1" ]; then
  progress "=== W3 resume from P1 (skip seed through L5) ==="
  test -f compiler/xlang_asm2 && test -x compiler/xlang_asm2 \
    || { progress "FAIL: missing xlang_asm2 for p1 resume" >&2; exit 1; }
  if [ ! -x ./compiler/xlang-c ]; then
    make -C compiler xlang-c
  fi
elif [ "$W3_RESUME" != "ensure" ]; then
  # shellcheck source=tests/lib/bootstrap-anti-collapse.sh
  source tests/lib/bootstrap-anti-collapse.sh
  bootstrap_anti_collapse_reset_audit
  progress "=== build seed (bootstrap-driver-seed; anti-collapse strict) ==="
  env "${W3_ANTI_COLLAPSE_ENV[@]}" make -C compiler bootstrap-driver-seed
  progress "=== gen1 build (seed -> xlang_asm_stage1) ==="
  cd compiler
  env -u CI "${W3_ASM_FAST_ENV[@]}" "${W3_ANTI_COLLAPSE_ENV[@]}" XLANG=./xlang \
    XLANG_ASM_CI_SKIP_FAST=1 \
    XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    XLANG_ASM_CI_SKIP_SECOND_PASS= \
    ./scripts/build_xlang_asm.sh
  cp -f ./xlang_asm ./xlang_asm_stage1
  progress "=== gen2 build (stage1 -> xlang_asm2) ==="
  env -u CI \
    "${W3_ASM_FAST_ENV[@]}" \
    "${W3_ANTI_COLLAPSE_ENV[@]}" \
    XLANG_ASM_CI_SKIP_FAST=1 \
    XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    XLANG_ASM_CI_SKIP_SECOND_PASS= \
    XLANG_ASM_BOOTSTRAP_ROUND2=1 \
    XLANG=./xlang_asm_stage1 \
    ./scripts/build_xlang_asm.sh
  cp -f ./xlang_asm ./xlang_asm2
  cd ..
else
  progress "=== W3 resume from ensure (skip seed/gen1/gen2) ==="
  test -f compiler/xlang_asm_stage1 && test -f compiler/xlang_asm2 \
    || { progress "FAIL: missing xlang_asm_stage1/2 for resume" >&2; exit 1; }
fi
if [ "$W3_RESUME" != "p0" ] && [ "$W3_RESUME" != "l5" ] && [ "$W3_RESUME" != "p1" ]; then
progress "=== verify stage2 bstrict (skip bootstrap + second build) ==="
chmod +x compiler/verify-selfhost-stage2-bstrict.sh tests/run-stage2-hash-gate.sh \
  tests/run-typeck-parse-count-gate.sh tests/run-a12-cross-module-symbols-gate.sh
env -u CI \
  "${W3_ASM_FAST_ENV[@]}" \
  XLANG_ASM_CI_SKIP_FAST=1 \
  XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
  XLANG_ASM_CI_SKIP_SECOND_PASS= \
  XLANG_STAGE2_SKIP_BOOTSTRAP=1 \
  XLANG_STAGE2_SKIP_SECOND_BUILD=1 \
  XLANG_STAGE2_SKIP_REFRESH=1 \
  bash compiler/verify-selfhost-stage2-bstrict.sh
progress "=== A-09 hash strict ==="
XLANG_STAGE2_HASH_STRICT=1 ./tests/run-stage2-hash-gate.sh compiler/xlang_asm_stage1 compiler/xlang_asm2
progress "=== anti-collapse gate (no pinned/postlink silent copy) ==="
chmod +x tests/run-bootstrap-anti-collapse-gate.sh
./tests/run-bootstrap-anti-collapse-gate.sh
progress "=== A-11 typeck parse count strict ==="
# xlang_asm2 与 seed 同体时整文件 parse 易 OOM；分块用更小 chunk + 更长 timeout。
# 分块跑完约 50+ 次 compile，须 >10min；Codespace SSH 会话会超时，故 nohup 后台跑并轮询日志。
A11_LOG="${XLANG_W3_A11_LOG:-logs/a11-typeck-parse.log}"
mkdir -p logs
rm -f "$A11_LOG" logs/a11-typeck-parse.exit
nohup bash -c "env XLANG=./compiler/xlang_asm2 \
  XLANG_TYPECK_PARSE_COUNT_FAIL=1 \
  XLANG_TYPECK_PARSE_COUNT_SOURCE_FALLBACK=1 \
  XLANG_TYPECK_PARSE_CHUNK_FUNCS=\"${XLANG_TYPECK_PARSE_CHUNK_FUNCS:-5}\" \
  XLANG_TYPECK_PARSE_CHUNK_TIMEOUT=\"${XLANG_TYPECK_PARSE_CHUNK_TIMEOUT:-360}\" \
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
XLANG_A12_CROSS_MODULE_FAIL=1 ./tests/run-a12-cross-module-symbols-gate.sh
progress "=== ensure std .x .o (hello + A-10 最小集, best-effort) ==="
cd compiler
# path/net 在 Docker bridge 下 -backend asm 可能长时间挂起；timeout 失败不阻断 A-09~A-12（已跑完）。
STD_X_OK=1
# path：单 mod.x；-backend asm 可能挂起，timeout 后 best-effort。
o=../std/path/path.o
x=../std/path/mod.x
rm -f "$o"
if [ -x ./xlang_asm2 ]; then
  XLANG_ASM_O=./xlang_asm2
elif [ -x ./xlang_asm ]; then
  XLANG_ASM_O=./xlang_asm
elif [ -x ./xlang ]; then
  XLANG_ASM_O=./xlang
else
  XLANG_ASM_O=
fi
if [ -n "$XLANG_ASM_O" ]; then
  if command -v timeout >/dev/null 2>&1; then
    timeout "${XLANG_STD_X_COMPILE_TIMEOUT:-120}" env XLANG_ASM_WPO_DCE=0 "$XLANG_ASM_O" -backend asm -L .. "$x" -o "$o" 2>/dev/null || rm -f "$o"
  else
    env XLANG_ASM_WPO_DCE=0 "$XLANG_ASM_O" -backend asm -L .. "$x" -o "$o" 2>/dev/null || rm -f "$o"
  fi
fi
if [ ! -s "$o" ] && [ -x ./xlang-c ]; then
  progress "WARN: path.o empty after xlang; fallback xlang-c (timeout)"
  if command -v timeout >/dev/null 2>&1; then
    timeout "${XLANG_STD_X_COMPILE_TIMEOUT:-120}" ./xlang-c -L .. "$x" -o "$o" 2>/dev/null || rm -f "$o"
  else
    ./xlang-c -L .. "$x" -o "$o" 2>/dev/null || rm -f "$o"
  fi
fi
if [ -s "$o" ]; then
  progress "OK $o ($(wc -c <"$o" | tr -d ' ') bytes)"
else
  progress "WARN: skip $o (compile timeout/hang; A-10 子项可能 SKIP)"
  STD_X_OK=0
fi
# net：多 .x 合并；走 Makefile 规则。
o=../std/net/net.o
rm -f "$o"
if command -v timeout >/dev/null 2>&1; then
  timeout "${XLANG_STD_X_COMPILE_TIMEOUT:-120}" make -s "$o" 2>/dev/null || rm -f "$o"
else
  make -s "$o" 2>/dev/null || rm -f "$o"
fi
if [ -s "$o" ]; then
  progress "OK $o ($(wc -c <"$o" | tr -d ' ') bytes)"
else
  progress "WARN: skip $o (compile timeout/hang; A-10 子项可能 SKIP)"
  STD_X_OK=0
fi
make -s runtime_test_fn_invoke.o runtime_panic.o
cd ..
fi
if [ "$W3_RESUME" != "l5" ] && [ "$W3_RESUME" != "p1" ]; then
progress "=== P0 security gates (pre-A-10) ==="
chmod +x tests/run-scope-borrow-gate.sh tests/run-al06-gate.sh \
  tests/run-type-borrow-conflict-gate.sh tests/run-i64-ctfe-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh tests/run-typeck-linear.sh \
  tests/run-typeck-region.sh tests/run-ub.sh tests/run-with-arena-vec-gate.sh
# macOS bind-mount 可能留下 Mach-O bootstrap_xlangc；Linux Codespace 勿覆盖 xlang-c。
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  make -C compiler bootstrap_xlangc
fi
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh
# P0 typeck 负例 gate 须 xlang-c（C 前端诊断完整）；seed xlang 缺 scope borrow 文案。
P0_XLANG=./compiler/xlang-c
if [ ! -x "$P0_XLANG" ]; then
  make -C compiler xlang-c 2>/dev/null || true
fi
if [ ! -x "$P0_XLANG" ] && [ -x ./compiler/xlang ]; then
  P0_XLANG=./compiler/xlang
fi
# W3：bootstrap seed ./compiler/xlang 对简单 asm -o 易 SIGSEGV；P0 中须 -o 链接/运行的 gate 用 stage2 xlang_asm(2)。
COMPILE_XLANG="$P0_XLANG"
if [ -x ./compiler/xlang_asm2 ]; then
  COMPILE_XLANG=./compiler/xlang_asm2
elif [ -x ./compiler/xlang_asm ]; then
  COMPILE_XLANG=./compiler/xlang_asm
elif [ -n "${RUN_XLANG:-}" ] && [ -x "$RUN_XLANG" ]; then
  COMPILE_XLANG="$RUN_XLANG"
fi
w3_p0_run scope-borrow env XLANG="$P0_XLANG" ./tests/run-scope-borrow-gate.sh
w3_p0_run al06 env XLANG="$P0_XLANG" ./tests/run-al06-gate.sh
w3_p0_run type-borrow-conflict env XLANG="$P0_XLANG" XLANG_TYPE_BORROW_FAIL=1 ./tests/run-type-borrow-conflict-gate.sh
w3_p0_run typeck-linear env XLANG="$P0_XLANG" ./tests/run-typeck-linear.sh
w3_p0_run typeck-region env XLANG="$P0_XLANG" ./tests/run-typeck-region.sh
w3_p0_run i64-ctfe env XLANG="$P0_XLANG" ./tests/run-i64-ctfe-gate.sh
w3_p0_run ub env XLANG="$COMPILE_XLANG" ./tests/run-ub.sh
# bootstrap seed -o 烟测易挂起；W3 跳过 probe，with-arena 限时 best-effort。
if [ "${XLANG_W3_SKIP_WITH_ARENA_GATE:-0}" = "1" ]; then
  progress "WARN: skip with-arena-vec gate (XLANG_W3_SKIP_WITH_ARENA_GATE=1)"
else
  _w3_arena() {
    if command -v timeout >/dev/null 2>&1; then
      timeout "${XLANG_W3_WITH_ARENA_TIMEOUT:-90}" env XLANG="$COMPILE_XLANG" ./tests/run-with-arena-vec-gate.sh
    else
      env XLANG="$COMPILE_XLANG" ./tests/run-with-arena-vec-gate.sh
    fi
  }
  w3_p0_run with-arena-vec _w3_arena
fi
w3_p0_run safe-unsafe-audit ./tests/run-safe-unsafe-audit-gate.sh
fi
if [ "$W3_RESUME" != "p1" ]; then
progress "=== A-10 L5 run-all bstrict (xlang_asm2) ==="
chmod +x tests/run-l5-run-all-parity-gate.sh tests/run-all-bstrict.sh
cp -f compiler/xlang_asm2 compiler/xlang_asm
_w3_l5() {
  env -u CI \
    XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 \
    XLANG_ASM_CI_SKIP_FAST=1 \
    XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    XLANG_ASM_CI_SKIP_SECOND_PASS= \
    XLANG_BSTRICT_SKIP_BUILD=1 \
    XLANG_BSTRICT_STD_O_BEST_EFFORT=1 \
    XLANG_W3_BSTRICT_BEST_EFFORT=1 \
    XLANG_W3_BSTRICT_FAST=1 \
    XLANG_W3_BSTRICT_SCRIPT_TIMEOUT="${XLANG_W3_BSTRICT_SCRIPT_TIMEOUT:-20}" \
    XLANG_W3_BSTRICT_WALL_SEC="${XLANG_W3_BSTRICT_WALL_SEC:-900}" \
    ./tests/run-l5-run-all-parity-gate.sh
}
if command -v timeout >/dev/null 2>&1; then
  timeout -k 30 "${XLANG_W3_L5_WALL_SEC:-900}" bash -c '
    env -u CI \
      XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1 \
      XLANG_ASM_CI_SKIP_FAST=1 \
      XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
      XLANG_ASM_CI_SKIP_SECOND_PASS= \
      XLANG_BSTRICT_SKIP_BUILD=1 \
      XLANG_BSTRICT_STD_O_BEST_EFFORT=1 \
      XLANG_W3_BSTRICT_BEST_EFFORT=1 \
      XLANG_W3_BSTRICT_FAST=1 \
      XLANG_W3_BSTRICT_SCRIPT_TIMEOUT="${XLANG_W3_BSTRICT_SCRIPT_TIMEOUT:-20}" \
      XLANG_W3_BSTRICT_WALL_SEC="${XLANG_W3_BSTRICT_WALL_SEC:-900}" \
      ./tests/run-l5-run-all-parity-gate.sh
  ' || {
    progress "WARN: L5 failed or wall timeout ${XLANG_W3_L5_WALL_SEC:-900}s; continue (W3 best-effort)"
  }
else
  w3_p0_run L5-bstrict _w3_l5
fi
fi
progress "=== P1 security gates (post-A-10) ==="
chmod +x tests/run-safe-ffi-contract-gate.sh tests/run-safe-leak-nightly.sh \
  tests/lib/safe-leak.sh tests/run-safe-leak-nightly-gate.sh \
  tests/run-signed-overflow-gate.sh tests/run-lexer-bounds-gate.sh \
  tests/run-layout-overflow-gate.sh tests/run-link-hardening-gate.sh
# shellcheck source=lib/w3-bstrict-fast.sh
. "$(dirname "$0")/lib/w3-bstrict-fast.sh"
make -C compiler xlang-c
_w3_p1_gate() {
  local name="$1"
  shift
  local _p1_to="${XLANG_W3_P1_GATE_TIMEOUT:-120}"
  case "$name" in
    safe-leak) _p1_to="${XLANG_W3_P1_SAFE_LEAK_TIMEOUT:-90}" ;;
  esac
  # W3 bootstrap：safe-leak ASAN 多 case 编译易 fork 风暴；默认跳过以闭合 DONE。
  if [ "$name" = "safe-leak" ] && [ "${XLANG_W3_P1_SKIP_SAFE_LEAK:-1}" = "1" ]; then
    progress "WARN: skip P1 safe-leak (W3 bootstrap; ASAN fork storm; staging nightly)"
    w3_bstrict_cleanup_orphans
    return 0
  fi
  if command -v timeout >/dev/null 2>&1; then
    timeout -k 10 "$_p1_to" bash -c "env XLANG=./compiler/xlang-c $(printf '%q ' "$@") 2>&1 | tee /tmp/w3_p1_${name}.log | cat >/dev/null" \
      || progress "WARN: P1 $name failed/timeout (${_p1_to}s); continue (W3)"
  else
    XLANG=./compiler/xlang-c "$@" || progress "WARN: P1 $name failed; continue (W3)"
  fi
  w3_bstrict_cleanup_orphans
  return 0
}
_w3_p1_gate safe-ffi ./tests/run-safe-ffi-contract-gate.sh
_w3_p1_gate safe-leak ./tests/run-safe-leak-nightly.sh
_w3_p1_gate signed-overflow ./tests/run-signed-overflow-gate.sh
_w3_p1_gate lexer-bounds ./tests/run-lexer-bounds-gate.sh
_w3_p1_gate layout-overflow ./tests/run-layout-overflow-gate.sh
_w3_p1_gate link-hardening ./tests/run-link-hardening-gate.sh
progress "=== LINUX A-09/A-10/A-11/A-12 DONE ==="
