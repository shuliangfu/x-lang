#!/usr/bin/env bash
# F-elf v1: std.elf de-C (elf.x; io glue retired F-ZC).
#
# Usage: ./tests/run-f-elf-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-elf-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_ELF_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static green; STD-058 parse
# host-c smoke / elf-write still product residual — observational only).
# Report static=/ensure=/parse=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-elf-v1.md"
MANIFEST="tests/baseline/f-elf-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_ELF_V1]"

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
  echo "f-elf-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} parse=${PARSE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
PARSE_OK=0
SKIP=1

echo "=== F-elf v1: std.elf elf.c → elf.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-elf v1' "$DOC" || die "doc missing F-elf v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/elf/elf.x ] || die "missing elf.x"
[ ! -f std/elf/elf_io_glue.c ] || die "elf_io_glue.c should be deleted (F-ZC)"
[ ! -f std/elf/elf.c ] || die "elf.c should be deleted"

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
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/elf/elf.o >/dev/null 2>&1 \
  || die "ensure elf.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-058 parse: host-c smoke / product residual — observational (listed skip 复探红 / elf-write).
if [ -f tests/run-std-elf-parse-gate.sh ]; then
  echo "=== F-elf v1: std-elf-parse (observational; product residual) ==="
  chmod +x tests/run-std-elf-parse-gate.sh
  if tests/run-std-elf-parse-gate.sh; then
    PARSE_OK=1
  else
    echo "f-elf-v1 WARN: std-elf-parse failed (observational)" >&2
    PARSE_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} parse=${PARSE_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-elf-v1 std.elf gate OK (F-elf v1; honesty)"
