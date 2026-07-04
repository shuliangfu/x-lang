#!/usr/bin/env sh
# capture_asm_partial_seed_legacy.sh — 用 LEGACY C 前端 shux-c 生成 asm_backend_partial seed（G-06 破蛋）
#
# bootstrap_shuxc 种子无法可靠 -E asm.x；本脚本在 Linux x86_64 上用 gcc 链 LEGACY shux-c 再跑 build_seed_asm_host。
#
# 用法（compiler 目录，Linux x86_64 / Docker 内）：
#   ./scripts/capture_asm_partial_seed_legacy.sh
#
# 产出：seeds/asm_backend_partial.linux.x86_64.o

set -e
cd "$(dirname "$0")/.."

progress() { echo "[$(date +%H:%M:%S)] capture_asm_partial: $*"; }

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')"
case "$arch" in x86_64|amd64) arch="x86_64" ;; aarch64|arm64) arch="arm64" ;; esac
case "$os" in darwin) os="darwin" ;; linux) os="linux" ;; esac

SEED="seeds/asm_backend_partial.${os}.${arch}.o"
export SHUX_LEGACY_C_FRONTEND=1

progress "LEGACY make shux-c (gcc C 前端，无 bootstrap -E) ..."
make -j4 shux-c

progress "dispatch TU ..."
make -j4 src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o \
  src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o \
  src/asm/pipeline_abi_f32_xmm.o

progress "build_seed_asm_host via LEGACY shux-c ..."
SHUX_E=./shux-c ./scripts/build_seed_asm_host.sh

if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then
  echo "capture_asm_partial: FAIL: missing build_asm/seed_host/asm_backend_partial.o" >&2
  exit 1
fi

mkdir -p seeds
cp -f build_asm/seed_host/asm_backend_partial.o "$SEED"
progress "OK $SEED ($(wc -c <"$SEED" | tr -d ' ') bytes)"
