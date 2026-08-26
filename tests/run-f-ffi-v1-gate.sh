#!/usr/bin/env bash
# F-ffi v1: std.ffi de-C (ffi.x; F-ZC zero C, no cb glue).
#
# Usage: ./tests/run-f-ffi-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-ffi-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-055 ffi-cstring hard delegate (embeds SAFE-004). Soft XLANG_F_FFI_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+cstring green;
# STD-151 struct-callback DOC residual observational).
# Report static=/ensure=/cstr=/struct=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-ffi-v1.md"
MANIFEST="tests/baseline/f-ffi-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_FFI_V1]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-ffi-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} cstr=${CSTR_OK:-0} struct=${STRUCT_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
CSTR_OK=0
STRUCT_OK=0
SKIP=1

echo "=== F-ffi v1: std.ffi ffi.c → ffi.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-ffi v1' "$DOC" || die "doc missing F-ffi v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/ffi/ffi.x ] || die "missing ffi.x"
[ ! -f std/ffi/ffi_cb_glue.c ] || die "ffi_cb_glue.c should be deleted (F-ZC)"
[ ! -f std/ffi/ffi.c ] || die "ffi.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"

grep -q 'ffi_cb_double_i32_fn_c' std/ffi/ffi.x || die "ffi.x missing cb fn"
grep -q 'ffi_invoke_i32_cb_c' std/ffi/ffi.x || die "ffi.x missing invoke"
grep -q 'ffi_f_zero_c_marker_c' std/ffi/ffi.x || die "ffi.x missing zero-c marker"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/ffi/ffi.o >/dev/null 2>&1 \
  || die "ensure ffi.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-055 ffi-cstring already soft→硬绿 (embeds SAFE-004); hard-delegate.
if [ -f tests/run-std-ffi-cstring-lifecycle-gate.sh ]; then
  echo "=== F-ffi v1: delegate run-std-ffi-cstring-lifecycle-gate ==="
  chmod +x tests/run-std-ffi-cstring-lifecycle-gate.sh
  if ! tests/run-std-ffi-cstring-lifecycle-gate.sh; then
    die "std-ffi-cstring sub-gate failed"
  fi
  CSTR_OK=1
fi

# STD-151 struct-callback: DOC section residual — observational only.
if [ -f tests/run-std-ffi-struct-callback-gate.sh ]; then
  echo "=== F-ffi v1: std-ffi-struct-callback (observational; DOC residual) ==="
  chmod +x tests/run-std-ffi-struct-callback-gate.sh
  if tests/run-std-ffi-struct-callback-gate.sh; then
    STRUCT_OK=1
  else
    echo "f-ffi-v1 WARN: std-ffi-struct-callback failed (observational)" >&2
    STRUCT_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} cstr=${CSTR_OK} struct=${STRUCT_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-ffi-v1 std.ffi gate OK (F-ffi v1; honesty)"
