/* Source-faithful pipeline_asm_wpo_reach_compute_for_elf twin
 * (runtime_pipeline_abi_asm_wpo_thin.x).
 * s139 hang after prerun: prerun returned 0 at 0.704s, typeck method
 * call entered, then live samples sat in typool
 * pipeline_asm_wpo_reach_compute_for_elf (0x1400c49e4) scanning names
 * via pipeline_module_func_name_equal_at -> module_func_at / sidecar.
 * Source `break` after found_root=1 was typool-compiled as
 *   movl $1, found_root; jmp loop_test
 * without leaving the loop or incrementing fi0. Hello's first function
 * is "main", so typool re-compared fi0=0 forever. Same typool
 * break-as-jmp-to-head family as s137 rt_ab_dep_waits_unvisited.
 * typool first-wins WPO state in runtime_pipeline_abi_asm_wpo_thin.o
 * is Lxml end-labeled COMMON/.data (not the leftover pabi_weak g_aw_*
 * locals). Accessors match typool lea SYM-size. docs-only .x, do not idx8.
 */
#include <stdint.h>

/* typool Lxml end labels from first-wins asm_wpo_thin.o (reach_clear relocs). */
extern uint8_t Lxml_47de0326edf5c0f6[]; /* g_aw_nmods, 8 */
extern uint8_t Lxml_5f00fba9edf5c0f6[]; /* g_aw_nfuncs, 8 */
extern uint8_t Lxml_c32abd59edf5c0f6[]; /* g_aw_valid, 8 */
extern uint8_t Lxml_97c78f2fedf5c0f6[]; /* g_aw_reachable, 4096 */
extern int64_t Lxml_eeba97b0edf5c0f6;   /* g_aw_root_id, .data start */

#define g_aw_nmods (*(int32_t *)(Lxml_47de0326edf5c0f6 - 8))
#define g_aw_nfuncs (*(int32_t *)(Lxml_5f00fba9edf5c0f6 - 8))
#define g_aw_valid_slot (*(int64_t *)(Lxml_c32abd59edf5c0f6 - 8))
#define g_aw_reachable (Lxml_97c78f2fedf5c0f6 - 4096)
#define g_aw_root_id Lxml_eeba97b0edf5c0f6

void pipeline_asm_wpo_reach_clear(void);
int32_t pipeline_asm_wpo_dce_env_enabled(void);
int32_t pipeline_module_num_funcs(uint8_t *module);
int32_t pipeline_module_func_name_equal_at(uint8_t *m, int32_t fi, const char *name, int32_t name_len);
int32_t pipeline_module_main_func_index(uint8_t *module);
void pipeline_asm_wpo_set_entry(uint8_t *m);
void pipeline_asm_wpo_set_dep_ctx(uint8_t *c);
int32_t pipeline_asm_wpo_register_mod(uint8_t *m, uint8_t *a);
int32_t pipeline_dep_ctx_ndep(uint8_t *ctx);
uint8_t *pipeline_dep_ctx_module_at(uint8_t *ctx, int32_t j);
uint8_t *pipeline_dep_ctx_arena_at(uint8_t *ctx, int32_t j);
uint8_t *pipeline_asm_wpo_mod_slot(int32_t i);
int32_t pipeline_asm_wpo_register_func(uint8_t *m, int32_t fi);
int32_t pipeline_asm_wpo_func_id_of(uint8_t *m, int32_t fi);
int32_t asm_module_is_pipeline_selfhost(uint8_t *m);
int32_t asm_module_is_typeck_selfhost(uint8_t *m);
int32_t asm_module_is_backend_selfhost(uint8_t *m);
int32_t asm_module_is_driver_compile_selfhost(uint8_t *m);
int32_t pipeline_asm_wpo_is_user_program_entry(void);
int32_t pipeline_asm_wpo_is_user_single_file_pgo_entry(void);
int32_t pipeline_asm_wpo_user_main_func_id(void);
void pipeline_asm_wpo_build_reach(void);
void pipeline_asm_wpo_close_std_heap_helpers(void);
void pipeline_asm_wpo_reach_fixpoint_expand(void);
void pipeline_asm_wpo_mark_pgo_hot(void);
void pipeline_asm_wpo_mark_pgo_depth(void);

