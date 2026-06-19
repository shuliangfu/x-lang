/**
 * std/elf/elf.c — ELF64 头与 section 头只读解析（STD-058）
 *
 * 【文件职责】
 * elf64_parse_hdr_c、elf64_read_shdr_c、elf64_sec_name_c、elf64_read_phdr_c、
 * elf64_read_sym_c、elf64_read_rela_c（STD-103）；工具链烟测金样。
 * 【所属模块】标准库 std.elf；与 std/elf/mod.sx 同属一模块。无外部依赖。
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

/** 与 mod.sx ELF_* 常量一致。 */
enum {
  ELF_OK = 0,
  ELF_ERR_NULL = -1,
  ELF_ERR_SHORT = -2,
  ELF_ERR_MAGIC = -3,
  ELF_ERR_CLASS = -4,
  ELF_ERR_ENDIAN = -5,
  ELF_ERR_INDEX = -6,
  ELF_ERR_NOT_FOUND = -7,
};

#define ELFMAG0 0x7f
#define ELFMAG1 'E'
#define ELFMAG2 'L'
#define ELFMAG3 'F'
#define ELFCLASS64 2
#define ELFDATA2LSB 1

/** 输出：与 .sx Elf64Hdr 字段顺序一致。 */
typedef struct {
  int32_t e_type;
  int32_t machine;
  uint64_t entry;
  uint64_t phoff;
  int32_t phnum;
  int32_t shnum;
  uint64_t shoff;
  int32_t shstrndx;
} elf64_hdr_out_t;

/** 输出：与 .sx Elf64Phdr 一致。 */
typedef struct {
  int32_t p_type;
  int32_t p_flags;
  uint64_t offset;
  uint64_t vaddr;
  uint64_t filesz;
  uint64_t memsz;
} elf64_phdr_out_t;

/** 输出：与 .sx Elf64Sec 一致。 */
typedef struct {
  int32_t name_off;
  int32_t sh_type;
  uint64_t addr;
  uint64_t offset;
  uint64_t size;
} elf64_sec_out_t;

/** 输出：与 .sx Elf64Sym 一致。 */
typedef struct {
  int32_t name_off;
  int32_t bind;
  int32_t sym_type;
  int32_t shndx;
  uint64_t value;
  uint64_t size;
} elf64_sym_out_t;

/** 输出：与 .sx Elf64Rela 一致。 */
typedef struct {
  uint64_t offset;
  int32_t sym_idx;
  int32_t reloc_type;
  int64_t addend;
} elf64_rela_out_t;

static int32_t elf64_check_ident(const uint8_t *p, int32_t len) {
  if (!p || len < 64) return ELF_ERR_SHORT;
  if (p[0] != ELFMAG0 || p[1] != ELFMAG1 || p[2] != ELFMAG2 || p[3] != ELFMAG3)
    return ELF_ERR_MAGIC;
  if (p[4] != ELFCLASS64) return ELF_ERR_CLASS;
  if (p[5] != ELFDATA2LSB) return ELF_ERR_ENDIAN;
  return ELF_OK;
}

