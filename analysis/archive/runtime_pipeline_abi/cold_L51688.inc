/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after F7 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave273 after F7 */

/** PGO-Lite ELF 段索引（与 write_elf_o_pgo 中 shdr 顺序一致）。 */
enum {
  PIPELINE_ELF_SHNX_TEXT = 1,
  PIPELINE_ELF_SHNX_TEXT_HOT = 2,
  PIPELINE_ELF_SHNX_TEXT_UNLIKELY = 3,
  /* F7: read-only data section for vtable static data with absolute pointer
   * relocations. Maps to __DATA,__const on Mach-O. */
  PIPELINE_ELF_SHNX_DATA = 4
};

/** 当前 emit 的 ELF 段索引：hot→2，PGO 冷路径→3，否则→1。
 * F7: respects the shndx override (when non-zero, returns it so new
 * relocs/syms/labels are tagged as data-section). */
static int32_t pipeline_elf_ctx_current_shndx(PipelineElfCtxAccess *ctx) {
  if (!ctx)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_shndx_override != 0)
    return g_pipeline_elf_shndx_override;
  if (pipeline_elf_pgo_hot_enabled()) {
    if (ctx->emit_hot != 0)
      return PIPELINE_ELF_SHNX_TEXT_HOT;
    return PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
  }
  return PIPELINE_ELF_SHNX_TEXT;
}

/** 按段索引取 code 缓冲指针（unlikely 与 legacy .text 共用 code_data）。 */
static uint8_t *pipeline_elf_ctx_code_buf(uint8_t *ctx_bytes, int32_t shndx) {
  if (shndx == PIPELINE_ELF_SHNX_TEXT_HOT)
    return ctx_bytes + kPipelineElfCtxCodeHotDataOff;
  return ctx_bytes + kPipelineElfCtxCodeDataOff;
}

/** 按段索引读已编码长度。 */
static int32_t pipeline_elf_ctx_section_len(PipelineElfCtxAccess *ctx, int32_t shndx) {
  if (!ctx)
    return 0;
  if (shndx == PIPELINE_ELF_SHNX_TEXT_HOT)
    return ctx->code_hot_len;
  return ctx->code_len;
}

/**
 * 向当前 emit 段追加机器码字节（append_elf_bytes 统一 C 路由，避免 partial .o 与 ctx 布局漂移）。
 * 返回 0 成功，-1 缓冲满。
 */
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n) {
  PipelineElfCtxAccess *ctx;
  uint8_t *buf;
  int32_t *len_slot;
  int32_t i;
  if (!ctx_bytes || !ptr || n < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (pipeline_elf_pgo_hot_enabled() && ctx->emit_hot != 0) {
    buf = ctx_bytes + kPipelineElfCtxCodeHotDataOff;
    len_slot = &ctx->code_hot_len;
    if (*len_slot + n > (int32_t)PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP)
      return -1;
  } else {
    buf = ctx_bytes + kPipelineElfCtxCodeDataOff;
    len_slot = &ctx->code_len;
    if (*len_slot + n > (int32_t)PIPELINE_ELF_CTX_CODE_BUF_CAP)
      return -1;
  }
  for (i = 0; i < n; i++)
    buf[*len_slot + i] = ptr[i];
  *len_slot = *len_slot + n;
  return 0;
}

/** num_relocs > TABLE_CAP 时的堆 sidecar（单 ctx 编译期有效；elf_ctx_reset 绑定 owner）。 */
static uint8_t *g_pipeline_elf_reloc_sidecar_owner;
static PipelineElfRelocHeapEntry g_pipeline_elf_reloc_heap[PIPELINE_ELF_CTX_RELOC_HEAP_CAP];
/* Cap 4.2.8: heap reloc sym rows match reloc_sym_names.bytes[256] (was [128]). */
static uint8_t g_pipeline_elf_reloc_sym_heap[PIPELINE_ELF_CTX_RELOC_HEAP_CAP][256];

/** PGO 段索引 sidecar：内联 labels/patches/relocs 无 code_shndx 字段（与 elf.x 布局对齐）。 */
static uint8_t *g_pipeline_elf_shndx_sidecar_owner;
static int32_t g_pipeline_elf_label_shndx[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_patch_shndx[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_reloc_shndx[PIPELINE_ELF_CTX_TABLE_CAP];

/**
 * PLATFORM: SHARED — SHN_COMMON object sidecar (module mutable lets → linker BSS).
 * Declared before write_elf so standard/pgo writers can emit COMMON st_shndx/size.
 */
static uint8_t *g_pipeline_elf_common_owner;
static uint8_t g_pipeline_elf_sym_is_common[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_sym_common_size[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_sym_common_align[PIPELINE_ELF_CTX_TABLE_CAP];

/**
 * PLATFORM: SHARED — per-reloc type/pcrel sidecar (wave405 arm64 ADRP/PAGEOFF for modlet).
 * r_type 0 => fall back to call reloc default (Mach-O BRANCH26 / ELF reloc_type_r_pc32).
 * r_pcrel: -1 = default (1 for call-style); 0/1 explicit (PAGEOFF12 needs pcrel=0).
 *
 * wave612: leftover-PE / gcc rest still own this static, but the live product
 * append_reloc_typed is the elf_ctx PREFER overlay (different BSS). Mach-O
 * write must consume pipeline_elf_ctx_reloc_r_type_at — not this array —
 * or ADRP of file-level let COMMON is emitted as BRANCH26.
 */
static int32_t g_pipeline_elf_reloc_r_type[PIPELINE_ELF_CTX_TABLE_CAP];
static int8_t g_pipeline_elf_reloc_r_pcrel[PIPELINE_ELF_CTX_TABLE_CAP];
int32_t pipeline_elf_ctx_reloc_r_type_at(uint8_t *ctx_bytes, int32_t r);
int32_t pipeline_elf_ctx_reloc_r_pcrel_at(uint8_t *ctx_bytes, int32_t r);

/* F7 BSS (g_pipeline_elf_data_* / g_pipeline_elf_shndx_override) lives in the
 * leftover-PE OR block above so WIN FROM_X rest and the cold path both see
 * the declaration before first use. Do not re-declare here (duplicate static). */

static void pipeline_elf_common_sidecar_reset(uint8_t *ctx_bytes) {
  g_pipeline_elf_common_owner = ctx_bytes;
  memset(g_pipeline_elf_sym_is_common, 0, sizeof(g_pipeline_elf_sym_is_common));
  memset(g_pipeline_elf_sym_common_size, 0, sizeof(g_pipeline_elf_sym_common_size));
  memset(g_pipeline_elf_sym_common_align, 0, sizeof(g_pipeline_elf_sym_common_align));
}

/** 未显式记录时的默认 reloc 段索引。 */
static int32_t pipeline_elf_default_reloc_shndx(void) {
  return pipeline_elf_pgo_hot_enabled() ? PIPELINE_ELF_SHNX_TEXT_UNLIKELY : PIPELINE_ELF_SHNX_TEXT;
}

/** 重置 label/patch/reloc 段 sidecar（与 elf_ctx_reset 同步）。 */
static void pipeline_elf_shndx_sidecar_reset(uint8_t *ctx_bytes) {
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  memset(g_pipeline_elf_label_shndx, 0, sizeof(g_pipeline_elf_label_shndx));
  memset(g_pipeline_elf_patch_shndx, 0, sizeof(g_pipeline_elf_patch_shndx));
  memset(g_pipeline_elf_reloc_shndx, 0, sizeof(g_pipeline_elf_reloc_shndx));
}

static int32_t pipeline_elf_label_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_shndx_sidecar_owner != ctx_bytes || g_pipeline_elf_label_shndx[idx] == 0)
    return pipeline_elf_default_reloc_shndx();
  return g_pipeline_elf_label_shndx[idx];
}

static void pipeline_elf_label_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return;
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  g_pipeline_elf_label_shndx[idx] = shndx;
}

static int32_t pipeline_elf_patch_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_shndx_sidecar_owner != ctx_bytes || g_pipeline_elf_patch_shndx[idx] == 0)
    return pipeline_elf_default_reloc_shndx();
  return g_pipeline_elf_patch_shndx[idx];
}

static void pipeline_elf_patch_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return;
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  g_pipeline_elf_patch_shndx[idx] = shndx;
}

static void pipeline_elf_reloc_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0)
    return;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
    g_pipeline_elf_reloc_shndx[idx] = shndx;
    return;
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  idx = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (idx >= 0 && idx < PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    g_pipeline_elf_reloc_heap[idx].code_shndx = shndx;
}

/** elf_ctx_reset：绑定 sidecar owner；num_relocs 清零后 heap 槽位可复用。 */
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes) {
  g_pipeline_elf_reloc_sidecar_owner = ctx_bytes;
  pipeline_elf_shndx_sidecar_reset(ctx_bytes);
  memset(g_pipeline_elf_reloc_r_type, 0, sizeof(g_pipeline_elf_reloc_r_type));
  memset(g_pipeline_elf_reloc_r_pcrel, 0xff, sizeof(g_pipeline_elf_reloc_r_pcrel)); /* -1 default */
}

/** 读第 idx 条 reloc 的 code offset（内联或 heap sidecar）。 */
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return 0;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->relocs[idx].offset;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return 0;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return 0;
  return g_pipeline_elf_reloc_heap[hi].offset;
}

/** 读第 idx 条 reloc 的目标段（1=.text，2=.text.hot）。 */
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return PIPELINE_ELF_SHNX_TEXT;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    if (g_pipeline_elf_shndx_sidecar_owner == ctx_bytes && g_pipeline_elf_reloc_shndx[idx] != 0)
      return g_pipeline_elf_reloc_shndx[idx];
    return pipeline_elf_default_reloc_shndx();
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return PIPELINE_ELF_SHNX_TEXT;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_reloc_heap[hi].code_shndx != 0)
    return g_pipeline_elf_reloc_heap[hi].code_shndx;
  return pipeline_elf_default_reloc_shndx();
}

/** 读第 idx 个导出符号的 st_shndx（1=.text，2=.text.hot）。 */
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || idx < 0)
    return 1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_syms)
    return PIPELINE_ELF_SHNX_TEXT;
  if (ctx->syms[idx].sym_shndx != 0)
    return ctx->syms[idx].sym_shndx;
  return pipeline_elf_pgo_hot_enabled() ? PIPELINE_ELF_SHNX_TEXT_UNLIKELY : PIPELINE_ELF_SHNX_TEXT;
}

/** 返回 .text 机器码缓冲指针（glue 统一偏移；write_elf_o 须经此读，勿直接用 X code_data[]）。 */
uint8_t *pipeline_elf_ctx_code_data_ptr(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return NULL;
  return pipeline_elf_ctx_code_buf(ctx_bytes, PIPELINE_ELF_SHNX_TEXT);
}

/** 向 CodegenOutBuf 追加字节；layout 与 codegen.x 一致。 */
/* wave1246: ELF/Mach-O .o write cluster (standard + PGO + macho) migrated to
 * pipeline_elf_write_o.c (same-TU #include). Members:
 *   pipeline_elf_out_append, pipeline_elf_sym_name_off, pipeline_elf_reloc_is_defined,
 *   pipeline_elf_call_reloc_type, pipeline_elf_rela_set_addend64,
 *   pipeline_elf_write_o_standard_to_buf_c,
 *   pipeline_macho_link_name_extra_byte, pipeline_macho_name_eq,
 *   pipeline_macho_write_o_to_buf_c, platform_macho_write_macho_o_to_buf,
 *   pipeline_elf_write_o_pgo_to_buf.
 * PLATFORM: SHARED — host-cc still compiles via ast_pool mega-TU.
 */

/* wave273: inlined write_o cold twin body */
/* ============================================================================
 * pipeline_elf_write_o.c — ELF64 ET_REL + Mach-O MH_OBJECT .o writers
 *
 * wave1246 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   pipeline_elf_out_append + write/reloc helpers
 *   pipeline_elf_write_o_standard_to_buf_c
 *   pipeline_macho_write_o_to_buf_c + platform_macho_write_macho_o_to_buf
 *   pipeline_elf_write_o_pgo_to_buf
 *
 * Included from ast_pool.c after PipelineElfCtxAccess layout / code_data ptr
 * helpers so writers share one layout authority (G.7). Not a separate .o.
 *
 * PLATFORM: SHARED layout; ELF writer primary on LINUX; Mach-O body for MACOS
 * product pure-asm (linked everywhere, used when use_macho_o).
 * ============================================================================ */