void pipeline_asm_wpo_reach_compute_for_elf(uint8_t *entry, uint8_t *entry_arena, uint8_t *ctx) {
  int32_t nf0;
  int32_t fi0;
  int32_t found_root;
  int32_t ndep;
  int32_t j;
  uint8_t *dm;
  uint8_t *da;
  int32_t mi;
  int32_t nm;
  int32_t fi;
  int32_t nf;
  int32_t fi2;
  int32_t main_ix;
  int32_t user_main;
  int32_t user_main2;
  int32_t user_main3;
  int32_t _r;
  int32_t _rf;

  pipeline_asm_wpo_reach_clear();
  if (entry == 0 || entry_arena == 0) {
    return;
  }
  if (pipeline_asm_wpo_dce_env_enabled() == 0) {
    return;
  }
  nf0 = pipeline_module_num_funcs(entry);
  fi0 = 0;
  found_root = 0;
  while (fi0 < nf0) {
    if (pipeline_module_func_name_equal_at(entry, fi0, "main", 4) != 0 ||
        pipeline_module_func_name_equal_at(entry, fi0, "entry", 5) != 0) {
      found_root = 1;
      break;
    }
    fi0 = fi0 + 1;
  }
  if (found_root == 0) {
    return;
  }
  pipeline_asm_wpo_set_entry(entry);
  pipeline_asm_wpo_set_dep_ctx(ctx);
  if (pipeline_asm_wpo_register_mod(entry, entry_arena) < 0) {
    return;
  }
  if (ctx != 0) {
    ndep = pipeline_dep_ctx_ndep(ctx);
    j = 0;
    while (j < ndep) {
      dm = pipeline_dep_ctx_module_at(ctx, j);
      da = pipeline_dep_ctx_arena_at(ctx, j);
      if (dm != 0 && da != 0 && dm != entry) {
        _r = pipeline_asm_wpo_register_mod(dm, da);
        (void)_r;
      }
      j = j + 1;
    }
  }
  mi = 0;
  while (mi < g_aw_nmods) {
    nm = pipeline_module_num_funcs(pipeline_asm_wpo_mod_slot(mi));
    fi = 0;
    while (fi < nm) {
      _rf = pipeline_asm_wpo_register_func(pipeline_asm_wpo_mod_slot(mi), fi);
      (void)_rf;
      fi = fi + 1;
    }
    mi = mi + 1;
  }
  nf = pipeline_module_num_funcs(entry);
  fi2 = 0;
  while (fi2 < nf) {
    if (pipeline_module_func_name_equal_at(entry, fi2, "entry", 5) != 0) {
      g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
      break;
    }
    fi2 = fi2 + 1;
  }
  if (g_aw_root_id < 0) {
    fi2 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "main", 4) != 0) {
        g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
  }
  if (g_aw_root_id < 0 && asm_module_is_pipeline_selfhost(entry) != 0) {
    fi2 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "run_x_pipeline_impl", 19) != 0) {
        g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
  }
  if (g_aw_root_id < 0 && asm_module_is_typeck_selfhost(entry) != 0) {
    fi2 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "typeck_x_ast", 12) != 0) {
        g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
  }
  if (g_aw_root_id < 0 && asm_module_is_backend_selfhost(entry) != 0) {
    fi2 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "asm_codegen_ast", 15) != 0) {
        g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
  }
  if (g_aw_root_id < 0 && asm_module_is_driver_compile_selfhost(entry) != 0) {
    fi2 = 0;
    while (fi2 < nf) {
      if (pipeline_module_func_name_equal_at(entry, fi2, "compile_dispatch_asm_backend", 28) != 0) {
        g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
        break;
      }
      fi2 = fi2 + 1;
    }
    if (g_aw_root_id < 0) {
      fi2 = 0;
      while (fi2 < nf) {
        if (pipeline_module_func_name_equal_at(entry, fi2, "run_compiler_full_x", 19) != 0) {
          g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, fi2);
          break;
        }
        fi2 = fi2 + 1;
      }
    }
  }
  main_ix = pipeline_module_main_func_index(entry);
  if (g_aw_root_id < 0 && main_ix >= 0) {
    if (pipeline_module_func_name_equal_at(entry, main_ix, "main", 4) != 0) {
      g_aw_root_id = pipeline_asm_wpo_func_id_of(entry, main_ix);
    }
  }
  if (g_aw_root_id < 0 || g_aw_nfuncs <= 0) {
    return;
  }
  if (pipeline_asm_wpo_is_user_program_entry() != 0) {
    user_main = pipeline_asm_wpo_user_main_func_id();
    if (user_main >= 0) {
      g_aw_root_id = user_main;
    }
  } else if (pipeline_asm_wpo_is_user_single_file_pgo_entry() != 0) {
    user_main2 = pipeline_asm_wpo_user_main_func_id();
    if (user_main2 >= 0) {
      g_aw_root_id = user_main2;
    }
  }
  pipeline_asm_wpo_build_reach();
  pipeline_asm_wpo_close_std_heap_helpers();
  if (pipeline_asm_wpo_is_user_program_entry() != 0) {
    user_main3 = pipeline_asm_wpo_user_main_func_id();
    if (user_main3 >= 0) {
      g_aw_reachable[user_main3] = 1;
    }
  }
  pipeline_asm_wpo_reach_fixpoint_expand();
  g_aw_valid_slot = 1;
  pipeline_asm_wpo_mark_pgo_hot();
  pipeline_asm_wpo_mark_pgo_depth();
}
