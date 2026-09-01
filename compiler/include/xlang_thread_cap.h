/*
 * xlang_thread_cap.h — Cap residual 10.6.1: Linux futex + mmap stack + clone
 * without libpthread (x86_64 + aarch64).
 *
 * G.7: single authority for thread-primitive Cap faces. Uses xlang_syscall_cap.h
 * only — no libc futex/mmap/pthread wrappers on the Cap path.
 *
 * Slice0: futex wait/wake + anonymous stack mmap/munmap.
 * Slice1: clone3 (fallback classic clone) + spawn/join via futex.
 * Later: product pthread face → Cap · Windows CreateThread (10.6.2).
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

/* clone flags (linux/sched.h) — Cap mirror; avoid pulling libc headers. */
#define XLANG_CLONE_VM 0x00000100u
#define XLANG_CLONE_FS 0x00000200u
#define XLANG_CLONE_FILES 0x00000400u
#define XLANG_CLONE_SIGHAND 0x00000800u
#define XLANG_CLONE_THREAD 0x00010000u
#define XLANG_CLONE_SYSVSEM 0x00040000u
#define XLANG_CLONE_PARENT_SETTID 0x00100000u
#define XLANG_CLONE_CHILD_CLEARTID 0x00200000u

/** Default pthread-like thread flags (no TLS). */
#define XLANG_CLONE_THREAD_FLAGS                                               \
  (XLANG_CLONE_VM | XLANG_CLONE_FS | XLANG_CLONE_FILES | XLANG_CLONE_SIGHAND |  \
   XLANG_CLONE_THREAD | XLANG_CLONE_SYSVSEM | XLANG_CLONE_PARENT_SETTID |      \
   XLANG_CLONE_CHILD_CLEARTID)

/**
 * Cap timespec twin (avoid pulling libc time.h layouts into Cap face).
 * PLATFORM: LINUX LP64 — matches kernel timespec.
 */
struct xlang_thread_timespec {
  long tv_sec;
  long tv_nsec;
};

/**
 * clone3 args VER0 (64 bytes) — mirrors linux/sched.h struct clone_args.
 * PLATFORM: LINUX
 */
struct xlang_clone_args {
  uint64_t flags;
  uint64_t pidfd;
  uint64_t child_tid;
  uint64_t parent_tid;
  uint64_t exit_signal;
  uint64_t stack;
  uint64_t stack_size;
  uint64_t tls;
};

/**
 * Join handle filled by xlang_thread_spawn; wait with xlang_thread_join.
 * PLATFORM: LINUX
 */
struct xlang_thread_join {
  uint32_t done; /* 0 running · 1 finished (futex word) */
  int child_tid; /* CLONE_CHILD_CLEARTID / PARENT_SETTID */
  void *stack;
  size_t stack_len;
};

/** Start routine for Cap spawn (pthread-compatible shape). */
typedef void *(*xlang_thread_start_fn)(void *arg);

/**
 * Pack living in shared VM for child after clone (bottom of stack mapping).
 * PLATFORM: LINUX
 */
