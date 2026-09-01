/*
 * xlang_backtrace_cap.h — Cap residual 9.1.11: stack capture + symbol resolve
 * without libc backtrace()/dladdr() on Linux (x86_64 + aarch64).
 *
 * Capture: frame-pointer walk via __builtin_frame_address.
 * Resolve: Linux — /proc/self/maps + ELF symtab; Darwin — Mach-O (slice1, WIP).
 *
 * Frame pointers may require -fno-omit-frame-pointer for deep stacks.
 *
 * PLATFORM: LINUX + DARWIN (x86_64 + aarch64); other platforms use execinfo/dladdr.
 */

#ifndef XLANG_BACKTRACE_CAP_H
#define XLANG_BACKTRACE_CAP_H

#include <stddef.h>
#include <stdint.h>

#if (defined(__linux__) || defined(__APPLE__)) && (defined(__x86_64__) || defined(__aarch64__))

/** dladdr-compatible layout for Cap symbolicate. PLATFORM: SHARED */
typedef struct XlangBtDlInfo {
  const char *dli_fname;
  void *dli_fbase;
  const char *dli_sname;
  void *dli_saddr;
} XlangBtDlInfo;

/**
 * Capture return addresses by walking the frame-pointer chain.
 * Mirrors glibc backtrace() layout: array[i] = return IP of frame i above caller.
 *
 * @param array output pointer array (void*)
 * @param size  max entries
 * @return number of frames written (0 on failure)
 * PLATFORM: LINUX|DARWIN
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

#if defined(__linux__)

#include <fcntl.h>
#include <stdint.h>
#include <string.h>

#include <xlang_syscall_cap.h>

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

#elif defined(__APPLE__)

#include <fcntl.h>
#include <string.h>

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

/** Mach-O 64-bit constants (minimal subset). PLATFORM: MACOS|DARWIN */
enum {
  XLANG_BT_MH_MAGIC_64 = 0xfeedfacfU,
  XLANG_BT_LC_SYMTAB = 2U,
  XLANG_BT_LC_SEGMENT_64 = 0x19U,
  XLANG_BT_MACH_N_EXT = 0x01U,
  XLANG_BT_MACH_N_TYPE = 0x0eU,
  XLANG_BT_MACH_N_SECT = 0x0eU,
  XLANG_BT_MACH_N_ABS = 0x02U,
  XLANG_BT_MACH_N_STAB = 0xe0U
};

/** Minimal Mach types for mach_vm_region_recurse. PLATFORM: MACOS|DARWIN */
typedef unsigned int xlang_bt_natural_t;
typedef xlang_bt_natural_t xlang_bt_mach_port_t;
typedef uint64_t xlang_bt_mach_vm_addr_t;
typedef uint64_t xlang_bt_mach_vm_size_t;
typedef int xlang_bt_kern_return_t;
typedef xlang_bt_natural_t xlang_bt_mach_msg_type_num_t;
typedef int xlang_bt_integer_t;

typedef struct {
  xlang_bt_integer_t data[64];
} xlang_bt_vm_recurse_info_t;

extern xlang_bt_mach_port_t mach_task_self(void);
extern xlang_bt_kern_return_t mach_vm_region_recurse(
    xlang_bt_mach_port_t target_task,
    xlang_bt_mach_vm_addr_t *address,
    xlang_bt_mach_vm_size_t *size,
    xlang_bt_natural_t *depth,
    xlang_bt_integer_t *info,
    xlang_bt_mach_msg_type_num_t *infoCnt);
extern int proc_regionfilename(int pid, uint64_t address, void *buffer, uint32_t buffersize);

/**
 * Darwin raw syscall with 0 args (getpid).
 * PLATFORM: MACOS|DARWIN
 */
