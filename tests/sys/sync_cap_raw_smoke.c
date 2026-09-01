/*
 * sync_cap_raw_smoke.c — Stage 10 (10.6.3) Cap residual probe.
 *
 * Host-cc smoke for xlang_sync_cap.h:
 *   slice0: mutex init/lock/trylock/unlock + Cap-spawn contention
 *   slice1: condvar wait/signal (producer/consumer)
 *
 * PLATFORM: LINUX|x86_64|aarch64 gold.
 *
 * Build (gate): cc -O0 -Icompiler/include -o /tmp/... tests/sys/sync_cap_raw_smoke.c
 * Exit: 0 ok; 1..12 step failure.
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
 * Cap residual 10.6.3 probe entry (mutex + condvar).
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

  return 0;
}

#endif /* __linux__ */