static uint16_t u16le(const uint8_t *p) {
  return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t u32le(const uint8_t *p) {
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
         ((uint32_t)p[3] << 24);
}

static uint64_t u64le(const uint8_t *p) {
  uint64_t lo = u32le(p);
  uint64_t hi = u32le(p + 4);
  return lo | (hi << 32);
}

/** 解析 ELF64 文件头；out 为 elf64_hdr_out_t*。 */
int32_t elf64_parse_hdr_c(const uint8_t *ptr, int32_t len, void *out) {
  elf64_hdr_out_t *hdr;
  int32_t rc;
  const uint8_t *eh;
  if (!out) return ELF_ERR_NULL;
  hdr = (elf64_hdr_out_t *)out;
  memset(hdr, 0, sizeof(*hdr));
  rc = elf64_check_ident(ptr, len);
  if (rc != ELF_OK) return rc;
  eh = ptr;
  hdr->e_type = (int32_t)u16le(eh + 16);
  hdr->machine = (int32_t)u16le(eh + 18);
  hdr->entry = u64le(eh + 24);
  hdr->phoff = u64le(eh + 32);
  hdr->phnum = (int32_t)u16le(eh + 56);
  hdr->shnum = (int32_t)u16le(eh + 60);
  hdr->shoff = u64le(eh + 40);
  hdr->shstrndx = (int32_t)u16le(eh + 62);
  return ELF_OK;
}

/** 读取第 idx 个 program 头（0..phnum-1）；phentsize 固定 56。 */
int32_t elf64_read_phdr_c(const uint8_t *ptr, int32_t len, uint64_t phoff, int32_t phnum, int32_t idx,
                          void *out) {
  elf64_phdr_out_t *ph;
  uint64_t off;
  const uint8_t *phb;
  if (!ptr || !out) return ELF_ERR_NULL;
  if (idx < 0 || idx >= phnum) return ELF_ERR_INDEX;
  off = phoff + (uint64_t)idx * 56u;
  if ((int64_t)len < 0 || (uint64_t)len < off + 56u) return ELF_ERR_SHORT;
  ph = (elf64_phdr_out_t *)out;
  memset(ph, 0, sizeof(*ph));
  phb = ptr + off;
  ph->p_type = (int32_t)u32le(phb + 0);
  ph->p_flags = (int32_t)u32le(phb + 4);
  ph->offset = u64le(phb + 8);
  ph->vaddr = u64le(phb + 16);
  ph->filesz = u64le(phb + 32);
  ph->memsz = u64le(phb + 40);
  return ELF_OK;
}

/** 读取第 idx 个 section 头（0..shnum-1）。 */
int32_t elf64_read_shdr_c(const uint8_t *ptr, int32_t len, uint64_t shoff, int32_t shnum,
                          int32_t idx, void *out) {
  elf64_sec_out_t *sec;
  uint64_t off;
  const uint8_t *sh;
  if (!ptr || !out) return ELF_ERR_NULL;
  if (idx < 0 || idx >= shnum) return ELF_ERR_INDEX;
  off = shoff + (uint64_t)idx * 64u;
  if ((int64_t)len < 0 || (uint64_t)len < off + 64u) return ELF_ERR_SHORT;
  sec = (elf64_sec_out_t *)out;
  memset(sec, 0, sizeof(*sec));
  sh = ptr + off;
  sec->name_off = (int32_t)u32le(sh + 0);
  sec->sh_type = (int32_t)u32le(sh + 4);
  sec->addr = u64le(sh + 16);
  sec->offset = u64le(sh + 24);
  sec->size = u64le(sh + 32);
  return ELF_OK;
}

/** 从 shstrtab 取出节名到 buf（NUL 结尾）；返回写入长度或错误码。 */
int32_t elf64_sec_name_c(const uint8_t *ptr, int32_t len, uint64_t str_off, uint64_t str_size,
                         int32_t name_off, uint8_t *buf, int32_t buf_len) {
  uint64_t pos;
  int32_t i;
  if (!ptr || !buf || buf_len <= 0) return ELF_ERR_NULL;
  pos = str_off + (uint64_t)name_off;
  if (pos >= str_off + str_size || (uint64_t)len <= pos) return ELF_ERR_SHORT;
  for (i = 0; i < buf_len - 1; i++) {
    uint8_t c = ptr[pos + (uint64_t)i];
    buf[i] = c;
    if (c == 0) return i;
  }
  buf[buf_len - 1] = 0;
  return ELF_ERR_SHORT;
}

/** 比较 shstrtab 中 name_off 处节名与 want（NUL 结尾 C 串）。 */
static int32_t elf64_name_eq_c(const uint8_t *ptr, int32_t len, uint64_t str_off, uint64_t str_size,
                               int32_t name_off, const char *want) {
  uint8_t buf[32];
  int32_t rc;
  int32_t i;
  if (!want) return 0;
  rc = elf64_sec_name_c(ptr, len, str_off, str_size, name_off, buf, (int32_t)sizeof(buf));
  if (rc < 0) return 0;
  for (i = 0; want[i] != 0; i++) {
    if (buf[i] != (uint8_t)want[i]) return 0;
  }
  return buf[i] == 0 ? 1 : 0;
}

/** 按节名查找索引；out_idx 为 *i32。未找到返回 ELF_ERR_NOT_FOUND。 */
int32_t elf64_find_section_c(const uint8_t *ptr, int32_t len, uint64_t shoff, int32_t shnum,
                              int32_t shstrndx, const char *want, void *out_idx) {
  elf64_sec_out_t shstr;
  elf64_sec_out_t sec;
  int32_t *idx_out;
  int32_t idx;
  int32_t rc;
  if (!ptr || !want || !out_idx) return ELF_ERR_NULL;
  idx_out = (int32_t *)out_idx;
  *idx_out = -1;
  rc = elf64_read_shdr_c(ptr, len, shoff, shnum, shstrndx, &shstr);
  if (rc != ELF_OK) return rc;
  for (idx = 0; idx < shnum; idx++) {
    rc = elf64_read_shdr_c(ptr, len, shoff, shnum, idx, &sec);
    if (rc != ELF_OK) continue;
    if (elf64_name_eq_c(ptr, len, shstr.offset, shstr.size, sec.name_off, want)) {
      *idx_out = idx;
      return ELF_OK;
    }
  }
  return ELF_ERR_NOT_FOUND;
}

/** 读取节体内偏移 at 处的单字节；out 为 *u8。 */
int32_t elf64_read_sec_byte_c(const uint8_t *ptr, int32_t len, uint64_t sec_off, uint64_t sec_size,
                               uint64_t at, void *out) {
  uint64_t pos;
  uint8_t *byte_out;
  if (!ptr || !out) return ELF_ERR_NULL;
  if (at >= sec_size) return ELF_ERR_INDEX;
  pos = sec_off + at;
  if ((int64_t)len < 0 || (uint64_t)len <= pos) return ELF_ERR_SHORT;
  byte_out = (uint8_t *)out;
  *byte_out = ptr[pos];
  return ELF_OK;
}

/** 读取 symtab 内第 idx 个 Elf64_Sym（24 字节）；out 为 elf64_sym_out_t*。 */
int32_t elf64_read_sym_c(const uint8_t *ptr, int32_t len, uint64_t sym_off, uint64_t sym_size,
                         int32_t idx, void *out) {
  elf64_sym_out_t *sym;
  uint64_t off;
  const uint8_t *sb;
  uint8_t st_info;
  if (!ptr || !out) return ELF_ERR_NULL;
  if (idx < 0 || (uint64_t)idx * 24u + 24u > sym_size) return ELF_ERR_INDEX;
  off = sym_off + (uint64_t)idx * 24u;
  if ((int64_t)len < 0 || (uint64_t)len < off + 24u) return ELF_ERR_SHORT;
  sym = (elf64_sym_out_t *)out;
  memset(sym, 0, sizeof(*sym));
  sb = ptr + off;
  sym->name_off = (int32_t)u32le(sb + 0);
  st_info = sb[4];
  sym->bind = (int32_t)(st_info >> 4);
  sym->sym_type = (int32_t)(st_info & 0x0fu);
  sym->shndx = (int32_t)u16le(sb + 6);
  sym->value = u64le(sb + 8);
  sym->size = u64le(sb + 16);
  return ELF_OK;
}

/** 读取 rela 节内第 idx 个 Elf64_Rela（24 字节）；out 为 elf64_rela_out_t*。 */
int32_t elf64_read_rela_c(const uint8_t *ptr, int32_t len, uint64_t rela_off, uint64_t rela_size,
                          int32_t idx, void *out) {
  elf64_rela_out_t *rela;
  uint64_t off;
  const uint8_t *rb;
  uint64_t r_info;
  if (!ptr || !out) return ELF_ERR_NULL;
  if (idx < 0 || (uint64_t)idx * 24u + 24u > rela_size) return ELF_ERR_INDEX;
  off = rela_off + (uint64_t)idx * 24u;
  if ((int64_t)len < 0 || (uint64_t)len < off + 24u) return ELF_ERR_SHORT;
  rela = (elf64_rela_out_t *)out;
  memset(rela, 0, sizeof(*rela));
  rb = ptr + off;
  rela->offset = u64le(rb + 0);
  r_info = u64le(rb + 8);
  rela->sym_idx = (int32_t)(r_info >> 32);
  rela->reloc_type = (int32_t)(r_info & 0xffffffffu);
  rela->addend = (int64_t)u64le(rb + 16);
  return ELF_OK;
}

/** C 烟测：读取金样 fixture，解析 ET_REL 与 .text 节名。 */
int32_t elf64_parse_smoke_c(void) {
  static const char *fixture_path = "tests/baseline/fixtures/elf64_min_reloc.bin";
  uint8_t blob[512];
  elf64_hdr_out_t hdr;
  elf64_sec_out_t sec;
  uint8_t name[16];
  FILE *fp;
  long n;
  int32_t blen;
  int32_t rc;

  fp = fopen(fixture_path, "rb");
  if (!fp) return 1;
  n = (long)fread(blob, 1, sizeof(blob), fp);
  fclose(fp);
  if (n < 64) return 1;
  blen = (int32_t)n;

  rc = elf64_parse_hdr_c(blob, blen, &hdr);
  if (rc != ELF_OK) return 2;
  if (hdr.e_type != 1 || hdr.machine != 62) return 3;
  if (hdr.shnum != 3 || hdr.shoff != 64) return 4;
  if (hdr.shstrndx != 2) return 5;

  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, 1, &sec);
  if (rc != ELF_OK || sec.sh_type != 1 || sec.size != 4) return 6;

  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, 2, &sec);
  if (rc != ELF_OK || sec.sh_type != 3) return 7;

  rc = elf64_sec_name_c(blob, blen, sec.offset, sec.size, 1, name, (int32_t)sizeof(name));
  if (rc < 0 || name[0] != '.' || name[1] != 't' || name[2] != 'e' || name[3] != 'x') return 8;
  return 0;
}

