#!/usr/bin/env bash
# PERF-002: IO throughput vs Zig gate (sequential + random).
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm. Default FAIL_ON soft path reports obs via runner (opt-in
# XLANG_PERF_FAIL_ON_IO_*=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-io-zig-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_PERF_IO_ZIG]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-io-zig gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

DOC="${XLANG_PERF_IO_ZIG_DOC:-analysis/archive/perf/perf-io-zig-v1.md}"

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-io-zig-v1.md ]; then
  die "refuse top-level analysis/perf-io-zig-v1.md (use archive/perf)"
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"
if [ ! -f "$DOC" ]; then
  die "missing $DOC"
fi
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

echo "=== PERF-002: IO throughput vs Zig (sequential + random) ==="
chmod +x tests/run-perf-io.sh
# Default soft FAIL_ON:-0 → runner obs on over-cap; opt-in =1 still hard.
set +e
out="$(
  XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    XLANG_PERF_FAIL_ON_IO_ZIG="${XLANG_PERF_FAIL_ON_IO_ZIG:-0}" \
    XLANG_PERF_FAIL_ON_IO_REGRESSION="${XLANG_PERF_FAIL_ON_IO_REGRESSION:-0}" \
    XLANG_IO_BENCH_MB="${XLANG_IO_BENCH_MB:-4}" \
    ./tests/run-perf-io.sh --bench 2>&1
)"
rc=$?
set -e
printf '%s\n' "$out"
if [ "$rc" -ne 0 ]; then
  die "run-perf-io --bench rc=$rc"
fi
RUN_OK=1
if echo "$out" | grep -qE 'OBS:|obs=[1-9]'; then
  OBS=1
fi
echo "perf-io-zig gate OK"
ok_report
exit 0
