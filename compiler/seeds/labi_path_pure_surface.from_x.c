/* seeds/labi_path_pure_surface.from_x.c
 * G-02f labi_path_pure R2 full surface — isomorphic with src/runtime/labi_path_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_path_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (17 public gates + count; wave160 compiler_o_path_copy)
 * Cap residual: Windows #if path sep mega cold; getenv Cap; skip_missing+bank_push Cap;
 *   link_abi_realpath_cap Cap (wave146); bank_push Cap (wave147);
 *   skip/rel/bank/diag Cap (wave148 push_obj); call_ensure Cap (wave149 push_glue);
 *   *_o_path Cap (wave150 push_minimal); table+access Cap (wave151 append_user_extra);
 *   shu_resolve_compiler_dir Cap (wave160 compiler_o_path_copy)
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
extern uint8_t * shux_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
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
extern void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * p);
extern int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t * flag_out);
extern void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la);
extern void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la);
extern void shux_asm_ld_append_user_extra_o_files(uint8_t * * argv, int32_t * la, int32_t max_la);
extern int32_t shux_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz);
extern int32_t labi_path_pure_count(void);
extern int32_t link_abi_call_ensure_argv0(uint8_t * ensure_fn, uint8_t * link_argv0);
extern uint8_t * shux_runtime_asm_io_stubs_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_process_argv_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_panic_o_path(uint8_t * argv0);
extern int32_t link_abi_user_extra_o_count(void);
extern uint8_t * link_abi_user_extra_o_at(int32_t i);
extern int32_t link_abi_path_readable(uint8_t * path);
extern int32_t shu_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
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
void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * p) {
  if ((p ==0)) {
    return;
  }
  if (((p)[0] ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t cur = (la)[0];
  if ((cur >=(max_la - 1))) {
    return;
  }
  uint8_t * use_p = p;
  if ((bank !=0)) {
    uint8_t * bp = 0;
    (void)((bp = shux_asm_ld_bank_push(bank, p)));
    if ((bp !=0)) {
      (void)((use_p = bp));
    }
  }
  if ((link_abi_asm_ld_argv_has_obj(argv, cur, use_p) !=0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  (void)(((argv)[cur] = use_p));
  (void)(((la)[0] = (cur + 1)));
}
/* wave148: push_obj pure orch (surface pin; Cap residual skip/rel/bank/diag). */
int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t * flag_out) {
  if ((la ==0)) {
    return 0;
  }
  int32_t cur = (la)[0];
  if ((cur >=(max_la - 1))) {
    return 0;
  }
  int32_t debug_runtime_obj = 0;
  if ((rel !=0)) {
    uint8_t * t1 = ((uint8_t *)("compiler/runtime_asm_io_stubs.o"));
    uint8_t * t2 = ((uint8_t *)("compiler/runtime_process_argv.o"));
    int32_t eq1 = 1;
    int32_t i1 = 0;
    while ((i1 < 1048576)) {
      uint8_t ca = (rel)[i1];
      uint8_t cb = (t1)[i1];
      if ((ca !=cb)) {
        (void)((eq1 = 0));
        break;
      }
      if ((ca ==0)) {
        break;
      }
      (void)((i1 = (i1 + 1)));
    }
    if ((eq1 !=0)) {
      (void)((debug_runtime_obj = 1));
    }
    if ((debug_runtime_obj ==0)) {
      int32_t eq2 = 1;
      int32_t i2 = 0;
      while ((i2 < 1048576)) {
        uint8_t ca2 = (rel)[i2];
        uint8_t cb2 = (t2)[i2];
        if ((ca2 !=cb2)) {
          (void)((eq2 = 0));
          break;
        }
        if ((ca2 ==0)) {
          break;
        }
        (void)((i2 = (i2 + 1)));
      }
      if ((eq2 !=0)) {
        (void)((debug_runtime_obj = 1));
      }
    }
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg = 0;
    (void)((dbg = getenv(((uint8_t *)("SHUX_DEBUG_LD")))));
    if ((dbg !=0)) {
      uint8_t * pp = primary;
      if ((pp ==0)) {
        (void)((pp = ((uint8_t *)("(null)"))));
      }
      link_diag_ld_debug_push(rel, ((uint8_t *)("primary")), pp);
    }
  }
  uint8_t * p = 0;
  if ((primary !=0)) {
    if (((primary)[0] !=0)) {
      (void)((p = asm_link_obj_skip_missing(primary)));
    }
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg2 = 0;
    (void)((dbg2 = getenv(((uint8_t *)("SHUX_DEBUG_LD")))));
    if ((dbg2 !=0)) {
      uint8_t * ap = p;
      if ((ap ==0)) {
        (void)((ap = ((uint8_t *)("(null)"))));
      }
      link_diag_ld_debug_push(rel, ((uint8_t *)("after-primary")), ap);
    }
  }
  if ((p ==0)) {
    if ((rel !=0)) {
      if (((rel)[0] !=0)) {
        uint8_t * relp = 0;
        (void)((relp = shux_rel_o_path_from_argv0(link_argv0, rel)));
        if ((relp !=0)) {
          (void)((p = asm_link_obj_skip_missing(relp)));
        }
      }
    }
  }
  if ((p ==0)) {
    if ((bank !=0)) {
      if ((rel !=0)) {
        if (((rel)[0] !=0)) {
          (void)((p = shux_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank)));
        }
      }
    }
  }
  if ((p ==0)) {
    return 0;
  }
  if ((bank !=0)) {
    uint8_t * bp = 0;
    (void)((bp = shux_asm_ld_bank_push(bank, p)));
    if ((bp ==0)) {
      return 0;
    }
    (void)((p = bp));
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg3 = 0;
    (void)((dbg3 = getenv(((uint8_t *)("SHUX_DEBUG_LD")))));
    if ((dbg3 !=0)) {
      uint8_t * fp = p;
      if ((fp ==0)) {
        (void)((fp = ((uint8_t *)("(null)"))));
      }
      link_diag_ld_debug_push(rel, ((uint8_t *)("final")), fp);
    }
  }
  int32_t before = (la)[0];
  link_abi_asm_ld_argv_push_stable(0, argv, la, max_la, p);
  if (((la)[0] <=before)) {
    return 0;
  }
  if ((flag_out !=0)) {
    (void)(((flag_out)[0] = 1));
  }
  return 1;
}
/* wave149: push_glue_after_std pure orch (surface pin; Cap residual call_ensure). */
void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la) {
  if ((have_std ==0)) {
    return;
  }
  if ((ensure_fn !=0)) {
    int32_t rc = 0;
    (void)((rc = link_abi_call_ensure_argv0(ensure_fn, link_argv0)));
    if ((rc !=0)) {
      return;
    }
  }
  int32_t _pushed = link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pushed ==0)) {
    return;
  }
}
/* wave150: push_minimal_runtime_objs pure orch (surface pin; Cap residual *_o_path). */
void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la) {
  uint8_t * io_p = 0;
  uint8_t * proc_p = 0;
  uint8_t * panic_p = 0;
  (void)((io_p = shux_runtime_asm_io_stubs_o_path(link_argv0)));
  (void)((proc_p = shux_runtime_process_argv_o_path(link_argv0)));
  (void)((panic_p = shux_runtime_panic_o_path(link_argv0)));
  int32_t _io = link_abi_asm_ld_push_obj(io_p, link_argv0, "compiler/runtime_asm_io_stubs.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_io ==0)) {
  }
  int32_t _pa = link_abi_asm_ld_push_obj(proc_p, link_argv0, "compiler/runtime_process_argv.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pa ==0)) {
  }
  int32_t _pn = link_abi_asm_ld_push_obj(panic_p, link_argv0, "compiler/runtime_panic.o", lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pn ==0)) {
    return;
  }
}
/* wave151: append_user_extra_o_files pure orch (surface pin; Cap residual table+access). */
void shux_asm_ld_append_user_extra_o_files(uint8_t * * argv, int32_t * la, int32_t max_la) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t n = 0;
  (void)((n = link_abi_user_extra_o_count()));
  int32_t ui = 0;
  while ((ui <n)) {
    int32_t cur = (la)[0];
    if ((cur >=(max_la - 1))) {
      break;
    }
    uint8_t * p = 0;
    (void)((p = link_abi_user_extra_o_at(ui)));
    (void)((ui = (ui + 1)));
    if ((p ==0)) {
      continue;
    }
    if (((p)[0] ==0)) {
      continue;
    }
    int32_t ok = 0;
    (void)((ok = link_abi_path_readable(p)));
    if ((ok ==0)) {
      continue;
    }
    (void)(((argv)[cur] = p));
    (void)(((la)[0] = (cur + 1)));
  }
}
/* wave160: compiler_o_path_copy pure orch (surface pin; Cap residual shu_resolve_compiler_dir). */
int32_t shux_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz) {
  if ((out == 0)) {
    return -1;
  }
  if ((out_sz == 0)) {
    return -1;
  }
  if ((leaf == 0)) {
    return -1;
  }
  if (((leaf)[0] == 0)) {
    return -1;
  }
  (void)(((out)[0] = 0));
  uint8_t comp_dir[4096];
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp_dir)[0]), 4096)));
  if ((rc != 0)) {
    return -1;
  }
  int32_t dn = 0;
  while (((comp_dir)[dn] != 0)) {
    (void)((dn = (dn + 1)));
  }
  int32_t ln = 0;
  while (((leaf)[ln] != 0)) {
    (void)((ln = (ln + 1)));
  }
  int64_t need = ((((int64_t)(dn)) + 1) + ((int64_t)(ln)));
  if ((need >= out_sz)) {
    (void)(((out)[0] = 0));
    return -1;
  }
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out)[i] = (comp_dir)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out)[dn] = 47));
  int32_t k = 0;
  while ((k <= ln)) {
    (void)(((out)[(dn + 1) + k] = (leaf)[k]));
    (void)((k = (k + 1)));
  }
  return 0;
}
int32_t labi_path_pure_count(void) {
  return 17;
}
