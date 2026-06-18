#!/usr/bin/env bash
# P5 push 前自检：M-3/M-4 typeck + M-5 IO + ZC-3 slice/option + WPO DCE + ZC-1/IO-A6 SKIP 烟测（跨平台 shu-c）。
# Linux 额外跑 refresh shu_asm gate（SU 路径 region/linear）。
# 用法：./tests/run-pre-push-p5.sh
# Mac 无 refresh：./scripts/docker-ci-local.sh ubuntu-gates
set -e
cd "$(dirname "$0")/.."

make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
# Docker 产物为 Linux ELF 时 Mac 无法 exec
if [ "$(uname -s)" = "Darwin" ] && [ -f ./compiler/shu-c ] && file ./compiler/shu-c | grep -q 'ELF'; then
  echo "pre-push P5: shu-c is Linux ELF (from docker); on Mac run: make -C compiler clean && make -C compiler shu-c" >&2
  echo "hint: or ./scripts/docker-ci-local.sh ubuntu-gates" >&2
  exit 1
fi
make -C compiler -q ../std/process/process.o ../std/io/io.o 2>/dev/null \
  || make -C compiler ../std/process/process.o ../std/io/io.o

echo "=== P5: B-CMP codegen-fair 1.0× (shu-c) ==="
chmod +x tests/run-bcmp-gate.sh
./tests/run-bcmp-gate.sh | tee /tmp/shu_bcmp_p5.log
grep -q 'bcmp gate OK' /tmp/shu_bcmp_p5.log

echo "=== P5: migrate SU gen gate ==="
chmod +x tests/run-migrate-su-gen-gate.sh
./tests/run-migrate-su-gen-gate.sh

echo "=== P5: M-4 linear typeck ==="
chmod +x tests/run-typeck-linear.sh
./tests/run-typeck-linear.sh

echo "=== P5: M-6 sanitize=address bounds instrumentation ==="
chmod +x tests/run-sanitize-gate.sh
./tests/run-sanitize-gate.sh

echo "=== P5: ZC gates (ZC-1 → ZC-2 → ZC-3 → ZC-4 → ZC-5) ==="
chmod +x tests/run-zc-gates.sh
./tests/run-zc-gates.sh

echo "=== P5: core.option stdlib import ==="
chmod +x tests/run-stdlib-import.sh
./tests/run-stdlib-import.sh

echo "=== P5: WPO DCE / S1 / S2 (shu-c) ==="
chmod +x tests/run-wpo-dce-emit.sh tests/run-wpo-s1.sh tests/run-wpo-s2.sh tests/run-perf-wpo-s2.sh tests/lib/wpo-main-disasm.sh
./tests/run-wpo-dce-emit.sh
./tests/run-wpo-s1.sh
./tests/run-wpo-s2.sh

echo "=== P5: WPO-S3 struct stack promote + await asm (shu-c typeck; shu_asm 时跑 exit 10/0) ==="
chmod +x tests/run-wpo-s3-gate.sh tests/lib/wpo-s3-disasm.sh tests/lib/wpo-main-disasm.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o
  SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh | tee /tmp/shu_wpo_s3_p5.log
  grep -q 'wpo-s3 await asm OK' /tmp/shu_wpo_s3_p5.log
  grep -q 'wpo-s3 await_yield asm OK' /tmp/shu_wpo_s3_p5.log
else
  ./tests/run-wpo-s3-gate.sh
fi

echo "=== P5: WPO-S4 PGO-Lite (.text.hot/unlikely + call-depth emit; shu_asm 时全量) ==="
chmod +x tests/run-wpo-s4-gate.sh tests/run-perf-wpo-dce-shu-asm-text.sh tests/lib/wpo-ab-proxy.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  SHU_WPO_PGO_HOT=1 SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh | tee /tmp/shu_wpo_s4_p5.log
  grep -q 'wpo-s4 gate OK' /tmp/shu_wpo_s4_p5.log
  grep -q 'wpo-s4: .text.hot order OK' /tmp/shu_wpo_s4_p5.log
