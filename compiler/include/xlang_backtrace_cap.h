/*
 * xlang_backtrace_cap.h — Cap residual 9.1.11: stack capture + symbol resolve
 * without libc backtrace()/dladdr() on Linux (x86_64 + aarch64).
 *
 * Capture: frame-pointer walk via __builtin_frame_address.
 * Resolve: /proc/self/maps + ELF .dynsym/.symtab scan (no libdl).
 *
 * Frame pointers may require -fno-omit-frame-pointer for deep stacks.
 *
 * PLATFORM: LINUX primary; other platforms use execinfo/dladdr at call sites.
 */

#ifndef XLANG_BACKTRACE_CAP_H
#define XLANG_BACKTRACE_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <fcntl.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include <xlang_syscall_cap.h>

/** dladdr-compatible layout for Cap symbolicate (Linux slice1). */
typedef struct XlangBtDlInfo {
  const char *dli_fname;
  void *dli_fbase;
  const char *dli_sname;
  void *dli_saddr;
} XlangBtDlInfo;

#if defined(__x86_64__)
#define XLANG_BT_SYS_open(path) ((int)xlang_syscall3(2, (long)(path), (long)O_RDONLY, 0))
#define XLANG_BT_SYS_close(fd)  ((int)xlang_syscall1(3, (long)(fd)))
#define XLANG_BT_SYS_pread(fd, buf, cnt, off) \
  (xlang_syscall4(17, (long)(fd), (long)(buf), (long)(cnt), (long)(off)))
#elif defined(__aarch64__)
#ifndef AT_FDCWD
#define AT_FDCWD (-100)
#endif
#define XLANG_BT_SYS_open(path) \
  ((int)xlang_syscall4(56, (long)AT_FDCWD, (long)(path), (long)O_RDONLY, 0))
#define XLANG_BT_SYS_close(fd)  ((int)xlang_syscall1(57, (long)(fd)))
#define XLANG_BT_SYS_pread(fd, buf, cnt, off) \
  (xlang_syscall4(67, (long)(fd), (long)(buf), (long)(cnt), (long)(off)))
#endif

/**
 * Parse hex prefix from maps token; advances *p past consumed digits.
 * PLATFORM: LINUX
 */
static inline uintptr_t xlang_bt_parse_hex(const char **p) {
  uintptr_t v = 0;
  const char *s = *p;
  while (*s) {
    char c = *s;
    if (c >= '0' && c <= '9')
      v = (v << 4) + (uintptr_t)(c - '0');
    else if (c >= 'a' && c <= 'f')
      v = (v << 4) + (uintptr_t)(c - 'a' + 10);
    else if (c >= 'A' && c <= 'F')
      v = (v << 4) + (uintptr_t)(c - 'A' + 10);
    else
      break;
    s++;
  }
  *p = s;
  return v;
}

/**
 * Copy path field from a /proc/self/maps line into out (NUL-terminated).
 * @return 1 if a pathname was copied, else 0
 * PLATFORM: LINUX
 */
static inline int xlang_bt_maps_copy_path(const char *line, char *out, size_t out_cap) {
  const char *p = line;
  int fields = 0;
  size_t n = 0;
  if (!line || !out || out_cap == 0)
    return 0;
  while (*p && fields < 5) {
    while (*p == ' ')
      p++;
    if (!*p)
      break;
    while (*p && *p != ' ')
      p++;
    fields++;
  }
  while (*p == ' ')
    p++;
  if (!*p || *p == '\n')
    return 0;
  while (*p && *p != '\n' && n + 1 < out_cap) {
    out[n++] = *p++;
  }
  out[n] = '\0';
  return n > 0 ? 1 : 0;
}

/**
 * Find executable mapping containing addr; writes path/base/end.
 * @return 1 on hit, else 0
 * PLATFORM: LINUX
 */
static inline int xlang_bt_maps_find(uintptr_t addr, char *path, size_t path_cap,
                                     uintptr_t *base_out, uintptr_t *end_out) {
  char maps[32768];
  int fd;
  long nr;
  char *cur;
  char *nl;
  int have = 0;
  if (!path || path_cap == 0 || !base_out || !end_out)
    return 0;
  path[0] = '\0';
  fd = XLANG_BT_SYS_open("/proc/self/maps");
  if (fd < 0)
    return 0;
  nr = XLANG_BT_SYS_pread(fd, maps, sizeof(maps) - 1, 0);
  XLANG_BT_SYS_close(fd);
  if (nr <= 0)
    return 0;
  maps[nr] = '\0';
  cur = maps;
  while (cur && *cur) {
    uintptr_t start;
    uintptr_t end;
    const char *p = cur;
    nl = strchr(cur, '\n');
    if (nl)
      *nl = '\0';
    start = xlang_bt_parse_hex(&p);
    if (*p != '-')
      goto next_line;
    p++;
    end = xlang_bt_parse_hex(&p);
    if (addr >= start && addr < end) {
      char tmp[256];
      if (xlang_bt_maps_copy_path(cur, tmp, sizeof(tmp))) {
        int is_exec = strstr(cur, " r-xp ") != NULL;
        if (!have || is_exec) {
          size_t n = 0;
          while (tmp[n] && n + 1 < path_cap)
            n++;
          memcpy(path, tmp, n);
          path[n] = '\0';
          *base_out = start;
          *end_out = end;
          have = 1;
          if (is_exec)
            return 1;
        }
      }
    }
  next_line:
    if (!nl)
      break;
    cur = nl + 1;
  }
  return have;
}

