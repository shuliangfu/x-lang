#!/usr/bin/env sh
# capture_asm_partial_seed_legacy.sh — 用 LEGACY C 前端 xlang-c 生成 asm_backend_partial seed（G-06 破蛋）
#
# bootstrap_xlangc 种子无法可靠 -E asm.x；本脚本在 Linux x86_64 上用 gcc 链 LEGACY xlang-c 再跑 build_seed_asm_host。
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
export XLANG_LEGACY_C_FRONTEND=1

# PLATFORM: SHARED — post-Makefile phys-del: LEGACY xlang-c via legacy_xlang_c_link
# (G.7 single archaeology authority; ban residual `make xlang-c`).
progress "LEGACY xlang-c via legacy_xlang_c_link.sh (0-make; gcc C frontend)"
if ! bash scripts/legacy_xlang_c_link.sh; then
  echo "capture_asm_partial: FAIL legacy_xlang_c_link (XLANG_LEGACY_C_FRONTEND=1)" >&2
  exit 1
fi

# PLATFORM: SHARED — dispatch TU via ensure try-r3-cold (catalog R3_COLD).
# f32 xmm ABI already folded into backend_call_dispatch (G-02e); no separate
# pipeline_abi_f32_xmm.o leaf.
progress "dispatch TU via ensure_host_cc_seed_o try-r3-cold (0-make)"
for _dof in src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o \
            src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o; do
  if ! bash scripts/ensure_host_cc_seed_o.sh try-r3-cold "$_dof"; then
    echo "capture_asm_partial: FAIL ensure $_dof (try-r3-cold)" >&2
    exit 1
  fi
done

progress "build_seed_asm_host via LEGACY xlang-c ..."
XLANG_E=./xlang-c ./scripts/build_seed_asm_host.sh

if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then
  echo "capture_asm_partial: FAIL: missing build_asm/seed_host/asm_backend_partial.o" >&2
  exit 1
fi

mkdir -p seeds
cp -f build_asm/seed_host/asm_backend_partial.o "$SEED"
progress "OK $SEED ($(wc -c <"$SEED" | tr -d ' ') bytes)"