static int32_t pipeline_elf_out_append(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

/** 第 sym_idx 个符号名在 sym_name_data 中的偏移。 */
static int32_t pipeline_elf_sym_name_off(PipelineElfCtxAccess *ctx, int32_t sym_idx) {
  int32_t off;
  int32_t i;
  off = 0;
  i = 0;
  while (i < sym_idx && i < ctx->num_syms) {
    off = off + ctx->syms[i].name_len;
    i = i + 1;
  }
  return off;
}

/** reloc 目标是否为已定义导出符号（非 UND）。 */
static int32_t pipeline_elf_reloc_is_defined(PipelineElfCtxAccess *ctx, uint8_t *ctx_bytes, int32_t reloc_idx,
                                             uint8_t *rname, int32_t rlen) {
  int32_t m;
  int32_t off;
  uint8_t *sym_pool;
  if (!ctx || !ctx_bytes || !rname || rlen <= 0)
    return 0;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  for (m = 0; m < ctx->num_syms; m++) {
    off = pipeline_elf_sym_name_off(ctx, m);
    if (ctx->syms[m].name_len == rlen && rlen > 0 &&
        memcmp(sym_pool + off, rname, (size_t)rlen) == 0)
      return 1;
  }
  return 0;
}

/** x86_64 ELF call 重定位类型：本 TU 已定义符号用 PC32；UND 外部（如 libc putchar）须 PLT32 方能 -pie 链接。
 * wave405: explicit per-reloc type (ADRP/PAGEOFF) wins when sidecar r_type != 0. */
static int32_t pipeline_elf_call_reloc_type(PipelineElfCtxAccess *ctx, uint8_t *ctx_bytes, int32_t reloc_idx,
                                            uint8_t *rname, int32_t rlen) {
  if (!ctx)
    return 2;
  if (reloc_idx >= 0 && reloc_idx < PIPELINE_ELF_CTX_TABLE_CAP && g_pipeline_elf_reloc_r_type[reloc_idx] != 0)
    return g_pipeline_elf_reloc_r_type[reloc_idx];
  if (ctx->e_machine == 62 && !pipeline_elf_reloc_is_defined(ctx, ctx_bytes, reloc_idx, rname, rlen))
    return 4; /* R_X86_64_PLT32 */
  return ctx->reloc_type_r_pc32;
}

/* wave700: FORCE full-body unique UND saturates 256. Leftover stack
 * undef_names[256][128] silently dropped calloc/mmap (and ~1K other faces)
 * so write_o emitted R_X86_64_PLT32 with r_sym=0 → call-to-0 inside
 * pipe_gv_alloc_bytes. Twin of runtime_pipeline_abi.x::pipe_elf_undef_cap()
 * (already 2048). File-scope BSS, not 256KB auto — the compiler stack is
 * already deep in parse/typeck/codegen when this writer runs.
 * PLATFORM: LINUX ELF writer (linked SHARED; unused on Darwin Mach-O path). */
#define PIPELINE_ELF_UNDEF_SYM_CAP 2048
static uint8_t g_pipeline_elf_undef_names[PIPELINE_ELF_UNDEF_SYM_CAP][128];
static int32_t g_pipeline_elf_undef_lens[PIPELINE_ELF_UNDEF_SYM_CAP];

/** 向 ELF64 Rela 条目 bytes[16..23] 写入 signed 64-bit r_addend（须全 8 字节符号扩展，勿只写低 32 位）。 */
static void pipeline_elf_rela_set_addend64(uint8_t *rela_buf, int64_t addend) {
  rela_buf[16] = (uint8_t)(addend & 255);
  rela_buf[17] = (uint8_t)((addend >> 8) & 255);
  rela_buf[18] = (uint8_t)((addend >> 16) & 255);
  rela_buf[19] = (uint8_t)((addend >> 24) & 255);
  rela_buf[20] = (uint8_t)((addend >> 32) & 255);
  rela_buf[21] = (uint8_t)((addend >> 40) & 255);
  rela_buf[22] = (uint8_t)((addend >> 48) & 255);
  rela_buf[23] = (uint8_t)((addend >> 56) & 255);
}

/**
 * ELF64 ET_REL .o writer (non-PGO). Reads machine code from glue code_data.
 *
 * F7: always emits .data at ELF section index 4 (PIPELINE_ELF_SHNX_DATA) plus
 * .rela.text / .rela.data split by the reloc shndx sidecar. Vtable statics
 * with absolute64 pointer slots must live in .data — putting them in .text
 * makes ld report TEXTREL and the linked image SIGSEGV.
 *
 * Layout (section header indices):
 *   0 NULL  1 .text  2 .symtab  3 .strtab  4 .data
 *   5 .shstrtab  6 .rela.text  7 .rela.data
 *
 * G.7: same semantics as runtime_pipeline_abi.x::pipeline_elf_write_o_standard_to_buf_c.
 * Product hybrid: this seed body is the strong rest; .x is WEAK thin.
 * PLATFORM: LINUX primary (ELF); linked SHARED.
 */
int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *code;
  int32_t code_len;
  int32_t data_len;
  uint8_t *data_buf;
  int32_t strtab_off;
  int32_t num_undef;
  uint8_t (*undef_names)[128];
  int32_t *undef_lens;
  int32_t strtab_size;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t nr_text;
  int32_t nr_data;
  int32_t rela_text_size;
  int32_t rela_data_size;
  int32_t shstr_sz;
  int32_t off_text;
  int32_t off_data;
  int32_t off_strtab;
  int32_t off_shstrtab;
  int32_t off_symtab;
  int32_t off_rela_text;
  int32_t off_rela_data;
  int32_t off_shdr;
  /* Historic 46-byte blob (name offsets 1/8/16/24/34 kept) plus F7
   * [45] ".data\0" [51] ".rela.data\0" → 63 bytes. */
  static const uint8_t shstrtab_std[63] = {
      0, '.', 't', 'e', 'x', 't', 0, '.', 's', 'y', 'm', 't', 'a', 'b', 0,
      '.', 's', 't', 'r', 't', 'a', 'b', 0, '.', 's', 'h', 's', 't', 'r', 't', 'a', 'b', 0,
      '.', 'r', 'e', 'l', 'a', '.', 't', 'e', 'x', 't', 0,
      '.', 'd', 'a', 't', 'a', 0,
      '.', 'r', 'e', 'l', 'a', '.', 'd', 'a', 't', 'a', 0};
  uint8_t ehdr[128];
  uint8_t z0[1];
  int32_t s;
  int32_t r0;
  int32_t e_machine;
  uint8_t *sym_pool;
  int32_t pass;

  if (!ctx_bytes || !out)
    return -1;
  if (pipeline_elf_pgo_hot_enabled())
    return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  code = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  code_len = ctx->code_len;
  e_machine = ctx->e_machine;
  data_len = g_pipeline_elf_data_len;
  if (data_len < 0)
    data_len = 0;
  data_buf = &g_pipeline_elf_data_buf[0];
  undef_names = g_pipeline_elf_undef_names;
  undef_lens = g_pipeline_elf_undef_lens;
  num_undef = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    uint8_t rname[256];
    int32_t rlen;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, rname);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipeline_elf_reloc_is_defined(ctx, ctx_bytes, r0, rname, rlen) == 0) {
      int32_t u0;
      int32_t dup;
      dup = 0;
      u0 = 0;
      while (u0 < num_undef) {
        if (undef_lens[u0] == rlen && rlen > 0 && memcmp(undef_names[u0], rname, (size_t)rlen) == 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < PIPELINE_ELF_UNDEF_SYM_CAP) {
        /* wave580 Cap: undef_names rows are u8[128]; full row ('_'+127). */
        if (rlen > 128)
          rlen = 128;
        /* wave700: empty reloc names must not enter the ELF symtab.
         * GNU ld rejects STT_FUNC GLOBAL UND with st_name=="" as
         * "corrupt symbol table". Those rows were previously dropped by
         * the 256 cap; 2048 lets calloc/mmap in and would also admit
         * nameless PLT32s. Skip rlen<=0; leave those rela r_sym=0.
         * PLATFORM: LINUX ELF writer. */
        if (rlen > 0) {
          memcpy(undef_names[num_undef], rname, (size_t)rlen);
          undef_lens[num_undef] = rlen;
          num_undef = num_undef + 1;
        }
      }
    }
    r0 = r0 + 1;
  }
  strtab_off = 1;
  s = 0;
  while (s < ctx->num_syms) {
    strtab_off = strtab_off + ctx->syms[s].name_len + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + undef_lens[s] + 1;
    s = s + 1;
  }
  strtab_size = strtab_off;
  symtab_ents = 1 + ctx->num_syms + num_undef;
  symtab_size = symtab_ents * 24;
  nr_text = 0;
  nr_data = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    int32_t sd = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r0);
    if (sd == PIPELINE_ELF_SHNX_DATA)
      nr_data = nr_data + 1;
    else
      nr_text = nr_text + 1;
    r0 = r0 + 1;
  }
  rela_text_size = nr_text * 24;
  rela_data_size = nr_data * 24;
  shstr_sz = 63;
  off_text = 64;
  off_data = (off_text + code_len + 7) & (int32_t)~7;
  off_strtab = off_data + ((data_len + 7) & (int32_t)~7);
  off_shstrtab = off_strtab + strtab_size;
  off_symtab = off_shstrtab + shstr_sz;
  off_rela_text = off_symtab + symtab_size;
  off_rela_data = off_rela_text + rela_text_size;
  off_shdr = off_rela_data + rela_data_size;
  memset(ehdr, 0, sizeof(ehdr));
  ehdr[0] = 127;
  ehdr[1] = 69;
  ehdr[2] = 76;
  ehdr[3] = 70;
  ehdr[4] = 2;
  ehdr[5] = 1;
  ehdr[6] = 1;
  ehdr[16] = 1;
  ehdr[18] = (uint8_t)(e_machine & 255);
  ehdr[19] = (uint8_t)((e_machine >> 8) & 255);
  /* ET_REL：e_phoff@32 等为 0；e_ehsize@52=64、e_shentsize@58=64（勿写 ehdr[32]=64 误作 phoff）。 */
  ehdr[40] = (uint8_t)(off_shdr & 255);
  ehdr[41] = (uint8_t)((off_shdr >> 8) & 255);
  ehdr[42] = (uint8_t)((off_shdr >> 16) & 255);
  ehdr[43] = (uint8_t)((off_shdr >> 24) & 255);
  ehdr[52] = 64;
  ehdr[58] = 64;
  ehdr[60] = 8; /* e_shnum = 8 */
  ehdr[62] = 5; /* e_shstrndx = 5 (.shstrtab); index 4 is .data */
  codegen_out_buf_set_len(out, 0);
  if (pipeline_elf_out_append(out, ehdr, 64) != 0)
    return -1;
  if (code_len > 0 && code && pipeline_elf_out_append(out, code, code_len) != 0)
    return -1;
  z0[0] = 0;
  s = off_text + code_len;
  while (s < off_data) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (data_len > 0 && data_buf && pipeline_elf_out_append(out, data_buf, data_len) != 0)
    return -1;
  s = off_data + data_len;
  while (s < off_strtab) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, z0, 1) != 0)
    return -1;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  s = 0;
  while (s < ctx->num_syms) {
    int32_t nlen;
    nlen = ctx->syms[s].name_len;
    if (nlen > 0 && pipeline_elf_out_append(out, sym_pool + pipeline_elf_sym_name_off(ctx, s), nlen) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    if (undef_lens[s] > 0 && pipeline_elf_out_append(out, undef_names[s], undef_lens[s]) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, shstrtab_std, shstr_sz) != 0)
    return -1;
  {
    uint8_t sym_sect[24];
    memset(sym_sect, 0, sizeof(sym_sect));
    sym_sect[4] = 3;
    sym_sect[6] = 1;
    sym_sect[8] = (uint8_t)(code_len & 255);
    sym_sect[9] = (uint8_t)((code_len >> 8) & 255);
    sym_sect[10] = (uint8_t)((code_len >> 16) & 255);
    sym_sect[11] = (uint8_t)((code_len >> 24) & 255);
    if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
      return -1;
  }
  {
    int32_t str_off;
    str_off = 1;
    s = 0;
    while (s < ctx->num_syms) {
      uint8_t ent[24];
      int32_t is_common;
      int32_t csize;
      int32_t calign;
      int32_t sym_shndx;
      int32_t elf_shndx;
      memset(ent, 0, sizeof(ent));
      is_common = (s < PIPELINE_ELF_CTX_TABLE_CAP &&
                   pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s) == 65522) /* wave672: shndx sole authority (stale sidecar bits misclassified functions as COM) */
                      ? 1
                      : 0;
      /* wave613 root fix: SHN_COMMON (65522) authority fallback — cross-copy
       * sidecar misses classified mutable COMMON as STT_FUNC shndx=1 .text
       * (read-only) and dump-path writes SEGV'd both ends. The ctx symbol
       * entry shndx (written by pipeline_elf_ctx_add_common_sym) is the
       * single authority; the sidecar only enriches size/align. */
      if (is_common == 0 &&
          pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s) == 65522) {
        is_common = 1;
      }
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      if (is_common != 0) {
        /* STB_GLOBAL|STT_OBJECT=17; SHN_COMMON=0xfff2; st_value=align, st_size=size
         * wave696: ctx offset is the COMMON size authority (add_common_sym 4th
         * arg). Sidecar size is dual-copy and FORCE full-body emit smashes it
         * to 1 (same class as w672 is_common bits). PLATFORM: SHARED. */
        csize = ctx->syms[s].offset;
        calign = g_pipeline_elf_sym_common_align[s];
        if (calign <= 0)
          calign = 8;
        if (csize <= 0)
          csize = g_pipeline_elf_sym_common_size[s];
        if (csize <= 0)
          csize = 8;
        ent[4] = 17;
        ent[6] = 0xf2;
        ent[7] = 0xff;
        ent[8] = (uint8_t)(calign & 255);
        ent[9] = (uint8_t)((calign >> 8) & 255);
        ent[10] = (uint8_t)((calign >> 16) & 255);
        ent[11] = (uint8_t)((calign >> 24) & 255);
        ent[16] = (uint8_t)(csize & 255);
        ent[17] = (uint8_t)((csize >> 8) & 255);
        ent[18] = (uint8_t)((csize >> 16) & 255);
        ent[19] = (uint8_t)((csize >> 24) & 255);
      } else {
        /* F7: st_shndx from sidecar. 4 = .data (vtable); else .text. */
        sym_shndx = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
        elf_shndx = (sym_shndx == PIPELINE_ELF_SHNX_DATA) ? 4 : 1;
        ent[4] = 18;
        ent[6] = (uint8_t)(elf_shndx & 255);
        ent[7] = (uint8_t)((elf_shndx >> 8) & 255);
        ent[8] = (uint8_t)(ctx->syms[s].offset & 255);
        ent[9] = (uint8_t)((ctx->syms[s].offset >> 8) & 255);
        ent[10] = (uint8_t)((ctx->syms[s].offset >> 16) & 255);
        ent[11] = (uint8_t)((ctx->syms[s].offset >> 24) & 255);
      }
      if (pipeline_elf_out_append(out, ent, 24) != 0)
        return -1;
      str_off = str_off + ctx->syms[s].name_len + 1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      uint8_t uent[24];
      memset(uent, 0, sizeof(uent));
      uent[4] = 18;
      uent[0] = (uint8_t)(str_off & 255);
      uent[1] = (uint8_t)((str_off >> 8) & 255);
      uent[2] = (uint8_t)((str_off >> 16) & 255);
      uent[3] = (uint8_t)((str_off >> 24) & 255);
      if (pipeline_elf_out_append(out, uent, 24) != 0)
        return -1;
      str_off = str_off + undef_lens[s] + 1;
      s = s + 1;
    }
  }
  /* F7: two-pass rela — text-section first (shndx != 4), then data (shndx == 4). */
  pass = 0;
  while (pass < 2) {
    int32_t want_data = (pass == 1) ? 1 : 0;
    int32_t r = 0;
    while (r < ctx->num_relocs) {
      int32_t r_sd;
      int32_t is_data;
      int32_t sym_idx;
      int32_t m;
      int32_t u;
      uint8_t r_sym_buf[256];
      int32_t rlen;
      uint8_t rela_buf[24];
      int32_t roff;
      int32_t rtype;
      r_sd = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r);
      is_data = (r_sd == PIPELINE_ELF_SHNX_DATA) ? 1 : 0;
      if (is_data != want_data) {
        r = r + 1;
        continue;
      }
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
      rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
      sym_idx = 0;
      m = 0;
      while (m < ctx->num_syms) {
        int32_t off;
        off = pipeline_elf_sym_name_off(ctx, m);
        if (ctx->syms[m].name_len == rlen && rlen > 0 &&
            memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = m + 1;
          break;
        }
        m = m + 1;
      }
      if (sym_idx == 0) {
        u = 0;
        while (u < num_undef) {
          if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
            sym_idx = ctx->num_syms + 1 + u;
            break;
          }
          u = u + 1;
        }
      }
      memset(rela_buf, 0, sizeof(rela_buf));
      pipeline_elf_rela_set_addend64(rela_buf, -4);
      roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
      rela_buf[0] = (uint8_t)(roff & 255);
      rela_buf[1] = (uint8_t)((roff >> 8) & 255);
      rela_buf[2] = (uint8_t)((roff >> 16) & 255);
      rela_buf[3] = (uint8_t)((roff >> 24) & 255);
      rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      /* F7 absolute64: sentinel r_type=200 → platform ABS64 with ZERO addend.
       * x86_64 R_X86_64_64=1; arm64 R_AARCH64_ABS64=257; riscv64 R_RISCV_64=2. */
      if (rtype == 200) {
        pipeline_elf_rela_set_addend64(rela_buf, 0);
        if (e_machine == 62)
          rtype = 1;
        else if (e_machine == 183)
          rtype = 257;
        else if (e_machine == 243)
          rtype = 2;
        else
          rtype = 1;
      }
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
      rela_buf[12] = (uint8_t)(sym_idx & 255);
      rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
      rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
      rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
      if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
        return -1;
      r = r + 1;
    }
    pass = pass + 1;
  }
  {
    uint8_t shdr0[64];
    uint8_t shdr_text[64];
    uint8_t shdr_sym[64];
    uint8_t shdr_str[64];
    uint8_t shdr_data[64];
    uint8_t shdr_shstr[64];
    uint8_t shdr_rela[64];
    uint8_t shdr_rela_data[64];
    memset(shdr0, 0, sizeof(shdr0));
    if (pipeline_elf_out_append(out, shdr0, 64) != 0)
      return -1;
    memset(shdr_text, 0, sizeof(shdr_text));
    shdr_text[0] = 1;
    shdr_text[4] = 1;
    shdr_text[8] = 6;
    shdr_text[24] = (uint8_t)(off_text & 255);
    shdr_text[25] = (uint8_t)((off_text >> 8) & 255);
    shdr_text[26] = (uint8_t)((off_text >> 16) & 255);
    shdr_text[27] = (uint8_t)((off_text >> 24) & 255);
    shdr_text[32] = (uint8_t)(code_len & 255);
    shdr_text[33] = (uint8_t)((code_len >> 8) & 255);
    shdr_text[34] = (uint8_t)((code_len >> 16) & 255);
    shdr_text[35] = (uint8_t)((code_len >> 24) & 255);
    if (pipeline_elf_out_append(out, shdr_text, 64) != 0)
      return -1;
    memset(shdr_sym, 0, sizeof(shdr_sym));
    shdr_sym[0] = 8;
    shdr_sym[4] = 2;
    shdr_sym[24] = (uint8_t)(off_symtab & 255);
    shdr_sym[25] = (uint8_t)((off_symtab >> 8) & 255);
    shdr_sym[26] = (uint8_t)((off_symtab >> 16) & 255);
    shdr_sym[27] = (uint8_t)((off_symtab >> 24) & 255);
    shdr_sym[32] = (uint8_t)(symtab_size & 255);
    shdr_sym[33] = (uint8_t)((symtab_size >> 8) & 255);
    shdr_sym[34] = (uint8_t)((symtab_size >> 16) & 255);
    shdr_sym[35] = (uint8_t)((symtab_size >> 24) & 255);
    shdr_sym[40] = 3;
    shdr_sym[44] = 1;
    shdr_sym[56] = 24;
    if (pipeline_elf_out_append(out, shdr_sym, 64) != 0)
      return -1;
    memset(shdr_str, 0, sizeof(shdr_str));
    shdr_str[0] = 16;
    shdr_str[4] = 3;
    shdr_str[24] = (uint8_t)(off_strtab & 255);
    shdr_str[25] = (uint8_t)((off_strtab >> 8) & 255);
    shdr_str[26] = (uint8_t)((off_strtab >> 16) & 255);
    shdr_str[27] = (uint8_t)((off_strtab >> 24) & 255);
    shdr_str[32] = (uint8_t)(strtab_size & 255);
    shdr_str[33] = (uint8_t)((strtab_size >> 8) & 255);
    shdr_str[34] = (uint8_t)((strtab_size >> 16) & 255);
    shdr_str[35] = (uint8_t)((strtab_size >> 24) & 255);
    shdr_str[48] = 1;
    if (pipeline_elf_out_append(out, shdr_str, 64) != 0)
      return -1;
    /* index 4 = .data (SHT_PROGBITS, SHF_WRITE|SHF_ALLOC, align 8) */
    memset(shdr_data, 0, sizeof(shdr_data));
    shdr_data[0] = 45;
    shdr_data[4] = 1;
    shdr_data[8] = 3;
    shdr_data[24] = (uint8_t)(off_data & 255);
    shdr_data[25] = (uint8_t)((off_data >> 8) & 255);
    shdr_data[26] = (uint8_t)((off_data >> 16) & 255);
    shdr_data[27] = (uint8_t)((off_data >> 24) & 255);
    shdr_data[32] = (uint8_t)(data_len & 255);
    shdr_data[33] = (uint8_t)((data_len >> 8) & 255);
    shdr_data[34] = (uint8_t)((data_len >> 16) & 255);
    shdr_data[35] = (uint8_t)((data_len >> 24) & 255);
    shdr_data[48] = 8;
    if (pipeline_elf_out_append(out, shdr_data, 64) != 0)
      return -1;
    memset(shdr_shstr, 0, sizeof(shdr_shstr));
    shdr_shstr[0] = 24;
    shdr_shstr[4] = 3;
    shdr_shstr[24] = (uint8_t)(off_shstrtab & 255);
    shdr_shstr[25] = (uint8_t)((off_shstrtab >> 8) & 255);
    shdr_shstr[26] = (uint8_t)((off_shstrtab >> 16) & 255);
    shdr_shstr[27] = (uint8_t)((off_shstrtab >> 24) & 255);
    shdr_shstr[32] = (uint8_t)(shstr_sz & 255);
    shdr_shstr[48] = 1;
    if (pipeline_elf_out_append(out, shdr_shstr, 64) != 0)
      return -1;
    memset(shdr_rela, 0, sizeof(shdr_rela));
    shdr_rela[0] = 34;
    shdr_rela[4] = 4;
    shdr_rela[8] = 2;
    shdr_rela[16] = 64;
    shdr_rela[24] = (uint8_t)(off_rela_text & 255);
    shdr_rela[25] = (uint8_t)((off_rela_text >> 8) & 255);
    shdr_rela[26] = (uint8_t)((off_rela_text >> 16) & 255);
    shdr_rela[27] = (uint8_t)((off_rela_text >> 24) & 255);
    shdr_rela[32] = (uint8_t)(rela_text_size & 255);
    shdr_rela[33] = (uint8_t)((rela_text_size >> 8) & 255);
    shdr_rela[34] = (uint8_t)((rela_text_size >> 16) & 255);
    shdr_rela[35] = (uint8_t)((rela_text_size >> 24) & 255);
    shdr_rela[40] = 2;
    shdr_rela[44] = 1;
    shdr_rela[56] = 24;
    if (pipeline_elf_out_append(out, shdr_rela, 64) != 0)
      return -1;
    memset(shdr_rela_data, 0, sizeof(shdr_rela_data));
    shdr_rela_data[0] = 51;
    shdr_rela_data[4] = 4;
    shdr_rela_data[8] = 2;
    shdr_rela_data[16] = 64;
    shdr_rela_data[24] = (uint8_t)(off_rela_data & 255);
    shdr_rela_data[25] = (uint8_t)((off_rela_data >> 8) & 255);
    shdr_rela_data[26] = (uint8_t)((off_rela_data >> 16) & 255);
    shdr_rela_data[27] = (uint8_t)((off_rela_data >> 24) & 255);
    shdr_rela_data[32] = (uint8_t)(rela_data_size & 255);
    shdr_rela_data[33] = (uint8_t)((rela_data_size >> 8) & 255);
    shdr_rela_data[34] = (uint8_t)((rela_data_size >> 16) & 255);
    shdr_rela_data[35] = (uint8_t)((rela_data_size >> 24) & 255);
    shdr_rela_data[40] = 2;
    shdr_rela_data[44] = 4; /* sh_info = 4 (.data) */
    shdr_rela_data[56] = 24;
    if (pipeline_elf_out_append(out, shdr_rela_data, 64) != 0)
      return -1;
  }
  return codegen_out_buf_len(out);
}

