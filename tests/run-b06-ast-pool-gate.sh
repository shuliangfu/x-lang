#!/usr/bin/env bash
# B-06: AST Arena / pool-limit boundary gate — honesty soft→硬绿.
#
# wave309: compiler/ast_pool.c left — do NOT hard-require the deleted mega shell
# (sit-red forever / dual-authority if resurrected). Live pool/arena authority:
#   compiler/src/runtime_pipeline_abi.x  (ast_pool_* freestanding APIs,
#   pipe_en_max_variants, grow pools)
# plus parser.x call sites and tests/run-pool-limits.sh behavioral matrix.
#
# Honesty: soft default `./compiler/xlang-c` + soft SKIP→OK when no runnable
# xlang (prefer-c / portable false-green) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: live ABI anchors + deleted mega shell stay deleted
#   - hard: pool-limits product matrix (delegated; reports run=/obs=/skip=)
# Report: run=/obs=/skip= (merged from pool-limits)
# Usage: ./tests/run-b06-ast-pool-gate.sh
# PLATFORM: SHARED archaeology honesty (bootstrap-bstrict-ci still invokes).
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_B06_PREFIX:-xlang: [XLANG_B06_AST_POOL]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "b06-ast-pool FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== B-06: pool limits / live arena authority (prefer asm; hard/obs) ==="
LIVE_ABI="compiler/src/runtime_pipeline_abi.x"
for f in "$LIVE_ABI" tests/run-pool-limits.sh; do
  [ -f "$f" ] || die "missing $f"
done

# Live freestanding pool API must remain callable from parser (G.7).
grep -q 'ast_pool_' compiler/src/parser/parser.x || \
  die "parser.x missing ast_pool_* refs (live freestanding pool API)"
RUN_OK=$((RUN_OK + 1))

# Cap authority lives in runtime_pipeline_abi (historical MODULE_ENUM_MAX twin).
grep -q 'pipe_en_max_variants' "$LIVE_ABI" || \
  die "$LIVE_ABI missing pipe_en_max_variants"
RUN_OK=$((RUN_OK + 1))

# Honesty: deleted mega shell must stay deleted (no resurrected fossil).
if [ -f compiler/ast_pool.c ]; then
  die "compiler/ast_pool.c resurrected (wave309 left; dual authority)"
fi
RUN_OK=$((RUN_OK + 1))

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

chmod +x tests/run-pool-limits.sh
set +e
pool_out=$(XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" bash tests/run-pool-limits.sh 2>&1)
pool_ec=$?
set -e
echo "$pool_out"
# Merge run=/obs=/skip= from pool-limits report line when present.
if echo "$pool_out" | grep -qE 'status=(ok|fail).*run='; then
  _rep=$(echo "$pool_out" | grep -E 'status=(ok|fail).*run=' | tail -1)
  _r=$(echo "$_rep" | sed -n 's/.*run=\([0-9]*\).*/\1/p')
  _o=$(echo "$_rep" | sed -n 's/.*obs=\([0-9]*\).*/\1/p')
  _s=$(echo "$_rep" | sed -n 's/.*skip=\([0-9]*\).*/\1/p')
  RUN_OK=$((RUN_OK + ${_r:-0}))
  OBS=$((OBS + ${_o:-0}))
  SKIP=$((SKIP + ${_s:-0}))
fi
[ "$pool_ec" -eq 0 ] || die "pool-limits failed (ec=$pool_ec)"

echo "b06 ast-pool gate OK"
ok_report
