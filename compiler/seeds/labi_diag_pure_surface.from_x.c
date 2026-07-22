/* seeds/labi_diag_pure_surface.from_x.c
 * G-02f labi_diag_pure R2 full surface — isomorphic with src/runtime/labi_diag_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_diag_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (code_for_kind + 8 report + count)
 * Cap residual: link_diag_ld_debug_argv → mega _impl (char**);
 *   link_diag_errno / path (errno+strerror); wave111 shux_link_perror pure orch
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
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
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
/* Cap residual (mega always): errno + strerror + reportf. */
extern void link_diag_errno(uint8_t * kind, uint8_t * op);
extern void link_diag_errno_path(uint8_t * kind, uint8_t * op, uint8_t * path);
extern void shux_link_perror(uint8_t * msg);
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
void shux_link_perror(uint8_t * msg) {
  uint8_t * pe = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x20\x65\x72\x72\x6f\x72");
  uint8_t * sc = ((uint8_t *)"\x73\x79\x73\x74\x65\x6d\x20\x63\x61\x6c\x6c");
  uint8_t * base = msg;
  int32_t start = 0;
  int32_t n = 0;
  int32_t i = 0;
  int32_t lparen = -1;
  int32_t rparen = -1;
  int32_t op_end = 0;
  int32_t op_len = 0;
  int32_t path_len = 0;
  int32_t j = 0;
  uint8_t op_buf[128] = {};
  uint8_t path_buf[160] = {};
  uint8_t * text = 0;
  if ((base ==0)) {
    (void)(link_diag_errno(pe, sc));
    return;
  }
  if (((base)[0] ==0)) {
    (void)(link_diag_errno(pe, sc));
    return;
  }
  if (((base)[0] ==115)) {
    if (((base)[1] ==104)) {
      if (((base)[2] ==117)) {
        if (((base)[3] ==120)) {
          if (((base)[4] ==58)) {
            if (((base)[5] ==32)) {
              (void)((start = 6));
            }
          }
        }
      }
    }
  }
  (void)((n = start));
  while (((base)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  (void)((i = start));
  while ((i < n)) {
    if (((base)[i] ==40)) {
      (void)((lparen = i));
    }
    if (((base)[i] ==41)) {
      (void)((rparen = i));
    }
    (void)((i = (i + 1)));
  }
  if ((((lparen >=start) && (rparen > lparen)) && ((rparen + 1) ==n))) {
    (void)((op_end = lparen));
    while (((op_end > start) && ((base)[(op_end - 1)] ==32))) {
      (void)((op_end = (op_end - 1)));
    }
    (void)((op_len = (op_end - start)));
    if ((op_len >=128)) {
      (void)((op_len = 127));
    }
    (void)((path_len = ((rparen - lparen) - 1)));
    if ((path_len >=160)) {
      (void)((path_len = 159));
    }
    (void)((j = 0));
    while ((j < op_len)) {
      (void)(((op_buf)[((size_t)(j))] = (base)[((size_t)((start + j)))]));
      (void)((j = (j + 1)));
    }
    (void)(((op_buf)[((size_t)(op_len))] = 0));
    (void)((j = 0));
    while ((j < path_len)) {
      (void)(((path_buf)[((size_t)(j))] = (base)[((size_t)(((lparen + 1) + j)))]));
      (void)((j = (j + 1)));
    }
    (void)(((path_buf)[((size_t)(path_len))] = 0));
    (void)(link_diag_errno_path(pe, &((op_buf)[0]), &((path_buf)[0])));
    return;
  }
  (void)((text = &((base)[start])));
  (void)(link_diag_errno(pe, text));
}
int32_t labi_diag_pure_count(void) {
  return 9;
}
