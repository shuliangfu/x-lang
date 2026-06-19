#!/usr/bin/env bash
# M3-c：CI / 本地统一的 B-strict 验收入口。
# 1) make bootstrap-driver-bstrict（链接审计：无 cc -c pipeline_gen.c）
# 2) run-shux-asm-gate（用户 import / option 等）
# 3) run-asm-73-gate（binop + vector-var + call-inline）
# 4) run-all-bstrict（M7：bootstrap-driver-bstrict 已默认 shux_asm -> shux，白名单 107 项）
# 语义自举主路径：make bootstrap-verify（check-7.2-bstrict / shux_asm）；seed 链：make bootstrap-verify-seed。
# 用法：仓库根目录 ./tests/run-bootstrap-bstrict-ci.sh

set -e
cd "$(dirname "$0")/.."

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

# Docker 容器探测（与 run-ci-full-suite.sh ci_is_docker 一致）。
bootstrap_ci_is_docker() {
  [ -f /.dockerenv ] || [ -n "${SHUX_CI_DOCKER:-}" ]
}

if [ ! -f compiler/shux ] || [ ! -x compiler/shux ]; then
  echo "bootstrap-bstrict-ci: seed shux missing; run: make -C compiler OPT=1 all" >&2
  exit 127
fi

echo "bootstrap-bstrict-ci: B-01 cfg attribute lex skip (shux-c) ..."
chmod +x tests/run-cfg-attribute-skip-gate.sh tests/run-repr-c-attribute-skip-gate.sh tests/run-cfg-target-triple-gate.sh
SHUX_CFG_ATTR_SKIP_FAIL=1 ./tests/run-cfg-attribute-skip-gate.sh
SHUX_CFG_TARGET_TRIPLE_FAIL=1 ./tests/run-cfg-target-triple-gate.sh
SHUX_REPR_C_ATTR_SKIP_FAIL=1 ./tests/run-repr-c-attribute-skip-gate.sh
SHUX_REPR_C_LAYOUT_FAIL=1 ./tests/run-repr-c-layout-gate.sh

echo "bootstrap-bstrict-ci: B-19 std.sys platform write (shux-c) ..."
chmod +x tests/run-sys-platform-write-gate.sh tests/run-sys-mod-cfg-import-gate.sh tests/run-sys-read-file-gate.sh
SHUX_SYS_PLATFORM_WRITE_FAIL=1 ./tests/run-sys-platform-write-gate.sh
SHUX_SYS_MOD_CFG_IMPORT_FAIL=1 ./tests/run-sys-mod-cfg-import-gate.sh
SHUX_SYS_READ_FILE_FAIL=1 ./tests/run-sys-read-file-gate.sh

echo "bootstrap-bstrict-ci: B-20 generated_c scan (no fopen) ..."
chmod +x tests/run-b20-generated-c-scan-gate.sh
SHUX_B20_GENERATED_C_SCAN_FAIL=1 ./tests/run-b20-generated-c-scan-gate.sh

echo "bootstrap-bstrict-ci: C-04 -E-extern import extern (shux-c) ..."
chmod +x tests/run-e-extern-import-gate.sh
SHUX_E_EXTERN_IMPORT_FAIL=1 ./tests/run-e-extern-import-gate.sh

echo "bootstrap-bstrict-ci: lexer parse + pipeline -E-extern ..."
chmod +x tests/run-lexer-e-extern-gate.sh
SHUX_LEXER_E_EXTERN_FAIL=1 ./tests/run-lexer-e-extern-gate.sh

echo "bootstrap-bstrict-ci: pipeline -E-extern cc -c (C-04 v2) ..."
chmod +x tests/run-pipeline-e-extern-gate.sh
SHUX_PIPELINE_E_EXTERN_FAIL=1 ./tests/run-pipeline-e-extern-gate.sh

echo "bootstrap-bstrict-ci: parser -E-extern cc -c (C-04 parser) ..."
chmod +x tests/run-parser-e-extern-gate.sh
SHUX_PARSER_E_EXTERN_FAIL=1 ./tests/run-parser-e-extern-gate.sh

echo "bootstrap-bstrict-ci: B-16 macOS mmap (Darwin only) ..."
chmod +x tests/run-macos-mmap-gate.sh tests/run-macos-mmap-file-gate.sh
SHUX_MACOS_MMAP_FAIL=1 ./tests/run-macos-mmap-gate.sh
SHUX_MACOS_MMAP_FILE_FAIL=1 ./tests/run-macos-mmap-file-gate.sh