/** C 深化烟测（STD-063）：按名查找 .text/.shstrtab 并读取 .text 首字节。 */
int32_t elf64_sections_deep_smoke_c(void) {
  static const char *fixture_path = "tests/baseline/fixtures/elf64_min_reloc.bin";
  uint8_t blob[512];
  elf64_hdr_out_t hdr;
  elf64_sec_out_t sec;
  int32_t idx;
  uint8_t byte;
  FILE *fp;
  long n;
  int32_t blen;
  int32_t rc;

  fp = fopen(fixture_path, "rb");
  if (!fp) return 1;
  n = (long)fread(blob, 1, sizeof(blob), fp);
  fclose(fp);
  if (n < 64) return 1;
  blen = (int32_t)n;

  rc = elf64_parse_hdr_c(blob, blen, &hdr);
  if (rc != ELF_OK) return 2;

  rc = elf64_find_section_c(blob, blen, hdr.shoff, hdr.shnum, hdr.shstrndx, ".text", &idx);
  if (rc != ELF_OK || idx != 1) return 3;

  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, idx, &sec);
  if (rc != ELF_OK || sec.sh_type != 1 || sec.size != 4) return 4;

  rc = elf64_read_sec_byte_c(blob, blen, sec.offset, sec.size, 0, &byte);
  if (rc != ELF_OK || byte != 0x90) return 5;

  /* 金样 section[2] 为 SHT_STRTAB（name_off 指向 ".text" 为 STD-058 最小 fixture 约定）。 */
  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, 2, &sec);
  if (rc != ELF_OK || sec.sh_type != 3) return 6;

  return 0;
}

