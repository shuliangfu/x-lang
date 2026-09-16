#!/usr/bin/env bash
# CORE-012: core.debug assert type-extend gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + soft auto-make xlang-c +
# check SKIP narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o tests/debug/assert_extend.x exit0 = hard run;
# check = obs. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-debug-assert-extend-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-debug-assert-extend.sh
. tests/lib/core-debug-assert-extend.sh

DOC="${XLANG_CORE_DEBUG_ASSERT_EXTEND_DOC:-analysis/archive/core/core-debug-assert-extend-v1.md}"
MANIFEST="${XLANG_CORE_DEBUG_ASSERT_EXTEND_TSV:-tests/baseline/core-debug-assert-extend.tsv}"
DEBUG_X="core/debug/mod.x"
LIB="tests/lib/core-debug-assert-extend.sh"
SMOKE="tests/debug/assert_extend.x"
REGRESS="tests/debug/main.x"
MIN_SYMBOLS=6
SMOKE_EXPECT=0

PREFIX="${XLANG_CORE_DEBUG_ASSERT_EXTEND_PREFIX:-xlang: [XLANG_CORE_DEBUG_ASSERT_EXTEND]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-debug-assert-extend gate FAIL: $*" >&2
  core_debug_assert_extend_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== CORE-012: debug assert extend (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
if [ -f analysis/core-debug-assert-extend-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$DEBUG_X" "$SMOKE" "$REGRESS"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in assert_eq_u64 assert_eq_ptr assert_ne_bool panic; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-debug-assert-extend FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMBOLS" ] || [ "$MISS" -gt 0 ]; then
  die "symbols=${SYM_N} miss=${MISS}"
fi

sym_miss="$(core_debug_assert_extend_symbols_ok "$DEBUG_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-debug-assert-extend manifest OK (symbols=${SYM_N})"

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
  echo "core-debug-assert-extend OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_debug_assert_extend_$$"
trap 'rm -f "$exe"' EXIT
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_core_debug_assert_extend_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_debug_assert_extend_o.log 2>/dev/null || true
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$run_ec (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))

core_debug_assert_extend_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-debug-assert-extend gate OK"
ok_report
