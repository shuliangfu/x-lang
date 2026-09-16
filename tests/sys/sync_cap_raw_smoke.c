/*
 * sync_cap_raw_smoke.c — Stage 10 (10.6.3) Cap residual probe.
 *
 * Host-cc smoke for xlang_sync_cap.h:
 *   slice0: mutex init/lock/trylock/unlock + Cap-spawn contention
 *   slice1: condvar wait/signal (producer/consumer)
 *   slice2: semaphore wait/trywait/post
 *   slice4: rwlock rd/wr + Cap-spawn writer contention
 *
 * PLATFORM: LINUX|x86_64|aarch64 gold.
 *
 * Build (gate): cc -O0 -Icompiler/include -o /tmp/... tests/sys/sync_cap_raw_smoke.c
 * Exit: 0 ok; 1..16 step failure.
 */

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <xlang_sync_cap.h>

#ifndef __linux__
int main(void) {
  fprintf(stderr, "sync_cap_raw_smoke: Linux only\n");
  return 0;
}
#else

/** Shared mutex + counter for Cap concurrent smoke. */
static struct xlang_cap_mutex g_mu;
static volatile int g_counter = 0;

/** Condvar handshake: child parks until parent sets ready=1 and signals. */
static struct xlang_cap_mutex g_cv_mu;
static struct xlang_cap_cond g_cv;
static volatile int g_waiting = 0;
static volatile int g_ready = 0;
static volatile int g_seen = 0;

/** Semaphore Cap-spawn handshake. */
static struct xlang_cap_sem *g_sem = 0;
static volatile int g_sem_got = 0;

/** RwLock Cap-spawn writer contention. */
static struct xlang_cap_rwlock g_rw;
static volatile int g_rw_counter = 0;

/**
 * Cap child: lock, increment counter, unlock.
 * @param arg unused
 * @return NULL
 * PLATFORM: LINUX
 */
static void *sync_cap_child(void *arg) {
  int i = 0;
  (void)arg;
  for (i = 0; i < 1000; i++) {
    if (xlang_cap_mutex_lock(&g_mu) != 0) {
      return 0;
    }
    g_counter = g_counter + 1;
    (void)xlang_cap_mutex_unlock(&g_mu);
  }
  return 0;
}

/**
 * Cap child: announce waiting, then wait on condvar until g_ready.
 * @param arg unused
 * @return NULL
 * PLATFORM: LINUX
 */
static void *sync_cap_waiter(void *arg) {
  (void)arg;
  if (xlang_cap_mutex_lock(&g_cv_mu) != 0) {
    return 0;
  }
  g_waiting = 1;
  while (g_ready == 0) {
    if (xlang_cap_cond_wait(&g_cv, &g_cv_mu) != 0) {
      (void)xlang_cap_mutex_unlock(&g_cv_mu);
      return 0;
    }
  }
  g_seen = 1;
  (void)xlang_cap_mutex_unlock(&g_cv_mu);
  return 0;
}

/**
 * Cap child: block on semaphore wait, then set g_sem_got.
 * @param arg unused
 * @return NULL
 * PLATFORM: LINUX
 */
static void *sync_cap_sem_waiter(void *arg) {
  (void)arg;
  if (g_sem == 0) {
    return 0;
  }
  if (xlang_cap_sem_wait(g_sem) != 0) {
    return 0;
  }
  g_sem_got = 1;
  return 0;
}

/**
 * Cap child: wrlock, increment shared counter, wrunlock (1000×).
 * @param arg unused
 * @return NULL
 * PLATFORM: LINUX
 */
static void *sync_cap_rw_writer(void *arg) {
  int i = 0;
  (void)arg;
  for (i = 0; i < 1000; i++) {
    if (xlang_cap_rwlock_wrlock(&g_rw) != 0) {
      return 0;
    }
    g_rw_counter = g_rw_counter + 1;
    (void)xlang_cap_rwlock_wrunlock(&g_rw);
  }
  return 0;
}

/**
 * Cap residual 10.6.3 probe entry (mutex + condvar + semaphore + rwlock).
 * @return 0 ok; nonzero step id on failure
 * PLATFORM: LINUX
 */
