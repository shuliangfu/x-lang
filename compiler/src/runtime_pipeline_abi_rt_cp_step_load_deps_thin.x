/**
 * Thin twin of rt_cp_step_load_deps (logic matches the .c).
 * Root (s43 SI check): this face calloc(n_deps) then pipeline_set_dep_slots
 *   always walks 32 slots → pipe_load_ptr_slot SIGSEGV at i=24 when the
 *   table is short (SI n_deps=3). asm-backend already calloc(32). The
 *   Windows fold vehicle is the .c; idx8 of thins with calls AVs in typool
 *   va_cap; use host-cc of the .c. Fold this name only.
 * PLATFORM: SHARED — 32-wide dep tables; dual-host prove.
 */
export extern function malloc(n: usize): *u8;
export extern function memset(p: *u8, c: i32, n: usize): *u8;
export extern function driver_parsed_work_p_get(i: i32): *u8;
export extern function driver_parsed_work_p_set(i: i32, v: *u8): void;
export extern function driver_parsed_work_i_get(i: i32): i32;
export extern function driver_parsed_work_i_set(i: i32, v: i32): void;
export extern function driver_parsed_work_z_get(i: i32): usize;
export extern function driver_ptr_table_calloc(n: i32): *u8;
export extern function driver_ptr_table_free(t: *u8): void;
export extern function driver_ptr_table_set(t: *u8, i: i32, p: *u8): void;
export extern function driver_size_table_calloc(n: i32): *u8;
export extern function driver_size_table_free(t: *u8): void;
export extern function xlang_collect_deps_transitive(
  module: *u8, arena_sz: usize, module_sz: usize, lib_roots: *u8, n_lib: i32,
  entry_dir: *u8, defines: *u8, n_defines: i32,
  cls: *u8, clens: *u8, cpaths: *u8, n_closure: *i32): i32;
export extern function driver_codegen_outbuf_calloc(): *u8;
export extern function driver_codegen_outbuf_free(p: *u8): void;
export extern function driver_pipeline_dep_ctx_calloc(): *u8;
export extern function pipeline_dep_ctx_heap_destroy(ctx: *u8): void;
export extern function xlang_pipeline_fill_ctx_path_buffers(
  ctx: *u8, entry_dir: *u8, lib_roots: *u8, n_lib: i32): void;
export extern function xlang_pipeline_pctx_seed_dep_slots(
  ctx: *u8, dep_mods: *u8, dep_ar: *u8, dep_paths: *u8, n: i32): void;
export extern function driver_pipeline_dep_ctx_set_skip_codegen_dep_0(ctx: *u8, v: i32): void;
export extern function rt_cp_diag(path: *u8, kind_fn: i32, code_fn: i32, msg_fn: i32): void;
export extern function rt_run_compiler_parsed_rt_cp_release_arena_module(arena: *u8, module: *u8): void;