else
  ./tests/run-wpo-s4-gate.sh
fi

echo "=== P5: SIMD-S1 target-cpu probe (--print-target-cpu) ==="
chmod +x tests/run-simd-s1-gate.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  SHU=./compiler/shu_asm ./tests/run-simd-s1-gate.sh | tee /tmp/shu_simd_s1_p5.log
  grep -q 'simd-s1 gate OK' /tmp/shu_simd_s1_p5.log
else
  ./tests/run-simd-s1-gate.sh
fi

echo "=== P5: SIMD-S2 Vec4f/Vec8i compile smoke ==="
chmod +x tests/run-simd-s2-gate.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  SHU=./compiler/shu_asm ./tests/run-simd-s2-gate.sh | tee /tmp/shu_simd_s2_p5.log
  grep -q 'simd-s2 gate OK' /tmp/shu_simd_s2_p5.log
else
  ./tests/run-simd-s2-gate.sh
fi

echo "=== P5: SIMD-S3 hw vector add smoke ==="
chmod +x tests/run-simd-s3-gate.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh | tee /tmp/shu_simd_s3_p5.log
  grep -q 'simd-s3 gate OK' /tmp/shu_simd_s3_p5.log
else
  ./tests/run-simd-s3-gate.sh
fi

echo "=== P5: SIMD-S4 comptime shuffle smoke ==="
chmod +x tests/run-simd-s4-gate.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  SHU=./compiler/shu_asm ./tests/run-simd-s4-gate.sh | tee /tmp/shu_simd_s4_p5.log
  grep -q 'simd-s4 gate OK' /tmp/shu_simd_s4_p5.log
else
  ./tests/run-simd-s4-gate.sh
fi

echo "=== P5: SIMD dot perf (optional, Linux shu_asm) ==="
chmod +x tests/run-perf-simd-dot.sh
./tests/run-perf-simd-dot.sh

# shu_asm 可用时补 WPO-S2 perf compile/disasm/exit 门禁（跳过 median，Mac 友好）
if [ -x ./compiler/shu_asm ]; then
  echo "=== P5: WPO-S2 perf compile-only (shu_asm) ==="
  SHU=./compiler/shu_asm SHU_WPO_S2_COMPILE_ONLY=1 SHU_WPO_S2_LIMIT=100000 ./tests/run-perf-wpo-s2.sh --bench
fi

echo "=== P5: DOD-S1 struct soa smoke ==="
chmod +x tests/run-dod-s1-gate.sh tests/run-perf-dod-soa.sh
./tests/run-dod-s1-gate.sh
./tests/run-perf-dod-soa.sh

echo "=== P5: DOD-S2 std.vec SoA smoke (xmm default + CLI legacy in f32-xmm-gates) ==="
chmod +x tests/run-dod-s2-gate.sh tests/run-f32-xmm-gates.sh tests/lib/dod-native-exe.sh
if [ -x ./compiler/shu_asm ] && [ "$(uname -s)" = "Linux" ]; then
  if [ ! -f std/heap/heap.o ] || [ std/heap/heap.c -nt std/heap/heap.o ]; then
    cc -Wall -Wextra -Icompiler -Icompiler/include -c -o std/heap/heap.o std/heap/heap.c 2>/dev/null \
      || cc -Wall -Wextra -c -o std/heap/heap.o std/heap/heap.c
  fi
  SHU=./compiler/shu_asm ./tests/run-f32-xmm-gates.sh
else
  ./tests/run-dod-s2-gate.sh
fi

echo "=== P5: DOD-S3 WPO SoA layout unify ==="
chmod +x tests/run-dod-s3-gate.sh
./tests/run-dod-s3-gate.sh

echo "=== P5: DOD-CL-S1 align(64) + pad-fields ==="
chmod +x tests/run-dod-cl-s1-gate.sh
./tests/run-dod-cl-s1-gate.sh

