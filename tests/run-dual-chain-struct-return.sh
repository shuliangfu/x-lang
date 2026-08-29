#!/usr/bin/env bash
# Dual-chain struct/packed/return: seed (xlang) and B-strict (xlang_asm)
# must both pass already-honesty-closed nested run-struct /
# run-return-value / run-return-expr.
#
# Honesty: leftover unused compiler-make.sh sourced unused
# (no xlang_compiler_make; false authority that can silently rebuild)
# retired. Dual-chain purpose pins seed then asm. Nested gates already
# honesty-closed (resolve_shu / prefer-asm / explicit-bad hard-die).
# G.7: complete existing nested resolve_shu; do not fork a third resolver
# in this host. Explicit-bad caller XLANG / missing native = hard die
# (refuse leftover unused compiler-make / leftover ignore of explicit-bad
# / soft SKIP→OK / soft auto-make). Report: run=/skip=
# Usage: ./tests/run-dual-chain-struct-return.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# run-all-bstrict skips this host on non-x86_64 (existing leftover).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_DUAL_CHAIN]"
RUN_OK=0
SKIP=0
SCRIPTS=(run-struct.sh run-return-value.sh run-return-expr.sh)

die() {
  echo "run-dual-chain-struct-return FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# ignore of explicit-bad). Dual-chain still pins seed then asm.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover unused compiler-make / leftover ignore of explicit-bad / leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
  fi
fi

# Leftover skip-make env kept (nested struct subscript make is not this knife).
export XLANG_SKIP_SUBSCRIPT_MAKE=1
ulimit -s 16384 2>/dev/null || true

echo "=== dual-chain struct/packed/return (seed + xlang_asm) ==="
for chain in seed xlang_asm; do
  if [ "$chain" = "seed" ]; then
    cand="./compiler/xlang"
  else
    cand="./compiler/xlang_asm"
    # Leftover parse-smoke skip on the asm chain (existing leftover).
    export XLANG_SKIP_PARSE_SMOKE=1
  fi
  abs="$(abs_of "$cand")"
  if ! dod_native_exe "$abs"; then
    die "no native $cand (refuse leftover unused compiler-make / soft SKIP→OK / soft auto-make)"
  fi
  echo "run-dual-chain-struct-return: $chain ($abs) ..."
  # Drop leftover parent unused compiler-make. Nested gates already
  # honesty-closed: explicit XLANG that is missing/non-native hard-dies.
  for script in "${SCRIPTS[@]}"; do
    XLANG="$abs" XLANG_LINK_XLANG="$abs" "./tests/$script"
  done
  RUN_OK=$((RUN_OK + 1))
done

echo "dual-chain struct/packed/return OK (seed + xlang_asm)"
ok_report
exit 0
