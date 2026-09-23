/*
 * wave744 leftover-gcc sidecar: F7 data-section length/buffer family that
 * writes BOTH BSS homes so leftover compact macho_write sees the bake.
 *
 * G.1 (Darwin Lxml S n_sect=2 with nsects=1):
 *   Producer: leftover gcc emit_data_len / append_data_zeros / data_poke_u8
 *     (unique weak T) RIP-load .x named g_pipe_elf_data_len / g_pipe_elf_data_buf.
 *     wave344 non-zero scalar imm (asm_wpo_thin g_aw_root_id = -1) add_sym's
 *     SHNX_DATA and bakes into that mega home.
 *   Store: two BSS homes in product pabi — .x g_pipe_elf_data_* and leftover
 *     compact-writer static g_pipeline_elf_data_*.
 *   Consumer: leftover WAVE273 macho_write inlines g_pipeline_elf_data_len
 *     + g_pipeline_elf_data_buf. Leftover C len stays 0 → omit __DATA
 *     (nsects=1) while the DATA-shndx Lxml is still n_sect=2 → ld
 *     "n_sect=2 out of bounds".
 *
 * This TU is a strong T first-wins of leftover gcc weak emit/append/poke
 * (and mega smash T of reset / data_ptr / append_u32 after inject weaken).
 * It does not gcc -E .x, does not PREFER macho_write_thin, does not ld -r
 * into pabi (Darwin libtool n_sect). Inject globalizes the leftover C
 * statics so this sidecar can write them.
 *
 * PLATFORM: SHARED leftover gcc sidecar · LINUX gold · MACOS writer co-path.
 */
#include <stdint.h>
#include <string.h>

enum { W744_PIPE_ELF_DATA_CAP = 65536 };

/* .x named BSS (leftover gcc emit/append/poke already write this home). */
extern uint8_t g_pipe_elf_data_buf[W744_PIPE_ELF_DATA_CAP];
extern int32_t g_pipe_elf_data_len;
extern uint8_t *g_pipe_elf_data_owner;

/* Leftover compact-writer homes (macho_write inlines len+buf).
 * data_owner is .x-only in product pabi (leftover C owner was unused and
 * dropped from this TU).
 * Darwin and Windows pabi already export these two names (Darwin aliases
 * data_len onto g_pipe_elf_data_len). Linux pure-asm pabi emits only the
 * g_pipe_elf_data_* names, so this TU owns the g_pipeline_elf_data_* BSS
 * there — the same split the reloc overlay uses for g_pipeline_elf_reloc_*.
 * PLATFORM: LINUX|UBUNTU definition. MACOS|WINDOWS extern (pabi owns them). */
#if defined(__APPLE__) || defined(_WIN32)
extern uint8_t g_pipeline_elf_data_buf[W744_PIPE_ELF_DATA_CAP];
extern int32_t g_pipeline_elf_data_len;
#else
uint8_t g_pipeline_elf_data_buf[W744_PIPE_ELF_DATA_CAP];
int32_t g_pipeline_elf_data_len;
#endif

/**
 * Clamp a data_len to [0, CAP].
 * @param n raw length (may be negative)
 * @return clamped length
 * PLATFORM: SHARED leftover gcc sidecar.
 */
static int32_t w744_clamp_len(int32_t n) {
  if (n < 0)
    return 0;
  if (n > W744_PIPE_ELF_DATA_CAP)
    return W744_PIPE_ELF_DATA_CAP;
  return n;
}

/**
 * Copy the longer F7 data home onto the shorter so both BSS match.
 * Writer inlines leftover C; bake currently grows the mega home. First
 * sidecar call in a module copies mega→leftover C when leftover C is empty.
 * PLATFORM: SHARED leftover gcc sidecar · MACOS writer co-path.
 */
static void w744_sync_homes(void) {
  int32_t n_pipe;
  int32_t n_pl;
  n_pipe = w744_clamp_len(g_pipe_elf_data_len);
  n_pl = w744_clamp_len(g_pipeline_elf_data_len);
  g_pipe_elf_data_len = n_pipe;
  g_pipeline_elf_data_len = n_pl;
  if (n_pipe > n_pl) {
    memcpy(g_pipeline_elf_data_buf, g_pipe_elf_data_buf, (size_t)n_pipe);
    g_pipeline_elf_data_len = n_pipe;
  } else if (n_pl > n_pipe) {
    memcpy(g_pipe_elf_data_buf, g_pipeline_elf_data_buf, (size_t)n_pl);
    g_pipe_elf_data_len = n_pl;
  }
}

