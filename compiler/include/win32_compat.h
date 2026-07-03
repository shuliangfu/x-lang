/* win32_compat.h — MinGW POSIX 兼容层 */
#ifndef SHUX_WIN32_COMPAT_H
#define SHUX_WIN32_COMPAT_H

#ifdef _WIN32

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <io.h>
#include <direct.h>
#include <process.h>
#include <sys/stat.h>

/* strndup — MinGW 无此函数 */
static inline char *strndup(const char *s, size_t n) {
    char *p = (char *)malloc(n + 1);
    if (!p) return NULL;
    memcpy(p, s, n); p[n] = 0; return p;
}

/* waitpid 宏 — Windows 无 sys/wait.h */
#ifndef WIFEXITED
#define WIFEXITED(s) 1
#define WEXITSTATUS(s) ((s) & 0xFF)
#define WIFSIGNALED(s) 0
#define WTERMSIG(s) 0
#define WIFSTOPPED(s) 0
static inline int waitpid(int pid, int *status, int options) {
    (void)pid; (void)options; if (status) *status = 0; return 0;
}
static inline int kill(int pid, int sig) { (void)pid; (void)sig; return 0; }
#endif

/* fork — Windows 无；返回 -1 表示不支持 */
static inline int fork(void) { return -1; }

/* sys/resource.h — Windows 无 */
struct rusage { int ru_utime; int ru_stime; };
#define RUSAGE_SELF 0
static inline int getrusage(int who, struct rusage *ru) { (void)who; if(ru) memset(ru,0,sizeof(*ru)); return 0; }

/* sys/utsname.h — Windows 无 */
struct utsname { char sysname[128]; char nodename[128]; char release[128]; char version[128]; char machine[128]; };
static inline int uname(struct utsname *buf) {
    if (!buf) return -1;
    strncpy(buf->sysname, "Windows", sizeof(buf->sysname)-1);
    strncpy(buf->machine, "x86_64", sizeof(buf->machine)-1);
    buf->nodename[0] = 0; buf->release[0] = 0; buf->version[0] = 0;
    return 0;
}

/* realpath — MinGW 无 */
static inline char *realpath(const char *path, char *resolved) {
    if (!path) return NULL;
    if (!resolved) resolved = (char *)malloc(260);
    if (!resolved) return NULL;
    _fullpath(resolved, path, 260);
    return resolved;
}

/* fcntl.h */
#ifndef F_OK
#define F_OK 0
#define W_OK 2
#define R_OK 4
#define X_OK 4
#endif

/* access — MinGW 有 _access */
#ifndef access
#define access _access
#endif

/* setenv — MinGW 无此函数 */
static inline int setenv(const char *name, const char *value, int overwrite) {
    (void)overwrite; return _putenv_s(name, value) == 0 ? 0 : -1;
}
static inline int unsetenv(const char *name) {
    return _putenv_s(name, "") == 0 ? 0 : -1;
}

/* strtok_r — MinGW 有 strtok_s */
#ifndef strtok_r
#define strtok_r strtok_s
#endif


/* gettimeofday — MinGW 有但需要正确头文件 */
#include <time.h>

/* sys/resource.h — rlimit/getrlimit */
struct rlimit { unsigned long rlim_cur; unsigned long rlim_max; };
typedef unsigned long rlim_t;
#define RLIMIT_STACK 3
#define RLIM_INFINITY (~0UL)
static inline int getrlimit(int resource, struct rlimit *rl) {
    (void)resource; if (rl) { rl->rlim_cur = 8*1024*1024; rl->rlim_max = RLIM_INFINITY; } return 0;
}

/* sys/mman.h — Windows 用 VirtualAlloc 替代 mmap */
#define PROT_READ 0x1
#define PROT_WRITE 0x2
#define MAP_PRIVATE 0x02
#define MAP_FAILED ((void*)-1)
static inline void *mmap(void *addr, size_t length, int prot, int flags, int fd, long offset) {
    (void)addr; (void)prot; (void)flags; (void)fd; (void)offset;
    return malloc(length);
}
static inline int munmap(void *addr, size_t length) { (void)length; free(addr); return 0; }

/* fork 返回 -1（不支持）已在上面定义 */


/* posix_memalign — MinGW 无 */
static inline int posix_memalign(void **memptr, size_t alignment, size_t size) {
    *memptr = _aligned_malloc(size, alignment);
    return *memptr ? 0 : -1;
}

/* pthread_attr_setguardsize — MinGW 无 */
static inline int pthread_attr_setguardsize(void *attr, size_t guardsize) {
    (void)attr; (void)guardsize; return 0;
}


/* asm 后端桩——shux-c C 前端不需要 asm codegen */
static inline void pipeline_fill_soa_field_access_for_asm_emit(void *m, void *a) { (void)m; (void)a; }
static inline void pipeline_module_fixup_with_arena_stmt_orders(void *m, void *a) { (void)m; (void)a; }
static inline void pipeline_fill_array_lit_types_for_skipped_typeck(void *m, void *a) { (void)m; (void)a; }
static inline void asm_skip_heavy_set_pipeline_ctx(void *ctx) { (void)ctx; }
/* 注意：真实签名有 6 参数（module, arena, ctx, elf_ctx, out_buf, out_len_ptr）
 * 但 runtime_pipeline_abi.c 调用时可能只传 5 个。桩接受 5 个匹配调用。 */
static inline int asm_asm_codegen_elf_o(void *m, void *a, void *c, void *e, void *o) {
    (void)m; (void)a; (void)c; (void)e; (void)o; return -1;
}


/* parser 模块查询桩——shux-c C 前端不需要 import 解析 */
static inline int parser_get_module_num_imports(void *m) { (void)m; return 0; }
static inline void parser_get_module_import_path(void *m, int i, unsigned char *path_buf) { (void)m; (void)i; if(path_buf) path_buf[0] = 0; }



#endif /* _WIN32 */
#endif /* SHUX_WIN32_COMPAT_H */