/** C phdr 烟测（STD-064）：解析 ET_EXEC 金样 program header。 */
int32_t elf64_phdr_smoke_c(void) {
  static const char *fixture_path = "tests/baseline/fixtures/elf64_min_phdr.bin";
  uint8_t blob[256];
  elf64_hdr_out_t hdr;
  elf64_phdr_out_t ph;
  FILE *fp;
  long n;
  int32_t blen;
  int32_t rc;

  fp = fopen(fixture_path, "rb");
  if (!fp) return 1;
  n = (long)fread(blob, 1, sizeof(blob), fp);
  fclose(fp);
  if (n < 120) return 1;
  blen = (int32_t)n;

  rc = elf64_parse_hdr_c(blob, blen, &hdr);
  if (rc != ELF_OK) return 2;
  if (hdr.e_type != 2 || hdr.machine != 62) return 3;
  if (hdr.phnum != 1 || hdr.phoff != 64) return 4;

  rc = elf64_read_phdr_c(blob, blen, hdr.phoff, hdr.phnum, 0, &ph);
  if (rc != ELF_OK) return 5;
  if (ph.p_type != 1 || ph.p_flags != 5) return 6;
  if (ph.offset != 0x100u || ph.vaddr != 0x400000u) return 7;
  if (ph.filesz != 4u || ph.memsz != 4u) return 8;

  return 0;
}

