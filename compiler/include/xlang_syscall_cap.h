/*
 * xlang_syscall_cap.h — Cap residual 9.1.9: single Linux inline-asm syscall
 * authority (x86_64 + aarch64).
 *
 * G.7: all Cap residual headers (path/io/net/process/time/random/dir/…) must use
 * these helpers instead of duplicating syscall/svc asm.
 *
 * Returns raw kernel return (negative -errno on failure). Callers map errno.
 *
 * Windows: not used.
 * Other POSIX: not provided — Cap faces keep libc thin wrappers.
 *
 * PLATFORM: LINUX primary (x86_64 + aarch64).
 */

#ifndef XLANG_SYSCALL_CAP_H
#define XLANG_SYSCALL_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

/**
 * Linux raw syscall ≤6 args. Returns -errno on failure (kernel convention).
 * PLATFORM: LINUX
 */
static inline long xlang_syscall6(long nr, long a1, long a2, long a3, long a4, long a5, long a6) {
  long r;
#if defined(__x86_64__)
  register long r10 __asm__("r10") = a4;
  register long r8 __asm__("r8") = a5;
  register long r9 __asm__("r9") = a6;
  __asm__ __volatile__("syscall"
                       : "=a"(r)
                       : "a"(nr), "D"(a1), "S"(a2), "d"(a3), "r"(r10), "r"(r8), "r"(r9)
                       : "rcx", "r11", "memory");
#elif defined(__aarch64__)
  register long x8 __asm__("x8") = nr;
  register long x0 __asm__("x0") = a1;
  register long x1 __asm__("x1") = a2;
  register long x2 __asm__("x2") = a3;
  register long x3 __asm__("x3") = a4;
  register long x4 __asm__("x4") = a5;
  register long x5 __asm__("x5") = a6;
  __asm__ __volatile__("svc #0"
                       : "+r"(x0)
                       : "r"(x8), "r"(x1), "r"(x2), "r"(x3), "r"(x4), "r"(x5)
                       : "memory");
  r = x0;
#endif
  return r;
}

/** PLATFORM: LINUX — syscall with 0 args. */
static inline long xlang_syscall0(long nr) {
  return xlang_syscall6(nr, 0, 0, 0, 0, 0, 0);
}

/** PLATFORM: LINUX — syscall with 1 arg. */
static inline long xlang_syscall1(long nr, long a1) {
  return xlang_syscall6(nr, a1, 0, 0, 0, 0, 0);
}

/** PLATFORM: LINUX — syscall with 2 args. */
static inline long xlang_syscall2(long nr, long a1, long a2) {
  return xlang_syscall6(nr, a1, a2, 0, 0, 0, 0);
}

/** PLATFORM: LINUX — syscall with 3 args. */
static inline long xlang_syscall3(long nr, long a1, long a2, long a3) {
  return xlang_syscall6(nr, a1, a2, a3, 0, 0, 0);
}

/** PLATFORM: LINUX — syscall with 4 args. */
static inline long xlang_syscall4(long nr, long a1, long a2, long a3, long a4) {
  return xlang_syscall6(nr, a1, a2, a3, a4, 0, 0);
}

/** PLATFORM: LINUX — syscall with 5 args. */
static inline long xlang_syscall5(long nr, long a1, long a2, long a3, long a4, long a5) {
  return xlang_syscall6(nr, a1, a2, a3, a4, a5, 0);
}

#endif /* LINUX x86_64|aarch64 */

#endif /* XLANG_SYSCALL_CAP_H */
