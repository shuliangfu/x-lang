/*
 * xlang_sync_cap.h — Cap residual 10.6.3: Linux futex sync without libpthread
 * (x86_64 + aarch64).
 *
 * G.7: single authority for Cap sync primitives. Builds on xlang_thread_cap.h
 * futex faces only — no pthread_mutex_* / pthread_cond_* on the Cap path.
 *
 * Slice0: non-recursive mutex (init/lock/trylock/unlock).
 * Slice1: condition variable (init/wait/signal/broadcast).
 * Later: semaphore · wire runtime_sync_os _impl · Windows (10.6.2).
 *
 * Windows / Darwin: not provided — callers keep OS mutex/cond APIs.
 *
 * PLATFORM: LINUX primary (x86_64 + aarch64).
 */

#ifndef XLANG_SYNC_CAP_H
#define XLANG_SYNC_CAP_H

#if defined(__linux__) && (defined(__x86_64__) || defined(__aarch64__))

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

#include <xlang_thread_cap.h>

/** Unlocked. */
#define XLANG_CAP_MUTEX_UNLOCKED 0u
/** Locked (may have waiters). */
#define XLANG_CAP_MUTEX_LOCKED 1u

/**
 * Cap futex mutex — single aligned u32 word (non-recursive).
 * PLATFORM: LINUX
 */
struct xlang_cap_mutex {
  uint32_t state;
};

/**
 * Initialize Cap mutex to unlocked.
 * @param m mutex (must be non-null, 4-byte aligned)
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_mutex_init(struct xlang_cap_mutex *m) {
  if (m == 0) {
    errno = EINVAL;
    return -1;
  }
  m->state = XLANG_CAP_MUTEX_UNLOCKED;
  return 0;
}

/**
 * Destroy Cap mutex (no heap; clears state).
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_mutex_destroy(struct xlang_cap_mutex *m) {
  if (m == 0) {
    errno = EINVAL;
    return -1;
  }
  m->state = XLANG_CAP_MUTEX_UNLOCKED;
  return 0;
}

/**
 * Acquire Cap mutex (block via futex while locked).
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_mutex_lock(struct xlang_cap_mutex *m) {
  uint32_t expected = XLANG_CAP_MUTEX_UNLOCKED;
  if (m == 0) {
    errno = EINVAL;
    return -1;
  }
  for (;;) {
    expected = XLANG_CAP_MUTEX_UNLOCKED;
    if (__atomic_compare_exchange_n(&m->state, &expected, XLANG_CAP_MUTEX_LOCKED, 0,
                                    __ATOMIC_ACQUIRE, __ATOMIC_RELAXED)) {
      return 0;
    }
    /* state is LOCKED — sleep until unlock wakes. */
    (void)xlang_futex(&m->state, XLANG_FUTEX_WAIT, XLANG_CAP_MUTEX_LOCKED, 0);
  }
}

/**
 * Try to acquire Cap mutex without blocking.
 * @return 0 acquired; -1 with errno=EBUSY if held; -1 EINVAL if m null
 * PLATFORM: LINUX
 */
static inline int xlang_cap_mutex_trylock(struct xlang_cap_mutex *m) {
  uint32_t expected = XLANG_CAP_MUTEX_UNLOCKED;
  if (m == 0) {
    errno = EINVAL;
    return -1;
  }
  if (__atomic_compare_exchange_n(&m->state, &expected, XLANG_CAP_MUTEX_LOCKED, 0,
                                  __ATOMIC_ACQUIRE, __ATOMIC_RELAXED)) {
    return 0;
  }
  errno = EBUSY;
  return -1;
}

/**
 * Release Cap mutex and wake one waiter.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_mutex_unlock(struct xlang_cap_mutex *m) {
  if (m == 0) {
    errno = EINVAL;
    return -1;
  }
  __atomic_store_n(&m->state, XLANG_CAP_MUTEX_UNLOCKED, __ATOMIC_RELEASE);
  (void)xlang_futex_wake(&m->state, 1);
  return 0;
}

/**
 * Cap futex condvar — sequence word (waiters sleep on seq).
 * PLATFORM: LINUX
 */
struct xlang_cap_cond {
  uint32_t seq;
};

/**
 * Initialize Cap condvar.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_cond_init(struct xlang_cap_cond *cv) {
  if (cv == 0) {
    errno = EINVAL;
    return -1;
  }
  cv->seq = 0;
  return 0;
}

/**
 * Destroy Cap condvar (no heap).
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_cond_destroy(struct xlang_cap_cond *cv) {
  if (cv == 0) {
    errno = EINVAL;
    return -1;
  }
  cv->seq = 0;
  return 0;
}

/**
 * Wait on Cap condvar: atomically unlock m, sleep until signal/broadcast, relock.
 * Caller must hold m. Spurious wakes possible — recheck predicate.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_cond_wait(struct xlang_cap_cond *cv, struct xlang_cap_mutex *m) {
  uint32_t seq = 0;
  if (cv == 0 || m == 0) {
    errno = EINVAL;
    return -1;
  }
  seq = __atomic_load_n(&cv->seq, __ATOMIC_ACQUIRE);
  if (xlang_cap_mutex_unlock(m) != 0) {
    return -1;
  }
  (void)xlang_futex(&cv->seq, XLANG_FUTEX_WAIT, seq, 0);
  if (xlang_cap_mutex_lock(m) != 0) {
    return -1;
  }
  return 0;
}

/**
 * Wake one Cap condvar waiter.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_cond_signal(struct xlang_cap_cond *cv) {
  if (cv == 0) {
    errno = EINVAL;
    return -1;
  }
  (void)__atomic_fetch_add(&cv->seq, 1u, __ATOMIC_RELEASE);
  (void)xlang_futex_wake(&cv->seq, 1);
  return 0;
}

/**
 * Wake all Cap condvar waiters.
 * @return 0 ok; -1 with errno
 * PLATFORM: LINUX
 */
static inline int xlang_cap_cond_broadcast(struct xlang_cap_cond *cv) {
  if (cv == 0) {
    errno = EINVAL;
    return -1;
  }
  (void)__atomic_fetch_add(&cv->seq, 1u, __ATOMIC_RELEASE);
  (void)xlang_futex_wake(&cv->seq, 0x7fffffff);
  return 0;
}

#endif /* LINUX x86_64|aarch64 */

#endif /* XLANG_SYNC_CAP_H */
