#!/usr/bin/env sh
# capture_bootstrap_seeds.sh — 用 LEGACY C 前端构建一次 xlang，刷新 seeds/ 冷启动产物（G-06）
#
# 用法（compiler 目录）：
#   XLANG_LEGACY_C_FRONTEND=1 ./scripts/capture_bootstrap_seeds.sh
#
# 产出：
#   seeds/bootstrap_xlangc.<os>.<arch>（linux / darwin / freebsd）
#   seeds/asm_backend_partial.<os>.<arch>.o
#
# CI：.github/workflows/bootstrap-seeds-capture.yml（linux/darwin/Alpine）
#      .cirrus.yml（FreeBSD 云端 VM，无需自备真机）

set -e
cd "$(dirname "$0")/.."

export XLANG_LEGACY_C_FRONTEND=1

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
case "$os" in darwin) os="darwin" ;; linux) os="linux" ;; freebsd) os="freebsd" ;; esac

# PLATFORM: SHARED — post-Makefile phys-del (wave941+): clean + cold seed via
# shell authorities (G.7). Ban residual bare `make` — MF absent hard-fails.
#   clean  → scripts/clean_compiler.sh
#   seed   → scripts/bootstrap_driver_seed.sh
# Escape: XLANG_CAPTURE_SEEDS_VIA_MAKE=1 + Makefile present → historic make.
echo "capture_bootstrap_seeds: LEGACY build (${os}.${arch}) ..."
if [ "${XLANG_CAPTURE_SEEDS_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
  echo "capture_bootstrap_seeds: VIA_MAKE escape → make clean + bootstrap-driver-seed" >&2
  make clean
  make bootstrap-driver-seed
else
  echo "capture_bootstrap_seeds: clean_compiler.sh + bootstrap_driver_seed.sh (0-make)" >&2
  bash scripts/clean_compiler.sh
  bash scripts/bootstrap_driver_seed.sh
fi

mkdir -p seeds
./scripts/bootstrap_xlangc_create.sh ./xlang
cp -f bootstrap_xlangc "seeds/bootstrap_xlangc.${os}.${arch}"
if has_real_partial_seed_mega build_asm/seed_host/asm_backend_partial.o; then
  cp -f build_asm/seed_host/asm_backend_partial.o "seeds/asm_backend_partial.${os}.${arch}.o"
else
  rm -f "seeds/asm_backend_partial.${os}.${arch}.o"
  echo "capture_bootstrap_seeds: skip non-real asm_backend_partial seed (missing strong seed_mega)" >&2
fi

echo "capture_bootstrap_seeds OK:"
ls -la "seeds/bootstrap_xlangc.${os}.${arch}" 2>/dev/null
ls -la "seeds/asm_backend_partial.${os}.${arch}.o" 2>/dev/null || true
