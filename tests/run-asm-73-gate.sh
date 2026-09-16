#!/usr/bin/env bash
# asm compute: 8× binop + vector-var + call-inline (same set as
# run-pre-push-p0 / bstrict-ci). Nested children already honesty-closed.
#
# Honesty: leftover `ensure-compiler-seed.sh` auto-make
# (`bootstrap-driver-seed` if compiler/xlang missing) retired. Nested
# run-asm-binop-* / run-asm-vector-var / run-asm-call-inline already
# honesty-closed (resolve_shu / prefer-asm / explicit-bad hard-die).
# G.7: complete existing nested resolve_shu; do not fork a third resolver
# in this host. Explicit-bad caller XLANG hard-dies via parent
# dod_native_exe before nesting. Missing native still FAIL (nested).
# Report: run=/obs=/skip=. Keep `asm compute gate OK`.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: XLANG=./compiler/xlang_asm ./tests/run-asm-73-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="xlang: [XLANG_ASM73]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "run-asm-73-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

scripts=(
  run-asm-binop-var.sh
  run-asm-binop-block-var.sh
  run-asm-binop-stack-spill.sh
  run-asm-binop-cfg-merge.sh
  run-asm-binop-field-index.sh
  run-asm-binop-nested-var.sh
  run-asm-binop-index-lit.sh
  run-asm-binop-div-index.sh
  run-asm-vector-var.sh
  run-asm-call-inline.sh
)

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# ensure-compiler-seed auto-make / leftover ignore of explicit-bad).
# Unset XLANG: nested already-honesty-closed resolve_shu prefers asm.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover ensure-compiler-seed / leftover ignore of explicit-bad / leftover XLANG fallthrough / leftover SKIP→OK / soft auto-make)"
  fi
  export XLANG="$abs"
  export XLANG_LINK_XLANG="$abs"
fi

echo "=== asm compute (8× binop + vector-var + call-inline; refuse leftover ensure-compiler-seed) ==="
# Drop leftover ensure-compiler-seed auto-make. Nested gates already
# honesty-closed: explicit XLANG that is missing/non-native hard-dies;
# missing native FAIL.
for s in "${scripts[@]}"; do
  echo "=== asm compute: $s ==="
  chmod +x "./tests/$s"
  "./tests/$s" || die "nested $s failed (refuse leftover ensure-compiler-seed / leftover SKIP→OK / soft auto-make)"
  RUN_OK=$((RUN_OK + 1))
done

echo "asm compute gate OK (${#scripts[@]} scripts: 8× binop + vector-var + call-inline)"
ok_report
exit 0
