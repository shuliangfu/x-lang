/* ============================================================================
 * pipeline_elf_ctx.c — ELF/Mach-O codegen ctx accessors + label/sym/patch/reloc
 *
 * wave1247 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   PipelineElfCtxAccess layout + PGO-Lite + reloc/label/patch/shndx/common sidecar
 *   ctx accessors (set_emit_hot/total_code_len/emit_code_len/append_bytes/code_data_ptr)
 *   label_mod_scope + add_label/ensure_label/pad_code/add_sym/add_common_sym
 *   append_patch/resolve_patches + reloc_sym_name + log_unresolved_patch
 *
 * Included from ast_pool.c (replaces former inline body). Writers
 * (pipeline_elf_write_o.c) included mid-file so writers share one layout
 * authority (G.7). Not a separate .o.
 *
 * PLATFORM: SHARED layout; ELF ctx primary on LINUX; Mach-O underscore on MACOS.
 * ============================================================================ */
/** ElfCodegenCtx 标签/补丁/重定位/符号表行数；与 platform/elf.x 内联数组维度一致（改须全链 rebuild）。
 * parser EMIT_HEAVY 真 emit 时 num_patches/labels 可上千；4096 与 elf.x 16384 漂移会导致 resolve_patches 失败。 */
#define PIPELINE_ELF_CTX_TABLE_CAP 16384
/** 堆 sidecar 扩 reloc 总上限（内联 16384 + heap 16384）。 */
#define PIPELINE_ELF_CTX_RELOC_TOTAL_CAP 32768
#define PIPELINE_ELF_CTX_RELOC_HEAP_CAP (PIPELINE_ELF_CTX_RELOC_TOTAL_CAP - PIPELINE_ELF_CTX_TABLE_CAP)

/**
 * platform/elf.x：ElfCodegenCtx 体量大，.x/asm 对 patches[pi].* / relocs[ri].* 字段写入 typeck 失败；
 * 布局须与 elf.x 中 ElfLabelEntry / ElfPatchEntry / ElfRelocEntry / ElfSymEntry 前缀一致（改 elf.x 时同步）。
 */
/** 与 elf.x ElfLabelEntry 布局一致（无 code_shndx；PGO 段索引见 sidecar）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t offset;
} PipelineElfLabelEntry;

/** 与 elf.x ElfPatchEntry 布局一致。 */
typedef struct {
  int32_t rel32_offset;
  uint8_t name[128];
  int32_t name_len;
  int32_t patch_imm_bits;
} PipelineElfPatchEntry;

/** 与 elf.x ElfRelocEntry 布局一致。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
} PipelineElfRelocEntry;

/** heap reloc sidecar 专用：内联 relocs[] 无 code_shndx 字段。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
  int32_t code_shndx;
} PipelineElfRelocHeapEntry;

typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t offset;
  /** 符号所属段：1=.text，2=.text.hot，3=.text.unlikely。 */
  int32_t sym_shndx;
} PipelineElfSymEntry;

typedef struct {
  uint8_t bytes[128];
} PipelineElfRelocSymName64;

