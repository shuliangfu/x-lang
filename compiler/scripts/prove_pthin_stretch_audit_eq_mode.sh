#!/bin/bash
# prove_pthin_stretch_audit_eq_mode.sh — B-minus eq wall-clock modes
#
# Usage:
#   bash scripts/prove_pthin_stretch_audit_eq_mode.sh daily [substr,substr,...]
#   bash scripts/prove_pthin_stretch_audit_eq_mode.sh full
#
# daily — EQ_ONLY filter (default: pass comma substrings of THIS wave's new
#         exports). Optional EQ_SKIP_SYNTH=1. Typical: <2 min for ~8 cases.
# full  — clear EQ_ONLY; EQ_MAX_FILE_OFF=128 (wave-close / pin-bump gate).
#         Dual-end (~50 min/host). Do NOT run full on every micro soft-knife.
#
# PLATFORM: SHARED — same script on Darwin and Ubuntu.
set -eu
cd "$(dirname "$0")/.."

MODE=${1:-}
shift || true

case "$MODE" in
  daily)
    if [ "$#" -lt 1 ] || [ -z "${1:-}" ]; then
      echo "usage: $0 daily <EQ_ONLY substrings comma-separated>" >&2
      exit 2
    fi
    export EQ_ONLY="$1"
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-128}"
    # Keep synth by default for small delta sets; opt-in skip via env.
    echo "eq_mode=daily EQ_ONLY=$EQ_ONLY EQ_MAX_FILE_OFF=$EQ_MAX_FILE_OFF EQ_SKIP_SYNTH=${EQ_SKIP_SYNTH:-0}"
    exec bash scripts/prove_pthin_stretch_audit_eq.sh
    ;;
  full)
    unset EQ_ONLY || true
    unset EQ_SKIP_SYNTH || true
    export EQ_MAX_FILE_OFF="${EQ_MAX_FILE_OFF:-128}"
    echo "eq_mode=full EQ_ONLY=(all) EQ_MAX_FILE_OFF=$EQ_MAX_FILE_OFF"
    exec bash scripts/prove_pthin_stretch_audit_eq.sh
    ;;
  *)
    echo "usage: $0 daily <substrs> | $0 full" >&2
    exit 2
    ;;
esac
