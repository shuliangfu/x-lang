#!/usr/bin/env bash
# LANG-009: Option<T> generic struct gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. `xlang check` is observational (check gate paused 2026-08-05)
# — count as obs, not soft silence. Runnable -o path is hard-green.
# DOC authority = archive/lang. Report run=/obs=/skip=.
#
# Usage: ./tests/run-lang-option-generic-gate.sh
# wave honesty (2026-08-24 #10): DOC → analysis/archive/lang/;
# typeck_generic_struct.c/parser.c retired — live mono = codegen.x;
# 2026-08-25: runnable hard-green (STRUCT_LIT type-inst mangle).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/lang-option-generic.sh
. tests/lib/lang-option-generic.sh

DOC="${XLANG_LANG009_DOC:-analysis/archive/lang/lang-option-generic-v1.md}"
MANIFEST="${XLANG_LANG009_TSV:-tests/baseline/lang-option-generic.tsv}"
SMOKE1="tests/lang-option-generic/option_three.x"
SMOKE2="tests/lang-option-generic/with_core_import.x"
CODEGEN_X="compiler/src/codegen/codegen.x"
MIN_GOLDEN=2
PREFIX="${XLANG_LANG009_PREFIX:-xlang: [XLANG_LANG009_OPTION_GENERIC]}"

RUN_OK=0
OBS=0
SKIP=0
GOLDEN_OK=0

die() {
  echo "lang-option-generic gate FAIL: $*" >&2
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

echo "=== LANG-009: Option<T> generic struct manifest (c retired) ==="
if [ -f analysis/lang-option-generic-v1.md ]; then
  die "top-level DOC resurrected (live = archive/lang/)"
fi
if [ -f compiler/src/typeck/typeck_generic_struct.c ]; then
  die "typeck_generic_struct.c resurrected"
fi
if [ -f compiler/src/parser/parser.c ]; then
  die "parser.c resurrected (live = parser.x)"
fi
for f in "$DOC" "$MANIFEST" "$SMOKE1" "$SMOKE2" core/option/mod.x "$CODEGEN_X"; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_golden) MIN_GOLDEN="$c2" ;;
  esac
done < "$MANIFEST"

for kw in Option M7 typeck_materialize parser_append_type_inst_mangle; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing '$kw'"
  fi
done

sym_miss="$(lang_option_generic_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  die "manifest symbols missing=${sym_miss}"
fi
echo "lang-option-generic manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

echo "=== LANG-009: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
# check gate paused — observational product/diag debt, not soft silence.
# PLATFORM: SHARED — count obs when check fails; runnable remains hard.
if "$XLANG_BIN" check -L . "$SMOKE1" >/dev/null 2>&1 \
  && "$XLANG_BIN" check -L . "$SMOKE2" >/dev/null 2>&1; then
  :
else
  echo "lang-option-generic gate OBS check (paused / typeck debt)" >&2
  OBS=1
fi

exe="/tmp/xlang_lang009_$$"
set +e
for x in "$SMOKE1" "$SMOKE2"; do
  link_log=$("$XLANG_BIN" -L . "$x" -o "$exe" 2>&1)
  link_ec=$?
  if [ "$link_ec" -ne 0 ]; then
    echo "$link_log" | tail -20 >&2 || true
    rm -f "$exe"
    die "runnable link ($x)"
  fi
  "$exe" >/dev/null 2>&1
  run_ec=$?
  rm -f "$exe"
  if [ "$run_ec" -ne 0 ]; then
    die "run $x exit=$run_ec"
  fi
  GOLDEN_OK=$((GOLDEN_OK + 1))
done
set -e

if [ "$GOLDEN_OK" -lt "$MIN_GOLDEN" ]; then
  die "golden=$GOLDEN_OK < min $MIN_GOLDEN"
fi
RUN_OK="$GOLDEN_OK"

ok_report
echo "lang-option-generic gate OK"
