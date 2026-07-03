/* win32_compat.h — MinGW POSIX 兼容层 */
#ifndef SHUX_WIN32_COMPAT_H
#define SHUX_WIN32_COMPAT_H

#ifdef _WIN32

#include <stdlib.h>
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

/* strtok_r — MinGW 有 strtok_s */
#ifndef strtok_r
#define strtok_r strtok_s
#endif

#endif /* _WIN32 */
#endif /* SHUX_WIN32_COMPAT_H */
