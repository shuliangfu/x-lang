/**
 * bootstrap_nostdlib_stubs.c — NL-07 v2：编译器 bootstrap crt0 链 nostdlib 最小 libc 桩
 *
 * 【职责】
 * 当 SHUX_BOOTSTRAP_NOSTDLIB=1 时，与 crt0_x86_64.o + freestanding_io_x86_64.o 一并链入，
 * 替代 -lc/-lm，供 build_shux_asm.sh crt0 路径尝试无 libc.so 静态链。
 *
 * 【范围】
 * 覆盖 bootstrap 链常见未定义符号：string/mem、stdio 最小格式化、getenv、
 * libm（__builtin_*）、fenv 空实现、posix_memalign、POSIX open/read/close/fstat/waitpid、
 * readlink/realpath/getcwd/opendir（NL-07 v5 runtime_link_abi / fmt_check 路径）。
 * 完整编译器仍可能缺符号（pthread/io_uring 仍链系统库）；失败时 build_shux_asm 回退 -lc/-lm。
 *
 * 【依赖】
 * freestanding_io_x86_64.s 提供 shux_sys_write / shux_sys_mmap / shux_sys_exit。
 */

#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#ifndef _WIN32
#include <sys/wait.h>
#endif
#include <sys/time.h>
#ifndef _WIN32
#include <sys/resource.h>
#endif
#ifndef _WIN32
#include <sys/utsname.h>
#endif
#include <pthread.h>
#ifndef _WIN32
#include <unistd.h>
#endif

/** bootstrap opendir 用最小 dirent（勿链 libc libdl）。 */
struct dirent {
    char d_name[256];
};

/** 不透明目录流；见 opendir/readdir/closedir。 */
typedef struct bootstrap_dir DIR;

/** FILE 最小占位；bootstrap 仅区分 stdout/stderr。 */
struct _bootstrap_file {
    int fd;
};
typedef struct _bootstrap_file FILE;

static FILE bootstrap_stdout_file = { 1 };
static FILE bootstrap_stderr_file = { 2 };

FILE *stdout = &bootstrap_stdout_file;
FILE *stderr = &bootstrap_stderr_file;

/** 线程局部 errno 占位。 */
static int bootstrap_errno;

/** nostdlib crt0 无 libc _start：由 bootstrap_init_environ 从 argv 后填充。 */
char **environ;

/** 返回 errno 指针；满足链接对 __errno_location 的引用。 */
int *__errno_location(void) {
    return &bootstrap_errno;
}

/** freestanding syscall 门面（见 freestanding_io_x86_64.s）。 */
extern long shux_sys_write(int fd, const void *buf, unsigned long len);
extern long shux_sys_read(int fd, void *buf, unsigned long len);
extern long shux_sys_close(int fd);
extern void *shux_sys_mmap(void *addr, unsigned long len, int prot, int flags, int fd, long off);
extern long shux_sys_munmap(void *addr, unsigned long len);
extern void shux_sys_exit(int code) __attribute__((noreturn));

#ifndef ARCH_SET_FS
#define ARCH_SET_FS 0x1002
#endif
#ifndef SYS_arch_prctl
#define SYS_arch_prctl 158
#endif

/**
 * NL-07 v5：nostdlib 静态链无 glibc TLS 初始化；gcc -fstack-protector 读 %fs:0x28 会 SIGSEGV。
 * FS 基址设为 &block 后，fs:0x28 即 block.stack_guard（Linux x86_64 TLS 布局）。
 */
struct bootstrap_tls_block {
    char pad[0x28];
    unsigned long stack_guard;
};

static struct bootstrap_tls_block bootstrap_tls;

/**
 * 由 crt0_x86_64.s _start 在 main_entry 之前调用；仅 Linux x86_64 nostdlib 链需要。
 * 不用 libc syscall()（-nostdlib 无 syscall 桩）。
 */
void bootstrap_init_static_tls(void) {
    long ret;
    unsigned long tls_base = (unsigned long)&bootstrap_tls;
    bootstrap_tls.stack_guard =
        (unsigned long)0xdeadbeefdeadbeefUL ^ tls_base;
    /* Linux x86_64：arch_prctl(ARCH_SET_FS, tls_base) */
    __asm__ volatile("syscall" : "=a"(ret) : "a"(158L), "D"(0x1002L), "S"(tls_base) : "rcx", "r11", "memory");
    (void)ret;
}

/**
 * NL-07 v5：自定义 crt0 不链 libc _start，须从栈布局 argv[argc+1]… 初始化 environ。
 * 由 crt0_x86_64.s _start 在 main_entry 前调用（rdi=argc, rsi=argv）。
 */
void bootstrap_init_environ(int argc, char **argv) {
    if (!argv || argc < 0) {
        environ = NULL;
        return;
    }
    environ = &argv[argc + 1];
}

/** 返回 1：driver_run_thread_on_large_stack 须在当前线程执行（pthread 桩不同步分配栈）。 */
int bootstrap_nostdlib_pthread_is_stub(void) {
    return 1;
}

/** 内存拷贝；bootstrap 链常见 libgcc/libc 引用。 */
void *memcpy(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;
    size_t i;
    if (!dest || !src)
        return dest;
    for (i = 0; i < n; i++)
        d[i] = s[i];
    return dest;
}

/** 内存移动；重叠区从后向前复制。 */
void *memmove(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;
    size_t i;
    if (!dest || !src)
        return dest;
    if (d == s || n == 0)
        return dest;
    if (d < s) {
        for (i = 0; i < n; i++)
            d[i] = s[i];
    } else {
        for (i = n; i > 0; i--)
            d[i - 1] = s[i - 1];
    }
    return dest;
}

/** 内存填充。 */
void *memset(void *s, int c, size_t n) {
    unsigned char *p = (unsigned char *)s;
    unsigned char b = (unsigned char)c;
    size_t i;
    if (!s)
        return s;
    for (i = 0; i < n; i++)
        p[i] = b;
    return s;
}

/** 内存比较；相等返回 0。 */
int memcmp(const void *a, const void *b, size_t n) {
    const unsigned char *p = (const unsigned char *)a;
    const unsigned char *q = (const unsigned char *)b;
    size_t i;
    for (i = 0; i < n; i++) {
        if (p[i] != q[i])
            return (int)p[i] - (int)q[i];
    }
    return 0;
}

