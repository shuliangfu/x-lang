#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
struct PipelineDepCtx {
  int32_t ndep;
  uint8_t entry_dir_buf[512];
  int32_t entry_dir_len;
  int32_t num_lib_roots;
  uint8_t path_buf[512];
  uint8_t loaded_buf[4194304];
  ssize_t loaded_len;
  uint8_t preprocess_buf[4194304];
  int32_t preprocess_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  int32_t target_cpu_features;
  int32_t use_macho_o;
  int32_t use_coff_o;
  int32_t current_block_ref;
  int32_t typeck_loop_depth;
  int32_t current_func_index;
  int32_t skip_codegen_dep_0;
  int32_t entry_already_parsed;
  int32_t current_func_single_empty_param_index;
  int32_t current_func_empty_param_count;
  int32_t current_emit_empty_var_next_index;
  int32_t emit_expr_as_callee;
  uint8_t * current_codegen_module;
  uint8_t * current_codegen_arena;
  int32_t current_codegen_dep_index;
  uint8_t current_codegen_prefix_mirror[64];
  int32_t current_codegen_prefix_len;
  int32_t asm_entry_module_only;
  uint8_t entry_module_import_path_mirror[64];
  int32_t entry_module_import_path_len;
  int32_t typeck_scope_region_len;
  uint8_t typeck_scope_region_label[64];
};

struct CodegenOutBuf {
  uint8_t data[9437184];
  int32_t len;
};

struct DriverXEmitState {
  uint8_t path_buf[512];
  int32_t path_len;
  int32_t emit_extern_imports;
  int32_t use_asm_backend;
  int32_t target_arch;
  uint8_t out_path_buf[512];
  int32_t out_path_len;
};

