/*
 * xlang_thread_cap.h — Cap residual 10.6.1 slice0: Linux futex + mmap stack
 * without libpthread (x86_64 + aarch64).
 *
 * G.7: single authority for thread-primitive Cap faces. Uses xlang_syscall_cap.h
 * only — no libc futex/mmap wrappers on the Cap path.
 *
 * Slice0: futex wait/wake + anonymous stack mmap/munmap.
 * Later: clone/clone3 thread spawn (10.6.1 slice1+) · Windows CreateThread (10.6.2).
 *
 * Windows / Darwin: not provided — callers keep OS thread APIs.
 *
 * PLATFORM: LINUX primary (x86_64 + aarch64).
 */

#ifndef XLANG_THREAD_CAP_H
#define XLANG_THREAD_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#include <xlang_syscall_cap.h>

/** FUTEX_WAIT — sleep while *uaddr == val. */
#define XLANG_FUTEX_WAIT 0
/** FUTEX_WAKE — wake up to n waiters. */
#define XLANG_FUTEX_WAKE 1

/** PROT_READ|PROT_WRITE */
#define XLANG_PROT_RW 3
/** MAP_PRIVATE|MAP_ANONYMOUS (Linux). */
#define XLANG_MAP_PRIV_ANON 0x22
/** MAP_STACK (Linux) — hint for thread stacks. */
#define XLANG_MAP_STACK 0x20000

/**
 * Cap timespec twin (avoid pulling libc time.h layouts into Cap face).
 * PLATFORM: LINUX LP64 — matches kernel timespec.
 */
struct xlang_thread_timespec {
  long tv_sec;
  long tv_nsec;
};

/**
 * Raw futex(2). Returns 0 on success; -1 with errno on failure.
 * @param uaddr word address (must be 4-byte aligned)
 * @param op XLANG_FUTEX_WAIT / XLANG_FUTEX_WAKE
 * @param val expected value (WAIT) or wake count (WAKE)
 * @param timeout NULL = forever (WAIT only); ignored for WAKE
 * PLATFORM: LINUX
 */
static inline long xlang_futex(uint32_t *uaddr, int op, uint32_t val,
                               const struct xlang_thread_timespec *timeout) {
  long r;
  long nr;
  if (uaddr == 0) {
    errno = EFAULT;
    return -1;
  }
#if defined(__x86_64__)
  nr = 202; /* SYS_futex */
#elif defined(__aarch64__)
  nr = 98; /* SYS_futex */
#endif
  /* futex(uaddr, op, val, timeout, uaddr2=NULL, val3=0) */
  r = xlang_syscall6(nr, (long)uaddr, (long)op, (long)val, (long)timeout, 0, 0);
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * FUTEX_WAIT with absolute-ish relative timeout in nanoseconds (best-effort).
 * timeout_ns <= 0 → wait forever.
 * @return 0 woken; -1 with errno (ETIMEDOUT / EAGAIN / …)
 * PLATFORM: LINUX
 */
static inline long xlang_futex_wait_timeout_ns(uint32_t *uaddr, uint32_t expected,
                                              int64_t timeout_ns) {
  struct xlang_thread_timespec ts;
  const struct xlang_thread_timespec *pto = 0;
  if (timeout_ns > 0) {
    ts.tv_sec = (long)(timeout_ns / 1000000000LL);
    ts.tv_nsec = (long)(timeout_ns % 1000000000LL);
    pto = &ts;
  }
  return xlang_futex(uaddr, XLANG_FUTEX_WAIT, expected, pto);
}

/**
 * FUTEX_WAKE — wake up to n waiters on *uaddr.
 * @return number woken (>=0); -1 with errno on failure
 * PLATFORM: LINUX
 */
static inline long xlang_futex_wake(uint32_t *uaddr, int n) {
  if (n < 0) {
    errno = EINVAL;
    return -1;
  }
  return xlang_futex(uaddr, XLANG_FUTEX_WAKE, (uint32_t)n, 0);
}

/**
 * Anonymous RW stack mapping (MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK).
 * @param len bytes (page-rounded by kernel)
 * @return mapped base or NULL with errno
 * PLATFORM: LINUX
 */
static inline void *xlang_thread_mmap_stack(size_t len) {
  long r;
  long nr;
  if (len == 0) {
    errno = EINVAL;
    return 0;
  }
#if defined(__x86_64__)
  nr = 9; /* SYS_mmap */
#elif defined(__aarch64__)
  nr = 222; /* SYS_mmap */
#endif
  r = xlang_syscall6(nr, 0, (long)len, (long)XLANG_PROT_RW,
                     (long)(XLANG_MAP_PRIV_ANON | XLANG_MAP_STACK), (long)-1, 0);
  if (r < 0) {
    errno = (int)(-r);
    return 0;
  }
  return (void *)r;
}

/**
 * Unmap a stack mapping from xlang_thread_mmap_stack.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline long xlang_thread_munmap_stack(void *addr, size_t len) {
  long r;
  long nr;
  if (addr == 0 || len == 0) {
    errno = EINVAL;
    return -1;
  }
#if defined(__x86_64__)
  nr = 11; /* SYS_munmap */
#elif defined(__aarch64__)
  nr = 215; /* SYS_munmap */
#endif
  r = xlang_syscall2(nr, (long)addr, (long)len);
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return 0;
}

#endif /* LINUX x86_64|aarch64 */

#endif /* XLANG_THREAD_CAP_H */