/** C 字符串长度。 */
size_t strlen(const char *s) {
    size_t n = 0;
    if (!s)
        return 0;
    while (s[n])
        n++;
    return n;
}

/** 返回 s 中首个落在 reject 集内的字符偏移；未命中则返回 strlen(s)。 */
size_t strcspn(const char *s, const char *reject) {
    size_t i;
    size_t j;
    if (!s)
        return 0;
    if (!reject || !reject[0])
        return strlen(s);
    for (i = 0; s[i]; i++) {
        for (j = 0; reject[j]; j++) {
            if (s[i] == reject[j])
                return i;
        }
    }
    return i;
}

/** POSIX write；转 shux_sys_write。 */
long write(int fd, const void *buf, unsigned long count) {
    return shux_sys_write(fd, buf, count);
}

/** 栈保护失败；直接退出（bootstrap 烟测路径）。 */
void __stack_chk_fail(void) {
    shux_sys_exit(127);
}

/** abort 等价；bootstrap 无 stderr 格式化。 */
void abort(void) {
    shux_sys_exit(134);
}

/** 简单 mmap bump 分配器（MAP_PRIVATE | ANONYMOUS = 0x22 on Linux x86_64）。 */
static unsigned char *bootstrap_heap_base;
static unsigned char *bootstrap_heap_end;
static unsigned char *bootstrap_heap_limit;

/** 对齐到 16 字节边界。 */
static size_t bootstrap_align16(size_t n) {
    return (n + 15u) & ~(size_t)15u;
}

/** 扩展 bump 区；失败返回 NULL。 */
static int bootstrap_heap_grow(size_t need) {
    unsigned long chunk = 1024UL * 1024UL;
    void *p;
    if (need > chunk)
        chunk = (unsigned long)((need + 65535UL) & ~65535UL);
    p = shux_sys_mmap(0, chunk, 3 /* PROT_READ|PROT_WRITE */, 0x22 /* MAP_PRIVATE|MAP_ANONYMOUS */, -1, 0);
    if (!p || p == (void *)(intptr_t)-1)
        return -1;
    bootstrap_heap_base = (unsigned char *)p;
    bootstrap_heap_end = bootstrap_heap_base;
    bootstrap_heap_limit = bootstrap_heap_base + chunk;
    return 0;
}

/** malloc 最小实现；bootstrap 链按需。 */
void *malloc(size_t size) {
    size_t need;
    void *out;
    if (size == 0)
        return NULL;
    need = bootstrap_align16(size);
    if (!bootstrap_heap_end || bootstrap_heap_end + need > bootstrap_heap_limit) {
        if (bootstrap_heap_grow(need) != 0)
            return NULL;
    }
    out = bootstrap_heap_end;
    bootstrap_heap_end += need;
    return out;
}

/** free 最小实现；bump 分配器 no-op。 */
void free(void *ptr) {
    (void)ptr;
}

/** calloc 最小实现。 */
void *calloc(size_t nmemb, size_t size) {
    size_t total = nmemb * size;
    void *p = malloc(total);
    if (p)
        memset(p, 0, total);
    return p;
}

/** realloc 最小实现；仅支持 NULL 或 bump 内指针的简单路径。 */
void *realloc(void *ptr, size_t size) {
    if (!ptr)
        return malloc(size);
    if (size == 0) {
        free(ptr);
        return NULL;
    }
    /* bump 无法原地扩展；分配新块并拷贝（bootstrap 烟测足够）。 */
    {
        void *n = malloc(size);
        if (!n)
            return NULL;
        /* 旧块大小未知；保守拷贝 size 字节。 */
        memcpy(n, ptr, size);
        return n;
    }
}

/** C 字符串比较；相等返回 0。 */
int strcmp(const char *a, const char *b) {
    size_t i = 0;
    if (!a || !b)
        return (a == b) ? 0 : (a ? 1 : -1);
    while (a[i] && a[i] == b[i])
        i++;
    return (unsigned char)a[i] - (unsigned char)b[i];
}

/** 限定长度字符串比较。 */
int strncmp(const char *a, const char *b, size_t n) {
    size_t i;
    if (!a || !b)
        return (a == b) ? 0 : (a ? 1 : -1);
    for (i = 0; i < n; i++) {
        if (a[i] != b[i] || a[i] == '\0')
            return (unsigned char)a[i] - (unsigned char)b[i];
    }
    return 0;
}

/** 字符串拷贝；返回 dest。 */
char *strcpy(char *dest, const char *src) {
  char *d = dest;
  if (!dest || !src)
    return dest;
  while ((*d++ = *src++))
    ;
  return dest;
}

/** 字符串拼接；dest 须有足够空间。 */
char *strcat(char *dest, const char *src) {
  size_t dlen;
  if (!dest || !src)
    return dest;
  dlen = strlen(dest);
  strcpy(dest + dlen, src);
  return dest;
}

/** strtol 最小实现：支持 base 0/10/16 与正负号。 */
long strtol(const char *nptr, char **endptr, int base) {
  const char *p = nptr;
  long sign = 1;
  long val = 0;
  if (!nptr) {
    if (endptr)
      *endptr = (char *)nptr;
    return 0;
  }
  while (*p == ' ' || *p == '\t' || *p == '\n')
    p++;
  if (*p == '-') {
    sign = -1;
    p++;
  } else if (*p == '+') {
    p++;
  }
  if (base == 0) {
    if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
      base = 16;
      p += 2;
    } else if (p[0] == '0') {
      base = 8;
      p++;
    } else {
      base = 10;
    }
  } else if (base == 16 && p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
    p += 2;
  }
  while (*p) {
    int digit = -1;
    if (*p >= '0' && *p <= '9')
      digit = *p - '0';
    else if (*p >= 'a' && *p <= 'z')
      digit = 10 + (*p - 'a');
    else if (*p >= 'A' && *p <= 'Z')
      digit = 10 + (*p - 'A');
    if (digit < 0 || digit >= base)
      break;
    val = val * base + digit;
    p++;
  }
  if (endptr)
    *endptr = (char *)p;
  return sign * val;
}

