#!/usr/bin/env bash
# F-std-zero-c v1: std zero handwritten .c/.h track (endgame roadmap).
#
# Usage: ./tests/run-f-std-zero-c-track-gate.sh
#        XLANG_F_STD_ZERO_C_STRICT=1 ./tests/run-f-std-zero-c-track-gate.sh
#        XLANG_F_STD_ZERO_C_UPDATE=1 ./tests/run-f-std-zero-c-track-gate.sh
# 2026-08-27: Honesty — hard-fail track regressions (new unlisted std C/H,
# missing DOC/xbuild/Makefile resurrect, inventory child). Soft
# XLANG_F_STD_ZERO_C_FAIL retired. Root: soft die→exit0 = portable
# false-green (could add unlisted .c while gate still exit0). STRICT
# remains opt-in for endgame 0/0 (current formal_surface.c residual >0).
# Report c=/h=/new=/gone=/inv=/strict=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

STRICT=${XLANG_F_STD_ZERO_C_STRICT:-0}
UPDATE=${XLANG_F_STD_ZERO_C_UPDATE:-0}
DOC="analysis/archive/phase/phase-f-std-zero-c-v1.md"
MANIFEST="tests/baseline/f-std-zero-c-track.tsv"
TMP="/tmp/xlang_std_zero_c_track.$$.tsv"
PREFIX="xlang: [XLANG_F_STD_ZERO_C]"

C_N=0
H_N=0
NEW=0
GONE=0
INV_OK=0
SKIP=1

die() {
  echo "f-std-zero-c-track FAIL: $*" >&2
  echo "${PREFIX} status=fail c=${C_N:-0} h=${H_N:-0} new=${NEW:-0} gone=${GONE:-0} inv=${INV_OK:-0} strict=${STRICT} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

collect_track() {
  local c_n h_n
  c_n=$(find std -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
  h_n=$(find std -type f -name '*.h' 2>/dev/null | wc -l | tr -d ' ')
  {
    echo "# F-std-zero-c track manifest（std 零 C/H 终局）"
    echo "# 列：kind	path	phase	notes"
    echo "# 更新：XLANG_F_STD_ZERO_C_UPDATE=1 ./tests/run-f-std-zero-c-track-gate.sh"
    echo "summary_std_c_target	0"
    echo "summary_std_h_target	0"
    printf 'summary_std_c_current\t%s\n' "$c_n"
    printf 'summary_std_h_current\t%s\n' "$h_n"
    find std -name '*.c' | LC_ALL=C sort | while IFS= read -r p; do
      case "$p" in
        std/async/*) ph=Z2-async ;;
        std/http/*) ph=Z1-http ;;
        std/channel/*|std/thread/*|std/process/*) ph=Z3-channel-thread-process ;;
        std/sync/*|std/atomic/*) ph=Z4-sync-atomic ;;
        std/net/*) ph=Z5-net ;;
        std/db/*) ph=Z6-db ;;
        std/crypto/*) ph=Z7-crypto ;;
        *) ph=Z8-os-glue ;;
      esac
      printf 'file_c\t%s\t%s\tpending\n' "$p" "$ph"
    done
    find std -name '*.h' | LC_ALL=C sort | while IFS= read -r p; do
      case "$p" in
        std/*/*_abi.h|std/path/path_abi.h|std/map/map_abi.h|std/fs/fs_abi.h|std/error/error_abi.h)
          ph=Z9-abi-header ;;
        *) ph=Z9-header ;;
      esac
      printf 'file_h\t%s\t%s\tpending\n' "$p" "$ph"
    done
    if [ -f compiler/include/xlang_std_abi/fs_abi.h ]; then
      printf 'file_abi_h\tcompiler/include/xlang_std_abi/fs_abi.h\tZ9-abi-header-done\tF-ZC inline preamble\n'
    fi
    if [ -f std/compress/common.x ]; then
      printf 'file_x\tstd/compress/common.x\tZ9-header-done\tcompress_common.h removed\n'
    fi
  } >"$TMP"
  echo "$c_n $h_n"
}

echo "=== F-std-zero-c v1: std zero C/H track (honesty) ==="
# MG: compiler/Makefile deleted — build entry is xbuild; refuse resurrect.
if [ -f compiler/Makefile ]; then die "compiler/Makefile resurrected (use xbuild)"; fi
[ -f xbuild ] || die "missing xbuild"
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-std-zero-c v1' "$DOC" || die "doc missing marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

read -r C_N H_N <<< "$(collect_track)"
echo "f-std-zero-c-track: std .c=${C_N} std .h=${H_N} (target 0/0)"

if [ "$UPDATE" = "1" ]; then
  mv "$TMP" "$MANIFEST"
  SKIP=0
  echo "f-std-zero-c-track: updated $MANIFEST"
  echo "${PREFIX} status=ok c=${C_N} h=${H_N} new=0 gone=0 inv=0 strict=${STRICT} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -f "$MANIFEST" ]; then
  mv "$TMP" "$MANIFEST"
  SKIP=0
  echo "f-std-zero-c-track: created $MANIFEST"
  echo "${PREFIX} status=ok c=${C_N} h=${H_N} new=0 gone=0 inv=0 strict=${STRICT} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi
rm -f "$TMP"

# Refuse new unlisted std C/H (track regression).
NEW=0
while IFS= read -r p; do
  [ -z "$p" ] && continue
  if ! awk -F'\t' -v path="$p" '$2==path { found=1; exit } END { exit !found }' "$MANIFEST"; then
    echo "f-std-zero-c-track FAIL: new unlisted: $p" >&2
    NEW=$((NEW + 1))
  fi
done < <({ find std -name '*.c'; find std -name '*.h'; } | LC_ALL=C sort -u)
[ "$NEW" -eq 0 ] || die "$NEW new std C/H not in manifest (migrate to .x first)"

# Baseline entries removed → progress hint (not a hard fail).
GONE=0
while IFS=$'\t' read -r kind path _phase _notes; do
  [ "$kind" = "file_c" ] || [ "$kind" = "file_h" ] || continue
  [ -f "$path" ] || GONE=$((GONE + 1))
done < "$MANIFEST"
if [ "$GONE" -gt 0 ]; then
  echo "f-std-zero-c-track: $GONE baseline entries removed (good progress; run XLANG_F_STD_ZERO_C_UPDATE=1 to refresh)" >&2
fi

# STRICT = endgame observational opt-in (formal_surface residual still >0).
if [ "$STRICT" = "1" ]; then
  if [ "$C_N" != "0" ] || [ "$H_N" != "0" ]; then
    die "STRICT: std still has ${C_N} .c + ${H_N} .h (endgame requires 0)"
  fi
fi

[ -f std/compress/common.x ] || die "missing std/compress/common.x"
grep -q 'compress_common_zero_c_marker_c' std/compress/common.x || die "common.x missing marker"
[ ! -f std/compress/compress_common.h ] || die "compress_common.h should be deleted"

chmod +x tests/run-std-c-inventory-gate.sh
if ! tests/run-std-c-inventory-gate.sh; then
  die "std-c-inventory failed"
fi
INV_OK=1
SKIP=0

echo "f-std-zero-c-track OK (c=${C_N} h=${H_N} strict=${STRICT})"
echo "${PREFIX} status=ok c=${C_N} h=${H_N} new=${NEW} gone=${GONE} inv=${INV_OK} strict=${STRICT} skip=${SKIP} host=$(ci_host_summary)"