extern uint8_t * driver_emit_state_key(struct DriverXEmitState * state);
extern void driver_emit_copy_lib_roots_to_ctx(uint8_t * state_key, struct PipelineDepCtx * ctx);
extern void driver_pipeline_dep_ctx_fill_for_emit(struct PipelineDepCtx * ctx, int32_t use_asm, int32_t target);
extern int32_t ew_std_sys_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap);
extern ssize_t ew_fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count);
extern int32_t ew_fs_posix_close_c(int32_t fd);
extern int32_t ew_preprocess_x_buf(uint8_t * source_buf, ssize_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t ew_ensure_source_buffers(struct PipelineDepCtx * ctx);
extern void ew_free_source_buffers(struct PipelineDepCtx * ctx);
extern uint8_t * ew_loaded_buf_ptr(struct PipelineDepCtx * ctx);
extern uint8_t * ew_preprocess_buf_ptr(struct PipelineDepCtx * ctx);
extern void ew_set_loaded_len(struct PipelineDepCtx * ctx, ssize_t n);
extern int32_t ew_lib_root_count(uint8_t * state);
extern int32_t ew_lib_root_len(uint8_t * state, int32_t i);
extern void ew_lib_root_copy(uint8_t * state, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t ew_fs_open_write(uint8_t * path, int32_t path_len);
extern uint8_t * ew_arena_buf(void);
extern uint8_t * ew_module_buf(void);
extern void ew_pipeline_fail_code(int32_t rc, uint8_t * path);
extern void ew_print_x_smoke_summary(uint8_t * module, size_t codegen_len);
extern int32_t ew_set_path(uint8_t * path, int32_t path_len);
extern int32_t ew_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t ew_set_n_lib_roots(int32_t n);
extern int32_t ew_set_emit_extern(int32_t v);
extern int32_t ew_run_x_emit_c(void);
extern int32_t ew_append_lib_root(struct PipelineDepCtx * ctx, uint8_t * path, int32_t len);
extern int32_t driver_run_x_emit_x(struct DriverXEmitState * state);
extern int32_t driver_dispatch_x_emit_to_c(struct DriverXEmitState * state);
extern int32_t std_sys_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap);
extern ssize_t fs_posix_read_c(int32_t fd, uint8_t * buf, size_t count);
extern ssize_t fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count);
extern int32_t fs_posix_close_c(int32_t fd);
extern int32_t preprocess_x_buf(uint8_t * source_buf, ssize_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t pipeline_dep_ctx_ensure_source_buffers(struct PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_free_source_buffers(struct PipelineDepCtx * ctx);
extern uint8_t * pipeline_dep_ctx_loaded_buf_ptr(struct PipelineDepCtx * ctx);
extern uint8_t * pipeline_dep_ctx_preprocess_buf_ptr(struct PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_set_loaded_len(struct PipelineDepCtx * ctx, ssize_t n);
uint8_t * driver_emit_state_key(struct DriverXEmitState * state) {
  return ((uint8_t *)(state));
}
void driver_emit_copy_lib_roots_to_ctx(uint8_t * state_key, struct PipelineDepCtx * ctx) {
  int32_t k = 0;
  int32_t n = ew_lib_root_count(state_key);
  uint8_t tmp[256] = {};
  while ((k < n)) {
    int32_t llen = ew_lib_root_len(state_key, k);
    if ((llen > 0)) {
      (void)(ew_lib_root_copy(state_key, k, &((tmp)[0]), 256));
      (void)(ew_append_lib_root(ctx, &((tmp)[0]), llen));
    }
    (void)((k = (k + 1)));
  }
  (void)(0);
  return;
}
void driver_pipeline_dep_ctx_fill_for_emit(struct PipelineDepCtx * ctx, int32_t use_asm, int32_t target) {
  (void)(((ctx->ndep) = 0));
  (void)(((ctx->entry_dir_len) = 0));
  (void)(((ctx->num_lib_roots) = 0));
  (void)(((ctx->use_asm_backend) = use_asm));
  (void)(((ctx->target_arch) = target));
  (void)(((ctx->current_func_index) = -(1)));
  (void)(((ctx->current_func_single_empty_param_index) = -(1)));
}
extern int32_t driver_emit_lib_root_count(uint8_t * state);
extern int32_t driver_emit_lib_root_len(uint8_t * state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t * state, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t driver_fs_open_read_path(uint8_t * path, int32_t path_len);
extern int32_t driver_fs_open_write(uint8_t * path, int32_t path_len);
extern uint8_t * driver_arena_buf(void);
extern uint8_t * driver_module_buf(void);
extern void driver_pipeline_fail_code(int32_t rc, uint8_t * path);
extern void driver_print_x_smoke_summary(uint8_t * module, size_t codegen_len);
extern int32_t pipeline_run_x_pipeline_impl(uint8_t * module_buf, uint8_t * arena_buf, uint8_t * source, size_t source_len, struct CodegenOutBuf * out, struct PipelineDepCtx * ctx);
extern int32_t driver_run_x_emit_c_set_path(uint8_t * path, int32_t path_len);
extern int32_t driver_run_x_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t driver_run_x_emit_c_set_n_lib_roots(int32_t n);
extern int32_t driver_run_x_emit_c_set_emit_extern(int32_t v);
extern int32_t driver_run_x_emit_c(void);
extern int32_t ast_pipeline_ctx_append_lib_root(struct PipelineDepCtx * ctx, uint8_t * path, int32_t len);
int32_t ew_std_sys_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap) {
  return std_sys_read_file_into(path, buf, cap);
  return 0;
}
ssize_t ew_fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count) {
  return fs_posix_write_c(fd, buf, count);
  return ((ssize_t)(0));
}
int32_t ew_fs_posix_close_c(int32_t fd) {
  return fs_posix_close_c(fd);
  return 0;
}
int32_t ew_preprocess_x_buf(uint8_t * source_buf, ssize_t source_len, uint8_t * out_buf, int32_t out_cap) {
  return preprocess_x_buf(source_buf, source_len, out_buf, out_cap);
  return 0;
}
int32_t ew_ensure_source_buffers(struct PipelineDepCtx * ctx) {
  return pipeline_dep_ctx_ensure_source_buffers(ctx);
  return 0;
}
void ew_free_source_buffers(struct PipelineDepCtx * ctx) {
  (void)(pipeline_dep_ctx_free_source_buffers(ctx));
  (void)(0);
  return;
}
uint8_t * ew_loaded_buf_ptr(struct PipelineDepCtx * ctx) {
  return pipeline_dep_ctx_loaded_buf_ptr(ctx);
  return ((uint8_t *)(0));
}
uint8_t * ew_preprocess_buf_ptr(struct PipelineDepCtx * ctx) {
  return pipeline_dep_ctx_preprocess_buf_ptr(ctx);
  return ((uint8_t *)(0));
}
void ew_set_loaded_len(struct PipelineDepCtx * ctx, ssize_t n) {
  (void)(pipeline_dep_ctx_set_loaded_len(ctx, n));
  (void)(0);
  return;
}
int32_t ew_lib_root_count(uint8_t * state) {
  return driver_emit_lib_root_count(state);
  return 0;
}
int32_t ew_lib_root_len(uint8_t * state, int32_t i) {
  return driver_emit_lib_root_len(state, i);
  return 0;
}
void ew_lib_root_copy(uint8_t * state, int32_t i, uint8_t * dst, int32_t cap) {
  (void)(driver_emit_lib_root_copy(state, i, dst, cap));
  (void)(0);
  return;
}
int32_t ew_fs_open_write(uint8_t * path, int32_t path_len) {
  return driver_fs_open_write(path, path_len);
  return 0;
}
uint8_t * ew_arena_buf(void) {
  return driver_arena_buf();
  return ((uint8_t *)(0));
}
uint8_t * ew_module_buf(void) {
  return driver_module_buf();
  return ((uint8_t *)(0));
}
void ew_pipeline_fail_code(int32_t rc, uint8_t * path) {
  (void)(driver_pipeline_fail_code(rc, path));
  (void)(0);
  return;
}
void ew_print_x_smoke_summary(uint8_t * module, size_t codegen_len) {
  (void)(driver_print_x_smoke_summary(module, codegen_len));
  (void)(0);
  return;
}
int32_t ew_set_path(uint8_t * path, int32_t path_len) {
  return driver_run_x_emit_c_set_path(path, path_len);
  return 0;
}
int32_t ew_set_lib(int32_t i, uint8_t * buf, int32_t len) {
  return driver_run_x_emit_c_set_lib(i, buf, len);
  return 0;
}
int32_t ew_set_n_lib_roots(int32_t n) {
  return driver_run_x_emit_c_set_n_lib_roots(n);
  return 0;
}
int32_t ew_set_emit_extern(int32_t v) {
  return driver_run_x_emit_c_set_emit_extern(v);
  return 0;
}
int32_t ew_run_x_emit_c(void) {
  return driver_run_x_emit_c();
  return 0;
}
int32_t ew_append_lib_root(struct PipelineDepCtx * ctx, uint8_t * path, int32_t len) {
  return ast_pipeline_ctx_append_lib_root(ctx, path, len);
  return 0;
}
int32_t driver_run_x_emit_x(struct DriverXEmitState * state) {
  if ((((state->path_len) >=0) && ((state->path_len) < 511))) {
    (void)((((state->path_buf))[(state->path_len)] = ((uint8_t)(0))));
  }
  struct PipelineDepCtx ctx = (struct PipelineDepCtx){ .ndep = 0, .entry_dir_buf = { 0 }, .entry_dir_len = 0, .num_lib_roots = 0 };
  (void)(driver_pipeline_dep_ctx_fill_for_emit(&(ctx), (state->use_asm_backend), (state->target_arch)));
  if ((ew_ensure_source_buffers(&(ctx)) !=0)) {
    return 1;
  }
  int32_t cap_i = 4194304;
  int32_t n = ew_std_sys_read_file_into(&(((state->path_buf))[0]), ew_loaded_buf_ptr(&(ctx)), cap_i);
  if ((n < 0)) {
    (void)(ew_free_source_buffers(&(ctx)));
    return 1;
  }
  (void)(ew_set_loaded_len(&(ctx), ((ssize_t)(n))));
  int32_t out_len = ew_preprocess_x_buf(ew_loaded_buf_ptr(&(ctx)), n, ew_preprocess_buf_ptr(&(ctx)), 4194304);
  if ((out_len < 0)) {
    (void)(ew_free_source_buffers(&(ctx)));
    return 1;
  }
  (void)(((ctx.preprocess_len) = out_len));
  uint8_t * arena_buf = ew_arena_buf();
  uint8_t * module_buf = ew_module_buf();
  int32_t last_slash = -(1);
  int32_t k = 0;
  while (((k < (state->path_len)) && (k < 512))) {
    if ((((state->path_buf))[k] ==47)) {
      (void)((last_slash = k));
    }
    (void)((k = (k + 1)));
  }
  if ((last_slash >=0)) {
    (void)((k = 0));
    while (((k < last_slash) && (k < 511))) {
      (void)((((ctx.entry_dir_buf))[k] = ((state->path_buf))[k]));
      (void)((k = (k + 1)));
    }
    (void)((((ctx.entry_dir_buf))[k] = 0));
    (void)(((ctx.entry_dir_len) = k));
  } else {
    (void)((((ctx.entry_dir_buf))[0] = 46));
    (void)((((ctx.entry_dir_buf))[1] = 0));
    (void)(((ctx.entry_dir_len) = 1));
  }
  (void)(((ctx.num_lib_roots) = 0));
  (void)(driver_emit_copy_lib_roots_to_ctx(driver_emit_state_key(state), &(ctx)));
  struct CodegenOutBuf out = (struct CodegenOutBuf){ .data = { 0 }, .len = 0 };
  size_t source_len = ((size_t)(out_len));
  uint8_t * prep_src = ew_preprocess_buf_ptr(&(ctx));
  int32_t rc = 0;
  (void)((rc = pipeline_run_x_pipeline_impl(module_buf, arena_buf, prep_src, source_len, &(out), &(ctx))));
  if ((rc !=0)) {
    (void)(ew_pipeline_fail_code(rc, &(((ctx.path_buf))[0])));
    (void)(ew_free_source_buffers(&(ctx)));
    return 1;
  }
  int32_t len = (out.len);
  if (((state->out_path_len) ==0)) {
    (void)(ew_print_x_smoke_summary(module_buf, ((size_t)(len))));
  }
  if (((state->out_path_len) > 0)) {
    int32_t wfd = ew_fs_open_write((state->out_path_buf), (state->out_path_len));
    if ((wfd < 0)) {
      (void)(ew_free_source_buffers(&(ctx)));
      return 1;
    }
    if ((len > 262144)) {
      ssize_t written = ew_fs_posix_write_c(wfd, &(((out.data))[0]), 262144);
      (void)(ew_fs_posix_close_c(wfd));
      if (((written < 0) || (((int32_t)(written)) !=262144))) {
        (void)(ew_free_source_buffers(&(ctx)));
        return 1;
      }
    } else {
      ssize_t written = ew_fs_posix_write_c(wfd, &(((out.data))[0]), ((size_t)(len)));
      (void)(ew_fs_posix_close_c(wfd));
      if (((written < 0) || (((int32_t)(written)) !=len))) {
        (void)(ew_free_source_buffers(&(ctx)));
        return 1;
      }
    }
  } else {
    if ((len > 262144)) {
      ssize_t written = ew_fs_posix_write_c(1, &(((out.data))[0]), 262144);
      if (((written < 0) || (((int32_t)(written)) !=262144))) {
        (void)(ew_free_source_buffers(&(ctx)));
        return 1;
      }
    } else {
      ssize_t written = ew_fs_posix_write_c(1, &(((out.data))[0]), ((size_t)(len)));
      if (((written < 0) || (((int32_t)(written)) !=len))) {
        (void)(ew_free_source_buffers(&(ctx)));
        return 1;
      }
    }
  }
  (void)(ew_free_source_buffers(&(ctx)));
  return 0;
}
int32_t driver_dispatch_x_emit_to_c(struct DriverXEmitState * state) {
  (void)(ew_set_emit_extern((state->emit_extern_imports)));
  (void)(ew_set_path((state->path_buf), (state->path_len)));
  int32_t k = 0;
  int32_t n_roots = ew_lib_root_count(driver_emit_state_key(state));
  uint8_t lib_tmp[256] = {};
  while ((k < n_roots)) {
    int32_t llen = ew_lib_root_len(driver_emit_state_key(state), k);
    (void)(ew_lib_root_copy(driver_emit_state_key(state), k, &((lib_tmp)[0]), 256));
    (void)(ew_set_lib(k, &((lib_tmp)[0]), llen));
    (void)((k = (k + 1)));
  }
  (void)(ew_set_n_lib_roots(n_roots));
  return ew_run_x_emit_c();
}
