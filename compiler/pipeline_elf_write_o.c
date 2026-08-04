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
 * 标准单 .text ELF64 ET_REL .o 写出（非 PGO）；从 glue code_data 偏移读机器码。
 * 替代 seed partial 内 write_elf_o_to_buf 对 X code_data[] 的错误偏移读（导致 __text 全零）。
 */
int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *code;
  int32_t code_len;
  int32_t strtab_off;
  int32_t num_undef;
  uint8_t undef_names[PIPELINE_ELF_UNDEF_SYM_CAP][128];
  int32_t undef_lens[PIPELINE_ELF_UNDEF_SYM_CAP];
  int32_t strtab_size;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t rela_size;
  int32_t align4;
  int32_t off_text;
  int32_t off_strtab;
  int32_t off_shstrtab;
  int32_t off_symtab;
  int32_t off_rela;
  int32_t off_shdr;
  static const uint8_t shstrtab_std[46] = {
      0, '.', 't', 'e', 'x', 't', 0, '.', 's', 'y', 'm', 't', 'a', 'b', 0,
      '.', 's', 't', 'r', 't', 'a', 'b', 0, '.', 's', 'h', 's', 't', 'r', 't', 'a', 'b', 0,
      '.', 'r', 'e', 'l', 'a', '.', 't', 'e', 'x', 't', 0};
  uint8_t ehdr[128];
  uint8_t z0[1];
  int32_t s;
  int32_t r0;
  int32_t r;
  int32_t e_machine;
  int32_t reloc_type;
  uint8_t *sym_pool;

  if (!ctx_bytes || !out)
    return -1;
  if (pipeline_elf_pgo_hot_enabled())
    return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  code = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  code_len = ctx->code_len;
  e_machine = ctx->e_machine;
  reloc_type = ctx->reloc_type_r_pc32;
  num_undef = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    uint8_t rname[128];
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
  rela_size = ctx->num_relocs * 24;
  align4 = (code_len + 3) & ~3;
  off_text = 64;
  off_strtab = off_text + align4;
  off_shstrtab = off_strtab + strtab_size;
  off_symtab = off_shstrtab + 46;
  off_rela = off_symtab + symtab_size;
  off_shdr = off_rela + rela_size;
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
  ehdr[60] = 6;
  ehdr[62] = 4;
  codegen_out_buf_set_len(out, 0);
  if (pipeline_elf_out_append(out, ehdr, 64) != 0)
    return -1;
  if (code_len > 0 && code && pipeline_elf_out_append(out, code, code_len) != 0)
    return -1;
  z0[0] = 0;
  s = code_len;
  while (s < align4) {
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
  if (pipeline_elf_out_append(out, shstrtab_std, 46) != 0)
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
        ent[4] = 18;
        ent[6] = 1;
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
  r = 0;
  while (r < ctx->num_relocs) {
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t r_sym_buf[128];
    int32_t rlen;
    uint8_t rela_buf[24];
    int32_t roff;
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
    r = r + 1;
  }
  {
    uint8_t shdr0[128];
    uint8_t shdr_text[128];
    uint8_t shdr_sym[128];
    uint8_t shdr_str[128];
    uint8_t shdr_shstr[128];
    uint8_t shdr_rela[128];
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
    memset(shdr_shstr, 0, sizeof(shdr_shstr));
    shdr_shstr[0] = 24;
    shdr_shstr[4] = 3;
    shdr_shstr[24] = (uint8_t)(off_shstrtab & 255);
    shdr_shstr[25] = (uint8_t)((off_shstrtab >> 8) & 255);
    shdr_shstr[26] = (uint8_t)((off_shstrtab >> 16) & 255);
    shdr_shstr[27] = (uint8_t)((off_shstrtab >> 24) & 255);
    shdr_shstr[32] = 46;
    shdr_shstr[48] = 1;
    if (pipeline_elf_out_append(out, shdr_shstr, 64) != 0)
      return -1;
    memset(shdr_rela, 0, sizeof(shdr_rela));
    shdr_rela[0] = 34;
    shdr_rela[4] = 4;
    shdr_rela[8] = 2;
    shdr_rela[16] = 64;
    shdr_rela[24] = (uint8_t)(off_rela & 255);
    shdr_rela[25] = (uint8_t)((off_rela >> 8) & 255);
    shdr_rela[26] = (uint8_t)((off_rela >> 16) & 255);
    shdr_rela[27] = (uint8_t)((off_rela >> 24) & 255);
    shdr_rela[32] = (uint8_t)(rela_size & 255);
    shdr_rela[33] = (uint8_t)((rela_size >> 8) & 255);
    shdr_rela[34] = (uint8_t)((rela_size >> 16) & 255);
    shdr_rela[35] = (uint8_t)((rela_size >> 24) & 255);
    shdr_rela[40] = 2;
    shdr_rela[44] = 1;
    shdr_rela[56] = 24;
    if (pipeline_elf_out_append(out, shdr_rela, 64) != 0)
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
  uint8_t lc_bv[24];
  uint8_t lc_sym[24];
  uint8_t nlist0[16];
  uint8_t z0[1];
  uint8_t uscore[1];
  int32_t pad;
  int32_t z;
  int32_t str_off;
  int32_t uu;
  int32_t r;
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
    uint8_t rname[128];
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
      uint8_t srname[128];
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

  /* nlist entries: NULL + defined + und */
  symtab_ents = ctx->num_syms + nu + 1;
  symtab_size = symtab_ents * 16;
  reloc_size = ctx->num_relocs * 8;
  lc_build_size = 24;
  sizeofcmds = 152 + lc_build_size + 24;
  off_text = 32 + sizeofcmds;
  off_sym = (off_text + code_len + 3) & (int32_t)0xFFFFFFFCu;
  off_str = off_sym + symtab_size;
  off_reloc = off_str + strtab_size;
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
  /* ncmds = 3: LC_SEGMENT_64 + LC_BUILD_VERSION + LC_SYMTAB */
  hdr[16] = 3;
  hdr[20] = (uint8_t)(sizeofcmds & 255);
  hdr[21] = (uint8_t)((sizeofcmds >> 8) & 255);
  hdr[22] = (uint8_t)((sizeofcmds >> 16) & 255);
  hdr[23] = (uint8_t)((sizeofcmds >> 24) & 255);
  if (pipeline_elf_out_append(out, hdr, 32) != 0)
    return -1;

  memset(seg, 0, sizeof(seg));
  /* LC_SEGMENT_64 cmd=0x19, cmdsize=152 */
  seg[0] = 25;
  seg[4] = 152;
  /* segname "__TEXT" */
  seg[8] = 95;
  seg[9] = 95;
  seg[10] = 84;
  seg[11] = 69;
  seg[12] = 88;
  seg[13] = 84;
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
  seg[128] = (uint8_t)(off_reloc & 255);
  seg[129] = (uint8_t)((off_reloc >> 8) & 255);
  seg[130] = (uint8_t)((off_reloc >> 16) & 255);
  seg[131] = (uint8_t)((off_reloc >> 24) & 255);
  seg[132] = (uint8_t)(ctx->num_relocs & 255);
  seg[133] = (uint8_t)((ctx->num_relocs >> 8) & 255);
  /* S_ATTR_SOME_INSTRUCTIONS | S_ATTR_PURE_INSTRUCTIONS */
  seg[136] = 0;
  seg[137] = 0;
  seg[138] = 4;
  seg[139] = 128;
  if (pipeline_elf_out_append(out, seg, 152) != 0)
    return -1;

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

  if (code_len > 0 && code && pipeline_elf_out_append(out, code, code_len) != 0)
    return -1;
  pad = off_sym - off_text - code_len;
  z0[0] = 0;
  z = 0;
  while (z < pad) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    z = z + 1;
  }

  /* nlist[0] = NULL symbol */
  memset(nlist0, 0, sizeof(nlist0));
  if (pipeline_elf_out_append(out, nlist0, 16) != 0)
    return -1;

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
    is_common = (g_pipeline_elf_common_owner == ctx_bytes && s < PIPELINE_ELF_CTX_TABLE_CAP &&
                 g_pipeline_elf_sym_is_common[s] != 0)
                    ? 1
                    : 0;
    if (is_common != 0) {
      csize = g_pipeline_elf_sym_common_size[s];
      if (csize <= 0)
        csize = 8;
      /* N_UNDF|N_EXT = 0x01; n_sect=NO_SECT; n_value=size (tentative/common). */
      ent[4] = 1;
      ent[5] = 0;
      ent[8] = (uint8_t)(csize & 255);
      ent[9] = (uint8_t)((csize >> 8) & 255);
      ent[10] = (uint8_t)((csize >> 16) & 255);
      ent[11] = (uint8_t)((csize >> 24) & 255);
    } else {
      /* N_SECT|N_EXT = 0x0f, n_sect = 1 */
      ent[4] = 15;
      ent[5] = 1;
      ent[8] = (uint8_t)(sym_va & 255);
      ent[9] = (uint8_t)((sym_va >> 8) & 255);
      ent[10] = (uint8_t)((sym_va >> 16) & 255);
      ent[11] = (uint8_t)((sym_va >> 24) & 255);
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
  r = 0;
  while (r < ctx->num_relocs) {
    uint8_t ri[8];
    int32_t sym_idx = 0;
    int32_t found_def = 0;
    int32_t m = 0;
    uint8_t r_sym_buf[128];
    int32_t rlen;
    int32_t r_sym;
    int32_t word2;
    int32_t roff;
    int32_t use_type;
    int32_t use_pcrel;
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
        uint8_t sr2_buf[128];
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
    if (r < PIPELINE_ELF_CTX_TABLE_CAP && g_pipeline_elf_reloc_r_type[r] != 0)
      use_type = g_pipeline_elf_reloc_r_type[r];
    if (r < PIPELINE_ELF_CTX_TABLE_CAP && g_pipeline_elf_reloc_r_pcrel[r] >= 0)
      use_pcrel = (int32_t)g_pipeline_elf_reloc_r_pcrel[r];
    /* r_symbolnum = sym_idx+1 (skip NULL nlist); r_pcrel; r_length; r_extern=1; r_type */
    r_sym = sym_idx + 1;
    word2 = (r_sym & 16777215) | ((use_pcrel & 1) << 24) | (rel_len << 25) | (1 << 27) | (use_type << 28);
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
    uint8_t rname[128];
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
    uint8_t r_sym_buf[128];
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
    uint8_t r_sym_buf[128];
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
    uint8_t r_sym_buf[128];
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

