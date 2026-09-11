#!/bin/bash
# prove_pthin_stretch_audit_eq_mode.sh — B-minus eq wall-clock modes
#
# Target (2026-09-11): soft-knife L2 close wall-clock budget **≤10 min**
# (g05+matrix+drift+compress+eq). Full OFF=128 serial (~50 min) is NOT a
# soft-knife gate anymore.
#
# Usage:
#   bash scripts/prove_pthin_stretch_audit_eq_mode.sh daily <substr,substr,...>
#   bash scripts/prove_pthin_stretch_audit_eq_mode.sh close
#   bash scripts/prove_pthin_stretch_audit_eq_mode.sh full
#
# daily — EQ_ONLY delta on this wave's new symbols. Typical ~1 min.
# close — ALL symbols, OFF=24, parallel shards (default JOBS=min(8,ncpu)).
#         Measured Darwin: ~3.2 min eq @ JOBS=8 → soft-knife L2 total ≤10 min.
# full  — ALL symbols, OFF=128, parallel. Pin-bump / L4 only (NOT every soft knife).
#         Serial JOBS=1 ≈50 min — avoid.
#
# Env overrides: EQ_MAX_FILE_OFF, EQ_JOBS, EQ_FILE_STRIDE, EQ_SKIP_SYNTH.
# PLATFORM: SHARED — Darwin + Ubuntu.
set -eu
cd "$(dirname "$0")/.."

MODE=${1:-}
shift || true

OUT=tests/probes/pthin_stretch_audit
HARNESS="$OUT/eq_harness"
CC=${CC:-cc}

default_jobs() {
  local n=4
  if n=$(sysctl -n hw.ncpu 2>/dev/null); then
    :
  elif n=$(nproc 2>/dev/null); then
    :
  else
    n=4
  fi
  if [ "$n" -gt 8 ]; then
    n=8
  fi
  if [ "$n" -lt 2 ]; then
    n=2
  fi
  echo "$n"
}

build_harness() {
  mkdir -p "$OUT"
  ./xlang -E src/asm/pthin_stretch_audit.x >"$OUT/audit_x_E.c" 2>"$OUT/audit_x_E.err"
  $CC -c -I. -Iinclude -Isrc -Isrc/asm -Iseeds/parser_asm -o "$OUT/audit_x.o" "$OUT/audit_x_E.c" \
    2>"$OUT/audit_x_cc.err" || { cat "$OUT/audit_x_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -Isrc -Iseeds/parser_asm -o "$OUT/bridge.o" \
    seeds/parser_asm_lex_step_bridge.from_x.c 2>"$OUT/bridge_cc.err" || {
    cat "$OUT/bridge_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -Isrc -o "$OUT/lexer_pin.o" seeds/lexer_gen.linux.x86_64.c \
    2>"$OUT/lexer_pin_cc.err" || { cat "$OUT/lexer_pin_cc.err" >&2; return 1; }
  $CC -I. -Iinclude -o "$HARNESS" \
    scripts/pthin_stretch_audit_eq_harness.c "$OUT/audit_x.o" "$OUT/bridge.o" "$OUT/lexer_pin.o" \
    2>"$OUT/harness_cc.err" || { cat "$OUT/harness_cc.err" >&2; return 1; }
}

run_shards() {
  local jobs="$1"
  shift
  local files=("$@")
  local i pids=() rc=0 checks=0 fail=0
  local logdir
  logdir=$(mktemp -d "${TMPDIR:-/tmp}/eq_shards.XXXXXX")
  if [ "$jobs" -le 1 ]; then
    export EQ_SHARD=0/1
    "$HARNESS" "${files[@]}"
    return $?
  fi
  for i in $(seq 0 $((jobs - 1))); do
    (
      export EQ_SHARD="$i/$jobs"
      "$HARNESS" "${files[@]}" >"$logdir/w$i.out" 2>"$logdir/w$i.err"
      echo $? >"$logdir/w$i.rc"
    ) &
    pids+=($!)
  done
  for i in "${pids[@]}"; do
    wait "$i" || true
  done
  for i in $(seq 0 $((jobs - 1))); do
    cat "$logdir/w$i.err" >&2 || true
    cat "$logdir/w$i.out" || true
    wrc=$(cat "$logdir/w$i.rc")
    if [ "$wrc" != 0 ]; then
      rc=1
    fi
    # Sum checks from "N checks OK" / "N checks, F FAIL"
    c=$(sed -n 's/.*: \([0-9][0-9]*\) checks.*/\1/p' "$logdir/w$i.out" | tail -1)
    checks=$((checks + ${c:-0}))
  done
  rm -rf "$logdir"
  if [ "$rc" -ne 0 ]; then
    echo "pthin_stretch_audit_eq: shard FAIL (jobs=$jobs partial_checks=$checks)" >&2
    return 1
  fi
  echo "pthin_stretch_audit_eq: $checks checks OK (jobs=$jobs aggregated)"
  return 0
}

FILES=(src/asm/pthin_stretch_audit.x src/asm/pthin_stretch.x src/main.x)

case "$MODE" in
  daily)
    if [ "$#" -lt 1 ] || [ -z "${1:-}" ]; then
      echo "usage: $0 daily <EQ_ONLY substrings comma-separated>" >&2
      exit 2
    fi
    export EQ_ONLY="$1"
    # Default OFF=24: ultra_hyper+ score chains make OFF=128 daily multi-minute;
    # close already covers the full table at OFF=24×parallel. Override with
    # EQ_MAX_FILE_OFF=128 when deliberately deepening a delta smoke.
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-24}"
    unset EQ_SHARD || true
    echo "eq_mode=daily EQ_ONLY=$EQ_ONLY OFF=$EQ_MAX_FILE_OFF (target <2min)"
    build_harness
    export EQ_SHARD=0/1
    "$HARNESS" "${FILES[@]}"
    ;;
  close)
    # Soft-knife wave close: all symbols, thinned offsets, parallel shards.
    unset EQ_ONLY || true
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-24}"
    JOBS="${EQ_JOBS:-$(default_jobs)}"
    export EQ_FILE_STRIDE="${EQ_FILE_STRIDE:-1}"
    echo "eq_mode=close OFF=$EQ_MAX_FILE_OFF JOBS=$JOBS STRIDE=$EQ_FILE_STRIDE (target eq ~3min; L2 total ≤10min)"
    build_harness
    run_shards "$JOBS" "${FILES[@]}"
    ;;
  full)
    # Pin-bump / L4 only — never the soft-knife micro-wave gate.
    unset EQ_ONLY || true
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-128}"
    JOBS="${EQ_JOBS:-$(default_jobs)}"
    export EQ_FILE_STRIDE="${EQ_FILE_STRIDE:-1}"
    echo "eq_mode=full OFF=$EQ_MAX_FILE_OFF JOBS=$JOBS (pin/L4 only)"
    build_harness
    run_shards "$JOBS" "${FILES[@]}"
    ;;
  *)
    echo "usage: $0 daily <substrs> | $0 close | $0 full" >&2
    exit 2
    ;;
esac
