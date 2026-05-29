#!/usr/bin/env bash
# M3-c：CI / 本地统一的 B-strict 验收入口。
# 1) make bootstrap-driver-bstrict（链接审计：无 cc -c pipeline_gen.c）
# 2) run-shu-asm-gate（用户 import / option 等）
# 3) run-all-bstrict（SHU_BSTRICT_REPLACE=1 白名单 52 项）
# 语义自举仍由 make bootstrap-verify（check-7.2）单独跑，本脚本不替代。
# 用法：仓库根目录 ./tests/run-bootstrap-bstrict-ci.sh

set -e
cd "$(dirname "$0")/.."

ulimit -s 16384 2>/dev/null || true

if [ ! -f compiler/shu ] || [ ! -x compiler/shu ]; then
  echo "bootstrap-bstrict-ci: seed shu missing; run: make -C compiler OPT=1 all" >&2
  exit 127
fi

echo "bootstrap-bstrict-ci: bootstrap-driver-bstrict (build shu_asm) ..."
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log

if ! grep -qE 'Target-B-strict|B-strict OK|LINK_MODE=asm_only_strict' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: expected Target-B-strict / B-strict OK in build log" >&2
  exit 1
fi
if grep -q 'cc -c pipeline_gen.c' /tmp/build_bstrict.log; then
  echo "bootstrap-bstrict-ci: B-strict link must not compile pipeline_gen.c" >&2
  exit 1
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

echo "bootstrap-bstrict-ci: run-all-bstrict (replace seed, whitelist) ..."
export SHU_BSTRICT_SKIP_BUILD=1
./tests/run-all-bstrict.sh

echo "bootstrap-bstrict-ci: Linux crt0 + full_asm (M4, no-op on macOS) ..."
chmod +x tests/run-bootstrap-bstrict-linux.sh
./tests/run-bootstrap-bstrict-linux.sh

echo "bootstrap-bstrict-ci: M5 B-strict Stage2 (shu_asm -> shu_asm2) ..."
chmod +x tests/run-bootstrap-stage2-bstrict.sh compiler/verify-selfhost-stage2-bstrict.sh
./tests/run-bootstrap-stage2-bstrict.sh

echo "bootstrap-bstrict-ci OK (B-strict audited + gate + whitelist + linux crt0 + stage2)"