/** ELF64 constants for sym scan (minimal subset). */
enum {
  XLANG_BT_EI_CLASS = 4,
  XLANG_BT_ELFCLASS64 = 2,
  XLANG_BT_SHT_SYMTAB = 2,
  XLANG_BT_SHT_STRTAB = 3,
  XLANG_BT_SHT_DYNSYM = 11,
  XLANG_BT_STT_FUNC = 2,
  XLANG_BT_STT_NOTYPE = 0,
  XLANG_BT_STB_GLOBAL = 1,
  XLANG_BT_STB_WEAK = 2
};

/**
 * Lookup symbol name for offset within ELF fd; writes name into out.
 * @return 1 if a symbol name was written, else 0
 * PLATFORM: LINUX
 */
static inline int xlang_bt_elf_lookup_sym(int fd, uintptr_t offset, char *out, size_t out_cap) {
  uint8_t ehdr[64];
  uint8_t shdrs[8192];
  uint8_t shstr[4096];
  uint8_t syms[65536];
  uint8_t strs[65536];
  uint64_t e_shoff;
  uint16_t e_shentsize;
  uint16_t e_shnum;
  uint16_t e_shstrndx;
  uint16_t shi;
  int found = 0;
  if (!out || out_cap == 0)
    return 0;
  out[0] = '\0';
  if (XLANG_BT_SYS_pread(fd, ehdr, sizeof(ehdr), 0) != (long)sizeof(ehdr))
    return 0;
  if (ehdr[0] != 0x7f || ehdr[1] != 'E' || ehdr[2] != 'L' || ehdr[3] != 'F')
    return 0;
  if (ehdr[XLANG_BT_EI_CLASS] != XLANG_BT_ELFCLASS64)
    return 0;
  memcpy(&e_shoff, ehdr + 40, 8);
  memcpy(&e_shentsize, ehdr + 58, 2);
  memcpy(&e_shnum, ehdr + 60, 2);
  memcpy(&e_shstrndx, ehdr + 62, 2);
  if (e_shentsize == 0 || e_shnum == 0 || e_shnum > 128)
    return 0;
  if (XLANG_BT_SYS_pread(fd, shdrs, (long)e_shentsize * (long)e_shnum, (long)e_shoff) <= 0)
    return 0;
  if (e_shstrndx >= e_shnum)
    return 0;
  {
    const uint8_t *shstr_h = shdrs + (size_t)e_shstrndx * (size_t)e_shentsize;
    uint64_t shstr_off;
    uint64_t shstr_sz;
    memcpy(&shstr_off, shstr_h + 24, 8);
    memcpy(&shstr_sz, shstr_h + 32, 8);
    if (shstr_sz == 0 || shstr_sz >= sizeof(shstr))
      return 0;
    if (XLANG_BT_SYS_pread(fd, shstr, (long)shstr_sz, (long)shstr_off) <= 0)
      return 0;
  }
  for (shi = 0; shi < e_shnum; shi++) {
    const uint8_t *sh = shdrs + (size_t)shi * (size_t)e_shentsize;
    uint32_t sh_type;
    uint64_t sh_off;
    uint64_t sh_sz;
    uint32_t sh_link;
    uint64_t best_val = 0;
    uint32_t best_name = 0;
    int have_best = 0;
    memcpy(&sh_type, sh + 4, 4);
    if (sh_type != XLANG_BT_SHT_DYNSYM && sh_type != XLANG_BT_SHT_SYMTAB)
      continue;
    memcpy(&sh_off, sh + 24, 8);
    memcpy(&sh_sz, sh + 32, 8);
    memcpy(&sh_link, sh + 40, 4);
    if (sh_sz == 0 || sh_sz >= sizeof(syms) || sh_link >= e_shnum)
      continue;
    if (XLANG_BT_SYS_pread(fd, syms, (long)sh_sz, (long)sh_off) <= 0)
      continue;
    {
      const uint8_t *str_sh = shdrs + (size_t)sh_link * (size_t)e_shentsize;
      uint64_t str_off;
      uint64_t str_sz;
      memcpy(&str_off, str_sh + 24, 8);
      memcpy(&str_sz, str_sh + 32, 8);
      if (str_sz == 0 || str_sz >= sizeof(strs))
        continue;
      if (XLANG_BT_SYS_pread(fd, strs, (long)str_sz, (long)str_off) <= 0)
        continue;
    }
    {
      size_t sym_count = (size_t)(sh_sz / 24);
      size_t si;
      for (si = 0; si < sym_count; si++) {
        const uint8_t *sym = syms + si * 24;
        uint32_t st_name;
        uint8_t st_info;
        uint64_t st_value;
        uint64_t st_size;
        uint8_t st_type;
        uint8_t st_bind;
        memcpy(&st_name, sym + 0, 4);
        st_info = sym[4];
        memcpy(&st_value, sym + 8, 8);
        memcpy(&st_size, sym + 16, 8);
        st_bind = (uint8_t)(st_info >> 4);
        st_type = (uint8_t)(st_info & 0x0fu);
        if (st_name == 0)
          continue;
        if (st_bind != XLANG_BT_STB_GLOBAL && st_bind != XLANG_BT_STB_WEAK)
          continue;
        if (st_type != XLANG_BT_STT_FUNC && st_type != XLANG_BT_STT_NOTYPE)
          continue;
        if (st_value > offset)
          continue;
        if (st_size != 0 && offset >= st_value + st_size)
          continue;
        if (!have_best || st_value >= best_val) {
          best_val = st_value;
          best_name = st_name;
          have_best = 1;
        }
      }
    }
    if (have_best && best_name < sizeof(strs)) {
      const char *s = (const char *)(strs + best_name);
      size_t n = 0;
      while (s[n] && n + 1 < out_cap)
        n++;
      if (n > 0) {
        memcpy(out, s, n);
        out[n] = '\0';
        found = 1;
      }
    }
  }
  return found;
}

