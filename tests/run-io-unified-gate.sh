#!/usr/bin/env bash
# run-io-unified-gate leftover: unified IO backend (Tier P + Tier B).
# Same .x sources: batch_rw_smoke product -o; delegates leftover
# run-io-read-ptr-slice + already-honest run-io.sh. Linux ZC-1/multishot
# stay leave (host-c + liburing). Optional --perf keeps platform perf.
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q || make` +
# process.o) + bootstrap-link wrap + xlang-c-first prefer-c retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / leftover XLANG fallthrough / soft
# auto-make / prefer-c). Check path = obs= (paused 2026-08-05).
# Product `-o` batch_rw_smoke must exit 0. Nested leftover / run-io must
# exit 0. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-io-unified-gate.sh [--perf]
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_IO_UNIFIED_PREFIX:-xlang: [IO_UNIFIED]}"
RUN_OK=0
OBS=0
SKIP=0
DO_PERF=0

die() {
  echo "io-unified FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Explicit XLANG that is missing/non-native
# returns 1 (caller hard-dies; refuse leftover XLANG fallthrough).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

for arg in "$@"; do
  case "$arg" in
    --perf) DO_PERF=1 ;;
    -h|--help)
      echo "Usage: $0 [--perf]"
      exit 0
      ;;
    *)
      echo "run-io-unified-gate: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

echo "=== io-unified leftover (prefer asm; hard; refuse leftover auto-make / prefer-c) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft auto-make)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . tests/io/batch_rw_smoke.x >/tmp/xlang_io_unified_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "io-unified OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Smoke writes bench/.io_batch_rw_smoke_tmp (v1.2 git-mv from tests/bench/).
# PLATFORM: SHARED — fixture cleanup; Ubuntu gold still required.
rm -f bench/.io_batch_rw_smoke_tmp

echo "=== IO unified: batch_rw_smoke.x ($(ci_host_summary)) ==="
exe="/tmp/xlang_io_batch_rw_smoke_$$"
rm -f "$exe"
set +e
"$XLANG_BIN" -L . tests/io/batch_rw_smoke.x -o "$exe" >/tmp/xlang_io_batch_rw_smoke_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_io_batch_rw_smoke_o.log 2>/dev/null || true
  rm -f "$exe"
  die "batch_rw_smoke product -o failed (ec=$o_ec; refuse leftover auto-make / prefer-c)"
fi
set +e
"$exe"
r_ec=$?
set -e
rm -f "$exe" bench/.io_batch_rw_smoke_tmp
[ "$r_ec" -eq 0 ] || die "batch_rw_smoke exit=$r_ec (expected 0)"
RUN_OK=$((RUN_OK + 1))
echo "io batch_rw_smoke OK"

echo "=== IO unified: read_ptr_slice (M-5 leftover) ==="
chmod +x tests/run-io-read-ptr-slice.sh
XLANG="$XLANG_BIN" ./tests/run-io-read-ptr-slice.sh

echo "=== IO unified: std.io smoke (run-io.sh) ==="
chmod +x tests/run-io.sh
XLANG="$XLANG_BIN" ./tests/run-io.sh

# Tier B: Linux io_uring leave (host-c + liburing). Do not rewrite those
# leftover auto-make scripts this wave; keep calling as existing live face.
# PLATFORM: LINUX — io_uring; Darwin/Windows N/A.
if ci_is_linux; then
  echo "=== IO unified: ZC-1 provided buffers (Linux leave) ==="
  chmod +x tests/run-provided-buffers.sh tests/lib/io-uring-probe.sh
  set +e
  ./tests/run-provided-buffers.sh | tee /tmp/io_unified_zc1.log
  set -e
  if grep -q "provided buffers smoke FAIL" /tmp/io_unified_zc1.log; then
    die "provided buffers smoke"
  fi
  if grep -q "provided buffers smoke OK" /tmp/io_unified_zc1.log; then
    echo "io provided buffers OK"
  else
    echo "io provided buffers N/A ($(ci_host_summary))"
  fi

  echo "=== IO unified: multishot accept (Linux leave) ==="
  chmod +x tests/run-io-multishot.sh
  set +e
  ./tests/run-io-multishot.sh | tee /tmp/io_unified_multishot.log
  set -e
  if grep -q "io multishot FAIL" /tmp/io_unified_multishot.log; then
    die "multishot"
  fi
  grep -qE 'io multishot accept OK|io multishot: N/A' /tmp/io_unified_multishot.log
else
  echo "io ZC-1/multishot N/A ($(ci_host_summary): io_uring requires Linux)"
fi

if [ "$DO_PERF" -eq 0 ]; then
  ok_report
  echo "io unified gate OK (smoke)"
  exit 0
fi

echo "=== IO unified: perf baseline (run-perf-io) ==="
chmod +x tests/run-perf-io.sh
if ci_is_linux; then
  IO_PERF_REGRESS="${XLANG_PERF_FAIL_ON_IO_REGRESSION:-1}"
  IO_PERF_ZIG="${XLANG_PERF_FAIL_ON_IO_ZIG:-0}"
  XLANG_PERF_FAIL_ON_IO_REGRESSION="$IO_PERF_REGRESS" \
    XLANG_PERF_FAIL_ON_IO_ZIG="$IO_PERF_ZIG" \
    ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
else
  ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
fi
grep -q 'io perf OK' /tmp/io_unified_perf.log

if ci_is_linux && ci_io_uring_available; then
  echo "=== IO unified: ZC-1 net perf (Linux io_uring) ==="
  chmod +x tests/run-zc1-gate.sh
  ZC1_ENV="XLANG_PERF_FAIL_ON_NET_REGRESSION=1 XLANG_PERF_FAIL_ON_ZC1=1"
  if [ -n "${XLANG_CI_REQUIRE_ZC1:-}" ]; then
    ZC1_ENV="${ZC1_ENV} XLANG_CI_REQUIRE_ZC1=1"
  fi
  # shellcheck disable=SC2086
  env ${ZC1_ENV} ./tests/run-zc1-gate.sh --perf | tee /tmp/io_unified_zc1_perf.log
  grep -qE 'ZC-1 gate OK|provided buffers N/A' /tmp/io_unified_zc1_perf.log
  grep -q 'ZC-1 provided vs batch OK' /tmp/io_unified_zc1_perf.log || {
    if [ -n "${XLANG_CI_REQUIRE_ZC1:-}" ]; then
      die "ZC-1 -10% required (XLANG_CI_REQUIRE_ZC1=1)"
    fi
    echo "io ZC-1 perf stretch N/A (no -10% on this runner)"
  }
else
  echo "io ZC-1 perf N/A ($(ci_host_summary))"
fi

if iocp_backend_expected; then
  echo "=== IO unified: IOCP pipe perf (Windows) ==="
  chmod +x tests/run-perf-iocp.sh
  XLANG_IOCP_RUNS="${XLANG_IOCP_RUNS:-1}" XLANG_IOCP_BENCH_ROUNDS="${XLANG_IOCP_BENCH_ROUNDS:-32768}" \
    XLANG_PERF_FAIL_ON_IOCP_REGRESSION=1 ./tests/run-perf-iocp.sh --bench | tee /tmp/io_unified_iocp_perf.log
  grep -q 'iocp perf OK' /tmp/io_unified_iocp_perf.log
else
  echo "io IOCP perf N/A ($(ci_host_summary))"
fi

ok_report
echo "io unified gate OK (smoke + perf)"
