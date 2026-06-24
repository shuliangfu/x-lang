#!/usr/bin/env bash
# run-g-fast-track.sh — 阶段 G 高效率分波回归（fail-fast，实时输出）
#
# 按耗时分波执行；默认只跑 W0+W1（约 1～3 分钟）。全链用 W2/W3 或 run-full-suite-stream。
#
# 用法（仓库根）：
#   ./tests/run-g-fast-track.sh              # W0 + W1（推荐日常）
#   ./tests/run-g-fast-track.sh --w2         # + W2（~10～20min，Docker）
#   ./tests/run-g-fast-track.sh --w2-d03-only # 仅 D-03 哈希（~5s，须已有 shux_asm_stage1/2）
#   ./tests/run-g-fast-track.sh --w3         # + W3（~1h+，Docker，慎用）
#   ./tests/run-g-fast-track.sh --w0-only    # 仅本地秒级清单
#
# 环境：
#   SHUX_FAST_TRACK_FAIL=1     任一步失败即 exit 1（默认 1）
#   SHUX_DOCKER_PERSIST=1      Docker 常驻容器（W1+ 推荐）
#   SHUX_G06_E_TIMEOUT=120     preflight --asm-e 超时（默认 W1 不跑 --asm-e）
#   SHUX_FAST_TRACK_LOG_DIR    日志目录（默认 /tmp/shux-fast-track-$$）
#
# 日志：各波次 tee 到 LOG_DIR；另开终端 tail -f $LOG_DIR/w1-g06-bootstrap.log

set -euo pipefail
cd "$(dirname "$0")/.."

PROGRESS="./tests/lib/progress-run.sh"
DOCKER="./tests/lib/docker-linux-run.sh"
LOG_DIR="${SHUX_FAST_TRACK_LOG_DIR:-/tmp/shux-fast-track-$$}"
FAIL="${SHUX_FAST_TRACK_FAIL:-1}"

W0_ONLY=0
RUN_W2=0
RUN_W2_D03_ONLY=0
RUN_W3=0
RUN_P0="${SHUX_FAST_TRACK_P0:-0}"

# B-strict bridge/Docker 快路径：跳过 main/WPO/smoke 重编（改 build 脚本日常联调）
BSTRICT_FAST_ENV=(
  SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1
  SHUX_ASM_SKIP_STRICT_SMOKE=1
  SHUX_ASM_SKIP_MAIN_O_REBUILD=1
  SHUX_ASM_SKIP_WPO_DOGFOOD=1
  SHUX_STAGE2_SKIP_REFRESH=1
)

for arg in "$@"; do
  case "$arg" in
    --w0-only) W0_ONLY=1 ;;
    --w2) RUN_W2=1 ;;
    --w2-d03-only) RUN_W2_D03_ONLY=1 ;;
    --w3) RUN_W3=1 ;;
    --p0) RUN_P0=1 ;;
    -h|--help)
      sed -n '2,22p' "$0"
      exit 0
      ;;
    *) echo "run-g-fast-track: unknown arg $arg (use --help)" >&2; exit 1 ;;
  esac
done

mkdir -p "$LOG_DIR"
chmod +x "$PROGRESS" "$DOCKER" tests/run-g06-preflight-docker.sh tests/run-g06-bootstrap-docker.sh 2>/dev/null || true

progress() { echo "[$(date +%H:%M:%S)] fast-track $*"; }

