#!/usr/bin/env bash
# F-02 v2: std.sys win32 remove win32*.inc.c (B-17/B-18 + F-01 inventory).
#
# Usage: ./tests/run-f02-std-sys-win32-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f02-std-sys-win32-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + B-17/B-18 + inventory
# (no soft die→exit0). Soft XLANG_F02_WIN32_FAIL retired. Prefer asm; pin
# XLANG_LINK_XLANG for dogfood consistency. Report
# static=/b17=/b18=/inventory=/skip=. Gate was portable-false-green (DOC still
# pointed at top-level analysis/phase-f-f02-v2.md after archive move; soft
# FAIL printed then exit0 while static checks already green).
# PLATFORM: SHARED archaeology (Windows smoke N/A on non-Windows; facade
# static checks run on all hosts).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_F02_WIN32_DOC:-analysis/archive/phase/phase-f-f02-v2.md}"
MANIFEST="tests/baseline/f02-std-sys-win32.tsv"
PREFIX="xlang: [XLANG_F02_WIN32]"

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
  echo "f02-win32 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} b17=${B17_OK:-0} b18=${B18_OK:-0} inventory=${INVENTORY_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
B17_OK=0
B18_OK=0
INVENTORY_OK=0
SKIP=1

echo "=== F-02 v2: std.sys win32 remove win32*.inc.c (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
grep -q 'F-02 v2' "$DOC" || die "doc missing F-02 v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

# Manifest: absent / script / symbol rows (honesty TSV).
# PLATFORM: SHARED archaeology.
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in
    \#*) continue ;;
  esac
  case "$kind" in
    absent)
      [ ! -f "$anchor" ] || die "manifest absent file still exists: $anchor"
      ;;
    script)
      [ -f "$anchor" ] || die "manifest missing script: $anchor"
      ;;
    symbol)
      target="$mod_path"
      [ -n "$target" ] || die "manifest symbol missing mod_path for $item_id"
      [ -f "$target" ] || die "manifest target missing: $target"
      grep -qF "$anchor" "$target" || die "manifest missing '$anchor' in $target"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"

[ ! -f std/sys/win32.inc.c ] || die "win32.inc.c should be deleted"
[ ! -f std/sys/win32_net.inc.c ] || die "win32_net.inc.c should be deleted"
grep -q 'GetStdHandle' std/sys/win32.x || die "win32.x missing GetStdHandle FFI"
grep -q 'WSAStartup' std/sys/win32_net.x || die "win32_net.x missing WSAStartup FFI"
if grep -q 'xlang_win32_' std/sys/win32.x 2>/dev/null; then
  die "win32.x still references xlang_win32_* C shim"
fi
if grep -q 'xlang_win32_net_available_c' std/sys/win32_net.x 2>/dev/null; then
  die "win32_net.x still references xlang_win32_net_available_c"
fi
echo "f02-win32 manifest OK"
STATIC_OK=1

# Resolve prefer-asm for dogfood pin even when remaining checks are static.
# PLATFORM: SHARED — product path honesty.
if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

if [ ! -f tests/run-b17-exit-process-gate.sh ]; then
  die "missing tests/run-b17-exit-process-gate.sh"
fi
echo "=== F-02 v2: delegate run-b17-exit-process-gate (hard) ==="
chmod +x tests/run-b17-exit-process-gate.sh
if ! tests/run-b17-exit-process-gate.sh; then
  die "b17 exit-process sub-gate failed"
fi
B17_OK=1

if [ ! -f tests/run-b18-win32-net-gate.sh ]; then
  die "missing tests/run-b18-win32-net-gate.sh"
fi
echo "=== F-02 v2: delegate run-b18-win32-net-gate (hard) ==="
chmod +x tests/run-b18-win32-net-gate.sh
if ! tests/run-b18-win32-net-gate.sh; then
  die "b18 win32-net sub-gate failed"
fi
B18_OK=1

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-02 v2: delegate run-std-c-inventory-gate (F-01; hard) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! XLANG_STD_C_INVENTORY_FAIL=1 tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
  INVENTORY_OK=1
else
  die "missing tests/run-std-c-inventory-gate.sh"
fi

SKIP=0
echo "${PREFIX} status=ok static=${STATIC_OK} b17=${B17_OK} b18=${B18_OK} inventory=${INVENTORY_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f02-win32 gate OK (F-02 v2; win32*.inc.c removed; honesty)"