#[no_mangle]
export function rt_cp_step_load_deps(): i32 {
  let module: *u8 = 0 as *u8;
  let asz: usize = 0;
  let msz: usize = 0;
  let lib: *u8 = 0 as *u8;
  let nlib: i32 = 0;
  let entry: *u8 = 0 as *u8;
  let defs: *u8 = 0 as *u8;
  let ndef: i32 = 0;
  let nimp: i32 = 0;
  let dsrc: *u8 = 0 as *u8;
  let dpath: *u8 = 0 as *u8;
  let dlens: *u8 = 0 as *u8;
  let dar: *u8 = 0 as *u8;
  let dmod: *u8 = 0 as *u8;
  let n_deps: i32 = 0;
  let out_buf: *u8 = 0 as *u8;
  let pctx: *u8 = 0 as *u8;
  let j: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    module = driver_parsed_work_p_get(4);
    asz = driver_parsed_work_z_get(1);
    msz = driver_parsed_work_z_get(2);
    lib = driver_parsed_work_p_get(16);
    nlib = driver_parsed_work_i_get(0);
    entry = driver_parsed_work_p_get(5);
    defs = driver_parsed_work_p_get(22);
    ndef = driver_parsed_work_i_get(6);
    nimp = driver_parsed_work_i_get(2);
  }
  if (nimp > 0) {
    if (nimp <= 32) {
      unsafe {
        dsrc = driver_ptr_table_calloc(128);
        dpath = driver_ptr_table_calloc(128);
        dlens = driver_size_table_calloc(128);
      }
      if (dsrc == 0 as *u8) { return 1; }
      if (dpath == 0 as *u8) {
        unsafe { driver_ptr_table_free(dsrc); }
        return 1;
      }
      if (dlens == 0 as *u8) {
        unsafe {
          driver_ptr_table_free(dsrc);
          driver_ptr_table_free(dpath);
        }
        return 1;
      }
      unsafe {
        rc = xlang_collect_deps_transitive(
          module, asz, msz, lib, nlib, entry, defs, ndef, dsrc, dlens, dpath, &n_deps);
      }
      if (rc != 0) {
        unsafe {
          driver_ptr_table_free(dsrc);
          driver_ptr_table_free(dpath);
          driver_size_table_free(dlens);
        }
        return 1;
      }
      unsafe {
        driver_parsed_work_p_set(6, dsrc);
        driver_parsed_work_p_set(7, dpath);
        driver_parsed_work_p_set(8, dlens);
        driver_parsed_work_i_set(1, n_deps);
      }
    }
  }
  unsafe {
    n_deps = driver_parsed_work_i_get(1);
  }
  if (n_deps > 0) {
    unsafe {
      dar = driver_ptr_table_calloc(32);
      dmod = driver_ptr_table_calloc(32);
    }
    if (dar == 0 as *u8) { return 1; }
    if (dmod == 0 as *u8) {
      unsafe { driver_ptr_table_free(dar); }
      return 1;
    }
    j = n_deps - 1;
    while (j >= 0) {
      let a: *u8 = 0 as *u8;
      let m: *u8 = 0 as *u8;
      unsafe {
        a = malloc(asz);
        m = malloc(msz);
      }
      if (a == 0 as *u8) {
        unsafe {
          rt_run_compiler_parsed_rt_cp_release_arena_module(0 as *u8, m);
          rt_cp_diag(0 as *u8, 3, 5, 6);
          driver_ptr_table_free(dar);
          driver_ptr_table_free(dmod);
        }
        return 1;
      }
      if (m == 0 as *u8) {
        unsafe {
          rt_run_compiler_parsed_rt_cp_release_arena_module(a, 0 as *u8);
          rt_cp_diag(0 as *u8, 3, 5, 6);
          driver_ptr_table_free(dar);
          driver_ptr_table_free(dmod);
        }
        return 1;
      }
      unsafe {
        memset(a, 0, asz);
        memset(m, 0, msz);
        driver_ptr_table_set(dar, j, a);
        driver_ptr_table_set(dmod, j, m);
      }
      j = j - 1;
    }
    unsafe {
      driver_parsed_work_p_set(9, dar);
      driver_parsed_work_p_set(10, dmod);
    }
  }
  unsafe {
    out_buf = driver_codegen_outbuf_calloc();
    pctx = driver_pipeline_dep_ctx_calloc();
  }
  if (out_buf == 0 as *u8) {
    if (pctx != 0 as *u8) {
      unsafe { pipeline_dep_ctx_heap_destroy(pctx); }
    }
    unsafe { rt_cp_diag(0 as *u8, 3, 6, 7); }
    return 1;
  }
  if (pctx == 0 as *u8) {
    unsafe {
      driver_codegen_outbuf_free(out_buf);
      rt_cp_diag(0 as *u8, 3, 6, 7);
    }
    return 1;
  }
  unsafe {
    xlang_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib);
    dmod = driver_parsed_work_p_get(10);
    dar = driver_parsed_work_p_get(9);
    dpath = driver_parsed_work_p_get(7);
    n_deps = driver_parsed_work_i_get(1);
    xlang_pipeline_pctx_seed_dep_slots(pctx, dmod, dar, dpath, n_deps);
    driver_pipeline_dep_ctx_set_skip_codegen_dep_0(pctx, 0);
    driver_parsed_work_p_set(11, out_buf);
    driver_parsed_work_p_set(12, pctx);
  }
  return 0;
}
