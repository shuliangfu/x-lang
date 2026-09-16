/*
 * Darwin ingest vehicle for pipeline_macho_write_o_to_buf_c.
 * G.7: body matches runtime_pipeline_abi.x / from_x.c writer
 * (clang MH_OBJECT: empty LC_SEGMENT_64.segname, no dummy nlist,
 * LC_DYSYMTAB, __text flags 0x80000400). Data goes through product
 * accessors so F7 .data stays on leftover BSS.
 * COMMON flags/size/align go through pipeline_elf_ctx_sym_*_at —
 * private common sidecars here were always empty while product
 * add_common_sym wrote g_pipe_elf_* (file-level let → N_SECT __TEXT).
 * Reloc r_type/r_pcrel likewise via pipeline_elf_ctx_reloc_r_*_at —
 * private reloc statics stayed empty → ADRP emitted as BRANCH26.
 * ensure injects via pipeline_abi_inject_macho_write_thin (weaken
 * leftover T then first-wins ld -r; avoids Darwin mega -E).
 * PLATFORM: MACOS|DARWIN ingest · LINUX gold co-path (ELF unused).
 */

#include <stdint.h>
#include <string.h>
#include <stddef.h>

struct codegen_CodegenOutBuf;
extern int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out);
extern void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n);
extern int32_t pipe_elf_out_append(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n);
#define pipeline_elf_out_append pipe_elf_out_append
extern int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes);
extern uint8_t *pipeline_elf_ctx_code_data_ptr(uint8_t *ctx_bytes);
extern void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx, int32_t idx);
extern uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx, int32_t idx);
extern int32_t pipeline_elf_ctx_emit_data_len(uint8_t *ctx_bytes);
extern uint8_t *pipeline_elf_ctx_data_data_ptr(uint8_t *ctx_bytes);
extern int32_t pipeline_elf_ctx_sym_is_common_at(uint8_t *ctx_bytes, int32_t s);
extern int32_t pipeline_elf_ctx_sym_common_size_at(uint8_t *ctx_bytes, int32_t s);
extern int32_t pipeline_elf_ctx_sym_common_align_at(uint8_t *ctx_bytes, int32_t s);
extern int32_t pipeline_elf_ctx_reloc_r_type_at(uint8_t *ctx_bytes, int32_t r);
extern int32_t pipeline_elf_ctx_reloc_r_pcrel_at(uint8_t *ctx_bytes, int32_t r);
extern void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
extern void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);

#define PIPELINE_ELF_CTX_TABLE_CAP 16384
#define PIPELINE_ELF_CTX_CODE_BUF_CAP 8716288
#define PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP 1048576
#define PIPELINE_ELF_SHNX_DATA 4
#define PIPELINE_MACHO_UNDEF_SYM_CAP 256

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
  data_len = pipeline_elf_ctx_emit_data_len(ctx_bytes);
  if (data_len < 0)
    data_len = 0;
  data_buf = pipeline_elf_ctx_data_data_ptr(ctx_bytes);
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
    /* wave405: COMMON → N_UNDF|N_EXT + n_value=size (linker BSS). Never N_SECT in __text (RX SEGV).
     * G.7: read product g_pipe_elf_* via accessors (not this TU's empty statics). */
    is_common = pipeline_elf_ctx_sym_is_common_at(ctx_bytes, s);
    if (is_common != 0) {
      int32_t calign;
      int32_t alg;
      int32_t ndesc;
      csize = pipeline_elf_ctx_sym_common_size_at(ctx_bytes, s);
      calign = pipeline_elf_ctx_sym_common_align_at(ctx_bytes, s);
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
      {
        /* Product append_reloc_typed writes g_pipe_elf_*; never private statics. */
        int32_t rt = pipeline_elf_ctx_reloc_r_type_at(ctx_bytes, r);
        int32_t rp = pipeline_elf_ctx_reloc_r_pcrel_at(ctx_bytes, r);
        if (rt != 0)
          use_type = rt;
        if (rp >= 0)
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