struct xlang_thread_spawn_pack {
  xlang_thread_start_fn fn;
  void *arg;
  struct xlang_thread_join *join;
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

/**
 * Thread-local exit (SYS_exit) — does not return.
 * PLATFORM: LINUX — use for Cap clone children (not exit_group).
 */
static inline void xlang_thread_exit(long code) {
  long nr;
#if defined(__x86_64__)
  nr = 60; /* SYS_exit */
#elif defined(__aarch64__)
  nr = 93; /* SYS_exit */
#endif
  (void)xlang_syscall1(nr, code);
  for (;;) {
  }
}

/**
 * Raw clone3(2). Returns tid in parent, 0 in child, -1 with errno on failure.
 * @param args VER0 clone_args (64 bytes)
 * @param size sizeof(*args) or CLONE_ARGS_SIZE_VER0
 * PLATFORM: LINUX
 */
static inline long xlang_clone3(struct xlang_clone_args *args, size_t size) {
  long r;
  long nr;
  if (args == 0 || size < 64) {
    errno = EINVAL;
    return -1;
  }
#if defined(__x86_64__)
  nr = 435; /* SYS_clone3 */
#elif defined(__aarch64__)
  nr = 435; /* SYS_clone3 */
#endif
  r = xlang_syscall2(nr, (long)args, (long)size);
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Classic clone(2) with pthread-like flags. stack_top = high address (grows down).
 * Returns tid in parent, 0 in child, -1 with errno.
 * PLATFORM: LINUX — x86_64 vs aarch64 arg order differs (kernel ABI).
 */
static inline long xlang_clone(unsigned long flags, void *stack_top, int *parent_tid,
                               int *child_tid, unsigned long tls) {
  long r;
#if defined(__x86_64__)
  /* clone = 56: flags, stack, parent_tid, child_tid, tls */
  r = xlang_syscall6(56, (long)flags, (long)stack_top, (long)parent_tid, (long)child_tid,
                     (long)tls, 0);
#elif defined(__aarch64__)
  /* clone = 220: flags, stack, parent_tid, tls, child_tid */
  r = xlang_syscall6(220, (long)flags, (long)stack_top, (long)parent_tid, (long)tls,
                     (long)child_tid, 0);
#endif
  if (r < 0) {
    errno = (int)(-r);
    return -1;
  }
  return r;
}

/**
 * Spawn fn(arg) on a Cap-mapped stack (clone3, ENOSYS → classic clone).
 * join must be zero-initialized; owns stack until xlang_thread_join.
 * @return 0 parent ok; -1 with errno (never returns in child)
 * PLATFORM: LINUX
 */
static inline int xlang_thread_spawn(xlang_thread_start_fn fn, void *arg,
                                     struct xlang_thread_join *join, size_t stack_len) {
  void *stack = 0;
  struct xlang_thread_spawn_pack *pack = 0;
  struct xlang_clone_args ca;
  unsigned char *base = 0;
  size_t pack_off = 0;
  size_t usable = 0;
  void *stack_top = 0;
  long r = 0;
  unsigned long flags = (unsigned long)XLANG_CLONE_THREAD_FLAGS;

  if (fn == 0 || join == 0 || stack_len < 16384u) {
    errno = EINVAL;
    return -1;
  }

  join->done = 0;
  join->child_tid = 0;
  join->stack = 0;
  join->stack_len = 0;

  stack = xlang_thread_mmap_stack(stack_len);
  if (stack == 0) {
    return -1;
  }

  /* Reserve pack at low end of mapping (shared VM; clone3 stack = low+size). */
  base = (unsigned char *)stack;
  pack_off = (sizeof(struct xlang_thread_spawn_pack) + 15u) & ~(size_t)15u;
  if (pack_off + 4096u > stack_len) {
    (void)xlang_thread_munmap_stack(stack, stack_len);
    errno = EINVAL;
    return -1;
  }
  pack = (struct xlang_thread_spawn_pack *)(void *)base;
  pack->fn = fn;
  pack->arg = arg;
  pack->join = join;
  usable = stack_len - pack_off;

  ca.flags = (uint64_t)flags;
  ca.pidfd = 0;
  ca.child_tid = (uint64_t)(uintptr_t)&join->child_tid;
  ca.parent_tid = (uint64_t)(uintptr_t)&join->child_tid;
  ca.exit_signal = 0;
  ca.stack = (uint64_t)(uintptr_t)(base + pack_off);
  ca.stack_size = (uint64_t)usable;
  ca.tls = 0;

  r = xlang_clone3(&ca, sizeof(ca));
  if (r < 0 && errno == ENOSYS) {
    /* Fallback: classic clone — stack_top = high end, 16-byte aligned. */
    stack_top = (void *)(((uintptr_t)(base + stack_len)) & ~(uintptr_t)15u);
    r = xlang_clone(flags, stack_top, &join->child_tid, &join->child_tid, 0);
  }
  if (r < 0) {
    (void)xlang_thread_munmap_stack(stack, stack_len);
    return -1;
  }

  if (r == 0) {
    /* Child: pack lives at mapping base (CLONE_VM). */
    xlang_thread_start_fn child_fn = pack->fn;
    void *child_arg = pack->arg;
    struct xlang_thread_join *child_join = pack->join;
    (void)child_fn(child_arg);
    child_join->done = 1;
    (void)xlang_futex_wake(&child_join->done, 1);
    xlang_thread_exit(0);
  }

  /* Parent */
  join->stack = stack;
  join->stack_len = stack_len;
  return 0;
}

/**
 * Wait for Cap-spawned thread, then munmap its stack.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_thread_join(struct xlang_thread_join *join) {
  if (join == 0) {
    errno = EINVAL;
    return -1;
  }
  while (join->done == 0) {
    (void)xlang_futex_wait_timeout_ns(&join->done, 0, 0);
  }
  /* CLONE_CHILD_CLEARTID: kernel stores 0 and futex-wakes child_tid on exit. */
  while (join->child_tid != 0) {
    uint32_t expect = (uint32_t)join->child_tid;
    (void)xlang_futex((uint32_t *)(void *)&join->child_tid, XLANG_FUTEX_WAIT, expect, 0);
  }
  if (join->stack != 0 && join->stack_len != 0) {
    if (xlang_thread_munmap_stack(join->stack, join->stack_len) != 0) {
      return -1;
    }
    join->stack = 0;
    join->stack_len = 0;
  }
  return 0;
}

#endif /* LINUX x86_64|aarch64 */

#endif /* XLANG_THREAD_CAP_H */