die() {
  echo "run-g-fast-track FAIL: $*" >&2
  progress "logs: $LOG_DIR"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

run_step() {
  local label="$1"
  local log="$2"
  shift 2
  progress "── $label ──"
  "$PROGRESS" "$label" "$log" -- "$@" || die "$label"
}

progress "START log_dir=$LOG_DIR host=$(uname -s)-$(uname -m 2>/dev/null)"

# ── W0：本地秒级（清单 / manifest，无编译）────────────────────────────
progress "=== W0 local inventory (~30s) ==="

run_step "W0 d01 manifest" "$LOG_DIR/w0-d01-manifest.log" \
  env SHUX_D01_MANIFEST_ONLY=1 ./tests/run-d01-stage0-to-stage1-gate.sh

run_step "W0 f08 core inventory" "$LOG_DIR/w0-f08.log" \
  env SHUX_F08_CORE_INVENTORY_FAIL=1 ./tests/run-f08-core-inventory-gate.sh

# E-soft 全量 manifest 在 compiler 仍含 LEGACY C 时可能红；W0 仅跑 track（不 FAIL）
run_step "W0 e-soft track" "$LOG_DIR/w0-e-soft.log" \
  env SHUX_E_SOFT_FAIL=0 SHUX_E_SOFT_MANIFEST_ONLY=1 ./tests/run-e-soft-retire-gate.sh

if [ "$W0_ONLY" = "1" ]; then
  progress "OK W0 only"
  exit 0
fi

# ── W2 d03-only：秒级哈希 gate（须 Docker 内已有 stage1/stage2 产物）────────
if [ "$RUN_W2_D03_ONLY" = "1" ]; then
  progress "=== W2 d03-only (~5s; needs compiler/shux_asm_stage1 + shux_asm2) ==="
  run_step "W2 d03 hash only" "$LOG_DIR/w2-d03-only.log" \
    env SHUX_D03_FAIL=1 "${BSTRICT_FAST_ENV[@]}" "$DOCKER" compiler \
    'test -f shux_asm_stage1 && test -f shux_asm2 || { echo "missing shux_asm_stage1/2; run: make -C compiler bootstrap-driver-bstrict (with BSTRICT_FAST skips) && verify-selfhost-stage2-bstrict.sh" >&2; exit 1; }; cd .. && ./tests/run-d03-stage2-hash-gate.sh'
  progress "OK W2 d03-only"
  progress "logs: $LOG_DIR"
  exit 0
fi

# ── W1：Docker 分钟级（G-06 冷启动链）────────────────────────────────
progress "=== W1 docker G-06 (~1～3min) ==="

export SHUX_DOCKER_MEMORY="${SHUX_DOCKER_MEMORY:-16g}"
export SHUX_DOCKER_SHM="${SHUX_DOCKER_SHM:-4g}"
export SHUX_G06_PREFLIGHT_LOG="$LOG_DIR/w1-g06-preflight.log"
export SHUX_G06_BOOTSTRAP_LOG="$LOG_DIR/w1-g06-bootstrap.log"

run_step "W1 g06 preflight seed" "$LOG_DIR/w1-g06-preflight.log" \
  ./tests/run-g06-preflight-docker.sh

run_step "W1 g06 bootstrap-driver-seed" "$LOG_DIR/w1-g06-bootstrap.log" \
  ./tests/run-g06-bootstrap-docker.sh

# P0 安全 gate 依赖完整 shux_asm/typeck 链；冷启动 stub partial 下默认跳过（--p0 或 W2+）
if [ "$RUN_P0" = "1" ]; then
  run_step "W1 P0 scope-borrow" "$LOG_DIR/w1-borrow.log" \
    "$DOCKER" tests './run-scope-borrow-gate.sh'

  run_step "W1 P0 al06" "$LOG_DIR/w1-al06.log" \
    "$DOCKER" tests './run-al06-gate.sh'
else
  progress "SKIP W1 P0 security gates (set SHUX_FAST_TRACK_P0=1 or --p0 after bstrict)"
fi

if [ "$RUN_W2" != "1" ] && [ "$RUN_W3" != "1" ]; then
  progress "OK W0+W1 (use --w2 for d01/e03/coldstart; --w3 for linux-a09)"
  progress "logs: $LOG_DIR"
  exit 0
fi

# ── W2：Docker 十分钟级（Stage0→1 / 冷启动 track）────────────────────
progress "=== W2 docker medium (~10～20min) ==="

run_step "W2 d01 stage0→1" "$LOG_DIR/w2-d01.log" \
  env SHUX_D01_FAIL=1 "$DOCKER" tests './run-d01-stage0-to-stage1-gate.sh'

run_step "W2 e03 coldstart track" "$LOG_DIR/w2-e03.log" \
  env SHUX_E03_FAIL=1 "$DOCKER" tests './run-e03-v3-coldstart-track-gate.sh'

run_step "W2 d03 stage2 hash" "$LOG_DIR/w2-d03.log" \
  env SHUX_D03_FAIL=1 "${BSTRICT_FAST_ENV[@]}" "$DOCKER" compiler './verify-selfhost-stage2-bstrict.sh && cd .. && ./tests/run-d03-stage2-hash-gate.sh'

if [ "$RUN_W3" != "1" ]; then
  progress "OK W0+W1+W2"
  progress "logs: $LOG_DIR"
  exit 0
fi

# ── W3：Docker 小时级（黄金链全 gate）────────────────────────────────
progress "=== W3 docker full linux-a09 (~1h+) ==="

run_step "W3 linux-a09-a11" "$LOG_DIR/w3-linux-a09.log" \
  ./tests/run-linux-a09-a11-gate.sh

progress "OK W0+W1+W2+W3 — full fast-track passed"
progress "logs: $LOG_DIR"
