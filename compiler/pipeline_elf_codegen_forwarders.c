/* wave1181 G.7: elf/codegen prefix forwarder cluster (18 fns) migrated from
 * pipeline_glue.c to this domain file (same-TU #include below).
 *
 * Why centralize: pipeline.x / asm.x / platform.elf resolve extern symbols
 *   with module-prefixed names (platform_elf_pipeline_elf_*,
 *   codegen_codegen_out_buf_*, pipeline_codegen_out_buf_*,
 *   codegen_pipeline_scratch_buf64*) at import time, but the authoritative
 *   implementations live in ast_pool.c / pipeline_elf.c / codegen.c with
 *   unprefixed C names. These 18 thin forwarders exist solely to satisfy the
 *   linker name-mangling gap; colocating them here keeps pipeline_glue.c
 *   focused on real glue logic instead of rename shims.
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_ / codegen_ impl.
 *   Adding logic here violates the forwarder-only invariant; fix the
 *   authoritative impl instead.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic; underlying impls may
 *   differ per arch but the symbol surface is identical on macOS/Ubuntu.
 */

/* --- platform.elf prefix forwarders (12 fns) ----------------------------
 * platform.elf module calls carry platform_elf_ prefix at codegen time;
 * these forward to the unprefixed pipeline_elf_* implementations in
 * ast_pool.c / pipeline_elf.c (ElfCodegenCtx byte-buffer accessors).
 */

/**
 * Return a pointer to the relocation symbol name bytes at slot idx.
 * Why: platform.elf CALL needs the raw name bytes to emit a symtab entry;
 *      the authoritative layout lives in ElfCodegenCtx (ast_pool.c).
 * Contract: idx must be a valid reloc slot; NULL only if ctx has no reloc
 *           at idx (delegates to pipeline_elf_ctx_reloc_sym_name_ptr).
 */
uint8_t *platform_elf_pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
}

/**
 * Copy up to 64 bytes of the reloc symbol name at slot idx into dst.
 * Why: platform.elf builds a fixed 64-byte name field for symtab; the copy
 *      boundary (64) matches the ElfCodegenCtx name slot width.
 * Contract: dst must point to >=64 writable bytes; no partial-write report.
 */
void platform_elf_pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, idx, dst);
}

/**
 * Return the byte length of the reloc symbol name at slot idx.
 * Why: platform.elf needs the true name length (<=64) to zero-pad the
 *      symtab name field without overrunning.
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_name_len(ctx_bytes, idx);
}

/**
 * Reset the reloc sidecar table in ctx_bytes.
 * Why: a fresh .o emit pass must clear stale reloc entries left by the
 *      previous function; the sidecar is the per-ctx reloc index.
 * Contract: clears all reloc slots; no return value.
 */
void platform_elf_pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes) {
  pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
}

/**
 * Return the r_offset of the reloc at slot idx.
 * Why: platform.elf writes r_offset into the Elf32_Rel/Elf64_Rel entry;
 *      the value is the section-relative byte offset of the patched call.
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_offset_at(ctx_bytes, idx);
}

/**
 * Set the r_offset of the reloc at slot idx.
 * Why: asm backend records the patch site offset after emitting the call
 *      instruction so the linker can fix up the rel32 displacement.
 */
void platform_elf_pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset) {
  pipeline_elf_ctx_reloc_offset_set(ctx_bytes, idx, offset);
}

/**
 * Return the r_info shndx field of the reloc at slot idx.
 * Why: platform.elf packs shndx into r_info to identify which section the
 *      reloc applies to (typically .text for call sites).
 */
int32_t platform_elf_pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, idx);
}

/**
 * Return the shndx of the symbol at slot idx (symtab view, not reloc view).
 * Why: platform.elf emits st_shndx into the symtab entry to bind a symbol
 *      to its defining section (e.g. .text for functions).
 */
int32_t platform_elf_pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  return pipeline_elf_ctx_sym_shndx_at(ctx_bytes, idx);
}

/**
 * Return 1 if PGO hot-path emission is enabled, 0 otherwise.
 * Why: asm backend branches on this to emit hot/cold section annotations;
 *      gated by a build-time flag in the authoritative impl.
 */
int32_t platform_elf_pipeline_elf_pgo_hot_enabled(void) {
  return pipeline_elf_pgo_hot_enabled();
}

/**
 * Mark ctx_bytes as emitting a hot (1) or cold (0) section.
 * Why: PGO tags each function's .o fragment so the linker can group hot
 *      functions into a contiguous .text.hot for icache locality.
 */
