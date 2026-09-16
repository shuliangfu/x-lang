/*
 * Thin pure: wave273 ELF/Mach-O ctx + write_o Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave273 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local ELF sidecars
 * (reloc/shndx/common/F7 data). Excludes pipeline_macho_write_o_to_buf_c
 * (owned by runtime_pipeline_abi_macho_write_thin.c).
 *
 * Faces: pipeline_elf_pgo_* / pipeline_elf_ctx_* / pipeline_elf_label_* /
 *   pipeline_elf_log_* / pipeline_elf_write_o_* (+ absolute64).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding ELF/Mach-O Cap leave.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

struct codegen_CodegenOutBuf;

/* Forward decls: faces defined later in this TU (write_o before reloc_sym). */
struct platform_elf_ElfCodegenCtx;
int32_t pipeline_elf_pgo_hot_enabled(void);
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot);
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes);
void pipeline_elf_ctx_reset_data(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_emit_data_len(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_data_u32_le(uint8_t *ctx_bytes, uint32_t word);
int32_t pipeline_elf_ctx_append_data_zeros(uint8_t *ctx_bytes, int32_t n);
int32_t pipeline_elf_ctx_data_poke_u8(uint8_t *ctx_bytes, int32_t off, int32_t b);
void pipeline_elf_ctx_set_shndx_override(uint8_t *ctx_bytes, int32_t shndx);
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx);
int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);
void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset);
void pipeline_elf_label_mod_scope_reset(void);
int32_t pipeline_elf_label_mod_scope_next_module(void);
void pipeline_elf_label_mod_scope_begin_module(void);
int32_t pipeline_elf_label_mod_scope_active(void);
int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset);
int32_t pipeline_elf_ctx_add_common_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t size,
                                        int32_t align);
int32_t pipeline_elf_ctx_sym_is_common_at(uint8_t *ctx_bytes, int32_t s);
int32_t pipeline_elf_ctx_sym_common_size_at(uint8_t *ctx_bytes, int32_t s);
int32_t pipeline_elf_ctx_sym_common_align_at(uint8_t *ctx_bytes, int32_t s);
int32_t pipeline_elf_ctx_reloc_r_type_at(uint8_t *ctx_bytes, int32_t r);
int32_t pipeline_elf_ctx_reloc_r_pcrel_at(uint8_t *ctx_bytes, int32_t r);
int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                      int32_t imm_bits);
int32_t pipeline_elf_ctx_patch_imm_bits_at(uint8_t *ctx_bytes, int32_t patch_idx);
int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes);
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len,
                                            int32_t r_type, int32_t r_pcrel);
int32_t pipeline_elf_ctx_append_reloc_absolute64(uint8_t *ctx_bytes, int32_t offset,
                                                 uint8_t *name, int32_t name_len);
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst);
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx);
void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx);
extern int32_t pipeline_macho_write_o_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out);

/** Thin-local trace sink (seed pabi_trace uses xlang_vfdprintf; no-op here). */
static void pabi_trace(const char *fmt, ...) {
  (void)fmt;
}

/* driver diagnostics live in pipeline_glue / product host */
extern void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
extern void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
extern void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, ...);
extern char *link_abi_getenv(const char *name);
extern int32_t codegen_out_buf_len(void *out);
extern void codegen_out_buf_set_len(void *out, int32_t n);

#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif

/* CodegenOutBuf is opaque to residual; writers cast via void* helpers above. */
struct codegen_CodegenOutBuf;

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
  uint8_t name[256];
  int32_t name_len;
  int32_t offset;
} PipelineElfLabelEntry;

/** 与 elf.x ElfPatchEntry 布局一致。 */
typedef struct {
  int32_t rel32_offset;
  uint8_t name[256];
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
  uint8_t name[256];
  int32_t name_len;
  int32_t offset;
  /** 符号所属段：1=.text，2=.text.hot，3=.text.unlikely。 */
  int32_t sym_shndx;
} PipelineElfSymEntry;

