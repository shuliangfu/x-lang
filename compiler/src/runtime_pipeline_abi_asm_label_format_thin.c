/*
 * Thin pure: wave288 pipeline_asm_label_format Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE288_ASM_LABEL_FORMAT_ALWAYS (emit_next_label_c / format_label_id_c +
 * file-local format_u32/i32 helpers). No BSS. No FROM_X gate.
 * Callees: pipeline_asm_ctx_layout / pipeline_elf_label_mod_scope_active.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc asm_label_format Cap residual leave.
 */

/* XLANG_PABI_ASM_LABEL_FORMAT_THIN_BEGIN */

#include <stdint.h>
#include <stdio.h>

/* Prefer void* ctx (match pure export-extern + residual cold callers). */
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t pipeline_elf_label_mod_scope_active(void);

/* LE overlay: only first 4 i32 fields of AsmFuncCtx needed for label faces. */
typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
  int32_t label_counter;
} w288_AsmFuncCtxLayout;

/**
 * Write unsigned decimal into buf[off..]. Returns bytes written or -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave288).
 */
static int32_t w288_glue_format_u32_to_buf(uint8_t *buf, int32_t off, int32_t max, uint32_t val) {
  char tmp[16];
  int n;
  int i;
  if (!buf || max <= 0 || off < 0)
    return -1;
  n = snprintf(tmp, sizeof(tmp), "%u", (unsigned)val);
  if (n <= 0 || n > max)
    return -1;
  for (i = 0; i < n; i++)
    buf[off + i] = (uint8_t)tmp[i];
  return n;
}

/**
 * Write signed decimal into buf[off..]. Returns bytes written or -1.
 * PLATFORM: SHARED — seed ALWAYS residual (wave288).
 */
static int32_t w288_glue_format_i32_to_buf(uint8_t *buf, int32_t off, int32_t max, int32_t val) {
  char tmp[16];
  int n;
  int i;
  if (!buf || max <= 0 || off < 0)
    return -1;
  n = snprintf(tmp, sizeof(tmp), "%d", (int)val);
  if (n <= 0 || n > max)
    return -1;
  for (i = 0; i < n; i++)
    buf[off + i] = (uint8_t)tmp[i];
  return n;
}

/**
 * Emit unique local label ".Lf<scope>_<n>" into buf; advance label_counter.
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave288 seed ALWAYS).
 */
int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size) {
  w288_AsmFuncCtxLayout *ly;
  int32_t n;
  int32_t id;
  int32_t scope;
  int32_t off;
  if (!ctx || !buf || buf_size < 8)
    return -1;
  ly = (w288_AsmFuncCtxLayout *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  scope = pipeline_elf_label_mod_scope_active();
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'f';
  off = 3;
  n = w288_glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)scope);
  if (n <= 0)
    n = 1;
  off = off + n;
  if (off + 2 >= buf_size)
    return -1;
  buf[off] = (uint8_t)'_';
  off = off + 1;
  id = ly->label_counter;
  ly->label_counter = id + 1;
  n = w288_glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)id);
  if (n <= 0)
    n = 1;
  return off + n;
}

/**
 * Format fixed-prefix label ".L_<id>" into buf (does not advance counter).
 * @return total label length (>=4) or -1 on null/undersized buf.
 * PLATFORM: SHARED freestanding Cap leave (wave288 seed ALWAYS).
 */
int32_t pipeline_asm_format_label_id_c(uint8_t *buf, int32_t buf_size, int32_t id) {
  int32_t n;
  if (!buf || buf_size < 4)
    return -1;
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'_';
  n = w288_glue_format_i32_to_buf(buf, 3, buf_size - 3, id);
  if (n <= 0)
    n = 1;
  return 3 + n;
}

/* XLANG_PABI_ASM_LABEL_FORMAT_THIN_END */
