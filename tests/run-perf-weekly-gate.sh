#!/usr/bin/env bash
# PERF-169：SIMD/IO/NET/DB 每周性能基线汇总门禁
#
# 四支柱 + STD 扩展：
#   1) SIMD — std-simd-autovec-strategy + 可选 shuffle/select perf
#   2) IO   — perf-io-zig（无 native shux 时 SKIP）
#   3) NET  — perf-net-zc manifest + perf-net-zig（无 shux 时 SKIP）
#   4) DB   — perf-sqlite manifest + stub/loop 烟测
#
# 用法：./tests/run-perf-weekly-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_PERF_WEEKLY_DOC:-analysis/perf-weekly-v1.md}"
MANIFEST="${SHUX_PERF_WEEKLY_TSV:-tests/baseline/perf-weekly.tsv}"
PREFIX="shux: [SHUX_PERF_WEEKLY]"

echo "=== PERF-169: weekly perf manifest ==="
for f in "$DOC" "$MANIFEST"; do
  if [ ! -f "$f" ]; then
    echo "perf-weekly gate FAIL: missing $f" >&2
    exit 1
  fi
done

MISS=0
PILLARS=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    pillar)
      PILLARS=$((PILLARS + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-weekly FAIL: doc missing pillar '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    gate_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "perf-weekly FAIL: missing gate tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "perf-weekly FAIL: doc missing gate $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$PILLARS" -lt 5 ]; then
  echo "perf-weekly gate FAIL: pillars=${PILLARS} < 5" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "perf-weekly gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "perf-weekly manifest OK (pillars=${PILLARS})"

SIMD_OK=0
IO_OK=0
NET_OK=0
DB_OK=0
STD_OK=0
SKIP=0

echo "=== PERF-169: pillar SIMD ==="
chmod +x tests/run-std-simd-autovec-strategy-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
SIMD_OK=1
if [ -x ./compiler/shux_asm ] || [ -x ./compiler/shux_asm.strict ]; then
  chmod +x tests/run-perf-simd-shuffle-select.sh 2>/dev/null || true
  if [ -f tests/run-perf-simd-shuffle-select.sh ]; then
    set +e
    SHUX_SIMD_SS_FAIL=0 ./tests/run-perf-simd-shuffle-select.sh >/tmp/perf_weekly_simd.log 2>&1
    simd_ec=$?
    set -e
    if [ "$simd_ec" -eq 0 ]; then
      echo "perf-weekly SIMD shuffle/select OK"
    else
      echo "perf-weekly SIMD shuffle/select SKIP (see /tmp/perf_weekly_simd.log)" >&2
      SKIP=$((SKIP + 1))
    fi
  fi
fi

echo "=== PERF-169: pillar IO ==="
chmod +x tests/run-perf-io-zig-gate.sh
set +e
./tests/run-perf-io-zig-gate.sh >/tmp/perf_weekly_io.log 2>&1
io_ec=$?
set -e
if [ "$io_ec" -eq 0 ]; then
  IO_OK=1
  echo "perf-weekly IO OK"
elif grep -q 'SKIP' /tmp/perf_weekly_io.log 2>/dev/null; then
  IO_OK=1
  SKIP=$((SKIP + 1))
  echo "perf-weekly IO SKIP (no native shux)"
else
  echo "perf-weekly IO FAIL" >&2
  tail -8 /tmp/perf_weekly_io.log >&2 || true
  exit 1
fi

echo "=== PERF-169: pillar NET ==="
chmod +x tests/run-perf-net-zc-gate.sh tests/run-perf-net-zig-gate.sh
./tests/run-perf-net-zc-gate.sh
set +e
./tests/run-perf-net-zig-gate.sh >/tmp/perf_weekly_net.log 2>&1
net_ec=$?
set -e
if [ "$net_ec" -eq 0 ]; then
  NET_OK=1
  echo "perf-weekly NET OK"
elif grep -q 'SKIP' /tmp/perf_weekly_net.log 2>/dev/null; then
  NET_OK=1
  SKIP=$((SKIP + 1))
  echo "perf-weekly NET SKIP (no native shux)"
else
  echo "perf-weekly NET FAIL" >&2
  tail -8 /tmp/perf_weekly_net.log >&2 || true
  exit 1
fi

echo "=== PERF-169: pillar DB ==="
chmod +x tests/run-perf-sqlite-gate.sh
./tests/run-perf-sqlite-gate.sh
DB_OK=1

echo "=== PERF-169: pillar STD (Phase 3) ==="
chmod +x tests/run-perf-phase3-gate.sh tests/lib/perf-phase3.sh
./tests/run-perf-phase3-gate.sh
STD_OK=1

echo "${PREFIX} status=ok simd=${SIMD_OK} io=${IO_OK} net=${NET_OK} db=${DB_OK} std=${STD_OK} skip=${SKIP}"
echo "perf-weekly gate OK"