/**
 * PLATFORM: MACOS/DARWIN — MH_OBJECT writer for pure-asm -o .o (product g05).
 *
 * CG002 residual (2026-07-22 wave103): after arm64 enc fixed mega_body, Darwin
 * still failed at macho_write=-1 because only XLANG_WEAK
 * platform_macho_write_macho_o_to_buf stubs (experimental bridge / full_link stubs)
 * were linked; true macho.x is not on the product hybrid chain.
 *
 * Authority: port of src/asm/platform/macho.x::write_macho_o_to_buf using the same
 * PipelineElfCtxAccess + glue code_data offset as pipeline_elf_write_o_standard_to_buf_c
 * (G.7 single layout path; do not read X code_data[] offsets).
 *
 * Linked via pipeline_glue / ast_pool into product; strong symbol overrides Darwin
 * weak stubs. Safe on non-Darwin hosts (body unused unless use_macho_o).
 */
/* Defined later in this TU; needed before PGO section for macho write. */
int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes);

#define PIPELINE_MACHO_UNDEF_SYM_CAP 256

static int32_t pipeline_macho_link_name_extra_byte(const uint8_t *name_ptr) {
  if (!name_ptr)
    return 0;
  /* Already starts with '_' → no extra leading underscore. */
  if (name_ptr[0] != 95)
    return 1;
  return 0;
}

static int32_t pipeline_macho_name_eq(const uint8_t *a, int32_t a_len, const uint8_t *b, int32_t b_len) {
  if (a_len != b_len || a_len < 0)
    return 0;
  if (a_len == 0)
    return 1;
  if (!a || !b)
    return 0;
  return memcmp(a, b, (size_t)a_len) == 0 ? 1 : 0;
}

/**
 * Write MH_OBJECT (Mach-O 64) into out from emit ctx.
 * @return out length on success, -1 on failure
 */
