/* seeds/labi_path_pure_surface.from_x.c
 * G-02f labi_path_pure R2 full surface — isomorphic with src/runtime/labi_path_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_path_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (11 public gates + count; wave146 argv_has_obj)
 * Cap residual: Windows #if path sep mega cold; getenv Cap; skip_missing+bank_push Cap;
 *   link_abi_realpath_cap Cap (wave146)
 * Regen: ./shux_asm -E ... src/runtime/labi_path_pure.x | filter DBG + polish prologue
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * shux_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1);
extern int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
extern int32_t shux_output_is_elf_o(uint8_t * path);
extern int32_t shux_output_want_exe(uint8_t * path);
extern int32_t shux_path_has_sep(uint8_t * s);
extern uint8_t * shux_path_last_sep(uint8_t * s);
extern int32_t shux_asm_ld_lib_root_ptr_usable(uint8_t * p);
extern void shux_asm_ld_lib_root_default(uint8_t * root_buf);
extern uint8_t * shux_asm_ld_try_under_lib_roots(uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank);
extern int32_t link_abi_asm_ld_argv_has_obj(uint8_t * * argv, int32_t la, uint8_t * path);
extern int32_t labi_path_pure_count(void);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * shux_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1) {
  if ((n < 2)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a1)) {
    return 0;
  }
  return 1;
}
int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3) {
  if ((n < 4)) {
    return 0;
  }
  if (((s)[(n - 4)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 3)] !=a1)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a2)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a3)) {
    return 0;
  }
  return 1;
}
int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s) {
  int32_t n = 0;
  if ((s ==0)) {
    return 0;
  }
  if (((s)[0] ==0)) {
    return 0;
  }
  while (((s)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(s, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(s, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t shux_output_is_elf_o(uint8_t * path) {
  int32_t n = 0;
  if ((path ==0)) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t shux_output_want_exe(uint8_t * path) {
  int32_t n = 0;
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 115) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 0;
  }
  return 1;
}
int32_t shux_path_has_sep(uint8_t * s) {
  if ((s ==0)) {
    return 0;
  }
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * shux_path_last_sep(uint8_t * s) {
  if ((s ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t last = 0;
  int32_t found = 0;
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      (void)((last = i));
      (void)((found = 1));
    }
    (void)((i = (i + 1)));
  }
  if ((found ==0)) {
    return ((uint8_t *)(0));
  }
  size_t base = ((size_t)(s));
  return ((uint8_t *)((base + ((size_t)(last)))));
}
int32_t shux_asm_ld_lib_root_ptr_usable(uint8_t * p) {
  if ((p ==0)) {
    return 0;
  }
  if ((((size_t)(p)) < 4096)) {
    return 0;
  }
  if (((p)[0] ==0)) {
    return 0;
  }
  return 1;
}
void shux_asm_ld_lib_root_default(uint8_t * root_buf) {
  (void)(((root_buf)[0] = 46));
  (void)(((root_buf)[1] = 0));
  uint8_t * def = 0;
  (void)((def = getenv(((uint8_t *)"\x53\x48\x55\x58\x5f\x4c\x49\x42"))));
  if ((shux_asm_ld_lib_root_ptr_usable(def) ==0)) {
    return;
  }
  int32_t i = 0;
  while ((i < 511)) {
    uint8_t c = (def)[i];
    (void)(((root_buf)[i] = c));
    if ((c ==0)) {
      return;
    }
    (void)((i = (i + 1)));
  }
  (void)(((root_buf)[511] = 0));
}
uint8_t * shux_asm_ld_try_under_lib_roots(uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank) {
  if ((shux_asm_ld_lib_root_ptr_usable(rel) ==0)) {
    return ((uint8_t *)(0));
  }
  if ((bank ==0)) {
    return ((uint8_t *)(0));
  }
  if ((((size_t)(bank)) < 4096)) {
    return ((uint8_t *)(0));
  }
  uint8_t * roots_base = ((uint8_t *)(lib_roots));
  if ((roots_base ==0)) {
    return ((uint8_t *)(0));
  }
  if ((((size_t)(roots_base)) < 4096)) {
    return ((uint8_t *)(0));
  }
  if ((n_lib_roots <=0)) {
    return ((uint8_t *)(0));
  }
  int32_t rel_n = 0;
  while (((rel)[rel_n] !=0)) {
    (void)((rel_n = (rel_n + 1)));
  }
  int32_t i = 0;
  while ((i < n_lib_roots)) {
    if ((i >=24)) {
      break;
    }
    uint8_t * root = (lib_roots)[i];
    if ((shux_asm_ld_lib_root_ptr_usable(root) ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    int32_t rn = 0;
    while (((root)[rn] !=0)) {
      (void)((rn = (rn + 1)));
    }
    while ((rn > 1)) {
      if (((root)[(rn - 1)] !=47)) {
        break;
      }
      (void)((rn = (rn - 1)));
    }
    if ((((rn + 2) + rel_n) >=4096)) {
      (void)((i = (i + 1)));
      continue;
    }
    uint8_t tmp[4096] = {};
    if ((rn > 0)) {
      int32_t j = 0;
      while ((j < rn)) {
        (void)(((tmp)[j] = (root)[j]));
        (void)((j = (j + 1)));
      }
      (void)(((tmp)[rn] = 47));
      int32_t k = 0;
      while ((k <=rel_n)) {
        (void)(((tmp)[((rn + 1) + k)] = (rel)[k]));
        (void)((k = (k + 1)));
      }
    } else {
      int32_t k2 = 0;
      while ((k2 <=rel_n)) {
        (void)(((tmp)[k2] = (rel)[k2]));
        (void)((k2 = (k2 + 1)));
      }
    }
    uint8_t * hit = 0;
    (void)((hit = asm_link_obj_skip_missing(&((tmp)[0]))));
    if ((hit ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    uint8_t * pushed = 0;
    (void)((pushed = shux_asm_ld_bank_push(bank, &((tmp)[0]))));
    return pushed;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_asm_ld_argv_has_obj(uint8_t * * argv, int32_t la, uint8_t * path) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return 0;
  }
  if ((la <=0)) {
    return 0;
  }
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  uint8_t abs_new[4096] = {};
  uint8_t * use_new = path;
  uint8_t * rn = 0;
  (void)((rn = link_abi_realpath_cap(path, &((abs_new)[0]))));
  if ((rn !=0)) {
    (void)((use_new = rn));
  }
  int32_t k = 0;
  while ((k < la)) {
    uint8_t * exist = (argv)[k];
    if ((exist ==0)) {
      (void)((k = (k + 1)));
      continue;
    }
    if (((exist)[0] ==0)) {
      (void)((k = (k + 1)));
      continue;
    }
    int32_t eq_path = 1;
    int32_t i0 = 0;
    while ((i0 < 1048576)) {
      uint8_t ca = (exist)[i0];
      uint8_t cb = (path)[i0];
      if ((ca !=cb)) {
        (void)((eq_path = 0));
        break;
      }
      if ((ca ==0)) {
        break;
      }
      (void)((i0 = (i0 + 1)));
    }
    if ((eq_path !=0)) {
      return 1;
    }
    int32_t eq_new = 1;
    int32_t i1 = 0;
    while ((i1 < 1048576)) {
      uint8_t ca2 = (exist)[i1];
      uint8_t cb2 = (use_new)[i1];
      if ((ca2 !=cb2)) {
        (void)((eq_new = 0));
        break;
      }
      if ((ca2 ==0)) {
        break;
      }
      (void)((i1 = (i1 + 1)));
    }
    if ((eq_new !=0)) {
      return 1;
    }
    uint8_t abs_exist[4096] = {};
    uint8_t * re = 0;
    (void)((re = link_abi_realpath_cap(exist, &((abs_exist)[0]))));
    if ((re !=0)) {
      int32_t eq_re = 1;
      int32_t i2 = 0;
      while ((i2 < 1048576)) {
        uint8_t ca3 = (re)[i2];
        uint8_t cb3 = (use_new)[i2];
        if ((ca3 !=cb3)) {
          (void)((eq_re = 0));
          break;
        }
        if ((ca3 ==0)) {
          break;
        }
        (void)((i2 = (i2 + 1)));
      }
      if ((eq_re !=0)) {
        return 1;
      }
    }
    (void)((k = (k + 1)));
  }
  return 0;
}
int32_t labi_path_pure_count(void) {
  return 11;
}
