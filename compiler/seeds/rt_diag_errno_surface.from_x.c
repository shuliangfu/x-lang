/* seeds/rt_diag_errno_surface.from_x.c
 * G-02f rt_diag_errno R2 full surface — isomorphic with src/runtime/rt_diag_errno.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_diag_errno.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (code_for_kind + errno family + cli_usage)
 * Regen: ./shux -E ... src/runtime/rt_diag_errno.x | filter DBG + polish prologue
 * Track-L (2026-07-16): helpers rt_diag_get_errno / rt_diag_ensure_codes / rt_diag_append
 * keep short names; .x has #[no_mangle] (was module-prefix mangle).
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t rt_diag_get_errno(void);
extern void rt_diag_ensure_codes(void);
extern int32_t rt_diag_append(uint8_t * dst, int32_t cap, uint8_t * src);
extern uint8_t * runtime_diag_code_for_kind(uint8_t * kind);
extern void runtime_diag_errno(uint8_t * file, uint8_t * kind, uint8_t * op);
extern void runtime_diag_errno_path(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * path);
extern void runtime_diag_errno_path_pair(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * from_path, uint8_t * to_path);
extern void runtime_diag_cli_usage_note(uint8_t * argv0);
static int32_t g_rt_diag_codes_ready;
static uint8_t * g_rt_diag_io001;
static uint8_t * g_rt_diag_prc001;
static uint8_t * g_rt_diag_bld001;
static void init_globals(void) {
  g_rt_diag_codes_ready = 0;
  g_rt_diag_io001 = ((uint8_t *)(0));
  g_rt_diag_prc001 = ((uint8_t *)(0));
  g_rt_diag_bld001 = ((uint8_t *)(0));
}
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern int32_t * __error(void);
int32_t rt_diag_get_errno(void) {
  int32_t * p = ((int32_t *)(0));
  {
    (void)((p = __error()));
  }
  if ((p ==((int32_t *)(0)))) {
    return 0;
  }
  return (p)[0];
}
void rt_diag_ensure_codes(void) {
  uint8_t * p = ((uint8_t *)(0));
  if ((g_rt_diag_codes_ready !=0)) {
    return;
  }
  {
    (void)((p = malloc(((size_t)(8)))));
  }
  if ((p !=((uint8_t *)(0)))) {
    (void)(((p)[0] = 73));
    (void)(((p)[1] = 79));
    (void)(((p)[2] = 48));
    (void)(((p)[3] = 48));
    (void)(((p)[4] = 49));
    (void)(((p)[5] = 0));
    (void)((g_rt_diag_io001 = p));
  }
  {
    (void)((p = malloc(((size_t)(8)))));
  }
  if ((p !=((uint8_t *)(0)))) {
    (void)(((p)[0] = 80));
    (void)(((p)[1] = 82));
    (void)(((p)[2] = 67));
    (void)(((p)[3] = 48));
    (void)(((p)[4] = 48));
    (void)(((p)[5] = 49));
    (void)(((p)[6] = 0));
    (void)((g_rt_diag_prc001 = p));
  }
  {
    (void)((p = malloc(((size_t)(8)))));
  }
  if ((p !=((uint8_t *)(0)))) {
    (void)(((p)[0] = 66));
    (void)(((p)[1] = 76));
    (void)(((p)[2] = 68));
    (void)(((p)[3] = 48));
    (void)(((p)[4] = 48));
    (void)(((p)[5] = 49));
    (void)(((p)[6] = 0));
    (void)((g_rt_diag_bld001 = p));
  }
  (void)((g_rt_diag_codes_ready = 1));
}
int32_t rt_diag_append(uint8_t * dst, int32_t cap, uint8_t * src) {
  int32_t i = 0;
  int32_t j = 0;
  if ((dst ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((src ==((uint8_t *)(0)))) {
    while ((i < cap)) {
      if (((dst)[((size_t)(i))] ==0)) {
        return i;
      }
      (void)((i = (i + 1)));
    }
    return 0;
  }
  while ((i < cap)) {
    if (((dst)[((size_t)(i))] ==0)) {
      break;
    }
    (void)((i = (i + 1)));
  }
  if ((i >=cap)) {
    (void)(((dst)[((size_t)((cap - 1)))] = 0));
    return (cap - 1);
  }
  (void)((j = 0));
  while (((i + 1) < cap)) {
    uint8_t c = (src)[((size_t)(j))];
    if ((c ==0)) {
      break;
    }
    (void)(((dst)[((size_t)(i))] = c));
    (void)((i = (i + 1)));
    (void)((j = (j + 1)));
  }
  (void)(((dst)[((size_t)(i))] = 0));
  return i;
}
uint8_t * runtime_diag_code_for_kind(uint8_t * kind) {
  (void)(rt_diag_ensure_codes());
  if ((kind ==((uint8_t *)(0)))) {
    return g_rt_diag_bld001;
  }
  {
    if ((strcmp(kind, (uint8_t[]){105, 111, 32, 101, 114, 114, 111, 114, 0 }) ==0)) {
      return g_rt_diag_io001;
    }
    if ((strcmp(kind, (uint8_t[]){112, 114, 111, 99, 101, 115, 115, 32, 101, 114, 114, 111, 114, 0 }) ==0)) {
      return g_rt_diag_prc001;
    }
    if ((strcmp(kind, (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }) ==0)) {
      return g_rt_diag_bld001;
    }
  }
  return ((uint8_t *)(0));
}
void runtime_diag_errno(uint8_t * file, uint8_t * kind, uint8_t * op) {
  int32_t saved = 0;
  uint8_t * err = ((uint8_t *)(0));
  uint8_t * rk = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  uint8_t msg[256] = {};
  uint8_t * s = ((uint8_t *)(0));
  (void)((saved = rt_diag_get_errno()));
  {
    (void)((err = strerror(saved)));
  }
  if ((err ==((uint8_t *)(0)))) {
    (void)((err = (uint8_t[]){117, 110, 107, 110, 111, 119, 110, 32, 101, 114, 114, 111, 114, 0 }));
  }
  if ((kind !=((uint8_t *)(0)))) {
    (void)((rk = kind));
  } else {
    (void)((rk = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  }
  (void)((code = runtime_diag_code_for_kind(rk)));
  if ((op !=((uint8_t *)(0)))) {
    (void)((s = op));
  } else {
    (void)((s = (uint8_t[]){115, 121, 115, 116, 101, 109, 32, 99, 97, 108, 108, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(rt_diag_append(&((msg)[0]), 256, s));
  (void)(rt_diag_append(&((msg)[0]), 256, (uint8_t[]){32, 102, 97, 105, 108, 101, 100, 58, 32, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 256, err));
  {
    (void)(diag_report_with_code(file, 0, 0, rk, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void runtime_diag_errno_path(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * path) {
  int32_t saved = 0;
  uint8_t * err = ((uint8_t *)(0));
  uint8_t * rk = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  uint8_t msg[384] = {};
  uint8_t * s = ((uint8_t *)(0));
  if ((path ==((uint8_t *)(0)))) {
    (void)(runtime_diag_errno(file, kind, op));
    return;
  }
  if (((path)[((size_t)(0))] ==((uint8_t)(0)))) {
    (void)(runtime_diag_errno(file, kind, op));
    return;
  }
  (void)((saved = rt_diag_get_errno()));
  {
    (void)((err = strerror(saved)));
  }
  if ((err ==((uint8_t *)(0)))) {
    (void)((err = (uint8_t[]){117, 110, 107, 110, 111, 119, 110, 32, 101, 114, 114, 111, 114, 0 }));
  }
  if ((kind !=((uint8_t *)(0)))) {
    (void)((rk = kind));
  } else {
    (void)((rk = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  }
  (void)((code = runtime_diag_code_for_kind(rk)));
  if ((op !=((uint8_t *)(0)))) {
    (void)((s = op));
  } else {
    (void)((s = (uint8_t[]){115, 121, 115, 116, 101, 109, 32, 99, 97, 108, 108, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(rt_diag_append(&((msg)[0]), 384, s));
  (void)(rt_diag_append(&((msg)[0]), 384, (uint8_t[]){32, 102, 97, 105, 108, 101, 100, 32, 102, 111, 114, 32, 39, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 384, path));
  (void)(rt_diag_append(&((msg)[0]), 384, (uint8_t[]){39, 58, 32, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 384, err));
  {
    (void)(diag_report_with_code(file, 0, 0, rk, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void runtime_diag_errno_path_pair(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * from_path, uint8_t * to_path) {
  int32_t saved = 0;
  uint8_t * err = ((uint8_t *)(0));
  uint8_t * rk = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  uint8_t msg[512] = {};
  uint8_t * s = ((uint8_t *)(0));
  uint8_t * from_s = ((uint8_t *)(0));
  uint8_t * to_s = ((uint8_t *)(0));
  (void)((saved = rt_diag_get_errno()));
  {
    (void)((err = strerror(saved)));
  }
  if ((err ==((uint8_t *)(0)))) {
    (void)((err = (uint8_t[]){117, 110, 107, 110, 111, 119, 110, 32, 101, 114, 114, 111, 114, 0 }));
  }
  if ((kind !=((uint8_t *)(0)))) {
    (void)((rk = kind));
  } else {
    (void)((rk = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  }
  (void)((code = runtime_diag_code_for_kind(rk)));
  if ((op !=((uint8_t *)(0)))) {
    (void)((s = op));
  } else {
    (void)((s = (uint8_t[]){115, 121, 115, 116, 101, 109, 32, 99, 97, 108, 108, 0 }));
  }
  if ((from_path !=((uint8_t *)(0)))) {
    (void)((from_s = from_path));
  } else {
    (void)((from_s = (uint8_t[]){63, 0 }));
  }
  if ((to_path !=((uint8_t *)(0)))) {
    (void)((to_s = to_path));
  } else {
    (void)((to_s = (uint8_t[]){63, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(rt_diag_append(&((msg)[0]), 512, s));
  (void)(rt_diag_append(&((msg)[0]), 512, (uint8_t[]){32, 102, 97, 105, 108, 101, 100, 32, 102, 111, 114, 32, 39, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 512, from_s));
  (void)(rt_diag_append(&((msg)[0]), 512, (uint8_t[]){39, 32, 45, 62, 32, 39, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 512, to_s));
  (void)(rt_diag_append(&((msg)[0]), 512, (uint8_t[]){39, 58, 32, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 512, err));
  {
    (void)(diag_report_with_code(file, 0, 0, rk, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void runtime_diag_cli_usage_note(uint8_t * argv0) {
  uint8_t msg[256] = {};
  uint8_t * name = ((uint8_t *)(0));
  uint8_t * note_kind = ((uint8_t *)(0));
  if ((argv0 !=((uint8_t *)(0)))) {
    (void)((name = argv0));
  } else {
    (void)((name = (uint8_t[]){115, 104, 117, 120, 0 }));
  }
  (void)((note_kind = (uint8_t[]){110, 111, 116, 101, 0 }));
  (void)(((msg)[0] = 0));
  (void)(rt_diag_append(&((msg)[0]), 256, (uint8_t[]){117, 115, 97, 103, 101, 58, 32, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 256, name));
  (void)(rt_diag_append(&((msg)[0]), 256, (uint8_t[]){32, 91, 32, 45, 76, 32, 60, 108, 105, 98, 62, 32, 93, 32, 91, 32, 45, 116, 97, 114, 103, 101, 116, 32, 60, 116, 114, 105, 112, 108, 101, 62, 32, 93, 32, 91, 32, 45, 68, 32, 60, 115, 121, 109, 62, 32, 93, 32, 0 }));
  (void)(rt_diag_append(&((msg)[0]), 256, (uint8_t[]){91, 32, 45, 79, 32, 48, 124, 49, 124, 50, 124, 51, 124, 115, 32, 93, 32, 91, 32, 45, 102, 108, 116, 111, 32, 93, 32, 60, 102, 105, 108, 101, 46, 120, 62, 32, 91, 32, 45, 111, 32, 60, 111, 117, 116, 62, 32, 93, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, note_kind, ((uint8_t *)(0)), &((msg)[0]), ((uint8_t *)(0))));
  }
}
