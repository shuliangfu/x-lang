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
#         HARD BAN (2026-09-11): do NOT use daily for deep climb substrings
#         (summit / peak / zenith / versal / vx / apex_max_ultra… score chains).
#         Measured: exact-summit daily OFF=24 ≈65 min for 21 symbols — burns
#         a whole soft-knife slot. Soft-knife gate for deep climbs = **close
#         only** (matrix+drift+compress+close). Override only with
#         EQ_FORCE_DEEP_DAILY=1 (explicit, never default).
# close — ALL symbols, OFF=24, parallel shards (default JOBS=min(4,ncpu)).
#         Soft-knife wave gate. Defaults tuned 2026-09-11 after peak×OFF=24
#         burned 25+ min with no live logs:
#           EQ_SKIP_SYNTH=1          (synth×deep ≈98% of check volume)
#           EQ_FILE_STRIDE=4         (shallow breadth, fewer offsets)
#           EQ_DEEP_MAX_FILE_OFF=1   (peak/summit/zenith/versal offset cap)
#           deep skip on src len>512  (large .x files); short deep_smoke instead
#         Harness prints battery/progress on stderr (live; not held to end).
# full  — ALL symbols, OFF=128, parallel. Pin-bump / L4 only (NOT every soft knife).
#         Serial JOBS=1 ≈50 min — avoid. Does NOT apply deep_cap by default
#         (set EQ_DEEP_MAX_FILE_OFF explicitly if needed).
#
# Env overrides: EQ_MAX_FILE_OFF, EQ_JOBS, EQ_FILE_STRIDE, EQ_SKIP_SYNTH,
#                EQ_DEEP_MAX_FILE_OFF, EQ_FORCE_DEEP_DAILY.
# PLATFORM: SHARED — Darwin + Ubuntu.
set -eu
cd "$(dirname "$0")/.."

MODE=${1:-}
shift || true

OUT=tests/probes/pthin_stretch_audit
HARNESS="$OUT/eq_harness"
CC=${CC:-cc}

default_jobs() {
  # Cap at 4: JOBS=8 saturated every core and made the machine unusable
  # during soft-knife close (2026-09-11). Override with EQ_JOBS when deliberate.
  local n=4
  if n=$(sysctl -n hw.ncpu 2>/dev/null); then
    :
  elif n=$(nproc 2>/dev/null); then
    :
  else
    n=4
  fi
  # Soft default 2: leaves headroom for the IDE/agent. EQ_JOBS=4 when deliberate.
  if [ "$n" -gt 2 ]; then
    n=2
  fi
  if [ "$n" -lt 1 ]; then
    n=1
  fi
  echo "$n"
}

