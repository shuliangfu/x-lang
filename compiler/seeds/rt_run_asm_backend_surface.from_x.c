/* seeds/rt_run_asm_backend_surface.from_x.c
 * R2 full surface — isomorphic with src/runtime/rt_run_asm_backend.x
 * Product PREFER_X_O: full .x + rest marker (H=0)
 * Regen: shux -E ... rt_run_asm_backend.x | strip DBG + polish libc redecl
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
extern int32_t ap_path(void);
extern int32_t ap_src(void);
extern int32_t ap_out_path(void);
extern int32_t ap_arena(void);
extern int32_t ap_module(void);
extern int32_t ap_entry(void);
extern int32_t ap_dsrc(void);
extern int32_t ap_dpath(void);
extern int32_t ap_dlens(void);
extern int32_t ap_dar(void);
extern int32_t ap_dmod(void);
extern int32_t ap_out(void);
extern int32_t ap_pctx(void);
extern int32_t ap_kind(void);
extern int32_t ap_code(void);
extern int32_t ap_msg(void);
extern int32_t ap_lib(void);
extern int32_t ap_target(void);
extern int32_t ap_argv(void);
extern int32_t ap_asm_out(void);
extern int32_t ap_elf(void);
extern int32_t ap_defs(void);
extern int32_t ap_tmp(void);
extern int32_t ai_nlib(void);
extern int32_t ai_ndeps(void);
extern int32_t ai_nimp(void);
extern int32_t ai_main(void);
extern int32_t ai_emit_elf(void);
extern int32_t ai_want_exe(void);
extern int32_t ai_smoke(void);
extern int32_t ai_ndef(void);
extern int32_t ai_ec(void);
extern int32_t ai_entry_only(void);
extern int32_t az_slen(void);
extern int32_t az_asz(void);
extern int32_t az_msz(void);
extern void rt_ab_fill_kind_io(uint8_t * k);
extern void rt_ab_fill_code_io001(uint8_t * c);
extern void rt_ab_fill_kind_pp(uint8_t * k);
extern void rt_ab_fill_code_pp002(uint8_t * c);
extern void rt_ab_fill_kind_pipe(uint8_t * k);
extern void rt_ab_fill_code_xp001(uint8_t * c);
extern void rt_ab_fill_code_xp005(uint8_t * c);
extern void rt_ab_fill_code_xp006(uint8_t * c);
extern void rt_ab_fill_code_xp008(uint8_t * c);
extern void rt_ab_fill_kind_parse(uint8_t * k);
extern void rt_ab_fill_code_p001(uint8_t * c);
extern void rt_ab_fill_kind_cg(uint8_t * k);
extern void rt_ab_fill_code_cg002(uint8_t * c);
extern void rt_ab_fill_kind_build(uint8_t * k);
extern void rt_ab_fill_code_bld001(uint8_t * c);
extern void rt_ab_msg_cannot_read(uint8_t * m);
extern void rt_ab_msg_pp_failed(uint8_t * m);
extern void rt_ab_msg_alloc_failed(uint8_t * m);
extern void rt_ab_msg_parse_failed(uint8_t * m);
extern void rt_ab_msg_dep_alloc(uint8_t * m);
extern void rt_ab_msg_out_ctx(uint8_t * m);
extern void rt_ab_msg_dep_prerun(uint8_t * m);
extern void rt_ab_msg_pipe_failed(uint8_t * m);
extern void rt_ab_msg_no_funcs(uint8_t * m);
extern void rt_ab_msg_elf_failed(uint8_t * m);
extern void rt_ab_msg_ld_failed(uint8_t * m);
extern void rt_ab_msg_elf_ctx(uint8_t * m);
extern void rt_ab_msg_metric(uint8_t * m);
extern void rt_ab_diag(uint8_t * path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn);
extern int32_t rt_ab_step_read_pp(void);
extern int32_t rt_ab_step_early(void);
extern int32_t rt_ab_step_parse(void);
extern int32_t rt_ab_step_load_deps(void);
extern int32_t rt_ab_step_open_out(void);
extern int32_t rt_ab_step_prerun(void);
extern int32_t rt_ab_step_pipeline(void);
extern int32_t rt_ab_step_finish(void);
extern int32_t driver_run_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * target, int32_t argc, uint8_t * argv);
extern uint8_t * runtime_read_file_malloc(uint8_t * path, size_t * out_len);
extern uint8_t * shux_preprocess_with_path(uint8_t * data, size_t len, uint8_t * path, uint8_t * defines, int32_t n_defines, size_t * out_len);
extern void pipeline_diag_emitted_reset(void);
extern int32_t pipeline_diag_emitted_get(void);
extern void diag_set_file(uint8_t * path, uint8_t * src, size_t len);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern void parser_parse_into_init(uint8_t * module, uint8_t * arena);
extern void parser_parse_into_set_main_index(uint8_t * module, int32_t main_idx);
extern int32_t driver_get_module_num_funcs(uint8_t * m);
extern int32_t parser_get_module_num_imports(uint8_t * module);
extern void shux_get_entry_dir(uint8_t * path, uint8_t * out, size_t out_sz);
extern void driver_dep_seeded_clear_all(void);
extern void driver_dep_publish_slot(int32_t j, uint8_t * arena, uint8_t * module, uint8_t * path);
extern void pipeline_set_dep_slots(uint8_t * arenas, uint8_t * modules);
extern void driver_dep_seed_slots(uint8_t * arenas, uint8_t * modules, int32_t n);
extern void codegen_set_dep_slots_for_x_pipeline(uint8_t * mods, uint8_t * paths, int32_t n);
extern void codegen_set_preamble_has_core_option_result(int32_t on);
extern int32_t runtime_report_precise_parse_failure_if_known(uint8_t * input_path, uint8_t * src, size_t src_len);
extern void pipeline_dep_ctx_heap_destroy(uint8_t * ctx);
extern int32_t shux_pipeline_run_x_pipeline_large_stack(uint8_t * module, uint8_t * arena, uint8_t * src, size_t src_len, uint8_t * out_buf, uint8_t * pctx);
extern void shux_pipeline_fill_ctx_path_buffers(uint8_t * ctx, uint8_t * entry_dir, uint8_t * lib_roots, int32_t n_lib);
extern void shux_pipeline_pctx_seed_dep_slots(uint8_t * ctx, uint8_t * dep_mods, uint8_t * dep_ar, uint8_t * dep_paths, int32_t n);
extern void shux_pipeline_one_ctx_for_dep_prerun(uint8_t * ctx, int32_t j, uint8_t * dep_mods, uint8_t * dep_ar, uint8_t * dep_paths, int32_t n, uint8_t * dep_src, size_t dep_len);
extern int32_t shux_load_direct_imports_for_asm_layout(uint8_t * module, uint8_t * lib_roots, int32_t n_lib, uint8_t * entry_dir, uint8_t * defines, int32_t n_defines, uint8_t * dep_sources, uint8_t * dep_lens, uint8_t * dep_paths, int32_t * n_deps);
extern int32_t shux_collect_deps_transitive(uint8_t * module, size_t arena_sz, size_t module_sz, uint8_t * lib_roots, int32_t n_lib, uint8_t * entry_dir, uint8_t * defines, int32_t n_defines, uint8_t * cls, uint8_t * clens, uint8_t * cpaths, int32_t * n_closure);
extern int32_t shux_merge_direct_then_transitive_deps(uint8_t * module, int32_t n_imports, uint8_t * cls, uint8_t * clens, uint8_t * cpaths, int32_t n_closure, uint8_t * dep_sources, uint8_t * dep_lens, uint8_t * dep_paths, int32_t * n_deps);
extern uint8_t * shux_dep_prerun_entry_dir(uint8_t * entry_dir, uint8_t * lib_roots, int32_t n_lib);
extern int32_t shux_pipeline_dep_prerun_parse_only(uint8_t * mod, uint8_t * arena, uint8_t * src, size_t len);
extern int32_t shux_pipeline_dep_prerun_parse_skip_typeck(uint8_t * mod, uint8_t * arena, uint8_t * src, size_t len, uint8_t * out, uint8_t * ctx);
extern int32_t shux_pipeline_dep_prerun_for_asm_module_o(uint8_t * mod, uint8_t * arena, uint8_t * src, size_t len, uint8_t * out, uint8_t * ctx);
extern int32_t shux_asm_user_std_dep_skip_x_typeck(uint8_t * dep_path);
extern int32_t shux_asm_user_dep_parse_skip_typeck_path(uint8_t * dep_path);
extern int32_t shux_asm_user_std_net_dep_path(uint8_t * dep_path);
extern void pipeline_asm_seed_std_net_struct_layouts(uint8_t * m);
extern int32_t pipeline_asm_user_deps_need_coemit(uint8_t * dep_paths, int32_t n);
extern int32_t shux_output_want_exe(uint8_t * path);
extern int32_t shux_output_is_elf_o(uint8_t * path);
extern int32_t shux_asm_out_buf_is_object(uint8_t * data, size_t len);
extern void shux_driver_asm_prepare_entry_elf_emit(uint8_t * module, uint8_t * arena, uint8_t * pctx);
extern int32_t shux_asm_codegen_elf_o_large_stack(uint8_t * module, uint8_t * arena, uint8_t * pctx, uint8_t * elf_ctx, uint8_t * out_buf);
extern int32_t shux_invoke_ld_for_exe(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho, int32_t use_coff, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib);
/* G.7: CLI user .o table shared with invoke_cc; set/clear around invoke_ld. */
extern void shux_invoke_cc_set_user_o_files_from_argv(int32_t argc, uint8_t * argv);
extern void shux_invoke_cc_clear_user_o_files(void);
extern void runtime_pipeline_elf_ctx_diag_note(uint8_t * ctx_bytes);
extern void runtime_diag_errno_path(uint8_t * file, uint8_t * kind, uint8_t * op, uint8_t * path);
extern void driver_unlink_failed_output(uint8_t * out_path);
extern void driver_bump_stack_limit(void);
extern void cfg_apply_compile_target_from_triple(uint8_t * triple, int32_t len);
extern void cfg_reset_compile_target(void);
extern void driver_set_pipeline_entry_source_len(size_t len);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t driver_asm_entry_module_only_from_env(void);
extern int32_t driver_asm_parse_metric_only_from_env(void);
extern int32_t driver_freestanding_get(void);
extern int32_t driver_check_only_get(void);
extern int32_t driver_check_diag_emitted_get(void);
extern void driver_x_pipeline_skip_typeck_set(int32_t v);
extern void driver_x_pipeline_skip_codegen_set(int32_t v);
extern int32_t driver_deps_are_std_core_closure_only(uint8_t * dep_paths, int32_t n);
extern void driver_print_x_smoke_summary(uint8_t * module, size_t codegen_len);
extern void driver_print_check_ok(uint8_t * input_path);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_after_entry_parse_module(uint8_t * module);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
extern uint8_t * driver_codegen_outbuf_calloc(void);
extern void driver_codegen_outbuf_free(uint8_t * p);
extern int32_t driver_codegen_outbuf_len(uint8_t * p);
extern uint8_t * driver_codegen_outbuf_data(uint8_t * p);
extern uint8_t * driver_pipeline_dep_ctx_calloc(void);
extern uint8_t * driver_ptr_table_calloc(int32_t n);
extern void driver_ptr_table_free(uint8_t * t);
extern uint8_t * driver_ptr_table_get(uint8_t * t, int32_t i);
extern void driver_ptr_table_set(uint8_t * t, int32_t i, uint8_t * p);
extern uint8_t * driver_size_table_calloc(int32_t n);
extern void driver_size_table_free(uint8_t * t);
extern size_t driver_size_table_get(uint8_t * t, int32_t i);
extern void driver_size_table_set(uint8_t * t, int32_t i, size_t v);
extern int32_t driver_parse_into_buf_rc(uint8_t * arena, uint8_t * module, uint8_t * data, int32_t len, int32_t * out_main_idx);
extern void driver_typeck_ndep_set(int32_t n);
extern void driver_typeck_dep_ptrs_set(int32_t j, uint8_t * mod, uint8_t * arena);
extern uint8_t * driver_entry_dir_slot(void);
extern void driver_pipeline_dep_ctx_set_use_asm(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_target_arch(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_target_cpu_features(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_use_macho_o(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_use_coff_o(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_entry_already_parsed(uint8_t * ctx, int32_t v);
extern void driver_pipeline_dep_ctx_set_asm_entry_module_only(uint8_t * ctx, int32_t v);
extern int32_t driver_pipeline_dep_ctx_get_asm_entry_module_only(uint8_t * ctx);
extern int32_t driver_pipeline_dep_ctx_get_use_macho_o(uint8_t * ctx);
extern int32_t driver_pipeline_dep_ctx_get_use_coff_o(uint8_t * ctx);
extern void driver_asm_pctx_apply_host_defaults(uint8_t * ctx, uint8_t * target, int32_t emit_elf_o);
extern uint8_t * driver_asm_fopen_wb(uint8_t * path);
extern uint8_t * driver_asm_mkstemp_fdopen(uint8_t * path_out64);
extern void driver_asm_fclose(uint8_t * fp);
extern int32_t driver_asm_fwrite(uint8_t * fp, uint8_t * data, int32_t len);
extern void driver_asm_fflush_stdout(void);
extern int32_t driver_asm_write_metric_o(uint8_t * path);
extern uint8_t * driver_asm_elf_ctx_calloc(void);
extern void driver_asm_elf_ctx_free(uint8_t * p);
extern uint8_t * driver_asm_tmp_path_slot(void);
extern int32_t driver_asm_collect_defines(int32_t argc, uint8_t * argv);
extern uint8_t * driver_asm_defines_as_u8(void);
extern int32_t driver_asm_ndefines_get(void);
extern uint8_t * driver_asm_bind_lib_roots(uint8_t * lib_roots, int32_t n, int32_t * n_out);
extern uint8_t * driver_asm_argv0(uint8_t * argv);
extern int32_t driver_asm_try_c_frontend_early(uint8_t * input_path, uint8_t * src, uint8_t * lib_roots, int32_t n_lib, uint8_t * out_path);
extern int32_t driver_asm_try_c_typeck_precheck(uint8_t * input_path, uint8_t * src, uint8_t * lib_roots, int32_t n_lib);
extern int32_t driver_asm_use_compiler_impl_c(void);
extern void driver_asm_work_reset(void);
extern uint8_t * driver_asm_work_p_get(int32_t i);
extern void driver_asm_work_p_set(int32_t i, uint8_t * v);
extern int32_t driver_asm_work_i_get(int32_t i);
extern void driver_asm_work_i_set(int32_t i, int32_t v);
extern size_t driver_asm_work_z_get(int32_t i);
extern void driver_asm_work_z_set(int32_t i, size_t v);
extern void driver_asm_work_cleanup(void);
int32_t ap_path(void) {
  return 0;
}
int32_t ap_src(void) {
  return 1;
}
int32_t ap_out_path(void) {
  return 2;
}
int32_t ap_arena(void) {
  return 3;
}
int32_t ap_module(void) {
  return 4;
}
int32_t ap_entry(void) {
  return 5;
}
int32_t ap_dsrc(void) {
  return 6;
}
int32_t ap_dpath(void) {
  return 7;
}
int32_t ap_dlens(void) {
  return 8;
}
int32_t ap_dar(void) {
  return 9;
}
int32_t ap_dmod(void) {
  return 10;
}
int32_t ap_out(void) {
  return 11;
}
int32_t ap_pctx(void) {
  return 12;
}
int32_t ap_kind(void) {
  return 13;
}
int32_t ap_code(void) {
  return 14;
}
int32_t ap_msg(void) {
  return 15;
}
int32_t ap_lib(void) {
  return 16;
}
int32_t ap_target(void) {
  return 17;
}
int32_t ap_argv(void) {
  return 18;
}
int32_t ap_asm_out(void) {
  return 19;
}
int32_t ap_elf(void) {
  return 20;
}
int32_t ap_defs(void) {
  return 21;
}
int32_t ap_tmp(void) {
  return 22;
}
int32_t ai_nlib(void) {
  return 0;
}
int32_t ai_ndeps(void) {
  return 1;
}
int32_t ai_nimp(void) {
  return 2;
}
int32_t ai_main(void) {
  return 3;
}
int32_t ai_emit_elf(void) {
  return 4;
}
int32_t ai_want_exe(void) {
  return 5;
}
int32_t ai_smoke(void) {
  return 6;
}
int32_t ai_ndef(void) {
  return 7;
}
int32_t ai_ec(void) {
  return 9;
}
int32_t ai_entry_only(void) {
  return 11;
}
int32_t az_slen(void) {
  return 0;
}
int32_t az_asz(void) {
  return 1;
}
int32_t az_msz(void) {
  return 2;
}
void rt_ab_fill_kind_io(uint8_t * k) {
  (void)(((k)[0] = 105));
  (void)(((k)[1] = 111));
  (void)(((k)[2] = 32));
  (void)(((k)[3] = 101));
  (void)(((k)[4] = 114));
  (void)(((k)[5] = 114));
  (void)(((k)[6] = 111));
  (void)(((k)[7] = 114));
  (void)(((k)[8] = 0));
}
void rt_ab_fill_code_io001(uint8_t * c) {
  (void)(((c)[0] = 73));
  (void)(((c)[1] = 79));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 49));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_kind_pp(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 114));
  (void)(((k)[2] = 101));
  (void)(((k)[3] = 112));
  (void)(((k)[4] = 114));
  (void)(((k)[5] = 111));
  (void)(((k)[6] = 99));
  (void)(((k)[7] = 101));
  (void)(((k)[8] = 115));
  (void)(((k)[9] = 115));
  (void)(((k)[10] = 32));
  (void)(((k)[11] = 101));
  (void)(((k)[12] = 114));
  (void)(((k)[13] = 114));
  (void)(((k)[14] = 111));
  (void)(((k)[15] = 114));
  (void)(((k)[16] = 0));
}
void rt_ab_fill_code_pp002(uint8_t * c) {
  (void)(((c)[0] = 80));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 50));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_kind_pipe(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 105));
  (void)(((k)[2] = 112));
  (void)(((k)[3] = 101));
  (void)(((k)[4] = 108));
  (void)(((k)[5] = 105));
  (void)(((k)[6] = 110));
  (void)(((k)[7] = 101));
  (void)(((k)[8] = 32));
  (void)(((k)[9] = 101));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 114));
  (void)(((k)[12] = 111));
  (void)(((k)[13] = 114));
  (void)(((k)[14] = 0));
}
void rt_ab_fill_code_xp001(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 49));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_code_xp005(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 53));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_code_xp006(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 54));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_code_xp008(uint8_t * c) {
  (void)(((c)[0] = 88));
  (void)(((c)[1] = 80));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 56));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_kind_parse(uint8_t * k) {
  (void)(((k)[0] = 112));
  (void)(((k)[1] = 97));
  (void)(((k)[2] = 114));
  (void)(((k)[3] = 115));
  (void)(((k)[4] = 101));
  (void)(((k)[5] = 32));
  (void)(((k)[6] = 101));
  (void)(((k)[7] = 114));
  (void)(((k)[8] = 114));
  (void)(((k)[9] = 111));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 0));
}
void rt_ab_fill_code_p001(uint8_t * c) {
  (void)(((c)[0] = 80));
  (void)(((c)[1] = 48));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 49));
  (void)(((c)[4] = 0));
}
void rt_ab_fill_kind_cg(uint8_t * k) {
  (void)(((k)[0] = 99));
  (void)(((k)[1] = 111));
  (void)(((k)[2] = 100));
  (void)(((k)[3] = 101));
  (void)(((k)[4] = 103));
  (void)(((k)[5] = 101));
  (void)(((k)[6] = 110));
  (void)(((k)[7] = 32));
  (void)(((k)[8] = 101));
  (void)(((k)[9] = 114));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 111));
  (void)(((k)[12] = 114));
  (void)(((k)[13] = 0));
}
void rt_ab_fill_code_cg002(uint8_t * c) {
  (void)(((c)[0] = 67));
  (void)(((c)[1] = 71));
  (void)(((c)[2] = 48));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 50));
  (void)(((c)[5] = 0));
}
void rt_ab_fill_kind_build(uint8_t * k) {
  (void)(((k)[0] = 98));
  (void)(((k)[1] = 117));
  (void)(((k)[2] = 105));
  (void)(((k)[3] = 108));
  (void)(((k)[4] = 100));
  (void)(((k)[5] = 32));
  (void)(((k)[6] = 101));
  (void)(((k)[7] = 114));
  (void)(((k)[8] = 114));
  (void)(((k)[9] = 111));
  (void)(((k)[10] = 114));
  (void)(((k)[11] = 0));
}
void rt_ab_fill_code_bld001(uint8_t * c) {
  (void)(((c)[0] = 66));
  (void)(((c)[1] = 76));
  (void)(((c)[2] = 68));
  (void)(((c)[3] = 48));
  (void)(((c)[4] = 48));
  (void)(((c)[5] = 49));
  (void)(((c)[6] = 0));
}
void rt_ab_msg_cannot_read(uint8_t * m) {
  (void)(((m)[0] = 99));
  (void)(((m)[1] = 97));
  (void)(((m)[2] = 110));
  (void)(((m)[3] = 110));
  (void)(((m)[4] = 111));
  (void)(((m)[5] = 116));
  (void)(((m)[6] = 32));
  (void)(((m)[7] = 114));
  (void)(((m)[8] = 101));
  (void)(((m)[9] = 97));
  (void)(((m)[10] = 100));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 102));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 0));
}
void rt_ab_msg_pp_failed(uint8_t * m) {
  (void)(((m)[0] = 112));
  (void)(((m)[1] = 114));
  (void)(((m)[2] = 101));
  (void)(((m)[3] = 112));
  (void)(((m)[4] = 114));
  (void)(((m)[5] = 111));
  (void)(((m)[6] = 99));
  (void)(((m)[7] = 101));
  (void)(((m)[8] = 115));
  (void)(((m)[9] = 115));
  (void)(((m)[10] = 32));
  (void)(((m)[11] = 102));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 100));
  (void)(((m)[17] = 0));
}
void rt_ab_msg_alloc_failed(uint8_t * m) {
  (void)(((m)[0] = 46));
  (void)(((m)[1] = 120));
  (void)(((m)[2] = 32));
  (void)(((m)[3] = 112));
  (void)(((m)[4] = 105));
  (void)(((m)[5] = 112));
  (void)(((m)[6] = 101));
  (void)(((m)[7] = 108));
  (void)(((m)[8] = 105));
  (void)(((m)[9] = 110));
  (void)(((m)[10] = 101));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 108));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 111));
  (void)(((m)[16] = 99));
  (void)(((m)[17] = 32));
  (void)(((m)[18] = 102));
  (void)(((m)[19] = 97));
  (void)(((m)[20] = 105));
  (void)(((m)[21] = 108));
  (void)(((m)[22] = 101));
  (void)(((m)[23] = 100));
  (void)(((m)[24] = 0));
}
void rt_ab_msg_parse_failed(uint8_t * m) {
  (void)(((m)[0] = 97));
  (void)(((m)[1] = 115));
  (void)(((m)[2] = 109));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 112));
  (void)(((m)[5] = 97));
  (void)(((m)[6] = 114));
  (void)(((m)[7] = 115));
  (void)(((m)[8] = 101));
  (void)(((m)[9] = 32));
  (void)(((m)[10] = 102));
  (void)(((m)[11] = 97));
  (void)(((m)[12] = 105));
  (void)(((m)[13] = 108));
  (void)(((m)[14] = 101));
  (void)(((m)[15] = 100));
  (void)(((m)[16] = 0));
}
void rt_ab_msg_dep_alloc(uint8_t * m) {
  (void)(((m)[0] = 100));
  (void)(((m)[1] = 101));
  (void)(((m)[2] = 112));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 97));
  (void)(((m)[5] = 108));
  (void)(((m)[6] = 108));
  (void)(((m)[7] = 111));
  (void)(((m)[8] = 99));
  (void)(((m)[9] = 32));
  (void)(((m)[10] = 102));
  (void)(((m)[11] = 97));
  (void)(((m)[12] = 105));
  (void)(((m)[13] = 108));
  (void)(((m)[14] = 101));
  (void)(((m)[15] = 100));
  (void)(((m)[16] = 0));
}
void rt_ab_msg_out_ctx(uint8_t * m) {
  (void)(((m)[0] = 111));
  (void)(((m)[1] = 117));
  (void)(((m)[2] = 116));
  (void)(((m)[3] = 47));
  (void)(((m)[4] = 99));
  (void)(((m)[5] = 116));
  (void)(((m)[6] = 120));
  (void)(((m)[7] = 32));
  (void)(((m)[8] = 97));
  (void)(((m)[9] = 108));
  (void)(((m)[10] = 108));
  (void)(((m)[11] = 111));
  (void)(((m)[12] = 99));
  (void)(((m)[13] = 32));
  (void)(((m)[14] = 102));
  (void)(((m)[15] = 97));
  (void)(((m)[16] = 105));
  (void)(((m)[17] = 108));
  (void)(((m)[18] = 101));
  (void)(((m)[19] = 100));
  (void)(((m)[20] = 0));
}
void rt_ab_msg_dep_prerun(uint8_t * m) {
  (void)(((m)[0] = 100));
  (void)(((m)[1] = 101));
  (void)(((m)[2] = 112));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 112));
  (void)(((m)[5] = 114));
  (void)(((m)[6] = 101));
  (void)(((m)[7] = 114));
  (void)(((m)[8] = 117));
  (void)(((m)[9] = 110));
  (void)(((m)[10] = 32));
  (void)(((m)[11] = 102));
  (void)(((m)[12] = 97));
  (void)(((m)[13] = 105));
  (void)(((m)[14] = 108));
  (void)(((m)[15] = 101));
  (void)(((m)[16] = 100));
  (void)(((m)[17] = 0));
}
void rt_ab_msg_pipe_failed(uint8_t * m) {
  (void)(((m)[0] = 46));
  (void)(((m)[1] = 120));
  (void)(((m)[2] = 32));
  (void)(((m)[3] = 112));
  (void)(((m)[4] = 105));
  (void)(((m)[5] = 112));
  (void)(((m)[6] = 101));
  (void)(((m)[7] = 108));
  (void)(((m)[8] = 105));
  (void)(((m)[9] = 110));
  (void)(((m)[10] = 101));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 102));
  (void)(((m)[13] = 97));
  (void)(((m)[14] = 105));
  (void)(((m)[15] = 108));
  (void)(((m)[16] = 101));
  (void)(((m)[17] = 100));
  (void)(((m)[18] = 0));
}
void rt_ab_msg_no_funcs(uint8_t * m) {
  (void)(((m)[0] = 110));
  (void)(((m)[1] = 111));
  (void)(((m)[2] = 32));
  (void)(((m)[3] = 102));
  (void)(((m)[4] = 117));
  (void)(((m)[5] = 110));
  (void)(((m)[6] = 99));
  (void)(((m)[7] = 116));
  (void)(((m)[8] = 105));
  (void)(((m)[9] = 111));
  (void)(((m)[10] = 110));
  (void)(((m)[11] = 115));
  (void)(((m)[12] = 0));
}
void rt_ab_msg_elf_failed(uint8_t * m) {
  (void)(((m)[0] = 97));
  (void)(((m)[1] = 115));
  (void)(((m)[2] = 109));
  (void)(((m)[3] = 95));
  (void)(((m)[4] = 99));
  (void)(((m)[5] = 111));
  (void)(((m)[6] = 100));
  (void)(((m)[7] = 101));
  (void)(((m)[8] = 103));
  (void)(((m)[9] = 101));
  (void)(((m)[10] = 110));
  (void)(((m)[11] = 32));
  (void)(((m)[12] = 102));
  (void)(((m)[13] = 97));
  (void)(((m)[14] = 105));
  (void)(((m)[15] = 108));
  (void)(((m)[16] = 101));
  (void)(((m)[17] = 100));
  (void)(((m)[18] = 0));
}
void rt_ab_msg_ld_failed(uint8_t * m) {
  (void)(((m)[0] = 108));
  (void)(((m)[1] = 100));
  (void)(((m)[2] = 32));
  (void)(((m)[3] = 102));
  (void)(((m)[4] = 97));
  (void)(((m)[5] = 105));
  (void)(((m)[6] = 108));
  (void)(((m)[7] = 101));
  (void)(((m)[8] = 100));
  (void)(((m)[9] = 0));
}
void rt_ab_msg_elf_ctx(uint8_t * m) {
  (void)(((m)[0] = 69));
  (void)(((m)[1] = 76));
  (void)(((m)[2] = 70));
  (void)(((m)[3] = 32));
  (void)(((m)[4] = 99));
  (void)(((m)[5] = 116));
  (void)(((m)[6] = 120));
  (void)(((m)[7] = 32));
  (void)(((m)[8] = 97));
  (void)(((m)[9] = 108));
  (void)(((m)[10] = 108));
  (void)(((m)[11] = 111));
  (void)(((m)[12] = 99));
  (void)(((m)[13] = 32));
  (void)(((m)[14] = 102));
  (void)(((m)[15] = 97));
  (void)(((m)[16] = 105));
  (void)(((m)[17] = 108));
  (void)(((m)[18] = 101));
  (void)(((m)[19] = 100));
  (void)(((m)[20] = 0));
}
void rt_ab_msg_metric(uint8_t * m) {
  (void)(((m)[0] = 109));
  (void)(((m)[1] = 101));
  (void)(((m)[2] = 116));
  (void)(((m)[3] = 114));
  (void)(((m)[4] = 105));
  (void)(((m)[5] = 99));
  (void)(((m)[6] = 32));
  (void)(((m)[7] = 119));
  (void)(((m)[8] = 114));
  (void)(((m)[9] = 105));
  (void)(((m)[10] = 116));
  (void)(((m)[11] = 101));
  (void)(((m)[12] = 32));
  (void)(((m)[13] = 102));
  (void)(((m)[14] = 97));
  (void)(((m)[15] = 105));
  (void)(((m)[16] = 108));
  (void)(((m)[17] = 101));
  (void)(((m)[18] = 100));
  (void)(((m)[19] = 0));
}
void rt_ab_diag(uint8_t * path, int32_t kind_fn, int32_t code_fn, int32_t msg_fn) {
  uint8_t * k = ((uint8_t *)(0));
  uint8_t * c = ((uint8_t *)(0));
  uint8_t * m = ((uint8_t *)(0));
  {
    (void)((k = driver_asm_work_p_get(ap_kind())));
    (void)((c = driver_asm_work_p_get(ap_code())));
    (void)((m = driver_asm_work_p_get(ap_msg())));
  }
  if ((k ==((uint8_t *)(0)))) {
    return;
  }
  if ((kind_fn ==1)) {
    (void)(rt_ab_fill_kind_io(k));
  }
  if ((kind_fn ==2)) {
    (void)(rt_ab_fill_kind_pp(k));
  }
  if ((kind_fn ==3)) {
    (void)(rt_ab_fill_kind_pipe(k));
  }
  if ((kind_fn ==4)) {
    (void)(rt_ab_fill_kind_parse(k));
  }
  if ((kind_fn ==5)) {
    (void)(rt_ab_fill_kind_cg(k));
  }
  if ((kind_fn ==6)) {
    (void)(rt_ab_fill_kind_build(k));
  }
  if ((code_fn ==1)) {
    (void)(rt_ab_fill_code_io001(c));
  }
  if ((code_fn ==2)) {
    (void)(rt_ab_fill_code_pp002(c));
  }
  if ((code_fn ==3)) {
    (void)(rt_ab_fill_code_xp001(c));
  }
  if ((code_fn ==5)) {
    (void)(rt_ab_fill_code_xp005(c));
  }
  if ((code_fn ==6)) {
    (void)(rt_ab_fill_code_xp006(c));
  }
  if ((code_fn ==8)) {
    (void)(rt_ab_fill_code_xp008(c));
  }
  if ((code_fn ==9)) {
    (void)(rt_ab_fill_code_p001(c));
  }
  if ((code_fn ==10)) {
    (void)(rt_ab_fill_code_cg002(c));
  }
  if ((code_fn ==11)) {
    (void)(rt_ab_fill_code_bld001(c));
  }
  if ((msg_fn ==1)) {
    (void)(rt_ab_msg_cannot_read(m));
  }
  if ((msg_fn ==2)) {
    (void)(rt_ab_msg_pp_failed(m));
  }
  if ((msg_fn ==3)) {
    (void)(rt_ab_msg_alloc_failed(m));
  }
  if ((msg_fn ==5)) {
    (void)(rt_ab_msg_parse_failed(m));
  }
  if ((msg_fn ==6)) {
    (void)(rt_ab_msg_dep_alloc(m));
  }
  if ((msg_fn ==7)) {
    (void)(rt_ab_msg_out_ctx(m));
  }
  if ((msg_fn ==8)) {
    (void)(rt_ab_msg_dep_prerun(m));
  }
  if ((msg_fn ==9)) {
    (void)(rt_ab_msg_pipe_failed(m));
  }
  if ((msg_fn ==10)) {
    (void)(rt_ab_msg_no_funcs(m));
  }
  if ((msg_fn ==11)) {
    (void)(rt_ab_msg_elf_failed(m));
  }
  if ((msg_fn ==12)) {
    (void)(rt_ab_msg_ld_failed(m));
  }
  if ((msg_fn ==13)) {
    (void)(rt_ab_msg_elf_ctx(m));
  }
  if ((msg_fn ==14)) {
    (void)(rt_ab_msg_metric(m));
  }
  {
    (void)(diag_report_with_code(path, 0, 0, k, c, m, ((uint8_t *)(0))));
  }
  (void)(0);
  return;
}
int32_t rt_ab_step_read_pp(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * raw = ((uint8_t *)(0));
  size_t raw_len = 0;
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  uint8_t * defs = ((uint8_t *)(0));
  int32_t ndef = 0;
  int32_t rc = 0;
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((ndef = driver_asm_work_i_get(ai_ndef())));
    (void)((defs = driver_asm_work_p_get(ap_defs())));
    (void)((raw = runtime_read_file_malloc(path, &(raw_len))));
  }
  if ((raw ==((uint8_t *)(0)))) {
    (void)(rt_ab_diag(path, 1, 1, 1));
    return 1;
  }
  {
    (void)(pipeline_diag_emitted_reset());
    (void)((src = shux_preprocess_with_path(raw, raw_len, path, defs, ndef, &(src_len))));
    (void)(free(raw));
  }
  if ((src ==((uint8_t *)(0)))) {
    {
      (void)((rc = pipeline_diag_emitted_get()));
    }
    if ((rc ==0)) {
      (void)(rt_ab_diag(path, 2, 2, 2));
    }
    return 1;
  }
  {
    (void)(driver_asm_work_p_set(ap_src(), src));
    (void)(driver_asm_work_z_set(az_slen(), src_len));
    (void)(diag_set_file(path, src, src_len));
  }
  return 0;
}
int32_t rt_ab_step_early(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * outp = ((uint8_t *)(0));
  int32_t rc = 0;
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((src = driver_asm_work_p_get(ap_src())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((outp = driver_asm_work_p_get(ap_out_path())));
    (void)((rc = driver_asm_try_c_frontend_early(path, src, lib, nlib, outp)));
  }
  if ((rc ==(0 - 2))) {
    return 0;
  }
  {
    (void)(driver_asm_work_i_set(ai_ec(), rc));
  }
  return 2;
}
int32_t rt_ab_step_parse(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  size_t asz = 0;
  size_t msz = 0;
  uint8_t * arena = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  int32_t main_idx = 0;
  int32_t pr_ok = 0;
  uint8_t * outp = ((uint8_t *)(0));
  int32_t rc = 0;
  int32_t nimp = 0;
  uint8_t * entry = ((uint8_t *)(0));
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((src = driver_asm_work_p_get(ap_src())));
    (void)((src_len = driver_asm_work_z_get(az_slen())));
    (void)((outp = driver_asm_work_p_get(ap_out_path())));
    (void)((asz = pipeline_sizeof_arena()));
    (void)((msz = pipeline_sizeof_module()));
    (void)((arena = malloc(asz)));
    (void)((module = malloc(msz)));
  }
  if ((arena ==((uint8_t *)(0)))) {
    if ((module !=((uint8_t *)(0)))) {
      {
        (void)(free(module));
      }
    }
    (void)(rt_ab_diag(((uint8_t *)(0)), 3, 5, 3));
    return 1;
  }
  if ((module ==((uint8_t *)(0)))) {
    {
      (void)(free(arena));
    }
    (void)(rt_ab_diag(((uint8_t *)(0)), 3, 5, 3));
    return 1;
  }
  {
    (void)(memset(arena, 0, asz));
    (void)(memset(module, 0, msz));
    (void)(parser_parse_into_init(module, arena));
    (void)((pr_ok = driver_parse_into_buf_rc(arena, module, src, ((int32_t)(src_len)), &(main_idx))));
  }
  if ((pr_ok !=0)) {
    {
      (void)((rc = runtime_report_precise_parse_failure_if_known(path, src, src_len)));
    }
    if ((rc ==0)) {
      (void)(rt_ab_diag(path, 4, 9, 5));
    }
    {
      (void)(free(arena));
      (void)(free(module));
    }
    return 1;
  }
  {
    (void)(parser_parse_into_set_main_index(module, main_idx));
    (void)(driver_set_pipeline_entry_source_len(src_len));
    (void)(driver_asm_work_p_set(ap_arena(), arena));
    (void)(driver_asm_work_p_set(ap_module(), module));
    (void)(driver_asm_work_z_set(az_asz(), asz));
    (void)(driver_asm_work_z_set(az_msz(), msz));
    (void)(driver_asm_work_i_set(ai_main(), main_idx));
  }
  {
    (void)((rc = driver_asm_parse_metric_only_from_env()));
  }
  if ((rc !=0)) {
    if ((outp !=((uint8_t *)(0)))) {
      {
        (void)(driver_diagnostic_after_entry_parse(driver_get_module_num_funcs(module)));
        (void)(driver_diagnostic_after_entry_parse_module(module));
        (void)((rc = driver_asm_write_metric_o(outp)));
      }
      if ((rc !=0)) {
        (void)(rt_ab_diag(outp, 1, 1, 14));
        return 1;
      }
      {
        (void)(driver_asm_work_i_set(ai_ec(), 0));
      }
      return 2;
    }
  }
  {
    (void)((nimp = parser_get_module_num_imports(module)));
    (void)((entry = driver_entry_dir_slot()));
    (void)(shux_get_entry_dir(path, entry, ((size_t)(512))));
    (void)(driver_asm_work_p_set(ap_entry(), entry));
    (void)(driver_asm_work_i_set(ai_nimp(), nimp));
  }
  return 0;
}
int32_t rt_ab_step_load_deps(void) {
  uint8_t * module = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * entry = ((uint8_t *)(0));
  uint8_t * defs = ((uint8_t *)(0));
  int32_t ndef = 0;
  int32_t nimp = 0;
  size_t asz = 0;
  size_t msz = 0;
  uint8_t * ds = ((uint8_t *)(0));
  uint8_t * dp = ((uint8_t *)(0));
  uint8_t * dl = ((uint8_t *)(0));
  int32_t n_deps = 0;
  int32_t skip_load = 0;
  int32_t rc = 0;
  uint8_t * cls = ((uint8_t *)(0));
  uint8_t * clens = ((uint8_t *)(0));
  uint8_t * cpaths = ((uint8_t *)(0));
  int32_t n_closure = 0;
  int32_t rev = 0;
  int32_t o = 0;
  uint8_t * ts = ((uint8_t *)(0));
  size_t tl = 0;
  uint8_t * tp = ((uint8_t *)(0));
  {
    (void)((module = driver_asm_work_p_get(ap_module())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((entry = driver_asm_work_p_get(ap_entry())));
    (void)((defs = driver_asm_work_p_get(ap_defs())));
    (void)((ndef = driver_asm_work_i_get(ai_ndef())));
    (void)((nimp = driver_asm_work_i_get(ai_nimp())));
    (void)((asz = driver_asm_work_z_get(az_asz())));
    (void)((msz = driver_asm_work_z_get(az_msz())));
    (void)((skip_load = 0));
    if ((driver_asm_entry_module_only_from_env() !=0)) {
      if ((driver_asm_build_skip_typeck() !=0)) {
        (void)((skip_load = 1));
      }
    }
  }
  if ((nimp <=0)) {
    {
      (void)(driver_asm_work_i_set(ai_ndeps(), 0));
    }
    return 0;
  }
  if ((nimp > 32)) {
    {
      (void)(driver_asm_work_i_set(ai_ndeps(), 0));
    }
    return 0;
  }
  {
    (void)((ds = driver_ptr_table_calloc(128)));
    (void)((dp = driver_ptr_table_calloc(128)));
    (void)((dl = driver_size_table_calloc(128)));
  }
  if ((ds ==((uint8_t *)(0)))) {
    return 1;
  }
  if ((dp ==((uint8_t *)(0)))) {
    {
      (void)(free(ds));
    }
    return 1;
  }
  if ((dl ==((uint8_t *)(0)))) {
    {
      (void)(free(ds));
      (void)(free(dp));
    }
    return 1;
  }
  if ((skip_load !=0)) {
    {
      (void)((rc = shux_load_direct_imports_for_asm_layout(module, lib, nlib, entry, defs, ndef, ds, dl, dp, &(n_deps))));
    }
    if ((rc !=0)) {
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
      }
      return 1;
    }
  } else {
    {
      (void)((cls = driver_ptr_table_calloc(128)));
      (void)((clens = driver_size_table_calloc(128)));
      (void)((cpaths = driver_ptr_table_calloc(128)));
    }
    if ((cls ==((uint8_t *)(0)))) {
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
      }
      return 1;
    }
    if ((clens ==((uint8_t *)(0)))) {
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
        (void)(free(cls));
      }
      return 1;
    }
    if ((cpaths ==((uint8_t *)(0)))) {
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
        (void)(free(cls));
        (void)(free(clens));
      }
      return 1;
    }
    {
      (void)((rc = shux_collect_deps_transitive(module, asz, msz, lib, nlib, entry, defs, ndef, cls, clens, cpaths, &(n_closure))));
    }
    if ((rc !=0)) {
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
        (void)(free(cls));
        (void)(free(clens));
        (void)(free(cpaths));
      }
      return 1;
    }
    (void)((rev = 0));
    while ((rev < (n_closure / 2))) {
      (void)((o = ((n_closure - 1) - rev)));
      {
        (void)((ts = driver_ptr_table_get(cls, rev)));
        (void)(driver_ptr_table_set(cls, rev, driver_ptr_table_get(cls, o)));
        (void)(driver_ptr_table_set(cls, o, ts));
        (void)((tl = driver_size_table_get(clens, rev)));
        (void)(driver_size_table_set(clens, rev, driver_size_table_get(clens, o)));
        (void)(driver_size_table_set(clens, o, tl));
        (void)((tp = driver_ptr_table_get(cpaths, rev)));
        (void)(driver_ptr_table_set(cpaths, rev, driver_ptr_table_get(cpaths, o)));
        (void)(driver_ptr_table_set(cpaths, o, tp));
      }
      (void)((rev = (rev + 1)));
    }
    {
      (void)((rc = shux_merge_direct_then_transitive_deps(module, nimp, cls, clens, cpaths, n_closure, ds, dl, dp, &(n_deps))));
    }
    if ((rc !=0)) {
      while ((n_closure > 0)) {
        (void)((n_closure = (n_closure - 1)));
        {
          (void)(free(driver_ptr_table_get(cls, n_closure)));
          (void)(free(driver_ptr_table_get(cpaths, n_closure)));
        }
      }
      {
        (void)(free(ds));
        (void)(free(dp));
        (void)(free(dl));
        (void)(free(cls));
        (void)(free(clens));
        (void)(free(cpaths));
      }
      return 1;
    }
    {
      (void)(free(cls));
      (void)(free(clens));
      (void)(free(cpaths));
    }
  }
  {
    (void)(driver_asm_work_p_set(ap_dsrc(), ds));
    (void)(driver_asm_work_p_set(ap_dpath(), dp));
    (void)(driver_asm_work_p_set(ap_dlens(), dl));
    (void)(driver_asm_work_i_set(ai_ndeps(), n_deps));
  }
  return 0;
}
int32_t rt_ab_step_open_out(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * outp = ((uint8_t *)(0));
  uint8_t * target = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * entry = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  int32_t n_deps = 0;
  int32_t smoke = 0;
  int32_t want_exe = 0;
  int32_t emit_elf = 0;
  uint8_t * asm_out = ((uint8_t *)(0));
  uint8_t * tmp = ((uint8_t *)(0));
  uint8_t * elf = ((uint8_t *)(0));
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  uint8_t * da = ((uint8_t *)(0));
  uint8_t * dm = ((uint8_t *)(0));
  size_t asz = 0;
  size_t msz = 0;
  int32_t j = 0;
  uint8_t * ar = ((uint8_t *)(0));
  uint8_t * mo = ((uint8_t *)(0));
  int32_t nf = 0;
  int32_t eo = 0;
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((outp = driver_asm_work_p_get(ap_out_path())));
    (void)((target = driver_asm_work_p_get(ap_target())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((entry = driver_asm_work_p_get(ap_entry())));
    (void)((module = driver_asm_work_p_get(ap_module())));
    (void)((n_deps = driver_asm_work_i_get(ai_ndeps())));
    (void)((asz = driver_asm_work_z_get(az_asz())));
    (void)((msz = driver_asm_work_z_get(az_msz())));
    (void)(driver_typeck_ndep_set(0));
  }
  if ((outp ==((uint8_t *)(0)))) {
    (void)((smoke = 1));
    (void)((want_exe = 0));
    (void)((emit_elf = 0));
  } else {
    (void)((smoke = 0));
    {
      (void)((want_exe = shux_output_want_exe(outp)));
    }
    if ((want_exe !=0)) {
      {
        (void)((tmp = driver_asm_tmp_path_slot()));
        (void)((asm_out = driver_asm_mkstemp_fdopen(tmp)));
      }
      if ((asm_out ==((uint8_t *)(0)))) {
        {
          (void)(runtime_diag_errno_path(path, ((uint8_t *)(0)), ((uint8_t *)(0)), tmp));
        }
        return 1;
      }
      (void)((emit_elf = 1));
      {
        (void)(driver_asm_work_p_set(ap_tmp(), tmp));
      }
    } else {
      {
        (void)((asm_out = driver_asm_fopen_wb(outp)));
      }
      if ((asm_out ==((uint8_t *)(0)))) {
        {
          (void)(runtime_diag_errno_path(outp, ((uint8_t *)(0)), ((uint8_t *)(0)), outp));
        }
        return 1;
      }
      {
        (void)((emit_elf = shux_output_is_elf_o(outp)));
      }
    }
  }
  {
    (void)(driver_asm_work_i_set(ai_smoke(), smoke));
    (void)(driver_asm_work_i_set(ai_want_exe(), want_exe));
    (void)(driver_asm_work_i_set(ai_emit_elf(), emit_elf));
    (void)(driver_asm_work_p_set(ap_asm_out(), asm_out));
  }
  if ((emit_elf !=0)) {
    {
      (void)((elf = driver_asm_elf_ctx_calloc()));
    }
    if ((elf ==((uint8_t *)(0)))) {
      (void)(rt_ab_diag(((uint8_t *)(0)), 3, 5, 13));
      return 1;
    }
    {
      (void)(driver_asm_work_p_set(ap_elf(), elf));
    }
  }
  if ((n_deps > 0)) {
    {
      (void)((da = driver_ptr_table_calloc(n_deps)));
      (void)((dm = driver_ptr_table_calloc(n_deps)));
    }
    if ((da ==((uint8_t *)(0)))) {
      return 1;
    }
    if ((dm ==((uint8_t *)(0)))) {
      {
        (void)(free(da));
      }
      return 1;
    }
    (void)((j = 0));
    while ((j < n_deps)) {
      {
        (void)((ar = malloc(asz)));
        (void)((mo = malloc(msz)));
      }
      if ((ar ==((uint8_t *)(0)))) {
        if ((mo !=((uint8_t *)(0)))) {
          {
            (void)(free(mo));
          }
        }
        (void)(rt_ab_diag(((uint8_t *)(0)), 3, 5, 6));
        {
          (void)(driver_asm_work_p_set(ap_dar(), da));
          (void)(driver_asm_work_p_set(ap_dmod(), dm));
        }
        return 1;
      }
      if ((mo ==((uint8_t *)(0)))) {
        {
          (void)(free(ar));
        }
        (void)(rt_ab_diag(((uint8_t *)(0)), 3, 5, 6));
        {
          (void)(driver_asm_work_p_set(ap_dar(), da));
          (void)(driver_asm_work_p_set(ap_dmod(), dm));
        }
        return 1;
      }
      {
        (void)(memset(ar, 0, asz));
        (void)(memset(mo, 0, msz));
        (void)(driver_ptr_table_set(da, j, ar));
        (void)(driver_ptr_table_set(dm, j, mo));
      }
      (void)((j = (j + 1)));
    }
    {
      (void)(driver_asm_work_p_set(ap_dar(), da));
      (void)(driver_asm_work_p_set(ap_dmod(), dm));
    }
  }
  {
    (void)((out_buf = driver_codegen_outbuf_calloc()));
    (void)((pctx = driver_pipeline_dep_ctx_calloc()));
  }
  if ((out_buf ==((uint8_t *)(0)))) {
    if ((pctx !=((uint8_t *)(0)))) {
      {
        (void)(pipeline_dep_ctx_heap_destroy(pctx));
      }
    }
    (void)(rt_ab_diag(((uint8_t *)(0)), 3, 6, 7));
    return 1;
  }
  if ((pctx ==((uint8_t *)(0)))) {
    {
      (void)(driver_codegen_outbuf_free(out_buf));
    }
    (void)(rt_ab_diag(((uint8_t *)(0)), 3, 6, 7));
    return 1;
  }
  {
    (void)(driver_asm_work_p_set(ap_out(), out_buf));
    (void)(driver_asm_work_p_set(ap_pctx(), pctx));
    (void)(shux_pipeline_fill_ctx_path_buffers(pctx, entry, lib, nlib));
    (void)(driver_pipeline_dep_ctx_set_use_asm(pctx, 0));
    (void)(driver_asm_pctx_apply_host_defaults(pctx, target, emit_elf));
  }
  (void)((eo = 0));
  if ((emit_elf !=0)) {
    {
      (void)((eo = driver_asm_entry_module_only_from_env()));
    }
  }
  {
    if ((want_exe !=0)) {
      if ((n_deps > 0)) {
        if ((smoke ==0)) {
          if ((driver_asm_build_skip_typeck() !=0)) {
            (void)((eo = 1));
          }
        }
      }
    }
    if ((emit_elf !=0)) {
      if ((n_deps ==0)) {
        if ((smoke ==0)) {
          if ((driver_asm_build_skip_typeck() ==0)) {
            (void)((nf = driver_get_module_num_funcs(module)));
            if ((nf <=1)) {
              (void)((eo = 1));
            }
          }
        }
      }
    }
    if ((emit_elf !=0)) {
      if ((n_deps > 0)) {
        if ((smoke ==0)) {
          if ((driver_asm_build_skip_typeck() ==0)) {
            if ((driver_freestanding_get() ==0)) {
              if ((pipeline_asm_user_deps_need_coemit(driver_asm_work_p_get(ap_dpath()), n_deps) ==0)) {
                (void)((eo = 1));
              }
            }
          }
        }
      }
    }
    (void)(driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, eo));
    (void)(driver_asm_work_i_set(ai_entry_only(), eo));
    (void)(driver_dep_seeded_clear_all());
  }
  return 0;
}
int32_t rt_ab_step_prerun(void) {
  int32_t n_deps = 0;
  int32_t emit_elf = 0;
  int32_t smoke = 0;
  int32_t eo = 0;
  int32_t j = 0;
  uint8_t * da = ((uint8_t *)(0));
  uint8_t * dm = ((uint8_t *)(0));
  uint8_t * ds = ((uint8_t *)(0));
  uint8_t * dp = ((uint8_t *)(0));
  uint8_t * dl = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * entry = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  uint8_t * one = ((uint8_t *)(0));
  uint8_t * dep_out = ((uint8_t *)(0));
  uint8_t * dep_src = ((uint8_t *)(0));
  size_t dep_len = 0;
  uint8_t * dep_path = ((uint8_t *)(0));
  uint8_t * prerun_dir = ((uint8_t *)(0));
  int32_t ec_loop = 0;
  int32_t skip_tk = 0;
  {
    (void)((n_deps = driver_asm_work_i_get(ai_ndeps())));
    (void)((emit_elf = driver_asm_work_i_get(ai_emit_elf())));
    (void)((smoke = driver_asm_work_i_get(ai_smoke())));
    (void)((eo = driver_asm_work_i_get(ai_entry_only())));
    (void)((da = driver_asm_work_p_get(ap_dar())));
    (void)((dm = driver_asm_work_p_get(ap_dmod())));
    (void)((ds = driver_asm_work_p_get(ap_dsrc())));
    (void)((dp = driver_asm_work_p_get(ap_dpath())));
    (void)((dl = driver_asm_work_p_get(ap_dlens())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((entry = driver_asm_work_p_get(ap_entry())));
    (void)((pctx = driver_asm_work_p_get(ap_pctx())));
  }
  if ((n_deps <=0)) {
    return 0;
  }
  {
    (void)((skip_tk = driver_asm_build_skip_typeck()));
  }
  if ((emit_elf !=0)) {
    if ((eo !=0)) {
      if ((skip_tk !=0)) {
        (void)((j = 0));
        while ((j < n_deps)) {
          {
            (void)((dep_src = driver_ptr_table_get(ds, j)));
            (void)((dep_len = driver_size_table_get(dl, j)));
            (void)((dep_path = driver_ptr_table_get(dp, j)));
            (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
          }
          if ((ec_loop !=0)) {
            (void)(rt_ab_diag(dep_path, 4, 9, 5));
            return 1;
          }
          {
            (void)(driver_dep_publish_slot(j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path));
          }
          (void)((j = (j + 1)));
        }
        return 0;
      }
    }
  }
  (void)((j = 0));
  while ((j < n_deps)) {
    {
      (void)((one = driver_pipeline_dep_ctx_calloc()));
      (void)((dep_out = driver_codegen_outbuf_calloc()));
      (void)((dep_src = driver_ptr_table_get(ds, j)));
      (void)((dep_len = driver_size_table_get(dl, j)));
      (void)((dep_path = driver_ptr_table_get(dp, j)));
    }
    if ((one ==((uint8_t *)(0)))) {
      if ((dep_out !=((uint8_t *)(0)))) {
        {
          (void)(driver_codegen_outbuf_free(dep_out));
        }
      }
      (void)(rt_ab_diag(((uint8_t *)(0)), 3, 6, 7));
      return 1;
    }
    if ((dep_out ==((uint8_t *)(0)))) {
      {
        (void)(pipeline_dep_ctx_heap_destroy(one));
      }
      (void)(rt_ab_diag(((uint8_t *)(0)), 3, 6, 7));
      return 1;
    }
    {
      (void)((prerun_dir = shux_dep_prerun_entry_dir(entry, lib, nlib)));
      (void)(shux_pipeline_fill_ctx_path_buffers(one, prerun_dir, lib, nlib));
      (void)(shux_pipeline_one_ctx_for_dep_prerun(one, j, dm, da, dp, n_deps, dep_src, dep_len));
    }
    if ((smoke !=0)) {
      {
        (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
      }
    } else {
      if ((emit_elf !=0)) {
        {
          if ((shux_asm_user_std_dep_skip_x_typeck(dep_path) !=0)) {
            (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
          } else {
            if ((shux_asm_user_dep_parse_skip_typeck_path(dep_path) !=0)) {
              (void)((ec_loop = shux_pipeline_dep_prerun_parse_skip_typeck(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
              if ((ec_loop ==0)) {
                if ((shux_asm_user_std_net_dep_path(dep_path) !=0)) {
                  (void)(pipeline_asm_seed_std_net_struct_layouts(driver_ptr_table_get(dm, j)));
                }
              }
            } else {
              if ((eo !=0)) {
                if ((skip_tk ==0)) {
                  (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
                } else {
                  if ((driver_asm_use_compiler_impl_c() !=0)) {
                    if ((skip_tk ==0)) {
                      (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
                    } else {
                      (void)((ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
                    }
                  } else {
                    (void)((ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
                  }
                }
              } else {
                if ((driver_asm_use_compiler_impl_c() !=0)) {
                  if ((skip_tk ==0)) {
                    (void)((ec_loop = shux_pipeline_dep_prerun_parse_only(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len)));
                  } else {
                    (void)((ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
                  }
                } else {
                  (void)((ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
                }
              }
            }
          }
        }
      } else {
        {
          (void)((ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j), dep_src, dep_len, dep_out, one)));
        }
      }
    }
    {
      (void)(pipeline_dep_ctx_heap_destroy(one));
      (void)(driver_codegen_outbuf_free(dep_out));
    }
    if ((ec_loop !=0)) {
      (void)(rt_ab_diag(dep_path, 3, 8, 8));
      return 1;
    }
    {
      (void)(driver_dep_publish_slot(j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), dep_path));
    }
    (void)((j = (j + 1)));
  }
  return 0;
}
int32_t rt_ab_step_pipeline(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * src = ((uint8_t *)(0));
  size_t src_len = 0;
  uint8_t * arena = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  int32_t n_deps = 0;
  uint8_t * da = ((uint8_t *)(0));
  uint8_t * dm = ((uint8_t *)(0));
  uint8_t * dp = ((uint8_t *)(0));
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  int32_t smoke = 0;
  int32_t j = 0;
  int32_t ec = 0;
  int32_t pre = 0;
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((src = driver_asm_work_p_get(ap_src())));
    (void)((src_len = driver_asm_work_z_get(az_slen())));
    (void)((arena = driver_asm_work_p_get(ap_arena())));
    (void)((module = driver_asm_work_p_get(ap_module())));
    (void)((n_deps = driver_asm_work_i_get(ai_ndeps())));
    (void)((da = driver_asm_work_p_get(ap_dar())));
    (void)((dm = driver_asm_work_p_get(ap_dmod())));
    (void)((dp = driver_asm_work_p_get(ap_dpath())));
    (void)((out_buf = driver_asm_work_p_get(ap_out())));
    (void)((pctx = driver_asm_work_p_get(ap_pctx())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((smoke = driver_asm_work_i_get(ai_smoke())));
    (void)(driver_typeck_ndep_set(n_deps));
  }
  (void)((j = 0));
  while ((j < n_deps)) {
    {
      (void)(driver_typeck_dep_ptrs_set(j, driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j)));
    }
    (void)((j = (j + 1)));
  }
  {
    (void)(shux_pipeline_pctx_seed_dep_slots(pctx, dm, da, dp, n_deps));
    (void)(pipeline_set_dep_slots(da, dm));
    (void)(driver_dep_seed_slots(da, dm, n_deps));
    (void)(codegen_set_dep_slots_for_x_pipeline(dm, dp, n_deps));
    (void)(codegen_set_preamble_has_core_option_result(1));
    (void)(driver_pipeline_dep_ctx_set_entry_already_parsed(pctx, 1));
    (void)((pre = driver_asm_try_c_typeck_precheck(path, src, lib, nlib)));
  }
  if ((pre ==1)) {
    return 1;
  }
  if ((smoke ==0)) {
    if ((n_deps > 0)) {
      {
        (void)(driver_x_pipeline_skip_typeck_set(1));
      }
    }
    {
      (void)(driver_x_pipeline_skip_codegen_set(1));
    }
  } else {
    if ((n_deps > 0)) {
      {
        if ((driver_deps_are_std_core_closure_only(dp, n_deps) !=0)) {
          (void)(driver_x_pipeline_skip_typeck_set(1));
        }
      }
    }
    {
      (void)(driver_x_pipeline_skip_codegen_set(1));
    }
  }
  {
    (void)((ec = shux_pipeline_run_x_pipeline_large_stack(module, arena, src, src_len, out_buf, pctx)));
    (void)(driver_x_pipeline_skip_typeck_set(0));
    (void)(driver_x_pipeline_skip_codegen_set(0));
    (void)(driver_pipeline_dep_ctx_set_use_asm(pctx, 1));
    (void)(driver_asm_work_i_set(ai_ec(), ec));
  }
  return 0;
}
int32_t rt_ab_step_finish(void) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * outp = ((uint8_t *)(0));
  uint8_t * target = ((uint8_t *)(0));
  uint8_t * argv = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  uint8_t * arena = ((uint8_t *)(0));
  uint8_t * module = ((uint8_t *)(0));
  int32_t n_deps = 0;
  uint8_t * da = ((uint8_t *)(0));
  uint8_t * dm = ((uint8_t *)(0));
  uint8_t * dp = ((uint8_t *)(0));
  uint8_t * out_buf = ((uint8_t *)(0));
  uint8_t * pctx = ((uint8_t *)(0));
  uint8_t * asm_out = ((uint8_t *)(0));
  uint8_t * elf = ((uint8_t *)(0));
  uint8_t * tmp = ((uint8_t *)(0));
  int32_t smoke = 0;
  int32_t emit_elf = 0;
  int32_t want_exe = 0;
  int32_t ec = 0;
  int32_t out_len = 0;
  uint8_t * out_data = ((uint8_t *)(0));
  int32_t j = 0;
  int32_t nf = 0;
  int32_t diag_em = 0;
  int32_t elf_ec = 0;
  int32_t is_obj = 0;
  int32_t macho = 0;
  int32_t coff = 0;
  uint8_t * argv0 = ((uint8_t *)(0));
  int32_t ld_ok = 0;
  uint8_t * exe_out = ((uint8_t *)(0));
  {
    (void)((path = driver_asm_work_p_get(ap_path())));
    (void)((outp = driver_asm_work_p_get(ap_out_path())));
    (void)((target = driver_asm_work_p_get(ap_target())));
    (void)((argv = driver_asm_work_p_get(ap_argv())));
    (void)((lib = driver_asm_work_p_get(ap_lib())));
    (void)((nlib = driver_asm_work_i_get(ai_nlib())));
    (void)((arena = driver_asm_work_p_get(ap_arena())));
    (void)((module = driver_asm_work_p_get(ap_module())));
    (void)((n_deps = driver_asm_work_i_get(ai_ndeps())));
    (void)((da = driver_asm_work_p_get(ap_dar())));
    (void)((dm = driver_asm_work_p_get(ap_dmod())));
    (void)((dp = driver_asm_work_p_get(ap_dpath())));
    (void)((out_buf = driver_asm_work_p_get(ap_out())));
    (void)((pctx = driver_asm_work_p_get(ap_pctx())));
    (void)((asm_out = driver_asm_work_p_get(ap_asm_out())));
    (void)((elf = driver_asm_work_p_get(ap_elf())));
    (void)((tmp = driver_asm_work_p_get(ap_tmp())));
    (void)((smoke = driver_asm_work_i_get(ai_smoke())));
    (void)((emit_elf = driver_asm_work_i_get(ai_emit_elf())));
    (void)((want_exe = driver_asm_work_i_get(ai_want_exe())));
    (void)((ec = driver_asm_work_i_get(ai_ec())));
    (void)((out_len = driver_codegen_outbuf_len(out_buf)));
    (void)((out_data = driver_codegen_outbuf_data(out_buf)));
  }
  if ((smoke !=0)) {
    {
      (void)((nf = driver_get_module_num_funcs(module)));
      (void)((diag_em = driver_check_diag_emitted_get()));
    }
    if ((ec !=0)) {
      if ((diag_em ==0)) {
        (void)(rt_ab_diag(path, 3, 3, 9));
      }
    } else {
      if ((nf <=0)) {
        (void)(rt_ab_diag(path, 4, 9, 10));
      } else {
        {
          if ((driver_check_only_get() !=0)) {
            if ((diag_em ==0)) {
              (void)(driver_print_x_smoke_summary(module, ((size_t)(out_len))));
              if ((path !=((uint8_t *)(0)))) {
                (void)(driver_print_check_ok(path));
              }
            }
          } else {
            (void)(driver_print_x_smoke_summary(module, ((size_t)(out_len))));
          }
        }
      }
    }
    {
      (void)(driver_dep_seeded_clear_all());
      (void)(driver_typeck_ndep_set(0));
    }
    if ((ec !=0)) {
      return 1;
    }
    if ((nf <=0)) {
      return 1;
    }
    {
      if ((driver_check_only_get() !=0)) {
        if ((diag_em !=0)) {
          return 1;
        }
      }
    }
    return 0;
  }
  if ((ec ==0)) {
    if ((out_len > 0)) {
    } else {
      if ((emit_elf !=0)) {
      } else {
        if ((want_exe !=0)) {
          if ((tmp !=((uint8_t *)(0)))) {
            {
              (void)(unlink(tmp));
            }
          }
        }
        if ((ec !=0)) {
          {
            (void)(driver_unlink_failed_output(outp));
          }
          (void)(rt_ab_diag(path, 3, 3, 9));
        }
        {
          (void)(driver_dep_seeded_clear_all());
          (void)(codegen_set_dep_slots_for_x_pipeline(((uint8_t *)(0)), ((uint8_t *)(0)), 0));
        }
        return 1;
      }
    }
    if ((emit_elf !=0)) {
      if ((elf !=((uint8_t *)(0)))) {
        {
          (void)((is_obj = shux_asm_out_buf_is_object(out_data, ((size_t)(out_len)))));
        }
        if ((is_obj ==0)) {
          if ((n_deps > 0)) {
            (void)((j = 0));
            while ((j < n_deps)) {
              {
                (void)(driver_dep_publish_slot(j, driver_ptr_table_get(da, j), driver_ptr_table_get(dm, j), driver_ptr_table_get(dp, j)));
                (void)(driver_typeck_dep_ptrs_set(j, driver_ptr_table_get(dm, j), driver_ptr_table_get(da, j)));
              }
              (void)((j = (j + 1)));
            }
            {
              (void)(driver_typeck_ndep_set(n_deps));
              (void)(pipeline_set_dep_slots(da, dm));
              (void)(driver_dep_seed_slots(da, dm, n_deps));
              (void)(shux_pipeline_pctx_seed_dep_slots(pctx, dm, da, dp, n_deps));
              if ((driver_asm_entry_module_only_from_env() ==0)) {
                if ((pipeline_asm_user_deps_need_coemit(dp, n_deps) !=0)) {
                  (void)(driver_pipeline_dep_ctx_set_asm_entry_module_only(pctx, 0));
                }
              }
              (void)(driver_pipeline_dep_ctx_set_use_asm(pctx, 1));
            }
          }
          {
            (void)(shux_driver_asm_prepare_entry_elf_emit(module, arena, pctx));
            (void)((elf_ec = shux_asm_codegen_elf_o_large_stack(module, arena, pctx, elf, out_buf)));
            (void)((out_len = driver_codegen_outbuf_len(out_buf)));
            (void)((out_data = driver_codegen_outbuf_data(out_buf)));
          }
          if ((elf_ec !=0)) {
            (void)(rt_ab_diag(path, 5, 10, 11));
            if ((elf !=((uint8_t *)(0)))) {
              {
                (void)(runtime_pipeline_elf_ctx_diag_note(elf));
              }
            }
            {
              (void)(driver_unlink_failed_output(outp));
            }
            return 1;
          }
          if ((out_len <=0)) {
            (void)(rt_ab_diag(path, 5, 10, 11));
            {
              (void)(driver_unlink_failed_output(outp));
            }
            return 1;
          }
        }
      }
    }
    {
      (void)(driver_asm_fwrite(asm_out, out_data, out_len));
    }
    if ((asm_out ==((uint8_t *)(0)))) {
      {
        (void)(driver_asm_fflush_stdout());
      }
    }
    {
      (void)(driver_asm_fclose(asm_out));
      (void)(driver_asm_work_p_set(ap_asm_out(), ((uint8_t *)(0))));
      if ((elf !=((uint8_t *)(0)))) {
        (void)(driver_asm_elf_ctx_free(elf));
        (void)(driver_asm_work_p_set(ap_elf(), ((uint8_t *)(0))));
      }
    }
    if ((want_exe !=0)) {
      if ((tmp !=((uint8_t *)(0)))) {
        (void)((exe_out = outp));
        if ((exe_out ==((uint8_t *)(0)))) {
        }
        {
          (void)(driver_bump_stack_limit());
          (void)((macho = driver_pipeline_dep_ctx_get_use_macho_o(pctx)));
          (void)((coff = driver_pipeline_dep_ctx_get_use_coff_o(pctx)));
          (void)((argv0 = driver_asm_argv0(argv)));
          /* G.7: plumb CLI extra .o into asm ld (same globals as C invoke_cc). */
          if ((argc > 0) && (argv != ((uint8_t *)(0)))) {
            (void)(shux_invoke_cc_set_user_o_files_from_argv(argc, argv));
          }
          (void)((ld_ok = shux_invoke_ld_for_exe(tmp, exe_out, target, macho, coff, argv0, lib, nlib)));
          (void)(shux_invoke_cc_clear_user_o_files());
          (void)(unlink(tmp));
        }
        if ((ld_ok !=0)) {
          {
            (void)(driver_unlink_failed_output(exe_out));
          }
          (void)(rt_ab_diag(((uint8_t *)(0)), 6, 11, 12));
          return 1;
        }
      }
    }
  } else {
    if ((want_exe !=0)) {
      if ((tmp !=((uint8_t *)(0)))) {
        {
          (void)(unlink(tmp));
        }
      }
    }
    {
      (void)(driver_unlink_failed_output(outp));
    }
    (void)(rt_ab_diag(path, 3, 3, 9));
    return 1;
  }
  {
    (void)((nf = driver_get_module_num_funcs(module)));
  }
  if ((ec ==0)) {
    if ((emit_elf !=0)) {
      if ((nf <=0)) {
        (void)(rt_ab_diag(path, 4, 9, 10));
        return 1;
      }
    }
  }
  {
    (void)(driver_dep_seeded_clear_all());
    (void)(codegen_set_dep_slots_for_x_pipeline(((uint8_t *)(0)), ((uint8_t *)(0)), 0));
  }
  if ((ec !=0)) {
    return 1;
  }
  return 0;
}
int32_t driver_run_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * target, int32_t argc, uint8_t * argv) {
  uint8_t * path = ((uint8_t *)(0));
  uint8_t * lib = ((uint8_t *)(0));
  int32_t nlib = 0;
  int32_t ndef = 0;
  uint8_t * defs = ((uint8_t *)(0));
  uint8_t * k = ((uint8_t *)(0));
  uint8_t * c = ((uint8_t *)(0));
  uint8_t * m = ((uint8_t *)(0));
  int32_t rc = 0;
  int32_t tlen = 0;
  {
    (void)(driver_bump_stack_limit());
    (void)(driver_asm_work_reset());
    (void)((path = input_path));
    if ((path ==((uint8_t *)(0)))) {
      return 1;
    }
    (void)(driver_asm_work_p_set(ap_path(), path));
    (void)(driver_asm_work_p_set(ap_out_path(), out_path));
    (void)(driver_asm_work_p_set(ap_target(), target));
    (void)(driver_asm_work_p_set(ap_argv(), argv));
    (void)((lib = driver_asm_bind_lib_roots(lib_roots, n_lib_roots, &(nlib))));
    (void)(driver_asm_work_p_set(ap_lib(), lib));
    (void)(driver_asm_work_i_set(ai_nlib(), nlib));
    (void)((ndef = driver_asm_collect_defines(argc, argv)));
    (void)((defs = driver_asm_defines_as_u8()));
    (void)(driver_asm_work_i_set(ai_ndef(), ndef));
    (void)(driver_asm_work_p_set(ap_defs(), defs));
    if ((target !=((uint8_t *)(0)))) {
      (void)((tlen = ((int32_t)(strlen(target)))));
      (void)(cfg_apply_compile_target_from_triple(target, tlen));
    } else {
      (void)(cfg_reset_compile_target());
    }
    (void)((k = malloc(((size_t)(32)))));
    (void)((c = malloc(((size_t)(16)))));
    (void)((m = malloc(((size_t)(64)))));
  }
  if ((k ==((uint8_t *)(0)))) {
    return 1;
  }
  if ((c ==((uint8_t *)(0)))) {
    {
      (void)(free(k));
    }
    return 1;
  }
  if ((m ==((uint8_t *)(0)))) {
    {
      (void)(free(k));
      (void)(free(c));
    }
    return 1;
  }
  {
    (void)(driver_asm_work_p_set(ap_kind(), k));
    (void)(driver_asm_work_p_set(ap_code(), c));
    (void)(driver_asm_work_p_set(ap_msg(), m));
    (void)((rc = rt_ab_step_read_pp()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_early()));
  }
  if ((rc ==2)) {
    {
      (void)((rc = driver_asm_work_i_get(ai_ec())));
      (void)(driver_asm_work_cleanup());
    }
    return rc;
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_parse()));
  }
  if ((rc ==2)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 0;
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_load_deps()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_open_out()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_prerun()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_pipeline()));
  }
  if ((rc !=0)) {
    {
      (void)(driver_asm_work_cleanup());
    }
    return 1;
  }
  {
    (void)((rc = rt_ab_step_finish()));
    (void)(driver_asm_work_cleanup());
  }
  return rc;
}
