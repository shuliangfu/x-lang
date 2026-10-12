/* seeds/rt_pipeline_elf_diag.from_x.c — G-02f-304 P2 runtime rest (elf ctx diag)
 * Logic source: src/runtime/rt_pipeline_elf_diag.x and the three sibling .x files
 * (find, kind, note). w1137: Darwin and the prefer path pure-asm those four
 * files and ld -r them. This seed stays the cold body and the marker-only
 * rest under XLANG_RT_PIPELINE_ELF_DIAG_FROM_X.
 * Hybrid: XLANG_RT_PIPELINE_ELF_DIAG_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：runtime_pipeline_elf_ctx_diag_note 由 .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * Scope: runtime_pipeline_elf_ctx_diag_note（读表 + first patch / label match notes）。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#define RUNTIME_PIPELINE_ELF_CTX_TABLE_CAP 16384
/* wave651 twin: patches-only 65536 (layout must match pabi ctx). */
#define RUNTIME_PIPELINE_ELF_CTX_PATCH_CAP 65536
/* wave652 twin: labels-only 65536 (layout must match pabi ctx). */
#define RUNTIME_PIPELINE_ELF_CTX_LABEL_CAP 65536

typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t offset;
} RuntimePipelineElfLabelEntry;

typedef struct {
  int32_t rel32_offset;
  uint8_t name[256];
  int32_t name_len;
  int32_t patch_imm_bits;
} RuntimePipelineElfPatchEntry;

typedef struct {
  int32_t code_len;
  RuntimePipelineElfLabelEntry labels[RUNTIME_PIPELINE_ELF_CTX_LABEL_CAP];
  int32_t num_labels;
  RuntimePipelineElfPatchEntry patches[RUNTIME_PIPELINE_ELF_CTX_PATCH_CAP];
  int32_t num_patches;
} RuntimePipelineElfCtxAccess;

extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt,
                         ...);
extern void diag_report(const char *file, int line, int col, const char *kind, const char *msg, const char *detail);

#ifndef XLANG_RT_PIPELINE_ELF_DIAG_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_PIPELINE_ELF_DIAG_FROM_X removed */
#else
void runtime_pipeline_elf_ctx_diag_note(uint8_t *ctx_bytes);

int labi_rt_pipeline_elf_diag_slice_marker(void) {
  return 1;
}
#endif /* !XLANG_RT_PIPELINE_ELF_DIAG_FROM_X */
