/* Source-faithful rt_ab_step_prerun twin (rt_run_asm_backend.x).
 * s135 typool zeroed prerun_seen u8[32] as 8-byte scale-8 stores
 * starting at lea -0xe8(%rbp): store at 0x140228fb6 movq $0,(%rbx)
 * with rbx = return slot 0x103fd488 (index 30), after already
 * zeroing saved rbp (index 29). First-chance execute-at-0 follows
 * the typool epilogue ret. Source already addresses through *u8
 * for byte stores; typool still emitted scale-8. Only this proven
 * function; cousins (path_buf, later prerun_seen_p[j]=1 which is
 * already scale-1) are not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t driver_asm_work_i_get(int32_t i);
extern uint8_t *driver_asm_work_p_get(int32_t i);
extern int32_t ai_ndeps(void);
extern int32_t ai_emit_elf(void);
extern int32_t ai_smoke(void);
extern int32_t ai_entry_only(void);
extern int32_t ai_nlib(void);
extern int32_t ap_dar(void);
extern int32_t ap_dmod(void);
extern int32_t ap_dsrc(void);
extern int32_t ap_dpath(void);
extern int32_t ap_dlens(void);
extern int32_t ap_lib(void);
extern int32_t ap_entry(void);
extern int32_t ap_pctx(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t rt_run_asm_backend_rt_ab_prerun_next_slot(uint8_t *ds, uint8_t *dl, uint8_t *dp, int32_t n_deps, uint8_t *seen);
extern uint8_t *driver_ptr_table_get(uint8_t *t, int32_t i);
extern size_t driver_size_table_get(uint8_t *t, int32_t i);
extern int32_t xlang_pipeline_dep_prerun_parse_only(uint8_t *dep_mod, uint8_t *dep_arena, uint8_t *src, int64_t len);
extern void rt_ab_diag(uint8_t *path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn);
extern void driver_dep_publish_slot(int32_t j, uint8_t *arena, uint8_t *module, uint8_t *path);
extern uint8_t *driver_pipeline_dep_ctx_calloc(void);
extern uint8_t *driver_codegen_outbuf_calloc(void);
extern void driver_codegen_outbuf_free(uint8_t *p);
extern void pipeline_dep_ctx_heap_destroy(uint8_t *ctx);
extern int32_t xlang_asm_user_std_dep_skip_x_typeck(uint8_t *dep_path);
extern int32_t xlang_asm_user_dep_parse_skip_typeck_path(uint8_t *dep_path);
extern int32_t driver_asm_use_compiler_impl_c(void);
extern uint8_t *xlang_dep_prerun_entry_dir(uint8_t *main_entry_dir, uint8_t *lib_roots, int32_t n_lib_roots);
extern void xlang_pipeline_fill_ctx_path_buffers(uint8_t *ctx, uint8_t *entry_dir, uint8_t *lib_roots, int32_t n_lib_roots);
extern void xlang_pipeline_one_ctx_for_dep_prerun(uint8_t *ctx, int32_t j, uint8_t *dep_mods, uint8_t *dep_ars, uint8_t *dep_paths, int32_t ndep, uint8_t *dep_src, int64_t dep_src_len);
extern int32_t xlang_pipeline_dep_prerun_parse_skip_typeck(uint8_t *dep_mod, uint8_t *dep_arena, uint8_t *src, int64_t len, uint8_t *dep_out, uint8_t *one_ctx);
extern int32_t xlang_asm_user_std_net_dep_path(uint8_t *dep_path);
extern void pipeline_asm_seed_std_net_struct_layouts(uint8_t *m);
extern int32_t xlang_pipeline_dep_prerun_for_asm_module_o(uint8_t *dep_mod, uint8_t *dep_arena, uint8_t *src, int64_t len, uint8_t *dep_out, uint8_t *one_ctx);

int32_t rt_ab_step_prerun(void) {
  int32_t n_deps = 0;
  int32_t emit_elf = 0;
  int32_t smoke = 0;
  int32_t eo = 0;
  int32_t j = 0;
  uint8_t *da = 0;
  uint8_t *dm = 0;
  uint8_t *ds = 0;
  uint8_t *dp = 0;
  uint8_t *dl = 0;
  uint8_t *lib = 0;
  int32_t nlib = 0;
  uint8_t *entry = 0;
  uint8_t *pctx = 0;
  uint8_t *one = 0;
  uint8_t *dep_out = 0;
  uint8_t *dep_src = 0;
  size_t dep_len = 0;
  uint8_t *dep_path = 0;
  uint8_t *prerun_dir = 0;
  int32_t ec_loop = 0;
  int32_t skip_tk = 0;
  int32_t need_import_map = 0;
  uint8_t prerun_seen[32];
  uint8_t *prerun_seen_p = 0;
  int32_t prerun_zi = 0;
  int32_t prerun_step = 0;
  int32_t prerun_topo = 0;

  n_deps = driver_asm_work_i_get(ai_ndeps());
  emit_elf = driver_asm_work_i_get(ai_emit_elf());
  smoke = driver_asm_work_i_get(ai_smoke());
  eo = driver_asm_work_i_get(ai_entry_only());
  da = driver_asm_work_p_get(ap_dar());
  dm = driver_asm_work_p_get(ap_dmod());
  ds = driver_asm_work_p_get(ap_dsrc());
  dp = driver_asm_work_p_get(ap_dpath());
  dl = driver_asm_work_p_get(ap_dlens());
  lib = driver_asm_work_p_get(ap_lib());
  nlib = driver_asm_work_i_get(ai_nlib());
  entry = driver_asm_work_p_get(ap_entry());
  pctx = driver_asm_work_p_get(ap_pctx());
  (void)pctx;

  if (n_deps <= 0) {
    return 0;
  }
  skip_tk = driver_asm_build_skip_typeck();
  prerun_topo = 1;
  if (n_deps > 32) {
    prerun_topo = 0;
  }
  prerun_seen_p = &prerun_seen[0];
  prerun_zi = 0;
  while (prerun_zi < 32) {
    prerun_seen_p[prerun_zi] = 0;
    prerun_zi = prerun_zi + 1;
  }
  if (emit_elf != 0) {
    if (eo != 0) {
      if (skip_tk != 0) {
        prerun_step = 0;
        while (prerun_step < n_deps) {
          if (prerun_topo != 0) {
            j = rt_run_asm_backend_rt_ab_prerun_next_slot(ds, dl, dp, n_deps, prerun_seen_p);
          } else {
            j = prerun_step;
          }
          dep_src = driver_ptr_table_get(ds, j);
          dep_len = driver_size_table_get(dl, j);
          dep_path = driver_ptr_table_get(dp, j);
          ec_loop = xlang_pipeline_dep_prerun_parse_only(
              driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
              dep_src, (int64_t)dep_len);
          if (ec_loop != 0) {
            rt_ab_diag(dep_path, 4, 9, 5);
            return 1;
          }
          driver_dep_publish_slot(
              j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path);
          if (prerun_topo != 0) {
            if (j >= 0) {
              if (j < 32) {
                prerun_seen_p[j] = 1;
              }
            }
          }
          prerun_step = prerun_step + 1;
        }
        return 0;
      }
    }
  }
  prerun_step = 0;
  while (prerun_step < n_deps) {
    if (prerun_topo != 0) {
      j = rt_run_asm_backend_rt_ab_prerun_next_slot(ds, dl, dp, n_deps, prerun_seen_p);
    } else {
      j = prerun_step;
    }
    one = driver_pipeline_dep_ctx_calloc();
    dep_out = driver_codegen_outbuf_calloc();
    dep_src = driver_ptr_table_get(ds, j);
    dep_len = driver_size_table_get(dl, j);
    dep_path = driver_ptr_table_get(dp, j);
    if (one == 0) {
      if (dep_out != 0) {
        driver_codegen_outbuf_free(dep_out);
      }
      rt_ab_diag(0, 3, 6, 7);
      return 1;
    }
    if (dep_out == 0) {
      pipeline_dep_ctx_heap_destroy(one);
      rt_ab_diag(0, 3, 6, 7);
      return 1;
    }
    need_import_map = 1;
    if (smoke != 0) {
      need_import_map = 0;
    } else {
      if (emit_elf != 0) {
        if (xlang_asm_user_std_dep_skip_x_typeck(dep_path) != 0) {
          need_import_map = 0;
        } else {
          if (xlang_asm_user_dep_parse_skip_typeck_path(dep_path) != 0) {
            need_import_map = 1;
          } else {
            if (skip_tk == 0) {
              if (eo != 0) {
                need_import_map = 0;
              } else {
                if (driver_asm_use_compiler_impl_c() != 0) {
                  need_import_map = 0;
                }
              }
            }
          }
        }
      }
    }
    if (need_import_map != 0) {
      prerun_dir = xlang_dep_prerun_entry_dir(entry, lib, nlib);
      xlang_pipeline_fill_ctx_path_buffers(one, prerun_dir, lib, nlib);
      xlang_pipeline_one_ctx_for_dep_prerun(one, j, dm, da, dp, n_deps, dep_src, (int64_t)dep_len);
    }
    if (smoke != 0) {
      ec_loop = xlang_pipeline_dep_prerun_parse_only(
          driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
          dep_src, (int64_t)dep_len);
    } else {
      if (emit_elf != 0) {
        if (xlang_asm_user_std_dep_skip_x_typeck(dep_path) != 0) {
          ec_loop = xlang_pipeline_dep_prerun_parse_only(
              driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
              dep_src, (int64_t)dep_len);
        } else {
          if (xlang_asm_user_dep_parse_skip_typeck_path(dep_path) != 0) {
            ec_loop = xlang_pipeline_dep_prerun_parse_skip_typeck(
                driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                dep_src, (int64_t)dep_len, dep_out, one);
            if (ec_loop == 0) {
              if (xlang_asm_user_std_net_dep_path(dep_path) != 0) {
                pipeline_asm_seed_std_net_struct_layouts(driver_ptr_table_get(dm, j));
              }
            }
          } else {
            if (eo != 0) {
              if (skip_tk == 0) {
                ec_loop = xlang_pipeline_dep_prerun_parse_only(
                    driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                    dep_src, (int64_t)dep_len);
              } else {
                if (driver_asm_use_compiler_impl_c() != 0) {
                  if (skip_tk == 0) {
                    ec_loop = xlang_pipeline_dep_prerun_parse_only(
                        driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                        dep_src, (int64_t)dep_len);
                  } else {
                    ec_loop = xlang_pipeline_dep_prerun_for_asm_module_o(
                        driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                        dep_src, (int64_t)dep_len, dep_out, one);
                  }
                } else {
                  ec_loop = xlang_pipeline_dep_prerun_for_asm_module_o(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, (int64_t)dep_len, dep_out, one);
                }
              }
            } else {
              if (driver_asm_use_compiler_impl_c() != 0) {
                if (skip_tk == 0) {
                  ec_loop = xlang_pipeline_dep_prerun_parse_only(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, (int64_t)dep_len);
                } else {
                  ec_loop = xlang_pipeline_dep_prerun_for_asm_module_o(
                      driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                      dep_src, (int64_t)dep_len, dep_out, one);
                }
              } else {
                ec_loop = xlang_pipeline_dep_prerun_for_asm_module_o(
                    driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
                    dep_src, (int64_t)dep_len, dep_out, one);
              }
            }
          }
        }
      } else {
        ec_loop = xlang_pipeline_dep_prerun_for_asm_module_o(
            driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j),
            dep_src, (int64_t)dep_len, dep_out, one);
      }
    }
    pipeline_dep_ctx_heap_destroy(one);
    driver_codegen_outbuf_free(dep_out);
    if (ec_loop != 0) {
      rt_ab_diag(dep_path, 3, 8, 8);
      return 1;
    }
    driver_dep_publish_slot(
        j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path);
    if (prerun_topo != 0) {
      if (j >= 0) {
        if (j < 32) {
          prerun_seen_p[j] = 1;
        }
      }
    }
    prerun_step = prerun_step + 1;
  }
  return 0;
}
