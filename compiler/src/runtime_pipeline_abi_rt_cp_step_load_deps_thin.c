/*
 * Host-gcc twin of rt_cp_step_load_deps.
 * Root (s43 SI check): typool/gcc of this face calls driver_ptr_table_calloc(n_deps)
 *   (SI n_deps=3) and later rt_cp_step_pipeline → pipeline_set_dep_slots always
 *   walks 32 slots. gdb: pipe_load_ptr_slot+86 movzbl at i=24, off=0xc0,
 *   modules base ends at a page boundary (0x...f000). The loader itself is
 *   gcc-correct (i*8); the table is short. asm-backend already calloc(32)
 *   for the same reason (option n_deps=1). SI build uses that 32-wide path
 *   and is a later residual (post-SEH RIP=0 after funcs=1) — not this face.
 * Fold allowlist: rt_cp_step_load_deps only. Keep mid_ret / i32_le hooks.
 * PLATFORM: WINDOWS — PE fold first-wins; typool T JMP to this face.
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

uint8_t *driver_parsed_work_p_get(int32_t i);
void driver_parsed_work_p_set(int32_t i, uint8_t *v);
int32_t driver_parsed_work_i_get(int32_t i);
void driver_parsed_work_i_set(int32_t i, int32_t v);
size_t driver_parsed_work_z_get(int32_t i);
void driver_parsed_work_z_set(int32_t i, size_t v);
uint8_t *driver_ptr_table_calloc(int32_t n);
void driver_ptr_table_free(uint8_t *t);
void driver_ptr_table_set(uint8_t *t, int32_t i, uint8_t *p);
uint8_t *driver_size_table_calloc(int32_t n);
void driver_size_table_free(uint8_t *t);
int32_t xlang_collect_deps_transitive(uint8_t *module, size_t arena_sz, size_t module_sz,
                                     uint8_t *lib_roots, int32_t n_lib, uint8_t *entry_dir,
                                     uint8_t *defines, int32_t n_defines,
                                     uint8_t *cls, uint8_t *clens, uint8_t *cpaths,
                                     int32_t *n_closure);
uint8_t *driver_codegen_outbuf_calloc(void);
void driver_codegen_outbuf_free(uint8_t *p);
uint8_t *driver_pipeline_dep_ctx_calloc(void);
void pipeline_dep_ctx_heap_destroy(uint8_t *ctx);
void xlang_pipeline_fill_ctx_path_buffers(uint8_t *ctx, uint8_t *entry_dir,
                                         uint8_t *lib_roots, int32_t n_lib);
void xlang_pipeline_pctx_seed_dep_slots(uint8_t *ctx, uint8_t *dep_mods, uint8_t *dep_ar,
                                       uint8_t *dep_paths, int32_t n);
void driver_pipeline_dep_ctx_set_skip_codegen_dep_0(uint8_t *ctx, int32_t v);
void rt_cp_diag(uint8_t *path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn);
void rt_run_compiler_parsed_rt_cp_release_arena_module(uint8_t *arena, uint8_t *module);

/* work-slot indices: same as pp_ / pi_ / pz_ slot helpers in rt_run_compiler_parsed.x */
#define PP_MODULE 4
#define PP_ENTRY 5
#define PP_DSRC 6
#define PP_DPATH 7
#define PP_DLENS 8
#define PP_DAR 9
#define PP_DMOD 10
#define PP_OUT 11
#define PP_PCTX 12
#define PP_LIB 16
#define PP_DEFS 22
#define PI_NLIB 0
#define PI_NDEPS 1
#define PI_NIMP 2
#define PI_NDEF 6
#define PZ_ASZ 1
#define PZ_MSZ 2