echo "bootstrap-bstrict-ci: B-14 Linux freestanding syscall (Linux only) ..."
chmod +x tests/run-linux-syscall-invoke-gate.sh tests/run-linux-open-read-gate.sh tests/run-linux-mmap-invoke-gate.sh tests/run-linux-openat-read-gate.sh
SHUX_LINUX_SYSCALL_INVOKE_FAIL=1 ./tests/run-linux-syscall-invoke-gate.sh
SHUX_LINUX_OPEN_READ_FAIL=1 ./tests/run-linux-open-read-gate.sh
SHUX_LINUX_MMAP_INVOKE_FAIL=1 ./tests/run-linux-mmap-invoke-gate.sh
SHUX_LINUX_OPENAT_READ_FAIL=1 ./tests/run-linux-openat-read-gate.sh

echo "bootstrap-bstrict-ci: bootstrap-driver-bstrict (build shux_asm) ..."
# strict 重链会覆盖 shux；cfg-merge 在 GHA 上对 strict shux_asm 偶发 SIGSEGV，保留 seed 作 -o 回退。
if [ -x compiler/shux-sx ]; then
  cp -f compiler/shux-sx compiler/shux_asm73_seed
elif [ -x compiler/shux ]; then
  cp -f compiler/shux compiler/shux_asm73_seed
fi
export ASM73_FALLBACK_SHUX=./compiler/shux_asm73_seed
# CI fast 仅保留 asm_only_experimental（pipeline_sx partial），cfg-merge 编译会 SIGSEGV；
# bstrict 验收须 strict 第二遍重链（asm_only_strict）。
if [ -n "${CI:-}" ] && [ "$(uname -s 2>/dev/null)" = "Linux" ]; then
  export SHUX_ASM_CI_SKIP_FAST=1
  # strict 链 smoke 与 ci-full-suite 前段 run_shux_asm_smoke 重复；asm-73 cfg-merge 为实质验收。
  export SHUX_ASM_SKIP_STRICT_SMOKE=1
  echo "bootstrap-bstrict-ci: SHUX_ASM_CI_SKIP_FAST=1 (strict relink for asm-73 cfg-merge)"
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
if grep -q 'installed shux_asm.experimental as shux_asm (fallback OK)' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: experimental fallback in build log — strict smoke must pass natively" >&2
  exit 1
fi
if grep -qE 'full_asm|M11 OK' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: full_asm topology confirmed"
else
  echo "bootstrap-bstrict-ci: warn: full_asm/M11 marker not in build log (__text 可能未全绿)" >&2
fi
if grep -qE 'cc -c .*pipeline_sx\.(c|o)' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: B-strict final link must not use pipeline_sx.c/o" >&2
  exit 1
fi

if [ ! -x compiler/shux_asm ]; then
  echo "bootstrap-bstrict-ci: compiler/shux_asm not built" >&2
  exit 1
fi

echo "bootstrap-bstrict-ci: strict smoke gate (no experimental fallback) ..."
chmod +x tests/run-strict-smoke-gate.sh
BUILD_LOG=/tmp/build_bstrict.log ./tests/run-strict-smoke-gate.sh

echo "bootstrap-bstrict-ci: run-shux-asm-gate ..."
SHUX=./compiler/shux_asm ./tests/run-shux-asm-gate.sh

echo "bootstrap-bstrict-ci: asm compute gate (binop + vector + call-inline) ..."
# asm-73 须 strict shux_asm；experimental 为 bootstrap 中间产物（pipeline_sx partial），cfg-merge 会 SIGSEGV。
ASM_COMPUTE_SHUX="./compiler/shux_asm"
if [ ! -x "$ASM_COMPUTE_SHUX" ] && [ -x ./compiler/shux_asm.experimental ]; then
  ASM_COMPUTE_SHUX="./compiler/shux_asm.experimental"
fi
if bootstrap_ci_is_docker; then
  echo "bootstrap-bstrict-ci: Docker — asm-73 compute gate N/A (native linux GHA job covers; experimental SIGSEGV in container)"
else
  export ASM73_FALLBACK_SHUX="${ASM73_FALLBACK_SHU:-./compiler/shux_asm73_seed}"
  SHUX="$ASM_COMPUTE_SHUX" ./tests/run-asm-73-gate.sh