/** C symtab/rela 烟测（STD-103）：解析 elf64_sym_rela.bin 中 main 符号与 R_X86_64_64。 */
int32_t elf64_sym_rela_smoke_c(void) {
  static const char *fixture_path = "tests/baseline/fixtures/elf64_sym_rela.bin";
  uint8_t blob[640];
  elf64_hdr_out_t hdr;
  elf64_sec_out_t sec;
  elf64_sym_out_t sym;
  elf64_rela_out_t rela;
  uint8_t name[16];
  int32_t idx;
  FILE *fp;
  long n;
  int32_t blen;
  int32_t rc;

  fp = fopen(fixture_path, "rb");
  if (!fp) return 1;
  n = (long)fread(blob, 1, sizeof(blob), fp);
  fclose(fp);
  if (n < 64) return 1;
  blen = (int32_t)n;

  rc = elf64_parse_hdr_c(blob, blen, &hdr);
  if (rc != ELF_OK || hdr.e_type != 1 || hdr.shnum != 6) return 2;

  rc = elf64_find_section_c(blob, blen, hdr.shoff, hdr.shnum, hdr.shstrndx, ".symtab", &idx);
  if (rc != ELF_OK || idx != 2) return 3;
  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, idx, &sec);
  if (rc != ELF_OK || sec.sh_type != 2 || sec.size != 48) return 4;

  rc = elf64_read_sym_c(blob, blen, sec.offset, sec.size, 1, &sym);
  if (rc != ELF_OK || sym.name_off != 1 || sym.bind != 1 || sym.sym_type != 2) return 5;
  if (sym.shndx != 1 || sym.size != 4) return 6;

  rc = elf64_find_section_c(blob, blen, hdr.shoff, hdr.shnum, hdr.shstrndx, ".strtab", &idx);
  if (rc != ELF_OK || idx != 3) return 7;
  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, idx, &sec);
  if (rc != ELF_OK || sec.sh_type != 3) return 8;
  rc = elf64_sec_name_c(blob, blen, sec.offset, sec.size, sym.name_off, name, (int32_t)sizeof(name));
  if (rc < 0 || name[0] != 'm' || name[1] != 'a' || name[2] != 'i' || name[3] != 'n') return 9;

  rc = elf64_find_section_c(blob, blen, hdr.shoff, hdr.shnum, hdr.shstrndx, ".rela.text", &idx);
  if (rc != ELF_OK || idx != 4) return 10;
  rc = elf64_read_shdr_c(blob, blen, hdr.shoff, hdr.shnum, idx, &sec);
  if (rc != ELF_OK || sec.sh_type != 4 || sec.size != 24) return 11;
  rc = elf64_read_rela_c(blob, blen, sec.offset, sec.size, 0, &rela);
  if (rc != ELF_OK || rela.offset != 0 || rela.sym_idx != 1) return 12;
  if (rela.reloc_type != 1 || rela.addend != 0) return 13;

  return 0;
}

/* --- STD-121：最小 ET_REL 写入（链接器级 v1 子集） --- */

enum {
  ELF_WRITE_OK = 0,
  ELF_WRITE_ERR_NULL = -1,
  ELF_WRITE_ERR_BUFFER = -2,
  ELF_WRITE_ERR_PARAM = -3,
};

#define ELF64_WRITE_MIN_TEXT_MAX 64
#define ELF64_WRITE_SHSTR 7 /* "\0.text\0" */

static void elf64_put_u16le(uint8_t *p, uint16_t v) {
  p[0] = (uint8_t)(v & 0xffu);
  p[1] = (uint8_t)((v >> 8) & 0xffu);
}

static void elf64_put_u32le(uint8_t *p, uint32_t v) {
  p[0] = (uint8_t)(v & 0xffu);
  p[1] = (uint8_t)((v >> 8) & 0xffu);
  p[2] = (uint8_t)((v >> 16) & 0xffu);
  p[3] = (uint8_t)((v >> 24) & 0xffu);
}

static void elf64_put_u64le(uint8_t *p, uint64_t v) {
  elf64_put_u32le(p, (uint32_t)(v & 0xffffffffu));
  elf64_put_u32le(p + 4, (uint32_t)(v >> 32));
}

/** 计算 write_min_reloc 所需缓冲容量。 */
int32_t elf64_write_min_reloc_size_c(int32_t text_len) {
  if (text_len < 0 || text_len > ELF64_WRITE_MIN_TEXT_MAX) return ELF_WRITE_ERR_PARAM;
  return 64 + 3 * 64 + ELF64_WRITE_SHSTR + text_len;
}

/**
 * 写入最小 ET_REL：Ehdr + 3 Shdr（null/.text/.shstrtab）+ shstrtab + .text 节体。
 * shstrtab 固定 "\0.text\0"；text_len 上限 64；成功写 out_len 并返回 ELF_WRITE_OK。
 */