/** strtoul 最小实现：委托 strtol，负值钳制为 0（SHUX_STACK_LIMIT_MB 等环境变量解析）。 */
unsigned long strtoul(const char *nptr, char **endptr, int base) {
  long v = strtol(nptr, endptr, base);
  if (v < 0)
    return 0UL;
  return (unsigned long)v;
}

/** glibc 2.38+ 可能把 strto* 重写到 __isoc23_*；nostdlib 链直接回落到本地最小实现。 */
long __isoc23_strtol(const char *nptr, char **endptr, int base) {
  return strtol(nptr, endptr, base);
}

/** 兼容 glibc 新符号名，避免 runtime_driver_abi / pipeline_sx 在 nostdlib 链丢失解析符号。 */
unsigned long __isoc23_strtoul(const char *nptr, char **endptr, int base) {
  return strtoul(nptr, endptr, base);
}

/** mmap 最小包装：将裸 syscall 的负 errno 返回归一化为 MAP_FAILED。 */
void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t off) {
  uintptr_t raw = (uintptr_t)shux_sys_mmap(addr, (unsigned long)len, prot, flags, fd, (long)off);
  if (raw >= (uintptr_t)-4095) {
    bootstrap_errno = -(int)(intptr_t)raw;
    return (void *)-1;
  }
  return (void *)raw;
}

/** munmap 最小包装：将裸 syscall 的负 errno 返回归一化为 -1。 */
int munmap(void *addr, size_t len) {
  long rc = shux_sys_munmap(addr, (unsigned long)len);
  if (rc < 0) {
    bootstrap_errno = (int)(-rc);
    return -1;
  }
  return 0;
}

/** 限定长度拷贝；保证 dest 以 NUL 结尾。 */
char *strncpy(char *dest, const char *src, size_t n) {
    size_t i;
    if (!dest || !src)
        return dest;
    for (i = 0; i < n && src[i]; i++)
        dest[i] = src[i];
    for (; i < n; i++)
        dest[i] = '\0';
    return dest;
}

/** 堆上复制字符串；失败返回 NULL。 */
char *strdup(const char *s) {
    size_t n;
    char *p;
    if (!s)
        return NULL;
    n = strlen(s) + 1;
    p = (char *)malloc(n);
    if (p)
        memcpy(p, s, n);
    return p;
}

/** 进程退出；转 shux_sys_exit。 */
void exit(int code) {
    shux_sys_exit(code);
}

/**
 * getenv：遍历 bootstrap_init_environ 设置的 environ（与 Linux 进程 envp 布局一致）。
 */
char *getenv(const char *name) {
    char **ep;
    size_t nlen;
    if (!name || !environ)
        return NULL;
    nlen = strlen(name);
    for (ep = environ; *ep; ep++) {
        if (strncmp(*ep, name, nlen) == 0 && (*ep)[nlen] == '=')
            return *ep + nlen + 1;
    }
    return NULL;
}

/** 对齐分配；用 bump malloc + 手动对齐。 */
int posix_memalign(void **memptr, size_t alignment, size_t size) {
    uintptr_t raw;
    uintptr_t aligned;
    size_t total;
    void *block;
    if (!memptr || alignment < sizeof(void *) || (alignment & (alignment - 1)) != 0)
        return 22; /* EINVAL */
    if (size == 0) {
        *memptr = NULL;
        return 0;
    }
    total = size + alignment + sizeof(void *);
    block = malloc(total);
    if (!block)
        return 12; /* ENOMEM */
    raw = (uintptr_t)block + sizeof(void *);
    aligned = (raw + alignment - 1) & ~(uintptr_t)(alignment - 1);
    ((void **)aligned)[-1] = block;
    *memptr = (void *)aligned;
    return 0;
}

/** 最小 vsnprintf：支持 %% %c %s %d %u %ld %lu %x %p %f（%f 精度有限）。 */
static int bootstrap_format_double(double x, char *out, size_t cap) {
    size_t n = 0;
    long ipart;
    unsigned frac6;
    int scale;
    if (cap == 0)
        return 0;
    if (x < 0.0) {
        if (n < cap)
            out[n++] = '-';
        x = -x;
    }
    ipart = (long)x;
    frac6 = (unsigned)((x - (double)ipart) * 1000000.0 + 0.5);
    if (frac6 >= 1000000u) {
        ipart++;
        frac6 = 0;
    }
    if (ipart == 0) {
        if (n < cap)
            out[n++] = '0';
    } else {
        char ib[32];
        int in = 0;
        long v = ipart;
        while (v > 0) {
            ib[in++] = (char)('0' + (v % 10));
            v /= 10;
        }
        while (in > 0 && n < cap)
            out[n++] = ib[--in];
    }
    if (n < cap)
        out[n++] = '.';
    for (scale = 100000; scale >= 1; scale /= 10) {
        if (n < cap)
            out[n++] = (char)('0' + ((frac6 / (unsigned)scale) % 10u));
    }
    return (int)n;
}

