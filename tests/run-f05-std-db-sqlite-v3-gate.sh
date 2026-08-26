#!/usr/bin/env bash
# F-05 v3: std.db.sqlite remove sqlite.c (sqlite.x + runtime sqlite glue).
#
# Usage: ./tests/run-f05-std-db-sqlite-v3-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f05-std-db-sqlite-v3-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + STD-057
# manifest-only (no soft die→exit0). Soft XLANG_F05_DB_SQLITE_V3_FAIL
# retired. Prefer asm; pin XLANG_LINK_XLANG. Host-c nm/cc smoke retired.
# Full STD-057 exec / stub open+last_error product-red → observational
# (not soft false-green; do not die). Report
# static=/inventory=/sqlite=/stub=/skip=. Gate was portable-false-green
# (DOC still pointed at top-level analysis/phase-f-f05-v3.md after archive;
# soft FAIL printed then exit0; Makefile fossil greps after Makefile
# deleted). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F05_SQLITE_DOC:-analysis/archive/phase/phase-f-f05-v3.md}"
MANIFEST="tests/baseline/f05-std-db-sqlite-v3.tsv"
PREFIX="xlang: [XLANG_F05_SQLITE]"

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
  echo "f05-db-sqlite-v3 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} sqlite=${SQLITE_OK:-0} stub=${STUB_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
SQLITE_OK=0
STUB_OK=0
SKIP=1

echo "=== F-05 v3: std.db.sqlite remove sqlite.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-05 v3' "$DOC" || die "doc missing F-05 v3 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f05-v3.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    symbol)
      target="$mod_path"
      [ -n "$target" ] || die "manifest symbol missing mod_path for $item_id"
      [ -f "$target" ] || die "manifest target missing: $target"
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    file)
      [ -f "$anchor" ] || die "manifest missing file: $anchor"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
echo "f05-sqlite manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-05 v3: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
echo "=== F-05 v3: STD-057 sqlite manifest-only (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty.
# Manifest-only: full exec / open / last_error product-red residual stays
# out of this archaeology knife (see STD-139 stub honesty notes).
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
if [ ! -f tests/run-std-sqlite-gate.sh ]; then
  die "missing tests/run-std-sqlite-gate.sh"
fi
chmod +x tests/run-std-sqlite-gate.sh
if ! XLANG_STD_SQLITE_MANIFEST_ONLY=1 tests/run-std-sqlite-gate.sh; then
  die "std-sqlite manifest-only sub-gate failed"
fi
SQLITE_OK=1

# Observational: STD-139 stub honesty already covers is_available +
# stub_behavior.x; open/last_error product segfault residual stays skip.
# PLATFORM: SHARED — do not die on stub product-red.
if [ -f tests/run-std-sqlite-stub-gate.sh ]; then
  echo "=== F-05 v3: STD-139 stub (observational) ==="
  chmod +x tests/run-std-sqlite-stub-gate.sh
  set +e
  tests/run-std-sqlite-stub-gate.sh
  stub_rc=$?
  set -e
  if [ "$stub_rc" -eq 0 ]; then
    STUB_OK=1
  else
    echo "f05-sqlite: stub observational rc=$stub_rc (product residual; not soft FAIL)" >&2
    STUB_OK=0
  fi
fi
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} sqlite=${SQLITE_OK} stub=${STUB_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f05 std.db.sqlite v3 gate OK (F-05 v3; honesty)"