int32_t pipeline_macho_write_o_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *code;
  uint8_t *sym_pool;
  int32_t code_len;
  int32_t und_src_reloc[PIPELINE_MACHO_UNDEF_SYM_CAP];
  int32_t und_lens[PIPELINE_MACHO_UNDEF_SYM_CAP];
  int32_t nu;
  int32_t rx;
  int32_t strtab_size;
  int32_t s;
  int32_t ui;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t reloc_size;
  int32_t lc_build_size;
  int32_t sizeofcmds;
  int32_t off_text;
  int32_t off_sym;
  int32_t off_str;
  int32_t off_reloc;
  int32_t cputype;
  int32_t cpusubtype;
  uint8_t hdr[32];
  uint8_t seg[152];
  uint8_t seg2[152]; /* F7: second LC_SEGMENT_64 for __DATA,__const */
  uint8_t lc_bv[24];
  uint8_t lc_sym[24];
  uint8_t lc_dys[80];
  int32_t lc_dysym_size;
  uint8_t z0[1];
  uint8_t uscore[1];
  int32_t pad;
  int32_t z;
  int32_t str_off;
  int32_t uu;
  int32_t r;
  /* F7: data section (vtable statics with absolute pointer relocs). */
  int32_t data_len;
  uint8_t *data_buf;
  int32_t off_data;
  int32_t nr_text;
  int32_t nr_data;
  int32_t rc_i;
  int32_t off_reloc_text;
  int32_t off_reloc_data;
  int32_t pad_data;
  int32_t pd;
  int32_t pass;
  int32_t want_data;
  int32_t is_data;
  int32_t r_sd;
  int32_t sym_shndx;
  int32_t n_sect;
  int32_t data_vmaddr;
  int32_t emit_data_seg;
  int32_t n_val;
  int32_t rel_type;
  int32_t rel_len;
  extern void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
  extern void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);

  if (!ctx_bytes || !out)
    return -1;
  /* Patches already resolved on product path; re-resolve is idempotent. */
  if (pipeline_elf_ctx_resolve_patches(ctx_bytes) != 0)
    return -1;

  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  code = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  code_len = ctx->code_len;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  nu = 0;
  rx = 0;
  while (rx < ctx->num_relocs) {
    uint8_t rname[256];
    int32_t rlen;
    int32_t us;
    int32_t dup;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, rx, rname);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, rx);
    if (pipeline_elf_reloc_is_defined(ctx, ctx_bytes, rx, rname, rlen) != 0) {
      rx = rx + 1;
      continue;
    }
    dup = -1;
    us = 0;
    while (us < nu) {
      uint8_t srname[256];
      int32_t sr = und_src_reloc[us];
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, sr, srname);
      if (pipeline_macho_name_eq(rname, rlen, srname, und_lens[us]) != 0) {
        dup = us;
        break;
      }
      us = us + 1;
    }
    if (dup >= 0) {
      rx = rx + 1;
      continue;
    }
    if (nu >= PIPELINE_MACHO_UNDEF_SYM_CAP)
      return -1;
    if (rlen <= 0) {
      driver_diagnostic_asm_macho_empty_reloc(rx);
      return -1;
    }
    und_src_reloc[nu] = rx;
    und_lens[nu] = rlen;
    nu = nu + 1;
    rx = rx + 1;
  }

  strtab_size = 1;
  s = 0;
  while (s < ctx->num_syms) {
    int32_t off = pipeline_elf_sym_name_off(ctx, s);
    int32_t extra = pipeline_macho_link_name_extra_byte(sym_pool + off);
    strtab_size = strtab_size + ctx->syms[s].name_len + extra + 1;
    s = s + 1;
  }
  ui = 0;
  while (ui < nu) {
    int32_t sr = und_src_reloc[ui];
    uint8_t *und_ptr = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr);
    int32_t extra = pipeline_macho_link_name_extra_byte(und_ptr);
    strtab_size = strtab_size + und_lens[ui] + extra + 1;
    ui = ui + 1;
  }

  /* clang MH_OBJECT: no dummy nlist[0]. strtab[0] stays the empty NUL. */
  symtab_ents = ctx->num_syms + nu;
  symtab_size = symtab_ents * 16;
  reloc_size = ctx->num_relocs * 8;
  lc_build_size = 24;
  lc_dysym_size = 80;
  /* F7: data section (vtable statics with absolute pointer relocs).
   * Count data relocs BEFORE sizeofcmds so empty __DATA can drop the
   * second LC_SEGMENT_64 with matching ncmds/sizeofcmds.
   * Twin of runtime_pipeline_abi.x macho writer. */
  data_len = g_pipeline_elf_data_len;
  if (data_len < 0)
    data_len = 0;
  data_buf = &g_pipeline_elf_data_buf[0];
  nr_text = 0;
  nr_data = 0;
  rc_i = 0;
  while (rc_i < ctx->num_relocs) {
    int32_t sd = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, rc_i);
    if (sd == PIPELINE_ELF_SHNX_DATA)
      nr_data = nr_data + 1;
    else
      nr_text = nr_text + 1;
    rc_i = rc_i + 1;
  }
  /* Omit empty F7 __DATA LC_SEGMENT_64 when there are no data bytes and
   * no data relocs. Darwin clang -r of a two-segment MH_OBJECT onto
   * hybrid pabi.o can succeed and still poison ELF finalize (CG002
   * elf_ec=-1 out_len=0). Keep the second segment when vtable/static
   * data or ARM64_RELOC_UNSIGNED lives there.
   * PLATFORM: MACOS|DARWIN writer; ELF path unchanged. */
  emit_data_seg = 0;
  if (data_len > 0 || nr_data > 0)
    emit_data_seg = 1;
  sizeofcmds = 152 + lc_build_size + 24 + lc_dysym_size;
  if (emit_data_seg != 0)
    sizeofcmds = sizeofcmds + 152;
  off_text = 32 + sizeofcmds;
  off_data = (off_text + code_len + 3) & (int32_t)0xFFFFFFFCu;
  off_sym = (off_data + data_len + 3) & (int32_t)0xFFFFFFFCu;
  off_str = off_sym + symtab_size;
  off_reloc_text = off_str + strtab_size;
  off_reloc_data = off_reloc_text + nr_text * 8;
  off_reloc = off_reloc_text; /* keep for backward compat (text relocs) */
  (void)reloc_size;

  codegen_out_buf_set_len(out, 0);

  /* CPU_TYPE_X86_64=0x01000007; CPU_TYPE_ARM64=0x0100000C (EM_AARCH64=183). */
  cputype = 16777223;
  cpusubtype = 3;
  if (ctx->e_machine == 183) {
    cputype = 16777228;
    cpusubtype = 0;
  }

  memset(hdr, 0, sizeof(hdr));
  /* MH_MAGIC_64 = 0xFEEDFACF little-endian: CF FA ED FE */
  hdr[0] = 207;
  hdr[1] = 250;
  hdr[2] = 237;
  hdr[3] = 254;
  hdr[4] = (uint8_t)(cputype & 255);
  hdr[5] = (uint8_t)((cputype >> 8) & 255);
  hdr[6] = (uint8_t)((cputype >> 16) & 255);
  hdr[7] = (uint8_t)((cputype >> 24) & 255);
  hdr[8] = (uint8_t)(cpusubtype & 255);
  hdr[9] = (uint8_t)((cpusubtype >> 8) & 255);
  hdr[10] = (uint8_t)((cpusubtype >> 16) & 255);
  hdr[11] = (uint8_t)((cpusubtype >> 24) & 255);
  /* MH_OBJECT = 1 */
  hdr[12] = 1;
  /* ncmds = 4 (seg + BUILD + SYMTAB + DYSYMTAB), or 5 with __DATA. */
  hdr[16] = (uint8_t)(emit_data_seg != 0 ? 5 : 4);
  hdr[20] = (uint8_t)(sizeofcmds & 255);
  hdr[21] = (uint8_t)((sizeofcmds >> 8) & 255);
  hdr[22] = (uint8_t)((sizeofcmds >> 16) & 255);
  hdr[23] = (uint8_t)((sizeofcmds >> 24) & 255);
  if (pipeline_elf_out_append(out, hdr, 32) != 0)
    return -1;

  memset(seg, 0, sizeof(seg));
  /* LC_SEGMENT_64 cmd=0x19, cmdsize=152.
   * clang MH_OBJECT: LC_SEGMENT_64.segname is empty; section still
   * names __TEXT,__text. Twin of runtime_pipeline_abi.x. */
  seg[0] = 25;
  seg[4] = 152;
  /* vmsize / filesize = code_len; fileoff = off_text */
  seg[32] = (uint8_t)(code_len & 255);
  seg[33] = (uint8_t)((code_len >> 8) & 255);
  seg[34] = (uint8_t)((code_len >> 16) & 255);
  seg[35] = (uint8_t)((code_len >> 24) & 255);
  seg[40] = (uint8_t)(off_text & 255);
  seg[41] = (uint8_t)((off_text >> 8) & 255);
  seg[42] = (uint8_t)((off_text >> 16) & 255);
  seg[43] = (uint8_t)((off_text >> 24) & 255);
  seg[48] = (uint8_t)(code_len & 255);
  seg[49] = (uint8_t)((code_len >> 8) & 255);
  seg[50] = (uint8_t)((code_len >> 16) & 255);
  seg[51] = (uint8_t)((code_len >> 24) & 255);
  /* maxprot / initprot = rwx = 7 */
  seg[56] = 7;
  seg[60] = 7;
  /* nsects = 1 */
  seg[64] = 1;
  /* sectname "__text" */
  seg[72] = 95;
  seg[73] = 95;
  seg[74] = 116;
  seg[75] = 101;
  seg[76] = 120;
  seg[77] = 116;
  /* segname "__TEXT" for section */
  seg[88] = 95;
  seg[89] = 95;
  seg[90] = 84;
  seg[91] = 69;
  seg[92] = 88;
  seg[93] = 84;
  /* section size / offset */
  seg[112] = (uint8_t)(code_len & 255);
  seg[113] = (uint8_t)((code_len >> 8) & 255);
  seg[114] = (uint8_t)((code_len >> 16) & 255);
  seg[115] = (uint8_t)((code_len >> 24) & 255);
  seg[120] = (uint8_t)(off_text & 255);
  seg[121] = (uint8_t)((off_text >> 8) & 255);
  seg[122] = (uint8_t)((off_text >> 16) & 255);
  seg[123] = (uint8_t)((off_text >> 24) & 255);
  /* F7: __TEXT,__text reloc table now only covers text-section relocs. */
  seg[128] = (uint8_t)(off_reloc_text & 255);
  seg[129] = (uint8_t)((off_reloc_text >> 8) & 255);
  seg[130] = (uint8_t)((off_reloc_text >> 16) & 255);
  seg[131] = (uint8_t)((off_reloc_text >> 24) & 255);
  seg[132] = (uint8_t)(nr_text & 255);
  seg[133] = (uint8_t)((nr_text >> 8) & 255);
  /* S_ATTR_PURE_INSTRUCTIONS|S_ATTR_SOME_INSTRUCTIONS = 0x80000400.
   * S_ATTR_EXT_RELOC (0x40000) only when this section has relocs. */
  seg[136] = 0;
  seg[137] = 4;
  seg[138] = (uint8_t)(nr_text > 0 ? 4 : 0);
  seg[139] = 128;
  if (pipeline_elf_out_append(out, seg, 152) != 0)
    return -1;

  if (emit_data_seg != 0) {
  /* F7: emit second LC_SEGMENT_64 for __DATA,__const (vtable static data).
   * This segment is writable at link time (initprot=rw-) so absolute 64-bit
   * pointer relocations (ARM64_RELOC_UNSIGNED) can be applied; ld rejects
   * these in __TEXT,__text which is pure_instructions.
   * Layout: segment_command_64 (72 bytes) + section_64 (80 bytes) = 152.
   * MH_OBJECT: __DATA.vmaddr MUST NOT overlap __TEXT.vmaddr+[0,vmsize).
   * Both at 0 with nonzero vmsize → ld "vm range overlaps". Place __DATA at
   * code_len (section addrs sequential, clang MH_OBJECT style). */
  data_vmaddr = code_len;
  if (data_vmaddr < 0)
    data_vmaddr = 0;
  /* Pointer slots require 8-byte alignment (ld: "pointer not aligned"). */
  data_vmaddr = (data_vmaddr + 7) & ~7;
  memset(seg2, 0, sizeof(seg2));
  seg2[0] = 25;  /* LC_SEGMENT_64 */
  seg2[4] = 152; /* cmdsize */
  seg2[8] = 95; seg2[9] = 95; seg2[10] = 68; seg2[11] = 65; seg2[12] = 84; seg2[13] = 65;  /* "__DATA" */
  /* vmaddr = data_vmaddr (non-overlapping with __TEXT at 0) */
  seg2[24] = (uint8_t)(data_vmaddr & 255);
  seg2[25] = (uint8_t)((data_vmaddr >> 8) & 255);
  seg2[26] = (uint8_t)((data_vmaddr >> 16) & 255);
  seg2[27] = (uint8_t)((data_vmaddr >> 24) & 255);
  /* vmsize / filesize = data_len; fileoff = off_data */
  seg2[32] = (uint8_t)(data_len & 255);
  seg2[33] = (uint8_t)((data_len >> 8) & 255);
  seg2[34] = (uint8_t)((data_len >> 16) & 255);
  seg2[35] = (uint8_t)((data_len >> 24) & 255);
  seg2[40] = (uint8_t)(off_data & 255);
  seg2[41] = (uint8_t)((off_data >> 8) & 255);
  seg2[42] = (uint8_t)((off_data >> 16) & 255);
  seg2[43] = (uint8_t)((off_data >> 24) & 255);
  seg2[48] = (uint8_t)(data_len & 255);
  seg2[49] = (uint8_t)((data_len >> 8) & 255);
  seg2[50] = (uint8_t)((data_len >> 16) & 255);
  seg2[51] = (uint8_t)((data_len >> 24) & 255);
  /* maxprot=rwx(7), initprot=rw-(3) */
  seg2[56] = 7;
  seg2[60] = 3;
  seg2[64] = 1;  /* nsects = 1 */
  /* section_64.sectname = "__data" at seg2+72.
   * Was "__const": final ld maps __const RO → mutable modlet ARRAY_LIT
   * counters (fmt g_fmt_*_n) SIGBUS on store. Library-TU .data bake needs
   * writable home; vtable statics are fine in __data too.
   * PLATFORM: MACOS|DARWIN — __DATA,__data; ELF stays .data.
   * Twin of runtime_pipeline_abi.x macho writer. */
  seg2[72] = 95; seg2[73] = 95; seg2[74] = 100; seg2[75] = 97; seg2[76] = 116; seg2[77] = 97;
  /* section_64.segname = "__DATA" at seg2+88 */
  seg2[88] = 95; seg2[89] = 95; seg2[90] = 68; seg2[91] = 65; seg2[92] = 84; seg2[93] = 65;
  /* section_64.addr = data_vmaddr (match segment vmaddr) */
  seg2[104] = (uint8_t)(data_vmaddr & 255);
  seg2[105] = (uint8_t)((data_vmaddr >> 8) & 255);
  seg2[106] = (uint8_t)((data_vmaddr >> 16) & 255);
  seg2[107] = (uint8_t)((data_vmaddr >> 24) & 255);
  /* section_64.size = data_len */
  seg2[112] = (uint8_t)(data_len & 255);
  seg2[113] = (uint8_t)((data_len >> 8) & 255);
  seg2[114] = (uint8_t)((data_len >> 16) & 255);
  seg2[115] = (uint8_t)((data_len >> 24) & 255);
  /* section_64.offset = off_data */
  seg2[120] = (uint8_t)(off_data & 255);
  seg2[121] = (uint8_t)((off_data >> 8) & 255);
  seg2[122] = (uint8_t)((off_data >> 16) & 255);
  seg2[123] = (uint8_t)((off_data >> 24) & 255);
  /* section_64.reloff = off_reloc_data */
  seg2[128] = (uint8_t)(off_reloc_data & 255);
  seg2[129] = (uint8_t)((off_reloc_data >> 8) & 255);
  seg2[130] = (uint8_t)((off_reloc_data >> 16) & 255);
  seg2[131] = (uint8_t)((off_reloc_data >> 24) & 255);
  /* section_64.align = 2^3 (8-byte pointers) */
  seg2[124] = 3;
  /* section_64.nreloc = nr_data */
  seg2[132] = (uint8_t)(nr_data & 255);
  seg2[133] = (uint8_t)((nr_data >> 8) & 255);
  /* section_64.flags = 0 (S_REGULAR) */
  seg2[136] = 0; seg2[137] = 0; seg2[138] = 0; seg2[139] = 0;
  if (pipeline_elf_out_append(out, seg2, 152) != 0)
    return -1;
  }

  /* LC_BUILD_VERSION: platform=macOS(1), minos/sdk=11.0.0 */
  memset(lc_bv, 0, sizeof(lc_bv));
  lc_bv[0] = 50; /* 0x32 */
  lc_bv[4] = (uint8_t)(lc_build_size & 255);
  lc_bv[5] = (uint8_t)((lc_build_size >> 8) & 255);
  lc_bv[8] = 1;
  {
    int32_t ver = 720896; /* 11 << 16 */
    lc_bv[12] = (uint8_t)(ver & 255);
    lc_bv[13] = (uint8_t)((ver >> 8) & 255);
    lc_bv[14] = (uint8_t)((ver >> 16) & 255);
    lc_bv[15] = (uint8_t)((ver >> 24) & 255);
    lc_bv[16] = (uint8_t)(ver & 255);
    lc_bv[17] = (uint8_t)((ver >> 8) & 255);
    lc_bv[18] = (uint8_t)((ver >> 16) & 255);
    lc_bv[19] = (uint8_t)((ver >> 24) & 255);
  }
  if (pipeline_elf_out_append(out, lc_bv, lc_build_size) != 0)
    return -1;

  /* LC_SYMTAB */
  memset(lc_sym, 0, sizeof(lc_sym));
  lc_sym[0] = 2;
  lc_sym[4] = 24;
  lc_sym[8] = (uint8_t)(off_sym & 255);
  lc_sym[9] = (uint8_t)((off_sym >> 8) & 255);
  lc_sym[10] = (uint8_t)((off_sym >> 16) & 255);
  lc_sym[11] = (uint8_t)((off_sym >> 24) & 255);
  lc_sym[12] = (uint8_t)(symtab_ents & 255);
  lc_sym[13] = (uint8_t)((symtab_ents >> 8) & 255);
  lc_sym[16] = (uint8_t)(off_str & 255);
  lc_sym[17] = (uint8_t)((off_str >> 8) & 255);
  lc_sym[18] = (uint8_t)((off_str >> 16) & 255);
  lc_sym[19] = (uint8_t)((off_str >> 24) & 255);
  lc_sym[20] = (uint8_t)(strtab_size & 255);
  lc_sym[21] = (uint8_t)((strtab_size >> 8) & 255);
  if (pipeline_elf_out_append(out, lc_sym, 24) != 0)
    return -1;

  /* LC_DYSYMTAB (cmd=0x0b, cmdsize=80). Grouping matches nlist order:
   * ns ext-def then nu undef. Commons stay in the ns prefix. */
  memset(lc_dys, 0, sizeof(lc_dys));
  lc_dys[0] = 11;
  lc_dys[4] = 80;
  lc_dys[20] = (uint8_t)(ctx->num_syms & 255);
  lc_dys[21] = (uint8_t)((ctx->num_syms >> 8) & 255);
  lc_dys[22] = (uint8_t)((ctx->num_syms >> 16) & 255);
  lc_dys[23] = (uint8_t)((ctx->num_syms >> 24) & 255);
  lc_dys[24] = (uint8_t)(ctx->num_syms & 255);
  lc_dys[25] = (uint8_t)((ctx->num_syms >> 8) & 255);
  lc_dys[26] = (uint8_t)((ctx->num_syms >> 16) & 255);
  lc_dys[27] = (uint8_t)((ctx->num_syms >> 24) & 255);
  lc_dys[28] = (uint8_t)(nu & 255);
  lc_dys[29] = (uint8_t)((nu >> 8) & 255);
  lc_dys[30] = (uint8_t)((nu >> 16) & 255);
  lc_dys[31] = (uint8_t)((nu >> 24) & 255);
  if (pipeline_elf_out_append(out, lc_dys, lc_dysym_size) != 0)
    return -1;

  if (code_len > 0 && code && pipeline_elf_out_append(out, code, code_len) != 0)
    return -1;
  z0[0] = 0;
  /* F7: padding between text and data (alignment 4); always emit so the file
   * position lands at off_data regardless of whether the data section is used. */
  pad_data = off_data - off_text - code_len;
  pd = 0;
  while (pd < pad_data) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    pd = pd + 1;
  }
  /* F7: emit data section bytes (__DATA,__const). */
  if (data_len > 0 && data_buf && pipeline_elf_out_append(out, data_buf, data_len) != 0)
    return -1;
  /* F7: pad now spans from end of data to start of symtab (was: text to symtab). */
  pad = off_sym - off_data - data_len;
  z = 0;
  while (z < pad) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    z = z + 1;
  }

  str_off = 1;
  s = 0;
  while (s < ctx->num_syms) {
    uint8_t ent[16];
    int32_t off = pipeline_elf_sym_name_off(ctx, s);
    int32_t sym_va = ctx->syms[s].offset;
    int32_t is_common = 0;
    int32_t csize = 0;
    memset(ent, 0, sizeof(ent));
    ent[0] = (uint8_t)(str_off & 255);
    ent[1] = (uint8_t)((str_off >> 8) & 255);
    ent[2] = (uint8_t)((str_off >> 16) & 255);
    ent[3] = (uint8_t)((str_off >> 24) & 255);
    /* wave405: COMMON → N_UNDF|N_EXT + n_value=size (linker BSS). Never N_SECT in __text (RX SEGV). */
    is_common = (s < PIPELINE_ELF_CTX_TABLE_CAP &&
                 pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s) == 65522) /* wave672 */
                    ? 1
                    : 0;
    /* wave613 root fix: SHN_COMMON (65522) authority fallback — cross-copy
     * sidecar misses pinned mutable COMMON into __TEXT (read-only) and
     * dump-path writes SIGBUS/SEGV'd both ends. The ctx symbol entry shndx
     * (written by pipeline_elf_ctx_add_common_sym) is the single authority;
     * the sidecar only enriches size/align. */
    if (is_common == 0 &&
        pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s) == 65522) {
      is_common = 1;
    }
    if (is_common != 0) {
      int32_t calign;
      int32_t alg;
      int32_t ndesc;
      /* wave696: ctx offset (sym_va) is the COMMON size authority. Sidecar
       * size is dual-copy and FORCE full-body emit smashes it to 1
       * (same class as w672 is_common bits). PLATFORM: SHARED. */
      csize = sym_va;
      calign = g_pipeline_elf_sym_common_align[s];
      if (csize <= 0)
        csize = g_pipeline_elf_sym_common_size[s];
      if (csize <= 0)
        csize = 8;
      if (calign <= 0)
        calign = 8;
      /* N_UNDF|N_EXT = 0x01; n_sect=NO_SECT; n_value=size (tentative/common).
       * PLATFORM: MACOS|DARWIN — set n_desc GET_COMM_ALIGN (log2) so Apple ld
       * does not size-derive __DATA,__common section align to 0x8000 for
       * multi-MiB commons (fmt g_fmt_file_list_paths 4MiB). Floor 8 / cap 2^14
       * twin of pipe_macho_common_align_log2. */
      alg = 3;
      if (calign < 8)
        calign = 8;
      if (calign > 16384)
        calign = 16384;
      while (alg < 14) {
        int32_t step = 1 << alg;
        if (step >= calign)
          break;
        alg++;
      }
      if (alg > 14)
        alg = 14;
      ndesc = alg << 8;
      ent[4] = 1;
      ent[5] = 0;
      ent[6] = (uint8_t)(ndesc & 255);
      ent[7] = (uint8_t)((ndesc >> 8) & 255);
      ent[8] = (uint8_t)(csize & 255);
      ent[9] = (uint8_t)((csize >> 8) & 255);
      ent[10] = (uint8_t)((csize >> 16) & 255);
      ent[11] = (uint8_t)((csize >> 24) & 255);
    } else {
      /* N_SECT|N_EXT = 0x0f; F7: n_sect based on symbol's shndx
       * (1 = __TEXT,__text; 2 = __DATA,__const).
       * n_value = section addr + offset-in-section (data section addr = data_vmaddr). */
      sym_shndx = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      n_sect = 1;
      n_val = sym_va;
      if (sym_shndx == PIPELINE_ELF_SHNX_DATA) {
        n_sect = 2;
        n_val = data_vmaddr + sym_va;
      }
      ent[4] = 15;
      ent[5] = (uint8_t)n_sect;
      ent[8] = (uint8_t)(n_val & 255);
      ent[9] = (uint8_t)((n_val >> 8) & 255);
      ent[10] = (uint8_t)((n_val >> 16) & 255);
      ent[11] = (uint8_t)((n_val >> 24) & 255);
    }
    if (pipeline_elf_out_append(out, ent, 16) != 0)
      return -1;
    str_off = str_off + ctx->syms[s].name_len + pipeline_macho_link_name_extra_byte(sym_pool + off) + 1;
    s = s + 1;
  }

  uu = 0;
  while (uu < nu) {
    uint8_t entu[16];
    int32_t sr = und_src_reloc[uu];
    uint8_t *und_ptr = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr);
    memset(entu, 0, sizeof(entu));
    entu[0] = (uint8_t)(str_off & 255);
    entu[1] = (uint8_t)((str_off >> 8) & 255);
    entu[2] = (uint8_t)((str_off >> 16) & 255);
    entu[3] = (uint8_t)((str_off >> 24) & 255);
    /* N_UNDF | N_EXT */
    entu[4] = 1;
    if (pipeline_elf_out_append(out, entu, 16) != 0)
      return -1;
    str_off = str_off + und_lens[uu] + pipeline_macho_link_name_extra_byte(und_ptr) + 1;
    uu = uu + 1;
  }

  /* string table: leading NUL then names (optional leading '_') */
  if (pipeline_elf_out_append(out, z0, 1) != 0)
    return -1;
  uscore[0] = 95;
  s = 0;
  while (s < ctx->num_syms) {
    int32_t off = pipeline_elf_sym_name_off(ctx, s);
    uint8_t *nm = sym_pool + off;
    int32_t nlen = ctx->syms[s].name_len;
    if (pipeline_macho_link_name_extra_byte(nm) != 0) {
      if (pipeline_elf_out_append(out, uscore, 1) != 0)
        return -1;
    }
    if (nlen > 0 && pipeline_elf_out_append(out, nm, nlen) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  uu = 0;
  while (uu < nu) {
    int32_t sr = und_src_reloc[uu];
    uint8_t *und_ptr = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, sr);
    if (pipeline_macho_link_name_extra_byte(und_ptr) != 0) {
      if (pipeline_elf_out_append(out, uscore, 1) != 0)
        return -1;
    }
    if (und_lens[uu] > 0 && und_ptr && pipeline_elf_out_append(out, und_ptr, und_lens[uu]) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    uu = uu + 1;
  }

  /* relocation entries: default BRANCH26/BRANCH type 2; wave405 typed PAGE21/PAGEOFF12. */
  rel_type = 2;
  rel_len = 2;
  if (ctx->e_machine == 183) {
    rel_type = 2;
    rel_len = 2;
  }
  /* F7: two-pass reloc emission — text-section relocs first (shndx != 4),
   * then data-section relocs (shndx == 4). Sequential append matches the file
   * layout: off_reloc_text then off_reloc_data. */
  pass = 0;
  while (pass < 2) {
    want_data = (pass == 1) ? 1 : 0;
    r = 0;
    while (r < ctx->num_relocs) {
      uint8_t ri[8];
      int32_t sym_idx = 0;
      int32_t found_def = 0;
      int32_t m = 0;
      uint8_t r_sym_buf[256];
      int32_t rlen;
      int32_t r_sym;
      int32_t word2;
      int32_t roff;
      int32_t use_type;
      int32_t use_pcrel;
      int32_t eff_len;
      r_sd = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r);
      is_data = (r_sd == PIPELINE_ELF_SHNX_DATA) ? 1 : 0;
      if (is_data != want_data) {
        r = r + 1;
        continue;
      }
      pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
      rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
      while (m < ctx->num_syms) {
        int32_t off = pipeline_elf_sym_name_off(ctx, m);
        if (pipeline_macho_name_eq(r_sym_buf, rlen, sym_pool + off, ctx->syms[m].name_len) != 0) {
          sym_idx = m;
          found_def = 1;
          break;
        }
        m = m + 1;
      }
      if (found_def == 0) {
        int32_t uslot = -1;
        int32_t us2 = 0;
        while (us2 < nu) {
          uint8_t sr2_buf[256];
          int32_t sr2 = und_src_reloc[us2];
          pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, sr2, sr2_buf);
          if (pipeline_macho_name_eq(r_sym_buf, rlen, sr2_buf, und_lens[us2]) != 0) {
            uslot = us2;
            break;
          }
          us2 = us2 + 1;
        }
        if (uslot < 0) {
          driver_diagnostic_asm_macho_missing_und_reloc(r);
          return -1;
        }
        sym_idx = ctx->num_syms + uslot;
      }
      use_type = rel_type;
      use_pcrel = 1;
      /* wave612: G.7 consume typed sidecar via accessors. This TU's
       * g_pipeline_elf_reloc_r_type is empty when append_reloc_typed is the
       * elf_ctx PREFER overlay — private read made every ADRP BRANCH26.
       * PLATFORM: MACOS|DARWIN writer. */
      {
        int32_t rt = pipeline_elf_ctx_reloc_r_type_at(ctx_bytes, r);
        int32_t rp;
        if (rt != 0)
          use_type = rt;
        rp = pipeline_elf_ctx_reloc_r_pcrel_at(ctx_bytes, r);
        if (rp != -1)
          use_pcrel = rp;
      }
      /* F7 absolute64: sentinel r_type=200 → ARM64_RELOC_UNSIGNED (type=0, pcrel=0,
       * length=3 quad-word). Without this vtable data slots fall to default
       * BRANCH26 and ld rejects ("relocation on non-b/bl instruction"). */
      eff_len = rel_len;
      if (use_type == 200) {
        use_type = 0;
        use_pcrel = 0;
        eff_len = 3;
      }
      /* r_symbolnum is 0-based after dropping dummy nlist[0]. */
      r_sym = sym_idx;
      word2 = (r_sym & 16777215) | ((use_pcrel & 1) << 24) | (eff_len << 25) | (1 << 27) | (use_type << 28);
      roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
      ri[0] = (uint8_t)(roff & 255);
      ri[1] = (uint8_t)((roff >> 8) & 255);
      ri[2] = (uint8_t)((roff >> 16) & 255);
      ri[3] = (uint8_t)((roff >> 24) & 255);
      ri[4] = (uint8_t)(word2 & 255);
      ri[5] = (uint8_t)((word2 >> 8) & 255);
      ri[6] = (uint8_t)((word2 >> 16) & 255);
      ri[7] = (uint8_t)((word2 >> 24) & 255);
      if (pipeline_elf_out_append(out, ri, 8) != 0)
        return -1;
      r = r + 1;
    }
    pass = pass + 1;
  }
  return codegen_out_buf_len(out);
}

