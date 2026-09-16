#!/usr/bin/env bash
# STD-131: core.str BytesView find/split gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make xlang-c +
# check SKIP narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o find_split.x exit0 = hard run; check = obs.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-str-find-split-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-str-find-split.sh
. tests/lib/core-str-find-split.sh

DOC="${XLANG_CORE_STR_FIND_SPLIT_DOC:-analysis/archive/core/core-str-find-split-v1.md}"
MANIFEST="tests/baseline/core-str-find-split-manifest.tsv"
MOD_X="core/str/mod.x"
LIB="tests/lib/core-str-find-split.sh"
SMOKE_X="tests/str/find_split.x"
SMOKE_EXPECT=0

PREFIX="${XLANG_STD131_CORE_STR_FIND_SPLIT_PREFIX:-xlang: [XLANG_STD131_CORE_STR_FIND_SPLIT]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-str-find-split gate FAIL: $*" >&2
  core_str_find_split_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-131: core.str find/split (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
if [ -f analysis/core-str-find-split-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qF STD-131 "$DOC" || die "doc missing STD-131"

sym_miss="$(core_str_find_split_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-str-find-split manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "core-str-find-split OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_str_find_split_$$"
trap 'rm -f "$exe"' EXIT
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$exe" >/tmp/xlang_core_str_find_split_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_str_find_split_o.log 2>/dev/null || true
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$run_ec (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))

core_str_find_split_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-str-find-split gate OK"
ok_report
