#!/usr/bin/env bash
# CORE-007: core.str BytesView gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make xlang-c +
# check SKIP narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o bytes_view.x exit0 + cookbook core_str_index
# exit0 = hard run; check = obs. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-str-view-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-str-view.sh
. tests/lib/core-str-view.sh

DOC="${XLANG_CORE_STR_DOC:-analysis/archive/core/core-str-view-v1.md}"
STD_DOC="${XLANG_STD_STRVIEW_DOC:-analysis/archive/std/std-strview-zc4-v1.md}"
MANIFEST="${XLANG_CORE_STR_TSV:-tests/baseline/core-str-view.tsv}"
STR_X="core/str/mod.x"
LIB="tests/lib/core-str-view.sh"
SMOKE="tests/str/bytes_view.x"
COOKBOOK="examples/cookbook/core_str_index.x"
COOKBOOK_EXPECT=0

PREFIX="${XLANG_CORE_STR_VIEW_PREFIX:-xlang: [XLANG_CORE_STR_VIEW]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-str-view gate FAIL: $*" >&2
  core_str_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== CORE-007: core.str BytesView (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
if [ -f analysis/core-str-view-v1.md ] || [ -f analysis/std-strview-zc4-v1.md ]; then
  die "top-level DOC resurrected (live = archive/)"
fi
for f in "$DOC" "$STD_DOC" "$MANIFEST" "$LIB" "$STR_X" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in BytesView StrView bytes_view_subview 生命周期 Cookbook core_str_index; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(core_str_symbols_ok "$STR_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-str-view manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Observational check (paused) — never soft SKIP→OK / never soft auto-make.
set +e
"$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "core-str-view OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_str_view_$$"
trap 'rm -f "$exe"' EXIT
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_core_str_view_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_str_view_o.log 2>/dev/null || true
  die "product -o smoke failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq 0 ] || die "smoke runnable exit=$run_ec"
RUN_OK=$((RUN_OK + 1))

# Cookbook: product unique-UNDEF fire (index_of / starts_with); success score 0.
cb_exe="/tmp/xlang_core_str_view_cb_$$"
trap 'rm -f "$exe" "$cb_exe"' EXIT
set +e
"$XLANG_BIN" -L . "$COOKBOOK" -o "$cb_exe" >/tmp/xlang_core_str_view_cb_o.log 2>&1
cb_o_ec=$?
set -e
if [ "$cb_o_ec" -ne 0 ] || [ ! -x "$cb_exe" ]; then
  tail -n 12 /tmp/xlang_core_str_view_cb_o.log 2>/dev/null || true
  die "product -o cookbook failed (ec=$cb_o_ec; refuse soft SKIP→OK)"
fi
set +e
"$cb_exe" >/dev/null 2>&1
cb_ec=$?
set -e
rm -f "$cb_exe"
[ "$cb_ec" -eq "$COOKBOOK_EXPECT" ] || die "cookbook exit=$cb_ec (expect $COOKBOOK_EXPECT)"
RUN_OK=$((RUN_OK + 1))

core_str_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-str-view gate OK"
ok_report
