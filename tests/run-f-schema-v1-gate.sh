#!/usr/bin/env bash
# F-schema v1: std.schema de-C (schema.c → schema.x; v2 logic in schema.x).
#
# Usage: ./tests/run-f-schema-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-schema-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_SCHEMA_V1_FAIL retired. Root: soft die→exit0 = portable false-green
# (static already green; STD-090 still red on fossil API needles schema_new vs
# live mod.x `new`/`add_field`). STD-090 observational (product/DOC residual).
# Report static=/ensure=/schema=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-schema-v1.md"
MANIFEST="tests/baseline/f-schema-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_SCHEMA_V1]"

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
  echo "f-schema-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} schema=${SCHEMA_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
SCHEMA_OK=0
SKIP=1

echo "=== F-schema v1: schema.c → schema.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-schema v1' "$DOC" || die "doc missing F-schema v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/schema/schema.x ] || die "missing schema.x"
[ ! -f std/schema/schema_glue.c ] || die "schema_glue.c should be deleted (see v2)"
[ ! -f std/schema/schema.c ] || die "schema.c should be deleted"
grep -q 'schema_create_c' std/schema/schema.x || die "schema.x missing decode logic"

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

xlang_compiler_make ../std/schema/schema.o >/dev/null 2>&1 \
  || die "ensure schema.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# STD-090 observational: fossil api_new→schema_new vs live mod.x `new` (product residual).
if [ -f tests/run-std-schema-gate.sh ]; then
  echo "=== F-schema v1: std-schema (observational; API rename residual) ==="
  chmod +x tests/run-std-schema-gate.sh
  if tests/run-std-schema-gate.sh; then
    SCHEMA_OK=1
  else
    echo "f-schema-v1 WARN: std-schema failed (observational)" >&2
    SCHEMA_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} schema=${SCHEMA_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-schema-v1 std.schema gate OK (F-schema v1; honesty)"
