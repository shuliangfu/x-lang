#!/usr/bin/env bash
# G-02f-317：product hybrid 下 runtime rest 业务 T 符号须为 0（f-316 里程碑哨兵）。
#
# wave honesty (2026-08-24 #5): monofile seeds/runtime.from_x.c retired wave321;
# "rest empty" is now satisfied by physical deletion — refuse resurrect.
# Live business symbols live in rt_* / runtime_*_abi slices (not a residual monofile).
# PLATFORM: SHARED archaeology.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CDIR="$ROOT/compiler"
cd "$CDIR"

if [ -f seeds/runtime.from_x.c ]; then
  echo "FAIL: seeds/runtime.from_x.c resurrected; rest empty requires monofile stay deleted (G-02f-317)" >&2
  exit 1
fi

# Spot-check that live rest slices still exist (not a silent empty tree).
for f in seeds/rt_dispatch_impl.from_x.c seeds/rt_run_compiler_parsed.from_x.c \
  seeds/runtime_link_abi.from_x.c seeds/runtime_pipeline_abi.from_x.c; do
  if [ ! -f "$f" ]; then
    echo "FAIL: missing live seed $f (G-02f-317 rest→slice migration)" >&2
    exit 1
  fi
done

echo "OK: product hybrid runtime rest T=0 via monofile retired (G-02f-317 gate)"
exit 0
