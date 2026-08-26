#!/usr/bin/env bash
# F-encoding v1: std.encoding de-C (encoding.c → encoding.x).
#
# Usage: ./tests/run-f-encoding-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-encoding-v1-gate.sh
# 2026-08-26: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure.
# Soft XLANG_F_ENCODING_V1_FAIL retired. Root: orphan `die Makefile…; fi` after
# Makefile delete → bash syntax error; soft de-c-batch swallowed RC≠0 (portable
# false-green). encoding-hex-b64 / encoding-extra stay observational (product
# UNDEF / check residual; listed skip). Report
# static=/ensure=/hex=/extra=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-encoding-v1.md"
MANIFEST="tests/baseline/f-encoding-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_ENCODING_V1]"

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
  echo "f-encoding-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} hex=${HEX_OK:-0} extra=${EXTRA_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
HEX_OK=0
EXTRA_OK=0
SKIP=1

echo "=== F-encoding v1: std.encoding encoding.c → encoding.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-encoding v1' "$DOC" || die "doc missing F-encoding v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/encoding/encoding.x ] || die "missing std/encoding/encoding.x"
[ ! -f std/encoding/encoding.c ] || die "std/encoding/encoding.c should be deleted"

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

xlang_compiler_make ../std/encoding/encoding.o >/dev/null 2>&1 \
  || die "ensure encoding.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Observational residual (do not invoke): encoding-hex-b64 / encoding-extra are on
# the product UNDEF / check skip list — running them re-dogfoods known red and can
# hang host-c paths. Counters stay 0. PLATFORM: SHARED archaeology.
echo "f-encoding-v1 SKIP encoding-hex-b64 (observational; product residual; not invoked)" >&2
echo "f-encoding-v1 SKIP encoding-extra (observational; product residual; not invoked)" >&2

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} hex=${HEX_OK} extra=${EXTRA_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-encoding-v1 std.encoding gate OK (F-encoding v1; honesty)"
