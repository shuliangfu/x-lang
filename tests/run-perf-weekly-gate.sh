#!/usr/bin/env bash
# PERF-169: weekly perf baseline aggregator gate.
#
# Honesty: soft SKIP→OK when child prints SKIP / soft FAIL=0 simd swallow /
# missing top-level DOC retired. Prefer product paths via child gates
# (io-zig / net-zig / simd already honesty-rewritten). Child hard fail =
# hard fail (no grep-SKIP soft green). Child obs=/skip= propagated.
# DOC authority = archive/perf. Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-weekly-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_PERF_WEEKLY_DOC:-analysis/archive/perf/perf-weekly-v1.md}"
MANIFEST="${XLANG_PERF_WEEKLY_TSV:-tests/baseline/perf-weekly.tsv}"
PREFIX="xlang: [XLANG_PERF_WEEKLY]"
RUN_OK=0
OBS=0
SKIP=0
SIMD_OK=0
IO_OK=0
NET_OK=0
DB_OK=0
STD_OK=0

# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

die() {
  echo "perf-weekly gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok simd=${SIMD_OK} io=${IO_OK} net=${NET_OK} db=${DB_OK} std=${STD_OK} run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-weekly-v1.md ]; then
  die "refuse top-level analysis/perf-weekly-v1.md (use archive/perf)"
fi

# Explicit bad XLANG hard-dies before pillar fan-out.
if [ -n "${XLANG:-}" ]; then
  resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
fi

echo "=== PERF-169: weekly perf manifest ==="
for f in "$DOC" "$MANIFEST"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi

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
  die "pillars=${PILLARS} < 5"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "perf-weekly manifest OK (pillars=${PILLARS})"

absorb_status() {
  # Parse child status line for obs=/skip=; never soft-swallow non-zero rc.
  local log="$1"
  local ec="$2"
  local label="$3"
  if [ "$ec" -ne 0 ]; then
    echo "perf-weekly ${label} FAIL (rc=${ec})" >&2
    tail -12 "$log" >&2 || true
    die "${label} child rc=${ec}"
  fi
  if grep -qE 'obs=[1-9]' "$log" 2>/dev/null; then
    OBS=1
  fi
  if grep -qE 'OBS:' "$log" 2>/dev/null; then
    OBS=1
  fi
  if grep -qE 'skip=[1-9]' "$log" 2>/dev/null; then
    SKIP=$((SKIP + 1))
  fi
}

echo "=== PERF-169: pillar SIMD ==="
chmod +x tests/run-std-simd-autovec-strategy-gate.sh
./tests/run-std-simd-autovec-strategy-gate.sh
SIMD_OK=1
if [ -x ./compiler/xlang_asm ] || [ -x ./compiler/xlang_asm.strict ]; then
  chmod +x tests/run-perf-simd-shuffle-select.sh 2>/dev/null || true
  if [ -f tests/run-perf-simd-shuffle-select.sh ]; then
    set +e
    # Child honesty: FAIL=0 → under-ratio = obs (not soft SKIP).
    ./tests/run-perf-simd-shuffle-select.sh >/tmp/perf_weekly_simd.log 2>&1
    simd_ec=$?
    set -e
    absorb_status /tmp/perf_weekly_simd.log "$simd_ec" "SIMD shuffle/select"
    echo "perf-weekly SIMD shuffle/select OK"
  fi
fi

echo "=== PERF-169: pillar IO ==="
chmod +x tests/run-perf-io-zig-gate.sh
set +e
./tests/run-perf-io-zig-gate.sh >/tmp/perf_weekly_io.log 2>&1
io_ec=$?
set -e
absorb_status /tmp/perf_weekly_io.log "$io_ec" "IO"
IO_OK=1
echo "perf-weekly IO OK"

echo "=== PERF-169: pillar NET ==="
chmod +x tests/run-perf-net-zc-gate.sh tests/run-perf-net-zig-gate.sh
set +e
./tests/run-perf-net-zc-gate.sh >/tmp/perf_weekly_net_zc.log 2>&1
nzc_ec=$?
set -e
absorb_status /tmp/perf_weekly_net_zc.log "$nzc_ec" "NET-ZC"
set +e
./tests/run-perf-net-zig-gate.sh >/tmp/perf_weekly_net.log 2>&1
net_ec=$?
set -e
absorb_status /tmp/perf_weekly_net.log "$net_ec" "NET"
NET_OK=1
echo "perf-weekly NET OK"

echo "=== PERF-169: pillar DB ==="
chmod +x tests/run-perf-sqlite-gate.sh
./tests/run-perf-sqlite-gate.sh
DB_OK=1

echo "=== PERF-169: pillar STD (Phase 3) ==="
chmod +x tests/run-perf-phase3-gate.sh tests/lib/perf-phase3.sh
./tests/run-perf-phase3-gate.sh
STD_OK=1

RUN_OK=1
echo "perf-weekly gate OK"
ok_report
exit 0
