#!/usr/bin/env bash
# P1 perf gate: compute baseline + B-CMP + IO + NET + compile dogfood.
#
# Honesty: soft auto-make (ensure-compiler-seed) + soft prefer-c + bare
# ZC SKIP without skip= retired. Prefer product xlang_asm. Explicit bad
# XLANG = hard die. Default archaeology: FAIL_ON soft→obs via runners
# (opt-in XLANG_PERF_P1_HARD=1 restores FAIL_ON_*=1 for pre-push).
# Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-p1-gate.sh
#   XLANG_PERF_P1_HARD=1 ./tests/run-perf-p1-gate.sh   # pre-push hard
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_PERF_P1]"
RUN_OK=0
OBS=0
SKIP=0
HARD="${XLANG_PERF_P1_HARD:-0}"

die() {
  echo "perf P1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} hard=${HARD} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} hard=${HARD} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Refuse soft auto-make: tip must already have a native product binary.
XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft auto-make / soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

if [ "$HARD" = "1" ]; then
  FAIL_ZIG=1
  FAIL_IO_ZIG=1
  FAIL_IO_REG=1
  FAIL_NET_REG=1
else
  # Archaeology default: over-cap / behind = obs (FAIL=1 still available via HARD).
  FAIL_ZIG=0
  FAIL_IO_ZIG=0
  FAIL_IO_REG=0
  FAIL_NET_REG=0
fi

absorb_log() {
  local log="$1"
  if grep -qE 'OBS:|obs=[1-9]' "$log" 2>/dev/null; then
    OBS=1
  fi
  if grep -qE 'skip=[1-9]' "$log" 2>/dev/null; then
    SKIP=$((SKIP + 1))
  fi
}

echo "=== perf P1 gate: compute baseline (Zig; HARD=${HARD}) ==="
set +e
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  XLANG_PERF_FAIL_ON_ZIG="$FAIL_ZIG" \
  ./tests/run-perf-baseline.sh --bench > /tmp/perf_p1_baseline.log 2>&1
bl_ec=$?
set -e
cat /tmp/perf_p1_baseline.log
absorb_log /tmp/perf_p1_baseline.log
if [ "$bl_ec" -ne 0 ]; then
  die "baseline rc=$bl_ec"
fi
grep -qE 'perf baseline OK|perf B-CMP' /tmp/perf_p1_baseline.log || die "baseline missing OK"

echo "=== perf P1 gate: B-CMP (Xlang -O3 codegen-fair vs C -O3; HARD=${HARD}) ==="
chmod +x tests/run-bcmp-gate.sh
if [ "$HARD" = "1" ]; then
  set +e
  ./tests/run-bcmp-gate.sh > /tmp/perf_p1_bcmp.log 2>&1
  bc_ec=$?
  set -e
  cat /tmp/perf_p1_bcmp.log
  absorb_log /tmp/perf_p1_bcmp.log
  if [ "$bc_ec" -ne 0 ]; then
    die "bcmp rc=$bc_ec"
  fi
else
  # Archaeology: bcmp-gate forces FAIL_ON_C_O3=1 (tip under-ratio = portable
  # false-red). Soft path relies on the baseline step above (FAIL_ON=0 → obs).
  echo "perf P1 gate: B-CMP soft skip hard-gate (covered by baseline obs; HARD=0)"
fi

echo "=== perf P1 gate: IO (Zig + regression; HARD=${HARD}) ==="
set +e
XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  XLANG_PERF_FAIL_ON_IO_ZIG="$FAIL_IO_ZIG" \
  XLANG_PERF_FAIL_ON_IO_REGRESSION="$FAIL_IO_REG" \
  ./tests/run-perf-io.sh --bench > /tmp/perf_p1_io.log 2>&1
io_ec=$?
set -e
cat /tmp/perf_p1_io.log
absorb_log /tmp/perf_p1_io.log
if [ "$io_ec" -ne 0 ]; then
  die "io rc=$io_ec"
fi
grep -q 'io perf OK' /tmp/perf_p1_io.log || die "io missing OK"

echo "=== perf P1 gate: net (regression; Linux io_uring 时含 ZC-1 --perf) ==="
chmod +x tests/run-perf-net.sh tests/run-zc1-gate.sh 2>/dev/null || true
if [ "$(uname -s)" = "Linux" ]; then
  # shellcheck source=tests/lib/io-uring-probe.sh
  . tests/lib/io-uring-probe.sh
  if io_uring_available; then
    set +e
    ./tests/run-zc1-gate.sh --perf > /tmp/perf_p1_net.log 2>&1
    net_ec=$?
    set -e
    cat /tmp/perf_p1_net.log
    absorb_log /tmp/perf_p1_net.log
    if [ "$net_ec" -ne 0 ]; then
      die "zc1 --perf rc=$net_ec"
    fi
  else
    SKIP=$((SKIP + 1))
    echo "perf P1 gate: ZC-1 SKIP (io_uring unavailable; skip=1)"
    set +e
    XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      XLANG_PERF_FAIL_ON_NET_REGRESSION="$FAIL_NET_REG" \
      ./tests/run-perf-net.sh --bench > /tmp/perf_p1_net.log 2>&1
    net_ec=$?
    set -e
    cat /tmp/perf_p1_net.log
    absorb_log /tmp/perf_p1_net.log
    if [ "$net_ec" -ne 0 ]; then
      die "net rc=$net_ec"
    fi
    grep -q 'net perf OK' /tmp/perf_p1_net.log || die "net missing OK"
  fi
else
  SKIP=$((SKIP + 1))
  echo "perf P1 gate: ZC-1 SKIP (non-Linux; skip=1)"
  set +e
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    XLANG_PERF_FAIL_ON_NET_REGRESSION="$FAIL_NET_REG" \
    ./tests/run-perf-net.sh --bench > /tmp/perf_p1_net.log 2>&1
  net_ec=$?
  set -e
  cat /tmp/perf_p1_net.log
  absorb_log /tmp/perf_p1_net.log
  if [ "$net_ec" -ne 0 ]; then
    die "net rc=$net_ec"
  fi
  grep -q 'net perf OK' /tmp/perf_p1_net.log || die "net missing OK"
fi

echo "=== perf P1 gate: compile dogfood (PERF-004) ==="
chmod +x tests/run-perf-compile-dogfood-gate.sh
set +e
# Dogfood default FAIL_REG=1; archaeology soft→obs when HARD=0.
if [ "$HARD" = "1" ]; then
  XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 \
    ./tests/run-perf-compile-dogfood-gate.sh > /tmp/perf_p1_dogfood.log 2>&1
else
  XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=0 \
    ./tests/run-perf-compile-dogfood-gate.sh > /tmp/perf_p1_dogfood.log 2>&1
fi
df_ec=$?
set -e
cat /tmp/perf_p1_dogfood.log
absorb_log /tmp/perf_p1_dogfood.log
if [ "$df_ec" -ne 0 ]; then
  die "compile-dogfood rc=$df_ec"
fi
grep -qE 'compile dogfood OK|perf-compile-dogfood gate OK|status=ok|SKIP bench' /tmp/perf_p1_dogfood.log \
  || die "dogfood missing OK"

RUN_OK=1
echo "perf P1 gate OK (baseline + io + net + compile dogfood)"
ok_report
exit 0
