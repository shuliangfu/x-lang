#!/usr/bin/env bash
# F-url v2: parse/build/query/resolve in url.x (F-ZC; url_glue.c deleted).
#
# Usage: ./tests/run-f-url-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-url-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-076 url + STD-134 ipv6-host hard delegate. Soft XLANG_F_URL_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/url=/ipv6=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-url-v2.md"
MANIFEST="tests/baseline/f-url-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_URL_V2]"

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
  echo "f-url-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} url=${URL_OK:-0} ipv6=${IPV6_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
URL_OK=0
IPV6_OK=0
SKIP=1

echo "=== F-url v2: URL logic → url.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-url v2' "$DOC" || die "doc missing F-url v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/url/url.x ] || die "missing url.x"
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
grep -q 'url_parse_c' std/url/url.x || die "url.x missing parse"
grep -q 'url_resolve_c' std/url/url.x || die "url.x missing resolve"
grep -q 'url_smoke_c' std/url/url.x || die "url.x missing smoke"
grep -q 'url_f_url_v2_marker_c' std/url/url.x || die "url.x missing v2 marker"
grep -q 'url_f_zero_c_marker_c' std/url/url.x || die "url.x missing zero-c marker"
grep -q 'url_inet_pton6_c' std/url/url.x || die "url.x missing inet_pton"
grep -q 'inet_ntop' std/url/url.x || die "url.x missing inet_ntop extern"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/url/url.o >/dev/null 2>&1 \
  || die "ensure url.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-076 / STD-134.
# Do NOT export retired XLANG_F_URL_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-url-gate.sh ]; then
  echo "=== F-url v2: delegate run-std-url-gate (hard) ==="
  chmod +x tests/run-std-url-gate.sh
  if ! tests/run-std-url-gate.sh; then
    die "std-url sub-gate failed"
  fi
  URL_OK=1
else
  die "missing tests/run-std-url-gate.sh"
fi

if [ -f tests/run-std-url-ipv6-host-gate.sh ]; then
  echo "=== F-url v2: delegate run-std-url-ipv6-host-gate (hard) ==="
  chmod +x tests/run-std-url-ipv6-host-gate.sh
  if ! tests/run-std-url-ipv6-host-gate.sh; then
    die "std-url-ipv6-host sub-gate failed"
  fi
  IPV6_OK=1
else
  die "missing tests/run-std-url-ipv6-host-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} url=${URL_OK} ipv6=${IPV6_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-url-v2 gate OK (F-url v2; honesty)"
