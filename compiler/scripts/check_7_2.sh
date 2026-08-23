#!/usr/bin/env bash
# check_7_2.sh — seed-path two-stage smoke (Makefile phony check-7.2)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for Makefile phony check-7.2.
#   Historic dual body lived inline in Makefile (cp stage → TARGET + six
#   smoke scripts per stage).
#
#   Related but NOT the same authority as bootstrap_verify_bstrict.sh:
#     - check-7.2        → $(TARGET)_stage1 / $(TARGET)_stage2 after bootstrap-self
#     - check-7.2-bstrict → xlang_asm_stage1 / xlang_asm2 after B-strict path
#   Suites also differ (seed path includes return-value + hello). Do not merge
#   into bootstrap_verify_bstrict without a deliberate redesign of both phonies.
#
#   What this owns:
#     1) For each stage binary TARGET_stage1 / TARGET_stage2:
#        - require executable stage
#        - cp stage → ./TARGET (legacy Makefile behavior for tools that read TARGET)
#        - run return-value / hello / lexer / typeck / vec-map-heap / parser-typeck dogfood
#     2) Print historical OK line for make / CI consumers
#
#   Why shell-primary (not physical delete)?
#     bootstrap-self prereq + leaf .o graph still make residual; this is only
#     the multi-stage smoke orchestration body.
#
# Usage (cwd = compiler/):
#   bash scripts/check_7_2.sh
#   bash scripts/check_7_2.sh --check
#
# Env:
#   TARGET — product binary name (default: xlang); stages are ${TARGET}_stage1/2
#            Makefile keeps bootstrap-self as prereq so stages should exist.
#
# wave870 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in product stages / tests.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"

log() { echo "check-7.2: $*" >&2; }
fail() { echo "check-7.2: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^check-7\.2:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'check_7_2\.sh' <<<"$_rec"; then
    fail "check-7.2 must thin-call check_7_2.sh (wave870)"
  fi
  # Dual body signals: inline stage loop / smoke scripts
  if grep -qE 'run-return-value\.sh|run-hello\.sh|run-lexer\.sh|run-typeck\.sh|run-bootstrap-semantic-smoke|run-bootstrap-stage2-dogfood' <<<"$_rec"; then
    fail "check-7.2 must not keep dual inline smoke suite (wave870; shell owns suite)"
  fi
  if grep -qE '_stage1|_stage2|check-7\.2 FAIL|check-7\.2 OK' <<<"$_rec"; then
    fail "check-7.2 must not keep dual stage loop / OK lines (wave870)"
  fi
  echo "check_7_2: --check OK (wave870; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path (seed-path two-stage smoke · historic Makefile check-7.2)
# ---------------------------------------------------------------------------
ROOT="$(pwd)/.."
CDIR="$(pwd)"

for ST in "${TARGET}_stage1" "${TARGET}_stage2"; do
  if [ ! -x "$CDIR/$ST" ]; then
    fail "missing executable $ST (run bash scripts/bootstrap_self.sh first)"
  fi
  cp "$CDIR/$ST" "$CDIR/$TARGET"
  (
    cd "$ROOT" &&
      XLANG="$CDIR/$ST" ./tests/run-return-value.sh &&
      XLANG="$CDIR/$ST" ./tests/run-hello.sh &&
      XLANG="$CDIR/$ST" ./tests/run-lexer.sh &&
      XLANG="$CDIR/$ST" ./tests/run-typeck.sh &&
      XLANG="$CDIR/$ST" ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh &&
      XLANG="$CDIR/$ST" ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
  ) || {
    fail "$ST"
  }
done

echo "check-7.2 OK (both stages: return-value, hello, lexer, typeck, vec/map/heap + parser/typeck dogfood)"
