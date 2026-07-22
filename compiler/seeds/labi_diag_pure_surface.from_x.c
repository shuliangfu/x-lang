/* seeds/labi_diag_pure_surface.from_x.c
 * G-02f labi_diag_pure R2 full surface — isomorphic with src/runtime/labi_diag_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_diag_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (code_for_kind + reports + count + wave111/112)
 * Cap residual: link_diag_ld_debug_argv → mega _impl (char**);
 *   link_diag_errno / path (errno+strerror); link_diag_wait_* (WIF*);
 *   wave111 shux_link_perror pure orch; wave112 tool_status / obj_build_status pure orch
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
extern void labi_diag_append_i32(uint8_t * dst, int32_t cap, int32_t v);
extern uint8_t * link_diag_code_for_kind(uint8_t * kind);
extern void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint);
extern void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path);
extern void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix);
extern void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o);
extern void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name);
extern void link_diag_freestanding_unsupported(void);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv);
extern void link_diag_tool_status(uint8_t * tool, int32_t status);
extern void link_diag_runtime_obj_build_status(uint8_t * obj_name, int32_t status);
extern int32_t labi_diag_pure_count(void);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern void link_diag_ld_debug_argv_impl(uint8_t * label, uint8_t * argv);
/* Cap residual (mega always): errno + strerror + reportf. */
extern void link_diag_errno(uint8_t * kind, uint8_t * op);
extern void link_diag_errno_path(uint8_t * kind, uint8_t * op, uint8_t * path);
/* Cap residual (mega always): POSIX wait decode. PLATFORM: POSIX. */
extern int32_t link_diag_wait_is_signaled(int32_t status);
extern int32_t link_diag_wait_code(int32_t status);
extern void shux_link_perror(uint8_t * msg);
int32_t labi_diag_append(uint8_t * dst, int32_t cap, uint8_t * src) {
  int32_t i = 0;
  int32_t j = 0;
  if ((dst ==0)) {
    return 0;
  }
  if ((src ==0)) {
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
void labi_diag_append_i32(uint8_t * dst, int32_t cap, int32_t v) {
  uint8_t dig[16] = {};
  int32_t n = v;
  int32_t i = 0;
  int32_t j = 0;
  int32_t neg = 0;
  uint8_t a = 0;
  (void)(((dig)[0] = 0));
  if ((n ==0)) {
    (void)(((dig)[0] = 48));
    (void)(((dig)[1] = 0));
    (void)(labi_diag_append(dst, cap, &((dig)[0])));
    return;
  }
  if ((n < 0)) {
    (void)((neg = 1));
    (void)((n = (0 - n)));
  }
  while ((n > 0)) {
    if ((i >=15)) {
      break;
    }
    (void)(((dig)[i] = ((uint8_t)((48 + (n - ((n / 10) * 10)))))));
    (void)((n = (n / 10)));
    (void)((i = (i + 1)));
  }
  if ((neg !=0)) {
    if ((i < 15)) {
      (void)(((dig)[i] = 45));
      (void)((i = (i + 1)));
    }
  }
  (void)((j = 0));
  while ((j < (i / 2))) {
    (void)((a = (dig)[j]));
    (void)(((dig)[j] = (dig)[((i - 1) - j)]));
    (void)(((dig)[((i - 1) - j)] = a));
    (void)((j = (j + 1)));
  }
  (void)(((dig)[i] = 0));
  (void)(labi_diag_append(dst, cap, &((dig)[0])));
}
uint8_t * link_diag_code_for_kind(uint8_t * kind) {
  if ((kind ==0)) {
    uint8_t * p = ((uint8_t *)"\x50\x52\x43\x30\x30\x31");
    return p;
  }
  {
    uint8_t * be = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72");
    if ((strcmp(kind, be) ==0)) {
      uint8_t * p = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31");
      return p;
    }
    uint8_t * pe = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x20\x65\x72\x72\x6f\x72");
    if ((strcmp(kind, pe) ==0)) {
      uint8_t * p = ((uint8_t *)"\x50\x52\x43\x30\x30\x31");
      return p;
    }
  }
  return ((uint8_t *)(0));
}
void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint) {
  uint8_t * on = obj_name;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x63\x61\x6e\x6e\x6f\x74\x20\x72\x65\x73\x6f\x6c\x76\x65\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x64\x69\x72\x65\x63\x74\x6f\x72\x79\x20\x74\x6f\x20\x62\x75\x69\x6c\x64\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  if ((hint !=0)) {
    if (((hint)[((size_t)(0))] !=0)) {
      (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x28")));
      (void)(labi_diag_append(&((msg)[0]), 320, hint));
      (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x29")));
    }
  }
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path) {
  uint8_t * on = obj_name;
  uint8_t * sp = source_path;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  if ((sp ==0)) {
    (void)((sp = ((uint8_t *)"\x3f")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x73\x6f\x75\x72\x63\x65\x20\x6e\x6f\x74\x20\x66\x6f\x75\x6e\x64\x20\x61\x74\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, sp));
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix) {
  uint8_t * on = obj_name;
  uint8_t * bd = base_dir;
  uint8_t * sf = suffix;
  uint8_t msg[384] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  if ((bd ==0)) {
    (void)((bd = ((uint8_t *)"\x3f")));
  }
  if ((sf ==0)) {
    (void)((sf = ((uint8_t *)"")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 384, on));
  (void)(labi_diag_append(&((msg)[0]), 384, ((uint8_t *)"\x20\x73\x6f\x75\x72\x63\x65\x20\x6e\x6f\x74\x20\x66\x6f\x75\x6e\x64\x20\x75\x6e\x64\x65\x72\x20")));
  (void)(labi_diag_append(&((msg)[0]), 384, bd));
  (void)(labi_diag_append(&((msg)[0]), 384, sf));
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o) {
  uint8_t * on = obj_name;
  uint8_t * oo = out_o;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  if ((oo ==0)) {
    (void)((oo = ((uint8_t *)"\x3f")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x6d\x69\x73\x73\x69\x6e\x67\x20\x61\x66\x74\x65\x72\x20\x63\x63\x20\x2d\x63\x20\x28\x65\x78\x70\x65\x63\x74\x65\x64\x20\x6e\x65\x61\x72\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, oo));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x29")));
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name) {
  uint8_t * on = obj_name;
  uint8_t * sn = symbol_name;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x20\x6c\x69\x6e\x6b\x20\x6d\x69\x73\x73\x69\x6e\x67\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  if ((sn !=0)) {
    if (((sn)[((size_t)(0))] !=0)) {
      (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x28\x75\x73\x65\x72\x20\x72\x65\x66\x65\x72\x65\x6e\x63\x65\x73\x20")));
      (void)(labi_diag_append(&((msg)[0]), 320, sn));
      (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x29")));
    }
  }
  (void)((kind = ((uint8_t *)"\x6c\x69\x6e\x6b\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_freestanding_unsupported(void) {
  uint8_t msg[192] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 192, ((uint8_t *)"\x2d\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x20\x2f\x20\x53\x48\x55\x58\x5f\x46\x52\x45\x45\x53\x54\x41\x4e\x44\x49\x4e\x47\x20\x69\x73\x20\x6f\x6e\x6c\x79\x20\x73\x75\x70\x70\x6f\x72\x74\x65\x64\x20\x66\x6f\x72\x20")));
  (void)(labi_diag_append(&((msg)[0]), 192, ((uint8_t *)"\x4c\x69\x6e\x75\x78\x20\x45\x4c\x46\x20\x78\x38\x36\x5f\x36\x34\x20\x28\x2d\x6f\x20\x70\x72\x6f\x67\x2c\x20\x6e\x6f\x74\x20\x2e\x6f\x2f\x2e\x6f\x62\x6a\x20\x6f\x6e\x20\x6d\x61\x63\x4f\x53\x2f\x43\x4f\x46\x46\x29")));
  (void)((kind = ((uint8_t *)"\x6c\x69\x6e\x6b\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path) {
  uint8_t * r = rel;
  uint8_t * st = stage;
  uint8_t * p = path;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  if ((r ==0)) {
    (void)((r = ((uint8_t *)"\x28\x6e\x75\x6c\x6c\x29")));
  }
  if ((st ==0)) {
    (void)((st = ((uint8_t *)"\x70\x61\x74\x68")));
  }
  if ((p ==0)) {
    (void)((p = ((uint8_t *)"\x28\x6e\x75\x6c\x6c\x29")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x6c\x64\x20\x64\x65\x62\x75\x67\x3a\x20\x70\x75\x73\x68\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, r));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, st));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x3d")));
  (void)(labi_diag_append(&((msg)[0]), 320, p));
  (void)((kind = ((uint8_t *)"\x6e\x6f\x74\x65")));
  (void)(diag_report_with_code(0, 0, 0, kind, 0, &((msg)[0]), 0));
}
void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv) {
  (void)(link_diag_ld_debug_argv_impl(label, argv));
}
void link_diag_tool_status(uint8_t * tool, int32_t status) {
  uint8_t * t = tool;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  int32_t sig = 0;
  int32_t c = 0;
  if ((t ==0)) {
    (void)((t = ((uint8_t *)"\x74\x6f\x6f\x6c")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, t));
  (void)((sig = link_diag_wait_is_signaled(status)));
  (void)((c = link_diag_wait_code(status)));
  if ((sig !=0)) {
    (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x66\x61\x69\x6c\x65\x64\x20\x28\x73\x69\x67\x6e\x61\x6c\x20")));
  } else {
    (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x66\x61\x69\x6c\x65\x64\x20\x28\x65\x78\x69\x74\x20")));
  }
  (void)(labi_diag_append_i32(&((msg)[0]), 320, c));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x29")));
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
}
void link_diag_runtime_obj_build_status(uint8_t * obj_name, int32_t status) {
  uint8_t * on = obj_name;
  uint8_t msg[320] = {};
  uint8_t * kind = 0;
  uint8_t * code = 0;
  int32_t sig = 0;
  int32_t c = 0;
  if ((on ==0)) {
    (void)((on = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x20\x6f\x62\x6a\x65\x63\x74")));
  }
  (void)(((msg)[0] = 0));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x66\x61\x69\x6c\x65\x64\x20\x74\x6f\x20\x62\x75\x69\x6c\x64\x20")));
  (void)(labi_diag_append(&((msg)[0]), 320, on));
  (void)((sig = link_diag_wait_is_signaled(status)));
  (void)((c = link_diag_wait_code(status)));
  if ((sig !=0)) {
    (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x28\x73\x69\x67\x6e\x61\x6c\x20")));
  } else {
    (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x20\x28\x65\x78\x69\x74\x20")));
  }
  (void)(labi_diag_append_i32(&((msg)[0]), 320, c));
  (void)(labi_diag_append(&((msg)[0]), 320, ((uint8_t *)"\x29")));
  (void)((kind = ((uint8_t *)"\x62\x75\x69\x6c\x64\x20\x65\x72\x72\x6f\x72")));
  (void)((code = ((uint8_t *)"\x42\x4c\x44\x30\x30\x31")));
  (void)(diag_report_with_code(0, 0, 0, kind, code, &((msg)[0]), 0));
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
