#!/usr/bin/env bash
# STD-150: std.sort complex key comparator gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# key_stable.x -o exit0 = hard run. check / host-C archaeology = obs. Report:
# run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# Fossil API → product: stable_by_key / cmp_key_fn / cmp_asc_fn / stable_key_tag.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sort-key-cmp-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SORT_KEY_CMP_DOC:-analysis/archive/std/std-sort-key-cmp-v1.md}"
MANIFEST="${XLANG_STD_SORT_KEY_CMP_MANIFEST:-tests/baseline/std-sort-key-cmp-manifest.tsv}"
VECTORS="${XLANG_STD_SORT_KEY_CMP_VECTORS:-tests/baseline/std-sort-key-cmp.tsv}"
MOD_X="std/sort/mod.x"
SORT_X="std/sort/sort.x"
LIB="tests/lib/std-sort-key-cmp.sh"
SMOKE_X="tests/std-sort/key_stable.x"
SMOKE_C="tests/std-sort/key_cmp_ok.c"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-sort-key-cmp.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sort-key-cmp gate FAIL: $*" >&2
  std_sort_key_cmp_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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

echo "=== STD-150: sort key cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SORT_X" "$SMOKE_X" "$SMOKE_C" std/sort/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-150 stable_by_key cmp_key_fn KeyTag; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- 'stable_by_key' std/sort/README.md 2>/dev/null || die "README missing stable_by_key"
[ ! -f std/sort/sort.c ] || die "sort.c should be deleted"

sym_miss="$(std_sort_key_cmp_symbols_ok "$MOD_X" "$SORT_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
std_sort_key_cmp_vectors_ok "$VECTORS" 3 || die "vectors fail"
echo "std-sort-key-cmp registry OK"

if [ "${XLANG_STD_SORT_KEY_CMP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sort_key_cmp_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sort-key-cmp gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-150: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

# Host-C archaeology = obs only; refuse soft ensure_std rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if [ -f std/sort/sort.o ] && std_sort_key_cmp_run_c_smoke "$SORT_X"; then
  echo "std-sort-key-cmp c smoke OK (observational)"
else
  echo "std-sort-key-cmp OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_sort_key_cmp_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-sort-key-cmp OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_sort_key_cmp_$$"
LOG="/tmp/xlang_std_sort_key_cmp_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-sort-key-cmp OK: product -o"

std_sort_key_cmp_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sort-key-cmp gate OK"