/**
 * Cap residual dladdr: map address to file + nearest symbol (ELF symtab scan).
 * @return nonzero on success (至少 dli_fname 或 dli_sname 可用)
 * PLATFORM: LINUX
 */
static inline int xlang_bt_dladdr(void *addr, XlangBtDlInfo *info) {
  static char fname[256];
  static char sname[256];
  uintptr_t a = (uintptr_t)addr;
  uintptr_t base = 0;
  uintptr_t end = 0;
  char path[256];
  int fd;
  if (!info)
    return 0;
  info->dli_fname = NULL;
  info->dli_fbase = NULL;
  info->dli_sname = NULL;
  info->dli_saddr = NULL;
  fname[0] = '\0';
  sname[0] = '\0';
  path[0] = '\0';
  if (!xlang_bt_maps_find(a, path, sizeof(path), &base, &end))
    return 0;
  strncpy(fname, path, sizeof(fname) - 1);
  fname[sizeof(fname) - 1] = '\0';
  info->dli_fname = fname;
  info->dli_fbase = (void *)base;
  fd = XLANG_BT_SYS_open(path);
  if (fd >= 0) {
    uintptr_t off = a - base;
    if (xlang_bt_elf_lookup_sym(fd, off, sname, sizeof(sname))) {
      info->dli_sname = sname;
      info->dli_saddr = (void *)(base + off);
    }
    XLANG_BT_SYS_close(fd);
  }
  return (info->dli_sname && info->dli_sname[0]) ? 1 : (info->dli_fname && info->dli_fname[0]) ? 1 : 0;
}

/**
 * Capture return addresses by walking the frame-pointer chain.
 * Mirrors glibc backtrace() layout: array[i] = return IP of frame i above caller.
 *
 * @param array output pointer array (void*)
 * @param size  max entries
 * @return number of frames written (0 on failure)
 * PLATFORM: LINUX
 */
static inline int xlang_bt_backtrace(void **array, int size) {
  void **bp;
  int n = 0;
  if (!array || size <= 0)
    return 0;
  bp = (void **)(uintptr_t)__builtin_frame_address(0);
  while (n < size && bp != NULL) {
    void **next_bp;
    void *ret_addr;
    if (((uintptr_t)bp & (sizeof(void *) - 1)) != 0)
      break;
    next_bp = (void **)*bp;
    ret_addr = *(bp + 1);
    if (ret_addr == NULL)
      break;
    array[n++] = ret_addr;
    if (next_bp == NULL || next_bp <= bp)
      break;
    bp = next_bp;
  }
  return n;
}

#endif /* LINUX Cap */

#endif /* XLANG_BACKTRACE_CAP_H */
