#!/usr/bin/env bash
# check_6_4.sh — seed-path return-value=42 smoke (Makefile phony check-6.4)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for Makefile phony check-6.4.
#   Historic dual body lived inline in Makefile:
#     make bootstrap-driver-seed
#       && ./TARGET return-value -o /tmp/check64.c
#       && $(CC) $(CFLAGS) -o /tmp/check64 /tmp/check64.c
#       && /tmp/check64; [ $? -eq 42 ]
#
#   What this owns:
#     1) Require executable TARGET (seed path; Makefile keeps
#        bootstrap-driver-seed as prereq so TARGET should exist)
#     2) Emit C via seed-style -o (writes .c, not host Mach-O/ELF)
#     3) Host-cc link the emitted C → /tmp/check64
#     4) Run binary; require exit status 42
#     5) Print historical OK line for make / CI consumers
#
#   Why shell-primary (not physical delete)?
#     bootstrap-driver-seed prereq + leaf .o graph still make residual; this is
#     only the 6.4 acceptance smoke orchestration body.
#
#   Related but NOT the same as:
#     - tests/run-return-value.sh (product -o binary path; may not use seed C emit)
#     - check-7.2 / check_7_2.sh (two-stage stage1/stage2 suite)
#   Do not merge without deliberate redesign of both phonies.
#
# Usage (cwd = compiler/):
#   bash scripts/check_6_4.sh
#   bash scripts/check_6_4.sh --check
#
# Env:
#   TARGET — product binary name (default: xlang)
#   CC     — host C compiler (default: cc)
#   CFLAGS — host C flags for linking emitted C (default: empty; optional)
#   XLANG_CHECK64_C / XLANG_CHECK64_BIN — paths (defaults under /tmp)
#
# wave871 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in product TARGET / host cc.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
CC="${CC:-cc}"
CFLAGS="${CFLAGS-}"
CHECK64_C="${XLANG_CHECK64_C:-/tmp/check64.c}"
CHECK64_BIN="${XLANG_CHECK64_BIN:-/tmp/check64}"

log() { echo "check-6.4: $*" >&2; }
fail() { echo "check-6.4: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^check-6\.4:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'check_6_4\.sh' <<<"$_rec"; then
    fail "check-6.4 must thin-call check_6_4.sh (wave871)"
  fi
  # Dual body signals: inline seed rebuild / emit-C / host-cc / exit 42
  if grep -qE 'bootstrap-driver-seed|return-value/main\.x|/tmp/check64|check-6\.4 OK' <<<"$_rec"; then
    fail "check-6.4 must not keep dual inline smoke body (wave871; shell owns suite)"
  fi
  echo "check_6_4: --check OK (wave871; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path (seed-path return-value=42 · historic Makefile check-6.4)
# ---------------------------------------------------------------------------
if [ ! -x "./$TARGET" ]; then
  fail "missing executable ./$TARGET (run make bootstrap-driver-seed first)"
fi

# Seed path: -o writes C source (not a native binary). Host cc then links.
rm -f "$CHECK64_C" "$CHECK64_BIN"
./"$TARGET" ../tests/return-value/main.x -o "$CHECK64_C" \
  || fail "seed $TARGET emit C failed"
[ -s "$CHECK64_C" ] || fail "empty emit C: $CHECK64_C"

# shellcheck disable=SC2086 # CFLAGS is intentional multi-token host flags
$CC $CFLAGS -o "$CHECK64_BIN" "$CHECK64_C" \
  || fail "host-cc link failed ($CC $CFLAGS -o $CHECK64_BIN $CHECK64_C)"
[ -x "$CHECK64_BIN" ] || fail "missing linked binary $CHECK64_BIN"

set +e
"$CHECK64_BIN"
rc=$?
set -e
if [ "$rc" -ne 42 ]; then
  fail "expected exit 42, got $rc ($CHECK64_BIN)"
fi

echo "check-6.4 OK"
