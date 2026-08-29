#!/usr/bin/env bash
# F-05 v2: std.db.kv remove kv.c (kv.x + runtime mmap glue).
#
# Usage: ./tests/run-f05-std-db-kv-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f05-std-db-kv-v2-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + inventory + kv-arrow product
# (no soft die→exit0). Soft XLANG_F05_DB_KV_V2_FAIL retired. Prefer asm;
# pin XLANG_LINK_XLANG. Host-c nm/cc smoke retired (product path = kv-arrow
# honesty gate). Report static=/inventory=/kv_arrow=/skip=. Gate was
# portable-false-green (DOC still pointed at top-level
# analysis/phase-f-f05-v2.md after archive; soft FAIL printed then exit0;
# Makefile fossil greps after Makefile deleted).
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / nested leftover inventory / leftover nested kv-arrow;
# refuse leftover ignore of explicit-bad). leftover nested product path
# (inventory / kv-arrow) stay.
# G.7: complete existing resolve_shu; converge dod_native_exe.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F05_KV_DOC:-analysis/archive/phase/phase-f-f05-v2.md}"
MANIFEST="tests/baseline/f05-std-db-kv-v2.tsv"
PREFIX="xlang: [XLANG_F05_KV]"

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

die() {
  echo "f05-db-kv-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} inventory=${INVENTORY_OK:-0} kv_arrow=${KV_ARROW_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
INVENTORY_OK=0
KV_ARROW_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# nested leftover inventory / leftover nested kv-arrow (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover inventory / kv-arrow).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-05 v2: std.db.kv remove kv.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-05 v2' "$DOC" || die "doc missing F-05 v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f05-v2.md ]; then
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
echo "f05-kv manifest OK"
STATIC_OK=1

if [ ! -f tests/run-std-c-inventory-gate.sh ]; then
  die "missing tests/run-std-c-inventory-gate.sh"
fi
echo "=== F-05 v2: delegate run-std-c-inventory-gate (F-01; hard) ==="
chmod +x tests/run-std-c-inventory-gate.sh
if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory sub-gate failed"
fi
INVENTORY_OK=1

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
echo "=== F-05 v2: kv+arrow product (XLANG=$XLANG_BIN; hard) ==="
# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
if [ ! -f tests/run-std-db-kv-arrow-gate.sh ]; then
  die "missing tests/run-std-db-kv-arrow-gate.sh"
fi
chmod +x tests/run-std-db-kv-arrow-gate.sh
if ! tests/run-std-db-kv-arrow-gate.sh; then
  die "kv+arrow sub-gate failed"
fi
KV_ARROW_OK=1
SKIP=0

echo "${PREFIX} status=ok static=${STATIC_OK} inventory=${INVENTORY_OK} kv_arrow=${KV_ARROW_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f05 std.db.kv v2 gate OK (F-05 v2; honesty)"