/**
 * Reset both F7 data homes at module start.
 * @param ctx_bytes ElfCodegenCtx* (owner cookie; may be null)
 * PLATFORM: SHARED leftover gcc sidecar.
 */
void pipeline_elf_ctx_reset_data(uint8_t *ctx_bytes) {
  g_pipe_elf_data_len = 0;
  g_pipeline_elf_data_len = 0;
  g_pipe_elf_data_owner = ctx_bytes;
}

/**
 * Current data-section length after syncing both homes.
 * Writer reads leftover C; bake uses the return as the next-cell offset.
 * @param ctx_bytes ElfCodegenCtx*
 * @return length in 0..CAP; 0 if ctx is null
 * PLATFORM: SHARED leftover gcc sidecar · MACOS writer co-path.
 */
int32_t pipeline_elf_ctx_emit_data_len(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return 0;
  w744_sync_homes();
  return g_pipeline_elf_data_len;
}

/**
 * Pointer to leftover-C data buf (the home macho_write inlines).
 * @param ctx_bytes ElfCodegenCtx*
 * @return leftover C buf, or null if ctx is null
 * PLATFORM: SHARED leftover gcc sidecar · MACOS writer co-path.
 */
uint8_t *pipeline_elf_ctx_data_data_ptr(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return 0;
  w744_sync_homes();
  return &g_pipeline_elf_data_buf[0];
}

/**
 * Append n zero bytes to both F7 data homes.
 * @param ctx_bytes ElfCodegenCtx*
 * @param n byte count; n<=0 is success no-op
 * @return 0 ok, -1 overflow/null
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t pipeline_elf_ctx_append_data_zeros(uint8_t *ctx_bytes, int32_t n) {
  int32_t off;
  if (!ctx_bytes)
    return -1;
  if (n <= 0)
    return 0;
  w744_sync_homes();
  off = g_pipeline_elf_data_len;
  if (off + n > W744_PIPE_ELF_DATA_CAP)
    return -1;
  memset(&g_pipeline_elf_data_buf[off], 0, (size_t)n);
  memset(&g_pipe_elf_data_buf[off], 0, (size_t)n);
  g_pipeline_elf_data_len = off + n;
  g_pipe_elf_data_len = off + n;
  return 0;
}

/**
 * Append a little-endian u32 to both F7 data homes.
 * @param ctx_bytes ElfCodegenCtx*
 * @param word payload
 * @return 0 ok, -1 overflow/null
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t pipeline_elf_ctx_append_data_u32_le(uint8_t *ctx_bytes, uint32_t word) {
  int32_t off;
  if (!ctx_bytes)
    return -1;
  w744_sync_homes();
  off = g_pipeline_elf_data_len;
  if (off + 4 > W744_PIPE_ELF_DATA_CAP)
    return -1;
  g_pipeline_elf_data_buf[off] = (uint8_t)(word & 255);
  g_pipeline_elf_data_buf[off + 1] = (uint8_t)((word >> 8) & 255);
  g_pipeline_elf_data_buf[off + 2] = (uint8_t)((word >> 16) & 255);
  g_pipeline_elf_data_buf[off + 3] = (uint8_t)((word >> 24) & 255);
  g_pipe_elf_data_buf[off] = g_pipeline_elf_data_buf[off];
  g_pipe_elf_data_buf[off + 1] = g_pipeline_elf_data_buf[off + 1];
  g_pipe_elf_data_buf[off + 2] = g_pipeline_elf_data_buf[off + 2];
  g_pipe_elf_data_buf[off + 3] = g_pipeline_elf_data_buf[off + 3];
  g_pipeline_elf_data_len = off + 4;
  g_pipe_elf_data_len = off + 4;
  return 0;
}

/**
 * Poke one byte into both already-reserved F7 data homes.
 * @param ctx_bytes ElfCodegenCtx*
 * @param off offset in the current data_len
 * @param b low 8 bits stored
 * @return 0 ok, -1 OOB/null
 * PLATFORM: SHARED leftover gcc sidecar.
 */
int32_t pipeline_elf_ctx_data_poke_u8(uint8_t *ctx_bytes, int32_t off, int32_t b) {
  uint8_t v;
  if (!ctx_bytes || off < 0)
    return -1;
  w744_sync_homes();
  if (off >= g_pipeline_elf_data_len)
    return -1;
  v = (uint8_t)(b & 255);
  g_pipeline_elf_data_buf[off] = v;
  g_pipe_elf_data_buf[off] = v;
  return 0;
}
