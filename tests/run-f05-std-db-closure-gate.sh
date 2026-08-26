#!/usr/bin/env bash
# F-05 v4: std.db three-backend closure (arrow + kv + sqlite aggregate).
#
# Usage: ./tests/run-f05-std-db-closure-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f05-std-db-closure-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + three child gates +
# kv-arrow + sqlite manifest-only + inventory (no soft die→exit0; no
# export of retired XLANG_F05_DB_{ARROW_V1,KV_V2,SQLITE_V3,CLOSURE}_FAIL).
# Soft XLANG_F05_DB_CLOSURE_FAIL retired. Prefer asm; pin XLANG_LINK_XLANG.
# Report arrow=/kv=/sqlite=/kv_arrow=/sqlite_m=/inventory=/skip=. Gate was
# portable-false-green (soft FAIL exit0 + soft child FAIL pass-through +
# Makefile content greps after Makefile deleted while children already
# honesty-green). PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F05_DOC:-analysis/archive/phase/phase-f-f05-v4-closure.md}"
MANIFEST="tests/baseline/f05-std-db-closure.tsv"
PREFIX="xlang: [XLANG_F05_CLOSURE]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for child dogfood consistency.
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
  echo "f05-db-closure gate FAIL: $*" >&2
  echo "${PREFIX} status=fail arrow=${ARROW_OK:-0} kv=${KV_OK:-0} sqlite=${SQLITE_OK:-0} kv_arrow=${KV_ARROW_OK:-0} sqlite_m=${SQLITE_M_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

ARROW_OK=0
KV_OK=0
SQLITE_OK=0
KV_ARROW_OK=0
SQLITE_M_OK=0
INVENTORY_OK=0
SKIP=1

echo "=== F-05 v4: std.db closure arrow+kv+sqlite (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-05 v4' "$DOC" || die "doc missing F-05 v4 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f analysis/phase-f-f05-v4-closure.md ]; then
  die "top-level DOC resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    file|doc|gate|script)
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
echo "f05-closure manifest OK"

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
# Pin product link for child dogfood (children re-resolve; keep env honest).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

# Hard-delegate children. Do NOT export retired XLANG_F05_DB_*_FAIL envs —
# each child is already honesty-hard (prefer-asm + inventory + product).
# PLATFORM: SHARED archaeology.
run_child() {
  local g="$1"
  local flag_var="$2"
  [ -f "$g" ] || die "missing $g"
  echo "=== F-05 v4: delegate $(basename "$g") (hard) ==="
  chmod +x "$g"
  if ! "$g"; then
    die "$(basename "$g") sub-gate failed"
  fi
  eval "$flag_var=1"
}

run_child tests/run-f05-std-db-arrow-v1-gate.sh ARROW_OK
run_child tests/run-f05-std-db-kv-v2-gate.sh KV_OK
run_child tests/run-f05-std-db-sqlite-v3-gate.sh SQLITE_OK

# Direct product delegates (children already run these; keep aggregate
# counters explicit for report honesty).
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-db-kv-arrow-gate.sh ]; then
  echo "=== F-05 v4: delegate kv+arrow gate (hard) ==="
  chmod +x tests/run-std-db-kv-arrow-gate.sh
  if ! tests/run-std-db-kv-arrow-gate.sh; then
    die "run-std-db-kv-arrow-gate failed"
  fi
  KV_ARROW_OK=1
else
  die "missing tests/run-std-db-kv-arrow-gate.sh"
fi

if [ -f tests/run-std-sqlite-gate.sh ]; then
  echo "=== F-05 v4: delegate std-sqlite gate (manifest-only; hard) ==="
  chmod +x tests/run-std-sqlite-gate.sh
  if ! XLANG_STD_SQLITE_MANIFEST_ONLY=1 tests/run-std-sqlite-gate.sh; then
    die "run-std-sqlite-gate failed"
  fi
  SQLITE_M_OK=1
else
  die "missing tests/run-std-sqlite-gate.sh"
fi

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-05 v4: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi
SKIP=0

echo "${PREFIX} status=ok arrow=${ARROW_OK} kv=${KV_OK} sqlite=${SQLITE_OK} kv_arrow=${KV_ARROW_OK} sqlite_m=${SQLITE_M_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f05 std.db closure gate OK (F-05 v4; honesty)"
