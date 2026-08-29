#!/usr/bin/env bash
# B-05: Codegen bootstrap MVP checklist — leftover SKIP→OK when
# xlang_asm not runnable →硬绿. Delegates leftover-now-honest
# run-asm-73-gate.sh (pointer/struct/control-flow/ABI subset).
#
# Honesty: leftover parent SKIP→OK (`xlang_asm not runnable` still
# printed `b05 codegen-mvp gate OK`) retired. Nested run-asm-73-gate.sh
# honesty-closes leftover ensure-compiler-seed auto-make; nested
# binop/vector/call-inline already honesty-closed (resolve_shu /
# prefer-asm / explicit-bad hard-die). G.7: complete existing nested
# resolve_shu; do not fork a third resolver in this host. Explicit-bad
# caller XLANG hard-dies via parent dod_native_exe before nesting.
# Missing native still FAIL (nested). Archive DOC still hard.
# Docker N/A skip=1 before resolve (TSV !docker; existing leftover).
# Report: run=/obs=/skip=. Keep `b05 codegen-mvp gate OK`.
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-b05-codegen-mvp-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_B_DOC:-analysis/archive/phase/phase-b-completion-v1.md}"
PREFIX="xlang: [XLANG_B05]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "b05 gate FAIL: $*" >&2
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

echo "=== B-05: codegen MVP (asm-73; refuse leftover SKIP→OK) ==="
[ -f "$DOC" ] || die "missing phase-b doc ($DOC)"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/phase-b-completion-v1.md ] || die "dual-authority fossil analysis/phase-b-completion-v1.md (archive live)"

# PLATFORM: SHARED — Docker N/A skip=1 before resolve (TSV !docker;
# bootstrap-repro policy). Existing leftover, like linux-* Darwin N/A.
if [ -f /.dockerenv ] || [ -n "${XLANG_CI_DOCKER:-}" ]; then
  echo "b05 gate SKIP asm-73 inside Docker (bootstrap-repro policy)"
  SKIP=1
  echo "b05 codegen-mvp gate OK"
  ok_report
  exit 0
fi

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad). Unset XLANG: nested
# already-honesty-closed run-asm-73-gate.sh resolve_shu prefers asm.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover SKIP→OK / leftover ignore of explicit-bad / leftover XLANG fallthrough / leftover ensure-compiler-seed / soft auto-make)"
  fi
  export XLANG="$abs"
  export XLANG_LINK_XLANG="$abs"
fi

chmod +x tests/run-asm-73-gate.sh
# Drop leftover SKIP→OK when xlang_asm not runnable. Nested gate
# honesty-closes leftover ensure-compiler-seed: explicit XLANG that is
# missing/non-native hard-dies; missing native FAIL.
./tests/run-asm-73-gate.sh || die "nested asm-73 failed (refuse leftover SKIP→OK / leftover ensure-compiler-seed / soft auto-make)"
RUN_OK=$((RUN_OK + 1))

echo "b05 codegen-mvp gate OK"
ok_report
exit 0