/** code_data 之前的完整前缀；glue 用 offsetof 取 e_machine / code_data，避免手算偏移漂移。 */
typedef struct {
  int32_t code_len;
  PipelineElfLabelEntry labels[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_labels;
  PipelineElfPatchEntry patches[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_patches;
  PipelineElfRelocEntry relocs[PIPELINE_ELF_CTX_TABLE_CAP];
  PipelineElfRelocSymName64 reloc_sym_names[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_relocs;
  PipelineElfSymEntry syms[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_syms;
  int32_t sym_name_len;
  int32_t e_machine;
  int32_t reloc_type_r_pc32;
  int32_t current_frame_size;
  int32_t macho_leading_underscore;
  /** PGO-Lite：.text.hot 已写字节数；与 code_data 之后的 code_hot_data 对应。 */
  int32_t code_hot_len;
  /** 当前 emit 段：0=.text，非 0=.text.hot（须 XLANG_WPO_PGO_HOT=1）。 */
  int32_t emit_hot;
} PipelineElfCtxAccess;

/** code_data 容量；与 elf.x ElfCodegenCtx.code_data 维度一致（8716288，勿用旧 8388608）。 */
#define PIPELINE_ELF_CTX_CODE_BUF_CAP 8716288
/** .text.hot 缓冲（用户程序热段通常远小于 cold；减小 ctx 体积避免 malloc/栈压力）。 */
#define PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP 1048576

/** platform_elf_ElfCodegenCtx 后缀字段偏移（须与 elf.x / pipeline_gen 一致）。 */
enum {
  kPipelineElfCtxEMachineOff = (int)offsetof(PipelineElfCtxAccess, e_machine),
  kPipelineElfCtxMachoUnderscoreOff = (int)offsetof(PipelineElfCtxAccess, macho_leading_underscore),
  kPipelineElfCtxCodeDataOff = (int)sizeof(PipelineElfCtxAccess),
  kPipelineElfCtxCodeHotDataOff = (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP,
  kPipelineElfCtxSymNameDataOff =
      (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP + PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP
};

/** 与 elf.x ElfCodegenCtx 前缀一致；漂移会导致 append_bytes 写穿 malloc 区。 */
_Static_assert(sizeof(PipelineElfLabelEntry) == 136, "PipelineElfLabelEntry must match elf.x ElfLabelEntry (wave577 Cap: name[64]→[128])");
_Static_assert(sizeof(PipelineElfPatchEntry) == 140, "PipelineElfPatchEntry must match elf.x ElfPatchEntry (wave577 Cap: name[64]→[128])");
_Static_assert(sizeof(PipelineElfRelocEntry) == 8, "PipelineElfRelocEntry must match elf.x ElfRelocEntry");
_Static_assert(sizeof(PipelineElfSymEntry) == 140, "PipelineElfSymEntry must match elf.x ElfSymEntry (wave577 Cap: name[64]→[128])");
_Static_assert(kPipelineElfCtxCodeDataOff == (int)sizeof(PipelineElfCtxAccess),
               "PipelineElfCtxAccess prefix size drift vs elf.x");

/** XLANG_WPO_PGO_HOT=1 时启用 .text.hot 双段 emit。 */
int32_t pipeline_elf_pgo_hot_enabled(void) {
  const char *e = link_abi_getenv("XLANG_WPO_PGO_HOT");
  if (!e || e[0] == '\0')
    return 0;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 设置当前函数 emit 目标段（backend 每函数 emit 前调用）。 */
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  ctx->emit_hot = hot != 0 ? 1 : 0;
}

/** .text + .text.hot 已编码字节总和（空 __text 拒绝用）。 */
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->code_len + ctx->code_hot_len;
}

/** 当前 emit 段已写字节数（x86 call patch 的 rel32_at 须相对本段 code_len）。 */
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
    return ctx->code_hot_len;
  return ctx->code_len;
}

/** PGO-Lite ELF 段索引（与 write_elf_o_pgo 中 shdr 顺序一致）。 */
enum {
  PIPELINE_ELF_SHNX_TEXT = 1,
  PIPELINE_ELF_SHNX_TEXT_HOT = 2,
  PIPELINE_ELF_SHNX_TEXT_UNLIKELY = 3
};

/** 当前 emit 的 ELF 段索引：hot→2，PGO 冷路径→3，否则→1。 */
static int32_t pipeline_elf_ctx_current_shndx(PipelineElfCtxAccess *ctx) {
  if (!ctx)
    return PIPELINE_ELF_SHNX_TEXT;
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
static uint8_t g_pipeline_elf_reloc_sym_heap[PIPELINE_ELF_CTX_RELOC_HEAP_CAP][128];

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
 */
static int32_t g_pipeline_elf_reloc_r_type[PIPELINE_ELF_CTX_TABLE_CAP];
static int8_t g_pipeline_elf_reloc_r_pcrel[PIPELINE_ELF_CTX_TABLE_CAP];

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
#include "pipeline_elf_write_o.c"

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
  if (ctx->num_labels >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  li = ctx->num_labels;
  /* wave577 Cap / wave580: labels.name is u8[128]; store up to 128 (was silent 64 clamp). */
  n = name_len > 128 ? 128 : name_len;
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
  /* wave580 Cap residual: sym name pool holds link names up to 128
   * ('_' + 127 AST content on Darwin). Was 64. */
  if (copy_len > 128)
    copy_len = 128;
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
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
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
  if (ctx->num_patches >= PIPELINE_ELF_CTX_TABLE_CAP) {
    fprintf(stderr, "xlang: elf num_patches limit %d reached\n", PIPELINE_ELF_CTX_TABLE_CAP);
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
  /* wave580 Cap: patches.name is u8[128]; store clamped length matching copied bytes. */
  n = name_len > 128 ? 128 : name_len;
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
        if (link_abi_getenv("XLANG_ASM_DEBUG")) {
          fprintf(stderr,
                  "xlang: elf patch shndx mismatch p=%d patch_sh=%d target_sh=%d rel=%d tgt=%d code_len=%d hot=%d\n",
                  (int)p, (int)patch_shndx, (int)target_shndx, (int)rel32_offset, (int)target_offset,
                  (int)ctx->code_len, (int)ctx->code_hot_len);
        }
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

/** 追加一条外部重定位；ctx 为 *ElfCodegenCtx 转 *u8；超 TABLE_CAP 写入 heap sidecar。 */
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
    fprintf(stderr, "xlang: elf num_relocs limit %d reached\n", PIPELINE_ELF_CTX_RELOC_TOTAL_CAP);
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
  /* wave580 Cap: reloc_sym_names.bytes is u8[128]; clamp to full row ('_'+127 ok). */
  memset(sym_row, 0, 128);
  n = name_len > 128 ? 128 : name_len;
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

/** 返回 reloc_sym_names[idx] 首地址；越界返回 NULL（含 heap sidecar）。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return NULL;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return NULL;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->reloc_sym_names[idx].bytes;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return NULL;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return NULL;
  return g_pipeline_elf_reloc_sym_heap[hi];
}

/** Copy reloc_sym_names[idx] into dst (u8[128] content cap 127 + trailing zero region).
 * Name kept as *copy64 for ABI stability; wave580 Cap raised payload 64→128.
 * PLATFORM: SHARED — heap sidecar + inline reloc rows.
 */
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  PipelineElfCtxAccess *ctx;
  int32_t k;
  uint8_t *src;
  if (!dst)
    return;
  memset(dst, 0, 128);
  src = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
  if (!src)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (!ctx || idx < 0 || idx >= ctx->num_relocs)
    return;
  for (k = 0; k < 128; k++)
    dst[k] = src[k];
}

/** 读 relocs[idx].name_len（内联或 heap sidecar）。 */
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return 0;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->relocs[idx].name_len;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return 0;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return 0;
  return g_pipeline_elf_reloc_heap[hi].name_len;
}

/* wave1240 dead code delete: pipeline_elf_ctx_diag_stderr removed — defined here
 * but had zero callers across .c/.x/.h (was an asm .o failure diagnostic helper
 * printing ElfCodegenCtx counts). Superseded by pipeline_elf_log_unresolved_patch
 * below, which handles unresolved-patch diagnostics via the same PipelineElfCtxAccess
 * layout. PLATFORM: SHARED. */

void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx) {
  PipelineElfCtxAccess *acc;
  PipelineElfPatchEntry *p;
  int32_t l;
  int32_t hits;
  if (!ctx || patch_idx < 0)
    return;
  acc = (PipelineElfCtxAccess *)(uint8_t *)ctx;
  if (patch_idx >= acc->num_patches)
    return;
  p = &acc->patches[patch_idx];
  hits = 0;
  l = 0;
  while (l < acc->num_labels) {
    int32_t same = (acc->labels[l].name_len == p->name_len);
    if (same && p->name_len > 0)
      same = (memcmp(acc->labels[l].name, p->name, (size_t)p->name_len) == 0);
    if (same)
      hits = hits + 1;
    l = l + 1;
  }
  diag_reportf(NULL, 0, 0, "note", NULL,
               "elf unresolved patch_idx=%d label_hits=%d num_labels=%d",
               (int)patch_idx, (int)hits, (int)acc->num_labels);
}