typedef struct {
  uint8_t bytes[256];
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
_Static_assert(sizeof(PipelineElfLabelEntry) == 264, "PipelineElfLabelEntry must match elf.x ElfLabelEntry (Cap 4.2.8: name[128]→[256])");
_Static_assert(sizeof(PipelineElfPatchEntry) == 268, "PipelineElfPatchEntry must match elf.x ElfPatchEntry (wave577 Cap: name[64]→[128])");
_Static_assert(sizeof(PipelineElfRelocEntry) == 8, "PipelineElfRelocEntry must match elf.x ElfRelocEntry");
_Static_assert(sizeof(PipelineElfSymEntry) == 268, "PipelineElfSymEntry must match elf.x ElfSymEntry (wave577 Cap: name[64]→[128])");
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


/* F7: data section buffer for vtable static data (read-only data with absolute
 * pointer relocations; cannot live in __TEXT,__text which is pure_instructions).
 * Single-threaded compile; reset per-module via pipeline_elf_ctx_reset_data. */
static uint8_t g_pipeline_elf_data_buf[65536];
static int32_t g_pipeline_elf_data_len;
static uint8_t *g_pipeline_elf_data_owner;
/* F7: shndx override (0 = no override; 4 = data section). When non-zero,
 * pipeline_elf_ctx_current_shndx returns this value, so new relocs/syms/labels
 * are tagged as data-section. Single-threaded compile; safe as a global mutable. */
static int32_t g_pipeline_elf_shndx_override;

/**
 * F7: Reset the data section buffer at module start.
 * Must be called once per module BEFORE emitting any vtable statics.
 * PLATFORM: SHARED freestanding ELF leave.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
void pipeline_elf_ctx_reset_data(uint8_t *ctx_bytes) {
  g_pipeline_elf_data_len = 0;
  g_pipeline_elf_data_owner = ctx_bytes;
}

/**
 * F7: Current data section length (bytes already emitted to data buf).
 * PLATFORM: SHARED freestanding ELF leave.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
int32_t pipeline_elf_ctx_emit_data_len(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return 0;
  return g_pipeline_elf_data_len;
}

/**
 * F7: Pointer to data section buffer start.
 * PLATFORM: SHARED freestanding ELF leave.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
uint8_t *pipeline_elf_ctx_data_data_ptr(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return 0;
  return &g_pipeline_elf_data_buf[0];
}

/**
 * F7: Append 4 bytes (little-endian u32) to the data section buffer.
 * Returns 0 ok, -1 overflow/null.
 * PLATFORM: SHARED freestanding ELF leave.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
int32_t pipeline_elf_ctx_append_data_u32_le(uint8_t *ctx_bytes, uint32_t word) {
  int32_t off;
  if (!ctx_bytes)
    return -1;
  if (g_pipeline_elf_data_len < 0)
    g_pipeline_elf_data_len = 0;
  if (g_pipeline_elf_data_len + 4 > 65536)
    return -1;
  off = g_pipeline_elf_data_len;
  g_pipeline_elf_data_buf[off] = (uint8_t)(word & 255);
  g_pipeline_elf_data_buf[off + 1] = (uint8_t)((word >> 8) & 255);
  g_pipeline_elf_data_buf[off + 2] = (uint8_t)((word >> 16) & 255);
  g_pipeline_elf_data_buf[off + 3] = (uint8_t)((word >> 24) & 255);
  g_pipeline_elf_data_len = off + 4;
  return 0;
}

/**
 * F7: Append `n` zero bytes to the data section buffer (reserve + clear).
 * Twin of runtime_pipeline_abi.x pipeline_elf_ctx_append_data_zeros.
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
int32_t pipeline_elf_ctx_append_data_zeros(uint8_t *ctx_bytes, int32_t n) {
  int32_t off;
  if (!ctx_bytes)
    return -1;
  if (n <= 0)
    return 0;
  if (g_pipeline_elf_data_len < 0)
    g_pipeline_elf_data_len = 0;
  if (g_pipeline_elf_data_len + n > 65536)
    return -1;
  off = g_pipeline_elf_data_len;
  memset(&g_pipeline_elf_data_buf[off], 0, (size_t)n);
  g_pipeline_elf_data_len = off + n;
  return 0;
}

/**
 * F7: Poke one byte into an already-reserved data-section offset.
 * Twin of runtime_pipeline_abi.x pipeline_elf_ctx_data_poke_u8.
 * PLATFORM: SHARED freestanding · ELF .data + Mach-O __DATA,__const.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
int32_t pipeline_elf_ctx_data_poke_u8(uint8_t *ctx_bytes, int32_t off, int32_t b) {
  if (!ctx_bytes || off < 0 || off >= g_pipeline_elf_data_len)
    return -1;
  g_pipeline_elf_data_buf[off] = (uint8_t)(b & 255);
  return 0;
}

/**
 * F7: Set/clear shndx override. When set to 4 (data section), subsequent
 * relocs/syms/labels are tagged as data-section. Set to 0 to restore default.
 * PLATFORM: SHARED freestanding ELF leave.
 * PLATFORM: WINDOWS leftover-PE compiles this twin in FROM_X rest.
 */
void pipeline_elf_ctx_set_shndx_override(uint8_t *ctx_bytes, int32_t shndx) {
  (void)ctx_bytes;
  g_pipeline_elf_shndx_override = shndx;
}


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
 */
static int32_t g_pipeline_elf_reloc_r_type[PIPELINE_ELF_CTX_TABLE_CAP];
static int8_t g_pipeline_elf_reloc_r_pcrel[PIPELINE_ELF_CTX_TABLE_CAP];

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

#define PIPELINE_ELF_UNDEF_SYM_CAP 256

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
  uint8_t undef_names[PIPELINE_ELF_UNDEF_SYM_CAP][128];
  int32_t undef_lens[PIPELINE_ELF_UNDEF_SYM_CAP];
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
        if (rlen > 0)
          memcpy(undef_names[num_undef], rname, (size_t)rlen);
        undef_lens[num_undef] = rlen;
        num_undef = num_undef + 1;
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
      is_common = (g_pipeline_elf_common_owner == ctx_bytes && s < PIPELINE_ELF_CTX_TABLE_CAP &&
                   g_pipeline_elf_sym_is_common[s] != 0)
                      ? 1
                      : 0;
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      if (is_common != 0) {
        /* STB_GLOBAL|STT_OBJECT=17; SHN_COMMON=0xfff2; st_value=align, st_size=size */
        csize = g_pipeline_elf_sym_common_size[s];
        calign = g_pipeline_elf_sym_common_align[s];
        if (calign <= 0)
          calign = 8;
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
/* stripped: int32_t pipeline_macho_write_o_to_buf_c — see macho_write_thin */


/**
 * Product surface: Darwin user_asm_seed_bridge weak_import target.
 * Strong body overrides seeds/asm_experimental_symbol_bridge weak -1 stub.
 * PLATFORM: MACOS pure-asm (also linked on Linux; unused there).
 */
/* stripped: int32_t platform_macho_write_macho_o_to_buf — see macho_write_thin */


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
      is_common = (g_pipeline_elf_common_owner == ctx_bytes && s < PIPELINE_ELF_CTX_TABLE_CAP &&
                   g_pipeline_elf_sym_is_common[s] != 0)
                      ? 1
                      : 0;
      shndx = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      if (is_common != 0) {
        csize = g_pipeline_elf_sym_common_size[s];
        calign = g_pipeline_elf_sym_common_align[s];
        if (calign <= 0)
          calign = 8;
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
  if (ctx->num_labels >= PIPELINE_ELF_CTX_TABLE_CAP)
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

/** COMMON size for writer. PLATFORM: SHARED. */
int32_t pipeline_elf_ctx_sym_common_size_at(uint8_t *ctx_bytes, int32_t s) {
  if (pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s) == 0)
    return 0;
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
  if (ctx->num_patches >= PIPELINE_ELF_CTX_TABLE_CAP) {
    pabi_trace( "xlang: elf num_patches limit %d reached\n", PIPELINE_ELF_CTX_TABLE_CAP);
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
        if (link_abi_getenv("XLANG_ASM_DEBUG")) {
          pabi_trace(
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


int32_t pipeline_elf_ctx_append_reloc_absolute64(uint8_t *ctx_bytes, int32_t offset,
                                                 uint8_t *name, int32_t name_len) {
  return pipeline_elf_ctx_append_reloc_typed(ctx_bytes, offset, name, name_len, 200, 0);
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

/** Copy reloc_sym_names[idx] into dst (u8[128] content cap 255 + trailing zero region).
 * Name kept as *copy64 for ABI stability; wave580 Cap raised payload 64→128.
 * PLATFORM: SHARED — heap sidecar + inline reloc rows.
 */
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  PipelineElfCtxAccess *ctx;
  int32_t k;
  uint8_t *src;
  if (!dst)
    return;
  memset(dst, 0, 256);
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


