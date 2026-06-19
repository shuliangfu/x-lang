#!/usr/bin/env bash
# seed 链全量回归：bootstrap-driver-seed 后 SHUX=./compiler/shux 跑 run-all。
# x86_64 CI 必跑；arm64/Darwin 上 -o 链接部分用例走 shux-c（run-all 内 run_shu_for_script 已分流）。
# 用法：./tests/run-all-seed.sh

set -e
cd "$(dirname "$0")/.."

make -C compiler bootstrap-driver-seed
export SHUX=./compiler/shux
export SHUX_RUN_ALL_BOOTSTRAP_SHUX=1

case "$(uname -m 2>/dev/null)" in
  x86_64|amd64)
    echo "run-all-seed: Linux/macOS x86_64 — full seed + shux-c split per run-all"
    ;;
  *)
    echo "run-all-seed: $(uname -m) — seed typeck/lexer; -o 优先 shux-c（见 run-all.sh）"
    ;;
esac

exec ./tests/run-all.sh