static inline long xlang_bt_darwin_syscall0(long nr) {
  long r;
#if defined(__x86_64__)
  __asm__ __volatile__("syscall" : "=a"(r) : "a"(nr) : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = 0;
  __asm__ __volatile__("svc #0" : "+r"(x0) : "r"(x8) : "memory");
  r = x0;
#endif
  return r;
}

/**
 * Darwin raw syscall with 1 arg (close).
 * PLATFORM: MACOS|DARWIN
 */
static inline long xlang_bt_darwin_syscall1(long nr, long a1) {
  long r;
#if defined(__x86_64__)
  __asm__ __volatile__("syscall" : "=a"(r) : "a"(nr), "D"(a1) : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = a1;
  __asm__ __volatile__("svc #0" : "+r"(x0) : "r"(x8) : "memory");
  r = x0;
#endif
  return r;
}

/**
 * Darwin raw syscall with 3 args (open).
 * PLATFORM: MACOS|DARWIN
 */
static inline long xlang_bt_darwin_syscall3(long nr, long a1, long a2, long a3) {
  long r;
#if defined(__x86_64__)
  __asm__ __volatile__("syscall"
                       : "=a"(r)
                       : "a"(nr), "D"(a1), "S"(a2), "d"(a3)
                       : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = a1;
  register long x1 __asm__("x1") = a2;
  register long x2 __asm__("x2") = a3;
  __asm__ __volatile__("svc #0"
                       : "+r"(x0)
                       : "r"(x8), "r"(x1), "r"(x2)
                       : "memory");
  r = x0;
#endif
  return r;
}

/**
 * Darwin raw syscall with 4 args (pread).
 * PLATFORM: MACOS|DARWIN
 */
static inline long xlang_bt_darwin_syscall4(long nr, long a1, long a2, long a3, long a4) {
  long r;
#if defined(__x86_64__)
  register long r10 __asm__("r10") = a4;
  __asm__ __volatile__("syscall"
                       : "=a"(r)
                       : "a"(nr), "D"(a1), "S"(a2), "d"(a3), "r"(r10)
                       : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = a1;
  register long x1 __asm__("x1") = a2;
  register long x2 __asm__("x2") = a3;
  register long x3 __asm__("x3") = a4;
  __asm__ __volatile__("svc #0"
                       : "+r"(x0)
                       : "r"(x8), "r"(x1), "r"(x2), "r"(x3)
                       : "memory");
  r = x0;
#endif
  return r;
}

#if defined(__x86_64__)
#define XLANG_BT_SYS_open(path) ((int)xlang_bt_darwin_syscall3(0x2000005L, (long)(path), (long)O_RDONLY, 0))
#define XLANG_BT_SYS_close(fd)  ((int)xlang_bt_darwin_syscall1(0x2000006L, (long)(fd)))
#define XLANG_BT_SYS_pread(fd, buf, cnt, off) \
  (xlang_bt_darwin_syscall4(0x2000177L, (long)(fd), (long)(buf), (long)(cnt), (long)(off)))
#define XLANG_BT_SYS_getpid()   ((int)xlang_bt_darwin_syscall0(0x2000014L))
#elif defined(__aarch64__)
#define XLANG_BT_SYS_open(path) ((int)xlang_bt_darwin_syscall3(5, (long)(path), (long)O_RDONLY, 0))
#define XLANG_BT_SYS_close(fd)  ((int)xlang_bt_darwin_syscall1(6, (long)(fd)))
#define XLANG_BT_SYS_pread(fd, buf, cnt, off) \
  (xlang_bt_darwin_syscall4(189, (long)(fd), (long)(buf), (long)(cnt), (long)(off)))
#define XLANG_BT_SYS_getpid()   ((int)xlang_bt_darwin_syscall0(20))
#endif

/**
 * Resolve VM region base for addr via mach_vm_region_recurse (slide anchor).
 * @return 1 on success with *region_out set, else 0
 * PLATFORM: MACOS|DARWIN
 */
static inline int xlang_bt_darwin_region_base(uintptr_t addr, uintptr_t *region_out) {
  xlang_bt_mach_vm_addr_t vaddr;
  xlang_bt_mach_vm_size_t vsize;
  xlang_bt_natural_t depth;
  xlang_bt_vm_recurse_info_t info;
  xlang_bt_mach_msg_type_num_t count;
  xlang_bt_kern_return_t kr;
  if (!region_out)
    return 0;
  vaddr = (xlang_bt_mach_vm_addr_t)addr;
  vsize = 0;
  depth = 0;
  count = (xlang_bt_mach_msg_type_num_t)(sizeof(info) / sizeof(xlang_bt_integer_t));
  kr = mach_vm_region_recurse(mach_task_self(), &vaddr, &vsize, &depth, info.data, &count);
  if (kr != 0)
    return 0;
  *region_out = (uintptr_t)vaddr;
  return 1;
}

/**
 * Copy mapping path for addr via proc_regionfilename.
 * @return 1 if path copied, else 0
 * PLATFORM: MACOS|DARWIN
 */
static inline int xlang_bt_darwin_region_path(uintptr_t addr, char *path, size_t path_cap) {
  int pid;
  int n;
  if (!path || path_cap == 0)
    return 0;
  path[0] = '\0';
  pid = XLANG_BT_SYS_getpid();
  n = proc_regionfilename(pid, (uint64_t)addr, path, (uint32_t)path_cap);
  return (n > 0 && path[0]) ? 1 : 0;
}

/**
 * Parse Mach-O header load commands; return __TEXT vmaddr for slide math.
 * @return 1 if vmaddr found, else 0
 * PLATFORM: MACOS|DARWIN
 */
static inline int xlang_bt_macho_text_vmaddr(int fd, uint64_t *vmaddr_out) {
  uint8_t hdr[32];
  uint32_t ncmds;
  uint32_t off;
  uint32_t i;
  if (!vmaddr_out)
    return 0;
  *vmaddr_out = 0;
  if (XLANG_BT_SYS_pread(fd, hdr, sizeof(hdr), 0) != (long)sizeof(hdr))
    return 0;
  {
    uint32_t magic;
    memcpy(&magic, hdr, 4);
    if (magic != XLANG_BT_MH_MAGIC_64)
      return 0;
  }
  memcpy(&ncmds, hdr + 16, 4);
  off = 32;
  for (i = 0; i < ncmds && off + 8 <= sizeof(hdr) + 65536u; i++) {
    uint8_t cmdbuf[72];
    uint32_t cmd;
    uint32_t cmdsize;
    if (XLANG_BT_SYS_pread(fd, cmdbuf, sizeof(cmdbuf), (long)off) != (long)sizeof(cmdbuf))
      break;
    memcpy(&cmd, cmdbuf, 4);
    memcpy(&cmdsize, cmdbuf + 4, 4);
    if (cmdsize < 8)
      break;
    if (cmd == XLANG_BT_LC_SEGMENT_64) {
      char segname[16];
      uint64_t vmaddr;
      memcpy(segname, cmdbuf + 8, 16);
      segname[15] = '\0';
      memcpy(&vmaddr, cmdbuf + 24, 8);
      if (strncmp(segname, "__TEXT", 16) == 0) {
        *vmaddr_out = vmaddr;
        return 1;
      }
    }
    off += cmdsize;
  }
  return 0;
}

/**
 * Lookup nearest nlist_64 symbol for unslid target address in Mach-O symtab.
 * @return 1 if symbol name written, else 0
 * PLATFORM: MACOS|DARWIN
 */
static inline int xlang_bt_macho_lookup_sym(int fd, uint64_t target, char *out, size_t out_cap) {
  uint8_t hdr[32];
  uint32_t ncmds;
  uint32_t off;
  uint32_t i;
  uint32_t symoff = 0;
  uint32_t nsyms = 0;
  uint32_t stroff = 0;
  uint32_t strsize = 0;
  uint8_t syms[65536];
  uint8_t strs[65536];
  uint64_t best_val = 0;
  uint32_t best_name = 0;
  int have_best = 0;
  if (!out || out_cap == 0)
    return 0;
  out[0] = '\0';
  if (XLANG_BT_SYS_pread(fd, hdr, sizeof(hdr), 0) != (long)sizeof(hdr))
    return 0;
  memcpy(&ncmds, hdr + 16, 4);
  off = 32;
  for (i = 0; i < ncmds; i++) {
    uint8_t cmdbuf[32];
    uint32_t cmd;
    uint32_t cmdsize;
    if (XLANG_BT_SYS_pread(fd, cmdbuf, sizeof(cmdbuf), (long)off) != (long)sizeof(cmdbuf))
      break;
    memcpy(&cmd, cmdbuf, 4);
    memcpy(&cmdsize, cmdbuf + 4, 4);
    if (cmdsize < 8)
      break;
    if (cmd == XLANG_BT_LC_SYMTAB) {
      memcpy(&symoff, cmdbuf + 8, 4);
      memcpy(&nsyms, cmdbuf + 12, 4);
      memcpy(&stroff, cmdbuf + 16, 4);
      memcpy(&strsize, cmdbuf + 20, 4);
      break;
    }
    off += cmdsize;
  }
  if (symoff == 0 || nsyms == 0 || stroff == 0 || strsize == 0)
    return 0;
  if (nsyms > 4096)
    nsyms = 4096;
  if ((uint64_t)nsyms * 16u > sizeof(syms))
    return 0;
  if (strsize == 0 || strsize >= sizeof(strs))
    return 0;
  if (XLANG_BT_SYS_pread(fd, syms, (long)nsyms * 16L, (long)symoff) <= 0)
    return 0;
  if (XLANG_BT_SYS_pread(fd, strs, (long)strsize, (long)stroff) <= 0)
    return 0;
  for (i = 0; i < nsyms; i++) {
    const uint8_t *sym = syms + (size_t)i * 16u;
    uint32_t n_strx;
    uint8_t n_type;
    uint8_t type;
    uint64_t n_value;
    uint64_t next_val;
    memcpy(&n_strx, sym + 0, 4);
    n_type = sym[4];
    memcpy(&n_value, sym + 8, 8);
    if (n_strx == 0 || n_value == 0)
      continue;
    if ((n_type & XLANG_BT_MACH_N_STAB) != 0)
      continue;
    type = (uint8_t)(n_type & XLANG_BT_MACH_N_TYPE);
    if (type != XLANG_BT_MACH_N_SECT && type != XLANG_BT_MACH_N_ABS)
      continue;
    if (n_value > target)
      continue;
    next_val = UINT64_MAX;
    if (i + 1 < nsyms) {
      const uint8_t *ns = syms + (size_t)(i + 1u) * 16u;
      uint8_t nt = ns[4];
      if ((nt & XLANG_BT_MACH_N_STAB) == 0) {
        uint64_t nv;
        memcpy(&nv, ns + 8, 8);
        if (nv > n_value)
          next_val = nv;
      }
    }
    if (target >= next_val)
      continue;
    if (!have_best || n_value >= best_val) {
      best_val = n_value;
      best_name = n_strx;
      have_best = 1;
    }
  }
  if (have_best && best_name < strsize) {
    const char *s = (const char *)(strs + best_name);
    size_t n = 0;
    while (s[n] && n + 1 < out_cap)
      n++;
    if (n > 0) {
      memcpy(out, s, n);
      out[n] = '\0';
      return 1;
    }
  }
  return 0;
}

/**
 * Cap residual dladdr: proc_regionfilename + Mach-O LC_SYMTAB + slide from
 * mach_vm_region_recurse / __TEXT vmaddr (Darwin syscall open/pread/close only).
 * @return nonzero on success (dli_fname and/or dli_sname usable)
 * PLATFORM: MACOS|DARWIN
 */
static inline int xlang_bt_dladdr(void *addr, XlangBtDlInfo *info) {
  static char fname[256];
  static char sname[256];
  uintptr_t a = (uintptr_t)addr;
  uintptr_t region = 0;
  uint64_t text_vmaddr = 0;
  uint64_t slide;
  uint64_t target;
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
  if (!xlang_bt_darwin_region_base(a, &region))
    return 0;
  if (!xlang_bt_darwin_region_path(a, path, sizeof(path)))
    return 0;
  strncpy(fname, path, sizeof(fname) - 1);
  fname[sizeof(fname) - 1] = '\0';
  info->dli_fname = fname;
  info->dli_fbase = (void *)region;
  fd = XLANG_BT_SYS_open(path);
  if (fd < 0)
    return (info->dli_fname && info->dli_fname[0]) ? 1 : 0;
  if (!xlang_bt_macho_text_vmaddr(fd, &text_vmaddr)) {
    XLANG_BT_SYS_close(fd);
    return (info->dli_fname && info->dli_fname[0]) ? 1 : 0;
  }
  slide = (uint64_t)region - text_vmaddr;
  target = (uint64_t)a - slide;
  if (xlang_bt_macho_lookup_sym(fd, target, sname, sizeof(sname))) {
    info->dli_sname = sname;
    info->dli_saddr = (void *)(uintptr_t)(target + slide);
  }
  XLANG_BT_SYS_close(fd);
  return (info->dli_sname && info->dli_sname[0]) ? 1 : (info->dli_fname && info->dli_fname[0]) ? 1 : 0;
}

#endif /* __linux__ | __APPLE__ dladdr */

#endif /* LINUX|DARWIN Cap */

#endif /* XLANG_BACKTRACE_CAP_H */
