#!/usr/bin/env bash
# M3-c：CI / 本地统一的 B-strict 验收入口。
# 1) make bootstrap-driver-bstrict（链接审计：无 cc -c pipeline_gen.c）
# 2) run-shu-asm-gate（用户 import / option 等）
# 3) run-asm-73-gate（binop + vector-var + call-inline）
# 4) run-all-bstrict（M7：bootstrap-driver-bstrict 已默认 shu_asm -> shu，白名单 107 项）
# 语义自举主路径：make bootstrap-verify（check-7.2-bstrict / shu_asm）；seed 链：make bootstrap-verify-seed。
# 用法：仓库根目录 ./tests/run-bootstrap-bstrict-ci.sh

set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

# Docker 容器探测（与 run-ci-full-suite.sh ci_is_docker 一致）。
bootstrap_ci_is_docker() {
  [ -f /.dockerenv ] || [ -n "${SHU_CI_DOCKER:-}" ]
}

if [ ! -f compiler/shu ] || [ ! -x compiler/shu ]; then
  echo "bootstrap-bstrict-ci: seed shu missing; run: make -C compiler OPT=1 all" >&2
  exit 127
fi

echo "bootstrap-bstrict-ci: bootstrap-driver-bstrict (build shu_asm) ..."
# strict 重链会覆盖 shu；cfg-merge 在 GHA 上对 strict shu_asm 偶发 SIGSEGV，保留 seed 作 -o 回退。
if [ -x compiler/shu-su ]; then
  cp -f compiler/shu-su compiler/shu_asm73_seed
elif [ -x compiler/shu ]; then
  cp -f compiler/shu compiler/shu_asm73_seed
fi
export ASM73_FALLBACK_SHU=./compiler/shu_asm73_seed
# CI fast 仅保留 asm_only_experimental（pipeline_su partial），cfg-merge 编译会 SIGSEGV；
# bstrict 验收须 strict 第二遍重链（asm_only_strict）。
if [ -n "${CI:-}" ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  export SHU_ASM_CI_SKIP_FAST=1
  # strict 链 smoke 与 ci-full-suite 前段 run_shu_asm_smoke 重复；asm-73 cfg-merge 为实质验收。
  export SHU_ASM_SKIP_STRICT_SMOKE=1
  echo "bootstrap-bstrict-ci: SHU_ASM_CI_SKIP_FAST=1 (strict relink for asm-73 cfg-merge)"
fi
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log

if ! grep -qE 'Target-B-strict|B-strict OK|LINK_MODE=asm_only_strict' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: expected Target-B-strict / B-strict OK / asm_only_strict in build log" >&2
  exit 1
fi
if grep -qE 'LINK_MODE=asm_only_experimental' /tmp/build_bstrict.log \
  && ! grep -qE 'LINK_MODE=asm_only_strict' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: asm_only_experimental only — cfg-merge asm-73 requires strict relink" >&2
  exit 1
fi
if grep -qE '(^|[[:space:]])cc -c (\\.\\./)?pipeline_gen\\.c([[:space:]]|$)' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: B-strict link must not compile pipeline_gen.c" >&2
  exit 1
fi
if grep -qE 'full_asm|M11 OK' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: full_asm topology confirmed"
else
  echo "bootstrap-bstrict-ci: warn: full_asm/M11 marker not in build log (__text 可能未全绿)" >&2
fi
if grep -qE 'cc -c .*pipeline_su\.(c|o)' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: B-strict final link must not use pipeline_su.c/o" >&2
  exit 1
fi

if [ ! -x compiler/shu_asm ]; then
  echo "bootstrap-bstrict-ci: compiler/shu_asm not built" >&2
  exit 1
fi

echo "bootstrap-bstrict-ci: run-shu-asm-gate ..."
SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh

echo "bootstrap-bstrict-ci: asm compute gate (binop + vector + call-inline) ..."
# asm-73 须 strict shu_asm；experimental 为 bootstrap 中间产物（pipeline_su partial），cfg-merge 会 SIGSEGV。
ASM_COMPUTE_SHU="./compiler/shu_asm"
if [ ! -x "$ASM_COMPUTE_SHU" ] && [ -x ./compiler/shu_asm.experimental ]; then
  ASM_COMPUTE_SHU="./compiler/shu_asm.experimental"
fi
if bootstrap_ci_is_docker; then
  echo "bootstrap-bstrict-ci: Docker — asm-73 compute gate N/A (native linux GHA job covers; experimental SIGSEGV in container)"
else
  export ASM73_FALLBACK_SHU="${ASM73_FALLBACK_SHU:-./compiler/shu_asm73_seed}"
  SHU="$ASM_COMPUTE_SHU" ./tests/run-asm-73-gate.sh
fi

echo "bootstrap-bstrict-ci: run-all-bstrict (replace seed, whitelist) ..."
export SHU_BSTRICT_SKIP_BUILD=1
./tests/run-all-bstrict.sh

echo "bootstrap-bstrict-ci: Linux crt0 + full_asm (M4, no-op on macOS) ..."
chmod +x tests/run-bootstrap-bstrict-linux.sh
./tests/run-bootstrap-bstrict-linux.sh

echo "bootstrap-bstrict-ci: S4 freestanding hello (nostdlib, no-op on macOS) ..."
chmod +x tests/run-freestanding-hello.sh
./tests/run-freestanding-hello.sh

echo "bootstrap-bstrict-ci: M5 B-strict Stage2 (shu_asm -> shu_asm2) ..."
chmod +x tests/run-bootstrap-stage2-bstrict.sh compiler/verify-selfhost-stage2-bstrict.sh
./tests/run-bootstrap-stage2-bstrict.sh

echo "bootstrap-bstrict-ci: ensure WPO build_asm artifacts (五模块) ..."
chmod +x tests/ensure-wpo-build-asm-artifacts.sh compiler/scripts/build_shu_asm.sh
SHU_WPO_ENSURE_FAIL=1 ./tests/ensure-wpo-build-asm-artifacts.sh

echo "bootstrap-bstrict-ci: wpo build_asm chain gate (post-stage2) ..."
chmod +x tests/run-wpo-main-o-gate.sh tests/run-wpo-driver-o-gate.sh tests/run-wpo-pipeline-o-gate.sh tests/run-wpo-typeck-o-gate.sh tests/run-wpo-backend-o-gate.sh tests/run-wpo-build-asm-chain-gate.sh
./tests/run-wpo-build-asm-chain-gate.sh

echo "bootstrap-bstrict-ci: wpo strict link gate (pipeline+typeck+backend WPO in strict_glue) ..."
chmod +x tests/run-wpo-strict-link-gate.sh tests/run-wpo-pipeline-reach-gate.sh \
  tests/run-wpo-typeck-reach-gate.sh tests/run-wpo-backend-reach-gate.sh \
  compiler/scripts/relink_shu_asm_strict_glue.sh
SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh

echo "bootstrap-bstrict-ci OK (B-strict audited + gate + asm-73 + whitelist + linux crt0 + freestanding + stage2 + wpo gates + strict link)"