/**
 * Product surface: Darwin user_asm_seed_bridge weak_import target.
 * Strong body overrides seeds/asm_experimental_symbol_bridge weak -1 stub.
 * PLATFORM: MACOS pure-asm (also linked on Linux; unused there).
 */
int32_t platform_macho_write_macho_o_to_buf(void *elf_ctx, void *out_buf) {
  if (!elf_ctx || !out_buf)
    return -1;
  return pipeline_macho_write_o_to_buf_c((uint8_t *)elf_ctx, (struct codegen_CodegenOutBuf *)out_buf);
}

/**
 * PGO-Lite：写出 .text（空）/ .text.hot / .text.unlikely 三代码段 ELF64 ET_REL .o。
 * code_data→unlikely，code_hot_data→hot；冷/热/空 rela 分表。
 */
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *unlikely;
  uint8_t *hot;
  int32_t code_unlikely_len;
  int32_t code_hot_len;
  int32_t strtab_off;
  int32_t strtab_size;
  int32_t num_undef;
  uint8_t undef_names[32][128];
  int32_t undef_lens[32];
  int32_t num_text_rela;
  int32_t num_hot_rela;
  int32_t num_unlikely_rela;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t align_hot;
  int32_t align_unlikely;
  int32_t off_text;
  int32_t off_hot;
  int32_t off_unlikely;
  int32_t off_strtab;
  int32_t off_shstrtab;
  int32_t off_symtab;
  int32_t off_rela_text;
  int32_t off_rela_hot;
  int32_t off_rela_unlikely;
  int32_t off_shdr;
  /** shstrtab：.text / .text.hot / .text.unlikely / symtab / strtab / shstrtab / rela×3 */
  static const uint8_t shstrtab_pgo[107] = {
      0,
      46, 116, 101, 120, 116, 0,
      46, 116, 101, 120, 116, 46, 104, 111, 116, 0,
      46, 116, 101, 120, 116, 46, 117, 110, 108, 105, 107, 101, 108, 121, 0,
      46, 115, 121, 109, 116, 97, 98, 0,
      46, 115, 116, 114, 116, 97, 98, 0,
      46, 115, 104, 115, 116, 114, 116, 97, 98, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 46, 104, 111, 116, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 46, 117, 110, 108, 105, 107, 101, 108, 121, 0};
  uint8_t ehdr[128];
  uint8_t z0[1];
  int32_t s;
  int32_t r0;
  int32_t r;
  int32_t e_machine;
  int32_t reloc_type;
  if (!ctx_bytes || !out)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  unlikely = ctx_bytes + kPipelineElfCtxCodeDataOff;
  hot = ctx_bytes + kPipelineElfCtxCodeHotDataOff;
  code_unlikely_len = ctx->code_len;
  code_hot_len = ctx->code_hot_len;
  e_machine = ctx->e_machine;
  reloc_type = ctx->reloc_type_r_pc32;
  num_undef = 0;
  num_text_rela = 0;
  num_hot_rela = 0;
  num_unlikely_rela = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    uint8_t rname[256];
    int32_t rlen;
    int32_t rsh;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, rname);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipeline_elf_reloc_is_defined(ctx, ctx_bytes, r0, rname, rlen) == 0) {
      int32_t u0;
      int32_t dup;
      dup = 0;
      u0 = 0;
      while (u0 < num_undef) {
        if (undef_lens[u0] == rlen && rlen > 0 && memcmp(undef_names[u0], rname, (size_t)rlen) == 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < 32) {
        /* wave580 Cap: undef_names rows are u8[128]; full row ('_'+127). */
        if (rlen > 128)
          rlen = 128;
        if (rlen > 0)
          memcpy(undef_names[num_undef], rname, (size_t)rlen);
        undef_lens[num_undef] = rlen;
        num_undef = num_undef + 1;
      }
    }
    rsh = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r0);
    if (rsh == PIPELINE_ELF_SHNX_TEXT_HOT)
      num_hot_rela = num_hot_rela + 1;
    else if (rsh == PIPELINE_ELF_SHNX_TEXT_UNLIKELY)
      num_unlikely_rela = num_unlikely_rela + 1;
    else
      num_text_rela = num_text_rela + 1;
    r0 = r0 + 1;
  }
  strtab_off = 1;
  s = 0;
  while (s < ctx->num_syms) {
    strtab_off = strtab_off + ctx->syms[s].name_len + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + undef_lens[s] + 1;
    s = s + 1;
  }
  strtab_size = strtab_off;
  symtab_ents = 3 + ctx->num_syms + num_undef;
  symtab_size = symtab_ents * 24;
  align_hot = (code_hot_len + 3) & ~3;
  align_unlikely = (code_unlikely_len + 3) & ~3;
  off_text = 64;
  off_hot = off_text;
  off_unlikely = off_hot + align_hot;
  off_strtab = off_unlikely + align_unlikely;
  off_shstrtab = off_strtab + strtab_size;
  off_symtab = off_shstrtab + 107;
  off_rela_text = off_symtab + symtab_size;
  off_rela_hot = off_rela_text + num_text_rela * 24;
  off_rela_unlikely = off_rela_hot + num_hot_rela * 24;
  off_shdr = off_rela_unlikely + num_unlikely_rela * 24;
  memset(ehdr, 0, sizeof(ehdr));
  ehdr[0] = 127;
  ehdr[1] = 69;
  ehdr[2] = 76;
  ehdr[3] = 70;
  ehdr[4] = 2;
  ehdr[5] = 1;
  ehdr[6] = 1;
  ehdr[16] = 1;
  ehdr[18] = (uint8_t)(e_machine & 255);
  ehdr[19] = (uint8_t)((e_machine >> 8) & 255);
  /* ET_REL PGO：e_phoff@32 等为 0（同 pipeline_elf_write_o_standard_to_buf_c）。 */
  ehdr[40] = (uint8_t)(off_shdr & 255);
  ehdr[41] = (uint8_t)((off_shdr >> 8) & 255);
  ehdr[42] = (uint8_t)((off_shdr >> 16) & 255);
  ehdr[43] = (uint8_t)((off_shdr >> 24) & 255);
  ehdr[52] = 64;
  ehdr[58] = 64;
  ehdr[60] = 10;
  ehdr[62] = 6;
  codegen_out_buf_set_len(out, 0);
  if (pipeline_elf_out_append(out, ehdr, 64) != 0)
    return -1;
  if (code_hot_len > 0 && pipeline_elf_out_append(out, hot, code_hot_len) != 0)
    return -1;
  z0[0] = 0;
  s = code_hot_len;
  while (s < align_hot) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (code_unlikely_len > 0 && pipeline_elf_out_append(out, unlikely, code_unlikely_len) != 0)
    return -1;
  s = code_unlikely_len;
  while (s < align_unlikely) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, z0, 1) != 0)
    return -1;
  {
    uint8_t *sym_pool;
    int32_t str_off;
    sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
    s = 0;
    while (s < ctx->num_syms) {
      int32_t nlen;
      nlen = ctx->syms[s].name_len;
      if (nlen > 0 && pipeline_elf_out_append(out, sym_pool + pipeline_elf_sym_name_off(ctx, s), nlen) != 0)
        return -1;
      if (pipeline_elf_out_append(out, z0, 1) != 0)
        return -1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      if (undef_lens[s] > 0 && pipeline_elf_out_append(out, undef_names[s], undef_lens[s]) != 0)
        return -1;
      if (pipeline_elf_out_append(out, z0, 1) != 0)
        return -1;
      s = s + 1;
    }
    if (pipeline_elf_out_append(out, shstrtab_pgo, 107) != 0)
      return -1;
    {
      uint8_t sym_sect[24];
      memset(sym_sect, 0, sizeof(sym_sect));
      sym_sect[4] = 3;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT;
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT_HOT;
      sym_sect[8] = (uint8_t)(code_hot_len & 255);
      sym_sect[9] = (uint8_t)((code_hot_len >> 8) & 255);
      sym_sect[10] = (uint8_t)((code_hot_len >> 16) & 255);
      sym_sect[11] = (uint8_t)((code_hot_len >> 24) & 255);
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
      sym_sect[8] = (uint8_t)(code_unlikely_len & 255);
      sym_sect[9] = (uint8_t)((code_unlikely_len >> 8) & 255);
      sym_sect[10] = (uint8_t)((code_unlikely_len >> 16) & 255);
      sym_sect[11] = (uint8_t)((code_unlikely_len >> 24) & 255);
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
    }
    str_off = 1;
    s = 0;
    while (s < ctx->num_syms) {
      uint8_t ent[24];
      int32_t shndx;
      int32_t is_common;
      int32_t csize;
      int32_t calign;
      memset(ent, 0, sizeof(ent));
      is_common = (s < PIPELINE_ELF_CTX_TABLE_CAP &&
                   pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s) == 65522) /* wave672: shndx sole authority (stale sidecar bits misclassified functions as COM) */
                      ? 1
                      : 0;
      shndx = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      /* wave613 root fix: SHN_COMMON (65522) authority fallback (same class
       * as the main ELF/Mach-O writers — see wave613 notes there). */
      if (is_common == 0 && shndx == 65522) {
        is_common = 1;
      }
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      if (is_common != 0) {
        /* wave696: ctx offset is the COMMON size authority. Sidecar size is
         * dual-copy and FORCE full-body emit smashes it to 1 (same class as
         * w672 is_common bits). PLATFORM: SHARED. */
        csize = ctx->syms[s].offset;
        calign = g_pipeline_elf_sym_common_align[s];
        if (calign <= 0)
          calign = 8;
        if (csize <= 0)
          csize = g_pipeline_elf_sym_common_size[s];
        if (csize <= 0)
          csize = 8;
        ent[4] = 17;
        ent[6] = 0xf2;
        ent[7] = 0xff;
        ent[8] = (uint8_t)(calign & 255);
        ent[9] = (uint8_t)((calign >> 8) & 255);
        ent[10] = (uint8_t)((calign >> 16) & 255);
        ent[11] = (uint8_t)((calign >> 24) & 255);
        ent[16] = (uint8_t)(csize & 255);
        ent[17] = (uint8_t)((csize >> 8) & 255);
        ent[18] = (uint8_t)((csize >> 16) & 255);
        ent[19] = (uint8_t)((csize >> 24) & 255);
      } else {
        ent[4] = 18;
        ent[6] = (uint8_t)(shndx & 255);
        ent[7] = (uint8_t)((shndx >> 8) & 255);
        ent[8] = (uint8_t)(ctx->syms[s].offset & 255);
        ent[9] = (uint8_t)((ctx->syms[s].offset >> 8) & 255);
        ent[10] = (uint8_t)((ctx->syms[s].offset >> 16) & 255);
        ent[11] = (uint8_t)((ctx->syms[s].offset >> 24) & 255);
      }
      if (pipeline_elf_out_append(out, ent, 24) != 0)
        return -1;
      str_off = str_off + ctx->syms[s].name_len + 1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      uint8_t uent[24];
      memset(uent, 0, sizeof(uent));
      uent[0] = (uint8_t)(str_off & 255);
      uent[1] = (uint8_t)((str_off >> 8) & 255);
      uent[2] = (uint8_t)((str_off >> 16) & 255);
      uent[3] = (uint8_t)((str_off >> 24) & 255);
      uent[4] = 18;
      if (pipeline_elf_out_append(out, uent, 24) != 0)
        return -1;
      str_off = str_off + undef_lens[s] + 1;
      s = s + 1;
    }
  }
  /** 写出 rela 表（按 shndx 分三段；sym index 含 3 个 STT_SECTION 占位）。 */
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t want_sh;
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[256];
    int32_t rlen;
    want_sh = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r);
    if (want_sh != PIPELINE_ELF_SHNX_TEXT)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[256];
    int32_t rlen;
    if (pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r) != PIPELINE_ELF_SHNX_TEXT_HOT)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[256];
    int32_t rlen;
    if (pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r) != PIPELINE_ELF_SHNX_TEXT_UNLIKELY)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  {
    uint8_t shdr0[128];
    uint8_t shdr_text[128];
    uint8_t shdr_hot[128];
    uint8_t shdr_unlikely[128];
    uint8_t shdr_sym[128];
    uint8_t shdr_str[128];
    uint8_t shdr_shstr[128];
    uint8_t shdr_rela_text[128];
    uint8_t shdr_rela_hot[128];
    uint8_t shdr_rela_unlikely[128];
    memset(shdr0, 0, sizeof(shdr0));
    memset(shdr_text, 0, sizeof(shdr_text));
    memset(shdr_hot, 0, sizeof(shdr_hot));
    memset(shdr_unlikely, 0, sizeof(shdr_unlikely));
    memset(shdr_sym, 0, sizeof(shdr_sym));
    memset(shdr_str, 0, sizeof(shdr_str));
    memset(shdr_shstr, 0, sizeof(shdr_shstr));
    memset(shdr_rela_text, 0, sizeof(shdr_rela_text));
    memset(shdr_rela_hot, 0, sizeof(shdr_rela_hot));
    memset(shdr_rela_unlikely, 0, sizeof(shdr_rela_unlikely));
    shdr_text[0] = 1;
    shdr_text[4] = 1;
    shdr_text[8] = 6;
    shdr_text[24] = (uint8_t)(off_text & 255);
    shdr_text[25] = (uint8_t)((off_text >> 8) & 255);
    shdr_text[26] = (uint8_t)((off_text >> 16) & 255);
    shdr_text[27] = (uint8_t)((off_text >> 24) & 255);
    shdr_hot[0] = 7;
    shdr_hot[4] = 1;
    shdr_hot[8] = 6;
    shdr_hot[24] = (uint8_t)(off_hot & 255);
    shdr_hot[25] = (uint8_t)((off_hot >> 8) & 255);
    shdr_hot[26] = (uint8_t)((off_hot >> 16) & 255);
    shdr_hot[27] = (uint8_t)((off_hot >> 24) & 255);
    shdr_hot[32] = (uint8_t)(code_hot_len & 255);
    shdr_hot[33] = (uint8_t)((code_hot_len >> 8) & 255);
    shdr_hot[34] = (uint8_t)((code_hot_len >> 16) & 255);
    shdr_hot[35] = (uint8_t)((code_hot_len >> 24) & 255);
    shdr_unlikely[0] = 17;
    shdr_unlikely[4] = 1;
    shdr_unlikely[8] = 6;
    shdr_unlikely[24] = (uint8_t)(off_unlikely & 255);
    shdr_unlikely[25] = (uint8_t)((off_unlikely >> 8) & 255);
    shdr_unlikely[26] = (uint8_t)((off_unlikely >> 16) & 255);
    shdr_unlikely[27] = (uint8_t)((off_unlikely >> 24) & 255);
    shdr_unlikely[32] = (uint8_t)(code_unlikely_len & 255);
    shdr_unlikely[33] = (uint8_t)((code_unlikely_len >> 8) & 255);
    shdr_unlikely[34] = (uint8_t)((code_unlikely_len >> 16) & 255);
    shdr_unlikely[35] = (uint8_t)((code_unlikely_len >> 24) & 255);
    shdr_sym[0] = 32;
    shdr_sym[4] = 2;
    shdr_sym[24] = (uint8_t)(off_symtab & 255);
    shdr_sym[25] = (uint8_t)((off_symtab >> 8) & 255);
    shdr_sym[26] = (uint8_t)((off_symtab >> 16) & 255);
    shdr_sym[27] = (uint8_t)((off_symtab >> 24) & 255);
    shdr_sym[32] = (uint8_t)(symtab_size & 255);
    shdr_sym[33] = (uint8_t)((symtab_size >> 8) & 255);
    shdr_sym[34] = (uint8_t)((symtab_size >> 16) & 255);
    shdr_sym[35] = (uint8_t)((symtab_size >> 24) & 255);
    shdr_sym[40] = 5;
    shdr_sym[44] = 1;
    shdr_sym[56] = 24;
    shdr_str[0] = 40;
    shdr_str[4] = 3;
    shdr_str[24] = (uint8_t)(off_strtab & 255);
    shdr_str[25] = (uint8_t)((off_strtab >> 8) & 255);
    shdr_str[26] = (uint8_t)((off_strtab >> 16) & 255);
    shdr_str[27] = (uint8_t)((off_strtab >> 24) & 255);
    shdr_str[32] = (uint8_t)(strtab_size & 255);
    shdr_str[33] = (uint8_t)((strtab_size >> 8) & 255);
    shdr_str[34] = (uint8_t)((strtab_size >> 16) & 255);
    shdr_str[35] = (uint8_t)((strtab_size >> 24) & 255);
    shdr_str[48] = 1;
    shdr_shstr[0] = 48;
    shdr_shstr[4] = 3;
    shdr_shstr[24] = (uint8_t)(off_shstrtab & 255);
    shdr_shstr[25] = (uint8_t)((off_shstrtab >> 8) & 255);
    shdr_shstr[26] = (uint8_t)((off_shstrtab >> 16) & 255);
    shdr_shstr[27] = (uint8_t)((off_shstrtab >> 24) & 255);
    shdr_shstr[32] = 107;
    shdr_shstr[48] = 1;
    shdr_rela_text[0] = 58;
    shdr_rela_text[4] = 4;
    shdr_rela_text[24] = (uint8_t)(off_rela_text & 255);
    shdr_rela_text[25] = (uint8_t)((off_rela_text >> 8) & 255);
    shdr_rela_text[26] = (uint8_t)((off_rela_text >> 16) & 255);
    shdr_rela_text[27] = (uint8_t)((off_rela_text >> 24) & 255);
    shdr_rela_text[32] = (uint8_t)((num_text_rela * 24) & 255);
    shdr_rela_text[33] = (uint8_t)(((num_text_rela * 24) >> 8) & 255);
    shdr_rela_text[34] = (uint8_t)(((num_text_rela * 24) >> 16) & 255);
    shdr_rela_text[35] = (uint8_t)(((num_text_rela * 24) >> 24) & 255);
    shdr_rela_text[40] = 4;
    shdr_rela_text[44] = 1;
    shdr_rela_text[56] = 24;
    shdr_rela_hot[0] = 71;
    shdr_rela_hot[4] = 4;
    shdr_rela_hot[24] = (uint8_t)(off_rela_hot & 255);
    shdr_rela_hot[25] = (uint8_t)((off_rela_hot >> 8) & 255);
    shdr_rela_hot[26] = (uint8_t)((off_rela_hot >> 16) & 255);
    shdr_rela_hot[27] = (uint8_t)((off_rela_hot >> 24) & 255);
    shdr_rela_hot[32] = (uint8_t)((num_hot_rela * 24) & 255);
    shdr_rela_hot[33] = (uint8_t)(((num_hot_rela * 24) >> 8) & 255);
    shdr_rela_hot[34] = (uint8_t)(((num_hot_rela * 24) >> 16) & 255);
    shdr_rela_hot[35] = (uint8_t)(((num_hot_rela * 24) >> 24) & 255);
    shdr_rela_hot[40] = 4;
    shdr_rela_hot[44] = 2;
    shdr_rela_hot[56] = 24;
    shdr_rela_unlikely[0] = 86;
    shdr_rela_unlikely[4] = 4;
    shdr_rela_unlikely[24] = (uint8_t)(off_rela_unlikely & 255);
    shdr_rela_unlikely[25] = (uint8_t)((off_rela_unlikely >> 8) & 255);
    shdr_rela_unlikely[26] = (uint8_t)((off_rela_unlikely >> 16) & 255);
    shdr_rela_unlikely[27] = (uint8_t)((off_rela_unlikely >> 24) & 255);
    shdr_rela_unlikely[32] = (uint8_t)((num_unlikely_rela * 24) & 255);
    shdr_rela_unlikely[33] = (uint8_t)(((num_unlikely_rela * 24) >> 8) & 255);
    shdr_rela_unlikely[34] = (uint8_t)(((num_unlikely_rela * 24) >> 16) & 255);
    shdr_rela_unlikely[35] = (uint8_t)(((num_unlikely_rela * 24) >> 24) & 255);
    shdr_rela_unlikely[40] = 4;
    shdr_rela_unlikely[44] = 3;
    shdr_rela_unlikely[56] = 24;
    if (pipeline_elf_out_append(out, shdr0, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_text, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_hot, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_unlikely, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_sym, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_str, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_shstr, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_text, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_hot, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_unlikely, 64) != 0)
      return -1;
  }
  return codegen_out_buf_len(out);
}