int main(void) {
  struct xlang_cap_mutex m;
  struct xlang_thread_join join;
  int i = 0;

  /* Step1: init / lock / unlock / destroy. */
  if (xlang_cap_mutex_init(&m) != 0) {
    fprintf(stderr, "mutex_init failed errno=%d\n", errno);
    return 1;
  }
  if (xlang_cap_mutex_lock(&m) != 0) {
    fprintf(stderr, "mutex_lock failed errno=%d\n", errno);
    return 2;
  }
  if (xlang_cap_mutex_trylock(&m) == 0) {
    fprintf(stderr, "trylock unexpectedly succeeded\n");
    return 3;
  }
  if (errno != EBUSY) {
    fprintf(stderr, "trylock errno=%d want EBUSY\n", errno);
    return 4;
  }
  if (xlang_cap_mutex_unlock(&m) != 0) {
    fprintf(stderr, "mutex_unlock failed errno=%d\n", errno);
    return 5;
  }
  if (xlang_cap_mutex_trylock(&m) != 0) {
    fprintf(stderr, "trylock after unlock failed errno=%d\n", errno);
    return 6;
  }
  (void)xlang_cap_mutex_unlock(&m);
  (void)xlang_cap_mutex_destroy(&m);

  /* Step2: two threads (parent loop + Cap spawn) under Cap mutex. */
  if (xlang_cap_mutex_init(&g_mu) != 0) {
    fprintf(stderr, "g_mu init failed\n");
    return 7;
  }
  g_counter = 0;
  memset(&join, 0, sizeof(join));
  if (xlang_thread_spawn(sync_cap_child, 0, &join, 65536u) != 0) {
    fprintf(stderr, "spawn failed errno=%d\n", errno);
    return 8;
  }
  for (i = 0; i < 1000; i++) {
    if (xlang_cap_mutex_lock(&g_mu) != 0) {
      fprintf(stderr, "parent lock failed\n");
      return 8;
    }
    g_counter = g_counter + 1;
    (void)xlang_cap_mutex_unlock(&g_mu);
  }
  if (xlang_thread_join(&join) != 0) {
    fprintf(stderr, "join failed errno=%d\n", errno);
    return 8;
  }
  if (g_counter != 2000) {
    fprintf(stderr, "counter=%d want 2000\n", g_counter);
    return 9;
  }
  (void)xlang_cap_mutex_destroy(&g_mu);

  /* Step3: condvar wait/signal handshake. */
  if (xlang_cap_mutex_init(&g_cv_mu) != 0 || xlang_cap_cond_init(&g_cv) != 0) {
    fprintf(stderr, "cv init failed\n");
    return 10;
  }
  g_waiting = 0;
  g_ready = 0;
  g_seen = 0;
  memset(&join, 0, sizeof(join));
  if (xlang_thread_spawn(sync_cap_waiter, 0, &join, 65536u) != 0) {
    fprintf(stderr, "waiter spawn failed errno=%d\n", errno);
    return 11;
  }
  /* Wait until child announced it holds the lock and will wait. */
  for (;;) {
    if (xlang_cap_mutex_lock(&g_cv_mu) != 0) {
      fprintf(stderr, "cv parent lock failed\n");
      return 11;
    }
    if (g_waiting != 0) {
      break;
    }
    (void)xlang_cap_mutex_unlock(&g_cv_mu);
  }
  g_ready = 1;
  if (xlang_cap_cond_signal(&g_cv) != 0) {
    fprintf(stderr, "cond_signal failed errno=%d\n", errno);
    (void)xlang_cap_mutex_unlock(&g_cv_mu);
    return 11;
  }
  (void)xlang_cap_mutex_unlock(&g_cv_mu);
  if (xlang_thread_join(&join) != 0) {
    fprintf(stderr, "waiter join failed errno=%d\n", errno);
    return 11;
  }
  if (g_seen != 1) {
    fprintf(stderr, "g_seen=%d want 1\n", g_seen);
    return 12;
  }
  (void)xlang_cap_cond_destroy(&g_cv);
  (void)xlang_cap_mutex_destroy(&g_cv_mu);

  /* Step4: semaphore trywait / wait / post + Cap-spawn consumer. */
  {
    struct xlang_cap_sem sem;
    struct xlang_thread_join sjoin;
    if (xlang_cap_sem_init(&sem, 0) != 0) {
      fprintf(stderr, "sem_init failed\n");
      return 13;
    }
    if (xlang_cap_sem_trywait(&sem) == 0) {
      fprintf(stderr, "trywait on 0 unexpectedly ok\n");
      return 14;
    }
    if (errno != EAGAIN) {
      fprintf(stderr, "trywait errno=%d want EAGAIN\n", errno);
      return 14;
    }
    g_sem = &sem;
    g_sem_got = 0;
    memset(&sjoin, 0, sizeof(sjoin));
    if (xlang_thread_spawn(sync_cap_sem_waiter, 0, &sjoin, 65536u) != 0) {
      fprintf(stderr, "sem waiter spawn failed errno=%d\n", errno);
      return 15;
    }
    /* Brief spin so child reaches wait; post wakes it. */
    for (i = 0; i < 100000 && g_sem_got == 0; i++) {
    }
    if (xlang_cap_sem_post(&sem) != 0) {
      fprintf(stderr, "sem_post failed errno=%d\n", errno);
      return 15;
    }
    if (xlang_thread_join(&sjoin) != 0) {
      fprintf(stderr, "sem join failed errno=%d\n", errno);
      return 15;
    }
    if (g_sem_got != 1) {
      fprintf(stderr, "g_sem_got=%d want 1\n", g_sem_got);
      return 16;
    }
    if (xlang_cap_sem_post(&sem) != 0 || xlang_cap_sem_trywait(&sem) != 0) {
      fprintf(stderr, "sem post/trywait roundtrip failed\n");
      return 16;
    }
    (void)xlang_cap_sem_destroy(&sem);
    g_sem = 0;
  }

  /* Step5: rwlock rd/wr + Cap-spawn writer contention. */
  {
    struct xlang_cap_rwlock rw;
    struct xlang_thread_join rjoin;
    if (xlang_cap_rwlock_init(&rw) != 0) {
      fprintf(stderr, "rwlock_init failed\n");
      return 17;
    }
    if (xlang_cap_rwlock_rdlock(&rw) != 0) {
      fprintf(stderr, "rdlock failed errno=%d\n", errno);
      return 17;
    }
    if (xlang_cap_rwlock_rdlock(&rw) != 0) {
      fprintf(stderr, "second rdlock failed errno=%d\n", errno);
      return 17;
    }
    (void)xlang_cap_rwlock_rdunlock(&rw);
    (void)xlang_cap_rwlock_rdunlock(&rw);
    if (xlang_cap_rwlock_wrlock(&rw) != 0) {
      fprintf(stderr, "wrlock failed errno=%d\n", errno);
      return 18;
    }
    (void)xlang_cap_rwlock_wrunlock(&rw);
    (void)xlang_cap_rwlock_destroy(&rw);

    if (xlang_cap_rwlock_init(&g_rw) != 0) {
      fprintf(stderr, "g_rw init failed\n");
      return 19;
    }
    g_rw_counter = 0;
    memset(&rjoin, 0, sizeof(rjoin));
    if (xlang_thread_spawn(sync_cap_rw_writer, 0, &rjoin, 65536u) != 0) {
      fprintf(stderr, "rw writer spawn failed errno=%d\n", errno);
      return 19;
    }
    for (i = 0; i < 1000; i++) {
      if (xlang_cap_rwlock_wrlock(&g_rw) != 0) {
        fprintf(stderr, "parent wrlock failed\n");
        return 19;
      }
      g_rw_counter = g_rw_counter + 1;
      (void)xlang_cap_rwlock_wrunlock(&g_rw);
    }
    if (xlang_thread_join(&rjoin) != 0) {
      fprintf(stderr, "rw join failed errno=%d\n", errno);
      return 19;
    }
    if (g_rw_counter != 2000) {
      fprintf(stderr, "g_rw_counter=%d want 2000\n", g_rw_counter);
      return 20;
    }
    (void)xlang_cap_rwlock_destroy(&g_rw);
  }

  return 0;
}

#endif /* __linux__ */
