/* seeds/rt_content_surface.from_x.c
 * G-02f rt_content L2 thin surface — isomorphic with src/runtime/rt_content.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_content.x) + hybrid rest seed
 *   seeds/rt_content.from_x.c (-DSHUX_RT_CONTENT_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed unchanged: driver_source_has_* path wrappers + marker
 *   (#ifndef SHUX_RT_CONTENT_FROM_X keeps content_has_* C bodies for cold path)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface + helpers)
 * Regen: ./shux -E ... src/runtime/rt_content.x | filter DBG + polish prologue
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
extern int32_t rt_eq2(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1);
extern int32_t rt_eq3(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2);
extern int32_t rt_eq4(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3);
extern int32_t rt_eq5(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4);
extern int32_t rt_eq6(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4, uint8_t a5);
extern int32_t rt_is_generic_at(uint8_t * content, int32_t n, int32_t p);
extern int32_t content_has_generic_syntax(uint8_t * content, size_t n);
extern int32_t rt_is_compound_at(uint8_t * content, int32_t n, int32_t at);
extern int32_t rt_is_block_comment_end(uint8_t * c, int32_t n, int32_t at);
extern int32_t rt_is_string_escape(uint8_t * c, int32_t n, int32_t at);
extern int32_t rt_is_line_comment_start(uint8_t * c, int32_t n, int32_t at);
extern int32_t rt_is_block_comment_start(uint8_t * c, int32_t n, int32_t at);
extern int32_t content_has_compound_assign_syntax(uint8_t * content, size_t n);
int32_t rt_eq2(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1) {
  if (((p + 2) > n)) {
    return 0;
  }
  if (((c)[((size_t)(p))] !=a0)) {
    return 0;
  }
  if (((c)[((size_t)((p + 1)))] !=a1)) {
    return 0;
  }
  return 1;
}
int32_t rt_eq3(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2) {
  if (((p + 3) > n)) {
    return 0;
  }
  if (((c)[((size_t)(p))] !=a0)) {
    return 0;
  }
  if (((c)[((size_t)((p + 1)))] !=a1)) {
    return 0;
  }
  if (((c)[((size_t)((p + 2)))] !=a2)) {
    return 0;
  }
  return 1;
}
int32_t rt_eq4(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3) {
  if (((p + 4) > n)) {
    return 0;
  }
  if (((c)[((size_t)(p))] !=a0)) {
    return 0;
  }
  if (((c)[((size_t)((p + 1)))] !=a1)) {
    return 0;
  }
  if (((c)[((size_t)((p + 2)))] !=a2)) {
    return 0;
  }
  if (((c)[((size_t)((p + 3)))] !=a3)) {
    return 0;
  }
  return 1;
}
int32_t rt_eq5(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4) {
  if (((p + 5) > n)) {
    return 0;
  }
  if (((c)[((size_t)(p))] !=a0)) {
    return 0;
  }
  if (((c)[((size_t)((p + 1)))] !=a1)) {
    return 0;
  }
  if (((c)[((size_t)((p + 2)))] !=a2)) {
    return 0;
  }
  if (((c)[((size_t)((p + 3)))] !=a3)) {
    return 0;
  }
  if (((c)[((size_t)((p + 4)))] !=a4)) {
    return 0;
  }
  return 1;
}
int32_t rt_eq6(uint8_t * c, int32_t n, int32_t p, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3, uint8_t a4, uint8_t a5) {
  if (((p + 6) > n)) {
    return 0;
  }
  if (((c)[((size_t)(p))] !=a0)) {
    return 0;
  }
  if (((c)[((size_t)((p + 1)))] !=a1)) {
    return 0;
  }
  if (((c)[((size_t)((p + 2)))] !=a2)) {
    return 0;
  }
  if (((c)[((size_t)((p + 3)))] !=a3)) {
    return 0;
  }
  if (((c)[((size_t)((p + 4)))] !=a4)) {
    return 0;
  }
  if (((c)[((size_t)((p + 5)))] !=a5)) {
    return 0;
  }
  return 1;
}
int32_t rt_is_generic_at(uint8_t * content, int32_t n, int32_t p) {
  int32_t prev = 0;
  int32_t q = 0;
  if ((p >=n)) {
    return 0;
  }
  if (((content)[((size_t)(p))] !=60)) {
    return 0;
  }
  if (((p + 1) >=n)) {
    return 0;
  }
  if ((p > 0)) {
    (void)((prev = (p - 1)));
    if (((content)[((size_t)(prev))] ==93)) {
      return 0;
    }
  }
  if (((content)[((size_t)((p + 1)))] ==84)) {
    (void)((q = (p + 2)));
    if ((q >=n)) {
      return 1;
    }
    if (((content)[((size_t)(q))] ==62)) {
      return 1;
    }
    if (((content)[((size_t)(q))] ==44)) {
      return 1;
    }
  }
  if ((rt_eq4(content, n, p, 60, 105, 56, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 105, 49, 54, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 105, 51, 50, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 105, 54, 52, 62) !=0)) {
    return 1;
  }
  if ((rt_eq4(content, n, p, 60, 117, 56, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 117, 49, 54, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 117, 51, 50, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 117, 54, 52, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 102, 51, 50, 62) !=0)) {
    return 1;
  }
  if ((rt_eq5(content, n, p, 60, 102, 54, 52, 62) !=0)) {
    return 1;
  }
  if ((rt_eq6(content, n, p, 60, 98, 111, 111, 108, 62) !=0)) {
    return 1;
  }
  return 0;
}
int32_t content_has_generic_syntax(uint8_t * content, size_t n) {
  int32_t p = 0;
  int32_t i = 0;
  int32_t ni = 0;
  if ((content ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((n ==0)) {
    return 0;
  }
  (void)((ni = ((int32_t)(n))));
  if ((ni < 0)) {
    (void)((ni = 2147483647));
  }
  (void)((p = 0));
  while ((p < ni)) {
    if ((rt_is_generic_at(content, ni, p) !=0)) {
      return 1;
    }
    (void)((p = (p + 1)));
  }
  if ((ni >=6)) {
    (void)((i = 0));
    while ((i <=(ni - 6))) {
      if ((rt_eq6(content, ni, i, 116, 114, 97, 105, 116, 32) !=0)) {
        return 1;
      }
      if ((rt_eq6(content, ni, i, 32, 105, 109, 112, 108, 32) !=0)) {
        return 1;
      }
      (void)((i = (i + 1)));
    }
  }
  return 0;
}
int32_t rt_is_compound_at(uint8_t * content, int32_t n, int32_t at) {
  if ((rt_eq3(content, n, at, 60, 60, 61) !=0)) {
    return 1;
  }
  if ((rt_eq3(content, n, at, 62, 62, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 43, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 45, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 42, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 47, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 37, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 38, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 124, 61) !=0)) {
    return 1;
  }
  if ((rt_eq2(content, n, at, 94, 61) !=0)) {
    return 1;
  }
  return 0;
}
int32_t rt_is_block_comment_end(uint8_t * c, int32_t n, int32_t at) {
  if (((at + 1) >=n)) {
    return 0;
  }
  if (((c)[((size_t)(at))] !=42)) {
    return 0;
  }
  if (((c)[((size_t)((at + 1)))] !=47)) {
    return 0;
  }
  return 1;
}
int32_t rt_is_string_escape(uint8_t * c, int32_t n, int32_t at) {
  if (((c)[((size_t)(at))] !=92)) {
    return 0;
  }
  if (((at + 1) >=n)) {
    return 0;
  }
  return 1;
}
int32_t rt_is_line_comment_start(uint8_t * c, int32_t n, int32_t at) {
  if (((at + 1) >=n)) {
    return 0;
  }
  if (((c)[((size_t)(at))] !=47)) {
    return 0;
  }
  if (((c)[((size_t)((at + 1)))] !=47)) {
    return 0;
  }
  return 1;
}
int32_t rt_is_block_comment_start(uint8_t * c, int32_t n, int32_t at) {
  if (((at + 1) >=n)) {
    return 0;
  }
  if (((c)[((size_t)(at))] !=47)) {
    return 0;
  }
  if (((c)[((size_t)((at + 1)))] !=42)) {
    return 0;
  }
  return 1;
}
int32_t content_has_compound_assign_syntax(uint8_t * content, size_t n) {
  int32_t at = 0;
  int32_t ni = 0;
  int32_t state = 0;
  if ((content ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((n < 3)) {
    return 0;
  }
  (void)((ni = ((int32_t)(n))));
  if ((ni < 0)) {
    (void)((ni = 2147483647));
  }
  while ((at < ni)) {
    if ((state ==0)) {
      if ((rt_is_line_comment_start(content, ni, at) !=0)) {
        (void)((state = 1));
        (void)((at = (at + 2)));
      } else {
        if ((rt_is_block_comment_start(content, ni, at) !=0)) {
          (void)((state = 2));
          (void)((at = (at + 2)));
        } else {
          if (((content)[((size_t)(at))] ==34)) {
            (void)((state = 3));
            (void)((at = (at + 1)));
          } else {
            if ((rt_is_compound_at(content, ni, at) !=0)) {
              return 1;
            }
            (void)((at = (at + 1)));
          }
        }
      }
    } else {
      if ((state ==1)) {
        if (((content)[((size_t)(at))] ==10)) {
          (void)((state = 0));
        }
        (void)((at = (at + 1)));
      } else {
        if ((state ==2)) {
          if ((rt_is_block_comment_end(content, ni, at) !=0)) {
            (void)((state = 0));
            (void)((at = (at + 2)));
          } else {
            (void)((at = (at + 1)));
          }
        } else {
          if ((rt_is_string_escape(content, ni, at) !=0)) {
            (void)((at = (at + 2)));
          } else {
            if (((content)[((size_t)(at))] ==34)) {
              (void)((state = 0));
            }
            (void)((at = (at + 1)));
          }
        }
      }
    }
  }
  return 0;
}
