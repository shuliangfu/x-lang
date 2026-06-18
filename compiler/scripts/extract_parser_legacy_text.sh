#!/usr/bin/env bash
# 从含 T parser_parse_into_buf 的旧 shu_asm 可执行文件提取 .text → ET_REL .o，供 seed/experimental 链入真 parse。
# 用法：cd compiler && ./scripts/extract_parser_legacy_text.sh [legacy_bin] [out.o]
set -e
cd "$(dirname "$0")/.."
LEGACY_BIN="${1:-./shu_asm2_refreshed}"
OUT="${2:-build_asm/parser_legacy_text.o}"
if [ ! -x "$LEGACY_BIN" ]; then
  echo "extract_parser_legacy_text: skip (no executable $LEGACY_BIN)" >&2
  exit 0
fi
if ! file "$LEGACY_BIN" 2>/dev/null | grep -q "ELF.*x86-64"; then
  echo "extract_parser_legacy_text: skip (not linux x86-64 ELF: $LEGACY_BIN)" >&2
  exit 0
fi
mkdir -p "$(dirname "$OUT")"
if [ -f "$OUT" ] && [ "$OUT" -nt "$LEGACY_BIN" ] && [ "$OUT" -nt "${0}" ]; then
  echo "extract_parser_legacy_text: up to date $OUT"
  exit 0
fi
echo "extract_parser_legacy_text: objcopy .text from $LEGACY_BIN -> $OUT"
objcopy -j .text -O elf64-x86-64 "$LEGACY_BIN" "$OUT" 2>/dev/null || {
  echo "extract_parser_legacy_text: objcopy failed" >&2
  exit 1
}
if ! nm -g "$OUT" 2>/dev/null | grep -qE ' parser_parse_into_buf$'; then
  echo "extract_parser_legacy_text: warn: $OUT missing parser_parse_into_buf" >&2
  exit 1
fi
echo "extract_parser_legacy_text OK ($OUT)"