int32_t rt_cp_step_load_deps(void) {
  uint8_t *module;
  size_t asz;
  size_t msz;
  uint8_t *lib;
  int32_t nlib;
  uint8_t *entry;
  uint8_t *defs;
  int32_t ndef;
  int32_t nimp;
  uint8_t *dsrc;
  uint8_t *dpath;
  uint8_t *dlens;
  uint8_t *dar;
  uint8_t *dmod;
  int32_t n_deps;
  uint8_t *out_buf;
  uint8_t *pctx;
  int32_t j;
  int32_t rc;
  uint8_t *a;
  uint8_t *m;

  module = driver_parsed_work_p_get(PP_MODULE);
  asz = driver_parsed_work_z_get(PZ_ASZ);
  msz = driver_parsed_work_z_get(PZ_MSZ);
  lib = driver_parsed_work_p_get(PP_LIB);
  nlib = driver_parsed_work_i_get(PI_NLIB);
  entry = driver_parsed_work_p_get(PP_ENTRY);
  defs = driver_parsed_work_p_get(PP_DEFS);
  ndef = driver_parsed_work_i_get(PI_NDEF);
  nimp = driver_parsed_work_i_get(PI_NIMP);

  dsrc = 0;
  dpath = 0;
  dlens = 0;
  dar = 0;
  dmod = 0;
  n_deps = 0;
  out_buf = 0;
  pctx = 0;

  if (nimp > 0) {
    if (nimp <= 32) {
      dsrc = driver_ptr_table_calloc(128);
      dpath = driver_ptr_table_calloc(128);
      dlens = driver_size_table_calloc(128);
      if (dsrc == 0) {
        return 1;
      }
      if (dpath == 0) {
        driver_ptr_table_free(dsrc);
        return 1;
      }
      if (dlens == 0) {
        driver_ptr_table_free(dsrc);
        driver_ptr_table_free(dpath);
        return 1;
      }
      rc = xlang_collect_deps_transitive(
          module, asz, msz, lib, nlib, entry, defs, ndef, dsrc, dlens, dpath, &n_deps);
      if (rc != 0) {
        driver_ptr_table_free(dsrc);
        driver_ptr_table_free(dpath);
        driver_size_table_free(dlens);
        return 1;
      }
      driver_parsed_work_p_set(PP_DSRC, dsrc);
      driver_parsed_work_p_set(PP_DPATH, dpath);
      driver_parsed_work_p_set(PP_DLENS, dlens);
      driver_parsed_work_i_set(PI_NDEPS, n_deps);
    }
  }

  n_deps = driver_parsed_work_i_get(PI_NDEPS);
  if (n_deps > 0) {
    /* Match pipeline_set_dep_slots walk of 32 slots; do not calloc(n_deps). */
    dar = driver_ptr_table_calloc(32);
    dmod = driver_ptr_table_calloc(32);
    if (dar == 0) {
      return 1;
    }
    if (dmod == 0) {
      driver_ptr_table_free(dar);
      return 1;
    }
    j = n_deps - 1;
    while (j >= 0) {
      a = (uint8_t *)malloc(asz);
      m = (uint8_t *)malloc(msz);
      if (a == 0) {
        rt_run_compiler_parsed_rt_cp_release_arena_module(0, m);
        rt_cp_diag(0, 3, 5, 6);
        driver_ptr_table_free(dar);
        driver_ptr_table_free(dmod);
        return 1;
      }
      if (m == 0) {
        rt_run_compiler_parsed_rt_cp_release_arena_module(a, 0);
        rt_cp_diag(0, 3, 5, 6);
        driver_ptr_table_free(dar);
        driver_ptr_table_free(dmod);
        return 1;
      }
      memset(a, 0, asz);
      memset(m, 0, msz);
      driver_ptr_table_set(dar, j, a);
      driver_ptr_table_set(dmod, j, m);
      j = j - 1;
    }
    driver_parsed_work_p_set(PP_DAR, dar);
    driver_parsed_work_p_set(PP_DMOD, dmod);
  }

  out_buf = driver_codegen_outbuf_calloc();
  pctx = driver_pipeline_dep_ctx_calloc();
  if (out_buf == 0) {
    if (pctx != 0) {
      pipeline_dep_ctx_heap_destroy(pctx);
    }
    rt_cp_diag(0, 3, 6, 7);
    return 1;
  }
  if (pctx == 0) {
    driver_codegen_outbuf_free(out_buf);
    rt_cp_diag(0, 3, 6, 7);
    return 1;
  }
  xlang_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib);
  dmod = driver_parsed_work_p_get(PP_DMOD);
  dar = driver_parsed_work_p_get(PP_DAR);
  dpath = driver_parsed_work_p_get(PP_DPATH);
  n_deps = driver_parsed_work_i_get(PI_NDEPS);
  xlang_pipeline_pctx_seed_dep_slots(pctx, dmod, dar, dpath, n_deps);
  driver_pipeline_dep_ctx_set_skip_codegen_dep_0(pctx, 0);
  driver_parsed_work_p_set(PP_OUT, out_buf);
  driver_parsed_work_p_set(PP_PCTX, pctx);
  return 0;
}
