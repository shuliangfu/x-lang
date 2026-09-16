#!/usr/bin/env bash
# STD-060: std.sort stable + custom cmp gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# stable_i32.x + cmp_desc.x -o exit0 = hard run (run=2). check / host-C
# archaeology = obs. Report: run=/obs=/skip=. G.7: complete existing
# resolve_shu; drop unused compiler-make.sh.
# Fossil API → product: stable / cmp / cmp_desc_fn.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sort-stable-cmp-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SORT_STABLE_CMP_DOC:-analysis/archive/std/std-sort-stable-cmp-v1.md}"
MANIFEST="${XLANG_STD_SORT_STABLE_CMP_TSV:-tests/baseline/std-sort-stable-cmp.tsv}"
VECTORS="${XLANG_STD_SORT_STABLE_CMP_VECTORS:-tests/baseline/std-sort-stable-cmp-vectors.tsv}"
MOD_X="std/sort/mod.x"
SORT_X="std/sort/sort.x"
LIB="tests/lib/std-sort-stable-cmp.sh"
SMOKE_STABLE="tests/std-sort/stable_i32.x"
SMOKE_CMP="tests/std-sort/cmp_desc.x"
SMOKE_C="tests/std-sort/stable_smoke_ok.c"
SMOKE_EXPECT=0
MIN_APIS=3

# shellcheck source=tests/lib/std-sort-stable-cmp.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sort-stable-cmp gate FAIL: $*" >&2
  std_sort_stable_cmp_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-060: sort stable/cmp manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SORT_X" "$SMOKE_STABLE" "$SMOKE_CMP" "$SMOKE_C" std/sort/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-060 stable usize stable_dup; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- 'cmp_desc' "$VECTORS" 2>/dev/null || die "vectors missing cmp_desc"
grep -qF -- 'stable' std/sort/README.md 2>/dev/null || die "README missing stable"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF -- "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"
[ ! -f std/sort/sort.c ] || die "sort.c should be deleted"

sym_miss="$(std_sort_stable_cmp_symbols_ok "$MOD_X" "$SORT_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sort-stable-cmp manifest OK"

if [ "${XLANG_STD_SORT_STABLE_CMP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sort_stable_cmp_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sort-stable-cmp gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-060: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

# Host-C archaeology = obs only; refuse soft ensure_std rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if [ -f std/sort/sort.o ] && std_sort_stable_cmp_run_c_smoke "$SORT_X"; then
  echo "std-sort-stable-cmp c smoke OK (observational)"
else
  echo "std-sort-stable-cmp OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_STABLE" >/tmp/xlang_std_sort_stable_check_a.log 2>&1
chk_a=$?
"$XLANG_BIN" check -L . "$SMOKE_CMP" >/tmp/xlang_std_sort_stable_check_b.log 2>&1
chk_b=$?
set -e
if [ "$chk_a" -ne 0 ] || [ "$chk_b" -ne 0 ]; then
  echo "std-sort-stable-cmp OBS check (paused / CHK residual a=$chk_a b=$chk_b; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

for x in "$SMOKE_STABLE" "$SMOKE_CMP"; do
  tag="$(basename "$x" .x)"
  OUT="/tmp/xlang_std_sort_stable_${tag}_$$"
  LOG="/tmp/xlang_std_sort_stable_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$x" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $x failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable $x exit=$exitcode (expect $SMOKE_EXPECT)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-sort-stable-cmp OK: product -o $tag"
done

std_sort_stable_cmp_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sort-stable-cmp gate OK"
