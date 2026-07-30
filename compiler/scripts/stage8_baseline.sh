#!/usr/bin/env bash
# stage8_baseline.sh — stage-8 size / perf baseline phonies (size-baseline · perf-baseline)
#
# Authority (G.7 有则补全 / 无才新增):
#   Measurement body already lives in tests/run-size-baseline.sh and
#   tests/run-perf-baseline.sh (single authority). Historic dual body lived
#   inline in Makefile as if/chmod/cd/XLANG wrappers around those scripts.
#   This shell owns only the make-cwd → repo-root dispatch + historic soft
#   skip when the tests script is missing (same soft semantics as make).
#
#   What this owns:
#     1) Resolve repo root from compiler/ cwd
#     2) Require tests/run-{size,perf}-baseline.sh (or soft-skip if absent)
#     3) Exec the measurement script with remaining args
#
#   Why shell-primary (not physical delete)?
#     Optional stage-8 CI phonies still hang off make graph; product cold path
#     does not need them. Swallowing Makefile dual wrappers is residual S1.4.
#
# Usage (cwd = compiler/):
#   bash scripts/stage8_baseline.sh size
#   bash scripts/stage8_baseline.sh perf [--bench]
#   bash scripts/stage8_baseline.sh --check
#
# wave875 (G.7 有则补全): Makefile fat if/chmod/XLANG body → this script.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI / product binary selection stays
#   inside tests/run-*-baseline.sh.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"
shift || true

log() { echo "stage8-baseline: $*" >&2; }
fail() { echo "stage8-baseline: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  for phony in size-baseline perf-baseline; do
    _rec=$(awk -v t="$phony" '
      $0 ~ ("^" t ":") { hit=1; next }
      hit && /^[^[:space:]#]/ { exit }
      hit && /^\t/ { print }
    ' "$MF")
    if ! grep -q 'stage8_baseline\.sh' <<<"$_rec"; then
      fail "$phony must thin-call stage8_baseline.sh (wave875)"
    fi
    # Dual body: inline if/chmod/cd/XLANG wrappers (shell owns dispatch).
    if grep -qE 'run-size-baseline|run-perf-baseline|chmod \+x tests/' <<<"$_rec"; then
      fail "$phony must not keep dual tests/run-*-baseline body (wave875; shell owns)"
    fi
    if grep -qE 'if \[ -f \.\./tests/' <<<"$_rec"; then
      fail "$phony must not keep dual if-file gate body (wave875; shell owns)"
    fi
  done
  ROOT="$(cd .. && pwd)"
  [ -f "$ROOT/tests/run-size-baseline.sh" ] || fail "missing $ROOT/tests/run-size-baseline.sh (measurement authority)"
  [ -f "$ROOT/tests/run-perf-baseline.sh" ] || fail "missing $ROOT/tests/run-perf-baseline.sh (measurement authority)"
  echo "stage8_baseline: --check OK (wave875; shell-primary size+perf; not physical delete)"
  exit 0
fi

case "$MODE" in
  size)
    SCRIPT_NAME=run-size-baseline.sh
    ;;
  perf)
    SCRIPT_NAME=run-perf-baseline.sh
    ;;
  *)
    echo "usage: $0 {size|perf|--check} [args...]" >&2
    exit 2
    ;;
esac

ROOT="$(cd .. && pwd)"
SCRIPT="$ROOT/tests/$SCRIPT_NAME"

# Historic make soft-skip: missing script → no-op success (optional stage-8).
if [ ! -f "$SCRIPT" ]; then
  log "SKIP: missing $SCRIPT (optional stage-8 baseline)"
  exit 0
fi

chmod +x "$SCRIPT" 2>/dev/null || true
# Measurement authority owns XLANG defaults (xlang / xlang-c); do not re-pin here.
cd "$ROOT"
exec bash "./tests/$SCRIPT_NAME" "$@"