fi

echo "bootstrap-bstrict-ci: L5 run-all parity (A-10 whitelist sync + bstrict) ..."
export SHUX_BSTRICT_SKIP_BUILD=1
chmod +x tests/run-l5-run-all-parity-gate.sh
./tests/run-l5-run-all-parity-gate.sh

echo "bootstrap-bstrict-ci: Linux crt0 + full_asm (M4, no-op on macOS) ..."
chmod +x tests/run-bootstrap-bstrict-linux.sh
./tests/run-bootstrap-bstrict-linux.sh

echo "bootstrap-bstrict-ci: S4 freestanding hello (nostdlib, no-op on macOS) ..."
chmod +x tests/run-freestanding-hello.sh
./tests/run-freestanding-hello.sh

echo "bootstrap-bstrict-ci: BOOT-029 std.sys freestanding write ..."
chmod +x tests/run-std-sys-gate.sh
./tests/run-std-sys-gate.sh

echo "bootstrap-bstrict-ci: M5 B-strict Stage2 (shux_asm -> shux_asm2) ..."
# gen2 round2 对齐 gen1 链拓扑（driver_compile_su、无 typeck/backend WPO）；Linux 硬门禁。
if [ "$(uname -s 2>/dev/null)" != "Linux" ]; then
  echo "bootstrap-bstrict-ci: skip stage2 (non-Linux)"
elif [ -n "${SHUX_CI_SKIP_STAGE2:-}" ]; then
  echo "bootstrap-bstrict-ci: skip stage2 (SHUX_CI_SKIP_STAGE2=1)"
else
  chmod +x tests/run-stage2-bstrict-gate.sh compiler/verify-selfhost-stage2-bstrict.sh
  SHUX_STAGE2_SKIP_BOOTSTRAP=1 ./tests/run-stage2-bstrict-gate.sh
fi

echo "bootstrap-bstrict-ci: ensure WPO build_asm artifacts (五模块) ..."
chmod +x tests/ensure-wpo-build-asm-artifacts.sh compiler/scripts/build_shux_asm.sh
SHUX_WPO_ENSURE_FAIL=1 ./tests/ensure-wpo-build-asm-artifacts.sh

echo "bootstrap-bstrict-ci: wpo build_asm chain gate (post-stage2) ..."
chmod +x tests/run-wpo-main-o-gate.sh tests/run-wpo-driver-o-gate.sh tests/run-wpo-pipeline-o-gate.sh tests/run-wpo-typeck-o-gate.sh tests/run-wpo-backend-o-gate.sh tests/run-wpo-build-asm-chain-gate.sh
./tests/run-wpo-build-asm-chain-gate.sh

echo "bootstrap-bstrict-ci: wpo strict link gate (pipeline+typeck+backend WPO in strict_glue) ..."
chmod +x tests/run-wpo-strict-link-gate.sh tests/run-wpo-pipeline-reach-gate.sh \
  tests/run-wpo-typeck-reach-gate.sh tests/run-wpo-backend-reach-gate.sh \
  compiler/scripts/relink_shux_asm_strict_glue.sh
SHUX_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh

echo "bootstrap-bstrict-ci: strict_glue measured .text A/B (pipeline WPO helpers) ..."
chmod +x tests/run-wpo-strict-glue-text-gate.sh tests/lib/wpo-ab-proxy.sh
SHUX_WPO_STRICT_GLUE_TEXT_FAIL=1 ./tests/run-wpo-strict-glue-text-gate.sh

echo "bootstrap-bstrict-ci: parser su strict gate ..."
chmod +x tests/run-parser-sx-strict-gate.sh tests/run-parser-experimental-emit-gate.sh
SHUX_PARSER_SX_STRICT_FAIL=1 ./tests/run-parser-sx-strict-gate.sh
./tests/run-parser-experimental-emit-gate.sh

echo "bootstrap-bstrict-ci: parser second pass gate ..."
chmod +x tests/run-parser-second-pass-gate.sh tests/run-parser-thin-glue-symbol-integrity-gate.sh
SHUX_PARSER_SECOND_PASS_FAIL=1 ./tests/run-parser-second-pass-gate.sh
SHUX_PARSER_SECOND_PASS_COMPILER=compiler/shux_asm \
  SHUX_PARSER_SECOND_PASS_EMIT_HEAVY=1 \
  SHUX_PARSER_SECOND_PASS_FAIL=1 \
  SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 \
  ./tests/run-parser-second-pass-gate.sh