echo "=== P5: DOD-CL-S2 Arena64 + hot-reorder ==="
chmod +x tests/run-dod-cl-s2-gate.sh
./tests/run-dod-cl-s2-gate.sh

echo "=== P5: ZC-1 / IO-A6 gate (跨平台；非 Linux/Windows 时 SKIP) ==="
chmod +x tests/run-zc1-gate.sh tests/run-iocp-gate.sh tests/run-perf-iocp.sh
./tests/run-zc1-gate.sh
./tests/run-iocp-gate.sh

if [ "$(uname -s)" = "Linux" ]; then
  echo "=== P5: refresh shu_asm gate (Linux SU path) ==="
  make -C compiler -q OPT=1 2>/dev/null || make -C compiler OPT=1
  chmod +x tests/run-refresh-shu-asm-gate.sh tests/run-size-shu-asm-gate.sh
  ./tests/run-refresh-shu-asm-gate.sh
  if [ -x ./compiler/shu_asm ]; then
    echo "=== P5: B-SIZE shu_asm stripped (advisory, ENG-002) ==="
    ./tests/run-size-shu-asm-gate.sh
    echo "=== P5: S3 pipeline SU emit gate (parse_entry_do_parse + EMIT_HEAVY) ==="
    chmod +x tests/run-s3-pipeline-gate.sh tests/run-s3-pipeline-sync-build-o.sh
    ./tests/run-s3-pipeline-sync-build-o.sh
    SHU_S3_FAIL_ON_REGRESSION=1 ./tests/run-s3-pipeline-gate.sh
    echo "=== P5: WPO shu_asm binary .text proxy (Linux) ==="
    chmod +x tests/run-perf-wpo-dce-shu-asm-text.sh tests/lib/wpo-ab-proxy.sh \
      tests/ensure-wpo-build-asm-artifacts.sh tests/run-wpo-full-chain-gate.sh
    SHU_WPO_ENSURE_FAIL=1 SHU_WPO_ENSURE_COMPILER=./compiler/shu_asm ./tests/ensure-wpo-build-asm-artifacts.sh
    SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shu-asm-text.sh
    # B-CMP-ASM：跟踪 shu_asm vs C-O3（计算 loop 仍劣于 C，勿硬门禁）
    echo "=== P5: B-CMP shu_asm 1.0× (track-only, non-fatal) ==="
    SHU_PERF_BCMP_ASM=1 ./tests/run-bcmp-gate.sh | tee /tmp/shu_bcmp_asm_p5.log || true
    grep -q 'B-CMP-ASM' /tmp/shu_bcmp_asm_p5.log || true
    # stretch -3%：须 run-bootstrap-bstrict-ci 全链后 ./tests/run-wpo-stretch-gate.sh
  fi
else
  echo "=== P5: refresh shu_asm gate SKIP (non-Linux) ==="
  echo "hint: ./scripts/docker-ci-local.sh ubuntu-gates"
  echo "hint: Linux perf+ZC-1: ./tests/run-zc1-gate.sh --perf 或 ./tests/run-perf-p1-gate.sh"
fi

echo "pre-push P5 OK (M-3/M-4/M-6/ZC-2/ZC-3/ZC-4/ZC-5/WPO cross-platform gates)"
# 推送提示（与 run-pre-push-p0.sh 一致）
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  br=$(git branch --show-current 2>/dev/null || echo "?")
  ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "?")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "git: branch=$br ahead-of-upstream=$ahead dirty-files=$dirty"
  if [ "$ahead" != "?" ] && [ "$ahead" != "0" ]; then
    echo "next: commit → git push origin $br   # GHA: run-zc1-gate --perf / Net perf"
  fi
  if [ "$(uname -s)" = "Darwin" ] && [ "$dirty" != "0" ]; then
    echo "note: after ./scripts/docker-ci-local.sh ubuntu-gates, rebuild native shu-c (make clean && make shu-c)"
  fi
fi
