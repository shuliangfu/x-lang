#!/usr/bin/env sh
# extract_lsp_gen_seeds.sh — 从 lsp_gen_full.c 拆分冷启动用 lsp_io_gen / lsp_gen seed（G-06）
#
# 用法（compiler 目录）：
#   ./scripts/extract_lsp_gen_seeds.sh
#
# 产出：
#   seeds/lsp_io_gen.linux.x86_64.c
#   seeds/lsp_gen.linux.x86_64.c

set -e
cd "$(dirname "$0")/.."

SRC=lsp_gen_full.c
if [ ! -s "$SRC" ]; then
  echo "extract_lsp_gen_seeds: missing $SRC" >&2
  exit 1
fi

mkdir -p seeds

# lsp_io 实现段：lsp_io_LSP_* 常量至 lsp_io_lsp_is_null 结束（约 382–578 行）
awk 'NR>=382 && NR<=578 { print }' "$SRC" > seeds/_lsp_io_body.c

cat > seeds/lsp_io_gen.linux.x86_64.c <<'HDR'
/* generated seed from lsp_gen_full.c (G-06 cold start) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern ptrdiff_t io_read(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern ptrdiff_t io_write(int32_t fd, uint8_t * buf, size_t count, uint32_t timeout_ms);
extern uint8_t * std_heap_alloc(size_t size);
extern void std_heap_free(uint8_t * ptr);
#define std_io_read io_read
#define std_io_write io_write
/* C-04 -E-extern TU aliases */
HDR

cat seeds/_lsp_io_body.c >> seeds/lsp_io_gen.linux.x86_64.c

# lsp_io_* 导出符号 → typeck_*（与 lsp_io.sx -E-extern mangling 一致）
perl -i -pe '
  s/\blsp_io_read_message\b/typeck_read_message/g;
  s/\blsp_io_write_fd\b/typeck_write_fd/g;
  s/\blsp_io_parse_content_length_in_buf\b/typeck_parse_content_length_in_buf/g;
  s/\blsp_io_extract_document_text\b/typeck_extract_document_text/g;
  s/\blsp_io_lsp_alloc\b/typeck_lsp_alloc/g;
  s/\blsp_io_lsp_free\b/typeck_lsp_free/g;
  s/\blsp_io_lsp_is_null\b/typeck_lsp_is_null/g;
  s/\blsp_io_LSP_/typeck_LSP_/g;
' seeds/lsp_io_gen.linux.x86_64.c

# lsp_gen：保留头（至 std_io 段末）+ io 薄 extern + lsp 主循环。
# 去掉 326–381 std_heap 实现（由 sx_seed_bridge.o / lsp_io_std_heap_sx.o 提供）；
# 去掉 382–579 内联 lsp_io 实现（由 lsp_io_sx.o 提供）；
# lsp_main 导出为 typeck_lsp_main_impl（typeck_lsp_main 由 lsp_state.o 包装）。
{
  awk 'NR>=1 && NR<=325 { print }' "$SRC"
  echo ""
  echo "/* C-04 -E-extern TU aliases (lsp_io via typeck_* from lsp_io_sx.o) */"
  awk 'NR>=580 && NR<=604 { print }' "$SRC"
  awk 'NR>=605 { print }' "$SRC"
} > seeds/lsp_gen.linux.x86_64.c

perl -i -pe '
  s/\btypeck_lsp_main\b/typeck_lsp_main_impl/g;
  s/uint8_t state_buf\[16388\] = \{ 0 \}/extern uint8_t g_lsp_state_buf[16388]/g;
  s/\(state_buf\)/(g_lsp_state_buf)/g;
' seeds/lsp_gen.linux.x86_64.c

rm -f seeds/_lsp_io_body.c

for f in lsp_io_gen lsp_gen; do
  sz=$(wc -c < "seeds/${f}.linux.x86_64.c" | tr -d ' ')
  echo "extract_lsp_gen_seeds: seeds/${f}.linux.x86_64.c ($sz bytes)"
done

echo "extract_lsp_gen_seeds OK"
