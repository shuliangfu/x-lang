#!/usr/bin/env bash
# P0 本地 push 前自检：bootstrap-ci + perf P1 + asm 7.3（bstrict 107 含于 bootstrap-ci）。
# 用法：SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/ensure-compiler-seed.sh
source "$(dirname "$0")/lib/ensure-compiler-seed.sh"
export SHUX="${SHUX:-./compiler/shux_asm}"
if [ ! -x "$SHUX" ]; then
  echo "run-pre-push-p0: missing $SHUX (make -C compiler bootstrap-driver-bstrict)" >&2
  exit 1
fi

echo "=== P0: bootstrap-bstrict-ci ==="
SHUX="$SHUX" ./tests/run-bootstrap-bstrict-ci.sh

echo "=== P0: asm compute gate (binop + vector + call-inline) ==="
SHUX="$SHUX" ./tests/run-asm-73-gate.sh

echo "=== P0: perf P1 gate ==="
./tests/run-perf-p1-gate.sh

echo "pre-push P0 OK (bootstrap-ci + asm-73 + perf-p1)"
# 提示：未 push 时 GHA 不会跑；显示当前分支与 origin 差异（若有 git）。
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  br=$(git branch --show-current 2>/dev/null || echo "?")
  ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "?")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "git: branch=$br ahead-of-upstream=$ahead dirty-files=$dirty"
  if [ "$ahead" != "?" ] && [ "$ahead" != "0" ]; then
    echo "next: git push origin $br   # then: gh run watch"
  fi
  if [ "$dirty" != "0" ] && [ "$dirty" != "?" ]; then
    echo "note: working tree has uncommitted changes; commit before push if needed"
  fi
fi