int32_t elf64_write_min_reloc_c(uint8_t *buf, int32_t cap, const uint8_t *text, int32_t text_len,
                                int32_t *out_len) {
  int32_t need;
  int32_t shstr_off;
  int32_t text_off;
  uint8_t *eh;
  uint8_t *sh;
  static const uint8_t shstr[ELF64_WRITE_SHSTR] = {0, '.', 't', 'e', 'x', 't', 0};
  if (!buf || !out_len) return ELF_WRITE_ERR_NULL;
  if (text_len < 0 || text_len > ELF64_WRITE_MIN_TEXT_MAX) return ELF_WRITE_ERR_PARAM;
  if (text_len > 0 && !text) return ELF_WRITE_ERR_NULL;
  need = elf64_write_min_reloc_size_c(text_len);
  if (need < 0 || cap < need) return ELF_WRITE_ERR_BUFFER;
  memset(buf, 0, (size_t)need);
  eh = buf;
  eh[0] = ELFMAG0;
  eh[1] = ELFMAG1;
  eh[2] = ELFMAG2;
  eh[3] = ELFMAG3;
  eh[4] = ELFCLASS64;
  eh[5] = ELFDATA2LSB;
  eh[6] = 1;
  elf64_put_u16le(eh + 16, 1);   /* ET_REL */
  elf64_put_u16le(eh + 18, 62);  /* EM_X86_64 */
  elf64_put_u64le(eh + 24, 0);   /* e_entry */
  elf64_put_u64le(eh + 40, 64);  /* e_shoff */
  elf64_put_u16le(eh + 58, 64);  /* e_shentsize */
  elf64_put_u16le(eh + 60, 3);   /* e_shnum */
  elf64_put_u16le(eh + 62, 2);   /* e_shstrndx */

  shstr_off = 64 + 3 * 64;
  text_off = shstr_off + ELF64_WRITE_SHSTR;
  memcpy(buf + shstr_off, shstr, (size_t)ELF64_WRITE_SHSTR);
  if (text_len > 0) memcpy(buf + text_off, text, (size_t)text_len);

  /* section[1] .text */
  sh = buf + 64 + 64;
  elf64_put_u32le(sh + 0, 1);
  elf64_put_u32le(sh + 4, 1);
  elf64_put_u64le(sh + 24, (uint64_t)text_off);
  elf64_put_u64le(sh + 32, (uint64_t)text_len);
  elf64_put_u64le(sh + 48, 4); /* sh_addralign */

  /* section[2] .shstrtab */
  sh = buf + 64 + 128;
  elf64_put_u32le(sh + 4, 3);
  elf64_put_u64le(sh + 24, (uint64_t)shstr_off);
  elf64_put_u64le(sh + 32, (uint64_t)ELF64_WRITE_SHSTR);

  *out_len = need;
  return ELF_WRITE_OK;
}

/** 写入 + 解析 round-trip 烟测；0 通过。 */
int32_t elf64_write_smoke_c(void) {
  uint8_t out[512];
  uint8_t text[4] = {0x90, 0x90, 0x90, 0x90};
  int32_t out_len = 0;
  elf64_hdr_out_t hdr;
  elf64_sec_out_t sec;
  int32_t idx;
  uint8_t byte;
  int32_t rc;

  rc = elf64_write_min_reloc_c(out, (int32_t)sizeof(out), text, 4, &out_len);
  if (rc != ELF_WRITE_OK || out_len <= 0) return 1;

  rc = elf64_parse_hdr_c(out, out_len, &hdr);
  if (rc != ELF_OK || hdr.e_type != 1 || hdr.machine != 62) return 2;
  if (hdr.shnum != 3 || hdr.shoff != 64 || hdr.shstrndx != 2) return 3;

  rc = elf64_find_section_c(out, out_len, hdr.shoff, hdr.shnum, hdr.shstrndx, ".text", &idx);
  if (rc != ELF_OK || idx != 1) return 4;
  rc = elf64_read_shdr_c(out, out_len, hdr.shoff, hdr.shnum, idx, &sec);
  if (rc != ELF_OK || sec.sh_type != 1 || sec.size != 4) return 5;
  rc = elf64_read_sec_byte_c(out, out_len, sec.offset, sec.size, 0, &byte);
  if (rc != ELF_OK || byte != 0x90) return 6;

  return 0;
}