/** 最小 vsnprintf：支持 %% %c %s %d %u %ld %lu %x %p %f（%f 精度有限）。 */
int vsnprintf(char *buf, size_t size, const char *fmt, va_list ap) {
    size_t pos = 0;
    if (!buf || size == 0)
        return fmt ? (int)strlen(fmt) : 0;
    if (!fmt) {
        buf[0] = '\0';
        return 0;
    }
    while (*fmt) {
        if (*fmt != '%') {
            if (pos + 1 < size)
                buf[pos] = *fmt;
            pos++;
            fmt++;
            continue;
        }
        fmt++;
        if (*fmt == '%') {
            if (pos + 1 < size)
                buf[pos] = '%';
            pos++;
            fmt++;
            continue;
        }
        {
            char tmp[64];
            int tn = 0;
            int width = 0;
            int prec = -1;
            int longmod = 0;
            while (*fmt >= '0' && *fmt <= '9') {
                width = width * 10 + (*fmt - '0');
                fmt++;
            }
            if (*fmt == '.') {
                fmt++;
                prec = 0;
                while (*fmt >= '0' && *fmt <= '9') {
                    prec = prec * 10 + (*fmt - '0');
                    fmt++;
                }
            }
            if (*fmt == 'l') {
                longmod = 1;
                fmt++;
            }
            (void)width;
            (void)prec;
            switch (*fmt) {
            case 'c': {
                char c = (char)va_arg(ap, int);
                tmp[tn++] = c;
                break;
            }
            case 's': {
                const char *s = va_arg(ap, const char *);
                int si = 0;
                if (!s)
                    s = "(null)";
                while (s[si]) {
                    if (pos + 1 < size)
                        buf[pos] = s[si];
                    pos++;
                    si++;
                }
                fmt++;
                continue;
            }
            case 'd': {
                long v = longmod ? va_arg(ap, long) : va_arg(ap, int);
                char ib[32];
                int in = 0;
                int neg = 0;
                if (v < 0) {
                    neg = 1;
                    v = -v;
                }
                if (v == 0)
                    ib[in++] = '0';
                while (v > 0) {
                    ib[in++] = (char)('0' + (v % 10));
                    v /= 10;
                }
                if (neg && in < (int)sizeof(ib))
                    ib[in++] = '-';
                while (in > 0 && tn < (int)sizeof(tmp) - 1)
                    tmp[tn++] = ib[--in];
                break;
            }
            case 'u': {
                unsigned long v = longmod ? va_arg(ap, unsigned long) : va_arg(ap, unsigned int);
                char ib[32];
                int in = 0;
                if (v == 0)
                    ib[in++] = '0';
                while (v > 0) {
                    ib[in++] = (char)('0' + (v % 10));
                    v /= 10;
                }
                while (in > 0 && tn < (int)sizeof(tmp) - 1)
                    tmp[tn++] = ib[--in];
                break;
            }
            case 'x': {
                unsigned long v = longmod ? va_arg(ap, unsigned long) : va_arg(ap, unsigned int);
                char ib[32];
                int in = 0;
                if (v == 0)
                    ib[in++] = '0';
                while (v > 0) {
                    ib[in++] = "0123456789abcdef"[v & 15];
                    v >>= 4;
                }
                while (in > 0 && tn < (int)sizeof(tmp) - 1)
                    tmp[tn++] = ib[--in];
                break;
            }
            case 'p': {
                void *p = va_arg(ap, void *);
                tmp[tn++] = '0';
                tmp[tn++] = 'x';
                {
                    uintptr_t v = (uintptr_t)p;
                    char ib[2 * sizeof(uintptr_t) + 1];
                    int in = 0;
                    if (v == 0)
                        ib[in++] = '0';
                    while (v > 0) {
                        ib[in++] = "0123456789abcdef"[v & 15];
                        v >>= 4;
                    }
                    while (in > 0 && tn < (int)sizeof(tmp) - 1)
                        tmp[tn++] = ib[--in];
                }
                break;
            }
            case 'f': {
                double dv = va_arg(ap, double);
                char fb[32];
                int fn = bootstrap_format_double(dv, fb, sizeof(fb));
                int fi = 0;
                if (fn < 0)
                    fn = 0;
                while (fi < fn && tn < (int)sizeof(tmp) - 1)
                    tmp[tn++] = fb[fi++];
                break;
            }
            default:
                tmp[tn++] = *fmt;
                break;
            }
            fmt++;
            {
                int ti;
                for (ti = 0; ti < tn; ti++) {
                    if (pos + 1 < size)
                        buf[pos] = tmp[ti];
                    pos++;
                }
            }
        }
    }
    if (size > 0)
        buf[pos < size ? pos : size - 1] = '\0';
    return (int)pos;
}

/** snprintf 包装 vsnprintf。 */
int snprintf(char *buf, size_t size, const char *fmt, ...) {
    va_list ap;
    int n;
    va_start(ap, fmt);
    n = vsnprintf(buf, size, fmt, ap);
    va_end(ap);
    return n;
}

/** 向 fd 格式化输出；返回写入字节数。 */
static int bootstrap_vfprintf_fd(int fd, const char *fmt, va_list ap) {
    char stack_buf[512];
    char *heap_buf = NULL;
    char *use_buf = stack_buf;
    size_t cap = sizeof(stack_buf);
    va_list ap2;
    int need;
    int wrote = 0;
    if (!fmt)
        return 0;
    va_copy(ap2, ap);
    need = vsnprintf(stack_buf, cap, fmt, ap2);
    va_end(ap2);
    if (need >= (int)cap) {
        cap = (size_t)need + 1u;
        heap_buf = (char *)malloc(cap);
        if (!heap_buf)
            return -1;
        use_buf = heap_buf;
        need = vsnprintf(use_buf, cap, fmt, ap);
    }
    if (need > 0)
        wrote = (int)write(fd, use_buf, (unsigned long)need);
    free(heap_buf);
    return wrote;
}

/** fprintf 最小实现；仅 stdout/stderr fd 路径。 */
int fprintf(FILE *stream, const char *fmt, ...) {
    va_list ap;
    int n;
    int fd = 1;
    if (stream == stderr)
        fd = 2;
    va_start(ap, fmt);
    n = bootstrap_vfprintf_fd(fd, fmt, ap);
    va_end(ap);
    return n;
}

/** vfprintf 最小实现；供 _FORTIFY_SOURCE 重定向桩使用。 */
int vfprintf(FILE *stream, const char *fmt, va_list ap) {
    int fd = 1;
    if (stream == stderr)
        fd = 2;
    else if (stream != stdout)
        return -1;
    return bootstrap_vfprintf_fd(fd, fmt, ap);
}

/** glibc _FORTIFY_SOURCE：nostdlib 链 fmt_check_cmd_driver.o 需要。 */
int __fprintf_chk(FILE *stream, int flag, const char *fmt, ...) {
    va_list ap;
    int n;
    (void)flag;
    va_start(ap, fmt);
    n = vfprintf(stream, fmt, ap);
    va_end(ap);
    return n;
}

/** glibc _FORTIFY_SOURCE：nostdlib 链 snprintf 重定向。 */
int __snprintf_chk(char *s, size_t maxlen, int flag, size_t slen, const char *fmt, ...) {
    va_list ap;
    int n;
    (void)flag;
    (void)slen;
    if (!s || maxlen == 0)
        return -1;
    va_start(ap, fmt);
    n = vsnprintf(s, maxlen, fmt, ap);
    va_end(ap);
    return n;
}

