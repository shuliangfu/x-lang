/* generated from lsp_io_std_heap */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/* wave245 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED orch / host getenv residual via single face.
 * Compiler-only gen seed pin (CRASH_EVIDENCE inline) — not user program template
 * (runtime.from_x.c fprintf CRASH_EVIDENCE templates stay raw getenv for user C). */
extern char *link_abi_getenv(const char *name);
extern int getpid(void);
static inline void xlang_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = link_abi_getenv("XLANG_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "xlang: [XLANG_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = link_abi_getenv("XLANG_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/xlang-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "xlang: [XLANG_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void xlang_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void xlang_panic_(int has_msg, int msg_val) {
  xlang_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
/* PLATFORM: SHARED — do NOT redeclare malloc/free/calloc after <stdlib.h>.
 * Linux/glibc: void* prototypes; uint8_t* redecls are conflicting types and
 * fail seed cc -c. Bodies call libc via the standard headers above. */
uint8_t * lsp_io_std_heap_std_heap_alloc(size_t size);
uint8_t * lsp_io_std_heap_std_heap_alloc_zeroed(size_t size);
void lsp_io_std_heap_std_heap_free(uint8_t * ptr);
uint8_t * lsp_io_std_heap_std_heap_alloc(size_t size) {
  (void)(({ uint8_t * __tmp = 0; if (size == ((size_t)(0))) {   return ((uint8_t *)(0));
 } else (__tmp = 0) ; __tmp; }));
  return malloc(size);
}
uint8_t * lsp_io_std_heap_std_heap_alloc_zeroed(size_t size) {
  (void)(({ uint8_t * __tmp = 0; if (size == ((size_t)(0))) {   return ((uint8_t *)(0));
 } else (__tmp = 0) ; __tmp; }));
  return calloc(((size_t)(1)), size);
}
void lsp_io_std_heap_std_heap_free(uint8_t * ptr) {
  (void)(({ int32_t __tmp = 0; if (ptr == ((uint8_t *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(free(ptr));
}
