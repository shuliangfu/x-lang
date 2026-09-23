/*
 * wave743 leftover-gcc sidecar: pipeline_elf_ctx_append_reloc_typed that
 * binds BOTH reloc-type BSS homes and writes PAGE21/PAGEOFF12 rows into both.
 *
 * G.1 (Darwin COMMON lea BRANCH26):
 *   Producer: leftover gcc glue_asm_lea_rax_common_adrp_arm64 calls the
 *     unique global append_reloc_typed (writes g_pipe_elf_reloc_r_type,
 *     no owner bind).
 *   Store: two BSS homes in product pabi — .x g_pipe_elf_reloc_r_* and
 *     leftover compact-writer static g_pipeline_elf_reloc_r_*.
 *   Consumer: leftover WAVE273 macho_write inlines reloc_r_type_at against
 *     g_pipeline_elf_reloc_r_type + sidecar_owner. Owner mismatch / empty
 *     row → r_type 0 → ARM64_RELOC_BRANCH26 on adrp+add of file-level let.
 *
 * This TU is a strong T first-wins of leftover gcc weak append_reloc_typed.
 * It does not gcc -E .x, does not PREFER macho_write_thin, does not ld -r
 * into pabi (Darwin libtool n_sect). Inject globalizes the leftover C
 * statics so this sidecar can write them.
 *
 * PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS writer co-path.
 */
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name,
                                             int32_t name_len);
extern int32_t pipe_load_i32_le(uint8_t *base, int32_t off);

/* .x named BSS (leftover gcc lea already wrote this home). */
extern int32_t g_pipe_elf_reloc_r_type[];
extern uint8_t g_pipe_elf_reloc_r_pcrel[];
extern uint8_t *g_pipe_elf_reloc_sidecar_owner;

/* Leftover compact-writer BSS home (macho_write inlines this).
 * wave831 CB-fix: tip cold Win link needs a defining TU — overlay owns
 * these globals (from_x keeps file-static twins). PLATFORM: SHARED. */
int32_t g_pipeline_elf_reloc_r_type[16384];
int8_t g_pipeline_elf_reloc_r_pcrel[16384];
uint8_t *g_pipeline_elf_reloc_sidecar_owner;

enum {
  W743_PIPE_ELF_OFF_NUM_RELOCS = 39190540,
  W743_PIPE_ELF_TABLE_CAP = 16384
};

/**
 * Append reloc with explicit r_type / r_pcrel and bind both sidecar owners.
 * @param ctx_bytes ElfCodegenCtx*
 * @param offset byte offset of the instruction
 * @param name reloc symbol bytes
 * @param name_len symbol length; must be > 0
 * @param r_type 3=PAGE21, 4=PAGEOFF12, 200=absolute64
 * @param r_pcrel 1 for PAGE21, 0 for PAGEOFF12; negative → 255 default
 * @return 0 ok, -1 fail
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name,
                                            int32_t name_len, int32_t r_type, int32_t r_pcrel) {
  int32_t ri;
  uint8_t pv;
  if (pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len) != 0)
    return -1;
  /* First typed row for this ctx: leftover compact macho_write inlines the
   * leftover C statics. Untyped call rows never write that home; BSS zero
   * pcrel would become BRANCH26 with r_pcrel=0 (ld rejects). Prefill pcrel
   * to 255 (-1) so those slots keep the writer default pcrel=1.
   * PLATFORM: MACOS writer co-path · SHARED sidecar. */
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes) {
    memset(g_pipeline_elf_reloc_r_type, 0, (size_t)W743_PIPE_ELF_TABLE_CAP * 4u);
    memset(g_pipeline_elf_reloc_r_pcrel, 0xff, (size_t)W743_PIPE_ELF_TABLE_CAP);
  }
  g_pipe_elf_reloc_sidecar_owner = ctx_bytes;
  g_pipeline_elf_reloc_sidecar_owner = ctx_bytes;
  ri = pipe_load_i32_le(ctx_bytes, W743_PIPE_ELF_OFF_NUM_RELOCS) - 1;
  if (ri < 0 || ri >= W743_PIPE_ELF_TABLE_CAP)
    return 0;
  g_pipe_elf_reloc_r_type[ri] = r_type;
  g_pipeline_elf_reloc_r_type[ri] = r_type;
  if (r_pcrel < 0)
    pv = 255;
  else
    pv = (uint8_t)(r_pcrel != 0 ? 1 : 0);
  g_pipe_elf_reloc_r_pcrel[ri] = pv;
  g_pipeline_elf_reloc_r_pcrel[ri] = (int8_t)pv;
  return 0;
}