/** printf 最小实现。 */
int printf(const char *fmt, ...) {
    va_list ap;
    int n;
    va_start(ap, fmt);
    n = bootstrap_vfprintf_fd(1, fmt, ap);
    va_end(ap);
    return n;
}

/* ── libm：编译器内置，替代 -lm ── */

double sin(double x) { return __builtin_sin(x); }
double cos(double x) { return __builtin_cos(x); }
double tan(double x) { return __builtin_tan(x); }
double asin(double x) { return __builtin_asin(x); }
double acos(double x) { return __builtin_acos(x); }
double atan(double x) { return __builtin_atan(x); }
double atan2(double y, double x) { return __builtin_atan2(y, x); }
double sqrt(double x) { return __builtin_sqrt(x); }
double cbrt(double x) { return __builtin_cbrt(x); }
double pow(double base, double exp) { return __builtin_pow(base, exp); }
double exp(double x) { return __builtin_exp(x); }
double log(double x) { return __builtin_log(x); }
double log1p(double x) { return __builtin_log1p(x); }
double expm1(double x) { return __builtin_expm1(x); }
double fabs(double x) { return __builtin_fabs(x); }
double floor(double x) { return __builtin_floor(x); }
double ceil(double x) { return __builtin_ceil(x); }
double trunc(double x) { return __builtin_trunc(x); }
double round(double x) { return __builtin_round(x); }
double fmin(double a, double b) { return __builtin_fmin(a, b); }
double fmax(double a, double b) { return __builtin_fmax(a, b); }
double erf(double x) { return __builtin_erf(x); }
double erfc(double x) { return __builtin_erfc(x); }

/* ── fenv 空实现：runtime_math_libm.c 在 Linux 上可链入 ── */

#define FE_INVALID 0x01
#define FE_DIVBYZERO 0x02
#define FE_OVERFLOW 0x04
#define FE_UNDERFLOW 0x08
#define FE_INEXACT 0x10
#define FE_ALL_EXCEPT (FE_INVALID | FE_DIVBYZERO | FE_OVERFLOW | FE_UNDERFLOW | FE_INEXACT)

/** 清除浮点异常标志；bootstrap 恒成功。 */
int feclearexcept(int excepts) {
    (void)excepts;
    return 0;
}

/** 测试浮点异常标志；bootstrap 恒无异常。 */
int fetestexcept(int excepts) {
    (void)excepts;
    return 0;
}

/** 触发浮点异常标志；bootstrap 恒成功。 */
int feraiseexcept(int excepts) {
    (void)excepts;
    return 0;
}

/* ── POSIX I/O / 进程：Linux x86_64 经 freestanding_io 或 syscall ── */

#if defined(__linux__) && defined(__x86_64__)

/** Linux x86_64 三参数 syscall 助手。 */
static long bootstrap_syscall3(long nr, long a0, long a1, long a2) {
    long ret;
    __asm__ volatile("syscall" : "=a"(ret) : "a"(nr), "D"(a0), "S"(a1), "d"(a2) : "rcx", "r11", "memory");
    return ret;
}

/** Linux x86_64 四参数 syscall 助手（waitpid 等）。 */
static long bootstrap_syscall4(long nr, long a0, long a1, long a2, long a3) {
    long ret;
    register long r10 asm("r10") = a3;
    __asm__ volatile("syscall" : "=a"(ret) : "a"(nr), "D"(a0), "S"(a1), "d"(a2), "r"(r10) : "rcx", "r11", "memory");
    return ret;
}

#endif

/** read：转 shux_sys_read。 */
ssize_t read(int fd, void *buf, size_t count) {
    return (ssize_t)shux_sys_read(fd, buf, (unsigned long)count);
}

/** close：转 shux_sys_close。 */
int close(int fd) {
    return (int)shux_sys_close(fd);
}

/** open：O_CREAT 时取 mode；Linux 走 syscall 2。 */
int open(const char *path, int flags, ...) {
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode = (mode_t)va_arg(ap, int);
        va_end(ap);
    }
#if defined(__linux__) && defined(__x86_64__)
    return (int)bootstrap_syscall3(2L, (long)path, (long)flags, (long)mode);
#else
    (void)path;
    (void)flags;
    (void)mode;
    return -1;
#endif
}

/** fstat：Linux syscall 5。 */
int fstat(int fd, struct stat *st) {
#if defined(__linux__) && defined(__x86_64__)
    return (int)bootstrap_syscall3(5L, (long)fd, (long)st, 0L);
#else
    (void)fd;
    (void)st;
    return -1;
#endif
}

/** stat：Linux syscall 4。 */
int stat(const char *path, struct stat *st) {
#if defined(__linux__) && defined(__x86_64__)
    return (int)bootstrap_syscall3(4L, (long)path, (long)st, 0L);
#else
    (void)path;
    (void)st;
    return -1;
#endif
}

/** getpid：Linux syscall 39。 */
pid_t getpid(void) {
#if defined(__linux__) && defined(__x86_64__)
    return (pid_t)bootstrap_syscall3(39L, 0L, 0L, 0L);
#else
    return 1;
#endif
}

/** waitpid：Linux syscall 61。 */
pid_t waitpid(pid_t pid, int *status, int options) {
#if defined(__linux__) && defined(__x86_64__)
    return (pid_t)bootstrap_syscall4(61L, (long)pid, (long)status, (long)options, 0L);
#else
    (void)pid;
    (void)status;
    (void)options;
    return -1;
#endif
}

/** perror：最小实现，输出 msg + errno 到 stderr。 */
void perror(const char *msg) {
    if (msg && msg[0])
        fprintf(stderr, "%s: ", msg);
    fprintf(stderr, "errno=%d\n", bootstrap_errno);
}