/** 写第 idx 条 reloc 的 code offset（内联或 heap sidecar）。 */
void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    ctx->relocs[idx].offset = offset;
    return;
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return;
  g_pipeline_elf_reloc_heap[hi].offset = offset;
}

struct platform_elf_ElfCodegenCtx;

/**
 * 多 Module 顺序写入同一 ElfCodegenCtx 时，为 `.Lf<scope>_<n>` 提供跨 Module 唯一 scope。
 * 每 Module 占 256 个 func 槽；elf_ctx_reset 时清零。
 */
static int32_t g_pipeline_elf_label_mod_scope_base;

void pipeline_elf_label_mod_scope_reset(void) {
  g_pipeline_elf_label_mod_scope_base = 0;
}

int32_t pipeline_elf_label_mod_scope_next_module(void) {
  int32_t base = g_pipeline_elf_label_mod_scope_base;
  g_pipeline_elf_label_mod_scope_base = g_pipeline_elf_label_mod_scope_base + 256;
  return base;
}

/** 当前 Module 写入共享 ElfCodegenCtx 时的标签 scope（与 pipeline_asm_emit_next_label_c 对齐）。 */
static int32_t g_pipeline_elf_label_mod_scope_active;

/**
 * 每个 Module 开始 asm_codegen_ast_to_elf 前调用一次，避免多 Module 共用 elf_ctx 时 `.L_0` 标签名碰撞。
 */