build_harness() {
  mkdir -p "$OUT"
  # Fail hard on -E: empty/failed emit must not reuse a stale audit_x.o (fake-green).
  if ! ./xlang -E src/asm/pthin_stretch_audit.x >"$OUT/audit_x_E.c" 2>"$OUT/audit_x_E.err"; then
    echo "pthin_stretch_audit_eq: -E FAILED (see $OUT/audit_x_E.err)" >&2
    cat "$OUT/audit_x_E.err" >&2 || true
    return 1
  fi
  if [ ! -s "$OUT/audit_x_E.c" ]; then
    echo "pthin_stretch_audit_eq: -E produced empty C (see $OUT/audit_x_E.err)" >&2
    cat "$OUT/audit_x_E.err" >&2 || true
    return 1
  fi
  $CC -c -I. -Iinclude -Isrc -Isrc/asm -Iseeds/parser_asm -o "$OUT/audit_x.o" "$OUT/audit_x_E.c" \
    2>"$OUT/audit_x_cc.err" || { cat "$OUT/audit_x_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -Isrc -Iseeds/parser_asm -o "$OUT/bridge.o" \
    seeds/parser_asm_lex_step_bridge.from_x.c 2>"$OUT/bridge_cc.err" || {
    cat "$OUT/bridge_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -Isrc -o "$OUT/lexer_pin.o" seeds/lexer_gen.linux.x86_64.c \
    2>"$OUT/lexer_pin_cc.err" || { cat "$OUT/lexer_pin_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -o "$OUT/leftover_kind.o" \
    scripts/pthin_stretch_audit_eq_leftover_kind.c 2>"$OUT/leftover_kind_cc.err" || {
    cat "$OUT/leftover_kind_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -o "$OUT/leftover_namelen.o" \
    scripts/pthin_stretch_audit_eq_leftover_namelen.c 2>"$OUT/leftover_namelen_cc.err" || {
    cat "$OUT/leftover_namelen_cc.err" >&2; return 1; }
  $CC -c -I. -Iinclude -o "$OUT/leftover_sourceoff.o" \
    scripts/pthin_stretch_audit_eq_leftover_sourceoff.c 2>"$OUT/leftover_sourceoff_cc.err" || {
    cat "$OUT/leftover_sourceoff_cc.err" >&2; return 1; }
  $CC -I. -Iinclude -o "$HARNESS" \
    scripts/pthin_stretch_audit_eq_harness.c "$OUT/audit_x.o" "$OUT/bridge.o" "$OUT/lexer_pin.o" \
    "$OUT/leftover_kind.o" "$OUT/leftover_namelen.o" "$OUT/leftover_sourceoff.o" \
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
      # stdout → shard file (summary line); stderr live via tee so progress
      # lines appear while workers run (old path held stderr until wait).
      "$HARNESS" "${files[@]}" >"$logdir/w$i.out" 2> >(tee "$logdir/w$i.err" >&2)
      echo $? >"$logdir/w$i.rc"
    ) &
    pids+=($!)
  done
  for i in "${pids[@]}"; do
    wait "$i" || true
  done
  for i in $(seq 0 $((jobs - 1))); do
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
    # Refuse deep-climb dailies by default (hour-scale wall-clock). Soft-knife
    # gate for those waves is close-only. See header HARD BAN.
    if [ "${EQ_FORCE_DEEP_DAILY:-0}" != 1 ]; then
      # Hour-scale only: exact summit+ and 88+ versal. Lower rungs (hyper/
      # ultra_hyper/max/apex) may still use daily when <~15 min; apex already
      # stretched the soft budget — prefer close when in doubt.
      case ",$EQ_ONLY," in
        *,*summit*|*,*peak*|*,*zenith*|*,*versal*|*,*vx*)
          echo "eq_mode=daily REFUSED: deep-climb EQ_ONLY='$EQ_ONLY' is hour-scale." >&2
          echo "  Soft-knife gate = close (matrix+drift+compress+close)." >&2
          echo "  Override only with EQ_FORCE_DEEP_DAILY=1 (never default)." >&2
          exit 3
          ;;
      esac
    fi
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
    # Defaults keep ≤10 min even when the table holds peak score-chains.
    unset EQ_ONLY || true
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-24}"
    JOBS="${EQ_JOBS:-$(default_jobs)}"
    export EQ_FILE_STRIDE="${EQ_FILE_STRIDE:-4}"
    export EQ_SKIP_SYNTH="${EQ_SKIP_SYNTH:-1}"
    export EQ_DEEP_MAX_FILE_OFF="${EQ_DEEP_MAX_FILE_OFF:-1}"
    export EQ_DEEP_MAX_SRC_LEN="${EQ_DEEP_MAX_SRC_LEN:-512}"
    echo "eq_mode=close OFF=$EQ_MAX_FILE_OFF JOBS=$JOBS STRIDE=$EQ_FILE_STRIDE SKIP_SYNTH=$EQ_SKIP_SYNTH DEEP_CAP=$EQ_DEEP_MAX_FILE_OFF DEEP_SRC=$EQ_DEEP_MAX_SRC_LEN (target eq ~3min; L2 total ≤10min)"
    build_harness
    run_shards "$JOBS" "${FILES[@]}"
    ;;
  full)
    # Pin-bump / L4 only — never the soft-knife micro-wave gate.
    unset EQ_ONLY || true
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-128}"
    JOBS="${EQ_JOBS:-$(default_jobs)}"
    export EQ_FILE_STRIDE="${EQ_FILE_STRIDE:-1}"
    # full keeps synth + no deep_cap unless caller sets them.
    echo "eq_mode=full OFF=$EQ_MAX_FILE_OFF JOBS=$JOBS STRIDE=$EQ_FILE_STRIDE (pin/L4 only)"
    build_harness
    run_shards "$JOBS" "${FILES[@]}"
    ;;
  *)
    echo "usage: $0 daily <substrs> | $0 close | $0 full" >&2
    exit 2
    ;;
esac
