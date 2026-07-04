#!/usr/bin/env sh
# capture_asm_partial_seed.sh — 生成 seeds/asm_backend_partial.<os>.<arch>.o（G-06）
#
# 顺序：
#   1) 已有 build_asm/seed_host/asm_backend_partial.o 或 seeds 内 partial → 跳过
#   2) bootstrap_shuxc / shux-seed-phase1 + build_seed_asm_host（须 Linux x86_64，大内存）
#
# 用法（compiler 目录）：
#   ./scripts/capture_asm_partial_seed.sh
#
# 环境：SHUX_E 默认 ./bootstrap_shuxc；Docker 建议 SHUX_DOCKER_MEMORY=16g

set -e
cd "$(dirname "$0")/.."

progress() { echo "[$(date +%H:%M:%S)] capture_asm_partial: $*"; }

has_real_partial_seed_mega() {
  _obj="$1"
  nm "$_obj" 2>/dev/null | awk '/ T / {
    s=$3; sub(/^_/, "", s)
    if (s == "backend_asm_codegen_ast_seed_mega") found=1
  } END { exit !found }'
}

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$arch" in x86_64|amd64) arch="x86_64" ;; aarch64|arm64) arch="arm64" ;; esac
case "$os" in darwin) os="darwin" ;; linux) os="linux" ;; esac

SEED="seeds/asm_backend_partial.${os}.${arch}.o"
PARTIAL="build_asm/seed_host/asm_backend_partial.o"

if [ -s "$SEED" ] && has_real_partial_seed_mega "$SEED"; then
  progress "reuse $SEED"
  mkdir -p build_asm/seed_host
  cp -f "$SEED" "$PARTIAL"
  exit 0
fi
if [ -s "$SEED" ]; then
  progress "ignore non-real seed $SEED (missing strong seed_mega)"
fi

SHUX_E="${SHUX_E:-./bootstrap_shuxc}"
if [ -x ./shux-seed-phase1 ]; then
  SHUX_E=./shux-seed-phase1
elif [ ! -x "$SHUX_E" ] && [ -x ./shux-c ]; then
  SHUX_E=./shux-c
fi

if [ ! -x "$SHUX_E" ]; then
  cp -f seeds/bootstrap_shuxc.linux.x86_64 bootstrap_shuxc 2>/dev/null || true
  chmod +x bootstrap_shuxc 2>/dev/null || true
  SHUX_E=./bootstrap_shuxc
fi

if [ ! -x "$SHUX_E" ]; then
  echo "capture_asm_partial: FAIL: no SHUX_E" >&2
  exit 1
fi

progress "SHUX_E=$SHUX_E (bootstrap -E path; LEGACY 无法 parse 当前 ast.x)"
make -j4 src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o \
  src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o \
  src/asm/pipeline_abi_f32_xmm.o

ulimit -s unlimited 2>/dev/null || ulimit -s 65532 2>/dev/null || true

SHUX_E="$SHUX_E" ./scripts/build_seed_asm_host.sh

if [ ! -s "$PARTIAL" ]; then
  echo "capture_asm_partial: FAIL: no $PARTIAL (try SHUX_DOCKER_MEMORY=16g)" >&2
  exit 1
fi

mkdir -p seeds
cp -f "$PARTIAL" "$SEED"
progress "OK $SEED ($(wc -c <"$SEED" | tr -d ' ') bytes)"
