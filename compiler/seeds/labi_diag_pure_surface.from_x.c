/* seeds/labi_diag_pure_surface.from_x.c
 * G-02f labi_diag_pure R2 full surface — isomorphic with src/runtime/labi_diag_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_diag_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (code_for_kind + 8 report + count)
 * Cap residual: link_diag_ld_debug_argv → mega _impl (char**)
 * Regen: ./shux -E ... src/runtime/labi_diag_pure.x | filter DBG + polish prologue
 * Track-L (2026-07-16): labi_diag_append keeps short name; .x has #[no_mangle] (was module mangle).
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
extern int32_t labi_diag_append(uint8_t * dst, int32_t cap, uint8_t * src);
extern uint8_t * link_diag_code_for_kind(uint8_t * kind);
extern void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint);
extern void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path);
extern void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix);
extern void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o);
extern void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name);
extern void link_diag_freestanding_unsupported(void);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv);
extern int32_t labi_diag_pure_count(void);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void link_diag_ld_debug_argv_impl(uint8_t * label, uint8_t * argv);
int32_t labi_diag_append(uint8_t * dst, int32_t cap, uint8_t * src) {
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
uint8_t * link_diag_code_for_kind(uint8_t * kind) {
  if ((kind ==((uint8_t *)(0)))) {
    uint8_t * p = (uint8_t[]){80, 82, 67, 48, 48, 49, 0 };
    return p;
  }
  {
    uint8_t * be = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 };
    if ((strcmp(kind, be) ==0)) {
      uint8_t * p = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 };
      return p;
    }
    uint8_t * pe = (uint8_t[]){112, 114, 111, 99, 101, 115, 115, 32, 101, 114, 114, 111, 114, 0 };
    if ((strcmp(kind, pe) ==0)) {
      uint8_t * p = (uint8_t[]){80, 82, 67, 48, 48, 49, 0 };
      return p;
    }
  }
  return ((uint8_t *)(0));
}
void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint) {
  uint8_t * on = obj_name;
  uint8_t msg[320] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  if ((on ==((uint8_t *)(0)))) {
    (void)((on = (uint8_t[]){114, 117, 110, 116, 105, 109, 101, 32, 111, 98, 106, 101, 99, 116, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){99, 97, 110, 110, 111, 116, 32, 114, 101, 115, 111, 108, 118, 101, 32, 99, 111, 109, 112, 105, 108, 101, 114, 32, 100, 105, 114, 101, 99, 116, 111, 114, 121, 32, 116, 111, 32, 98, 117, 105, 108, 100, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  if ((hint !=((uint8_t *)(0)))) {
    if (((hint)[((size_t)(0))] !=0)) {
      (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){32, 40, 0 }));
      (void)(labi_diag_append(&((msg)[0]), 320, hint));
      (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){41, 0 }));
    }
  }
  (void)((kind = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path) {
  uint8_t * on = obj_name;
  uint8_t * sp = source_path;
  uint8_t msg[320] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  if ((on ==((uint8_t *)(0)))) {
    (void)((on = (uint8_t[]){114, 117, 110, 116, 105, 109, 101, 32, 111, 98, 106, 101, 99, 116, 0 }));
  }
  if ((sp ==((uint8_t *)(0)))) {
    (void)((sp = (uint8_t[]){63, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){32, 115, 111, 117, 114, 99, 101, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 32, 97, 116, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, sp));
  (void)((kind = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix) {
  uint8_t * on = obj_name;
  uint8_t * bd = base_dir;
  uint8_t * sf = suffix;
  uint8_t msg[384] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  if ((on ==((uint8_t *)(0)))) {
    (void)((on = (uint8_t[]){114, 117, 110, 116, 105, 109, 101, 32, 111, 98, 106, 101, 99, 116, 0 }));
  }
  if ((bd ==((uint8_t *)(0)))) {
    (void)((bd = (uint8_t[]){63, 0 }));
  }
  if ((sf ==((uint8_t *)(0)))) {
    (void)((sf = (uint8_t[]){0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 384, on));
  (void)(labi_diag_append(&((msg)[0]), 384, (uint8_t[]){32, 115, 111, 117, 114, 99, 101, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 32, 117, 110, 100, 101, 114, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 384, bd));
  (void)(labi_diag_append(&((msg)[0]), 384, sf));
  (void)((kind = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o) {
  uint8_t * on = obj_name;
  uint8_t * oo = out_o;
  uint8_t msg[320] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  if ((on ==((uint8_t *)(0)))) {
    (void)((on = (uint8_t[]){114, 117, 110, 116, 105, 109, 101, 32, 111, 98, 106, 101, 99, 116, 0 }));
  }
  if ((oo ==((uint8_t *)(0)))) {
    (void)((oo = (uint8_t[]){63, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){32, 109, 105, 115, 115, 105, 110, 103, 32, 97, 102, 116, 101, 114, 32, 99, 99, 32, 45, 99, 32, 40, 101, 120, 112, 101, 99, 116, 101, 100, 32, 110, 101, 97, 114, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, oo));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){41, 0 }));
  (void)((kind = (uint8_t[]){98, 117, 105, 108, 100, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name) {
  uint8_t * on = obj_name;
  uint8_t * sn = symbol_name;
  uint8_t msg[320] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  if ((on ==((uint8_t *)(0)))) {
    (void)((on = (uint8_t[]){114, 117, 110, 116, 105, 109, 101, 32, 111, 98, 106, 101, 99, 116, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 32, 108, 105, 110, 107, 32, 109, 105, 115, 115, 105, 110, 103, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  if ((sn !=((uint8_t *)(0)))) {
    if (((sn)[((size_t)(0))] !=0)) {
      (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){32, 40, 117, 115, 101, 114, 32, 114, 101, 102, 101, 114, 101, 110, 99, 101, 115, 32, 0 }));
      (void)(labi_diag_append(&((msg)[0]), 320, sn));
      (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){41, 0 }));
    }
  }
  (void)((kind = (uint8_t[]){108, 105, 110, 107, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_freestanding_unsupported(void) {
  uint8_t msg[192] = {};
  uint8_t * kind = ((uint8_t *)(0));
  uint8_t * code = ((uint8_t *)(0));
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 192, (uint8_t[]){45, 102, 114, 101, 101, 115, 116, 97, 110, 100, 105, 110, 103, 32, 47, 32, 83, 72, 85, 88, 95, 70, 82, 69, 69, 83, 84, 65, 78, 68, 73, 78, 71, 32, 105, 115, 32, 111, 110, 108, 121, 32, 115, 117, 112, 112, 111, 114, 116, 101, 100, 32, 102, 111, 114, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 192, (uint8_t[]){76, 105, 110, 117, 120, 32, 69, 76, 70, 32, 120, 56, 54, 95, 54, 52, 32, 40, 45, 111, 32, 112, 114, 111, 103, 44, 32, 110, 111, 116, 32, 46, 111, 47, 46, 111, 98, 106, 32, 111, 110, 32, 109, 97, 99, 79, 83, 47, 67, 79, 70, 70, 41, 0 }));
  (void)((kind = (uint8_t[]){108, 105, 110, 107, 32, 101, 114, 114, 111, 114, 0 }));
  (void)((code = (uint8_t[]){66, 76, 68, 48, 48, 49, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, code, &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path) {
  uint8_t * r = rel;
  uint8_t * st = stage;
  uint8_t * p = path;
  uint8_t msg[320] = {};
  uint8_t * kind = ((uint8_t *)(0));
  if ((r ==((uint8_t *)(0)))) {
    (void)((r = (uint8_t[]){40, 110, 117, 108, 108, 41, 0 }));
  }
  if ((st ==((uint8_t *)(0)))) {
    (void)((st = (uint8_t[]){112, 97, 116, 104, 0 }));
  }
  if ((p ==((uint8_t *)(0)))) {
    (void)((p = (uint8_t[]){40, 110, 117, 108, 108, 41, 0 }));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){108, 100, 32, 100, 101, 98, 117, 103, 58, 32, 112, 117, 115, 104, 32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, r));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){32, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, st));
  (void)(labi_diag_append(&((msg)[0]), 320, (uint8_t[]){61, 0 }));
  (void)(labi_diag_append(&((msg)[0]), 320, p));
  (void)((kind = (uint8_t[]){110, 111, 116, 101, 0 }));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, kind, ((uint8_t *)(0)), &((msg)[0]), ((uint8_t *)(0))));
  }
}
void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv) {
  {
    (void)(link_diag_ld_debug_argv_impl(label, argv));
  }
  (void)(0);
  return;
}
int32_t labi_diag_pure_count(void) {
  return 9;
}
