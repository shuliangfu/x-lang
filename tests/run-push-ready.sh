#!/usr/bin/env bash
# Push 前一键自检：P5 + S2 typeck + 平台提示；不执行 git push。
# 用法：./tests/run-push-ready.sh
# Mac：P5 + docker ubuntu-gates 提示；Linux：可追加 ./tests/run-perf-p1-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== push-ready: pre-push P5 ==="
chmod +x tests/run-pre-push-p5.sh
./tests/run-pre-push-p5.sh

echo ""
echo "=== push-ready: S2 typeck gate (shu-c, no shu_asm required) ==="
chmod +x tests/run-s2-typeck-gate.sh
./tests/run-s2-typeck-gate.sh

echo ""
echo "=== push-ready: WPO-S3 (struct promote + await/yield asm) ==="
chmod +x tests/run-wpo-s3-gate.sh tests/lib/wpo-s3-disasm.sh
if [ -x ./compiler/shu_asm ] && { [ "$(uname -s)" = "Linux" ] || file ./compiler/shu_asm 2>/dev/null | grep -q Mach-O; }; then
  make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o
  SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh | tee /tmp/shu_wpo_s3_push.log
  grep -q 'wpo-s3 await asm OK' /tmp/shu_wpo_s3_push.log
  grep -q 'wpo-s3 await_yield asm OK' /tmp/shu_wpo_s3_push.log
else
  ./tests/run-wpo-s3-gate.sh
fi

if [ "$(uname -s)" = "Linux" ]; then
  echo ""
  echo "=== push-ready: optional Linux perf P1 (ZC-1 --perf when io_uring available) ==="
  echo "run: ./tests/run-perf-p1-gate.sh"
else
  echo ""
  echo "=== push-ready: optional Docker Linux gates ==="
  echo "run: ./scripts/docker-ci-local.sh ubuntu-gates    # P5 + refresh shu_asm"
  echo "run: ./scripts/docker-ci-local.sh ubuntu-net-zc1  # ZC-1 (GHA kernel; Docker Desktop may SKIP)"
fi

echo ""
if [ ! -x ./compiler/shu_asm ]; then
  echo "note: compiler/shu_asm missing (docker make clean / no bootstrap)"
  echo "  P0/asm: ./scripts/docker-ci-local.sh ubuntu-gates  or  make -C compiler bootstrap-driver-bstrict"
  echo "  WPO-S2: ./scripts/docker-ci-local.sh ubuntu-wpo-s2"
fi
if command -v gh >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  br=$(git branch --show-current 2>/dev/null || echo dev)
  echo "=== recent GHA runs (branch ${br}) ==="
  gh run list --branch "$br" -L 3 2>/dev/null || echo "(gh run list unavailable)"
fi

echo ""
echo "push-ready OK — next: commit → git push → gh run watch (Net perf / ZC-1, Windows IO-A6)"
