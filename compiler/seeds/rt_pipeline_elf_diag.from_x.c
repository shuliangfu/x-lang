/* seeds/rt_pipeline_elf_diag.from_x.c — G-02f-304 P2 runtime rest (elf ctx diag)
 * Logic source: src/runtime/rt_pipeline_elf_diag.x
 * Hybrid: SHUX_RT_PIPELINE_ELF_DIAG_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: runtime_pipeline_elf_ctx_diag_note（读表 + first patch / label match notes）。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define RUNTIME_PIPELINE_ELF_CTX_TABLE_CAP 16384

typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
} RuntimePipelineElfLabelEntry;

typedef struct {
  int32_t rel32_offset;
  uint8_t name[64];
  int32_t name_len;
  int32_t patch_imm_bits;
} RuntimePipelineElfPatchEntry;

typedef struct {
  int32_t code_len;
  RuntimePipelineElfLabelEntry labels[RUNTIME_PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_labels;
  RuntimePipelineElfPatchEntry patches[RUNTIME_PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_patches;
} RuntimePipelineElfCtxAccess;

extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report(const char *file, int line, int col, const char *kind, const char *msg, const char *detail);

/* G-02f-445：thin+rest PREFER_X_O
 *   thin .x provides 1 #[no_mangle] wrapper (calls *_impl in rest).
 *   rest seed C (compiled with -DSHUX_RT_PIPELINE_ELF_DIAG_FROM_X):
 *     - runtime_pipeline_elf_ctx_diag_note renamed to *_impl via macro.
 *   No #ifndef guard needed (no real .x implementation; .x is thin-only). */
#ifdef SHUX_RT_PIPELINE_ELF_DIAG_FROM_X
#define runtime_pipeline_elf_ctx_diag_note    runtime_pipeline_elf_ctx_diag_note_impl
#endif

void runtime_pipeline_elf_ctx_diag_note(uint8_t *ctx_bytes) {
  RuntimePipelineElfCtxAccess *ctx;
  int32_t l;
  char namebuf[65];

  if (!ctx_bytes)
    return;
  ctx = (RuntimePipelineElfCtxAccess *)ctx_bytes;
  diag_reportf(NULL, 0, 0, "note", NULL, "elf ctx code_len=%d num_labels=%d num_patches=%d", (int)ctx->code_len,
               (int)ctx->num_labels, (int)ctx->num_patches);
  if (ctx->num_patches <= 0)
    return;
  {
    RuntimePipelineElfPatchEntry *p = &ctx->patches[0];
    int32_t name_len = p->name_len > 64 ? 64 : p->name_len;
    int32_t i;
    if (name_len < 0)
      name_len = 0;
    for (i = 0; i < name_len; i++)
      namebuf[i] = (char)p->name[i];
    namebuf[name_len] = '\0';
    diag_reportf(NULL, 0, 0, "note", NULL, "elf first patch name_len=%d name='%s'", (int)p->name_len, namebuf);
    for (l = 0; l < ctx->num_labels; l++) {
      int32_t same = (ctx->labels[l].name_len == p->name_len);
      if (same && p->name_len > 0)
        same = (memcmp(ctx->labels[l].name, p->name, (size_t)p->name_len) == 0);
      if (same) {
        diag_reportf(NULL, 0, 0, "note", NULL, "elf label match at idx=%d offset=%d", (int)l,
                     (int)ctx->labels[l].offset);
        return;
      }
    }
  }
  diag_report(NULL, 0, 0, "note", "elf no label match for first patch", NULL);
}

int labi_rt_pipeline_elf_diag_slice_marker(void) {
  return 1;
}
