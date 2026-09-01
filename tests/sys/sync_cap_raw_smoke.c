/*
 * sync_cap_raw_smoke.c — Stage 10 (10.6.3) slice0 Cap residual probe.
 *
 * Host-cc smoke for xlang_sync_cap.h: mutex init/lock/trylock/unlock +
 * Cap-spawn concurrent lock (no libpthread).
 *
 * PLATFORM: LINUX|x86_64|aarch64 gold.
 *
 * Build (gate): cc -O0 -Icompiler/include -o /tmp/... tests/sys/sync_cap_raw_smoke.c
 * Exit: 0 ok; 1..9 step failure.
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
 * Cap residual 10.6.3 slice0 probe entry.
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

  return 0;
}

#endif /* __linux__ */