void pipeline_elf_label_mod_scope_begin_module(void) {
  g_pipeline_elf_label_mod_scope_active = pipeline_elf_label_mod_scope_next_module();
}

/** 返回当前 emit 模块的 ELF 局部标签 scope。 */
int32_t pipeline_elf_label_mod_scope_active(void) {
  return g_pipeline_elf_label_mod_scope_active;
}

/** 追加或更新局部标签；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  int32_t li;
  int32_t n;
  int32_t shndx;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  shndx = pipeline_elf_ctx_current_shndx(ctx);
  l = 0;
  while (l < ctx->num_labels) {
    if (ctx->labels[l].name_len == name_len && name_len > 0 &&
        memcmp(ctx->labels[l].name, name, (size_t)name_len) == 0) {
      ctx->labels[l].offset = offset;
      pipeline_elf_label_shndx_set(ctx_bytes, l, shndx);
      return 0;
    }
    l = l + 1;
  }
  if (ctx->num_labels >= PIPELINE_ELF_CTX_LABEL_CAP)
    return -1;
  li = ctx->num_labels;
  /* Cap 4.2.8: labels.name is u8[256]; store up to 255 content (was wave580 128). */
  n = name_len > 255 ? 255 : name_len;
  if (n < 0)
    n = 0;
  if (n > 0)
    memcpy(ctx->labels[li].name, name, (size_t)n);
  ctx->labels[li].name_len = n;
  ctx->labels[li].offset = offset;
  pipeline_elf_label_shndx_set(ctx_bytes, li, shndx);
  ctx->num_labels = ctx->num_labels + 1;
  return 0;
}

/** 前向跳转占位标签（offset=-1）；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  l = 0;
  while (l < ctx->num_labels) {
    if (ctx->labels[l].name_len == name_len && name_len > 0 &&
        memcmp(ctx->labels[l].name, name, (size_t)name_len) == 0) {
      return 0;
    }
    l = l + 1;
  }
  return pipeline_elf_ctx_add_label(ctx_bytes, name, name_len, -1);
}

/** Mach-O/ELF 函数入口 4 字节对齐；端口 elf.x elf_pad_code_to_4。 */
int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes) {
  uint8_t pad[1] = {0};
  if (!ctx_bytes)
    return -1;
  while (pipeline_elf_ctx_emit_code_len(ctx_bytes) % 4 != 0) {
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, pad, 1) != 0)
      return -1;
  }
  return 0;
}

/** 记录导出符号；端口 elf.x elf_add_sym。 */
int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  uint8_t *sym_pool;
  int32_t copy_len;
  int32_t k;
  int32_t shndx;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_syms >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  if (g_pipeline_elf_common_owner != ctx_bytes)
    pipeline_elf_common_sidecar_reset(ctx_bytes);
  copy_len = name_len;
  /* Cap 4.2.8: sym name pool holds link names up to 256
   * ('_' + 255 AST content on Darwin). Was wave580 128. */
  if (copy_len > 256)
    copy_len = 256;
  if (copy_len < 0)
    copy_len = 0;
  if (ctx->sym_name_len + copy_len > 131072)
    return -1;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  k = 0;
  while (k < copy_len) {
    sym_pool[ctx->sym_name_len + k] = name[k];
    k = k + 1;
  }
  ctx->sym_name_len = ctx->sym_name_len + copy_len;
  ctx->syms[ctx->num_syms].name_len = copy_len;
  ctx->syms[ctx->num_syms].offset = offset;
  /* F7: respect shndx override (data section for vtable statics). */
  if (g_pipeline_elf_shndx_override != 0)
    shndx = g_pipeline_elf_shndx_override;
  else if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
    shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
  else if (pipeline_elf_pgo_hot_enabled() != 0)
    shndx = PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
  else
    shndx = PIPELINE_ELF_SHNX_TEXT;
  ctx->syms[ctx->num_syms].sym_shndx = shndx;
  g_pipeline_elf_sym_is_common[ctx->num_syms] = 0;
  ctx->num_syms = ctx->num_syms + 1;
  return 0;
}

/**
 * PLATFORM: SHARED — add SHN_COMMON object symbol (linker BSS, writable).
 * Used by asm modlet (true cross-fn mutable top-level lit lets).
 */
int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size,
                                        int32_t align) {
  PipelineElfCtxAccess *ctx;
  int32_t si;
  if (!ctx_bytes || !name || name_len <= 0 || size <= 0)
    return -1;
  if (align <= 0)
    align = 8;
  if (g_pipeline_elf_common_owner != ctx_bytes)
    pipeline_elf_common_sidecar_reset(ctx_bytes);
  /* offset unused for COMMON; store size in offset for debug. */
  if (pipeline_elf_ctx_add_sym(ctx_bytes, name, name_len, size) != 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  si = ctx->num_syms - 1;
  if (si < 0 || si >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  g_pipeline_elf_sym_is_common[si] = 1;
  g_pipeline_elf_sym_common_size[si] = size;
  g_pipeline_elf_sym_common_align[si] = align;
  /* Distinct from .text so writers can branch. */
  ctx->syms[si].sym_shndx = 0xfff2;
  return 0;
}

/**
 * Query whether sym[s] is SHN_COMMON. G.7 twin of .x accessors for
 * macho_write_thin / cold writers. PLATFORM: SHARED.
 */
int32_t pipeline_elf_ctx_sym_is_common_at(uint8_t *ctx_bytes, int32_t s) {
  if (!ctx_bytes || s < 0 || s >= PIPELINE_ELF_CTX_TABLE_CAP)
    return 0;
  if (g_pipeline_elf_common_owner != ctx_bytes)
    return 0;
  return g_pipeline_elf_sym_is_common[s] != 0 ? 1 : 0;
}

/** COMMON size for writer. wave696: classify via shndx==65522 (w672),
 * then ctx offset is the size authority. PLATFORM: SHARED. */
int32_t pipeline_elf_ctx_sym_common_size_at(uint8_t *ctx_bytes, int32_t s) {
  PipelineElfCtxAccess *ctx;
  int32_t off;
  if (!ctx_bytes || s < 0 || s >= PIPELINE_ELF_CTX_TABLE_CAP)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->syms[s].sym_shndx != 0xfff2)
    return 0;
  off = ctx->syms[s].offset;
  if (off > 0)
    return off;
  return g_pipeline_elf_sym_common_size[s];
}

/** COMMON align for writer. PLATFORM: SHARED. */
int32_t pipeline_elf_ctx_sym_common_align_at(uint8_t *ctx_bytes, int32_t s) {
  if (pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s) == 0)
    return 0;
  return g_pipeline_elf_sym_common_align[s];
}