/** fopen 最小实现：仅支持 "w"/"r"；返回带 fd 的 FILE 占位。 */
FILE *fopen(const char *path, const char *mode) {
    static FILE bootstrap_file_w = { 1 };
    static FILE bootstrap_file_r = { 0 };
    int flags = 0;
    int fd;
    if (!path || !mode)
        return NULL;
    if (mode[0] == 'w')
        flags = O_WRONLY | O_CREAT | O_TRUNC;
    else if (mode[0] == 'r')
        flags = O_RDONLY;
    else
        return NULL;
    fd = open(path, flags, 0644);
    if (fd < 0)
        return NULL;
    if (mode[0] == 'w') {
        bootstrap_file_w.fd = fd;
        return &bootstrap_file_w;
    }
    bootstrap_file_r.fd = fd;
    return &bootstrap_file_r;
}

/** fclose：close 并返回 0。 */
int fclose(FILE *stream) {
    if (!stream)
        return -1;
    close(stream->fd);
    stream->fd = -1;
    return 0;
}

/** fwrite 最小实现。 */
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t total;
    ssize_t n;
    if (!ptr || !stream || size == 0 || nmemb == 0)
        return 0;
    total = size * nmemb;
    n = write(stream->fd, ptr, (unsigned long)total);
    if (n < 0)
        return 0;
    return (size_t)n / size;
}

/** 查找字符首次出现位置。 */
char *strchr(const char *s, int c) {
  if (!s)
    return NULL;
  for (; *s; s++) {
    if ((unsigned char)*s == (unsigned char)c)
      return (char *)s;
  }
  if ((unsigned char)c == '\0')
    return (char *)s;
  return NULL;
}

/** 在内存块中查找字节；string.h 常用。 */
void *memchr(const void *s, int c, size_t n) {
  const unsigned char *p = (const unsigned char *)s;
  size_t i;
  if (!p)
    return NULL;
  for (i = 0; i < n; i++) {
    if (p[i] == (unsigned char)c)
      return (void *)(p + i);
  }
  return NULL;
}

/** 写 C 字符串到流（不含换行）。 */
int fputs(const char *s, FILE *stream) {
  size_t n;
  if (!s || !stream)
    return -1;
  n = strlen(s);
  if (n > 0 && write(stream->fd, s, (unsigned long)n) != (ssize_t)n)
    return -1;
  return 1;
}

/** ASCII 大写化；driver_argv_collect_defines 路径用。 */
int toupper(int c) {
  if (c >= 'a' && c <= 'z')
    return c + ('A' - 'a');
  return c;
}

/** gettimeofday 最小实现；Linux 走 syscall 96。 */
int gettimeofday(struct timeval *tv, void *tz) {
  (void)tz;
  if (!tv)
    return -1;
#if defined(__linux__) && defined(__x86_64__)
  {
    long ret = bootstrap_syscall3(96L, (long)tv, 0L, 0L);
    return (int)ret;
  }
#else
  tv->tv_sec = 0;
  tv->tv_usec = 0;
  return 0;
#endif
}

/** popen/pclose 最小桩；runtime_link_abi 仅需符号解析。 */
FILE *popen(const char *command, const char *type) {
  (void)command;
  (void)type;
  return NULL;
}

int pclose(FILE *stream) {
  (void)stream;
  return -1;
}

/** pthread 最小桩：bootstrap 单线程，create 同步执行 start_routine。 */
int pthread_attr_init(pthread_attr_t *attr) {
  if (!attr)
    return 22;
  memset(attr, 0, sizeof(*attr));
  return 0;
}

int pthread_attr_destroy(pthread_attr_t *attr) {
  (void)attr;
  return 0;
}

int pthread_attr_setguardsize(pthread_attr_t *attr, size_t guardsize) {
  (void)attr;
  (void)guardsize;
  return 0;
}

int pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize) {
  (void)attr;
  (void)stackaddr;
  (void)stacksize;
  return 0;
}

int pthread_attr_setstacksize(pthread_attr_t *attr, size_t stacksize) {
  (void)attr;
  (void)stacksize;
  return 0;
}

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg) {
  (void)attr;
  if (thread)
    *thread = 1;
  if (start_routine)
    (void)start_routine(arg);
  return 0;
}

int pthread_join(pthread_t thread, void **retval) {
  (void)thread;
  if (retval)
    *retval = NULL;
  return 0;
}

/** pthread 互斥/条件变量最小桩：bootstrap 单线程；满足 runtime 链符号，不链 libpthread。 */
int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *attr) {
  (void)attr;
  if (!mutex)
    return 22;
  memset(mutex, 0, sizeof(*mutex));
  return 0;
}

int pthread_mutex_destroy(pthread_mutex_t *mutex) {
  (void)mutex;
  return 0;
}

int pthread_mutex_lock(pthread_mutex_t *mutex) {
  (void)mutex;
  return 0;
}

int pthread_mutex_unlock(pthread_mutex_t *mutex) {
  (void)mutex;
  return 0;
}

pthread_t pthread_self(void) {
  return (pthread_t)1;
}

int pthread_cond_init(pthread_cond_t *cond, const pthread_condattr_t *attr) {
  (void)attr;
  if (!cond)
    return 22;
  memset(cond, 0, sizeof(*cond));
  return 0;
}

int pthread_cond_destroy(pthread_cond_t *cond) {
  (void)cond;
  return 0;
}

int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex) {
  (void)cond;
  (void)mutex;
  return 0;
}

int pthread_cond_signal(pthread_cond_t *cond) {
  (void)cond;
  return 0;
}

int pthread_cond_broadcast(pthread_cond_t *cond) {
  (void)cond;
  return 0;
}

int pthread_setaffinity_np(pthread_t thread, size_t cpusetsize, const cpu_set_t *cpuset) {
  (void)thread;
  (void)cpusetsize;
  (void)cpuset;
  return 0;
}

/** 查找字符最后一次出现位置。 */
char *strrchr(const char *s, int c) {
    const char *last = NULL;
    if (!s)
        return NULL;
    for (; *s; s++) {
        if ((unsigned char)*s == (unsigned char)c)
            last = s;
    }
    if ((unsigned char)c == '\0')
        return (char *)s;
    return (char *)last;
}

/** 查找子串首次出现位置；needle 空串时返回 haystack。 */
char *strstr(const char *haystack, const char *needle) {
    size_t nlen;
    size_t i;
    if (!haystack || !needle)
        return NULL;
    if (!needle[0])
        return (char *)haystack;
    nlen = strlen(needle);
    for (i = 0; haystack[i]; i++) {
        if (strncmp(haystack + i, needle, nlen) == 0)
            return (char *)(haystack + i);
    }
    return NULL;
}