SHUX_PARSER_SECOND_PASS_COMPILER=compiler/shux_asm \
  SHUX_PARSER_SECOND_PASS_EMIT_HEAVY=1 \
  SHUX_PARSER_SECOND_PASS_WPO_DCE=1 \
  SHUX_PARSER_SECOND_PASS_FAIL=1 \
  SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 \
  ./tests/run-parser-second-pass-gate.sh

echo "bootstrap-bstrict-ci: typeck parse count baseline ..."
chmod +x tests/run-typeck-parse-count-gate.sh tests/run-typeck-parse-bisect-gate.sh
SHUX_TYPECK_PARSE_COUNT_FAIL=1 SHUX=./compiler/shux_asm \
  ./tests/run-typeck-parse-count-gate.sh
./tests/run-typeck-parse-bisect-gate.sh || true

echo "bootstrap-bstrict-ci: A-12 cross-module symbols (track-only) ..."
chmod +x tests/run-a12-cross-module-symbols-gate.sh
SHUX_A12_CROSS_MODULE_FAIL=0 SHUX_A12_COMPILER=./compiler/shux_asm \
  ./tests/run-a12-cross-module-symbols-gate.sh

echo "bootstrap-bstrict-ci: F-01 std/core .c inventory ..."
chmod +x tests/run-std-c-inventory-gate.sh
SHUX_STD_C_INVENTORY_FAIL=1 ./tests/run-std-c-inventory-gate.sh

echo "bootstrap-bstrict-ci: parser parse bootstrap gate ..."
chmod +x tests/run-parser-parse-bootstrap-gate.sh tests/run-parser-parse-bootstrap-link-smoke.sh \
  tests/run-parser-parse-bootstrap-sx-emit-gate.sh tests/run-parser-parse-bootstrap-bisect-gate.sh \
  tests/run-parser-mega-bisect-gate.sh
SHUX_PARSER_PARSE_BOOTSTRAP_FAIL=1 ./tests/run-parser-parse-bootstrap-gate.sh
SHUX_PARSER_PARSE_BOOTSTRAP_LINK_FAIL=1 ./tests/run-parser-parse-bootstrap-link-smoke.sh
SHUX_PARSER_PARSE_BOOTSTRAP_BISECT_FAIL=1 ./tests/run-parser-parse-bootstrap-bisect-gate.sh
./tests/run-parser-mega-bisect-gate.sh || true
chmod +x tests/run-parser-mega-bisect-sweep-gate.sh
./tests/run-parser-mega-bisect-sweep-gate.sh || true
./tests/run-parser-parse-bootstrap-sx-emit-gate.sh || true

echo "bootstrap-bstrict-ci: parser parse count baseline ..."
chmod +x tests/run-parser-parse-count-gate.sh
SHUX_PARSER_PARSE_COUNT_FAIL=1 SHUX_PARSER_PARSE_COUNT_TARGET=466 SHUX=./compiler/shux_asm \
  ./tests/run-parser-parse-count-gate.sh

echo "bootstrap-bstrict-ci: DOD-CL-S1 struct layout smoke ..."
chmod +x tests/run-dod-cl-s1-gate.sh
SHUX=./compiler/shux_asm ./tests/run-dod-cl-s1-gate.sh

echo "bootstrap-bstrict-ci: pipeline WPO full link smoke (track-only) ..."
chmod +x tests/run-pipeline-wpo-full-link-smoke.sh
./tests/run-pipeline-wpo-full-link-smoke.sh

echo "bootstrap-bstrict-ci: pipeline WPO opt-in smoke (track-only) ..."
chmod +x tests/run-pipeline-wpo-optin-smoke.sh
./tests/run-pipeline-wpo-optin-smoke.sh || true

echo "bootstrap-bstrict-ci: typeck WPO helpers smoke ..."
chmod +x tests/run-typeck-wpo-optin-smoke.sh
./tests/run-typeck-wpo-optin-smoke.sh

echo "bootstrap-bstrict-ci OK (B-strict audited + gate + asm-73 + L5 parity + linux crt0 + freestanding + stage2 + wpo gates + strict link + strict_glue text A/B)"
