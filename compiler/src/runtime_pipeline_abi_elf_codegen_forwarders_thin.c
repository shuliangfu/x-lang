/*
 * Thin pure: wave291 pipeline_elf_codegen_forwarders Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE291_ELF_CODEGEN_FORWARDERS_ALWAYS (platform.elf / codegen_ / pipeline_
 * rename shims + pipeline_sizeof_elf_ctx). No BSS. No FROM_X gate.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc elf_codegen_forwarders Cap residual leave.
 */

/* XLANG_PABI_ELF_CODEGEN_FORWARDERS_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>

struct codegen_CodegenOutBuf;

/* Pure product callees (wave273 ELF + wave289 outbuf faces + codegen_x scratch). */
extern uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx);
extern void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
extern int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
extern void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx);
extern void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset);
extern int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx);
extern int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx);
extern int32_t pipeline_elf_pgo_hot_enabled(void);
extern void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
extern int32_t codegen_out_buf_len(void *out);
extern void codegen_out_buf_set_len(void *out, int32_t n);
extern uint8_t *pipeline_scratch_buf64(void);
extern uint8_t *pipeline_scratch_buf64_slot(int32_t slot);

/*
 * LP64 sizeof(struct platform_elf_ElfCodegenCtx) matching pipeline_gen /
 * platform/elf.x layout. Measured 27328560 on host; keep in lockstep.
 * PLATFORM: SHARED LP64 — not host sizeof() (struct incomplete in freestanding).
 */
#ifndef WAVE291_PIPELINE_ELF_CODEGEN_CTX_SIZE
#define WAVE291_PIPELINE_ELF_CODEGEN_CTX_SIZE ((size_t)27328560)
#endif

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sym_name_ptr.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
uint8_t *platform_elf_pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sym_name_copy64.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void platform_elf_pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, idx, dst);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_name_len.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_name_len(ctx_bytes, idx);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_sidecar_reset.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void platform_elf_pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes) {
  pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_offset_at.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_offset_at(ctx_bytes, idx);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_offset_set.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void platform_elf_pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset) {
  pipeline_elf_ctx_reloc_offset_set(ctx_bytes, idx, offset);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_reloc_shndx_at.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, idx);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_sym_shndx_at.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_sym_shndx_at(ctx_bytes, idx);
}

/**
 * platform.elf prefix → pipeline_elf_pgo_hot_enabled.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_pgo_hot_enabled(void) {
  return pipeline_elf_pgo_hot_enabled();
}

/**
 * platform.elf prefix → pipeline_elf_ctx_set_emit_hot.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void platform_elf_pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot) {
  pipeline_elf_ctx_set_emit_hot(ctx_bytes, hot);
}

/**
 * platform.elf prefix → pipeline_elf_ctx_append_bytes.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n) {
  return pipeline_elf_ctx_append_bytes(ctx_bytes, ptr, n);
}

/**
 * platform.elf prefix → pipeline_elf_write_o_pgo_to_buf.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t platform_elf_pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
}

/**
 * codegen_ prefix → codegen_out_buf_len.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t codegen_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len((void *)out);
}

/**
 * codegen_ prefix → codegen_out_buf_set_len.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void codegen_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len((void *)out, n);
}

/**
 * pipeline_ prefix → codegen_out_buf_len.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
int32_t pipeline_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len((void *)out);
}

/**
 * pipeline_ prefix → codegen_out_buf_set_len.
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
void pipeline_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len((void *)out, n);
}

/**
 * codegen_ prefix → pipeline_scratch_buf64 (BSS authority = codegen_x.o).
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
uint8_t *codegen_pipeline_scratch_buf64(void) {
  return pipeline_scratch_buf64();
}

/**
 * codegen_ prefix → pipeline_scratch_buf64_slot (BSS authority = codegen_x.o).
 * PLATFORM: SHARED — seed ALWAYS residual (wave291).
 */
uint8_t *codegen_pipeline_scratch_buf64_slot(int32_t slot) {
  return pipeline_scratch_buf64_slot(slot);
}

/**
 * pipeline_sizeof_elf_ctx — LP64 layout size for malloc of ElfCodegenCtx.
 * Freestanding Cap uses fixed size constant (no host sizeof(struct)).
 * PLATFORM: SHARED LP64.
 */
size_t pipeline_sizeof_elf_ctx(void) {
  return WAVE291_PIPELINE_ELF_CODEGEN_CTX_SIZE;
}

/* XLANG_PABI_ELF_CODEGEN_FORWARDERS_THIN_END */