/** 小写化 ASCII 字母；bootstrap target_cpu 路径用。 */
int tolower(int c) {
    if (c >= 'A' && c <= 'Z')
        return c + ('a' - 'A');
    return c;
}

#if defined(__linux__) && defined(__x86_64__)

/** readlink：Linux syscall 89。 */
ssize_t readlink(const char *path, char *buf, size_t bufsiz) {
    long ret = bootstrap_syscall3(89L, (long)path, (long)buf, (long)bufsiz);
    if (ret < 0)
        return -1;
    return (ssize_t)ret;
}

/** getcwd：优先 /proc/self/cwd readlink。 */
char *getcwd(char *buf, size_t size) {
    ssize_t n;
    if (!buf || size == 0) {
        bootstrap_errno = 22; /* EINVAL */
        return NULL;
    }
    n = readlink("/proc/self/cwd", buf, size - 1);
    if (n < 0)
        return NULL;
    buf[n] = '\0';
    return buf;
}

/** 拼接 base + rel 到 out（out 容量 cap）；成功返回 out。 */
static char *bootstrap_path_join(char *out, size_t cap, const char *base, const char *rel) {
    size_t blen;
    size_t rlen;
    if (!out || cap == 0 || !base || !rel)
        return NULL;
    blen = strlen(base);
    rlen = strlen(rel);
    if (blen + 1 + rlen + 1 > cap)
        return NULL;
    memcpy(out, base, blen);
    if (blen > 0 && base[blen - 1] != '/') {
        out[blen] = '/';
        blen++;
    }
    memcpy(out + blen, rel, rlen + 1);
    return out;
}

/** realpath 最小实现：绝对路径拷贝；相对路径基于 getcwd 拼接（无 .. 规范化）。 */
char *realpath(const char *path, char *resolved) {
    static char bootstrap_realpath_pool[4096];
    char *out = resolved ? resolved : bootstrap_realpath_pool;
    size_t cap = resolved ? 4096u : sizeof(bootstrap_realpath_pool);
    char cwd[2048];
    if (!path)
        return NULL;
    if (path[0] == '/') {
        if (strlen(path) + 1 > cap)
            return NULL;
        strcpy(out, path);
        return out;
    }
    if (!getcwd(cwd, sizeof(cwd)))
        return NULL;
    return bootstrap_path_join(out, cap, cwd, path);
}

/** Linux getdents64 目录项（bootstrap opendir 用）。 */
struct bootstrap_linux_dirent64 {
    uint64_t d_ino;
    int64_t d_off;
    unsigned short d_reclen;
    unsigned char d_type;
    char d_name[];
};

/** bootstrap opendir 状态。 */
struct bootstrap_dir {
    int fd;
    unsigned char *buf;
    size_t buf_cap;
    size_t buf_len;
    size_t buf_pos;
    struct dirent ent;
};

/** opendir：open + getdents64 缓冲。 */
DIR *opendir(const char *name) {
    struct bootstrap_dir *d;
    if (!name)
        return NULL;
    d = (struct bootstrap_dir *)calloc(1, sizeof(*d));
    if (!d)
        return NULL;
    d->fd = open(name, O_RDONLY | 0200000 /* O_DIRECTORY */);
    if (d->fd < 0) {
        free(d);
        return NULL;
    }
    d->buf_cap = 8192;
    d->buf = (unsigned char *)malloc(d->buf_cap);
    if (!d->buf) {
        close(d->fd);
        free(d);
        return NULL;
    }
    return (DIR *)d;
}

/** readdir：从 getdents64 缓冲取下一条；失败或结束返回 NULL。 */
struct dirent *readdir(DIR *dirp) {
    struct bootstrap_dir *d = (struct bootstrap_dir *)dirp;
    struct bootstrap_linux_dirent64 *de;
    if (!d || d->fd < 0)
        return NULL;
    for (;;) {
        if (d->buf_pos >= d->buf_len) {
            long nr = bootstrap_syscall3(217L, (long)d->fd, (long)d->buf, (long)d->buf_cap);
            if (nr <= 0)
                return NULL;
            d->buf_len = (size_t)nr;
            d->buf_pos = 0;
        }
        if (d->buf_pos >= d->buf_len)
            return NULL;
        de = (struct bootstrap_linux_dirent64 *)(d->buf + d->buf_pos);
        d->buf_pos += de->d_reclen;
        if (de->d_name[0] == '\0')
            continue;
        strncpy(d->ent.d_name, de->d_name, sizeof(d->ent.d_name) - 1);
        d->ent.d_name[sizeof(d->ent.d_name) - 1] = '\0';
        return &d->ent;
    }
}

/** closedir：释放 bootstrap_dir。 */
int closedir(DIR *dirp) {
    struct bootstrap_dir *d = (struct bootstrap_dir *)dirp;
    if (!d)
        return -1;
    if (d->fd >= 0)
        close(d->fd);
    free(d->buf);
    free(d);
    return 0;
}

#else

/** 非 Linux x86_64：路径 API 桩返回失败。 */
ssize_t readlink(const char *path, char *buf, size_t bufsiz) {
    (void)path;
    (void)buf;
    (void)bufsiz;
    return -1;
}

char *getcwd(char *buf, size_t size) {
    (void)buf;
    (void)size;
    return NULL;
}

char *realpath(const char *path, char *resolved) {
    (void)path;
    (void)resolved;
    return NULL;
}

DIR *opendir(const char *name) {
    (void)name;
    return NULL;
}

struct dirent *readdir(DIR *dirp) {
    (void)dirp;
    return NULL;
}

int closedir(DIR *dirp) {
    (void)dirp;
    return -1;
}

#endif

/** fgets：从 FILE 读一行（含换行或 EOF）。 */
char *fgets(char *s, int size, FILE *stream) {
  int i;
  if (!s || size <= 0 || !stream)
    return NULL;
  for (i = 0; i < size - 1; i++) {
    unsigned char c;
    ssize_t n = read(stream->fd, &c, 1);
    if (n <= 0) {
      if (i == 0)
        return NULL;
      break;
    }
    s[i] = (char)c;
    if (c == '\n') {
      i++;
      break;
    }
  }
  s[i] = '\0';
  return s;
}

