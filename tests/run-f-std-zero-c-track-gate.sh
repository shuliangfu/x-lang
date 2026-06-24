#!/usr/bin/env bash
# F-std-zero-c v1：std 标准库零 C/H 终局跟踪门禁。
#
# 用法：./tests/run-f-std-zero-c-track-gate.sh
# 环境：
#   SHUX_F_STD_ZERO_C_FAIL=1       — 跟踪失败时硬退出（默认软通过）
#   SHUX_F_STD_ZERO_C_STRICT=1     — 终局模式：std 仍存在 .c/.h 即 FAIL
#   SHUX_F_STD_ZERO_C_UPDATE=1     — 刷新 tests/baseline/f-std-zero-c-track.tsv
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_STD_ZERO_C_FAIL:-0}
STRICT=${SHUX_F_STD_ZERO_C_STRICT:-0}
UPDATE=${SHUX_F_STD_ZERO_C_UPDATE:-0}
DOC="analysis/phase-f-std-zero-c-v1.md"
MANIFEST="tests/baseline/f-std-zero-c-track.tsv"
TMP="/tmp/shux_std_zero_c_track.$$.tsv"

die() {
  echo "f-std-zero-c-track FAIL: $*" >&2
  [ "$FAIL" = "1" ] || [ "$STRICT" = "1" ] && exit 1
  exit 0
}

collect_track() {
  local c_n h_n
  c_n=$(find std -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
  h_n=$(find std -type f -name '*.h' 2>/dev/null | wc -l | tr -d ' ')
  {
    echo "# F-std-zero-c track manifest（std 零 C/H 终局）"
    echo "# 列：kind	path	phase	notes"
    echo "# 更新：SHUX_F_STD_ZERO_C_UPDATE=1 ./tests/run-f-std-zero-c-track-gate.sh"
    echo "summary_std_c_target	0"
    echo "summary_std_h_target	0"
    printf 'summary_std_c_current\t%s\n' "$c_n"
    printf 'summary_std_h_current\t%s\n' "$h_n"
    find std -name '*.c' | LC_ALL=C sort | while IFS= read -r p; do
      case "$p" in
        std/http/*) ph=Z1-http ;;
        std/async/*) ph=Z2-async ;;
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
    if [ -f compiler/include/shux_std_abi/fs_abi.h ]; then
      printf 'file_abi_h\tcompiler/include/shux_std_abi/fs_abi.h\tZ9-abi-header-done\tF-ZC inline preamble\n'
    fi
    if [ -f std/compress/common.sx ]; then
      printf 'file_sx\tstd/compress/common.sx\tZ9-header-done\tcompress_common.h removed\n'
    fi
  } >"$TMP"
  echo "$c_n $h_n"
}

echo "=== F-std-zero-c v1: std zero C/H track ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-std-zero-c v1' "$DOC" || die "doc missing marker"

read -r std_c std_h <<< "$(collect_track)"
echo "f-std-zero-c-track: std .c=${std_c} std .h=${std_h} (target 0/0)"

if [ "$UPDATE" = "1" ]; then
  mv "$TMP" "$MANIFEST"
  echo "f-std-zero-c-track: updated $MANIFEST"
  exit 0
fi

if [ ! -f "$MANIFEST" ]; then
  mv "$TMP" "$MANIFEST"
  echo "f-std-zero-c-track: created $MANIFEST"
  exit 0
fi
rm -f "$TMP"

# 禁止新增未登记 std C/H
NEW=0
while IFS= read -r p; do
  [ -z "$p" ] && continue
  if ! awk -F'\t' -v path="$p" '$2==path { found=1; exit } END { exit !found }' "$MANIFEST"; then
    echo "f-std-zero-c-track FAIL: new unlisted: $p" >&2
    NEW=$((NEW + 1))
  fi
done < <({ find std -name '*.c'; find std -name '*.h'; } | LC_ALL=C sort -u)
[ "$NEW" -eq 0 ] || die "$NEW new std C/H not in manifest (migrate to .sx first)"

# 已删 baseline 行 → 刷新提示
GONE=0
while IFS=$'\t' read -r kind path _phase _notes; do
  [ "$kind" = "file_c" ] || [ "$kind" = "file_h" ] || continue
  [ -f "$path" ] || GONE=$((GONE + 1))
done < "$MANIFEST"
if [ "$GONE" -gt 0 ]; then
  echo "f-std-zero-c-track: $GONE baseline entries removed (good progress; run SHUX_F_STD_ZERO_C_UPDATE=1 to refresh)" >&2
fi

if [ "$STRICT" = "1" ]; then
  if [ "$std_c" != "0" ] || [ "$std_h" != "0" ]; then
    die "STRICT: std still has ${std_c} .c + ${std_h} .h (终局 requires 0)"
  fi
fi

[ -f std/compress/common.sx ] || die "missing std/compress/common.sx"
grep -q 'compress_common_zero_c_marker_c' std/compress/common.sx || die "common.sx missing marker"
[ ! -f std/compress/compress_common.h ] || die "compress_common.h should be deleted"

chmod +x tests/run-std-c-inventory-gate.sh
tests/run-std-c-inventory-gate.sh || die "std-c-inventory failed"

echo "f-std-zero-c-track OK (c=${std_c} h=${std_h} strict=${STRICT})"
