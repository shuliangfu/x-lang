#!/usr/bin/env bash
# F-04 v6: std.compress brotli remove brotli.c (lib.x + mod.x import).
# Honesty: soft XLANG_F04_COMPRESS_BROTLI_FAIL + top-level DOC/Makefile
# anchors retired — missing analysis/phase-f-f04-v6.md after MG archive
# was portable false-green (soft die→exit0). Product brotli ld residual
# stays deferred (tip skip); this gate is packaging/archaeology only.
#
# Usage: ./tests/run-f04-std-compress-brotli-gate.sh
# Env:
#   XLANG_F04_COMPRESS_BROTLI_MANIFEST_ONLY=1  — static + TSV only (no delegates)
#
# Live authority: archive DOC + lib.x/mod.x + baseline TSV + STD-125 / F-01
# delegates (refuse top-level DOC / compiler/Makefile resurrect).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-f04-v6.md"
BROTLI_LIB="std/compress/brotli/lib.x"
BROTLI_MOD="std/compress/brotli/mod.x"
MANIFEST="tests/baseline/f04-std-compress-brotli.tsv"
PREFIX="xlang: [XLANG_F04_COMPRESS_BROTLI]"

die() {
  echo "f04-compress-brotli gate FAIL: $*" >&2
  echo "${PREFIX} status=fail doc=${DOC_OK:-0} lib=${LIB_OK:-0} mod=${MOD_OK:-0} absent_c=${ABSENT_C_OK:-0} manifest=${MANIFEST_OK:-0} std125=${STD125_OK:-0} compress=${COMPRESS_OK:-0} inv=${INV_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

DOC_OK=0
LIB_OK=0
MOD_OK=0
ABSENT_C_OK=0
MANIFEST_OK=0
STD125_OK=0
COMPRESS_OK=0
INV_OK=0
SKIP=1

echo "=== F-04 v6: std.compress brotli remove brotli.c (honesty; archive DOC) ==="
# Refuse top-level DOC resurrect (live = archive/phase/).
if [ -f analysis/phase-f-f04-v6.md ]; then
  die "top-level analysis/phase-f-f04-v6.md resurrected (live = archive/phase/)"
fi
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (MG retired; do not re-anchor brotli.o here)"
fi

for f in "$DOC" "$BROTLI_LIB" "$BROTLI_MOD" "$MANIFEST"; do
  [ -f "$f" ] || die "missing $f"
done
grep -q 'F-04 v6' "$DOC" || die "doc missing F-04 v6 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate honesty section"
DOC_OK=1

[ ! -f std/compress/brotli/brotli.c ] || die "brotli.c should be deleted"
ABSENT_C_OK=1

grep -q 'compress_brotli_compress_c' "$BROTLI_LIB" || die "lib missing compress_brotli_compress_c"
grep -q 'compress_brotli_stream_compress_c' "$BROTLI_LIB" || die "lib missing stream compress"
grep -q 'xlang_compress_brotli_marker' "$BROTLI_LIB" || die "lib missing marker"
LIB_OK=1
echo "f04-compress-brotli OK: lib.x symbols + marker"

grep -q 'import("std.compress.brotli.lib")' "$BROTLI_MOD" || die "mod.x missing lib import"
if grep -q 'extern function compress_brotli_compress_c' "$BROTLI_MOD" 2>/dev/null; then
  die "mod.x still extern compress_brotli_compress_c"
fi
MOD_OK=1
echo "f04-compress-brotli OK: mod.x import (no bare extern)"

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    symbol)
      target="$BROTLI_LIB"
      case "$mod_path" in
        std/compress/brotli/mod.x) target="$BROTLI_MOD" ;;
        std/compress/brotli/lib.x) target="$BROTLI_LIB" ;;
      esac
      if ! grep -qF "$anchor" "$target"; then
        echo "f04-compress-brotli manifest missing '$anchor' in $target" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    absent)
      if [ -f "$anchor" ]; then
        echo "f04-compress-brotli manifest absent file still exists: $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    doc)
      [ -f "$anchor" ] || { echo "f04-compress-brotli missing doc path $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
    *)
      echo "f04-compress-brotli unknown kind: $kind ($item_id)" >&2
      MISS=$((MISS + 1))
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "$MISS manifest item(s) failed"
MANIFEST_OK=1
echo "f04-compress-brotli OK: baseline TSV"

if [ "${XLANG_F04_COMPRESS_BROTLI_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=0
  echo "f04 std.compress brotli gate OK (manifest only; soft FAIL retired)"
  echo "${PREFIX} status=ok doc=${DOC_OK} lib=${LIB_OK} mod=${MOD_OK} absent_c=${ABSENT_C_OK} manifest=${MANIFEST_OK} std125=${STD125_OK} compress=${COMPRESS_OK} inv=${INV_OK} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

# Hard-delegate children (STD-125 / compress / F-01). Do NOT re-export retired soft FAIL.
echo "=== F-04 v6: hard-delegate STD-125 compress-brotli ==="
chmod +x tests/run-std-compress-brotli-gate.sh
./tests/run-std-compress-brotli-gate.sh || die "STD-125 compress-brotli delegate failed"
STD125_OK=1

echo "=== F-04 v6: hard-delegate std-compress ==="
chmod +x tests/run-std-compress-gate.sh
./tests/run-std-compress-gate.sh || die "std-compress delegate failed"
COMPRESS_OK=1

echo "=== F-04 v6: hard-delegate F-01 std-c-inventory ==="
chmod +x tests/run-std-c-inventory-gate.sh
./tests/run-std-c-inventory-gate.sh || die "std-c-inventory sub-gate failed"
INV_OK=1
SKIP=0

echo "f04 std.compress brotli gate OK (F-04 v6; soft FAIL retired)"
echo "${PREFIX} status=ok doc=${DOC_OK} lib=${LIB_OK} mod=${MOD_OK} absent_c=${ABSENT_C_OK} manifest=${MANIFEST_OK} std125=${STD125_OK} compress=${COMPRESS_OK} inv=${INV_OK} skip=${SKIP} host=$(ci_host_summary)"
