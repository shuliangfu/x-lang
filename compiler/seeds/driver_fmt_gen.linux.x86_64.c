/* generated from driver */
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
extern int32_t driver_run_fmt(int32_t argc, uint8_t * argv);
int32_t driver_cmd_fmt(int32_t argc, uint8_t * argv);
int32_t driver_cmd_fmt(int32_t argc, uint8_t * argv) {
  return driver_run_fmt(argc, argv);
}
