/* generated from typeck */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
extern int getpid(void);
static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = getenv("SHUX_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/shux-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
uint8_t * typeck_std_heap_alloc(size_t size);
uint8_t * typeck_std_heap_alloc_zeroed(size_t size);
void typeck_std_heap_free(uint8_t * ptr);
uint8_t * typeck_std_heap_alloc(size_t size) {
  (void)(({ uint8_t * __tmp = 0; if (size == ((size_t)(0))) {   return ((uint8_t *)(0));
 } else (__tmp = 0) ; __tmp; }));
  return malloc(size);
}
uint8_t * typeck_std_heap_alloc_zeroed(size_t size) {
  (void)(({ uint8_t * __tmp = 0; if (size == ((size_t)(0))) {   return ((uint8_t *)(0));
 } else (__tmp = 0) ; __tmp; }));
  return calloc(((size_t)(1)), size);
}
void typeck_std_heap_free(uint8_t * ptr) {
  (void)(({ int32_t __tmp = 0; if (ptr == ((uint8_t *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(free(ptr));
}
