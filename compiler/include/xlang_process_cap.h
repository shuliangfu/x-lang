/*
 * xlang_process_cap.h — Cap residual 9.1.4: Linux fork/execve/wait4/pipe
 * without libc fork/execve/waitpid/pipe.
 *
 * Single authority for std.process OS glue (process_*_impl) on LINUX primary.
 * Host mega spawn/system may call the same helpers later.
 *
 * PLATFORM: LINUX (x86_64 + aarch64) primary; other POSIX keep libc at call sites.
 */

#ifndef XLANG_PROCESS_CAP_H
#define XLANG_PROCESS_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <xlang_syscall_cap.h>

#ifndef SIGCHLD
#define SIGCHLD 17
#endif

/** Cap residual 9.1.9: aliases → single syscall authority. */
#define xlang_proc_syscall6 xlang_syscall6
#define xlang_proc_syscall3 xlang_syscall3
#define xlang_proc_syscall1 xlang_syscall1

/**
 * Cap residual pipe(2): create pipe ends into fd[2].
 * @return 0 ok, -1 fail
 * PLATFORM: LINUX
 */
static inline int xlang_proc_pipe(int fd[2]) {
  long r;
  if (!fd)
    return -1;
#if defined(__x86_64__)
  /* pipe = 22; fills int fd[2] */
  r = xlang_proc_syscall1(22, (long)fd);
#elif defined(__aarch64__)
  /* pipe2 = 59, flags=0 */
  r = xlang_proc_syscall3(59, (long)fd, 0, 0);
#endif
  return r == 0 ? 0 : -1;
}

/**
 * Cap residual fork(2): return child pid in parent, 0 in child, -1 on error.
 * PLATFORM: LINUX — x86_64 fork; aarch64 clone(SIGCHLD).
 */
static inline long xlang_proc_fork(void) {
#if defined(__x86_64__)
  /* fork = 57 */
  return xlang_proc_syscall1(57, 0);
#elif defined(__aarch64__)
  /* clone = 220; flags=SIGCHLD, stack=0 → fork-like */
  return xlang_proc_syscall6(220, (long)SIGCHLD, 0, 0, 0, 0, 0);
#endif
}

/**
 * Cap residual execve(2). Does not return on success.
 * @return -1 on failure (caller should _exit)
 * PLATFORM: LINUX
 */
static inline int xlang_proc_execve(const char *path, char *const argv[], char *const envp[]) {
  long r;
#if defined(__x86_64__)
  /* execve = 59 */
  r = xlang_proc_syscall3(59, (long)path, (long)argv, (long)envp);
#elif defined(__aarch64__)
  /* execve = 221 */
  r = xlang_proc_syscall3(221, (long)path, (long)argv, (long)envp);
#endif
  (void)r;
  return -1;
}

/**
 * Cap residual wait4 → waitpid(pid, status, options) semantics (rusage ignored).
 * @return pid on success, -1 on failure
 * PLATFORM: LINUX
 */
static inline long xlang_proc_waitpid(long pid, int *status, int options) {
#if defined(__x86_64__)
  /* wait4 = 61 */
  return xlang_proc_syscall6(61, pid, (long)status, (long)options, 0, 0, 0);
#elif defined(__aarch64__)
  /* wait4 = 260 */
  return xlang_proc_syscall6(260, pid, (long)status, (long)options, 0, 0, 0);
#endif
}

/**
 * Cap residual _exit(2) / exit_group — never returns.
 * PLATFORM: LINUX
 */
static inline void xlang_proc_exit(int code) {
#if defined(__x86_64__)
  /* exit_group = 231 */
  (void)xlang_proc_syscall1(231, (long)code);
#elif defined(__aarch64__)
  /* exit_group = 94 */
  (void)xlang_proc_syscall1(94, (long)code);
#endif
  for (;;) {
  }
}

/**
 * Cap residual dup2(oldfd, newfd).
 * @return newfd on success, -1 on failure
 * PLATFORM: LINUX
 */
static inline int xlang_proc_dup2(int oldfd, int newfd) {
  long r;
#if defined(__x86_64__)
  /* dup2 = 33 */
  r = xlang_proc_syscall3(33, (long)oldfd, (long)newfd, 0);
#elif defined(__aarch64__)
  /* dup3 = 24, flags=0 */
  r = xlang_proc_syscall3(24, (long)oldfd, (long)newfd, 0);
#endif
  return (r < 0) ? -1 : (int)r;
}

#include <string.h>
#include <xlang_environ_cap.h>

/**
 * Cap residual execvp: PATH search then execve (no libc execvp/execlp).
 * @param file program name or path
 * @param argv NULL-terminated argv (argv[0] conventionally = file)
 * @return -1 on failure (does not return on success)
 * PLATFORM: LINUX — uses environ walk for PATH (9.1.1).
 */
static inline int xlang_proc_execvp(const char *file, char *const argv[]) {
  char buf[4096];
  const char *path;
  const char *p;
  const char *q;
  size_t flen;
  size_t dlen;
  extern char **environ;
  if (!file || !file[0])
    return -1;
  if (strchr(file, '/')) {
    (void)xlang_proc_execve(file, argv, environ);
    return -1;
  }
  path = xlang_environ_getenv("PATH");
  if (!path || !path[0])
    path = "/bin:/usr/bin";
  flen = strlen(file);
  p = path;
  for (;;) {
    q = p;
    while (*q && *q != ':')
      q++;
    dlen = (size_t)(q - p);
    if (dlen + 1 + flen + 1 <= sizeof(buf)) {
      if (dlen == 0) {
        memcpy(buf, file, flen + 1);
      } else {
        memcpy(buf, p, dlen);
        buf[dlen] = '/';
        memcpy(buf + dlen + 1, file, flen + 1);
      }
      (void)xlang_proc_execve(buf, argv, environ);
    }
    if (*q != ':')
      break;
    p = q + 1;
  }
  return -1;
}

/** Linux EINTR raw errno value for wait4 retry loops. */
#ifndef EINTR
#define EINTR 4
#endif

#endif /* __linux__ && (x86_64|aarch64) */

#endif /* XLANG_PROCESS_CAP_H */