/**
 * Reloc r_type sidecar for writers. G.7 twin of .x —
 * macho_write_thin private statics stay empty (ADRP→BRANCH26).
 * PLATFORM: SHARED · MACOS writer co-path.
 */
int32_t pipeline_elf_ctx_reloc_r_type_at(uint8_t *ctx_bytes, int32_t r) {
  if (!ctx_bytes || r < 0 || r >= PIPELINE_ELF_CTX_TABLE_CAP)
    return 0;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return 0;
  return g_pipeline_elf_reloc_r_type[r];
}

/**
 * Reloc r_pcrel sidecar (-1 = writer default). PLATFORM: SHARED.
 */
int32_t pipeline_elf_ctx_reloc_r_pcrel_at(uint8_t *ctx_bytes, int32_t r) {
  if (!ctx_bytes || r < 0 || r >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return -1;
  return (int32_t)g_pipeline_elf_reloc_r_pcrel[r];
}

/** 读 ElfCodegenCtx.macho_leading_underscore（Darwin call/reloc 前缀 `_`）。 */
int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->macho_leading_underscore;
}

/** 追加一条 rel32 补丁槽；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                      int32_t imm_bits) {
  PipelineElfCtxAccess *ctx;
  PipelineElfPatchEntry *ent;
  int32_t pi;
  int32_t n;
  int32_t bits;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_patches >= PIPELINE_ELF_CTX_PATCH_CAP) {
    pabi_trace( "xlang: elf num_patches limit %d reached\n", PIPELINE_ELF_CTX_PATCH_CAP);
    return -1;
  }
  bits = imm_bits;
  /*
   * arm64 enc_jz 应传 imm_bits=19；偶发仍为 0 时 elf_resolve_patches 误走 x86 rel32，
   * 把 cbz 占位 0x34xxxxxx 写成 udf 非法指令（Mach-O 烟测 SIGILL）。
   */
#if defined(__APPLE__) && defined(__aarch64__)
  if (bits == 0)
    bits = 19;
#endif
  pi = ctx->num_patches;
  ent = &ctx->patches[pi];
  ent->rel32_offset = rel32_offset;
  /* Cap 4.2.8: patches.name is u8[256]; store clamped length matching copied bytes. */
  n = name_len > 255 ? 255 : name_len;
  if (n < 0)
    n = 0;
  if (n > 0)
    memcpy(ent->name, name, (size_t)n);
  ent->name_len = n;
  ent->patch_imm_bits = bits;
  pipeline_elf_patch_shndx_set(ctx_bytes, pi, pipeline_elf_ctx_current_shndx(ctx));
  ctx->num_patches = ctx->num_patches + 1;
  return 0;
}

/** 读取第 patch_idx 条补丁的 imm_bits；越界返回 0。 */
int32_t pipeline_elf_ctx_patch_imm_bits_at(uint8_t *ctx_bytes, int32_t patch_idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || patch_idx < 0 || patch_idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (patch_idx >= ctx->num_patches)
    return 0;
  return ctx->patches[patch_idx].patch_imm_bits;
}

/** 读 ctx 指定段 code 小端 u32；ctx 为完整 ElfCodegenCtx 字节视图。 */
static int32_t pipeline_elf_ctx_read_u32_le(uint8_t *ctx_bytes, int32_t shndx, int32_t off) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return 0;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  return (int32_t)((unsigned)code[off] | ((unsigned)code[off + 1] << 8) | ((unsigned)code[off + 2] << 16) |
                   ((unsigned)code[off + 3] << 24));
}

/** 写 ctx 指定段 code 小端 u32。 */
static void pipeline_elf_ctx_write_u32_le(uint8_t *ctx_bytes, int32_t shndx, int32_t off, int32_t word) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  code[off] = (uint8_t)(word & 255);
  code[off + 1] = (uint8_t)((word >> 8) & 255);
  code[off + 2] = (uint8_t)((word >> 16) & 255);
  code[off + 3] = (uint8_t)((word >> 24) & 255);
}

/** 从占位指令推断 arm64/riscv patch 位宽；与 platform/elf.x elf_infer_patch_imm_bits_from_code 一致。 */
static int32_t pipeline_elf_ctx_infer_patch_imm_bits(uint8_t *ctx_bytes, int32_t shndx, int32_t rel32_offset) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  int32_t op8;
  if (!ctx_bytes || rel32_offset < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (rel32_offset + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return 0;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  op8 = (int32_t)(code[rel32_offset + 3] & 255);
  if (op8 == 52 || op8 == 53 || op8 == 84)
    return 19;
  if (op8 == 20 || op8 == 148)
    return 26;
  if (op8 == 99 || op8 == 103)
    return 13;
  if (op8 == 111)
    return 21;
  return 0;
}

/** 标签名相等比较（pool 固定 64 字节槽）。 */
static int32_t pipeline_elf_ctx_name_eq(const uint8_t *a, int32_t a_len, const uint8_t *b, int32_t b_len) {
  int32_t i;
  if (a_len != b_len)
    return 0;
  i = 0;
  while (i < a_len) {
    if (a[i] != b[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * 解析 ctx 内 cbz/b/rel32 补丁（与 append_patch 共用 PipelineElfCtxAccess 视图）。
 * AArch64 分支 PC 相对当前指令；x86 rel32 相对下一条。返回 0 成功，-1 未解析标签。
 */
int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  int32_t e_machine;
  int32_t p;
  if (!ctx_bytes)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  e_machine = *(int32_t *)(ctx_bytes + kPipelineElfCtxEMachineOff);
  p = 0;
  while (p < ctx->num_patches) {
    PipelineElfPatchEntry *patch;
    int32_t rel32_offset;
    int32_t target_offset;
    int32_t imm_bits;
    int32_t delta;
    int32_t l;
    int32_t patch_shndx;
    int32_t target_shndx;
    patch = &ctx->patches[p];
    rel32_offset = patch->rel32_offset;
    patch_shndx = pipeline_elf_patch_shndx_at(ctx_bytes, p);
    target_offset = -1;
    target_shndx = patch_shndx;
    l = 0;
    while (l < ctx->num_labels) {
      if (pipeline_elf_ctx_name_eq(patch->name, patch->name_len, ctx->labels[l].name, ctx->labels[l].name_len) != 0) {
        target_offset = ctx->labels[l].offset;
        target_shndx = pipeline_elf_label_shndx_at(ctx_bytes, l);
        break;
      }
      l = l + 1;
    }
    if (target_offset < 0) {
      driver_diagnostic_asm_elf_unresolved_patch(patch->name, patch->name_len);
      pipeline_elf_log_unresolved_patch((struct platform_elf_ElfCodegenCtx *)ctx_bytes, p);
      return -1;
    }
    /*
     * PGO 关闭时仅 .text（code_data）；sidecar shndx 偶发与 append 段不一致，但 rel32/label
     * offset 仍同在 code_data — 勿因此误杀 resolve（with_arena_vec / 多 if 烟测）。
     */
    if (patch_shndx != target_shndx) {
      if (!pipeline_elf_pgo_hot_enabled()) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT;
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= ctx->code_len && target_offset >= 0 &&
                 target_offset <= ctx->code_len) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT;
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= ctx->code_hot_len && target_offset >= 0 &&
                 target_offset <= ctx->code_hot_len) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
      } else {
        /* Class AW: Cap XLANG_ASM_DEBUG note retired. */
        driver_diagnostic_asm_elf_unresolved_patch(patch->name, patch->name_len);
        return -1;
      }
    }
    imm_bits = patch->patch_imm_bits;
    if (imm_bits == 0)
      imm_bits = pipeline_elf_ctx_infer_patch_imm_bits(ctx_bytes, patch_shndx, rel32_offset);
    /*
     * x86 rel32：相对下一条；AArch64 B/BL/CBZ/CBNZ：相对当前 PC（ARM ARM）。
     * 误用 next_insn 作 arm64 基准会把 imm 少 1 → cbz 跳自身（asm 编排 smoke SIGSEGV）。
     */
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26)
      delta = target_offset - rel32_offset;
    else
      delta = target_offset - (rel32_offset + 4);
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26) {
      int32_t insn;
      int32_t imm;
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      imm = delta / 4;
      if (imm_bits == 26)
        insn = (insn & (int32_t)4293918720) | (imm & 67108863);
      else if (imm_bits == 19)
        insn = (insn & (int32_t)4278190175) | ((imm & 524287) << 5);
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn);
    } else if (e_machine == 243 || imm_bits == 13 || imm_bits == 21) {
      int32_t insn;
      int32_t val;
      int32_t b_imm;
      int32_t j_imm;
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      val = delta >> 1;
      if (imm_bits == 13) {
        b_imm = val & 8191;
        insn = (insn & 2097183) | ((b_imm & 4096) << 19) | ((b_imm & 4032) << 20) | ((b_imm & 30) << 7) |
               ((b_imm & 2048) >> 4);
      } else if (imm_bits == 21) {
        j_imm = val & 2097151;
        insn = (insn & 4095) | ((j_imm & 524288) << 11) | ((j_imm & 1023) << 21) | ((j_imm & 1024) << 8) |
               ((j_imm & 522240) << 1);
      }
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn);
    } else {
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, delta);
    }
    p = p + 1;
  }
  return 0;
}

/** 追加一条外部重定位；ctx 为 *ElfCodegenCtx 转 *u8；超 TABLE_CAP 写入 heap sidecar。
 * wave701: WAVE273 writers overlay must keep-global this face plus
 * reloc_offset_at / name_len / copy64 / shndx_at / sidecar_reset (see
 * compiler/scripts/pabi_wave273_writers_keep.txt). Overlay-local `t`
 * copies of these helpers own a second g_pipeline_elf_reloc_heap; write_o
 * then emits heap relocs with empty names / r_offset=0, so FORCE mega
 * later functions (block_alloc) keep `call next_insn` and parse P001.
 * PLATFORM: LINUX ELF writer overlay; Mach-O typed reloc uses the same
 * helpers on Darwin overlay ingest. */
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len) {
  PipelineElfCtxAccess *ctx;
  int32_t ri;
  int32_t hi;
  int32_t n;
  PipelineElfRelocEntry *ent;
  PipelineElfRelocHeapEntry *hent;
  uint8_t *sym_row;
  if (!ctx_bytes || !name || name_len <= 0 || name[0] == 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_relocs >= PIPELINE_ELF_CTX_RELOC_TOTAL_CAP) {
    pabi_trace( "xlang: elf num_relocs limit %d reached\n", PIPELINE_ELF_CTX_RELOC_TOTAL_CAP);
    return -1;
  }
  ri = ctx->num_relocs;
  if (ri < PIPELINE_ELF_CTX_TABLE_CAP) {
    ent = &ctx->relocs[ri];
    sym_row = ctx->reloc_sym_names[ri].bytes;
    hent = NULL;
  } else {
    if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
      pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
    hi = ri - PIPELINE_ELF_CTX_TABLE_CAP;
    if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
      return -1;
    hent = &g_pipeline_elf_reloc_heap[hi];
    ent = NULL;
    sym_row = g_pipeline_elf_reloc_sym_heap[hi];
  }
  if (ent) {
    ent->offset = offset;
    ent->name_len = name_len;
  } else if (hent) {
    hent->offset = offset;
    hent->name_len = name_len;
  }
  pipeline_elf_reloc_shndx_set(ctx_bytes, ri, pipeline_elf_ctx_current_shndx(ctx));
  /* Cap 4.2.8: reloc_sym_names.bytes is u8[256]; clamp to full row ('_'+255 ok). */
  memset(sym_row, 0, 256);
  n = name_len > 255 ? 255 : name_len;
  if (n < 0)
    n = 0;
  if (n > 0)
    memcpy(sym_row, name, (size_t)n);
  if (ent)
    ent->name_len = n;
  else if (hent)
    hent->name_len = n;
  /* Default call-style reloc type (0 => writer uses reloc_type_r_pc32 / BRANCH26). */
  if (ri < PIPELINE_ELF_CTX_TABLE_CAP) {
    g_pipeline_elf_reloc_r_type[ri] = 0;
    g_pipeline_elf_reloc_r_pcrel[ri] = (int8_t)-1;
  }
  ctx->num_relocs = ctx->num_relocs + 1;
  return 0;
}

/**
 * PLATFORM: SHARED — append reloc with explicit Mach-O/ELF r_type and r_pcrel.
 * wave405: arm64 ADRP (PAGE21, pcrel=1) + ADD (PAGEOFF12, pcrel=0) for modlet COMMON.
 * @param r_type int32 — Mach-O ARM64_RELOC_* or ELF R_* ; 0 falls back to call default
 * @param r_pcrel int32 — 0 or 1; negative => default pcrel=1
 */
int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len,
                                            int32_t r_type, int32_t r_pcrel) {
  int32_t ri;
  if (pipeline_elf_ctx_append_reloc(ctx_bytes, offset, name, name_len) != 0)
    return -1;
  /* wave743: first typed row binds owner and prefills pcrel to 255 so untyped
   * call slots keep writer-default pcrel=1. Empty leftover C pcrel=0 after
   * owner bind made BRANCH26 r_pcrel=0 (Darwin ld rejects). PLATFORM: SHARED. */
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  g_pipeline_elf_reloc_sidecar_owner = ctx_bytes;
  {
    PipelineElfCtxAccess *ctx = (PipelineElfCtxAccess *)ctx_bytes;
    ri = ctx->num_relocs - 1;
  }
  if (ri >= 0 && ri < PIPELINE_ELF_CTX_TABLE_CAP) {
    g_pipeline_elf_reloc_r_type[ri] = r_type;
    if (r_pcrel < 0)
      g_pipeline_elf_reloc_r_pcrel[ri] = (int8_t)-1;
    else
      g_pipeline_elf_reloc_r_pcrel[ri] = (int8_t)(r_pcrel != 0 ? 1 : 0);
  }
  return 0;
}

#endif /* close wave273 FROM_X reopen after F7 for leftover-PE append_reloc_absolute64 */
#endif /* close wave178 FROM_X after F7 for leftover-PE append_reloc_absolute64 */