/** glibc FORTIFY：nostdlib 链 backend_call_dispatch / parser_asm 需要。 */
void *__memcpy_chk(void *dest, const void *src, size_t len, size_t destlen) {
  if (len > destlen)
    __stack_chk_fail();
  return memcpy(dest, src, len);
}

/** 刷新流；bootstrap 无用户缓冲，恒成功。 */
int fflush(FILE *stream) {
  (void)stream;
  return 0;
}

/** 写单字符到流。 */
int fputc(int c, FILE *stream) {
  unsigned char ch = (unsigned char)c;
  if (!stream)
    return -1;
  if (write(stream->fd, &ch, 1) != 1)
    return -1;
  return (unsigned char)c;
}

/** 设置流缓冲；bootstrap no-op。 */
int setvbuf(FILE *stream, char *buf, int mode, size_t size) {
  (void)stream;
  (void)buf;
  (void)mode;
  (void)size;
  return 0;
}

/** 设置环境变量；bootstrap 无真实 environ，恒成功 no-op。 */
int setenv(const char *name, const char *value, int overwrite) {
  (void)name;
  (void)value;
  (void)overwrite;
  return 0;
}

/** 进程立即退出；不跑 atexit（Linux syscall 60）。 */
void _exit(int status) {
#if defined(__linux__) && defined(__x86_64__)
  bootstrap_syscall3(60L, (long)status, 0L, 0L);
  for (;;)
    ;
#else
  shux_sys_exit(status);
#endif
}

#if defined(__linux__) && defined(__x86_64__)

/** fork：Linux syscall 57。 */
pid_t fork(void) {
  return (pid_t)bootstrap_syscall3(57L, 0L, 0L, 0L);
}

/** execve：Linux syscall 59；execvp 传入 bootstrap environ（勿传 NULL，否则 gcc/collect2 无 PATH）。 */
int execvp(const char *file, char *const argv[]) {
  return (int)bootstrap_syscall3(59L, (long)file, (long)argv, (long)(uintptr_t)environ);
}

/** execv：Linux syscall 59。 */
int execv(const char *path, char *const argv[]) {
  return (int)bootstrap_syscall3(59L, (long)path, (long)argv, 0L);
}

/** execlp：可变参数转 argv 后 execvp（签名与 unistd.h 一致）。 */
int execlp(const char *file, const char *arg, ...) {
  va_list ap;
  char *argv[256];
  int i = 0;
  argv[i++] = (char *)file;
  argv[i++] = (char *)arg;
  va_start(ap, arg);
  while (i < 255) {
    char *a = va_arg(ap, char *);
    argv[i++] = a;
    if (!a)
      break;
  }
  va_end(ap);
  return execvp(file, argv);
}

/** uname：Linux syscall 63。 */
int uname(struct utsname *buf) {
  if (!buf)
    return -1;
  memset(buf, 0, sizeof(*buf));
  strncpy(buf->sysname, "Linux", sizeof(buf->sysname) - 1);
  strncpy(buf->machine, "x86_64", sizeof(buf->machine) - 1);
  return 0;
}

/** getrlimit / setrlimit：Linux syscall 97 / 160。 */
int getrlimit(int resource, struct rlimit *rlim) {
  return (int)bootstrap_syscall3(97L, (long)resource, (long)rlim, 0L);
}

int setrlimit(int resource, const struct rlimit *rlim) {
  return (int)bootstrap_syscall3(160L, (long)resource, (long)rlim, 0L);
}

/** system 最小实现：fork + execvp + waitpid；失败返回 -1。 */
int system(const char *command) {
  pid_t pid;
  int status = 0;
  if (!command)
    return 1;
  pid = fork();
  if (pid < 0)
    return -1;
  if (pid == 0) {
    char *argv[] = { "/bin/sh", "-c", (char *)command, NULL };
    execvp("/bin/sh", argv);
    _exit(127);
  }
  if (waitpid(pid, &status, 0) < 0)
    return -1;
  if (WIFEXITED(status))
    return WEXITSTATUS(status);
  return -1;
}

/** unlink：Linux syscall 87。 */
int unlink(const char *path) {
  return (int)bootstrap_syscall3(87L, (long)path, 0L, 0L);
}

/** rename：Linux syscall 82。 */
int rename(const char *oldpath, const char *newpath) {
  return (int)bootstrap_syscall3(82L, (long)oldpath, (long)newpath, 0L);
}

/** access：Linux syscall 21（mode 仅 F_OK 常用）。 */
int access(const char *path, int mode) {
  return (int)bootstrap_syscall3(21L, (long)path, (long)mode, 0L);
}

/** fdopen：将已打开 fd 包装为 FILE 占位。 */
FILE *fdopen(int fd, const char *mode) {
  static FILE bootstrap_fd_file = { -1 };
  (void)mode;
  if (fd < 0)
    return NULL;
  bootstrap_fd_file.fd = fd;
  return &bootstrap_fd_file;
}

/** mkstemp：/tmp/shuxXXXXXX 最小实现（pid+序号避免跨进程 O_EXCL 冲突）。 */
int mkstemp(char *template) {
  static int bootstrap_mkstemp_seq;
  char *p;
  int fd;
  int attempt;
  if (!template)
    return -1;
  p = strstr(template, "XXXXXX");
  if (!p)
    return -1;
  for (attempt = 0; attempt < 32; attempt++) {
    bootstrap_mkstemp_seq++;
    snprintf(p, 7, "%06d", (int)((getpid() * 997u + (unsigned)bootstrap_mkstemp_seq + (unsigned)attempt) % 1000000u));
    fd = open(template, O_RDWR | O_CREAT | O_EXCL, 0600);
    if (fd >= 0)
      return fd;
  }
  return -1;
}

#else

/** 非 Linux x86_64：进程 API 桩。 */
pid_t fork(void) {
  return -1;
}

int execvp(const char *file, char *const argv[]) {
  (void)file;
  (void)argv;
  return -1;
}

int system(const char *command) {
  (void)command;
  return -1;
}

#endif
