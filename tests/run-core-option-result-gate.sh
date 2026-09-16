#!/usr/bin/env bash
# CORE-002/003: Option/Result combinators gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make xlang-c +
# check SKIP narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o option exit102 + result exit173 = hard run;
# check = obs. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-option-result-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-option-result.sh
. tests/lib/core-option-result.sh

DOC="${XLANG_CORE_OR_DOC:-analysis/archive/core/core-option-result-combinators-v1.md}"
MANIFEST="${XLANG_CORE_OR_TSV:-tests/baseline/core-option-result.tsv}"
OPTION_X="core/option/mod.x"
RESULT_X="core/result/mod.x"
LIB="tests/lib/core-option-result.sh"
OPTION_SMOKE="tests/option/main.x"
RESULT_SMOKE="tests/result/main.x"
OPTION_EXPECT=102
RESULT_EXPECT=173

PREFIX="${XLANG_CORE_OPTION_RESULT_PREFIX:-xlang: [XLANG_CORE_OPTION_RESULT]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-option-result gate FAIL: $*" >&2
  core_or_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

echo "=== CORE-002/003: Option/Result (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
if [ -f analysis/core-option-result-combinators-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$OPTION_X" "$RESULT_X" "$OPTION_SMOKE" "$RESULT_SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in eager EXC-001 Option_ptr_u8 Result_u8 or_else_i32; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(core_or_symbols_ok "$OPTION_X" "$RESULT_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-option-result manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$OPTION_SMOKE" >/dev/null 2>&1
chk_opt=$?
"$XLANG_BIN" check -L . "$RESULT_SMOKE" >/dev/null 2>&1
chk_res=$?
set -e
if [ "$chk_opt" -ne 0 ] || [ "$chk_res" -ne 0 ]; then
  echo "core-option-result OBS check (paused / CHK residual opt=$chk_opt res=$chk_res; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

opt_exe="/tmp/xlang_core_or_option_$$"
res_exe="/tmp/xlang_core_or_result_$$"
trap 'rm -f "$opt_exe" "$res_exe"' EXIT

set +e
"$XLANG_BIN" -L . "$OPTION_SMOKE" -o "$opt_exe" >/tmp/xlang_core_or_option_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$opt_exe" ]; then
  tail -n 12 /tmp/xlang_core_or_option_o.log 2>/dev/null || true
  die "product -o option failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$opt_exe" >/dev/null 2>&1
opt_ec=$?
set -e
rm -f "$opt_exe"
[ "$opt_ec" -eq "$OPTION_EXPECT" ] || die "option exit=$opt_ec (expect $OPTION_EXPECT)"
RUN_OK=$((RUN_OK + 1))

set +e
"$XLANG_BIN" -L . "$RESULT_SMOKE" -o "$res_exe" >/tmp/xlang_core_or_result_o.log 2>&1
r_ec=$?
set -e
if [ "$r_ec" -ne 0 ] || [ ! -x "$res_exe" ]; then
  tail -n 12 /tmp/xlang_core_or_result_o.log 2>/dev/null || true
  die "product -o result failed (ec=$r_ec; refuse soft SKIP→OK)"
fi
set +e
"$res_exe" >/dev/null 2>&1
res_ec=$?
set -e
rm -f "$res_exe"
[ "$res_ec" -eq "$RESULT_EXPECT" ] || die "result exit=$res_ec (expect $RESULT_EXPECT)"
RUN_OK=$((RUN_OK + 1))

core_or_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-option-result gate OK"
ok_report