void platform_elf_pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot) {
  pipeline_elf_ctx_set_emit_hot(ctx_bytes, hot);
}

/**
 * Append n bytes from ptr into the ctx_bytes code buffer.
 * Why: asm backend streams raw instruction bytes into ElfCodegenCtx; the
 *      authoritative impl manages the buffer cursor and capacity.
 * Contract: ptr must point to >=n readable bytes; returns new cursor or -1.
 */
int32_t platform_elf_pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n) {
  return pipeline_elf_ctx_append_bytes(ctx_bytes, ptr, n);
}

/**
 * Write the PGO-tagged .o fragment from ctx_bytes into out buf.
 * Why: after emitting a function's bytes, the backend flushes the ctx into
 *      the final CodegenOutBuf so the linker sees a complete .o section.
 * Contract: out must be a valid CodegenOutBuf with remaining capacity.
 */
int32_t platform_elf_pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
}

/* --- codegen_ / pipeline_ prefix out_buf forwarders (4 fns) -------------
 * pipeline.x and codegen.x resolve extern out_buf accessors with a doubled
 * codegen_codegen_ or pipeline_codegen_ prefix; forward to the canonical
 * codegen_out_buf_* impl in codegen.c.
 */

/**
 * Return the current used length of the CodegenOutBuf.
 * Why: pipeline.x reads out->len to know how many bytes were emitted so far;
 *      the codegen_ prefix is the import-name artifact.
 */
int32_t codegen_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len(out);
}

/**
 * Set the used length of the CodegenOutBuf to n.
 * Why: asm backend updates the cursor after a raw byte append to keep
 *      out->len in sync with the actual buffer fill level.
 */
void codegen_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len(out, n);
}

/**
 * Return the current used length of the CodegenOutBuf (pipeline_ alias).
 * Why: pipeline.x uses pipeline_codegen_ prefix for the same accessor;
 *      identical semantics to codegen_codegen_out_buf_len.
 */
int32_t pipeline_codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  return codegen_out_buf_len(out);
}

/**
 * Set the used length of the CodegenOutBuf to n (pipeline_ alias).
 * Why: pipeline.x uses pipeline_codegen_ prefix for the same setter;
 *      identical semantics to codegen_codegen_out_buf_set_len.
 */
void pipeline_codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  codegen_out_buf_set_len(out, n);
}

/* --- codegen_ prefix scratch_buf64 forwarders (2 fns) -------------------
 * asm.x resolves extern scratch accessors with a codegen_ prefix; forward
 * to the canonical pipeline_scratch_buf64* impl in ast_pool.c.
 */

/**
 * Return a pointer to the 64-byte scratch buffer (slot 0).
 * Why: asm backend uses a fixed 64-byte scratch for temporary byte assembly
 *      (e.g. building a reloc name field) without stack allocation; the
 *      authoritative static buffer lives in ast_pool.c.
 * Contract: returns a stable pointer valid until the next call.
 */
uint8_t *codegen_pipeline_scratch_buf64(void) {
  return pipeline_scratch_buf64();
}

/**
 * Return a pointer to scratch slot `slot` (64 bytes each).
 * Why: asm backend needs up to N independent 64-byte scratches when nesting
 *      emit passes (e.g. outer reloc name + inner symtab field); slot index
 *      selects which static buffer to use.
 * Contract: slot must be in [0, SCRATCH_SLOT_COUNT); stable pointer.
 */
uint8_t *codegen_pipeline_scratch_buf64_slot(int32_t slot) {
  return pipeline_scratch_buf64_slot(slot);
}

/* wave1213 G.7: pipeline_sizeof_elf_ctx migrated from pipeline_glue.c L356-361.
 * Returns sizeof(struct platform_elf_ElfCodegenCtx); #ifdef guard for parser
 * exe TU (XLANG_PARSER_EXE_PIPELINE_GLUE) returns 0 when struct is incomplete.
 * Colocated with elf_codegen_forwarders.c (ELF codegen domain; #include at
 * glue.c L2971). No TU-internal callsites — sole consumers are seeds
 * (rt_run_asm_backend.from_x.c L393/403 via extern). The #ifdef guard is
 * TU-level — behavior identical at any position within the same TU.
 * PLATFORM: SHARED LP64. */
#ifndef XLANG_PARSER_EXE_PIPELINE_GLUE
size_t pipeline_sizeof_elf_ctx(void) { return sizeof(struct platform_elf_ElfCodegenCtx); }
#else
size_t pipeline_sizeof_elf_ctx(void) { return (size_t)0; }
#endif /* XLANG_PARSER_EXE_PIPELINE_GLUE */
