#!/usr/bin/env bash
# F-url v1: std.url de-C (url.c → url.x; url_glue.c deleted F-ZC).
#
# Usage: ./tests/run-f-url-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-url-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-076／STD-134 hard delegate. Soft XLANG_F_URL_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/url=/ipv6=/skip=.
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Explicit-bad XLANG / missing native = hard die FIRST (before
# static / leftover nested std-url / leftover nested std-url-ipv6-host;
# refuse leftover ignore of explicit-bad). leftover auto-make of
# url.o (`xlang_compiler_make` even when the leaf is present —
# try-heat/g05 raced L2) retired. leftover unused compiler-make.sh
# sourced unused after leftover auto-make retired. Missing leaf .o =
# hard die. leftover nested std-url / std-url-ipv6-host stay.
# G.7: complete existing resolve_shu; converge dod_native_exe; do not
# fork a third resolver.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-url-v1.md"
MANIFEST="tests/baseline/f-url-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_URL_V1]"

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
  echo "f-url-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} url=${URL_OK:-0} ipv6=${IPV6_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
URL_OK=0
IPV6_OK=0
SKIP=1

# Explicit XLANG that is missing/non-native hard-dies BEFORE static /
# leftover nested std-url / leftover nested std-url-ipv6-host (refuse
# leftover SKIP→OK / leftover ignore of explicit-bad / leftover XLANG
# fallthrough). leftover nested product path stays when XLANG is unset
# (do not rewrite leftover nested std-url / std-url-ipv6-host).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

echo "=== F-url v1: std.url url.c → url.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-url v1' "$DOC" || die "doc missing F-url v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/url/url.x ] || die "missing std/url/url.x"
[ ! -f std/url/url_glue.c ] || die "url_glue.c should be deleted (F-ZC)"
[ ! -f std/url/url.c ] || die "url.c should be deleted"

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

if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

# leftover auto-make retired: require the leaf already present (refuse try-heat/g05).
# PLATFORM: SHARED — missing leaf = hard die; Ubuntu gold still required.
if [ ! -f std/url/url.o ]; then
  die "missing std/url/url.o (refuse leftover auto-make)"
fi
ENSURE_OK=1

if [ -f tests/run-std-url-gate.sh ]; then
  echo "=== F-url v1: delegate run-std-url-gate ==="
  chmod +x tests/run-std-url-gate.sh
  if ! tests/run-std-url-gate.sh; then
    die "std-url sub-gate failed"
  fi
  URL_OK=1
fi

if [ -f tests/run-std-url-ipv6-host-gate.sh ]; then
  echo "=== F-url v1: delegate run-std-url-ipv6-host-gate ==="
  chmod +x tests/run-std-url-ipv6-host-gate.sh
  if ! tests/run-std-url-ipv6-host-gate.sh; then
    die "std-url-ipv6-host sub-gate failed"
  fi
  IPV6_OK=1
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} url=${URL_OK} ipv6=${IPV6_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-url-v1 std.url gate OK (F-url v1; honesty)"
